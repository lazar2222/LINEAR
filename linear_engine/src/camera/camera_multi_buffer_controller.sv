module camera_multi_buffer_controller #(
    parameter int WIDTH,
    parameter int NUM_FRAMES
) (
    input clk,
    input rst,

    input [WIDTH-1:0] sim_a,
    input [WIDTH-1:0] sim_b,
    input [WIDTH-1:0] sim_c,

    input strobe,

    input [$clog2(NUM_FRAMES)-1:0] read_address,

    output [WIDTH-1:0] sim_a_buffer,
    output [WIDTH-1:0] sim_b_buffer,
    output [WIDTH-1:0] sim_c_buffer
);
    reg [NUM_FRAMES-1:0][WIDTH-1:0] sim_a_storage;
    reg [NUM_FRAMES-1:0][WIDTH-1:0] sim_b_storage;
    reg [NUM_FRAMES-1:0][WIDTH-1:0] sim_c_storage;

    reg [$clog2(NUM_FRAMES)-1:0] write_address;

    assign sim_a_buffer = sim_a_storage[read_address];
    assign sim_b_buffer = sim_b_storage[read_address];
    assign sim_c_buffer = sim_c_storage[read_address];

    always @(posedge clk) begin
        if (strobe) begin
            sim_a_storage[write_address] <= sim_a;
            sim_b_storage[write_address] <= sim_b;
            sim_c_storage[write_address] <= sim_c;
            write_address                <= write_address + 1'd1;
        end
        if (rst) begin
            sim_a_storage <= '0;
            sim_b_storage <= '0;
            sim_c_storage <= '0;
            write_address <= '0;
        end
    end

endmodule
