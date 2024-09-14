`include "../interfaces/bus_if.svh"

`define BUS_MATRIX__FILTER(s, f, p) \
    bus_if #(                                \
        .DataWidth       (DataWidth),        \
        .ByteAddressWidth(ByteAddressWidth), \
        .ByteSize        (ByteSize)          \
    ) f ();                                  \
    bus_if #(                                \
        .DataWidth       (DataWidth),        \
        .ByteAddressWidth(ByteAddressWidth), \
        .ByteSize        (ByteSize)          \
    ) p ();                                  \
    mem_filter mem_filter_``s`` (            \
        .clk        (clk),                   \
        .rst        (rst),                   \
        .in         (s),                     \
        .filtered   (f),                     \
        .passthrough(p)                      \
    );                                       \

`define BUS_MATRIX__TERMINATOR(source) \
    mem_terminator mem_terminator_``source`` ( \
        .in(source)                            \
    );                                         \

`define BUS_MATRIX__CONNECTOR1(slave, master) \
    mem_connector mem_connector_``master`` ( \
        .in (slave),                         \
        .out(master)                         \
    );                                       \

`define BUS_MATRIX__CONNECTOR2(slave1, slave2, master) \
    mem_arbiter mem_arbiter_``slave2`` ( \
        .clk   (clk),                    \
        .rst   (rst),                    \
        .port_a(slave1),                 \
        .port_b(slave2),                 \
        .port  (master)                  \
    );                                   \

`define BUS_MATRIX__CONNECTOR3(slave1, slave2, slave3, master) \
    bus_if #(                                \
        .DataWidth       (DataWidth),        \
        .ByteAddressWidth(ByteAddressWidth), \
        .ByteSize        (ByteSize)          \
    ) ``slave1``_``slave2`` ();              \
    mem_arbiter mem_arbiter_``slave2`` (     \
        .clk   (clk),                        \
        .rst   (rst),                        \
        .port_a(slave1),                     \
        .port_b(slave2),                     \
        .port  (``slave1``_``slave2``)       \
    );                                       \
    mem_arbiter mem_arbiter_``slave3`` (     \
        .clk   (clk),                        \
        .rst   (rst),                        \
        .port_a(``slave1``_``slave2``),      \
        .port_b(slave3),                     \
        .port  (master)                      \
    );                                       \

