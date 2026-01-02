`timescale 1ns / 1ps

module modular_mul #(parameter data_width = 12)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire [data_width-1:0]  A_in,
    input  wire [data_width-1:0]  B_in,
    output wire [data_width-1:0]  P_out
);

    // q = 3329
    localparam [data_width-1:0] q  = 12'd3329;

    // mu = floor(2^24 / q) = 5038
    localparam [12:0] mu = 13'd5038;

    // --------------------------------------------------
    // Stage 0: full multiply
    // --------------------------------------------------
    wire [2*data_width-1:0] z = A_in * B_in;

    wire [2*data_width-1:0] z_q1;
    DFF #(.data_width(2*data_width)) dff_z1 (
        .clk(clk), .rst(rst), .d(z), .q(z_q1)
    );

    // --------------------------------------------------
    // FIX: align z with m*q path (add 2-cycle delay)
    // z_q3 is z delayed total 3 cycles from input, same as m_q_q
    // --------------------------------------------------
    wire [2*data_width-1:0] z_q2, z_q3;
    DFF #(.data_width(2*data_width)) dff_z2 (
        .clk(clk), .rst(rst), .d(z_q1), .q(z_q2)
    );
    DFF #(.data_width(2*data_width)) dff_z3 (
        .clk(clk), .rst(rst), .d(z_q2), .q(z_q3)
    );

    // --------------------------------------------------
    // Stage 1: t = floor(z / 2^k), k = 12
    // --------------------------------------------------
    wire [data_width:0] t = z_q1 >> data_width;

    // --------------------------------------------------
    // Stage 2: t * mu
    // --------------------------------------------------
    wire [2*data_width:0] t_mu = t * mu;

    wire [2*data_width:0] t_mu_q;
    DFF #(.data_width(2*data_width+1)) dff_tmu (
        .clk(clk), .rst(rst), .d(t_mu), .q(t_mu_q)
    );

    // --------------------------------------------------
    // Stage 3: m = floor(t_mu / 2^12)
    // --------------------------------------------------
    wire [data_width:0] m = t_mu_q >> data_width;

    // --------------------------------------------------
    // Stage 4: m * q
    // --------------------------------------------------
    wire [2*data_width-1:0] m_q = m * q;

    wire [2*data_width-1:0] m_q_q;
    DFF #(.data_width(2*data_width)) dff_mq (
        .clk(clk), .rst(rst), .d(m_q), .q(m_q_q)
    );

    // --------------------------------------------------
    // Stage 5: r = z - m*q (NOW ALIGNED)
    // --------------------------------------------------
    wire [2*data_width-1:0] r0 = z_q3 - m_q_q;

    // --------------------------------------------------
    // Stage 6: final correction (handle up to 3q)
    // --------------------------------------------------
    wire [2*data_width-1:0] q1  = {{(2*data_width-data_width){1'b0}}, q};
    wire [2*data_width-1:0] q2  = q1 << 1;          // 2q
    wire [2*data_width-1:0] q3  = q2 + q1;          // 3q

    wire [2*data_width-1:0] r_fix =
        (r0 >= q3) ? (r0 - q3) :
        (r0 >= q2) ? (r0 - q2) :
        (r0 >= q1) ? (r0 - q1) :
                    r0;

    DFF #(.data_width(data_width)) dff_out (
        .clk(clk), .rst(rst), .d(r_fix[data_width-1:0]), .q(P_out)
    );


endmodule
