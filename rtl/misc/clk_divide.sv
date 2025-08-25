//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   clk_divide
 Author:        Antoni Sus
 Version:       1.0
 Last modified: 2025-08-25
 Coding style: safe with FPGA sync reset
 Description:  Simple clock divider
 */
//////////////////////////////////////////////////////////////////////////////
module clk_divide #(
    parameter CYCLES = 650000
) (
    input logic clk,
    input logic rst,

    output logic clk_delayed
);
//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

logic [31:0] delay_counter;

//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        delay_counter <= 0;
        clk_delayed <= 0;
    end else begin
        if (delay_counter >= CYCLES) begin
            delay_counter <= 0;
            clk_delayed <= 1;
        end else begin
            delay_counter <= delay_counter + 1;
            clk_delayed <= 0;
        end
    end
end

endmodule