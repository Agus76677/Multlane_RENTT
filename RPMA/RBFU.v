`timescale 1ns / 1ps
`include "parameter.v"
//////////////////////////////////////////////////////////////////////////////////
// opcode:00 NTT
// opcode:01 INTT
// opcode:10 PWM
// opcode:11 reserved
// RAD4 端口映射：
//   a0=rbfu_a0, a1=rbfu_b0, a2=rbfu_a1, a3=rbfu_b1
//   w1=rbfu_w0, w2=rbfu_w1, w3=rbfu_w2
// RAD2 端口映射：
//   pair0: (a0=rbfu_a0,b0=rbfu_b0,w0=rbfu_w0)
//   pair1: (a1=rbfu_a1,b1=rbfu_b1,w1=rbfu_w1)
// PWM 映射：
//   f0=rbfu_a0, g0=rbfu_b0, f1=rbfu_a1, g1=rbfu_b1, tw=rbfu_tw_pwm
//////////////////////////////////////////////////////////////////////////////////
`ifdef PIPE1
module RBFU(
    input                      clk,
    input                      rst,
    input                      radix_mode, //0:RAD2 1:RAD4
    input  [`DATA_WIDTH-1 : 0] rbfu_a0,rbfu_b0,rbfu_w0,
    input  [`DATA_WIDTH-1 : 0] rbfu_a1,rbfu_b1,rbfu_w1,
    input  [`DATA_WIDTH-1 : 0] rbfu_w2,
    input  [`DATA_WIDTH-1 : 0] rbfu_tw_pwm,
    input  [1:0]               opcode,
    output [`DATA_WIDTH-1 : 0] Dout0,
    output [`DATA_WIDTH-1 : 0] Dout1,
    output [`DATA_WIDTH-1 : 0] Dout2,
    output [`DATA_WIDTH-1 : 0] Dout3
);

localparam DW      = `DATA_WIDTH;
localparam I_CONST = 12'd1729;
localparam I_INV   = 12'd1600;

wire [DW-1:0] r4_in_a0 = rbfu_a0;
wire [DW-1:0] r4_in_a1 = rbfu_b0;
wire [DW-1:0] r4_in_a2 = rbfu_a1;
wire [DW-1:0] r4_in_a3 = rbfu_b1;

//====================== mul pool ======================//
reg  [DW-1:0] mul0_a, mul0_b;
reg  [DW-1:0] mul1_a, mul1_b;
reg  [DW-1:0] mul2_a, mul2_b;
reg  [DW-1:0] mul3_a, mul3_b;
wire [DW-1:0] mul0_p, mul1_p, mul2_p, mul3_p;

Modmul u_Modmul0(.clk(clk), .A(mul0_a), .B(mul0_b), .R(mul0_p));
Modmul u_Modmul1(.clk(clk), .A(mul1_a), .B(mul1_b), .R(mul1_p));
Modmul u_Modmul2(.clk(clk), .A(mul2_a), .B(mul2_b), .R(mul2_p));
Modmul u_Modmul3(.clk(clk), .A(mul3_a), .B(mul3_b), .R(mul3_p));

//====================== RAD2 path ======================//
wire [DW-1:0] rad2_ma0_s, rad2_ma1_s;
wire [DW-1:0] rad2_ms0_s, rad2_ms1_s;
wire [DW-1:0] rad2_div0_s, rad2_div1_s;
wire [DW-1:0] rad2_sub0_s, rad2_sub1_s;
wire [DW-1:0] rad2_sum0_div2, rad2_sum1_div2;
wire [DW-1:0] rad2_sub0_div2, rad2_sub1_div2;

reg  [DW-1:0] rad2_a0_r, rad2_a1_r;
reg  [DW-1:0] rad2_a0_ff, rad2_a1_ff;
reg  [DW-1:0] rad2_b0_r, rad2_b1_r;
reg  [DW-1:0] rad2_w0_r, rad2_w1_r;
reg          rad2_ntt_en_d, rad2_ntt_en_ff;
reg          rad2_intt_en_d, rad2_intt_en_ff;
reg  [DW-1:0] rad2_sum0_div2_r, rad2_sum1_div2_r;
reg  [DW-1:0] rad2_sum0_div2_ff, rad2_sum1_div2_ff;
reg  [DW-1:0] rad2_sub0_div2_r, rad2_sub1_div2_r;

MA u_rad2_ma0(.MA_a(rad2_a0_ff), .MA_b(mul0_p), .MA_s(rad2_ma0_s));
MA u_rad2_ma1(.MA_a(rad2_a1_ff), .MA_b(mul1_p), .MA_s(rad2_ma1_s));
MS u_rad2_ms0(.MS_a(rad2_a0_ff), .MS_b(mul0_p), .MS_s(rad2_ms0_s));
MS u_rad2_ms1(.MS_a(rad2_a1_ff), .MS_b(mul1_p), .MS_s(rad2_ms1_s));

MA u_rad2_sum0(.MA_a(rbfu_a0), .MA_b(rbfu_b0), .MA_s(rad2_div0_s));
MA u_rad2_sum1(.MA_a(rbfu_a1), .MA_b(rbfu_b1), .MA_s(rad2_div1_s));
MS u_rad2_diff0(.MS_a(rbfu_b0), .MS_b(rbfu_a0), .MS_s(rad2_sub0_s));
MS u_rad2_diff1(.MS_a(rbfu_b1), .MS_b(rbfu_a1), .MS_s(rad2_sub1_s));

Div2 u_rad2_div_sum0(.x(rad2_div0_s), .y(rad2_sum0_div2));
Div2 u_rad2_div_sum1(.x(rad2_div1_s), .y(rad2_sum1_div2));
Div2 u_rad2_div_sub0(.x(rad2_sub0_s), .y(rad2_sub0_div2));
Div2 u_rad2_div_sub1(.x(rad2_sub1_s), .y(rad2_sub1_div2));

//====================== RAD4 NTT =======================//
reg  [DW-1:0] r4_a0_r, r4_a1_r, r4_a2_r, r4_a3_r;
reg          r4_ntt_en_d1, r4_ntt_en_d2;

wire [DW-1:0] r4_t0, r4_t1, r4_t2, r4_t3;
MA u_r4_t0(.MA_a(r4_a0_r), .MA_b(mul0_p), .MA_s(r4_t0));
MS u_r4_t1(.MS_a(r4_a0_r), .MS_b(mul0_p), .MS_s(r4_t1));
MA u_r4_t2(.MA_a(mul1_p), .MA_b(mul2_p), .MA_s(r4_t2));
MS u_r4_t3(.MS_a(mul1_p), .MS_b(mul2_p), .MS_s(r4_t3));

reg [DW-1:0] r4_t0_ff, r4_t1_ff, r4_t2_ff;
reg [DW-1:0] r4_t3_reg;
reg [DW-1:0] r4_t4_ff;

wire [DW-1:0] r4_y0, r4_y1, r4_y2, r4_y3;
MA u_r4_y0(.MA_a(r4_t0_ff), .MA_b(r4_t2_ff), .MA_s(r4_y0));
MS u_r4_y2(.MS_a(r4_t0_ff), .MS_b(r4_t2_ff), .MS_s(r4_y2));
MA u_r4_y1(.MA_a(r4_t1_ff), .MA_b(r4_t4_ff), .MA_s(r4_y1));
MS u_r4_y3(.MS_a(r4_t1_ff), .MS_b(r4_t4_ff), .MS_s(r4_y3));

//====================== RAD4 INTT ======================//
wire [DW-1:0] intt_y0, intt_y2, intt_y1, intt_y3;
assign intt_y0 = rbfu_a0;
assign intt_y2 = rbfu_b0;
assign intt_y1 = rbfu_a1;
assign intt_y3 = rbfu_b1;

wire [DW-1:0] intt_u0, intt_u1, intt_u2, intt_d;
MA u_intt_u0 (.MA_a(intt_y0), .MA_b(intt_y2), .MA_s(intt_u0));
MS u_intt_u2 (.MS_a(intt_y0), .MS_b(intt_y2), .MS_s(intt_u2));
MA u_intt_u1 (.MA_a(intt_y1), .MA_b(intt_y3), .MA_s(intt_u1));
MS u_intt_d  (.MS_a(intt_y1), .MS_b(intt_y3), .MS_s(intt_d));

wire [DW-1:0] intt_u0_div2, intt_u1_div2, intt_u2_div2, intt_d_div2;
Div2 u_intt_div_u0(.x(intt_u0), .y(intt_u0_div2));
Div2 u_intt_div_u1(.x(intt_u1), .y(intt_u1_div2));
Div2 u_intt_div_u2(.x(intt_u2), .y(intt_u2_div2));
Div2 u_intt_div_d (.x(intt_d),  .y(intt_d_div2));

reg [DW-1:0] intt_u0_r, intt_u1_r, intt_u2_r;
reg [DW-1:0] intt_w1_r, intt_w2_r, intt_w3_r;
reg          intt_stageA_en, intt_stageB_en, intt_stageC_en;

wire [DW-1:0] intt_a0_half, intt_v1, intt_v2, intt_v3;
wire [DW-1:0] intt_a0_half_w, intt_v2_div2_w, intt_v1_div2_w, intt_v3_div2_w;
MA   u_intt_a0   (.MA_a(intt_u0_r), .MA_b(intt_u1_r), .MA_s(intt_a0_half));
Div2 u_intt_a0_d (.x(intt_a0_half), .y(intt_a0_half_w));
MS   u_intt_v2_0 (.MS_a(intt_u0_r), .MS_b(intt_u1_r), .MS_s(intt_v2));
Div2 u_intt_v2_d (.x(intt_v2), .y(intt_v2_div2_w));
MA   u_intt_v1_0 (.MA_a(intt_u2_r), .MA_b(mul3_p), .MA_s(intt_v1));
Div2 u_intt_v1_d (.x(intt_v1), .y(intt_v1_div2_w));
MS   u_intt_v3_0 (.MS_a(intt_u2_r), .MS_b(mul3_p), .MS_s(intt_v3));
Div2 u_intt_v3_d (.x(intt_v3), .y(intt_v3_div2_w));

reg [DW-1:0] intt_a0_reg;
reg [DW-1:0] intt_v1_reg, intt_v2_reg, intt_v3_reg;

//====================== PWM ============================//
wire pwm_stage0_en = (opcode == `PWM) && radix_mode;
reg  pwm_stage1_en_d, pwm_stage2_en_d;

wire [DW-1:0] pwm_s0, pwm_s1;
MA u_pwm_s0(.MA_a(rbfu_a0), .MA_b(rbfu_a1), .MA_s(pwm_s0));
MA u_pwm_s1(.MA_a(rbfu_b0), .MA_b(rbfu_b1), .MA_s(pwm_s1));

reg [DW-1:0] pwm_s0_r, pwm_s1_r;
reg [DW-1:0] pwm_m0_r, pwm_m1_r;
reg [DW-1:0] pwm_tw_r;

wire [DW-1:0] pwm_h0, pwm_h1, pwm_m0m1_sum;
MA u_pwm_h0(.MA_a(pwm_m0_r), .MA_b(mul2_p), .MA_s(pwm_h0));
MA u_pwm_m0m1(.MA_a(pwm_m0_r), .MA_b(pwm_m1_r), .MA_s(pwm_m0m1_sum));
MS u_pwm_h1(.MS_a(mul3_p), .MS_b(pwm_m0m1_sum), .MS_s(pwm_h1));

//====================== control pipeline ==============//
always @(posedge clk) begin
    if (rst) begin
        r4_a0_r <= {DW{1'b0}}; r4_a1_r <= {DW{1'b0}}; r4_a2_r <= {DW{1'b0}}; r4_a3_r <= {DW{1'b0}};
        r4_ntt_en_d1 <= 1'b0; r4_ntt_en_d2 <= 1'b0;
        r4_t0_ff <= {DW{1'b0}}; r4_t1_ff <= {DW{1'b0}}; r4_t2_ff <= {DW{1'b0}}; r4_t3_reg <= {DW{1'b0}}; r4_t4_ff <= {DW{1'b0}};

        intt_u0_r <= {DW{1'b0}}; intt_u1_r <= {DW{1'b0}}; intt_u2_r <= {DW{1'b0}};
        intt_w1_r <= {DW{1'b0}}; intt_w2_r <= {DW{1'b0}}; intt_w3_r <= {DW{1'b0}};
        intt_stageA_en <= 1'b0; intt_stageB_en <= 1'b0; intt_stageC_en <= 1'b0;
        intt_a0_reg <= {DW{1'b0}}; intt_v1_reg <= {DW{1'b0}}; intt_v2_reg <= {DW{1'b0}}; intt_v3_reg <= {DW{1'b0}};

        pwm_s0_r <= {DW{1'b0}}; pwm_s1_r <= {DW{1'b0}}; pwm_m0_r <= {DW{1'b0}}; pwm_m1_r <= {DW{1'b0}}; pwm_tw_r <= {DW{1'b0}};
        pwm_stage1_en_d <= 1'b0; pwm_stage2_en_d <= 1'b0;

        rad2_a0_r <= {DW{1'b0}}; rad2_a1_r <= {DW{1'b0}}; rad2_a0_ff <= {DW{1'b0}}; rad2_a1_ff <= {DW{1'b0}};
        rad2_b0_r <= {DW{1'b0}}; rad2_b1_r <= {DW{1'b0}}; rad2_w0_r <= {DW{1'b0}}; rad2_w1_r <= {DW{1'b0}};
        rad2_ntt_en_d <= 1'b0; rad2_ntt_en_ff <= 1'b0;
        rad2_intt_en_d <= 1'b0; rad2_intt_en_ff <= 1'b0;
        rad2_sum0_div2_r <= {DW{1'b0}}; rad2_sum1_div2_r <= {DW{1'b0}};
        rad2_sum0_div2_ff <= {DW{1'b0}}; rad2_sum1_div2_ff <= {DW{1'b0}};
        rad2_sub0_div2_r <= {DW{1'b0}}; rad2_sub1_div2_r <= {DW{1'b0}};
    end else begin
        // RAD4 NTT input capture
        r4_ntt_en_d1 <= (opcode == `NTT) && radix_mode;
        r4_ntt_en_d2 <= r4_ntt_en_d1;
        if ((opcode == `NTT) && radix_mode) begin
            r4_a0_r <= rbfu_a0;
            r4_a1_r <= rbfu_b0;
            r4_a2_r <= rbfu_a1;
            r4_a3_r <= rbfu_b1;
        end

        // RAD4 NTT stage compute alignment
        if (r4_ntt_en_d1) begin
            r4_t0_ff <= r4_t0;
            r4_t1_ff <= r4_t1;
            r4_t2_ff <= r4_t2;
            r4_t3_reg <= r4_t3;
        end else begin
            r4_t0_ff <= r4_t0_ff;
            r4_t1_ff <= r4_t1_ff;
            r4_t2_ff <= r4_t2_ff;
            r4_t3_reg <= r4_t3_reg;
        end
        if (r4_ntt_en_d2) begin
            r4_t4_ff <= mul3_p;
        end else begin
            r4_t4_ff <= r4_t4_ff;
        end

        // RAD4 INTT pipeline
        intt_stageA_en <= (opcode == `INTT) && radix_mode;
        intt_stageB_en <= intt_stageA_en;
        intt_stageC_en <= intt_stageB_en;
        if ((opcode == `INTT) && radix_mode) begin
            intt_u0_r <= intt_u0_div2;
            intt_u1_r <= intt_u1_div2;
            intt_u2_r <= intt_u2_div2;
            intt_w1_r <= rbfu_w0;
            intt_w2_r <= rbfu_w1;
            intt_w3_r <= rbfu_w2;
        end
        if (intt_stageB_en) begin
            intt_a0_reg <= intt_a0_half_w;
            intt_v1_reg <= intt_v1_div2_w;
            intt_v2_reg <= intt_v2_div2_w;
            intt_v3_reg <= intt_v3_div2_w;
        end

        // PWM pipeline enables
        pwm_stage1_en_d <= pwm_stage0_en;
        pwm_stage2_en_d <= pwm_stage1_en_d;
        if (pwm_stage0_en) begin
            pwm_s0_r <= pwm_s0;
            pwm_s1_r <= pwm_s1;
            pwm_tw_r <= rbfu_tw_pwm;
        end
        if (pwm_stage1_en_d) begin
            pwm_m0_r <= mul0_p;
            pwm_m1_r <= mul1_p;
        end

        // RAD2 alignment
        rad2_ntt_en_d <= (!radix_mode) && (opcode == `NTT);
        rad2_ntt_en_ff <= rad2_ntt_en_d;
        rad2_intt_en_d <= (!radix_mode) && (opcode == `INTT);
        rad2_intt_en_ff <= rad2_intt_en_d;
        rad2_a0_ff <= rad2_a0_r;
        rad2_a1_ff <= rad2_a1_r;
        if (!radix_mode) begin
            rad2_a0_r <= rbfu_a0;
            rad2_a1_r <= rbfu_a1;
            rad2_b0_r <= rbfu_b0;
            rad2_b1_r <= rbfu_b1;
            rad2_w0_r <= rbfu_w0;
            rad2_w1_r <= rbfu_w1;
        end
        rad2_sum0_div2_ff <= rad2_sum0_div2_r;
        rad2_sum1_div2_ff <= rad2_sum1_div2_r;
        if ((!radix_mode) && (opcode == `INTT)) begin
            rad2_sum0_div2_r <= rad2_sum0_div2;
            rad2_sum1_div2_r <= rad2_sum1_div2;
            rad2_sub0_div2_r <= rad2_sub0_div2;
            rad2_sub1_div2_r <= rad2_sub1_div2;
        end
    end
end

//====================== mul input selection ===========//
always @(*) begin
    mul0_a = {DW{1'b0}}; mul0_b = {DW{1'b0}};
    mul1_a = {DW{1'b0}}; mul1_b = {DW{1'b0}};
    mul2_a = {DW{1'b0}}; mul2_b = {DW{1'b0}};
    mul3_a = {DW{1'b0}}; mul3_b = {DW{1'b0}};

    case(opcode)
        `NTT: begin
            if (radix_mode) begin
                mul0_a = r4_in_a2; mul0_b = rbfu_w1; // a2*w2
                mul1_a = r4_in_a1; mul1_b = rbfu_w0; // a1*w1
                mul2_a = r4_in_a3; mul2_b = rbfu_w2; // a3*w3
                mul3_a = r4_t3_reg; mul3_b = I_CONST; // T3*I
            end else begin
                mul0_a = rad2_b0_r; mul0_b = rad2_w0_r;
                mul1_a = rad2_b1_r; mul1_b = rad2_w1_r;
            end
        end
        `INTT: begin
            if (radix_mode) begin
                mul3_a = intt_d_div2; mul3_b = I_INV;
                if (intt_stageB_en) begin
                    mul0_a = intt_v2_reg; mul0_b = intt_w2_r;
                    mul1_a = intt_v1_reg; mul1_b = intt_w1_r;
                    mul2_a = intt_v3_reg; mul2_b = intt_w3_r;
                end
            end else begin
                mul0_a = rad2_sub0_div2; mul0_b = rad2_w0_r;
                mul1_a = rad2_sub1_div2; mul1_b = rad2_w1_r;
            end
        end
        `PWM: begin
            if (radix_mode) begin
                mul0_a = rbfu_a0; mul0_b = rbfu_b0;
                mul1_a = rbfu_a1; mul1_b = rbfu_b1;
                mul2_a = pwm_m1_r; mul2_b = pwm_tw_r;
                mul3_a = pwm_s0_r; mul3_b = pwm_s1_r;
            end
        end
        default: begin end
    endcase
end

//====================== outputs ========================//
reg [DW-1:0] out0_r, out1_r, out2_r, out3_r;
always @(*) begin
    out0_r = {DW{1'b0}}; out1_r = {DW{1'b0}}; out2_r = {DW{1'b0}}; out3_r = {DW{1'b0}};
    case(opcode)
        `NTT: begin
            if (radix_mode) begin
                if (r4_ntt_en_d2) begin
                    out0_r = r4_y0; out1_r = r4_y2; out2_r = r4_y1; out3_r = r4_y3;
                end
            end else begin
                if (rad2_ntt_en_d) begin
                    out0_r = rad2_ma0_s; out1_r = rad2_ms0_s; out2_r = rad2_ma1_s; out3_r = rad2_ms1_s;
                end
            end
        end
        `INTT: begin
            if (radix_mode) begin
                if (intt_stageC_en) begin
                    out0_r = intt_a0_reg;
                    out1_r = mul1_p;
                    out2_r = mul0_p;
                    out3_r = mul2_p;
                end
            end else begin
                if (rad2_intt_en_d) begin
                    out0_r = rad2_sum0_div2_ff; out1_r = mul0_p; out2_r = rad2_sum1_div2_ff; out3_r = mul1_p;
                end
            end
        end
        `PWM: begin
            if (radix_mode && pwm_stage2_en_d) begin
                out0_r = pwm_h0; out1_r = pwm_h1; out2_r = {DW{1'b0}}; out3_r = {DW{1'b0}};
            end
        end
        default: begin end
    endcase
end

assign Dout0 = out0_r;
assign Dout1 = out1_r;
assign Dout2 = out2_r;
assign Dout3 = out3_r;

endmodule
`endif
