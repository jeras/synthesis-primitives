///////////////////////////////////////////////////////////////////////////////
// register slice for forward data path
//
// Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module register_slice_datapath #(
    // data type and reset value
    // by default 'x synthesizes into a datapath without reset
    parameter type    DAT_TYP = logic [8-1:0],
    parameter DAT_TYP DAT_RST = DAT_TYP'('x),
    // low power mode reduces propagation of non valid data from RX to TX
    parameter bit     LOW_PWR = 1'b1
)(
    // system signals
    input  logic   clk,  // clock
    input  logic   rst,  // reset
    // RX interface
    input  logic   rx_vld,  // valid
    input  DAT_TYP rx_dat,  // data
    output logic   rx_rdy,  // ready
    // TX interface
    output logic   tx_vld,  // valid
    output DAT_TYP tx_dat,  // data
    input  logic   tx_rdy   // ready
);

    // transfer signals
    logic   rx_trn;
    logic   tx_trn;

    // transfer
    assign rx_trn = rx_vld & rx_rdy;
    assign tx_trn = tx_vld & tx_rdy;

    // combinational RX backpressure
    assign rx_rdy = ~tx_vld | tx_rdy;

    // handshake (asynchronous reset)
    always_ff @(posedge clk, posedge rst)
    if (rst) begin
        tx_vld <= 1'b0;
    end else begin
        if (rx_rdy) begin
            tx_vld <= rx_vld;
        end
    end

    // data path register (optional asynchronous reset)
    always_ff @(posedge clk, posedge rst)
    if (rst) begin
        tx_dat <= DAT_RST;
    end else begin
        if (LOW_PWR ? rx_trn : rx_rdy) begin
           tx_dat <= rx_dat;
        end
    end

endmodule: register_slice_datapath
