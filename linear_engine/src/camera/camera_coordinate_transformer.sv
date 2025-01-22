module camera_coordinate_transformer #(
    parameter int WIDTH,
    parameter int PIXEL_WIDTH
) (
    input [WIDTH-1:0] sim_a,
    input [WIDTH-1:0] sim_b,
    input [WIDTH-1:0] sim_c,

    input [WIDTH-1:0] camera_x,
    input [WIDTH-1:0] camera_y,

    input [1:0] x_channel,
    input [1:0] y_channel,
    input [1:0] a_channel,

    input [$clog2(WIDTH)-1:0] x_shamt,
    input [$clog2(WIDTH)-1:0] y_shamt,
    input [$clog2(WIDTH)-1:0] a_shamt,

    input x_shiftd,
    input y_shiftd,
    input a_shiftd,

    input [WIDTH-1:0] x_offset,
    input [WIDTH-1:0] y_offset,
    input [WIDTH-1:0] a_offset,

    output [      WIDTH-1:0] world_x,
    output [      WIDTH-1:0] world_y,
    output [PIXEL_WIDTH-1:0] aux_value
);
    wire [WIDTH-1:0] sim_x = x_channel == 2'b00 ? sim_a : x_channel == 2'b01 ? sim_b : sim_c;
    wire [WIDTH-1:0] sim_y = y_channel == 2'b00 ? sim_a : y_channel == 2'b01 ? sim_b : sim_c;
    wire [WIDTH-1:0] sim_u = a_channel == 2'b00 ? sim_a : a_channel == 2'b01 ? sim_b : sim_c;

    wire [WIDTH-1:0] sim_x_shifted = x_shiftd ? sim_x << x_shamt : sim_x >> x_shamt;
    wire [WIDTH-1:0] sim_y_shifted = y_shiftd ? sim_y << y_shamt : sim_y >> y_shamt;
    wire [WIDTH-1:0] sim_u_shifted = a_shiftd ? sim_u << a_shamt : sim_u >> a_shamt;

    assign world_x   = camera_x + sim_x_shifted + x_offset;
    assign world_y   = camera_y + sim_y_shifted + y_offset;
    assign aux_value =            sim_u_shifted + a_offset;

endmodule
