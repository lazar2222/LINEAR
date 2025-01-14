`include "../interfaces/parallel_if.svh"

module uart_tx #(
    parameter int CLOCK_RATE,
    parameter int BAUD_RATE,
    `PARALLEL_IF__UNI_PARAMS(parallel_rx)
) (
    input clk,
    input rst,

    output tx,

    `PARALLEL_IF__UNI_RX_PORTS(parallel_rx)
);
    localparam int DATA_WIDTH        = DATA_WIDTH_parallel_rx;
    localparam int CYCLES_PER_BIT    = CLOCK_RATE / BAUD_RATE;
    localparam int COUNTER_WIDTH     = $clog2(CYCLES_PER_BIT);
    localparam int BIT_COUNTER_WIDTH = $clog2(DATA_WIDTH + 2);

    reg [       DATA_WIDTH+1:0] data_reg;
    reg [    COUNTER_WIDTH-1:0] counter;
    reg [BIT_COUNTER_WIDTH-1:0] bit_counter;

    reg writing;

    assign parallel_rx_ready = !writing || (bit_counter == '0 && counter == '0);
    assign tx                = data_reg[0];

    always @(posedge clk) begin
        if (writing) begin
            counter <= counter - 1'd1;
            if (counter == '0) begin
                counter     <= CYCLES_PER_BIT - 1'd1;
                data_reg    <= {1'b1, data_reg[DATA_WIDTH+1:1]};
                bit_counter <= bit_counter - 1'd1;
                if (bit_counter == '0) begin
                    writing <= '0;
                end
            end
        end
        if (parallel_rx_valid && parallel_rx_ready) begin
            counter     <= CYCLES_PER_BIT - 1'd1;
            data_reg    <= {1'b1, parallel_rx_data, 1'b0};
            writing     <= '1;
            bit_counter <= DATA_WIDTH + 1'd1;
        end
        if (rst) begin
            data_reg    <= '1;
            counter     <= '0;
            bit_counter <= '0;
            writing     <= '0;
        end
    end

endmodule
