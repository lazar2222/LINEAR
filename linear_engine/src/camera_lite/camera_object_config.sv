`include "../interfaces/bus_if.svh"

module camera_object_config #(
    parameter int BASE_ADDRESS,
    parameter int WIDTH,
    parameter int PIXEL_WIDTH,
    `BUS_IF__PARAMS(config_port)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(config_port),

    output [        WIDTH-1:0] x1,
    output [        WIDTH-1:0] y1,
    output [        WIDTH-1:0] x2,
    output [        WIDTH-1:0] y2,
    output [$clog2(WIDTH)-1:0] patch_size_x,
    output [$clog2(WIDTH)-1:0] patch_size_y,
    output [  PIXEL_WIDTH-1:0] aux_min,
    output [  PIXEL_WIDTH-1:0] aux_max
);
    localparam int SIZE_WORDS = 8;
    localparam int DATA_WIDTH = DATA_WIDTH_config_port;

    wire [SIZE_WORDS*DATA_WIDTH-1:0] memory;
    wire [           DATA_WIDTH-1:0] write_data;
    wire [           SIZE_WORDS-1:0] write;

    reg [        WIDTH-1:0] x1_reg;
    reg [        WIDTH-1:0] y1_reg;
    reg [        WIDTH-1:0] x2_reg;
    reg [        WIDTH-1:0] y2_reg;
    reg [$clog2(WIDTH)-1:0] patch_size_x_reg;
    reg [$clog2(WIDTH)-1:0] patch_size_y_reg;
    reg [  PIXEL_WIDTH-1:0] aux_min_reg;
    reg [  PIXEL_WIDTH-1:0] aux_max_reg;

    wire [DATA_WIDTH-1:0] conf = {patch_size_y_reg, patch_size_x_reg};

    assign memory = {aux_max_reg, aux_min_reg, conf, y2_reg, x2_reg, y1_reg, x1_reg};

    assign x1           = x1_reg;
    assign y1           = y1_reg;
    assign x2           = x2_reg;
    assign y2           = y2_reg;
    assign patch_size_x = patch_size_x_reg;
    assign patch_size_y = patch_size_y_reg;
    assign aux_min      = aux_min_reg;
    assign aux_max      = aux_max_reg;

    always @(posedge clk) begin
        if (write[0]) begin
            x1_reg <= write_data[0*WIDTH+:WIDTH];
        end
        if (write[1]) begin
            x2_reg <= write_data[0*WIDTH+:WIDTH];
        end
		  if (write[5]) begin
            y1_reg <= write_data[0*WIDTH+:WIDTH];
        end
        if (write[6]) begin
            y2_reg <= write_data[0*WIDTH+:WIDTH];
        end
        if (write[2]) begin
            patch_size_x_reg <= write_data[$clog2(WIDTH)*0+:$clog2(WIDTH)];
            patch_size_y_reg <= write_data[$clog2(WIDTH)*1+:$clog2(WIDTH)];
        end
        if (write[3]) begin
            aux_min_reg <= write_data;
        end
        if (write[4]) begin
            aux_max_reg <= write_data;
        end
        if (rst) begin
            x1_reg           <= '0;
            y1_reg           <= '0;
            x2_reg           <= '0;
            y2_reg           <= '0;
            patch_size_x_reg <= '0;
            patch_size_y_reg <= '0;
            aux_min_reg      <= '0;
            aux_max_reg      <= '0;
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
