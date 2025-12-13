`include "parameter.v"
//-通用map,适用于与N=256,R=2,PE=2，4,8,16等配置(双PE设计)
/*
地址映射是组合逻辑，然后打一拍输出
*/
module memory_map(
input clk,
input rst,
input [1:0] opcode, 
input mode, 
input offset,
input [7:0] old_ie0,
input [7:0] old_io0,
input [7:0] old_ie1,
input [7:0] old_io1,
output  [`MAP-1:0] BI_ie0,
output  [`MAP-1:0] BI_io0,
output  [`MAP-1:0] BI_ie1,
output  [`MAP-1:0] BI_io1,
output  [7     :0] BA_ie0,
output  [7     :0] BA_io0,
output  [7     :0] BA_ie1,
output  [7     :0] BA_io1
);
//PE0
wire [7     :0] BA_ie_temp0;
wire [7     :0] BA_io_temp0;
wire [`MAP-1:0] BI_ie_temp0;
wire [`MAP-1:0] BI_io_temp0;

assign BI_ie_temp0=old_ie0[`MAP-1:0]+((^old_ie0[7:`MAP])<<`P_SHIFT)+({`MAP{mode}}&`P);//mode
assign BI_io_temp0=old_io0[`MAP-1:0]+((^old_io0[7:`MAP])<<`P_SHIFT)+({`MAP{mode}}&`P);//mode
assign BA_ie_temp0={{(`MAP-1){1'b0}},offset,old_ie0[7:`MAP]};//offset
assign BA_io_temp0={{(`MAP-1){1'b0}},offset,old_io0[7:`MAP]};//offset

DFF #(.data_width(`MAP)) BI_ie0_inst(.clk(clk),.rst(rst),.d(BI_ie_temp0),.q(BI_ie0));
DFF #(.data_width(`MAP)) BI_io0_inst(.clk(clk),.rst(rst),.d(BI_io_temp0),.q(BI_io0));
DFF #(.data_width(8   )) BA_ie0_inst(.clk(clk),.rst(rst),.d(BA_ie_temp0),.q(BA_ie0));
DFF #(.data_width(8   )) BA_io0_inst(.clk(clk),.rst(rst),.d(BA_io_temp0),.q(BA_io0));

//PE1
wire [7     :0] BA_ie_temp1;
wire [7     :0] BA_io_temp1;
wire [`MAP-1:0] BI_ie_temp1;
wire [`MAP-1:0] BI_io_temp1;
wire RBFU_mode;
wire RBFU_offset;
assign RBFU_mode   = (opcode == `PWM0 || opcode == `PWM1) ? ~mode : mode;
assign RBFU_offset = (opcode == `PWM0 || opcode == `PWM1) ? ~offset :offset; 
assign BI_ie_temp1=old_ie1[`MAP-1:0]+((^old_ie1[7:`MAP])<<`P_SHIFT)+({`MAP{RBFU_mode}}&`P);//mode
assign BI_io_temp1=old_io1[`MAP-1:0]+((^old_io1[7:`MAP])<<`P_SHIFT)+({`MAP{RBFU_mode}}&`P);//mode
assign BA_ie_temp1={{(`MAP-1){1'b0}},RBFU_offset,old_ie1[7:`MAP]};//offset
assign BA_io_temp1={{(`MAP-1){1'b0}},RBFU_offset,old_io1[7:`MAP]};//offset

DFF #(.data_width(`MAP)) BI_ie1_inst(.clk(clk),.rst(rst),.d(BI_ie_temp1),.q(BI_ie1));
DFF #(.data_width(`MAP)) BI_io1_inst(.clk(clk),.rst(rst),.d(BI_io_temp1),.q(BI_io1));
DFF #(.data_width(8   )) BA_ie1_inst(.clk(clk),.rst(rst),.d(BA_ie_temp1),.q(BA_ie1));
DFF #(.data_width(8   )) BA_io1_inst(.clk(clk),.rst(rst),.d(BA_io_temp1),.q(BA_io1));
endmodule




// module memory_map(
// input clk,
// input rst,
// input mode, 
// input offset,
// input [7:0] old_ie,
// input [7:0] old_io,
// output  [7     :0] BA_ie,
// output  [7     :0] BA_io,
// output  [`MAP-1:0] BI_ie,
// output  [`MAP-1:0] BI_io
// );

// wire [7     :0] BA_ie_temp;
// wire [7     :0] BA_io_temp;
// wire [`MAP-1:0] BI_ie_temp;
// wire [`MAP-1:0] BI_io_temp;

// assign BI_ie_temp=old_ie[`MAP-1:0]+((^old_ie[7:`MAP])<<`P_SHIFT)+({`MAP{mode}}&`P);//mode
// assign BI_io_temp=old_io[`MAP-1:0]+((^old_io[7:`MAP])<<`P_SHIFT)+({`MAP{mode}}&`P);//mode
// assign BA_ie_temp={{(`MAP-1){1'b0}},offset,old_ie[7:`MAP]};//offset
// assign BA_io_temp={{(`MAP-1){1'b0}},offset,old_io[7:`MAP]};//offset

// DFF #(.data_width(`MAP)) BI_ie_inst(.clk(clk),.rst(rst),.d(BI_ie_temp),.q(BI_ie));
// DFF #(.data_width(`MAP)) BI_io_inst(.clk(clk),.rst(rst),.d(BI_io_temp),.q(BI_io));
// DFF #(.data_width(8   )) BA_ie_inst(.clk(clk),.rst(rst),.d(BA_ie_temp),.q(BA_ie));
// DFF #(.data_width(8   )) BA_io_inst(.clk(clk),.rst(rst),.d(BA_io_temp),.q(BA_io));

// endmodule