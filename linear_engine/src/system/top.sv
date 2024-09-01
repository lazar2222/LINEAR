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
            system_pll system_pll (
                .rst   (pll_reset),
                .refclk(clock_50),
                .outclk(clk),
                .locked(locked)
            );
            vga_pll vga_pll (
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

endmodule
