`timescale 1ns / 1ps
`include "../../sources_1/RTL/parameter.v"
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

always#2.5 clk = ~clk;

// 文件路径变量和循环变量
reg [1000:0] file_path;
integer bank_idx;
integer file_handle;
integer i;

initial
begin 
`ifdef OP0
    $readmemb("Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_0.bin",polytop_inst.gen_dff[0].bank_inst.bank);
    $readmemb("Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_1.bin",polytop_inst.gen_dff[1].bank_inst.bank);
    $readmemb("Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_2.bin",polytop_inst.gen_dff[2].bank_inst.bank);
    $readmemb("Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_3.bin",polytop_inst.gen_dff[3].bank_inst.bank);
`elsif OP1
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_0.bin",polytop_inst.gen_dff[0].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_1.bin",polytop_inst.gen_dff[1].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_2.bin",polytop_inst.gen_dff[2].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_3.bin",polytop_inst.gen_dff[3].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_4.bin",polytop_inst.gen_dff[4].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_5.bin",polytop_inst.gen_dff[5].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_6.bin",polytop_inst.gen_dff[6].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_7.bin",polytop_inst.gen_dff[7].bank_inst.bank);
`elsif OP2
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_0.bin",polytop_inst.gen_dff[0].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_1.bin",polytop_inst.gen_dff[1].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_2.bin",polytop_inst.gen_dff[2].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_3.bin",polytop_inst.gen_dff[3].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_4.bin",polytop_inst.gen_dff[4].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_5.bin",polytop_inst.gen_dff[5].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_6.bin",polytop_inst.gen_dff[6].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_7.bin",polytop_inst.gen_dff[7].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_8.bin",polytop_inst.gen_dff[8].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_9.bin",polytop_inst.gen_dff[9].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_10.bin",polytop_inst.gen_dff[10].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_11.bin",polytop_inst.gen_dff[11].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_12.bin",polytop_inst.gen_dff[12].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_13.bin",polytop_inst.gen_dff[13].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_14.bin",polytop_inst.gen_dff[14].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_15.bin",polytop_inst.gen_dff[15].bank_inst.bank);
`elsif OP3
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_0.bin", polytop_inst.gen_dff[ 0].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_1.bin", polytop_inst.gen_dff[ 1].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_2.bin", polytop_inst.gen_dff[ 2].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_3.bin", polytop_inst.gen_dff[ 3].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_4.bin", polytop_inst.gen_dff[ 4].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_5.bin", polytop_inst.gen_dff[ 5].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_6.bin", polytop_inst.gen_dff[ 6].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_7.bin", polytop_inst.gen_dff[ 7].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_8.bin", polytop_inst.gen_dff[ 8].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_9.bin", polytop_inst.gen_dff[ 9].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_10.bin",  polytop_inst.gen_dff[10].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_11.bin",  polytop_inst.gen_dff[11].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_12.bin",  polytop_inst.gen_dff[12].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_13.bin",  polytop_inst.gen_dff[13].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_14.bin",  polytop_inst.gen_dff[14].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_15.bin",  polytop_inst.gen_dff[15].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_16.bin",  polytop_inst.gen_dff[16].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_17.bin",  polytop_inst.gen_dff[17].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_18.bin",  polytop_inst.gen_dff[18].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_19.bin",  polytop_inst.gen_dff[19].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_20.bin",  polytop_inst.gen_dff[20].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_21.bin",  polytop_inst.gen_dff[21].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_22.bin",  polytop_inst.gen_dff[22].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_23.bin",  polytop_inst.gen_dff[23].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_24.bin",  polytop_inst.gen_dff[24].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_25.bin",  polytop_inst.gen_dff[25].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_26.bin",  polytop_inst.gen_dff[26].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_27.bin",  polytop_inst.gen_dff[27].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_28.bin",  polytop_inst.gen_dff[28].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_29.bin",  polytop_inst.gen_dff[29].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_30.bin",  polytop_inst.gen_dff[30].bank_inst.bank);
    $readmemb("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bank_input_31.bin",  polytop_inst.gen_dff[31].bank_inst.bank);
