/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Tomasz Sieja
 *
 * Description:
 * Package with vga related constants.
 */

package vga_pkg;

    // Parameters for VGA Display 1024 x 768 @ 60fps using a 65 MHz clock;
    localparam HOR_PIXELS = 1024;
    localparam VER_PIXELS = 768;

    localparam TOTAL_HOR_PIXELS = 1344;
    localparam TOTAL_VER_PIXELS = 806;

    localparam HBLNK_START = 1024;
    localparam HBLNK_END = 1344;

    localparam VBLNK_START = 768;
    localparam VBLNK_END = 806;

    localparam H_SYNC_WIDTH  = 136;
    localparam V_SYNC_WIDTH  = 6;

    localparam H_SYNC_START = 1024 + 24;
    localparam H_SYNC_END   = H_SYNC_START + H_SYNC_WIDTH;

    localparam V_SYNC_START = 768 + 3;
    localparam V_SYNC_END   = V_SYNC_START + V_SYNC_WIDTH;

    // Add VGA timing parameters here and refer to them in other modules.

endpackage
