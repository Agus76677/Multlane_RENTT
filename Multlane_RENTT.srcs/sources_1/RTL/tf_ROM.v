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
integer init_status;
string tf_mem_path;
integer ren_seen;

initial begin
    if(!$value$plusargs("TF_MEM=%s", tf_mem_path)) begin
        tf_mem_path = "tf_rom_radix4.mem";
    end
    init_status = $fopen(tf_mem_path, "r");
    if(init_status == 0) begin
        $fatal(1, "[tf_ROM] failed to open twiddle mem file %s", tf_mem_path);
    end else begin
        $fclose(init_status);
    end
    $display("[tf_ROM] loading %s", tf_mem_path);
    $readmemh(tf_mem_path, rom);
    ren_seen = 0;
end

always@(posedge clk)
begin
    if(REN == 1'b1) begin
        Q <= rom[A];
        if(ren_seen < 10) begin
            $display("[tf_ROM] A=%0d Q=%h", A, rom[A]);
            ren_seen <= ren_seen + 1;
        end
    end else
        Q <= {4*`DATA_WIDTH{1'b0}};
end
endmodule
