`include "parameter.v"

// Benes-style permutation using a bitonic sorting network on destination tags.
// Sorts (dest,data) pairs by dest, then outputs data in destination order.
module permute_benes #(
    parameter integer N    = 2*`P,
    parameter integer W    = 1,
    parameter integer SELW = `MAP
) (
    input  [N*W-1:0]    in_bus,
    input  [N*SELW-1:0] dest_bus,
    output [N*W-1:0]    out_bus
);

    // Unpack inputs
    wire [W-1:0]    data_arr [0:N-1];
    wire [SELW-1:0] dest_arr [0:N-1];
    genvar idx_unpack;
    generate
        for (idx_unpack = 0; idx_unpack < N; idx_unpack = idx_unpack + 1) begin : gen_unpack
            assign data_arr[idx_unpack] = in_bus[idx_unpack*W + W-1 : idx_unpack*W];
            assign dest_arr[idx_unpack] = dest_bus[idx_unpack*SELW + SELW-1 : idx_unpack*SELW];
        end
    endgenerate

    // Bitonic sort on destination tags; data follows swaps.
    reg  [W-1:0]    sort_data [0:N-1];
    reg  [SELW-1:0] sort_dest [0:N-1];
    integer i, j, k;
    integer l;
    reg [W-1:0]    tmp_data;
    reg [SELW-1:0] tmp_dest;
    always @(*) begin
        // initialize
        for (i = 0; i < N; i = i + 1) begin
            sort_data[i] = data_arr[i];
            sort_dest[i] = dest_arr[i];
        end

        // bitonic network
        for (k = 2; k <= N; k = k << 1) begin
            for (j = k >> 1; j > 0; j = j >> 1) begin
                for (i = 0; i < N; i = i + 1) begin
                    l = i ^ j;
                    if (l > i) begin
                        if ((i & k) == 0) begin
                            if (sort_dest[i] > sort_dest[l]) begin
                                // swap to enforce ascending order
                                tmp_data      = sort_data[i];
                                tmp_dest      = sort_dest[i];
                                sort_data[i]  = sort_data[l];
                                sort_dest[i]  = sort_dest[l];
                                sort_data[l]  = tmp_data;
                                sort_dest[l]  = tmp_dest;
                            end
                        end else begin
                            if (sort_dest[i] < sort_dest[l]) begin
                                tmp_data      = sort_data[i];
                                tmp_dest      = sort_dest[i];
                                sort_data[i]  = sort_data[l];
                                sort_dest[i]  = sort_dest[l];
                                sort_data[l]  = tmp_data;
                                sort_dest[l]  = tmp_dest;
                            end
                        end
                    end
                end
            end
        end
    end

    // Pack outputs in sorted order (dest assumed unique permutation)
    genvar po;
    generate
        for (po = 0; po < N; po = po + 1) begin : pack_out
            assign out_bus[po*W + W-1 : po*W] = sort_data[po];
        end
    endgenerate
endmodule
