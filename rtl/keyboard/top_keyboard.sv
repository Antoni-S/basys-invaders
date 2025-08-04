module top_uart (
    input logic clk,
    input logic rst,
    input logic btnU,
    input logic loopback_enable,
    input logic rx,

    output logic tx,
    output logic [6:0] seg,
    output logic dp,
    output logic [3:0] an,
    output logic rx_monitor,
    output logic tx_monitor
);

timeunit 1ns;
timeprecision 1ps;

//signals
logic tx_uart;
logic rd_uart, wr_uart;
logic [7:0] w_data, r_data;
logic tx_full, rx_empty;
logic db_level, db_tick;
logic [3:0] hex0, hex1, hex2, hex3;

//connections

debounce u_debounce (
    .clk      (clk),
    .reset    (rst),
    .sw       (btnU),
    .db_level (db_level),
    .db_tick  (db_tick)
);

uart #(
    .DBIT     (8),
    .SB_TICK  (16),
    .DVSR     (54),
    .DVSR_BIT (7),
    .FIFO_W   (1)
   ) u_uart (
    .clk      (clk),
    .reset    (rst),
    .rd_uart  (rd_uart),
    .wr_uart  (wr_uart),
    .rx       (rx),
    .w_data   (w_data),
    .tx_full  (tx_full),
    .rx_empty (rx_empty),
    .tx       (tx_uart),
    .r_data   (r_data)
);

uart_monitor u_uart_monitor (
    .clk      (clk),
    .rst      (rst),
    .loopback_enable,
    .rx       (rx),
    .tx_uart  (tx_uart),
    .rx_empty (rx_empty),
    .r_data   (r_data),
    .db_tick  (db_tick),
    .tx       (tx),
    .wr_uart  (wr_uart),
    .rd_uart  (rd_uart),
    .w_data   (w_data),
    .hex0     (hex0),
    .hex1     (hex1),
    .hex2     (hex2),
    .hex3     (hex3),
    .rx_monitor,
    .tx_monitor
);

disp_hex_mux u_disp_hex_mux (
    .clk      (clk),
    .reset    (rst),
    .hex0     (hex0),
    .hex1     (hex1),
    .hex2     (hex2),
    .hex3     (hex3),
    .dp_in    (4'b1111),
    .an       (an),
    .sseg     ({dp, seg})
);

endmodule