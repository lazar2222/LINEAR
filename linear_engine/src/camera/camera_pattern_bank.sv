`include "../interfaces/bus_if.svh"

module camera_pattern_bank #(
    parameter int WIDTH,
    parameter int PIXEL_WIDTH,
    parameter int PATTERN_BYTE_SIZE,
    parameter int CAMERA_INSTANCES,
    parameter int BASE_ADDRESS,
    `BUS_IF__PARAMS(write_port)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(write_port),

    input  [CAMERA_INSTANCES-1:0][      WIDTH-1:0] pattern_address,
    output [CAMERA_INSTANCES-1:0][PIXEL_WIDTH-1:0] pattern_data
);
    localparam int BYTE_WIDTH        = BYTE_WIDTH_write_port;
    localparam int BANK_DATA_WIDTH   = PIXEL_WIDTH * CAMERA_INSTANCES;

    `BUS_IF__(write_port_f, DATA_WIDTH_write_port, BYTE_ADDRESS_WIDTH_write_port, BYTE_WIDTH)
    `BUS_IF__(write_port_w, BANK_DATA_WIDTH,       BYTE_ADDRESS_WIDTH_write_port, BYTE_WIDTH)

    `BUS_IF__(read_port_a,  BANK_DATA_WIDTH, $clog2(PATTERN_BYTE_SIZE), BYTE_WIDTH)
    `BUS_IF__(read_port_b,  BANK_DATA_WIDTH, $clog2(PATTERN_BYTE_SIZE), BYTE_WIDTH)
    `BUS_IF__(write_port_a, BANK_DATA_WIDTH, $clog2(PATTERN_BYTE_SIZE), BYTE_WIDTH)
    `BUS_IF__(write_port_b, BANK_DATA_WIDTH, $clog2(PATTERN_BYTE_SIZE), BYTE_WIDTH)

    wire [CAMERA_INSTANCES-1:0][                   WIDTH-1:0] local_address;
    wire [CAMERA_INSTANCES-1:0][$clog2(CAMERA_INSTANCES)-1:0] offset_address;
    wire [CAMERA_INSTANCES-1:0]                               bank_address;
    reg  [CAMERA_INSTANCES-1:0][$clog2(CAMERA_INSTANCES)-1:0] offset_reg;
    reg  [CAMERA_INSTANCES-1:0]                               bank_reg;

    assign read_port_a_data_ctp = '0;
    assign read_port_b_data_ctp = '0;
    assign read_port_a_address     = bank_address[0] ? local_address[CAMERA_INSTANCES-1] : local_address[0];
    assign read_port_b_address     = bank_address[0] ? local_address[0]                  : local_address[CAMERA_INSTANCES-1];
    assign read_port_a_byte_enable = '0;
    assign read_port_b_byte_enable = '0;
    assign read_port_a_read        = '1;
    assign read_port_b_read        = '1;
    assign read_port_a_write       = '0;
    assign read_port_b_write       = '0;

    genvar i;
    generate
        for (i = 0; i < CAMERA_INSTANCES; i++) begin : g_camera_instances
            assign local_address[i]  = pattern_address[i] >> ($clog2(CAMERA_INSTANCES) + 1);
            assign offset_address[i] = pattern_address[i][$clog2(CAMERA_INSTANCES):1];
            assign bank_address[i]   = pattern_address[i][0];
            assign pattern_data[i]   = (bank_reg[i] ? read_port_b_data_ptc : read_port_a_data_ptc) >> (offset_reg[i] * PIXEL_WIDTH);
        end
    endgenerate

    always @(posedge clk) begin
        offset_reg <= offset_address;
        bank_reg   <= bank_address;
        if (rst) begin
            offset_reg <= '0;
            bank_reg   <= '0;
        end
    end

    bus_filter #(
        .BASE_ADDRESS       (BASE_ADDRESS),
        .SIZE_BYTES         (PATTERN_BYTE_SIZE),
        `BUS_IF__FILL_PARAMS(slave,  write_port),
        `BUS_IF__FILL_PARAMS(master, write_port_f)
    ) bus_filter (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(slave,  write_port),
        `BUS_IF__CONNECT(master, write_port_f)
    );

    bus_adapter #(
        `BUS_IF__FILL_PARAMS(slave,  write_port_f),
        `BUS_IF__FILL_PARAMS(master, write_port_w)
    ) bus_adapter (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(slave,  write_port_f),
        `BUS_IF__CONNECT(master, write_port_w)
    );

    bus_interleaved_adapter #(
        `BUS_IF__FILL_PARAMS(slave,    write_port_w),
        `BUS_IF__FILL_PARAMS(master_a, write_port_a),
        `BUS_IF__FILL_PARAMS(master_b, write_port_b)
    ) bus_interleaved_adapter (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(slave,    write_port_w),
        `BUS_IF__CONNECT(master_a, write_port_a),
        `BUS_IF__CONNECT(master_b, write_port_b)
    );

    mem_bank #(
        .BASE_ADDRESS       (0),
        .SIZE_BYTES         (PATTERN_BYTE_SIZE/2),
        .INIT_FILE          (""),
        `BUS_IF__FILL_PARAMS(port_a, read_port_a),
        `BUS_IF__FILL_PARAMS(port_b, write_port_a)
    ) mem_bank_a (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(port_a, read_port_a),
        `BUS_IF__CONNECT(port_b, write_port_a)
    );

    mem_bank #(
        .BASE_ADDRESS       (0),
        .SIZE_BYTES         (PATTERN_BYTE_SIZE/2),
        .INIT_FILE          (""),
        `BUS_IF__FILL_PARAMS(port_a, read_port_b),
        `BUS_IF__FILL_PARAMS(port_b, write_port_b)
    ) mem_bank_b (
        .clk            (clk),
        .rst            (rst),
        `BUS_IF__CONNECT(port_a, read_port_b),
        `BUS_IF__CONNECT(port_b, write_port_b)
    );

endmodule
