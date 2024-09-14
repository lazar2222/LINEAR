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
    parallel_rx_if #($bits(xcvr.data_rx)) rx (); \
    parallel_tx_if #($bits(xcvr.data_tx)) tx (); \
    assign xcvr.data_rx = rx.data;               \
    assign xcvr.valid   = rx.valid;              \
    assign tx.data      = xcvr.data_tx;          \
    assign tx.send      = xcvr.send;             \
    assign xcvr.ready   = tx.ready;              \

`endif //PARALLEL_IF__SVH
