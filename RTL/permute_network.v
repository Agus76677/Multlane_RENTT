`include "parameter.v"

// 2x2 switch fabric based on a Beneš-style routing algorithm
// Supports permutation routing: out[ dest[j] ] = in[j]
module permute_benes #(
    parameter integer N    = 2*`P,
    parameter integer W    = 1,
    parameter integer SELW = `MAP
) (
    input  [N*W-1:0]    in_bus,
    input  [N*SELW-1:0] dest_bus,
    output [N*W-1:0]    out_bus
);

    localparam integer LOGN   = $clog2(N);
    localparam integer STAGES = 2*LOGN - 1;

    wire [W-1:0]    in_arr  [0:N-1];
    wire [SELW-1:0] dest_arr[0:N-1];
    wire [W-1:0]    stage_data [0:STAGES][0:N-1];
    reg  [N/2-1:0]  stage_sel  [0:STAGES-1];

    genvar gi;
    generate
        for (gi = 0; gi < N; gi = gi + 1) begin : gen_unpack
            assign in_arr[gi]  = in_bus[gi*W + W-1 : gi*W];
            assign dest_arr[gi]= dest_bus[gi*SELW + SELW-1 : gi*SELW];
            assign stage_data[0][gi] = in_arr[gi];
            assign out_bus[gi*W + W-1 : gi*W] = stage_data[STAGES][gi];
        end
    endgenerate

    // Utility: integer log2
    function integer log2_int;
        input integer value;
        integer t;
        begin
            t = value - 1;
            log2_int = 0;
            while (t > 0) begin
                log2_int = log2_int + 1;
                t = t >> 1;
            end
        end
    endfunction

    integer perm_work [0:N-1];

    task automatic route_benes;
        input integer offset;
        input integer size;
        input integer stage_base;
        integer inv_local   [0:N-1];
        integer in_dir      [0:N-1];
        integer out_dir     [0:N-1];
        integer i;
        integer span;
        integer last_stage;
        integer cur_in;
        integer cur_out;
        integer dir;
        begin
            if (size == 2) begin
                stage_sel[stage_base][offset/2] = (perm_work[offset] == offset) ? 0 : 1;
            end else begin
                // Build inverse permutation (local indexing)
                for (i = 0; i < size; i = i + 1) begin
                    inv_local[i] = 0;
                end
                for (i = 0; i < size; i = i + 1) begin
                    inv_local[perm_work[offset+i] - offset] = i;
                end

                // Assign directions using cycle traversal
                for (i = 0; i < size; i = i + 1) begin
                    in_dir[i]  = -1;
                    out_dir[i] = -1;
                end

                for (i = 0; i < size; i = i + 1) begin
                    if (in_dir[i] == -1) begin
                        cur_in = i;
                        dir    = 0;
                        while (in_dir[cur_in] == -1) begin
                            in_dir[cur_in]  = dir;
                            cur_out         = perm_work[offset+cur_in] - offset;
                            out_dir[cur_out]= dir;
                            dir             = dir ^ 1;
                            cur_in          = inv_local[cur_out ^ 1];
                        end
                    end
                end

                // First stage selections
                for (i = 0; i < size/2; i = i + 1) begin
                    stage_sel[stage_base][offset/2 + i] = (in_dir[2*i] == 0 && in_dir[2*i+1] == 1) ? 0 : 1;
                end

                // Last stage selections
                span       = 2*log2_int(size) - 1;
                last_stage = stage_base + span - 1;
                for (i = 0; i < size/2; i = i + 1) begin
                    stage_sel[last_stage][offset/2 + i] = (out_dir[2*i] == 0 && out_dir[2*i+1] == 1) ? 0 : 1;
                end

                // Store sub-permutations with updated offsets (ordered by switch index)
                for (i = 0; i < size; i = i + 1) begin
                    if (in_dir[i] == 0) begin
                        perm_work[offset + (i/2)] = ((perm_work[offset+i] - offset) >> 1) + offset;
                    end else begin
                        perm_work[offset + size/2 + (i/2)] = ((perm_work[offset+i] - offset) >> 1) + offset + size/2;
                    end
                end

                // Recursive route for upper and lower subnetworks
                route_benes(offset, size/2, stage_base + 1);
                route_benes(offset + size/2, size/2, stage_base + 1);
            end
        end
    endtask

    integer si;
    integer sj;
    always @(*) begin
        // Default clear
        for (si = 0; si < STAGES; si = si + 1) begin
            stage_sel[si] = {N/2{1'b0}};
        end

        // Load permutation work array
        for (si = 0; si < N; si = si + 1) begin
            perm_work[si] = dest_arr[si];
        end

        // Compute routing configuration
        route_benes(0, N, 0);
    end

    // Switch fabric
    generate
        genvar st, sw;
        for (st = 0; st < STAGES; st = st + 1) begin : gen_stage
            for (sw = 0; sw < N/2; sw = sw + 1) begin : gen_switch
                wire [W-1:0] upper_in;
                wire [W-1:0] lower_in;
                assign upper_in = stage_data[st][2*sw];
                assign lower_in = stage_data[st][2*sw+1];
                assign stage_data[st+1][2*sw]   = stage_sel[st][sw] ? lower_in : upper_in;
                assign stage_data[st+1][2*sw+1] = stage_sel[st][sw] ? upper_in : lower_in;
            end
        end
    endgenerate

endmodule

// Wrapper to keep existing interface naming
// Provides scatter permutation; USE_BENES allows switching between
// the Beneš fabric and a simple crossbar implementation.
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
        if (USE_BENES) begin : gen_use_benes
            permute_benes #(
                .N(N),
                .W(W),
                .SELW(SELW)
            ) u_perm_benes (
                .in_bus(in_bus),
                .dest_bus(sel_in_bus),
                .out_bus(out_bus)
            );
        end else begin : gen_crossbar
            wire [W-1:0]       in_arr  [0:N-1];
            wire [SELW-1:0]    sel_in  [0:N-1];
            reg  [W-1:0]       out_arr [0:N-1];
            localparam [SELW:0] N_VAL = N;

            genvar si;
            for (si = 0; si < N; si = si + 1) begin : gen_unpack
                assign in_arr[si]  = in_bus[si*W + W-1 : si*W];
                assign sel_in[si]  = sel_in_bus[si*SELW + SELW-1 : si*SELW];
                assign out_bus[si*W + W-1 : si*W] = out_arr[si];
            end

            integer j, m;
            always @(*) begin
                for (m = 0; m < N; m = m + 1) begin
                    out_arr[m] = {W{1'b0}};
                end

                for (j = 0; j < N; j = j + 1) begin
                    if ({1'b0, sel_in[j]} < N_VAL)
                        out_arr[sel_in[j]] = in_arr[j];
                end
            end
        end
    endgenerate
endmodule

