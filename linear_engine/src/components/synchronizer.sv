module synchronizer #(
    parameter int WIDTH,
    parameter int DEPTH
) (
    input dest_clk,
    input dest_reset,

    input  [WIDTH-1:0] in,
    output [WIDTH-1:0] out
);
    reg [DEPTH-1:0][WIDTH-1:0] buffer;

    assign out = buffer[0];

    always @(posedge dest_clk) begin
        buffer <= {in, buffer[DEPTH-1:1]};
        if (dest_reset) begin
            buffer <= '0;
        end
    end

endmodule
