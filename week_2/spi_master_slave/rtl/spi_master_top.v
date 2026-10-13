
`timescale 1ns / 1ps

module spi_master_top #(
    parameter integer HALF_PERIOD = 63,
    parameter integer START_DELAY_CYCLES = 125_000_000,
    parameter integer DEBOUNCE_CYCLES = 1_250_000
)(
    input  wire       clk,
    input  wire       btn,

    output reg        spi_cs   = 1'b1,
    output reg        spi_sclk = 1'b0,
    output reg        spi_mosi = 1'b0,

    output wire [3:0] led
);

    localparam IDLE     = 2'd0;
    localparam TRANSFER = 2'd1;
    localparam FINISH   = 2'd2;

    reg [1:0] state = IDLE;

    // Selected byte: A5 or 3C
    reg select_byte = 1'b0;

    reg [7:0] tx_shift = 8'hA5;
    reg [3:0] bit_count = 0;

    reg [31:0] half_count = 0;
    reg [31:0] start_count = 0;

    reg started = 1'b0;
    reg transfer_pending = 1'b1;

    // Button synchronization and debouncing
    reg btn_meta   = 1'b0;
    reg btn_sync   = 1'b0;
    reg btn_stable = 1'b0;

    reg [31:0] debounce_count = 0;

    // Detect a new button press
    reg button_press = 1'b0;

    always @(posedge clk) begin
        btn_meta <= btn;
        btn_sync <= btn_meta;
        button_press <= 1'b0;

        if (btn_sync == btn_stable) begin
            debounce_count <= 0;
        end
        else if (debounce_count >= DEBOUNCE_CYCLES - 1) begin
            debounce_count <= 0;
            btn_stable <= btn_sync;

            if (btn_sync)
                button_press <= 1'b1;
        end
        else begin
            debounce_count <= debounce_count + 1'b1;
        end
    end

    // Select a byte and request a new transmission.
    // Do not change the byte in the middle of a transfer.
    always @(posedge clk) begin
        if (button_press) begin
            select_byte <= ~select_byte;
            transfer_pending <= 1'b1;
        end
    end

    // SPI Mode 0: CPOL=0, CPHA=0
    // MSB first, one byte per transaction.
    always @(posedge clk) begin

        if (!started) begin
            if (start_count >= START_DELAY_CYCLES - 1) begin
                started <= 1'b1;
                start_count <= 0;
            end
            else begin
                start_count <= start_count + 1'b1;
            end
        end
        else begin

            case (state)

                IDLE: begin
                    spi_cs   <= 1'b1;
                    spi_sclk <= 1'b0;
                    spi_mosi <= 1'b0;
                    half_count <= 0;

                    if (transfer_pending) begin
                        // Load the currently selected byte.
                        tx_shift <= select_byte ? 8'h3C : 8'hA5;
                        bit_count <= 0;

                        // Present MSB before first rising edge.
                        spi_mosi <= select_byte ? 1'b0 : 1'b1;
                        spi_cs <= 1'b0;

                        transfer_pending <= 1'b0;
                        state <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    if (half_count >= HALF_PERIOD - 1) begin
                        half_count <= 0;

                        if (spi_sclk == 1'b0) begin
                            // Rising edge: Slave samples MOSI.
                            spi_sclk <= 1'b1;

                            if (bit_count == 7) begin
                                state <= FINISH;
                            end
                            else begin
                                bit_count <= bit_count + 1'b1;
                            end
                        end
                        else begin
                            // Falling edge: prepare next data bit.
                            spi_sclk <= 1'b0;
                            tx_shift <= {tx_shift[6:0], 1'b0};
                            spi_mosi <= tx_shift[6];
                        end
                    end
                    else begin
                        half_count <= half_count + 1'b1;
                    end
                end

                FINISH: begin
                    if (half_count >= HALF_PERIOD - 1) begin
                        half_count <= 0;
                        spi_sclk <= 1'b0;
                        spi_cs <= 1'b1;
                        spi_mosi <= 1'b0;
                        state <= IDLE;
                    end
                    else begin
                        half_count <= half_count + 1'b1;
                    end
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end
    end

    // Display the selected byte's lower nibble.
    // A5 -> 5; 3C -> C.
    assign led = select_byte ? 4'hC : 4'h5;

endmodule