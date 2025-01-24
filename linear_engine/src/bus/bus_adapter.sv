`include "../interfaces/bus_if.svh"

module bus_adapter #(
    `BUS_IF__PARAMS(slave),
    `BUS_IF__PARAMS(master)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(slave),
    `BUS_IF__MASTER_PORTS(master)
);
    localparam int BYTE_ADDRESS_WIDTH   = BYTE_ADDRESS_WIDTH_master;
    localparam int BYTE_WIDTH           = BYTE_WIDTH_master;
    localparam int DATA_WIDTH_m         = DATA_WIDTH_master;
    localparam int DATA_WIDTH_s         = DATA_WIDTH_slave;
    localparam int WORD_SIZE_m          = WORD_SIZE_master;
    localparam int WORD_SIZE_s          = WORD_SIZE_slave;
    localparam int WORD_ADDRESS_WIDTH_m = WORD_ADDRESS_WIDTH_master;
    localparam int WORD_ADDRESS_WIDTH_s = WORD_ADDRESS_WIDTH_slave;
    localparam int OFFSET_BITS          = WORD_ADDRESS_WIDTH_s - WORD_ADDRESS_WIDTH_m;

    wire [OFFSET_BITS-1:0] offset_next = slave_address[OFFSET_BITS-1:0];
    reg  [OFFSET_BITS-1:0] offset_reg;

    assign slave_data_ptc    = master_hit ? master_data_ptc >> (offset_reg  * DATA_WIDTH_s) : 'z;
    assign slave_hit_address = master_hit_address << OFFSET_BITS;
    assign slave_hit_mask    = master_hit_mask    << OFFSET_BITS;
    assign slave_hit         = master_hit;
    assign slave_complete    = master_complete;
    assign slave_error       = master_error;
    
    assign master_data_ctp    = slave_data_ctp    << (offset_next * DATA_WIDTH_s);
    assign master_address     = slave_address     >> OFFSET_BITS;
    assign master_byte_enable = slave_byte_enable << (offset_next * WORD_SIZE_s);
    assign master_read        = slave_read;
    assign master_write       = slave_write;

    always @(posedge clk) begin
        offset_reg <= offset_next;
        if (rst) begin
            offset_reg <= '0;
        end
    end

endmodule
