`include "../interfaces/bus_if.svh"
`include "../interfaces/parallel_if.svh"

module hab #(
    parameter int BusWidth,
    parameter int ParallelWidth,
    parameter int FifoDepth,
    parameter int NSPIInstances
) (
    input clk,
    input rst,

    bus_if.master bus,

    input                      nspi_clk,
    input  [NSPIInstances-1:0] nspi_mosi,
    output [NSPIInstances-1:0] nspi_miso
);
    localparam int AddressWidth = $bits(bus.address);
    localparam int DataWidth    = $bits(bus.data_ctp);
    localparam int BytesPerWord = $bits(bus.byte_enable);
    localparam int ByteSize     = DataWidth / BytesPerWord;

    `BUS_IF__CREATE_BUS(bus_narrow, BusWidth, AddressWidth, ByteSize);
    parallel_xcvr_if #(ParallelWidth) xcvr_if ();

    wi_cache hab_cache (
        .clk   (clk),
        .rst   (rst),
        .master(bus),
        .slave (bus_narrow)
    );

    parallel_to_bus #(
        .FifoDepth(FifoDepth)
    ) hab_to_bus (
        .clk     (clk),
        .rst     (rst),
        .bus     (bus_narrow),
        .parallel(xcvr_if)
    );

    nspi_xcvr #(
        .InstanceCount(NSPIInstances)
    ) hab_xcvr (
        .clk          (clk),
        .rst          (rst),
        .spi_clk      (nspi_clk),
        .spi_mosi     (nspi_mosi),
        .spi_miso     (nspi_miso),
        .parallel_xcvr(xcvr_if)
    );

endmodule
