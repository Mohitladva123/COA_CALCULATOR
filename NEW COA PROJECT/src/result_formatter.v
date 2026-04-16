//=============================================================================
// Module : result_formatter
// Desc   : Pure combinational.
//          Converts the binary result + status flags from calc_core into
//          four 4-bit digit codes ready for sevenseg_mux, plus a
//          decimal-point select register.
//
// Digit code table (used by sevenseg_mux decoder):
//   4'd0  - 4'd9  : digits 0-9
//   4'd10 (BLANK) : space / blank segment
//   4'd11 (MINUS) : minus sign  '-'
//   4'd12 (E_CHR) : letter      'E'
//   4'd13 (R_CHR) : letter      'r'
//
// Display formats
//   Normal  (ADD/SUB+/MUL) :  "  15"  right-justified, leading blanks
//   Negative subtraction   :  " -14"  minus + magnitude
//   Division               :  " 7.5"  or "15.0"  (dp_sel[1]=1)
//   Divide-by-zero         :  " Err"
//   Overflow               :  " Err"  (theoretically never happens)
//=============================================================================
module result_formatter (
    input      [7:0] result,
    input            overflow,
    input            div_by_zero,
    input            neg_flag,
    input            is_division,
    input      [3:0] dec_digit,
    // 4 digit codes for the 7-seg mux (digit3 = leftmost)
    output reg [3:0] digit3,
    output reg [3:0] digit2,
    output reg [3:0] digit1,
    output reg [3:0] digit0,
    // Decimal-point enable per digit position (1 = show DP after that digit)
    output reg [3:0] dp_sel
);

    // ---------- Special codes ----------
    localparam BLANK  = 4'd10;
    localparam MINUS  = 4'd11;
    localparam E_CHR  = 4'd12;
    localparam R_CHR  = 4'd13;

    // Working registers
    reg [7:0] magnitude;
    reg [3:0] d_h, d_t, d_u;   // hundreds, tens, units of the display value

    always @(*) begin
        // Safe defaults
        dp_sel   = 4'b0000;
        digit3   = BLANK;
        digit2   = BLANK;
        digit1   = BLANK;
        digit0   = BLANK;
        magnitude = 8'd0;
        d_h = 4'd0;
        d_t = 4'd0;
        d_u = 4'd0;

        // ----- Priority decode -----

        if (div_by_zero || overflow) begin
            //--------------------------------------------------------------
            // Error: display " Err"
            //--------------------------------------------------------------
            digit3 = BLANK;
            digit2 = E_CHR;
            digit1 = R_CHR;
            digit0 = R_CHR;

        end else if (neg_flag) begin
            //--------------------------------------------------------------
            // Negative subtraction result
            // Recover magnitude from 8-bit 2's complement: ~result + 1
            // Maximum magnitude = 15  (max 1-digit tens, 1-digit units)
            //--------------------------------------------------------------
            magnitude = (~result) + 8'd1;
            d_t = magnitude / 8'd10;   // 0 or 1
            d_u = magnitude % 8'd10;   // 0-9

            if (d_t == 4'd0) begin
                // " -X" format
                digit3 = BLANK;
                digit2 = BLANK;
                digit1 = MINUS;
                digit0 = d_u;
            end else begin
                // "-XX" format  (e.g. -14)
                digit3 = BLANK;
                digit2 = MINUS;
                digit1 = d_t;
                digit0 = d_u;
            end

        end else if (is_division) begin
            //--------------------------------------------------------------
            // Division result with one decimal place
            // result = integer quotient (0-15)
            // dec_digit = tenths digit  (0-9)
            // Decimal point sits between digit1 and digit0
            //--------------------------------------------------------------
            d_t = result / 8'd10;   // 0 or 1 (quotient max = 15)
            d_u = result % 8'd10;   // 0-9

            if (d_t == 4'd0) begin
                // " X.X" format
                digit3 = BLANK;
                digit2 = BLANK;
                digit1 = d_u;       // DP after this digit
                digit0 = dec_digit;
            end else begin
                // "XX.X" format
                digit3 = BLANK;
                digit2 = d_t;
                digit1 = d_u;       // DP after this digit
                digit0 = dec_digit;
            end
            dp_sel = 4'b0010;       // decimal point on digit1 position

        end else begin
            //--------------------------------------------------------------
            // Normal positive result (ADD, positive SUB, MUL)
            // Range: 0-225 -> max 3 digits
            //--------------------------------------------------------------
            d_h = result / 8'd100;
            d_t = (result % 8'd100) / 8'd10;
            d_u = result % 8'd10;

            if (d_h > 4'd0) begin
                digit3 = BLANK;
                digit2 = d_h;
                digit1 = d_t;
                digit0 = d_u;
            end else if (d_t > 4'd0) begin
                digit3 = BLANK;
                digit2 = BLANK;
                digit1 = d_t;
                digit0 = d_u;
            end else begin
                digit3 = BLANK;
                digit2 = BLANK;
                digit1 = BLANK;
                digit0 = d_u;
            end
        end
    end

endmodule
