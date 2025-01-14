module shift_reg_with_delay #(
    parameter int WIDTH,
    parameter int INPUT_DELAY,
    parameter int OUTPUT_DELAY
) (
    input clk,
    input rst,
    input latch,

    input              serial_in,
    output             serial_out,
    input  [WIDTH-1:0] data_in,
    output [WIDTH-1:0] data_out
);
    localparam int INPUT_DELAY_WIDTH  = 2 * INPUT_DELAY + WIDTH;
    localparam int OUTPUT_DELAY_WIDTH = 2 * OUTPUT_DELAY + WIDTH;

    wire serial_int1, serial_int2;

    wire [WIDTH-1:0] delayed_data_in;
    wire [WIDTH-1:0] register_data_out;

    wire [ INPUT_DELAY_WIDTH-1:0] input_delay_in;
    wire [ INPUT_DELAY_WIDTH-1:0] input_delay_out;
    wire [OUTPUT_DELAY_WIDTH-1:0] output_delay_in;
    wire [OUTPUT_DELAY_WIDTH-1:0] output_delay_out;

    shift_reg #(
        .WIDTH(WIDTH)
    ) data_reg (
        .clk       (clk),
        .rst       (rst),
        .latch     (latch),
        .serial_in (serial_in),
        .serial_out(serial_int1),
        .data_in   (delayed_data_in),
        .data_out  (register_data_out)
    );

    shift_reg #(
        .WIDTH(INPUT_DELAY_WIDTH)
    ) input_delay_reg (
        .clk       (clk),
        .rst       (rst),
        .latch     (latch),
        .serial_in (serial_int1),
        .serial_out(serial_int2),
        .data_in   (input_delay_out),
        .data_out  (input_delay_in)
    );

    shift_reg #(
        .WIDTH(OUTPUT_DELAY_WIDTH)
    ) output_delay_reg (
        .clk       (clk),
        .rst       (rst),
        .latch     (latch),
        .serial_in (serial_int2),
        .serial_out(serial_out),
        .data_in   (output_delay_out),
        .data_out  (output_delay_in)
    );

    propagation_delay #(
        .WIDTH(WIDTH),
        .DELAY(INPUT_DELAY)
    ) input_delay (
        .data_in  (data_in),
        .data_out (delayed_data_in),
        .delay_in (input_delay_in),
        .delay_out(input_delay_out)
    );

    propagation_delay #(
        .WIDTH(WIDTH),
        .DELAY(OUTPUT_DELAY)
    ) output_delay (
        .data_in  (register_data_out),
        .data_out (data_out),
        .delay_in (output_delay_in),
        .delay_out(output_delay_out)
    );

endmodule
