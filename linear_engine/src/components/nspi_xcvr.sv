`include "../interfaces/parallel_if.svh"

module nspi_xcvr #(
    parameter int INSTANCE_COUNT,
    `PARALLEL_IF__BI_PARAMS(parallel)
) (
    input clk,
    input rst,

    input                       spi_clk,
    input  [INSTANCE_COUNT-1:0] spi_mosi,
    output [INSTANCE_COUNT-1:0] spi_miso,

    `PARALLEL_IF__BI_PORTS(parallel)
);
    nspi_tx #(
        .INSTANCE_COUNT              (INSTANCE_COUNT),
        `PARALLEL_IF__UNI_FILL_PARAMS(parallel_rx, parallel_rx)
    ) nspi_tx (
        .clk                     (clk),
        .rst                     (rst),
        .spi_clk                 (spi_clk),
        .spi_miso                (spi_miso),
        `PARALLEL_IF__UNI_CONNECT(parallel_rx, parallel_rx)
    );

    nspi_rx #(
        .INSTANCE_COUNT              (INSTANCE_COUNT),
        `PARALLEL_IF__UNI_FILL_PARAMS(parallel_tx, parallel_tx)
    ) nspi_rx (
        .clk                     (clk),
        .rst                     (rst),
        .spi_clk                 (spi_clk),
        .spi_mosi                (spi_mosi),
        `PARALLEL_IF__UNI_CONNECT(parallel_tx, parallel_tx)
    );

endmodule
