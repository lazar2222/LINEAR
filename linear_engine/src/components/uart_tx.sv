module uart_tx #(
    parameter int DataWidth,
    parameter int ClockRate,
    parameter int BaudRate
) (
    input clk,
    input rst,

    output tx,

    input  [DataWidth-1:0] data,
    input                  send,
    output                 ready
);
    localparam int CyclesPerBit    = ClockRate / BaudRate;
    localparam int CounterWidth    = $clog2(CyclesPerBit);
    localparam int BitCounterWidth = $clog2(DataWidth + 2);

    reg [      DataWidth+1:0] data_reg;
    reg [   CounterWidth-1:0] counter;
    reg [BitCounterWidth-1:0] bit_counter;

    reg writing;

    assign ready = !writing || (bit_counter == '0 && counter == '0);
    assign tx    = data_reg[0];

    always @(posedge clk) begin
        if (writing) begin
            counter <= counter - 1'd1;
            if (counter == '0) begin
                counter     <= CyclesPerBit - 1'd1;
                data_reg    <= {1'b1, data_reg[DataWidth+1:1]};
                bit_counter <= bit_counter - 1'd1;
                if (bit_counter == '0) begin
                    writing <= '0;
                end
            end
        end
        if (send && ready) begin
            counter     <= CyclesPerBit - 1'd1;
            data_reg    <= {1'b1, data, 1'b0};
            writing     <= '1;
            bit_counter <= DataWidth + 1'd1;
        end
        if (rst) begin
            data_reg    <= '1;
            counter     <= '0;
            bit_counter <= '0;
            writing     <= '0;
        end
    end

endmodule
