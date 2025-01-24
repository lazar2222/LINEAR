`include "../interfaces/bus_if.svh"

module camera_bank #(
    parameter int FRAME_BASE_ADDRESS,
    parameter int CONFIG_BASE_ADDRESS,
    parameter int PIXEL_WIDTH,
    parameter int SCREEN_WIDTH,
    parameter int SCREEN_HEIGHT,
    parameter int NUM_FRAMES,
    parameter int NUM_OBJECTS,
    parameter int WIDTH,
    parameter int PATTERN_SIZE,
    `BUS_IF__PARAMS(data_port),
    `BUS_IF__PARAMS(config_port)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(data_port),
    `BUS_IF__SLAVE_PORTS(config_port),

    input strobe,

    input [WIDTH-1:0] sim_a,
    input [WIDTH-1:0] sim_b,
    input [WIDTH-1:0] sim_c
);
    localparam int CAMERA_INSTANCES  = DATA_WIDTH_data_port / PIXEL_WIDTH;
    localparam int PATTERN_BYTE_SIZE = PATTERN_SIZE * PIXEL_WIDTH / BYTE_WIDTH_config_port;
    localparam int SCREEN_X_WIDTH    = $clog2(SCREEN_WIDTH);
    localparam int SCREEN_Y_WIDTH    = $clog2(SCREEN_HEIGHT);
    localparam int FRAME_WIDTH       = $clog2(NUM_FRAMES);

    wire [CAMERA_INSTANCES-1:0][   PIXEL_WIDTH-1:0] pixel_data;
    wire [CAMERA_INSTANCES-1:0][SCREEN_X_WIDTH-1:0] camera_x;
    wire [CAMERA_INSTANCES-1:0][SCREEN_Y_WIDTH-1:0] camera_y;
    wire [CAMERA_INSTANCES-1:0][   FRAME_WIDTH-1:0] camera_frame;

    wire [CAMERA_INSTANCES-1:0][NUM_OBJECTS-1:0][      WIDTH-1:0] pattern_address;
    wire [CAMERA_INSTANCES-1:0][NUM_OBJECTS-1:0][PIXEL_WIDTH-1:0] pattern_data;
    wire [NUM_OBJECTS-1:0][CAMERA_INSTANCES-1:0][      WIDTH-1:0] pattern_address_pivot;
    wire [NUM_OBJECTS-1:0][CAMERA_INSTANCES-1:0][PIXEL_WIDTH-1:0] pattern_data_pivot;

    wire [NUM_OBJECTS-1:0][        WIDTH-1:0] x1;
    wire [NUM_OBJECTS-1:0][        WIDTH-1:0] y1;
    wire [NUM_OBJECTS-1:0][        WIDTH-1:0] x2;
    wire [NUM_OBJECTS-1:0][        WIDTH-1:0] y2;
    wire [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] patch_size_x;
    wire [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] patch_size_y;
    wire [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] pattern_size_x;
    wire [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] pattern_size_y;
    wire [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] aux_shift;
    wire [NUM_OBJECTS-1:0]                    aux_shiftd;
    wire [NUM_OBJECTS-1:0][  PIXEL_WIDTH-1:0] aux_min;
    wire [NUM_OBJECTS-1:0][  PIXEL_WIDTH-1:0] aux_max;
    wire [NUM_OBJECTS-1:0][  PIXEL_WIDTH-1:0] aux_mask;

    wire [              1:0] x_channel;
    wire [              1:0] y_channel;
    wire [              1:0] a_channel;
    wire [$clog2(WIDTH)-1:0] x_shamt;
    wire [$clog2(WIDTH)-1:0] y_shamt;
    wire [$clog2(WIDTH)-1:0] a_shamt;
    wire                     x_shiftd;
    wire                     y_shiftd;
    wire                     a_shiftd;
    wire [        WIDTH-1:0] x_offset;
    wire [        WIDTH-1:0] y_offset;
    wire [        WIDTH-1:0] a_offset;

    /*my_pivot #(
        .DIM_A(CAMERA_INSTANCES),
        .DIM_B(NUM_OBJECTS),
        .WIDTH(WIDTH)
    ) pivot_pattern_address (
        .a(pattern_address),
        .b(pattern_address_pivot)
    );

    my_pivot #(
        .DIM_A(NUM_OBJECTS),
        .DIM_B(CAMERA_INSTANCES),
        .WIDTH(PIXEL_WIDTH)
    ) pivot_pattern_data (
        .a(pattern_data_pivot),
        .b(pattern_data)
    );*/

    genvar i, j;
    generate
        for (i = 0; i < CAMERA_INSTANCES; i++) begin : g_i
            for (j = 0; j < NUM_OBJECTS; j++) begin : g_j
                assign pattern_address_pivot[j][i] = pattern_address[i][j];
                assign pattern_data[i][j] = pattern_data_pivot[j][i];
            end
        end
    endgenerate

    camera_instance_block #(
        .PIXEL_WIDTH     (PIXEL_WIDTH),
        .NUM_FRAMES      (NUM_FRAMES),
        .NUM_OBJECTS     (NUM_OBJECTS),
        .WIDTH           (WIDTH),
        .CAMERA_INSTANCES(CAMERA_INSTANCES)
    ) camera_instance_block (
        .clk            (clk),
        .rst            (rst),
        .sim_a          (sim_a),
        .sim_b          (sim_b),
        .sim_c          (sim_c),
        .strobe         (strobe),
        .camera_frame   (camera_frame),
        .camera_x       (camera_x),
        .camera_y       (camera_y),
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
        .pattern_address(pattern_address),
        .pattern_data   (pattern_data),
        .data           (pixel_data)
    );

    camera_pattern_config #(
        .BASE_ADDRESS       (CONFIG_BASE_ADDRESS),
        .PIXEL_WIDTH        (PIXEL_WIDTH),
        .NUM_OBJECTS        (NUM_OBJECTS),
        .WIDTH              (WIDTH),
        .PATTERN_BYTE_SIZE  (PATTERN_BYTE_SIZE),
        .CAMERA_INSTANCES   (CAMERA_INSTANCES),
        `BUS_IF__FILL_PARAMS(config_port, config_port)
    ) camera_pattern_config (
        .clk                  (clk),
        .rst                  (rst),
        `BUS_IF__CONNECT      (config_port, config_port),
        .pattern_address_pivot(pattern_address_pivot),
        .pattern_data_pivot   (pattern_data_pivot),
        .x1                   (x1),
        .y1                   (y1),
        .x2                   (x2),
        .y2                   (y2),
        .patch_size_x         (patch_size_x),
        .patch_size_y         (patch_size_y),
        .pattern_size_x       (pattern_size_x),
        .pattern_size_y       (pattern_size_y),
        .aux_shift            (aux_shift),
        .aux_shiftd           (aux_shiftd),
        .aux_min              (aux_min),
        .aux_max              (aux_max),
        .aux_mask             (aux_mask)
    );

    camera_global_config #(
        .BASE_ADDRESS       (CONFIG_BASE_ADDRESS + NUM_OBJECTS * PATTERN_BYTE_SIZE * 2),
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

    camera_mem_interface #(
        .BASE_ADDRESS       (FRAME_BASE_ADDRESS),
        .PIXEL_WIDTH        (PIXEL_WIDTH),
        .SCREEN_WIDTH       (SCREEN_WIDTH),
        .SCREEN_HEIGHT      (SCREEN_HEIGHT),
        .NUM_FRAMES         (NUM_FRAMES),
        `BUS_IF__FILL_PARAMS(port, data_port)
    ) camera_mem_interface (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(port, data_port),
        .data_in        (pixel_data),
        .camera_x       (camera_x),
        .camera_y       (camera_y),
        .camera_frame   (camera_frame)
    );

endmodule
