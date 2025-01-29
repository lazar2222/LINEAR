`include "../interfaces/bus_if.svh"

module camera_bank #(
    parameter int FRAME_BASE_ADDRESS,
    parameter int CONFIG_BASE_ADDRESS,
    parameter int PIXEL_WIDTH,
    parameter int SCREEN_WIDTH,
    parameter int SCREEN_HEIGHT,
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
    input [WIDTH-1:0] sim_c,

    output done,
    output shadow_error
);
    localparam int CAMERA_INSTANCES  = DATA_WIDTH_data_port / PIXEL_WIDTH;

    wire [CAMERA_INSTANCES-1:0][PIXEL_WIDTH-1:0] pixel_data;
    wire [CAMERA_INSTANCES-1:0][      WIDTH-1:0] camera_x;
    wire [CAMERA_INSTANCES-1:0][      WIDTH-1:0] camera_y;

    wire [CAMERA_INSTANCES-1:0] shadow_errors;
    wire [CAMERA_INSTANCES-1:0] dones;

    assign done = &dones;

    assign shadow_errors[0] = '0;
    assign shadow_error     = |shadow_errors;

    genvar i;
    generate
        for (i = 1; i < CAMERA_INSTANCES; i = i + 1) begin : g_camera_block
            `BUS_IF__(shadow_config, DATA_WIDTH_config_port, BYTE_ADDRESS_WIDTH_config_port, BYTE_WIDTH_config_port)

            assign shadow_config_data_ctp    = config_port_data_ctp;
            assign shadow_config_address     = config_port_address;
            assign shadow_config_byte_enable = config_port_byte_enable;
            assign shadow_config_read        = config_port_read;
            assign shadow_config_write       = config_port_write;

            wire ptc_error = config_port_data_ptc    != shadow_config_data_ptc;
            wire ha_error  = config_port_hit_address != shadow_config_hit_address;
            wire hm_error  = config_port_hit_mask    != shadow_config_hit_mask;
            wire h_error   = config_port_hit         != shadow_config_hit;
            wire c_error   = config_port_complete    != shadow_config_complete;
            wire e_error   = config_port_error       != shadow_config_error;
        
            assign shadow_errors[i] = ptc_error || ha_error || hm_error || h_error || c_error || e_error;

            camera_block #(
                .NUM_OBJECTS    (NUM_OBJECTS),
                .WIDTH          (WIDTH),
                .PIXEL_WIDTH    (PIXEL_WIDTH),
                .PATTERN_SIZE   (PATTERN_SIZE),
                .BASE_ADDRESS   (CONFIG_BASE_ADDRESS),
                `BUS_IF__FILL_PARAMS(config_port, shadow_config)
            ) camera_block (
                .clk        (clk),
                .rst        (rst),
                `BUS_IF__CONNECT(config_port, shadow_config),
                .strobe     (strobe),
                .sim_a      (sim_a),
                .sim_b      (sim_b),
                .sim_c      (sim_c),
                .camera_x   (camera_x[i]),
                .camera_y   (camera_y[i]),
                .data       (pixel_data[i]),
                .done       (dones[i])
            );
        end
    endgenerate

    camera_block #(
        .NUM_OBJECTS    (NUM_OBJECTS),
        .WIDTH          (WIDTH),
        .PIXEL_WIDTH    (PIXEL_WIDTH),
        .PATTERN_SIZE   (PATTERN_SIZE),
        .BASE_ADDRESS   (CONFIG_BASE_ADDRESS),
        `BUS_IF__FILL_PARAMS(config_port, config_port)
    ) camera_block (
        .clk        (clk),
        .rst        (rst),
        `BUS_IF__CONNECT(config_port, config_port),
        .strobe     (strobe),
        .sim_a      (sim_a),
        .sim_b      (sim_b),
        .sim_c      (sim_c),
        .camera_x   (camera_x[0]),
        .camera_y   (camera_y[0]),
        .data       (pixel_data[0]),
        .done       (dones[0])
    );

    camera_mem_interface #(
        .BASE_ADDRESS       (FRAME_BASE_ADDRESS),
        .PIXEL_WIDTH        (PIXEL_WIDTH),
        .SCREEN_WIDTH       (SCREEN_WIDTH),
        .SCREEN_HEIGHT      (SCREEN_HEIGHT),
        .WIDTH              (WIDTH),
        `BUS_IF__FILL_PARAMS(port, data_port)
    ) camera_mem_interface (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(port, data_port),
        .data_in        (pixel_data),
        .camera_x       (camera_x),
        .camera_y       (camera_y)
    );

endmodule
