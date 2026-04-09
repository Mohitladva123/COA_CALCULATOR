`timescale 1ns/1ps

module reset_sync (
    input  wire clk,
    input  wire rst_in,
    output wire rst
);
    reg [1:0] sync_ff = 2'b11;

    always @(posedge clk or posedge rst_in) begin
        if (rst_in) begin
            sync_ff <= 2'b11;
        end else begin
            sync_ff <= {sync_ff[0], 1'b0};
        end
    end

    assign rst = sync_ff[1];
endmodule
