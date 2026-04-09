`timescale 1ns/1ps

module result_formatter (
    input  wire       rst,
    input  wire [7:0] result,
    input  wire       div_by_zero,
    input  wire       overflow,
    input  wire [1:0] op_sel,
    output reg  [3:0] digit3,
    output reg  [3:0] digit2,
    output reg  [3:0] digit1,
    output reg  [3:0] digit0,
    output reg        decimal_point
);

    reg [7:0] display_val;
    reg [3:0] tens;
    reg [3:0] ones;

    always @(*) begin
        display_val = result;
        decimal_point = 1'b0;

        if (rst || div_by_zero) begin
            digit3 = 0;
            digit2 = 0;
            digit1 = 0;
            digit0 = 0;
        end else begin

            if (op_sel == 2'b11) begin
                // Division fixed-point value is result*10 (e.g., 15.0 => 150).
                if (display_val > 150)
                    display_val = 150;

                digit3 = 0;
                digit2 = display_val / 100;       // tens of integer part
                digit1 = (display_val / 10) % 10; // ones of integer part
                digit0 = display_val % 10;        // tenths

                decimal_point = 1'b1;
            end else begin
                // Normal operations
                if (display_val > 99)
                    display_val = 99;

                tens = display_val / 10;
                ones = display_val % 10;

                digit3 = 0;
                digit2 = overflow ? 1 : 0;
                digit1 = tens;
                digit0 = ones;
            end
        end
    end
endmodule