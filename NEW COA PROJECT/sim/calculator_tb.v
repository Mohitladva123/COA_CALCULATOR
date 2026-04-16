//=============================================================================
// Module   : calculator_tb
// Desc     : Self-checking testbench for the FPGA Calculator.
//            Exercises all four operations with boundary and typical values.
//            Expected values are checked automatically; PASS/FAIL printed.
//
// Run with Vivado Simulator or any Verilog-2001 compatible tool:
//   iverilog -o sim.out calculator_tb.v calculator_top.v \
//       input_mapper.v calc_core.v result_formatter.v \
//       sevenseg_mux.v led_driver.v clock_divider.v reset_sync.v
//   vvp sim.out
//=============================================================================
`timescale 1ns / 1ps

module calculator_tb;

    //------------------------------------------------------------------
    // DUT I/O
    //------------------------------------------------------------------
    reg         clk;
    reg         rst_in;
    reg  [15:0] sw;

    wire [15:0] led;
    wire [7:0]  an;
    wire [6:0]  seg;
    wire        dp;

    //------------------------------------------------------------------
    // Instantiate DUT
    //------------------------------------------------------------------
    calculator_top uut (
        .clk    (clk),
        .rst_in (rst_in),
        .sw     (sw),
        .led    (led),
        .an     (an),
        .seg    (seg),
        .dp     (dp)
    );

    //------------------------------------------------------------------
    // 100 MHz clock
    //------------------------------------------------------------------
    localparam CLK_PERIOD = 10; // ns
    initial clk = 1'b0;
    always  #(CLK_PERIOD/2) clk = ~clk;

    //------------------------------------------------------------------
    // Test counters
    //------------------------------------------------------------------
    integer pass_count;
    integer fail_count;

    //------------------------------------------------------------------
    // Helper: apply switches, wait 4 clock cycles, read LED outputs
    //------------------------------------------------------------------
    task apply;
        input [3:0]  a_in;
        input [3:0]  b_in;
        input [1:0]  op_in;
        begin
            sw = {6'b000000, op_in, b_in, a_in};
            repeat(4) @(posedge clk);
            #1; // settle past clock edge
        end
    endtask

    //------------------------------------------------------------------
    // Helper: check result byte + flags
    //------------------------------------------------------------------
    task check;
        input [3:0]  a_in;
        input [3:0]  b_in;
        input [1:0]  op_in;
        input [7:0]  exp_result;
        input        exp_neg;
        input        exp_div0;
        input        exp_ovf;
        input [63:0] label;      // 8-char ASCII label, e.g. "ADD 5+3 "
        begin
            apply(a_in, b_in, op_in);

            if (led[7:0] === exp_result &&
                led[10]  === exp_neg   &&
                led[9]   === exp_div0  &&
                led[8]   === exp_ovf) begin
                $display("  PASS  %-8s  a=%2d b=%2d  result=0x%02X neg=%b div0=%b ovf=%b",
                    label, a_in, b_in, led[7:0], led[10], led[9], led[8]);
                pass_count = pass_count + 1;
            end else begin
                $display("  FAIL  %-8s  a=%2d b=%2d",
                    label, a_in, b_in);
                $display("         expected result=0x%02X neg=%b div0=%b ovf=%b",
                    exp_result, exp_neg, exp_div0, exp_ovf);
                $display("         got      result=0x%02X neg=%b div0=%b ovf=%b",
                    led[7:0], led[10], led[9], led[8]);
                fail_count = fail_count + 1;
            end
        end
    endtask

    //------------------------------------------------------------------
    // Main test sequence
    //------------------------------------------------------------------
    initial begin
        $dumpfile("calculator_tb.vcd");
        $dumpvars(0, calculator_tb);

        pass_count = 0;
        fail_count = 0;

        //---------- Reset ----------
        rst_in = 1'b1;
        sw     = 16'h0000;
        repeat(6) @(posedge clk);
        rst_in = 1'b0;
        @(posedge clk); #1;

        $display("");
        $display("============================================");
        $display("  FPGA Calculator Testbench (Nexys A7)");
        $display("============================================");

        //==============================================================
        //  ADDITION  op_sel = 00
        //==============================================================
        $display("\n--- ADDITION (op_sel=00) ---");
        //               a     b  op     exp_res  neg div0 ovf label
        check(4'd0,  4'd0,  2'b00, 8'h00, 1'b0, 1'b0, 1'b0, "ADD 0+0 ");
        check(4'd5,  4'd3,  2'b00, 8'h08, 1'b0, 1'b0, 1'b0, "ADD 5+3 ");
        check(4'd9,  4'd7,  2'b00, 8'h10, 1'b0, 1'b0, 1'b0, "ADD 9+7 ");
        check(4'd15, 4'd15, 2'b00, 8'h1E, 1'b0, 1'b0, 1'b0, "ADD 15+15");
        check(4'd1,  4'd0,  2'b00, 8'h01, 1'b0, 1'b0, 1'b0, "ADD 1+0 ");

        //==============================================================
        //  SUBTRACTION  op_sel = 01
        //==============================================================
        $display("\n--- SUBTRACTION (op_sel=01) ---");
        // Positive results
        check(4'd7,  4'd3,  2'b01, 8'h04, 1'b0, 1'b0, 1'b0, "SUB 7-3 ");
        check(4'd15, 4'd15, 2'b01, 8'h00, 1'b0, 1'b0, 1'b0, "SUB 15-15");
        check(4'd5,  4'd0,  2'b01, 8'h05, 1'b0, 1'b0, 1'b0, "SUB 5-0 ");
        // Negative results — result is 2's complement, neg_flag=1
        // 0-1 = -1  =>  8-bit 2's comp = 0xFF = 255
        check(4'd0,  4'd1,  2'b01, 8'hFF, 1'b1, 1'b0, 1'b0, "SUB 0-1 ");
        // 3-7 = -4  =>  2's comp = 0xFC = 252
        check(4'd3,  4'd7,  2'b01, 8'hFC, 1'b1, 1'b0, 1'b0, "SUB 3-7 ");
        // 1-15 = -14 => 2's comp = 0xF2 = 242
        check(4'd1,  4'd15, 2'b01, 8'hF2, 1'b1, 1'b0, 1'b0, "SUB 1-15");

        //==============================================================
        //  MULTIPLICATION  op_sel = 10
        //==============================================================
        $display("\n--- MULTIPLICATION (op_sel=10) ---");
        check(4'd0,  4'd5,  2'b10, 8'h00, 1'b0, 1'b0, 1'b0, "MUL 0*5 ");
        check(4'd1,  4'd1,  2'b10, 8'h01, 1'b0, 1'b0, 1'b0, "MUL 1*1 ");
        check(4'd3,  4'd4,  2'b10, 8'h0C, 1'b0, 1'b0, 1'b0, "MUL 3*4 ");
        check(4'd7,  4'd8,  2'b10, 8'h38, 1'b0, 1'b0, 1'b0, "MUL 7*8 ");
        check(4'd15, 4'd15, 2'b10, 8'hE1, 1'b0, 1'b0, 1'b0, "MUL 15*15");  // 225=0xE1

        //==============================================================
        //  DIVISION  op_sel = 11
        // result = integer quotient; dec_digit hidden inside LED[10]
        // We check the result register (quotient) and the div0 flag.
        //==============================================================
        $display("\n--- DIVISION (op_sel=11) ---");
        check(4'd10, 4'd2,  2'b11, 8'h05, 1'b0, 1'b0, 1'b0, "DIV 10/2 "); // 5.0
        check(4'd7,  4'd2,  2'b11, 8'h03, 1'b0, 1'b0, 1'b0, "DIV 7/2  "); // 3.5
        check(4'd1,  4'd3,  2'b11, 8'h00, 1'b0, 1'b0, 1'b0, "DIV 1/3  "); // 0.3
        check(4'd0,  4'd5,  2'b11, 8'h00, 1'b0, 1'b0, 1'b0, "DIV 0/5  "); // 0.0
        check(4'd15, 4'd1,  2'b11, 8'h0F, 1'b0, 1'b0, 1'b0, "DIV 15/1 "); // 15.0
        check(4'd14, 4'd3,  2'b11, 8'h04, 1'b0, 1'b0, 1'b0, "DIV 14/3 "); // 4.6
        // Divide by zero
        check(4'd5,  4'd0,  2'b11, 8'h00, 1'b0, 1'b1, 1'b0, "DIV 5/0  "); // Err
        check(4'd0,  4'd0,  2'b11, 8'h00, 1'b0, 1'b1, 1'b0, "DIV 0/0  "); // Err

        //==============================================================
        //  RESET test — hold reset, all LEDs should clear
        //==============================================================
        $display("\n--- RESET test ---");
        sw = 16'hFFFF;                    // Set all switches
        repeat(3) @(posedge clk);
        rst_in = 1'b1;
        repeat(3) @(posedge clk); #1;
        if (led === 16'h0000) begin
            $display("  PASS  RESET  led=0x0000 during reset");
            pass_count = pass_count + 1;
        end else begin
            $display("  FAIL  RESET  expected led=0x0000 got 0x%04X", led);
            fail_count = fail_count + 1;
        end
        rst_in = 1'b0;

        //==============================================================
        //  Summary
        //==============================================================
        $display("");
        $display("============================================");
        $display("  Results: %0d PASS  /  %0d FAIL", pass_count, fail_count);
        $display("============================================");
        $display("");

        if (fail_count == 0)
            $display("  *** ALL TESTS PASSED ***");
        else
            $display("  *** %0d TEST(S) FAILED ***", fail_count);

        $display("");
        #100;
        $finish;
    end

    // Watchdog
    initial begin
        #5_000_000;
        $display("WATCHDOG TIMEOUT – simulation hung!");
        $finish;
    end

endmodule
