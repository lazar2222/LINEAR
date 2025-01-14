module por #(
    parameter int CYCLES
) (
    input clk,
    input power,

    output rst
);
    int cnt;

    assign rst = cnt != CYCLES;

    initial begin
        cnt = '0;
    end

    always @(posedge clk) begin
        if (power) begin
            if (cnt != CYCLES) begin
                cnt <= cnt + 1'd1;
            end
        end else begin
            cnt <= '0;
        end
    end

endmodule
