`include "../interfaces/bus_if.svh"

module bus_interleaved_adapter #(
    `BUS_IF__PARAMS(slave),
    `BUS_IF__PARAMS(master_a),
    `BUS_IF__PARAMS(master_b)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(slave),
    `BUS_IF__MASTER_PORTS(master_a),
    `BUS_IF__MASTER_PORTS(master_b)
);
    wire bank_next = slave_address[0];
    reg  bank_reg;

    assign slave_data_ptc    = bank_reg  ? master_b_data_ptc : master_a_data_ptc;
    assign slave_hit         = bank_next ? master_b_hit      : master_a_hit;
    assign slave_complete    = bank_next ? master_b_complete : master_a_complete;
    assign slave_error       = bank_next ? master_b_error    : master_a_error;
    assign slave_hit_address = master_a_hit_address << 1;
    assign slave_hit_mask    = master_a_hit_mask    << 1;

    assign master_a_data_ctp    = slave_data_ctp;
    assign master_b_data_ctp    = slave_data_ctp;
    assign master_a_address     = slave_address >> 1;
    assign master_b_address     = slave_address >> 1;
    assign master_a_byte_enable = slave_byte_enable;
    assign master_b_byte_enable = slave_byte_enable;
    assign master_a_read        = slave_read  && !bank_next;
    assign master_b_read        = slave_read  &&  bank_next;
    assign master_a_write       = slave_write && !bank_next;
    assign master_b_write       = slave_write &&  bank_next;

    always @(posedge clk) begin
        bank_reg <= bank_next;
        if (rst) begin
            bank_reg <= '0;
        end
    end

endmodule
