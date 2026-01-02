`timescale 1ns/1ps

module tb_pe0;

    localparam integer DW = 12;
    localparam integer Q  = 3329;

    // Latency derived from your actual RTL:
    // NTT (sel=0): output valid after 8 cycles
    // INTT(sel=1): upper path dominated by w_q7 + mul pipeline => 14 cycles
    localparam integer NTT_LAT  = 8;
    localparam integer INTT_LAT = 14;

    localparam integer NTT_NUM  = 6000;  // must match or exceed lines in pe0_ntt.vec
    localparam integer INTT_NUM = 6000;  // must match or exceed lines in pe0_intt.vec

    reg clk;
    reg rst;

    reg sel;
    reg [DW-1:0] u, v, w;
    wire [DW-1:0] bf_upper, bf_lower;

    // DUT
    PE0 #(.data_width(DW)) dut (
        .clk(clk),
        .rst(rst),
        .sel(sel),
        .u(u),
        .v(v),
        .w(w),
        .bf_upper(bf_upper),
        .bf_lower(bf_lower)
    );

    // vector memories: 60-bit packed
    reg [59:0] ntt_vec [0:NTT_NUM-1];
    reg [59:0] intt_vec[0:INTT_NUM-1];

    integer i;
    integer fail_ntt, fail_intt;

    // unpack helpers
    reg [DW-1:0] tv_u, tv_v, tv_w, tv_expU, tv_expL;

    // clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic apply_one_vec;
        input [59:0] packed;
        begin
            tv_u    = packed[59:48];
            tv_v    = packed[47:36];
            tv_w    = packed[35:24];
            tv_expU = packed[23:12];
            tv_expL = packed[11:0];

            u = tv_u;
            v = tv_v;
            w = tv_w;
        end
    endtask

    task automatic wait_cycles;
        input integer n;
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) begin
                @(posedge clk);
            end
        end
    endtask

    task automatic check_and_print;
        input [127:0] tag;  // "NTT" or "INTT"
        input integer idx;
        input reg [DW-1:0] gotU, gotL;
        input reg [DW-1:0] expU, expL;
        input reg [DW-1:0] in_u, in_v, in_w;
        inout integer fail_cnt;
        begin
            if ((gotU === expU) && (gotL === expL)) begin
                $display("[PASS] [%16s] input[%03h %03h %03h] outU[%03h] outL[%03h] expU[%03h] expL[%03h]",
                         tag, in_u, in_v, in_w, gotU, gotL, expU, expL);
            end else begin
                fail_cnt = fail_cnt + 1;
                $display("[FAIL] [%16s] input[%03h %03h %03h] outU[%03h] outL[%03h] expU[%03h] expL[%03h]",
                         tag, in_u, in_v, in_w, gotU, gotL, expU, expL);
            end
        end
    endtask

    initial begin
        // init
        rst = 1'b1;
        sel = 1'b0;
        u   = 0;
        v   = 0;
        w   = 0;
        fail_ntt  = 0;
        fail_intt = 0;

        // load vectors
        $readmemh("tb_vectors/pe0_ntt.vec",  ntt_vec);
        $readmemh("tb_vectors/pe0_intt.vec", intt_vec);

        // reset sequence
        wait_cycles(3);
        rst = 1'b0;

        // ----------------------------
        // NTT tests (sel=0)
        // ----------------------------
        sel = 1'b0;

        // flush pipeline with a few cycles after mode switch
        u = 0; v = 0; w = 0;
        wait_cycles(5);

        for (i = 0; i < NTT_NUM; i = i + 1) begin
            apply_one_vec(ntt_vec[i]);

            // hold inputs stable long enough, then sample once
            wait_cycles(NTT_LAT);

            check_and_print("NTT", i, bf_upper, bf_lower, tv_expU, tv_expL, tv_u, tv_v, tv_w, fail_ntt);

            // optional gap to avoid accidental overlap if you later change DUT
            wait_cycles(1);
        end

        // ----------------------------
        // INTT tests (sel=1)
        // ----------------------------
        sel = 1'b1;

        // flush pipeline after mode switch
        u = 0; v = 0; w = 0;
        wait_cycles(8);

        for (i = 0; i < INTT_NUM; i = i + 1) begin
            apply_one_vec(intt_vec[i]);

            // IMPORTANT: INTT upper path is slower; wait max latency so both outputs correspond to same vector
            wait_cycles(INTT_LAT);

            check_and_print("INTT", i, bf_upper, bf_lower, tv_expU, tv_expL, tv_u, tv_v, tv_w, fail_intt);

            wait_cycles(1);
        end

        // summary
        if ((fail_ntt == 0) && (fail_intt == 0)) begin
            $display("[PASS] PE0 NTT/INTT all tests passed.");
        end else begin
            $display("[FAIL] PE0 NTT mismatches=%0d, INTT mismatches=%0d", fail_ntt, fail_intt);
        end

        $finish;
    end

endmodule
