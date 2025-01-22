module priority_enc #(
    parameter int WIDTH
) (
    input  [        WIDTH-1:0] in,
    output [        WIDTH-1:0] out,
    output [$clog2(WIDTH)-1:0] sel,
    output                     any
);
    wire [WIDTH-1:0] tmp;

    reg [$clog2(WIDTH)-1:0] sel_reg;

    assign any = |in;
    assign sel = sel_reg;

    assign tmp[0] = in[0];
    assign out[0] = in[0];

    genvar i;
    generate
        for (i = 1; i < WIDTH; i++) begin : g_prio
            assign tmp[i] = in[i] ||  tmp[i-1];
            assign out[i] = in[i] && !tmp[i-1];
        end
    endgenerate

    always_comb begin
        sel_reg = '0;
        for (int i = 0; i < WIDTH; i++)
        if (in[i]) begin
            sel_reg = i;
            break;
        end
    end

endmodule
