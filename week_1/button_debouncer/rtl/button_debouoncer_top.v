`timescale 1ns / 1ps

module button_debouncer_top (
    input  wire clk,
    input  wire btn,
    output wire led
);

    wire clean_btn;

    button_debouncer #(
        .DEBOUNCE_COUNT(1_250_000)
    ) debounce_inst (
        .clk(clk),
        .btn(btn),
        .debounced_btn(clean_btn)
    );

    assign led = clean_btn;

endmodule