`include "../interfaces/bus_if.svh"

module camera_mem_interface #(
    parameter int BASE_ADDRESS,
    parameter int PIXEL_WIDTH,
    parameter int SCREEN_WIDTH,
    parameter int SCREEN_HEIGHT,
    parameter int WIDTH,
    `BUS_IF__PARAMS(port)
) (
    input clk,
    input rst,

    `BUS_IF__SLAVE_PORTS(port),

    input  [DATA_WIDTH_port/PIXEL_WIDTH-1:0][PIXEL_WIDTH-1:0] data_in,
    output [DATA_WIDTH_port/PIXEL_WIDTH-1:0][      WIDTH-1:0] camera_x,
    output [DATA_WIDTH_port/PIXEL_WIDTH-1:0][      WIDTH-1:0] camera_y
);
    localparam int DATA_WIDTH               = DATA_WIDTH_port;
    localparam int BYTE_ADDRESS_WIDTH       = BYTE_ADDRESS_WIDTH_port;
    localparam int BYTE_WIDTH               = BYTE_WIDTH_port;
    localparam int WORD_SIZE                = WORD_SIZE_port;
    localparam int WORD_ADDRESS_WIDTH       = WORD_ADDRESS_WIDTH_port;
    localparam int SIZE_BYTES               = SCREEN_WIDTH * SCREEN_HEIGHT * PIXEL_WIDTH / BYTE_WIDTH;
    localparam int SIZE_WORDS               = SIZE_BYTES / WORD_SIZE;
    localparam int LOCAL_ADDRESS_WIDTH      = $clog2(SIZE_WORDS);
    localparam int LOCAL_BYTE_ADDRESS_WIDTH = $clog2(SIZE_BYTES);
    localparam int DEVICE_ADDRESS_WIDTH     = WORD_ADDRESS_WIDTH - LOCAL_ADDRESS_WIDTH;
    localparam int DEVICE_ADDRESS           = BASE_ADDRESS[BYTE_ADDRESS_WIDTH-1:LOCAL_BYTE_ADDRESS_WIDTH];
    localparam int CAMERA_INSTANCES         = DATA_WIDTH / PIXEL_WIDTH;
    localparam int INSTANCE_WIDTH           = $clog2(CAMERA_INSTANCES);
    localparam int SCREEN_X_WIDTH           = $clog2(SCREEN_WIDTH);
    localparam int SCREEN_Y_WIDTH           = $clog2(SCREEN_HEIGHT);

    wire [DEVICE_ADDRESS_WIDTH-1:0] device_address = port_address[WORD_ADDRESS_WIDTH-1:LOCAL_ADDRESS_WIDTH];
    wire [ LOCAL_ADDRESS_WIDTH-1:0] local_address  = port_address[LOCAL_ADDRESS_WIDTH-1:0];
    wire [          DATA_WIDTH-1:0] data_out;

    wire hit       = device_address == DEVICE_ADDRESS;
    wire read_hit  = hit && port_read;

    reg read_hit_reg;

    assign port_data_ptc    = read_hit_reg ? data_out : 'z;
    assign port_hit_address = {DEVICE_ADDRESS, {LOCAL_ADDRESS_WIDTH{1'b0}}};
    assign port_hit_mask    = {{DEVICE_ADDRESS_WIDTH{1'b1}}, {LOCAL_ADDRESS_WIDTH{1'b0}}};
    assign port_hit         = hit ? '1         : 'z;
    assign port_complete    = hit ? port_read  : 'z;
    assign port_error       = hit ? port_write : 'z;

    always @(posedge clk) begin
        read_hit_reg <= read_hit;
        if (rst) begin
            read_hit_reg <= '0;
        end
    end

    genvar i;
    generate
        for (i = 0; i < CAMERA_INSTANCES; i++) begin : g_data_out_a
            assign data_out[i*PIXEL_WIDTH+:PIXEL_WIDTH] = data_in[i];
            wire [LOCAL_BYTE_ADDRESS_WIDTH-1:0] local_byte_address = {local_address, i[INSTANCE_WIDTH-1:0]};
            assign camera_x[i] = local_byte_address[0+:SCREEN_X_WIDTH];
            assign camera_y[i] = local_byte_address[SCREEN_X_WIDTH+:SCREEN_Y_WIDTH];
        end
    endgenerate

endmodule
