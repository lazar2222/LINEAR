`include "../interfaces/bus_if.svh"

module bus_filter (
    input clk,
    input rst,

    bus_if.slave  in,
    bus_if.master filtered,
    bus_if.master passthrough
);
    reg  filter_dht;
    wire filter_hit = (in.address & filtered.hit_mask) == filtered.hit_address;

    assign filtered.data_ctp       = in.data_ctp;
    assign filtered.address        = in.address;
    assign filtered.byte_enable    = in.byte_enable;
    assign filtered.read           = filter_hit & in.read;
    assign filtered.write          = filter_hit & in.write;

    assign passthrough.data_ctp    = in.data_ctp;
    assign passthrough.address     = in.address;
    assign passthrough.byte_enable = in.byte_enable;
    assign passthrough.read        = !filter_hit & in.read;
    assign passthrough.write       = !filter_hit & in.write;

    assign in.data_ptc             = filter_dht ? filtered.data_ptc : passthrough.data_ptc;
    assign in.hit                  = filter_hit ? filtered.hit      : passthrough.hit;
    assign in.complete             = filter_hit ? filtered.complete : passthrough.complete;
    assign in.error                = filter_hit ? filtered.error    : passthrough.error;
    assign in.hit_address          = '0;
    assign in.hit_mask             = '0;

    always @(posedge clk) begin
        filter_dht <= filter_hit;
        if (rst) begin
            filter_dht <= '0;
        end
    end

endmodule
