`timescale 1ns/1ps

module tb_modops;

    localparam integer DW      = 12;
    localparam integer MUL_LAT = 3;
    localparam integer MUL_PIPE = MUL_LAT;

    // ============================================================
    // Vector directory (absolute path for Vivado / XSim)
    // ============================================================
    localparam VEC_DIR_ABS =
        "D:/desktopnew/Vivado_Projects/1.NTT/CFNTT/CFNTT_tb/CFNTT_tb.sim/sim_1/behav/xsim/tb_vectors/";

    localparam PATH_ADD  = {VEC_DIR_ABS, "vec_add.txt"};
    localparam PATH_SUB  = {VEC_DIR_ABS, "vec_sub.txt"};
    localparam PATH_HALF = {VEC_DIR_ABS, "vec_half.txt"};
    localparam PATH_MUL  = {VEC_DIR_ABS, "vec_mul.txt"};

    // ----------------------------
    // Clock / Reset
    // ----------------------------
    reg clk, rst;

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;   // 100 MHz
    end

    // ----------------------------
    // DUT inputs / outputs
    // ----------------------------
    reg  [DW-1:0] add_x, add_y;
    wire [DW-1:0] add_z;

    reg  [DW-1:0] sub_x, sub_y;
    wire [DW-1:0] sub_z;

    reg  [DW-1:0] half_x;
    wire [DW-1:0] half_y;

    reg  [DW-1:0] mul_a, mul_b;
    wire [DW-1:0] mul_p;

    // ----------------------------
    // DUT instances
    // ----------------------------
    modular_add #(.data_width(DW)) u_add (
        .x_add(add_x), .y_add(add_y), .z_add(add_z)
    );

    modular_substraction #(.data_width(DW)) u_sub (
        .x_sub(sub_x), .y_sub(sub_y), .z_sub(sub_z)
    );

    modular_half #(.data_width(DW)) u_half (
        .x_half(half_x), .y_half(half_y)
    );

    modular_mul #(.data_width(DW)) u_mul (
        .clk(clk), .rst(rst),
        .A_in(mul_a), .B_in(mul_b),
        .P_out(mul_p)
    );

    // ----------------------------
    // Vector handling
    // ----------------------------
    integer f_add, f_sub, f_half, f_mul;
    integer r;

    integer vec_add, vec_sub, vec_half, vec_mul;
    integer fail_cnt;

    reg [DW-1:0] exp_add, exp_sub, exp_half, exp_mul;

    // ============ MUL expected handling ============
    reg [DW-1:0] exp_mul_reg;                     // 本拍读入 → 下拍生效
    reg [DW-1:0] mul_exp_pipe [0:MUL_PIPE-1];     // 3 拍 FIFO
    reg [DW-1:0] mul_a_reg, mul_b_reg;
    reg [DW-1:0] mul_a_pipe [0:MUL_PIPE-1];
    reg [DW-1:0] mul_b_pipe [0:MUL_PIPE-1];
    integer i;

    task init_mul_pipe;
        begin
            exp_mul_reg = {DW{1'b0}};
            mul_a_reg   = {DW{1'b0}};
            mul_b_reg   = {DW{1'b0}};
            for (i = 0; i < MUL_PIPE; i = i + 1)
                mul_exp_pipe[i] = {DW{1'b0}};
            for (i = 0; i < MUL_PIPE; i = i + 1) begin
                mul_a_pipe[i] = {DW{1'b0}};
                mul_b_pipe[i] = {DW{1'b0}};
            end
        end
    endtask

    task shift_mul_pipe(input [DW-1:0] v);
        begin
            for (i = MUL_PIPE-1; i > 0; i = i - 1)
                mul_exp_pipe[i] <= mul_exp_pipe[i-1];
            mul_exp_pipe[0] <= v;
        end
    endtask

    task shift_mul_op_pipe(input [DW-1:0] a, input [DW-1:0] b);
        begin
            for (i = MUL_PIPE-1; i > 0; i = i - 1) begin
                mul_a_pipe[i] <= mul_a_pipe[i-1];
                mul_b_pipe[i] <= mul_b_pipe[i-1];
            end
            mul_a_pipe[0] <= a;
            mul_b_pipe[0] <= b;
        end
    endtask

    task check_eq1(
        input [DW-1:0] got,
        input [DW-1:0] exp,
        input [8*16-1:0] tag,
        input integer idx,
        input [DW-1:0] op0
    );
        begin
            if (got !== exp) begin
                fail_cnt = fail_cnt + 1;
                $display("[FAIL][%s][%0d] x=%h got=%h exp=%h", tag, idx, op0, got, exp);
            end
        end
    endtask

    task check_eq2(
        input [DW-1:0] got,
        input [DW-1:0] exp,
        input [8*16-1:0] tag,
        input integer idx,
        input [DW-1:0] op0,
        input [DW-1:0] op1
    );
        begin
            if (got !== exp) begin
                fail_cnt = fail_cnt + 1;
                $display("[FAIL][%s][%0d] x=%h y=%h got=%h exp=%h", tag, idx, op0, op1, got, exp);
            end
        end
    endtask

    localparam [8*16-1:0] TAG_ADD  = "ADD ";
    localparam [8*16-1:0] TAG_SUB  = "SUB ";
    localparam [8*16-1:0] TAG_HALF = "HALF";
    localparam [8*16-1:0] TAG_MUL  = "MUL ";

    // ----------------------------
    // Main
    // ----------------------------
    initial begin
        rst = 1'b1;
        fail_cnt = 0;

        add_x = 0; add_y = 0;
        sub_x = 0; sub_y = 0;
        half_x = 0;
        mul_a = 0; mul_b = 0;

        vec_add = 0;
        vec_sub = 0;
        vec_half = 0;
        vec_mul = 0;

        init_mul_pipe();

        repeat (5) @(posedge clk);
        rst = 1'b0;

        f_add  = $fopen(PATH_ADD,  "r");
        f_sub  = $fopen(PATH_SUB,  "r");
        f_half = $fopen(PATH_HALF, "r");
        f_mul  = $fopen(PATH_MUL,  "r");

        if (f_add == 0 || f_sub == 0 || f_half == 0 || f_mul == 0) begin
            $display("[ERROR] cannot open vector files");
            $finish;
        end

        // ================= MAIN LOOP =================
        while (!$feof(f_add) || !$feof(f_sub) || !$feof(f_half) || !$feof(f_mul)) begin

            // -------- negedge: read vectors only --------
            @(negedge clk);

            if (!$feof(f_add)) begin
                r = $fscanf(f_add, "%h %h %h\n", add_x, add_y, exp_add);
                if (r == 3) vec_add = vec_add + 1;
            end

            if (!$feof(f_sub)) begin
                r = $fscanf(f_sub, "%h %h %h\n", sub_x, sub_y, exp_sub);
                if (r == 3) vec_sub = vec_sub + 1;
            end

            if (!$feof(f_half)) begin
                r = $fscanf(f_half, "%h %h\n", half_x, exp_half);
                if (r == 2) vec_half = vec_half + 1;
            end

            if (!$feof(f_mul)) begin
                r = $fscanf(f_mul, "%h %h %h\n", mul_a, mul_b, exp_mul);
                if (r == 3) vec_mul = vec_mul + 1;
            end

            // combinational ops
            #1;
            if (vec_add  > 0) check_eq2(add_z,  exp_add,  TAG_ADD,  vec_add-1, add_x, add_y);
            if (vec_sub  > 0) check_eq2(sub_z,  exp_sub,  TAG_SUB,  vec_sub-1, sub_x, sub_y);
            if (vec_half > 0) check_eq1(half_y, exp_half, TAG_HALF, vec_half-1, half_x);

            // -------- posedge: advance expected & check --------
            @(posedge clk);
            if (!rst) begin
                // ① 推进 FIFO（上一拍生效的期望）
                shift_mul_pipe(exp_mul_reg);
                shift_mul_op_pipe(mul_a_reg, mul_b_reg);

                // ② 比对
                if (vec_mul >= MUL_PIPE) begin
                    check_eq2(
                        mul_p,
                        mul_exp_pipe[MUL_PIPE-1],
                        TAG_MUL,
                        vec_mul - MUL_PIPE,
                        mul_a_pipe[MUL_PIPE-1],
                        mul_b_pipe[MUL_PIPE-1]
                    );
                end

                // ③ 锁存本拍刚读入的 exp
                exp_mul_reg <= exp_mul;
                mul_a_reg   <= mul_a;
                mul_b_reg   <= mul_b;
            end
        end

        // flush
        repeat (MUL_PIPE) begin
            @(posedge clk);
            shift_mul_pipe({DW{1'b0}});
            shift_mul_op_pipe({DW{1'b0}}, {DW{1'b0}});
        end

        if (fail_cnt == 0)
            $display("[PASS] modular_add / sub / half / mul all tests passed.");
        else
            $display("[FAIL] total mismatches = %0d", fail_cnt);

        $finish;
    end

endmodule
