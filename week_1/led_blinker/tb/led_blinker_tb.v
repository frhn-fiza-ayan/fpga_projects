`timescale 1ns/1ps

module led_blinker_tb;

    reg clk;
    wire led;

    led_blinker uut (
        .clk(clk),
        .led(led)
    );

    // Clock: 100 MHz
    always #4 clk = ~clk;

    initial begin

        clk = 0;

        // Initialize DUT registers
        uut.counter = 27'd124_999_990;
        uut.led = 0;

        #2000000000;

        $finish;

    end

endmodule