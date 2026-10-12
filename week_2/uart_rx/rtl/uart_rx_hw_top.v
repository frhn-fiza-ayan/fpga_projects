
`timescale 1ns / 1ps

module uart_rx_hw_top (
    input  wire       clk,
    input  wire       uart_rx,
    output reg  [3:0] led_data = 4'b0000
);

    // ---------------------------------------------------------
    // 1. Startup reset
    // ---------------------------------------------------------

    reg [20:0] reset_counter = 21'd0;
    reg        rst = 1'b1;

    always @(posedge clk) begin
        if (reset_counter < 21'd1000000) begin
            reset_counter <= reset_counter + 1'b1;
            rst <= 1'b1;
        end
        else begin
            rst <= 1'b0;
        end
    end

    // ---------------------------------------------------------
    // 2. Baud-rate generator
    // ---------------------------------------------------------

    wire enb_tx;
    wire enb_rx;

    baud_rate_generator #(
        .CLK_FREQ  (125000000),
        .BAUD_RATE (9600)
    ) baud_gen (
        .clock  (clk),
        .reset  (rst),
        .enb_tx (enb_tx),
        .enb_rx (enb_rx)
    );

    // ---------------------------------------------------------
    // 3. UART receiver
    // ---------------------------------------------------------

    wire [7:0] received_data;
    wire       received_ready;

    reg received_ready_d = 1'b0;

    uart_receiver uart_rx_inst (
        .clk     (clk),
        .rx      (uart_rx),
        .enb     (enb_rx),
        .rst     (rst),
        .rdy_clr (received_ready),
        .data_out(received_data),
        .rdy     (received_ready)
    );

    // ---------------------------------------------------------
    // 4. Display received byte on four LEDs
    // ---------------------------------------------------------

    always @(posedge clk) begin
        if (rst) begin
            led_data <= 4'b0000;
            received_ready_d <= 1'b0;
        end
        else begin
            received_ready_d <= received_ready;

            // Latch the lower nibble when a new byte arrives
            if (received_ready && !received_ready_d)
                led_data <= received_data[3:0];
        end
    end

endmodule