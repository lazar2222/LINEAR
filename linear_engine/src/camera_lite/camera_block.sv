`include "../interfaces/bus_if.svh"

module camera_block #(
    parameter int NUM_OBJECTS,
    parameter int WIDTH,
    parameter int PIXEL_WIDTH,
    parameter int PATTERN_SIZE,
    parameter int BASE_ADDRESS,
    `BUS_IF__PARAMS(config_port)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(config_port),

    input strobe,

    input [WIDTH-1:0] sim_a,
    input [WIDTH-1:0] sim_b,
    input [WIDTH-1:0] sim_c,

    input [WIDTH-1:0] camera_x,
    input [WIDTH-1:0] camera_y,

    output [PIXEL_WIDTH-1:0] data,

    output done
);
    localparam int PATTERN_BYTE_SIZE = PATTERN_SIZE * PATTERN_SIZE * PIXEL_WIDTH / BYTE_WIDTH_config_port;

    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] fill_x;
    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] fill_y;
    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] pattern_address;
    wire [NUM_OBJECTS-1:0][PIXEL_WIDTH-1:0] pattern_data;
    wire [NUM_OBJECTS-1:0][PIXEL_WIDTH-1:0] samples;
    wire [NUM_OBJECTS-1:0]                  visible;
    
    wire [              1:0] x_channel;
    wire [              1:0] y_channel;
    wire [              1:0] a_channel;
    wire [$clog2(WIDTH)-1:0] x_shamt;
    wire [$clog2(WIDTH)-1:0] y_shamt;
    wire [$clog2(WIDTH)-1:0] a_shamt;
    wire [        WIDTH-1:0] x_offset;
    wire [        WIDTH-1:0] y_offset;
    wire [        WIDTH-1:0] a_offset;
    
    wire [NUM_OBJECTS-1:0][        WIDTH-1:0] x1;
    wire [NUM_OBJECTS-1:0][        WIDTH-1:0] y1;
    wire [NUM_OBJECTS-1:0][        WIDTH-1:0] x2;
    wire [NUM_OBJECTS-1:0][        WIDTH-1:0] y2;
    wire [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] patch_size_x;
    wire [NUM_OBJECTS-1:0][$clog2(WIDTH)-1:0] patch_size_y;
    wire [NUM_OBJECTS-1:0][  PIXEL_WIDTH-1:0] aux_min;
    wire [NUM_OBJECTS-1:0][  PIXEL_WIDTH-1:0] aux_max;
    
    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] sim_x;
    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] sim_y;
    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] aux_value;
    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] ss_x1;
    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] ss_y1;
    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] ss_x2;
    wire [NUM_OBJECTS-1:0][      WIDTH-1:0] ss_y2;
    wire [NUM_OBJECTS-1:0][PIXEL_WIDTH-1:0] data_min;
    wire [NUM_OBJECTS-1:0][PIXEL_WIDTH-1:0] data_max;

    reg [NUM_OBJECTS-1:0] visible_reg;

    always @(posedge clk) begin
        visible_reg <= visible;
        if (rst) begin
            visible_reg <= '0;
        end
    end

    genvar i;
    generate
        for (i = 0; i < NUM_OBJECTS; i++) begin : g_samples
            camera_object_config #(
                .BASE_ADDRESS (BASE_ADDRESS + i * 2 * PATTERN_BYTE_SIZE + PATTERN_BYTE_SIZE),
                .WIDTH        (WIDTH),
                .PIXEL_WIDTH  (PIXEL_WIDTH),
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
                .aux_min        (aux_min[i]),
                .aux_max        (aux_max[i])
            );

            camera_pattern_bank #(
                .WIDTH              (WIDTH),
                .PIXEL_WIDTH        (PIXEL_WIDTH),
                .PATTERN_SIZE       (PATTERN_SIZE),
                .BASE_ADDRESS       (BASE_ADDRESS + i * 2 * PATTERN_BYTE_SIZE),
                `BUS_IF__FILL_PARAMS(config_port, config_port)
            ) camera_pattern_bank (
                .clk            (clk),
                .rst            (rst),
                `BUS_IF__CONNECT(config_port, config_port),
                .pattern_address(pattern_address[i]),
                .pattern_data   (pattern_data[i])
            );

            camera_coordinate_transformer #(
                .WIDTH      (WIDTH),
                .PIXEL_WIDTH(PIXEL_WIDTH)
            ) camera_coordinate_transformer (
                .clk      (clk),
                .rst      (rst),
                .strobe   (strobe),
                .sim_a    (sim_a),
                .sim_b    (sim_b),
                .sim_c    (sim_c),
                .camera_x (camera_x),
                .camera_y (camera_y),
                .x_channel(x_channel),
                .y_channel(y_channel),
                .a_channel(a_channel),
                .x_shamt  (x_shamt),
                .y_shamt  (y_shamt),
                .a_shamt  (a_shamt),
                .x_offset (x_offset),
                .y_offset (y_offset),
                .a_offset (a_offset),
                .x1       (x1[i]),
                .y1       (y1[i]),
                .x2       (x2[i]),
                .y2       (y2[i]),
                .aux_min  (aux_min[i]),
                .aux_max  (aux_max[i]),
                .sim_x    (sim_x[i]),
                .sim_y    (sim_y[i]),
                .aux_value(aux_value[i]),
                .ss_x1    (ss_x1[i]),
                .ss_y1    (ss_y1[i]),
                .ss_x2    (ss_x2[i]),
                .ss_y2    (ss_y2[i]),
                .data_min (data_min[i]),
                .data_max (data_max[i]),
                .done     (done)
            );

            occlusion_checker #(
                .WIDTH(WIDTH)
            ) occlusion_checker (
                .world_x(camera_x),
                .world_y(camera_y),
                .x1     (ss_x1[i]),
                .y1     (ss_y1[i]),
                .x2     (ss_x2[i]),
                .y2     (ss_y2[i]),
                .fill_x (fill_x[i]),
                .fill_y (fill_y[i]),
                .visible(visible[i])
            );

            pattern_sampler #(
                .WIDTH       (WIDTH),
                .PIXEL_WIDTH (PIXEL_WIDTH),
                .PATTERN_SIZE(PATTERN_SIZE)
            ) pattern_sampler (
                .fill_x         (fill_x[i]),
                .fill_y         (fill_y[i]),
                .patch_size_x   (patch_size_x[i]),
                .patch_size_y   (patch_size_y[i]),
                .pattern_address(pattern_address[i]),
                .pattern_data   (pattern_data[i]),
                .aux_value      (aux_value[i]),
                .data_min       (data_min[i]),
                .data_max       (data_max[i]),
                .aux_min        (aux_min[i]),
                .aux_max        (aux_max[i]),
                .output_data    (samples[i])
            );
        end
    endgenerate

    camera_global_config #(
        .BASE_ADDRESS       (BASE_ADDRESS + 2 * NUM_OBJECTS * PATTERN_BYTE_SIZE),
        .WIDTH              (WIDTH),
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
        .x_offset       (x_offset),
        .y_offset       (y_offset),
        .a_offset       (a_offset)
    );

    priority_select #(
        .WIDTH(PIXEL_WIDTH),
        .COUNT(NUM_OBJECTS)
    ) priority_select (
        .values     (samples),
        .enable     (visible_reg),
        .masked     (data),
        .prio_enable(),
        .prio_sel   (),
        .prio_any   ()
    );

endmodule
