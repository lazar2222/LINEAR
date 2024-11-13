`include "system.svh"
`include "../interfaces/bus_if.svh"

module test_top #(
    parameter int PLL = 1
) (
    input clock_50,

    input [3:0] key,
    input [9:0] sw,

    output [9:0] led,

    output vga_hs,
    output vga_vs,
    output vga_clk,
    output vga_sync_n,
    output vga_blank_n,

    output [7:0] vga_r,
    output [7:0] vga_g,
    output [7:0] vga_b,

    input  sim_rx,         // GPIO[0]
    output sim_tx,         // GPIO[2]

    input  cam_rx,         // GPIO[10]
    output cam_tx,         // GPIO[12]
    output cam_int,        // GPIO[14]

    input  [3:0] hab_clk,  // GPIO[1], GPIO[11], GPIO[21], GPIO[31]
    input  [3:0] hab_mosi, // GPIO[3], GPIO[13], GPIO[23], GPIO[33]
    output [3:0] hab_miso, // GPIO[5], GPIO[15], GPIO[24], GPIO[35]

    input  hab_reset,      // GPIO[30]
    output hab_power,      // GPIO[32]
    output hab_int         // GPIO[34]
);
    // Power and clock setup

    wire clk;
    wire locked, vga_locked;
    wire power = key[0] && (sw[0] || !hab_reset);
    wire pll_reset = !key[0] && !key[1];
    wire rst;

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

    por #(
        .Cycles(`SYSTEM__POR_TIME)
    ) por (
        .clk  (clk),
        .power(power && locked && vga_locked),
        .rst  (rst)
    );

    assign hab_power = !rst;

    assign led[0] = power;
    assign led[1] = locked;
    assign led[2] = vga_locked;
    assign led[3] = !rst;

    // Memory subsystem setup

    `BUS_IF__CREATE_MEM_BANK(hab, 32, 32, 8, 0, 256, "")

    parallel_xcvr_if #(.DataWidth(32)) xcvr_if ();

    parallel_to_bus #(
        .FifoDepth(4)
    ) hab_to_bus (
        .clk     (clk),
        .rst     (rst),
        .bus     (hab_a),
        .parallel(xcvr_if)
    );

    nspi_xcvr #(
        .InstanceCount(4)
    ) hab_xcvr (
        .clk          (clk),
        .rst          (rst),
        .spi_clk      (hab_clk[0]),
        .spi_mosi     (hab_mosi),
        .spi_miso     (hab_miso),
        .parallel_xcvr(xcvr_if)
    );

endmodule
