`include "../interfaces/parallel_if.svh"

module dummy_nspi_master #(
    parameter int DataWidth,
    parameter int InstanceCount,
    parameter int ClockDivFactor
) (
    input clk,
    input rst,

    output [InstanceCount-1:0] nspi_clk,
    output [InstanceCount-1:0] nspi_mosi,
    input  [InstanceCount-1:0] nspi_miso
);
    parallel_xcvr_if #(.DataWidth(DataWidth)) parallel_xcvr ();

    nspi_xcvr #(
        .InstanceCount(InstanceCount)
    ) nspi_xcvr (
        .clk          (clk),
        .rst          (rst),
        .spi_clk      (nspi_clk[0]),
        .spi_mosi     (nspi_miso),
        .spi_miso     (nspi_mosi),
        .parallel_xcvr(parallel_xcvr)
    );

    reg                 spi_clk;
    reg                 send;
    reg [DataWidth-1:0] data;

    assign parallel_xcvr.send    = send;
    assign parallel_xcvr.data_tx = data;

    assign nspi_clk = {InstanceCount{spi_clk}};

    initial begin
        spi_clk = '0;
        send = '0;
        data = '0;

        wait (rst == '0);
        @(posedge clk);

        wait (parallel_xcvr.ready == '1);
        @(posedge clk);
        data = 32'h0;
        send = '1;
        @(posedge clk);
        send = '0;
        wait (parallel_xcvr.ready == '0);

        wait (parallel_xcvr.ready == '1);
        @(posedge clk);
        data = 32'h80000001;
        send = '1;
        @(posedge clk);
        send = '0;
        wait (parallel_xcvr.ready == '0);

        wait (parallel_xcvr.ready == '1);
        @(posedge clk);
        data = 32'hDEADBEEF;
        send = '1;
        @(posedge clk);
        send = '0;
        wait (parallel_xcvr.ready == '0);

        wait (parallel_xcvr.ready == '1);
        @(posedge clk);
        data = 32'h0;
        send = '1;
        @(posedge clk);
        send = '0;
        wait (parallel_xcvr.ready == '0);

    end

    always begin
        wait (parallel_xcvr.ready == '0);
        @(posedge clk);
        for (int i = 0; i < (DataWidth / InstanceCount) ; i++) begin
            spi_clk <= ~spi_clk;
            for (int j = 0; j < ClockDivFactor / 2; j++) begin
                @(posedge clk);
            end
            spi_clk <= ~spi_clk;
            for (int j = 0; j < ClockDivFactor / 2; j++) begin
                @(posedge clk);
            end
        end
    end

endmodule
