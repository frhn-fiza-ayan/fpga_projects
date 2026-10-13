
`timescale 1ns / 1ps

module i2c_master #(
    parameter integer CLK_FREQ_HZ = 125_000_000,
    parameter integer I2C_FREQ_HZ = 100_000,
    parameter integer DEBOUNCE_CYCLES = 1_250_000,
    parameter [6:0] SLAVE_ADDR = 7'h42
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       btn,

    output reg  [7:0] tx_data,
    output reg        busy,
    output reg        done,
    output reg        ack_error,
    output reg        scl,
    inout  wire       sda
);

    localparam integer HALF_PERIOD =
        CLK_FREQ_HZ / (2 * I2C_FREQ_HZ);

    localparam [3:0]
        IDLE         = 4'd0,
        START        = 4'd1,
        BIT_SETUP    = 4'd2,
        BIT_RISE     = 4'd3,
        BIT_FALL     = 4'd4,
        ACK_SETUP    = 4'd5,
        ACK_RISE     = 4'd6,
        ACK_SAMPLE   = 4'd7,
        STOP_SETUP   = 4'd8,
        STOP_RISE    = 4'd9,
        STOP_RELEASE = 4'd10,
        FINISH       = 4'd11;

    reg [3:0] state;
    reg [31:0] divider;

    reg btn_meta, btn_sync;
    reg btn_stable, btn_stable_prev;
    reg [31:0] debounce_count;
    reg button_pending;

    reg sda_drive_low;
    reg [7:0] shift_reg;
    reg [7:0] data_latched;
    reg [3:0] bit_count;
    reg data_phase;

    wire tick = (divider == HALF_PERIOD - 1);
    wire btn_press = btn_stable && !btn_stable_prev;

    assign sda = sda_drive_low ? 1'b0 : 1'bz;

    // Synchronize button input.
    always @(posedge clk) begin
        if (rst) begin
            btn_meta <= 1'b0;
            btn_sync <= 1'b0;
        end else begin
            btn_meta <= btn;
            btn_sync <= btn_meta;
        end
    end

    // Debounce button.
    always @(posedge clk) begin
        if (rst) begin
            btn_stable <= 1'b0;
            debounce_count <= 0;
        end else if (btn_sync == btn_stable) begin
            debounce_count <= 0;
        end else if (debounce_count >= DEBOUNCE_CYCLES - 1) begin
            btn_stable <= btn_sync;
            debounce_count <= 0;
        end else begin
            debounce_count <= debounce_count + 1'b1;
        end
    end

    // Detect one event per debounced press.
    always @(posedge clk) begin
        if (rst)
            btn_stable_prev <= 1'b0;
        else
            btn_stable_prev <= btn_stable;
    end

    // Remember button events until the master can accept them.
    always @(posedge clk) begin
        if (rst) begin
            button_pending <= 1'b0;
        end else begin
            if (btn_press)
                button_pending <= 1'b1;

            if (tick && state == IDLE &&
                (button_pending || btn_press))
                button_pending <= 1'b0;
        end
    end

    // IMPORTANT: Keep the divider running during IDLE.
    always @(posedge clk) begin
        if (rst)
            divider <= 0;
        else if (tick)
            divider <= 0;
        else
            divider <= divider + 1'b1;
    end

    // I2C master controller.
    always @(posedge clk) begin
        if (rst) begin
            state         <= IDLE;
            tx_data       <= 8'hA5;
            data_latched  <= 8'hA5;
            shift_reg     <= 8'h00;
            bit_count     <= 0;
            data_phase    <= 1'b0;

            scl           <= 1'b1;
            sda_drive_low <= 1'b0;

            busy          <= 1'b0;
            done          <= 1'b0;
            ack_error     <= 1'b0;
        end else begin
            done <= 1'b0;

            if (tick) begin
                case (state)

                    IDLE: begin
                        scl           <= 1'b1;
                        sda_drive_low <= 1'b0;
                        busy          <= 1'b0;

                        if (button_pending || btn_press) begin
                            if (tx_data == 8'hA5) begin
                                tx_data      <= 8'h3C;
                                data_latched <= 8'h3C;
                            end else begin
                                tx_data      <= 8'hA5;
                                data_latched <= 8'hA5;
                            end

                            shift_reg  <= {SLAVE_ADDR, 1'b0};
                            bit_count  <= 4'd7;
                            data_phase <= 1'b0;
                            ack_error  <= 1'b0;
                            busy       <= 1'b1;
                            state      <= START;
                        end
                    end

                    // START condition: SDA falls while SCL is high.
                    START: begin
                        scl           <= 1'b1;
                        sda_drive_low <= 1'b1;
                        state         <= BIT_SETUP;
                    end

                    BIT_SETUP: begin
                        scl           <= 1'b0;
                        sda_drive_low <= ~shift_reg[bit_count];
                        state         <= BIT_RISE;
                    end

                    BIT_RISE: begin
                        scl   <= 1'b1;
                        state <= BIT_FALL;
                    end

                    BIT_FALL: begin
                        scl <= 1'b0;

                        if (bit_count == 0) begin
                            state <= ACK_SETUP;
                        end else begin
                            bit_count <= bit_count - 1'b1;
                            state <= BIT_SETUP;
                        end
                    end

                    // Release SDA for slave ACK.
                    ACK_SETUP: begin
                        scl           <= 1'b0;
                        sda_drive_low <= 1'b0;
                        state         <= ACK_RISE;
                    end

                    ACK_RISE: begin
                        scl   <= 1'b1;
                        state <= ACK_SAMPLE;
                    end

                    ACK_SAMPLE: begin
                        scl <= 1'b0;

                        if (sda !== 1'b0)
                            ack_error <= 1'b1;

                        if (!data_phase) begin
                            shift_reg <= data_latched;
                            bit_count <= 4'd7;
                            data_phase <= 1'b1;
                            state <= BIT_SETUP;
                        end else begin
                            state <= STOP_SETUP;
                        end
                    end

                    STOP_SETUP: begin
                        scl           <= 1'b0;
                        sda_drive_low <= 1'b1;
                        state         <= STOP_RISE;
                    end

                    STOP_RISE: begin
                        scl   <= 1'b1;
                        state <= STOP_RELEASE;
                    end

                    STOP_RELEASE: begin
                        scl           <= 1'b1;
                        sda_drive_low <= 1'b0;
                        state         <= FINISH;
                    end

                    FINISH: begin
                        scl   <= 1'b1;
                        busy  <= 1'b0;
                        done  <= 1'b1;
                        state <= IDLE;
                    end

                    default: begin
                        state         <= IDLE;
                        scl           <= 1'b1;
                        sda_drive_low <= 1'b0;
                        busy          <= 1'b0;
                    end

                endcase
            end
        end
    end

endmodule
