`include "../interfaces/parallel_if.svh"

module nspi_xcvr #(
    parameter int InstanceCount
) (
    input clk,
    input rst,

    input                      spi_clk,
    input  [InstanceCount-1:0] spi_mosi,
    output [InstanceCount-1:0] spi_miso,

    parallel_xcvr_if.xcvr parallel_xcvr
);
    localparam int DataWidth = $bits(parallel_xcvr.data_rx);

    `PARALLEL_IF__XCVR_BREAKDOWN(parallel_xcvr, parallel_xcvr_tx, parallel_xcvr_rx);

    nspi_tx #(
        .DataWidth    (DataWidth),
        .InstanceCount(InstanceCount)
    ) nspi_tx (
        .clk        (clk),
        .rst        (rst),
        .spi_clk    (spi_clk),
        .spi_miso   (spi_miso),
        .parallel_tx(parallel_xcvr_tx)
    );

    nspi_rx #(
        .DataWidth    (DataWidth),
        .InstanceCount(InstanceCount)
    ) nspi_rx (
        .clk        (clk),
        .rst        (rst),
        .spi_clk    (spi_clk),
        .parallel_rx(parallel_xcvr_rx)
    );

endmodule
