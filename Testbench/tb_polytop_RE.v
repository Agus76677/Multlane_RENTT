`timescale 1ns / 1ps
`include "../RTL/parameter.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/19 21:08:04
// Design Name: 
// Module Name: tb_polytop
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_polytop_RE();
reg clk;
reg rst;
reg [1:0] opcode;
reg mode;
reg offset;
reg start;    // Pulse signal
wire finish;  // Pulse signal, 1 : finish

reg [8*1024-1:0] tb_dir;

always#2.5 clk = ~clk;
// TB config + file-IO helpers (avoid OP0/OP1/OP2/OP3 copy-paste)
// ============================================================================
localparam integer TB_BANK_NUM = 2*`P;

initial begin
  tb_dir = "software/testbench_data";
  if ($value$plusargs("TB_DATA_DIR=%s", tb_dir))
    $display("[TB] TB_DATA_DIR overridden to %0s", tb_dir);
  else
    $display("[TB] TB_DATA_DIR using default %0s", tb_dir);

  $display("[TB] effective TB_DATA_DIR=%0s", tb_dir);
end

localparam integer DUMP_F   = 0;
localparam integer DUMP_G   = 1;
localparam integer DUMP_HAT = 2;
localparam integer DUMP_H   = 3;

integer dump_sel;
integer dump_row_base;
event   dump_event;

// [TB] input loading is handled by GEN_TB_BANK below (no OP0/1/2/3 copy-paste)


genvar gi;
generate
  for (gi = 0; gi < TB_BANK_NUM; gi = gi + 1) begin : GEN_TB_BANK
    // Load input data into each bank
    initial begin : LOAD_INPUT
      reg [2000:0] fp_in;
      #1; // ensure tb_dir initialized
      $sformat(fp_in, "%0s/bank_input_%0d.bin", tb_dir, gi);
      $display("[TB] loading bank %0d from %0s", gi, fp_in);
      $readmemb(fp_in, polytop_inst.gen_dff[gi].bank_inst.bank);
    end

    // Dump bank content to file when dump_event triggers
    always @(dump_event) begin : DUMP_BANK
      reg [2000:0] fp_out;
      integer fh;
      integer jj;
      case (dump_sel)
        DUMP_F  : $sformat(fp_out, "%0s/bankf_%0d.txt",   tb_dir, gi);
        DUMP_G  : $sformat(fp_out, "%0s/bankg_%0d.txt",   tb_dir, gi);
        DUMP_HAT: $sformat(fp_out, "%0s/bankhat_%0d.txt", tb_dir, gi);
        DUMP_H  : $sformat(fp_out, "%0s/bankh_%0d.txt",   tb_dir, gi);
        default : $sformat(fp_out, "%0s/bankx_%0d.txt",   tb_dir, gi);
      endcase

      fh = $fopen(fp_out, "w");
      for (jj = 0; jj < `BANK_ROW + 1; jj = jj + 1) begin
        $fdisplay(fh, "%d", polytop_inst.gen_dff[gi].bank_inst.bank[jj + dump_row_base][11:0]);
      end
      $fclose(fh);
    end
  end
endgenerate



// ============================================================================
initial begin
    
    clk = 0;
    rst = 1'b1;                   // Assert reset
    //--------------------------f_NTT--------------------------
    opcode = 2'b00;               // NTT opcode
    start = 0; 
    mode=0;
    offset=0;                     // Start the operation
    #10 rst = 0;                  // Release reset
    @(posedge clk)
    begin
        start <= 1;
    end                           // Start the operation
    @(posedge clk)
    begin
        start <= 0;
    end                           // Deassert start
    @(posedge finish);            // Wait for the operation to complete
    $display("NTT finished");
    #15
    // [TB] dump banks (auto-loop)
    dump_sel      = DUMP_F;
    dump_row_base = 0;
    -> dump_event;

    //--------------------------g_NTT--------------------------
    #300
    rst = 1'b1;                   // Assert reset
    start = 0;                    // Start the operation
    opcode = 2'b00;               // NTT opcode
    mode=1;
    offset=1; 
    #10 rst = 0;                  // Release reset
    @(posedge clk)
    begin
        start <= 1;
    end                          // Start the operation
    @(posedge clk)
    begin
        start <= 0;
    end                           // Deassert start
    @(posedge finish);            // Wait for the operation to complete
    $display("NTT finished");
    wait(finish);
    // 十进制格式输出
    #15
    // [TB] dump banks (auto-loop)
    dump_sel      = DUMP_G;
    dump_row_base = `BANK_ROW + 1;
    -> dump_event;

    //--------------------------f,g pwm0--------------------------
    #300
    rst = 1'b1;                   // Assert reset
    start = 0;                    // Start the operation
    opcode = 2'b10;               // PWM0 opcode
    mode=0;
    offset=0; 
    #10 rst = 0;                  // Release reset
    @(posedge clk)
    begin
        start <= 1;
    end                          // Start the operation
    @(posedge clk)
    begin
        start <= 0;
    end                           // Deassert start
    @(posedge finish);            // Wait for the operation to complete
    $display("PWM0 finished");


    //--------------------------f,g pwm1--------------------------
    #300
    rst = 1'b1;                   // Assert reset
    start = 0;                    // Start the operation
    opcode = 2'b11;               // PWM1 opcode
    mode=0;
    offset=0; 
    #10 rst = 0;                  // Release reset
    @(posedge clk)
    begin
        start <= 1;
    end                          // Start the operation
    @(posedge clk)
    begin
        start <= 0;
    end                           // Deassert start
    @(posedge finish);            // Wait for the operation to complete
    $display("PWM1 finished");
    
    // 十进制格式输出
    #15
    // [TB] dump banks (auto-loop)
    dump_sel      = DUMP_HAT;
    dump_row_base = 0;
    -> dump_event;

    //--------------------------h INTT--------------------------
    #300
    rst = 1'b1;                   // Assert reset
    start = 0;                    // Start the operation
    opcode = 2'b01;               // PWM1 opcode
    mode=0;
    offset=0; 
    #10 rst = 0;                  // Release reset
    @(posedge clk)
    begin
        start <= 1;
    end                          // Start the operation
    @(posedge clk)
    begin
        start <= 0;
    end                           // Deassert start
    @(posedge finish);            // Wait for the operation to complete
    $display("INTT finished");
    // 十进制格式输出
    #15
    // [TB] dump banks (auto-loop)
    dump_sel      = DUMP_H;
    dump_row_base = 0;
    -> dump_event;

    #20;
    $finish;


end

polytop_RE polytop_inst(
    .clk                               (clk            ),
    .rst                               (rst            ),
    .opcode                            (opcode         ),
    .mode                              (mode           ),
    .offset                            (offset         ),
    .start                             (start          ),// Pulse signal
    .finish                            (finish         ) // Pulse signal, 1 : finish
);
endmodule
