`include "system.svh"
`include "../interfaces/parallel_if.svh"
`include "../interfaces/bus_if.svh"

module top #(
    parameter int PLL = 1
) (
    input clock_50,

    input [3:0] key,
    input [9:0] sw,

    output [9:0] led,

    output vga_hs,
    output vga_vs,
    output vga_clock,
    output vga_sync_n,
    output vga_blank_n,

    output [7:0] vga_r,
    output [7:0] vga_g,
    output [7:0] vga_b,

    input  sim_rx,          // GPIO[0]
    output sim_tx,          // GPIO[2]

    input  [3:0] hab_clk,   // GPIO[1], GPIO[11], GPIO[21], GPIO[31]
    input  [3:0] hab_mosi,  // GPIO[3], GPIO[13], GPIO[23], GPIO[33]
    output [3:0] hab_miso,  // GPIO[5], GPIO[15], GPIO[25], GPIO[35]

    input        hab_reset, // GPIO[26]
    output       hab_power, // GPIO[28]
    output [2:0] hab_int    // GPIO[30], GPIO[32], GPIO[34]
);
    // UI setup

    wire btn_reset     = !key[0];
    wire btn_pll_reset = !key[1];
    wire btn_          = !key[2];
    wire btn__         = !key[3];

    wire sw_reset_override = sw[0];
    wire sw_               = sw[1];
    wire sw__              = sw[2];
    wire sw___             = sw[3];
    wire sw____            = sw[4];
    wire sw_____           = sw[5];
    wire sw______          = sw[6];
    wire sw_______         = sw[7];
    wire sw________        = sw[8];
    wire sw_________       = sw[9];

    wire led_power;
    wire led_locked;
    wire led_vga_locked;
    wire led_running;
    wire led_;
    wire led__;
    wire led___;
    wire led____;
    wire led_____;
    wire led______;

    assign led = {led______, led_____, led____, led___, led__, led_, led_running, led_vga_locked, led_locked, led_power};

    // Power and clock setup

    wire pll_reset = btn_reset && btn_pll_reset;
    wire clk, vga_clk;
    wire locked, vga_locked;

    generate
        if (PLL == 1) begin : g_pll
            pll #(
                .FRACTIONAL      (`SYSTEM__CORE_FRACTIONAL),
                .INPUT_FREQUENCY (`SYSTEM__INPUT_FREQ),
                .OUTPUT_FREQUENCY(`SYSTEM__CORE_FREQ)
            ) system_pll (
                .rst   (pll_reset),
                .refclk(clock_50),
                .outclk(clk),
                .locked(locked)
            );
            pll #(
                .FRACTIONAL      (`SYSTEM__VGA_FRACTIONAL),
                .INPUT_FREQUENCY (`SYSTEM__INPUT_FREQ),
                .OUTPUT_FREQUENCY(`SYSTEM__VGA_FREQ)
            ) vga_pll (
                .rst   (pll_reset),
                .refclk(clock_50),
                .outclk(vga_clk),
                .locked(vga_locked)
            );
        end else begin : g_nopll
            assign clk        = clock_50;
            assign vga_clk    = clock_50;
            assign locked     = 1'b1;
            assign vga_locked = 1'b1;
        end
    endgenerate

    wire power = !btn_reset && (sw_reset_override || !hab_reset);
    wire rst;

    por #(
        .CYCLES(`SYSTEM__POR_TIME)
    ) por (
        .clk  (clk),
        .power(power && locked && vga_locked),
        .rst  (rst)
    );

    assign hab_power = !rst;

    assign led_power      = power;
    assign led_locked     = locked;
    assign led_vga_locked = vga_locked;
    assign led_running    = !rst;

endmodule
