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
        input  logic btnL,
        input  logic btnR,
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

    // VGA interface
    vga_if vga_timing_if();
    vga_if vga_bg_if();
    vga_if vga_player_if();

    //Wires
    wire [11:0] player_addr, player_rgb, player_xpos, player_ypos;
    reg db_L;
	reg db_R;

    /**
    * Signals assignments
    */

    assign vs = vga_player_if.vsync;
    assign hs = vga_player_if.hsync;
    assign {r,g,b} = vga_player_if.rgb;

    /**
    * Submodules instances
    */
    debouncer u_debounceL (
        .clk,
        .I (btnL),
        .O (db_L)
    );

    debouncer u_debounceR (
        .clk,
        .I (btnR),
        .O (db_R)
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

    player_ctl u_player_ctl (
        .clk,
        .rst,
        .button_left  (db_L),
        .button_right (db_R),
        .xpos         (player_xpos),
        .ypos         (player_ypos)
    );

    draw_rect u_player_rect (
        .clk,
        .rst,
        .draw_in    (vga_bg_if.in),
        .draw_out   (vga_player_if.out),
        .rgb_pixel  (player_rgb),
        .pixel_addr (player_addr),
        .xpos       (player_xpos),
        .ypos       (player_ypos)
    );

    image_rom #("../../rtl/misc/tilesheet.dat")
    u_player_rom (
        .clk,
        .address (player_addr),
        .rgb     (player_rgb)
    );

endmodule
