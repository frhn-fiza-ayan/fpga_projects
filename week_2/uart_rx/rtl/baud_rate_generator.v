
`timescale 1ns / 1ps

module baud_rate_generator #(
    parameter integer CLK_FREQ  = 125000000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire rst,
    output reg  enb_rx = 1'b0
);

    // 16x UART oversampling
    localparam integer OVERSAMPLE = 16;

    localparam integer DIVISOR =
        (CLK_FREQ + ((BAUD_RATE * OVERSAMPLE) / 2))
        / (BAUD_RATE * OVERSAMPLE);

    reg [31:0] baud_counter = 32'd0;

    always @(posedge clk) begin
        if (rst) begin
            baud_counter <= 32'd0;
            enb_rx       <= 1'b0;
        end else begin
            if (baud_counter >= DIVISOR - 1) begin
                baud_counter <= 32'd0;
                enb_rx       <= 1'b1;
            end else begin
                baud_counter <= baud_counter + 1'b1;
                enb_rx       <= 1'b0;
            end
        end
    end

endmodule
