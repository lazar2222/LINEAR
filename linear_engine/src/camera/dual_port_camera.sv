`include "../interfaces/bus_if.svh"

module dual_port_camera #(
    parameter int FRAME_BASE_ADDRESS,
    parameter int CONFIG_BASE_ADDRESS,
    parameter int PIXEL_WIDTH,
    parameter int SCREEN_WIDTH,
    parameter int SCREEN_HEIGHT,
    parameter int NUM_FRAMES,
    parameter int NUM_OBJECTS,
    parameter int WIDTH,
    parameter int PATTERN_SIZE,
    `BUS_IF__PARAMS(data_port_a),
    `BUS_IF__PARAMS(data_port_b),
    `BUS_IF__PARAMS(config_port)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(data_port_a),
    `BUS_IF__SLAVE_PORTS(data_port_b),
    `BUS_IF__SLAVE_PORTS(config_port),

    input strobe,

    input [WIDTH-1:0] sim_a,
    input [WIDTH-1:0] sim_b,
    input [WIDTH-1:0] sim_c,

    output shadow_error
);
    `BUS_IF__(config_port_a, DATA_WIDTH_config_port, BYTE_ADDRESS_WIDTH_config_port, BYTE_WIDTH_config_port)
    `BUS_IF__(config_port_b, DATA_WIDTH_config_port, BYTE_ADDRESS_WIDTH_config_port, BYTE_WIDTH_config_port)

    bus_shadow_clone #(
        `BUS_IF__FILL_PARAMS(slave, config_port),
        `BUS_IF__FILL_PARAMS(master_a, config_port_a),
        `BUS_IF__FILL_PARAMS(master_b, config_port_b)
    ) bus_shadow_clone (
        `BUS_IF__CONNECT(slave, config_port),
        `BUS_IF__CONNECT(master_a, config_port_a),
        `BUS_IF__CONNECT(master_b, config_port_b),
        .error(shadow_error)
    );

    camera_bank #(
        .FRAME_BASE_ADDRESS (FRAME_BASE_ADDRESS),
        .CONFIG_BASE_ADDRESS(CONFIG_BASE_ADDRESS),
        .PIXEL_WIDTH        (PIXEL_WIDTH),
        .SCREEN_WIDTH       (SCREEN_WIDTH),
        .SCREEN_HEIGHT      (SCREEN_HEIGHT),
        .NUM_FRAMES         (NUM_FRAMES),
        .NUM_OBJECTS        (NUM_OBJECTS),
        .WIDTH              (WIDTH),
        .PATTERN_SIZE       (PATTERN_SIZE),
        `BUS_IF__FILL_PARAMS(data_port, data_port_a),
        `BUS_IF__FILL_PARAMS(config_port, config_port_a)
    ) camera_bank_a (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(data_port, data_port_a),
        `BUS_IF__CONNECT(config_port, config_port_a),
        .strobe         (strobe),
        .sim_a          (sim_a),
        .sim_b          (sim_b),
        .sim_c          (sim_c)
    );

    camera_bank #(
        .FRAME_BASE_ADDRESS (FRAME_BASE_ADDRESS),
        .CONFIG_BASE_ADDRESS(CONFIG_BASE_ADDRESS),
        .PIXEL_WIDTH        (PIXEL_WIDTH),
        .SCREEN_WIDTH       (SCREEN_WIDTH),
        .SCREEN_HEIGHT      (SCREEN_HEIGHT),
        .NUM_FRAMES         (NUM_FRAMES),
        .NUM_OBJECTS        (NUM_OBJECTS),
        .WIDTH              (WIDTH),
        .PATTERN_SIZE       (PATTERN_SIZE),
        `BUS_IF__FILL_PARAMS(data_port, data_port_b),
        `BUS_IF__FILL_PARAMS(config_port, config_port_b)
    ) camera_bank_b (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(data_port, data_port_b),
        `BUS_IF__CONNECT(config_port, config_port_b),
        .strobe         (strobe),
        .sim_a          (sim_a),
        .sim_b          (sim_b),
        .sim_c          (sim_c)
    );

endmodule
