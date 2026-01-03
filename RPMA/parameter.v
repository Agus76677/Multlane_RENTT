
//------------编译定义-------------
`define OP0  //P=2时
// `define OP1  //P=4时
// `define OP2  //P=8时    
// `define OP3  //P=16时

`define PIPE1  //L=1时
// `define PIPE2  //L=2时
// `define PIPE3  //L=3时
// `define PIPE4  //L=4时
// `define PIPE5  //L=5时
// `define PIPE6  //L=6时
// `define PIPE7  //L=7时
// `define PIPE8  //L=8时

//--------------操作类型------------
`define NTT  2'b00 
`define INTT 2'b01 
`define PWM0 2'b10 
`define PWM1 2'b11 

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
//P的意思就是每个时钟周期并行处理的数据个数，也就是BFU的个数

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

`define MAP      $clog2(2*`P) //MAP的意思是每个BABI单元处理的数据个数的二进制位宽
`define P_SHIFT  $clog2(`P) //P的二进制位宽。后面的BABI切分依靠他，在memory_map中
`define P_HALF   `P/2          //RBFU的个数。每个RBFU由2个BFU组成。

`define BANK_ROW 256/(2*`P)-1 //Bank Row Size
`define S_END    128-`P

//pack unpack
`define BI_PACK   (2*`P)*`MAP //pack size
`define BA_PACK   8*(2*`P)    //pack size 
`define DATA_PACK 12*(2*`P)  //data pack size

//data size
`define DATA_WIDTH 12
`define ADDR_WIDTH 8   //data address width
`define DEPTH      256 //bank depth
`define ADDR_ROM_WIDTH 11-`P_SHIFT   //为什么是11？因为ROM_DEPTH最大是2048，2的11次方是2048
//Twiddle factor的数量是N*log2(N) = 256*8 = 2048个
//为什么不是

//但是因为我们是多路并行处理的，所以ROM_DEPTH要除以P。P个并行的BFU同时取P个旋转因子
`define ROM_DEPTH   2048/`P       //ROM Depth
`define OFFSET_TF_1 7*(128/`P) //TF偏移地址1
`define OFFSET_TF_2 14*(128/`P) //TF偏移地址2