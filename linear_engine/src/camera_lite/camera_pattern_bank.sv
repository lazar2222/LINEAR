`include "../interfaces/bus_if.svh"

module camera_pattern_bank #(
    parameter int WIDTH,
    parameter int PIXEL_WIDTH,
    parameter int PATTERN_SIZE,
    parameter int BASE_ADDRESS,
    `BUS_IF__PARAMS(config_port)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(config_port),

    input  [      WIDTH-1:0] pattern_address,
    output [PIXEL_WIDTH-1:0] pattern_data
);
    localparam int BYTE_WIDTH        = BYTE_WIDTH_config_port;
    localparam int PATTERN_BYTE_SIZE = PATTERN_SIZE * PATTERN_SIZE * PIXEL_WIDTH / BYTE_WIDTH;

    `BUS_IF__(config_port_f, PIXEL_WIDTH, BYTE_ADDRESS_WIDTH_config_port, BYTE_WIDTH)
    `BUS_IF__(read_port,    PIXEL_WIDTH, BYTE_ADDRESS_WIDTH_config_port, BYTE_WIDTH)

    assign read_port_data_ctp    = '0;
    assign read_port_address     = pattern_address;
    assign read_port_byte_enable = '0;
    assign read_port_read        = '1;
    assign read_port_write       = '0;

    assign pattern_data = read_port_data_ptc;

    bus_filter #(
        .BASE_ADDRESS       (BASE_ADDRESS),
        .SIZE_BYTES         (PATTERN_BYTE_SIZE),
        `BUS_IF__FILL_PARAMS(slave,  config_port),
        `BUS_IF__FILL_PARAMS(master, config_port_f)
    ) bus_filter (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(slave,  config_port),
        `BUS_IF__CONNECT(master, config_port_f)
    );

    mem_bank #(
        .BASE_ADDRESS       (0),
        .SIZE_BYTES         (PATTERN_BYTE_SIZE),
        .INIT_FILE          (""),
        `BUS_IF__FILL_PARAMS(port_a, read_port),
        `BUS_IF__FILL_PARAMS(port_b, config_port_f)
    ) mem_bank_a (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(port_a, read_port),
        `BUS_IF__CONNECT(port_b, config_port_f)
    );

endmodule
