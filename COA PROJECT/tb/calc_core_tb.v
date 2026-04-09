`timescale 1ns/1ps

module calc_core_tb;
    reg  [3:0] a;
    reg  [3:0] b;
    reg  [1:0] op_sel;
    wire [7:0] result;
    wire       valid;
    wire       div_by_zero;
    wire       overflow;

    calc_core dut (
        .a(a),
        .b(b),
        .op_sel(op_sel),
        .result(result),
        .valid(valid),
        .div_by_zero(div_by_zero),
        .overflow(overflow)
    );

    task run_case;
        input [127:0] name;
        input [3:0]   ta;
        input [3:0]   tb;
        input [1:0]   top;
        begin
            a      = ta;
            b      = tb;
            op_sel = top;
            #10;
            $display("[%0t] %0s | op=%b a=%0d b=%0d -> result=0x%02h (%0d) valid=%0b div0=%0b ovf=%0b",
                     $time, name, op_sel, a, b, result, result, valid, div_by_zero, overflow);
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, calc_core_tb);

        a      = 4'd0;
        b      = 4'd0;
        op_sel = 2'b00;
        #5;

        $display("===== ADDITION TESTS =====");
        run_case("ADD zero+zero",   4'd0,  4'd0,  2'b00);
        run_case("ADD normal",      4'd9,  4'd6,  2'b00);
        run_case("ADD max+max",     4'd15, 4'd15, 2'b00);
        run_case("ADD overflow",    4'd8,  4'd9,  2'b00);

        $display("===== SUBTRACTION TESTS =====");
        run_case("SUB equal",       4'd7,  4'd7,  2'b01);
        run_case("SUB positive",    4'd14, 4'd3,  2'b01);
        run_case("SUB negative",    4'd3,  4'd7,  2'b01);
        run_case("SUB 1-5",        4'd1,  4'd5,  2'b01);
        run_case("SUB 3-10",       4'd3,  4'd10, 2'b01);
        run_case("SUB 10-3",       4'd10, 4'd3,  2'b01);
        run_case("SUB min-max",     4'd0,  4'd15, 2'b01);

        $display("===== MULTIPLICATION TESTS =====");
        run_case("MUL zero",        4'd0,  4'd13, 2'b10);
        run_case("MUL normal",      4'd6,  4'd7,  2'b10);
        run_case("MUL max*max",     4'd15, 4'd15, 2'b10);

        $display("===== DIVISION TESTS =====");
        run_case("DIV normal",      4'd14, 4'd3,  2'b11);
        run_case("DIV exact",       4'd12, 4'd3,  2'b11);
        run_case("DIV 5/3",         4'd5,  4'd3,  2'b11);
        run_case("DIV 10/4",        4'd10, 4'd4,  2'b11);
        run_case("DIV 9/2",         4'd9,  4'd2,  2'b11);
        run_case("DIV numerator 0", 4'd0,  4'd5,  2'b11);
        run_case("DIV by zero",     4'd8,  4'd0,  2'b11);

        #10;
        $finish;
    end
endmodule
