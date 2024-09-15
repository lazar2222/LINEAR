`include "../interfaces/parallel_if.svh"

module nspi_rx #(
    parameter int InstanceCount
) (
    input clk,
    input rst,

    input                     spi_clk,
    input [InstanceCount-1:0] spi_mosi,

    parallel_rx_if.rx parallel_rx
);
    `PARALLEL_IF__SPLIT_RX(parallel_rx, InstanceCount)

    genvar i;
    generate
        for (i = 0; i < InstanceCount; i++) begin : g_nspi_rx_instance
            spi_rx spi_rx (
                .clk        (clk),
                .rst        (rst),
                .spi_clk    (spi_clk),
                .spi_mosi   (spi_mosi[i]),
                .parallel_rx(parallel_rx_div[i])
            );
        end
    endgenerate

endmodule
