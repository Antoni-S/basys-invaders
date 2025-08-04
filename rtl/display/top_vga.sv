/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * The project top module.
 */
 
module top_vga (
        input  logic clk100MHz,
        input  logic clk65MHz,
        input  logic rst,
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
    * Local variables and signals
    */

    // Interface
    vga_if tim_to_bg();
    vga_if bg_to_output();

    /**
    * Signals assignments
    */

    assign vs = bg_to_output.vsync;
    assign hs = bg_to_output.hsync;
    assign {r,g,b} = bg_to_output.rgb;

    /**
    * Submodules instances
    */

    vga_timing u_vga_timing (
        .clk(clk65MHz),
        .rst(rst),
        .vga_out(tim_to_bg.out)
    );

    draw_bg u_draw_bg (
        .clk(clk65MHz),
        .rst(rst),
        .vga_in(tim_to_bg.in),
        .vga_out(bg_to_output.out)
    );

endmodule
