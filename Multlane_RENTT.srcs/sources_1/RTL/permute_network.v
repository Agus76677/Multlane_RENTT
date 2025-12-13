`include "parameter.v"

// Generic gather permutation: out[k] = in[sel_out[k]]
module permute_gather #(
    parameter integer N    = 2*`P,
    parameter integer W    = 1,
    parameter integer SELW = `MAP
) (
    input  [W*N-1:0]       in_bus,
    input  [SELW*N-1:0]    sel_out_bus,
    output [W*N-1:0]       out_bus
);

    wire [W-1:0]    in      [0:N-1];
    wire [SELW-1:0] sel_out [0:N-1];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : unpack
            assign in[i]      = in_bus[i*W + W-1 : i*W];
            assign sel_out[i] = sel_out_bus[i*SELW + SELW-1 : i*SELW];
            assign out_bus[i*W + W-1 : i*W] = in[sel_out[i]];
        end
    endgenerate
endmodule

// Generic scatter permutation: out[sel_in[j]] = in[j]
module permute_scatter #(
    parameter integer N    = 2*`P,
    parameter integer W    = 1,
    parameter integer SELW = `MAP
) (
    input  [SELW*N-1:0] sel_in_bus,
    input  [W*N-1:0]    in_bus,
    output [W*N-1:0]    out_bus
);

    wire [SELW-1:0] sel_in [0:N-1];
    wire [W-1:0]    in     [0:N-1];
    reg  [W-1:0]    out    [0:N-1];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : unpack
            assign sel_in[i] = sel_in_bus[i*SELW + SELW-1 : i*SELW];
            assign in[i]     = in_bus[i*W + W-1 : i*W];
            assign out_bus[i*W + W-1 : i*W] = out[i];
        end
    endgenerate

    integer j, k;
    always @(*) begin
        // default values
        for (k = 0; k < N; k = k + 1) begin
            out[k] = {W{1'b0}};
        end
        // later indices overwrite earlier ones on collisions
        for (j = 0; j < N; j = j + 1) begin
            out[sel_in[j]] = in[j];
        end
    end
endmodule

