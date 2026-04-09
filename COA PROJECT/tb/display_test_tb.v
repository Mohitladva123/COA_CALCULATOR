`timescale 1ns/1ps

module display_test_tb;
    reg [3:0] test_digit;
    wire [7:0] seg_out;
    reg       dp;
    
    sevenseg_decoder_hex u_decoder (
        .hex(test_digit),
        .decimal_point(dp),
        .seg(seg_out)
    );
    
    initial begin
        $dumpfile("display_test.vcd");
        $dumpvars(0, display_test_tb);
        
        $display("=== 7-Segment Display Test ===");
        
        // Test all digits 0-9
        test_digit = 4'h0; dp = 1'b0; #10;
        $display("Digit 0: seg=%b", seg_out);
        
        test_digit = 4'h1; dp = 1'b0; #10;
        $display("Digit 1: seg=%b", seg_out);
        
        test_digit = 4'h2; dp = 1'b0; #10;
        $display("Digit 2: seg=%b", seg_out);
        
        test_digit = 4'h3; dp = 1'b0; #10;
        $display("Digit 3: seg=%b", seg_out);
        
        test_digit = 4'h4; dp = 1'b0; #10;
        $display("Digit 4: seg=%b", seg_out);
        
        test_digit = 4'h5; dp = 1'b0; #10;
        $display("Digit 5: seg=%b", seg_out);
        
        test_digit = 4'h6; dp = 1'b0; #10;
        $display("Digit 6: seg=%b", seg_out);
        
        test_digit = 4'h7; dp = 1'b0; #10;
        $display("Digit 7: seg=%b", seg_out);
        
        test_digit = 4'h8; dp = 1'b0; #10;
        $display("Digit 8: seg=%b", seg_out);
        
        test_digit = 4'h9; dp = 1'b0; #10;
        $display("Digit 9: seg=%b", seg_out);
        
        // Test decimal point
        test_digit = 4'h8; dp = 1'b1; #10;
        $display("Digit 8 with DP: seg=%b", seg_out);
        
        $finish;
    end
endmodule
