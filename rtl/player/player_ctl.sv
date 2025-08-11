

module player_ctl #(
	parameter PLAYER_WIDTH = 32
) (
    input   logic           clk,
    input   logic           rst,
    input   logic           button_left,
    input   logic           button_right,
    output  logic [11:0]    xpos
);


timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

/**
 * Local parameters
 */
localparam MOVEMENT_SPEED = 5;
localparam MOVEMENT_DELAY = 650000;
localparam INITIAL_POS = HOR_PIXELS/2;
localparam MAX_POS_R = HOR_PIXELS - PLAYER_WIDTH - (PLAYER_WIDTH / 4) - MOVEMENT_SPEED;

/**
 * Internal signals
 */
logic [11:0] xpos_nxt;
logic [31:0] delay_counter;
logic movement_enable;

/**
 * Internal logic
 */

// Licznik opóźnienia dla płynnego ruchu
always_ff @(posedge clk) begin
    if (rst) begin
        delay_counter <= 0;
        movement_enable <= 0;
    end else begin
        if (delay_counter >= MOVEMENT_DELAY) begin
            delay_counter <= 0;
            movement_enable <= 1;
        end else begin
            delay_counter <= delay_counter + 1;
            movement_enable <= 0;
        end
    end
end

// Logika pozycji
always_ff @(posedge clk) begin
    if (rst) begin
        xpos <= INITIAL_POS;
    end else if (movement_enable) begin
        xpos <= xpos_nxt;
    end
end


always_comb begin
    xpos_nxt = xpos;
    
    if (button_left && !button_right) begin
        if (xpos > MOVEMENT_SPEED) begin
            xpos_nxt = xpos - MOVEMENT_SPEED;
        end else begin
            xpos_nxt = 0;
        end
    end
    else if (button_right && !button_left) begin
        if (xpos < MAX_POS_R) begin
            xpos_nxt = xpos + MOVEMENT_SPEED;
        end else begin
            xpos_nxt = HOR_PIXELS - PLAYER_WIDTH;
        end
    end
end

endmodule