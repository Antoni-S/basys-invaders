/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Antoni Sus
 *
 * Description:
 * Controller for handling enemy collisions
 */

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
    output logic bullet_hit
);

timeunit 1ns;
timeprecision 1ps;

logic [NUM_ROWS - 1:0][NUM_INVADERS - 1:0] collision_nxt;
logic bullet_hit_nxt;

always_ff @(posedge clk) begin
    if(rst) begin
        collision <= '1;
        bullet_hit <= '0;
    end else begin
        collision <= collision_nxt;
        bullet_hit <= bullet_hit_nxt;
    end
end

always_comb begin
    collision_nxt = collision;
    bullet_hit_nxt = 0;

    if(bullet_active) begin
        for(logic [NUM_ROWS - 1:0] i = 0; i < NUM_ROWS; i++) begin
            for(logic [NUM_INVADERS - 1:0] j = 0; j < NUM_INVADERS; j++) begin
                automatic logic [11:0] current_enemy_y = enemy_ypos + i * OFFSET;

                automatic logic x_overlap = (projectile_xpos < invader_x_positions[j] + INVADER_WIDTH) && (projectile_xpos + PROJECTILE_WIDTH > invader_x_positions[j]);
                automatic logic y_overlap = (projectile_ypos <= current_enemy_y + INVADER_HEIGHT) && (projectile_ypos + PROJECTILE_HEIGHT >= current_enemy_y);

                if (x_overlap && y_overlap && collision[i][j]) begin
                        collision_nxt[i][j] = 1'b0;
                        bullet_hit_nxt = 1;

                end
            end
        end
    end
end

endmodule