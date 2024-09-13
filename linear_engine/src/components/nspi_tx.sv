module nspi_tx #(
    parameter int DataWidth,
    parameter int InstanceCount
) (
    input clk,
    input rst,

    input                      spi_clk,
    output [InstanceCount-1:0] spi_miso,

    input  [DataWidth-1:0] data,
    input                  send,
    output                 ready
);
    localparam int InstanceWidth = DataWidth / InstanceCount;

    wire [InstanceCount-1:0] readys;

    assign ready = &readys;

    genvar i;
    generate
        for (i = 0; i < InstanceCount; i++) begin : g_nspi_tx_instance
            spi_tx #(
                .DataWidth(InstanceWidth)
            ) spi_tx_inst (
                .clk     (clk),
                .rst     (rst),
                .spi_clk (spi_clk),
                .spi_miso(spi_miso[i]),
                .data    (data[InstanceWidth*i+:InstanceWidth]),
                .send    (send),
                .ready   (readys[i])
            );
        end
    endgenerate

endmodule
