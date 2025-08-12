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
	localparam NUM_INVADERS = 11;
    localparam OFFSET = 100;

    // VGA interface
    vga_if vga_timing_if();
    vga_if vga_bg_if();
    vga_if vga_player_if();
	vga_if bg_to_invader_row1();
    vga_if invader_row1_to_invader_row2();
    vga_if invader_row2_to_invader_row3();
    vga_if invader_row3_to_output();

    //Wires
    wire [11:0] player_addr, player_rgb, player_xpos;
	wire [11:0] player_ypos = VER_PIXELS - SPRITE_HEIGHT;
	wire [15:0] ps2_keycode;
	wire buttonL, buttonR;

	wire[11:0] image_addr_row1, image_rgb_row1;
    wire[11:0] image_addr_row2, image_rgb_row2;
    wire[11:0] image_addr_row3, image_rgb_row3;

    wire[9:0]  xpos, ypos;
    wire[NUM_INVADERS-1:0]  collision1, collision2, collision3;

    /**
    * Signals assignments
    */
	
    assign vs = invader_row3_to_output.vsync;
    assign hs = invader_row3_to_output.hsync;
    assign {r,g,b} = invader_row3_to_output.rgb;

	assign collision1 = 10'b11_1011_1111;
	assign collision2 = 10'b01_1111_1111;
	assign collision3 = 10'b11_1111_1011;

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

    /*
     * Row 1
     */
    display_invader #(
        .X_INIT(0),
        .Y_INIT(100),
        .INVADER_HEIGHT(32),
        .INVADER_WIDTH(64),
        .NUM_INVADERS(NUM_INVADERS),
        .OFFSET(OFFSET)
    ) display_invader_row1 (
        .clk65MHz(clk),
        .rst,

        .vga_in(vga_player_if.in),
        .vga_out(invader_row1_to_invader_row2.out),

        .xpos(xpos),
        .ypos(ypos),
        
        .invader_enable(collision1),
        .pixel_addr(image_addr_row1),
        .rgb_pixel(image_rgb_row1)
    );

    image_rom #(
		"../../rtl/invaders/invader_1.dat"
	) u_invader_1_rom (
        .clk(clk),

        .address(image_addr_row1),
        .rgb(image_rgb_row1)
    );
    /*
     * Row 2
     */
    display_invader #(
        .X_INIT(0),
        .Y_INIT(200),
        .INVADER_HEIGHT(32),
        .INVADER_WIDTH(64),
        .NUM_INVADERS(NUM_INVADERS),
        .OFFSET(OFFSET)
    ) display_invader_row2 (
        .clk65MHz(clk),
        .rst(rst),

        .vga_in(invader_row1_to_invader_row2.in),
        .vga_out(invader_row2_to_invader_row3.out),

        .xpos(xpos),
        .ypos(ypos),
        
        .invader_enable(collision2),
        .pixel_addr(image_addr_row2),
        .rgb_pixel(image_rgb_row2)
    );

    image_rom #(
		"../../rtl/invaders/invader_2.dat"
	) u_invader_2_rom (
        .clk(clk),

        .address(image_addr_row2),
        .rgb(image_rgb_row2)
    );

    /*
     * Row 3
     */
    display_invader #(
        .X_INIT(0),
        .Y_INIT(300),
        .INVADER_HEIGHT(32),
        .INVADER_WIDTH(64),
        .NUM_INVADERS(NUM_INVADERS),
        .OFFSET(OFFSET)
    ) display_invader_row3 (
        .clk65MHz(clk),
        .rst(rst),

        .vga_in(invader_row2_to_invader_row3.in),
        .vga_out(invader_row3_to_output.out),

        .xpos(xpos),
        .ypos(ypos),

        .invader_enable(collision3),
        .pixel_addr(image_addr_row3),
        .rgb_pixel(image_rgb_row3)
    );

    image_rom #(
		"../../rtl/invaders/invader_3.dat"
	) u_invader_3_rom (
        .clk(clk),

        .address(image_addr_row3),
        .rgb(image_rgb_row3)
    );

    invader_move #(
        .OFFSET(OFFSET)
    ) u_invader_move (
        .clk65MHz(clk),
        .rst(rst),

        .xpos(xpos),
        .ypos(ypos)
    );

endmodule
