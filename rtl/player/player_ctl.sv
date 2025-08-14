/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Sus
 *
 * Description:
 * Simple player controller for a "Space Invaders"-like game
 */

module player_ctl #(
	parameter PLAYER_WIDTH = 32,
	parameter PLAYER_HEIGHT = 32,
	parameter BULLET_HEIGHT = 32,
	parameter BULLET_WIDTH = 32,
	parameter MOVEMENT_SPEED = 5,
	parameter BULLET_SPEED = 3
) (
    input   logic           clk,
    input   logic           rst,
    input   logic           button_left,
    input   logic           button_right,
    input   logic           button_shoot,
    output  logic [11:0]    xpos,
    output  logic [11:0]    xpos_shoot,
	output  logic [11:0]    bullet_y,
	output  logic			bullet_active
);


timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

/**
 * Local parameters
 */
localparam MOVEMENT_DELAY = 650000;
localparam INITIAL_POS = HOR_PIXELS / 2;
localparam MAX_POS_R = HOR_PIXELS - PLAYER_WIDTH - MOVEMENT_SPEED;




/**
 * Internal signals
 */
logic [11:0] xpos_nxt, xpos_shoot_nxt;
logic [31:0] delay_counter;
logic movement_enable;

logic [11:0] bullet_y_nxt;
logic bullet_active_nxt;
logic can_shoot, can_shoot_nxt;
/**
 * Internal logic
 */

always_ff @(posedge clk) begin : clock_divide
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


always_ff @(posedge clk) begin : movement_logic
    if (rst) begin
        xpos <= INITIAL_POS;
		xpos_shoot <= '0;
		bullet_y <= '0;
		bullet_active <= '0;
		can_shoot <= 1;
    end else if (movement_enable) begin
        xpos <= xpos_nxt;
		xpos_shoot <= xpos_shoot_nxt;
		bullet_y <= bullet_y_nxt;
		bullet_active <= bullet_active_nxt;
		can_shoot <= can_shoot_nxt;
    end
end

always_comb begin : button_controller
    xpos_nxt = xpos;
	xpos_shoot_nxt = xpos_shoot;
	bullet_y_nxt = bullet_y;
	bullet_active_nxt = bullet_active;
	can_shoot_nxt = can_shoot;
    
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

	if (bullet_active) begin
		bullet_y_nxt = bullet_y - BULLET_SPEED;
			
		if (bullet_y <= BULLET_HEIGHT) begin
			bullet_active_nxt = 0;
			can_shoot_nxt = 1;
		end
	end

	if (button_shoot && can_shoot) begin
		bullet_active_nxt = 1;
		xpos_shoot_nxt = xpos + (PLAYER_WIDTH / 2) - (BULLET_WIDTH / 2);
		bullet_y_nxt = VER_PIXELS - PLAYER_HEIGHT - BULLET_HEIGHT;
		can_shoot_nxt = 0;
	end
end

endmodule