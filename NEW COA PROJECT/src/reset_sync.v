//=============================================================================
// Module : reset_sync
// Desc   : Two-flop synchronizer for asynchronous reset input.
//          Asserts rst immediately (async), de-asserts synchronously
//          after two clean clock cycles to avoid metastability.
//=============================================================================
module reset_sync (
    input  clk,
    input  rst_in,   // Asynchronous raw reset (active HIGH)
    output reg rst   // Synchronized reset (active HIGH)
);
    reg rst_meta;    // First synchronizer stage

    always @(posedge clk or posedge rst_in) begin
        if (rst_in) begin
            rst_meta <= 1'b1;
            rst      <= 1'b1;
        end else begin
            rst_meta <= 1'b0;
            rst      <= rst_meta;
        end
    end

endmodule
