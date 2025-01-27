`include "../interfaces/bus_if.svh"

module camera_object_block #(
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

    input  [CAMERA_INSTANCES-1:0][        WIDTH-1:0] pattern_address_pivot,
    output [CAMERA_INSTANCES-1:0][  PIXEL_WIDTH-1:0] pattern_data_pivot,

    output                       [        WIDTH-1:0] x1,
    output                       [        WIDTH-1:0] y1,
    output                       [        WIDTH-1:0] x2,
    output                       [        WIDTH-1:0] y2,
    output                       [$clog2(WIDTH)-1:0] patch_size_x,
    output                       [$clog2(WIDTH)-1:0] patch_size_y,
    output                       [$clog2(WIDTH)-1:0] pattern_size_x,
    output                       [$clog2(WIDTH)-1:0] pattern_size_y,
    output                       [$clog2(WIDTH)-1:0] aux_shift,
    output                                           aux_shiftd,
    output                       [  PIXEL_WIDTH-1:0] aux_min,
    output                       [  PIXEL_WIDTH-1:0] aux_max,
    output                       [  PIXEL_WIDTH-1:0] aux_mask
);
    camera_pattern_bank #(
        .WIDTH              (WIDTH),
        .PIXEL_WIDTH        (PIXEL_WIDTH),
        .PATTERN_BYTE_SIZE  (PATTERN_BYTE_SIZE),
        .CAMERA_INSTANCES   (CAMERA_INSTANCES),
        .BASE_ADDRESS       (BASE_ADDRESS),
        `BUS_IF__FILL_PARAMS(write_port, config_port)
    ) camera_pattern_bank (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(write_port, config_port),
        .pattern_address(pattern_address_pivot),
        .pattern_data   (pattern_data_pivot)
    );

    camera_object_config #(
        .BASE_ADDRESS       (BASE_ADDRESS + PATTERN_BYTE_SIZE),
        `BUS_IF__FILL_PARAMS(config_port, config_port)
    ) camera_object_config (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(config_port, config_port),
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
        .aux_mask       (aux_mask)
    );

endmodule
