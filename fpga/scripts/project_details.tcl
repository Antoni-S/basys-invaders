# Copyright (C) 2025  AGH University of Science and Technology
# MTM UEC2
# Author: Piotr Kaczmarczyk
#
# Description:
# Project detiles required for generate_bitstream.tcl
# Make sure that project_name, top_module and target are correct.
# Provide paths to all the files required for synthesis and implementation.
# Depending on the file type, it should be added in the corresponding section.
# If the project does not use files of some type, leave the corresponding section commented out.

#-----------------------------------------------------#
#                   Project details                   #
#-----------------------------------------------------#
# Project name                                  -- EDIT
set project_name vga_project

# Top module name                               -- EDIT
set top_module top_vga_basys3

# FPGA device
set target xc7a35tcpg236-1

#-----------------------------------------------------#
#                    Design sources                   #
#-----------------------------------------------------#
# Specify .xdc files location                   -- EDIT
set xdc_files {
    constraints/top_vga_basys3.xdc
}

# Specify SystemVerilog design files location   -- EDIT
set sv_files {
    ../rtl/display/draw_bg.sv
    ../rtl/display/draw_rect.sv
    ../rtl/display/top_vga.sv
    ../rtl/display/vga_if.sv
    ../rtl/display/vga_pkg.sv
    ../rtl/display/vga_timing.sv
	../rtl/keyboard/keyboard_ctl.sv
    ../rtl/uart/coop_comm_test.sv
    ../rtl/uart/coop_comm_tx.sv
    ../rtl/uart/coop_comm_rx.sv
    ../rtl/misc/delay.sv
    ../rtl/misc/image_rom.sv
    ../rtl/misc/clk_divide.sv
    ../rtl/player/player_ctl.sv
    ../rtl/player/game_state.sv
	../rtl/invaders/display_invader.sv
	../rtl/invaders/invader_move.sv
    ../rtl/invaders/collisions.sv
    rtl/top_vga_basys3.sv
}

# Specify Verilog design files location         -- EDIT
set verilog_files {
    ../rtl/keyboard/debouncer.v
    ../rtl/keyboard/PS2Receiver.v
    ../rtl/uart/fifo.v
    ../rtl/uart/mod_m_counter.v
    ../rtl/uart/uart_rx.v
    ../rtl/uart/uart_tx.v
    ../rtl/uart/uart.v
    rtl/clk_wiz_0_clk_wiz.v
}

# Specify VHDL design files location            -- EDIT
# set vhdl_files {
#    path/to/file.vhd
# }

# Specify files for a memory initialization     -- EDIT
set mem_files {
   ../rtl/display/start_prompt.dat
   ../rtl/display/title.dat
   ../rtl/misc/placeholder.dat
   ../rtl/misc/lose.dat
   ../rtl/misc/win.dat
   ../rtl/player/spaceship1.dat
   ../rtl/player/projectile.dat
   ../rtl/invaders/invader_1.dat
   ../rtl/invaders/invader_2.dat
   ../rtl/invaders/invader_3.dat
}