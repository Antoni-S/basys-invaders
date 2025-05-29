/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Tomasz Sieja
 *
 * Description:
 * Vga timing controller.
 */

module vga_timing (
    input  logic clk,       // 65 MHz clock
    input  logic rst,
    vga_if.out vga_out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    /**
     * Local variables and signals
     */

    logic [10:0] hcount1, vcount1;
    logic hblnk1, hsync1, vblnk1, vsync1;                   

    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin : timing_ff_blk
        if (rst) begin
            vga_out.hcount <= '0;
            vga_out.vcount <= '0;
            vga_out.hsync  <= '0;
            vga_out.vsync  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.rgb    <= '0;
        end else begin
            vga_out.hcount <= hcount1;
            vga_out.vcount <= vcount1;
            vga_out.hsync  <= hsync1;
            vga_out.vsync  <= vsync1;
            vga_out.hblnk  <= hblnk1;
            vga_out.vblnk  <= vblnk1;
            vga_out.rgb    <= vga_out.rgb;
        end
    end

    always_comb begin : timing_comb_blk
    hcount1 = vga_out.hcount;
    vcount1 = vga_out.vcount;

    if (vga_out.hcount == TOTAL_HOR_PIXELS - 1) begin
        hcount1 = 0;
    end else begin
        hcount1 = vga_out.hcount + 1;
    end

    if (vga_out.hcount == TOTAL_HOR_PIXELS - 2) begin
        if (vga_out.vcount == TOTAL_VER_PIXELS + 2) begin
            vcount1 = 0;
        end else begin
            vcount1 = vga_out.vcount + 1;
        end
    end

    hblnk1 = (vga_out.hcount >= HBLNK_START - 1) && (vga_out.hcount < HBLNK_END - 1);
    hsync1 = (vga_out.hcount >= H_SYNC_START - 1) && (vga_out.hcount < H_SYNC_END - 1);
    vblnk1 = (vga_out.vcount >= VBLNK_START) && (vga_out.vcount < VBLNK_END);
    vsync1 = (vga_out.vcount >= V_SYNC_START) && (vga_out.vcount < V_SYNC_END);
end


endmodule