`include "parameter.v"
//-通用map,适用于与N=256,R=2,PE=2，4,8,16等配置(双PE设计)
/*
把 addr_gen 给出的 逻辑地址 old_ie/old_io**
变成 物理存储地址：BA（bank 内地址）+ BI（bank 号），
并保证在多路并行访问时不会发生 bank 冲突（conflict-free）。

地址映射是组合逻辑，然后打一拍输出
*/
module memory_map(
input clk,
input rst,
input [1:0] opcode, 
input mode, 
//mode表示上下半区切换的模式bit，也对应论文中的mode
input offset,
//offset表示bank内地址的偏移，以及论文中PWM/INTT的多多项式/卷积偏移
input [7:0] old_ie0,
input [7:0] old_io0,
input [7:0] old_ie1,
input [7:0] old_io1,
//BI（bank index），表示2P个bank中的某一个
//BA（bank address），表示bank内的行地址
output  [`MAP-1:0] BI_ie0,
output  [`MAP-1:0] BI_io0,
output  [`MAP-1:0] BI_ie1,
output  [`MAP-1:0] BI_io1,
output  [7     :0] BA_ie0,
output  [7     :0] BA_io0,
output  [7     :0] BA_ie1,
output  [7     :0] BA_io1
);
//PE0
wire [7     :0] BA_ie_temp0;
wire [7     :0] BA_io_temp0;
wire [`MAP-1:0] BI_ie_temp0;
wire [`MAP-1:0] BI_io_temp0;

//原逻辑地址的低 MAP bit + 高位奇偶校验，提升到高位，做“行折叠” +  mode=1 时整体偏移 P（换另一半 bank）
//分开解释如下

//1. 直接用低位 bits 作为 bank 号的基础，表示在一个“大 tile”内的列索引；
//2. ^ 是 XOR 归约（奇偶校验），对高位 bits 做 parity，
//   左移 P_SHIFT = 在 BI 高位加 0 或 1 → 在“上/下半块 bank”之间切换；
//   → 这就是 conflict-free 的关键：不同 stage/行的访问会被折叠到不同 bank 半区。
//3. mode=1 时，再整体加上 P，相当于把访问从 bank[0..P-1] 换到 bank[P..2P-1]。
//对应论文中的Algorithm 2、Algorithm 7（mapping 规则）

// bank=f(stage,group,lane,index)
// addr_in_bank=g(index,offset)

//BA = (k mod 2P) ⊕ h(i,k)⊕mode⋅P
//BI = ⌊k/2P​⌋ +offset⋅2^(⋯)

assign BI_ie_temp0=old_ie0[`MAP-1:0] + ((^old_ie0[7:`MAP])<<`P_SHIFT) + ({`MAP{mode}}&`P);//mode
assign BI_io_temp0=old_io0[`MAP-1:0]+((^old_io0[7:`MAP])<<`P_SHIFT)+({`MAP{mode}}&`P);//mode

// 关于BA的组成 

// 1. 高位用零补齐（使宽度=8）；
// 2. 下边拼 offset + old_ie0[7:MAP]（高位 bits）做行地址；

// offset 在 PWM/INTT 中用于把“多多项式”分布到不同的行区间。

assign BA_ie_temp0={{(`MAP-1){1'b0}},offset,old_ie0[7:`MAP]};//offset
assign BA_io_temp0={{(`MAP-1){1'b0}},offset,old_io0[7:`MAP]};//offset

DFF #(.data_width(`MAP)) BI_ie0_inst(.clk(clk),.rst(rst),.d(BI_ie_temp0),.q(BI_ie0));
DFF #(.data_width(`MAP)) BI_io0_inst(.clk(clk),.rst(rst),.d(BI_io_temp0),.q(BI_io0));
DFF #(.data_width(8   )) BA_ie0_inst(.clk(clk),.rst(rst),.d(BA_ie_temp0),.q(BA_ie0));
DFF #(.data_width(8   )) BA_io0_inst(.clk(clk),.rst(rst),.d(BA_io_temp0),.q(BA_io0));

//PE1
wire [7     :0] BA_ie_temp1;
wire [7     :0] BA_io_temp1;
wire [`MAP-1:0] BI_ie_temp1;
wire [`MAP-1:0] BI_io_temp1;
wire RBFU_mode;
wire RBFU_offset;

// 在 NTT/INTT 模式下：
// PE1 和 PE0 用同样的 mode/offset 逻辑（只是 index 不同）。
// 在 PWM0/1 模式下：
// PE1 把 mode / offset 取反 → 访问 另一组 bank / 另一个“块”。

// 第一组多项式系数在某半区 bank，第二组系数经过循环移位映射到另一半区，
// 通过 mode/offset 翻转实现 并行且无冲突地访问两个多项式。

assign RBFU_mode   = (opcode == `PWM0 || opcode == `PWM1) ? ~mode : mode;
assign RBFU_offset = (opcode == `PWM0 || opcode == `PWM1) ? ~offset :offset; 
assign BI_ie_temp1=old_ie1[`MAP-1:0]+((^old_ie1[7:`MAP])<<`P_SHIFT)+({`MAP{RBFU_mode}}&`P);//mode
assign BI_io_temp1=old_io1[`MAP-1:0]+((^old_io1[7:`MAP])<<`P_SHIFT)+({`MAP{RBFU_mode}}&`P);//mode
assign BA_ie_temp1={{(`MAP-1){1'b0}},RBFU_offset,old_ie1[7:`MAP]};//offset
assign BA_io_temp1={{(`MAP-1){1'b0}},RBFU_offset,old_io1[7:`MAP]};//offset

DFF #(.data_width(`MAP)) BI_ie1_inst(.clk(clk),.rst(rst),.d(BI_ie_temp1),.q(BI_ie1));
DFF #(.data_width(`MAP)) BI_io1_inst(.clk(clk),.rst(rst),.d(BI_io_temp1),.q(BI_io1));
DFF #(.data_width(8   )) BA_ie1_inst(.clk(clk),.rst(rst),.d(BA_ie_temp1),.q(BA_ie1));
DFF #(.data_width(8   )) BA_io1_inst(.clk(clk),.rst(rst),.d(BA_io_temp1),.q(BA_io1));
endmodule




// module memory_map(
// input clk,
// input rst,
// input mode, 
// input offset,
// input [7:0] old_ie,
// input [7:0] old_io,
// output  [7     :0] BA_ie,
// output  [7     :0] BA_io,
// output  [`MAP-1:0] BI_ie,
// output  [`MAP-1:0] BI_io
// );

// wire [7     :0] BA_ie_temp;
// wire [7     :0] BA_io_temp;
// wire [`MAP-1:0] BI_ie_temp;
// wire [`MAP-1:0] BI_io_temp;

// assign BI_ie_temp=old_ie[`MAP-1:0]+((^old_ie[7:`MAP])<<`P_SHIFT)+({`MAP{mode}}&`P);//mode
// assign BI_io_temp=old_io[`MAP-1:0]+((^old_io[7:`MAP])<<`P_SHIFT)+({`MAP{mode}}&`P);//mode
// assign BA_ie_temp={{(`MAP-1){1'b0}},offset,old_ie[7:`MAP]};//offset
// assign BA_io_temp={{(`MAP-1){1'b0}},offset,old_io[7:`MAP]};//offset

// DFF #(.data_width(`MAP)) BI_ie_inst(.clk(clk),.rst(rst),.d(BI_ie_temp),.q(BI_ie));
// DFF #(.data_width(`MAP)) BI_io_inst(.clk(clk),.rst(rst),.d(BI_io_temp),.q(BI_io));
// DFF #(.data_width(8   )) BA_ie_inst(.clk(clk),.rst(rst),.d(BA_ie_temp),.q(BA_ie));
// DFF #(.data_width(8   )) BA_io_inst(.clk(clk),.rst(rst),.d(BA_io_temp),.q(BA_io));

// endmodule

//改为基4逻辑
/*
那么就要修改一下地址的映射关系
assign BI_ie_temp0 = old_ie0[`MAP-1:0] + ((^old_ie0[7:`MAP])<<`P_SHIFT) + ({`MAP{mode}}&`P);
assign BI_io_temp0 = ...
assign BA_ie_temp0 = {{(`MAP-1){1'b0}}, offset, old_ie0[7:`MAP]};
assign BA_io_temp0 = ...
// 以及 PE1 的同逻辑
*/