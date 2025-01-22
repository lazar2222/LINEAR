module priority_mask #(
    parameter int WIDTH,
    parameter int COUNT
) (
    input  [        COUNT-1:0][WIDTH-1:0] values,
    input  [        COUNT-1:0]            enable,
    output [        WIDTH-1:0]            masked,
    output [        COUNT-1:0]            prio_enable,
    output [$clog2(COUNT)-1:0]            prio_sel,
    output                                prio_any
);
    priority_enc #(
        .WIDTH(COUNT)
    ) priority_enc (
        .in (enable),
        .out(prio_enable),
        .sel(prio_sel),
        .any(prio_any)
    );

    mask #(
        .WIDTH(WIDTH),
        .COUNT(COUNT)
    ) mask (
        .values(values),
        .enable(prio_enable),
        .masked(masked)
    );

endmodule
