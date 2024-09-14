`include "../interfaces/bus_if.svh"
`include "../interfaces/fifo_if.svh"

module bus_to_fifo #(
    parameter int SerialDataWidth
) (
    input clk,
    input rst,

    bus_if.master bus,

    fifo_read_if.device  operation,
    fifo_read_if.device  address,
    fifo_read_if.device  data_in,
    fifo_write_if.device data_out,

    output error
);
    localparam int AddressFifoWidth = $bits(address.data);
    localparam int DataFifoWidth    = $bits(data_in.data);

    wire [AddressFifoWidth-1:0] address_swapped;
    wire [   DataFifoWidth-1:0] data_in_swapped;

    block_swap #(
        .DataWidth (SerialDataWidth),
        .BlockWidth(AddressFifoWidth)
    ) address_swap (
        .data_in (address.data),
        .data_out(address_swapped)
    );

    block_swap #(
        .DataWidth (SerialDataWidth),
        .BlockWidth(DataFifoWidth)
    ) data_in_swap (
        .data_in (data_in.data),
        .data_out(data_in_swapped)
    );

    block_swap #(
        .DataWidth (SerialDataWidth),
        .BlockWidth(DataFifoWidth)
    ) data_out_swap (
        .data_in (bus.data_ptc),
        .data_out(data_out.data)
    );

    reg output_data;

    wire read      = !operation.data;
    wire write     = operation.data;
    wire can_read  = read  && operation.can_read && address.can_read && data_out.can_write;
    wire can_write = write && operation.can_read && address.can_read && data_in.can_read;

    assign bus.data_ctp    = data_in_swapped;
    assign bus.address     = address_swapped;
    assign bus.byte_enable = '1;
    assign bus.read        = can_read;
    assign bus.write       = can_write;

    assign operation.read = (can_read || can_write) && bus.complete;
    assign address.read   = (can_read || can_write) && bus.complete;
    assign data_in.read   = (            can_write) && bus.complete;

    assign data_out.write = output_data;

    assign error = (can_read || can_write) && (!bus.hit || bus.error);

    always @(posedge clk) begin
        output_data <= can_read && bus.complete;
        if (rst) begin
            output_data <= 1'b0;
        end
    end

endmodule
