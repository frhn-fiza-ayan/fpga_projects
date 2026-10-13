
`timescale 1ns / 1ps

module tb_uart_echo;

    reg clk;
    reg rst;
    reg btn_nibble;

    wire uart_a_tx;
    wire uart_b_tx;

    wire [3:0] data_led;
    wire rgb_green_n;
    wire rgb_red_n;

    // Board A: Sends A5 and verifies the echoed byte
    uart_echo_board_a #(
        .CLK_FREQ(125_000_000),
        .BAUD_RATE(9600),
        .DEBOUNCE_COUNT(20)
    ) board_a (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_b_tx),
        .uart_tx(uart_a_tx),
        .btn_nibble(btn_nibble),
        .data_led(data_led),
        .rgb_green_n(rgb_green_n),
        .rgb_red_n(rgb_red_n)
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

    // Apply reset and check the echo result
    initial begin
        rst = 1'b1;
        btn_nibble = 1'b0;

        repeat (20) @(posedge clk);
        rst = 1'b0;

        // Wait for PASS (active-low green output)
        // or FAIL (active-low red output).
        wait ((rgb_green_n == 1'b0) ||
              (rgb_red_n == 1'b0));

        if (rgb_green_n == 1'b0) begin
            $display("TEST PASSED: UART echo received 8'hA5 correctly.");
            $display("Upper nibble display = %b", data_led);

            // Press button to select lower nibble
            btn_nibble = 1'b1;
            repeat (30) @(posedge clk);
            btn_nibble = 1'b0;
            repeat (30) @(posedge clk);

            $display("Lower nibble display = %b", data_led);
        end else begin
            $display("TEST FAILED: UART echo data mismatch.");
        end

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
