/**
 *  Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for vga_timing module.
 */

module vga_timing_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    vga_if timing_if();


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 15;     // 65 MHz


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst;

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
    .vga_out(timing_if)
);

    /**
     * Tasks and functions
     */

    // Here you can declare tasks with immediate assertions (assert).


    /**
     * Assertions
     */

    property hblnk_property;
        @(posedge clk) (timing_if.hcount >= HBLNK_START - 1) && (timing_if.hcount < HBLNK_END - 1) |=> (timing_if.hblnk == 1);
    endproperty

    property vblnk_property;
        @(posedge clk) (timing_if.vcount >= VBLNK_START) && (timing_if.vcount < VBLNK_END) |=> (timing_if.vblnk == 1);
    endproperty

    property hsync_property;
        @(posedge clk) (timing_if.hcount >= H_SYNC_START - 1) && (timing_if.hcount < H_SYNC_END - 1) |=> (timing_if.hsync == 1);
    endproperty

    property vsync_property;
        @(posedge clk) (timing_if.vcount >= V_SYNC_START) && (timing_if.vcount < V_SYNC_END) |=> (timing_if.vsync == 1);
    endproperty

    assert property (hblnk_property) else $error("HBLANK FAIL: hcount=%d", timing_if.hcount);
    assert property (vblnk_property) else $error("VBLANK FAIL: vcount=%d", timing_if.vcount);
    assert property (hsync_property) else $error("HSYNC FAIL: hcount=%d", timing_if.hcount);
    assert property (vsync_property) else $error("VSYNC FAIL: vcount=%d", timing_if.vcount);



    /**
     * Main test
     */

    initial begin
        @(posedge rst);
        @(negedge rst);

        wait (timing_if.vsync == 1'b0);
        @(negedge timing_if.vsync);
        @(negedge timing_if.vsync);

        $finish;
    end

endmodule