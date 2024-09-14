`include "../interfaces/parallel_if.svh"

module nspi_rx #(
    parameter int InstanceCount
) (
    input clk,
    input rst,

    input                     spi_clk,
    input [InstanceCount-1:0] spi_mosi,

    parallel_rx_if.rx parallel_rx
);
    localparam int DataWidth     = $bits(parallel_rx.data);
    localparam int InstanceWidth = DataWidth / InstanceCount;

    wire [InstanceCount-1:0] valids;

    assign parallel_rx.valid = &valids;

    genvar i;
    generate
        for (i = 0; i < InstanceCount; i++) begin : g_nspi_rx_instance
            spi_rx #(
                .DataWidth(InstanceWidth)
            ) spi_rx (
                .clk     (clk),
                .rst     (rst),
                .spi_clk (spi_clk),
                .spi_mosi(spi_mosi[i]),
                .data    (parallel_rx.data[InstanceWidth*i+:InstanceWidth]),
                .valid   (valids[i])
            );
        end
    endgenerate

endmodule
