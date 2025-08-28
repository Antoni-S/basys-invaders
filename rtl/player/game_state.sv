//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   game_state
 Author:        Antoni Sus
 Version:       1.0
 Last modified: 2025-08-25
 Coding style: safe with FPGA sync reset
 Description:  Controller for handling winning and losing conditions of the game
 */
//////////////////////////////////////////////////////////////////////////////


module game_state #(
    parameter NUM_INVADERS = 10,
    parameter NUM_ROWS = 3
)(
    input logic clk,
    input logic rst,

    input logic player_hit,
    input logic [NUM_ROWS - 1:0][NUM_INVADERS - 1:0] collision,

    output logic game_lost,
    output logic game_won
);

timeunit 1ns;
timeprecision 1ps;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic game_lost_nxt, game_won_nxt;

//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if(rst) begin
        game_lost <= '0;
        game_won <= '0;
    end else begin
        game_lost <= game_lost_nxt;
        game_won <= game_won_nxt;
    end
end

//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------
always_comb begin
    game_lost_nxt = game_lost;
    game_won_nxt = game_won;
    if(player_hit) begin
        game_lost_nxt = 1;
    end else if(collision == '0) begin
        game_won_nxt = 1;
    end
end

endmodule