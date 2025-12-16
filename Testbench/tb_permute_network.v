`timescale 1ns/1ps

module tb_permute_network;
  localparam integer N     = 4;
  localparam integer DATAW = 8;
  localparam integer SELW  = 2;

  reg  [N*DATAW-1:0] in_bus_gather;
  reg  [N*SELW-1:0]  sel_out_bus;
  wire [N*DATAW-1:0] out_bus_gather;

  reg  [N*DATAW-1:0] in_bus_scatter;
  reg  [N*SELW-1:0]  sel_in_bus;
  wire [N*DATAW-1:0] out_bus_scatter;

  permute_gather #(
      .N(N),
      .W(DATAW),
      .SELW(SELW)
  ) dut_gather (
      .in_bus(in_bus_gather),
      .sel_out_bus(sel_out_bus),
      .out_bus(out_bus_gather)
  );

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
    // Gather test: lanes = {D4,C3,B2,A1}, select = {2,0,3,1}
    in_bus_gather = {8'hD4, 8'hC3, 8'hB2, 8'hA1};
    sel_out_bus   = {2'd2, 2'd0, 2'd3, 2'd1};
    #1;
    if (out_bus_gather !== {8'hC3, 8'hA1, 8'hD4, 8'hB2}) begin
      $display("[GATHER] Mismatch: got %h", out_bus_gather);
      $fatal;
    end else begin
      $display("[GATHER] PASS: %h", out_bus_gather);
    end

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
