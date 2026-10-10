`timescale 1ns / 1ps

module traffic_light_fsm_pynqz2 #(
    parameter integer CLK_FREQ_HZ = 125_000_000,
    parameter integer GREEN_TIME  = 10,
    parameter integer YELLOW_TIME = 3
)(
    input  wire clk,
    input  wire reset,

    // =========================================================
    // LD4 - North/South traffic light
    //
    // PYNQ-Z2 RGB LEDs are ACTIVE-LOW:
    // 0 = ON
    // 1 = OFF
    // =========================================================
    output reg led4_r,
    output reg led4_g,
    output reg led4_b,

    // =========================================================
    // LD5 - East/West traffic light
    //
    // ACTIVE-LOW:
    // 0 = ON
    // 1 = OFF
    // =========================================================
    output reg led5_r,
    output reg led5_g,
    output reg led5_b
);


    // =========================================================
    // STATE DEFINITIONS
    // =========================================================

    localparam NS_GREEN  = 2'b00;
    localparam NS_YELLOW = 2'b01;
    localparam EW_GREEN  = 2'b10;
    localparam EW_YELLOW = 2'b11;

    reg [1:0] state;
    reg [1:0] next_state;


    // =========================================================
    // 1-SECOND CLOCK ENABLE
    // =========================================================

    localparam integer CLK_COUNTER_WIDTH = $clog2(CLK_FREQ_HZ);

    reg [CLK_COUNTER_WIDTH-1:0] clk_counter;
    reg one_second_tick;

    always @(posedge clk) begin

        if (reset) begin
            clk_counter     <= 0;
            one_second_tick <= 1'b0;
        end

        else if (clk_counter == CLK_FREQ_HZ - 1) begin
            clk_counter     <= 0;
            one_second_tick <= 1'b1;
        end

        else begin
            clk_counter     <= clk_counter + 1'b1;
            one_second_tick <= 1'b0;
        end

    end


    // =========================================================
    // STATE DURATION COUNTER
    // =========================================================

    localparam integer STATE_COUNTER_WIDTH =
        $clog2(
            (GREEN_TIME > YELLOW_TIME ?
             GREEN_TIME : YELLOW_TIME) + 1
        );

    reg [STATE_COUNTER_WIDTH-1:0] state_counter;

    always @(posedge clk) begin

        if (reset) begin
            state_counter <= 0;
        end

        else if (one_second_tick) begin

            case (state)

                NS_GREEN: begin
                    if (state_counter == GREEN_TIME - 1)
                        state_counter <= 0;
                    else
                        state_counter <= state_counter + 1'b1;
                end

                NS_YELLOW: begin
                    if (state_counter == YELLOW_TIME - 1)
                        state_counter <= 0;
                    else
                        state_counter <= state_counter + 1'b1;
                end

                EW_GREEN: begin
                    if (state_counter == GREEN_TIME - 1)
                        state_counter <= 0;
                    else
                        state_counter <= state_counter + 1'b1;
                end

                EW_YELLOW: begin
                    if (state_counter == YELLOW_TIME - 1)
                        state_counter <= 0;
                    else
                        state_counter <= state_counter + 1'b1;
                end

                default: begin
                    state_counter <= 0;
                end

            endcase

        end

    end


    // =========================================================
    // STATE REGISTER
    // =========================================================

    always @(posedge clk) begin

        if (reset)
            state <= NS_GREEN;
        else
            state <= next_state;

    end


    // =========================================================
    // NEXT STATE LOGIC
    // =========================================================

    always @(*) begin

        next_state = state;

        case (state)

            // -------------------------------------------------
            // NORTH-SOUTH GREEN
            // -------------------------------------------------

            NS_GREEN: begin

                if (one_second_tick &&
                    state_counter == GREEN_TIME - 1)

                    next_state = NS_YELLOW;

            end


            // -------------------------------------------------
            // NORTH-SOUTH YELLOW
            // -------------------------------------------------

            NS_YELLOW: begin

                if (one_second_tick &&
                    state_counter == YELLOW_TIME - 1)

                    next_state = EW_GREEN;

            end


            // -------------------------------------------------
            // EAST-WEST GREEN
            // -------------------------------------------------

            EW_GREEN: begin

                if (one_second_tick &&
                    state_counter == GREEN_TIME - 1)

                    next_state = EW_YELLOW;

            end


            // -------------------------------------------------
            // EAST-WEST YELLOW
            // -------------------------------------------------

            EW_YELLOW: begin

                if (one_second_tick &&
                    state_counter == YELLOW_TIME - 1)

                    next_state = NS_GREEN;

            end


            // -------------------------------------------------
            // SAFETY DEFAULT
            // -------------------------------------------------

            default: begin
                next_state = NS_GREEN;
            end

        endcase

    end


    // =========================================================
    // TRAFFIC LIGHT OUTPUT LOGIC
    //
    // ACTIVE-LOW
    //
    // 0 = LED ON
    // 1 = LED OFF
    //
    // Yellow = RED + GREEN
    // Blue   = OFF
    // =========================================================

    always @(*) begin

        // -------------------------------------------------
        // DEFAULT: ALL LEDs OFF
        // -------------------------------------------------

        led4_r = 1'b1;
        led4_g = 1'b1;
        led4_b = 1'b1;

        led5_r = 1'b1;
        led5_g = 1'b1;
        led5_b = 1'b1;


        case (state)

            // =================================================
            // NORTH-SOUTH GREEN
            //
            // LD4 = GREEN
            // LD5 = RED
            // =================================================

            NS_GREEN: begin

                // LD4 GREEN ON
                led4_g = 1'b0;

                // LD5 RED ON
                led5_r = 1'b0;

            end


            // =================================================
            // NORTH-SOUTH YELLOW
            //
            // LD4 = YELLOW
            // LD5 = RED
            // =================================================

            NS_YELLOW: begin

                // LD4 RED + GREEN = YELLOW
                led4_r = 1'b0;
                led4_g = 1'b0;

                // LD5 RED
                led5_r = 1'b0;

            end


            // =================================================
            // EAST-WEST GREEN
            //
            // LD4 = RED
            // LD5 = GREEN
            // =================================================

            EW_GREEN: begin

                // LD4 RED
                led4_r = 1'b0;

                // LD5 GREEN
                led5_g = 1'b0;

            end


            // =================================================
            // EAST-WEST YELLOW
            //
            // LD4 = RED
            // LD5 = YELLOW
            // =================================================

            EW_YELLOW: begin

                // LD4 RED
                led4_r = 1'b0;

                // LD5 RED + GREEN = YELLOW
                led5_r = 1'b0;
                led5_g = 1'b0;

            end


            // =================================================
            // SAFETY DEFAULT
            // =================================================

            default: begin

                led4_r = 1'b1;
                led4_g = 1'b1;
                led4_b = 1'b1;

                led5_r = 1'b1;
                led5_g = 1'b1;
                led5_b = 1'b1;

            end

        endcase

    end

endmodule