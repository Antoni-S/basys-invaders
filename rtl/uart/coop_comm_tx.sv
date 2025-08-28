//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   coop_comm_tx
 Author:        Antoni Sus
 Version:       1.0
 Last modified: 2025-08-27
 Coding style: safe, with FPGA sync reset
 Description:  Transmitter module for UART transmission
 */
//////////////////////////////////////////////////////////////////////////////

module coop_comm_tx (
    input  logic        clk,
    input  logic        rst,
    input  logic [11:0] player_x,

    output logic [7:0]  tx_data,
    output logic        tx_wr,
    input  logic        tx_busy
);

timeunit 1ns;
timeprecision 1ps;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------

logic [11:0] prev_x;
logic change_detected;

assign change_detected = (player_x != prev_x);

enum logic [1:0] {
    IDLE,
    SEND_START,
    SEND_XL,
    SEND_XM
} state, state_nxt;

logic [7:0] data_nxt;
logic wr_nxt;

//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        state   <= IDLE;
        prev_x  <= 0;
        tx_data <= 0;
        tx_wr   <= 0;
    end else begin
        state   <= state_nxt;
        tx_data <= data_nxt;
        tx_wr   <= wr_nxt;

        if (state == IDLE && change_detected && !tx_busy)
            prev_x <= player_x;
    end
end

//------------------------------------------------------------------------------
// next state logic
//------------------------------------------------------------------------------
always_comb begin
    state_nxt = state;
    data_nxt  = tx_data;
    wr_nxt    = 0;
    case (state)
        IDLE: if (change_detected && !tx_busy) begin
                    data_nxt  = 8'hAA;
                    wr_nxt    = 1;
                    state_nxt = SEND_START;
                end
        SEND_START: if (!tx_busy) begin
                    data_nxt  = player_x[7:0];
                    wr_nxt    = 1;
                    state_nxt = SEND_XL;
                end
        SEND_XL: if (!tx_busy) begin
                    data_nxt  = {6'b0, player_x[9:8]};
                    wr_nxt    = 1;
                    state_nxt = SEND_XM;
                end
        SEND_XM: if (!tx_busy) begin
                    state_nxt = IDLE;
                end
    endcase
end

endmodule
