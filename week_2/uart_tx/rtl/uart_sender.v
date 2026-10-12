
`timescale 1ns / 1ps

module uart_sender (
    input  wire       clk,
    input  wire       wr_en,
    input  wire       enb,
    input  wire       rst,
    input  wire [7:0] data_in,

    output reg        tx,
    output wire       tx_busy
);

    // UART transmitter states
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state;
    reg [7:0] data;
    reg [2:0] bitpos;

    always @(posedge clk) begin
        if (rst) begin
            state  <= IDLE;
            data   <= 8'h00;
            bitpos <= 3'd0;
            tx     <= 1'b1;  // UART idle is HIGH
        end
        else begin
            case (state)

                // Wait for a transmission request
                IDLE: begin
                    tx <= 1'b1;

                    if (wr_en) begin
                        data   <= data_in;
                        bitpos <= 3'd0;
                        state  <= START;
                    end
                end

                // Hold the start bit LOW for one bit period
                START: begin
                    if (enb) begin
                        tx    <= 1'b0;
                        state <= DATA;
                    end
                end

                // Transmit 8 data bits, least-significant bit first
                DATA: begin
                    if (enb) begin
                        tx <= data[bitpos];

                        if (bitpos == 3'd7) begin
                            state <= STOP;
                        end
                        else begin
                            bitpos <= bitpos + 1'b1;
                        end
                    end
                end

                // Hold the stop bit HIGH for one bit period
                STOP: begin
                    if (enb) begin
                        tx    <= 1'b1;
                        state <= IDLE;
                    end
                end

                default: begin
                    state <= IDLE;
                    tx    <= 1'b1;
                end

            endcase
        end
    end

    assign tx_busy = (state != IDLE);

endmodule
