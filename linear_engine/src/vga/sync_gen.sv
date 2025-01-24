module sync_gen #(
    parameter int HORIZONTAL_VISIBLE_AREA,
    parameter int HORIZONTAL_FRONT_PORCH,
    parameter int HORIZONTAL_SYNC_PULSE,
    parameter int HORIZONTAL_BACK_PORCH,
    parameter int VERTICAL_VISIBLE_AREA,
    parameter int VERTICAL_FRONT_PORCH,
    parameter int VERTICAL_SYNC_PULSE,
    parameter int VERTICAL_BACK_PORCH
) (
    input clk,
    input rst,

    output [$clog2(HORIZONTAL_VISIBLE_AREA+HORIZONTAL_FRONT_PORCH+HORIZONTAL_SYNC_PULSE+HORIZONTAL_BACK_PORCH)-1:0] x,
    output [$clog2(VERTICAL_VISIBLE_AREA  +VERTICAL_FRONT_PORCH  +VERTICAL_SYNC_PULSE  +VERTICAL_BACK_PORCH  )-1:0] y,

    output h_sync,
    output v_sync,
    output visible_area,
    output start_fill
);
    localparam int HORIZONTAL_WHOLE      = HORIZONTAL_VISIBLE_AREA + HORIZONTAL_FRONT_PORCH + HORIZONTAL_SYNC_PULSE + HORIZONTAL_BACK_PORCH;
    localparam int HORIZONTAL_SYNC_START = HORIZONTAL_VISIBLE_AREA + HORIZONTAL_FRONT_PORCH;
    localparam int VERTICAL_WHOLE        = VERTICAL_VISIBLE_AREA   + VERTICAL_FRONT_PORCH   + VERTICAL_SYNC_PULSE   + VERTICAL_BACK_PORCH;
    localparam int VERTICAL_SYNC_START   = VERTICAL_VISIBLE_AREA   + VERTICAL_FRONT_PORCH;
    localparam int HORIZONTAL_BITS       = $clog2(HORIZONTAL_WHOLE);
    localparam int VERTICAL_BITS         = $clog2(VERTICAL_WHOLE);

    reg [HORIZONTAL_BITS-1:0] x_reg;
    reg [  VERTICAL_BITS-1:0] y_reg;

    assign x = x_reg;
    assign y = y_reg;

    assign h_sync       = x_reg >= HORIZONTAL_SYNC_START  && x_reg < (HORIZONTAL_SYNC_START + HORIZONTAL_SYNC_PULSE);
    assign v_sync       = y_reg >= VERTICAL_SYNC_START    && y_reg < (VERTICAL_SYNC_START   + VERTICAL_SYNC_PULSE);
    assign visible_area = x_reg < HORIZONTAL_VISIBLE_AREA && y_reg < VERTICAL_VISIBLE_AREA;
    assign start_fill   = x_reg == '0                     && y_reg == VERTICAL_WHOLE - 1'd1;

    always @(posedge clk) begin
        x_reg <= x_reg + 1'd1;
        if (x_reg == HORIZONTAL_WHOLE - 1'd1) begin
            x_reg <= '0;
            y_reg <= y_reg + 1'd1;
            if (y_reg == VERTICAL_WHOLE - 1'd1) begin
                y_reg <= '0;
            end
        end
        if (rst) begin
            x_reg <= '0;
            y_reg <= VERTICAL_VISIBLE_AREA;
        end
    end

endmodule
