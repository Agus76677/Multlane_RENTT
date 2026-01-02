`timescale 1ns / 1ps
`include "parameter.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/18 10:27:11
// Design Name: 
// Module Name: fsm
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


module fsm(  
input                               clk    ,
input                               rst    ,
input              [   1:0]         opcode   ,
input                               start  ,//Pulse signal
output             [   5:0]         i      ,//max = 64-1，i对应stage
output             [   6:0]         s      ,//max = 128-1，s对应group
output                              wen    ,//驱动写使能
output                              ren    ,//驱动读使能
output                              en     ,//总使能，为两者或
output                              finish  
);

reg wen_ff,ren_ff,en_ff;//使能寄存器
wire en_ff1;
reg [1:0] mode_state;
reg [5:0] i_ff;       //这里实际上是wire
reg [6:0] s_ff;       //这里实际上是wire
reg done_ff;
reg start_ff;
wire [5:0] stage_start,stage_end;
wire [6:0] group_end;

assign i = i_ff;
assign s = s_ff;
assign en = en_ff1|wen; 

shift#(.SHIFT(`L+3),.data_width(1)) shif_wen(.clk(clk),.rst(rst),.din(wen_ff),.dout(wen));//wen与finish同步
shift#(.SHIFT(`L+3),.data_width(1)) shif_finish(.clk(clk),.rst(rst),.din(done_ff),.dout(finish));
//这里的`L+3来自于数据从RBFU输出到memory_map再到bank的延时。
//RBFU+Modmul有`L个周期的延时，ren_ff有2个延迟，bank读有1个延时。
//而且finish信号和写信号对齐，因果关系是：wen决定了finish。一个是用来读写bank的，一个是状态机转换的。
//不可进行信号简化。
shift#(.SHIFT(2),.data_width(1)) shif_en(.clk(clk),.rst(rst),.din(en_ff),.dout(en_ff1));
//en_ff1开启bank。
//写期间可能有en_ff1=0，但wen=1使得en=1，保证写通路激活。

shift#(.SHIFT(2),.data_width(1)) shif_ren(.clk(clk),.rst(rst),.din(ren_ff),.dout(ren));
// DFF #(.data_width(1)) dff_en(.clk(clk),.rst(rst),.d(en_ff),.q(en_ff1));
// DFF #(.data_width(1)) dff_ren(.clk(clk),.rst(rst),.d(ren_ff),.q(ren));
// DFF #(.data_width(1)) dff_sel(.clk(clk),.rst(rst),.d(sel_ff),.q(sel));

always @(posedge clk) 
begin
    if(rst)
        start_ff <= 0;
    else if(done_ff) //反压：一次运算完成后清空start_ff
        start_ff <= 0;
    else if(start)
        start_ff <=1;
end

always@(posedge clk )
begin
    if(rst)
        mode_state <= `NTT; //初始状态
    else
        mode_state <= opcode;
end

assign stage_start = opcode == `INTT ? 6 : 0;
assign stage_end   = opcode == `NTT ?  6 :  opcode==`INTT? 0 : `BANK_ROW;
assign group_end   = opcode == `NTT ||opcode == `INTT  ? `S_END :1;

//译码单元
always@(*)
begin
    if(start_ff) 
        case(mode_state)
            `NTT:begin 
                    en_ff = 1; 
                    wen_ff = 1;
                    ren_ff = 1;
                    if((i_ff == stage_end)&&(s_ff == group_end))
                        done_ff = 1; 
                    else
                        done_ff = 0; 
                end
            `PWM0:begin 
                    en_ff  = 1;
                    wen_ff = 1;
                    ren_ff = 1;
                    if((i_ff == stage_end)&&(s_ff == group_end))
                        done_ff = 1; 
                    else 
                        done_ff = 0; 
                end
            `PWM1:begin 
                    en_ff  = 1;
                    wen_ff = 1;
                    ren_ff = 1;
                    if((i_ff == stage_end)&&(s_ff == group_end))
                        done_ff = 1; 
                    else 
                        done_ff = 0; 
                end
            `INTT:begin 
                    en_ff = 1;
                    wen_ff = 1;
                    ren_ff = 1;
                    if((i_ff == stage_end)&&(s_ff == group_end))
                        done_ff = 1; 
                    else 
                        done_ff = 0; 
                end
            default:begin 
                    done_ff=0;
                    en_ff = 0;
                    wen_ff = 0;
                    ren_ff = 0; 
                end
        endcase
    else begin 
        done_ff=0;
        en_ff = 0;
        wen_ff = 0;
        ren_ff = 0; 
    end
end

// (i,s) 循环控制逻辑
always@(posedge clk)
begin 
    if(rst) begin
        // 复位：从当前 opcode 对应的 stage_start、s=0 开始
        i_ff <= stage_start;
        s_ff <= 0;          
    end 
    else if(start_ff) begin
        if(s_ff== group_end) begin
            // 当前 stage 内的所有 group 已处理完
            s_ff <= 0;
            if(i_ff == stage_end) 
                // 所有 stage 结束：i 回到起点，等待 done_ff 清空 start_ff
                i_ff <= stage_start;
            else begin
                // 进入下一个 stage
                if(mode_state == `INTT)
                    i_ff <= i_ff - 1;//INTT下每次减1，直到0
                else
                    i_ff <= i_ff + 1;//NTT下每次加1，直到6
            end
        end
        else begin 
            // 当前 stage 内推进下一个 group
            if(mode_state == `PWM0 || mode_state == `PWM1) 
                s_ff <= s_ff + 1;//每次加1，在PWM模式下
            else
                s_ff <= s_ff + `P; //每次增加`P个，因为一拍处理`P个group，在NTT/INTT模式下
        end
    end
    else begin
        //未启动状态，保持初始值
        i_ff <= stage_start;
        s_ff <= 0; 
    end
end
//进行基4改动的重点是。
// stage_start / stage_end：从 “0 ↔ 6” 变成 “0 ↔ log₄N−1” 或按你的新调度来。

// group_end 与 s_ff 步长：radix-4 每个 stage 蝶形数量变了，s 的上界和步长也要对齐新循环结构。

// done_ff 条件：对应新的 (i,s) 范围。

endmodule