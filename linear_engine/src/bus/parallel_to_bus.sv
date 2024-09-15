`include "../interfaces/bus_if.svh"
`include "../interfaces/parallel_if.svh"
`include "../interfaces/fifo_if.svh"

module parallel_to_bus #(
    parameter int FifoDepth
) (
    input clk,
    input rst,

    bus_if.master bus,

    parallel_xcvr_if.device parallel
);
    localparam int SerialDataWidth     = $bits(parallel.data_tx);
    localparam int DataWidth           = $bits(bus.data_ctp);
    localparam int AddressWidth        = $bits(bus.address);
    localparam int AddressPartSections = (AddressWidth + 1 + SerialDataWidth - 1) / SerialDataWidth;
    localparam int DataPartSections    = (DataWidth        + SerialDataWidth - 1) / SerialDataWidth;
    localparam int AddressFifoWidth    = AddressPartSections * SerialDataWidth;
    localparam int DataFifoWidth       = DataPartSections    * SerialDataWidth;

    wire overflow;
    wire underflow;
    wire error;

    `FIFO_IF__MAKE_FIFO(operation,  1,               1,                FifoDepth,                                      1)
    `FIFO_IF__MAKE_FIFO(address,    SerialDataWidth, AddressFifoWidth, FifoDepth * AddressFifoWidth / SerialDataWidth, 1)
    `FIFO_IF__MAKE_FIFO(write_data, SerialDataWidth, DataFifoWidth,    FifoDepth * DataFifoWidth    / SerialDataWidth, 1)
    `FIFO_IF__MAKE_FIFO(read_data,  DataFifoWidth,   SerialDataWidth,  FifoDepth,                                      1)

    parallel_to_fifo #(
        .DataWidth   (DataWidth),
        .AddressWidth(AddressWidth),
        .FifoDepth   (FifoDepth)
    ) parallel_to_fifo (
        .clk      (clk),
        .rst      (rst),
        .parallel (parallel),
        .operation(operation_write),
        .address  (address_write),
        .data_out (write_data_write),
        .data_in  (read_data_read),
        .overflow (overflow),
        .underflow(underflow)
    );

    bus_to_fifo #(
        .SerialDataWidth(SerialDataWidth)
    ) bus_to_fifo (
        .clk      (clk),
        .rst      (rst),
        .bus      (bus),
        .operation(operation_read),
        .address  (address_read),
        .data_in  (write_data_read),
        .data_out (read_data_write),
        .error    (error)
    );

endmodule
