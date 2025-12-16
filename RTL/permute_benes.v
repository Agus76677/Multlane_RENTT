`include "parameter.v"

// Switch-based permutation network implemented with a bitonic compare-and-swap fabric.
// Routes lane-ordered inputs to output indices given by dest_bus: out[dest[i]] = in[i].
// Supports N = 2^k up to small sizes used in this design (4/8/16/32).
module permute_benes #(
    parameter integer N    = 2*`P,
    parameter integer W    = 1,
    parameter integer SELW = `MAP
) (
    input  [N*W-1:0]       in_bus,
    input  [N*SELW-1:0]    dest_bus,
    output [N*W-1:0]       out_bus
);

    // Unpack buses
    wire [W-1:0]       in_arr     [0:N-1];
    wire [SELW-1:0]    dest_in    [0:N-1];
    reg  [W-1:0]       data_arr   [0:N-1];
    reg  [SELW-1:0]    dest_arr   [0:N-1];
    integer            i;
    integer            k, j, idx, ixj;
    reg [W-1:0]        data_tmp;
    reg [SELW-1:0]     dest_tmp;

    genvar g;
    generate
        for (g = 0; g < N; g = g + 1) begin : gen_unpack
            assign in_arr[g]  = in_bus[g*W + W-1 : g*W];
            assign dest_in[g] = dest_bus[g*SELW + SELW-1 : g*SELW];
        end
    endgenerate

    always @(*) begin
        for (i = 0; i < N; i = i + 1) begin
            data_arr[i] = in_arr[i];
            dest_arr[i] = dest_in[i];
        end

        // Bitonic sorting network on dest_arr, swapping payloads alongside.
        for (k = 2; k <= N; k = k << 1) begin
            for (j = k >> 1; j > 0; j = j >> 1) begin
                for (idx = 0; idx < N; idx = idx + 1) begin
                    ixj = idx ^ j;
                    if (ixj > idx) begin
                        // Ascending in even partitions, descending in odd partitions
                        if (((idx & k) == 0 && dest_arr[idx] > dest_arr[ixj]) ||
                            ((idx & k) != 0 && dest_arr[idx] < dest_arr[ixj])) begin
                            data_tmp       = data_arr[idx];
                            data_arr[idx]  = data_arr[ixj];
                            data_arr[ixj]  = data_tmp;

                            dest_tmp       = dest_arr[idx];
                            dest_arr[idx]  = dest_arr[ixj];
                            dest_arr[ixj]  = dest_tmp;
                        end
                    end
                end
            end
        end
    end

    // Pack outputs; after sorting, dest_arr should be 0..N-1 in order
    generate
        genvar o;
        for (o = 0; o < N; o = o + 1) begin : gen_pack
            assign out_bus[o*W + W-1 : o*W] = data_arr[o];
        end
    endgenerate
endmodule

