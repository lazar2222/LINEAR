`include "../interfaces/bus_if.svh"

module mem_bank #(
    parameter int BASE_ADDRESS,
    parameter int SIZE_BYTES,
    parameter     INIT_FILE,
    `BUS_IF__PARAMS(port_a),
    `BUS_IF__PARAMS(port_b)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(port_a),
    `BUS_IF__SLAVE_PORTS(port_b)
);
    localparam int DATA_WIDTH               = DATA_WIDTH_port_a;
    localparam int BYTE_ADDRESS_WIDTH       = BYTE_ADDRESS_WIDTH_port_a;
    localparam int BYTE_WIDTH               = BYTE_WIDTH_port_a;
    localparam int WORD_SIZE                = WORD_SIZE_port_a;
    localparam int WORD_ADDRESS_WIDTH       = WORD_ADDRESS_WIDTH_port_a;
    localparam int SIZE_WORDS               = SIZE_BYTES / WORD_SIZE;
    localparam int LOCAL_ADDRESS_WIDTH      = $clog2(SIZE_WORDS);
    localparam int LOCAL_BYTE_ADDRESS_WIDTH = $clog2(SIZE_BYTES);
    localparam int DEVICE_ADDRESS_WIDTH     = WORD_ADDRESS_WIDTH - LOCAL_ADDRESS_WIDTH;
    localparam int DEVICE_ADDRESS           = BASE_ADDRESS[BYTE_ADDRESS_WIDTH-1:LOCAL_BYTE_ADDRESS_WIDTH];

    wire [DEVICE_ADDRESS_WIDTH-1:0] device_address_a = port_a_address[WORD_ADDRESS_WIDTH-1:LOCAL_ADDRESS_WIDTH];
    wire [ LOCAL_ADDRESS_WIDTH-1:0] local_address_a  = port_a_address[LOCAL_ADDRESS_WIDTH-1:0];
    wire [           WORD_SIZE-1:0] byte_enable_a    = port_a_byte_enable;
    wire [          DATA_WIDTH-1:0] data_in_a        = port_a_data_ctp;
    wire [          DATA_WIDTH-1:0] data_out_a;
    wire [DEVICE_ADDRESS_WIDTH-1:0] device_address_b = port_b_address[WORD_ADDRESS_WIDTH-1:LOCAL_ADDRESS_WIDTH];
    wire [ LOCAL_ADDRESS_WIDTH-1:0] local_address_b  = port_b_address[LOCAL_ADDRESS_WIDTH-1:0];
    wire [           WORD_SIZE-1:0] byte_enable_b    = port_b_byte_enable;
    wire [          DATA_WIDTH-1:0] data_in_b        = port_b_data_ctp;
    wire [          DATA_WIDTH-1:0] data_out_b;

    wire hit_a       = device_address_a == DEVICE_ADDRESS;
    wire hit_b       = device_address_b == DEVICE_ADDRESS;
    wire read_hit_a  = hit_a && port_a_read;
    wire read_hit_b  = hit_b && port_b_read;
    wire write_hit_a = hit_a && port_a_write;
    wire write_hit_b = hit_b && port_b_write;

    reg read_hit_a_reg, read_hit_b_reg;

    assign port_a_data_ptc    = read_hit_a_reg ? data_out_a : 'z;
    assign port_b_data_ptc    = read_hit_b_reg ? data_out_b : 'z;
    assign port_a_hit_address = {DEVICE_ADDRESS, {LOCAL_ADDRESS_WIDTH{1'b0}}};
    assign port_b_hit_address = {DEVICE_ADDRESS, {LOCAL_ADDRESS_WIDTH{1'b0}}};
    assign port_a_hit_mask    = {{DEVICE_ADDRESS_WIDTH{1'b1}}, {LOCAL_ADDRESS_WIDTH{1'b0}}};
    assign port_b_hit_mask    = {{DEVICE_ADDRESS_WIDTH{1'b1}}, {LOCAL_ADDRESS_WIDTH{1'b0}}};
    assign port_a_hit         = hit_a ? '1                                                                   : 'z;
    assign port_b_hit         = hit_b ? '1                                                                   : 'z;
    assign port_a_complete    = hit_a ? (read_hit_a || write_hit_a)                                          : 'z;
    assign port_b_complete    = hit_b ? (read_hit_b || write_hit_b)                                          : 'z;
    assign port_a_error       = hit_a ? (write_hit_a && write_hit_b && (local_address_a == local_address_b)) : 'z;
    assign port_b_error       = hit_b ? (write_hit_a && write_hit_b && (local_address_a == local_address_b)) : 'z;

    always @(posedge clk) begin
        read_hit_a_reg <= read_hit_a;
        read_hit_b_reg <= read_hit_b;
        if (rst) begin
            read_hit_a_reg <= '0;
            read_hit_b_reg <= '0;
        end
    end

    altsyncram #(
        .byte_size                         (BYTE_WIDTH),
        .numwords_a                        (SIZE_WORDS),
        .numwords_b                        (SIZE_WORDS),
        .widthad_a                         (LOCAL_ADDRESS_WIDTH),
        .widthad_b                         (LOCAL_ADDRESS_WIDTH),
        .width_a                           (DATA_WIDTH),
        .width_b                           (DATA_WIDTH),
        .width_byteena_a                   (WORD_SIZE),
        .width_byteena_b                   (WORD_SIZE),
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
        .init_file                         (INIT_FILE),
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
        .data_a        (data_in_a),
        .data_b        (data_in_b),
        .wren_a        (write_hit_a && !port_a_error),
        .wren_b        (write_hit_b && !port_b_error),
        .q_a           (data_out_a),
        .q_b           (data_out_b),
        .aclr0         ('0),
        .aclr1         ('0),
        .addressstall_a('0),
        .addressstall_b('0),
        .clock0        (clk),
        .clock1        ('1),
        .clocken0      ('1),
        .clocken1      ('1),
        .clocken2      ('1),
        .clocken3      ('1),
        .rden_a        ('1),
        .rden_b        ('1),
        .eccstatus     ()
    );

endmodule
