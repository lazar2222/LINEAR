`include "../interfaces/bus_if.svh"
`include "../interfaces/parallel_if.svh"

`define VGA_CONTROLLER_SYNC(signal) \
    wire [$bits(signal)-1:0] ``signal``_sync; \
    synchronizer #(                           \
        .WIDTH($bits(signal)),                \
        .DEPTH(2)                             \
    ) sync_``signal`` (                       \
        .dest_clk(vga_clk),                   \
        .dest_reset(rst),                     \
        .in      (signal),                    \
        .out     (``signal``_sync)            \
    )                                         \

`define VGA_CONTROLLER_SYNC_INVERSE(signal) \
    wire [$bits(signal)-1:0] ``signal``_sync; \
    synchronizer #(                           \
        .WIDTH($bits(signal)),                \
        .DEPTH(2)                             \
    ) sync_``signal`` (                       \
        .dest_clk(clk),                       \
        .dest_reset(rst),                     \
        .in      (signal),                    \
        .out     (``signal``_sync)            \
    )                                         \

module vga_controller #(
    parameter int HORIZONTAL_VISIBLE_AREA,
    parameter int HORIZONTAL_FRONT_PORCH,
    parameter int HORIZONTAL_SYNC_PULSE,
    parameter int HORIZONTAL_BACK_PORCH,
    parameter int VERTICAL_VISIBLE_AREA,
    parameter int VERTICAL_FRONT_PORCH,
    parameter int VERTICAL_SYNC_PULSE,
    parameter int VERTICAL_BACK_PORCH,
    parameter int OUTPUT_COMPONENT_WIDTH,
    parameter int CONFIG_BASE_ADDRESS,
    parameter int FIFO_DEPTH,
    `BUS_IF__PARAMS(master),
    `BUS_IF__PARAMS(config_port)
) (
    input clk,
    input rst,

    input vga_clk,

    `BUS_IF__MASTER_PORTS(master),
    `BUS_IF__SLAVE_PORTS(config_port),

    output vga_hs,
    output vga_vs,
    output vga_clock,
    output vga_sync_n,
    output vga_blank_n,

    output [OUTPUT_COMPONENT_WIDTH-1:0] vga_r,
    output [OUTPUT_COMPONENT_WIDTH-1:0] vga_g,
    output [OUTPUT_COMPONENT_WIDTH-1:0] vga_b,

    output overflow,
    output underflow,
    output miss,
    output error
);
    localparam int SIZE_WORDS       = 2;
    localparam int LOCAL_WORD_WIDTH = 4 * OUTPUT_COMPONENT_WIDTH;
    localparam int HORIZONTAL_WHOLE = HORIZONTAL_VISIBLE_AREA + HORIZONTAL_FRONT_PORCH + HORIZONTAL_SYNC_PULSE + HORIZONTAL_BACK_PORCH;
    localparam int VERTICAL_WHOLE   = VERTICAL_VISIBLE_AREA   + VERTICAL_FRONT_PORCH   + VERTICAL_SYNC_PULSE   + VERTICAL_BACK_PORCH;
    localparam int HORIZONTAL_BITS  = $clog2(HORIZONTAL_WHOLE);
    localparam int VERTICAL_BITS    = $clog2(VERTICAL_WHOLE);
    localparam int PWS_BITS         = $clog2($clog2(LOCAL_WORD_WIDTH)-1);

    `PARALLEL_IF__UNI(fifo_write, DATA_WIDTH_master)
    `PARALLEL_IF__UNI(fifo_read,  LOCAL_WORD_WIDTH)

    reg  [BYTE_ADDRESS_WIDTH_master-1:0] base_address;
    reg                                  enable;
    reg                                  compact;
    reg                                  mono;
    reg  [                 PWS_BITS-1:0] pixel_width_select;

    wire [  DATA_WIDTH_config_port-1:0] base_address_mem = base_address;
    wire [2*DATA_WIDTH_config_port-1:0] memory           = {pixel_width_select, mono, compact, enable, base_address_mem};
    wire [  DATA_WIDTH_config_port-1:0] memory_data;
    wire [                         1:0] memory_write;

    wire [HORIZONTAL_BITS-1:0] x;
    wire [  VERTICAL_BITS-1:0] y;
    wire                       visible_area;
    wire                       start_fill;

    reg start_fill_reg;

    wire strobe;
    wire underflow_ns;

    wire vga_rst_n = !(rst || !enable);

    `VGA_CONTROLLER_SYNC(vga_rst_n);
    `VGA_CONTROLLER_SYNC(mono);
    `VGA_CONTROLLER_SYNC(pixel_width_select);
    `VGA_CONTROLLER_SYNC_INVERSE(start_fill);
    `VGA_CONTROLLER_SYNC_INVERSE(underflow_ns);

    assign strobe = start_fill_sync && !start_fill_reg;

    assign vga_clock   = vga_clk;
    assign vga_sync_n  = '0;
    assign vga_blank_n = visible_area;

    assign underflow = underflow_ns_sync;

    always @(posedge clk) begin
        start_fill_reg <= start_fill_sync;
        if (memory_write[0]) begin
            base_address <= memory_data;
        end
        if (memory_write[1]) begin
            enable             <= memory_data[0];
            compact            <= memory_data[1];
            mono               <= memory_data[2];
            pixel_width_select <= memory_data[3+:PWS_BITS];
        end
        if (rst) begin
            base_address       <= '0;
            enable             <= '0;
            compact            <= '0;
            mono               <= '0;
            pixel_width_select <= '0;
            start_fill_reg     <= '0;
        end
    end

    periph_mem_interface #(
        .BASE_ADDRESS       (CONFIG_BASE_ADDRESS),
        .SIZE_WORDS         (SIZE_WORDS),
        `BUS_IF__FILL_PARAMS(port, config_port)
    ) config_port (
        .clk              (clk),
        .rst              (rst),
        `BUS_IF__CONNECT  (port, config_port),
        .data_periph_in   (memory),
        .data_periph_out  (memory_data),
        .data_periph_write(memory_write)
    );

    sync_gen #(
        .HORIZONTAL_VISIBLE_AREA(HORIZONTAL_VISIBLE_AREA),
        .HORIZONTAL_FRONT_PORCH (HORIZONTAL_FRONT_PORCH),
        .HORIZONTAL_SYNC_PULSE  (HORIZONTAL_SYNC_PULSE),
        .HORIZONTAL_BACK_PORCH  (HORIZONTAL_BACK_PORCH),
        .VERTICAL_VISIBLE_AREA  (VERTICAL_VISIBLE_AREA),
        .VERTICAL_FRONT_PORCH   (VERTICAL_FRONT_PORCH),
        .VERTICAL_SYNC_PULSE    (VERTICAL_SYNC_PULSE),
        .VERTICAL_BACK_PORCH    (VERTICAL_BACK_PORCH)
    ) sync_gen (
        .clk         (vga_clk),
        .rst         (!vga_rst_n_sync),
        .x           (x),
        .y           (y),
        .h_sync      (vga_hs),
        .v_sync      (vga_vs),
        .visible_area(visible_area),
        .start_fill  (start_fill)
    );

    vga_producer #(
        .SCREEN_WIDTH                (HORIZONTAL_VISIBLE_AREA),
        .SCREEN_HEIGHT               (VERTICAL_VISIBLE_AREA),
        .LOCAL_WORD_WIDTH            (LOCAL_WORD_WIDTH),
        `PARALLEL_IF__UNI_FILL_PARAMS(output_port, fifo_write),
        `BUS_IF__FILL_PARAMS         (bus, master)
    ) vga_producer (
            .clk                     (clk),
            .rst                     (!vga_rst_n),
            `PARALLEL_IF__UNI_CONNECT(output_port, fifo_write),
            `BUS_IF__CONNECT         (bus, master),
            .strobe                  (strobe),
            .base_address            (base_address),
            .compact                 (compact),
            .mono                    (mono),
            .pixel_width_select      (pixel_width_select),
            .overflow                (overflow),
            .miss                    (miss),
            .error                   (error)
    );

    async_fifo #(
        .DEPTH(FIFO_DEPTH),
        `PARALLEL_IF__UNI_FILL_PARAMS(write_port, fifo_write),
        `PARALLEL_IF__UNI_FILL_PARAMS(read_port, fifo_read)
    ) async_fifo (
        .read_clk                (vga_clk),
        .write_clk               (clk),
        .rst                     (!vga_rst_n),
        `PARALLEL_IF__UNI_CONNECT(write_port, fifo_write),
        `PARALLEL_IF__UNI_CONNECT(read_port, fifo_read)
    );

    vga_consumer #(
        .OUTPUT_COMPONENT_WIDTH      (OUTPUT_COMPONENT_WIDTH),
        `PARALLEL_IF__UNI_FILL_PARAMS(input_port, fifo_read)
    ) vga_consumer (
        .clk                     (vga_clk),
        .rst                     (!vga_rst_n_sync),
        `PARALLEL_IF__UNI_CONNECT(input_port, fifo_read),
        .visible_area            (visible_area),
        .mono                    (mono_sync),
        .pixel_width_select      (pixel_width_select_sync),
        .r                       (vga_r),
        .g                       (vga_g),
        .b                       (vga_b),
        .underflow               (underflow_ns)
    );

endmodule
