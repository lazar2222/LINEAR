module pattern_sampler #(
    parameter int WIDTH,
    parameter int PIXEL_WIDTH,
    parameter int PATTERN_SIZE
) (
    input [WIDTH-1:0] fill_x,
    input [WIDTH-1:0] fill_y,

    input [$clog2(WIDTH)-1:0] patch_size_x,
    input [$clog2(WIDTH)-1:0] patch_size_y,

    output [WIDTH-1:0] pattern_address,

    input signed [PIXEL_WIDTH-1:0] pattern_data,

    input signed [PIXEL_WIDTH-1:0] aux_value,
    input signed [PIXEL_WIDTH-1:0] data_min,
    input signed [PIXEL_WIDTH-1:0] data_max,
    input signed [PIXEL_WIDTH-1:0] aux_min,
    input signed [PIXEL_WIDTH-1:0] aux_max,

    output [PIXEL_WIDTH-1:0] output_data
);
    localparam int PATTERN_SIZE_BITS = $clog2(PATTERN_SIZE);

    wire [PATTERN_SIZE_BITS-1:0] pattern_x = fill_x[patch_size_x+:PATTERN_SIZE_BITS];
    wire [PATTERN_SIZE_BITS-1:0] pattern_y = fill_y[patch_size_y+:PATTERN_SIZE_BITS];

    assign pattern_address = {pattern_y, pattern_x};

    wire clamp_min = pattern_data < data_min;
    wire clamp_max = pattern_data > data_max;

    wire [PIXEL_WIDTH-1:0] pattern_aux         = pattern_data + aux_value;
    wire [PIXEL_WIDTH-1:0] pattern_aux_clamped = clamp_min ? aux_min : clamp_max ? aux_max : pattern_aux;

    assign output_data = pattern_aux_clamped;

endmodule
