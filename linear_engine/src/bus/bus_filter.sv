`include "../interfaces/bus_if.svh"

module bus_filter #(
    parameter int BASE_ADDRESS = '0,
    parameter int SIZE_BYTES   = '1,
    `BUS_IF__PARAMS(slave),
    `BUS_IF__PARAMS(master)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(slave),
    `BUS_IF__MASTER_PORTS(master)
);
    localparam int DATA_WIDTH               = DATA_WIDTH_slave;
    localparam int BYTE_ADDRESS_WIDTH       = BYTE_ADDRESS_WIDTH_slave;
    localparam int BYTE_WIDTH               = BYTE_WIDTH_slave;
    localparam int WORD_SIZE                = WORD_SIZE_slave;
    localparam int WORD_ADDRESS_WIDTH       = WORD_ADDRESS_WIDTH_slave;
    localparam int SIZE_WORDS               = SIZE_BYTES / WORD_SIZE;
    localparam int LOCAL_ADDRESS_WIDTH      = $clog2(SIZE_WORDS);
    localparam int LOCAL_BYTE_ADDRESS_WIDTH = $clog2(SIZE_BYTES);
    localparam int DEVICE_ADDRESS_WIDTH     = WORD_ADDRESS_WIDTH - LOCAL_ADDRESS_WIDTH;
    localparam int DEVICE_ADDRESS           = BASE_ADDRESS[BYTE_ADDRESS_WIDTH-1:LOCAL_BYTE_ADDRESS_WIDTH];

    wire [WORD_ADDRESS_WIDTH-1:0] hit_address;
    wire [WORD_ADDRESS_WIDTH-1:0] hit_mask;
    wire [WORD_ADDRESS_WIDTH-1:0] address_mask;

    generate
        if (BASE_ADDRESS == '0 && SIZE_BYTES == '1) begin
            assign hit_address  = master_hit_address;
            assign hit_mask     = master_hit_mask;
            assign address_mask = '1;
        end else begin
            assign hit_address  = {DEVICE_ADDRESS, {LOCAL_ADDRESS_WIDTH{1'b0}}};
            assign hit_mask     = {{DEVICE_ADDRESS_WIDTH{1'b1}}, {LOCAL_ADDRESS_WIDTH{1'b0}}};
            assign address_mask = {{DEVICE_ADDRESS_WIDTH{1'b0}}, {LOCAL_ADDRESS_WIDTH{1'b1}}};
        end
    endgenerate

    wire hit_next = (slave_address & hit_mask) == hit_address;
    reg  hit_reg;

    assign slave_data_ptc    = hit_reg  ? master_data_ptc : 'z;
    assign slave_hit         = hit_next ? master_hit      : 'z;
    assign slave_complete    = hit_next ? master_complete : 'z;
    assign slave_error       = hit_next ? master_error    : 'z;
    assign slave_hit_address = '0;
    assign slave_hit_mask    = '0;

    assign master_data_ctp    = slave_data_ctp;
    assign master_address     = slave_address & address_mask;
    assign master_byte_enable = slave_byte_enable;
    assign master_read        = hit_next && slave_read;
    assign master_write       = hit_next && slave_write;

    always @(posedge clk) begin
        hit_reg <= hit_next;
        if (rst) begin
            hit_reg <= '0;
        end
    end

endmodule
