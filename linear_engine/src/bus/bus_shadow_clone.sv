`include "../interfaces/bus_if.svh"

module bus_shadow_clone #(
    `BUS_IF__PARAMS(slave),
    `BUS_IF__PARAMS(master_a),
    `BUS_IF__PARAMS(master_b)
) (
    `BUS_IF__SLAVE_PORTS(slave),
    `BUS_IF__MASTER_PORTS(master_a),
    `BUS_IF__MASTER_PORTS(master_b),

    output error
);
    wire ptc_error = master_a_data_ptc    != master_b_data_ptc;
    wire ha_error  = master_a_hit_address != master_b_hit_address;
    wire hm_error  = master_a_hit_mask    != master_b_hit_mask;
    wire h_error   = master_a_hit         != master_b_hit;
    wire c_error   = master_a_complete    != master_b_complete;
    wire e_error   = master_a_error       != master_b_error;

    assign error = ptc_error || ha_error || hm_error || h_error || c_error || e_error;

    assign master_a_data_ctp    = slave_data_ctp;
    assign master_b_data_ctp    = slave_data_ctp;
    assign master_a_address     = slave_address;
    assign master_b_address     = slave_address;
    assign master_a_byte_enable = slave_byte_enable;
    assign master_b_byte_enable = slave_byte_enable;
    assign master_a_read        = slave_read;
    assign master_b_read        = slave_read;
    assign master_a_write       = slave_write;
    assign master_b_write       = slave_write;

    assign slave_data_ptc    = master_a_data_ptc;
    assign slave_hit_address = master_a_hit_address;
    assign slave_hit_mask    = master_a_hit_mask;
    assign slave_hit         = master_a_hit;
    assign slave_complete    = master_a_complete;
    assign slave_error       = master_a_error;

endmodule
