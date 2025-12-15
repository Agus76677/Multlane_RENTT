`include "parameter.v"

(*DONT_TOUCH = "true"*)
module tf_ROM (
input clk,
input [`ADDR_ROM_WIDTH-1:0] A,
input REN,
output reg [4*`DATA_WIDTH-1:0] Q
);

localparam integer DEPTH = `ROM_DEPTH;
reg [4*`DATA_WIDTH-1:0] rom [0:DEPTH-1];
initial begin
    $readmemh("tf_rom_radix4.mem", rom);
end

always@(posedge clk)
begin
    if(REN == 1'b1)
        Q <= rom[A];
    else
        Q <= {4*`DATA_WIDTH{1'b0}};
end
endmodule
