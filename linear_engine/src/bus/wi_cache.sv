`include "../interfaces/bus_if.svh"

module  wi_cache (
    input clk,
    input rst,

    bus_if.master master,
    bus_if.slave  slave
);
    localparam int MasterDataWidth    = $bits(master.data_ctp);
    localparam int MasterAddressWidth = $bits(master.address);
    localparam int SlaveDataWidth     = $bits(slave.data_ctp);
    localparam int SlaveAddressWidth  = $bits(slave.address);
    localparam int BufferAddressWidth = SlaveAddressWidth - MasterAddressWidth;
    localparam int SlaveBytesPerWord  = $bits(slave.byte_enable);

    reg                          read_hit;
    reg                          read_miss;
    reg [MasterAddressWidth-1:0] read_master_address;
    reg [BufferAddressWidth-1:0] read_address;

    reg                          valid;
    reg [MasterAddressWidth-1:0] tag;
    reg [   MasterDataWidth-1:0] data;

    wire [BufferAddressWidth-1:0] buffer_address = slave.address[BufferAddressWidth-1:0];
    wire [MasterAddressWidth-1:0] master_address = slave.address[SlaveAddressWidth-1:BufferAddressWidth];

    wire hit = valid && (tag == master_address) && slave.read;

    assign master.data_ctp    = slave.data_ctp    << (buffer_address * SlaveDataWidth);
    assign master.address     = master_address;
    assign master.byte_enable = slave.byte_enable << (buffer_address * SlaveBytesPerWord);
    assign master.read        = slave.read && !hit;
    assign master.write       = slave.write;

    assign slave.data_ptc    = (read_hit ? data : master.data_ptc) >> (read_address * SlaveDataWidth);
    assign slave.hit_address = '0;
    assign slave.hit_mask    = '0;
    assign slave.hit         = hit || master.hit;
    assign slave.complete    = hit || master.complete;
    assign slave.error       = hit ? '0 : master.error;

    always @(posedge clk) begin
        read_hit            <=  hit;
        read_miss           <= !hit && slave.read;
        read_master_address <= master_address;
        read_address        <= buffer_address;
        if (read_miss) begin
            valid <= '1;
            tag   <= read_master_address;
            data  <= master.data_ptc;
        end
        if (slave.write) begin
            valid <= '0;
        end
        if (rst) begin
            read_hit            <= '0;
            read_miss           <= '0;
            read_master_address <= '0;
            read_address        <= '0;
            valid               <= '0;
            tag                 <= '0;
            data                <= '0;
        end
    end

endmodule
