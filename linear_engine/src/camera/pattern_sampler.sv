module pattern_sampler #(
    parameter int WIDTH,
    parameter int PIXEL_WIDTH
) (
    input [WIDTH-1:0] fill_x,
    input [WIDTH-1:0] fill_y,

    input [$clog2(WIDTH)-1:0] patch_size_x,
    input [$clog2(WIDTH)-1:0] patch_size_y,
    input [$clog2(WIDTH)-1:0] pattern_size_x,
    input [$clog2(WIDTH)-1:0] pattern_size_y,

    output [WIDTH-1:0] pattern_address,

    input [PIXEL_WIDTH-1:0] pattern_data,

    input [  PIXEL_WIDTH-1:0] aux_value,
    input [$clog2(WIDTH)-1:0] aux_shift,
    input                     aux_shiftd,
    input [  PIXEL_WIDTH-1:0] aux_min,
    input [  PIXEL_WIDTH-1:0] aux_max,
    input [  PIXEL_WIDTH-1:0] aux_mask,

    output [PIXEL_WIDTH-1:0] output_data
);
    wire [WIDTH-1:0] patch_x = fill_x >> patch_size_x;
    wire [WIDTH-1:0] patch_y = fill_y >> patch_size_y;

    wire [WIDTH-1:0] pattern_x = patch_x & ((1'd1 << pattern_size_x) - 1'd1);
    wire [WIDTH-1:0] pattern_y = patch_y & ((1'd1 << pattern_size_y) - 1'd1);

    assign pattern_address = (pattern_y << pattern_size_x) | pattern_x;

    wire [PIXEL_WIDTH-1:0] aux_value_shift = aux_shiftd ? aux_value << aux_shift : aux_value >> aux_shift;
    wire [PIXEL_WIDTH-1:0] pattern_aux     = pattern_data + aux_value_shift;
    wire [PIXEL_WIDTH-1:0] pattern_aux_min = ((pattern_aux < aux_min) || pattern_aux[PIXEL_WIDTH-1]) ? aux_min : pattern_aux;
    wire [PIXEL_WIDTH-1:0] aux_value_max   = pattern_aux_min > aux_max                               ? aux_max : pattern_aux_min;

    assign output_data = aux_value_max & aux_mask;

endmodule
