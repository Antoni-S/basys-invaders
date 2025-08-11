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
    logic [11:0] rgb_nxt, rgb_d;
    logic [10:0] hcount_d, vcount_d;
    logic hsync_d, vsync_d, hblnk_d, vblnk_d;

    logic [5:0] rel_x, rel_y;

    logic invader_active;

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
        .dout ({hcount_d, hsync_d, vcount_d, vsync_d, hblnk_d, vblnk_d, rgb_d})
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
            vga_out.hcount <= hcount_d;
            vga_out.vcount <= vcount_d;
            vga_out.hsync  <= hsync_d;
            vga_out.vsync  <= vsync_d;
            vga_out.hblnk  <= hblnk_d;
            vga_out.vblnk  <= vblnk_d;
            vga_out.rgb    <= rgb_nxt;
        end
    end

    // Calculate which invader is being displayed
    always_comb begin : invaders_display
        invader_active = 0;
        pixel_addr = '0;
        
        for (int currentInvader = 0; currentInvader < NUM_INVADERS; currentInvader++) begin
            if (invader_enable[currentInvader]) begin
            automatic int currentX = X_INIT + xpos + currentInvader * (INVADER_WIDTH + SPACING);
            automatic int currentY = Y_INIT + ypos;

                if ((hcount_d >= currentX) && (hcount_d < currentX + INVADER_WIDTH) &&
                    (vcount_d >= currentY) && (vcount_d < currentY + INVADER_HEIGHT)) begin
                    invader_active = 1;

                    rel_x = hcount_d - currentX;
                    rel_y = vcount_d - currentY;
                    pixel_addr = {rel_y[5:0], rel_x[5:0]};
                end
            end
        end
    end

    always_comb begin : output_comb_blk
        if (vblnk_d || hblnk_d) begin
            rgb_nxt = rgb_d;
        end
        else if (invader_active) begin
            if(rgb_pixel == 12'h0_0_0) rgb_nxt = rgb_d;
			else rgb_nxt = rgb_pixel;
        end
        else begin
            rgb_nxt = rgb_d;
        end
    end
    
endmodule