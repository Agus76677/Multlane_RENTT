`timescale 1ns/1ps
`include "parameter.v"

module tb_rbfu_hybrid;
    localparam DW = `DATA_WIDTH;
    localparam MAX_VEC = 2048;

    reg clk;
    reg rst;

    reg radix_mode;
    reg [DW-1:0] rbfu_a0, rbfu_b0, rbfu_a1, rbfu_b1;
    reg [DW-1:0] rbfu_w0, rbfu_w1, rbfu_w2, rbfu_tw_pwm;
    reg [1:0] opcode;
    wire [DW-1:0] Dout0, Dout1, Dout2, Dout3;

    RBFU dut(
        .clk(clk),
        .rst(rst),
        .radix_mode(radix_mode),
        .rbfu_a0(rbfu_a0), .rbfu_b0(rbfu_b0), .rbfu_w0(rbfu_w0),
        .rbfu_a1(rbfu_a1), .rbfu_b1(rbfu_b1), .rbfu_w1(rbfu_w1),
        .rbfu_w2(rbfu_w2),
        .rbfu_tw_pwm(rbfu_tw_pwm),
        .opcode(opcode),
        .Dout0(Dout0), .Dout1(Dout1), .Dout2(Dout2), .Dout3(Dout3)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    integer vec_count = 0;
    reg [DW-1:0] in_a0   [0:MAX_VEC-1];
    reg [DW-1:0] in_b0   [0:MAX_VEC-1];
    reg [DW-1:0] in_a1   [0:MAX_VEC-1];
    reg [DW-1:0] in_b1   [0:MAX_VEC-1];
    reg [DW-1:0] in_w0   [0:MAX_VEC-1];
    reg [DW-1:0] in_w1   [0:MAX_VEC-1];
    reg [DW-1:0] in_w2   [0:MAX_VEC-1];
    reg [DW-1:0] in_tw   [0:MAX_VEC-1];
    reg          in_rad  [0:MAX_VEC-1];
    reg [1:0]    in_op   [0:MAX_VEC-1];
    reg [DW-1:0] exp0    [0:MAX_VEC-1];
    reg [DW-1:0] exp1    [0:MAX_VEC-1];
    reg [DW-1:0] exp2    [0:MAX_VEC-1];
    reg [DW-1:0] exp3    [0:MAX_VEC-1];

    reg [8*32-1:0] mode_str;
    integer latency;
    integer warmup;
    integer idx;

    task load_vectors;
        integer fd;
        integer r;
        reg [DW-1:0] ta0,tb0,ta1,tb1,tw0,tw1,tw2,tw_pwm;
        reg tr;
        reg [1:0] top;
        reg [DW-1:0] td0,td1,td2,td3;
        begin
            fd = $fopen(".tmp/vec.txt","r");
            if (fd == 0) begin
                $display("[TB] failed to open vector file");
                $finish;
            end
            vec_count = 0;
            while (!$feof(fd)) begin
                r = $fscanf(fd, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
                             ta0,tb0,ta1,tb1,tw0,tw1,tw2,tw_pwm,tr,top,td0,td1,td2,td3);
                if (r == 14 && vec_count < MAX_VEC) begin
                    in_a0[vec_count] = ta0; in_b0[vec_count] = tb0;
                    in_a1[vec_count] = ta1; in_b1[vec_count] = tb1;
                    in_w0[vec_count] = tw0; in_w1[vec_count] = tw1; in_w2[vec_count] = tw2; in_tw[vec_count] = tw_pwm;
                    in_rad[vec_count] = tr; in_op[vec_count] = top;
                    exp0[vec_count] = td0; exp1[vec_count] = td1; exp2[vec_count] = td2; exp3[vec_count] = td3;
                    vec_count = vec_count + 1;
                end
            end
            $fclose(fd);
            if (vec_count == 0) begin
                $display("[TB] no vectors loaded");
                $finish;
            end
        end
    endtask

    function integer mode_latency;
        input [8*32-1:0] s;
        begin
            if (s == "rad2_ntt" || s == "rad2_intt") mode_latency = 3;
            else mode_latency = 3;
        end
    endfunction

    task print_failure;
        input integer vidx;
        begin
            $display("[FAIL] vector %0d exp:%0d %0d %0d %0d got:%0d %0d %0d %0d",
                     vidx, exp0[vidx], exp1[vidx], exp2[vidx], exp3[vidx], Dout0, Dout1, Dout2, Dout3);
            $display("time=%0t", $time);
            $display("input radix=%0d opcode=%0d a0=%0d b0=%0d a1=%0d b1=%0d w0=%0d w1=%0d w2=%0d tw=%0d",
                     in_rad[vidx], in_op[vidx], in_a0[vidx], in_b0[vidx], in_a1[vidx], in_b1[vidx], in_w0[vidx], in_w1[vidx], in_w2[vidx], in_tw[vidx]);
            $display("mul0 a=%0d b=%0d p=%0d", dut.mul0_a, dut.mul0_b, dut.mul0_p);
            $display("mul1 a=%0d b=%0d p=%0d", dut.mul1_a, dut.mul1_b, dut.mul1_p);
            $display("mul2 a=%0d b=%0d p=%0d", dut.mul2_a, dut.mul2_b, dut.mul2_p);
            $display("mul3 a=%0d b=%0d p=%0d", dut.mul3_a, dut.mul3_b, dut.mul3_p);
            $display("r4_t3_reg=%0d intt_u0=%0d intt_u1=%0d intt_u2=%0d pwm_m0_r=%0d pwm_m1_r=%0d",
                     dut.r4_t3_reg, dut.intt_u0_r, dut.intt_u1_r, dut.intt_u2_r, dut.pwm_m0_r, dut.pwm_m1_r);
        end
    endtask

    initial begin
        if (!$value$plusargs("mode=%s", mode_str)) mode_str = "rad2_ntt";
        latency = mode_latency(mode_str);
        warmup = 2;
        load_vectors();

        rst = 1'b1;
        radix_mode = 1'b0; opcode = 2'b0;
        rbfu_a0 = 0; rbfu_b0 = 0; rbfu_a1 = 0; rbfu_b1 = 0; rbfu_w0 = 0; rbfu_w1 = 0; rbfu_w2 = 0; rbfu_tw_pwm = 0;
        repeat(4) @(posedge clk);
        rst = 1'b0;

        for (idx = 0; idx < vec_count; idx = idx + 1) begin
            rbfu_a0 = in_a0[idx]; rbfu_b0 = in_b0[idx]; rbfu_a1 = in_a1[idx]; rbfu_b1 = in_b1[idx];
            rbfu_w0 = in_w0[idx]; rbfu_w1 = in_w1[idx]; rbfu_w2 = in_w2[idx]; rbfu_tw_pwm = in_tw[idx];
            radix_mode = in_rad[idx]; opcode = in_op[idx];
            repeat(latency + warmup) @(posedge clk);
            if (Dout0 !== exp0[idx] || Dout1 !== exp1[idx] || Dout2 !== exp2[idx] || Dout3 !== exp3[idx]) begin
                print_failure(idx);
                $finish;
            end
        end

        $display("[PASS] mode=%s vectors=%0d latency=%0d", mode_str, vec_count, latency);
        $finish;
    end
endmodule
