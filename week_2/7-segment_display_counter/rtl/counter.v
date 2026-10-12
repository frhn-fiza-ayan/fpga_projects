`timescale 1ns / 1ps

module seven_segment_counter #(
    parameter integer COUNT_MAX = 124_999_999
)(
    input  wire       clk,
    output reg  [6:0] seg,
    output wire       digit
);

    // =========================================================
    // 1 SECOND COUNTER
    // =========================================================

    reg [26:0] counter = 27'd0;

    // =========================================================
    // 0-15 COUNTER
    // =========================================================

    reg [3:0] number = 4'd0;

    always @(posedge clk) begin

        if (counter == COUNT_MAX) begin

            counter <= 27'd0;

            if (number == 4'd15)
                number <= 4'd0;
            else
                number <= number + 1'b1;

        end

        else begin
            counter <= counter + 1'b1;
        end

    end

    // =========================================================
    // 7-SEGMENT DECODER
    //
    // seg = {g,f,e,d,c,b,a}
    //
    // ACTIVE-HIGH SEGMENTS
    // =========================================================

    always @(*) begin

        case (number)

            // 0
            4'd0:  seg = 7'b0111111;

            // 1
            4'd1:  seg = 7'b0000110;

            // 2
            4'd2:  seg = 7'b1011011;

            // 3
            4'd3:  seg = 7'b1001111;

            // 4
            4'd4:  seg = 7'b1100110;

            // 5
            4'd5:  seg = 7'b1101101;

            // 6
            4'd6:  seg = 7'b1111101;

            // 7
            4'd7:  seg = 7'b0000111;

            // 8
            4'd8:  seg = 7'b1111111;

            // 9
            4'd9:  seg = 7'b1101111;

            // A = 10
            4'd10: seg = 7'b1110111;

            // b = 11
            4'd11: seg = 7'b1111100;

            // C = 12
            4'd12: seg = 7'b0111001;

            // d = 13
            4'd13: seg = 7'b1011110;

            // E = 14
            4'd14: seg = 7'b1111001;

            // F = 15
            4'd15: seg = 7'b1110001;

            default: seg = 7'b0000000;

        endcase

    end

    // Enable the single digit
    assign digit = 1'b1;

endmodule