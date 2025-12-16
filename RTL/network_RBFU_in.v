`include "parameter.v"

module network_RBFU_in(
input clk,
input rst,
input [`BI_PACK-1   :0] sel_BI_bus,
input [`DATA_PACK-1 :0] q_bus,
output [`DATA_PACK-1:0] rbfu_data_bus
);

localparam integer N_LANES = 2*`P;

wire [`MAP-1:0] sel_BI      [0:N_LANES-1];
wire [`MAP-1:0] sel_BI_temp [0:N_LANES-1];
wire [`MAP*N_LANES-1:0] sel_BI_temp_bus;
wire [`DATA_WIDTH-1:0] q   [0:N_LANES-1];

genvar i;
generate
    for(i = 0; i < N_LANES; i = i + 1) begin : unpack_RBFU_in
        assign sel_BI[i] = sel_BI_bus[i*`MAP+`MAP-1 : i*`MAP];
        assign q[i] = q_bus[i*`DATA_WIDTH+`DATA_WIDTH-1 : i*`DATA_WIDTH];
        DFF #(.data_width(`MAP)) dff_inst(.clk(clk),.rst(rst),.d(sel_BI[i]),.q(sel_BI_temp[i]));
        assign sel_BI_temp_bus[i*`MAP+`MAP-1 : i*`MAP] = sel_BI_temp[i];
    end
endgenerate

permute_benes #(
    .N(N_LANES),
    .W(`DATA_WIDTH),
    .SELW(`MAP)
) scatter_to_rbfu (
    .in_bus(q_bus),
    .dest_bus(sel_BI_temp_bus),
    .out_bus(rbfu_data_bus)
);

endmodule
