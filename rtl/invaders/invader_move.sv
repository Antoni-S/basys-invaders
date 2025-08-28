//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   invader_move
 Author:        Tomasz Sieja
 Version:       1.0
 Last modified: 2025-08-25
 Coding style: safe with FPGA sync reset
 Description:  This module controls the movement pattern of an invader
 */
//////////////////////////////////////////////////////////////////////////////

module invader_move #(
    parameter OFFSET = 100
) (
    input logic clk65MHz,
    input logic rst,
    input logic game_start,
    
    output logic [9:0] xpos,
    output logic [9:0] ypos
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam signed X_MOVE = 4;
localparam signed Y_MOVE = 32;
localparam CLOCKS_PER_SECOND = 65_000_000;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic [9:0] xpos_reg, ypos_reg;
logic [7:0] move_counter, move_counter_nxt;

logic [31:0] clk_counter;
logic tick;

enum logic [2:0] {
    IDLE,
    RIGHT,
    DOWN_RIGHT,
    LEFT,
    DOWN_LEFT
} state, state_nxt;

/**
 * Timer
  */
always_ff @(posedge clk65MHz) begin : clk_counter_ff_blk
    if (rst) begin
        clk_counter <= 0;
        tick <= 0;
    end else begin
        if (clk_counter >= (CLOCKS_PER_SECOND - 1)/15) begin
            clk_counter <= 0;
            tick <= 1;
        end else begin
            clk_counter <= clk_counter + 1;
            tick <= 0;
        end
    end
end

//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
always_ff @(posedge clk65MHz) begin : state_ff_blk
    if (rst) begin
        state <= IDLE;
    end else begin
        state <= state_nxt;
    end
end

//------------------------------------------------------------------------------
// next state logic
//------------------------------------------------------------------------------
always_comb begin : state_comb_blk
    state_nxt = state;
    
    case (state)
        IDLE:       state_nxt = game_start ? RIGHT : IDLE;
        RIGHT:     if (move_counter >= OFFSET) state_nxt = DOWN_RIGHT;
        DOWN_RIGHT: state_nxt = LEFT;
        LEFT:      if (move_counter >= OFFSET) state_nxt = DOWN_LEFT;
        DOWN_LEFT:  state_nxt = RIGHT;
        default:    state_nxt = IDLE;
    endcase
end


//------------------------------------------------------------------------------
// output register
//------------------------------------------------------------------------------
    always_ff @(posedge clk65MHz) begin : move_ff_blk
    if (rst) begin
        xpos <= 0;
        ypos <= 0;
        move_counter <= 0;
    end else begin
        xpos <= xpos_reg;
        ypos <= ypos_reg;
        move_counter <= move_counter_nxt;
    end
end

//------------------------------------------------------------------------------
// output logic
//------------------------------------------------------------------------------
always_comb begin : move_comb_blk
    move_counter_nxt = move_counter;
    xpos_reg = xpos;
    ypos_reg = ypos;
    
    if (tick) begin
        case (state)
            RIGHT: begin
                move_counter_nxt = move_counter + X_MOVE;
                xpos_reg = xpos + X_MOVE;
            end
            LEFT: begin
                move_counter_nxt = move_counter + X_MOVE;
                xpos_reg = xpos - X_MOVE;
            end
            DOWN_RIGHT: begin
                move_counter_nxt = 0;
                ypos_reg = ypos + Y_MOVE;
            end
            DOWN_LEFT: begin
                move_counter_nxt = 0;
                ypos_reg = ypos + Y_MOVE;
            end
            default: begin
                move_counter_nxt = 0;
                xpos_reg = 0;
                ypos_reg = 0;
            end
        endcase
    end
end

endmodule