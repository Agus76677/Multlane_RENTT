`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/04 20:16:11
// Design Name: 
// Module Name: MS
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


module MS(
input [11:0] MS_a,
input [11:0] MS_b,
output [11:0] MS_s
);

wire [11:0] sub0;
wire [11:0] sub1;
wire c;
wire c_fault;

assign {c, sub0} = MS_a - MS_b;
assign {c_fault, sub1} = MS_a - MS_b + 12'd3329;

assign MS_s = c? sub1: sub0;

endmodule
