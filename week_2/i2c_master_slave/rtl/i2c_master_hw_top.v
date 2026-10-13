
`timescale 1ns / 1ps

module i2c_master_hw_top #(
    parameter integer CLK_FREQ_HZ = 125_000_000,
    parameter integer I2C_FREQ_HZ = 100_000,
    parameter integer DEBOUNCE_CYCLES = 1_250_000
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       btn,

    output wire [3:0] led,
    output wire       i2c_scl,
    inout  wire       i2c_sda
);

    wire [7:0] tx_data;
    wire       busy;
    wire       done;
    wire       ack_error;

    i2c_master #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .I2C_FREQ_HZ(I2C_FREQ_HZ),
        .DEBOUNCE_CYCLES(DEBOUNCE_CYCLES),
        .SLAVE_ADDR(7'h42)
    ) master_inst (
        .clk       (clk),
        .rst       (rst),
        .btn       (btn),
        .tx_data   (tx_data),
        .busy      (busy),
        .done      (done),
        .ack_error (ack_error),
        .scl       (i2c_scl),
        .sda       (i2c_sda)
    );

    // Display the upper nibble of the selected byte.
    assign led = tx_data[7:4];

endmodule
