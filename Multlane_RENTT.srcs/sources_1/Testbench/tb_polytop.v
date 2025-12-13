`timescale 1ns / 1ps
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


module tb_polytop();
reg clk;
reg rst;
reg [1:0] opcode;
reg mode;   
reg offset; 
reg start;    // Pulse signal
wire finish;  // Pulse signal, 1 : finish

initial
begin 
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_0.bin",polytop_inst.gen_dff[0].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_1.bin",polytop_inst.gen_dff[1].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_2.bin",polytop_inst.gen_dff[2].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_3.bin",polytop_inst.gen_dff[3].bank_inst.bank);
    // $readmemb("../../software/testbench_data/TF_ROM.bin",      polytop_inst.rom0.bank);
    
end

always#2.5 clk = ~clk;
integer file_handle;
integer i;

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
    
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_0.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle);
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_1.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_2.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle);
 
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_3.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle);
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
    
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_0.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i+64][11:0]);
    end
    $fclose(file_handle);
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_1.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i+64][11:0]);
    end
    $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_2.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i+64][11:0]);
    end
    $fclose(file_handle);
 
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_3.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i+64][11:0]);
    end
    $fclose(file_handle);

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
    
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_0.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle);
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_1.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_2.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle);
 
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_3.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle);

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
    
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_0.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle);
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_1.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_2.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle);
 
    file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_3.txt", "w");
    for(i = 0; i < 64; i = i + 1) begin
        // %d 表示十进制格式
        $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
    end
    $fclose(file_handle); 
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