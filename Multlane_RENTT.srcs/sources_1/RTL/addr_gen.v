`timescale 1ns / 1ps
`include "parameter.v"
//////////////////////////////////////////////////////////////////////////////////
// Radix-4 address generator: outputs 4-point indices per butterfly
//////////////////////////////////////////////////////////////////////////////////

module addr_gen(
input clk,
input rst,
input [2:0] i,
input [6:0] s,
input [`ADDR_ROM_WIDTH-1:0] k,
`ifdef OP0
    input b,
`else
    input [`P_SHIFT-1:0] b,
`endif
input [1:0] opcode,
output [7:0] ie0,
output [7:0] io0,
output [7:0] ie1,
output [7:0] io1
);

wire [7:0] idx0;
wire [7:0] idx1;
wire [7:0] idx2;
wire [7:0] idx3;

function [7:0] J_value;
    input [2:0] stage;
    begin
        case(stage)
            3'd0: J_value = 8'd64;
            3'd1: J_value = 8'd16;
            3'd2: J_value = 8'd4;
            default: J_value = 8'd1;
        endcase
    end
endfunction

wire [7:0] J = J_value(i);
wire [7:0] j_block = s * `P_HALF;
wire [7:0] j_local = j_block + { {6{1'b0}}, b, 1'b0 };
wire [15:0] base_full = (k << 2) * J;
wire [7:0] base = base_full[7:0];
assign idx0 = base + j_local;
assign idx1 = idx0 + J;
assign idx2 = idx0 + (J<<1);
assign idx3 = idx0 + (J<<1) + J;
wire [7:0] ie0_temp;
wire [7:0] io0_temp;
wire [7:0] ie1_temp;
wire [7:0] io1_temp;

assign ie0_temp = idx0;
assign io0_temp = idx1;
assign ie1_temp = idx2;
assign io1_temp = idx3;

DFF #(.data_width(8)) dff_ie0(.clk(clk),.rst(rst),.d(ie0_temp),.q(ie0));
DFF #(.data_width(8)) dff_io0(.clk(clk),.rst(rst),.d(io0_temp),.q(io0));
DFF #(.data_width(8)) dff_ie1(.clk(clk),.rst(rst),.d(ie1_temp),.q(ie1));
DFF #(.data_width(8)) dff_io1(.clk(clk),.rst(rst),.d(io1_temp),.q(io1));
endmodule
