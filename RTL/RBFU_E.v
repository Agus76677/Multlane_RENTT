`timescale 1ns / 1ps
`include "parameter.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/04 20:53:41
// Design Name: 
// Module Name: RBFU_E
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
// opcode:00 NTT
// opcode:01 INTT
// opcode:10 PWM0
// opcode:11 PWM1
// input   a b c w 
// output  Dout1, Dout2
// NTT:    Dout1 =  a + b*w                    Dout2 =  a - b*w     
// INTT:   Dout1 = (a + b)/2                   Dout2 = (a - b)*w/2  
// PWM0:   Dout1 =  a + b(s1=g[2i]+g[2i+1])    Dout2 =  b*w(m1=f[2i+1]*g[2i+1])            
// PWM1:   Dout1 =  c*w-a-b(h[2i+1]=s0*s1-m0-m1=(f[2i]+f[2i+1])*(g[2i]+g[2i+1])-f[2i+1]*g[2i+1]-f[2i]*g[2i]) Dout2 = 0
module RBFU_E(
    input  clk,
    input  rst,  
    input  [11 : 0] a,b,c,w,
    input  [ 1:0] opcode, 
    output [11: 0] Dout1,
    output [11: 0] Dout2  
);
  
//add0 输入 输出
wire  [11: 0] ma0_a, ma0_s;
wire  [11: 0] ma0_b;
assign ma0_a = a;
assign ma0_b = b;                       
MA u_MA(.MA_a(ma0_a),.MA_b(ma0_b),.MA_s(ma0_s));

//sub0 输入 输出
wire [11:0] ms0_a, ms0_b;
wire [11:0] ms0_s;
assign ms0_a = b;
assign ms0_b = a;
MS u_MS(.MS_a(ms0_a),.MS_b(ms0_b),.MS_s(ms0_s));

//第一级 选择器输出  o e 
reg [11:0] o, e;
always@(*) begin
    case(opcode) 
    `NTT  : begin o = a    ; e = b;     end
    `INTT : begin o = ma0_s; e = ms0_s; end
    `PWM0 : begin o = ma0_s; e = b;     end
    `PWM1 : begin o = ma0_s; e = c;     end
    default:begin o = 12'd0; e = 12'd0; end
    endcase
end

//o 延迟链
// reg [11:0] o_ff1=0; 
// reg [11:0] o_ff2=0;
// reg [11:0] o_ff3=0;
// reg [11:0] o_ff4=0;

// always@(posedge clk )
// begin
//     o_ff1<=o ;o_ff2<=o_ff1;o_ff3<=o_ff2;o_ff4<=o_ff3; 
// end 

wire [11:0] o_ff4;
shift#(.SHIFT(4),.data_width(`DATA_WIDTH)) REBFU_E_shfit(.clk(clk),.rst(rst),.din(o),.dout(o_ff4));

//寄存e 
// reg [11:0] e_ff1=0;
// always@(posedge clk)
// begin
//     e_ff1<=e;
// end

wire [11:0] e_ff1;
DFF #(.data_width(`DATA_WIDTH)) eff1_inst(.clk(clk),.rst(rst),.d(e),.q(e_ff1));

//寄存旋转因子
// reg [11:0] w_ff1=0;
// always@(posedge clk)
// begin
//     w_ff1<=w;
// end

wire [11:0] w_ff1;
DFF #(.data_width(`DATA_WIDTH)) wff1_inst(.clk(clk),.rst(rst),.d(w),.q(w_ff1));

//Modmul模乘器
wire [11:0] R;
Modmul u_Modmul(.clk(clk),.A(e_ff1),.B(w_ff1),.R(R));
// reg  [11:0] R_ff1=0;
// always@(posedge clk)
// begin
//     R_ff1<=R;
// end
wire [11:0] R_ff1;
DFF #(.data_width(`DATA_WIDTH)) Rff1_inst(.clk(clk),.rst(rst),.d(R),.q(R_ff1));

//add1 输入输出
wire [11: 0] ma1_a ;
wire [11: 0] ma1_b , ma1_s;

assign ma1_a = o_ff4;
assign ma1_b = R_ff1;
MA u_MA1(.MA_a(ma1_a),.MA_b(ma1_b),.MA_s(ma1_s));

//sub1 输入输出
wire [11:0] ms1_a, ms1_b;
wire [11:0] ms1_s;

assign ms1_a = o_ff4;
assign ms1_b = R_ff1;
MS u_MS1(.MS_a(ms1_a),.MS_b(ms1_b),.MS_s(ms1_s));

//******************** div2 ************************//
wire [11:0] sum_div;
wire [11:0] sub_div;
Div2 u_Div1(.x(o_ff4),.y(sum_div));
Div2 u_Div2(.x(R_ff1),.y(sub_div));
//******************** out *************************//
//分割组合逻辑
wire [11:0] ma1_s_ff;
wire [11:0] ms1_s_ff;
wire [11:0] sum_div_ff;
wire [11:0] sub_div_ff;
wire [11:0] o_ff5;
wire [11:0] R_ff2;
DFF #(.data_width(`DATA_WIDTH)) ma1_inst    (.clk(clk),.rst(rst),.d(ma1_s),  .q(ma1_s_ff));
DFF #(.data_width(`DATA_WIDTH)) ms1_inst    (.clk(clk),.rst(rst),.d(ms1_s),  .q(ms1_s_ff));
DFF #(.data_width(`DATA_WIDTH)) sum_div_inst(.clk(clk),.rst(rst),.d(sum_div),.q(sum_div_ff));
DFF #(.data_width(`DATA_WIDTH)) sub_div_inst(.clk(clk),.rst(rst),.d(sub_div),.q(sub_div_ff));
DFF #(.data_width(`DATA_WIDTH)) o_ff4_inst  (.clk(clk),.rst(rst),.d(o_ff4),  .q(o_ff5));
DFF #(.data_width(`DATA_WIDTH)) R_ff2_inst  (.clk(clk),.rst(rst),.d(R_ff1),  .q(R_ff2));

reg [11:0] out1, out2;

always@(*)
begin
    case(opcode)
    `NTT  : begin out1 = ma1_s_ff         ; out2 = ms1_s_ff   ; end
    `INTT : begin out1 = sum_div_ff       ; out2 = sub_div_ff ; end
    `PWM0 : begin out1 = o_ff5            ; out2 = R_ff2      ; end
    `PWM1 : begin out1 = 12'd3329-ms1_s_ff; out2 = 12'd0; end
    default : begin out1 = 12'd0 ; out2 = 12'd0   ; end
    endcase
end

assign Dout1 = out1;
assign Dout2 = out2;
endmodule