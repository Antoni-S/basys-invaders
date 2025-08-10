

module player_ctl (
    input   logic           clk,
    input   logic           rst,
    input   logic           button_left,
    input   logic           button_right,
    output  logic [11:0]    xpos,
    output  logic [11:0]    ypos
);


timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

enum logic [1:0] {ST_IDLE, ST_LEFT, ST_RIGHT} state;

/**
 * Local variables and signals
 */

logic [11:0] xpos_nxt, ypos_nxt;

/**
 * Internal logic
 */

always_ff @(posedge clk) begin
    if (rst) begin
        state <= ST_IDLE;
        xpos <= HOR_PIXELS / 2;
        ypos <= VER_PIXELS - 48;
    end else begin
        case(state)
            ST_IDLE: begin
                state <= button_left ? ST_LEFT : ST_IDLE;
                state <= button_right ? ST_RIGHT : ST_IDLE;
            end

            ST_LEFT: begin
				if(button_left) begin
                	if(xpos > 0) xpos_nxt <= xpos - 10;
				end else state <= ST_IDLE;
            end
            ST_RIGHT: begin
				if(button_right) begin
                	if(xpos < HOR_PIXELS - 64) xpos_nxt <= xpos + 10;
				end else state <= ST_IDLE;
            end
        endcase
    end
end

always_comb begin
	xpos = xpos_nxt;
	ypos = ypos_nxt;
end


endmodule