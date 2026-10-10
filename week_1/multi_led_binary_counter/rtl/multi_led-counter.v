`timescale 1ns / 1ps

module multi_led_counter (
    input  wire      clk,
    output reg [3:0] led = 4'd0
);

    reg [26:0] counter = 27'd0;

    always @(posedge clk) begin
        if (counter == 27'd124_999_999) begin
            counter <= 27'd0;
            led     <= led + 1'b1;
        end
        else begin
            counter <= counter + 1'b1;
        end
    end

endmodule