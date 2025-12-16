`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/18 16:00:25
// Design Name: 
// Module Name: tb_fsm
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


module tb_fsm();
reg               clk      ;
reg               rst      ;
reg     [   1:0]  opcode   ;
reg               start    ;
wire    [   5:0]  i        ;
wire    [   6:0]  s        ;
wire              wen      ;
wire              ren      ;
wire              en       ;
wire              finish   ;

always#2.5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1'b1;                   // Assert reset
    opcode = 2'b00;                 // NTT opcode
    start = 0;                    // Start the operation
    #10 rst = 0;                  // Release reset
    @(posedge clk)
    begin
        start <= 1;
    end                           // Start the operation
    @(posedge clk)
    begin
        start <= 0;
    end                           // Deassert start
    @(posedge finish);            // Wait for the operation to complete
    $display("NTT finished");
    
    #300
    rst = 1'b1;                   // Assert reset
    start = 0;                    // Start the operation
    opcode = 2'b01;                 // INTT opcode
    #10 rst = 0;                  // Release reset
    @(posedge clk)
    begin
        start <= 1;
    end                          // Start the operation
    @(posedge clk)
    begin
        start <= 0;
    end                          // Deassert start
    @(posedge finish);            // Wait for the operation to complete
    $display("INTT finished");

    #300
    rst = 1'b1;                   // Assert reset
    start = 0;                    // Start the operation
    opcode = 2'b10;                 // INTT opcode
    #10 rst = 0;                  // Release reset
    @(posedge clk)
    begin
        start <= 1;
    end                          // Start the operation
    @(posedge clk)
    begin
        start <= 0;
    end                         // Deassert start
    @(posedge finish);            // Wait for the operation to complete
    $display("INTT finished");
end

fsm fsm_inst(
    .clk       (clk          ),//I
    .rst       (rst          ),//I
    .opcode    (opcode       ),//I
    .start     (start        ),//I
    .i         (i            ),//O
    .s         (s            ),//O
    .wen       (wen          ),//O
    .ren       (ren          ),//O
    .en        (en           ),//O
    .finish    (finish       ) //O
);
endmodule
