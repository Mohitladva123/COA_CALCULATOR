//=============================================================================
// Module : calc_core
// Desc   : Synchronous ALU.  All outputs update on the rising clock edge
//          following a change on a, b, or op_sel.
//
// Operations
//   00 ADD : result = a + b          (0..30,  no overflow possible)
//   01 SUB : result = a - b (8-bit 2's complement)
//              neg_flag = 1 when a < b
//   10 MUL : result = a * b          (0..225, no overflow possible)
//   11 DIV : result    = a / b       (integer quotient)
//             dec_digit = ((a % b) * 10) / b   (tenths digit, 0-9)
//             div_by_zero = 1 when b == 0
//
// 2's complement note
//   When neg_flag is asserted, result[7:0] holds the standard 8-bit
//   two's complement representation (e.g. -4 => 0xFC).
//   The LED driver displays this raw value so the operator can read
//   the two's complement binary directly from the LEDs.
//   The result_formatter recovers the magnitude for the 7-seg display.
//=============================================================================
module calc_core (
    input        clk,
    input        rst,
    input  [3:0] a,
    input  [3:0] b,
    input  [1:0] op_sel,
    // outputs
    output reg [7:0] result,
    output reg       overflow,
    output reg       div_by_zero,
    output reg       neg_flag,
    output reg       is_division,
    output reg [3:0] dec_digit,
    output reg       valid
);
    // Wider intermediate for overflow detection
    reg [8:0] wide;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result      <= 8'd0;
            overflow    <= 1'b0;
            div_by_zero <= 1'b0;
            neg_flag    <= 1'b0;
            is_division <= 1'b0;
            dec_digit   <= 4'd0;
            valid       <= 1'b0;
        end else begin
            // ---- defaults (clear every cycle) ----
            overflow    <= 1'b0;
            div_by_zero <= 1'b0;
            neg_flag    <= 1'b0;
            is_division <= 1'b0;
            dec_digit   <= 4'd0;
            valid       <= 1'b1;

            case (op_sel)
                //------------------------------------------------------
                // ADD
                //------------------------------------------------------
                2'b00 : begin
                    wide   = {1'b0, a} + {1'b0, b};   // 9-bit sum
                    result   <= wide[7:0];
                    overflow <= wide[8];               // never set (max=30)
                end

                //------------------------------------------------------
                // SUB  — store 8-bit 2's complement, flag if negative
                //------------------------------------------------------
                2'b01 : begin
                    result   <= {4'b0000, a} - {4'b0000, b};
                    neg_flag <= (a < b) ? 1'b1 : 1'b0;
                end

                //------------------------------------------------------
                // MUL
                //------------------------------------------------------
                2'b10 : begin
                    wide   = {1'b0, a} * {1'b0, b};   // 9-bit product
                    result   <= wide[7:0];
                    overflow <= wide[8];               // never set (max=225)
                end

                //------------------------------------------------------
                // DIV  — integer quotient + one decimal digit
                //------------------------------------------------------
                2'b11 : begin
                    is_division <= 1'b1;
                    if (b == 4'd0) begin
                        div_by_zero <= 1'b1;
                        result      <= 8'd0;
                        dec_digit   <= 4'd0;
                    end else begin
                        // Integer quotient (0..15)
                        result <= {4'b0000, a} / {4'b0000, b};

                        // Tenths digit: floor( (remainder*10) / b )
                        // Max intermediate = 14*10 = 140  (fits in 8 bits)
                        dec_digit <= (({4'b0000, a} % {4'b0000, b}) * 8'd10)
                                      / {4'b0000, b};
                    end
                end

                default : begin
                    result <= 8'd0;
                end
            endcase
        end
    end

endmodule
