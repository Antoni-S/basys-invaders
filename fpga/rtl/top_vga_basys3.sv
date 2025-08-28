/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 * Modified: Tomasz Sieja
 *
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

module top_vga_basys3 (
        input  wire clk,
        input  wire btnC,
        input  wire test_Rx,
        input  wire JB1,
        input  wire JC2,

        output wire Vsync,
        output wire Hsync,
        output wire [3:0] vgaRed,
        output wire [3:0] vgaGreen,
        output wire [3:0] vgaBlue,
        output wire JA1,
        output wire test_Tx,
        output wire JB2,
        output wire JC1,
        output wire led0,

		inout  wire PS2Clk,
		inout  wire PS2Data
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */
    localparam NUM_ROWS = 3;
    localparam NUM_INVADERS = 10;

    wire clk100MHz;
    wire clk65MHz;
    wire clk65MHz_mirror;
    wire locked;

    logic [7:0] w_data, w_data_test;
    logic wr_uart, wr_uart_test;
    logic tx_full, tx_full_test;
    logic [7:0] r_data, r_data_test;
    logic rd_uart;
    logic rx_empty, rx_empty_test;

    wire buttonU;
    wire [NUM_ROWS - 1:0][NUM_INVADERS - 1:0] collision, remote_collisions;
    wire [11:0] player_xpos, remote_xpos;
    wire remote_fire;

    /**
     * Signals assignments
     */

    assign JA1 = clk65MHz_mirror;


    /**
     * FPGA submodules placement
     */

     //------------------- UART ------------------------

    uart #(
        .DBIT(8),
        .SB_TICK(16),
        .DVSR(35),
        .DVSR_BIT(6),
        .FIFO_W(6)
    ) u_uart_test (
        .clk(clk65MHz),
        .reset(btnC),
        .rd_uart(rd_uart),
        .wr_uart(wr_uart_test),
        .rx(test_Rx),
        .w_data(w_data_test),
        .tx_full(tx_full_test),
        .rx_empty(rx_empty_test),
        .tx(test_Tx),
        .r_data(r_data_test)
    );

    coop_comm_test #(
        .FCLK_HZ(65_000_000)
    )u_coop_comm_test (
        .clk(clk65MHz),
        .rst(btnC),
        .player_xpos(player_xpos),
        .tx_full(tx_full),
        .w_data(w_data_test),
        .wr_uart(wr_uart_test)
    );

    uart #(
        .DBIT(8),
        .SB_TICK(16),
        .DVSR(35),
        .DVSR_BIT(6),
        .FIFO_W(6)
    ) u_uart (
        .clk(clk65MHz),
        .reset(btnC),
        .rd_uart(rd_uart),
        .wr_uart(wr_uart),
        .rx(JB1),
        .w_data(w_data),
        .tx_full(tx_full),
        .rx_empty(rx_empty),
        .tx(JC1),
        .r_data(r_data)
    );

    coop_comm_tx u_coop_comm_tx (
        .clk(clk65MHz),
        .rst(btnC),
        .player_x(player_xpos),
        .tx_busy(tx_full),
        .tx_wr(wr_uart),
        .tx_data(w_data)
    );

    coop_comm_rx u_coop_comm_rx (
        .clk(clk65MHz),
        .rst(btnC),
        .rx_empty(rx_empty),
        .rx_rd(rd_uart),
        .rx_data(r_data),
        .remote_x(remote_xpos)
    );

    assign led0 = !tx_full;

    // ---------------------- CLOCK --------------------------

    clk_wiz_0_clk_wiz inst(
        // Clock out ports  
        .clk100MHz(clk100MHz),
        .clk65MHz(clk65MHz),
        // Status and control signals               
        .locked(locked),
        // Clock in ports
        .clk(clk)
    );

    // Mirror clk65MHz on a pin for use by the testbench;
    // not functionally required for this design to work.

    ODDR clk65MHz_oddr (
        .Q(clk65MHz_mirror),
        .C(clk65MHz),
        .CE(1'b1),
        .D1(1'b1),
        .D2(1'b0),
        .R(1'b0),
        .S(1'b0)
    );


    /**
     *  Project functional top module
     */

    top_vga u_top_vga (
        .clk100MHz(clk100MHz),
        .clk(clk65MHz),
        .rst(btnC),
        .r(vgaRed),
        .g(vgaGreen),
        .b(vgaBlue),
        .hs(Hsync),
        .vs(Vsync),
		.PS2Clk(PS2Clk),
		.PS2Data(PS2Data),
        .player_xpos(player_xpos),
        .buttonU(buttonU),
        .collision(collision),
        .remote_xpos(remote_xpos),
        .remote_fire(remote_fire),
        .remote_collisions(remote_collisions)
    );

endmodule
