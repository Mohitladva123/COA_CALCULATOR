`timescale 1ns/1ps

module sevenseg_mux_dp_tb;
    reg        clk;
    reg        rst;
    reg        refresh_tick;
    reg  [3:0] digit3;
    reg  [3:0] digit2;
    reg  [3:0] digit1;
    reg  [3:0] digit0;
    reg        decimal_point;
    wire [7:0] an;
    wire [7:0] seg;

    integer i;
    integer errors;

    sevenseg_mux dut (
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

    always #5 clk = ~clk;

    task pulse_refresh;
        begin
            @(negedge clk);
            refresh_tick = 1'b1;
            @(negedge clk);
            refresh_tick = 1'b0;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        refresh_tick = 1'b0;
        digit3 = 4'd3;
        digit2 = 4'd2;
        digit1 = 4'd1;
        digit0 = 4'd0;
        decimal_point = 1'b1;
        errors = 0;

        // Hold reset for a few cycles.
        repeat (3) @(negedge clk);
        rst = 1'b0;

        // Step through multiple scan periods and ensure DP is active only on AN1.
        for (i = 0; i < 12; i = i + 1) begin
            pulse_refresh();
            #1;

            if (an == 8'b1111_1101) begin
                if (seg[7] !== 1'b0) begin
                    $display("DP alignment error: an=%b seg[7]=%b (expected 0)", an, seg[7]);
                    errors = errors + 1;
                end
            end else begin
                if (seg[7] !== 1'b1) begin
                    $display("DP leakage error: an=%b seg[7]=%b (expected 1)", an, seg[7]);
                    errors = errors + 1;
                end
            end
        end

        if (errors == 0)
            $display("PASS: DP is active only on digit1 (AN1).");
        else
            $display("FAIL: %0d DP alignment errors.", errors);

        $finish;
    end
endmodule