`include "parameter.v"

module network_bank_in (
input [`BA_PACK-1:0] BA_bus,
input [`BI_PACK-1:0] BI_bus,
output [`BA_PACK-1:0] new_address_bus
);

localparam integer N_LANES = 2*`P;

permute_scatter #(
    .N(N_LANES),
    .W(`ADDR_WIDTH),
    .SELW(`MAP)
) scatter_addr (
    .in_bus(BA_bus),
    .sel_in_bus(BI_bus),
    .out_bus(new_address_bus)
);

endmodule
