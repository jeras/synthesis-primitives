///////////////////////////////////////////////////////////////////////////////
// register slice for backpressure
//
// Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module register_slice_backpressure #(
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
    output logic tx_vld,  // valid
    output DAT_T tx_dat,  // data
    input  logic tx_rdy   // ready
);

    // transfer signals
    logic rx_trn;
    logic tx_trn;

    // local data
    DAT_T ls_dat;

    // transfer
    assign rx_trn = rx_vld & rx_rdy;
    assign tx_trn = tx_vld & tx_rdy;

    // handshake (asynchronous reset)
    always_ff @(posedge clk, posedge rst)
    if (rst) begin
        rx_rdy <= 1'b0;
    end else begin
        if (tx_vld) begin
            rx_rdy <= tx_rdy;
        end
    end

    // data path register (without reset)
    always_ff @(posedge clk)
    if (rx_trn & ~tx_rdy) begin
        ls_dat <= rx_dat;
    end

    // combinational logic
    assign tx_vld = rx_rdy ? rx_vld : 1'b1;
    assign tx_dat = rx_rdy ? rx_dat : ls_dat;

endmodule: register_slice_backpressure
