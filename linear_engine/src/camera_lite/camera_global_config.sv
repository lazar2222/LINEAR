`include "../interfaces/bus_if.svh"

module camera_global_config #(
    parameter int BASE_ADDRESS,
    parameter int WIDTH,
    `BUS_IF__PARAMS(config_port)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(config_port),

    output strobe,

    output [WIDTH-1:0] sim_x,
    output [WIDTH-1:0] sim_y,
    output [WIDTH-1:0] aux_value
);
    localparam int SIZE_WORDS = 4;
    localparam int DATA_WIDTH = DATA_WIDTH_config_port;

    wire [SIZE_WORDS*DATA_WIDTH-1:0] memory;
    wire [           DATA_WIDTH-1:0] write_data;
    wire [           SIZE_WORDS-1:0] write;

    reg [DATA_WIDTH-1:0] sim_x_reg;
    reg [DATA_WIDTH-1:0] sim_y_reg;
    reg [DATA_WIDTH-1:0] aux_value_reg;

    reg [DATA_WIDTH-1:0] sim_x_store;
    reg [DATA_WIDTH-1:0] sim_y_store;
    reg [DATA_WIDTH-1:0] aux_value_store;

    assign memory = {aux_value_reg, sim_y_reg, sim_x_reg};

    assign sim_x     = sim_x_store;
    assign sim_y     = sim_y_store;
    assign aux_value = aux_value_store;
    
    assign strobe = write[3];

    always @(posedge clk) begin
        if (write[0]) begin
            sim_x_reg <= write_data;
        end
        if (write[1]) begin
            sim_y_reg <= write_data;
        end
        if (write[2]) begin
            aux_value_reg <= write_data;
        end
        if (strobe) begin
            sim_x_store     <= sim_x_reg;
            sim_y_store     <= sim_y_reg;
            aux_value_store <= aux_value_reg;
        end
        if (rst) begin
            sim_x_reg       <= 0;
            sim_y_reg       <= 0;
            aux_value_reg   <= 0;
            sim_x_store     <= 0;
            sim_y_store     <= 0;
            aux_value_store <= 0;    
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
