/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Sus
 *
 * Description:
 * Simple clock divider
 */
module clk_divide #(
    parameter CYCLES = 650000
) (
    input logic clk,
    input logic rst,

    output logic clk_delayed
);

logic [31:0] delay_counter;

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