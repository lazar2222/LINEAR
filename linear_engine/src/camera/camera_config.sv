`include "../interfaces/bus_if.svh"

module camera_config #(
    parameter int BASE_ADDRESS,
    parameter int PIXEL_WIDTH,
    parameter int NUM_OBJECTS,
    parameter int WIDTH,
    parameter int PATTERN_BYTE_SIZE,
    parameter int CAMERA_INSTANCES,
    `BUS_IF__PARAMS(config_port)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(config_port),

    input  [NUM_OBJECTS*CAMERA_INSTANCES-1:0][        WIDTH-1:0] pattern_address_pivot,
    output [NUM_OBJECTS*CAMERA_INSTANCES-1:0][  PIXEL_WIDTH-1:0] pattern_data_pivot,

    output [NUM_OBJECTS-1:0]                      [        WIDTH-1:0] x1,
    output [NUM_OBJECTS-1:0]                      [        WIDTH-1:0] y1,
    output [NUM_OBJECTS-1:0]                      [        WIDTH-1:0] x2,
    output [NUM_OBJECTS-1:0]                      [        WIDTH-1:0] y2,
    output [NUM_OBJECTS-1:0]                      [$clog2(WIDTH)-1:0] patch_size_x,
    output [NUM_OBJECTS-1:0]                      [$clog2(WIDTH)-1:0] patch_size_y,
    output [NUM_OBJECTS-1:0]                      [$clog2(WIDTH)-1:0] pattern_size_x,
    output [NUM_OBJECTS-1:0]                      [$clog2(WIDTH)-1:0] pattern_size_y,
    output [NUM_OBJECTS-1:0]                      [$clog2(WIDTH)-1:0] aux_shift,
    output [NUM_OBJECTS-1:0]                                          aux_shiftd,
    output [NUM_OBJECTS-1:0]                      [  PIXEL_WIDTH-1:0] aux_min,
    output [NUM_OBJECTS-1:0]                      [  PIXEL_WIDTH-1:0] aux_max,
    output [NUM_OBJECTS-1:0]                      [  PIXEL_WIDTH-1:0] aux_mask,

    output [                               1:0] x_channel,
    output [                               1:0] y_channel,
    output [                               1:0] a_channel,
    output [$clog2(DATA_WIDTH_config_port)-1:0] x_shamt,
    output [$clog2(DATA_WIDTH_config_port)-1:0] y_shamt,
    output [$clog2(DATA_WIDTH_config_port)-1:0] a_shamt,
    output                                      x_shiftd,
    output                                      y_shiftd,
    output                                      a_shiftd,
    output [        DATA_WIDTH_config_port-1:0] x_offset,
    output [        DATA_WIDTH_config_port-1:0] y_offset,
    output [        DATA_WIDTH_config_port-1:0] a_offset
);
    wire [NUM_OBJECTS-1:0][CAMERA_INSTANCES-1:0][      WIDTH-1:0] pattern_address_pivot_u = pattern_address_pivot;
    wire [NUM_OBJECTS-1:0][CAMERA_INSTANCES-1:0][PIXEL_WIDTH-1:0] pattern_data_pivot_u;

    assign pattern_data_pivot = pattern_data_pivot_u;

    genvar i;
    generate
        for (i = 0; i < NUM_OBJECTS; i++) begin : g_camera_objects
            camera_object_block #(
                .BASE_ADDRESS       (BASE_ADDRESS + i * PATTERN_BYTE_SIZE * 2),
                .PIXEL_WIDTH        (PIXEL_WIDTH),
                .NUM_OBJECTS        (NUM_OBJECTS),
                .WIDTH              (WIDTH),
                .PATTERN_BYTE_SIZE  (PATTERN_BYTE_SIZE),
                .CAMERA_INSTANCES   (CAMERA_INSTANCES),
                `BUS_IF__FILL_PARAMS(config_port, config_port)
            ) camera_object_block (
                .clk                  (clk),
                .rst                  (rst),
                `BUS_IF__CONNECT      (config_port, config_port),
                .pattern_address_pivot(pattern_address_pivot_u[i]),
                .pattern_data_pivot   (pattern_data_pivot_u[i]),
                .x1                   (x1[i]),
                .y1                   (y1[i]),
                .x2                   (x2[i]),
                .y2                   (y2[i]),
                .patch_size_x         (patch_size_x[i]),
                .patch_size_y         (patch_size_y[i]),
                .pattern_size_x       (pattern_size_x[i]),
                .pattern_size_y       (pattern_size_y[i]),
                .aux_shift            (aux_shift[i]),
                .aux_shiftd           (aux_shiftd[i]),
                .aux_min              (aux_min[i]),
                .aux_max              (aux_max[i]),
                .aux_mask             (aux_mask[i])
            );
        end
    endgenerate

    camera_global_config #(
        .BASE_ADDRESS       (BASE_ADDRESS + NUM_OBJECTS * PATTERN_BYTE_SIZE * 2),
        `BUS_IF__FILL_PARAMS(config_port, config_port)
    ) camera_global_config (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(config_port, config_port),
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
        .a_offset       (a_offset)
    );

endmodule
