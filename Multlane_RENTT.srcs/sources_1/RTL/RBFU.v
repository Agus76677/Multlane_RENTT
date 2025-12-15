`timescale 1ns / 1ps
`include "parameter.v"
//////////////////////////////////////////////////////////////////////////////////
// Radix-4 butterfly unit (4 inputs / 4 outputs)
//////////////////////////////////////////////////////////////////////////////////
module RBFU(
    input  clk,
    input  rst,
    input  [`DATA_WIDTH-1 : 0] rbfu_a0,
    input  [`DATA_WIDTH-1 : 0] rbfu_a1,
    input  [`DATA_WIDTH-1 : 0] rbfu_a2,
    input  [`DATA_WIDTH-1 : 0] rbfu_a3,
    input  [`DATA_WIDTH-1 : 0] tf_w2,
    input  [`DATA_WIDTH-1 : 0] tf_w1,
    input  [`DATA_WIDTH-1 : 0] tf_w3,
    input  [`DATA_WIDTH-1 : 0] tf_omega,
    input  [ 1            : 0] opcode,
    output [`DATA_WIDTH-1 : 0] Dout0,
    output [`DATA_WIDTH-1 : 0] Dout1,
    output [`DATA_WIDTH-1 : 0] Dout2,
    output [`DATA_WIDTH-1 : 0] Dout3
);

// stage 0: sums/diffs
wire [`DATA_WIDTH-1:0] a0_add_a2;
wire [`DATA_WIDTH-1:0] a1_add_a3;
wire [`DATA_WIDTH-1:0] a0_sub_a2;
wire [`DATA_WIDTH-1:0] a1_sub_a3;
MA u_add0(.MA_a(rbfu_a0), .MA_b(rbfu_a2), .MA_s(a0_add_a2));
MA u_add1(.MA_a(rbfu_a1), .MA_b(rbfu_a3), .MA_s(a1_add_a3));
MS u_sub0(.MS_a(rbfu_a0), .MS_b(rbfu_a2), .MS_s(a0_sub_a2));
MS u_sub1(.MS_a(rbfu_a1), .MS_b(rbfu_a3), .MS_s(a1_sub_a3));

// rotate by omega_i
wire [`DATA_WIDTH-1:0] rot_val;
Modmul u_mul_omega(.clk(clk), .A(a1_sub_a3), .B(tf_omega), .R(rot_val));

// y terms before twiddle
wire [`DATA_WIDTH-1:0] y0_raw;
wire [`DATA_WIDTH-1:0] y1_raw;
wire [`DATA_WIDTH-1:0] y2_raw;
wire [`DATA_WIDTH-1:0] y3_raw;
MA y0_add(.MA_a(a0_add_a2), .MA_b(a1_add_a3), .MA_s(y0_raw));
MS y2_sub(.MS_a(a0_add_a2), .MS_b(a1_add_a3), .MS_s(y2_raw));
MA y1_add(.MA_a(a0_sub_a2), .MA_b(rot_val), .MA_s(y1_raw));
MS y3_sub(.MS_a(a0_sub_a2), .MS_b(rot_val), .MS_s(y3_raw));

// multiply by twiddles
wire [`DATA_WIDTH-1:0] y1_mul;
wire [`DATA_WIDTH-1:0] y2_mul;
wire [`DATA_WIDTH-1:0] y3_mul;
Modmul mul1(.clk(clk), .A(y1_raw), .B(tf_w1), .R(y1_mul));
Modmul mul2(.clk(clk), .A(y2_raw), .B(tf_w2), .R(y2_mul));
Modmul mul3(.clk(clk), .A(y3_raw), .B(tf_w3), .R(y3_mul));

// pipeline align to overall latency
wire [`DATA_WIDTH-1:0] out0_ff;
wire [`DATA_WIDTH-1:0] out1_ff;
wire [`DATA_WIDTH-1:0] out2_ff;
wire [`DATA_WIDTH-1:0] out3_ff;
shift#(.SHIFT(`L+1),.data_width(`DATA_WIDTH)) sh0(.clk(clk),.rst(rst),.din(y0_raw),.dout(out0_ff));
shift#(.SHIFT(`L+1),.data_width(`DATA_WIDTH)) sh1(.clk(clk),.rst(rst),.din(y1_mul),.dout(out1_ff));
shift#(.SHIFT(`L+1),.data_width(`DATA_WIDTH)) sh2(.clk(clk),.rst(rst),.din(y2_mul),.dout(out2_ff));
shift#(.SHIFT(`L+1),.data_width(`DATA_WIDTH)) sh3(.clk(clk),.rst(rst),.din(y3_mul),.dout(out3_ff));

reg [`DATA_WIDTH-1:0] Dout0_r, Dout1_r, Dout2_r, Dout3_r;
always @(*) begin
    case(opcode)
        `NTT, `INTT: begin
            Dout0_r = out0_ff;
            Dout1_r = out1_ff;
            Dout2_r = out2_ff;
            Dout3_r = out3_ff;
        end
        `PWM0: begin
            Dout0_r = rbfu_a0;
            Dout1_r = rbfu_a1;
            Dout2_r = rbfu_a2;
            Dout3_r = rbfu_a3;
        end
        default: begin
            Dout0_r = out0_ff;
            Dout1_r = out1_ff;
            Dout2_r = out2_ff;
            Dout3_r = out3_ff;
        end
    endcase
end

assign Dout0 = Dout0_r;
assign Dout1 = Dout1_r;
assign Dout2 = Dout2_r;
assign Dout3 = Dout3_r;
endmodule
