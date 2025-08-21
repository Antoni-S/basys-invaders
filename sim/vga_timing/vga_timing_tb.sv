/**
 *  Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 * Modified: Tomasz Sieja
 *
 * Description:
 * Testbench for vga_timing module.
 */

module vga_timing_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 15;     // 65 MHz


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst;
    logic [10:0] hcount;
    logic [10:0] vcount;
    logic hblnk;
    logic vblnk;
    logic hsync;
    logic vsync;

    // wire [10:0] vcount, hcount;
    // wire        vsync,  hsync;
    // wire        vblnk,  hblnk;


    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /**
     * Reset generation
     */

    initial begin
        rst = 1'b0;
        #(1.25*CLK_PERIOD) rst = 1'b1;
        rst = 1'b1;
        #(2.00*CLK_PERIOD) rst = 1'b0;
    end


    /**
     * Dut placement
     */

    vga_timing dut (
    .clk(clk),
    .rst(rst),
    .hcount,
    .vcount,
    .hblnk,
    .vblnk,
    .hsync,
    .vsync
);

    /**
     * Tasks and functions
     */

    // Here you can declare tasks with immediate assertions (assert).


    /**
     * Assertions
     */

    property hblnk_property;
        @(posedge clk) (hcount >= HBLNK_START - 1) && (hcount < HBLNK_END - 1) |=> (hblnk == 1);
    endproperty

    property vblnk_property;
        @(posedge clk) (vcount >= VBLNK_START) && (vcount < VBLNK_END) |=> (vblnk == 1);
    endproperty

    property hsync_property;
        @(posedge clk) (hcount >= H_SYNC_START - 1) && (hcount < H_SYNC_END - 1) |=> (hsync == 1);
    endproperty

    property vsync_property;
        @(posedge clk) (vcount >= V_SYNC_START) && (vcount < V_SYNC_END) |=> (vsync == 1);
    endproperty

    assert property (hblnk_property) else $error("HBLANK FAIL: hcount=%d", hcount);
    assert property (vblnk_property) else $error("VBLANK FAIL: vcount=%d", vcount);
    assert property (hsync_property) else $error("HSYNC FAIL: hcount=%d", hcount);
    assert property (vsync_property) else $error("VSYNC FAIL: vcount=%d", vcount);



    /**
     * Main test
     */

    initial begin
        @(posedge rst);
        @(negedge rst);

        wait (vsync == 1'b0);
        @(negedge vsync);
        @(negedge vsync);

        $finish;
    end

endmodule