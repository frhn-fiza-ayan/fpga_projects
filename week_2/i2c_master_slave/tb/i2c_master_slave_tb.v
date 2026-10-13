
`timescale 1ns / 1ps

module i2c_master_slave_tb;

    reg clk;
    reg rst;

    wire scl;
    tri1 sda;

    wire [7:0] tx_data;
    wire [7:0] rx_data;

    wire busy;
    wire done;
    wire ack_error;
    wire data_valid;

    integer timeout_count;
    integer errors;

    // ------------------------------------------------
    // I2C MASTER
    // ------------------------------------------------
    i2c_master #(
        .CLK_FREQ_HZ(1_000_000),
        .I2C_FREQ_HZ(100_000),
        .DEBOUNCE_CYCLES(10),
        .SLAVE_ADDR(7'h42)
    ) master_inst (
        .clk      (clk),
        .rst      (rst),
        .btn      (1'b0),
        .tx_data  (tx_data),
        .busy     (busy),
        .done     (done),
        .ack_error(ack_error),
        .scl      (scl),
        .sda      (sda)
    );

    // ------------------------------------------------
    // I2C SLAVE
    // ------------------------------------------------
    i2c_slave #(
        .SLAVE_ADDR(7'h42)
    ) slave_inst (
        .clk       (clk),
        .rst       (rst),
        .scl       (scl),
        .sda       (sda),
        .rx_data   (rx_data),
        .data_valid(data_valid)
    );

    // 1 MHz simulation clock: 500 ns period.
    initial begin
        clk = 1'b0;
        forever #250 clk = ~clk;
    end

    // ------------------------------------------------
    // Wait for completion, with a timeout.
    // ------------------------------------------------
    task wait_for_completion;
        begin
            timeout_count = 0;

            while ((done !== 1'b1) &&
                   (timeout_count < 10000)) begin
                @(posedge clk);
                #1;
                timeout_count = timeout_count + 1;
            end

            if (done !== 1'b1) begin
                $display("FAIL: Master timed out.");
                errors = errors + 1;
            end
        end
    endtask

    // ------------------------------------------------
    // Trigger one transaction at a divider tick.
    // This bypasses button debouncing so the I2C
    // protocol can be tested independently.
    // ------------------------------------------------
    task trigger_transaction;
        begin
            wait (master_inst.tick === 1'b1);

            force master_inst.btn_press = 1'b1;
            @(posedge clk);
            #1;
            release master_inst.btn_press;
        end
    endtask

    // ------------------------------------------------
    // TEST SEQUENCE
    // ------------------------------------------------
    initial begin
        errors = 0;
        rst = 1'b1;

        $display("------------------------------------");
        $display("I2C MASTER-SLAVE TESTBENCH");
        $display("Slave address: 0x42");
        $display("------------------------------------");

        repeat (5) @(posedge clk);
        #1;
        rst = 1'b0;

        // Allow the reset to propagate.
        repeat (10) @(posedge clk);

        // TEST 1: A5 -> 3C
        $display("TEST 1: Transmit 0x3C");

        trigger_transaction;
        wait_for_completion;

        if (tx_data === 8'h3C)
            $display("PASS: Master selected 0x3C");
        else begin
            $display("FAIL: Master data = %h, expected 3C",
                     tx_data);
            errors = errors + 1;
        end

        if (ack_error === 1'b0)
            $display("PASS: No ACK error reported");
        else begin
            $display("FAIL: ACK error reported");
            errors = errors + 1;
        end

        if (rx_data === 8'h3C)
            $display("PASS: Slave received 0x3C");
        else begin
            $display("FAIL: Slave data = %h, expected 3C",
                     rx_data);
            errors = errors + 1;
        end

        repeat (10) @(posedge clk);

        // TEST 2: 3C -> A5
        $display("TEST 2: Transmit 0xA5");

        trigger_transaction;
        wait_for_completion;

        if (tx_data === 8'hA5)
            $display("PASS: Master selected 0xA5");
        else begin
            $display("FAIL: Master data = %h, expected A5",
                     tx_data);
            errors = errors + 1;
        end

        if (ack_error === 1'b0)
            $display("PASS: No ACK error reported");
        else begin
            $display("FAIL: ACK error reported");
            errors = errors + 1;
        end

        if (rx_data === 8'hA5)
            $display("PASS: Slave received 0xA5");
        else begin
            $display("FAIL: Slave data = %h, expected A5",
                     rx_data);
            errors = errors + 1;
        end

        $display("------------------------------------");

        if (errors == 0)
            $display("TESTBENCH PASSED");
        else
            $display("TESTBENCH FAILED: %0d error(s)", errors);

        $display("------------------------------------");
        $finish;
    end

endmodule
