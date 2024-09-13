module uart_xcvr #(
    parameter int DataWidth,
    parameter int ClockRate,
    parameter int BaudRate
) (
    input clk,
    input rst,

    input  rx,
    output tx,

    input  [DataWidth-1:0] data_tx,
    output [DataWidth-1:0] data_rx,
    input                  send,
    output                 ready,
    output                 valid
);
    uart_tx #(
        .DataWidth(DataWidth),
        .ClockRate(ClockRate),
        .BaudRate (BaudRate)
    ) uart_tx_inst (
        .clk  (clk),
        .rst  (rst),
        .tx   (tx),
        .data (data_tx),
        .send (send),
        .ready(ready)
    );

    uart_rx #(
        .DataWidth(DataWidth),
        .ClockRate(ClockRate),
        .BaudRate (BaudRate)
    ) uart_rx_inst (
        .clk  (clk),
        .rst  (rst),
        .rx   (rx),
        .data (data_rx),
        .valid(valid)
    );

endmodule
