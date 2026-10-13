
`timescale 1ns / 1ps

module i2c_slave_hw_top #(
    parameter [6:0] SLAVE_ADDR = 7'h42
)(
    input  wire       clk,
    input  wire       rst,

    input  wire       i2c_scl,
    inout  wire       i2c_sda,

    output wire [3:0] led
);

    wire [7:0] rx_data;
    wire       data_valid;

    i2c_slave #(
        .SLAVE_ADDR(SLAVE_ADDR)
    ) slave_inst (
        .clk        (clk),
        .rst        (rst),
        .scl        (i2c_scl),
        .sda        (i2c_sda),
        .rx_data    (rx_data),
        .data_valid (data_valid)
    );

    // Display the upper nibble of the received byte.
    assign led = rx_data[7:4];

endmodule
