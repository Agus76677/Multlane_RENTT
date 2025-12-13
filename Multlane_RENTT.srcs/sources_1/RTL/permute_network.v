`include "parameter.v"

// Generic gather network: out[k] = in[ sel_out[k] ]
module permute_gather #(
    parameter integer N    = 2*`P,
    parameter integer W    = 1,
    parameter integer SELW = `MAP
) (
    input  [N*W-1:0]       in_bus,
    input  [N*SELW-1:0]    sel_out_bus,
    output [N*W-1:0]       out_bus
);

    wire [W-1:0]       in_arr   [0:N-1];
    wire [SELW-1:0]    sel_out  [0:N-1];
    reg  [W-1:0]       out_arr  [0:N-1];

    genvar gi;
    generate
        for (gi = 0; gi < N; gi = gi + 1) begin : gen_unpack
            assign in_arr[gi]  = in_bus[gi*W + W-1 : gi*W];
            assign sel_out[gi] = sel_out_bus[gi*SELW + SELW-1 : gi*SELW];
            assign out_bus[gi*W + W-1 : gi*W] = out_arr[gi];
        end
    endgenerate

    integer k;
    always @(*) begin
        for (k = 0; k < N; k = k + 1) begin
            if (sel_out[k] < N[SELW-1:0]) begin
                out_arr[k] = in_arr[sel_out[k]];
            end else begin
                out_arr[k] = {W{1'b0}};
            end
        end
    end
endmodule

// Generic scatter network: out[ sel_in[j] ] = in[j]
module permute_scatter #(
    parameter integer N    = 2*`P,
    parameter integer W    = 1,
    parameter integer SELW = `MAP
) (
    input  [N*W-1:0]       in_bus,
    input  [N*SELW-1:0]    sel_in_bus,
    output [N*W-1:0]       out_bus
);

    wire [W-1:0]       in_arr  [0:N-1];
    wire [SELW-1:0]    sel_in  [0:N-1];
    reg  [W-1:0]       out_arr [0:N-1];

    genvar si;
    generate
        for (si = 0; si < N; si = si + 1) begin : gen_unpack
            assign in_arr[si]  = in_bus[si*W + W-1 : si*W];
            assign sel_in[si]  = sel_in_bus[si*SELW + SELW-1 : si*SELW];
            assign out_bus[si*W + W-1 : si*W] = out_arr[si];
        end
    endgenerate

    integer j, m;
    always @(*) begin
        for (m = 0; m < N; m = m + 1) begin
            out_arr[m] = {W{1'b0}};
        end

        for (j = 0; j < N; j = j + 1) begin
            if (sel_in[j] < N[SELW-1:0]) begin
                out_arr[sel_in[j]] = in_arr[j];
            end
        end
    end
endmodule

