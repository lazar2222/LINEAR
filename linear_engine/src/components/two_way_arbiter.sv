module two_way_arbiter (
    input clk,
    input rst,

    input request_a,
    input request_b,
    input complete,

    output grant_a,
    output grant_b
);
    reg priority_a;

    wire contention = request_a && request_b;

    assign grant_a = request_a && (!contention || priority_a);
    assign grant_b = request_b && (!contention || !priority_a);

    always @(posedge clk) begin
        if (complete) begin
            priority_a <= grant_b;
        end
        if (rst) begin
            priority_a <= '1;
        end
    end

endmodule
