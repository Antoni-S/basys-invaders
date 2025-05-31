/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Robert Szczygiel
 * Modified: Piotr Kaczmarczyk
 * Modified: Tomasz Sieja
 *
 * Description:
 * This is the ROM for the 'invader_*.png' image.
 * The image size is 64 x 32 pixels.
 * The input 'address' is a 12-bit number, composed of the concatenated
 * 6-bit y and 6-bit x pixel coordinates.
 * The output 'rgb' is 12-bit number with concatenated
 * red, green and blue color values (4-bit each)
 */

module invader_2_rom (
        input  logic clk ,
        input  logic [11:0] address,  // address = {addry[5:0], addrx[5:0]}
        output logic [11:0] rgb
    );

	(* rom_style = "block" *) // block || distributed

	logic [11:0] rom [0:4095]; // rom memory

	initial
		$readmemh("../../rtl/invaders/invader_2.dat", rom);

	always_ff @(posedge clk)
        rgb <= rom[address];

endmodule