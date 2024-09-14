`include "../interfaces/bus_if.svh"

module bus_arbiter (
    input clk,
    input rst,

    bus_if.slave  port_a,
    bus_if.slave  port_b,
    bus_if.master port
);
    wire grant_a, grant_b;
    wire request_a = port_a.read || port_a.write;
    wire request_b = port_b.read || port_b.write;
    wire complete  = port.complete;

    two_way_arbiter arbiter (
        .clk      (clk),
        .rst      (rst),
        .request_a(request_a),
        .request_b(request_b),
        .complete (complete),
        .grant_a  (grant_a),
        .grant_b  (grant_b)
    );

    assign port.data_ctp      = grant_a ? port_a.data_ctp    : port_b.data_ctp;
    assign port.address       = grant_a ? port_a.address     : port_b.address;
    assign port.byte_enable   = grant_a ? port_a.byte_enable : port_b.byte_enable;
    assign port.read          = grant_a ? port_a.read        : port_b.read;
    assign port.write         = grant_a ? port_a.write       : port_b.write;

    assign port_a.data_ptc    = port.data_ptc;
    assign port_b.data_ptc    = port.data_ptc;
    assign port_a.hit_address = port.hit_address;
    assign port_b.hit_address = port.hit_address;
    assign port_a.hit_mask    = port.hit_mask;
    assign port_b.hit_mask    = port.hit_mask;
    assign port_a.hit         = grant_a ? port.hit : '1;
    assign port_b.hit         = grant_b ? port.hit : '1;
    assign port_a.complete    = grant_a & port.complete;
    assign port_b.complete    = grant_b & port.complete;
    assign port_a.error       = grant_a & port.error;
    assign port_b.error       = grant_b & port.error;

endmodule
