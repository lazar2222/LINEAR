module camera_per_instance #(
    parameter int PIXEL_WIDTH,
    parameter int NUM_FRAMES,
    parameter int NUM_OBJECTS,
    parameter int WIDTH
) (
    input clk,
    input rst,

    input [WIDTH-1:0] sim_a,
    input [WIDTH-1:0] sim_b,
    input [WIDTH-1:0] sim_c,

    input strobe,

    input [$clog2(NUM_FRAMES)-1:0] camera_frame,

    input [WIDTH-1:0] camera_x,
    input [WIDTH-1:0] camera_y,

    input [              1:0] x_channel,
    input [              1:0] y_channel,
    input [              1:0] a_channel,
    input [$clog2(WIDTH)-1:0] x_shamt,
    input [$clog2(WIDTH)-1:0] y_shamt,
    input [$clog2(WIDTH)-1:0] a_shamt,
    input                     x_shiftd,
    input                     y_shiftd,
    input                     a_shiftd,
    input [        WIDTH-1:0] x_offset,
    input [        WIDTH-1:0] y_offset,
    input [        WIDTH-1:0] a_offset,

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

    output [PIXEL_WIDTH-1:0] data
);
    wire [WIDTH-1:0] sim_a_buffer;
    wire [WIDTH-1:0] sim_b_buffer;
    wire [WIDTH-1:0] sim_c_buffer;

    wire [      WIDTH-1:0] world_x;
    wire [      WIDTH-1:0] world_y;
    wire [PIXEL_WIDTH-1:0] aux_value;

    camera_multi_buffer_controller #(
        .WIDTH     (WIDTH),
        .NUM_FRAMES(NUM_FRAMES)
    ) camera_multi_buffer_controller (
        .clk         (clk),
        .rst         (rst),
        .sim_a       (sim_a),
        .sim_b       (sim_b),
        .sim_c       (sim_c),
        .strobe      (strobe),
        .read_address(camera_frame),
        .sim_a_buffer(sim_a_buffer),
        .sim_b_buffer(sim_b_buffer),
        .sim_c_buffer(sim_c_buffer)
    );

    camera_coordinate_transformer #(
        .WIDTH      (WIDTH),
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) camera_coordinate_transformer (
        .sim_a    (sim_a_buffer),
        .sim_b    (sim_b_buffer),
        .sim_c    (sim_c_buffer),
        .camera_x (camera_x),
        .camera_y (camera_y),
        .x_channel(x_channel),
        .y_channel(y_channel),
        .a_channel(a_channel),
        .x_shamt  (x_shamt),
        .y_shamt  (y_shamt),
        .a_shamt  (a_shamt),
        .x_shiftd (x_shiftd),
        .y_shiftd (y_shiftd),
        .a_shiftd (a_shiftd),
        .x_offset (x_offset),
        .y_offset (y_offset),
        .a_offset (a_offset),
        .world_x  (world_x),
        .world_y  (world_y),
        .aux_value(aux_value)
    );

    camera_block #(
        .NUM_OBJECTS(NUM_OBJECTS),
        .WIDTH      (WIDTH),
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) camera_block (
        .clk            (clk),
        .rst            (rst),
        .world_x        (world_x),
        .world_y        (world_y),
        .x1             (x1),
        .y1             (y1),
        .x2             (x2),
        .y2             (y2),
        .patch_size_x   (patch_size_x),
        .patch_size_y   (patch_size_y),
        .pattern_size_x (pattern_size_x),
        .pattern_size_y (pattern_size_y),
        .aux_shift      (aux_shift),
        .aux_shiftd     (aux_shiftd),
        .aux_min        (aux_min),
        .aux_max        (aux_max),
        .aux_mask       (aux_mask),
        .pattern_address(pattern_address),
        .pattern_data   (pattern_data),
        .aux_value      (aux_value),
        .data           (data)
    );

endmodule
