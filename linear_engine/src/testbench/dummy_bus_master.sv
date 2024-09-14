`include "../interfaces/bus_if.svh"

module dummy_bus_master #(
    parameter int Id
) (
    input clk,
    input rst,

    bus_if.master bus
);
    reg [14:0] target_device;
    reg [10:0] target_local_address;
    reg        read;
    reg        write;
    reg        in_progress;

    assign bus.data_ctp    = Id;
    assign bus.address     = {target_device, target_local_address};
    assign bus.byte_enable = bus.address;
    assign bus.read        = read;
    assign bus.write       = write;

    int random_op;

    always @(posedge clk) begin
        if (!in_progress || bus.complete || !bus.hit) begin
            random_op = $urandom_range(0, 2);
            read                 <= random_op == 0;
            write                <= random_op == 1;
            target_device        <= $urandom_range(0, 8);
            target_local_address <= $urandom_range(0, 1) * 1024;
            in_progress          <= random_op != 2;
        end
        if (rst) begin
            $urandom(Id);
            target_device        <= '0;
            target_local_address <= '0;
            read                 <= '0;
            write                <= '0;
            in_progress          <= '0;
        end
    end

endmodule
