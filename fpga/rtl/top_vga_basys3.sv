/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 * Modified: Tomasz Sieja
 *
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

module top_vga_basys3 (
        input  wire clk,
        input  wire btnC,
        output wire Vsync,
        output wire Hsync,
        output wire [3:0] vgaRed,
        output wire [3:0] vgaGreen,
        output wire [3:0] vgaBlue,
        output wire JA1,
		inout  wire PS2Clk,
		inout  wire PS2Data
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    wire clk100MHz;
    wire clk65MHz;
    wire clk65MHz_mirror;
    wire locked;

    /**
     * Signals assignments
     */

    assign JA1 = clk65MHz_mirror;


    /**
     * FPGA submodules placement
     */

    clk_wiz_0_clk_wiz inst(
        // Clock out ports  
        .clk100MHz(clk100MHz),
        .clk65MHz(clk65MHz),
        // Status and control signals               
        .locked(locked),
        // Clock in ports
        .clk(clk)
    );

    // Mirror clk65MHz on a pin for use by the testbench;
    // not functionally required for this design to work.

    ODDR clk65MHz_oddr (
        .Q(clk65MHz_mirror),
        .C(clk65MHz),
        .CE(1'b1),
        .D1(1'b1),
        .D2(1'b0),
        .R(1'b0),
        .S(1'b0)
    );


    /**
     *  Project functional top module
     */

    top_vga u_top_vga (
        .clk100MHz(clk100MHz),
        .clk(clk65MHz),
        .rst(btnC),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync),
		.PS2Clk(PS2Clk),
		.PS2Data(PS2Data)
    );

endmodule
