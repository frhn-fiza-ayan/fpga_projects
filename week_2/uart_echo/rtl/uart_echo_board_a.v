
`timescale 1ns / 1ps

module uart_echo_board_a #(
    parameter integer CLK_FREQ  = 125_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire rst,
    input  wire uart_rx,
    output wire uart_tx,
    output reg  led_pass,
    output reg  led_fail
);

    localparam [1:0] SEND_BYTE  = 2'd0;
    localparam [1:0] WAIT_REPLY = 2'd1;
    localparam [1:0] CHECK_BYTE = 2'd2;

    localparam [7:0] TEST_BYTE = 8'hA5;

    reg [1:0] state;
    reg tx_wr_en;
    reg rx_rdy_clr;

    wire tx_enb;
    wire rx_enb;
    wire tx_busy;
    wire rx_rdy;
    wire [7:0] rx_data;

    // Baud-rate generator
    baud_rate_genrator #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen (
        .clock(clk),
        .reset(rst),
        .enb_tx(tx_enb),
        .enb_rx(rx_enb)
    );

    // UART transmitter
    uart_sender tx_unit (
        .clk(clk),
        .wr_en(tx_wr_en),
        .enb(tx_enb),
        .rst(rst),
        .data_in(TEST_BYTE),
        .tx(uart_tx),
        .tx_busy(tx_busy)
    );

    // UART receiver
    uart_reciever rx_unit (
        .clk(clk),
        .rst(rst),
        .rx(uart_rx),
        .rdy_clr(rx_rdy_clr),
        .clken(rx_enb),
        .rdy(rx_rdy),
        .data_out(rx_data)
    );

    // Send once, then check the echoed byte.
    always @(posedge clk) begin
        if (rst) begin
            state      <= SEND_BYTE;
            tx_wr_en   <= 1'b0;
            rx_rdy_clr <= 1'b0;
            led_pass   <= 1'b0;
            led_fail   <= 1'b0;
        end else begin
            tx_wr_en   <= 1'b0;
            rx_rdy_clr <= 1'b0;

            case (state)

                SEND_BYTE: begin
                    tx_wr_en <= 1'b1;
                    state    <= WAIT_REPLY;
                end

                WAIT_REPLY: begin
                    if (rx_rdy)
                        state <= CHECK_BYTE;
                end

                CHECK_BYTE: begin
                    rx_rdy_clr <= 1'b1;

                    if (rx_data == TEST_BYTE)
                        led_pass <= 1'b1;
                    else
                        led_fail <= 1'b1;

                    // One test per reset.
                    state <= CHECK_BYTE;
                end

                default: begin
                    state <= SEND_BYTE;
                end

            endcase
        end
    end

endmodule
