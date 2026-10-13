
`timescale 1ns / 1ps

// ============================================================
// PYNQ-Z2 UART COMMAND LINE INTERFACE
// Clock      : 125 MHz
// Baud rate  : 115200
// Format     : 8-N-1
// LEDs       : 4-bit logical pattern
// ============================================================

module uart_cli_top (
    input  wire       clk,
    input  wire       uart_rx,
    output wire       uart_tx,
    output wire [3:0] led
);

    localparam integer CLKS_PER_BIT = 1085;
    localparam integer BUFFER_SIZE  = 32;
    localparam integer ONE_SECOND   = 125_000_000;

    // --------------------------------------------------------
    // UART RECEIVER
    // --------------------------------------------------------

    wire [7:0] rx_data;
    wire       rx_valid;

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) receiver (
        .clk(clk),
        .rx(uart_rx),
        .data_out(rx_data),
        .data_valid(rx_valid)
    );

    // --------------------------------------------------------
    // UART TRANSMITTER
    // --------------------------------------------------------

    reg        tx_start = 1'b0;
    reg  [7:0] tx_data  = 8'h00;
    wire       tx_busy;
    wire       tx_done;

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) transmitter (
        .clk(clk),
        .tx_start(tx_start),
        .data_in(tx_data),
        .tx(uart_tx),
        .busy(tx_busy),
        .done(tx_done)
    );

    // --------------------------------------------------------
    // LED REGISTER AND INTERNAL COUNTER
    // --------------------------------------------------------

    reg [3:0] led_reg = 4'b0000;
    assign led = led_reg;

    reg [31:0] counter = 32'd0;
    reg [26:0] second_divider = 27'd0;

    always @(posedge clk) begin
        if (second_divider == ONE_SECOND - 1) begin
            second_divider <= 0;
            counter <= counter + 1'b1;
        end
        else begin
            second_divider <= second_divider + 1'b1;
        end
    end

    // --------------------------------------------------------
    // COMMAND INPUT BUFFER
    // --------------------------------------------------------

    reg [7:0] cmd_mem [0:BUFFER_SIZE-1];
    reg [5:0] cmd_len = 0;
    reg       cmd_overflow = 0;
    reg       skip_lf = 0;

    integer i;

    // --------------------------------------------------------
    // RESPONSE BUFFER AND TRANSMISSION SEQUENCER
    // --------------------------------------------------------

    reg [639:0] response_message = 640'd0;
    reg [7:0]   response_length = 0;
    reg [7:0]   response_index = 0;
    reg         response_active = 0;

    // ASCII hexadecimal digit
    function automatic [7:0] hex_ascii(input [3:0] value);
        begin
            if (value < 10)
                hex_ascii = "0" + value;
            else
                hex_ascii = "A" + (value - 10);
        end
    endfunction

    // Convert received hexadecimal character into a 4-bit value
    function automatic [3:0] hex_value(input [7:0] ch);
        begin
            if (ch >= "0" && ch <= "9")
                hex_value = ch - "0";
            else if (ch >= "A" && ch <= "F")
                hex_value = ch - "A" + 10;
            else
                hex_value = 4'h0;
        end
    endfunction

    function automatic hex_valid(input [7:0] ch);
        begin
            hex_valid = ((ch >= "0" && ch <= "9") ||
                         (ch >= "A" && ch <= "F"));
        end
    endfunction

    // Convert lowercase ASCII to uppercase
    function automatic [7:0] uppercase(input [7:0] ch);
        begin
            if (ch >= "a" && ch <= "z")
                uppercase = ch - 8'd32;
            else
                uppercase = ch;
        end
    endfunction

    // Start a response. Message strings are packed from the right.
    task automatic start_response(
        input [639:0] message,
        input [7:0] length
    );
        begin
            response_message <= message;
            response_length  <= length;
            response_index   <= 0;
            response_active  <= 1'b1;
        end
    endtask

    // Send current LED pattern
    task automatic send_led_status;
        reg [639:0] temp;
        begin
            temp = "LED = 0000\r\n> ";
            temp[8*(14-1-6) +: 8] = led_reg[3] ? "1" : "0";
            temp[8*(14-1-7) +: 8] = led_reg[2] ? "1" : "0";
            temp[8*(14-1-8) +: 8] = led_reg[1] ? "1" : "0";
            temp[8*(14-1-9) +: 8] = led_reg[0] ? "1" : "0";
            start_response(temp, 14);
        end
    endtask

    // Send counter as eight hexadecimal digits
    task automatic send_count;
        reg [639:0] temp;
        begin
            temp = "COUNT = 00000000\r\n> ";
            temp[8*(20-1-8)  +: 8] = hex_ascii(counter[31:28]);
            temp[8*(20-1-9)  +: 8] = hex_ascii(counter[27:24]);
            temp[8*(20-1-10) +: 8] = hex_ascii(counter[23:20]);
            temp[8*(20-1-11) +: 8] = hex_ascii(counter[19:16]);
            temp[8*(20-1-12) +: 8] = hex_ascii(counter[15:12]);
            temp[8*(20-1-13) +: 8] = hex_ascii(counter[11:8]);
            temp[8*(20-1-14) +: 8] = hex_ascii(counter[7:4]);
            temp[8*(20-1-15) +: 8] = hex_ascii(counter[3:0]);
            start_response(temp, 20);
        end
    endtask

    // --------------------------------------------------------
    // RESPONSE TRANSMITTER CONTROL
    // --------------------------------------------------------

    always @(posedge clk) begin
        tx_start <= 1'b0;

        if (tx_done && response_active) begin
            if (response_index + 1 >= response_length) begin
                response_active <= 1'b0;
                response_index <= 0;
            end
            else begin
                response_index <= response_index + 1'b1;
            end
        end
        else if (response_active && !tx_busy && !tx_start) begin
            tx_data <= response_message[
                8*(response_length - 1 - response_index) +: 8
            ];
            tx_start <= 1'b1;
        end
    end

    // --------------------------------------------------------
    // COMMAND PARSER
    // --------------------------------------------------------

    initial begin
        for (i = 0; i < BUFFER_SIZE; i = i + 1)
            cmd_mem[i] = 8'h00;
    end

    always @(posedge clk) begin
        if (rx_valid) begin

            // CR or LF terminates the command
            if (rx_data == 8'h0D || rx_data == 8'h0A) begin

                // Ignore LF following CR
                if (rx_data == 8'h0A && skip_lf) begin
                    skip_lf <= 1'b0;
                end
                else begin
                    skip_lf <= (rx_data == 8'h0D);

                    // Process only when the previous response is done
                    if (!response_active && !tx_busy) begin

                        if (cmd_overflow) begin
                            start_response(
                                "ERR: COMMAND TOO LONG\r\n> ", 26
                            );
                        end

                        else if (cmd_len == 4 &&
                                 cmd_mem[0] == "H" &&
                                 cmd_mem[1] == "E" &&
                                 cmd_mem[2] == "L" &&
                                 cmd_mem[3] == "P") begin

                            start_response(
                                "HELP\r\nLED 0-F\r\nLED ON\r\nLED OFF\r\nSTATUS\r\nCOUNT\r\nCOUNT RESET\r\n> ",
                                57
                            );
                        end

                        else if (cmd_len == 6 &&
                                 cmd_mem[0] == "L" &&
                                 cmd_mem[1] == "E" &&
                                 cmd_mem[2] == "D" &&
                                 cmd_mem[3] == " " &&
                                 cmd_mem[4] == "O" &&
                                 cmd_mem[5] == "N") begin

                            led_reg <= 4'b1111;
                            start_response("OK: LED ON\r\n> ", 14);
                        end

                        else if (cmd_len == 7 &&
                                 cmd_mem[0] == "L" &&
                                 cmd_mem[1] == "E" &&
                                 cmd_mem[2] == "D" &&
                                 cmd_mem[3] == " " &&
                                 cmd_mem[4] == "O" &&
                                 cmd_mem[5] == "F" &&
                                 cmd_mem[6] == "F") begin

                            led_reg <= 4'b0000;
                            start_response("OK: LED OFF\r\n> ", 15);
                        end

                        else if (cmd_len == 5 &&
                                 cmd_mem[0] == "L" &&
                                 cmd_mem[1] == "E" &&
                                 cmd_mem[2] == "D" &&
                                 cmd_mem[3] == " " &&
                                 hex_valid(cmd_mem[4])) begin

                            led_reg <= hex_value(cmd_mem[4]);

                            start_response(
                                "OK: LED PATTERN UPDATED\r\n> ", 27
                            );
                        end

                        else if (cmd_len == 6 &&
                                 cmd_mem[0] == "S" &&
                                 cmd_mem[1] == "T" &&
                                 cmd_mem[2] == "A" &&
                                 cmd_mem[3] == "T" &&
                                 cmd_mem[4] == "U" &&
                                 cmd_mem[5] == "S") begin

                            send_led_status();
                        end

                        else if (cmd_len == 5 &&
                                 cmd_mem[0] == "C" &&
                                 cmd_mem[1] == "O" &&
                                 cmd_mem[2] == "U" &&
                                 cmd_mem[3] == "N" &&
                                 cmd_mem[4] == "T") begin

                            send_count();
                        end

                        else if (cmd_len == 11 &&
                                 cmd_mem[0]  == "C" &&
                                 cmd_mem[1]  == "O" &&
                                 cmd_mem[2]  == "U" &&
                                 cmd_mem[3]  == "N" &&
                                 cmd_mem[4]  == "T" &&
                                 cmd_mem[5]  == " " &&
                                 cmd_mem[6]  == "R" &&
                                 cmd_mem[7]  == "E" &&
                                 cmd_mem[8]  == "S" &&
                                 cmd_mem[9]  == "E" &&
                                 cmd_mem[10] == "T") begin

                            counter <= 0;
                            second_divider <= 0;
                            start_response("OK: COUNT RESET\r\n> ", 18);
                        end

                        else if (cmd_len != 0) begin
                            start_response(
                                "ERR: UNKNOWN COMMAND\r\n> ", 24
                            );
                        end
                    end

                    cmd_len <= 0;
                    cmd_overflow <= 0;
                end
            end

            // Backspace or Delete
            else if (rx_data == 8'h08 || rx_data == 8'h7F) begin
                skip_lf <= 1'b0;
                if (cmd_len > 0)
                    cmd_len <= cmd_len - 1'b1;
            end

            // Store incoming character
            else begin
                skip_lf <= 1'b0;

                if (cmd_len < BUFFER_SIZE) begin
                    cmd_mem[cmd_len] <= uppercase(rx_data);
                    cmd_len <= cmd_len + 1'b1;
                end
                else begin
                    cmd_overflow <= 1'b1;
                end
            end
        end
    end

endmodule


// ============================================================
// UART RECEIVER
// ============================================================

module uart_rx #(
    parameter integer CLKS_PER_BIT = 1085
)(
    input  wire       clk,
    input  wire       rx,
    output reg  [7:0] data_out = 8'h00,
    output reg        data_valid = 1'b0
);

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state = IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] shift_reg = 0;

    reg rx_sync1 = 1'b1;
    reg rx_sync2 = 1'b1;

    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
        data_valid <= 1'b0;

        case (state)
            IDLE: begin
                clk_count <= 0;
                bit_index <= 0;

                if (!rx_sync2)
                    state <= START;
            end

            START: begin
                if (clk_count == (CLKS_PER_BIT/2)-1) begin
                    clk_count <= 0;

                    if (!rx_sync2)
                        state <= DATA;
                    else
                        state <= IDLE;
                end
                else
                    clk_count <= clk_count + 1'b1;
            end

            DATA: begin
                if (clk_count == CLKS_PER_BIT-1) begin
                    clk_count <= 0;
                    shift_reg[bit_index] <= rx_sync2;

                    if (bit_index == 7) begin
                        bit_index <= 0;
                        state <= STOP;
                    end
                    else
                        bit_index <= bit_index + 1'b1;
                end
                else
                    clk_count <= clk_count + 1'b1;
            end

            STOP: begin
                if (clk_count == CLKS_PER_BIT-1) begin
                    clk_count <= 0;
                    state <= IDLE;

                    if (rx_sync2) begin
                        data_out <= shift_reg;
                        data_valid <= 1'b1;
                    end
                end
                else
                    clk_count <= clk_count + 1'b1;
            end

            default: state <= IDLE;
        endcase
    end

endmodule


// ============================================================
// UART TRANSMITTER
// ============================================================

module uart_tx #(
    parameter integer CLKS_PER_BIT = 1085
)(
    input  wire       clk,
    input  wire       tx_start,
    input  wire [7:0] data_in,
    output reg        tx = 1'b1,
    output reg        busy = 1'b0,
    output reg        done = 1'b0
);

    reg [15:0] clk_count = 0;
    reg [3:0] bit_index = 0;
    reg [7:0] shift_reg = 0;

    always @(posedge clk) begin
        done <= 1'b0;

        if (!busy) begin
            tx <= 1'b1;
            clk_count <= 0;
            bit_index <= 0;

            if (tx_start) begin
                shift_reg <= data_in;
                busy <= 1'b1;
                tx <= 1'b0;       // Start bit
            end
        end
        else begin
            if (clk_count == CLKS_PER_BIT-1) begin
                clk_count <= 0;

                if (bit_index < 8) begin
                    tx <= shift_reg[bit_index];
                    bit_index <= bit_index + 1'b1;
                end
                else begin
                    tx <= 1'b1;    // Stop bit
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            end
            else begin
                clk_count <= clk_count + 1'b1;
            end
        end
    end

endmodule
