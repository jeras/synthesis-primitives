///////////////////////////////////////////////////////////////////////////////
// register slice for forward data path
//
// Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module register_slice_datapath #(
    // data type
    parameter type DAT_T = logic [8-1:0]
)(
    // system signals
    input  logic clk,  // clock
    input  logic rst,  // reset
    // RX interface
    input  logic rx_vld,  // valid
    input  DAT_T rx_dat,  // data
    output logic rx_rdy,  // ready
    // TX interface
    output logic rx_vld,  // valid
    output DAT_T rx_dat,  // data
    input  logic rx_rdy   // ready
);

    // transfer signals
    logic rx_trn;
    logic tx_trn;

    // transfer
    assign rx_trn = rx_vld & rx_rdy;
    assign tx_trn = tx_vld & tx_rdy;

    // handshake (asynchronous reset)
    always_ff @(posedge clk, posedge rst)
    if (rst) begin
        tx_vld <= 1'b0;
    end else begin
        if (rx_rdy) begin
            tx_vld <= rx_vld;
        end
    end

    // data path register (without reset)
    always_ff @(posedge clk)
    if (rx_trn) begin
       tx_dat <= rx_dat;
    end

    // combinational backpressure
    assign rx_rdy = ~tx_vld | tx_rdy;

endmodule: register_slice_datapath
