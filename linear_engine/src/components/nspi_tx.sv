`include "../interfaces/parallel_if.svh"

module nspi_tx #(
    parameter int InstanceCount
) (
    input clk,
    input rst,

    input                      spi_clk,
    output [InstanceCount-1:0] spi_miso,

    parallel_tx_if.tx parallel_tx
);
    `PARALLEL_IF__SPLIT_TX(parallel_tx, InstanceCount)

    genvar i;
    generate
        for (i = 0; i < InstanceCount; i++) begin : g_nspi_tx_instance
            spi_tx spi_tx (
                .clk        (clk),
                .rst        (rst),
                .spi_clk    (spi_clk),
                .spi_miso   (spi_miso[i]),
                .parallel_tx(parallel_tx_div[i])
            );
        end
    endgenerate

endmodule
