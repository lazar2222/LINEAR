`include "../interfaces/parallel_if.svh"

module testbench_xcvr ();

    reg clk;
    reg spi_clk;
    reg rst;

    always #50  clk     = !clk;
    always #400 spi_clk = !spi_clk;

    initial begin
        clk     = '1;
        spi_clk = '1;
        rst     = '1;
        #100;
        rst = '0;
    end

    localparam int DataWidth = 8;
    localparam int ClockRate = 100;
    localparam int BaudRate  = 10;

    wire uart_data;
    wire spi_data;

    parallel_tx_if #(.DataWidth(DataWidth)) parallel_tx_uart ();
    parallel_rx_if #(.DataWidth(DataWidth)) parallel_rx_uart ();
    parallel_tx_if #(.DataWidth(DataWidth)) parallel_tx_spi ();
    parallel_rx_if #(.DataWidth(DataWidth)) parallel_rx_spi ();

    uart_tx #(
        .ClockRate(ClockRate),
        .BaudRate (BaudRate)
    ) uart_tx (
        .clk        (clk),
        .rst        (rst),
        .tx         (uart_data),
        .parallel_tx(parallel_tx_uart)
    );

    uart_rx #(
        .ClockRate(ClockRate),
        .BaudRate (BaudRate)
    ) uart_rx (
        .clk        (clk),
        .rst        (rst),
        .rx         (uart_data),
        .parallel_rx(parallel_rx_uart)
    );

    spi_tx spi_tx (
        .clk        (clk),
        .rst        (rst),
        .spi_clk    (spi_clk),
        .spi_miso   (spi_data),
        .parallel_tx(parallel_tx_spi)
    );

    spi_rx spi_rx (
        .clk        (clk),
        .rst        (rst),
        .spi_clk    (spi_clk),
        .spi_mosi   (spi_data),
        .parallel_rx(parallel_rx_spi)
    );

endmodule
