`timescale 1ns / 1ps
`include "../../parameter.v"  
// `include "Hybrid_compress_Red.v"
// `include "sel_nq.v"
// `include "sel_n2q.v"
// `include "sel_q.v"
// `include "CSA1.v"
// `include "CSA2.v"
// `include "CSA3.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/29 21:16:16
// Design Name: 
// Module Name: bitmod_wocsa3
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
// bitmod_wocsa3_RCA performance best
`ifdef PIPE1
module bitmod_wocsa3(
            input      clk,
            input      [23:0] C,
            output reg [11:0] R);

// First Stage
wire [14:0] C0;
wire [13:0] S0;

Hybrid_compress_Red_wocsa3 u0(
{C[0],C[20], C[17], C[18],!C[12],!C[14],!C[19],1'b1},
{C[1],C[21],!C[13],!C[15]},
{C[2],C[22], C[20], C[19],!C[14],!C[16]},
{C[3],C[23], C[21],!C[15],!C[17]},
{C[4],C[22],!C[16],!C[18]},
{C[5],C[23], C[19],!C[17],1'b1},
{C[6],C[18], C[19],!C[20],1'b1},
{C[7],C[18],!C[21],1'b1},
{C[8],C[12], C[17],!C[22],!C[14]},
{C[9],C[12], C[13], C[19],!C[15],!C[23]},
{C[10],C[13],C[17], C[19],!C[16],!C[18]},
C[11],
S0,C0
);

wire [14:0] Rmp0;
wire [14:0] Rm1q,Rm2q,Rp1q;
reg  [14:0] C0_ff;
reg  [13:0] S0_ff;

always @(posedge clk) begin
     C0_ff <=  C0;
     S0_ff <=  S0;
end

assign Rmp0 = C0_ff+S0_ff;

assign Rm1q = Rmp0-12'd3329;
assign Rm2q = Rmp0-13'd6658;
assign Rp1q = Rmp0+12'd3329;

always @(*) begin
    case ({Rm2q[14], Rm1q[14], Rmp0[14]})
        3'b000: R = Rm2q[11:0];     // 减2q结果为正
        3'b100: R = Rm1q[11:0];     // 减2q结果为负，减1q结果为正
        3'b110: R = Rmp0[11:0];     // 减2q、减1q结果为负，原结果为正
        3'b111: R = Rp1q[11:0];     // 所有结果为负，加1q结果
        default: R = 12'b0;         // 处理所有其他情况（理论上不会发生）
    endcase
end

endmodule

`elsif PIPE3
module bitmod_wocsa3(
            input      clk,
            input      [23:0] C,
            output reg [11:0] R);

// First Stage
wire [14:0] C0;
wire [13:0] S0;

