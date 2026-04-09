`timescale 1ns/1ps

module switch_sync #(
    parameter integer WIDTH = 16
) (
    input  wire             clk,
    input  wire             rst,
    input  wire [WIDTH-1:0] sw_in,
    output wire [WIDTH-1:0] sw_out
);
    reg [WIDTH-1:0] ff1 = {WIDTH{1'b0}};
    reg [WIDTH-1:0] ff2 = {WIDTH{1'b0}};

    always @(posedge clk) begin
        if (rst) begin
            ff1 <= {WIDTH{1'b0}};
            ff2 <= {WIDTH{1'b0}};
        end else begin
            ff1 <= sw_in;
            ff2 <= ff1;
        end
    end

    assign sw_out = ff2;
endmodule