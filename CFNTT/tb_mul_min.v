`timescale 1ns/1ps

module tb_mul_min;

  localparam integer DW = 12;

  reg  clk, rst;
  reg  [DW-1:0] A_in, B_in;
  wire [DW-1:0] P_out;

  // DUT
  modular_mul #(.data_width(DW)) dut (
    .clk(clk), .rst(rst),
    .A_in(A_in), .B_in(B_in),
    .P_out(P_out)
  );

  // clock: 10ns period
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // stimulus
  initial begin
    rst = 1'b1;
    A_in = 0;
    B_in = 0;

    // reset a few cycles
    repeat (3) @(posedge clk);
    rst = 1'b0;

    // apply one vector and HOLD it (avoid mixing transactions)
    @(negedge clk);
    // A_in = 12'hB62;
    // B_in = 12'hA35;
    // A_in = 12'hb77;
    // B_in = 12'hbfa;
    A_in = 12'hbb4;
    B_in = 12'hbc1;
    // observe for enough cycles (print every posedge)
    repeat (20) begin
      @(posedge clk);
      $display("t=%0t ns  A=%h B=%h  P_out=%h", $time, A_in, B_in, P_out);
    end

    $finish;
  end

endmodule
