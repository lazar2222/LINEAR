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

    wire       data;
    wire       send;
    wire       ready;
    wire       valid;
    wire       spi_data;
    wire       spi_ready;
    wire       spi_valid;
    wire [7:0] spi_data_out;
    wire [7:0] data_in;
    wire [7:0] data_out;

    uart_tx #(
        .DataWidth(DataWidth),
        .ClockRate(ClockRate),
        .BaudRate (BaudRate)
    ) uart_tx_inst (
        .clk  (clk),
        .rst  (rst),
        .tx   (data),
        .data (data_in),
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
        .rx   (data),
        .data (data_out),
        .valid(valid)
    );

    spi_tx #(
        .DataWidth(DataWidth)
    ) spi_tx_inst (
        .clk     (clk),
        .rst     (rst),
        .spi_clk (spi_clk),
        .spi_miso(spi_data),
        .data    (data_in),
        .send    (send),
        .ready   (spi_ready)
    );

    spi_rx #(
        .DataWidth(DataWidth)
    ) spi_rx_inst (
        .clk     (clk),
        .rst     (rst),
        .spi_clk (spi_clk),
        .spi_mosi(spi_data),
        .data    (spi_data_out),
        .valid   (spi_valid)
    );

endmodule
