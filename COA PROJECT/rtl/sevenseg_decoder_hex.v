`timescale 1ns/1ps

module sevenseg_decoder_hex (
    input  wire [3:0] hex,
    input  wire       decimal_point,
    output reg  [7:0] seg
);
    always @(*) begin
        // Active-low (0 = ON)
        // Mapping: seg[0]=a ... seg[6]=g, seg[7]=dp

        case (hex)
            4'h0: seg[6:0] = 7'b0000001; // 0
            4'h1: seg[6:0] = 7'b1001111; // 1
            4'h2: seg[6:0] = 7'b0010010; // 2
            4'h3: seg[6:0] = 7'b0000110; // 3
            4'h4: seg[6:0] = 7'b1001100; // 4
            4'h5: seg[6:0] = 7'b0100100; // 5
            4'h6: seg[6:0] = 7'b0100000; // 6
            4'h7: seg[6:0] = 7'b0001111; // 7
            4'h8: seg[6:0] = 7'b0000000; // 8
            4'h9: seg[6:0] = 7'b0000100; // 9
            default: seg[6:0] = 7'b1111111; // OFF
        endcase

        // Active-low decimal point: 0 = ON, 1 = OFF
        seg[7] = ~decimal_point;
    end
endmodule