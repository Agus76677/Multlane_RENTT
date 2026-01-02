module modular_add #(parameter data_width = 12)(
    input [data_width-1:0] x_add,
    input [data_width-1:0] y_add,
    output [data_width-1:0] z_add
    );
    
    localparam [data_width-1:0] M = 12'd3329;

    wire [data_width-1:0] s;
    wire c;
    wire [data_width-1:0] d;
    wire b;
    wire sel;

    wire [data_width:0] sum_ext = {1'b0, x_add} + {1'b0, y_add};
    wire [data_width:0] sub_ext = {1'b0, s} - {1'b0, M};

    assign {c,s} = sum_ext;
    assign {b,d} = sub_ext;

    assign sel = ~((~c) & b);
    assign z_add = sel ? d : s;
endmodule