
`timescale 1ns/1ps
module tb_pe3;

localparam DW = 12;
localparam NTT_LAT  = 8;
localparam INTT_LAT = 8;
localparam NTT_NUM  = 6010;
localparam INTT_NUM = 6010;

reg clk, rst, sel;
reg  [DW-1:0] u, v;
wire [DW-1:0] bf_upper, bf_lower;

PE3 #(.data_width(DW)) dut (
    .clk(clk), .rst(rst), .sel(sel),
    .u(u), .v(v),
    .bf_upper(bf_upper), .bf_lower(bf_lower)
);

reg [59:0] ntt_vec  [0:NTT_NUM-1];
reg [59:0] intt_vec [0:INTT_NUM-1];

integer i;
integer fail_ntt, fail_intt;

reg [DW-1:0] tv_u, tv_v, tv_expU, tv_expL;

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

task apply_vec(input [59:0] p);
begin
    tv_u    = p[59:48];
    tv_v    = p[47:36];
    tv_expU = p[23:12];
    tv_expL = p[11:0];
    u = tv_u;
    v = tv_v;
end
endtask

task wait_cyc(input integer n);
integer k;
begin
    for (k=0;k<n;k=k+1) @(posedge clk);
end
endtask

initial begin
    rst = 1; sel = 0; u = 0; v = 0;
    fail_ntt = 0; fail_intt = 0;

    $readmemh("tb_vectors/pe3_ntt.vec", ntt_vec);
    $readmemh("tb_vectors/pe3_intt.vec", intt_vec);

    wait_cyc(3);
    rst = 0;

    sel = 0;
    wait_cyc(6);
    for (i=0;i<NTT_NUM;i=i+1) begin
        apply_vec(ntt_vec[i]);
        wait_cyc(NTT_LAT);
        if (bf_upper !== tv_expU || bf_lower !== tv_expL) begin
            $display("[FAIL][NTT][%0d] u=%h v=%h got=%h %h exp=%h %h",
                     i, tv_u, tv_v, bf_upper, bf_lower, tv_expU, tv_expL);
            fail_ntt = fail_ntt + 1;
        end
        wait_cyc(1);
    end

    sel = 1;
    wait_cyc(6);
    for (i=0;i<INTT_NUM;i=i+1) begin
        apply_vec(intt_vec[i]);
        wait_cyc(INTT_LAT);
        if (bf_upper !== tv_expU || bf_lower !== tv_expL) begin
            $display("[FAIL][INTT][%0d] u=%h v=%h got=%h %h exp=%h %h",
                     i, tv_u, tv_v, bf_upper, bf_lower, tv_expU, tv_expL);
            fail_intt = fail_intt + 1;
        end
        wait_cyc(1);
    end

    if (fail_ntt==0 && fail_intt==0)
        $display("[PASS] PE3 all tests passed.");
    else
        $display("[FAIL] PE3 NTT=%0d INTT=%0d", fail_ntt, fail_intt);

    $finish;
end

endmodule
