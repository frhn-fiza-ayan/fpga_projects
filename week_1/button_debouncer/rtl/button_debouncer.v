`timescale 1ns / 1ps

module button_debouncer #(
    parameter integer DEBOUNCE_COUNT = 1_250_000
)(
    input  wire clk,
    input  wire btn,
    output reg debounced_btn = 1'b0
);

    // ========================================================
    // Two-flip-flop synchronizer
    // ========================================================

    reg btn_ff1 = 1'b0;
    reg btn_ff2 = 1'b0;

    always @(posedge clk) begin
        btn_ff1 <= btn;
        btn_ff2 <= btn_ff1;
    end


    // ========================================================
    // Debounce counter
    // 125 MHz clock
    // 1,250,000 cycles = 10 ms
    // ========================================================

    reg [20:0] counter = 21'd0;

    always @(posedge clk) begin

        if (btn_ff2 == debounced_btn) begin
            // Button is stable
            counter <= 21'd0;
        end

        else begin
            // Button state has changed
            if (counter < DEBOUNCE_COUNT - 1) begin
                counter <= counter + 1'b1;
            end

            else begin
                // New button state has remained stable
                // for the required debounce time
                debounced_btn <= btn_ff2;
                counter <= 21'd0;
            end
        end

    end

endmodule