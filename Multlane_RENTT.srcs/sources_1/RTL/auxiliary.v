`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/19 19:12:00
// Design Name: 
// Module Name: common_lib
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

module DFF #(
	parameter data_width = 12
)
(
	input clk,rst,
	input [data_width-1:0] d,
	output reg [data_width-1:0] q 
);

always@(posedge clk)
begin
	if(rst)
	q <= 0;
	else
	q <= d;
end
endmodule


module shift#(
        parameter SHIFT = 0,
        parameter data_width=12
)
(
        input         clk,
        input         rst,
    input  [data_width-1:0] din,
    output [data_width-1:0] dout
);

generate
    if (SHIFT == 0) begin : NO_SHIFT
        assign dout = din;
    end else begin : SHIFT_CHAIN
        reg [data_width-1:0] shift_array [0:SHIFT-1];
        genvar shft;

        always @(posedge clk) begin
            if(rst)
                shift_array[0] <= 0;
            else
                shift_array[0] <= din;
        end

        for(shft=0; shft < SHIFT-1; shft=shft+1) begin: DELAY_BLOCK
            always @(posedge clk ) begin
                if(rst)
                    shift_array[shft+1] <= 0;
                else
                    shift_array[shft+1] <= shift_array[shft];
            end
        end

        assign dout = shift_array[SHIFT-1];
    end
endgenerate
endmodule