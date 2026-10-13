
`timescale 1ns / 1ps

module spi_slave_top #(
    parameter integer CLK_FREQ_HZ = 125_000_000
)(
    input  wire       clk,

    // SPI inputs from Master
    input  wire       spi_cs,
    input  wire       spi_sclk,
    input  wire       spi_mosi,

    // Four onboard LEDs
    output wire [3:0] led
);

    // ==========================================
    // 1. Synchronize SPI signals
    // ==========================================

    reg cs_meta   = 1'b1;
    reg cs_sync   = 1'b1;
    reg cs_prev   = 1'b1;

    reg sclk_meta = 1'b0;
    reg sclk_sync = 1'b0;
    reg sclk_prev = 1'b0;

    reg mosi_meta = 1'b0;
    reg mosi_sync = 1'b0;

    always @(posedge clk) begin
        cs_meta   <= spi_cs;
        cs_sync   <= cs_meta;
        cs_prev   <= cs_sync;

        sclk_meta <= spi_sclk;
        sclk_sync <= sclk_meta;
        sclk_prev <= sclk_sync;

        mosi_meta <= spi_mosi;
        mosi_sync <= mosi_meta;
    end

    // ==========================================
    // 2. Receive one byte, MSB first
    // SPI Mode 0: sample on rising SCLK edge
    // ==========================================

    reg [7:0] rx_shift = 8'h00;
    reg [7:0] received_byte = 8'hA5;

    reg [3:0] bit_count = 0;

    always @(posedge clk) begin

        // CS falling edge: start of a new byte
        if (cs_prev && !cs_sync) begin
            rx_shift <= 8'h00;
            bit_count <= 0;
        end

        // Sample MOSI on rising SCLK edges
        else if (!cs_sync && sclk_sync && !sclk_prev) begin

            rx_shift <= {rx_shift[6:0], mosi_sync};

            if (bit_count == 7) begin
                received_byte <= {rx_shift[6:0], mosi_sync};
                bit_count <= 0;
            end
            else begin
                bit_count <= bit_count + 1'b1;
            end
        end
    end

    // ==========================================
    // 3. Display received byte's lower nibble
    // ==========================================

    assign led = received_byte[3:0];

endmodule