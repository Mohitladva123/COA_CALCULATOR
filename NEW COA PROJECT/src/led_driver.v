//=============================================================================
// Module : led_driver
// Desc   : Drives the 16 on-board LEDs.
//
//  led[ 7: 0] = result[7:0]   8-bit result (2's complement for negative SUB)
//  led[     8] = overflow      overflow flag
//  led[     9] = div_by_zero   divide-by-zero flag
//  led[    10] = neg_flag      negative result flag
//  led[15:11] = 0              unused
//
// All LEDs are cleared synchronously while rst is asserted.
//=============================================================================
module led_driver (
    input      [7:0] result,
    input            overflow,
    input            div_by_zero,
    input            neg_flag,
    input            rst,
    input            valid,
    output reg [15:0] led
);
    always @(*) begin
        if (rst || !valid)
            led = 16'd0;
        else
            led = {5'b00000, neg_flag, div_by_zero, overflow, result};
    end

endmodule
