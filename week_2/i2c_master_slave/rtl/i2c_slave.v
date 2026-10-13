
`timescale 1ns / 1ps

module i2c_slave #(
    parameter [6:0] SLAVE_ADDR = 7'h42
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       scl,
    inout  wire       sda,

    output reg  [7:0] rx_data,
    output reg        data_valid
);

    localparam [3:0]
        IDLE             = 4'd0,
        ADDRESS           = 4'd1,
        ADDRESS_ACK_WAIT  = 4'd2,
        ADDRESS_ACK_HIGH  = 4'd3,
        ADDRESS_ACK_END   = 4'd4,
        RECEIVE_DATA      = 4'd5,
        DATA_ACK_WAIT     = 4'd6,
        DATA_ACK_HIGH     = 4'd7,
        DATA_ACK_END      = 4'd8;

    reg [3:0] state;

    // Synchronize SCL and SDA to the slave clock.
    reg scl_meta, scl_sync, scl_prev;
    reg sda_meta, sda_sync, sda_prev;

    wire scl_rise = scl_sync && !scl_prev;
    wire scl_fall = !scl_sync && scl_prev;

    wire start_condition =
        sda_prev && !sda_sync && scl_sync;

    wire stop_condition =
        !sda_prev && sda_sync && scl_sync;

    reg [7:0] shift_reg;
    reg [7:0] received_byte;
    reg [3:0] bit_count;

    reg address_match;
    reg sda_drive_low;

    // Complete address byte: seven address bits followed by R/W.
    wire [7:0] address_byte_next =
        {shift_reg[6:0], sda_sync};

    // Open-drain SDA output.
    assign sda = sda_drive_low ? 1'b0 : 1'bz;

    // Input synchronizers and edge detectors.
    always @(posedge clk) begin
        if (rst) begin
            scl_meta <= 1'b1;
            scl_sync <= 1'b1;
            scl_prev <= 1'b1;

            sda_meta <= 1'b1;
            sda_sync <= 1'b1;
            sda_prev <= 1'b1;
        end else begin
            scl_meta <= scl;
            scl_sync <= scl_meta;
            scl_prev <= scl_sync;

            sda_meta <= sda;
            sda_sync <= sda_meta;
            sda_prev <= sda_sync;
        end
    end

    // Slave receiver and ACK controller.
    always @(posedge clk) begin
        if (rst) begin
            state         <= IDLE;
            shift_reg     <= 8'h00;
            received_byte <= 8'h00;
            bit_count     <= 4'd0;
            address_match <= 1'b0;

            rx_data       <= 8'hA5;
            data_valid    <= 1'b0;
            sda_drive_low <= 1'b0;
        end else begin
            data_valid <= 1'b0;

            if (start_condition) begin
                state         <= ADDRESS;
                shift_reg     <= 8'h00;
                bit_count     <= 4'd0;
                address_match <= 1'b0;
                sda_drive_low <= 1'b0;
            end else if (stop_condition) begin
                state         <= IDLE;
                bit_count     <= 4'd0;
                sda_drive_low <= 1'b0;
            end else begin
                case (state)

                    IDLE: begin
                        sda_drive_low <= 1'b0;
                    end

                    // Receive address and R/W bit, MSB first.
                    ADDRESS: begin
                        sda_drive_low <= 1'b0;

                        if (scl_rise) begin
                            shift_reg <= address_byte_next;

                            if (bit_count == 4'd7) begin
                                address_match <=
                                    (address_byte_next[7:1] == SLAVE_ADDR) &&
                                    (address_byte_next[0] == 1'b0);

                                bit_count <= 4'd0;
                                state <= ADDRESS_ACK_WAIT;
                            end else begin
                                bit_count <= bit_count + 1'b1;
                            end
                        end
                    end

                    // Wait for SCL falling edge before driving ACK.
                    ADDRESS_ACK_WAIT: begin
                        if (scl_fall) begin
                            sda_drive_low <= address_match;
                            state <= ADDRESS_ACK_HIGH;
                        end
                    end

                    // Keep ACK stable through the high phase.
                    ADDRESS_ACK_HIGH: begin
                        if (scl_rise)
                            state <= ADDRESS_ACK_END;
                    end

                    // Release SDA after the ACK clock.
                    ADDRESS_ACK_END: begin
                        if (scl_fall) begin
                            sda_drive_low <= 1'b0;

                            if (address_match) begin
                                state <= RECEIVE_DATA;
                                shift_reg <= 8'h00;
                                bit_count <= 4'd0;
                            end else begin
                                state <= IDLE;
                            end
                        end
                    end

                    // Receive the eight data bits.
                    RECEIVE_DATA: begin
                        sda_drive_low <= 1'b0;

                        if (scl_rise) begin
                            shift_reg <= {
                                shift_reg[6:0],
                                sda_sync
                            };

                            if (bit_count == 4'd7) begin
                                received_byte <= {
                                    shift_reg[6:0],
                                    sda_sync
                                };

                                bit_count <= 4'd0;
                                state <= DATA_ACK_WAIT;
                            end else begin
                                bit_count <= bit_count + 1'b1;
                            end
                        end
                    end

                    // Assert ACK on the falling edge after data.
                    DATA_ACK_WAIT: begin
                        if (scl_fall) begin
                            sda_drive_low <= 1'b1;
                            state <= DATA_ACK_HIGH;
                        end
                    end

                    // Hold ACK through the ninth clock's high phase.
                    DATA_ACK_HIGH: begin
                        if (scl_rise) begin
                            rx_data <= received_byte;
                            data_valid <= 1'b1;
                            state <= DATA_ACK_END;
                        end
                    end

                    // Release SDA after the ACK clock finishes.
                    DATA_ACK_END: begin
                        if (scl_fall) begin
                            sda_drive_low <= 1'b0;
                            shift_reg <= 8'h00;
                            bit_count <= 4'd0;
                            state <= RECEIVE_DATA;
                        end
                    end

                    default: begin
                        state <= IDLE;
                        sda_drive_low <= 1'b0;
                    end

                endcase
            end
        end
    end

endmodule
