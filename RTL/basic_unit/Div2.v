`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/04 21:56:33
// Design Name: 
// Module Name: Div2
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


module Div2(
            input [11:0] x,
            output[11:0] y);

wire [10:0] x0and;

assign x0and = {11{x[0]}} & 11'd1665;
assign y     = x[11:1] + x0and;

endmodule
