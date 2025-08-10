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
        input  logic clk,
        input  logic rst,
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b,
		inout  logic PS2Clk,
		inout  logic PS2Data
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
    * Local variables and signals
    */

    // Interface
    vga_if tim_to_bg();
    vga_if bg_to_output();

	wire [15:0] ps2_keycode;
	wire btnL, btnR;

    /**
    * Signals assignments
    */

    assign vs = bg_to_output.vsync;
    assign hs = bg_to_output.hsync;
    assign {r,g,b} = bg_to_output.rgb;

    /**
    * Submodules instances
    */

	PS2Receiver u_PS2Receiver (
		.clk,
		.kclk(PS2Clk),
		.kdata(PS2Data),
		.keycode(ps2_keycode)
	);

	keyboard_ctl u_keyboard_ctl (
		.clk,
		.keycode(ps2_keycode),
		.button_left(btnL),
		.button_right(btnR)
	);

    vga_timing u_vga_timing (
        .clk,
        .rst,
        .vga_out(tim_to_bg.out)
    );

    draw_bg u_draw_bg (
        .clk,
        .rst,
        .vga_in(tim_to_bg.in),
        .vga_out(bg_to_output.out)
    );

endmodule
