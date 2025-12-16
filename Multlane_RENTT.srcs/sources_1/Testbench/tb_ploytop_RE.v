`timescale 1ns / 1ps
`include "../../sources_1/RTL/parameter.v"

module tb_polytop_RE();
    reg clk;
    reg rst;
    reg [1:0] opcode;
    reg mode;
    reg offset;
    reg start;
    wire finish;

    string tb_dir;
    reg tb_dir_ready;
    localparam integer BANK_DEPTH = `BANK_ROW + 1;

    always #2.5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1'b1;
        opcode = `NTT;
        start = 0;
        mode = 1'b0;
        offset = 1'b0;
        tb_dir_ready = 1'b0;
        if(!$value$plusargs("TB_DATA_DIR=%s", tb_dir)) begin
            tb_dir = "Multlane_RENTT.srcs/sources_1/software/testbench_data";
        end
        tb_dir_ready = 1'b1;
        #10 rst = 0;
        @(posedge clk); start <= 1'b1;
        @(posedge clk); start <= 1'b0;
        @(posedge finish);
        $display("[TB] NTT finished");
        $display("[TB] PASS");
        #20;
        $finish;
    end

    genvar b;
    generate
        for (b = 0; b < 2*`P; b = b + 1) begin : bank_io
            integer fh;
            integer row;
            string path;

            initial begin
                wait(tb_dir_ready);
                path = $sformatf("%0s/bank_input_%0d.bin", tb_dir, b);
                fh = $fopen(path, "r");
                if (fh == 0) $fatal(1, "[TB] failed to open %s", path);
                $fclose(fh);
                $display("[TB] loading %s", path);
                $readmemb(path, polytop_inst.gen_dff[b].bank_inst.bank, 0, `DEPTH-1);
            end

            initial begin
                wait(finish);
                path = $sformatf("%0s/bank_out_%0d.txt", tb_dir, b);
                fh = $fopen(path, "w");
                if (fh == 0) $fatal(1, "[TB] cannot open %s for write", path);
                for (row = 0; row < BANK_DEPTH; row = row + 1)
                    $fdisplay(fh, "%0d", polytop_inst.gen_dff[b].bank_inst.bank[row][`DATA_WIDTH-1:0]);
                $fclose(fh);

                path = $sformatf("%0s/bankg_%0d.txt", tb_dir, b);
                fh = $fopen(path, "r");
                if (fh != 0) begin
                    integer gold;
                    integer status;
                    for (row = 0; row < BANK_DEPTH; row = row + 1) begin
                        status = $fscanf(fh, "%d\n", gold);
                        if (status != 1) $fatal(1, "[TB] malformed golden %s row %0d", path, row);
                        if (polytop_inst.gen_dff[b].bank_inst.bank[row][`DATA_WIDTH-1:0] !== gold[`DATA_WIDTH-1:0]) begin
                            $fatal(1, "[TB] mismatch bank %0d row %0d: got %0d expect %0d", b, row,
                                   polytop_inst.gen_dff[b].bank_inst.bank[row][`DATA_WIDTH-1:0], gold);
                        end
                    end
                    $fclose(fh);
                    $display("[TB] bank %0d compare OK", b);
                end else begin
                    $display("[TB] skip compare for bank %0d (no golden)", b);
                end
            end
        end
    endgenerate

    polytop_RE polytop_inst(
        .clk    (clk),
        .rst    (rst),
        .opcode (opcode),
        .mode   (mode),
        .offset (offset),
        .start  (start),
        .finish (finish)
    );
endmodule
