`include "../interfaces/parallel_if.svh"

module spi_rx #(
    `PARALLEL_IF__UNI_PARAMS(parallel_tx)
) (
    input clk,
    input rst,

    input spi_clk,
    input spi_mosi,

    `PARALLEL_IF__UNI_TX_PORTS(parallel_tx),

    output overflow
);
    localparam int DATA_WIDTH    = DATA_WIDTH_parallel_tx;
    localparam int COUNTER_WIDTH = $clog2(DATA_WIDTH);

    reg [   DATA_WIDTH-1:0] data_reg;
    reg [COUNTER_WIDTH-1:0] counter;

    reg spi_clk_d1, spi_clk_d2;
    reg spi_mosi_d1, spi_mosi_d2;

    wire spi_clk_edge = spi_clk_d2 && !spi_clk_d1;

    assign parallel_tx_data  = {spi_mosi_d2, data_reg[DATA_WIDTH-1:1]};
    assign parallel_tx_valid = spi_clk_edge && counter == DATA_WIDTH - 1'd1 &&  parallel_tx_ready;
    assign overflow          = spi_clk_edge && counter == DATA_WIDTH - 1'd1 && !parallel_tx_ready;

    always @(posedge clk) begin
        spi_clk_d2  <= spi_clk_d1;
        spi_clk_d1  <= spi_clk;
        spi_mosi_d2 <= spi_mosi_d1;
        spi_mosi_d1 <= spi_mosi;
        if (spi_clk_edge) begin
            counter  <= counter + 1'd1;
            data_reg <= {spi_mosi_d2, data_reg[DATA_WIDTH-1:1]};
            if (counter == DATA_WIDTH - 1'd1) begin
                counter   <= '0;
            end
        end
        if (rst) begin
            data_reg    <= '0;
            counter     <= '0;
            spi_clk_d1  <= '0;
            spi_clk_d2  <= '0;
            spi_mosi_d1 <= '0;
            spi_mosi_d2 <= '0;
        end
    end

endmodule
