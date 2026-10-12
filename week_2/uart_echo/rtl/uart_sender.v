
`timescale 1ns / 1ps

module uart_sender (
    input        clk,
    input        wr_en,
    input        enb,
    input        rst,
    input  [7:0] data_in,
    output reg   tx,
    output       tx_busy
);

    localparam STATE_IDLE  = 2'b00;
    localparam STATE_START = 2'b01;
    localparam STATE_DATA  = 2'b10;
    localparam STATE_STOP  = 2'b11;

    reg [7:0] data;
    reg [2:0] bitpos;
    reg [1:0] state;

    always @(posedge clk) begin
        if (rst) begin
            tx     <= 1'b1;
            data   <= 8'h00;
            bitpos <= 3'd0;
            state  <= STATE_IDLE;
        end else begin
            case (state)

                STATE_IDLE: begin
                    tx <= 1'b1;

                    if (wr_en) begin
                        data   <= data_in;
                        bitpos <= 3'd0;
                        state  <= STATE_START;
                    end
                end

                STATE_START: begin
                    if (enb) begin
                        tx    <= 1'b0;
                        state <= STATE_DATA;
                    end
                end

                STATE_DATA: begin
                    if (enb) begin
                        tx <= data[bitpos];

                        if (bitpos == 3'd7)
                            state <= STATE_STOP;
                        else
                            bitpos <= bitpos + 3'd1;
                    end
                end

                STATE_STOP: begin
                    if (enb) begin
                        tx    <= 1'b1;
                        state <= STATE_IDLE;
                    end
                end

                default: begin
                    tx    <= 1'b1;
                    state <= STATE_IDLE;
                end

            endcase
        end
    end

    assign tx_busy = (state != STATE_IDLE);

endmodule
