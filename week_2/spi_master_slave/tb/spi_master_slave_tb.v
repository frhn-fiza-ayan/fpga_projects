
`timescale 1ns / 1ps

module spi_master_slave_tb;

    reg clk = 1'b0;
    reg master_btn = 1'b0;

    wire spi_cs;
    wire spi_sclk;
    wire spi_mosi;

    wire [3:0] master_led;
    wire [3:0] slave_led;

    // 100 MHz simulation clock
    always #5 clk = ~clk;

    // ==========================================
    // SPI MASTER
    // ==========================================

    spi_master_top #(
        .HALF_PERIOD(5),
        .START_DELAY_CYCLES(10),
        .DEBOUNCE_CYCLES(4)
    ) master (
        .clk(clk),
        .btn(master_btn),
        .spi_cs(spi_cs),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .led(master_led)
    );

    // ==========================================
    // SPI SLAVE
    // ==========================================

    spi_slave_top slave (
        .clk(clk),
        .spi_cs(spi_cs),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi),
        .led(slave_led)
    );

    // ==========================================
    // TEST SEQUENCE
    // ==========================================

    initial begin

        $display("--------------------------------");
        $display(" SPI MASTER-SLAVE TEST");
        $display("--------------------------------");

        // Wait for the initial A5 transmission.
        wait (master.started == 1'b1);
        wait (master.transfer_pending == 1'b0);
        wait (master.state == 2'd0);
        wait (spi_cs == 1'b1);
        wait (slave.received_byte == 8'hA5);
        #100;

        if (master_led !== 4'h5)
            $fatal(1, "FAIL: Master should display 5");

        if (slave_led !== 4'h5)
            $fatal(1, "FAIL: Slave should display 5");

        $display("PASS: Initial A5 received; both LEDs show 5");

        // Press Master BTN0.
        master_btn = 1'b1;
        repeat (8) @(posedge clk);
        master_btn = 1'b0;

        // Wait for the selected 3C transmission.
        wait (master.select_byte == 1'b1);
        wait (master.transfer_pending == 1'b0);
        wait (master.state == 2'd0);
        wait (spi_cs == 1'b1);
        wait (slave.received_byte == 8'h3C);
        #100;

        if (master_led !== 4'hC)
            $fatal(1, "FAIL: Master should display C");

        if (slave_led !== 4'hC)
            $fatal(1, "FAIL: Slave should display C");

        $display("PASS: 3C received; both LEDs show C");

        // Press again to return to A5.
        master_btn = 1'b1;
        repeat (8) @(posedge clk);
        master_btn = 1'b0;

        wait (master.select_byte == 1'b0);
        wait (master.transfer_pending == 1'b0);
        wait (master.state == 2'd0);
        wait (spi_cs == 1'b1);
        wait (slave.received_byte == 8'hA5);
        #100;

        if (master_led !== 4'h5)
            $fatal(1, "FAIL: Master should return to 5");

        if (slave_led !== 4'h5)
            $fatal(1, "FAIL: Slave should return to 5");

        $display("PASS: A5 received again; both LEDs show 5");
        $display("--------------------------------");
        $display(" ALL TESTS PASSED");
        $display("--------------------------------");

        $finish;
    end

    // Timeout protection
    initial begin
        #100000;
        $fatal(1, "TIMEOUT: SPI test did not complete");
    end

endmodule