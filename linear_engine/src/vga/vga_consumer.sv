`include "../interfaces/parallel_if.svh"

module vga_consumer #(
    `PARALLEL_IF__UNI_PARAMS(input_port)
) (
    input clk,
    input rst,

    `PARALLEL_IF__UNI_RX_PORTS(input_port),

    input visible_area,

    input mono,
    input [1:0] pixel_width_select,

    output [7:0] r,
    output [7:0] g,
    output [7:0] b,

    output underflow
);
    wire [5:0] components_per_word = DATA_WIDTH_input_port >> pixel_width_select;
    wire [5:0] pixels_per_word     = mono ? components_per_word : (components_per_word >> 2);
    wire [5:0] pixel_width         = 2 ** pixel_width_select;
    wire [5:0] downshift           = mono ? pixel_width : (pixel_width << 2);

    reg [5:0] counter;

    wire [23:0] pixel_block = input_port_data >> (counter * downshift);
    wire [7:0]  r_block     = pixel_block;
    wire [7:0]  g_block     = pixel_block >> pixel_width;
    wire [7:0]  b_block     = pixel_block >> (pixel_width << 1);

    wire [3:0][7:0] r_block_loop;
    wire [3:0][7:0] g_block_loop;
    wire [3:0][7:0] b_block_loop;

    assign r = mono ? r_block_loop[pixel_width_select] : r_block_loop[pixel_width_select];
    assign g = mono ? r_block_loop[pixel_width_select] : g_block_loop[pixel_width_select];
    assign b = mono ? r_block_loop[pixel_width_select] : b_block_loop[pixel_width_select];

    assign input_port_ready = visible_area && (counter == (pixels_per_word - 1'd1)) &&  input_port_valid;
    assign underflow        = visible_area && (counter == (pixels_per_word - 1'd1)) && !input_port_valid;

    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : g_loopers
            looper #(
                .INPUT_WIDTH (2**i),
                .OUTPUT_WIDTH(8)
            ) looper_r (
                .data_in (r_block[(2**i)-1:0]),
                .data_out(r_block_loop[i])
            );
            looper #(
                .INPUT_WIDTH (2**i),
                .OUTPUT_WIDTH(8)
            ) looper_g (
                .data_in (g_block[(2**i)-1:0]),
                .data_out(g_block_loop[i])
            );
            looper #(
                .INPUT_WIDTH (2**i),
                .OUTPUT_WIDTH(8)
            ) looper_b (
                .data_in (b_block[(2**i)-1:0]),
                .data_out(b_block_loop[i])
            );
        end
    endgenerate

    always @(posedge clk) begin
        if (visible_area) begin
            counter <= counter + 1'd1;
            if (counter == (pixels_per_word - 1'd1)) begin
                counter <= '0;
            end
        end
        if (rst) begin
            counter <= '0;
        end
    end
    
endmodule
