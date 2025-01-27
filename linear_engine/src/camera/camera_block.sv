module camera_block #(
    parameter int NUM_OBJECTS,
    parameter int WIDTH,
    parameter int PIXEL_WIDTH
) (
    input clk,
    input rst,

    input [WIDTH-1:0] world_x,
    input [WIDTH-1:0] world_y,

    input [NUM_OBJECTS-1:0][        WIDTH-1:0] x1,
    input [NUM_OBJECTS-1:0][        WIDTH-1:0] y1,
    input [NUM_OBJECTS-1:0][        WIDTH-1:0] x2,
    input [NUM_OBJECTS-1:0][        WIDTH-1:0] y2,
    input [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] patch_size_x,
    input [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] patch_size_y,
    input [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] pattern_size_x,
    input [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] pattern_size_y,
    input [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] aux_shift,
    input [NUM_OBJECTS-1:0]                    aux_shiftd,
    input [NUM_OBJECTS-1:0][  PIXEL_WIDTH-1:0] aux_min,
    input [NUM_OBJECTS-1:0][  PIXEL_WIDTH-1:0] aux_max,
    input [NUM_OBJECTS-1:0][  PIXEL_WIDTH-1:0] aux_mask,

    output [NUM_OBJECTS-1:0][      WIDTH-1:0] pattern_address,
    input  [NUM_OBJECTS-1:0][PIXEL_WIDTH-1:0] pattern_data,

    input  [PIXEL_WIDTH-1:0] aux_value,

    output [PIXEL_WIDTH-1:0] data
);
    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] fill_x;
    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] fill_y;
    wire [NUM_OBJECTS-1:0][PIXEL_WIDTH-1:0] samples;
    wire [NUM_OBJECTS-1:0]                  visible;

    genvar i;
    generate
        for (i = 0; i < NUM_OBJECTS; i++) begin : g_samples
            occlusion_checker #(
                .WIDTH(WIDTH)
            ) occlusion_checker (
                .world_x(world_x),
                .world_y(world_y),
                .x1     (x1[i]),
                .y1     (y1[i]),
                .x2     (x2[i]),
                .y2     (y2[i]),
                .fill_x (fill_x[i]),
                .fill_y (fill_y[i]),
                .visible(visible[i])
            );

            pattern_sampler #(
                .WIDTH      (WIDTH),
                .PIXEL_WIDTH(PIXEL_WIDTH)
            ) pattern_sampler (
                .fill_x         (fill_x[i]),
                .fill_y         (fill_y[i]),
                .patch_size_x   (patch_size_x[i]),
                .patch_size_y   (patch_size_y[i]),
                .pattern_size_x (pattern_size_x[i]),
                .pattern_size_y (pattern_size_y[i]),
                .pattern_address(pattern_address[i]),
                .pattern_data   (pattern_data[i]),
                .aux_value      (aux_value),
                .aux_shift      (aux_shift[i]),
                .aux_shiftd     (aux_shiftd[i]),
                .aux_min        (aux_min[i]),
                .aux_max        (aux_max[i]),
                .aux_mask       (aux_mask[i]),
                .output_data    (samples[i])
            );
        end
    endgenerate

    priority_select #(
        .WIDTH(PIXEL_WIDTH),
        .COUNT(NUM_OBJECTS)
    ) priority_select (
        .values(samples),
        .enable(visible),
        .masked(data),
        .prio_enable(),
        .prio_sel(),
        .prio_any()
    );

endmodule
