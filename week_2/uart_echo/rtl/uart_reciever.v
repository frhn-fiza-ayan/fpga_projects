
`timescale 1ns / 1ps

module uart_reciever (
    input             clk,
    input             rst,
    input             rx,
    input             rdy_clr,
    input             clken,
    output reg        rdy,
    output reg [7:0]  data_out
);

    localparam RX_IDLE  = 2'b00;
    localparam RX_START = 2'b01;
    localparam RX_DATA  = 2'b10;
    localparam RX_STOP  = 2'b11;

    reg [1:0] state;
    reg [3:0] sample;
    reg [2:0] index;
    reg [7:0] temp;

    always @(posedge clk) begin
        if (rst) begin
            state    <= RX_IDLE;
            sample   <= 4'd0;
            index    <= 3'd0;
            temp     <= 8'h00;
            data_out <= 8'h00;
            rdy      <= 1'b0;
        end else begin

            if (rdy_clr)
                rdy <= 1'b0;

            if (clken) begin
                case (state)

                    RX_IDLE: begin
                        sample <= 4'd0;
                        index  <= 3'd0;

                        if (!rx) begin
                            state  <= RX_START;
                            sample <= 4'd0;
                        end
                    end

                    RX_START: begin
                        if (sample == 4'd7) begin
                            if (!rx) begin
                                state  <= RX_DATA;
                                sample <= 4'd0;
                                index  <= 3'd0;
                                temp   <= 8'h00;
                            end else begin
                                state  <= RX_IDLE;
                                sample <= 4'd0;
                            end
                        end else begin
                            sample <= sample + 1'b1;
                        end
                    end

                    RX_DATA: begin
                        if (sample == 4'd15) begin
                            temp[index] <= rx;
                            sample      <= 4'd0;

                            if (index == 3'd7)
                                state <= RX_STOP;
                            else
                                index <= index + 1'b1;
                        end else begin
                            sample <= sample + 1'b1;
                        end
                    end

                    RX_STOP: begin
                        if (sample == 4'd15) begin
                            data_out <= temp;
                            rdy      <= 1'b1;
                            sample   <= 4'd0;
                            state    <= RX_IDLE;
                        end else begin
                            sample <= sample + 1'b1;
                        end
                    end

                    default: begin
                        state  <= RX_IDLE;
                        sample <= 4'd0;
                        index  <= 3'd0;
                    end

                endcase
            end
        end
    end

endmodule
