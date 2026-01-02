`timescale 1ns / 1ps
`include "parameter.v"  
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/19 21:42:32
// Design Name: by hzw
// Module Name: polytop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module polytop_RE(
    input                               clk     ,
    input                               rst     ,
    input              [   1:0]         opcode  ,
    input                               mode    ,
    input                               offset  ,
    input                               start   ,// Pulse signal
    output                              finish   // Pulse signal, 1 : finish
);

//fsm port signal
wire [5:0] i;
wire [6:0] s;
wire wen,ren,en;

//address_generator port signal
wire [`ADDR_WIDTH-1:0] old_ie0 [0:`P_HALF-1];
wire [`ADDR_WIDTH-1:0] old_io0 [0:`P_HALF-1];
wire [`ADDR_WIDTH-1:0] old_ie1 [0:`P_HALF-1];
wire [`ADDR_WIDTH-1:0] old_io1 [0:`P_HALF-1];

//memory map port signal --- new_address
wire [`ADDR_WIDTH-1:0] BA [`P*2-1:0];
wire [`BA_PACK-1:0] BA_bus;
//memory map port signal --- bank_number
wire [`MAP-1:0] BI [`P*2-1:0];
wire [`BI_PACK-1:0] BI_bus;

//arbiter port signal
wire [`BI_PACK-1:0]  sel_BI_bus;
wire [`MAP-1:0] sel_BI [0:2*`P-1];
                     
//read address for bank
wire [`BA_PACK-1:0] new_address_bus;
wire [`ADDR_WIDTH-1:0] new_address [0:2*`P-1]; 

//write address for bank
wire [`ADDR_WIDTH-1:0] new_address_ff [0:2*`P-1];

//data from bank
wire [`DATA_WIDTH-1:0] q [0:2*`P-1];
wire [`DATA_PACK-1 :0] q_bus;

//data for bfu
wire [`DATA_WIDTH-1:0] rbfu_data [0:2*`P-1];
wire [`DATA_PACK-1 :0] rbfu_data_bus;

//data from bfu
wire [`DATA_WIDTH-1:0] bf_out [0:2*`P-1];
wire [`DATA_PACK-1 :0] bf_out_bus;

//data for bank
wire [`DATA_WIDTH-1:0] d_in [0:2*`P-1];
wire [`DATA_PACK-1 :0] d_in_bus;

//twiddle factor from ROM
wire [`DATA_WIDTH*`P-1:0] w;
wire [`DATA_WIDTH-1:0] wa [0:`P-1];

//tf address for ROM
wire [`ADDR_ROM_WIDTH-1:0] tf_address;

(*DONT_TOUCH = "true"*)
// FSM: 产生每拍的 stage/round 控制参数 i,s，以及 bank 的 EN/REN/WEN 时序。
// i,s -> 决定本拍访问哪些点（逻辑地址）
// ren -> 触发 ROM / bank 读
// wen -> 触发 bank 写回（与 RBFU 延迟对齐后再写）

fsm fsm_inst(
    .clk                               (clk                       ),//I
    .rst                               (rst                       ),//I
    .opcode                            (opcode                    ),//I
    .start                             (start                     ),//I
    .i                                 (i                         ),//O
    .s                                 (s                         ),//O
    .wen                               (wen                       ),//O
    .ren                               (ren                       ),//O
    .en                                (en                        ),//O
    .finish                            (finish                    ) //O
);

genvar i_AG;
generate
    for(i_AG = 0; i_AG < `P_HALF; i_AG = i_AG + 1) begin : gen_addr_gen
        (*DONT_TOUCH = "true"*)
        // addr_gen: 基于 (i,s,b,opcode) 生成 4 个逻辑地址：
        // old_ie0 old_io0 old_ie1 old_io1
        // 每个 i_AG 对应一组“蝶形对/点乘对”的访问模式（双PE/双lane）

