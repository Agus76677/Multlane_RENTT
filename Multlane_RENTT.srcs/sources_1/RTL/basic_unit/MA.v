`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/04 20:16:11
// Design Name: 
// Module Name: MA
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
module MA(
input [11:0] MA_a,
input [11:0] MA_b,
output [11:0] MA_s
);

wire [11:0] sum0;
wire [11:0] sum1;
wire c0;
wire c1;
wire sel;

assign {c0, sum0} = MA_a + MA_b;
assign {c1, sum1} = MA_a + MA_b - 12'd3329;
assign sel = ~c1 | c0;

assign MA_s = sel? sum1: sum0;

endmodule