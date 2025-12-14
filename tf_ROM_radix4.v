`include "parameter.v"

// ------------------------------------------------------------
// Auto-generated radix-4 twiddle ROM (Kyber N=256)
// Each ROM word = 4 * DATA_WIDTH = 48 bits
// Order (MSB -> LSB): w2 | w1 | w3 | omega1
// ------------------------------------------------------------
module tf_ROM_radix4(
    input                           clk,
    input       [`ADDR_ROM_WIDTH-1:0] A,
    input                           REN,
    output reg  [(4*`DATA_WIDTH)-1:0] Q
);

    // Radix-4 requires exactly 4 twiddles per cycle
    initial begin
        if (`P != 4) begin
            $display("ERROR: radix-4 tf_ROM expects P=4, but P=%0d", `P);
            $fatal;
        end
    end

    localparam integer DEPTH = 85;

    reg [(4*`DATA_WIDTH)-1:0] rom [0:DEPTH-1];
    initial $readmemh("tf_rom_radix4.mem", rom);

    always @(posedge clk) begin
        if (REN)
            Q <= rom[A];
        else
            Q <= {(4*`DATA_WIDTH){1'b0}};
    end

endmodule
