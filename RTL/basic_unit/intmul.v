`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/04 20:16:11
// Design Name: 
// Module Name: intmul
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

module intmul (
input 		[11:0] A,
input 		[11:0] B,
output 		[23:0] P
);

//************************ ASIC - begin **********************//
// P = A*B
// 24bit = 12bit * 12bit

(* use_dsp = "yes" *) wire [23 : 0] P_mul;
assign P_mul = A * B;
assign P = P_mul;
//************************ ASIC - end   **********************//

endmodule