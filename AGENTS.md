

你是数字IC/密码硬件加速方向的资深工程师。请在 **RPMA/** 工程基础上，逐步改造 **RBFU（仅 PIPE1）**，实现：
- **混合基**：RAD4 为主 + 可配置退化为 RAD2（同一条数据通路 + MUX 退化；禁止额外例化“基2蝶形单元”）
- **同一单元支持**：NTT / INTT / PWM
- **PWM 仅在 RAD4 语义执行**，并利用 4PE 优势：**opcode==PWM** 在 RBFU 内部 **两拍流水**完成完整 PWM（禁止 PWM0/PWM1 外部 opcode；禁止 RAD2 下 PWM）
- **单元级可验证**：用 **iverilog** 本地仿真 PASS（先测 RBFU 单元，不集成全系统）

工程目录：
- `RPMA/`：目标改造工程（以此为基准）
- `CFNTT/`：参考工程（只参考 compact_bf/4PE 的组织方式，不拷贝模运算模块）
仿真工具：`iverilog`（Verilog-2001；禁止 SystemVerilog）

---

## 0. 顶层硬规则（必须执行）

### 0.1 只实现 PIPE1
- **RBFU.v 只保留 PIPE1 风格**，禁止引入 PIPE2/PIPE3 或复杂 `ifdef` 树。
- basic_unit 中 **Modmul 及其底层 bitmod 系列**同样只需保证 PIPE1 正确；本任务禁止深挖/改写底层 bitmod。

### 0.2 basic_unit 黑盒契约（强制遵守，禁止下钻）
- `MA/MS/Div2`：**纯组合逻辑**（同周期更新）
- `Modmul`：**PIPE1：1-cycle 延时**（cycle t 输入 → cycle t+1 输出有效）
- **禁止**深入探索/重写/改动/讨论以下底层文件内部机理：
  - `bitmod_wocsa3.v`
  - `Hybrid_compress_wocsa3.v`
  - `CSA1.v`, `CSA2.v`
  - `sel_*.v`
- 你只需要把 `Modmul` 当作“**1-cycle 模乘黑盒**”并按延时对齐流水。

### 0.3 模运算必须复用 RPMA/basic_unit 现有模块（禁止新增同功能模块）
- `MA/MS/Modmul/Div2` 等严格使用 `RPMA/basic_unit/` 内现成模块
- 禁止新增任何功能等价的加/减/乘/除2模块（哪怕更短也不允许）

### 0.4 opcode 合并为三种
- `opcode:00 NTT`
- `opcode:01 INTT`
- `opcode:10 PWM`
- `opcode:11` 预留（不要作为 PWM1）
并且：
- `PWM` **仅允许** `radix_mode==RAD4`
- `radix_mode==RAD2 && opcode==PWM` 视为非法输入（RTL 可输出 0/保持旧值；**tb 不生成此用例**）

### 0.5 代码风格必须严格参考 RPMA（非常重要）
- `case(opcode)` **只做**：输出选择（Dout0..3）、必要的控制/选择信号（MUX sel、stage enable）
- 所有具体运算链（MA/MS/Div2/Modmul 实例化、组合与寄存器）必须放在 `case` 之外
- 便于后续插入流水寄存器；禁止把长运算链塞进 case 分支

### 0.6 DSP/Modmul 复用硬约束（必须，否则失败）
- **RBFU 内只允许例化 4 个 Modmul**（对应综合 ~4 DSP，目标从 15 降到 4~5 量级）
- 禁止按模式堆叠例化 `u_rad2_* / u_r4_* / u_pwm_*` 等多个 Modmul
- 所有模式乘法必须通过：
  **4个共享 Modmul + operand MUX + 寄存对齐（time-multiplex）** 实现
- 禁止“并行展开候选输出网络”（即同时生成 rad2/rad4/pwm 所有候选输出并各自带独立乘法器）

---

## 1. 不允许自动回滚（强制）
- **禁止 revert / reset / 回到旧 git 状态** 来“保护仓库”
- 如果某里程碑没完成：必须保证工程仍然 **可编译**，且之前已通过的子测试仍 **PASS**
- 每次提交都应是可运行状态（至少 iverilog 能编译；最好子测试 PASS）

---

## 2. 不提交测试向量文件（节省额度）
- **禁止提交**大规模测试向量文件到仓库
- 向量仅在本地运行时生成：
  - 写到 `RPMA/.tmp/` 或使用 stdout 管道
- 必须新增/更新 `.gitignore` 忽略：
  - `RPMA/.tmp/`
  - `*.vec`, `*.txt`（若用于临时向量）
- repo 只提交：RTL、tb、脚本、Python 生成器（不含生成出的向量数据）

---

## 3. 数学定义（必须严格一致）

### 3.1 常量
- `q = 3329`
- `zeta = 17`
- `I = ω4 = zeta^(N/4) mod q = 1729`
- `I_inv = I^{-1} mod q`（python: `pow(I,q-2,q)`，硬件可常量/输入）
- `inv2 = 1665`

### 3.2 基本运算（必须显式写）
- `MA(x,y) = (x+y) mod q`   // basic_unit/MA，组合
- `MS(x,y) = (x-y) mod q`   // basic_unit/MS，组合
- `Modmul(x,y) = (x*y) mod q` // basic_unit/Modmul，PIPE1：1-cycle
- `Div2(x) = x/2 mod q`     // basic_unit/Div2，组合
**Div2 输入必须是 MA/MS 输出**：只允许 `Div2(MA(...))` 或 `Div2(MS(...))`，禁止 `Div2(x+y)`。

---

## 4. 算法公式（固定，不得更改）

### 4.1 RAD4 NTT（输出顺序固定）
输入 `a0,a1,a2,a3`；twiddle `w1,w2,w3`；常量 `I`
```

T0 = MA(a0, Modmul(a2, w2))
T1 = MS(a0, Modmul(a2, w2))
T2 = MA(Modmul(a1, w1), Modmul(a3, w3))
T3 = MS(Modmul(a1, w1), Modmul(a3, w3))
T4 = Modmul(T3, I)

y0 = MA(T0, T2)
y2 = MS(T0, T2)
y1 = MA(T1, T4)
y3 = MS(T1, T4)

NTT 输出映射（必须固定）：
Dout0=y0, Dout1=y2, Dout2=y1, Dout3=y3

```
### 4.2 RAD4 INTT（输入/输出顺序固定）
INTT 输入端口喂入顺序：`(y0, y2, y1, y3)`（注意 y2/y1 交换）
```

T0 = Div2( MA(y0, y2) )
T2 = Div2( MS(y0, y2) )
T1 = Div2( MA(y1, y3) )
T3 = Modmul( Div2( MS(y1, y3) ), I_inv )

a0 = Div2( MA(T0, T1) )
a2 = Modmul( Div2( MS(T0, T1) ), w2 )
a1 = Modmul( Div2( MA(T2, T3) ), w1 )
a3 = Modmul( Div2( MS(T2, T3) ), w3 )

INTT 输出映射：
Dout0=a0, Dout1=a1, Dout2=a2, Dout3=a3

```
### 4.3 RAD2 NTT/INTT（必须与旧 RBFU 一致）
两对点：
- pair0: `(a0,b0,w0)->Dout0,Dout1`
- pair1: `(a1,b1,w1)->Dout2,Dout3`

RAD2 NTT：
```

Dout0 = MA(a0, Modmul(b0, w0))
Dout1 = MS(a0, Modmul(b0, w0))
Dout2 = MA(a1, Modmul(b1, w1))
Dout3 = MS(a1, Modmul(b1, w1))

```
RAD2 INTT：
```

Dout0 = Div2( MA(a0, b0) )
Dout1 = Modmul( Div2( MS(b0, a0) ), w0 )
Dout2 = Div2( MA(a1, b1) )
Dout3 = Modmul( Div2( MS(b1, a1) ), w1 )

```
### 4.4 PWM（opcode==PWM，RAD4 下两拍完成）
输入：`f0,f1,g0,g1`；`tw`
Stage0（第1拍）：
```

s0 = MA(f0, f1)
s1 = MA(g0, g1)
m0 = Modmul(f0, g0)
m1 = Modmul(f1, g1)

```
Stage1（第2拍）：
```

h0 = MA(m0, Modmul(m1, tw))
h1 = MS( Modmul(s0, s1), MA(m0, m1) )

```
输出映射：
`Dout0=h0, Dout1=h1, Dout2=0, Dout3=0`

---

## 5. 4×Modmul 复用的固定调度（按表实现，不得自行重排）

> Modmul 为 1-cycle；MA/MS/Div2 为组合。所有“使用乘法结果”的组合必须发生在下一拍或由寄存器对齐。

### 5.1 mul_pool 定义
仅允许 4 个实例：
- `mul0`, `mul1`, `mul2`, `mul3`
每个都有 `mulX_a`, `mulX_b`，输出 `mulX_p`（下一拍有效）。

必须为每个 mul 建立 operand MUX：
- `mulX_a` 从候选操作数中选
- `mulX_b` 从候选系数中选
选择信号只在 `case(opcode)` 里设置；MUX 与实例化在 case 外。

### 5.2 RAD4 NTT 调度（steady-state 友好）
Cycle t 设定 mul 输入：
- `mul0 = a2*w2`
- `mul1 = a1*w1`
- `mul2 = a3*w3`
- `mul3 = T3_prev * I`（用上一拍寄存的 `T3_reg`）

Cycle t+1 组合/寄存：
- 用 `mul0_p/mul1_p/mul2_p` 生成 `T0/T1/T2/T3`
- 将 `T3` 寄存为 `T3_reg`（供下一拍 mul3）
- 用 `mul3_p` 作为 `T4_prev` 与寄存对齐的 `T1_prev` 生成 `y1/y3`
- `y0/y2` 用对齐寄存的 `T0_prev/T2_prev` 生成
输出按 `(y0,y2,y1,y3)` 映射。

### 5.3 RAD4 INTT 调度（StageA/StageB 错峰）
StageA（Cycle t）：
- 组合得 `u0=Div2(MA(y0,y2))`, `u2=Div2(MS(y0,y2))`, `u1=Div2(MA(y1,y3))`
- 组合得 `d=Div2(MS(y1,y3))`
- `mul3 = d * I_inv`
- 寄存 `u0/u1/u2` 与模式 tag

StageB（Cycle t+1）：
- `T3 = mul3_p`
- 组合得：
  - `a0 = Div2(MA(u0,u1))`
  - `v2 = Div2(MS(u0,u1))`（->a2）
  - `v1 = Div2(MA(u2,T3))`（->a1）
  - `v3 = Div2(MS(u2,T3))`（->a3）
- 设定：
  - `mul0 = v2*w2`
  - `mul1 = v1*w1`
  - `mul2 = v3*w3`
- Cycle t+2：`mul0_p/mul1_p/mul2_p` 输出 a2/a1/a3，与 `a0` 寄存对齐后一起输出。

### 5.4 PWM 调度（两拍完成，可流式）
PWM Stage0（Cycle t）：
- `mul0 = f0*g0`（->m0）
- `mul1 = f1*g1`（->m1）
- 同周期组合 `s0=MA(f0,f1)`, `s1=MA(g0,g1)` 并寄存
- Cycle t+1：`m0/m1` 输出并寄存，连同 `s0/s1/tw` 寄存

PWM Stage1（Cycle t+1 设置 mul 输入）：
- `mul2 = m1 * tw`
- `mul3 = s0 * s1`
- Cycle t+2：
  - `h0 = MA(m0, mul2_p)`
  - `h1 = MS(mul3_p, MA(m0,m1))`
  - 输出 `(h0,h1,0,0)`

### 5.5 RAD2 调度（借用 mul0/mul1）
RAD2 NTT：
- `mul0=b0*w0`, `mul1=b1*w1`
RAD2 INTT：
- `mul0=Div2(MS(b0,a0))*w0`, `mul1=Div2(MS(b1,a1))*w1`
其余 mul2/mul3 空闲。

---

## 6. 里程碑驱动（强制按顺序推进；每步只测一种模式）

> 目标：避免“全向量全错”导致停摆。每完成一个里程碑必须本地 PASS，再进入下一个。

### Milestone A — 编译通过 + RAD2 回归（最小闭环）
- 只改必要文件：opcode 宏、RBFU 端口/框架
- 先保证 RAD2 NTT/INTT 与旧 RBFU 一致
- 运行：本地 `iverilog` + 小随机（50~200组）PASS

### Milestone B — 引入 4×Modmul mul_pool，但仍只跑 RAD2
- 删除所有“按模式堆叠”的 Modmul 实例
- 只保留 4 个 Modmul + operand MUX
- RAD2 小测试 PASS
- （可选）加入实例计数检查：grep/脚本统计 Modmul 实例数=4

### Milestone C — 仅 RAD4 NTT 打通
- 只生成 RAD4 NTT 用例（50~200）
- tb 只验证 NTT（不测 INTT/PWM）
- 失败时 tb 打印 mul0..mul3 的 a/b/p 与关键寄存（T3_reg 等）用于定位

### Milestone D — 仅 RAD4 INTT 打通
- 只生成 RAD4 INTT 用例（50~200）
- tb 只验证 INTT

### Milestone E — 仅 PWM 打通（两拍）
- 只生成 PWM 用例（50~200）
- tb 只验证 PWM 最终输出（h0/h1）

### Milestone F — 合并回归（可选，后做）
- 在 A~E 都 PASS 后再跑“混合模式分段”测试
- 初期不做每拍切换 opcode；先做“每段固定 opcode”降低 tag 需求

---

## 7. 测试与调试要求（必须执行）

### 7.1 不提交向量文件
- python 运行时生成到 `RPMA/.tmp/vec.txt`（gitignore）
- tb 从该文件读取，仿真结束后可删除

### 7.2 小样本优先
- 每个里程碑 50~200 组足够
- 出错时只打印**第一条失败向量**及关键内部信号（避免日志爆炸）

### 7.3 tb 必须具备“单失败向量深打印”
失败时打印：
- 输入：radix_mode, opcode, a0,b0,a1,b1,w0,w1,w2,tw
- 乘法器：mul0_a/mul0_b/mul0_p ... mul3_*
- 关键寄存：T3_reg、u0/u1/u2、pwm_m0_r/pwm_m1_r/s0_r/s1_r 等（按当前里程碑挑选）

---

## 8. 端口与映射（必须一致）

RBFU 端口新增：
- `input radix_mode;  // 0=RAD2, 1=RAD4`
- `input [DW-1:0] rbfu_w2;      // RAD4: w3 ; RAD2: ignore`
- `input [DW-1:0] rbfu_tw_pwm;  // PWM twiddle`

端口映射（必须写进注释，python/tb 一致）：
- RAD4 + NTT/INTT：
  - `a0=rbfu_a0, a1=rbfu_b0, a2=rbfu_a1, a3=rbfu_b1`
  - `w1=rbfu_w0, w2=rbfu_w1, w3=rbfu_w2`
- RAD2 + NTT/INTT：
  - pair0: `(a0=rbfu_a0,b0=rbfu_b0,w0=rbfu_w0)`
  - pair1: `(a1=rbfu_a1,b1=rbfu_b1,w1=rbfu_w1)`
- PWM（仅 RAD4）：
  - `f0=rbfu_a0, g0=rbfu_b0, f1=rbfu_a1, g1=rbfu_b1, tw=rbfu_tw_pwm`

---

## 9. 本次需要提交的内容（不含向量文件）
- 修改/新增文件清单（相对路径）
- RTL：RBFU 改造（PIPE1 + 4×Modmul）
- tb：`tb_rbfu_hybrid.v`（按里程碑可配置只测一种模式）
- Python：本地生成小样本向量（写入 RPMA/.tmp/）
- 脚本：`run_rbfu_tb.sh`（自动生成 vec -> iverilog -> vvp）
- `.gitignore`：忽略 `RPMA/.tmp/` 和 vec 文件

---

## 10. 运行方式（本地）
示例（可调整）：
1) `cd RPMA`
2) `./run_rbfu_tb.sh --mode rad2_ntt --n 200`
3) `./run_rbfu_tb.sh --mode rad2_intt --n 200`
4) `./run_rbfu_tb.sh --mode rad4_ntt --n 200`
5) `./run_rbfu_tb.sh --mode rad4_intt --n 200`
6) `./run_rbfu_tb.sh --mode pwm --n 200`

要求：每步 PASS 才进入下一步。

---

## 11. 输出要求（每次迭代必须给出）
1) 本轮里程碑与目标（1句话）
2) 修改/新增文件清单
3) 关键实现点（mul_pool 选择表/寄存对齐/输出有效拍）
4) 本地运行命令与结果（PASS/FAIL）
5) 若 FAIL：只给第一条失败向量的定位信息与下一步改动点（禁止 revert）

