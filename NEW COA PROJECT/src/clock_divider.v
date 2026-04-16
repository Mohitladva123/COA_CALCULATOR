//=============================================================================
// Module : clock_divider
// Desc   : Generates a single-cycle pulse (tick) at ~4 kHz from a 100 MHz
//          input clock.  Used to drive the 7-segment digit-scan counter in
//          sevenseg_mux.
//
//          100 MHz / 25 000 = 4 000 Hz  ->  each of 4 digits visible ~250 µs
//          (well above the 50 Hz flicker-fusion threshold)
//=============================================================================
module clock_divider (
    input  clk,
    input  rst,
    output reg tick
);
    // Adjust DIVISOR if your board runs at a different clock rate
    localparam integer DIVISOR = 25_000;   // 100 MHz -> 4 kHz tick

    reg [14:0] counter;   // 15 bits sufficient for 25 000

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 15'd0;
            tick    <= 1'b0;
        end else if (counter == DIVISOR - 1) begin
            counter <= 15'd0;
            tick    <= 1'b1;
        end else begin
            counter <= counter + 15'd1;
            tick    <= 1'b0;
        end
    end

endmodule
