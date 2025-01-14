`include "../interfaces/parallel_if.svh"

module nspi_rx #(
    parameter int INSTANCE_COUNT,
    `PARALLEL_IF__UNI_PARAMS(parallel_tx)
) (
    input clk,
    input rst,

    input                      spi_clk,
    input [INSTANCE_COUNT-1:0] spi_mosi,

    `PARALLEL_IF__UNI_TX_PORTS(parallel_tx)
);
    `PARALLEL_IF__SPLIT_TX(parallel_tx, INSTANCE_COUNT)

    genvar i;
    generate
        for (i = 0; i < INSTANCE_COUNT; i++) begin : g_nspi_rx_instance
            spi_rx #(
                `PARALLEL_IF__UNI_FILL_PARAMS(parallel_tx, parallel_tx_div)
            ) spi_rx (
                .clk                           (clk),
                .rst                           (rst),
                .spi_clk                       (spi_clk),
                .spi_mosi                      (spi_mosi[i]),
                `PARALLEL_IF__UNI_CONNECT_SPLIT(parallel_tx, parallel_tx_div, i)
            );
        end
    endgenerate

endmodule
