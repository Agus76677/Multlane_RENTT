1. 你是数字IC/密码硬件加速方向的资深工程师。现在需要在“RPMA/”工程基础上，逐步改造 RBFU（当前已精简为仅 PIPE1 版本），使其支持：
   - 混合基：radix-4 为主 + 可配置退化为 radix-2（不额外例化新的“基2蝶形单元”，必须复用同一条数据通路 + mux 退化）
   - 同一混合基蝶形单元支持 NTT / INTT / PWM
   - PWM 必须只在 radix-4 语义下执行，并利用 4PE 结构优势：同一个 opcode==PWM，在 RBFU 内部用“两拍流水”完成完整 PWM（不再暴露 PWM0/PWM1 两个 opcode，也禁止 PWM 在 radix-2 下运行）
   - 单元级可验证：建立 python goldenmodel + iverilog testbench，对改进后的 RBFU 做 NTT/INTT/PWM 覆盖测试（先只测 RBFU 单元，不集成全系统）

   工程目录：
   - RPMA/：目标改造工程（以此为基准）
   - CFNTT/：参考工程（仅用于 radix-4 4PE/compact_bf 的结构组织思路）
   仿真工具：iverilog（Verilog-2001；不要用 SystemVerilog 语法）

   ========================================
   (0) 新增硬约束（必须严格遵守）
   ========================================
   0.1 模运算单元必须复用 RPMA/basic_unit 下已有实现：
   - 模加、模减、模乘、div2（half_mod）等严格使用 RPMA/basic_unit 里的现成模块
   - 禁止新增任何“功能相同”的新模块（哪怕代码更短也不允许）
   - 需要的只是“连接与组合”，而不是重新写 add/sub/mul/div2

   0.2 只实现 PIPE1：
   - RPMA/basic_unit 的 Modmul 及其底层 bitmod 系列单元原本包含大量 `ifdef PIPE 分支
   - 你现在只需要保证“PIPE1 定义下”功能正确；不要再引入 PIPE2/PIPE3，不要恢复复杂 `ifdef 树
   - RBFU.v 也已精简为仅 PIPE1：新增逻辑按 PIPE1 风格组织

   0.3 basic_unit 黑盒契约（强制遵守，禁止下钻）：
   - MA/MS/Div2：纯组合逻辑（同周期输入变化 -> 输出变化）
   - Modmul：PIPE1 下为 1-cycle 时延（输入在 cycle t 打入，乘积在 cycle t+1 输出有效）
   - 重要：禁止深入探索/重写/改动 Modmul 的最底层构成单元：
     bitmod_wocsa3.v / Hybrid_compress_wocsa3.v / CSA1.v / CSA2.v / sel_*.v
     只把 Modmul 当作“1-cycle 延迟的模乘黑盒”使用即可
   - 不需要理解 bit-level 约减细节；只需要按上述延时对齐流水即可

   0.4 opcode 合并为三种（旧版 4 种 -> 新版 3 种）：
   - // opcode:00 NTT
   - // opcode:01 INTT
   - // opcode:10 PWM
   - // opcode:11 预留（不要用于 PWM1；PWM0/PWM1 已被 RBFU 内部两拍合并）
   并且：
   - PWM 仅允许在 radix_mode=RAD4 时执行
   - 若 radix_mode=RAD2 且 opcode==PWM：视为非法输入（RBFU 可输出 0/保持旧值均可，但 tb 不会生成这种用例；建议 tb 里直接避免）

   0.5 代码风格必须严格参考 RPMA 习惯（非常重要）：
   - case(opcode) 只做“不同 opcode 下最终选择/输出哪些数值（Dout0..3）以及必要的控制选择”
   - 所有具体运算过程（中间量计算、mul/add/sub/div2 的实例化与组合）必须放在 case 语句之外
   - 这样便于后续插入流水寄存器；不要把长运算链塞进 case 分支内部

   0.6 DSP/Modmul 复用硬约束（必须执行，否则视为失败）：
   - RBFU 内部“只允许例化 4 个 Modmul”（对应 4 个 DSP；与 CFNTT compact butterfly 思路一致）
     允许的形式：u_mul0/u_mul1/u_mul2/u_mul3（名字可不同，但实例个数必须=4）
   - 禁止为“rad2/rad4/ntt/intt/pwm”分别例化独立 Modmul（禁止出现 10+ 个 Modmul 实例）
   - 所有 NTT/INTT/PWM/RAD2 所需乘法必须通过：
     “4个共享 Modmul + 输入操作数 MUX + 寄存对齐（time-multiplex）”实现

   0.7 禁止“并行展开候选输出网络”：
   - 不允许在 case 外部同时生成 rad2_ntt、rad2_intt、rad4_ntt、rad4_intt、pwm 等所有候选输出并各自带独立 Modmul
   - 正确做法：只计算“当前拍需要的那组中间量”，乘法统一走共享 mul_pool，并通过寄存器/标签对齐输出

   ========================================
   (1) 必须写进 prompt 的数学公式
   ========================================
   模数：q = 3329
   Kyber N=256 常量：
   - zeta = 17
   - I = ω4 = zeta^(N/4) mod q = 1729
   - I_inv = I^{-1} mod q（在 python golden 中用 pow(I,q-2,q) 求；硬件里用 ROM 常量或预计算输入）
   - inv2 = (q+1)/2 = 1665

   基础运算定义（硬件实现必须严格对应到 RPMA/basic_unit 现有模块；所有“+/-”必须显式用 MA/MS 表示，所有“/2”必须显式用 Div2 表示）：
   - MA(x,y)     = (x+y) mod q          // 复用 RPMA/basic_unit/MA（组合）
   - MS(x,y)     = (x - y) mod q        // 复用 RPMA/basic_unit/MS（组合）
   - Modmul(x,y) = (x*y) mod q          // 复用 RPMA/basic_unit/Modmul（PIPE1：1-cycle）
   - Div2(x)     = x/2 mod q            // 复用 RPMA/basic_unit/Div2（组合）

   radix-4 twiddle 记为 (w1,w2,w3)

   ----------------------------------------
   (1.1) radix-4 NTT（输出顺序必须固定）
   ----------------------------------------
   输入 4 点：a0,a1,a2,a3 ∈ Z_q
   twiddle：w1,w2,w3 ∈ Z_q
   常量：I=ω4

   计算（全部用 MA/MS/Modmul 表示）：
   T0 = MA(a0, Modmul(a2, w2))
   T1 = MS(a0, Modmul(a2, w2))
   T2 = MA(Modmul(a1, w1), Modmul(a3, w3))
   T3 = MS(Modmul(a1, w1), Modmul(a3, w3))
   T4 = Modmul(T3, I)

   y0 = MA(T0, T2)
   y2 = MS(T0, T2)
   y1 = MA(T1, T4)
   y3 = MS(T1, T4)

   NTT 模式输出映射（必须固定）：
   Dout0=y0, Dout1=y2, Dout2=y1, Dout3=y3

   ----------------------------------------
   (1.2) radix-4 INTT（输入/输出顺序必须固定）
   ----------------------------------------
   INTT 输入端口喂入顺序为： (y0, y2, y1, y3)   // 注意 y2/y1 交换

   计算（注意：Div2 的输入必须是 MA/MS 的输出，禁止写成 Div2(y0+y2) 这种形式）：
   T0 = Div2( MA(y0, y2) )
   T2 = Div2( MS(y0, y2) )
   T1 = Div2( MA(y1, y3) )
   T3 = Modmul( Div2( MS(y1, y3) ), I_inv )

   a0 = Div2( MA(T0, T1) )
   a2 = Modmul( Div2( MS(T0, T1) ), w2 )
   a1 = Modmul( Div2( MA(T2, T3) ), w1 )
   a3 = Modmul( Div2( MS(T2, T3) ), w3 )

   INTT 模式输出映射：
   Dout0=a0, Dout1=a1, Dout2=a2, Dout3=a3

   ----------------------------------------
   (1.3) radix-2 NTT/INTT（RAD2 必须与旧 RBFU 完全一致）
   ----------------------------------------
   两对点：
   (a0,b0,w0) -> Dout0,Dout1
   (a1,b1,w1) -> Dout2,Dout3

   radix-2 NTT（全部用 MA/MS/Modmul 表示）：
   Dout0 = MA(a0, Modmul(b0, w0))
   Dout1 = MS(a0, Modmul(b0, w0))
   Dout2 = MA(a1, Modmul(b1, w1))
   Dout3 = MS(a1, Modmul(b1, w1))

   radix-2 INTT（Div2 输入必须是 MA/MS 输出）：
   Dout0 = Div2( MA(a0, b0) )
   Dout1 = Modmul( Div2( MS(b0, a0) ), w0 )
   Dout2 = Div2( MA(a1, b1) )
   Dout3 = Modmul( Div2( MS(b1, a1) ), w1 )

   ----------------------------------------
   (1.4) PWM（一个 opcode==PWM，RAD4 下两拍流水完成完整 PWM）
   ----------------------------------------
   输入：
   f0,f1,g0,g1 ∈ Z_q
   tw ∈ Z_q（PWM twiddle，上层/ROM 产生；本次单元测试直接当输入端口）

   第1拍（PE0 与 PE2）：产生 PWM0 中间量并寄存（全部用 MA/MS/Modmul 表示）
   s0 = MA(f0, f1)
   s1 = MA(g0, g1)
   m0 = Modmul(f0, g0)
   m1 = Modmul(f1, g1)

   第2拍（PE1 与 PE3）：使用中间量完成 PWM1，输出最终结果
   h0 = MA(m0, Modmul(m1, tw))
   h1 = MS( Modmul(s0, s1), MA(m0, m1) )   // 等价于 (s0*s1 - m0 - m1) mod q

   PWM 输出映射（固定）：
   Dout0=h0, Dout1=h1, Dout2=0, Dout3=0

   ----------------------------------------
   (1.5) 共享DSP/共享Modmul 的工程化复用规则（必须落实到代码）
   ----------------------------------------
   目标：RBFU 内仅 4 个 Modmul（PIPE1：每个 1-cycle），完成 RAD4-NTT / RAD4-INTT / RAD4-PWM / RAD2-NTT/INTT 的全部乘法需求。
   方法：建立“mul_pool(4个Modmul) + operand MUX + 寄存对齐 +（必要时）tag”。

   (1) 固定 4 个 Modmul 实例（禁止增减）：
   - u_mul0, u_mul1, u_mul2, u_mul3：每个有输入 mulX_a/mulX_b，输出 mulX_p（1-cycle 有效）
   - 所有乘法任务只能通过这四个实例完成

   (2) 为每个 Modmul 做输入选择（operand MUX）：
   - mulX_a 从若干“候选操作数”中选（a*/b*/f*/g*/T3_reg/d_reg/v*_reg/m1_reg/s0_reg 等）
   - mulX_b 从若干“候选系数”中选（w0/w1/w2/w3/I/I_inv/tw_pwm 等）
   - 选择信号 sel_mulX_a/sel_mulX_b 由控制逻辑产生（case 里只设置选择，不写运算）

   (3) RAD4-NTT：3个输入乘法 + 1个 ω4 乘法用流水复用（利用 Modmul 1-cycle）：
   - Cycle t：u_mul0=a2*w2，u_mul1=a1*w1，u_mul2=a3*w3，u_mul3=T3_prev*I
   - Cycle t+1：mul0_p/mul1_p/mul2_p 对应 a2w2/a1w1/a3w3；mul3_p 对应 T4_prev
     用组合 MA/MS 生成 T0/T1/T2/T3，并寄存 T3；同时用 T4_prev 与寄存的 T1_prev 生成 y1/y3_prev

   (4) RAD4-INTT：错峰调度（仍只用4个Modmul）：
   - Stage A（Cycle t）：用 MA/MS/Div2 先得到 u0/u1/u2 与 d=Div2(MS(y1,y3))，并令 u_mul3 = d*I_inv
   - Stage B（Cycle t+1）：用组合得到 a0 与 v1/v2/v3，并令：
     u_mul0=v2*w2，u_mul1=v1*w1，u_mul2=v3*w3
     （a0 通过寄存对齐与 a1/a2/a3 同时输出）

   (5) RAD4-PWM：两拍完成，完全复用 mul_pool（Modmul 1-cycle）：
   - PWM Stage0（Cycle t）：u_mul0=f0*g0 -> m0；u_mul1=f1*g1 -> m1；同时组合出 s0/s1 并寄存
   - PWM Stage1（Cycle t+1）：u_mul2=m1*tw -> m1tw；u_mul3=s0*s1 -> s0s1；
     组合出 h0/h1，输出 (h0,h1,0,0)

   (6) RAD2-NTT/INTT：借用 u_mul0/u_mul1 完成 2 次乘法，其余空闲：
   - RAD2 NTT：u_mul0=b0*w0，u_mul1=b1*w1
   - RAD2 INTT：u_mul0=Div2(MS(b0,a0))*w0，u_mul1=Div2(MS(b1,a1))*w1

   (7) tag/对齐要求：
   - 因 Modmul 为 1-cycle，所有依赖乘法结果的 MA/MS/Div2 必须在下一拍使用对应 mul*_p
   - 若 tb 会连续切换 opcode/radix_mode，需加入最小 tag 管线（op_pipe/radix_pipe/valid_pipe）与数据同步
   - 单元 tb 初期可采用“同一模式连续输入一段 + 需要时插泡泡”降低 tag 复杂度，但 RTL 结构应能后续加 tag

   ========================================
   (2) 代码改造任务清单（必须产出可跑的 iverilog 单元测试）
   ========================================

   A. 阅读/定位（不要改动全系统）
   1) RPMA/ 中定位：
   - 已优化后的 RBFU.v（仅 PIPE1）
   - RPMA/basic_unit 下的 MA/MS/Modmul/Div2 等模块（路径要写死为现存文件）
   - opcode 宏定义所在文件（parameter.v 或等效）

   2) CFNTT/ 中定位 compact_bf / 4PE，仅用于参考 “T0/T1/T2/T3 组织方式、输出顺序”，不要把 CFNTT 的模运算模块拷入。

   B. opcode 更新（三种 opcode）
   1) 在 parameter.v（或等效宏文件）中更新 opcode：
       `define NTT   2'b00
       `define INTT  2'b01
       `define PWM   2'b10
       // 2'b11 预留
   2) RBFU.v 内 case(opcode) 只处理这三类；PWM0/PWM1 的旧分支删除或屏蔽（但不要引入新 ifdef 树）。

   C. RBFU 接口与模式控制（保持 RPMA 风格）
   1) 在 RBFU 端口新增：
   - input radix_mode;  // 0=RAD2(退化/兼容), 1=RAD4
   2) radix-4 NTT/INTT 新增第三个 twiddle 端口：
   - input [DW-1:0] rbfu_w2;  // RAD4 时 w3；RAD2 时忽略
   3) PWM twiddle 端口（建议新增，避免混用 NTT twiddle）：
   - input [DW-1:0] rbfu_tw_pwm;

   端口解释（写在注释里，且用于 python/tb 一致）：
   - RAD4 且 opcode==NTT/INTT：
     a0=rbfu_a0, a1=rbfu_b0, a2=rbfu_a1, a3=rbfu_b1
     w1=rbfu_w0, w2=rbfu_w1, w3=rbfu_w2
   - RAD2 且 opcode==NTT/INTT：
     pair0: (a0=rbfu_a0,b0=rbfu_b0,w0=rbfu_w0)
     pair1: (a1=rbfu_a1,b1=rbfu_b1,w1=rbfu_w1)
   - PWM 仅在 RAD4 执行：
     f0=rbfu_a0, g0=rbfu_b0, f1=rbfu_a1, g1=rbfu_b1, tw=rbfu_tw_pwm

   D. RBFU 内部实现（严格按 RPMA 风格组织 + 必须满足DSP复用 + 只实现PIPE1）
   1) 只例化 4 个 Modmul（mul_pool），其余全部删除：
   - u_mul0/u_mul1/u_mul2/u_mul3：全部来自 RPMA/basic_unit/Modmul（PIPE1：1-cycle）
   - 同时例化需要的 MA/MS/Div2（来自 basic_unit，组合）
   - 为 u_mul0..u_mul3 建立 operand MUX（mulX_a/mulX_b）与选择信号（sel_mulX_a/sel_mulX_b）

   2) “运算过程”放在 case 之外（但不是并行展开候选输出）：
   - case 外只建立：
     - operand MUX 网络（由 sel_* 驱动）
     - 4 个 Modmul 实例
     - 为 NTT/INTT/PWM 所需的中间量寄存器链（如 T3_reg、T0/T1/T2_reg、u0/u1/u2_reg、pwm_*_reg 等）
     - 由 mul_pool 输出驱动的 MA/MS/Div2 组合/寄存逻辑
   - 严禁同时做出 “rad2_ntt_out*、rad2_intt_out*、rad4_ntt_out*、rad4_intt_out*、pwm_out*” 且每一路各自占用独立 Modmul

   3) case(opcode) 仅做控制选择（RPMA 风格）：
   - 只在 case 内设置：
     - sel_mul0_a/sel_mul0_b ... sel_mul3_a/sel_mul3_b
     - 各级寄存器 enable（如 ntt_stage_en/intt_stage_en/pwm_stage_en）
     - 输出选择 out_sel（从“当前流水级已对齐的输出寄存器”中选）
   - 不要在 case 内写长运算链

   4) Div2 使用规则（严格）：
   - 所有 Div2 的输入必须是 MA/MS 的输出（Div2(MA(...)) 或 Div2(MS(...))）
   - 禁止出现 Div2(x+y) / Div2(x-y) 形式

   5) 禁止深入研究 bitmod 底层文件（强制）：
   - 不要阅读/改动/引用 bitmod_wocsa3.v、Hybrid_compress_wocsa3.v、CSA1.v、CSA2.v、sel_*.v 的内部逻辑
   - 只把 Modmul 当作“1-cycle 模乘黑盒”使用，按延时对齐即可

   E. python goldenmodel + 向量生成（tb 直接测最终 PWM）
   在 RPMA/software/ 下新增：
   - gm_rbfu_hybrid.py：实现 RAD2 NTT/INTT（对齐旧）+ RAD4 NTT/INTT（按(1.1)(1.2)）+ PWM（按(1.4)，两拍不影响数学结果）
   - gen_vec_rbfu_hybrid.py：生成向量文件

   向量格式（每行空格分隔，hex）建议：
     radix_mode opcode a0 b0 a1 b1 w0 w1 w2 tw_pwm exp0 exp1 exp2 exp3
   规则：
   - NTT/INTT：tw_pwm 填 000
   - PWM：w0/w1/w2 可填 000（若实现不用），tw_pwm 必填
   - tb 不生成 RAD2+PWM 向量

   随机覆盖建议（每类 >= 1000）：
   - RAD4：NTT / INTT / PWM（完整 PWM 最终 h0/h1）
   - RAD2：NTT / INTT（回归对齐旧 RBFU）

   F. iverilog testbench（RPMA 风格，先保守 LAT）
   在 RPMA/Testbench/ 下新增 tb_rbfu_hybrid.v：
   - $fscanf 读向量
   - 每行向量打一拍输入
   - 等待足够保守 LAT 后比对 Dout0..3
     （先用固定大值，例如 80 cycles，覆盖 Modmul 1-cycle + PWM 两拍 + 可能的对齐寄存；功能通了再收敛 LAT）
   - 输出 PASS/FAIL 统计

   G. 一键脚本
   在 RPMA/ 下提供 run_rbfu_tb.sh 或 Makefile：
   - iverilog 编译包含：RBFU.v + RPMA/basic_unit 下依赖模块 + parameter.v + tb_rbfu_hybrid.v
   - vvp 运行

   ========================================
   (3) 本次验收标准（必须达成）
   ========================================
   1) iverilog 下 tb_rbfu_hybrid.v 一键 PASS
   2) 覆盖：
   - RAD4: NTT / INTT / PWM（PWM 为 opcode==PWM 的最终结果）
   - RAD2: NTT / INTT（与旧 RBFU 输出一致）
   3) 所有模运算均来自 RPMA/basic_unit 现有模块；禁止新增同功能模块
   4) case 风格符合 RPMA：case 只选输出与控制；运算过程放在 case 外
   5) DSP 资源验收（必须满足）：
   - RBFU 内 Modmul 实例数 = 4（对应综合 DSP≈4；必须从 15 显著降到 4~5 量级）
   - 禁止出现“按模式堆叠”的 Modmul 实例列表（如 u_rad2_*、u_r4_*、u_pwm_* 同时存在）
   6) PIPE 约束验收：
   - 仅 PIPE1 工作；不引入 PIPE2/PIPE3；basic_unit 底层 bitmod 文件不做改动

   ========================================
   (4) 你需要输出给我的内容
   ========================================
   1) 修改/新增文件清单（相对路径）
   2) RBFU 新端口与映射说明（RAD4 NTT/INTT 映射、PWM 映射、PWM 仅 RAD4）
   3) 共享 mul_pool 的选择表（至少列出 NTT/INTT/PWM/RAD2 各阶段 mul0..mul3 的 operand 选择）
   4) 如何运行（python 生成向量 + iverilog 编译 + vvp 运行命令）
   5) 简短说明：在 Modmul=1-cycle、MA/MS/Div2=comb 的 PIPE1 条件下，寄存哪些中间量、最终输出何时有效
