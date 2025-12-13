`timescale 1ns / 1ps
`include "parameter.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/17 22:05:33
// Design Name: 
// Module Name: bank
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


module bank(
    input                               clk             ,
    input             [`ADDR_WIDTH-1:0] waddr           ,//
    input             [`ADDR_WIDTH-1:0] raddr           ,//
    input             [`DATA_WIDTH-1:0] wdata           ,
    input                               WEN             ,
    input                               REN             ,
    input                               EN              ,
    output reg        [`DATA_WIDTH-1:0] rdata                
);

(*ram_style = "block"*)reg [`DATA_WIDTH-1:0] bank [`DEPTH-1:0];

always@(posedge clk)
begin
    if (EN == 1)
    begin
        if(WEN == 1'b1)
            bank[waddr] <= wdata;
        else
            bank[waddr] <= bank[waddr];
    end
end

always@(posedge clk)
begin
    if(EN == 1)
    begin
        if(REN == 1'b1)
            rdata <= bank[raddr];
        else
            rdata <= rdata;
    end
end
endmodule
