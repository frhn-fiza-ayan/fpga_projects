
module led_blinker (
    input  wire clk,
    output reg  led = 1'b0
);

    reg [26:0] counter = 27'd0;

    always @(posedge clk) begin
// write the frequency of board here
        if (counter == 27'd124_999_999) begin
            counter <= 27'd0;
            led     <= ~led;
        end
        else begin
            counter <= counter + 1'b1;
        end

    end

endmodule// H16 pin for clock