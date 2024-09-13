module sync_gen #(
    parameter int HorizontalVisibleArea,
    parameter int HorizontalFrontPorch,
    parameter int HorizontalSyncPulse,
    parameter int HorizontalBackPorch,
    parameter int VerticalVisibleArea,
    parameter int VerticalFrontPorch,
    parameter int VerticalSyncPulse,
    parameter int VerticalBackPorch
) (
    clk,
    rst,
    x,
    y,
    h_sync,
    v_sync,
    visible_area
);
    localparam int HorizontalWhole     = HorizontalVisibleArea + HorizontalFrontPorch + HorizontalSyncPulse + HorizontalBackPorch;
    localparam int HorizontalSyncStart = HorizontalVisibleArea + HorizontalFrontPorch;
    localparam int VerticalWhole       = VerticalVisibleArea   + VerticalFrontPorch   + VerticalSyncPulse   + VerticalBackPorch;
    localparam int VerticalSyncStart   = VerticalVisibleArea   + VerticalFrontPorch;
    localparam int HorizontalBits      = $clog2(HorizontalWhole);
    localparam int VerticalBits        = $clog2(VerticalWhole);

    input clk;
    input rst;

    output reg [HorizontalBits-1:0] x;
    output reg [  VerticalBits-1:0] y;

    output h_sync;
    output v_sync;
    output visible_area;

    assign h_sync       = x >= HorizontalSyncStart  && x < (HorizontalSyncStart + HorizontalSyncPulse);
    assign v_sync       = y >= VerticalSyncStart    && y < (VerticalSyncStart   + VerticalSyncPulse);
    assign visible_area = x < HorizontalVisibleArea && y < VerticalVisibleArea;

    always @(posedge clk) begin
        x <= x + 1'd1;
        if (x == HorizontalWhole - 1'd1) begin
            x <= '0;
            y <= y + 1'd1;
            if (y == VerticalWhole - 1'd1) begin
                y <= '0;
            end
        end
        if (rst) begin
            x <= '0;
            y <= '0;
        end
    end

endmodule
