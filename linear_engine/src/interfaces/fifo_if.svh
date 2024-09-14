`ifndef FIFO_IF__SVH
`define FIFO_IF__SVH

interface fifo_write_if #(
    parameter int DataWidth
);
    wire [DataWidth-1:0] data;
    wire                 can_write;
    wire                 write;

    modport fifo (
        input  data,
        output can_write,
        input  write
    );

    modport device (
        output data,
        input  can_write,
        output write
    );

endinterface

interface fifo_read_if #(
    parameter int DataWidth
);
    wire [DataWidth-1:0] data;
    wire                 can_read;
    wire                 read;

    modport fifo (
        output  data,
        output can_read,
        input  read
    );

    modport device (
        input  data,
        input  can_read,
        output read
    );

endinterface

`define FIFO_IF__MAKE_FIFO(name, ww, rw, d, f) \
    fifo_read_if  #(ww) ``name``_write (); \
    fifo_write_if #(rw) ``name``_read ();  \
    variable_fifo # (                      \
        .Depth(d),                         \
        .Fast (f)                          \
    )                                      \
    name (                                 \
        .clk(clk),                         \
        .rst(rst),                         \
        .write_port(``name``_write),       \
        .read_port(``name``_read)          \
    );                                     \

`endif //FIFO_IF__SVH
