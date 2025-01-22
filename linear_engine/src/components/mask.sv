module mask #(
    parameter int WIDTH,
    parameter int COUNT
) (
    input  [COUNT-1:0][WIDTH-1:0] values,
    input  [COUNT-1:0]            enable,
    output [WIDTH-1:0]            masked
);
    reg [WIDTH-1:0] masked_reg;

    assign masked = masked_reg;

    always_comb begin
        masked_reg = '0;
        for (int i = 0; i < COUNT; i++) begin
            if (enable[i]) begin
                masked_reg = masked_reg | values[i];
            end
        end
    end

endmodule
