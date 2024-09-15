`ifndef PARALLEL_IF__SVH
`define PARALLEL_IF__SVH

interface parallel_rx_if #(
    parameter int DataWidth
);
    wire [DataWidth-1:0] data;
    wire                 valid;

    modport rx (
        output data,
        output valid
    );

    modport device (
        input  data,
        input  valid
    );

endinterface

interface parallel_tx_if #(
    parameter int DataWidth
);
    wire [DataWidth-1:0] data;
    wire                 send;
    wire                 ready;

    modport tx (
        input  data,
        input  send,
        output ready
    );

    modport device (
        output data,
        output send,
        input  ready
    );

endinterface

interface parallel_xcvr_if #(
    parameter int DataWidth
);
    wire [DataWidth-1:0] data_rx;
    wire                 valid;
    wire [DataWidth-1:0] data_tx;
    wire                 send;
    wire                 ready;

    modport xcvr (
        output data_rx,
        output valid,
        input  data_tx,
        input  send,
        output ready
    );

    modport device (
        input  data_rx,
        input  valid,
        output data_tx,
        output send,
        input  ready
    );

endinterface

`define PARALLEL_IF__XCVR_BREAKDOWN(xcvr, tx, rx) \
    parallel_rx_if #(.DataWidth($bits(xcvr.data_rx))) rx (); \
    parallel_tx_if #(.DataWidth($bits(xcvr.data_tx))) tx (); \
    assign xcvr.data_rx = rx.data;                           \
    assign xcvr.valid   = rx.valid;                          \
    assign tx.data      = xcvr.data_tx;                      \
    assign tx.send      = xcvr.send;                         \
    assign xcvr.ready   = tx.ready;                          \

`define PARALLEL_IF__SPLIT_TX(intf, divf) \
    localparam int ``intf``_divw = $bits(intf.data) / divf;                                                   \
    parallel_tx_if #(.DataWidth(``intf``_divw)) ``intf``_div[divf] ();                                        \
    wire [divf-1:0] ``intf``_readys;                                                                          \
    genvar ``intf``_i;                                                                                        \
    generate                                                                                                  \
        for (``intf``_i = 0; ``intf``_i < divf; ``intf``_i++) begin : g_``intf``_gen                          \
            assign ``intf``_div   [``intf``_i].data = intf.data[``intf``_i * ``intf``_divw +: ``intf``_divw]; \
            assign ``intf``_div   [``intf``_i].send = intf.send;                                              \
            assign ``intf``_readys[``intf``_i]      = ``intf``_div[``intf``_i].ready;                         \
        end                                                                                                   \
    endgenerate                                                                                               \
    assign intf.ready = &``intf``_readys;                                                                     \

`define PARALLEL_IF__SPLIT_RX(intf, divf) \
    localparam int ``intf``_divw = $bits(intf.data) / divf;                                                 \
    parallel_rx_if #(.DataWidth(``intf``_divw)) ``intf``_div[divf] ();                                      \
    wire [divf-1:0] ``intf``_valids;                                                                        \
    genvar ``intf``_i;                                                                                      \
    generate                                                                                                \
        for (``intf``_i = 0; ``intf``_i < divf; ``intf``_i++) begin : g_``intf``_gen                        \
            assign intf.data[``intf``_i * ``intf``_divw +: ``intf``_divw] = ``intf``_div[``intf``_i].data;  \
            assign ``intf``_valids[``intf``_i]                            = ``intf``_div[``intf``_i].valid; \
        end                                                                                                 \
    endgenerate                                                                                             \
    assign intf.valid = &``intf``_valids;                                                                   \

`endif //PARALLEL_IF__SVH
