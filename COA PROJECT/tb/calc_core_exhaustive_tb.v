`timescale 1ns/1ps

module calc_core_exhaustive_tb;
    reg  [3:0] a;
    reg  [3:0] b;
    reg  [1:0] op_sel;
    wire [7:0] result;
    wire       valid;
    wire       div_by_zero;
    wire       overflow;

    integer i;
    integer j;
    integer errors;
    integer expected_add;
    integer expected_sub;
    integer expected_mul;
    integer expected_div;

    calc_core dut (
        .a(a),
        .b(b),
        .op_sel(op_sel),
        .result(result),
        .valid(valid),
        .div_by_zero(div_by_zero),
        .overflow(overflow)
    );

    initial begin
        errors = 0;

        // ADD
        op_sel = 2'b00;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0];
                b = j[3:0];
                #1;
                expected_add = i + j;
                if (result !== expected_add[7:0]) begin
                    $display("ADD result mismatch: a=%0d b=%0d got=%0d exp=%0d", i, j, result, expected_add[7:0]);
                    errors = errors + 1;
                end
                if (overflow !== (expected_add > 15)) begin
                    $display("ADD overflow mismatch: a=%0d b=%0d got=%0b exp=%0b", i, j, overflow, (expected_add > 15));
                    errors = errors + 1;
                end
                if (div_by_zero !== 1'b0) begin
                    $display("ADD div_by_zero should be 0: a=%0d b=%0d", i, j);
                    errors = errors + 1;
                end
            end
        end

        // SUB (4-bit wrap-around result in low nibble)
        op_sel = 2'b01;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0];
                b = j[3:0];
                #1;
                expected_sub = (i - j) & 32'hF;
                if (result !== {4'h0, expected_sub[3:0]}) begin
                    $display("SUB mismatch: a=%0d b=%0d got=0x%02h exp=0x%02h", i, j, result, {4'h0, expected_sub[3:0]});
                    errors = errors + 1;
                end
                if (overflow !== 1'b0) begin
                    $display("SUB overflow should be 0: a=%0d b=%0d", i, j);
                    errors = errors + 1;
                end
                if (valid !== 1'b1) begin
                    $display("SUB valid should be 1: a=%0d b=%0d", i, j);
                    errors = errors + 1;
                end
                if (div_by_zero !== 1'b0) begin
                    $display("SUB div_by_zero should be 0: a=%0d b=%0d", i, j);
                    errors = errors + 1;
                end
            end
        end

        // MUL
        op_sel = 2'b10;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0];
                b = j[3:0];
                #1;
                expected_mul = i * j;
                if (result !== expected_mul[7:0]) begin
                    $display("MUL mismatch: a=%0d b=%0d got=%0d exp=%0d", i, j, result, expected_mul[7:0]);
                    errors = errors + 1;
                end
                if (overflow !== 1'b0) begin
                    $display("MUL overflow should be 0: a=%0d b=%0d", i, j);
                    errors = errors + 1;
                end
                if (valid !== 1'b1) begin
                    $display("MUL valid should be 1: a=%0d b=%0d", i, j);
                    errors = errors + 1;
                end
                if (div_by_zero !== 1'b0) begin
                    $display("MUL div_by_zero should be 0: a=%0d b=%0d", i, j);
                    errors = errors + 1;
                end
            end
        end

        // DIV
        op_sel = 2'b11;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0];
                b = j[3:0];
                #1;
                if (j == 0) begin
                    if (div_by_zero !== 1'b1 || valid !== 1'b0 || result !== 8'h00) begin
                        $display("DIV by zero mismatch: a=%0d b=%0d got div0=%0b valid=%0b result=0x%02h", i, j, div_by_zero, valid, result);
                        errors = errors + 1;
                    end
                    if (overflow !== 1'b0) begin
                        $display("DIV overflow should be 0 on divide-by-zero: a=%0d b=%0d", i, j);
                        errors = errors + 1;
                    end
                end else begin
                    // Fixed-point division with rounding to nearest tenth.
                    expected_div = (i * 10 + (j / 2)) / j;
                    if (result !== expected_div[7:0]) begin
                        $display("DIV mismatch: a=%0d b=%0d got=%0d exp=%0d", i, j, result, expected_div[7:0]);
                        errors = errors + 1;
                    end
                    if (div_by_zero !== 1'b0 || valid !== 1'b1 || overflow !== 1'b0) begin
                        $display("DIV flags mismatch: a=%0d b=%0d div0=%0b valid=%0b ovf=%0b", i, j, div_by_zero, valid, overflow);
                        errors = errors + 1;
                    end
                end
            end
        end

        if (errors == 0) begin
            $display("PASS: all exhaustive calc_core checks passed.");
        end else begin
            $display("FAIL: %0d mismatches found.", errors);
        end

        $finish;
    end
endmodule
