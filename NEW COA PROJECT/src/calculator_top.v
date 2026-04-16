//=============================================================================
// Module   : calculator_top
// Board    : Nexys Artix-7 (100T / 50T)
// Tool     : Xilinx Vivado
// Desc     : Top-level wrapper.  Connects all submodules.
//
// Switch mapping
//   sw[ 3: 0] -> operand A (4-bit)
//   sw[ 7: 4] -> operand B (4-bit)
//   sw[ 9: 8] -> op_sel   (00=ADD, 01=SUB, 10=MUL, 11=DIV)
//   sw[15:10] -> unused
//
// LED mapping
//   led[ 7: 0] -> 8-bit result (2's complement for negative SUB)
//   led[     8] -> overflow flag
//   led[     9] -> divide-by-zero flag
//   led[    10] -> negative flag
//   led[15:11] -> 0
//
// 7-Seg display
//   ADD/SUB pos  :  "  15"  (right-justified decimal)
//   SUB negative :  " -14"  (sign + magnitude)
//   MUL          :  " 225"
//   DIV          :  " 7.5"  (1 decimal place)
//   DIV by zero  :  " Err"
//=============================================================================
module calculator_top (
    input        clk,        // 100 MHz system clock
    input        rst_in,     // Active-high async reset (BTNC)
    input  [15:0] sw,        // 16 switches
    output [15:0] led,       // 16 LEDs
    output [7:0]  an,        // 7-seg anodes  (active LOW)
    output [6:0]  seg,       // 7-seg cathodes (active LOW)
    output        dp         // 7-seg decimal point (active LOW)
);

    //------------------------------------------------------------------
    // Internal wires
    //------------------------------------------------------------------
    wire        rst;
    wire [3:0]  a, b;
    wire [1:0]  op_sel;
    wire [7:0]  result;
    wire        overflow, div_by_zero, neg_flag, is_division, valid;
    wire [3:0]  dec_digit;
    wire [3:0]  digit3, digit2, digit1, digit0;
    wire [3:0]  dp_sel;
    wire        refresh_tick;

    //------------------------------------------------------------------
    // Sub-module instantiations
    //------------------------------------------------------------------

    reset_sync u_reset_sync (
        .clk    (clk),
        .rst_in (rst_in),
        .rst    (rst)
    );

    input_mapper u_input_mapper (
        .sw     (sw),
        .a      (a),
        .b      (b),
        .op_sel (op_sel)
    );

    calc_core u_calc_core (
        .clk         (clk),
        .rst         (rst),
        .a           (a),
        .b           (b),
        .op_sel      (op_sel),
        .result      (result),
        .overflow    (overflow),
        .div_by_zero (div_by_zero),
        .neg_flag    (neg_flag),
        .is_division (is_division),
        .dec_digit   (dec_digit),
        .valid       (valid)
    );

    result_formatter u_result_formatter (
        .result      (result),
        .overflow    (overflow),
        .div_by_zero (div_by_zero),
        .neg_flag    (neg_flag),
        .is_division (is_division),
        .dec_digit   (dec_digit),
        .digit3      (digit3),
        .digit2      (digit2),
        .digit1      (digit1),
        .digit0      (digit0),
        .dp_sel      (dp_sel)
    );

    clock_divider u_refresh_div (
        .clk  (clk),
        .rst  (rst),
        .tick (refresh_tick)
    );

    sevenseg_mux u_sevenseg_mux (
        .clk          (clk),
        .rst          (rst),
        .refresh_tick (refresh_tick),
        .digit3       (digit3),
        .digit2       (digit2),
        .digit1       (digit1),
        .digit0       (digit0),
        .dp_sel       (dp_sel),
        .an           (an),
        .seg          (seg),
        .dp           (dp)
    );

    led_driver u_led_driver (
        .result      (result),
        .overflow    (overflow),
        .div_by_zero (div_by_zero),
        .neg_flag    (neg_flag),
        .rst         (rst),
        .valid       (valid),
        .led         (led)
    );

endmodule
