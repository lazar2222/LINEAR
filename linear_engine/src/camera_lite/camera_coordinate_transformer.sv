module camera_coordinate_transformer #(
    parameter int WIDTH,
    parameter int PIXEL_WIDTH
) (
    input clk,
    input rst,

    input strobe,

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

    input [WIDTH-1:0] x_offset,
    input [WIDTH-1:0] y_offset,
    input [WIDTH-1:0] a_offset,

    input [      WIDTH-1:0] x1,
    input [      WIDTH-1:0] y1,
    input [      WIDTH-1:0] x2,
    input [      WIDTH-1:0] y2,
    input [PIXEL_WIDTH-1:0] aux_min,
    input [PIXEL_WIDTH-1:0] aux_max,

    output [      WIDTH-1:0] sim_x,
    output [      WIDTH-1:0] sim_y,
    output [      WIDTH-1:0] aux_value,
    output [      WIDTH-1:0] ss_x1,
    output [      WIDTH-1:0] ss_y1,
    output [      WIDTH-1:0] ss_x2,
    output [      WIDTH-1:0] ss_y2,
    output [PIXEL_WIDTH-1:0] data_min,
    output [PIXEL_WIDTH-1:0] data_max,

    output done
);
    reg [WIDTH-1:0] sim_x_unshifted_reg;
    reg [WIDTH-1:0] sim_y_unshifted_reg;
    reg [WIDTH-1:0] sim_u_unshifted_reg;
    reg [WIDTH-1:0] sim_x_shifted_reg;
    reg [WIDTH-1:0] sim_y_shifted_reg;
    reg [WIDTH-1:0] sim_u_shifted_reg;
    reg [WIDTH-1:0] sim_x_reg;
    reg [WIDTH-1:0] sim_y_reg;
    reg [WIDTH-1:0] aux_value_reg;
    reg [WIDTH-1:0] ss_x1_reg;
    reg [WIDTH-1:0] ss_y1_reg;
    reg [WIDTH-1:0] ss_x2_reg;
    reg [WIDTH-1:0] ss_y2_reg;
    reg [PIXEL_WIDTH-1:0] data_min_reg;
    reg [PIXEL_WIDTH-1:0] data_max_reg;

    reg strobe_d, strobe_dd, strobe_ddd, strobe_dddd;

    assign sim_x     = sim_x_reg;
    assign sim_y     = sim_y_reg;
    assign aux_value = aux_value_reg;
    assign ss_x1     = ss_x1_reg;
    assign ss_y1     = ss_y1_reg;
    assign ss_x2     = ss_x2_reg;
    assign ss_y2     = ss_y2_reg;
    assign data_min  = data_min_reg;
    assign data_max  = data_max_reg;

    assign done = strobe_dddd;

    //-0.375 -7.294

    always @(posedge clk) begin
        strobe_dddd <= strobe_ddd;
        strobe_ddd <= strobe_dd;
        strobe_dd <= strobe_d;
        strobe_d  <= strobe;
        if (strobe) begin
            sim_x_unshifted_reg <= x_channel == 2'b00 ? sim_a : x_channel == 2'b01 ? sim_b : sim_c;
            sim_y_unshifted_reg <= y_channel == 2'b00 ? sim_a : y_channel == 2'b01 ? sim_b : sim_c;
            sim_u_unshifted_reg <= a_channel == 2'b00 ? sim_a : a_channel == 2'b01 ? sim_b : sim_c;
        end
        if (strobe_d) begin
            sim_x_shifted_reg <= sim_x_unshifted_reg >> x_shamt;
            sim_y_shifted_reg <= sim_y_unshifted_reg >> y_shamt;
            sim_u_shifted_reg <= sim_u_unshifted_reg >> a_shamt;
        end
        if (strobe_dd) begin
            sim_x_reg     <= sim_x_shifted_reg + x_offset;
            sim_y_reg     <= sim_y_shifted_reg + y_offset;
            aux_value_reg <= sim_u_shifted_reg + a_offset;
        end
        if (strobe_ddd) begin
            ss_x1_reg     <= x1      - sim_x_reg;
            ss_y1_reg     <= y1      - sim_y_reg;
            ss_x2_reg     <= x2      - sim_x_reg;
            ss_y2_reg     <= y2      - sim_y_reg;
            data_min_reg  <= aux_min - aux_value_reg;
            data_max_reg  <= aux_max - aux_value_reg;
        end
        if (rst) begin
            sim_x_reg     <= '0;
            sim_y_reg     <= '0;
            aux_value_reg <= '0;
            ss_x1_reg     <= '0;
            ss_y1_reg     <= '0;
            ss_x2_reg     <= '0;
            ss_y2_reg     <= '0;
            data_min_reg  <= '0;
            data_max_reg  <= '0;
            strobe_d      <= 0;
            strobe_dd     <= 0;
        end
    end

endmodule
