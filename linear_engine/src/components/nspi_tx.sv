`include "../interfaces/parallel_if.svh"

module nspi_tx #(
    parameter int INSTANCE_COUNT,
    `PARALLEL_IF__UNI_PARAMS(parallel_rx)
) (
    input clk,
    input rst,

    input                       spi_clk,
    output [INSTANCE_COUNT-1:0] spi_miso,

    `PARALLEL_IF__UNI_RX_PORTS(parallel_rx)
);
    `PARALLEL_IF__SPLIT_RX(parallel_rx, INSTANCE_COUNT);

    genvar i;
    generate
        for (i = 0; i < INSTANCE_COUNT; i++) begin : g_nspi_tx_instance
            spi_tx #(
                `PARALLEL_IF__UNI_FILL_PARAMS(parallel_rx, parallel_rx_div)
            ) spi_tx (
                .clk                           (clk),
                .rst                           (rst),
                .spi_clk                       (spi_clk),
                .spi_miso                      (spi_miso[i]),
                `PARALLEL_IF__UNI_CONNECT_SPLIT(parallel_rx, parallel_rx_div, i)
            );
        end
    endgenerate

endmodule
