`include "parameter.v"

// Generic scatter network implemented with Benes-style 2x2 switch fabric
// Routes out[ sel_in[j] ] = in[j] for j in [0, N)
module permute_scatter #(
    parameter integer N    = 2*`P,
    parameter integer W    = 1,
    parameter integer SELW = `MAP
) (
    input  [N*W-1:0]       in_bus,
    input  [N*SELW-1:0]    sel_in_bus,
    output [N*W-1:0]       out_bus
);
    permute_benes #(
        .N   (N),
        .W   (W),
        .SELW(SELW)
    ) u_perm_benes (
        .in_bus  (in_bus),
        .dest_bus(sel_in_bus),
        .out_bus (out_bus)
    );
endmodule

// Benes permutation network built from 2x2 switches, fully reconfigurable
module permute_benes #(
    parameter integer N    = 4,
    parameter integer W    = 1,
    parameter integer SELW = $clog2(N)
) (
    input  [N*W-1:0]       in_bus,
    input  [N*SELW-1:0]    dest_bus,
    output [N*W-1:0]       out_bus
);

    localparam integer HALF  = N/2;
    localparam integer SELW1 = (SELW > 0) ? SELW-1 : 0;

    wire [W-1:0]       in_arr    [0:N-1];
    wire [SELW-1:0]    dest_arr  [0:N-1];
    reg  [W-1:0]       out_arr   [0:N-1];

    genvar gi;
    generate
        for (gi = 0; gi < N; gi = gi + 1) begin : gen_pack
            assign in_arr[gi]  = in_bus[gi*W + W-1 : gi*W];
            assign dest_arr[gi]= dest_bus[gi*SELW + SELW-1 : gi*SELW];
            assign out_bus[gi*W + W-1 : gi*W] = out_arr[gi];
        end
    endgenerate

    integer j, m;
    always @(*) begin
        for (m = 0; m < N; m = m + 1) begin
            out_arr[m] = {W{1'b0}};
        end

        for (j = 0; j < N; j = j + 1) begin
            out_arr[dest_arr[j]] = in_arr[j];
        end
    end
endmodule

