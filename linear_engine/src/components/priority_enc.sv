module priority_enc #(
    parameter int Width
) (
    input  [        Width-1:0] in,
    output [        Width-1:0] out,
    output [$clog2(Width)-1:0] sel,
    output                     any
);
    wire [Width-1:0] tmp;

    reg [$clog2(Width)-1:0] sel_reg;

    assign any = |in;
    assign sel = sel_reg;

    assign tmp[0] = in[0];
    assign out[0] = in[0];

    genvar i;
    generate
        for (i = 1; i < Width; i++) begin : g_prio
            assign tmp[i] = in[i] |  tmp[i-1];
            assign out[i] = in[i] & !tmp[i-1];
        end
    endgenerate

    always_comb begin
        sel_reg = 'x;
        for (int i = 0; i < Width; i++)
        if (in[i]) begin
            sel_reg = i;
            break;
        end
    end

endmodule
