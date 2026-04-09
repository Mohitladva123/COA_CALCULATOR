`timescale 1ns/1ps

module input_mapper (
    input  wire [15:0] sw,
    output wire [3:0]  a,
    output wire [3:0]  b,
    output wire [1:0]  op_sel
);
    assign a      = sw[3:0];
    assign b      = sw[7:4];
    assign op_sel = sw[9:8];
endmodule
