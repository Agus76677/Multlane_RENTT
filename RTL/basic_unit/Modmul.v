`timescale 1ns / 1ps
`include "../parameter.v"  
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/04 20:16:11
// Design Name: 
// Module Name:Modmul 
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
`ifdef PIPE1
module Modmul(
            input         clk,
            input  [11:0] A,B,
            output [11:0] R);

wire [23:0] P;

intmul u_intmul(A,B,P);
// ---------------------------------------
bitmod_wocsa3 u_bitmod_wocsa3(
    .clk                               (clk                       ),
    .C                                 (P                         ),
    .R                                 (R                         ) 
);
endmodule
`elsif PIPE2
module Modmul(
            input         clk,
            input  [11:0] A,B,
            output [11:0] R);

wire [23:0] P;

intmul u_intmul(A,B,P);
// ---------------------------------------
bitmod_wocsa3 u_bitmod_wocsa3(
    .clk                               (clk                       ),
    .C                                 (P                         ),
    .R                                 (R                         ) 
);
endmodule
`elsif PIPE3
module Modmul(
            input         clk,
            input  [11:0] A,B,
            output [11:0] R);

wire [23:0] P;

intmul u_intmul(A,B,P);
// ---------------------------------------
bitmod_wocsa3 u_bitmod_wocsa3(
    .clk                               (clk                       ),
    .C                                 (P                         ),
    .R                                 (R                         ) 
);
endmodule
`else
module Modmul(
            input         clk,
            input  [11:0] A,B,
            output [11:0] R);

wire [23:0] P;
reg  [23:0] P_ff1=0;

intmul u_intmul(A,B,P);

always @(posedge clk) begin
        P_ff1 <= P;
end
// ---------------------------------------
bitmod_wocsa3 u_bitmod_wocsa3(
    .clk                               (clk                       ),
    .C                                 (P_ff1                     ),
    .R                                 (R                         ) 
);
endmodule

`endif