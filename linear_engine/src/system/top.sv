`include "system.svh"
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
        .rst  (reset)
    );

    assign hab_power = !reset;

    assign led[0] = power;
    assign led[1] = locked;
    assign led[2] = vga_locked;
    assign led[3] = !reset;

    // Memory subsystem setup

    //// Masters
    `BUS_IF__CREATE_BUS(sm0_im, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE);
    `BUS_IF__CREATE_BUS(sm0_dm, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE);
    `BUS_IF__CREATE_BUS(sm1_im, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE);
    `BUS_IF__CREATE_BUS(sm1_dm, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE);
    `BUS_IF__CREATE_BUS(hab,    `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE);

    //// Slaves
    `BUS_IF__CREATE_BUS(cm0_a, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE);
    `BUS_IF__CREATE_BUS(cm0_b, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE);
    `BUS_IF__CREATE_BUS(cm1_a, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE);
    `BUS_IF__CREATE_BUS(cm1_b, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE);
    `BUS_IF__CREATE_BUS(smc,   `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE);

    //// Memory banks
    `BUS_IF__CREATE_MEM_BANK(im0, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE, `SYSTEM__MEM_SM0_IMEM, `SYSTEM__MEM_IMEM_SIZE, "");
    `BUS_IF__CREATE_MEM_BANK(dm0, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE, `SYSTEM__MEM_SM0_DMEM, `SYSTEM__MEM_DMEM_SIZE, "");
    `BUS_IF__CREATE_MEM_BANK(im1, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE, `SYSTEM__MEM_SM1_IMEM, `SYSTEM__MEM_IMEM_SIZE, "");
    `BUS_IF__CREATE_MEM_BANK(dm1, `SYSTEM__MEM_DWIDTH, `SYSTEM__MEM_AWIDTH, `SYSTEM__MEM_BSIZE, `SYSTEM__MEM_SM1_DMEM, `SYSTEM__MEM_DMEM_SIZE, "");

    bus_matrix bus_matrix (
        .clk   (clk),
        .rst   (rst),
        .sm0_im(sm0_im),
        .sm0_dm(sm0_dm),
        .sm1_im(sm1_im),
        .sm1_dm(sm1_dm),
        .hab   (hab),
        .im0_a (im0_a),
        .im0_b (im0_b),
        .dm0_a (dm0_a),
        .dm0_b (dm0_b),
        .cm0_a (cm0_a),
        .cm0_b (cm0_b),
        .im1_a (im1_a),
        .im1_b (im1_b),
        .dm1_a (dm1_a),
        .dm1_b (dm1_b),
        .cm1_a (cm1_a),
        .cm1_b (cm1_b),
        .smc   (smc)
    );

    //// HAB

    hab #(
        .BusWidth     (`SYSTEM__MEM_DWIDTH_CORE),
        .ParallelWidth(`SYSTEM__SERIAL_NSPI_WIDTH),
        .FifoDepth    (`SYSTEM__SERIAL_FIFO_DEPTH),
        .NSPIInstances(`SYSTEM__SERIAL_NSPI_INSTANCES)
    ) hab_ctl (
        .clk      (clk),
        .rst      (rst),
        .bus      (hab),
        .nspi_clk (hab_clk[0]),
        .nspi_mosi(hab_mosi),
        .nspi_miso(hab_miso)
    );

endmodule
