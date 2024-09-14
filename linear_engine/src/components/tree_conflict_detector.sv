module tree_conflict_detector #(
    parameter int Width,
    parameter int Depth
) (
    input  [Width-1:0] data[Depth],
    output             conflict
);
    localparam int Levels = $clog2(Depth) + 1;

    wire [Width-1:0] intermediates[Levels][Depth];
    wire             conflicts    [Levels][Depth];

    genvar i, j;
    generate
        for (i = 0; i < Depth; i++) begin : g_level_0
            assign intermediates[0][i] = data[i];
            assign conflicts    [0][i] = '0;
        end
        for (i = 1; i < Levels; i++) begin : g_level_i
            for (j = 0; j < Depth >> i; j++) begin : g_node
                assign intermediates[i][j] =   intermediates[i-1][j*2] | intermediates[i-1][j*2+1];
                assign conflicts    [i][j] = |(intermediates[i-1][j*2] & intermediates[i-1][j*2+1]) || conflicts[i-1][j*2] || conflicts[i-1][j*2+1];
            end
        end
    endgenerate

    assign conflict = conflicts[Levels-1][0];

endmodule
