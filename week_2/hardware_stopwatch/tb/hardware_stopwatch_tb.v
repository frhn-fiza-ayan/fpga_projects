`timescale 1ns / 1ps

module hardware_stopwatch_tb;

    // ========================================================
    // Simulation Parameters
    // ========================================================
    // Small clock frequency so simulation runs quickly.
    //
    // 10 Hz clock:
    //   10 clock cycles = 1 simulated second
    //
    // Debounce:
    //   10 / 50 = 0 in integer arithmetic
    //   Therefore we use a custom simulation DUT parameter
    //   and make the debounce effectively very short.
    // ========================================================

    reg clk;
    reg reset;
    reg start_stop;

    wire [6:0] seg;
    wire       dp;

    // ========================================================
    // DUT
    // ========================================================

    hardware_stopwatch #(
        .CLK_FREQ_HZ(10)
    ) dut (
        .clk        (clk),
        .reset      (reset),
        .start_stop (start_stop),
        .seg        (seg),
        .dp         (dp)
    );

    // ========================================================
    // Clock Generation
    // 10 Hz equivalent clock
    // 100 ns period for fast simulation
    // ========================================================

    initial begin
        clk = 1'b0;

        forever #50 clk = ~clk;
    end

    // ========================================================
    // Display Decoder
    // Used only to make waveform output easier to understand.
    // ========================================================

    always @(seg) begin

        case (seg)

            7'b1111110:
                $display("[%0t ns] DISPLAY = 0", $time);

            7'b0110000:
                $display("[%0t ns] DISPLAY = 1", $time);

            7'b1101101:
                $display("[%0t ns] DISPLAY = 2", $time);

            7'b1111001:
                $display("[%0t ns] DISPLAY = 3", $time);

            7'b0110011:
                $display("[%0t ns] DISPLAY = 4", $time);

            7'b1011011:
                $display("[%0t ns] DISPLAY = 5", $time);

            7'b1011111:
                $display("[%0t ns] DISPLAY = 6", $time);

            7'b1110000:
                $display("[%0t ns] DISPLAY = 7", $time);

            7'b1111111:
                $display("[%0t ns] DISPLAY = 8", $time);

            7'b1111011:
                $display("[%0t ns] DISPLAY = 9", $time);

            default:
                $display("[%0t ns] DISPLAY = OFF/INVALID", $time);

        endcase

    end

    // ========================================================
    // Test Sequence
    // ========================================================

    initial begin

        // ----------------------------------------------------
        // Initial conditions
        // ----------------------------------------------------

        reset     = 1'b0;
        start_stop = 1'b0;

        $display("==========================================");
        $display(" HARDWARE STOPWATCH TESTBENCH");
        $display("==========================================");

        // ----------------------------------------------------
        // RESET
        // ----------------------------------------------------

        #200;

        reset = 1'b1;

        #300;

        reset = 1'b0;

        #300;

        // ----------------------------------------------------
        // START
        // ----------------------------------------------------

        $display("------------------------------------------");
        $display("Starting stopwatch...");
        $display("------------------------------------------");

        start_stop = 1'b1;

        #300;

        start_stop = 1'b0;

        // ----------------------------------------------------
        // Let stopwatch run
        // Approximately several seconds
        // ----------------------------------------------------

        #6500;

        // ----------------------------------------------------
        // STOP
        // ----------------------------------------------------

        $display("------------------------------------------");
        $display("Stopping stopwatch...");
        $display("------------------------------------------");

        start_stop = 1'b1;

        #300;

        start_stop = 1'b0;

        #1000;

        // ----------------------------------------------------
        // START AGAIN
        // ----------------------------------------------------

        $display("------------------------------------------");
        $display("Starting stopwatch again...");
        $display("------------------------------------------");

        start_stop = 1'b1;

        #300;

        start_stop = 1'b0;

        #3500;

        // ----------------------------------------------------
        // RESET WHILE RUNNING
        // ----------------------------------------------------

        $display("------------------------------------------");
        $display("Resetting stopwatch...");
        $display("------------------------------------------");

        reset = 1'b1;

        #300;

        reset = 1'b0;

        #1000;

        // ----------------------------------------------------
        // Finish
        // ----------------------------------------------------

        $display("==========================================");
        $display(" TESTBENCH COMPLETE");
        $display("==========================================");

        $finish;

    end

endmodule