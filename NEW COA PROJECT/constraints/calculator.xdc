##=============================================================================
## Nexys Artix-7 (A7-100T / A7-50T) — XDC Constraint File
## Project : FPGA Calculator
##
## NOTE: Verify all pin assignments against the official Digilent
##       Nexys A7 master XDC file before programming the device.
##       Download from: https://github.com/Digilent/digilent-xdc
##=============================================================================

##------------------------------------------------------------
## System Clock — 100 MHz  (Bank 35, E3)
##------------------------------------------------------------
set_property PACKAGE_PIN E3    [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 \
             -waveform {0 5} [get_ports clk]

##------------------------------------------------------------
## Reset — BTNC (Centre push-button, active HIGH)
##------------------------------------------------------------
set_property PACKAGE_PIN N17   [get_ports rst_in]
set_property IOSTANDARD LVCMOS33 [get_ports rst_in]

##------------------------------------------------------------
## Switches  sw[0..15]
##   sw[3:0]   -> operand A
##   sw[7:4]   -> operand B
##   sw[9:8]   -> op_sel  (00=ADD 01=SUB 10=MUL 11=DIV)
##   sw[15:10] -> unused
##------------------------------------------------------------
set_property PACKAGE_PIN J15   [get_ports {sw[0]}]
set_property PACKAGE_PIN L16   [get_ports {sw[1]}]
set_property PACKAGE_PIN M13   [get_ports {sw[2]}]
set_property PACKAGE_PIN R15   [get_ports {sw[3]}]
set_property PACKAGE_PIN R17   [get_ports {sw[4]}]
set_property PACKAGE_PIN T18   [get_ports {sw[5]}]
set_property PACKAGE_PIN U18   [get_ports {sw[6]}]
set_property PACKAGE_PIN R13   [get_ports {sw[7]}]
set_property PACKAGE_PIN T8    [get_ports {sw[8]}]
set_property PACKAGE_PIN U8    [get_ports {sw[9]}]
set_property PACKAGE_PIN R16   [get_ports {sw[10]}]
set_property PACKAGE_PIN T13   [get_ports {sw[11]}]
set_property PACKAGE_PIN H6    [get_ports {sw[12]}]
set_property PACKAGE_PIN U12   [get_ports {sw[13]}]
set_property PACKAGE_PIN U11   [get_ports {sw[14]}]
set_property PACKAGE_PIN V10   [get_ports {sw[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]

##------------------------------------------------------------
## LEDs  led[0..15]
##   led[7:0]  = 8-bit result (2's complement when neg)
##   led[8]    = overflow flag
##   led[9]    = divide-by-zero flag
##   led[10]   = negative flag
##   led[15:11]= 0
##------------------------------------------------------------
set_property PACKAGE_PIN H17   [get_ports {led[0]}]
set_property PACKAGE_PIN K15   [get_ports {led[1]}]
set_property PACKAGE_PIN J13   [get_ports {led[2]}]
set_property PACKAGE_PIN N14   [get_ports {led[3]}]
set_property PACKAGE_PIN R18   [get_ports {led[4]}]
set_property PACKAGE_PIN V17   [get_ports {led[5]}]
set_property PACKAGE_PIN U17   [get_ports {led[6]}]
set_property PACKAGE_PIN U16   [get_ports {led[7]}]
set_property PACKAGE_PIN V16   [get_ports {led[8]}]
set_property PACKAGE_PIN T15   [get_ports {led[9]}]
set_property PACKAGE_PIN U14   [get_ports {led[10]}]
set_property PACKAGE_PIN T16   [get_ports {led[11]}]
set_property PACKAGE_PIN V15   [get_ports {led[12]}]
set_property PACKAGE_PIN V14   [get_ports {led[13]}]
set_property PACKAGE_PIN V12   [get_ports {led[14]}]
set_property PACKAGE_PIN V11   [get_ports {led[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]

##------------------------------------------------------------
## 7-Segment Display — Cathode segments
##   seg[6:0] = { CG, CF, CE, CD, CC, CB, CA }
##            = {  g,  f,  e,  d,  c,  b,  a }
##   Active LOW (0 = segment ON)
##------------------------------------------------------------
set_property PACKAGE_PIN W7    [get_ports {seg[0]}]   ;# CA (a)
set_property PACKAGE_PIN W6    [get_ports {seg[1]}]   ;# CB (b)
set_property PACKAGE_PIN U8    [get_ports {seg[2]}]   ;# CC (c)  ** see note below
set_property PACKAGE_PIN V8    [get_ports {seg[3]}]   ;# CD (d)
set_property PACKAGE_PIN U5    [get_ports {seg[4]}]   ;# CE (e)
set_property PACKAGE_PIN V5    [get_ports {seg[5]}]   ;# CF (f)
set_property PACKAGE_PIN U7    [get_ports {seg[6]}]   ;# CG (g)
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]

## NOTE on seg[2] / sw[9] / U8:
##   On some Nexys A7 board revisions pin U8 is shared between
##   SW9 and the CC segment.  If you observe incorrect segment C
##   behaviour while sw[9] is used for op_sel[1], either:
##   (a) move op_sel[1] to sw[15] and update input_mapper.v, or
##   (b) confirm your board's exact XDC from Digilent GitHub.

##------------------------------------------------------------
## 7-Segment Display — Decimal Point
##   Active LOW (0 = decimal point ON)
##------------------------------------------------------------
set_property PACKAGE_PIN V7    [get_ports dp]
set_property IOSTANDARD LVCMOS33 [get_ports dp]

##------------------------------------------------------------
## 7-Segment Display — Anodes an[0..7]
##   Active LOW (0 = digit selected)
##   We drive an[3:0]; an[7:4] are held HIGH in RTL.
##------------------------------------------------------------
set_property PACKAGE_PIN J17   [get_ports {an[0]}]
set_property PACKAGE_PIN J18   [get_ports {an[1]}]
set_property PACKAGE_PIN T9    [get_ports {an[2]}]
set_property PACKAGE_PIN J14   [get_ports {an[3]}]
set_property PACKAGE_PIN P14   [get_ports {an[4]}]
set_property PACKAGE_PIN T14   [get_ports {an[5]}]
set_property PACKAGE_PIN K2    [get_ports {an[6]}]
set_property PACKAGE_PIN U13   [get_ports {an[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

##------------------------------------------------------------
## Timing constraints
##------------------------------------------------------------
## False path on reset synchronizer stages (async assert, sync deassert)
set_false_path -from [get_ports rst_in]

## Input/Output delays (relax if timing is not critical)
set_input_delay  -clock sys_clk_pin  2.0 [get_ports {sw[*]}]
set_output_delay -clock sys_clk_pin  2.0 [get_ports {led[*]}]
set_output_delay -clock sys_clk_pin  2.0 [get_ports {seg[*]}]
set_output_delay -clock sys_clk_pin  2.0 [get_ports {an[*]}]
set_output_delay -clock sys_clk_pin  2.0 [get_ports dp]
