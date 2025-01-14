module shift_reg #(
    parameter int WIDTH
) (
    input clk,
    input rst,
    input latch,

    input              serial_in,
    output             serial_out,
    input  [WIDTH-1:0] data_in,
    output [WIDTH-1:0] data_out
);
    reg [WIDTH-1:0] shift_reg;
    reg [WIDTH-1:0] output_reg;

    assign data_out   = output_reg;
    assign serial_out = shift_reg[WIDTH-1];

    always @(posedge clk) begin
        if (latch) begin
            output_reg <= shift_reg;
            shift_reg  <= data_in;
        end else begin
            shift_reg <= {shift_reg[WIDTH-2:0], serial_in};
        end
        if (rst) begin
            shift_reg  <= '0;
            output_reg <= '0;
        end
    end

endmodule
