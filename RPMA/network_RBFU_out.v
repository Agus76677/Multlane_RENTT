`include "parameter.v"  

// 把 2P 个 RBFU 输出 bf_out[j]，按照 sel_BI_bus 给出的“写回目的编号”，重排成 2P 路 d_in[k]，供后级写回到对应的 bank／地址。
// 同时用 shift(L+1) 把控制信号对齐数据流水线延迟。
module network_RBFU_out(
input clk,
input rst,
input [`DATA_PACK-1:0] bf_out_bus, // 来自 RBFU 阵列的并行输出
input [`BI_PACK-1  :0] sel_BI_bus, // 控制：每个输出应写回到哪个“目的编号”。来自aribiter
output[`DATA_PACK-1:0] d_in_bus   // 重排后的结果，送往写回链路
);

// 解包输入总线
wire [`DATA_WIDTH-1:0] bf_out [0:2*`P-1];
wire [`MAP-1:0] sel_BI [0:2*`P-1];
wire [`MAP-1:0] sel_BI_temp [0:2*`P-1];
reg [`DATA_WIDTH-1:0] d_in [0:2*`P-1];

// 解包，打包
genvar i;
generate
  for(i = 0; i < 2*`P; i = i + 1) begin : unpack_0
    // 解包输入总线
    assign bf_out[i] = bf_out_bus[i*`DATA_WIDTH + `DATA_WIDTH-1 : i*`DATA_WIDTH];
    assign sel_BI[i] = sel_BI_bus[i*`MAP + `MAP-1 : i*`MAP];
    shift #(.SHIFT(`L+1),.data_width(`MAP)) shif1 (.clk(clk),.rst(rst),.din(sel_BI[i]),.dout(sel_BI_temp[i]));
   
    // 打包输出总线
    assign d_in_bus[i*`DATA_WIDTH + `DATA_WIDTH-1 : i*`DATA_WIDTH] = d_in[i]; 
  end
endgenerate

genvar k;
generate
  for(k = 0; k < 2*`P; k = k + 1) begin : gen_new_address
    integer j;
    always @(*) begin
      d_in[k] = 'b0;
      // 对于每个可能的选择索引，检查并赋值
      for(j = 0; j < 2*`P; j = j + 1) begin
          if(sel_BI_temp[k] == j) begin
              d_in[k] = bf_out[j];
          end
      end
    end
  end
endgenerate

endmodule




// module network_RBFU_out(
// input clk,
// input rst,
// input [`DATA_WIDTH-1:0] bf_0_lower,bf_0_upper,bf_1_lower,bf_1_upper,
// input [1:0] sel_a_0,sel_a_1,sel_a_2,sel_a_3,
// output reg [`DATA_WIDTH-1:0] d0,d1,d2,d3
// );

// wire [1:0] sel_a_0_out,sel_a_1_out,sel_a_2_out,sel_a_3_out;

// shift #(.SHIFT(`L+3),.data_width(2)) shif1 (.clk(clk),.rst(rst),.din(sel_a_0),.dout(sel_a_0_out));
// shift #(.SHIFT(`L+3),.data_width(2)) shif2 (.clk(clk),.rst(rst),.din(sel_a_1),.dout(sel_a_1_out));
// shift #(.SHIFT(`L+3),.data_width(2)) shif3 (.clk(clk),.rst(rst),.din(sel_a_2),.dout(sel_a_2_out));
// shift #(.SHIFT(`L+3),.data_width(2)) shif4 (.clk(clk),.rst(rst),.din(sel_a_3),.dout(sel_a_3_out));

// always@(*)
// begin
//   case(sel_a_0_out)
//     2'b00:d0 = bf_0_lower;
//     2'b01:d0 = bf_0_upper;
//     2'b10:d0 = bf_1_lower;
//     2'b11:d0 = bf_1_upper;
//   default:;
//   endcase
// end

// always@(*)
// begin
//   case(sel_a_1_out)
//     2'b00:d1 = bf_0_lower;
//     2'b01:d1 = bf_0_upper;
//     2'b10:d1 = bf_1_lower;
//     2'b11:d1 = bf_1_upper;
//   default:;
//   endcase
// end    

// always@(*)
// begin
//   case(sel_a_2_out)
//     2'b00:d2 = bf_0_lower;
//     2'b01:d2 = bf_0_upper;
//     2'b10:d2 = bf_1_lower;
//     2'b11:d2 = bf_1_upper;
//   default:;
//   endcase
// end                       

// always@(*)
// begin
//   case(sel_a_3_out)
//     2'b00:d3 = bf_0_lower;
//     2'b01:d3 = bf_0_upper;
//     2'b10:d3 = bf_1_lower;
//     2'b11:d3 = bf_1_upper;
//   default:;
//   endcase
// end
    
// endmodule

/*
不需要为“基 4”单独改动。
*/