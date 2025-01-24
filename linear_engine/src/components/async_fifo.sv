`include "../interfaces/parallel_if.svh"

module async_fifo #(
    parameter int DEPTH,
    `PARALLEL_IF__UNI_PARAMS(write_port),
    `PARALLEL_IF__UNI_PARAMS(read_port)
) (
    input read_clk,
    input write_clk,
    input rst,

    `PARALLEL_IF__UNI_RX_PORTS(write_port),
    `PARALLEL_IF__UNI_TX_PORTS(read_port)
);
    localparam int WRITE_WIDTH      = DATA_WIDTH_write_port;
    localparam int READ_WIDTH       = DATA_WIDTH_read_port;
    localparam int BIT_DEPTH        = DEPTH * WRITE_WIDTH;
    localparam int WRITE_DEPTH      = BIT_DEPTH / WRITE_WIDTH;
    localparam int READ_DEPTH       = BIT_DEPTH / READ_WIDTH;
    localparam int WRITE_DEPTH_BITS = $clog2(WRITE_DEPTH);
    localparam int READ_DEPTH_BITS  = $clog2(READ_DEPTH);

    wire read_port_empty;
    wire write_port_full;

    assign read_port_valid  = !read_port_empty;
    assign write_port_ready = !write_port_full;

    dcfifo_mixed_widths #(
        .lpm_width             (WRITE_WIDTH),
        .lpm_width_r           (READ_WIDTH),
        .lpm_widthu            (WRITE_DEPTH_BITS),
        .lpm_widthu_r          (READ_DEPTH_BITS),
        .lpm_numwords          (DEPTH),
        .rdsync_delaypipe      (4),
        .wrsync_delaypipe      (4),
        .overflow_checking     ("OFF"),
        .underflow_checking    ("OFF"),
        .read_aclr_synch       ("OFF"),
        .write_aclr_synch      ("ON"),
        .lpm_showahead         ("ON"),
        .use_eab               ("ON"),
        .lpm_type              ("dcfifo_mixed_widths"),
        .intended_device_family("Cyclone V")
    ) dcfifo_mixed_widths (
        .rdclk    (read_clk),
        .q        (read_port_data),
        .rdreq    (read_port_ready),
        .rdempty  (read_port_empty),
        .rdfull   (),
        .rdusedw  (),
        .wrclk    (write_clk),
        .data     (write_port_data),
        .wrreq    (write_port_valid),
        .wrfull   (write_port_full),
        .wrempty  (),
        .wrusedw  (),
        .aclr     (rst),
        .eccstatus()        
    );
endmodule
