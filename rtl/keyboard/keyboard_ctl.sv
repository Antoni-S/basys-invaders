//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   keyboard_ctl
 Author:        Antoni Sus
 Version:       1.0
 Last modified: 2025-08-25
 Coding style: safe with FPGA sync reset
 Description:  Simple keyboard controller, that makes use of a select few keys on the keyboard
 */
//////////////////////////////////////////////////////////////////////////////

module keyboard_ctl (
	input logic clk,
	input logic [15:0] keycode,
	output logic button_left,
	output logic button_right,
	output logic button_shoot,
	output logic buttonE
);

timeunit 1ns;
timeprecision 1ps;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam LEFT = 8'h1C;
localparam RIGHT = 8'h23;
localparam UP = 8'h1D;
localparam STOP = 8'hF0;
localparam ENTER = 8'h5A;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic btnL_nxt, btnR_nxt, btnU_nxt, buttonE_nxt;

/**
 * Internal logic
 */

always_ff @(posedge clk) begin
	if(keycode[15:8] == STOP && keycode[7:0] == RIGHT) begin
		btnR_nxt <= '0;
	end else if(keycode[15:8] == STOP && keycode[7:0] == LEFT) begin
		btnL_nxt <= '0;
	end else if(keycode[15:8] == STOP && keycode[7:0] == UP) begin
		btnU_nxt <= '0;
	end else if(keycode[15:8] == STOP && keycode[7:0] == ENTER) begin
		buttonE_nxt <= '0;
	end else if(keycode[7:0] == LEFT) btnL_nxt <= 1;
	else if(keycode[7:0] == RIGHT) btnR_nxt <= 1;
	else if(keycode[7:0] == UP) btnU_nxt <= 1;
	else if(keycode[7:0] == ENTER) buttonE_nxt <= 1;
end

always_comb begin
	button_left = btnL_nxt;
	button_right = btnR_nxt;
	button_shoot = btnU_nxt;
	buttonE = buttonE_nxt;
end

endmodule