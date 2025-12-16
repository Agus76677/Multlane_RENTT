`include "parameter.v"

(*DONT_TOUCH = "true"*)
module tf_address_generator(
    input                               clk        ,
    input                               rst        ,
    input    [1                :0]      opcode     ,
    input    [5                :0]      i          ,
    input    [6                :0]      s          ,
    output   [`ADDR_ROM_WIDTH -1:0]      tf_address  
);
    
reg [`ADDR_ROM_WIDTH -1:0] tf_address_tmp;

always@(*) begin
  case(opcode)
    `NTT :begin tf_address_tmp=(i<<(7-`P_SHIFT))+(s>>`P_SHIFT);end
    `INTT:begin tf_address_tmp=(i<<(7-`P_SHIFT))+(s>>`P_SHIFT)+`OFFSET_TF_1;end
    `PWM1:begin tf_address_tmp={i,s[0]}|`OFFSET_TF_2;end
  endcase
end

shift#(.SHIFT(2),.data_width(`ADDR_ROM_WIDTH )) shift_tf(.clk(clk),.rst(rst),.din(tf_address_tmp),.dout(tf_address));
// DFF #(.data_width(`ADDR_ROM_WIDTH )) dff_tf(.clk(clk),.rst(rst),.d(tf_address_tmp),.q(tf_address));
endmodule