`timescale 1ns/1ps

module led_driver (
    input  wire        rst,
    input  wire [7:0]  result,
    input  wire        valid,
    input  wire        div_by_zero,
    input  wire        overflow,
    output wire [15:0] led
);
    assign led[7:0]   = rst ? 8'h00 : result;
    assign led[8]     = rst ? 1'b0  : valid;
    assign led[9]     = rst ? 1'b0  : div_by_zero;
    assign led[10]    = rst ? 1'b0  : overflow;
    assign led[13:11] = 3'b000;
    assign led[14]    = rst ? 1'b0  : overflow;    // dedicated overflow indicator
    assign led[15]    = rst ? 1'b0  : div_by_zero; // dedicated divide-by-zero indicator
endmodule
