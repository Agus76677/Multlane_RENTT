# Pure Radix-4 + 4PE 改造笔记（N=256, Kyber）

## 1. 目标与硬约束
- N = 256, q = 3329
- 纯 radix-4：stage 数 = log4(256) = 4（stage=0..3）
- 硬件配置：4PE，综合目标 DSP = 4
- stage=0 的 butterfly stride = 64（访存上必须能观察到）
- 关键经验：radix-4 在 PWM 映射上天然更顺，不应引入大量分支 mux；radix-2 映射 PWM 容易产生 mux 缺陷。

## 2. stage / stride（必须对齐 addr_gen 与 fsm）
对 N=256 的 radix-4：
- stage0: stride = 64
- stage1: stride = 16
- stage2: stride = 4
- stage3: stride = 1

每个 radix-4 butterfly 访问四点：
{ base,
  base + stride,
  base + 2*stride,
  base + 3*stride }

其中 base 的遍历方式由 fsm 的 (k/j/组号) 定义，但必须保证：
- 每 stage 覆盖全部 256 点
- 同 cycle 内多组 butterfly 的地址不会 bank 冲突（依赖 conflict_free_map）

## 3. Radix-4 DIT 迭代算法（用 φ 的 2N-th 根形式）
采用 CFNTT 风格的 radix-4 DIT 表达：
- φ：2N-th primitive root（即 512-th root），满足 φ^(2N) = 1，Kyber 下选 primitive_root=17 → φ = 17^((q-1)/(2N)) mod q
- ω1：4-th primitive root（对应“i”的角色，用于 T3 的旋转），ω1 = φ^(N/4) mod q

对每个 stage p：
- J = 4^p
- ωm = φ^( N / (4J) )

对每个 (k, j)：
令四个输入为：
A0 = A[4kJ + j]
A1 = A[4kJ + j + J]
A2 = A[4kJ + j + 2J]
A3 = A[4kJ + j + 3J]

定义（注意指数里是 (2j+1) 这种“奇数项”）：
T0 = ( A0 + A2 * ωm^( 2*(2j+1) ) ) mod q
T1 = ( A0 - A2 * ωm^( 2*(2j+1) ) ) mod q
T2 = ( A1 * ωm^( (2j+1) ) + A3 * ωm^( 3*(2j+1) ) ) mod q
T3 = ( A1 * ωm^( (2j+1) ) - A3 * ωm^( 3*(2j+1) ) ) mod q

输出更新：
A[4kJ + j      ] = (T0 + T2) mod q
A[4kJ + j + J  ] = (T1 + T3 * ω1) mod q
A[4kJ + j + 2J ] = (T0 - T2) mod q
A[4kJ + j + 3J ] = (T1 - T3 * ω1) mod q

实现提示：
- 这天然是“两层(two-layer)”结构：T0/T1 一层，T2/T3 一层，再做合成写回
- ω1 是常量（对 Kyber 固定），可用 CSA/常数乘优化，不一定强制占 DSP

## 4. Twiddle ROM 的组织（tf_ROM + tf_address_generator）
radix-4 每 stage 的 j 取值范围：
- stage0: j∈[0,1)
- stage1: j∈[0,4)
- stage2: j∈[0,16)
- stage3: j∈[0,64)

tf_address_generator 需要输出每个 butterfly 所需的 twiddle：
- ωm^(2*(2j+1)), ωm^( (2j+1) ), ωm^(3*(2j+1)), 以及常量 ω1
建议 ROM 以 “stage + j + lane_id” 组织成向量输出：
- 每拍输出一组 twiddle 向量（满足 4PE 并行需求）
- ROM 若带宽不足：优先“加宽一次性输出向量”，不要复制多个 ROM

必须新增脚本 gen_tf_rom_radix4.py：
- 输入：q, N, φ, ω1（脚本内置：q=3329, primitive_root=17, φ/ω1 自动推导）
- 输出：tf_ROM_radix4.v（mem 封装）+ tf_rom_radix4.mem + tf_rom_debug.txt（前几组便于 spot-check）
- 生成顺序：按 stage 依次输出 j=0..4^stage-1 的向量，地址从 stage0 累加到 stage3。

## 5. RPMA conflict_free_map（地址映射必须以此为基线）
地址 a -> (BI, BA)：
- t = XOR(a[n-1:m])   （按论文 Alg.2 的定义）
- S = t << ps
- BI = (a[m-1:0] + S) mod M
- mode=1 时：BI = (BI + p) mod M
- BA = a[n-1:m] + offset * (N/M)

要求：
- radix-4 同 cycle 的 4 个地址落在不同 bank
- 满足 RAW：读写间隔至少 L+1

## 6. “改为基4需要改哪些点”清单（路线B）
1) fsm：stage 0..3；每 stage 的循环/使能/finish 延时对齐按新流水重算
2) addr_gen：输出四点索引；stage0 stride=64；PWM 路径减少 mux
3) memory_map/arbiter/network_*：按 conflict_free_map 重新核对同拍无冲突；端口打包/lanes 对齐
4) tf_address_generator + tf_ROM：radix-4 twiddle 集合与地址规则重做；脚本自动生成 ROM 内容
5) RBFU：升级为 radix-4 butterfly（two-layer），保持 CSA/压缩树约减风格；DSP=4
6) polytop_RE 顶层：打包解包、lane 映射、shift 对齐常数按新总延迟重算
