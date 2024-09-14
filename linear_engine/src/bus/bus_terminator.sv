`include "../interfaces/bus_if.svh"

module bus_terminator (
    bus_if.slave in
);
    assign in.data_ptc    = 'z;
    assign in.hit_address = '0;
    assign in.hit_mask    = '0;
    assign in.hit         = '0;
    assign in.complete    = '0;
    assign in.error       = '0;

endmodule
