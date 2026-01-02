`include "parameter.v"
//作用：把控制器给的 (opcode, i, s) 映射成 twiddle factor ROM 的地址 tf_address，供 tf_ROM 读出旋转因子 w。
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

    // NTT：地址 = stage_base + group_index
    // stage_base = i * 2^(7-P_SHIFT)   （相当于每个stage占一段连续区域）
    // group_index = s >> P_SHIFT       （把并行粒度P折叠掉，只留下“组号”）
    `NTT :begin tf_address_tmp=(i<<(7-`P_SHIFT))+(s>>`P_SHIFT);end

    // INTT：与NTT同结构，但读取另一段 twiddle 表（加 OFFSET_TF_1）
    `INTT:begin tf_address_tmp=(i<<(7-`P_SHIFT))+(s>>`P_SHIFT)+`OFFSET_TF_1;end

    // PWM1：这里不是“stage+group”的线性表，而是把 i 和 s[0] 拼起来（或组合）后 
    // 再映射到 PWM1 专用 twiddle 区（OFFSET_TF_2）
    // {i, s[0]} 的含义：同一 i 下根据奇偶选择两类系数（常见于只需少量 twiddle 的阶段）
    `PWM1:begin tf_address_tmp={i,s[0]}|`OFFSET_TF_2;end

  endcase
end

// 地址延迟2拍：对齐后级 bank read / network / RBFU 的控制时序
shift#(.SHIFT(2),.data_width(`ADDR_ROM_WIDTH )) shift_tf(.clk(clk),.rst(rst),.din(tf_address_tmp),.dout(tf_address));
// DFF #(.data_width(`ADDR_ROM_WIDTH )) dff_tf(.clk(clk),.rst(rst),.d(tf_address_tmp),.q(tf_address));
endmodule
/*
基4修改： ROM 输出 bundle 的风格。
一次读出，同时输出多个twiddle向量。
可以坚持仍然是单个地址输出，但是在ROM中存放的逻辑就是连续三个twiddle向量的打包。
*/