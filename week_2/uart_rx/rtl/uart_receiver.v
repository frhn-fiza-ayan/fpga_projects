
`timescale 1ns / 1ps

module uart_receiver (
    input  wire       clk,
    input  wire       rx,
    input  wire       enb,
    input  wire       rst,
    input  wire       rdy_clr,

    output reg  [7:0] data_out,
    output reg        rdy
);

    // Receiver states
    localparam RX_IDLE  = 2'b00;
    localparam RX_START = 2'b01;
    localparam RX_DATA  = 2'b10;
    localparam RX_STOP  = 2'b11;

    reg [1:0] state;
    reg [3:0] sample_count;
    reg [2:0] bitpos;
    reg [7:0] data_temp;

    // Synchronize the asynchronous RX input to the system clock
    reg rx_sync1;
    reg rx_sync2;

    always @(posedge clk) begin
        if (rst) begin
            rx_sync1 <= 1'b1;
            rx_sync2 <= 1'b1;
        end
        else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            state        <= RX_IDLE;
            sample_count <= 4'd0;
            bitpos       <= 3'd0;
            data_temp    <= 8'd0;
            data_out     <= 8'd0;
            rdy          <= 1'b0;
        end
        else begin

            // Clear the received-data-ready flag when requested
            if (rdy_clr)
                rdy <= 1'b0;

            if (enb) begin
                case (state)

                    RX_IDLE: begin
                        sample_count <= 4'd0;

                        if (!rx_sync2) begin
                            state        <= RX_START;
                            sample_count <= 4'd0;
                        end
                    end

                    // Check the start bit near its midpoint
                    RX_START: begin
                        if (sample_count == 4'd7) begin
                            if (!rx_sync2) begin
                                state        <= RX_DATA;
                                sample_count <= 4'd0;
                                bitpos       <= 3'd0;
                            end
                            else begin
                                // False start: return to idle
                                state        <= RX_IDLE;
                                sample_count <= 4'd0;
                            end
                        end
                        else begin
                            sample_count <= sample_count + 1'b1;
                        end
                    end

                    // Sample each data bit at its midpoint
                    RX_DATA: begin
                        if (sample_count == 4'd15) begin
                            sample_count <= 4'd0;
                            data_temp[bitpos] <= rx_sync2;

                            if (bitpos == 3'd7)
                                state <= RX_STOP;
                            else
                                bitpos <= bitpos + 1'b1;
                        end
                        else begin
                            sample_count <= sample_count + 1'b1;
                        end
                    end

                    // Check the stop bit and publish the received byte
                    RX_STOP: begin
                        if (sample_count == 4'd15) begin
                            sample_count <= 4'd0;
                            state        <= RX_IDLE;

                            if (rx_sync2) begin
                                data_out <= data_temp;
                                rdy      <= 1'b1;
                            end
                        end
                        else begin
                            sample_count <= sample_count + 1'b1;
                        end
                    end

                    default: begin
                        state        <= RX_IDLE;
                        sample_count <= 4'd0;
                    end

                endcase
            end
        end
    end

endmodule
