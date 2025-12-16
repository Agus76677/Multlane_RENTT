`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/05/05 20:54:15
// Design Name: 
// Module Name: RBFU_tb
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
`define NTT  2'b00 
`define INTT 2'b01 
`define PWM1 2'b10 
`define PWM2 2'b11 

module RBFU_tb();
reg   clk;
reg   [11:0] a;
reg   [11:0] b;
reg   [11:0] c;
reg   [11:0] w;
wire  [11:0] Dout1;
wire  [11:0] Dout2;
reg   [1:0]  opcode;

wire  [11:0] ct[0:1];
wire  [11:0] gs[0:1];
wire  [11:0] PWM1[0:1];
wire  [11:0] PWM2[0:1];

RBFU_O u_RBFU_O0(
    .clk                               (clk                       ),
    .a                                 (a                         ),
    .b                                 (b                         ),
    .c                                 (c                         ),
    .w                                 (w                         ),
    .opcode                            (opcode                    ),
    .Dout1                             (Dout1                     ),
    .Dout2                             (Dout2                     ) 
);

// RBFU_E u_RBFU_E0(
//     .clk                               (clk                       ),
//     .a                                 (a                         ),
//     .b                                 (b                         ),
//     .c                                 (c                         ),
//     .w                                 (w                         ),
//     .opcode                            (opcode                    ),
//     .Dout1                             (Dout1                     ),
//     .Dout2                             (Dout2                     ) 
// );

initial begin
    clk=0;
    opcode =0;
    #1000 opcode =`PWM1;
    #1000 opcode =`PWM2;
    #1000 opcode =`NTT;
    #1000 opcode =`INTT;
end

always #5 clk=~clk;

always@(posedge clk) begin
    #1 a<={$random}%3329;
       b<={$random}%3329;
       c<={$random}%3329;
       w<={$random}%3329;
end

wire [11:0] sum_div;
wire [11:0] sub_div;
Div2 u_Div1(.x((a + b)%3329),.y(sum_div));
Div2 u_Div2(.x(((a - b+3329)* w)%3329),.y(sub_div));

assign ct[0]     = (a + b * w % 3329)%3329;
assign ct[1]     = (a - b * w % 3329 + 3329 )%3329; 
assign gs[0]     = sum_div;
assign gs[1]     = sub_div;
assign PWM1[0]   = (a + b) %3329 ; 
assign PWM1[1]   = (b * w) %3329 ;
assign PWM2[0]   = (a + b * w % 3329)%3329;
assign PWM2[1]   = (b * w % 3329-a-c+3329*2)%3329;


endmodule