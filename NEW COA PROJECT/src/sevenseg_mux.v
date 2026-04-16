//=============================================================================
// Module : sevenseg_mux
// Desc   : Time-multiplexes four digit codes onto the Nexys A7 eight-digit
//          7-segment display.  Only the four rightmost digits (an[3:0]) are
//          used; an[7:4] are held inactive.
//
// Digit code -> segment mapping (common anode, active LOW):
//   seg[6:0] = { CG, CF, CE, CD, CC, CB, CA }
//             = {  g,  f,  e,  d,  c,  b,  a }
//
//   Code  Symbol   7'b{g,f,e,d,c,b,a}
//    0      '0'    7'b1000000
//    1      '1'    7'b1111001
//    2      '2'    7'b0100100
//    3      '3'    7'b0110000
//    4      '4'    7'b0011001
//    5      '5'    7'b0010010
//    6      '6'    7'b0000010
//    7      '7'    7'b1111000
//    8      '8'    7'b0000000
//    9      '9'    7'b0010000
//   10    (blank)  7'b1111111
//   11      '-'    7'b0111111
//   12      'E'    7'b0000110
//   13      'r'    7'b0101111
//=============================================================================
module sevenseg_mux (
    input        clk,
    input        rst,
    input        refresh_tick,     // ~4 kHz strobe from clock_divider
    input  [3:0] digit3,           // leftmost digit code
    input  [3:0] digit2,
    input  [3:0] digit1,
    input  [3:0] digit0,           // rightmost digit code
    input  [3:0] dp_sel,           // dp_sel[i]=1 -> decimal point ON for digit i
    output reg [7:0] an,           // anodes  (active LOW); an[7:4] always 1
    output reg [6:0] seg,          // cathode segments (active LOW)
    output reg       dp            // decimal point    (active LOW)
);

    reg [1:0]  sel;          // current digit index (0-3)
    reg [3:0]  cur_code;     // digit code of selected digit
    reg        cur_dp;       // 1 = decimal point requested for this digit

    //------------------------------------------------------------------
    // Sequential: advance digit selector on each refresh tick
    //------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            sel <= 2'd0;
        else if (refresh_tick)
            sel <= sel + 2'd1;
    end

    //------------------------------------------------------------------
    // Combinational: select digit code, decimal point, and anode
    //------------------------------------------------------------------
    always @(*) begin
        an       = 8'b1111_1111;   // all off by default
        cur_code = digit0;
        cur_dp   = 1'b0;

        case (sel)
            2'd0 : begin an[0] = 1'b0; cur_code = digit0; cur_dp = dp_sel[0]; end
            2'd1 : begin an[1] = 1'b0; cur_code = digit1; cur_dp = dp_sel[1]; end
            2'd2 : begin an[2] = 1'b0; cur_code = digit2; cur_dp = dp_sel[2]; end
            2'd3 : begin an[3] = 1'b0; cur_code = digit3; cur_dp = dp_sel[3]; end
            default : begin an = 8'b1111_1111; cur_code = 4'd10; cur_dp = 1'b0; end
        endcase
    end

    //------------------------------------------------------------------
    // Combinational: 7-segment decoder + decimal point
    //------------------------------------------------------------------
    always @(*) begin
        dp = ~cur_dp;   // active LOW: 0 = decimal point ON

        case (cur_code)
            4'd0  : seg = 7'b1000000; // 0
            4'd1  : seg = 7'b1111001; // 1
            4'd2  : seg = 7'b0100100; // 2
            4'd3  : seg = 7'b0110000; // 3
            4'd4  : seg = 7'b0011001; // 4
            4'd5  : seg = 7'b0010010; // 5
            4'd6  : seg = 7'b0000010; // 6
            4'd7  : seg = 7'b1111000; // 7
            4'd8  : seg = 7'b0000000; // 8
            4'd9  : seg = 7'b0010000; // 9
            4'd10 : seg = 7'b1111111; // blank
            4'd11 : seg = 7'b0111111; // minus  (only g segment ON)
            4'd12 : seg = 7'b0000110; // E      (a,d,e,f,g ON)
            4'd13 : seg = 7'b0101111; // r      (e,g ON  - lowercase r)
            default: seg = 7'b1111111;// blank
        endcase
    end

endmodule
