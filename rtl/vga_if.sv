/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Tomasz Sieja
 *
 * Description:
 * Interafce defines VGA timing and data signals.
 */

 interface vga_if;
    logic [10:0] vcount;
    logic        vsync;
    logic        vblnk;
    logic [10:0] hcount;
    logic        hsync;
    logic        hblnk;
    logic [11:0] rgb;

    modport in (
        input vcount, vsync, vblnk, hcount, hsync, hblnk, rgb
    );

    modport out (
        output vcount, vsync, vblnk, hcount, hsync, hblnk, rgb
    );
endinterface