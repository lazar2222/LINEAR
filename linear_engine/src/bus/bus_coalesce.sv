`include "../interfaces/bus_if.svh"

module bus_coalesce #(
    parameter int SlavePorts
) (
    bus_if.master master,
    bus_if.slave  slaves[SlavePorts]
);
    localparam int MasterAddressWidth   = $bits(master.address);
    localparam int SlaveAddressWidth    = $bits(slaves[0].address);
    localparam int CoalesceAddressWidth = SlaveAddressWidth - MasterAddressWidth;
    localparam int SlaveSelectWidth     = $clog2(SlavePorts);
    localparam int MasterBytesPerWord   = $bits(master.byte_enable);
    localparam int MasterDataWidth      = $bits(master.data_ctp);
    localparam int SlaveDataWidth       = $bits(slaves[0].data_ctp);
    localparam int SlaveBytesPerWord    = $bits(slaves[0].byte_enable);
    localparam int ByteSize             = MasterDataWidth / MasterBytesPerWord;

    wire [  MasterAddressWidth-1:0] master_address  [SlavePorts];
    wire [CoalesceAddressWidth-1:0] coalesce_address[SlavePorts];
    wire [  MasterBytesPerWord-1:0] byte_enable     [SlavePorts];
    wire [     MasterDataWidth-1:0] data_mask       [SlavePorts];
    wire [     MasterDataWidth-1:0] data            [SlavePorts];
    wire [          SlavePorts-1:0] read;
    wire [          SlavePorts-1:0] write;
    wire [          SlavePorts-1:0] request;
    wire [          SlavePorts-1:0] compatible;
    wire [    SlaveSelectWidth-1:0] slave_select;

    wire conflict;

    priority_enc #(
        .Width(SlavePorts)
    ) priority_enc (
        .in (request),
        .out(),
        .sel(slave_select),
        .any()
    );

    tree_conflict_detector #(
        .Width(MasterBytesPerWord),
        .Depth(SlavePorts)
    ) tree_conflict_detector (
        .data    (byte_enable),
        .conflict(conflict)
    );

    assign master.data_ctp    = data.or();
    assign master.address     = master_address[slave_select];
    assign master.byte_enable = byte_enable.or();
    assign master.read        = read[slave_select];
    assign master.write       = write[slave_select];

    genvar i, j;
    generate
        for (i = 0; i < SlavePorts; i++) begin : g_slave_inputs
            assign master_address[i]   = slaves[i].address[SlaveAddressWidth-1:CoalesceAddressWidth];
            assign coalesce_address[i] = slaves[i].address[CoalesceAddressWidth-1:0];
            assign read[i]             = slaves[i].read;
            assign write[i]            = slaves[i].write;
            assign request[i]          = slaves[i].read || slaves[i].write;

            assign byte_enable[i] = slaves[i].write && compatible[i] ? (slaves[i].byte_enable << (coalesce_address[i] * SlaveBytesPerWord)) : '0;
            for (j = 0; j < MasterBytesPerWord; j++) begin : g_mask
                assign data_mask[i][ByteSize*j+:ByteSize] = {ByteSize{byte_enable[i][j]}};
            end
            assign data[i] = slaves[i].data_ctp << (coalesce_address[i] * SlaveDataWidth) & data_mask[i];

            assign compatible[i]         = (master_address[i] == master_address[slave_select]) && (read[i] == read[slave_select]) && (write[i] == read[slave_select]);
            assign slaves[i].data_ptc    = master.data_ptc >> (coalesce_address[i] * SlaveDataWidth);
            assign slaves[i].hit_address = '0;
            assign slaves[i].hit_mask    = '0;
            assign slaves[i].hit         = compatible[i] ? master.hit : '1;
            assign slaves[i].complete    = compatible[i] && master.complete;
            assign slaves[i].error       = compatible[i] && (conflict || master.error);
        end
    endgenerate

endmodule
