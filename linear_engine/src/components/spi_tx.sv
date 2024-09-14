`include "../interfaces/parallel_if.svh"

module spi_tx (
    input clk,
    input rst,

    input  spi_clk,
    output spi_miso,

    parallel_tx_if.tx parallel_tx
);
    localparam int DataWidth    = $bits(parallel_tx.data);
    localparam int CounterWidth = $clog2(DataWidth);

    reg [   DataWidth-1:0] data_reg;
    reg [CounterWidth-1:0] counter;

    reg writing;
    reg spi_miso_reg;
    reg spi_clk_d1, spi_clk_d2;

    wire spi_clk_edge = !spi_clk_d2 & spi_clk_d1;

    assign parallel_tx.ready = !writing && counter == '0 && !spi_clk_edge;
    assign spi_miso          = spi_miso_reg;

    always @(posedge clk) begin
        spi_clk_d2 <= spi_clk_d1;
        spi_clk_d1 <= spi_clk;
        if (spi_clk_edge) begin
            spi_miso_reg <= data_reg[DataWidth-1];
            data_reg     <= {data_reg[DataWidth-2:0], 1'b0};
            counter      <= counter + 1'd1;
            if (counter == DataWidth - 1'd1) begin
                counter <= '0;
                writing <= '0;
            end
        end
        if (parallel_tx.send && parallel_tx.ready) begin
            data_reg <= parallel_tx.data;
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
