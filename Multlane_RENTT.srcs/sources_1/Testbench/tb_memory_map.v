`define P 4 //Parallel Execution Units 
`define MAP  $clog2(2*`P)

module tb_memory_map();
reg clk;
reg rst;
reg mode;
reg offset;
reg  [7:0]     old_ie;
reg  [7:0]     old_io;
wire [7     :0] BA_ie;
wire [7     :0] BA_io;
wire [`MAP-1:0] BI_ie;
wire [`MAP-1:0] BI_io;

always#2.5 clk=~clk;

initial begin
    clk=0;
    rst=1;
    #5
    rst=0;
    #5
    mode=0;offset=0;old_ie=0 ;old_io=0;
    #5
    mode=0;offset=0;old_ie=52;old_io=52;
    #5
    mode=0;offset=1;old_ie=0;old_io=0;
    #5
    mode=0;offset=1;old_ie=52;old_io=52;
    #5
    mode=1;offset=0;old_ie=0;old_io=0;
    #5
    mode=1;offset=0;old_ie=52;old_io=52;
end

memory_map memory_map_inst(
    .clk                   (clk       ),//I
    .rst                   (rst       ),//I
    .mode                  (mode      ),//I
    .offset                (offset    ),//I
    .old_ie                (old_ie    ),//O
    .old_io                (old_io    ),//O
    .BA_ie                 (BA_ie     ),//O
    .BA_io                 (BA_io     ),//O
    .BI_ie                 (BI_ie     ),//O
    .BI_io                 (BI_io     ) //O
);

endmodule