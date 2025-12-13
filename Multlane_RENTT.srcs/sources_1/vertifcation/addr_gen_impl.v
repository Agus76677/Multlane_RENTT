`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/18 17:46:27
// Design Name: 
// Module Name: addr_gen_impl
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


module addr_gen_impl(
    input  clk,
    input  rst,
    input  [1:0] mode, 
    output reg [7:0] ie_ff,     
    output reg [7:0] io_ff      
);

reg  [5:0] i=0;
reg  [6:0] s=0;
reg  [4:0] b=0;
wire [7:0] io;
wire [7:0] ie;


always @(posedge clk or posedge rst) begin
    if (rst) begin
        i <= 0;
        s <= 0;
        b <= 0;
    end
    else
    begin
        if (mode == 2'b00) begin // NTT mode
            if (i < 6'd63) begin
                i <= i + 1;
            end else begin
                i <= 0;
                if (s < 7'd127) begin
                    s <= s + 1;
                end else begin
                    s <= 0;
                    b <= b + 1;
                end
            end
        end else if (mode == 2'b01) begin // INTT mode
            if (i < 6'd63) begin
                i <= i + 1;
            end else begin
                i <= 0;
                if (s < 7'd127) begin
                    s <= s + 1;
                end else begin
                    s <= 0;
                    b <= b + 1;
                end
            end
        end else if (mode == 2'b10 || mode == 2'b11) begin // PWM1 or PWM2 mode
            if (b < 5'd31) begin
                b <= b + 1;
            end else begin
                b <= 0; // Reset b for next cycle in PWM modes
            end
        end
    end
end

addr_gen addr_gen_inst(
    .i           (i         ),
    .s           (s         ),
    .b           (b         ),
    .mode        (mode      ),
    .ie          (ie        ),
    .io          (io        ) 
);


always @(posedge clk or posedge rst) begin
    if (rst) begin
        ie_ff <= 0;
        io_ff <= 0;
    end else begin
        ie_ff <= ie;
        io_ff <= io;
    end 
end

endmodule