module bus_matrix (
    input clk,
    input rst,

    bus_if.slave sm0_im,
    bus_if.slave sm0_dm,
    bus_if.slave sm1_im,
    bus_if.slave sm1_dm,
    bus_if.slave hab,

    bus_if.master im0_a,
    bus_if.master im0_b,
    bus_if.master dm0_a,
    bus_if.master dm0_b,
    bus_if.master cm0_a,
    bus_if.master cm0_b,
    bus_if.master im1_a,
    bus_if.master im1_b,
    bus_if.master dm1_a,
    bus_if.master dm1_b,
    bus_if.master cm1_a,
    bus_if.master cm1_b,
    bus_if.master smc
);
    localparam int DataWidth        = $bits(sm0_im.data_ctp);
    localparam int BytesPerWord     = $bits(sm0_im.byte_enable);
    localparam int ByteAddressWidth = $bits(sm0_im.address) + $clog2(BytesPerWord);
    localparam int ByteSize         = DataWidth / BytesPerWord;

    `BUS_MATRIX__FILTER    (sm0_im,       sm0_im_im0, sm0_im_pass1)
    `BUS_MATRIX__FILTER    (sm0_im_pass1, sm0_im_im1, sm0_im_pass2)
    `BUS_MATRIX__TERMINATOR(sm0_im_pass2)

    `BUS_MATRIX__FILTER    (sm0_dm,       sm0_dm_im0, sm0_dm_pass1)
    `BUS_MATRIX__FILTER    (sm0_dm_pass1, sm0_dm_dm0, sm0_dm_pass2)
    `BUS_MATRIX__FILTER    (sm0_dm_pass2, sm0_dm_cm0, sm0_dm_pass3)
    `BUS_MATRIX__FILTER    (sm0_dm_pass3, sm0_dm_im1, sm0_dm_pass4)
    `BUS_MATRIX__FILTER    (sm0_dm_pass4, sm0_dm_dm1, sm0_dm_pass5)
    `BUS_MATRIX__FILTER    (sm0_dm_pass5, sm0_dm_cm1, sm0_dm_pass6)
    `BUS_MATRIX__FILTER    (sm0_dm_pass6, sm0_dm_smc, sm0_dm_pass7)
    `BUS_MATRIX__TERMINATOR(sm0_dm_pass7)

    `BUS_MATRIX__FILTER    (sm1_im,       sm1_im_im1, sm1_im_pass1)
    `BUS_MATRIX__FILTER    (sm1_im_pass1, sm1_im_im0, sm1_im_pass2)
    `BUS_MATRIX__TERMINATOR(sm1_im_pass2)

    `BUS_MATRIX__FILTER    (sm1_dm,       sm1_dm_im1, sm1_dm_pass1)
    `BUS_MATRIX__FILTER    (sm1_dm_pass1, sm1_dm_dm1, sm1_dm_pass2)
    `BUS_MATRIX__FILTER    (sm1_dm_pass2, sm1_dm_cm1, sm1_dm_pass3)
    `BUS_MATRIX__FILTER    (sm1_dm_pass3, sm1_dm_im0, sm1_dm_pass4)
    `BUS_MATRIX__FILTER    (sm1_dm_pass4, sm1_dm_dm0, sm1_dm_pass5)
    `BUS_MATRIX__FILTER    (sm1_dm_pass5, sm1_dm_cm0, sm1_dm_pass6)
    `BUS_MATRIX__FILTER    (sm1_dm_pass6, sm1_dm_smc, sm1_dm_pass7)
    `BUS_MATRIX__TERMINATOR(sm1_dm_pass7)

    `BUS_MATRIX__FILTER    (hab,          hab_im0,    hab_pass1)
    `BUS_MATRIX__FILTER    (hab_pass1,    hab_dm0,    hab_pass2)
    `BUS_MATRIX__FILTER    (hab_pass2,    hab_cm0,    hab_pass3)
    `BUS_MATRIX__FILTER    (hab_pass3,    hab_im1,    hab_pass4)
    `BUS_MATRIX__FILTER    (hab_pass4,    hab_dm1,    hab_pass5)
    `BUS_MATRIX__FILTER    (hab_pass5,    hab_cm1,    hab_pass6)
    `BUS_MATRIX__FILTER    (hab_pass6,    hab_smc,    hab_pass7)
    `BUS_MATRIX__TERMINATOR(hab_pass7)

    `BUS_MATRIX__CONNECTOR2(sm0_im_im0, sm0_dm_im0,          im0_a)
    `BUS_MATRIX__CONNECTOR3(sm1_im_im0, sm1_dm_im0, hab_im0, im0_b)
    `BUS_MATRIX__CONNECTOR1(sm0_dm_dm0,                      dm0_a)
    `BUS_MATRIX__CONNECTOR2(sm1_dm_dm0, hab_dm0,             dm0_b)
    `BUS_MATRIX__CONNECTOR1(sm0_dm_cm0,                      cm0_a)
    `BUS_MATRIX__CONNECTOR2(sm1_dm_cm0, hab_cm0,             cm0_b)
    `BUS_MATRIX__CONNECTOR2(sm1_im_im1, sm1_dm_im1,          im1_a)
    `BUS_MATRIX__CONNECTOR3(sm0_im_im1, sm0_dm_im1, hab_im1, im1_b)
    `BUS_MATRIX__CONNECTOR1(sm1_dm_dm1,                      dm1_a)
    `BUS_MATRIX__CONNECTOR2(sm0_dm_dm1, hab_dm1,             dm1_b)
    `BUS_MATRIX__CONNECTOR1(sm1_dm_cm1,                      cm1_a)
    `BUS_MATRIX__CONNECTOR2(sm0_dm_cm1, hab_cm1,             cm1_b)
    `BUS_MATRIX__CONNECTOR3(sm0_dm_smc, sm1_dm_smc, hab_smc, smc)

endmodule
