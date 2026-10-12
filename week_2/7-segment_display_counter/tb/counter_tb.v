`timescale 1ns / 1ps

module seven_segment_counter_tb;

    reg clk;

    wire [6:0] seg;
    wire digit;

    seven_segment_counter #(
        .COUNT_MAX(9)
    ) uut (
        .clk(clk),
        .seg(seg),
        .digit(digit)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;

        #2000;

        $finish;

    end

endmodule