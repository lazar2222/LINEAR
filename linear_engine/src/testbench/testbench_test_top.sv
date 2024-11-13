module testbench_test_top ();

    reg clk;
    reg rst;

    always #50 clk = !clk;

    initial begin
        clk = '1;
        rst = '1;
        #100;
        rst = '0;
    end

    wire [3:0] key = {3'b111, !rst};
    wire [9:0] sw  = '1;
    wire [9:0] led;

    wire       vga_hs, vga_vs, vga_clk, vga_sync_n, vga_blank_n;
    wire [7:0] vga_r, vga_g, vga_b;
    wire sim_tx, cam_tx, cam_int, hab_power, hab_int;

    wire sim_rx    = '0;
    wire cam_rx    = '0;
    wire hab_reset = '0;

    wire [3:0] hab_clk;
    wire [3:0] hab_mosi;
    wire [3:0] hab_miso;

    dummy_nspi_master #(
        .DataWidth     (32),
        .InstanceCount (4),
        .ClockDivFactor(8)
    ) dummy_nspi_master (
        .clk      (clk),
        .rst      (rst),
        .nspi_clk (hab_clk),
        .nspi_mosi(hab_mosi),
        .nspi_miso(hab_miso)
    );

    test_top #(
        .PLL(0)
    ) test_top (
        .clock_50   (clk),
        .key        (key),
        .sw         (sw),
        .led        (led),
        .vga_hs     (vga_hs),
        .vga_vs     (vga_vs),
        .vga_clk    (vga_clk),
        .vga_sync_n (vga_sync_n),
        .vga_blank_n(vga_blank_n),
        .vga_r      (vga_r),
        .vga_g      (vga_g),
        .vga_b      (vga_b),
        .sim_rx     (sim_rx),
        .sim_tx     (sim_tx),
        .cam_rx     (cam_rx),
        .cam_tx     (cam_tx),
        .cam_int    (cam_int),
        .hab_clk    (hab_clk),
        .hab_mosi   (hab_mosi),
        .hab_miso   (hab_miso),
        .hab_reset  (hab_reset),
        .hab_power  (hab_power),
        .hab_int    (hab_int)
    );

endmodule
