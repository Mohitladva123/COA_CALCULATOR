`timescale 1ns/1ps

module clock_divider #(
    parameter integer DIVISOR = 100000
) (
    input  wire clk,
    input  wire rst,
    output reg  tick
);
    localparam integer CNT_W = 17;
    reg [CNT_W-1:0] cnt = {CNT_W{1'b0}};

    always @(posedge clk) begin
        if (rst) begin
            cnt  <= {CNT_W{1'b0}};
            tick <= 1'b0;
        end else if (cnt == (DIVISOR - 1)) begin
            cnt  <= {CNT_W{1'b0}};
            tick <= 1'b1;
        end else begin
            cnt  <= cnt + 1'b1;
            tick <= 1'b0;
        end
    end
endmodule
