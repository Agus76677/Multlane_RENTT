`include "parameter.v"
/*
前文形成了2P个访问请求
接下来的network_bank_in中要按照bank来排队，即当前拍由哪一个访问请求j来读写bank
arbiter就是解决bank和访问请求的分配问题。
不是真正的优先级仲裁，而是一个索引反查的作用。

*/
module arbiter(
    input [`BI_PACK-1:0] BI_bus,
    output [`BI_PACK-1:0] sel_BI_bus
);

wire [`MAP-1:0] BI [0:2*`P-1];
reg  [`MAP-1:0] sel_BI [0:2*`P-1];

// BI_bus 是一条大总线，宽度 = BI_PACK = 2*P*MAP。
// 这里把它拆成数组 BI[j]，j = 0…2P−1：
// 含义：第 j 个访问请求要去的 bank index。

genvar i_unpack;
generate
    for(i_unpack = 0; i_unpack < 2*`P; i_unpack = i_unpack + 1) begin : unpack_BI
        assign BI[i_unpack] = BI_bus[i_unpack*`MAP+`MAP-1: i_unpack*`MAP];
    end
endgenerate

genvar i_sel;
generate
    for(i_sel = 0; i_sel < 2*`P; i_sel = i_sel + 1) begin : gen_arbiter
        integer j;
        always@(*) begin
            sel_BI[i_sel] = {`MAP{1'b0}}; // 默认值
            // 检查每个输入是否匹配当前输出位置
            for(j = 0; j < 2*`P; j = j + 1) begin
                if(BI[j] == i_sel) begin
                    sel_BI[i_sel] = j; // 找到匹配的输入索引
                end
            end
        end
    end
    
    // 将选择结果打包回输出总线
    for(i_sel = 0; i_sel < 2*`P; i_sel = i_sel + 1) begin : pack_sel_BI
        assign sel_BI_bus[i_sel*`MAP+`MAP-1 : i_sel*`MAP] = sel_BI[i_sel];
    end
endgenerate

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


/*
不需要因基4进行改动
*/