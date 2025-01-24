module looper #(
    parameter int INPUT_WIDTH,
    parameter int OUTPUT_WIDTH
) (
    input  [ INPUT_WIDTH-1:0] data_in,
    output [OUTPUT_WIDTH-1:0] data_out
);
    localparam int LOOP_FACTOR = (OUTPUT_WIDTH + INPUT_WIDTH - 1) / INPUT_WIDTH;

    wire [INPUT_WIDTH*LOOP_FACTOR-1:0] data_out_internal = {LOOP_FACTOR{data_in}};

    assign data_out = data_out_internal[INPUT_WIDTH*LOOP_FACTOR-1-:OUTPUT_WIDTH];

endmodule
