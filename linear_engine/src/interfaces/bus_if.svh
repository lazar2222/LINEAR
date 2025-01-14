`ifndef BUS_IF__SVH
`define BUS_IF__SVH

`define BUS_IF__(name, data_width, byte_address_width, byte_width) \
    localparam int DATA_WIDTH_``name``         = data_width;                                               \
    localparam int BYTE_ADDRESS_WIDTH_``name`` = byte_address_width;                                       \
    localparam int BYTE_WIDTH_``name``         = byte_width;                                               \
    localparam int WORD_SIZE_``name``          = DATA_WIDTH_``name`` / BYTE_WIDTH_``name``;                \
    localparam int WORD_ADDRESS_WIDTH_``name`` = BYTE_ADDRESS_WIDTH_``name`` - $clog2(WORD_SIZE_``name``); \
    wire [        DATA_WIDTH_``name``-1:0] ``name``_data_ctp;                                              \
    wire [        DATA_WIDTH_``name``-1:0] ``name``_data_ptc;                                              \
    wire [WORD_ADDRESS_WIDTH_``name``-1:0] ``name``_address;                                               \
    wire [         WORD_SIZE_``name``-1:0] ``name``_byte_enable;                                           \
    wire [WORD_ADDRESS_WIDTH_``name``-1:0] ``name``_hit_address;                                           \
    wire [WORD_ADDRESS_WIDTH_``name``-1:0] ``name``_hit_mask;                                              \
    wire                                   ``name``_read;                                                  \
    wire                                   ``name``_write;                                                 \
    tri0                                   ``name``_hit;                                                   \
    tri0                                   ``name``_complete;                                              \
    tri0                                   ``name``_error;                                                 \

`define BUS_IF__PARAMS(name) \
    parameter int DATA_WIDTH_``name``,         \
    parameter int BYTE_ADDRESS_WIDTH_``name``, \
    parameter int BYTE_WIDTH_``name``,         \
    parameter int WORD_SIZE_``name``,          \
    parameter int WORD_ADDRESS_WIDTH_``name``  \

`define BUS_IF__MASTER_PORTS(name) \
    output wire [        DATA_WIDTH_``name``-1:0] ``name``_data_ctp,    \
    input  wire [        DATA_WIDTH_``name``-1:0] ``name``_data_ptc,    \
    output wire [WORD_ADDRESS_WIDTH_``name``-1:0] ``name``_address,     \
    output wire [         WORD_SIZE_``name``-1:0] ``name``_byte_enable, \
    input  wire [WORD_ADDRESS_WIDTH_``name``-1:0] ``name``_hit_address, \
    input  wire [WORD_ADDRESS_WIDTH_``name``-1:0] ``name``_hit_mask,    \
    output wire                                   ``name``_read,        \
    output wire                                   ``name``_write,       \
    input  wire                                   ``name``_hit,         \
    input  wire                                   ``name``_complete,    \
    input  wire                                   ``name``_error        \

`define BUS_IF__SLAVE_PORTS(name) \
    input  wire [        DATA_WIDTH_``name``-1:0] ``name``_data_ctp,    \
    output wire [        DATA_WIDTH_``name``-1:0] ``name``_data_ptc,    \
    input  wire [WORD_ADDRESS_WIDTH_``name``-1:0] ``name``_address,     \
    input  wire [         WORD_SIZE_``name``-1:0] ``name``_byte_enable, \
    output wire [WORD_ADDRESS_WIDTH_``name``-1:0] ``name``_hit_address, \
    output wire [WORD_ADDRESS_WIDTH_``name``-1:0] ``name``_hit_mask,    \
    input  wire                                   ``name``_read,        \
    input  wire                                   ``name``_write,       \
    output wire                                   ``name``_hit,         \
    output wire                                   ``name``_complete,    \
    output wire                                   ``name``_error        \

`define BUS_IF__FILL_PARAMS(mod, bus) \
    .DATA_WIDTH_``mod``        (DATA_WIDTH_``bus``),         \
    .BYTE_ADDRESS_WIDTH_``mod``(BYTE_ADDRESS_WIDTH_``bus``), \
    .BYTE_WIDTH_``mod``        (BYTE_WIDTH_``bus``),         \
    .WORD_SIZE_``mod``         (WORD_SIZE_``bus``),          \
    .WORD_ADDRESS_WIDTH_``mod``(WORD_ADDRESS_WIDTH_``bus``)  \

`define BUS_IF__CONNECT(mod, bus) \
    .``mod``_data_ctp   (``bus``_data_ctp),    \
    .``mod``_data_ptc   (``bus``_data_ptc),    \
    .``mod``_address    (``bus``_address),     \
    .``mod``_byte_enable(``bus``_byte_enable), \
    .``mod``_hit_address(``bus``_hit_address), \
    .``mod``_hit_mask   (``bus``_hit_mask),    \
    .``mod``_read       (``bus``_read),        \
    .``mod``_write      (``bus``_write),       \
    .``mod``_hit        (``bus``_hit),         \
    .``mod``_complete   (``bus``_complete),    \
    .``mod``_error      (``bus``_error)        \

`endif //BUS_IF__SVH
