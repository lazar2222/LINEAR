`include "../interfaces/bus_if.svh"

module bus_connector (
    bus_if.slave  in,
    bus_if.master out
);
    assign out.data_ctp    = in.data_ctp;
    assign out.address     = in.address;
    assign out.byte_enable = in.byte_enable;
    assign out.read        = in.read;
    assign out.write       = in.write;
    assign in.data_ptc     = out.data_ptc;
    assign in.hit_address  = out.hit_address;
    assign in.hit_mask     = out.hit_mask;
    assign in.hit          = out.hit;
    assign in.complete     = out.complete;
    assign in.error        = out.error;

endmodule