Hybrid_compress_Red_wocsa3 u0(
{C[0],C[20], C[17], C[18],!C[12],!C[14],!C[19],1'b1},
{C[1],C[21],!C[13],!C[15]},
{C[2],C[22], C[20], C[19],!C[14],!C[16]},
{C[3],C[23], C[21],!C[15],!C[17]},
{C[4],C[22],!C[16],!C[18]},
{C[5],C[23], C[19],!C[17],1'b1},
{C[6],C[18], C[19],!C[20],1'b1},
{C[7],C[18],!C[21],1'b1},
{C[8],C[12], C[17],!C[22],!C[14]},
{C[9],C[12], C[13], C[19],!C[15],!C[23]},
{C[10],C[13],C[17], C[19],!C[16],!C[18]},
C[11],
S0,C0
);

wire [14:0] Rmp0;
wire [14:0] Rm1q,Rm2q,Rp1q;
reg  [14:0] C0_ff;
reg  [13:0] S0_ff;

always @(posedge clk) begin
     C0_ff <=  C0;
     S0_ff <=  S0;
end

assign Rmp0 = C0_ff+S0_ff;

assign Rm1q = Rmp0-12'd3329;
assign Rm2q = Rmp0-13'd6658;
assign Rp1q = Rmp0+12'd3329;

reg [14:0] Rmp0_ff;
reg [14:0] Rm1q_ff,Rm2q_ff,Rp1q_ff;

always @(posedge clk) begin
    Rm2q_ff<=Rm2q;
    Rm1q_ff<=Rm1q;
    Rmp0_ff<=Rmp0;
    Rp1q_ff<=Rp1q;
end

always @(*) begin
    case ({Rm2q_ff[14], Rm1q_ff[14], Rmp0_ff[14]})
        3'b000: R = Rm2q_ff[11:0];     // 减2q结果为正
        3'b100: R = Rm1q_ff[11:0];     // 减2q结果为负，减1q结果为正
        3'b110: R = Rmp0_ff[11:0];     // 减2q、减1q结果为负，原结果为正
        3'b111: R = Rp1q_ff[11:0];     // 所有结果为负，加1q结果
        default: R = 12'b0;         // 处理所有其他情况（理论上不会发生）
    endcase
end
endmodule
`elsif PIPE7
module bitmod_wocsa3(
            input      clk,
            input      [23:0] C,
            output reg [11:0] R);

// First Stage
wire [14:0] C0;
wire [13:0] S0;

Hybrid_compress_Red_wocsa3 u0(
{C[0],C[20], C[17], C[18],!C[12],!C[14],!C[19],1'b1},
{C[1],C[21],!C[13],!C[15]},
{C[2],C[22], C[20], C[19],!C[14],!C[16]},
{C[3],C[23], C[21],!C[15],!C[17]},
{C[4],C[22],!C[16],!C[18]},
{C[5],C[23], C[19],!C[17],1'b1},
{C[6],C[18], C[19],!C[20],1'b1},
{C[7],C[18],!C[21],1'b1},
{C[8],C[12], C[17],!C[22],!C[14]},
{C[9],C[12], C[13], C[19],!C[15],!C[23]},
{C[10],C[13],C[17], C[19],!C[16],!C[18]},
C[11],
S0,C0
);

wire [14:0] Rmp0;
reg  [14:0] Rmp0_ff;
wire [14:0] Rm1q,Rm2q,Rp1q;

assign Rmp0 = C0+S0;

always @(posedge clk) begin
    Rmp0_ff <= Rmp0;
end

assign Rm1q = Rmp0_ff-12'd3329;
assign Rm2q = Rmp0_ff-13'd6658;
assign Rp1q = Rmp0_ff+12'd3329;

reg [14:0] Rmp0_ff2;
reg [14:0] Rm1q_ff,Rm2q_ff,Rp1q_ff;

always @(posedge clk) begin
    Rm2q_ff<=Rm2q;
    Rm1q_ff<=Rm1q;
    Rmp0_ff2<=Rmp0_ff;
    Rp1q_ff<=Rp1q;
end

always @(*) begin
    case ({Rm2q_ff[14], Rm1q_ff[14], Rmp0_ff2[14]})
        3'b000: R = Rm2q_ff[11:0];     // 减2q结果为正
        3'b100: R = Rm1q_ff[11:0];     // 减2q结果为负，减1q结果为正
        3'b110: R = Rmp0_ff2[11:0];     // 减2q、减1q结果为负，原结果为正
        3'b111: R = Rp1q_ff[11:0];     // 所有结果为负，加1q结果
        default: R = 12'b0;         // 处理所有其他情况（理论上不会发生）
    endcase
end
endmodule

`elsif PIPE8
module bitmod_wocsa3(
            input      clk,
            input      [23:0] C,
            output reg [11:0] R);

// First Stage
wire [14:0] C0;
wire [13:0] S0;

Hybrid_compress_Red_wocsa3 u0(
{C[0],C[20], C[17], C[18],!C[12],!C[14],!C[19],1'b1},
{C[1],C[21],!C[13],!C[15]},
{C[2],C[22], C[20], C[19],!C[14],!C[16]},
{C[3],C[23], C[21],!C[15],!C[17]},
{C[4],C[22],!C[16],!C[18]},
{C[5],C[23], C[19],!C[17],1'b1},
{C[6],C[18], C[19],!C[20],1'b1},
{C[7],C[18],!C[21],1'b1},
{C[8],C[12], C[17],!C[22],!C[14]},
{C[9],C[12], C[13], C[19],!C[15],!C[23]},
{C[10],C[13],C[17], C[19],!C[16],!C[18]},
C[11],
S0,C0
);

wire [14:0] Rmp0;
reg  [14:0] Rmp0_ff;
wire [14:0] Rm1q,Rm2q,Rp1q;

reg  [14:0] C0_ff;
reg  [13:0] S0_ff;

always @(posedge clk) begin
     C0_ff <=  C0;
     S0_ff <=  S0;
end

assign Rmp0 = C0_ff+S0_ff;

always @(posedge clk) begin
    Rmp0_ff <= Rmp0;
end

assign Rm1q = Rmp0_ff-12'd3329;
assign Rm2q = Rmp0_ff-13'd6658;
assign Rp1q = Rmp0_ff+12'd3329;

reg [14:0] Rmp0_ff2;
reg [14:0] Rm1q_ff,Rm2q_ff,Rp1q_ff;

always @(posedge clk) begin
    Rm2q_ff<=Rm2q;
    Rm1q_ff<=Rm1q;
    Rmp0_ff2<=Rmp0_ff;
    Rp1q_ff<=Rp1q;
end

always @(*) begin
    case ({Rm2q_ff[14], Rm1q_ff[14], Rmp0_ff2[14]})
        3'b000: R = Rm2q_ff[11:0];     // 减2q结果为正
        3'b100: R = Rm1q_ff[11:0];     // 减2q结果为负，减1q结果为正
        3'b110: R = Rmp0_ff2[11:0];    // 减2q、减1q结果为负，原结果为正
        3'b111: R = Rp1q_ff[11:0];     // 所有结果为负，加1q结果
        default: R = 12'b0;         // 处理所有其他情况（理论上不会发生）
    endcase
end
endmodule
`else
module bitmod_wocsa3(
            input      clk,
            input      [23:0] C,
            output reg [11:0] R);

// First Stage
wire [14:0] C0;
wire [13:0] S0;

Hybrid_compress_Red_wocsa3 u0(
{C[0],C[20], C[17], C[18],!C[12],!C[14],!C[19],1'b1},
{C[1],C[21],!C[13],!C[15]},
{C[2],C[22], C[20], C[19],!C[14],!C[16]},
{C[3],C[23], C[21],!C[15],!C[17]},
{C[4],C[22],!C[16],!C[18]},
{C[5],C[23], C[19],!C[17],1'b1},
{C[6],C[18], C[19],!C[20],1'b1},
{C[7],C[18],!C[21],1'b1},
{C[8],C[12], C[17],!C[22],!C[14]},
{C[9],C[12], C[13], C[19],!C[15],!C[23]},
{C[10],C[13],C[17], C[19],!C[16],!C[18]},
C[11],
// 1'b1,
// 1'b1,
// 1'b1,
S0,C0
);

wire [14:0] Rmp0;
reg  [14:0] Rmp0_ff1=0;
wire [14:0] Rm1q,Rm2q,Rp1q;

assign Rmp0 = C0+S0;

always @(posedge clk) begin
    Rmp0_ff1 <= Rmp0;
end

assign Rm1q = Rmp0_ff1-12'd3329;
assign Rm2q = Rmp0_ff1-13'd6658;
assign Rp1q = Rmp0_ff1+12'd3329;

always @(*) begin
    case ({Rm2q[14], Rm1q[14], Rmp0_ff1[14]})
        3'b000: R = Rm2q[11:0];     // 减2q结果为正
        3'b100: R = Rm1q[11:0];     // 减2q结果为负，减1q结果为正
        3'b110: R = Rmp0_ff1[11:0]; // 减2q、减1q结果为负，原结果为正
        3'b111: R = Rp1q[11:0];     // 所有结果为负，加1q结果
        default: R = 12'b0;         // 处理所有其他情况（理论上不会发生）
    endcase
end

endmodule
`endif