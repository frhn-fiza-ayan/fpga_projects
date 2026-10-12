`timescale 1ns / 1ps

// ============================================================
// 1-Digit Hardware Stopwatch
// Target : PYNQ-Z2
// Display: 5161AS (Common Cathode)
// Clock  : 125 MHz
//
// BTN0 -> Reset
// BTN1 -> Start / Stop
//
// Display:
//   0 -> 1 -> 2 -> ... -> 9 -> 0
//
// Segment outputs:
//   seg[6] = A
//   seg[5] = B
//   seg[4] = C
//   seg[3] = D
//   seg[2] = E
//   seg[1] = F
//   seg[0] = G
//
// Common Cathode:
//   segment ON  = 1
//   segment OFF = 0
//
// ============================================================

module hardware_stopwatch #(
    parameter CLK_FREQ_HZ = 125_000_000
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       start_stop,

    output reg [6:0]  seg,
    output wire       dp
);

    // ========================================================
    // 1. Button Synchronization
    // ========================================================

    reg reset_ff1, reset_ff2;
    reg start_ff1, start_ff2;

    always @(posedge clk) begin
        reset_ff1 <= reset;
        reset_ff2 <= reset_ff1;

        start_ff1 <= start_stop;
        start_ff2 <= start_ff1;
    end

    // ========================================================
    // 2. Button Debouncer
    // ========================================================

    // ~20 ms debounce time
    localparam integer DEBOUNCE_COUNT =
                    CLK_FREQ_HZ / 50;

    reg [31:0] reset_debounce_count = 32'd0;
    reg [31:0] start_debounce_count = 32'd0;

    reg reset_clean = 1'b0;
    reg start_clean = 1'b0;

    always @(posedge clk) begin

        // ----------------------------
        // RESET button debounce
        // ----------------------------
        if (reset_ff2 != reset_clean) begin

            if (reset_debounce_count < DEBOUNCE_COUNT) begin
                reset_debounce_count <=
                    reset_debounce_count + 1'b1;
            end
            else begin
                reset_clean <= reset_ff2;
                reset_debounce_count <= 32'd0;
            end

        end
        else begin
            reset_debounce_count <= 32'd0;
        end


        // ----------------------------
        // START/STOP button debounce
        // ----------------------------
        if (start_ff2 != start_clean) begin

            if (start_debounce_count < DEBOUNCE_COUNT) begin
                start_debounce_count <=
                    start_debounce_count + 1'b1;
            end
            else begin
                start_clean <= start_ff2;
                start_debounce_count <= 32'd0;
            end

        end
        else begin
            start_debounce_count <= 32'd0;
        end

    end

    // ========================================================
    // 3. Button Rising-Edge Detection
    // ========================================================

    reg reset_clean_d = 1'b0;
    reg start_clean_d = 1'b0;

    wire reset_pressed;
    wire start_pressed;

    assign reset_pressed =
                reset_clean & ~reset_clean_d;

    assign start_pressed =
                start_clean & ~start_clean_d;

    always @(posedge clk) begin
        reset_clean_d <= reset_clean;
        start_clean_d <= start_clean;
    end

    // ========================================================
    // 4. Stopwatch Run/Stop Control
    // ========================================================

    reg running = 1'b0;

    always @(posedge clk) begin

        if (reset_pressed) begin
            running <= 1'b0;
        end

        else if (start_pressed) begin
            running <= ~running;
        end

    end

    // ========================================================
    // 5. 1-Second Clock Enable
    // ========================================================

    reg [31:0] clk_counter = 32'd0;
    reg        one_second_tick = 1'b0;

    always @(posedge clk) begin

        if (reset_pressed) begin

            clk_counter <= 32'd0;
            one_second_tick <= 1'b0;

        end

        else if (running) begin

            if (clk_counter == CLK_FREQ_HZ - 1) begin

                clk_counter <= 32'd0;
                one_second_tick <= 1'b1;

            end
            else begin

                clk_counter <= clk_counter + 1'b1;
                one_second_tick <= 1'b0;
            end

        end

        else begin

            clk_counter <= 32'd0;
            one_second_tick <= 1'b0;

        end

    end

    // ========================================================
    // 6. Stopwatch Counter
    // ========================================================

    reg [3:0] seconds = 4'd0;

    always @(posedge clk) begin

        if (reset_pressed) begin

            seconds <= 4'd0;

        end

        else if (one_second_tick) begin

            if (seconds == 4'd9)
                seconds <= 4'd0;
            else
                seconds <= seconds + 1'b1;

        end

    end

    // ========================================================
    // 7. 7-Segment Decoder
    //
    // Common Cathode
    // 1 = ON
    // 0 = OFF
    //
    // seg[6:0] = A B C D E F G
    // ========================================================

    always @(*) begin

        case (seconds)

            4'd0:
                seg = 7'b1111110;

            4'd1:
                seg = 7'b0110000;

            4'd2:
                seg = 7'b1101101;

            4'd3:
                seg = 7'b1111001;

            4'd4:
                seg = 7'b0110011;

            4'd5:
                seg = 7'b1011011;

            4'd6:
                seg = 7'b1011111;

            4'd7:
                seg = 7'b1110000;

            4'd8:
                seg = 7'b1111111;

            4'd9:
                seg = 7'b1111011;

            default:
                seg = 7'b0000000;

        endcase

    end

    // Decimal point permanently OFF
    assign dp = 1'b0;

endmodule