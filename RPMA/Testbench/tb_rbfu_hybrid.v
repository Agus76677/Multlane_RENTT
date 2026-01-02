`timescale 1ns/1ps
`include "../parameter.v"

module tb_rbfu_hybrid();
    reg clk = 0;
    always #5 clk = ~clk;

    reg rst;
    reg [`DATA_WIDTH-1:0] rbfu_a0;
    reg [`DATA_WIDTH-1:0] rbfu_b0;
    reg [`DATA_WIDTH-1:0] rbfu_a1;
    reg [`DATA_WIDTH-1:0] rbfu_b1;
    reg [`DATA_WIDTH-1:0] rbfu_w0;
    reg [`DATA_WIDTH-1:0] rbfu_w1;
    reg [`DATA_WIDTH-1:0] rbfu_w2;
    reg [`DATA_WIDTH-1:0] rbfu_tw_pwm;
    reg                    radix_mode;
    reg [1:0]              opcode;

    wire [`DATA_WIDTH-1:0] Dout0;
    wire [`DATA_WIDTH-1:0] Dout1;
    wire [`DATA_WIDTH-1:0] Dout2;
    wire [`DATA_WIDTH-1:0] Dout3;

    RBFU dut(
        .clk(clk),
        .rst(rst),
        .rbfu_a0(rbfu_a0), .rbfu_b0(rbfu_b0),
        .rbfu_a1(rbfu_a1), .rbfu_b1(rbfu_b1),
        .rbfu_w0(rbfu_w0), .rbfu_w1(rbfu_w1), .rbfu_w2(rbfu_w2),
        .rbfu_tw_pwm(rbfu_tw_pwm),
        .radix_mode(radix_mode),
        .opcode(opcode),
        .Dout0(Dout0), .Dout1(Dout1), .Dout2(Dout2), .Dout3(Dout3)
    );

    integer fh;
    integer ret;
    integer total, pass;
    integer line_num;

    reg [`DATA_WIDTH-1:0] exp0;
    reg [`DATA_WIDTH-1:0] exp1;
    reg [`DATA_WIDTH-1:0] exp2;
    reg [`DATA_WIDTH-1:0] exp3;

    localparam integer LAT = 80;

    initial begin : finish_sim
        rst = 1'b1;
        rbfu_a0 = 0; rbfu_b0 = 0; rbfu_a1 = 0; rbfu_b1 = 0;
        rbfu_w0 = 0; rbfu_w1 = 0; rbfu_w2 = 0; rbfu_tw_pwm = 0;
        radix_mode = 0; opcode = 0;
        total = 0; pass = 0; line_num = 0;
        repeat(5) @(posedge clk);
        rst = 1'b0;

        fh = $fopen("software/rbfu_vectors.txt", "r");
        if (fh == 0) begin
            $display("Cannot open vector file");
            $finish;
        end

        while (!$feof(fh)) begin
            ret = $fscanf(fh, "%h %h %h %h %h %h %h %h %h %h %h %h %h %h\n",
                          radix_mode, opcode,
                          rbfu_a0, rbfu_b0, rbfu_a1, rbfu_b1,
                          rbfu_w0, rbfu_w1, rbfu_w2, rbfu_tw_pwm,
                          exp0, exp1, exp2, exp3);
            if (ret != 14) begin
                $display("Format error at line %0d", line_num);
                disable finish_sim;
            end
            line_num = line_num + 1;
            @(posedge clk);
            repeat(LAT) @(posedge clk);
            total = total + 1;
            if (Dout0 === exp0 && Dout1 === exp1 && Dout2 === exp2 && Dout3 === exp3) begin
                pass = pass + 1;
            end else begin
                $display("Mismatch line %0d: opcode=%b radix=%b exp=%h %h %h %h got=%h %h %h %h",
                         line_num, opcode, radix_mode, exp0, exp1, exp2, exp3, Dout0, Dout1, Dout2, Dout3);
            end
        end

        $display("Total=%0d Pass=%0d", total, pass);
        $finish;
    end
endmodule
