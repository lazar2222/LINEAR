`include "../interfaces/bus_if.svh"

module periph_mem_interface #(
    parameter int BASE_ADDRESS,
    parameter int SIZE_WORDS,
    `BUS_IF__PARAMS(port)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(port),

    input  [SIZE_WORDS*DATA_WIDTH_port-1:0] data_periph_in,
    output [           DATA_WIDTH_port-1:0] data_periph_out,
    output [                SIZE_WORDS-1:0] data_periph_write
);
    localparam int DATA_WIDTH               = DATA_WIDTH_port;
    localparam int BYTE_ADDRESS_WIDTH       = BYTE_ADDRESS_WIDTH_port;
    localparam int BYTE_WIDTH               = BYTE_WIDTH_port;
    localparam int WORD_SIZE                = WORD_SIZE_port;
    localparam int WORD_ADDRESS_WIDTH       = WORD_ADDRESS_WIDTH_port;
    localparam int SIZE_BYTES               = SIZE_WORDS * WORD_SIZE;
    localparam int LOCAL_ADDRESS_WIDTH      = $clog2(SIZE_WORDS);
    localparam int LOCAL_BYTE_ADDRESS_WIDTH = $clog2(SIZE_BYTES);
    localparam int DEVICE_ADDRESS_WIDTH     = WORD_ADDRESS_WIDTH - LOCAL_ADDRESS_WIDTH;
    localparam int DEVICE_ADDRESS           = BASE_ADDRESS[BYTE_ADDRESS_WIDTH-1:LOCAL_BYTE_ADDRESS_WIDTH];

    wire [DEVICE_ADDRESS_WIDTH-1:0]                 device_address = port_address[WORD_ADDRESS_WIDTH-1:LOCAL_ADDRESS_WIDTH];
    wire [ LOCAL_ADDRESS_WIDTH-1:0]                 local_address  = port_address[LOCAL_ADDRESS_WIDTH-1:0];
    wire [           WORD_SIZE-1:0]                 byte_enable    = port_byte_enable;
    wire [          DATA_WIDTH-1:0]                 data_in        = port_data_ctp;
    wire [          DATA_WIDTH-1:0]                 data_mask;
    reg  [          DATA_WIDTH-1:0]                 data_out;
    wire [          SIZE_WORDS-1:0][DATA_WIDTH-1:0] data_periph;

    wire hit       = device_address == DEVICE_ADDRESS;
    wire read_hit  = hit && port_read;
    wire write_hit = hit && port_write;

    reg read_hit_reg;

    assign port_data_ptc    = read_hit_reg ? data_out : 'z;
    assign port_hit_address = {DEVICE_ADDRESS, {LOCAL_ADDRESS_WIDTH{1'b0}}};
    assign port_hit_mask    = {{DEVICE_ADDRESS_WIDTH{1'b1}}, {LOCAL_ADDRESS_WIDTH{1'b0}}};
    assign port_hit         = hit ? '1 : 'z;
    assign port_complete    = hit ? (read_hit || write_hit) : 'z;
    assign port_error       = hit ? '0 : 'z;
    assign data_periph_out  = (data_in & data_mask) | (data_periph[local_address] & ~data_mask);

    always @(posedge clk) begin
        read_hit_reg <= read_hit;
        data_out     <= data_periph[local_address];
        if (rst) begin
            read_hit_reg <= '0;
            data_out     <= '0;
        end
    end

    genvar i;
    generate
        for (i = 0; i < WORD_SIZE; i++) begin : g_mask
            assign data_mask[BYTE_WIDTH*i+:BYTE_WIDTH] = {BYTE_WIDTH{byte_enable[i]}};
        end
        for (i = 0; i < SIZE_WORDS; i++) begin : g_write
            assign data_periph_write[i] = local_address == i && write_hit;
            assign data_periph[i]       = data_periph_in[DATA_WIDTH*i+:DATA_WIDTH];
        end
    endgenerate

endmodule
