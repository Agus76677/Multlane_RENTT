`include "parameter.v"

// 通用置换网络集合，面向 bank/RBFU 数据重排及后续 radix-4 扩展
// gather: out[k] = in[ sel_out[k] ]
module permute_gather #(
    parameter integer N    = 2*`P,
    parameter integer W    = `DATA_WIDTH,
    parameter integer SELW = `MAP
)(
    input  [N*W-1:0]     in_bus,
    input  [N*SELW-1:0]  sel_out_bus,
    output [N*W-1:0]     out_bus
);

    wire [W-1:0]    in      [0:N-1];
    wire [SELW-1:0] sel_out [0:N-1];
    reg  [W-1:0]    out     [0:N-1];

    genvar g;
    generate
        for(g = 0; g < N; g = g + 1) begin : UNPACK
            assign in[g]      = in_bus[g*W+W-1 : g*W];
            assign sel_out[g] = sel_out_bus[g*SELW+SELW-1 : g*SELW];
            assign out_bus[g*W+W-1 : g*W] = out[g];
        end
    endgenerate

    genvar k;
    generate
        for(k = 0; k < N; k = k + 1) begin : GEN_GATHER
            always @(*) begin
                out[k] = in[sel_out[k]];
            end
        end
    endgenerate
endmodule


// scatter: out[ sel_in[j] ] = in[j]; 后写覆盖前写
module permute_scatter #(
    parameter integer N    = 2*`P,
    parameter integer W    = `DATA_WIDTH,
    parameter integer SELW = `MAP
)(
    input  [N*W-1:0]     in_bus,
    input  [N*SELW-1:0]  sel_in_bus,
    output [N*W-1:0]     out_bus
);

    wire [W-1:0]    in     [0:N-1];
    wire [SELW-1:0] sel_in [0:N-1];
    reg  [W-1:0]    out    [0:N-1];

    genvar g;
    generate
        for(g = 0; g < N; g = g + 1) begin : UNPACK
            assign in[g]     = in_bus[g*W+W-1 : g*W];
            assign sel_in[g] = sel_in_bus[g*SELW+SELW-1 : g*SELW];
            assign out_bus[g*W+W-1 : g*W] = out[g];
        end
    endgenerate

    integer i;
    always @(*) begin
        for(i = 0; i < N; i = i + 1) begin
            out[i] = {W{1'b0}};
        end

        for(i = 0; i < N; i = i + 1) begin
            out[sel_in[i]] = in[i];
        end
    end
endmodule
