`include "../interfaces/parallel_if.svh"

module spi_tx #(
    `PARALLEL_IF__UNI_PARAMS(parallel_rx)
) (
    input clk,
    input rst,

    input  spi_clk,
    output spi_miso,

    `PARALLEL_IF__UNI_RX_PORTS(parallel_rx)
);
    localparam int DATA_WIDTH    = DATA_WIDTH_parallel_rx;
    localparam int COUNTER_WIDTH = $clog2(DATA_WIDTH);

    reg [   DATA_WIDTH-1:0] data_reg;
    reg [COUNTER_WIDTH-1:0] counter;

    reg writing;
    reg spi_miso_reg;
    reg spi_clk_d1, spi_clk_d2;

    wire spi_clk_edge = !spi_clk_d2 && spi_clk_d1;

    assign parallel_rx_ready = (counter == DATA_WIDTH - 1'd1 && spi_clk_edge) || (!writing && counter == '0);
    assign spi_miso          = spi_miso_reg;

    always @(posedge clk) begin
        spi_clk_d2 <= spi_clk_d1;
        spi_clk_d1 <= spi_clk;
        if (spi_clk_edge) begin
            spi_miso_reg <= (counter == '0 && parallel_rx_valid && parallel_rx_ready) ? parallel_rx_data[0] : data_reg[0];
            data_reg     <= {1'b0, data_reg[DATA_WIDTH-1:1]};
            counter      <= counter + 1'd1;
            if (counter == DATA_WIDTH - 1'd1) begin
                counter <= '0;
                writing <= '0;
            end
        end
        if (parallel_rx_valid && parallel_rx_ready) begin
            data_reg <= parallel_rx_data;
            writing  <= '1;
        end
        if (rst) begin
            data_reg     <= '0;
            counter      <= '0;
            writing      <= '0;
            spi_miso_reg <= '0;
            spi_clk_d1   <= '0;
            spi_clk_d2   <= '0;
        end
    end

endmodule
