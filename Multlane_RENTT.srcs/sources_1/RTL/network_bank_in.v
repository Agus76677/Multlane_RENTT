`include "parameter.v"

module network_bank_in (
input [`BA_PACK-1:0] BA_bus,
input [`BI_PACK-1:0] sel_BI_bus,
output [`BA_PACK-1:0] new_address_bus
);

localparam integer N_LANES = 2*`P;

wire [`ADDR_WIDTH-1:0] BA [0:N_LANES-1];
wire [`MAP-1:0] sel_BI [0:N_LANES-1];

genvar i;
generate
  for(i = 0; i < N_LANES; i = i + 1) begin : unpack_0
    assign BA[i] = BA_bus[i*`ADDR_WIDTH+`ADDR_WIDTH-1 : i*`ADDR_WIDTH];
    assign sel_BI[i] = sel_BI_bus[i*`MAP+`MAP-1 : i*`MAP];
  end
endgenerate

permute_gather #(
    .N(N_LANES),
    .W(`ADDR_WIDTH),
    .SELW(`MAP)
) gather_addr (
    .in_bus(BA_bus),
    .sel_out_bus(sel_BI_bus),
    .out_bus(new_address_bus)
);

endmodule
