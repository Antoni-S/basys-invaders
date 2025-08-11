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
        input  logic clk, //65MHz clock
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

	import vga_pkg::*;

    /**
    * Local variables and signals
    */
	//Local parameters
	localparam SPRITE_WIDTH = 64;
	localparam SPRITE_HEIGHT = 64;

    // VGA interface
    vga_if vga_timing_if();
    vga_if vga_bg_if();
    vga_if vga_player_if();

    //Wires
    wire [11:0] player_addr, player_rgb, player_xpos;
	wire [11:0] player_ypos = VER_PIXELS - SPRITE_HEIGHT;
	wire [15:0] ps2_keycode;
	wire buttonL, buttonR;

    /**
    * Signals assignments
    */

    assign vs = vga_player_if.vsync;
    assign hs = vga_player_if.hsync;
    assign {r,g,b} = vga_player_if.rgb;

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
		.button_left(buttonL),
		.button_right(buttonR)
	);

    vga_timing u_vga_timing (
        .clk,
        .rst,
        .vga_out (vga_timing_if.out)
    );

    draw_bg u_draw_bg (
        .clk,
        .rst,
        .vga_in  (vga_timing_if.in),
        .vga_out (vga_bg_if.out)
    );

    player_ctl #(
		.PLAYER_WIDTH(SPRITE_WIDTH)
	) u_player_ctl (
        .clk,
        .rst,
        .button_left  (buttonL),
        .button_right (buttonR),
        .xpos         (player_xpos)
    );

    draw_rect #(
		.RECT_WIDTH(SPRITE_WIDTH),
		.RECT_HEIGHT(SPRITE_HEIGHT)
	) u_player_rect (
        .clk,
        .rst,
        .draw_in    (vga_bg_if.in),
        .draw_out   (vga_player_if.out),
        .rgb_pixel  (player_rgb),
        .pixel_addr (player_addr),
        .xpos       (player_xpos),
        .ypos       (player_ypos)
    );

    image_rom #("../../rtl/misc/spaceship1.dat")
    u_player_rom (
        .clk,
        .address (player_addr),
        .rgb     (player_rgb)
    );

endmodule
