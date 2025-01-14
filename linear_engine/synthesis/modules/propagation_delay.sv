module propagation_delay #(
    parameter int WIDTH,
    parameter int DELAY
) (
    input  [        WIDTH-1:0] data_in,
    output [        WIDTH-1:0] data_out,
    input  [2*DELAY+WIDTH-1:0] delay_in,
    output [        DELAY-1:0] delay_out
);
    genvar i;
    generate
        if (DELAY == 0) begin : g_nodelay
            assign data_out = data_in;
        end else begin : g_delay
            localparam int INSTANCE_COUNT = (WIDTH + DELAY - 1) / DELAY;
            localparam int INTERNAL_WIDTH = INSTANCE_COUNT * DELAY;
            localparam int PADDING        = INTERNAL_WIDTH - WIDTH;

            wire [INTERNAL_WIDTH-1:0] data_internal;
            wire [INTERNAL_WIDTH-1:0] data_internal_delayed;

            assign data_out = data_internal_delayed[WIDTH-1:0];

            if (PADDING > 0) begin : g_padding
                assign delay_out     = data_internal_delayed[WIDTH+:PADDING];
                assign data_internal = {delay_in[INTERNAL_WIDTH+:PADDING], data_in};
            end else begin : g_nopadding
                assign delay_out     = '0;
                assign data_internal = data_in;
            end

            for (i = 0; i < INSTANCE_COUNT; i++) begin : g_delay_instance
                assign data_internal_delayed[DELAY*i+:DELAY] = data_internal[DELAY*i+:DELAY] + delay_in[DELAY*i+:DELAY];
            end
        end
    endgenerate

endmodule
