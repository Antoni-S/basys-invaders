/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Tomasz Sieja
 *
 * Description:
 * Display invaders in a row with spacing.
 */

module display_invader #(
    parameter X_INIT = 200,
    parameter Y_INIT = 100,
    parameter INVADER_HEIGHT = 48,
    parameter INVADER_WIDTH = 64,
    parameter NUM_INVADERS = 10,
    parameter OFFSET = 100
) (
    input logic clk65MHz,
    input logic rst,

    vga_if.in vga_in,
    vga_if.out vga_out,

    input logic  [11:0] rgb_pixel,
    input logic  [NUM_INVADERS -1:0]  invader_enable,
    input logic  [9:0]  xpos,
    input logic  [9:0]  ypos,

    output logic [11:0] pixel_addr
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    /**
     * Local parameters
     */
    localparam SPACING = ((HOR_PIXELS - OFFSET) - (NUM_INVADERS * INVADER_WIDTH)) / (NUM_INVADERS - 1);
    
    /**
     * Local variables and signals
     */
	vga_if vga_d();

	logic [11:0] rgb_nxt;

    logic [5:0] rel_x, rel_y;

    logic invader_active;

	logic [NUM_INVADERS-1:0] invader_x_positions[NUM_INVADERS];
    /**
     * Delays
     */
    delay #(
        .WIDTH (38),
        .CLK_DEL(2)
    ) u_delay (
        .clk (clk65MHz),
        .rst (rst),
        .din ({vga_in.hcount, vga_in.hsync, vga_in.vcount, vga_in.vsync, vga_in.hblnk, vga_in.vblnk, vga_in.rgb}),
        .dout ({vga_d.hcount, vga_d.hsync, vga_d.vcount, vga_d.vsync, vga_d.hblnk, vga_d.vblnk, vga_d.rgb})
    );

    /**
     * Internal logic
     */
    always_ff @(posedge clk65MHz) begin : display_ff_blk
        if (rst) begin
            vga_out.vcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.hcount <= '0;
            vga_out.hsync  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0;
        end else begin
            vga_out.hcount <= vga_d.hcount;
            vga_out.vcount <= vga_d.vcount;
            vga_out.hsync  <= vga_d.hsync;
            vga_out.vsync  <= vga_d.vsync;
            vga_out.hblnk  <= vga_d.hblnk;
            vga_out.vblnk  <= vga_d.vblnk;
            vga_out.rgb    <= rgb_nxt;
        end
    end

	always_comb begin : invader_positions
        for (int i = 0; i < NUM_INVADERS; i++) begin
            invader_x_positions[i] = X_INIT + xpos + i * (INVADER_WIDTH + SPACING);
        end
    end

    // Calculate which invader is being displayed
    always_comb begin : invaders_display
        invader_active = '0;
        pixel_addr = '0;
        
        for (int currentInvader = 0; currentInvader < NUM_INVADERS; currentInvader++) begin
            if (invader_enable[currentInvader]) begin
            automatic int currentX = invader_x_positions[currentInvader];
            automatic int currentY = Y_INIT + ypos;

                if ((vga_d.hcount >= currentX) && (vga_d.hcount < currentX + INVADER_WIDTH) &&
                    (vga_d.vcount >= currentY) && (vga_d.vcount < currentY + INVADER_HEIGHT)) begin
                    invader_active = 1;

                    rel_x = vga_d.hcount - currentX;
                    rel_y = vga_d.vcount - currentY;
                    pixel_addr = {rel_y[5:0], rel_x[5:0]};
					break;
                end
            end
        end
    end

    always_comb begin : output_comb_blk
        if (vga_d.vblnk || vga_d.hblnk) begin
            rgb_nxt = vga_d.rgb;
        end
        else if (invader_active) begin
            if(rgb_pixel == 12'h0_0_0) rgb_nxt = vga_d.rgb;
			else rgb_nxt = rgb_pixel;
        end
        else begin
            rgb_nxt = vga_d.rgb;
        end
    end
    
endmodule