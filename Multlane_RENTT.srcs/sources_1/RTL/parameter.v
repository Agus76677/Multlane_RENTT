//------------编译定义-------------
// `define OP0  //P=2时
`define OP1  //P=4时
// `define OP2  //P=8时
// `define OP3  //P=16时

// `define PIPE1  //L=1时
// `define PIPE2  //L=2时
// `define PIPE3  //L=3时
// `define PIPE4  //L=4时
// `define PIPE5  //L=5时
`define PIPE6  //L=6时
// `define PIPE7  //L=7时
// `define PIPE8  //L=8时

//--------------操作类型------------
`define NTT  2'b00
`define INTT 2'b01
`define PWM0 2'b10
`define PWM1 2'b11

//-------------Radix4 feature macros------------
`define RADIX4_EN
`define R4_STAGE_NUM 4
`define ADDR_ROM_WIDTH 9
`define TF_SEG_LEN 85
`define OFFSET_TF_NTT   0
`define OFFSET_TF_INTT  (`OFFSET_TF_NTT + `TF_SEG_LEN)
`define OFFSET_TF_PWM1  (`OFFSET_TF_INTT + `TF_SEG_LEN)
`define OFFSET_TF_PWM0  (`OFFSET_TF_PWM1 + `TF_SEG_LEN)
`define ROM_DEPTH       (`OFFSET_TF_PWM0 + `TF_SEG_LEN)

//-------------参数定义------------
// 根据OP宏自动配置P参数
`ifdef OP0
    `define P 2  // 并行执行单元数
`elsif OP1
    `define P 4
`elsif OP2
    `define P 8
`elsif OP3
    `define P 16
`else
    `define P 2  // 默认值
`endif

// 根据PIPE宏自动配置L参数
`ifdef PIPE1
    `define L 1  // 流水线深度
`elsif PIPE2
    `define L 2
`elsif PIPE3
    `define L 3
`elsif PIPE4
    `define L 4
`elsif PIPE5
    `define L 5
`elsif PIPE6
    `define L 6
`elsif PIPE7
    `define L 7
`elsif PIPE8
    `define L 8
`else
    `define L 1  // 默认值
`endif

`define MAP      $clog2(2*`P)
`define P_SHIFT  $clog2(`P)
`define P_HALF   `P/2          //Parallel Execution Units Half
`define BANK_ROW 256/(2*`P)-1 //Bank Row Size

//pack unpack
`define BI_PACK   (2*`P)*`MAP //pack size
`define BA_PACK   8*(2*`P)    //pack size
`define DATA_PACK 12*(2*`P)  //data pack size

//data size
`define DATA_WIDTH 12
`define ADDR_WIDTH 8   //data address width
`define DEPTH      256 //bank depth
