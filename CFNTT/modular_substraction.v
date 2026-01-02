`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/12/23 11:05:48
// Design Name: 
// Module Name: modular_substraction
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

module modular_substraction #(parameter data_width = 12)(
    input  [data_width-1:0] x_sub,
    input  [data_width-1:0] y_sub,
    output [data_width-1:0] z_sub
);
    localparam [data_width-1:0] M = 12'd3329;

    wire [data_width-1:0] q;
    wire c;
    wire [data_width-1:0] d;
    wire b;

    wire [data_width:0] diff_ext = {1'b0, x_sub} - {1'b0, y_sub};
    assign {b,d} = diff_ext;

    assign q = b ? M : {data_width{1'b0}};

    wire [data_width:0] sum_ext = {1'b0, d} + {1'b0, q};
    assign {c,z_sub} = sum_ext;
endmodule
