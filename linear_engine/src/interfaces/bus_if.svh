`ifndef BUS_IF__SVH
`define BUS_IF__SVH

interface bus_if #(
    parameter int DataWidth,
    parameter int ByteAddressWidth,
    parameter int ByteSize
);
    localparam int BytesPerWord     = DataWidth / ByteSize;
    localparam int WordAddressWidth = ByteAddressWidth - $clog2(BytesPerWord);

    wire [       DataWidth-1:0] data_ctp;
    wire [       DataWidth-1:0] data_ptc;
    wire [WordAddressWidth-1:0] address;
    wire [WordAddressWidth-1:0] hit_address;
    wire [WordAddressWidth-1:0] hit_mask;
    wire [    BytesPerWord-1:0] byte_enable;
    wire                        read;
    wire                        write;
    wire                        hit;
    wire                        complete;
    wire                        error;

    modport master (
        output data_ctp,
        output address,
        output byte_enable,
        output read,
        output write,
        input  data_ptc,
        input  hit_address,
        input  hit_mask,
        input  hit,
        input  complete,
        input  error
    );

    modport slave (
        input  data_ctp,
        input  address,
        input  byte_enable,
        input  read,
        input  write,
        output data_ptc,
        output hit_address,
        output hit_mask,
        output hit,
        output complete,
        output error
    );

endinterface

`endif //BUS_IF__SVH
