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


module polytop(
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
wire [`addr_width-1:0] old_address_0,old_address_1,old_address_2,old_address_3;

//memory map port signal --- new_address
wire [`addr_width-1:0] b0,b1,b2,b3;
//memory map port signal --- bank_number
wire[1:0] a0,a1,a2,a3;

//arbiter port signal
wire [1:0] sel_a_0,sel_a_1,
            sel_a_2,sel_a_3;

//write address for bank
wire [`addr_width-1:0] new_address_0_reg,new_address_1_reg,
                      new_address_2_reg,new_address_3_reg;
      
//read address for bank
wire [`addr_width-1:0] new_address_0,new_address_1,
                      new_address_2,new_address_3;

//data from bank
wire [`DATA_WIDTH-1:0] q0,q1,q2,q3;

//data for bfu
wire [`DATA_WIDTH-1:0] u0,v0,u1,v1;
//data from bfu
wire [`DATA_WIDTH-1:0] bf_0_upper,bf_0_lower,
                      bf_1_upper,bf_1_lower;

//data for bank
wire [`DATA_WIDTH-1:0] d0,d1,d2,d3;

//twiddle factor from ROM
wire [`DATA_WIDTH*`P-1:0] w;
wire [`DATA_WIDTH-1:0] wa1,wa2;

//tf address for ROM
wire [`addr_rom_width-1:0] tf_address;


(*DONT_TOUCH = "true"*)
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

(*DONT_TOUCH = "true"*)
addr_gen addr_gen_inst0(
    .i                                 (i                         ),//I
    .s                                 (s                         ),//I
    .b                                 (0                         ),//I
    .opcode                            (opcode                    ),//I
    .ie                                (old_address_0             ),//O
    .io                                (old_address_1             ) //O
);

wire [4:0] b;
assign b = (opcode == `PWM1 || opcode == `PWM0) ? 5'b00000 : 5'b00001;

(*DONT_TOUCH = "true"*)
addr_gen addr_gen_inst1(
    .i                                 (i                         ),//I
    .s                                 (s                         ),//I
    .b                                 (b                         ),//I
    .opcode                            (opcode                    ),//I
    .ie                                (old_address_2             ),//O
    .io                                (old_address_3             ) //O
);


(*DONT_TOUCH = "true"*)
memory_map memory_map_inst0(
    .clk                               (clk                       ),//I
    .rst                               (rst                       ),//I
    .mode                              (mode                      ),//I
    .offset                            (offset                    ),//I
    .old_ie                            (old_address_0             ),//O
    .old_io                            (old_address_1             ),//O
    .BA_ie                             (b0                        ),//O
    .BA_io                             (b1                        ),//O
    .BI_ie                             (a0                        ),//O
    .BI_io                             (a1                        ) //O
);

wire RPFU1_mode;
wire RPFU1_offset;
assign RPFU1_mode   = (opcode == `PWM0 || opcode == `PWM1) ? ~mode : mode;
assign RPFU1_offset = (opcode == `PWM0 || opcode == `PWM1) ? ~offset :offset;      

(*DONT_TOUCH = "true"*)
memory_map memory_map_inst1(
    .clk                               (clk                       ),//I
    .rst                               (rst                       ),//I
    .mode                              (RPFU1_mode                ),//I
    .offset                            (RPFU1_offset              ),//I
    .old_ie                            (old_address_2             ),//O
    .old_io                            (old_address_3             ),//O
    .BA_ie                             (b2                        ),//O
    .BA_io                             (b3                        ),//O
    .BI_ie                             (a2                        ),//O
    .BI_io                             (a3                        ) //O
);
    
(*DONT_TOUCH = "true"*)
arbiter m3(
    .a0                                (a0                        ),//I
    .a1                                (a1                        ),//I
    .a2                                (a2                        ),//I
    .a3                                (a3                        ),//I
    .sel_a_0                           (sel_a_0                   ),//O
    .sel_a_1                           (sel_a_1                   ),//O
    .sel_a_2                           (sel_a_2                   ),//O
    .sel_a_3                           (sel_a_3                   ) //O
);
                      
(*DONT_TOUCH = "true"*)
network_bank_in mux1(
    .b0                                (b0                        ),//I
    .b1                                (b1                        ),//I
    .b2                                (b2                        ),//I 
    .b3                                (b3                        ),//I
    .sel_a_0                           (sel_a_0                   ),//I
    .sel_a_1                           (sel_a_1                   ),//I
    .sel_a_2                           (sel_a_2                   ),//I
    .sel_a_3                           (sel_a_3                   ),//I
    .new_address_0                     (new_address_0             ),//O
    .new_address_1                     (new_address_1             ),//O 
    .new_address_2                     (new_address_2             ),//O
    .new_address_3                     (new_address_3             ) //O 
);

//L+2
shift#(.SHIFT(7),.data_width(`addr_width)) dff_n0(.clk(clk),.rst(rst),.din(new_address_0),.dout(new_address_0_reg));//      
shift#(.SHIFT(7),.data_width(`addr_width)) dff_n1(.clk(clk),.rst(rst),.din(new_address_1),.dout(new_address_1_reg));//
shift#(.SHIFT(7),.data_width(`addr_width)) dff_n2(.clk(clk),.rst(rst),.din(new_address_2),.dout(new_address_2_reg));//      
shift#(.SHIFT(7),.data_width(`addr_width)) dff_n3(.clk(clk),.rst(rst),.din(new_address_3),.dout(new_address_3_reg));//  
              
(*DONT_TOUCH = "true"*)
bank bank_0(
    .clk                               (clk                       ),//I
    .waddr                             (new_address_0_reg         ),//I
    .raddr                             (new_address_0             ),//I
    .wdata                             (d0                        ),//I
    .WEN                               (wen                       ),//I
    .REN                               (ren                       ),//I
    .EN                                (en                        ),//I
    .rdata                             (q0                        ) //O
);
                
(*DONT_TOUCH = "true"*)
bank bank_1(
    .clk                               (clk                       ),//I
    .waddr                             (new_address_1_reg         ),//I
    .raddr                             (new_address_1             ),//I
    .wdata                             (d1                        ),//I
    .WEN                               (wen                       ),//I
    .REN                               (ren                       ),//I
    .EN                                (en                        ),//I
    .rdata                             (q1                        ) //O
);

(*DONT_TOUCH = "true"*)
bank bank_2(
    .clk                               (clk                       ),//I
    .waddr                             (new_address_2_reg         ),//I
    .raddr                             (new_address_2             ),//I
    .wdata                             (d2                        ),//I
    .WEN                               (wen                       ),//I
    .REN                               (ren                       ),//I
    .EN                                (en                        ),//I
    .rdata                             (q2                        ) //O
);

(*DONT_TOUCH = "true"*)
bank bank_3(
    .clk                               (clk                       ),//I
    .waddr                             (new_address_3_reg         ),//I
    .raddr                             (new_address_3             ),//I
    .wdata                             (d3                        ),//I
    .WEN                               (wen                       ),//I
    .REN                               (ren                       ),//I
    .EN                                (en                        ),//I
    .rdata                             (q3                        ) //O
);
                
(*DONT_TOUCH = "true"*)
network_RBFU_in mux2(
    .clk                               (clk                       ),//I
    .rst                               (rst                       ),//I
    .sel_a_0                           (sel_a_0                   ),//I
    .sel_a_1                           (sel_a_1                   ),//I
    .sel_a_2                           (sel_a_2                   ),//I
    .sel_a_3                           (sel_a_3                   ),//I
    .q0                                (q0                        ),//I
    .q1                                (q1                        ),//I
    .q2                                (q2                        ),//I
    .q3                                (q3                        ),//I
    .u0                                (u0                        ),//O
    .v0                                (v0                        ),//O
    .u1                                (u1                        ),//O
    .v1                                (v1                        ) //O
);
wire [`DATA_WIDTH-1:0] u0_ff;
wire [`DATA_WIDTH-1:0] v0_ff;
wire [`DATA_WIDTH-1:0] u1_ff;
wire [`DATA_WIDTH-1:0] v1_ff;
DFF #(.data_width(`DATA_WIDTH)) dff_u0(.clk(clk),.rst(rst),.d(u0),.q(u0_ff));
DFF #(.data_width(`DATA_WIDTH)) dff_v0(.clk(clk),.rst(rst),.d(v0),.q(v0_ff));
DFF #(.data_width(`DATA_WIDTH)) dff_u1(.clk(clk),.rst(rst),.d(u1),.q(u1_ff));
DFF #(.data_width(`DATA_WIDTH)) dff_v1(.clk(clk),.rst(rst),.d(v1),.q(v1_ff));

// wire [`DATA_WIDTH-1:0] a_RBFU,b_RBFU;
// assign a_RBFU = (opcode == `PWM1) ? u1_ff : u0_ff;
// assign b_RBFU = (opcode == `PWM1) ? v1_ff : v0_ff;

// (*DONT_TOUCH = "true"*)
// RBFU_O u_RBFU_O0(
//     .clk                               (clk                       ),//I
//     .rst                               (rst                       ),//I
//     .a                                 (a_RBFU                    ),//I
//     .b                                 (b_RBFU                    ),//I
//     .c                                 (0                         ),//I
//     .w                                 (wa1                       ),//I
//     .opcode                            (opcode                    ),//I
//     .Dout1                             (bf_0_lower                ),//O
//     .Dout2                             (bf_0_upper                ) //O
// );

// wire [`DATA_WIDTH-1:0] c;
// assign c = (opcode == `PWM1) ? u0_ff : 0;

// (*DONT_TOUCH = "true"*)
// RBFU_E u_RBFU_E0(
//     .clk                               (clk                       ),//I
//     .rst                               (rst                       ),//I
//     .a                                 (u1_ff                     ),//I
//     .b                                 (v1_ff                     ),//I
//     .c                                 (c                         ),//I
//     .w                                 (wa2                       ),//I
//     .opcode                            (opcode                    ),//I
//     .Dout1                             (bf_1_lower                ),//O
//     .Dout2                             (bf_1_upper                ) //O
// );

wire [`DATA_WIDTH-1:0]  bf_0_lower_temp;
wire [`DATA_WIDTH-1:0]  bf_0_upper_temp;
wire [`DATA_WIDTH-1:0]  bf_1_lower_temp;
wire [`DATA_WIDTH-1:0]  bf_1_upper_temp;
// assign  bf_0_lower_temp = bf_0_lower;
// assign  bf_0_upper_temp = (opcode == `PWM1||opcode == `PWM0)?bf_1_lower:bf_0_upper;
// assign  bf_1_lower_temp = (opcode == `PWM1||opcode == `PWM0)?bf_0_upper:bf_1_lower;
// assign  bf_1_upper_temp = bf_1_upper;

RBFU u_RBFU(
    .clk                               (clk                       ),
    .rst                               (rst                       ),
    .a0                                (u0_ff                     ),
    .b0                                (v0_ff                     ),
    .w0                                (wa1                       ),
    .a1                                (u1_ff                     ),
    .b1                                (v1_ff                     ),
    .w1                                (wa2                       ),
    .opcode                            (opcode                    ),
    .Dout0                             (bf_0_lower_temp           ),
    .Dout1                             (bf_0_upper_temp           ),
    .Dout2                             (bf_1_lower_temp           ),
    .Dout3                             (bf_1_upper_temp           ) 
);

(*DONT_TOUCH = "true"*)          
network_RBFU_out mux3(
    .clk                               (clk                       ),//I
    .rst                               (rst                       ),//I
    .bf_0_lower                        (bf_0_lower_temp           ),//I
    .bf_0_upper                        (bf_0_upper_temp           ),//I
    .bf_1_lower                        (bf_1_lower_temp           ),//I
    .bf_1_upper                        (bf_1_upper_temp           ),//I
    .sel_a_0                           (sel_a_0                   ),//I
    .sel_a_1                           (sel_a_1                   ),//I
    .sel_a_2                           (sel_a_2                   ),//I
    .sel_a_3                           (sel_a_3                   ),//I
    .d0                                (d0                        ),//O
    .d1                                (d1                        ),//O
    .d2                                (d2                        ),//O
    .d3                                (d3                        ) //O
);

(*DONT_TOUCH = "true"*)
tf_address_generator m6(
    .clk                               (clk                       ),//I
    .rst                               (rst                       ),//I
    .opcode                            (opcode                    ),//I
    .i                                 (i                         ),//I
    .s                                 (s                         ),//I
    .tf_address                        (tf_address                ) //O
);

(*DONT_TOUCH = "true"*)
tf_ROM rom0(
    .clk                               (clk                       ),//I
    .A                                 (tf_address                ),//I
    .REN                               (ren                       ),//I
    .Q                                 (w                         ) //O
);

wire [`P*`DATA_WIDTH-1:0] w_ff;
DFF #(.data_width(`P*`DATA_WIDTH)) dff_w(.clk(clk),.rst(rst),.d(w),.q(w_ff));

// assign wa1 = (opcode == `PWM0) ? u1_ff: w_ff[`DATA_WIDTH*2-1:`DATA_WIDTH];
// assign wa2 = (opcode == `PWM1 || opcode == `PWM0) ? v0_ff:w_ff[`DATA_WIDTH-1:0];

assign wa1 = w_ff[`DATA_WIDTH*2-1:`DATA_WIDTH];
assign wa2 = w_ff[`DATA_WIDTH-1:0];
endmodule