`include "../interfaces/parallel_if.svh"

module nspi_tx #(
    parameter int InstanceCount
) (
    input clk,
    input rst,

    input                      spi_clk,
    output [InstanceCount-1:0] spi_miso,

    parallel_tx_if.tx parallel_tx
);
    localparam int DataWidth     = $bits(parallel_tx.data);
    localparam int InstanceWidth = DataWidth / InstanceCount;

    wire [InstanceCount-1:0] readys;

    assign parallel_tx.ready = &readys;

    genvar i;
    generate
        for (i = 0; i < InstanceCount; i++) begin : g_nspi_tx_instance
            spi_tx #(
                .DataWidth(InstanceWidth)
            ) spi_tx (
                .clk     (clk),
                .rst     (rst),
                .spi_clk (spi_clk),
                .spi_miso(spi_miso[i]),
                .data    (parallel_tx.data[InstanceWidth*i+:InstanceWidth]),
                .send    (parallel_tx.send),
                .ready   (readys[i])
            );
        end
    endgenerate

endmodule
