module keyboard_ctl (
	input logic clk,
	input logic [15:0] keycode,
	output logic button_left,
	output logic button_right
);

timeunit 1ns;
timeprecision 1ps;

localparam LEFT = 8'h1C;
localparam RIGHT = 8'h23;
localparam STOP = 8'hF0;

logic btnL_nxt, btnR_nxt;

always_ff @(posedge clk) begin
	if(keycode[15:8] == STOP && keycode[7:0] == RIGHT) begin
		btnR_nxt <= '0;
	end else if(keycode[15:8] == STOP && keycode[7:0] == LEFT) begin
		btnL_nxt <= '0;
	end else if(keycode[7:0] == LEFT) btnL_nxt <= 1;
	else if(keycode[7:0] == RIGHT) btnR_nxt <= 1;
end

always_comb begin
	button_left = btnL_nxt;
	button_right = btnR_nxt;
end

endmodule