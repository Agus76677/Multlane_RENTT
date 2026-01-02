`timescale 1ns / 1ps
`include "parameter.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/04 20:53:41
// Design Name: by hzw
// Module Name: RBFU_O
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
// input   a0 b0 w0，a1 b1 w1 
// output  Dout0, Dout1, Dout2, Dout3,
// NTT:    Dout0 =  a0 + b0*w0        Dout1 =  a0 - b0*w0    Dout2 =  a1 + b1*w1          Dout3 =  a1 - b1*w1    
// INTT:   Dout0 = (a0 + b0)/2        Dout1 = (b0 - a0)*w0/2 Dout2 = (a1 + b1)/2          Dout3 = (b1 - a1)*w1/2 
// PWM0:   Dout0 =  a0 + b0(s0)       Dout1 = a1 + b1(s1)    Dout2 =  a0*w0(m0)           Dout3 =  b1*w1(m1])                 
// PWM1:   Dout0 =  a1 + b1*w1(h[2i]) Dout1 =  a0*b0-a1-b1(h[2i+1])    Dout2 =0           Dout3 = 0
//s0=f[2i]+f[2i+1],m0=f[2i]*g[2i],s1=g[2i]+g[2i+1],m1=f[2i+1]*g[2i+1]
//h[2i]==m0+m1*w
//h[2i+1]=s0*s1-m0-m1=(f[2i]+f[2i+1])*(g[2i]+g[2i+1])-f[2i+1]*g[2i+1]-f[2i]*g[2i])

`ifdef PIPE1
module RBFU(
    input  clk,
    input  rst,
    input  [`DATA_WIDTH-1 : 0] rbfu_a0,rbfu_b0,rbfu_w0, //第一组系数
    input  [`DATA_WIDTH-1 : 0] rbfu_a1,rbfu_b1,rbfu_w1, //第二组系数
    input  [ 1            : 0] opcode, 
    output [`DATA_WIDTH-1 : 0] Dout0,
    output [`DATA_WIDTH-1 : 0] Dout1,
    output [`DATA_WIDTH-1 : 0] Dout2,
    output [`DATA_WIDTH-1 : 0] Dout3
);

wire [`DATA_WIDTH-1:0] a0, b0, a1, b1, w0, w1;
assign a0 = rbfu_a0;
assign b0 = rbfu_b0;
assign a1 = rbfu_a1;
assign b1 = rbfu_b1;
assign w0 = rbfu_w0;
assign w1 = rbfu_w1;

//add0 输入 输出
wire  [`DATA_WIDTH-1: 0] ma0_a0, ma0_s0;
wire  [`DATA_WIDTH-1: 0] ma0_b0;
wire  [`DATA_WIDTH-1: 0] ma0_a1, ma0_s1;
wire  [`DATA_WIDTH-1: 0] ma0_b1;
assign ma0_a0 = a0;
assign ma0_b0 = b0;
assign ma0_a1 = a1;
assign ma0_b1 = b1;                        
MA u_MA0(.MA_a(ma0_a0),.MA_b(ma0_b0),.MA_s(ma0_s0));                   
MA u_MA1(.MA_a(ma0_a1),.MA_b(ma0_b1),.MA_s(ma0_s1));

//sub0 输入 输出
wire [`DATA_WIDTH-1:0] ms0_a0, ms0_b0;
wire [`DATA_WIDTH-1:0] ms0_s0;
wire [`DATA_WIDTH-1:0] ms0_a1, ms0_b1;
wire [`DATA_WIDTH-1:0] ms0_s1;
assign ms0_a0 = b0;
assign ms0_b0 = a0;
assign ms0_a1 = b1;
assign ms0_b1 = a1;
MS u_MS0(.MS_a(ms0_a0),.MS_b(ms0_b0),.MS_s(ms0_s0));
MS u_MS1(.MS_a(ms0_a1),.MS_b(ms0_b1),.MS_s(ms0_s1));

//第一级 选择器输出  o e 
reg [`DATA_WIDTH-1:0] o0, e0;
reg [`DATA_WIDTH-1:0] o1, e1;
always@(*) begin
    case(opcode) 
    `NTT  : begin o0 = a0    ; e0 = b0    ;o1 = a1    ;  e1 = b1     ;end
    `INTT : begin o0 = ma0_s0; e0 = ms0_s0;o1 = ma0_s1;  e1 = ms0_s1 ;end
    `PWM0 : begin o0 = ma0_s0; e0 = a1    ;o1 = ma0_s1;  e1 = b1     ;end
    `PWM1 : begin o0 = ma0_s1; e0 = b0    ;o1 = a1    ;  e1 = b1     ;end
    default:begin o0 = 12'd0 ; e0 = 12'd0 ;o1 = 12'd0 ;  e1 = 12'd0  ;end
    endcase
end

//o0 延迟链,延迟一级
wire [`DATA_WIDTH-1:0] o0_ff4;
wire [`DATA_WIDTH-1:0] o1_ff4;
shift#(.SHIFT(`L),.data_width(`DATA_WIDTH)) REBFU_O0_shfit(.clk(clk),.rst(rst),.din(o0),.dout(o0_ff4));
shift#(.SHIFT(`L),.data_width(`DATA_WIDTH)) REBFU_O1_shfit(.clk(clk),.rst(rst),.din(o1),.dout(o1_ff4));

