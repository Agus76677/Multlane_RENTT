`include "parameter.v"

// 从 2P 个 bank 读出的数据，经一个可配置的交叉开关，送到 2P 个 RBFU 输入口
// 用 sel_BI_bus 决定：每个 bank 的数据该送到哪一个 RBFU lane。

module network_RBFU_in(
    input  clk,
    input  rst,
    input  [`BI_PACK-1   :0] sel_BI_bus,   // 2P 个选择控制，每个宽度 MAP
    input  [`DATA_PACK-1 :0] q_bus,        // 来自 2P 个 bank 的读数据
    output [`DATA_PACK-1 :0] rbfu_data_bus // 送往 2P 个 RBFU 输入。这里是经过了重新排序
);

   
wire [`MAP-1:0] sel_BI [0:2*`P-1];
wire [`MAP-1:0] sel_BI_temp [0:2*`P-1];
wire [`DATA_WIDTH-1:0] q [0:2*`P-1];
reg  [`DATA_WIDTH-1:0] rbfu_data [0:2*`P-1];

genvar i;
generate
    for(i = 0; i < 2*`P; i = i + 1) begin : unpack_RBFU_in
        // 解包输入总线，第 i 个源口的选择控制 & 数据
        assign sel_BI[i] = sel_BI_bus[i*`MAP+`MAP-1 : i*`MAP];
        assign q[i] = q_bus[i*`DATA_WIDTH+`DATA_WIDTH-1 : i*`DATA_WIDTH];
        // sel_BI 打一拍寄存：对齐 bank 的读延迟 / 下游时序
        DFF #(.data_width(`MAP)) dff_inst(.clk(clk),.rst(rst),.d(sel_BI[i]),.q(sel_BI_temp[i]));
        // 打包输出总线
        assign rbfu_data_bus[i*`DATA_WIDTH+`DATA_WIDTH-1 : i*`DATA_WIDTH] = rbfu_data[i];
    end 
endgenerate

// 生成DMUX
genvar k;
generate
  for(k = 0; k < 2*`P; k = k + 1) begin : DMUX
    integer j;
    always @(*) begin
         rbfu_data[k] = 12'b0;
         // 对于每个可能的选择索引，检查并赋值
        for(j = 0; j < 2*`P; j = j + 1) begin
            if(sel_BI_temp[j] == k) begin
                rbfu_data[k] = q[j];
            end
        end
    end
  end
endgenerate

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

/*
不需要为“基 4”单独改动。
*/