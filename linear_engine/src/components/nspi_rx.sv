module nspi_rx #(
    parameter int DataWidth,
    parameter int InstanceCount
) (
    input clk,
    input rst,

    input                     spi_clk,
    input [InstanceCount-1:0] spi_mosi,

    output [DataWidth-1:0] data,
    output                 valid
);
    localparam int InstanceWidth = DataWidth / InstanceCount;

    wire [InstanceCount-1:0] valids;

    assign valid = &valids;

    genvar i;
    generate
        for (i = 0; i < InstanceCount; i++) begin : g_nspi_rx_instance
            spi_rx #(
                .DataWidth(InstanceWidth)
            ) spi_rx_inst (
                .clk     (clk),
                .rst     (rst),
                .spi_clk (spi_clk),
                .spi_mosi(spi_mosi[i]),
                .data    (data[InstanceWidth*i+:InstanceWidth]),
                .valid   (valids[i])
            );
        end
    endgenerate

endmodule
