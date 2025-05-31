/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
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
     * Local parameters
     */
    localparam NUM_INVADERS = 10;
    localparam OFFSET = 100;

    /**
    * Local variables and signals
    */
    
    wire[11:0] image_addr_row1, image_rgb_row1;
    wire[11:0] image_addr_row2, image_rgb_row2;
    wire[11:0] image_addr_row3, image_rgb_row3;

    wire[9:0]  xpos, ypos;
    wire[NUM_INVADERS-1:0]  collision1, collision2, collision3;

    // Interface
    vga_if tim_to_bg();
    vga_if bg_to_invader_row1();
    vga_if invader_row1_to_invader_row2();
    vga_if invader_row2_to_invader_row3();
    vga_if invader_row3_to_output();

    /**
    * Signals assignments
    */

    assign collision1 = 10'b11_1011_1111;
    assign collision2 = 10'b01_1111_1111;
    assign collision3 = 10'b11_1111_1011;

    assign vs = invader_row3_to_output.vsync;
    assign hs = invader_row3_to_output.hsync;
    assign {r,g,b} = invader_row3_to_output.rgb;

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
        .vga_out(bg_to_invader_row1.out)
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
        .clk65MHz(clk65MHz),
        .rst(rst),

        .vga_in(bg_to_invader_row1.in),
        .vga_out(invader_row1_to_invader_row2.out),

        .xpos(xpos),
        .ypos(ypos),
        
        .invader_enable(collision1),
        .pixel_addr(image_addr_row1),
        .rgb_pixel(image_rgb_row1)
    );

    invader_1_rom u_invader_1_rom (
        .clk(clk65MHz),

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
        .clk65MHz(clk65MHz),
        .rst(rst),

        .vga_in(invader_row1_to_invader_row2.in),
        .vga_out(invader_row2_to_invader_row3.out),

        .xpos(xpos),
        .ypos(ypos),
        
        .invader_enable(collision2),
        .pixel_addr(image_addr_row2),
        .rgb_pixel(image_rgb_row2)
    );

    invader_2_rom u_invader_2_rom (
        .clk(clk65MHz),

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
        .clk65MHz(clk65MHz),
        .rst(rst),

        .vga_in(invader_row2_to_invader_row3.in),
        .vga_out(invader_row3_to_output.out),

        .xpos(xpos),
        .ypos(ypos),

        .invader_enable(collision3),
        .pixel_addr(image_addr_row3),
        .rgb_pixel(image_rgb_row3)
    );

    invader_3_rom u_invader_3_rom (
        .clk(clk65MHz),

        .address(image_addr_row3),
        .rgb(image_rgb_row3)
    );

    invader_move #(
        .OFFSET(OFFSET)
    ) u_invader_move (
        .clk65MHz(clk65MHz),
        .rst(rst),

        .xpos(xpos),
        .ypos(ypos)
    );

endmodule
