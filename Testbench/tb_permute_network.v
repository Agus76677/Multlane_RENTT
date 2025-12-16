`timescale 1ns/1ps

module tb_permute_network;
  localparam integer N     = 4;
  localparam integer DATAW = 8;
  localparam integer SELW  = 2;

  reg  [N*DATAW-1:0] in_bus_scatter;
  reg  [N*SELW-1:0]  sel_in_bus;
  wire [N*DATAW-1:0] out_bus_scatter;

  permute_scatter #(
      .N(N),
      .W(DATAW),
      .SELW(SELW)
  ) dut_scatter (
      .in_bus(in_bus_scatter),
      .sel_in_bus(sel_in_bus),
      .out_bus(out_bus_scatter)
  );

  initial begin
    // Scatter test: inputs = {40,30,20,10}, destinations = {3,1,0,2}
    in_bus_scatter = {8'h40, 8'h30, 8'h20, 8'h10};
    sel_in_bus     = {2'd2, 2'd0, 2'd1, 2'd3};
    #1;
    if (out_bus_scatter !== {8'h10, 8'h40, 8'h20, 8'h30}) begin
      $display("[SCATTER] Mismatch: got %h", out_bus_scatter);
      $fatal;
    end else begin
      $display("[SCATTER] PASS: %h", out_bus_scatter);
    end

    $display("Permute network unit test completed successfully.");
    $finish;
  end
endmodule
