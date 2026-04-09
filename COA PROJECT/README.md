# 4-bit Verilog Calculator (Nexys A7)

## Top module
- `rtl/calculator_top_nexys_a7.v`

## Files
- `rtl/calc_core.v`
- `rtl/input_mapper.v`
- `rtl/led_driver.v`
- `rtl/result_formatter.v`
- `rtl/sevenseg_decoder_hex.v`
- `rtl/sevenseg_mux.v`
- `constr/nexys_a7_calculator.xdc`
- `tb/calc_core_tb.v`

## Switch mapping
- `SW[3:0]`   -> `A[3:0]`
- `SW[7:4]`   -> `B[3:0]`
- `SW[9:8]`   -> `op_sel[1:0]`
  - `00` add
  - `01` subtract
  - `10` multiply
  - `11` divide

## LED mapping
- `LED[7:0]`   -> result
- `LED[8]`     -> valid
- `LED[9]`     -> divide-by-zero
- `LED[10]`    -> add overflow

## Note
- If your Nexys A7 variant uses different pin assignments, update `constr/nexys_a7_calculator.xdc` with your board master XDC.
