`timescale 1ns / 1ps
`include "parameter.v"
//////////////////////////////////////////////////////////////////////////////////
// Mixed-radix RBFU: radix-4 primary, radix-2 fallback (PIPE1 style)
// opcode:00 NTT
// opcode:01 INTT
// opcode:10 PWM (only valid in RAD4)
//////////////////////////////////////////////////////////////////////////////////
`ifdef PIPE1
module RBFU(
    input  clk,
    input  rst,
    input  [`DATA_WIDTH-1 : 0] rbfu_a0,
    input  [`DATA_WIDTH-1 : 0] rbfu_b0,
    input  [`DATA_WIDTH-1 : 0] rbfu_a1,
    input  [`DATA_WIDTH-1 : 0] rbfu_b1,
    input  [`DATA_WIDTH-1 : 0] rbfu_w0,
    input  [`DATA_WIDTH-1 : 0] rbfu_w1,
    input  [`DATA_WIDTH-1 : 0] rbfu_w2,
    input  [`DATA_WIDTH-1 : 0] rbfu_tw_pwm,
    input                      radix_mode, // 0: RAD2, 1: RAD4
    input  [1:0]               opcode,
    output [`DATA_WIDTH-1 : 0] Dout0,
    output [`DATA_WIDTH-1 : 0] Dout1,
    output [`DATA_WIDTH-1 : 0] Dout2,
    output [`DATA_WIDTH-1 : 0] Dout3
);

localparam DW      = `DATA_WIDTH;
localparam [DW-1:0] CONST_I     = 12'd1729; // omega^4
localparam [DW-1:0] CONST_I_INV = 12'd1600;

wire [DW-1:0] a0, b0, a1, b1, w0, w1, w2, tw_pwm;
assign a0     = rbfu_a0;
assign b0     = rbfu_b0;
assign a1     = rbfu_a1;
assign b1     = rbfu_b1;
assign w0     = rbfu_w0;
assign w1     = rbfu_w1;
assign w2     = rbfu_w2;
assign tw_pwm = rbfu_tw_pwm;

// -----------------------------------------------------------------------------
// radix-2 path (NTT / INTT)
// -----------------------------------------------------------------------------
wire [DW-1:0] rad2_mul0, rad2_mul1;
Modmul u_rad2_mul0(.clk(clk), .A(b0), .B(w0), .R(rad2_mul0));
Modmul u_rad2_mul1(.clk(clk), .A(b1), .B(w1), .R(rad2_mul1));

wire [DW-1:0] rad2_ntt_ma0, rad2_ntt_ms0;
wire [DW-1:0] rad2_ntt_ma1, rad2_ntt_ms1;
MA u_rad2_ntt_ma0(.MA_a(a0),       .MA_b(rad2_mul0), .MA_s(rad2_ntt_ma0));
MS u_rad2_ntt_ms0(.MS_a(a0),       .MS_b(rad2_mul0), .MS_s(rad2_ntt_ms0));
MA u_rad2_ntt_ma1(.MA_a(a1),       .MA_b(rad2_mul1), .MA_s(rad2_ntt_ma1));
MS u_rad2_ntt_ms1(.MS_a(a1),       .MS_b(rad2_mul1), .MS_s(rad2_ntt_ms1));

wire [DW-1:0] rad2_intt_sum0, rad2_intt_sum1;
wire [DW-1:0] rad2_intt_diff0, rad2_intt_diff1;
MA u_rad2_intt_sum0 (.MA_a(a0), .MA_b(b0), .MA_s(rad2_intt_sum0));
MA u_rad2_intt_sum1 (.MA_a(a1), .MA_b(b1), .MA_s(rad2_intt_sum1));
MS u_rad2_intt_diff0(.MS_a(b0), .MS_b(a0), .MS_s(rad2_intt_diff0));
MS u_rad2_intt_diff1(.MS_a(b1), .MS_b(a1), .MS_s(rad2_intt_diff1));

wire [DW-1:0] rad2_intt_div_sum0, rad2_intt_div_sum1;
wire [DW-1:0] rad2_intt_div_diff0, rad2_intt_div_diff1;
Div2 u_rad2_intt_div_sum0 (.x(rad2_intt_sum0),  .y(rad2_intt_div_sum0));
Div2 u_rad2_intt_div_sum1 (.x(rad2_intt_sum1),  .y(rad2_intt_div_sum1));
Div2 u_rad2_intt_div_diff0(.x(rad2_intt_diff0), .y(rad2_intt_div_diff0));
Div2 u_rad2_intt_div_diff1(.x(rad2_intt_diff1), .y(rad2_intt_div_diff1));

wire [DW-1:0] rad2_intt_mul0, rad2_intt_mul1;
Modmul u_rad2_intt_mul0(.clk(clk), .A(rad2_intt_div_diff0), .B(w0), .R(rad2_intt_mul0));
Modmul u_rad2_intt_mul1(.clk(clk), .A(rad2_intt_div_diff1), .B(w1), .R(rad2_intt_mul1));

wire [DW-1:0] rad2_ntt_out0, rad2_ntt_out1, rad2_ntt_out2, rad2_ntt_out3;
wire [DW-1:0] rad2_intt_out0, rad2_intt_out1, rad2_intt_out2, rad2_intt_out3;
assign rad2_ntt_out0  = rad2_ntt_ma0;
assign rad2_ntt_out1  = rad2_ntt_ms0;
assign rad2_ntt_out2  = rad2_ntt_ma1;
assign rad2_ntt_out3  = rad2_ntt_ms1;
assign rad2_intt_out0 = rad2_intt_div_sum0;
assign rad2_intt_out1 = rad2_intt_mul0;
assign rad2_intt_out2 = rad2_intt_div_sum1;
assign rad2_intt_out3 = rad2_intt_mul1;

// -----------------------------------------------------------------------------
// radix-4 path (NTT / INTT)
// mapping: a0=rbfu_a0, a1=rbfu_b0, a2=rbfu_a1, a3=rbfu_b1
// -----------------------------------------------------------------------------
wire [DW-1:0] r4_mul_a2_w2, r4_mul_a1_w1, r4_mul_a3_w3;
Modmul u_r4_mul_a2_w2(.clk(clk), .A(a1), .B(w1), .R(r4_mul_a2_w2));
Modmul u_r4_mul_a1_w1(.clk(clk), .A(b0), .B(w0), .R(r4_mul_a1_w1));
Modmul u_r4_mul_a3_w3(.clk(clk), .A(b1), .B(w2), .R(r4_mul_a3_w3));

wire [DW-1:0] r4_T0, r4_T1, r4_T2, r4_T3;
MA u_r4_T0(.MA_a(a0),          .MA_b(r4_mul_a2_w2), .MA_s(r4_T0));
MS u_r4_T1(.MS_a(a0),          .MS_b(r4_mul_a2_w2), .MS_s(r4_T1));
MA u_r4_T2(.MA_a(r4_mul_a1_w1),.MA_b(r4_mul_a3_w3), .MA_s(r4_T2));
MS u_r4_T3(.MS_a(r4_mul_a1_w1),.MS_b(r4_mul_a3_w3), .MS_s(r4_T3));

wire [DW-1:0] r4_T4;
Modmul u_r4_T4(.clk(clk), .A(r4_T3), .B(CONST_I), .R(r4_T4));

wire [DW-1:0] r4_y0, r4_y1, r4_y2, r4_y3;
MA u_r4_y0(.MA_a(r4_T0), .MA_b(r4_T2), .MA_s(r4_y0));
MS u_r4_y2(.MS_a(r4_T0), .MS_b(r4_T2), .MS_s(r4_y2));
MA u_r4_y1(.MA_a(r4_T1), .MA_b(r4_T4), .MA_s(r4_y1));
MS u_r4_y3(.MS_a(r4_T1), .MS_b(r4_T4), .MS_s(r4_y3));

wire [DW-1:0] rad4_ntt_out0, rad4_ntt_out1, rad4_ntt_out2, rad4_ntt_out3;
assign rad4_ntt_out0 = r4_y0;
assign rad4_ntt_out1 = r4_y2;
assign rad4_ntt_out2 = r4_y1;
assign rad4_ntt_out3 = r4_y3;

// -------------------- radix-4 INTT --------------------
wire [DW-1:0] r4_intt_sum0, r4_intt_diff0, r4_intt_sum1, r4_intt_diff1;
MA u_r4_intt_sum0 (.MA_a(a0), .MA_b(b0), .MA_s(r4_intt_sum0)); // y0 + y2
MS u_r4_intt_diff0(.MS_a(a0), .MS_b(b0), .MS_s(r4_intt_diff0));
MA u_r4_intt_sum1 (.MA_a(a1), .MA_b(b1), .MA_s(r4_intt_sum1)); // y1 + y3
MS u_r4_intt_diff1(.MS_a(a1), .MS_b(b1), .MS_s(r4_intt_diff1));

wire [DW-1:0] r4_intt_T0, r4_intt_T1, r4_intt_T2, r4_intt_T3_temp, r4_intt_T3;
Div2 u_r4_intt_T0     (.x(r4_intt_sum0),  .y(r4_intt_T0));
Div2 u_r4_intt_T2     (.x(r4_intt_diff0), .y(r4_intt_T2));
Div2 u_r4_intt_T1     (.x(r4_intt_sum1),  .y(r4_intt_T1));
Div2 u_r4_intt_T3temp (.x(r4_intt_diff1), .y(r4_intt_T3_temp));
Modmul u_r4_intt_T3   (.clk(clk), .A(r4_intt_T3_temp), .B(CONST_I_INV), .R(r4_intt_T3));

wire [DW-1:0] r4_intt_ma_T0T1, r4_intt_ms_T0T1, r4_intt_ma_T2T3, r4_intt_ms_T2T3;
MA u_r4_intt_ma_T0T1(.MA_a(r4_intt_T0), .MA_b(r4_intt_T1), .MA_s(r4_intt_ma_T0T1));
MS u_r4_intt_ms_T0T1(.MS_a(r4_intt_T0), .MS_b(r4_intt_T1), .MS_s(r4_intt_ms_T0T1));
MA u_r4_intt_ma_T2T3(.MA_a(r4_intt_T2), .MA_b(r4_intt_T3), .MA_s(r4_intt_ma_T2T3));
MS u_r4_intt_ms_T2T3(.MS_a(r4_intt_T2), .MS_b(r4_intt_T3), .MS_s(r4_intt_ms_T2T3));

wire [DW-1:0] r4_intt_a0, r4_intt_a1, r4_intt_a2, r4_intt_a3;
Div2 u_r4_intt_a0_div(.x(r4_intt_ma_T0T1), .y(r4_intt_a0));
wire [DW-1:0] r4_intt_a2_div;
Div2 u_r4_intt_a2_div(.x(r4_intt_ms_T0T1), .y(r4_intt_a2_div));
Modmul u_r4_intt_a2_mul(.clk(clk), .A(r4_intt_a2_div), .B(w1), .R(r4_intt_a2));
wire [DW-1:0] r4_intt_a1_div;
Div2 u_r4_intt_a1_div(.x(r4_intt_ma_T2T3), .y(r4_intt_a1_div));
Modmul u_r4_intt_a1_mul(.clk(clk), .A(r4_intt_a1_div), .B(w0), .R(r4_intt_a1));
wire [DW-1:0] r4_intt_a3_div;
Div2 u_r4_intt_a3_div(.x(r4_intt_ms_T2T3), .y(r4_intt_a3_div));
Modmul u_r4_intt_a3_mul(.clk(clk), .A(r4_intt_a3_div), .B(w2), .R(r4_intt_a3));

wire [DW-1:0] rad4_intt_out0, rad4_intt_out1, rad4_intt_out2, rad4_intt_out3;
assign rad4_intt_out0 = r4_intt_a0;
assign rad4_intt_out1 = r4_intt_a1;
assign rad4_intt_out2 = r4_intt_a2;
assign rad4_intt_out3 = r4_intt_a3;

// -----------------------------------------------------------------------------
// PWM (radix-4 only) - two-stage pipeline
// f0=rbfu_a0, g0=rbfu_b0, f1=rbfu_a1, g1=rbfu_b1, tw=rbfu_tw_pwm
// -----------------------------------------------------------------------------
wire [DW-1:0] pwm_s0, pwm_s1;
MA u_pwm_s0(.MA_a(a0), .MA_b(a1), .MA_s(pwm_s0));
MA u_pwm_s1(.MA_a(b0), .MA_b(b1), .MA_s(pwm_s1));

wire [DW-1:0] pwm_m0, pwm_m1;
Modmul u_pwm_m0(.clk(clk), .A(a0), .B(b0), .R(pwm_m0));
Modmul u_pwm_m1(.clk(clk), .A(a1), .B(b1), .R(pwm_m1));

reg [DW-1:0] pwm_s0_r, pwm_s1_r, pwm_m0_r, pwm_m1_r, pwm_tw_r;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        pwm_s0_r <= {DW{1'b0}};
        pwm_s1_r <= {DW{1'b0}};
        pwm_m0_r <= {DW{1'b0}};
        pwm_m1_r <= {DW{1'b0}};
        pwm_tw_r <= {DW{1'b0}};
    end else begin
        pwm_s0_r <= pwm_s0;
        pwm_s1_r <= pwm_s1;
        pwm_m0_r <= pwm_m0;
        pwm_m1_r <= pwm_m1;
        pwm_tw_r <= tw_pwm;
    end
end

wire [DW-1:0] pwm_m1_tw;
Modmul u_pwm_m1_tw(.clk(clk), .A(pwm_m1_r), .B(pwm_tw_r), .R(pwm_m1_tw));

wire [DW-1:0] pwm_h0;
MA u_pwm_h0(.MA_a(pwm_m0_r), .MA_b(pwm_m1_tw), .MA_s(pwm_h0));

wire [DW-1:0] pwm_s0s1, pwm_m0m1;
Modmul u_pwm_s0s1(.clk(clk), .A(pwm_s0_r), .B(pwm_s1_r), .R(pwm_s0s1));
MA     u_pwm_m0m1(.MA_a(pwm_m0_r), .MA_b(pwm_m1_r), .MA_s(pwm_m0m1));

wire [DW-1:0] pwm_h1;
MS u_pwm_h1(.MS_a(pwm_s0s1), .MS_b(pwm_m0m1), .MS_s(pwm_h1));

// -----------------------------------------------------------------------------
// Final output selection (case only routes precomputed results)
// -----------------------------------------------------------------------------
reg [DW-1:0] out0, out1, out2, out3;
always @(*) begin
    case(opcode)
        `NTT: begin
            if (radix_mode) begin
                out0 = rad4_ntt_out0; out1 = rad4_ntt_out1; out2 = rad4_ntt_out2; out3 = rad4_ntt_out3;
            end else begin
                out0 = rad2_ntt_out0; out1 = rad2_ntt_out1; out2 = rad2_ntt_out2; out3 = rad2_ntt_out3;
            end
        end
        `INTT: begin
            if (radix_mode) begin
                out0 = rad4_intt_out0; out1 = rad4_intt_out1; out2 = rad4_intt_out2; out3 = rad4_intt_out3;
            end else begin
                out0 = rad2_intt_out0; out1 = rad2_intt_out1; out2 = rad2_intt_out2; out3 = rad2_intt_out3;
            end
        end
        `PWM: begin
            out0 = radix_mode ? pwm_h0 : {DW{1'b0}};
            out1 = radix_mode ? pwm_h1 : {DW{1'b0}};
            out2 = {DW{1'b0}};
            out3 = {DW{1'b0}};
        end
        default: begin
            out0 = {DW{1'b0}}; out1 = {DW{1'b0}}; out2 = {DW{1'b0}}; out3 = {DW{1'b0}};
        end
    endcase
end

assign Dout0 = out0;
assign Dout1 = out1;
assign Dout2 = out2;
assign Dout3 = out3;

endmodule
`endif
