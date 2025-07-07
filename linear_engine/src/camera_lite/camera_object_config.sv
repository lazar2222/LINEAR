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

    input strobe,

    output [        WIDTH-1:0] x1,
    output [        WIDTH-1:0] y1,
    output [        WIDTH-1:0] x2,
    output [        WIDTH-1:0] y2,
    output [$clog2(WIDTH)-1:0] patch_size_x,
    output [$clog2(WIDTH)-1:0] patch_size_y,
    output [  PIXEL_WIDTH-1:0] data_min,
    output [  PIXEL_WIDTH-1:0] data_max,
    output [  PIXEL_WIDTH-1:0] aux_min,
    output [  PIXEL_WIDTH-1:0] aux_max
);
    localparam int SIZE_WORDS = 16;
    localparam int DATA_WIDTH = DATA_WIDTH_config_port;

    wire [SIZE_WORDS*DATA_WIDTH-1:0] memory;
    wire [           DATA_WIDTH-1:0] write_data;
    wire [           SIZE_WORDS-1:0] write;

    reg [DATA_WIDTH-1:0] x1_reg;
    reg [DATA_WIDTH-1:0] y1_reg;
    reg [DATA_WIDTH-1:0] x2_reg;
    reg [DATA_WIDTH-1:0] y2_reg;
    reg [DATA_WIDTH-1:0] patch_size_x_reg;
    reg [DATA_WIDTH-1:0] patch_size_y_reg;
    reg [DATA_WIDTH-1:0] data_min_reg;
    reg [DATA_WIDTH-1:0] data_max_reg;
    reg [DATA_WIDTH-1:0] aux_min_reg;
    reg [DATA_WIDTH-1:0] aux_max_reg;

    reg [DATA_WIDTH-1:0] x1_store;
    reg [DATA_WIDTH-1:0] y1_store;
    reg [DATA_WIDTH-1:0] x2_store;
    reg [DATA_WIDTH-1:0] y2_store;
    reg [DATA_WIDTH-1:0] patch_size_x_store;
    reg [DATA_WIDTH-1:0] patch_size_y_store;
    reg [DATA_WIDTH-1:0] data_min_store;
    reg [DATA_WIDTH-1:0] data_max_store;
    reg [DATA_WIDTH-1:0] aux_min_store;
    reg [DATA_WIDTH-1:0] aux_max_store;

    assign memory = {aux_max_reg, aux_min_reg, data_max_reg, data_min_reg, patch_size_y_reg, patch_size_x_reg, y2_reg, x2_reg, y1_reg, x1_reg};

    assign x1           = x1_store;
    assign y1           = y1_store;
    assign x2           = x2_store;
    assign y2           = y2_store;
    assign patch_size_x = patch_size_x_store;
    assign patch_size_y = patch_size_y_store;
    assign data_min     = data_min_store;
    assign data_max     = data_max_store;
    assign aux_min      = aux_min_store;
    assign aux_max      = aux_max_store;

    always @(posedge clk) begin
        if (write[0]) begin
            x1_reg <= write_data;
        end
        if (write[1]) begin
            y1_reg <= write_data;
        end
        if (write[2]) begin
            x2_reg <= write_data;
        end
        if (write[3]) begin
            y2_reg <= write_data;
        end
        if (write[4]) begin
            patch_size_x_reg <= write_data;
        end
        if (write[5]) begin
            patch_size_y_reg <= write_data;
        end
        if (write[6]) begin
            data_min_reg <= write_data;
        end
        if (write[7]) begin
            data_max_reg <= write_data;
        end
        if (write[8]) begin
            aux_min_reg <= write_data;
        end
        if (write[9]) begin
            aux_max_reg <= write_data;
        end
        if (strobe) begin
            x1_store           <= x1_reg;
            y1_store           <= y1_reg;
            x2_store           <= x2_reg;
            y2_store           <= y2_reg;
            patch_size_x_store <= patch_size_x_reg;
            patch_size_y_store <= patch_size_y_reg;
            data_min_store     <= data_min_reg;
            data_max_store     <= data_max_reg;
            aux_min_store      <= aux_min_reg;
            aux_max_store      <= aux_max_reg;
        end
        if (rst) begin
            x1_reg             <= '0;
            y1_reg             <= '0;
            x2_reg             <= '0;
            y2_reg             <= '0;
            patch_size_x_reg   <= '0;
            patch_size_y_reg   <= '0;
            data_min_reg       <= '0;
            data_max_reg       <= '0;
            aux_min_reg        <= '0;
            aux_max_reg        <= '0;
            x1_store           <= '0;
            y1_store           <= '0;
            x2_store           <= '0;
            y2_store           <= '0;
            patch_size_x_store <= '0;
            patch_size_y_store <= '0;
            data_min_store     <= '0;
            data_max_store     <= '0;
            aux_min_store      <= '0;
            aux_max_store      <= '0;
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
