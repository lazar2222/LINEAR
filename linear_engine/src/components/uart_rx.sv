`include "../interfaces/parallel_if.svh"

module uart_rx #(
    parameter int CLOCK_RATE,
    parameter int BAUD_RATE,
    `PARALLEL_IF__UNI_PARAMS(parallel_tx)
) (
    input clk,
    input rst,

    input rx,

    `PARALLEL_IF__UNI_TX_PORTS(parallel_tx),

    output overflow,
    output frame_error
);
    localparam int DATA_WIDTH          = DATA_WIDTH_parallel_tx;
    localparam int CYCLES_PER_BIT      = CLOCK_RATE / BAUD_RATE;
    localparam int HALF_CYCLES_PER_BIT = CYCLES_PER_BIT / 2;
    localparam int COUNTER_WIDTH       = $clog2(CYCLES_PER_BIT);

    reg [     DATA_WIDTH:0] data_reg;
    reg [COUNTER_WIDTH-1:0] counter;

    reg rx_d1, rx_d2;

    wire rx_edge = rx_d2 && !rx_d1;

    assign parallel_tx_data  = data_reg[DATA_WIDTH:1];
    assign parallel_tx_valid = counter == 1'd1 && !data_reg[0] &&  rx_d2 &&  parallel_tx_ready;
    assign overflow          = counter == 1'd1 && !data_reg[0] &&  rx_d2 && !parallel_tx_ready;
    assign frame_error       = counter == 1'd1 && !data_reg[0] && !rx_d2;

    always @(posedge clk) begin
        rx_d2 <= rx_d1;
        rx_d1 <= rx;
        if (rx_edge && counter == '0 && !data_reg[0]) begin
            counter  <= HALF_CYCLES_PER_BIT - 1'd1;
            data_reg <= '1;
        end
        if (data_reg[0] || counter != '0) begin
            counter <= counter - 1'd1;
            if (counter == '0) begin
                counter  <= CYCLES_PER_BIT - 1'd1;
                data_reg <= {rx_d2, data_reg[DATA_WIDTH:1]};
            end
        end
        if (rst) begin
            data_reg  <= '0;
            counter   <= '0;
            rx_d1     <= '0;
            rx_d2     <= '0;
        end
    end

endmodule
