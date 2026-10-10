`timescale 1ns / 1ps

module pwm_led (
    input  wire       clk,       // 125 MHz PYNQ-Z2 clock
    input  wire [3:0] btn,       // Button inputs
    output reg        led = 1'b0
);

    // --------------------------------------------------------
    // 8-bit PWM counter
    // Counts from 0 to 255 repeatedly
    // --------------------------------------------------------
    reg [7:0] pwm_counter = 8'd0;

    // --------------------------------------------------------
    // Duty-cycle value
    // 9 bits are required because 256 cannot fit in 8 bits
    // --------------------------------------------------------
    reg [8:0] duty_cycle;

    // --------------------------------------------------------
    // Button Selection
    //
    // 0001 -> 25%
    // 0010 -> 50%
    // 0100 -> 75%
    // 1000 -> 100%
    // --------------------------------------------------------
    always @(*) begin
        case (btn)

            4'b0001:
                duty_cycle = 9'd64;    // 25%

            4'b0010:
                duty_cycle = 9'd128;   // 50%

            4'b0100:
                duty_cycle = 9'd192;   // 75%

            4'b1000:
                duty_cycle = 9'd256;   // 100%

            default:
                duty_cycle = 9'd256;   // 100%

        endcase
    end

    // --------------------------------------------------------
    // PWM Generator
    // --------------------------------------------------------
    always @(posedge clk) begin

        // PWM counter continuously wraps from 255 to 0
        pwm_counter <= pwm_counter + 1'b1;

        // 100% duty cycle
        if (duty_cycle == 9'd256)
            led <= 1'b1;

        // Normal PWM operation
        else if (pwm_counter < duty_cycle)
            led <= 1'b1;

        // LED OFF
        else
            led <= 1'b0;

    end

endmodule