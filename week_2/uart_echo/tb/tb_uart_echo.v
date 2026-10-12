
`timescale 1ns / 1ps

module tb_uart_echo;

    reg clk;
    reg rst;

    wire uart_a_tx;
    wire uart_b_tx;

    wire led_pass;
    wire led_fail;

    // Board A: Sends 8'hA5 and checks the echo
    uart_echo_board_a #(
        .CLK_FREQ(125_000_000),
        .BAUD_RATE(9600)
    ) board_a (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_b_tx),
        .uart_tx(uart_a_tx),
        .led_pass(led_pass),
        .led_fail(led_fail)
    );

    // Board B: Receives and echoes the byte
    uart_echo_board_b #(
        .CLK_FREQ(125_000_000),
        .BAUD_RATE(9600)
    ) board_b (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_a_tx),
        .uart_tx(uart_b_tx)
    );

    // 125 MHz clock: 8 ns period
    initial begin
        clk = 1'b0;
        forever #4 clk = ~clk;
    end

    // Reset and run the test
    initial begin
        rst = 1'b1;

        repeat (20) @(posedge clk);
        rst = 1'b0;

        // Wait for Board A to report PASS or FAIL
        wait (led_pass || led_fail);

        if (led_pass)
            $display("TEST PASSED: UART echo received 8'hA5 correctly.");
        else
            $display("TEST FAILED: UART echo data mismatch.");

        #100;
        $finish;
    end

    // Timeout protection
    initial begin
        #5_000_000;
        $display("TEST FAILED: Simulation timed out.");
        $finish;
    end

endmodule
