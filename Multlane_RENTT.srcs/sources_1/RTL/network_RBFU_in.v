`include "parameter.v"

module network_RBFU_in(
input clk,
input rst,
input [`BI_PACK-1   :0] sel_BI_bus,
input [`DATA_PACK-1 :0] q_bus,
output [`DATA_PACK-1:0] rbfu_data_bus
);
   
wire [`MAP-1:0] sel_BI [0:2*`P-1];
wire [`MAP-1:0] sel_BI_temp [0:2*`P-1];
wire [`DATA_WIDTH-1:0] q [0:2*`P-1];
wire [`BI_PACK-1:0] sel_BI_temp_bus;

genvar i;
generate
    for(i = 0; i < 2*`P; i = i + 1) begin : unpack_RBFU_in
        // 解包输入总线
        assign sel_BI[i] = sel_BI_bus[i*`MAP+`MAP-1 : i*`MAP];
        assign q[i] = q_bus[i*`DATA_WIDTH+`DATA_WIDTH-1 : i*`DATA_WIDTH];
        DFF #(.data_width(`MAP)) dff_inst(.clk(clk),.rst(rst),.d(sel_BI[i]),.q(sel_BI_temp[i]));
        assign sel_BI_temp_bus[i*`MAP+`MAP-1 : i*`MAP] = sel_BI_temp[i];
        // 打包输出总线
    end
endgenerate

permute_scatter #(
    .N   (2*`P),
    .W   (`DATA_WIDTH),
    .SELW(`MAP)
) u_rbfu_in_scatter (
    .sel_in_bus(sel_BI_temp_bus),
    .in_bus    (q_bus),
    .out_bus   (rbfu_data_bus)
);

endmodule




// module network_RBFU_in(
// input clk,
// input rst,
// input [1:0] sel_a_0,sel_a_1,sel_a_2,sel_a_3,
// input [`DATA_WIDTH-1:0] q0,q1,q2,q3,
// output reg [`DATA_WIDTH-1:0] u0,v0,u1,v1
// );
   
// wire [1:0] sel_a_0_tmp,sel_a_1_tmp,sel_a_2_tmp,sel_a_3_tmp;

// DFF #(.data_width(2)) dff_sel0(.clk(clk),.rst(rst),.d(sel_a_0),.q(sel_a_0_tmp));
// DFF #(.data_width(2)) dff_sel1(.clk(clk),.rst(rst),.d(sel_a_1),.q(sel_a_1_tmp));
// DFF #(.data_width(2)) dff_sel2(.clk(clk),.rst(rst),.d(sel_a_2),.q(sel_a_2_tmp));
// DFF #(.data_width(2)) dff_sel3(.clk(clk),.rst(rst),.d(sel_a_3),.q(sel_a_3_tmp));

// always@(*)
// begin
//     u0 = 12'b0;
//     v0 = 12'b0;
//     u1 = 12'b0;
//     v1 = 12'b0;
//     case(sel_a_0_tmp)
//         2'b00:u0 = q0; 
//         2'b01:v0 = q0;
//         2'b10:u1 = q0;
//         2'b11:v1 = q0;
//     default:;
//     endcase
    
//     case(sel_a_1_tmp)
//         2'b00:u0 = q1;
//         2'b01:v0 = q1;
//         2'b10:u1 = q1;
//         2'b11:v1 = q1;
//     default:;
//     endcase
    
//     case(sel_a_2_tmp)
//         2'b00:u0 = q2;
//         2'b01:v0 = q2;
//         2'b10:u1 = q2;
//         2'b11:v1 = q2;
//     default:;
//     endcase   
    
//     case(sel_a_3_tmp)
//         2'b00:u0 = q3;
//         2'b01:v0 = q3;
//         2'b10:u1 = q3;
//         2'b11:v1 = q3;
//     default:;
//     endcase 
// end  
// endmodule