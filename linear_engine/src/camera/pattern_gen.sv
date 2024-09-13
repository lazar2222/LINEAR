module pattern_gen #(
    parameter int InputWidth,
    parameter int OutputWidth,
    parameter int PatchWidthBits,
    parameter int PatchHeightBits,
    parameter int PatternWidthBits,
    parameter int PatternHeightBits
) (
    x,
    y,
    pattern,
    out
);
    localparam int PatternWidth  = 1 << PatternWidthBits;
    localparam int PatternHeight = 1 << PatternHeightBits;
    localparam int PatternSize   = PatternWidth * PatternHeight * OutputWidth;

    input [ InputWidth-1:0] x;
    input [ InputWidth-1:0] y;
    input [PatternSize-1:0] pattern;

    output [OutputWidth-1:0] out;

    wire [OutputWidth-1:0] pattern_vector[PatternHeight][PatternWidth];

    genvar i, j;
    generate
        for (i = 0; i < PatternHeight; i++) begin : g_pattern_height
            for (j = 0; j < PatternWidth; j++) begin : g_pattern_width
                assign pattern_vector[i][j] = pattern[(i*PatternWidth+j)*OutputWidth+:OutputWidth];
            end
        end
    endgenerate

    wire [ PatternWidthBits-1:0] x_pattern_position = x[PatchWidthBits+:PatternWidthBits];
    wire [PatternHeightBits-1:0] y_pattern_position = y[PatchHeightBits+:PatternHeightBits];

    assign out = pattern_vector[y_pattern_position][x_pattern_position];

endmodule
