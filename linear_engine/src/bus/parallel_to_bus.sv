`include "../interfaces/parallel_if.svh"
`include "../interfaces/bus_if.svh"

module parallel_to_bus #(
    `PARALLEL_IF__BI_PARAMS(parallel),
    `BUS_IF__PARAMS(bus)
) (
    input clk,
    input rst,

    `PARALLEL_IF__BI_PORTS(parallel),
    `BUS_IF__MASTER_PORTS(bus),

    output overflow,
    output miss,
    output error
);
    localparam int BUS_WIDTH             = DATA_WIDTH_bus;
    localparam int BYTE_ADDRESS_WIDTH    = BYTE_ADDRESS_WIDTH_bus;
    localparam int BYTE_WIDTH            = BYTE_WIDTH_bus;
    localparam int WORD_SIZE             = WORD_SIZE_bus;
    localparam int WORD_ADDRESS_WIDTH    = WORD_ADDRESS_WIDTH_bus;
    localparam int PARALLEL_WIDTH        = DATA_WIDTH_parallel_tx;
    localparam int ADDRESS_PART_SECTIONS = (WORD_ADDRESS_WIDTH + 2 + PARALLEL_WIDTH - 1) / PARALLEL_WIDTH;
    localparam int ADDRESS_PART_WIDTH    = ADDRESS_PART_SECTIONS * PARALLEL_WIDTH;
    localparam int DATA_PART_SECTIONS    = (BUS_WIDTH + PARALLEL_WIDTH - 1) / PARALLEL_WIDTH;
    localparam int DATA_PART_WIDTH       = DATA_PART_SECTIONS * PARALLEL_WIDTH;
    localparam int SECTION_COUNTER_WIDTH = $clog2(ADDRESS_PART_SECTIONS + DATA_PART_SECTIONS);

    localparam int OP_NONE  = 2'b00;
    localparam int OP_READ  = 2'b01;
    localparam int OP_WRITE = 2'b10;
    localparam int OP_BURST = 2'b11;

    enum int unsigned {
        STATE_ADDRESS,
        STATE_COUNTER,
        STATE_DATA,
        STATE_BUS,
        STATE_READ
    } state_reg, state_next;

    reg [SECTION_COUNTER_WIDTH-1:0] section_counter;
    reg [SECTION_COUNTER_WIDTH-1:0] result_counter;
    reg [   ADDRESS_PART_WIDTH-1:0] address_part;
    reg [      DATA_PART_WIDTH-1:0] counter_part;
    reg [      DATA_PART_WIDTH-1:0] data_part;
    reg [      DATA_PART_WIDTH-1:0] result;

    reg read, write;

    wire [ADDRESS_PART_WIDTH-1:0] tmp = address_part << PARALLEL_WIDTH | parallel_rx_data;
    wire [                   1:0] op = tmp[ADDRESS_PART_WIDTH-1:ADDRESS_PART_WIDTH-2];

    assign bus_data_ctp    = data_part;
    assign bus_address     = address_part;
    assign bus_byte_enable = '1;
    assign bus_read        = state_reg == STATE_BUS && read;
    assign bus_write       = state_reg == STATE_BUS && write;

    assign parallel_rx_ready = state_reg == STATE_ADDRESS || state_reg == STATE_COUNTER || state_reg == STATE_DATA;
    assign parallel_tx_data  = state_reg == STATE_READ ? bus_data_ptc[DATA_PART_WIDTH-1-:PARALLEL_WIDTH] : result[DATA_PART_WIDTH-1-:PARALLEL_WIDTH];
    assign parallel_tx_valid = (state_reg == STATE_READ ||  result_counter != '0) &&  parallel_tx_ready;
    assign overflow          =  state_reg == STATE_READ && (result_counter != '0  || !parallel_tx_ready);

    assign miss  = state_reg == STATE_BUS && !bus_hit;
    assign error = state_reg == STATE_BUS &&  bus_error;

    always_comb begin
        case (op)
            OP_NONE: begin
                state_next = STATE_ADDRESS;
            end
            OP_READ: begin
                state_next = STATE_BUS;
            end
            OP_WRITE: begin
                state_next = STATE_DATA;
            end
            OP_BURST: begin
                state_next = STATE_COUNTER;
            end
        endcase
    end

    always @(posedge clk) begin
        case (state_reg)
            STATE_ADDRESS: begin
                if (parallel_rx_valid && parallel_rx_ready) begin
                    address_part <= address_part << PARALLEL_WIDTH | parallel_rx_data;
                    section_counter <= section_counter + 1'd1;
                    if (section_counter == ADDRESS_PART_SECTIONS - 1'd1) begin
                        state_reg       <= state_next;
                        section_counter <= '0;
                        counter_part    <= 1'd1;
                        read            <= op == OP_READ;
                        write           <= op == OP_WRITE || op == OP_BURST;
                    end
                end
            end
            STATE_COUNTER: begin
                if (parallel_rx_valid && parallel_rx_ready) begin
                    counter_part <= counter_part << PARALLEL_WIDTH | parallel_rx_data;
                    section_counter <= section_counter + 1'd1;
                    if (section_counter == DATA_PART_SECTIONS - 1'd1) begin
                        state_reg       <= STATE_DATA;
                        section_counter <= '0;
                    end
                end
            end
            STATE_DATA: begin
                if (parallel_rx_valid && parallel_rx_ready) begin
                    data_part <= data_part << PARALLEL_WIDTH | parallel_rx_data;
                    section_counter <= section_counter + 1'd1;
                    if (section_counter == DATA_PART_SECTIONS - 1'd1) begin
                        state_reg       <= STATE_BUS;
                        section_counter <= '0;
                    end
                end
            end
            STATE_BUS: begin
                if (!bus_hit || bus_error) begin
                    state_reg <= STATE_ADDRESS;
                end
                if (bus_hit && bus_complete) begin
                    if (read) begin
                        state_reg <= STATE_READ;
                    end else begin
                        if (counter_part == 1'd1) begin
                            state_reg <= STATE_ADDRESS;
                        end else begin
                            counter_part <= counter_part - 1'd1;
                            address_part <= address_part + 1'd1;
                            state_reg <= STATE_DATA;
                        end
                    end
                end
            end
            STATE_READ: begin
                state_reg      <= STATE_ADDRESS;
                result_counter <= DATA_PART_SECTIONS - 1'd1;
                result         <= bus_data_ptc << PARALLEL_WIDTH;
            end
        endcase
        if (parallel_tx_valid && result_counter != '0) begin
            result_counter <= result_counter - 1'd1;
            result         <= result << PARALLEL_WIDTH;
        end
        if (rst) begin
            state_reg       <= STATE_ADDRESS;
            section_counter <= '0;
            result_counter  <= '0;
            address_part    <= '0;
            counter_part    <= '0;
            data_part       <= '0;
            result          <= '0;
            read            <= '0;
            write           <= '0;
        end
    end

endmodule
