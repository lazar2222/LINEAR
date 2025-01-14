`include "../interfaces/parallel_if.svh"

module spi_rx #(
    `PARALLEL_IF__UNI_PARAMS(parallel_tx)
) (
    input clk,
    input rst,

    input spi_clk,
    input spi_mosi,

    `PARALLEL_IF__UNI_TX_PORTS(parallel_tx)
);
    localparam int DATA_WIDTH    = DATA_WIDTH_parallel_tx;
    localparam int COUNTER_WIDTH = $clog2(DATA_WIDTH);

    reg [   DATA_WIDTH-1:0] data_reg;
    reg [COUNTER_WIDTH-1:0] counter;

    reg valid_reg;
    reg spi_clk_d1, spi_clk_d2;
    reg spi_mosi_d1, spi_mosi_d2;

    wire spi_clk_edge = spi_clk_d2 & !spi_clk_d1;

    assign parallel_tx_data  = data_reg;
    assign parallel_tx_valid = valid_reg;

    always @(posedge clk) begin
        spi_clk_d2  <= spi_clk_d1;
        spi_clk_d1  <= spi_clk;
        spi_mosi_d2 <= spi_mosi_d1;
        spi_mosi_d1 <= spi_mosi;
        if (spi_clk_edge) begin
            counter  <= counter + 1'd1;
            data_reg <= {spi_mosi_d2, data_reg[DATA_WIDTH-1:1]};
            if (counter == DATA_WIDTH - 1'd1) begin
                valid_reg <= '1;
                counter   <= '0;
            end
        end
        if (valid_reg) begin
            valid_reg <= '0;
        end
        if (rst) begin
            data_reg    <= '0;
            counter     <= '0;
            spi_clk_d1  <= '0;
            spi_clk_d2  <= '0;
            spi_mosi_d1 <= '0;
            spi_mosi_d2 <= '0;
            valid_reg   <= '0;
        end
    end

endmodule
