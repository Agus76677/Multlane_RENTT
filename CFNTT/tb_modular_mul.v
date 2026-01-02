`timescale 1ns/1ps

module tb_modular_mul;

    // ============================================================
    // Parameters
    // ============================================================
    localparam DW  = 12;
    localparam LAT = 6;          // ★ 固定流水线延迟（与你当前实现一致）

    // ============================================================
    // Clock / Reset
    // ============================================================
    reg clk;
    reg rst;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 100MHz
    end

    // ============================================================
    // DUT I/O
    // ============================================================
    reg  [DW-1:0] A_in;
    reg  [DW-1:0] B_in;
    wire [DW-1:0] P_out;

    modular_mul #(.data_width(DW)) dut (
        .clk   (clk),
        .rst   (rst),
        .A_in  (A_in),
        .B_in  (B_in),
        .P_out (P_out)
    );

    // ============================================================
    // Golden model
    // ============================================================
    function [DW-1:0] modmul;
        input [DW-1:0] a;
        input [DW-1:0] b;
        reg   [23:0]   p;
        begin
            p = a * b;
            modmul = p % 12'd3329;
        end
    endfunction

    // ============================================================
    // Expected pipeline (scoreboard)
    // ============================================================
    reg [DW-1:0] exp_pipe [0:LAT-1];
    integer i;
    integer cycle;

    // ============================================================
    // Test sequence
    // ============================================================
    initial begin
        // ----------------------------
        // Init
        // ----------------------------
        rst   = 1;
        A_in  = 0;
        B_in  = 0;
        cycle = 0;

        for (i = 0; i < LAT; i = i + 1)
            exp_pipe[i] = 0;

        repeat (4) @(posedge clk);
        rst = 0;

        // ----------------------------
        // Continuous inputs
        // ----------------------------
        @(negedge clk);
        A_in = 12'hb62; B_in = 12'ha35;
 
        @(negedge clk);
        A_in = 12'hb77; B_in = 12'hbfa;

        // 停止输入，但流水线继续吐数
        @(negedge clk);
        A_in = 0; B_in = 0;

        repeat (20) @(posedge clk);
        $display("[PASS] modular_mul pipeline test finished.");
        $finish;
    end

    // ============================================================
    // Input sampling + golden shift (NEGEDGE)
    // ============================================================
    always @(negedge clk) begin
        if (!rst) begin
            exp_pipe[0] <= modmul(A_in, B_in);
            for (i = 1; i < LAT; i = i + 1)
                exp_pipe[i] <= exp_pipe[i-1];
        end
    end

    // ============================================================
    // Output check (POSEDGE)
    // ============================================================
    always @(posedge clk) begin
        if (!rst) begin
            if (cycle >= LAT) begin
                if (P_out !== exp_pipe[LAT-1]) begin
                    $display(
                        "[FAIL] cycle=%0d A=%h B=%h got=%h exp=%h",
                        cycle,
                        A_in,
                        B_in,
                        P_out,
                        exp_pipe[LAT-1]
                    );
                end else begin
                    $display(
                        "t=%0t  A=%h B=%h  P_out=%h",
                        $time,
                        A_in,
                        B_in,
                        P_out
                    );
                end
            end
            cycle = cycle + 1;
        end
    end

endmodule
