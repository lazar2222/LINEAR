`include "../interfaces/bus_if.svh"

module dummy_bus_slave #(
    parameter int BaseAddress,
    parameter int SizeBytes
) (
    input clk,
    input rst,

    bus_if.slave port_a,
    bus_if.slave port_b
);
    localparam int DataWidth             = $bits(port_a.data_ctp);
    localparam int AddressWidth          = $bits(port_a.address);
    localparam int BytesPerWord          = $bits(port_a.byte_enable);
    localparam int ByteSize              = DataWidth / BytesPerWord;
    localparam int SizeWords             = SizeBytes / BytesPerWord;
    localparam int ByteAddressWidth      = AddressWidth + $clog2(BytesPerWord);
    localparam int LocalAddressWidth     = $clog2(SizeWords);
    localparam int LocalByteAddressWidth = LocalAddressWidth + $clog2(BytesPerWord);
    localparam int DeviceAddressWidth    = AddressWidth - LocalAddressWidth;
    localparam int DeviceAddress         = BaseAddress[ByteAddressWidth-1:LocalByteAddressWidth];

    reg read_hit_a, read_hit_b;
    reg [DataWidth-1:0] data_out_a;
    reg [DataWidth-1:0] data_out_b;

    wire [DeviceAddressWidth-1:0] device_address_a = port_a.address[AddressWidth-1:LocalAddressWidth];
    wire [ LocalAddressWidth-1:0] local_address_a  = port_a.address[LocalAddressWidth-1:0];
    wire [DeviceAddressWidth-1:0] device_address_b = port_b.address[AddressWidth-1:LocalAddressWidth];
    wire [ LocalAddressWidth-1:0] local_address_b  = port_b.address[LocalAddressWidth-1:0];

    wire write_hit_a = port_a.hit && port_a.write;
    wire write_hit_b = port_b.hit && port_b.write;

    assign port_a.data_ptc    = read_hit_a ? data_out_a : 'z;
    assign port_b.data_ptc    = read_hit_b ? data_out_b : 'z;
    assign port_a.hit_address = {DeviceAddress, {LocalAddressWidth{1'b0}}};
    assign port_b.hit_address = {DeviceAddress, {LocalAddressWidth{1'b0}}};
    assign port_a.hit_mask    = {{DeviceAddressWidth{1'b1}}, {LocalAddressWidth{1'b0}}};
    assign port_b.hit_mask    = {{DeviceAddressWidth{1'b1}}, {LocalAddressWidth{1'b0}}};
    assign port_a.hit         = device_address_a == DeviceAddress;
    assign port_b.hit         = device_address_b == DeviceAddress;
    assign port_a.complete    = port_a.hit && (port_a.read || port_a.write);
    assign port_b.complete    = port_b.hit && (port_b.read || port_b.write);
    assign port_a.error       = write_hit_a && write_hit_b && (local_address_a == local_address_b);
    assign port_b.error       = write_hit_a && write_hit_b && (local_address_a == local_address_b);

    always @(posedge clk) begin
        read_hit_a <= port_a.hit && port_a.read;
        read_hit_b <= port_b.hit && port_b.read;
        data_out_a <= port_a.address;
        data_out_b <= port_b.address;
        if (rst) begin
            read_hit_a <= '0;
            read_hit_b <= '0;
            data_out_a <= '0;
            data_out_b <= '0;
        end
    end

endmodule
