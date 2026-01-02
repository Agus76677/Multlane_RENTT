`timescale 1ns/1ps

module tb_pe1;

    localparam integer DW = 12;
    localparam integer Q  = 3329;

    // PE1 pipeline:
    //   u,v -> shift_3 -> add/sub -> shift_3 -> outputs
    // total latency = 6 cycles (half is combinational)
    localparam integer NTT_LAT  = 6;
    localparam integer INTT_LAT = 6;

    // Must match the vector file line count.
    // gen_pe1_vectors.py uses: N_ZERO_WARMUP=10, N_RAND=6000 => 6010 lines
    localparam integer NTT_NUM  = 6010;
    localparam integer INTT_NUM = 6010;

    reg clk;
    reg rst;

    reg sel;
    reg [DW-1:0] u, v;
    wire [DW-1:0] bf_upper, bf_lower;

    // DUT
    PE1 #(.data_width(DW)) dut (
        .clk(clk),
        .rst(rst),
        .sel(sel),
        .u(u),
        .v(v),
        .bf_upper(bf_upper),
        .bf_lower(bf_lower)
    );

    // vector memories: keep PE0-compatible 60-bit packing
    // [59:48]=u, [47:36]=v, [35:24]=w0(dummy), [23:12]=expU, [11:0]=expL
    reg [59:0] ntt_vec [0:NTT_NUM-1];
    reg [59:0] intt_vec[0:INTT_NUM-1];

    integer i;
    integer fail_ntt, fail_intt;

    // unpack helpers
    reg [DW-1:0] tv_u, tv_v, tv_expU, tv_expL;
    reg [11:0]   tv_w0; // dummy field, kept for compatibility

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
            tv_w0   = packed[35:24];
            tv_expU = packed[23:12];
            tv_expL = packed[11:0];

            u = tv_u;
            v = tv_v;
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
        input reg [DW-1:0] in_u, in_v;
        inout integer fail_cnt;
        begin
            if ((gotU === expU) && (gotL === expL)) begin
                $display("[PASS] [%16s] input[%03h %03h] outU[%03h] outL[%03h] expU[%03h] expL[%03h]", 
                         tag, in_u, in_v, gotU, gotL, expU, expL);
            end else begin
                fail_cnt = fail_cnt + 1;
                $display("[FAIL] [%16s] input[%03h %03h] outU[%03h] outL[%03h] expU[%03h] expL[%03h]", 
                         tag, in_u, in_v, gotU, gotL, expU, expL);
            end
        end
    endtask

    initial begin
        // init
        rst = 1'b1;
        sel = 1'b0;
        u   = 0;
        v   = 0;
        fail_ntt  = 0;
        fail_intt = 0;

        // load vectors
        $readmemh("tb_vectors/pe1_ntt.vec",  ntt_vec);
        $readmemh("tb_vectors/pe1_intt.vec", intt_vec);

        // reset sequence
        wait_cycles(3);
        rst = 1'b0;

        // ----------------------------
        // NTT tests (sel=0)
        // ----------------------------
        sel = 1'b0;

        // flush pipeline with a few cycles after mode switch
        u = 0; v = 0;
        wait_cycles(6);

        for (i = 0; i < NTT_NUM; i = i + 1) begin
            apply_one_vec(ntt_vec[i]);

            wait_cycles(NTT_LAT);

            check_and_print("NTT", i, bf_upper, bf_lower, tv_expU, tv_expL, tv_u, tv_v, fail_ntt);

            wait_cycles(1);
        end

        // ----------------------------
        // INTT tests (sel=1)
        // ----------------------------
        sel = 1'b1;

        // flush pipeline after mode switch
        u = 0; v = 0;
        wait_cycles(6);

        for (i = 0; i < INTT_NUM; i = i + 1) begin
            apply_one_vec(intt_vec[i]);

            wait_cycles(INTT_LAT);

            check_and_print("INTT", i, bf_upper, bf_lower, tv_expU, tv_expL, tv_u, tv_v, fail_intt);

            wait_cycles(1);
        end

        // summary
        if ((fail_ntt == 0) && (fail_intt == 0)) begin
            $display("[PASS] PE1 NTT/INTT all tests passed.");
        end else begin
            $display("[FAIL] PE1 NTT mismatches=%0d, INTT mismatches=%0d", fail_ntt, fail_intt);
        end

        $finish;
    end

endmodule
