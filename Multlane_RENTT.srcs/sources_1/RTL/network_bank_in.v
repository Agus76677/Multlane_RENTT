`include "parameter.v"

module network_bank_in (
input [`BA_PACK-1:0] BA_bus,
input [`BI_PACK-1:0] sel_BI_bus,
output [`BA_PACK-1:0] new_address_bus
);

// 解包输入总线
wire [`ADDR_WIDTH-1:0] BA [0:2*`P-1];
wire [`MAP-1:0] sel_BI [0:2*`P-1];
reg [`ADDR_WIDTH-1:0] new_address [0:2*`P-1];

// 解包，打包
genvar i;
generate
  for(i = 0; i < 2*`P; i = i + 1) begin : unpack_0
    assign BA[i] = BA_bus[i*`ADDR_WIDTH+`ADDR_WIDTH-1 : i*`ADDR_WIDTH];
    assign sel_BI[i] = sel_BI_bus[i*`MAP+`MAP-1 : i*`MAP];
    assign new_address_bus[i*`ADDR_WIDTH+`ADDR_WIDTH-1 : i*`ADDR_WIDTH] = new_address[i];
  end
endgenerate

genvar k;
generate
  for(k = 0; k < 2*`P; k = k + 1) begin : gen_new_address
    integer j;
    always @(*) begin
      new_address[k] = 'b0;
      // 对于每个可能的选择索引，检查并赋值
      for(j = 0; j < 2*`P; j = j + 1) begin
        if(sel_BI[k] == j) begin
          new_address[k] = BA[j];
        end
      end
    end
  end
endgenerate

endmodule


// module network_bank_in (
// input [`addr_width-1:0] b0,b1,b2,b3,
// input [1:0] sel_a_0,sel_a_1,sel_a_2,sel_a_3,
// output reg [`addr_width-1:0] new_address_0,new_address_1,new_address_2,new_address_3
// );

// always@(*)
// begin
//   case(sel_a_0)
//     2'b00:new_address_0 = b0;
//     2'b01:new_address_0 = b1;
//     2'b10:new_address_0 = b2;
//     2'b11:new_address_0 = b3;
//     default:new_address_0 = b0;
//   endcase
// end

// always@(*)
// begin
//   case(sel_a_1)
//     2'b00:new_address_1 = b0;
//     2'b01:new_address_1 = b1;
//     2'b10:new_address_1 = b2;
//     2'b11:new_address_1 = b3;
//     default:new_address_1 = b0;
//   endcase
// end

// always@(*)
// begin
//   case(sel_a_2)
//     2'b00:new_address_2 = b0;
//     2'b01:new_address_2 = b1;
//     2'b10:new_address_2 = b2;
//     2'b11:new_address_2 = b3;
//     default:new_address_2 = b0;
//   endcase
// end

// always@(*)
// begin
//   case(sel_a_3)
//     2'b00:new_address_3 = b0;
//     2'b01:new_address_3 = b1;
//     2'b10:new_address_3 = b2;
//     2'b11:new_address_3 = b3;
//     default:new_address_3 = b0;
//   endcase
// end

// endmodule