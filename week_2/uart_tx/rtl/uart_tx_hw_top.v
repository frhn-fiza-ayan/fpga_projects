
`timescale 1ns / 1ps

module uart_tx_hw_top (
    input  wire clk,
    output wire uart_tx
);

    // ---------------------------------------------------------
    // 1. Generate a startup reset
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
        .clock (clk),
        .reset (rst),
        .enb_tx (enb_tx),
        .enb_rx (enb_rx)
    );

    // ---------------------------------------------------------
    // 3. Generate a transmit request periodically
    // ---------------------------------------------------------
    // 125,000,000 clock cycles = 1 second at 125 MHz
    reg [26:0] send_counter = 27'd0;
    reg        wr_en = 1'b0;

    always @(posedge clk) begin
        if (rst) begin
            send_counter <= 27'd0;
            wr_en <= 1'b0;
        end
        else if (send_counter >= 27'd124999999) begin
            send_counter <= 27'd0;
            wr_en <= 1'b1;
        end
        else begin
            send_counter <= send_counter + 1'b1;
            wr_en <= 1'b0;
        end
    end

    // ---------------------------------------------------------
    // 4. UART transmitter
    // ---------------------------------------------------------
    wire tx_busy;

    uart_sender uart_tx_inst (
        .clk     (clk),
        .wr_en   (wr_en),
        .enb     (enb_tx),
        .rst     (rst),
        .data_in (8'hA5),
        .tx      (uart_tx),
        .tx_busy (tx_busy)
    );

endmodule
