module testbench ();

    reg clk;
    reg rst;

    always #50 clk = !clk;

    initial begin
        clk = 1'b1;
        rst = 1'b1;
        #100;
        rst = 1'b0;
    end

    wire [3:0] key = {3'b111, !rst};
    wire [9:0] led;

    wire vga_hs, vga_vs, vga_clk, vga_sync_n, vga_blank_n;
    wire [7:0] vga_r, vga_g, vga_b;

    top #(
        .PLL(0)
    ) top (
        .clock_50   (clk),
        .key        (key),
        .led        (led),
        .vga_hs     (vga_hs),
        .vga_vs     (vga_vs),
        .vga_clk    (vga_clk),
        .vga_sync_n (vga_sync_n),
        .vga_blank_n(vga_blank_n),
        .vga_r      (vga_r),
        .vga_g      (vga_g),
        .vga_b      (vga_b)
    );

endmodule
