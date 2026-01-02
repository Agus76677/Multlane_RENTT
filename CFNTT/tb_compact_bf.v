`timescale 1ns/1ps

module tb_compact_bf;

    localparam integer DW = 12;
    localparam integer Q  = 3329;

    // Conservative latencies (hold each vector long enough for the pipeline to settle).
    // NTT path includes PE0/PE2 then PE1/PE3 => worst-case ≈ 16 cycles
    // INTT path includes PE3/PE1 then PE0/PE2 (with twiddle mul) => worst-case ≈ 22 cycles
    localparam integer NTT_LAT  = 16;
    localparam integer INTT_LAT = 22;

    // gen_compact_bf_vectors.py generates: 10 warmup + 6000 random = 6010 lines each
    localparam integer NTT_NUM  = 6010;
    localparam integer INTT_NUM = 6010;

    reg clk;
    reg rst;
    reg sel;

    reg  [DW-1:0] u0, v0, u1, v1;
    reg  [DW-1:0] wa1, wa2, wa3;

    wire [DW-1:0] bf_0_upper, bf_0_lower, bf_1_upper, bf_1_lower;

    compact_bf #(.data_width(DW)) dut (
        .clk(clk), .rst(rst),
        .u0(u0), .v0(v0), .u1(u1), .v1(v1),
        .wa1(wa1), .wa2(wa2), .wa3(wa3),
        .sel(sel),
        .bf_0_upper(bf_0_upper), .bf_0_lower(bf_0_lower),
        .bf_1_upper(bf_1_upper), .bf_1_lower(bf_1_lower)
    );

    // 132-bit packed vector (33 hex chars per line)
    // [131:120]=u0 [119:108]=v0 [107:96]=u1 [95:84]=v1 [83:72]=wa1 [71:60]=wa2 [59:48]=wa3
    // [47:36]=exp_bf0U [35:24]=exp_bf0L [23:12]=exp_bf1U [11:0]=exp_bf1L
    reg [131:0] ntt_vec  [0:NTT_NUM-1];
    reg [131:0] intt_vec [0:INTT_NUM-1];

    integer i;
    integer fail_ntt, fail_intt;

    reg [DW-1:0] tv_u0, tv_v0, tv_u1, tv_v1;
    reg [DW-1:0] tv_wa1, tv_wa2, tv_wa3;
    reg [DW-1:0] tv_exp0U, tv_exp0L, tv_exp1U, tv_exp1L;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task automatic wait_cycles;
        input integer n;
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) @(posedge clk);
        end
    endtask

    task automatic apply_one_vec;
        input [131:0] packed;
        begin
            tv_u0   = packed[131:120];
            tv_v0   = packed[119:108];
            tv_u1   = packed[107:96];
            tv_v1   = packed[95:84];
            tv_wa1  = packed[83:72];
            tv_wa2  = packed[71:60];
            tv_wa3  = packed[59:48];
            tv_exp0U= packed[47:36];
            tv_exp0L= packed[35:24];
            tv_exp1U= packed[23:12];
            tv_exp1L= packed[11:0];

            u0  = tv_u0;
            v0  = tv_v0;
            u1  = tv_u1;
            v1  = tv_v1;
            wa1 = tv_wa1;
            wa2 = tv_wa2;
            wa3 = tv_wa3;
        end
    endtask

    task automatic check_and_print;
        input [127:0] tag;  // "NTT" or "INTT"
        input integer idx;
        inout integer fail_cnt;
        begin
            if ((bf_0_upper === tv_exp0U) &&
                (bf_0_lower === tv_exp0L) &&
                (bf_1_upper === tv_exp1U) &&
                (bf_1_lower === tv_exp1L)) begin
                $display("[PASS] [%16s][%0d] in(u0,v0,u1,v1)=(%03h,%03h,%03h,%03h) wa=(%03h,%03h,%03h)  out=(%03h,%03h,%03h,%03h)",
                         tag, idx, tv_u0, tv_v0, tv_u1, tv_v1, tv_wa1, tv_wa2, tv_wa3,
                         bf_0_upper, bf_0_lower, bf_1_upper, bf_1_lower);
            end else begin
                fail_cnt = fail_cnt + 1;
                $display("[FAIL] [%16s][%0d] in(u0,v0,u1,v1)=(%03h,%03h,%03h,%03h) wa=(%03h,%03h,%03h)  got=(%03h,%03h,%03h,%03h) exp=(%03h,%03h,%03h,%03h)",
                         tag, idx, tv_u0, tv_v0, tv_u1, tv_v1, tv_wa1, tv_wa2, tv_wa3,
                         bf_0_upper, bf_0_lower, bf_1_upper, bf_1_lower,
                         tv_exp0U, tv_exp0L, tv_exp1U, tv_exp1L);
            end
        end
    endtask

    initial begin
        rst = 1'b1;
        sel = 1'b0;
        u0  = 0; v0  = 0; u1  = 0; v1  = 0;
        wa1 = 0; wa2 = 0; wa3 = 0;
        fail_ntt  = 0;
        fail_intt = 0;

        $readmemh("tb_vectors/compact_bf_ntt.vec",  ntt_vec);
        $readmemh("tb_vectors/compact_bf_intt.vec", intt_vec);

        wait_cycles(3);
        rst = 1'b0;

        // -----------------------------
        // NTT (sel=0)
        // -----------------------------
        sel = 1'b0;
        wait_cycles(6);

        for (i = 0; i < NTT_NUM; i = i + 1) begin
            apply_one_vec(ntt_vec[i]);
            wait_cycles(NTT_LAT);
            check_and_print("NTT", i, fail_ntt);
            wait_cycles(1);
        end

        // -----------------------------
        // INTT (sel=1)
        // -----------------------------
        sel = 1'b1;
        wait_cycles(6);

        for (i = 0; i < INTT_NUM; i = i + 1) begin
            apply_one_vec(intt_vec[i]);
            wait_cycles(INTT_LAT);
            check_and_print("INTT", i, fail_intt);
            wait_cycles(1);
        end

        if ((fail_ntt == 0) && (fail_intt == 0)) begin
            $display("[PASS] compact_bf NTT/INTT all tests passed.");
        end else begin
            $display("[FAIL] compact_bf NTT mismatches=%0d, INTT mismatches=%0d", fail_ntt, fail_intt);
        end

        $finish;
    end

endmodule
