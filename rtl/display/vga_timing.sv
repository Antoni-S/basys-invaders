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

    output logic [10:0] hcount,
    output logic [10:0] vcount,
    output logic        hblnk,
    output logic        vblnk,
    output logic        hsync,
    output logic        vsync
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
            hcount <= '0;
            vcount <= '0;
            hsync  <= '0;
            vsync  <= '0;
            hblnk  <= '0;
            vblnk  <= '0;
        end else begin
            hcount <= hcount1;
            vcount <= vcount1;
            hsync  <= hsync1;
            vsync  <= vsync1;
            hblnk  <= hblnk1;
            vblnk  <= vblnk1;
        end
    end

    always_comb begin : timing_comb_blk
    hcount1 = hcount;
    vcount1 = vcount;

    if (hcount == TOTAL_HOR_PIXELS - 1) begin
        hcount1 = 0;
    end else begin
        hcount1 = hcount + 1;
    end

    if (hcount == TOTAL_HOR_PIXELS - 2) begin
        if (vcount == TOTAL_VER_PIXELS + 2) begin
            vcount1 = 0;
        end else begin
            vcount1 = vcount + 1;
        end
    end

    hblnk1 = (hcount >= HBLNK_START - 1) && (hcount < HBLNK_END - 1);
    hsync1 = (hcount >= H_SYNC_START - 1) && (hcount < H_SYNC_END - 1);
    vblnk1 = (vcount >= VBLNK_START) && (vcount < VBLNK_END);
    vsync1 = (vcount >= V_SYNC_START) && (vcount < V_SYNC_END);
end


endmodule