`include "../interfaces/parallel_if.svh"

module uart_xcvr #(
    parameter int CLOCK_RATE,
    parameter int BAUD_RATE,
    `PARALLEL_IF__BI_PARAMS(parallel)
) (
    input clk,
    input rst,

    input  rx,
    output tx,

    `PARALLEL_IF__BI_PORTS(parallel),

    output overflow,
    output frame_error
);
    uart_tx #(
        .CLOCK_RATE                  (CLOCK_RATE),
        .BAUD_RATE                   (BAUD_RATE),
        `PARALLEL_IF__UNI_FILL_PARAMS(parallel_rx, parallel_rx)
    ) uart_tx (
        .clk                     (clk),
        .rst                     (rst),
        .tx                      (tx),
        `PARALLEL_IF__UNI_CONNECT(parallel_rx, parallel_rx)
    );

    uart_rx #(
        .CLOCK_RATE                  (CLOCK_RATE),
        .BAUD_RATE                   (BAUD_RATE),
        `PARALLEL_IF__UNI_FILL_PARAMS(parallel_tx, parallel_tx)
    ) uart_rx (
        .clk                     (clk),
        .rst                     (rst),
        .rx                      (rx),
        `PARALLEL_IF__UNI_CONNECT(parallel_tx, parallel_tx),
        .overflow                (overflow),
        .frame_error             (frame_error)
    );

endmodule
