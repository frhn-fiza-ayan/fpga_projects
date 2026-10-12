
`timescale 1ns / 1ps

module uart_tx_hw_top_tb;

    reg clk;
    wire uart_tx;
    wire [3:0] led_data;

    // 125 MHz clock: 8 ns period
    localparam BIT_PERIOD = 104167;

    integer i;
    reg [7:0] expected_data;

    uart_tx_hw_top dut (
        .clk(clk),
        .uart_tx(uart_tx),
        .led_data(led_data)
    );

    // Clock generation
    initial begin
        clk = 1'b0;
        forever #4 clk = ~clk;
    end

    initial begin
        expected_data = 8'hA5;

        $display("==================================");
        $display(" UART TX TOP TESTBENCH");
        $display("==================================");

        // Wait until the DUT finishes its reset
        wait (dut.rst == 1'b0);
        repeat (10) @(posedge clk);

        // Trigger one transmission immediately
        // instead of waiting for the 1-second counter.
        @(negedge clk);
        force dut.wr_en = 1'b1;
        @(posedge clk);
        #1;
        release dut.wr_en;

        // Wait for the UART start bit
        @(negedge uart_tx);

        // Start bit should be LOW at its center
        #(BIT_PERIOD / 2);

        if (uart_tx !== 1'b0) begin
            $display("FAIL: Invalid start bit");
            $finish;
        end

        $display("PASS: Start bit detected");

        // Move to the center of data bit 0
        #BIT_PERIOD;

        // UART transmits LSB first
        for (i = 0; i < 8; i = i + 1) begin
            if (uart_tx !== expected_data[i]) begin
                $display(
                    "FAIL: Data bit %0d, expected %b, got %b",
                    i, expected_data[i], uart_tx
                );
                $finish;
            end

            $display(
                "PASS: Data bit %0d = %b",
                i, uart_tx
            );

            #BIT_PERIOD;
        end

        // Check stop bit
        if (uart_tx !== 1'b1) begin
            $display("FAIL: Invalid stop bit");
            $finish;
        end

        $display("PASS: Stop bit detected");
        $display("PASS: UART transmitted byte 0xA5");
        $display("==================================");

        #BIT_PERIOD;
        $finish;
    end

    // Simulation timeout
    initial begin
        #2000000;
        $display("FAIL: TX testbench timed out");
        $finish;
    end

endmodule
