//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   coop_comm_rx
 Author:        Antoni Sus
 Version:       1.0
 Last modified: 2025-08-27
 Coding style: safe, with FPGA sync reset
 Description:  Receiver module for UART transmission
 */
//////////////////////////////////////////////////////////////////////////////

module coop_comm_rx (
    input  logic       clk,
    input  logic       rst,
    input  logic [7:0] rx_data,
    input  logic       rx_empty,

    output logic       rx_rd,
    output logic [11:0] remote_x
);

timeunit 1ns;
timeprecision 1ps;

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
enum logic [1:0] {
    WAIT_START,
    READ_XL,
    READ_XM
} state, state_nxt;

logic [7:0] xl_byte;

//------------------------------------------------------------------------------
// state sequential with synchronous reset
//------------------------------------------------------------------------------
always_ff @(posedge clk) begin
    if (rst) begin
        state     <= WAIT_START;
        xl_byte   <= 0;
        remote_x  <= 0;
    end else begin
        state <= state_nxt;
        if (state == READ_XL && !rx_empty) xl_byte <= rx_data;
        if (state == READ_XM && !rx_empty) 
            remote_x <= {rx_data[1:0], xl_byte};
    end
end

//------------------------------------------------------------------------------
// next state logic
//------------------------------------------------------------------------------
always_comb begin
    state_nxt = state;
    rx_rd = 0;
    case (state)
        WAIT_START: if (!rx_empty && rx_data == 8'hAA) begin
                        rx_rd = 1;
                        state_nxt = READ_XL;
                    end else if (!rx_empty) rx_rd = 1;
        READ_XL:    if (!rx_empty) begin
                        rx_rd = 1;
                        state_nxt = READ_XM;
                    end
        READ_XM:    if (!rx_empty) begin
                        rx_rd = 1;
                        state_nxt = WAIT_START;
                    end
    endcase
end

endmodule
