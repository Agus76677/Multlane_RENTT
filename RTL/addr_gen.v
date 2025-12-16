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
input [5:0] i,
input [6:0] s,
`ifdef OP0
    input b,
`else
    input [`P_SHIFT-2:0] b,
`endif
input [1:0] opcode,
output [7:0] ie0,
output [7:0] io0,
output [7:0] ie1,
output [7:0] io1
);

wire [7:0] j0;
wire [7:0] k0;
wire [7:0] ie_NTT0;
wire [7:0] io_NTT0;
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

//NTT or INTT
`ifdef OP0
    assign j0 ={s[6:`P_SHIFT],1'b0}>>(7-i); 
    assign k0 ={s[6:`P_SHIFT],1'b0}&(('d128>>i)-1);
    assign ie_NTT0 = (j0<<(8-i)) + k0;
    assign io_NTT0 = (j0<<(8-i)) + k0 + (1<<(7-i));
    assign j1 ={s[6:`P_SHIFT],1'b1}>>(7-i); 
    assign k1 ={s[6:`P_SHIFT],1'b1}&(('d128>>i)-1);
    assign ie_NTT1 = (j1<<(8-i)) + k1;
    assign io_NTT1 = (j1<<(8-i)) + k1 + (1<<(7-i));
`else
    assign j0 ={s[6:`P_SHIFT],{b,1'b0}}>>(7-i); 
    assign k0 ={s[6:`P_SHIFT],{b,1'b0}}&(('d128>>i)-1);
    assign ie_NTT0 = (j0<<(8-i)) + k0;
    assign io_NTT0 = (j0<<(8-i)) + k0 + (1<<(7-i));
    assign j1 ={s[6:`P_SHIFT],{b,1'b1}}>>(7-i); 
    assign k1 ={s[6:`P_SHIFT],{b,1'b1}}&(('d128>>i)-1);
    assign ie_NTT1 = (j1<<(8-i)) + k1;
    assign io_NTT1 = (j1<<(8-i)) + k1 + (1<<(7-i));
`endif


//PWM0,PWM1
assign ie_PWM0 = {b,1'b0}+(s<<`P_SHIFT)+(i<<(`P_SHIFT+1));
assign io_PWM0 = {b,1'b1}+(s<<`P_SHIFT)+(i<<(`P_SHIFT+1));
assign ie_PWM1 = ie_PWM0;
assign io_PWM1 = io_PWM0;

assign sel=(opcode==`INTT||opcode==`NTT);
assign ie0_temp =sel ? ie_NTT0:ie_PWM0;
assign io0_temp =sel ? io_NTT0:io_PWM0;
assign ie1_temp =sel ? ie_NTT1:ie_PWM1;
assign io1_temp =sel ? io_NTT1:io_PWM1;

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