wire [`DATA_WIDTH-1:0] w0_temp;
wire [`DATA_WIDTH-1:0] w1_temp;
assign w0_temp = opcode ==`PWM0 || opcode ==`PWM1? a0 : w0;
assign w1_temp = opcode ==`PWM0 ? b0 : w1;

//Modmul模乘器
wire [`DATA_WIDTH-1:0] R0;
wire [`DATA_WIDTH-1:0] R1;
Modmul u_Modmul0(.clk(clk),.A(e0),.B(w0_temp),.R(R0));
Modmul u_Modmul1(.clk(clk),.A(e1),.B(w1_temp),.R(R1));
wire [`DATA_WIDTH-1:0] R0_ff1;
wire [`DATA_WIDTH-1:0] R1_ff1;
assign R0_ff1 = R0;
assign R1_ff1 = R1;

//add1 输入输出
wire [`DATA_WIDTH-1: 0] ma1_a0 ;
wire [`DATA_WIDTH-1: 0] ma1_b0 , ma1_s0;
wire [`DATA_WIDTH-1: 0] ma1_a1 ;
wire [`DATA_WIDTH-1: 0] ma1_b1 , ma1_s1;

assign ma1_a0 = o0_ff4;
assign ma1_b0 = R0_ff1;
assign ma1_a1 = o1_ff4;
assign ma1_b1 = R1_ff1;
MA u_MA10(.MA_a(ma1_a0),.MA_b(ma1_b0),.MA_s(ma1_s0));
MA u_MA11(.MA_a(ma1_a1),.MA_b(ma1_b1),.MA_s(ma1_s1));

//sub1 输入输出
wire [`DATA_WIDTH-1:0] ms1_a0, ms1_b0;
wire [`DATA_WIDTH-1:0] ms1_s0;
wire [`DATA_WIDTH-1:0] ms1_a1, ms1_b1;
wire [`DATA_WIDTH-1:0] ms1_s1;

assign ms1_a0 = o0_ff4;
assign ms1_b0 = R0_ff1;
assign ms1_a1 = o1_ff4;
assign ms1_b1 = R1_ff1;
MS u_MS10(.MS_a(ms1_a0),.MS_b(ms1_b0),.MS_s(ms1_s0));
MS u_MS11(.MS_a(ms1_a1),.MS_b(ms1_b1),.MS_s(ms1_s1));

//******************** div2 ************************//
wire [`DATA_WIDTH-1:0] sum_div0;
wire [`DATA_WIDTH-1:0] sub_div0;
wire [`DATA_WIDTH-1:0] sum_div1;
wire [`DATA_WIDTH-1:0] sub_div1;
Div2 u_Div00(.x(o0_ff4),.y(sum_div0));
Div2 u_Div01(.x(R0_ff1),.y(sub_div0));
Div2 u_Div10(.x(o1_ff4),.y(sum_div1));
Div2 u_Div11(.x(R1_ff1),.y(sub_div1));
//******************** out *************************//
wire [`DATA_WIDTH-1:0] ma1_s0_ff;
wire [`DATA_WIDTH-1:0] ms1_s0_ff;
wire [`DATA_WIDTH-1:0] sum_div0_ff;
wire [`DATA_WIDTH-1:0] sub_div0_ff;
wire [`DATA_WIDTH-1:0] o0_ff5;
wire [`DATA_WIDTH-1:0] R0_ff2;

assign ma1_s0_ff  =  ma1_s0  ;
assign ms1_s0_ff  =  ms1_s0  ;
assign sum_div0_ff=  sum_div0;
assign sub_div0_ff=  sub_div0;
assign o0_ff5     =  o0_ff4  ;
assign R0_ff2     =  R0_ff1  ;

wire [`DATA_WIDTH-1:0] ma1_s1_ff;
wire [`DATA_WIDTH-1:0] ms1_s1_ff;
wire [`DATA_WIDTH-1:0] sum_div1_ff;
wire [`DATA_WIDTH-1:0] sub_div1_ff;
wire [`DATA_WIDTH-1:0] o1_ff5;
wire [`DATA_WIDTH-1:0] R1_ff2;  

assign ma1_s1_ff  = ma1_s1  ;
assign ms1_s1_ff  = ms1_s1  ;
assign sum_div1_ff= sum_div1;
assign sub_div1_ff= sub_div1;
assign o1_ff5     = o1_ff4  ;
assign R1_ff2     = R1_ff1  ;

reg [`DATA_WIDTH-1:0] out0, out1;
reg [`DATA_WIDTH-1:0] out2, out3;

always@(*)
begin
    case(opcode)
    `NTT  : begin out0 = ma1_s0_ff   ; out1 = ms1_s0_ff         ; out2 = ma1_s1_ff         ; out3 = ms1_s1_ff  ;end
    `INTT : begin out0 = sum_div0_ff ; out1 = sub_div0_ff       ; out2 = sum_div1_ff       ; out3 = sub_div1_ff;end
    `PWM0 : begin out0 = o0_ff5      ; out1 = o1_ff5            ; out2 = R0_ff2            ; out3 = R1_ff2     ;end
    `PWM1 : begin out0 = ma1_s1_ff   ; out1 = 12'd3329-ms1_s0_ff; out2 =12'd0              ; out3 = 12'd0      ;end
    default : begin out0 = 12'd0     ; out1 = 12'd0             ; out2 = 12'd0             ; out3 = 12'd0      ;end
    endcase
end

assign Dout0 = out0;
assign Dout1 = out1;
assign Dout2 = out2;
assign Dout3 = out3;
endmodule

    
`endif