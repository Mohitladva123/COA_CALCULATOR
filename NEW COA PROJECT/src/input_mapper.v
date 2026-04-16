//=============================================================================
// Module : input_mapper
// Desc   : Pure combinational module.
//          Maps 16-bit switch bus to calculator operands and operation.
//
//  sw[ 3: 0] -> a[3:0]      first operand  (0-15)
//  sw[ 7: 4] -> b[3:0]      second operand (0-15)
//  sw[ 9: 8] -> op_sel[1:0] operation select
//                   00 = Addition
//                   01 = Subtraction
//                   10 = Multiplication
//                   11 = Division
//  sw[15:10] -> unused
//=============================================================================
module input_mapper (
    input  [15:0] sw,
    output [3:0]  a,
    output [3:0]  b,
    output [1:0]  op_sel
);
    assign a      = sw[3:0];
    assign b      = sw[7:4];
    assign op_sel = sw[9:8];

endmodule
