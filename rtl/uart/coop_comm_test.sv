//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   coop_comm_test
 Author:        Antoni Sus
 Version:       1.0
 Last modified: 2025-08-25
 Coding style: safe with FPGA sync reset
 Description:  Test module used for reading packets sent via UART transmission
 */
//////////////////////////////////////////////////////////////////////////////

module coop_comm_test #(
    parameter int FCLK_HZ        = 100_000_000,
    parameter int SEND_PERIOD_MS = 50
)(
    input  logic        clk,
    input  logic        rst,
    input  logic [11:0]  player_xpos,

    input  logic        tx_full,
    output logic        wr_uart,
    output logic [7:0]  w_data
);

//------------------------------------------------------------------------------
// local parameters
//------------------------------------------------------------------------------
localparam int CYCLES = (FCLK_HZ/1000) * SEND_PERIOD_MS;

//------------------------------------------------------------------------------
// local variables
//------------------------------------------------------------------------------
logic tick;

enum logic [1:0] {
    S_IDLE,
    S_SEND,
    S_GAP
} state, state_nxt;

logic [2:0] idx, idx_nxt;
logic       wr_uart_nxt;
logic [7:0] w_data_nxt;

//------------------------------------------------------------------------------
// output register with sync reset
//------------------------------------------------------------------------------
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        state   <= S_IDLE;
        idx     <= '0;
        wr_uart <= 1'b0;
        w_data  <= 8'h00;
    end else begin
        state   <= state_nxt;
        idx     <= idx_nxt;
        wr_uart <= wr_uart_nxt;
        w_data  <= w_data_nxt;
    end
end

//------------------------------------------------------------------------------
// logic
//------------------------------------------------------------------------------

clk_divide #(
    .CYCLES(CYCLES)
) tick_gen (
    .clk(clk),
    .rst(rst),
    .clk_delayed(tick)
);

logic [3:0] d3, d2, d1, d0;
always_comb begin
    d3 = (player_xpos / 1000) % 10;
    d2 = (player_xpos / 100)  % 10;
    d1 = (player_xpos / 10)   % 10;
    d0 =  player_xpos         % 10;
end

function automatic [7:0] digit_ascii(input logic [3:0] d);
    return "0" + d;
endfunction

always_comb begin
    state_nxt   = state;
    idx_nxt     = idx;
    wr_uart_nxt = 1'b0;
    w_data_nxt  = w_data;

    unique case (state)
        S_IDLE: begin
            if (tick) begin
                idx_nxt   = 3'd0;
                state_nxt = S_SEND;
            end
        end

        S_SEND: begin
            unique case (idx)
                3'd0: w_data_nxt = "P"; //P as in player, used for tracking player's position
                3'd1: w_data_nxt = ":";
                3'd2: w_data_nxt = digit_ascii(d3);
                3'd3: w_data_nxt = digit_ascii(d2);
                3'd4: w_data_nxt = digit_ascii(d1);
                3'd5: w_data_nxt = digit_ascii(d0);
                3'd6: w_data_nxt = "\r";
                3'd7: w_data_nxt = "\n";
                default: w_data_nxt = 8'h00;
            endcase

            if (!tx_full) begin
                wr_uart_nxt = 1'b1;
                state_nxt   = S_GAP;
            end
        end

        S_GAP: begin
            if (idx == 3'd7)
                state_nxt = S_IDLE;
            else begin
                idx_nxt   = idx + 3'd1;
                state_nxt = S_SEND;
            end
        end
    endcase
end

endmodule
