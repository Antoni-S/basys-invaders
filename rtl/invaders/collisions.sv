//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   collisions
 Author:        Antoni Sus
 Version:       1.0
 Last modified: 2025-08-25
 Coding style: safe, with FPGA sync reset
 Description:  Controller for checking collisions between enemies/bullets and enemies/bottom screen edge
 */
//////////////////////////////////////////////////////////////////////////////
module collisions #(
    NUM_INVADERS = 10,
    NUM_ROWS = 3,
    OFFSET = 100,
    INVADER_HEIGHT = 32,
    INVADER_WIDTH = 64,
    PROJECTILE_WIDTH = 16,
    PROJECTILE_HEIGHT = 32
)(
    input logic clk,
    input logic rst,
    input logic [11:0] projectile_xpos,
    input logic [11:0] projectile_ypos,
    input logic [NUM_INVADERS-1:0][11:0] invader_x_positions,
    input logic [9:0] enemy_ypos,
    input logic bullet_active,

    output logic [NUM_ROWS - 1:0][NUM_INVADERS - 1:0] collision,
    output logic bullet_hit,
    output logic player_hit
);

timeunit 1ns;
timeprecision 1ps;

import vga_pkg::*;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic [NUM_ROWS - 1:0][NUM_INVADERS - 1:0] collision_nxt;
logic bullet_hit_nxt;
logic player_hit_nxt;
logic found_any_live;
logic [$clog2(NUM_ROWS)-1:0] lowest_live_row;

//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if(rst) begin
        collision <= '1;
        bullet_hit <= '0;
        player_hit <= '0;
    end else begin
        collision <= collision_nxt;
        bullet_hit <= bullet_hit_nxt;
        player_hit <= player_hit_nxt;
    end
end

//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------
always_comb begin
    collision_nxt = collision;
    bullet_hit_nxt = 0;
    player_hit_nxt = player_hit;

    if(bullet_active) begin
        for(logic [NUM_ROWS - 1:0] row = 0; row < NUM_ROWS; row++) begin
            for(logic [NUM_INVADERS - 1:0] col = 0; col < NUM_INVADERS; col++) begin
                automatic logic [11:0] current_enemy_y = enemy_ypos + row * OFFSET;

                automatic logic x_overlap = (projectile_xpos <= invader_x_positions[col] + INVADER_WIDTH) 
                                         && (projectile_xpos + PROJECTILE_WIDTH >= invader_x_positions[col]);
                automatic logic y_overlap = (projectile_ypos <= current_enemy_y + INVADER_HEIGHT)
                                         && (projectile_ypos + PROJECTILE_HEIGHT >= current_enemy_y);

                if (x_overlap && y_overlap && collision[row][col]) begin
                        collision_nxt[row][col] = 1'b0;
                        bullet_hit_nxt = 1;

                end
            end
        end
    end
    
    for(int row = NUM_ROWS - 1; row >= 0; row--) begin
        if(|collision[row]) begin
            lowest_live_row = row;
            found_any_live = 1;
            break;
        end
    end
    

    if(found_any_live) begin
        automatic logic [11:0] enemy_bottom_y = enemy_ypos + (lowest_live_row * OFFSET) + INVADER_HEIGHT;
        
        if(enemy_bottom_y >= VER_PIXELS - (2 * OFFSET)) begin
            player_hit_nxt = 1'b1;
        end
    end
end

endmodule