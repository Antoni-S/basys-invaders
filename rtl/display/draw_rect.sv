

module draw_rect #(
	parameter RECT_WIDTH = 32,
	parameter RECT_HEIGHT = 32
)
(
    input   logic     clk,
    input   logic     rst,
    input   logic    [11:0]  xpos,
    input   logic    [11:0]  ypos,
    input   logic    [11:0]  rgb_pixel,
    
    output  logic    [11:0]  pixel_addr,
    vga_if.in     draw_in,
    vga_if.out    draw_out
);


timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

/**
 * Local variables and signals
 */

localparam ANIMATION_FRAME = 0;

/**
 * Internal logic
 */

vga_if draw_delay();

delay #(
    .WIDTH (38),
    .CLK_DEL(1)
) u_delay (
    .clk  (clk),
    .rst  (rst),
    .din  ({draw_in.hcount, draw_in.hsync, draw_in.hblnk, draw_in.vcount, draw_in.vsync, draw_in.vblnk, draw_in.rgb}),
    .dout ({draw_delay.hcount, draw_delay.hsync, draw_delay.hblnk, draw_delay.vcount, draw_delay.vsync, draw_delay.vblnk, draw_delay.rgb})
);

logic [11:0] rgb_nxt;

always_ff @(posedge clk) begin
    if(rst) begin
        draw_out.hcount <= 0;
        draw_out.hsync <= 0;
        draw_out.hblnk <= 0;
        draw_out.vcount <= 0;
        draw_out.vsync <= 0;
        draw_out.vblnk <= 0;
        draw_out.rgb <= 0;
    end else begin
        draw_out.hcount <= draw_delay.hcount;
        draw_out.hsync <= draw_delay.hsync;
        draw_out.hblnk <= draw_delay.hblnk;
        draw_out.vcount <= draw_delay.vcount;
        draw_out.vsync <= draw_delay.vsync;
        draw_out.vblnk <= draw_delay.vblnk;
        draw_out.rgb <= rgb_nxt;
    end
end

assign pixel_addr = (draw_in.vcount-ypos) * RECT_WIDTH + (draw_in.hcount - xpos);// + (RECT_WIDTH * ANIMATION_FRAME);
// To get the proper image scale from the tilesheet you need to pass the amount of sprites in the sheet times sprite height
// For animation, to get the frame you want, pass the frame no. (indexing from 0) times sprite width



always_comb begin : rect_comb_blk
        if(draw_delay.hcount >= xpos && draw_delay.hcount < xpos + RECT_WIDTH &&
           draw_delay.vcount >= ypos && draw_delay.vcount < ypos + RECT_HEIGHT)
			if(rgb_pixel == 12'h0_0_0) rgb_nxt = draw_delay.rgb;
			else rgb_nxt = rgb_pixel;
        else
            rgb_nxt = draw_delay.rgb;
end

endmodule