`include "parameter.v"

module network_bank_in (
input [`BA_PACK-1:0] BA_bus,
input [`BI_PACK-1:0] sel_BI_bus,
output [`BA_PACK-1:0] new_address_bus
);

permute_gather #(
    .N(2*`P),
    .W(`ADDR_WIDTH),
    .SELW(`MAP)
) bank_addr_select (
    .in_bus(BA_bus),
    .sel_out_bus(sel_BI_bus),
    .out_bus(new_address_bus)
);

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