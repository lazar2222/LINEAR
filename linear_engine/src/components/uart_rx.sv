module uart_rx #(
    parameter int DataWidth,
    parameter int ClockRate,
    parameter int BaudRate
) (
    input clk,
    input rst,

    input rx,

    output [DataWidth-1:0] data,
    output                 valid
);
    localparam int CyclesPerBit     = ClockRate / BaudRate;
    localparam int HalfCyclesPerBit = CyclesPerBit / 2;
    localparam int CounterWidth     = $clog2(CyclesPerBit);

    reg [   DataWidth+1:0] data_reg;
    reg [CounterWidth-1:0] counter;

    reg reading;
    reg valid_reg;
    reg rx_d1, rx_d2;

    wire rx_edge = rx_d2 & !rx_d1;

    assign data  = data_reg[DataWidth:1];
    assign valid = valid_reg;

    always @(posedge clk) begin
        rx_d2 <= rx_d1;
        rx_d1 <= rx;
        if (rx_edge && !reading) begin
            counter  <= HalfCyclesPerBit - 1'd1;
            data_reg <= '1;
            reading  <= '1;
        end
        if (reading) begin
            counter <= counter - 1'd1;
            if (counter == '0) begin
                counter  <= CyclesPerBit - 1'd1;
                data_reg <= {rx_d1, data_reg[DataWidth+1:1]};
                if (!data_reg[1]) begin
                    reading   <= '0;
                    valid_reg <= '1;
                end
            end
        end
        if (valid_reg) begin
            valid_reg <= '0;
        end
        if (rst) begin
            data_reg  <= '1;
            counter   <= '0;
            rx_d1     <= '0;
            rx_d2     <= '0;
            reading   <= '0;
            valid_reg <= '0;
        end
    end

endmodule
