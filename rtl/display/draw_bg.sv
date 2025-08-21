/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */

module draw_bg (
        input logic clk,
        input logic rst,
        input logic [10:0] hcount,
        input logic [10:0] vcount,
        input logic        hblnk,
        input logic        vblnk,
        input logic        hsync,
        input logic        vsync,

        vga_if.out vga_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;


    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : bg_ff_blk
        if (rst) begin
            vga_out.vcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.hcount <= '0;
            vga_out.hsync  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0;
        end else begin
            vga_out.vcount <= vcount;
            vga_out.vsync  <= vsync;
            vga_out.vblnk  <= vblnk;
            vga_out.hcount <= hcount;
            vga_out.hsync  <= hsync;
            vga_out.hblnk  <= hblnk;
            vga_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : bg_comb_blk
        if (vblnk || hblnk) begin
            rgb_nxt = 12'h0_0_0;
        end else begin
            rgb_nxt = 12'h0_0_f;
        end
   end


endmodule
