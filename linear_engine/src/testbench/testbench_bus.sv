`include "../interfaces/bus_if.svh"

`define TESTBENCH_BUS__CREATE_MASTER(name, id) \
    bus_if #(                                \
        .DataWidth       (DataWidth),        \
        .ByteAddressWidth(ByteAddressWidth), \
        .ByteSize        (ByteSize)          \
    ) name ();                               \
    dummy_bus_master #(                      \
        .Id(id)                              \
    ) ``name``m (                            \
        .clk(clk),                           \
        .rst(rst),                           \
        .bus(name)                           \
    );                                       \

`define TESTBENCH_BUS__CREATE_SLAVE(name, base, size) \
    bus_if #(                                \
        .DataWidth       (DataWidth),        \
        .ByteAddressWidth(ByteAddressWidth), \
        .ByteSize        (ByteSize)          \
    ) ``name``_a ();                         \
    bus_if #(                                \
        .DataWidth       (DataWidth),        \
        .ByteAddressWidth(ByteAddressWidth), \
        .ByteSize        (ByteSize)          \
    ) ``name``_b ();                         \
    dummy_bus_slave #(                       \
        .BaseAddress(base),                  \
        .SizeBytes  (size)                   \
    ) name (                                 \
        .clk   (clk),                        \
        .rst   (rst),                        \
        .port_a(``name``_a),                 \
        .port_b(``name``_b)                  \
    );                                       \

module testbench_bus ();

    reg clk;
    reg rst;

    always #50 clk = !clk;

    initial begin
        clk = '1;
        rst = '1;
        #100;
        rst = '0;
    end

    localparam int DataWidth        = 512;
    localparam int ByteAddressWidth = 32;
    localparam int ByteSize         = 8;

    `TESTBENCH_BUS__CREATE_MASTER(sm0_im, 10)
    `TESTBENCH_BUS__CREATE_MASTER(sm0_dm, 11)
    `TESTBENCH_BUS__CREATE_MASTER(sm1_im, 20)
    `TESTBENCH_BUS__CREATE_MASTER(sm1_dm, 21)
    `TESTBENCH_BUS__CREATE_MASTER(hab,    30)

    `TESTBENCH_BUS__CREATE_SLAVE(im0, 32'h0000_0000, 2048 * 16 * 4)
    `TESTBENCH_BUS__CREATE_SLAVE(dm0, 32'h0002_0000, 2048 * 16 * 4)
    `TESTBENCH_BUS__CREATE_SLAVE(cm0, 32'h0004_0000, 2048 * 16 * 4 * 2)
    `TESTBENCH_BUS__CREATE_SLAVE(im1, 32'h0008_0000, 2048 * 16 * 4)
    `TESTBENCH_BUS__CREATE_SLAVE(dm1, 32'h000A_0000, 2048 * 16 * 4)
    `TESTBENCH_BUS__CREATE_SLAVE(cm1, 32'h000C_0000, 2048 * 16 * 4 * 2)
    `TESTBENCH_BUS__CREATE_SLAVE(smc, 32'h0010_0000,  256 * 16 * 4)

    bus_matrix bus_matrix (
        .clk   (clk),
        .rst   (rst),
        .sm0_im(sm0_im),
        .sm0_dm(sm0_dm),
        .sm1_im(sm1_im),
        .sm1_dm(sm1_dm),
        .hab   (hab),
        .im0_a (im0_a),
        .im0_b (im0_b),
        .dm0_a (dm0_a),
        .dm0_b (dm0_b),
        .cm0_a (cm0_a),
        .cm0_b (cm0_b),
        .im1_a (im1_a),
        .im1_b (im1_b),
        .dm1_a (dm1_a),
        .dm1_b (dm1_b),
        .cm1_a (cm1_a),
        .cm1_b (cm1_b),
        .smc   (smc_a)
    );

endmodule