`ifdef OP0
    localparam [0:0] B = i_AG;
`else
        localparam [`P_SHIFT-2:0] B = i_AG;
`endif

        addr_gen addr_gen_inst(
            .clk                       (clk                       ),//I
            .rst                       (rst                       ),//I
            .i                         (i                         ),//I
            .s                         (s                         ),//I
            .b                         (B                         ),//I
            .opcode                    (opcode                    ),//I
            .ie0                       (old_ie0[i_AG]             ),//O
            .io0                       (old_io0[i_AG]             ),//O
            .ie1                       (old_ie1[i_AG]             ),//O
            .io1                       (old_io1[i_AG]             ) //O
        );

        (*DONT_TOUCH = "true"*)
        // memory_map: 将逻辑地址 old_* 映射为：
        // BI_* : bank index（落在哪个bank/端口）
        // BA_* : bank internal address（bank 内部地址）
        // mode/offset/opcode 参与映射，用于实现“无冲突映射/模式切换/PWM 特例”

        memory_map memory_map_inst(
            .clk                       (clk                       ),//I
            .rst                       (rst                       ),//I
            .opcode                    (opcode                    ),//I
            .mode                      (mode                      ),//I
            .offset                    (offset                    ),//I
            .old_ie0                   (old_ie0[i_AG]             ),//O
            .old_io0                   (old_io0[i_AG]             ),//O
            .old_ie1                   (old_ie1[i_AG]             ),//O
            .old_io1                   (old_io1[i_AG]             ),//O
            .BI_ie0                    (BI[4*i_AG+0]              ),//O
            .BI_io0                    (BI[4*i_AG+1]              ),//O
            .BI_ie1                    (BI[4*i_AG+2]              ),//O
            .BI_io1                    (BI[4*i_AG+3]              ),//O
            .BA_ie0                    (BA[4*i_AG+0]              ),//O
            .BA_io0                    (BA[4*i_AG+1]              ),//O
            .BA_ie1                    (BA[4*i_AG+2]              ),//O
            .BA_io1                    (BA[4*i_AG+3]              ) //O
        );
    end
endgenerate

//将sel_BI_bus解包成sel_BI
genvar bi_pack;
generate
    for(bi_pack = 0; bi_pack < 2*`P; bi_pack = bi_pack + 1) begin : gen_BI_pack
        assign BI_bus[bi_pack*`MAP + `MAP-1 : bi_pack*`MAP] = BI[bi_pack];
        assign BA_bus[bi_pack*`ADDR_WIDTH + `ADDR_WIDTH-1 : bi_pack*`ADDR_WIDTH] = BA[bi_pack];
        assign sel_BI[bi_pack] = sel_BI_bus[bi_pack*`MAP + `MAP-1 : bi_pack*`MAP];
        assign new_address[bi_pack] = new_address_bus[bi_pack*`ADDR_WIDTH + `ADDR_WIDTH-1 : bi_pack*`ADDR_WIDTH];
    end
endgenerate
// arbiter: 对每个“目标 bank i_sel”，找出“哪个输入 j 想访问它”，输出 sel_BI[i_sel]=j
// 注意：此实现没有优先级机制，若多个输入请求同一 bank，将发生覆盖（理论上应由映射/冲突检测避免）
//
// network_bank_in: 根据 sel_BI，把 BA[j] 送到对应 bank k 的 raddr，实现：
// raddr[k] = BA[ sel_BI[k] ]

(*DONT_TOUCH = "true"*)
arbiter m3(
    .BI_bus                            (BI_bus                    ),//I
    .sel_BI_bus                        (sel_BI_bus                ) //0
);
                      
(*DONT_TOUCH = "true"*)
network_bank_in mux1(
    .BA_bus                            (BA_bus                     ),//I
    .sel_BI_bus                        (sel_BI_bus                 ),//I
    .new_address_bus                   (new_address_bus            ) //O
);

//L+1
genvar i_dff;
generate
    for(i_dff = 0; i_dff < 2*`P; i_dff = i_dff + 1) begin : gen_dff

        //地址/写回对齐：new_address_ff = shift(L+1, new_address)
        //new_address 是当前拍的读地址，延迟L+1拍后作为写地址 new_address_ff。妙啊
        // 也就是RBFU的主延迟参数数L+1

        (*DONT_TOUCH = "true"*)
        shift#(.SHIFT(`L+1),.data_width(8)) dff_n0(.clk(clk),.rst(rst),.din(new_address[i_dff]),.dout(new_address_ff[i_dff]));
        // bank: 单端口写 + 同步读（posedge 出 rdata）
        // raddr = new_address[k]          // 本拍读
        // waddr = new_address_ff[k]       // 延迟 L+1 拍后的写回地址（对齐 RBFU 输出）
        // WEN/REN/EN 由 FSM 统一控制

        (*DONT_TOUCH = "true"*)
        bank bank_inst(
            .clk                               (clk                       ),//I
            .waddr                             (new_address_ff[i_dff]     ),//I
            .raddr                             (new_address[i_dff]        ),//I
            .wdata                             (d_in[i_dff]               ),//I
            .WEN                               (wen                       ),//I
            .REN                               (ren                       ),//I
            .EN                                (en                        ),//I
            .rdata                             (q[i_dff]                  ) //O
        );

        //打包输出总线
        assign q_bus[i_dff*`DATA_WIDTH + `DATA_WIDTH-1 : i_dff*`DATA_WIDTH] = q[i_dff];
        //解包
        assign  rbfu_data[i_dff] = rbfu_data_bus[i_dff*`DATA_WIDTH + `DATA_WIDTH-1 : i_dff*`DATA_WIDTH];
    end
endgenerate

// network_RBFU_in: 把 bank 输出 q[k] 重新组织成 rbfu_data[*]：
// rbfu_data[logical_port] = q[bank_port_that_provided_it]
// 这样 RBFU 的 a0,b0,a1,b1 才对应正确的“蝶形输入对”

(*DONT_TOUCH = "true"*)
network_RBFU_in dmux(
    .clk                               (clk                       ),//I
    .rst                               (rst                       ),//I
    .sel_BI_bus                        (sel_BI_bus                ),//I
    .q_bus                             (q_bus                     ),//I
    .rbfu_data_bus                     (rbfu_data_bus             ) //O
);

genvar i_rbfu;
generate
    for(i_rbfu = 0; i_rbfu < `P_HALF ; i_rbfu = i_rbfu + 1) begin : gen_rbfu
        //BFU
        // RBFU: 每个实例处理两组 (a0,b0,w0) 和 (a1,b1,w1)，输出 4 路 bf_out
        // w0/w1 来自 twiddle ROM 向量 wa[]（注意 wa 的反向映射）

        (*DONT_TOUCH = "true"*)
        RBFU u_RBFU(
            .clk                               (clk                       ),
            .rst                               (rst                       ),
            .rbfu_a0                           (rbfu_data[4*i_rbfu+0]     ),
            .rbfu_b0                           (rbfu_data[4*i_rbfu+1]     ),
            .rbfu_w0                           (wa[2*i_rbfu+0]            ),
            .rbfu_a1                           (rbfu_data[4*i_rbfu+2]     ),
            .rbfu_b1                           (rbfu_data[4*i_rbfu+3]     ),
            .rbfu_w1                           (wa[2*i_rbfu+1]            ),
            .opcode                            (opcode                    ),
            .Dout0                             (bf_out[4*i_rbfu+0]        ),
            .Dout1                             (bf_out[4*i_rbfu+1]        ),
            .Dout2                             (bf_out[4*i_rbfu+2]        ),
            .Dout3                             (bf_out[4*i_rbfu+3]        ) 
        );
    end
endgenerate     

//打包输出总线
genvar i_bf_out;
generate
    for(i_bf_out = 0; i_bf_out < 2*`P; i_bf_out = i_bf_out + 1) begin : gen_bf
        //打包     
        assign bf_out_bus[i_bf_out*`DATA_WIDTH + `DATA_WIDTH-1 : i_bf_out*`DATA_WIDTH] = bf_out[i_bf_out];
        //解包
        assign d_in[i_bf_out]=d_in_bus[i_bf_out*`DATA_WIDTH + `DATA_WIDTH-1 : i_bf_out*`DATA_WIDTH];
    end
endgenerate 
// network_RBFU_out: 根据延迟后的 sel_BI（SHIFT=L+1），将 bf_out[j] 放回到 d_in[k]
// 使得 d_in[k] 与 waddr[k] 对应正确（写回原先被读出的那一“bank端口位置”）

(*DONT_TOUCH = "true"*)          
network_RBFU_out mux3(
    .clk                               (clk                            ),//I
    .rst                               (rst                            ),//I
    .bf_out_bus                        (bf_out_bus                     ),//I
    .sel_BI_bus                        (sel_BI_bus                     ),//I
    .d_in_bus                          (d_in_bus                       ) //O
);
// tf_address_generator: 根据 (opcode,i,s) 产生 twiddle ROM 地址，并延迟 2 拍输出
// tf_ROM: 同步 ROM，REN=1 时输出一个向量 w（包含 P 个 twiddle）
// wa[]: 将 w 向量按索引反转，保证 wa[0]..wa[P-1] 与 RBFU lane 的顺序匹配

// network_RBFU_out 内部对 sel_BI 做 SHIFT(L+1)，再用它把 bf_out 重新路由到 d_in_bus。
(*DONT_TOUCH = "true"*)
tf_address_generator m6(
    .clk                               (clk                            ),//I
    .rst                               (rst                            ),//I
    .opcode                            (opcode                         ),//I
    .i                                 (i                              ),//I
    .s                                 (s                              ),//I
    .tf_address                        (tf_address                     ) //O
);

(*DONT_TOUCH = "true"*)
tf_ROM rom0(
    .clk                               (clk                           ),//I
    .A                                 (tf_address                    ),//I
    .REN                               (ren                           ),//I
    .Q                                 (w                             ) //O
);


genvar i_wa;
generate    
    for(i_wa = 0; i_wa < `P; i_wa = i_wa + 1) begin : gen_wa
        // 反转映射：将最高位映射到wa[0]，最低位映射到wa[P-1]
        assign wa[i_wa] = w[(`P-1-i_wa)*`DATA_WIDTH + `DATA_WIDTH-1 : (`P-1-i_wa)*`DATA_WIDTH];
    end
endgenerate

endmodule