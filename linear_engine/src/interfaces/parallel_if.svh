`ifndef PARALLEL_IF__SVH
`define PARALLEL_IF__SVH

`define PARALLEL_IF__UNI(name, data_width) \
    localparam int DATA_WIDTH_``name`` = data_width; \
    wire [DATA_WIDTH_``name``-1:0] ``name``_data;    \
    wire                           ``name``_valid;   \
    wire                           ``name``_ready;   \

`define PARALLEL_IF__UNI_PARAMS(name) \
    parameter int DATA_WIDTH_``name`` \

`define PARALLEL_IF__UNI_TX_PORTS(name) \
    input  wire                           ``name``_ready, \
    output wire                           ``name``_valid, \
    output wire [DATA_WIDTH_``name``-1:0] ``name``_data   \

`define PARALLEL_IF__UNI_RX_PORTS(name) \
    output wire                           ``name``_ready, \
    input  wire                           ``name``_valid, \
    input  wire [DATA_WIDTH_``name``-1:0] ``name``_data   \

`define PARALLEL_IF__UNI_FILL_PARAMS(mod, bus) \
    .DATA_WIDTH_``mod``(DATA_WIDTH_``bus``) \

`define PARALLEL_IF__UNI_CONNECT(mod, bus) \
    .``mod``_data (``bus``_data),  \
    .``mod``_valid(``bus``_valid), \
    .``mod``_ready(``bus``_ready)  \

`define PARALLEL_IF__UNI_CONNECT_SPLIT(mod, bus, i) \
    .``mod``_data (``bus``_data[i]),  \
    .``mod``_valid(``bus``_valid[i]), \
    .``mod``_ready(``bus``_ready[i])  \

`define PARALLEL_IF__BI(name, data_width) \
    `PARALLEL_IF__UNI(``name``_tx, data_width); \
    `PARALLEL_IF__UNI(``name``_rx, data_width); \

`define PARALLEL_IF__BI_PARAMS(name) \
    `PARALLEL_IF__UNI_PARAMS(``name``_tx), \
    `PARALLEL_IF__UNI_PARAMS(``name``_rx)  \

`define PARALLEL_IF__BI_PORTS(name) \
    `PARALLEL_IF__UNI_TX_PORTS(``name``_tx), \
    `PARALLEL_IF__UNI_RX_PORTS(``name``_rx)  \

`define PARALLEL_IF__BI_FILL_PARAMS(mod, bus) \
    `PARALLEL_IF__UNI_FILL_PARAMS(``mod``_tx, ``bus``_tx), \
    `PARALLEL_IF__UNI_FILL_PARAMS(``mod``_rx, ``bus``_rx)  \

`define PARALLEL_IF__BI_FILL_PARAMS_INVERTED(mod, bus) \
    `PARALLEL_IF__UNI_FILL_PARAMS(``mod``_tx, ``bus``_rx), \
    `PARALLEL_IF__UNI_FILL_PARAMS(``mod``_rx, ``bus``_tx)  \

`define PARALLEL_IF__BI_CONNECT(mod, bus) \
    `PARALLEL_IF__UNI_CONNECT(``mod``_tx, ``bus``_tx), \
    `PARALLEL_IF__UNI_CONNECT(``mod``_rx, ``bus``_rx)  \

`define PARALLEL_IF__BI_CONNECT_INVERTED(mod, bus) \
    `PARALLEL_IF__UNI_CONNECT(``mod``_tx, ``bus``_rx), \
    `PARALLEL_IF__UNI_CONNECT(``mod``_rx, ``bus``_tx)  \

`define PARALLEL_IF__SPLIT_TX(name, divf) \
    localparam int DATA_WIDTH_``name``_div = DATA_WIDTH_``name`` / divf;                                                                   \
    wire [divf-1:0][DATA_WIDTH_``name``_div-1:0] ``name``_div_data;                                                                        \
    wire [divf-1:0]                              ``name``_div_valid;                                                                       \
    wire [divf-1:0]                              ``name``_div_ready;                                                                       \
    genvar ``name``_div_i;                                                                                                                 \
    generate                                                                                                                               \
        for (``name``_div_i = 0; ``name``_div_i < divf; ``name``_div_i++) begin : g_``name``_gen                                           \
            assign ``name``_data[``name``_div_i * DATA_WIDTH_``name``_div +: DATA_WIDTH_``name``_div] = ``name``_div_data[``name``_div_i]; \
            assign ``name``_div_ready[``name``_div_i] = ``name``_ready;                                                                    \
        end                                                                                                                                \
    endgenerate                                                                                                                            \
    assign ``name``_valid = &``name``_div_valid;                                                                                           \

`define PARALLEL_IF__SPLIT_RX(name, divf) \
    localparam int DATA_WIDTH_``name``_div = DATA_WIDTH_``name`` / divf;                                                                    \
    wire [divf-1:0][DATA_WIDTH_``name``_div-1:0] ``name``_div_data;                                                                         \
    wire [divf-1:0]                              ``name``_div_valid;                                                                        \
    wire [divf-1:0]                              ``name``_div_ready;                                                                        \
    genvar ``name``_div_i;                                                                                                                  \
    generate                                                                                                                                \
        for (``name``_div_i = 0; ``name``_div_i < divf; ``name``_div_i++) begin : g_``name``_gen                                            \
            assign ``name``_div_data [``name``_div_i] = ``name``_data[``name``_div_i * DATA_WIDTH_``name``_div +: DATA_WIDTH_``name``_div]; \
            assign ``name``_div_valid[``name``_div_i] = ``name``_valid;                                                                     \
        end                                                                                                                                 \
    endgenerate                                                                                                                             \
    assign ``name``_ready = &``name``_div_ready;                                                                                            \

`endif //PARALLEL_IF__SVH
