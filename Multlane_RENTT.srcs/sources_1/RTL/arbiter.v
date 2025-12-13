`include "parameter.v"

module arbiter(
    input [`BI_PACK-1:0] BI_bus,
    output [`BI_PACK-1:0] sel_BI_bus
);

wire [`MAP-1:0] req_idx [0:2*`P-1];
wire [`BI_PACK-1:0] req_idx_bus;

genvar i;
generate
    for (i = 0; i < 2*`P; i = i + 1) begin : gen_req_idx
        assign req_idx[i] = i[`MAP-1:0];
        assign req_idx_bus[i*`MAP+`MAP-1 : i*`MAP] = req_idx[i];
    end
endgenerate

// Inverse permutation: sel_BI[bank] = request index j with BI[j] == bank
permute_scatter #(
    .N   (2*`P),
    .W   (`MAP),
    .SELW(`MAP)
) u_sel_inverse (
    .sel_in_bus(BI_bus),
    .in_bus    (req_idx_bus),
    .out_bus   (sel_BI_bus)
);

endmodule




// module arbiter(
// input [1:0] a0,a1,a2,a3,
// output reg [1:0] sel_a_0,sel_a_1,sel_a_2,sel_a_3
// );
//不应该有优先级
// always@(*)
// begin
//   if(a0 == 0) 
//       sel_a_0 = 0;
//   else if(a1 == 0)
//       sel_a_0 = 1;
//   else if(a2 == 0)
//       sel_a_0 = 2;
//   else if(a3 == 0)
//       sel_a_0 = 3;   
//     else
//       sel_a_0 = 0;  
// end

// always@(*)
// begin
//   if(a0 == 1) 
//       sel_a_1 = 0;
//   else if(a1 == 1)
//       sel_a_1 = 1;
//   else if(a2 == 1)
//       sel_a_1 = 2;
//   else if(a3 == 1)
//       sel_a_1 = 3;   
//     else
//       sel_a_1 = 0;  
// end

// always@(*)
// begin
//   if(a0 == 2) 
//       sel_a_2 = 0;
//   else if(a1 == 2)
//       sel_a_2 = 1;
//   else if(a2 == 2)
//       sel_a_2 = 2;
//   else if(a3 == 2)
//       sel_a_2 = 3;   
//     else
//       sel_a_2 = 0;  
// end

// always@(*)
// begin
//   if(a0 == 3) 
//       sel_a_3 = 0;
//   else if(a1 == 3)
//       sel_a_3 = 1;
//   else if(a2 == 3)
//       sel_a_3 = 2;
//   else if(a3 == 3)
//       sel_a_3 = 3;    
//     else
//       sel_a_3 = 0;  
// end
// endmodule