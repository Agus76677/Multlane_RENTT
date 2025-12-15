`include "parameter.v"

(*DONT_TOUCH = "true"*)
module tf_address_generator(
    input                               clk        ,
    input                               rst        ,
    input    [1                :0]      opcode     ,
    input    [2                :0]      i          ,
    input    [6                :0]      k          ,
    output   [`ADDR_ROM_WIDTH -1:0]     tf_address
);

reg [`ADDR_ROM_WIDTH -1:0] tf_address_tmp;

function [6:0] stage_base;
    input [2:0] stage;
    begin
        case(stage)
            3'd0: stage_base = 7'd0;
            3'd1: stage_base = 7'd1;
            3'd2: stage_base = 7'd5;
            default: stage_base = 7'd21;
        endcase
    end
endfunction

always@(*) begin
  case(opcode)
    `NTT :begin tf_address_tmp = stage_base(i) + k; end
    `INTT:begin tf_address_tmp = `OFFSET_TF_INTT + stage_base(i) + k; end
    `PWM1:begin tf_address_tmp = `OFFSET_TF_PWM1 + k; end
    default: tf_address_tmp = 0;
  endcase
end

shift#(.SHIFT(2),.data_width(`ADDR_ROM_WIDTH )) shift_tf(.clk(clk),.rst(rst),.din(tf_address_tmp),.dout(tf_address));
endmodule
