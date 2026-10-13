
`timescale 1ns / 1ps

module uart_echo_board_b #(
    parameter integer CLK_FREQ = 125_000_000,
    parameter integer BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire rst,
    input  wire uart_rx,
    output wire uart_tx
);

    localparam [2:0] RX_WAIT       = 3'd0,
                     TX_WAIT_IDLE = 3'd1,
                     TX_LAUNCH    = 3'd2,
                     TX_WAIT_START= 3'd3,
                     TX_WAIT_DONE = 3'd4;

    reg [2:0] state;

    reg [7:0] echo_data;
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

    // UART transmitter
    uart_sender tx_unit (
        .clk(clk),
        .wr_en(tx_wr_en),
        .enb(tx_enb),
        .rst(rst),
        .data_in(echo_data),
        .tx(uart_tx),
        .tx_busy(tx_busy)
    );

    // Receive a byte and transmit it back
    always @(posedge clk) begin
        if (rst) begin
            state      <= RX_WAIT;
            echo_data  <= 8'h00;
            tx_wr_en   <= 1'b0;
            rx_rdy_clr <= 1'b0;
        end else begin
            tx_wr_en   <= 1'b0;
            rx_rdy_clr <= 1'b0;

            case (state)
                RX_WAIT: begin
                    if (rx_rdy) begin
                        echo_data  <= rx_data;
                        rx_rdy_clr <= 1'b1;
                        state      <= TX_WAIT_IDLE;
                    end
                end

                TX_WAIT_IDLE: begin
                    if (!tx_busy)
                        state <= TX_LAUNCH;
                end

                TX_LAUNCH: begin
                    tx_wr_en <= 1'b1;
                    state    <= TX_WAIT_START;
                end

                TX_WAIT_START: begin
                    if (tx_busy)
                        state <= TX_WAIT_DONE;
                end

                TX_WAIT_DONE: begin
                    if (!tx_busy)
                        state <= RX_WAIT;
                end

                default: state <= RX_WAIT;
            endcase
        end
    end

endmodule
