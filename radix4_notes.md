1. # Radix-4（纯基4）在 Multlane_RENTT（Kyber N=256, q=3329）中的实现笔记（v1→v2）

   > 目标：在当前工程（含 permute_network 优化版）基础上，将 NTT/INTT 改为 **纯 radix-4**，并采用 **4PE**（你当前定义下 P=4），同时允许 DSP 数量提升到 **4**。
   >
   > 指导句（必须长期遵守）：**“基4有天然优势在 PWM 的时候，不会引入很多分支 mux；radix2 在映射 PWM 有这个缺陷。”**

   ---

   ## 0. 现状与必须先修正的勘误（非常关键）

   ### 0.1 勘误 1：stage 编号与 stride=64 的关系（原 notes 有不一致）
   你已明确：**stage=0 的 butterfly stride 应当是 64**。

   这意味着硬件的 stage 顺序应当是（N=256）：

   - **stage0：stride=64**
   - **stage1：stride=16**
   - **stage2：stride=4**
   - **stage3：stride=1**

   也就是 radix-4 的 4 个 stage，从“跨得最大”到“跨得最小”。

   > 原 notes 如果写成 stage0 对应 J=1（或 stride=1），那就是把 stage 顺序写反了。  
   > 这会直接导致：tf ROM 的 stage 排布、tf_address_generator 的 stage 基址、以及 addr_gen 的 index 公式全部错位。

   ---

   ### 0.2 勘误 2：omega1 的定义（必须统一“PHI 是 2N-th root”还是 “PHI 是 N-th root”）
   在 Kyber 里常用：
   - g=17 是模 3329 的原根（primitive root）
   - 若令 **PHI = g^((q-1)/(2N))**，则 PHI 是 **2N=512-th primitive root**
   - 则 **W = PHI^2** 是 **N=256-th primitive root**

   Radix-4 蝶形里会出现一个“类似 i 的常量”，其阶为 4（fourth root of unity）：

   - 用 PHI（512-th root）表达：  
     **omega_i = PHI^(N/2) = PHI^128**（阶为 4）
   - 用 W（256-th root）表达：  
     **omega_i = W^(N/4) = W^64**（同一元素）

   > 因此：如果你的脚本里 PHI 是 2N-th root，那么 **omega1 不应该写成 PHI^(N/4)**。  
   > 必须改成 **PHI^(N/2)**，否则 omega1 阶不对。

   ---

   ### 0.3 勘误 3：Radix-4 ROM 的“每 stage 条目数”不是 J，而是 K=N/(4J)
   对每个 stage：
   - J = 4^(3-stage)（因为 stage0 stride=64，对应 J=64）
   - K = N / (4J)

   对于 N=256：
   - stage0：J=64 → K=1
   - stage1：J=16 → K=4
   - stage2：J=4  → K=16
   - stage3：J=1  → K=64

   总 ROM 深度：**1+4+16+64 = 85**

   > 原 notes 若把每 stage 条目数写成 1,4,16,64 但又把它当成 “j_span”，很容易混淆。  
   > 这 85 个条目应当对应 **(stage, k)** 的 twiddle 向量，而不是 (stage, j)。

   ---

   ## 1. Radix-4 索引公式（和 addr_gen 必须一致）

   采用标准 radix-4 结构（每个蝶形 4 点）：

   对给定 stage 和 (k, j)：
   - J = 4^(3-stage)
   - base = 4*k*J
   - 四个输入下标为：
     - idx0 = base + j
     - idx1 = base + j + J
     - idx2 = base + j + 2J
     - idx3 = base + j + 3J

   stride 就是 J（因为相邻点间隔为 J）：
   - stage0：J=64（stride=64）
   - stage1：J=16
   - stage2：J=4
   - stage3：J=1

   ---

   ## 2. Radix-4 twiddle 的结构（ROM 里到底要存什么）

   在 radix-4 DIF/DIT 的不同写法中，twiddle 的“放置点”略不同，但共同点是：

   - 每个 (stage, k) 会确定一组 twiddle：  
     **{w1, w2, w3}**（分别对应 W^k、W^(2k)、W^(3k) 一类的角色）
   - 以及一个常量 **omega_i（阶 4）** 用于处理 ±i 组合（对应 “不会引入很多分支 mux” 的硬件优势来源之一）

   工程实现建议（与你当前 ROM 打包方式一致）：
   - ROM 每个地址输出 4 个 12-bit：  
     **{w2, w1, w3, omega_i}**
   - 其中 omega_i 实际上是常量，但为了简化布线/对齐，允许“每条目重复存一次”。

   ---

   ## 3. tf_ROM 的地址规划（tf_address_generator 必须按这个来）

   ### 3.1 stage 的 k 数量表与基址
   定义 K(stage)=N/(4J)：
   - K0=1, K1=4, K2=16, K3=64

   定义 stage_base：
   - base0 = 0
   - base1 = 1
   - base2 = 1+4 = 5
   - base3 = 5+16 = 21

   因此 NTT 段地址：
   - addr = base[stage] + k
   - 范围 0..84

   ### 3.2 你当前工程里“原先的 OFFSET_TF_1/2”不能直接沿用
   你原 radix-2 设计的 tf_address_generator 是：
   - addr ≈ (stage_i << something) + (s >> P_SHIFT) + offset
   那是为 7 个 stage + 每 stage 128/P 个条目设计的。

   纯 radix-4 后：
   - stage 数变为 4
   - 每 stage 的 k 数为 [1,4,16,64]（总 85）
   - 所以必须换成 **stage_base + k** 的寻址逻辑

   ---

   ## 4. 端序（大小端）与 wa 反向映射：你应该发哪些 .v 我才能一锤定音

   要判断你 ROM 的 .mem 到底应该“大端打包还是小端打包”，只需要三份 RTL：

   1) **tf_ROM_radix4.v（或 tf_ROM.v）**  
      - 看 Q 的位拼接顺序：Q[MSB] 对应哪一个 twiddle

   2) **polytop_RE.v**（你已经给了关键片段）  
      - 看 `wa[i] = w[(P-1-i)*DW + ...]` 这种反向映射到底把 Q 的哪一段送到 wa[0]

   3) **RBFU.v**（最关键）  
      - 看 wa[0],wa[1],wa[2],wa[3] 分别被当作 w1/w2/w3/omega_i 的哪一个

   > 结论：你后续只要把 **RBFU.v** 贴出来（连同它对 wa 的使用顺序），我就能确定你 .py 里 pack 顺序到底该是 MSB→LSB 还是 LSB→MSB。

   ---

   ## 5. 结合当前 all_concat_radix4_v1.txt：纯 radix-4 需要改哪些 RTL（逐文件清单）

   > 原则：保持你现有的 bank 网络/arbiter/memory_map 框架不变，重点改 **fsm / addr_gen / tf_address_generator / tf_ROM / RBFU**。  
   > 目标：必须仿真通过。

   ### 5.1 parameter.v（先把“工程宏”改稳）
   - 固定阶段（当前版本先跑通）：**P=4（OP1）**
   - 新增或明确这些宏（示例命名）：
     - `RADIX4_EN`（开启 radix-4 路径）
     - `R4_STAGE_NUM = 4`
     - `ADDR_ROM_WIDTH = 7`（能覆盖 0..84）
     - `ROM_DEPTH = 85`（至少 NTT 段）
   - 如果你仍要保留 PWM1/INTT 的 ROM 分段：
     - `OFFSET_TF_INTT = 85`
     - `OFFSET_TF_PWM1 = 170`（是否需要取决于你 PWM1 是否仍用 ROM）
     - 总 ROM_DEPTH 按段叠加

   > 注意：你现在的 tf_ROM_radix4.v 里如果写死了 assert(P==4) + DEPTH=85，但 parameter.v 默认却是 OP0(P=2)，Vivado 会直接报错或行为不一致。  
   > 所以第一步必须把宏统一。

   ---

   ### 5.2 fsm.v（stage 数、stage 方向、以及新计数器）
   纯 radix-4 后：
   - NTT：stage 从 0→3（对应 stride 64→1）
   - INTT：stage 从 3→0（反向）

   你需要的不再是“7 stage + s_end=128-P”的结构，而是：
   - 每个 stage 有两个嵌套循环：
     - k：0..K(stage)-1（决定 twiddle 地址）
     - j：0..J(stage)-1（决定蝶形覆盖的索引）
   - 硬件上通常把 j 以 “每拍处理多少个蝶形” 来分块计数：
     - 每拍并行 radix-4 蝶形数量 = `P_HALF`（因为你现有结构每个 RBFU 处理 4 点）
     - 因此 j_block_count = ceil(J / P_HALF)

   fsm 输出信号：
   - `i`：建议仍叫 i，但语义变为 stage(0..3)
   - `s`：建议改成 “j_block” 或 “j_base”
   - 需要新增或复用一个寄存器保存 `k`

   并且：
   - wen/ren/en/finish 的对齐常数要重新标定  
     = bank 读延迟 + permute/network 延迟 + RBFU pipeline 延迟 + 写回延迟

   ---

   ### 5.3 addr_gen.v（把“旧的 ie/io 两点生成”改为“4 点生成”）
   你可以暂时不改端口名（仍输出 ie0/io0/ie1/io1），但**语义必须变成 4 个点**：

   对每个并行蝶形（b 表示第几个 RBFU）：
   - 计算 j = j_base + b
   - 计算 base = 4*k*J
   - 输出：
     - old_ie0 = base + j
     - old_io0 = base + j + J
     - old_ie1 = base + j + 2J
     - old_io1 = base + j + 3J

   这样 memory_map/arbiter/network 的接口可以先不动。

   ---

   ### 5.4 tf_address_generator.v（核心：stage_base + k）
   按 3.1 的 base 表做：
   - NTT：addr = base[stage] + k
   - INTT：addr = OFFSET_TF_INTT + base[stage] + k
   - PWM1：如果仍用 ROM，则 addr = OFFSET_TF_PWM1 + pwm_idx（取决于你 PWM1 的实现方式）

   > 你现在 all_concat 里那种 `(i << (7-P_SHIFT)) + (s >> P_SHIFT)` 必须干掉（这是 radix-2 时代的残留）。

   ---

   ### 5.5 tf_ROM_radix4.v（ROM 宽度/深度/ifdef）
   当前先跑通版本建议：
   - 输出宽度固定 48b（4×12），对应一组 {w2,w1,w3,omega_i}
   - 深度 = 85（或加上 INTT/PWM1 段）
   - 不要写死 A[7:0]，而是用 `ADDR_ROM_WIDTH`

   后续要支持多 OP：
   - 你可以保留输出仍为 48b（广播 twiddle），并让多个 RBFU 共用同一组 twiddle  
     （这要求你的调度是“并行在 j 维度”，而不是并行在 k 维度）
   - 如果未来你要并行在 k 维度，则 ROM 输出必须变宽（每个并行蝶形一组 48b）

   ---

   ### 5.6 RBFU.v（真正的 radix-4 蝶形 + DSP=4）
   你必须把 RBFU 从“两个 radix-2 蝶形”升级为“一个 radix-4 蝶形（4入4出）”。

   推荐的硬件友好写法（典型结构，具体乘法点位需与你选的 DIT/DIF 对齐）：
   1) 先做加减组合，尽量用 CSA/压缩树风格保留
   2) 用 omega_i 做一次“常量旋转”（等价于 i 或 -i 的那种结构）
   3) 对三路结果乘以 {w1,w2,w3}（这就是 DSP=4 的主要去向之一：3 个 twiddle mul + 1 个常量/或复用）
   4) opcode=NTT/INTT/PWM0/PWM1 下的差异：
      - NTT/INTT：蝶形路径启用
      - PWM0：点乘（不需要大量 mux，radix4 结构更顺）
      - PWM1：若仍保留 Kyber basemul 公式，需要把它映射到更规整的数据流（减少分支）

   ---

   ## 6. 为未来 OP（并行度）预留的空间（现在先写好“升级接口”）
   当前固定 P=4 跑通没问题，但你必须在代码结构上预留：
   - P 只通过 parameter.v 的 OPx 宏改变，不要散落 magic number
   - addr_gen 的 “每拍并行蝶形数量” 应当写成参数：
     - `R4_BFLY_PER_CYCLE = P_HALF`（在你当前结构里成立）
   - fsm 的 j_block 终值应当由 J(stage) 与 R4_BFLY_PER_CYCLE 计算得出，而不是写死常数
   - tf_ROM：
     - 当前可先广播 48b
     - 未来如果要扩展为多组 twiddle：建议输出总线宽度 = 48 * R4_BFLY_PER_CYCLE

   ---

   ## 7. 仿真必须通过：你现在遇到的 file open warning 的根因与规避方式
   你之前的 warning 本质上就是：
   - 仿真工作目录（xsim 的 cwd）与 `$readmemh/$fopen` 使用的相对路径不一致
   - 或者你引用了绝对路径，但工程实际路径变了

   建议：
   - ROM 的 mem 文件：放到 `sources_1/sim` 或者把它加入 Vivado “Simulation Sources”
   - tb 里尽量用相对路径，并保证路径相对于仿真 cwd 可达  
     （或者在 run.tcl 里显式 `cd` 到工程根目录）

   ---

   ## 8. 小结（你现在下一步要做什么）
   - 先把 **parameter.v 的 OP/P/ADDR_ROM_WIDTH/ROM_DEPTH** 统一
   - 然后按本 notes 改 **fsm / addr_gen / tf_address_generator / RBFU**
   - ROM 的 .mem 由 .py 脚本自动生成（这是必须的）
   - 最后必须跑通 tb（NTT→PWM→INTT 或者你当前 tb 的完整流程）
