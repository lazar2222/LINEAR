module occlusion_checker #(
    parameter int WIDTH
) (
    input [WIDTH-1:0] world_x,
    input [WIDTH-1:0] world_y,
    input [WIDTH-1:0] x1,
    input [WIDTH-1:0] y1,
    input [WIDTH-1:0] x2,
    input [WIDTH-1:0] y2,

    output [WIDTH-1:0] fill_x,
    output [WIDTH-1:0] fill_y,
    output             visible
);
    wire visible_x = (world_x >= x1) && (world_x < x2);
    wire visible_y = (world_y >= y1) && (world_y < y2);

    assign fill_x = world_x - x1;
    assign fill_y = world_y - y1;

    assign visible = visible_x && visible_y;

endmodule
