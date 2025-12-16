`include "parameter.v"

module arbiter(
    input [`BI_PACK-1:0] BI_bus,
    output [`BI_PACK-1:0] sel_BI_bus
);

localparam integer N_LANES = 2*`P;

wire [`MAP-1:0] BI [0:N_LANES-1];
wire [`BI_PACK-1:0] req_index_bus;

genvar i_unpack;
generate
    for(i_unpack = 0; i_unpack < N_LANES; i_unpack = i_unpack + 1) begin : unpack_BI
        assign BI[i_unpack] = BI_bus[i_unpack*`MAP+`MAP-1: i_unpack*`MAP];
        assign req_index_bus[i_unpack*`MAP+`MAP-1 : i_unpack*`MAP] = i_unpack[`MAP-1:0];
    end
endgenerate

permute_scatter #(
    .N(N_LANES),
    .W(`MAP),
    .SELW(`MAP)
) scatter_inv (
    .in_bus(req_index_bus),
    .sel_in_bus(BI_bus),
    .out_bus(sel_BI_bus)
);

endmodule
