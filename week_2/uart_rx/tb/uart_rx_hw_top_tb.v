
`timescale 1ns / 1ps

module uart_rx_hw_top_tb;

    reg clk;
    reg uart_rx;

    wire [3:0] led_data;

    // 125 MHz clock, 9600 baud
    localparam integer BIT_PERIOD = 104167;

    integer i;
    reg [7:0] test_data;

    // Device under test
    uart_rx_hw_top dut (
        .clk      (clk),
        .uart_rx  (uart_rx),
        .led_data (led_data)
    );

    // Clock generation: 125 MHz
    initial begin
        clk = 1'b0;
        forever #4 clk = ~clk;
    end

    // Task to transmit one UART byte, LSB first
    task send_uart_byte;
        input [7:0] data;
        integer j;
        begin
            // Idle
            uart_rx = 1'b1;
            #(BIT_PERIOD);

            // Start bit
            uart_rx = 1'b0;
            #(BIT_PERIOD);

            // Eight data bits
            for (j = 0; j < 8; j = j + 1) begin
                uart_rx = data[j];
                #(BIT_PERIOD);
            end

            // Stop bit
            uart_rx = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    // Main test
    initial begin
        uart_rx  = 1'b1;
        test_data = 8'hA5;

        $display("====================================");
        $display(" UART RX TOP TEST");
        $display("====================================");

        // Wait for startup reset
        wait (dut.rst == 1'b0);
        repeat (10) @(posedge clk);

        $display("Sending byte 0x%h", test_data);

        send_uart_byte(test_data);

        // Allow receiver and LED logic to settle
        #(200000);

        // 0xA5 lower nibble = 0x5 = 0101
        if (led_data === 4'b0101) begin
            $display("PASS: UART byte received");
            $display("Sent byte  : 0x%h", test_data);
            $display("LED output : %b", led_data);
        end
        else begin
            $display("FAIL: UART reception check failed");
            $display("Expected LED output: 0101");
            $display("Actual LED output  : %b", led_data);
        end

        $display("====================================");
        $finish;
    end

    // Timeout protection
    initial begin
        #12000000;
        $display("ERROR: Simulation timed out");
        $finish;
    end

endmodule