`timescale 1ns/1ps

module calculator_top_nexys_a7 (
    input  wire        clk,
    input  wire [15:0] sw,
    output wire [15:0] led,
    output wire [7:0]  seg,
    output wire [7:0]  an
);
    wire [3:0] a;
    wire [3:0] b;
    wire [1:0] op_sel;
    wire [15:0] sw_sync;

    wire [7:0] result;
    wire       valid;
    wire       div_by_zero;
    wire       overflow;
    wire       rst;
    wire       refresh_tick;

    reset_sync u_reset_sync (
        .clk(clk),
        .rst_in(sw[15]),
        .rst(rst)
    );

    switch_sync #(
        .WIDTH(16)
    ) u_switch_sync (
        .clk(clk),
        .rst(rst),
        .sw_in(sw),
        .sw_out(sw_sync)
    );

    clock_divider #(
        .DIVISOR(100000)
    ) u_refresh_div (
        .clk(clk),
        .rst(rst),
        .tick(refresh_tick)
    );


    wire [3:0] digit3;
    wire [3:0] digit2;
    wire [3:0] digit1;
    wire [3:0] digit0;
    wire       decimal_point;

    input_mapper u_input_mapper (
        .sw(sw_sync),
        .a(a),
        .b(b),
        .op_sel(op_sel)
    );

    calc_core u_calc_core (
        .a(a),
        .b(b),
        .op_sel(op_sel),
        .result(result),
        .valid(valid),
        .div_by_zero(div_by_zero),
        .overflow(overflow)
    );

    led_driver u_led_driver (
        .rst(rst),
        .result(result),
        .valid(valid),
        .div_by_zero(div_by_zero),
        .overflow(overflow),
        .led(led)
    );

    result_formatter u_result_formatter (
        .rst(rst),
        .result(result),
        .div_by_zero(div_by_zero),
        .overflow(overflow),
        .op_sel(op_sel),
        .digit3(digit3),
        .digit2(digit2),
        .digit1(digit1),
        .digit0(digit0),
        .decimal_point(decimal_point)
    );

    sevenseg_mux u_sevenseg_mux (
        .clk(clk),
        .rst(rst),
        .refresh_tick(refresh_tick),
        .digit3(digit3),
        .digit2(digit2),
        .digit1(digit1),
        .digit0(digit0),
        .decimal_point(decimal_point),
        .an(an),
        .seg(seg)
    );
endmodule
