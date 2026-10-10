`timescale 1ns/1ps

module multi_led_counter_tb;

    reg clk;
    wire [3:0] led;

    multi_led_counter uut (
        .clk(clk),
        .led(led)
    );

    // 100 MHz simulation clock
    always #4 clk = ~clk;

    initial begin

        clk = 0;

        // Start from zero
        uut.counter = 0;
        uut.led = 0;

        #1000;

        $finish;

    end

endmodule