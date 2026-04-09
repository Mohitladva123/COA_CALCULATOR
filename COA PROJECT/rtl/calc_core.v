`timescale 1ns/1ps

module calc_core (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [1:0] op_sel,
    output reg  [7:0] result,
    output reg        valid,
    output reg        div_by_zero,
    output reg        overflow
);
    reg [4:0] add_tmp;
    reg signed [4:0] sub_tmp;

    always @(*) begin
        result      = 8'h00;
        valid       = 1'b1;
        div_by_zero = 1'b0;
        overflow    = 1'b0;
        add_tmp     = 5'h00;
        sub_tmp     = 5'sh00;

        case (op_sel)
            2'b00: begin
                add_tmp   = {1'b0, a} + {1'b0, b};
                result    = {3'b000, add_tmp};
                overflow  = add_tmp[4];
            end

            2'b01: begin
                // Compute subtraction using 2's complement arithmetic (wrap-around)
                sub_tmp = $signed({1'b0, a}) - $signed({1'b0, b});
                // Output the 2's complement result directly (no absolute conversion)
                result = {3'b000, sub_tmp[3:0]};
            end

            2'b10: begin
                result = a * b;
            end

            2'b11: begin
                if (b == 4'b0000) begin
                    result      = 8'h00;
                    valid       = 1'b0;
                    div_by_zero = 1'b1;
                end else begin
                    // Fixed-point division with rounding: (a * 10 + b/2) / b
                    result = (a * 8'd10 + (b >> 1)) / b;
                end
            end

            default: begin
                result      = 8'h00;
                valid       = 1'b0;
                div_by_zero = 1'b0;
                overflow    = 1'b0;
            end
        endcase
    end
endmodule
