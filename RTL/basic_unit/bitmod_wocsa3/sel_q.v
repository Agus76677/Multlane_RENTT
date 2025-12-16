`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/29 19:46:03
// Design Name: 
// Module Name: sel_q
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


module sel_q(
    input [3-1:0] t0_0,
    input [2-1:0] t0_1,
    input [2-1:0] t0_2,
    input [2-1:0] t0_3,
    input [2-1:0] t0_4,
    input [2-1:0] t0_5,
    input [2-1:0] t0_6,
    input [2-1:0] t0_7,
    input [3-1:0] t0_8,
    input [2-1:0] t0_9,
    input [3-1:0] t0_10,
    input [3-1:0] t0_11,
    input [2-1:0] t0_12,
    input [2-1:0] t0_13,
    input [1-1:0] t0_14,
    output [15-1:0] s,
    output [15-1:0] c);

    // ------------------------------- Connections
    wire [2-1:0] t1_0;
    wire [2-1:0] t1_1;
    wire [2-1:0] t1_2;
    wire [2-1:0] t1_3;
    wire [2-1:0] t1_4;
    wire [2-1:0] t1_5;
    wire [2-1:0] t1_6;
    wire [2-1:0] t1_7;
    wire [2-1:0] t1_8;
    wire [2-1:0] t1_9;
    wire [2-1:0] t1_10;
    wire [2-1:0] t1_11;
    wire [2-1:0] t1_12;
    wire [2-1:0] t1_13;
    wire [2-1:0] t1_14;

    // ------------------------------- Operations
    CSA1 u000(t0_0[0],t0_0[1],t1_0[0],t1_1[0]);
    assign t1_0[1] = t0_0[2];
    CSA1 u010(t0_1[0],t0_1[1],t1_1[1],t1_2[0]);
    CSA1 u020(t0_2[0],t0_2[1],t1_2[1],t1_3[0]);
    CSA1 u030(t0_3[0],t0_3[1],t1_3[1],t1_4[0]);
    CSA1 u040(t0_4[0],t0_4[1],t1_4[1],t1_5[0]);
    CSA1 u050(t0_5[0],t0_5[1],t1_5[1],t1_6[0]);
    CSA1 u060(t0_6[0],t0_6[1],t1_6[1],t1_7[0]);
    CSA1 u070(t0_7[0],t0_7[1],t1_7[1],t1_8[0]);
    CSA2 u080(t0_8[0],t0_8[1],t0_8[2],t1_8[1],t1_9[0]);
    CSA1 u090(t0_9[0],t0_9[1],t1_9[1],t1_10[0]);
    CSA2 u0100(t0_10[0],t0_10[1],t0_10[2],t1_10[1],t1_11[0]);
    CSA2 u0110(t0_11[0],t0_11[1],t0_11[2],t1_11[1],t1_12[0]);
    CSA1 u0120(t0_12[0],t0_12[1],t1_12[1],t1_13[0]);
    CSA1 u0130(t0_13[0],t0_13[1],t1_13[1],t1_14[0]);
    assign t1_14[1] = t0_14[0];
    // CSA1 u0140(t0_14[0],t0_14[1],t1_14[1],dummy_var_0);

    // ------------------------------- Outputs
    assign c[0] = t1_0[0];
    assign c[1] = t1_1[0];
    assign c[2] = t1_2[0];
    assign c[3] = t1_3[0];
    assign c[4] = t1_4[0];
    assign c[5] = t1_5[0];
    assign c[6] = t1_6[0];
    assign c[7] = t1_7[0];
    assign c[8] = t1_8[0];
    assign c[9] = t1_9[0];
    assign c[10] = t1_10[0];
    assign c[11] = t1_11[0];
    assign c[12] = t1_12[0];
    assign c[13] = t1_13[0];
    assign c[14] = t1_14[0];
    assign s[0] = t1_0[1];
    assign s[1] = t1_1[1];
    assign s[2] = t1_2[1];
    assign s[3] = t1_3[1];
    assign s[4] = t1_4[1];
    assign s[5] = t1_5[1];
    assign s[6] = t1_6[1];
    assign s[7] = t1_7[1];
    assign s[8] = t1_8[1];
    assign s[9] = t1_9[1];
    assign s[10] = t1_10[1];
    assign s[11] = t1_11[1];
    assign s[12] = t1_12[1];
    assign s[13] = t1_13[1];
    assign s[14] = t1_14[1];

endmodule