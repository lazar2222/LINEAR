module block_swap #(
    parameter int DataWidth,
    parameter int BlockWidth
) (
    input  [DataWidth-1:0] data_in,
    output [DataWidth-1:0] data_out
);
    localparam int BlockCount = DataWidth / BlockWidth;

    wire [BlockWidth-1:0] input_blocks [BlockCount];
    wire [BlockWidth-1:0] output_blocks[BlockCount];

    genvar i;
    generate
        for (i = 0; i < BlockCount; i = i + 1) begin : g_block_swap
            assign input_blocks[i]                    = data_in[BlockWidth*i+:BlockWidth];
            assign output_blocks[i]                   = input_blocks[BlockCount-1-i];
            assign data_out[BlockWidth*i+:BlockWidth] = output_blocks[i];
        end
    endgenerate

endmodule
