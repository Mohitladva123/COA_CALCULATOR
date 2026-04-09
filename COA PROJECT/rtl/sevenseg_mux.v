`timescale 1ns/1ps

module sevenseg_mux (
    input  wire       clk,
    input  wire       rst,
    input  wire       refresh_tick,
    input  wire [3:0] digit3,
    input  wire [3:0] digit2,
    input  wire [3:0] digit1,
    input  wire [3:0] digit0,
    input  wire       decimal_point,
    output reg  [7:0] an,
    output wire [7:0] seg
);
    reg [1:0] scan_sel = 2'b00;
    reg [3:0] current_hex;
    wire      current_dp;

    // Show DP only while digit1 (AN1 active-low) is currently enabled.
    assign current_dp = decimal_point & (an == 8'b1111_1101);

    always @(posedge clk) begin
        if (rst) begin
            scan_sel <= 2'b00;
            an       <= 8'b1111_1110;
            current_hex <= digit0;
        end else if (refresh_tick) begin
            scan_sel <= scan_sel + 1'b1;

            case (scan_sel)
                2'd0: begin
                    an <= 8'b1111_1110; // digit0
                    current_hex <= digit0;
                end
                2'd1: begin
                    an <= 8'b1111_1101; // digit1
                    current_hex <= digit1;
                end
                2'd2: begin
                    an <= 8'b1111_1011; // digit2
                    current_hex <= digit2;
                end
                2'd3: begin
                    an <= 8'b1111_0111; // digit3
                    current_hex <= digit3;
                end
            endcase
        end
    end

    sevenseg_decoder_hex u_decoder (
        .hex(current_hex),
        .decimal_point(current_dp),
        .seg(seg)
    );

endmodule