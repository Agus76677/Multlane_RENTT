`include "parameter.v"

// Benes-style permutation network built from 2x2 switches
module permute_benes #(
    parameter integer N    = 2*`P,
    parameter integer W    = 1,
    parameter integer SELW = `MAP
) (
    input  [N*W-1:0]       in_bus,
    input  [N*SELW-1:0]    dest_bus,
    output [N*W-1:0]       out_bus
);

    localparam integer LOGN   = $clog2(N);
    localparam integer STAGES = (2*LOGN-1);

    wire [W-1:0] in_arr  [0:N-1];
    reg  [W-1:0] out_arr [0:N-1];
    wire [W-1:0] stage_data [0:STAGES][0:N-1];
    reg          ctrl       [0:STAGES-1][0:N/2-1];
    integer      perm_tmp   [0:N-1];

    genvar si;
    generate
        for (si = 0; si < N; si = si + 1) begin : gen_unpack
            assign in_arr[si]  = in_bus[si*W + W-1 : si*W];
            assign out_bus[si*W + W-1 : si*W] = out_arr[si];
        end
    endgenerate

    // Combinational route computation for Benes network
    integer s_idx, sw_idx;

    task automatic route_block;
        input integer offset;
        input integer size;
        input integer stage_base;

        integer half;
        integer i, j, out, next;
        integer inv_perm[0:N-1];
        integer first_sel[0:N-1];
        integer last_sel [0:N-1];
        integer visited [0:N-1];
        integer upper_perm[0:N-1];
        integer lower_perm[0:N-1];
        integer in_map   [0:N-1];
        integer out_map  [0:N-1];
        integer upper_in, lower_in, upper_out, lower_out;
    begin
        if (size == 2) begin
            ctrl[stage_base][offset/2] = (perm_tmp[offset] != 0);
        end else begin
            half = size/2;

            for (i = 0; i < size; i = i + 1) begin
                inv_perm[ perm_tmp[offset + i] - offset ] = i;
                visited[i]   = 0;
                first_sel[i] = 0;
                last_sel[i]  = 0;
            end

            for (i = 0; i < size; i = i + 1) begin
                if (!visited[i]) begin
                    j      = i;
                    next   = 0;
                    while (!visited[j]) begin
                        visited[j] = 1;
                        out        = perm_tmp[offset + j] - offset;
                        if (out < half) begin
                            first_sel[j] = next;
                            last_sel[out] = next;
                            j = out + half;
                        end else begin
                            first_sel[j] = next ^ 1;
                            last_sel[out] = next ^ 1;
                            j = out - half;
                        end
                        next = next ^ 1;
                    end
                end
            end

            for (i = 0; i < half; i = i + 1) begin
                if (first_sel[2*i] == first_sel[2*i+1])
                    first_sel[2*i+1] = ~first_sel[2*i];
                if (last_sel[2*i] == last_sel[2*i+1])
                    last_sel[2*i+1] = ~last_sel[2*i];

                ctrl[stage_base][offset/2 + i] = first_sel[2*i];
                ctrl[stage_base + (2*$clog2(size)-2)][offset/2 + i] = last_sel[2*i];
            end

            upper_in  = 0; lower_in  = 0;
            upper_out = 0; lower_out = 0;
            for (i = 0; i < size; i = i + 1) begin
                if (first_sel[i] == 0) begin
                    in_map[i] = upper_in;
                    upper_in  = upper_in + 1;
                end else begin
                    in_map[i] = lower_in;
                    lower_in  = lower_in + 1;
                end
                if (last_sel[i] == 0) begin
                    out_map[i] = upper_out;
                    upper_out  = upper_out + 1;
                end else begin
                    out_map[i] = lower_out;
                    lower_out  = lower_out + 1;
                end
            end

            for (i = 0; i < size; i = i + 1) begin
                if (first_sel[i] == 0)
                    upper_perm[in_map[i]] = out_map[ perm_tmp[offset + i] - offset ];
                else
                    lower_perm[in_map[i]] = out_map[ perm_tmp[offset + i] - offset ];
            end

            for (i = 0; i < half; i = i + 1) begin
                perm_tmp[offset + i]        = offset + upper_perm[i];
                perm_tmp[offset + half + i] = offset + half + lower_perm[i];
            end

            route_block(offset, half, stage_base + 1);
            route_block(offset + half, half, stage_base + 1);
        end
    end
    endtask

    always @(*) begin
        for (s_idx = 0; s_idx < STAGES; s_idx = s_idx + 1)
            for (sw_idx = 0; sw_idx < N/2; sw_idx = sw_idx + 1)
                ctrl[s_idx][sw_idx] = 1'b0;

        for (s_idx = 0; s_idx < N; s_idx = s_idx + 1)
            perm_tmp[s_idx] = dest_bus[s_idx*SELW +: SELW];

        route_block(0, N, 0);

        for (s_idx = 0; s_idx < N; s_idx = s_idx + 1)
            out_arr[s_idx] = stage_data[STAGES][s_idx];
    end

    // Data path through the switch fabric
    generate
        for (si = 0; si < N; si = si + 1) begin : gen_stage0
            assign stage_data[0][si] = in_arr[si];
        end
    endgenerate

    genvar st, sw;
    generate
        for (st = 0; st < STAGES; st = st + 1) begin : gen_stage
            for (sw = 0; sw < N/2; sw = sw + 1) begin : gen_sw
                assign stage_data[st+1][2*sw]     = ctrl[st][sw] ? stage_data[st][2*sw+1] : stage_data[st][2*sw];
                assign stage_data[st+1][2*sw + 1] = ctrl[st][sw] ? stage_data[st][2*sw]   : stage_data[st][2*sw+1];
            end
        end
    endgenerate
endmodule

// Wrapper to preserve existing module name while using Benes fabric
module permute_scatter #(
    parameter integer N    = 2*`P,
    parameter integer W    = 1,
    parameter integer SELW = `MAP,
    parameter integer USE_BENES = 0
) (
    input  [N*W-1:0]       in_bus,
    input  [N*SELW-1:0]    sel_in_bus,
    output [N*W-1:0]       out_bus
);
    generate
        if (USE_BENES) begin : gen_benes
            permute_benes #(
                .N(N),
                .W(W),
                .SELW(SELW)
            ) benes_impl (
                .in_bus(in_bus),
                .dest_bus(sel_in_bus),
                .out_bus(out_bus)
            );
        end else begin : gen_scatter
            wire [W-1:0]    in_arr  [0:N-1];
            wire [SELW-1:0] sel_in  [0:N-1];
            reg  [W-1:0]    out_arr [0:N-1];
            genvar          si;
            integer         j, m;

            for (si = 0; si < N; si = si + 1) begin : gen_unpack_scatter
                assign in_arr[si] = in_bus[si*W + W-1 : si*W];
                assign sel_in[si] = sel_in_bus[si*SELW + SELW-1 : si*SELW];
                assign out_bus[si*W + W-1 : si*W] = out_arr[si];
            end

            always @(*) begin
                for (m = 0; m < N; m = m + 1)
                    out_arr[m] = {W{1'b0}};

                for (j = 0; j < N; j = j + 1) begin
                    if ({1'b0, sel_in[j]} < N)
                        out_arr[sel_in[j]] = in_arr[j];
                end
            end
        end
    endgenerate
endmodule

