`include "../interfaces/parallel_if.svh"

module spi_rx (
    input clk,
    input rst,

    input spi_clk,
    input spi_mosi,

    parallel_rx_if.rx parallel_rx
);
    localparam int DataWidth    = $bits(parallel_rx.data);
    localparam int CounterWidth = $clog2(DataWidth);

    reg [   DataWidth-1:0] data_reg;
    reg [CounterWidth-1:0] counter;

    reg valid_reg;
    reg spi_clk_d1, spi_clk_d2;
    reg spi_mosi_d1, spi_mosi_d2;

    wire spi_clk_edge = spi_clk_d2 & !spi_clk_d1;

    assign parallel_rx.data  = data_reg;
    assign parallel_rx.valid = valid_reg;

    always @(posedge clk) begin
        spi_clk_d2  <= spi_clk_d1;
        spi_clk_d1  <= spi_clk;
        spi_mosi_d2 <= spi_mosi_d1;
        spi_mosi_d1 <= spi_mosi;
        if (spi_clk_edge) begin
            counter  <= counter + 1'd1;
            data_reg <= {data_reg[DataWidth-2:0], spi_mosi_d2};
            if (counter == DataWidth - 1'd1) begin
                valid_reg <= '1;
                counter   <= '0;
            end
        end
        if (valid_reg) begin
            valid_reg <= '0;
        end
        if (rst) begin
            data_reg    <= '0;
            counter     <= '0;
            spi_clk_d1  <= '0;
            spi_clk_d2  <= '0;
            spi_mosi_d1 <= '0;
            spi_mosi_d2 <= '0;
            valid_reg   <= '0;
        end
    end

endmodule
