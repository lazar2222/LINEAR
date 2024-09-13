module por #(
    parameter int Cycles
) (
    input clk,
    input power,

    output rst
);
    int cnt;

    assign rst = cnt != Cycles;

    initial begin
        cnt = '0;
    end

    always @(posedge clk) begin
        if (power) begin
            if (cnt != Cycles) begin
                cnt <= cnt + 1'd1;
            end
        end else begin
            cnt <= '0;
        end
    end

endmodule
