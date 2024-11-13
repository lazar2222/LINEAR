`include "../interfaces/parallel_if.svh"
`include "../interfaces/fifo_if.svh"

module parallel_to_fifo #(
    parameter int DataWidth,
    parameter int AddressWidth,
    parameter int FifoDepth
) (
    input clk,
    input rst,

    parallel_xcvr_if.device parallel,

    fifo_write_if.device operation,
    fifo_write_if.device address,
    fifo_write_if.device data_out,
    fifo_read_if.device  data_in,

    output overflow,
    output underflow
);
    localparam int SerialDataWidth     = $bits(parallel.data_rx);
    localparam int AddressPartWidth    = AddressWidth + 1;
    localparam int AddressPartSections = (AddressPartWidth + SerialDataWidth - 1) / SerialDataWidth;
    localparam int DataPartSections    = (DataWidth + SerialDataWidth - 1) / SerialDataWidth;
    localparam int TotalSections       = AddressPartSections + DataPartSections;
    localparam int TotalWidth          = TotalSections * SerialDataWidth;
    localparam int SectionCounterWidth = $clog2(TotalSections);
    localparam int FifoCounterWidth    = $clog2(FifoDepth);

    reg op;
    reg [SectionCounterWidth-1:0] section_counter;
    reg [   FifoCounterWidth-1:0] fifo_counter;

    reg send_d;
    reg ready_d;

    wire ready_fe = !parallel.ready && ready_d;

    assign parallel.data_tx = data_in.data;
    assign parallel.send    = data_in.can_read && parallel.ready;
    assign data_in.read     = data_in.can_read && parallel.ready;

    assign operation.data = section_counter == '0 ? parallel.data_rx[SerialDataWidth-1] : op;
    assign address.data   = parallel.data_rx;
    assign data_out.data  = parallel.data_rx;

    assign operation.write = parallel.valid && operation.can_write && section_counter == '0;
    assign address.write   = parallel.valid && address.can_write   && section_counter <= AddressPartSections - 1'd1;
    assign data_out.write  = parallel.valid && data_out.can_write  && section_counter >  AddressPartSections - 1'd1;

    wire overflow_operation = parallel.valid && !operation.can_write && section_counter == '0;
    wire overflow_address   = parallel.valid && !address.can_write   && section_counter <= AddressPartSections - 1'd1;
    wire overflow_data      = parallel.valid && !data_out.can_write  && section_counter >  AddressPartSections - 1'd1;

    assign overflow  = overflow_operation || overflow_address || overflow_data;
    assign underflow = ready_fe && !send_d && fifo_counter != '0;

    always @(posedge clk) begin
        if (parallel.valid) begin
            section_counter <= section_counter + 1'd1;
            if (section_counter == '0) begin
                op <= parallel.data_rx[SerialDataWidth-1];
            end
            if (section_counter == AddressPartSections - 1'd1 && !operation.data) begin
                section_counter <= '0;
                fifo_counter    <= fifo_counter + 1'd1;
            end
            if (section_counter == TotalSections - 1'd1) begin
                section_counter <= '0;
            end
        end
        send_d  <= parallel.send;
        ready_d <= parallel.ready;
        if (data_in.can_read && parallel.ready) begin
            fifo_counter <= fifo_counter - 1'd1;
        end
        if (rst) begin
            op              <= '0;
            section_counter <= '0;
            fifo_counter    <= '0;
            send_d          <= '0;
            ready_d         <= '0;
        end
    end

endmodule
