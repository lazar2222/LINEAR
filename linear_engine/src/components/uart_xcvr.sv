`include "../interfaces/parallel_if.svh"

module uart_xcvr #(
    parameter int ClockRate,
    parameter int BaudRate
) (
    input clk,
    input rst,

    input  rx,
    output tx,

    parallel_xcvr_if.xcvr parallel_xcvr
);
    localparam int DataWidth = $bits(parallel_xcvr.data_rx);

    `PARALLEL_IF__XCVR_BREAKDOWN(parallel_xcvr, parallel_xcvr_tx, parallel_xcvr_rx);

    uart_tx #(
        .DataWidth(DataWidth),
        .ClockRate(ClockRate),
        .BaudRate (BaudRate)
    ) uart_tx (
        .clk        (clk),
        .rst        (rst),
        .tx         (tx),
        .parallel_tx(parallel_xcvr_tx)
    );

    uart_rx #(
        .DataWidth(DataWidth),
        .ClockRate(ClockRate),
        .BaudRate (BaudRate)
    ) uart_rx (
        .clk        (clk),
        .rst        (rst),
        .rx         (rx),
        .parallel_rx(parallel_xcvr_rx)
    );

endmodule
