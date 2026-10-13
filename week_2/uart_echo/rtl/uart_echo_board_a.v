
`timescale 1ns / 1ps

module uart_echo_board_a #(
    parameter integer CLK_FREQ = 125_000_000,
    parameter integer BAUD_RATE = 9600,
    parameter integer DEBOUNCE_COUNT = 1_250_000
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       uart_rx,
    output wire       uart_tx,

    input  wire       btn_nibble,

    output reg  [3:0] data_led,
    output reg        rgb_green_n,
    output reg        rgb_red_n
);

    localparam [7:0] TEST_BYTE = 8'hA5;

    localparam [1:0] SEND_BYTE  = 2'd0,
                     WAIT_REPLY = 2'd1,
                     CHECK_BYTE = 2'd2,
                     DONE        = 2'd3;

    reg [1:0] state;

    reg tx_wr_en;
    reg rx_rdy_clr;

    wire tx_enb;
    wire rx_enb;
    wire tx_busy;
    wire rx_rdy;
    wire [7:0] rx_data;

    // Button synchronization
    reg btn_meta;
    reg btn_sync;
    reg btn_stable;
    reg [31:0] debounce_count;
    reg btn_pressed;

    reg show_lower;
    reg [7:0] received_byte;
    reg test_pass;

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

    // Synchronize the button input
    always @(posedge clk) begin
        if (rst) begin
            btn_meta <= 1'b0;
            btn_sync <= 1'b0;
        end else begin
            btn_meta <= btn_nibble;
            btn_sync <= btn_meta;
        end
    end

    // Debounce button and toggle nibble selection on each press
    always @(posedge clk) begin
        if (rst) begin
            btn_stable     <= 1'b0;
            debounce_count <= 0;
            btn_pressed    <= 1'b0;
            show_lower     <= 1'b0;
        end else begin
            btn_pressed <= 1'b0;

            if (btn_sync == btn_stable) begin
                debounce_count <= 0;
            end else if (debounce_count >= DEBOUNCE_COUNT - 1) begin
                btn_stable     <= btn_sync;
                debounce_count <= 0;

                if (btn_sync == 1'b1) begin
                    btn_pressed <= 1'b1;
                    show_lower  <= ~show_lower;
                end
            end else begin
                debounce_count <= debounce_count + 1;
            end
        end
    end

    // UART echo controller and result indicators
    always @(posedge clk) begin
        if (rst) begin
            state      <= SEND_BYTE;
            tx_wr_en   <= 1'b0;
            rx_rdy_clr <= 1'b0;
            received_byte <= 8'h00;
            test_pass  <= 1'b0;
        end else begin
            tx_wr_en   <= 1'b0;
            rx_rdy_clr <= 1'b0;

            case (state)
                SEND_BYTE: begin
                    tx_wr_en <= 1'b1;
                    state    <= WAIT_REPLY;
                end

                WAIT_REPLY: begin
                    if (rx_rdy) begin
                        received_byte <= rx_data;
                        rx_rdy_clr    <= 1'b1;
                        state         <= CHECK_BYTE;
                    end
                end

                CHECK_BYTE: begin
                    test_pass <= (received_byte == TEST_BYTE);
                    state     <= DONE;
                end

                DONE: begin
                    // Keep the final result until reset
                    state <= DONE;
                end

                default: state <= SEND_BYTE;
            endcase
        end
    end

    // Four LEDs display upper or lower nibble
    always @(*) begin
        if (show_lower)
            data_led = received_byte[3:0];
        else
            data_led = received_byte[7:4];
    end

    // RGB outputs are active-low:
    // PASS = green on; FAIL = red on.
    always @(*) begin
        rgb_green_n = 1'b1;
        rgb_red_n   = 1'b1;

        if (state == DONE) begin
            if (test_pass)
                rgb_green_n = 1'b0;
            else
                rgb_red_n = 1'b0;
        end
    end

endmodule
