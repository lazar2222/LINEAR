`include "system.svh"

module top #(
    parameter int PLL = 1
) (
    input clock_50,

    input [3:0] key,

    output [9:0] led,

    output vga_hs,
    output vga_vs,
    output vga_clk,
    output vga_sync_n,
    output vga_blank_n,

    output [7:0] vga_r,
    output [7:0] vga_g,
    output [7:0] vga_b
);
    wire clk, clk_vga;
    wire locked, locked_vga;
    wire power = key[0];
    wire pll_reset = !key[0] && !key[1];
    wire reset;

    generate
        if (PLL == 1) begin : g_pll
            pll #(
                .Fractional     (`SYSTEM__CORE_FRACTIONAL),
                .InputFrequency (`SYSTEM__INPUT_FREQ),
                .OutputFrequency(`SYSTEM__CORE_FREQ)
            ) system_pll (
                .rst   (pll_reset),
                .refclk(clock_50),
                .outclk(clk),
                .locked(locked)
            );
            pll #(
                .Fractional     (`SYSTEM__VGA_FRACTIONAL),
                .InputFrequency (`SYSTEM__INPUT_FREQ),
                .OutputFrequency(`SYSTEM__VGA_FREQ)
            ) vga_pll (
                .rst   (pll_reset),
                .refclk(clock_50),
                .outclk(clk_vga),
                .locked(locked_vga)
            );
        end else begin : g_nopll
            assign clk        = clock_50;
            assign clk_vga    = clock_50;
            assign locked     = 1'b1;
            assign locked_vga = 1'b1;
        end
    endgenerate

    por #(
        .Cycles(`SYSTEM__POR_TIME)
    ) por (
        .clk  (clk),
        .power(power && locked && locked_vga),
        .rst  (reset)
    );

    assign led[0] = power;
    assign led[1] = locked;
    assign led[2] = locked_vga;
    assign led[3] = !reset;

    wire [9:0] x, y;

    sync_gen #(
        .HorizontalVisibleArea(`SYSTEM__VGA_HORIZONTAL_VISIBLE_AREA),
        .HorizontalFrontPorch (`SYSTEM__VGA_HORIZONTAL_FRONT_PORCH),
        .HorizontalSyncPulse  (`SYSTEM__VGA_HORIZONTAL_SYNC_PULSE),
        .HorizontalBackPorch  (`SYSTEM__VGA_HORIZONTAL_BACK_PORCH),
        .VerticalVisibleArea  (`SYSTEM__VGA_VERTICAL_VISIBLE_AREA),
        .VerticalFrontPorch   (`SYSTEM__VGA_VERTICAL_FRONT_PORCH),
        .VerticalSyncPulse    (`SYSTEM__VGA_VERTICAL_SYNC_PULSE),
        .VerticalBackPorch    (`SYSTEM__VGA_VERTICAL_BACK_PORCH)
    ) sync_gen (
        .clk         (clk_vga),
        .rst         (reset),
        .x           (x),
        .y           (y),
        .h_sync      (vga_hs),
        .v_sync      (vga_vs),
        .visible_area(vga_blank_n)
    );

    assign vga_clk     = clk_vga;
    assign vga_sync_n  = 1'b0;

    assign vga_r       = x[9:2];
    assign vga_g       = y[9:2];
    assign vga_b       = 8'b0;

endmodule
