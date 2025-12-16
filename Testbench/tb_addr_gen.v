`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/18 17:46:27
// Design Name: 
// Module Name: tb_addr_gen
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


module tb_addr_gen();
reg  [5:0] i;
reg  clk;
reg  [6:0] s;
reg  [4:0] b;
reg  [1:0] opcode;
wire [7:0] ie;
wire [7:0] io;

always #2.5 clk = ~clk; // Clock generation


initial begin
    clk = 1'b0; 
    i = 6'd0; s = 7'd0; b = 5'd0; opcode = 2'b00; // NTT opcode
    #5;
    i = 6'd0; s = 7'd0; b = 5'd1; opcode = 2'b00; // NTT opcode
    #5;
    i = 6'd0; s = 7'd0; b = 5'd2; opcode = 2'b00; // NTT opcode
    #5;
    i = 6'd0; s = 7'd0; b = 5'd3; opcode = 2'b00; // NTT opcode
    #5;
    i = 6'd6; s = 7'd120; b = 5'd0; opcode = 2'b01; // INTT opcode
    #5;
    i = 6'd6; s = 7'd120; b = 5'd1; opcode = 2'b01; // INTT opcode
    #5;
    i = 6'd6; s = 7'd120; b = 5'd2; opcode = 2'b01; // INTT opcode
    #5;
    i = 6'd6; s = 7'd120; b = 5'd3; opcode = 2'b01; // INTT opcode
    #5;
    i = 6'd6; s = 7'd120; b = 5'd4; opcode = 2'b01; // INTT opcode
    #5;
    i = 6'd6; s = 7'd120; b = 5'd5; opcode = 2'b01; // INTT opcode
    #5;

    i = 6'd0; s = 7'd0; b = 5'd0; opcode = 2'b10; // PWM1 opcode
    #5;
    i = 6'd0; s = 7'd0; b = 5'd1; opcode = 2'b10; // PWM1 opcode
    #5;
    i = 6'd0; s = 7'd0; b = 5'd2; opcode = 2'b10; // PWM1 opcode
    #5;
    i = 6'd0; s = 7'd0; b = 5'd3; opcode = 2'b10; // PWM1 opcode
    #5;
    i = 6'd0; s = 7'd1; b = 5'd0; opcode = 2'b10; // PWM1 opcode
    #5;
    i = 6'd0; s = 7'd1; b = 5'd1; opcode = 2'b10; // PWM1 opcode
    #5;
    i = 6'd0; s = 7'd1; b = 5'd2; opcode = 2'b10; // PWM1 opcode
    #5;
    i = 6'd0; s = 7'd1; b = 5'd3; opcode = 2'b10; // PWM1 opcode
    #5;
    $finish;
end


addr_gen addr_gen_inst(
    .i           (i         ),//I
    .s           (s         ),//I
    .b           (b         ),//I
    .opcode      (opcode    ),//I
    .ie          (ie        ),//O
    .io          (io        ) //O
);

endmodule
