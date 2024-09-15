`include "../interfaces/fifo_if.svh"

module variable_fifo #(
    parameter int Depth,
    parameter int Fast
) (
    input clk,
    input rst,

    fifo_write_if.fifo write_port,
    fifo_read_if.fifo  read_port
);
    localparam int WriteWidth   = $bits(write_port.data);
    localparam int ReadWidth    = $bits(read_port.data);
    localparam int BitDepth     = WriteWidth * Depth;
    localparam int CounterWidth = $clog2(BitDepth);

    reg [    BitDepth-1:0] data;
    reg [CounterWidth-1:0] write_ptr;
    reg [CounterWidth-1:0] read_ptr;
    reg [  CounterWidth:0] count;

    wire can_write_slow = (count + WriteWidth             <= BitDepth);
    wire can_write_fast = (count + WriteWidth - ReadWidth <= BitDepth) && read_port.read;
    wire can_read_slow  = (count              >= ReadWidth);
    wire can_read_fast  = (count + WriteWidth >= ReadWidth) && write_port.write;

    wire [ReadWidth-1:0] data_out_fast = WriteWidth >= ReadWidth ? write_port.data[ReadWidth-1:0] : {write_port.data, data[read_ptr+:ReadWidth-WriteWidth]};
    wire [ReadWidth-1:0] data_out_slow = data[read_ptr+:ReadWidth];

    assign write_port.can_write = can_write_slow || (Fast && can_write_fast);
    assign read_port.can_read   = can_read_slow  || (Fast && can_read_fast);

    assign read_port.data = Fast && can_read_fast && !can_read_slow ? data_out_fast : data_out_slow;

    always @(posedge clk) begin
        if (write_port.write && read_port.read && write_port.can_write && read_port.can_read) begin
            data[write_ptr+:WriteWidth] <= write_port.data;
            write_ptr                   <= write_ptr + WriteWidth;
            read_ptr                    <= read_ptr  + ReadWidth;
            count                       <= count     + (WriteWidth - ReadWidth);
        end else if (write_port.write && write_port.can_write) begin
            data[write_ptr+:WriteWidth] <= write_port.data;
            write_ptr                   <= write_ptr + WriteWidth;
            count                       <= count     + WriteWidth;
        end else if (read_port.read && read_port.can_read) begin
            read_ptr <= read_ptr + ReadWidth;
            count    <= count    - ReadWidth;
        end
        if (rst) begin
            data      <= '0;
            write_ptr <= '0;
            read_ptr  <= '0;
            count     <= '0;
        end
    end

endmodule
