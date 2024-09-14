`include "../interfaces/bus_if.svh"

module mem_bank #(
    parameter int BaseAddress,
    parameter int SizeBytes,
    parameter     InitFile
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

    wire [DeviceAddressWidth-1:0] device_address_a = port_a.address[AddressWidth-1:LocalAddressWidth];
    wire [ LocalAddressWidth-1:0] local_address_a  = port_a.address[LocalAddressWidth-1:0];
    wire [      BytesPerWord-1:0] byte_enable_a    = port_a.byte_enable;
    wire [         DataWidth-1:0] data_in_a        = port_a.data_ctp;
    wire [         DataWidth-1:0] data_out_a;
    wire [DeviceAddressWidth-1:0] device_address_b = port_b.address[AddressWidth-1:LocalAddressWidth];
    wire [ LocalAddressWidth-1:0] local_address_b  = port_b.address[LocalAddressWidth-1:0];
    wire [      BytesPerWord-1:0] byte_enable_b    = port_b.byte_enable;
    wire [         DataWidth-1:0] data_in_b        = port_b.data_ctp;
    wire [         DataWidth-1:0] data_out_b;

    reg read_hit_a, read_hit_b;

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
        if (rst) begin
            read_hit_a <= '0;
            read_hit_b <= '0;
        end
    end

    altsyncram #(
        .byte_size                         (ByteSize),
        .numwords_a                        (SizeWords),
        .numwords_b                        (SizeWords),
        .widthad_a                         (LocalAddressWidth),
        .widthad_b                         (LocalAddressWidth),
        .width_a                           (DataWidth),
        .width_b                           (DataWidth),
        .width_byteena_a                   (BytesPerWord),
        .width_byteena_b                   (BytesPerWord),
        .clock_enable_input_a              ("BYPASS"),
        .clock_enable_input_b              ("BYPASS"),
        .clock_enable_output_a             ("BYPASS"),
        .clock_enable_output_b             ("BYPASS"),
        .outdata_aclr_a                    ("NONE"),
        .outdata_aclr_b                    ("NONE"),
        .outdata_reg_a                     ("UNREGISTERED"),
        .outdata_reg_b                     ("UNREGISTERED"),
        .read_during_write_mode_port_a     ("DONT_CARE"),
        .read_during_write_mode_port_b     ("DONT_CARE"),
        .read_during_write_mode_mixed_ports("OLD_DATA"),
        .init_file                         (InitFile),
        .lpm_type                          ("altsyncram"),
        .intended_device_family            ("Cyclone V"),
        .operation_mode                    ("BIDIR_DUAL_PORT"),
        .power_up_uninitialized            ("FALSE"),
        .address_reg_b                     ("CLOCK0"),
        .byteena_reg_b                     ("CLOCK0"),
        .indata_reg_b                      ("CLOCK0"),
        .wrcontrol_wraddress_reg_b         ("CLOCK0")
    ) ram (
        .address_a     (local_address_a),
        .address_b     (local_address_b),
        .byteena_a     (byte_enable_a),
        .byteena_b     (byte_enable_b),
        .clock0        (clk),
        .data_a        (data_in_a),
        .data_b        (data_in_b),
        .wren_a        (write_hit_a),
        .wren_b        (write_hit_b),
        .q_a           (data_out_a),
        .q_b           (data_out_b),
        .aclr0         ('0),
        .aclr1         ('0),
        .addressstall_a('0),
        .addressstall_b('0),
        .clock1        ('1),
        .clocken0      ('1),
        .clocken1      ('1),
        .clocken2      ('1),
        .clocken3      ('1),
        .eccstatus     (),
        .rden_a        ('1),
        .rden_b        ('1)
    );

endmodule
