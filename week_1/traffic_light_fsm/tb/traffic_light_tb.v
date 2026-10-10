`timescale 1ns / 1ps

module traffic_light_fsm_pynqz2_tb;

    // =========================================================
    // Accelerated simulation parameters
    // =========================================================
    localparam integer CLK_FREQ_HZ = 10;
    localparam integer GREEN_TIME  = 5;
    localparam integer YELLOW_TIME = 2;

    // =========================================================
    // Testbench signals
    // =========================================================
    reg clk;
    reg reset;

    wire led4_r;
    wire led4_g;
    wire led4_b;

    wire led5_r;
    wire led5_g;
    wire led5_b;

    // =========================================================
    // DUT
    // =========================================================
    traffic_light_fsm_pynqz2 #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .GREEN_TIME(GREEN_TIME),
        .YELLOW_TIME(YELLOW_TIME)
    ) dut (
        .clk(clk),
        .reset(reset),

        .led4_r(led4_r),
        .led4_g(led4_g),
        .led4_b(led4_b),

        .led5_r(led5_r),
        .led5_g(led5_g),
        .led5_b(led5_b)
    );

    // =========================================================
    // Clock
    // 10 Hz clock
    // Period = 100 ns
    // =========================================================
    initial begin
        clk = 1'b0;

        forever #50 clk = ~clk;
    end

    // =========================================================
    // Monitor
    //
    // Active-low LEDs:
    // 0 = ON
    // 1 = OFF
    // =========================================================
    initial begin
    $monitor("Time=%0t | State=%b | Counter=%0d | LD4(R,G,B)=%b%b%b | LD5(R,G,B)=%b%b%b",
             $time,
             dut.state,
             dut.state_counter,
             led4_r, led4_g, led4_b,
             led5_r, led5_g, led5_b);
end
    // =========================================================
    // Main test
    // =========================================================
    initial begin

        // -----------------------------------------------------
        // Reset
        // -----------------------------------------------------
        reset = 1'b1;

        #200;

        reset = 1'b0;

        // -----------------------------------------------------
        // Run long enough to observe a complete cycle
        //
        // Green = 5 sec
        // Yellow = 2 sec
        //
        // Complete cycle:
        // 5 + 2 + 5 + 2 = 14 sec
        //
        // With 10 Hz clock:
        // 14 sec = 140 clock cycles
        // -----------------------------------------------------
        #15000;

        $display("==============================================");
        $display("Simulation completed successfully.");
        $display("==============================================");

        $finish;
    end

    // =========================================================
    // Automatic output checks
    // =========================================================
    always @(posedge clk) begin

        if (!reset) begin

            case (dut.state)

                // -------------------------------------------------
                // NS_GREEN
                // LD4 = GREEN
                // LD5 = RED
                // -------------------------------------------------
                2'b00: begin

                    if (led4_r !== 1'b1 ||
                        led4_g !== 1'b0 ||
                        led4_b !== 1'b1 ||
                        led5_r !== 1'b0 ||
                        led5_g !== 1'b1 ||
                        led5_b !== 1'b1) begin

                        $display(
                            "ERROR: NS_GREEN output incorrect at time %0t",
                            $time
                        );

                    end
                end

                // -------------------------------------------------
                // NS_YELLOW
                // LD4 = YELLOW
                // LD5 = RED
                // -------------------------------------------------
                2'b01: begin

                    if (led4_r !== 1'b0 ||
                        led4_g !== 1'b0 ||
                        led4_b !== 1'b1 ||
                        led5_r !== 1'b0 ||
                        led5_g !== 1'b1 ||
                        led5_b !== 1'b1) begin

                        $display(
                            "ERROR: NS_YELLOW output incorrect at time %0t",
                            $time
                        );

                    end
                end

                // -------------------------------------------------
                // EW_GREEN
                // LD4 = RED
                // LD5 = GREEN
                // -------------------------------------------------
                2'b10: begin

                    if (led4_r !== 1'b0 ||
                        led4_g !== 1'b1 ||
                        led4_b !== 1'b1 ||
                        led5_r !== 1'b1 ||
                        led5_g !== 1'b0 ||
                        led5_b !== 1'b1) begin

                        $display(
                            "ERROR: EW_GREEN output incorrect at time %0t",
                            $time
                        );

                    end
                end

                // -------------------------------------------------
                // EW_YELLOW
                // LD4 = RED
                // LD5 = YELLOW
                // -------------------------------------------------
                2'b11: begin

                    if (led4_r !== 1'b0 ||
                        led4_g !== 1'b1 ||
                        led4_b !== 1'b1 ||
                        led5_r !== 1'b0 ||
                        led5_g !== 1'b0 ||
                        led5_b !== 1'b1) begin

                        $display(
                            "ERROR: EW_YELLOW output incorrect at time %0t",
                            $time
                        );

                    end
                end

                default: begin

                    $display(
                        "ERROR: Invalid state at time %0t",
                        $time
                    );

                end

            endcase
        end
    end

endmodule