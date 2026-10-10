`timescale 1ns / 1ps

module button_controlled_counter (
    input  wire       clk,
    input  wire       btn,
    output reg [3:0]  led = 4'b0000
);

    // =========================================================
    // 1. BUTTON SYNCHRONIZER
    // =========================================================

    reg btn_ff1 = 1'b0;
    reg btn_ff2 = 1'b0;

    always @(posedge clk) begin
        btn_ff1 <= btn;
        btn_ff2 <= btn_ff1;
    end


    // =========================================================
    // 2. DEBOUNCER
    // =========================================================

    parameter DEBOUNCE_COUNT = 1_250_000;

    reg [20:0] debounce_counter = 21'd0;
    reg clean_btn = 1'b0;

    always @(posedge clk) begin

        if (btn_ff2 == clean_btn) begin
            debounce_counter <= 21'd0;
        end

        else begin

            if (debounce_counter < DEBOUNCE_COUNT - 1) begin
                debounce_counter <= debounce_counter + 1'b1;
            end

            else begin
                clean_btn <= btn_ff2;
                debounce_counter <= 21'd0;
            end

        end

    end


    // =========================================================
    // 3. RISING-EDGE DETECTION
    // =========================================================

    reg btn_previous = 1'b0;

    always @(posedge clk) begin
        btn_previous <= clean_btn;
    end


    // =========================================================
    // 4. COUNTER
    // =========================================================

    always @(posedge clk) begin

        if (clean_btn && !btn_previous) begin
            led <= led + 1'b1;
        end

    end

endmodule