`timescale 1ns/1ps

module result_formatter_tb;
    reg        rst;
    reg  [7:0] result;
    reg        div_by_zero;
    reg        overflow;
    reg  [1:0] op_sel;
    wire [3:0] digit3;
    wire [3:0] digit2;
    wire [3:0] digit1;
    wire [3:0] digit0;
    wire       decimal_point;

    integer errors;

    result_formatter dut (
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

    task check_case;
        input [127:0] name;
        input [3:0] e3;
        input [3:0] e2;
        input [3:0] e1;
        input [3:0] e0;
        input       edp;
        begin
            #1;
            if (digit3 !== e3 || digit2 !== e2 || digit1 !== e1 || digit0 !== e0 || decimal_point !== edp) begin
                $display("FAIL %0s: got d3d2d1d0=%0d%0d%0d%0d dp=%0b exp=%0d%0d%0d%0d dp=%0b",
                         name, digit3, digit2, digit1, digit0, decimal_point, e3, e2, e1, e0, edp);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        errors = 0;

        // Division: 5/3 => 1.7
        rst = 1'b0; div_by_zero = 1'b0; overflow = 1'b0; op_sel = 2'b11; result = 8'd17;
        check_case("DIV 5/3", 4'd0, 4'd0, 4'd1, 4'd7, 1'b1);

        // Division upper bound representation: 15/1 => 15.0
        rst = 1'b0; div_by_zero = 1'b0; overflow = 1'b0; op_sel = 2'b11; result = 8'd150;
        check_case("DIV 15/1", 4'd0, 4'd1, 4'd5, 4'd0, 1'b1);

        // Non-division normal formatting.
        rst = 1'b0; div_by_zero = 1'b0; overflow = 1'b0; op_sel = 2'b00; result = 8'd42;
        check_case("ADD 42", 4'd0, 4'd0, 4'd4, 4'd2, 1'b0);

        // Overflow indicator on digit2 for non-division path.
        rst = 1'b0; div_by_zero = 1'b0; overflow = 1'b1; op_sel = 2'b00; result = 8'd30;
        check_case("ADD OVF", 4'd0, 4'd1, 4'd3, 4'd0, 1'b0);

        // Reset/div-by-zero blanking.
        rst = 1'b0; div_by_zero = 1'b1; overflow = 1'b0; op_sel = 2'b11; result = 8'd88;
        check_case("DIV0 blank", 4'd0, 4'd0, 4'd0, 4'd0, 1'b0);

        if (errors == 0)
            $display("PASS: result_formatter checks passed.");
        else
            $display("FAIL: %0d result_formatter errors.", errors);

        $finish;
    end
endmodule