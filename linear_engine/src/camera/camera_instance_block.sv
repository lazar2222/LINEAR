module camera_instance_block #(
    parameter int PIXEL_WIDTH,
    parameter int NUM_FRAMES,
    parameter int NUM_OBJECTS,
    parameter int WIDTH,
    parameter int CAMERA_INSTANCES
) (
    input clk,
    input rst,

    input [WIDTH-1:0] sim_a,
    input [WIDTH-1:0] sim_b,
    input [WIDTH-1:0] sim_c,

    input strobe,

    input [CAMERA_INSTANCES-1:0][WIDTH-1:0] camera_frame,
    input [CAMERA_INSTANCES-1:0][WIDTH-1:0] camera_x,
    input [CAMERA_INSTANCES-1:0][WIDTH-1:0] camera_y,

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

    output [CAMERA_INSTANCES*NUM_OBJECTS-1:0][      WIDTH-1:0] pattern_address,
    input  [CAMERA_INSTANCES*NUM_OBJECTS-1:0][PIXEL_WIDTH-1:0] pattern_data,

    output [CAMERA_INSTANCES-1:0][PIXEL_WIDTH-1:0] data
);
    wire [CAMERA_INSTANCES-1:0][NUM_OBJECTS-1:0][PIXEL_WIDTH-1:0] pattern_data_u = pattern_data;
    wire [CAMERA_INSTANCES-1:0][NUM_OBJECTS-1:0][      WIDTH-1:0] pattern_address_u;

    assign pattern_address = pattern_address_u;

    genvar i;
    generate
        for (i = 0; i < CAMERA_INSTANCES; i++) begin : g_camera_instances
            camera_instance #(
                .PIXEL_WIDTH    (PIXEL_WIDTH),
                .NUM_FRAMES     (NUM_FRAMES),
                .NUM_OBJECTS    (NUM_OBJECTS),
                .WIDTH          (WIDTH)
            ) camera_instance (
                .clk            (clk),
                .rst            (rst),
                .sim_a          (sim_a),
                .sim_b          (sim_b),
                .sim_c          (sim_c),
                .strobe         (strobe),
                .camera_frame   (camera_frame[i]),
                .camera_x       (camera_x[i]),
                .camera_y       (camera_y[i]),
                .x_channel      (x_channel),
                .y_channel      (y_channel),
                .a_channel      (a_channel),
                .x_shamt        (x_shamt),
                .y_shamt        (y_shamt),
                .a_shamt        (a_shamt),
                .x_shiftd       (x_shiftd),
                .y_shiftd       (y_shiftd),
                .a_shiftd       (a_shiftd),
                .x_offset       (x_offset),
                .y_offset       (y_offset),
                .a_offset       (a_offset),
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
                .pattern_address(pattern_address_u[i]),
                .pattern_data   (pattern_data_u[i]),
                .data           (data[i])
            );
        end
    endgenerate

endmodule
