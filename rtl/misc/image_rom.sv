/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Robert Szczygiel
 * Modified: Piotr Kaczmarczyk
 *
 * Description:
 * This is the ROM for the 'AGH48x64.png' image.
 * The image size is 48 x 64 pixels.
 * The input 'address' is a 12-bit number, composed of the concatenated
 * 6-bit y and 6-bit x pixel coordinates.
 * The output 'rgb' is 12-bit number with concatenated
 * red, green and blue color values (4-bit each)
 */

module image_rom #(
    parameter FILE="../../rtl/misc/placeholder.dat",
    parameter SIZE = 12,
    parameter SIZE_DEC = 4096
    )(
        input  logic clk ,
        input  logic [SIZE - 1:0] address,  // address = {addry[5:0], addrx[5:0]}
        output logic [11:0] rgb
    );


    /**
     * Local variables and signals
     */

    reg [SIZE - 1:0] rom [0:SIZE_DEC - 1];


    /**
     * Memory initialization from a file
     */

    /* Relative path from the simulation or synthesis working directory */
    initial $readmemh(FILE, rom);


    /**
     * Internal logic
     */

    always_ff @(posedge clk)
        rgb <= rom[address];

endmodule
