
`timescale 1ns / 1ps

module baud_rate_genrator #(
    parameter integer CLK_FREQ  = 125_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire clock,
    input  wire reset,
    output reg  enb_tx,
    output reg  enb_rx
);

    localparam integer DIVISOR_TX =
        CLK_FREQ / BAUD_RATE;

    localparam integer DIVISOR_RX =
        CLK_FREQ / (16 * BAUD_RATE);

    reg [31:0] counter_tx;
    reg [31:0] counter_rx;

    // TX baud enable: approximately 9600 pulses per second
    always @(posedge clock) begin
        if (reset) begin
            counter_tx <= 0;
            enb_tx     <= 1'b0;
        end else begin
            if (counter_tx == DIVISOR_TX - 1) begin
                counter_tx <= 0;
                enb_tx     <= 1'b1;
            end else begin
                counter_tx <= counter_tx + 1'b1;
                enb_tx     <= 1'b0;
            end
        end
    end

    // RX sampling enable: approximately 16x baud rate
    always @(posedge clock) begin
        if (reset) begin
            counter_rx <= 0;
            enb_rx     <= 1'b0;
        end else begin
            if (counter_rx == DIVISOR_RX - 1) begin
                counter_rx <= 0;
                enb_rx     <= 1'b1;
            end else begin
                counter_rx <= counter_rx + 1'b1;
                enb_rx     <= 1'b0;
            end
        end
    end

endmodule
