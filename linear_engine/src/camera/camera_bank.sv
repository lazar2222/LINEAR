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
    localparam int CAMERA_INSTANCES = DATA_WIDTH_data_port / PIXEL_WIDTH;
    localparam int SCREEN_X_WIDTH   = $clog2(SCREEN_WIDTH);
    localparam int SCREEN_Y_WIDTH   = $clog2(SCREEN_HEIGHT);
    localparam int FRAME_WIDTH      = $clog2(NUM_FRAMES);

    wire [CAMERA_INSTANCES-1:0][   PIXEL_WIDTH-1:0] pixel_data;
    wire [CAMERA_INSTANCES-1:0][SCREEN_X_WIDTH-1:0] camera_x;
    wire [CAMERA_INSTANCES-1:0][SCREEN_Y_WIDTH-1:0] camera_y;
    wire [CAMERA_INSTANCES-1:0][   FRAME_WIDTH-1:0] camera_frame;

    wire [CAMERA_INSTANCES-1:0][      WIDTH-1:0] sim_a_buffer;
    wire [CAMERA_INSTANCES-1:0][      WIDTH-1:0] sim_b_buffer;
    wire [CAMERA_INSTANCES-1:0][      WIDTH-1:0] sim_c_buffer;
    wire [CAMERA_INSTANCES-1:0][      WIDTH-1:0] world_x;
    wire [CAMERA_INSTANCES-1:0][      WIDTH-1:0] world_y;
    wire [CAMERA_INSTANCES-1:0][PIXEL_WIDTH-1:0] aux_value;

    wire [CAMERA_INSTANCES-1:0][NUM_OBJECTS-1:0][      WIDTH-1:0] pattern_address;
    wire [CAMERA_INSTANCES-1:0][NUM_OBJECTS-1:0][PIXEL_WIDTH-1:0] pattern_data;
    wire [NUM_OBJECTS-1:0][CAMERA_INSTANCES-1:0][      WIDTH-1:0] pattern_address_pivot;
    wire [NUM_OBJECTS-1:0][CAMERA_INSTANCES-1:0][PIXEL_WIDTH-1:0] pattern_data_pivot;

    reg [NUM_OBJECTS-1:0][        WIDTH-1:0] x1;
    reg [NUM_OBJECTS-1:0][        WIDTH-1:0] y1;
    reg [NUM_OBJECTS-1:0][        WIDTH-1:0] x2;
    reg [NUM_OBJECTS-1:0][        WIDTH-1:0] y2;
    reg [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] patch_size_x;
    reg [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] patch_size_y;
    reg [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] pattern_size_x;
    reg [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] pattern_size_y;
    reg [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] aux_shift;
    reg [NUM_OBJECTS-1:0]                    aux_shiftd;
    reg [NUM_OBJECTS-1:0][  PIXEL_WIDTH-1:0] aux_min;
    reg [NUM_OBJECTS-1:0][  PIXEL_WIDTH-1:0] aux_max;
    reg [NUM_OBJECTS-1:0][  PIXEL_WIDTH-1:0] aux_mask;

    reg [              1:0] x_channel;
    reg [              1:0] y_channel;
    reg [              1:0] a_channel;
    reg [$clog2(WIDTH)-1:0] x_shamt;
    reg [$clog2(WIDTH)-1:0] y_shamt;
    reg [$clog2(WIDTH)-1:0] a_shamt;
    reg                     x_shiftd;
    reg                     y_shiftd;
    reg                     a_shiftd;
    reg [        WIDTH-1:0] x_offset;
    reg [        WIDTH-1:0] y_offset;
    reg [        WIDTH-1:0] a_offset;

    camera_global_config #(
        .BASE_ADDRESS       (CONFIG_BASE_ADDRESS + NUM_OBJECTS * PATTERN_SIZE + NUM_OBJECTS * 8),
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

    genvar i,j;
    generate
        for (i = 0; i < NUM_OBJECTS; i++) begin : g_camera_pivot_objects
            for (j = 0; j < CAMERA_INSTANCES; j++) begin : g_camera_pivot_instances
                assign pattern_address_pivot[i][j] = pattern_address[j][i];
                assign pattern_data[j][i]          = pattern_data_pivot[i][j];
            end
        end

        for (i = 0; i < NUM_OBJECTS; i++) begin : g_camera_objects
            camera_pattern_bank #(
                .WIDTH              (WIDTH),
                .PIXEL_WIDTH        (PIXEL_WIDTH),
                .PATTERN_SIZE       (PATTERN_SIZE),
                .CAMERA_INSTANCES   (CAMERA_INSTANCES),
                .BASE_ADDRESS       (CONFIG_BASE_ADDRESS + i * PATTERN_SIZE),
                `BUS_IF__FILL_PARAMS(write_port, config_port)
            ) camera_pattern_bank (
                .clk            (clk),
                .rst            (rst),
                `BUS_IF__CONNECT(write_port, config_port),
                .pattern_address(pattern_address_pivot[i]),
                .pattern_data   (pattern_data_pivot[i])
            );

            camera_object_config #(
                .BASE_ADDRESS       (CONFIG_BASE_ADDRESS + NUM_OBJECTS * PATTERN_SIZE + i * 8),
                `BUS_IF__FILL_PARAMS(config_port, config_port)
            ) camera_object_config (
                .clk            (clk),
                .rst            (rst),
                `BUS_IF__CONNECT(config_port, config_port),
                .x1             (x1[i]),
                .y1             (y1[i]),
                .x2             (x2[i]),
                .y2             (y2[i]),
                .patch_size_x   (patch_size_x[i]),
                .patch_size_y   (patch_size_y[i]),
                .pattern_size_x (pattern_size_x[i]),
                .pattern_size_y (pattern_size_y[i]),
                .aux_shift      (aux_shift[i]),
                .aux_shiftd     (aux_shiftd[i]),
                .aux_min        (aux_min[i]),
                .aux_max        (aux_max[i]),
                .aux_mask       (aux_mask[i])
            );
        end

        for (i = 0; i < CAMERA_INSTANCES; i++) begin : g_camera_instances
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
                .read_address(camera_frame[i]),
                .sim_a_buffer(sim_a_buffer[i]),
                .sim_b_buffer(sim_b_buffer[i]),
                .sim_c_buffer(sim_c_buffer[i])
            );

            camera_coordinate_transformer #(
                .WIDTH      (WIDTH),
                .PIXEL_WIDTH(PIXEL_WIDTH)
            ) camera_coordinate_transformer (
                .sim_a    (sim_a_buffer[i]),
                .sim_b    (sim_b_buffer[i]),
                .sim_c    (sim_c_buffer[i]),
                .camera_x (camera_x[i]),
                .camera_y (camera_y[i]),
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
                .world_x  (world_x[i]),
                .world_y  (world_y[i]),
                .aux_value(aux_value[i])
            );

            camera_block #(
                .NUM_OBJECTS(NUM_OBJECTS),
                .WIDTH      (WIDTH),
                .PIXEL_WIDTH(PIXEL_WIDTH)
            ) (
                .clk            (clk),
                .rst            (rst),
                .world_x        (world_x[i]),
                .world_y        (world_y[i]),
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
                .pattern_address(pattern_address[i]),
                .pattern_data   (pattern_data[i]),
                .aux_value      (aux_value[i]),
                .data           (pixel_data[i])
            );
        end
    endgenerate

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
