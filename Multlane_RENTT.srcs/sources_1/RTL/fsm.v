`timescale 1ns / 1ps
`include "parameter.v"
//////////////////////////////////////////////////////////////////////////////////
// Radix-4 FSM: stage0 stride=64 -> stage3 stride=1
//////////////////////////////////////////////////////////////////////////////////

module fsm(
input                               clk    ,
input                               rst    ,
input              [   1:0]         opcode   ,
input                               start  ,//Pulse signal
output reg         [   2:0]         i      ,//stage index 0-3
output reg         [   6:0]         s      ,//j_block base (step by P_HALF)
output reg         [   6:0]         k      ,//k counter for twiddle address
output                              wen    ,
output                              ren    ,
output                              en     ,
output                              finish
);

localparam [1:0] ST_IDLE = 2'b00, ST_RUN = 2'b01;
reg [1:0] state;
reg wen_ff,ren_ff,en_ff;
wire en_ff1;
reg done_ff;
reg start_ff;

function [6:0] J_value;
    input [2:0] stage;
    begin
        case(stage)
            3'd0: J_value = 7'd64;
            3'd1: J_value = 7'd16;
            3'd2: J_value = 7'd4;
            default: J_value = 7'd1;
        endcase
    end
endfunction

function [6:0] K_value;
    input [2:0] stage;
    begin
        case(stage)
            3'd0: K_value = 7'd1;
            3'd1: K_value = 7'd4;
            3'd2: K_value = 7'd16;
            default: K_value = 7'd64;
        endcase
    end
endfunction

wire is_ntt  = (opcode == `NTT);
wire is_intt = (opcode == `INTT);

wire [6:0] J_cur = J_value(i);
wire [6:0] K_cur = K_value(i);
wire [6:0] j_block_last = ((J_cur + `P_HALF - 1)/`P_HALF) - 1'b1;

assign en = en_ff1|wen;

shift#(.SHIFT(`L+3),.data_width(1)) shif_wen(.clk(clk),.rst(rst),.din(wen_ff),.dout(wen));
shift#(.SHIFT(`L+3),.data_width(1)) shif_finish(.clk(clk),.rst(rst),.din(done_ff),.dout(finish));
shift#(.SHIFT(2),.data_width(1)) shif_en(.clk(clk),.rst(rst),.din(en_ff),.dout(en_ff1));
shift#(.SHIFT(2),.data_width(1)) shif_ren(.clk(clk),.rst(rst),.din(ren_ff),.dout(ren));

always @(posedge clk) begin
    if (rst)
        start_ff <= 1'b0;
    else if(done_ff)
        start_ff <= 1'b0;
    else if(start)
        start_ff <= 1'b1;
end

always @(posedge clk) begin
    if (rst) begin
        state <= ST_IDLE;
        i <= 0;
        s <= 0;
        k <= 0;
    end else begin
        case (state)
            ST_IDLE: begin
                done_ff <= 1'b0;
                if (start_ff) begin
                    state <= ST_RUN;
                    i <= is_intt ? (`R4_STAGE_NUM-1) : 0;
                    s <= 0;
                    k <= 0;
                end
            end
            ST_RUN: begin
                done_ff <= 1'b0;
                if (s == j_block_last) begin
                    s <= 0;
                    if (k == K_cur-1) begin
                        k <= 0;
                        if ( (is_ntt && (i == (`R4_STAGE_NUM-1))) || (is_intt && (i == 0)) ) begin
                            done_ff <= 1'b1;
                            state <= ST_IDLE;
                        end else begin
                            if (is_intt)
                                i <= i - 1'b1;
                            else
                                i <= i + 1'b1;
                        end
                    end else begin
                        k <= k + 1'b1;
                    end
                end else begin
                    s <= s + 1'b1;
                end
            end
            default: state <= ST_IDLE;
        endcase
    end
end

always @(*) begin
    if(state==ST_RUN) begin
        en_ff = 1'b1;
        wen_ff = 1'b1;
        ren_ff = 1'b1;
    end else begin
        en_ff = 1'b0;
        wen_ff = 1'b0;
        ren_ff = 1'b0;
    end
end

endmodule