`endif  
end

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
    `ifdef OP0
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `elsif OP1
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `elsif OP2
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_8.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[8].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_9.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[9].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_10.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[10].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_11.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[11].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_12.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[12].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_13.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[13].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_14.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[14].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_15.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[15].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `elif OP3
            file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_8.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[8].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_9.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[9].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_10.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[10].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_11.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[11].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_12.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[12].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_13.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[13].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_14.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[14].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_15.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[15].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_16.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[16].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_17.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[17].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_18.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[18].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_19.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[19].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_20.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[20].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_21.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[21].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_22.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[22].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_23.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[23].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_24.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[24].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_25.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[25].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_26.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[26].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_27.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[27].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_28.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[28].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_29.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[29].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_30.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[30].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_31.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[31].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `endif

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
    `ifdef OP0
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    `elsif OP1
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    `elsif OP2
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_8.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[8].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_9.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[9].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_10.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[10].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_11.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[11].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_12.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[12].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_13.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[13].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_14.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[14].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_15.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[15].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    `elsif OP3
            file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_8.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[8].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_9.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[9].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_10.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[10].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_11.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[11].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_12.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[12].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_13.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[13].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_14.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[14].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_15.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[15].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_16.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[16].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_17.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[17].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_18.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[18].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_19.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[19].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_20.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[20].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_21.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[21].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_22.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[22].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_23.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[23].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_24.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[24].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_25.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[25].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_26.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[26].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_27.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[27].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_28.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[28].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_29.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[29].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankg_30.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[30].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankf_31.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[31].bank_inst.bank[i+`BANK_ROW+1][11:0]);
        end
        $fclose(file_handle);
    `endif

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
    `ifdef OP0
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `elsif OP1
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `elsif OP2
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_8.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[8].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_9.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[9].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_10.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[10].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_11.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[11].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_12.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[12].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_13.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[13].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_14.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[14].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_15.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[15].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `elsif OP3
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_8.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[8].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_9.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[9].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_10.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[10].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_11.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[11].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_12.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[12].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_13.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[13].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_14.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[14].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_15.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[15].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_16.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[16].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_17.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[17].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_18.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[18].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_19.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[19].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_20.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[20].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_21.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[21].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_22.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[22].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_23.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[23].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_24.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[24].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_25.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[25].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_26.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[26].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_27.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[27].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_28.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[28].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_29.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[29].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_30.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[30].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankhat_31.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[31].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `endif

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
    `ifdef OP0
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `elsif OP1
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `elsif OP2
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_8.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[8].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_9.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[9].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_10.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[10].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_11.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[11].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_12.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[12].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_13.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[13].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_14.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[14].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_15.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[15].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `elsif OP3
            file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_0.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[0].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_1.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[1].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_2.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[2].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_3.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[3].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_4.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[4].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_5.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[5].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_6.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[6].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_7.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[7].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_8.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[8].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_9.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[9].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_10.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[10].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_11.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[11].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_12.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[12].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_13.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[13].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_14.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[14].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_15.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[15].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_16.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[16].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_17.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[17].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_18.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[18].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_19.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[19].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_20.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[20].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_21.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[21].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_22.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[22].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_23.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[23].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_24.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[24].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_25.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[25].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_26.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[26].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_27.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[27].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_28.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[28].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_29.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[29].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_30.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[30].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    
        file_handle = $fopen("D:/VivadoProject/Multlane_RENTT/Multlane_RENTT.srcs/sources_1/software/testbench_data/bankh_31.txt", "w");
        for(i = 0; i < `BANK_ROW+1; i = i + 1) begin
            // %d 表示十进制格式
            $fdisplay(file_handle, "%d", polytop_inst.gen_dff[31].bank_inst.bank[i][11:0]);
        end
        $fclose(file_handle);
    `endif
    

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