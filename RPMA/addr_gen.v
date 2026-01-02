`timescale 1ns / 1ps
`include "parameter.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/18 16:36:19
// Design Name: 
// Module Name: addr_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module addr_gen(
input clk,
input rst,
input [5:0] i,//stage编号
input [6:0] s,//group编号
`ifdef OP0 //仅 1 bit 并行（2 个 BFU），b 表示当前是 lane0 还是 lane1
    input b,//当前拍中的第几个并行蝶形
`else
    input [`P_SHIFT-2:0] b, // 一般情况：b 是并行 lan e索引（宽度 = P_SHIFT-1）
`endif
input [1:0] opcode,
//ie0, io0, ie1, io1：本拍中要处理的两个蝶形的 4 个逻辑地址。分为lane0和lane1
output [7:0] ie0,
output [7:0] io0,
output [7:0] ie1,
output [7:0] io1
);

//NTT INTT的典型基2迭代地址

wire [7:0] j0;//高位块号
wire [7:0] k0;//低位块内偏移
wire [7:0] ie_NTT0;//左蝶点地址
wire [7:0] io_NTT0;//右蝶点地址

//PWM地址，定义为顺序扫描

wire [7:0] ie_PWM0;
wire [7:0] io_PWM0;

wire [7:0] j1;
wire [7:0] k1;
wire [7:0] ie_NTT1;
wire [7:0] io_NTT1;
wire [7:0] ie_PWM1;
wire [7:0] io_PWM1;
wire sel;
wire [7:0] ie0_temp;    
wire [7:0] io0_temp;    
wire [7:0] ie1_temp;    
wire [7:0] io1_temp;    

//================================================================
// 1. NTT/INTT 地址生成（radix-2 迭代形式）
//================================================================

// j = base >> (7 - i);           // 高位块号
// k = base & ((128 >> i) - 1);   // 低位块内偏移
// ie = j << (8 - i) + k;         // 左蝶点地址
// io = ie + (1 << (7 - i));      // 右蝶点地址

//ie,io分别对应公式中的index0​=j⋅2^{8−i}+k, index1​=index0​+2^{7−i}

`ifdef OP0
    // OP0：仅 1bit b，直接拼 { ... , 0 } / { ... , 1 }
    // base0 = { s高位 , 0 }，base1 = { s高位 , 1 }
    assign j0 ={s[6:`P_SHIFT],1'b0}>>(7-i); 
    assign k0 ={s[6:`P_SHIFT],1'b0}&(('d128>>i)-1);
    assign ie_NTT0 = (j0<<(8-i)) + k0;
    assign io_NTT0 = (j0<<(8-i)) + k0 + (1<<(7-i));

    assign j1 ={s[6:`P_SHIFT],1'b1}>>(7-i); 
    assign k1 ={s[6:`P_SHIFT],1'b1}&(('d128>>i)-1);
    assign ie_NTT1 = (j1<<(8-i)) + k1;
    assign io_NTT1 = (j1<<(8-i)) + k1 + (1<<(7-i));
`else
    // 一般情况：base0 = { s高位 , b , 0 } ; base1 = { s高位 , b , 1 }
    // 相当于在每个 group 内，b 选择并行 butterfly，末位 0/1 区分一对蝶形的左/右 Lane

    assign j0 ={s[6:`P_SHIFT],{b,1'b0}}>>(7-i); 
    assign k0 ={s[6:`P_SHIFT],{b,1'b0}}&(('d128>>i)-1);
    assign ie_NTT0 = (j0<<(8-i)) + k0;
    assign io_NTT0 = (j0<<(8-i)) + k0 + (1<<(7-i));
    assign j1 ={s[6:`P_SHIFT],{b,1'b1}}>>(7-i); 
    assign k1 ={s[6:`P_SHIFT],{b,1'b1}}&(('d128>>i)-1);
    assign ie_NTT1 = (j1<<(8-i)) + k1;
    assign io_NTT1 = (j1<<(8-i)) + k1 + (1<<(7-i));
`endif

//================================================================
// 2. PWM0 / PWM1 地址生成：顺序扫描
//================================================================

//在 PWM 阶段，每拍就是按“行优先 + lane 偏移”线性扫地址，不再是蝶形模式。
//PWM1 与 PWM0 地址完全一样，区别只在 twiddle 选取和 bank 映射。

//base=s⋅2^{P_SHIFT} + i⋅2^{P_SHIFT+1} 
//lane = (b << 1) + 0/1

//ie=base+(b≪1)+0 , io=base+(b≪1)+1

assign ie_PWM0 = {b,1'b0}+(s<<`P_SHIFT)+(i<<(`P_SHIFT+1));
assign io_PWM0 = {b,1'b1}+(s<<`P_SHIFT)+(i<<(`P_SHIFT+1));
assign ie_PWM1 = ie_PWM0;
assign io_PWM1 = io_PWM0;

assign sel=(opcode==`INTT||opcode==`NTT);
assign ie0_temp =sel ? ie_NTT0:ie_PWM0;
assign io0_temp =sel ? io_NTT0:io_PWM0;
assign ie1_temp =sel ? ie_NTT1:ie_PWM1;
assign io1_temp =sel ? io_NTT1:io_PWM1;

//打一拍寄存，保证 addr_gen 输出与后续模块在时序上对齐。
DFF #(.data_width(8)) dff_ie0(.clk(clk),.rst(rst),.d(ie0_temp),.q(ie0));
DFF #(.data_width(8)) dff_io0(.clk(clk),.rst(rst),.d(io0_temp),.q(io0));
DFF #(.data_width(8)) dff_ie1(.clk(clk),.rst(rst),.d(ie1_temp),.q(ie1));
DFF #(.data_width(8)) dff_io1(.clk(clk),.rst(rst),.d(io1_temp),.q(io1));
endmodule


// module addr_gen(
// input [5:0] i,
// input [6:0] s,
// input [4:0] b,
// input [1:0] opcode,
// output [7:0] ie,
// output [7:0] io
// );

// wire [7:0] j;
// wire [7:0] k;
// wire [7:0] ie_NTT;
// wire [7:0] io_NTT;
// wire [7:0] ie_PWM;
// wire [7:0] io_PWM;
// wire sel;

// //NTT or INTT
// assign j ={s[6:`P_SHIFT],b[`P_SHIFT-1:0]}>>(7-i); 
// assign k ={s[6:`P_SHIFT],b[`P_SHIFT-1:0]}&(('d128>>i)-1);
// assign ie_NTT = (j<<(8-i))+k;
// assign io_NTT = (j<<(8-i)) + k + (1<<(7-i));

// //PWM0,PWM1
// assign ie_PWM = (b<<1)+(s<<`P_SHIFT)+(i<<(`P_SHIFT+1));
// assign io_PWM = ie_PWM+'b1;

// assign sel=(opcode==`INTT||opcode==`NTT);
// assign ie =sel ? ie_NTT:ie_PWM;
// assign io =sel ? io_NTT:io_PWM;

// endmodule

//如果进行基4改动
// NTT or INTT 分支里 j0,k0,j1,k1 。改为以4^i为补偿的公式。lane内部从1bit选择扩展为4bit选择，一次产生4个点地址
// ie_NTT*, io_NTT* 的位运算公式
//PWM保持不变，本身就是线性扫址
