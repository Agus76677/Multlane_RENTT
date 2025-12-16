`include "parameter.v"
module network_RBFU_out(
input clk,
input rst,
input [`DATA_PACK-1:0] bf_out_bus,
input [`BI_PACK-1  :0] BI_bus,
output[`DATA_PACK-1:0] d_in_bus
);

localparam integer N_LANES = 2*`P;

wire [`DATA_WIDTH-1:0] bf_out [0:N_LANES-1];
wire [`MAP-1:0] BI [0:N_LANES-1];
wire [`MAP-1:0] BI_temp [0:N_LANES-1];
wire [`MAP*N_LANES-1:0] BI_temp_bus;

// 解包，打包
genvar i;
generate
  for(i = 0; i < N_LANES; i = i + 1) begin : unpack_0
    assign bf_out[i] = bf_out_bus[i*`DATA_WIDTH + `DATA_WIDTH-1 : i*`DATA_WIDTH];
    assign BI[i] = BI_bus[i*`MAP + `MAP-1 : i*`MAP];
    shift #(.SHIFT(`L+1),.data_width(`MAP)) shif1 (.clk(clk),.rst(rst),.din(BI[i]),.dout(BI_temp[i]));
    assign BI_temp_bus[i*`MAP+`MAP-1 : i*`MAP] = BI_temp[i];
  end
endgenerate

permute_scatter #(
    .N(N_LANES),
    .W(`DATA_WIDTH),
    .SELW(`MAP)
) scatter_from_rbfu (
    .in_bus(bf_out_bus),
    .sel_in_bus(BI_temp_bus),
    .out_bus(d_in_bus)
);

endmodule
