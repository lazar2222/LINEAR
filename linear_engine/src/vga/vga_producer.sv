`include "../interfaces/bus_if.svh"
`include "../interfaces/parallel_if.svh"

module vga_producer #(
    parameter int SCREEN_WIDTH,
    parameter int SCREEN_HEIGHT,
    parameter int LOCAL_WORD_WIDTH,
    `PARALLEL_IF__UNI_PARAMS(output_port),
    `BUS_IF__PARAMS(bus)
) (
    input clk,
    input rst,

    `PARALLEL_IF__UNI_TX_PORTS(output_port),
    `BUS_IF__MASTER_PORTS(bus),

    input strobe,

    input [BYTE_ADDRESS_WIDTH_bus-1:0] base_address,
    
    input       compact,
    input       mono,
    input [1:0] pixel_width_select,
    
    output overflow,
    output miss,
    output error
);
    localparam int WORDS_PER_READ = DATA_WIDTH_bus / LOCAL_WORD_WIDTH;
    localparam int WIDTH_BITS     = $clog2(SCREEN_WIDTH);
    localparam int HEIGHT_BITS    = $clog2(SCREEN_HEIGHT);

    reg reading, waiting;

    reg [            WIDTH_BITS-1:0] x;
    reg [           HEIGHT_BITS-1:0] y;
    reg [WORD_ADDRESS_WIDTH_bus-1:0] counter;

    wire [5:0] components_per_word = LOCAL_WORD_WIDTH >> pixel_width_select;
    wire [5:0] pixels_per_word     = mono ? components_per_word : (components_per_word >> 2);

    wire [WORD_ADDRESS_WIDTH_bus-1:0] sparse_address_unadjusted = {y, x};
    wire [WORD_ADDRESS_WIDTH_bus-1:0] sparse_address_adjusted   = sparse_address_unadjusted >> ($clog2(WORDS_PER_READ) + $clog2(LOCAL_WORD_WIDTH) - (mono ? 0 : 2'd2) - pixel_width_select);
    wire [WORD_ADDRESS_WIDTH_bus-1:0] sparse_address            = sparse_address_adjusted | (base_address >> $clog2(WORD_SIZE_bus));

    assign overflow = (strobe && reading) || (strobe && !reading && !output_port_ready);
    assign miss     = bus_read && !bus_hit;
    assign error    = bus_read &&  bus_hit && bus_error;

    assign bus_data_ctp    = '0;
    assign bus_address     = compact ? counter : sparse_address;
    assign bus_byte_enable = '0;
    assign bus_read        = reading && output_port_ready && !waiting;
    assign bus_write       = '0;

    assign output_port_data  = bus_data_ptc;
    assign output_port_valid = waiting;

    always @(posedge clk) begin
        if (strobe && !reading) begin
            reading <= '1;
            waiting <= '0;
            x       <= '0;
            y       <= '0;
            counter <= base_address >> $clog2(WORD_SIZE_bus);
        end
        if (bus_read && bus_complete) begin
           waiting <= '1; 
        end
        if (waiting) begin
            waiting <= '0;
            counter <= counter + 1'd1;
            x       <= x + (WORDS_PER_READ * pixels_per_word);
            if (x + (WORDS_PER_READ  * pixels_per_word) == SCREEN_WIDTH) begin
                x <= '0;
                y <= y + 1'd1;
                if (y + 1'd1 == SCREEN_HEIGHT) begin
                    y       <= '0;
                    reading <= '0;
                end
            end
        end
        if (rst) begin
            reading <= '0;
            waiting <= '0;
            x       <= '0;
            y       <= '0;
            counter <= '0;
        end
    end

endmodule
