module nspi_xcvr #(
    parameter int DataWidth,
    parameter int InstanceCount
) (
    input clk,
    input rst,

    input                      spi_clk,
    input  [InstanceCount-1:0] spi_mosi,
    output [InstanceCount-1:0] spi_miso,

    input  [DataWidth-1:0] data_tx,
    output [DataWidth-1:0] data_rx,
    input                  send,
    output                 ready,
    output                 valid
);
    nspi_tx #(
        .DataWidth    (DataWidth),
        .InstanceCount(InstanceCount)
    ) nspi_tx_inst (
        .clk     (clk),
        .rst     (rst),
        .spi_clk (spi_clk),
        .spi_miso(spi_miso),
        .data    (data_tx),
        .send    (send),
        .ready   (ready)
    );

    nspi_rx #(
        .DataWidth    (DataWidth),
        .InstanceCount(InstanceCount)
    ) nspi_rx_inst (
        .clk     (clk),
        .rst     (rst),
        .spi_clk (spi_clk),
        .spi_mosi(spi_mosi),
        .data    (data_rx),
        .valid   (valid)
    );

endmodule
