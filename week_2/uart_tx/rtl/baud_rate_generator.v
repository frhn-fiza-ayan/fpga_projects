
`timescale 1ns / 1ps

module baud_rate_generator #(
    parameter integer CLK_FREQ  = 125000000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire clock,
    input  wire reset,

    output reg enb_tx,
    output reg enb_rx
);

    // Number of system-clock cycles per UART bit
    localparam integer TX_DIVISOR = CLK_FREQ / BAUD_RATE;

    // Number of system-clock cycles per 16x RX sample
    localparam integer RX_DIVISOR = CLK_FREQ / (16 * BAUD_RATE);

    reg [31:0] counter_tx = 0;
    reg [31:0] counter_rx = 0;

    // TX baud-rate enable
    always @(posedge clock) begin
        if (reset) begin
            counter_tx <= 0;
            enb_tx     <= 1'b0;
        end
        else if (counter_tx == TX_DIVISOR - 1) begin
            counter_tx <= 0;
            enb_tx     <= 1'b1;
        end
        else begin
            counter_tx <= counter_tx + 1'b1;
            enb_tx     <= 1'b0;
        end
    end

    // RX 16x oversampling enable
    always @(posedge clock) begin
        if (reset) begin
            counter_rx <= 0;
            enb_rx     <= 1'b0;
        end
        else if (counter_rx == RX_DIVISOR - 1) begin
            counter_rx <= 0;
            enb_rx     <= 1'b1;
        end
        else begin
            counter_rx <= counter_rx + 1'b1;
            enb_rx     <= 1'b0;
        end
    end

endmodule
