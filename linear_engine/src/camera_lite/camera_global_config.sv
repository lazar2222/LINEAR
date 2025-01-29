`include "../interfaces/bus_if.svh"

module camera_global_config #(
    parameter int BASE_ADDRESS,
    parameter int WIDTH,
    `BUS_IF__PARAMS(config_port)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(config_port),

    output [              1:0] x_channel,
    output [              1:0] y_channel,
    output [              1:0] a_channel,
    output [$clog2(WIDTH)-1:0] x_shamt,
    output [$clog2(WIDTH)-1:0] y_shamt,
    output [$clog2(WIDTH)-1:0] a_shamt,
    output [        WIDTH-1:0] x_offset,
    output [        WIDTH-1:0] y_offset,
    output [        WIDTH-1:0] a_offset
);
    localparam int SIZE_WORDS = 4;
    localparam int DATA_WIDTH = DATA_WIDTH_config_port;

    wire [SIZE_WORDS*DATA_WIDTH-1:0] memory;
    wire [           DATA_WIDTH-1:0] write_data;
    wire [           SIZE_WORDS-1:0] write;

    reg [              1:0] x_channel_reg; 
    reg [              1:0] y_channel_reg;
    reg [              1:0] a_channel_reg;
    reg [$clog2(WIDTH)-1:0] x_shamt_reg;
    reg [$clog2(WIDTH)-1:0] y_shamt_reg;
    reg [$clog2(WIDTH)-1:0] a_shamt_reg;
    reg [        WIDTH-1:0] x_offset_reg;
    reg [        WIDTH-1:0] y_offset_reg;
    reg [        WIDTH-1:0] a_offset_reg;

    wire [DATA_WIDTH-1:0] conf = {a_shamt_reg, y_shamt_reg, x_shamt_reg, a_channel_reg, y_channel_reg, x_channel_reg};

    assign memory = {a_offset_reg, 16'd0, y_offset_reg, 16'd0, x_offset_reg, conf};

    assign x_channel = x_channel_reg;
    assign y_channel = y_channel_reg;
    assign a_channel = a_channel_reg;
    assign x_shamt   = x_shamt_reg;
    assign y_shamt   = y_shamt_reg;
    assign a_shamt   = a_shamt_reg;
    assign x_offset  = x_offset_reg;
    assign y_offset  = y_offset_reg;
    assign a_offset  = a_offset_reg;

    always @(posedge clk) begin
        if (write[0]) begin
            a_channel_reg <= write_data[0+:2];
            y_channel_reg <= write_data[2+:2];
            x_channel_reg <= write_data[4+:2];
            x_shamt_reg   <= write_data[6+$clog2(WIDTH)*0+:$clog2(WIDTH)];
            y_shamt_reg   <= write_data[6+$clog2(WIDTH)*1+:$clog2(WIDTH)];
            a_shamt_reg   <= write_data[6+$clog2(WIDTH)*2+:$clog2(WIDTH)];
        end
        if (write[1]) begin
            x_offset_reg <= write_data;
        end
        if (write[2]) begin
            y_offset_reg <= write_data;
        end
        if (write[3]) begin
            a_offset_reg <= write_data;
        end
        if (rst) begin
            x_channel_reg <= '0;
            y_channel_reg <= '0;
            a_channel_reg <= '0;
            x_shamt_reg   <= '0;
            y_shamt_reg   <= '0;
            a_shamt_reg   <= '0;
            x_offset_reg  <= '0;
            y_offset_reg  <= '0;
            a_offset_reg  <= '0;
        end
    end

    periph_mem_interface #(
        .BASE_ADDRESS       (BASE_ADDRESS),
        .SIZE_WORDS         (SIZE_WORDS),
        `BUS_IF__FILL_PARAMS(port, config_port)
    ) periph_mem_interface_inst (
        .clk              (clk),
        .rst              (rst),
        `BUS_IF__CONNECT  (port, config_port),
        .data_periph_in   (memory),
        .data_periph_out  (write_data),
        .data_periph_write(write)
    );

endmodule
