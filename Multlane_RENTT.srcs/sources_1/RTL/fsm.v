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
output             [   5:0]         i      ,//max = 64-1
output             [   6:0]         s      ,//max = 128-1
output                              wen    ,
output                              ren    ,
output                              en     ,
output                              finish  
);

reg wen_ff,ren_ff,en_ff;
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

shift#(.SHIFT(`L+3),.data_width(1)) shif_wen(.clk(clk),.rst(rst),.din(wen_ff),.dout(wen));
shift#(.SHIFT(`L+3),.data_width(1)) shif_finish(.clk(clk),.rst(rst),.din(done_ff),.dout(finish));

shift#(.SHIFT(2),.data_width(1)) shif_en(.clk(clk),.rst(rst),.din(en_ff),.dout(en_ff1));
shift#(.SHIFT(2),.data_width(1)) shif_ren(.clk(clk),.rst(rst),.din(ren_ff),.dout(ren));
// DFF #(.data_width(1)) dff_en(.clk(clk),.rst(rst),.d(en_ff),.q(en_ff1));
// DFF #(.data_width(1)) dff_ren(.clk(clk),.rst(rst),.d(ren_ff),.q(ren));
// DFF #(.data_width(1)) dff_sel(.clk(clk),.rst(rst),.d(sel_ff),.q(sel));

always @(posedge clk) 
begin
    if(rst)
        start_ff <= 0;
    else if(done_ff) //反压
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

wire is_ntt, is_intt;
localparam [5:0] BANK_ROW6 = `BANK_ROW;
assign is_ntt  = (opcode == `NTT);
assign is_intt = (opcode == `INTT);

assign stage_start = is_intt ? 6'd6 : 6'd0;
assign stage_end   = is_ntt  ? 6'd6 : (is_intt ? 6'd0 : BANK_ROW6);
assign group_end   = (is_ntt || is_intt) ? `S_END : 1;

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

always@(posedge clk)
begin 
    if(rst) begin
        i_ff <= stage_start;
        s_ff <= 0;          
    end 
    else if(start_ff) begin
        if(s_ff== group_end) begin
            s_ff <= 0;
            if(i_ff == stage_end) 
                i_ff <= stage_start;
            else begin
                if(mode_state == `INTT)
                    i_ff <= i_ff - 1;
                else
                    i_ff <= i_ff + 1;
            end
        end
        else begin 
            if(mode_state == `PWM0 || mode_state == `PWM1) 
                s_ff <= s_ff + 1;
            else
                s_ff <= s_ff + `P; //每次增加`P个
        end
    end
    else begin
        i_ff <= stage_start;
        s_ff <= 0; 
    end
end

endmodule