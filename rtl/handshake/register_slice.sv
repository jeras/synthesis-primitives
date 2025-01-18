///////////////////////////////////////////////////////////////////////////////
// register slice with generics to enable data path and/or backpressure registers
//
// Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module register_slice #(
    // configuration
    parameter bit ENABLE_BACKPRESSURE = 1'b1,  // enable backpressure register
    parameter bit ENABLE_DATAPATH     = 1'b1,  // enable data path register
    // data type and reset value
    // default 'x synthesizes into a datapath without reset
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

    // middle stream signals
    logic   md_vld;  // valid
    DAT_TYP md_dat;  // data
    logic   md_rdy;  // ready

///////////////////////////////////////////////////////////////////////////////
// backward path (backpressure) register
///////////////////////////////////////////////////////////////////////////////

generate
if (ENABLE_BACKPRESSURE)
begin: backpressure

    register_slice_backpressure #(
        .DAT_TYP (DAT_TYP),
        .DAT_RST (DAT_RST),
        .LOW_PWR (LOW_PWR)
    ) backpressure (
        // system signals
        .clk    (clk),
        .rst    (rst),
        // RX interface
        .rx_vld (rx_vld),
        .rx_dat (rx_dat),
        .rx_rdy (rx_rdy),
        // TX interface
        .tx_vld (md_vld),
        .tx_dat (md_dat),
        .tx_rdy (md_rdy)
    );

end: backpressure
else begin: backpressure_bypass

    // combinational passthrough mode
    assign md_vld = rx_vld;
    assign md_dat = rx_dat;
    assign rx_rdy = md_rdy;

end: backpressure_bypass
endgenerate

///////////////////////////////////////////////////////////////////////////////
// forward (datapath) path register
///////////////////////////////////////////////////////////////////////////////

generate
if (ENABLE_DATAPATH)
begin: datapath

    register_slice_datapath #(
        .DAT_TYP (DAT_TYP),
        .DAT_RST (DAT_RST),
        .LOW_PWR (LOW_PWR)
    ) datapath (
        // system signals
        .clk    (clk),
        .rst    (rst),
        // RX interface
        .rx_vld (md_vld),
        .rx_dat (md_dat),
        .rx_rdy (md_rdy),
        // TX interface
        .tx_vld (tx_vld),
        .tx_dat (tx_dat),
        .tx_rdy (tx_rdy)
    );

end: datapath
else begin: datapath_bypass

    // combinational passthrough mode
    assign tx_vld = md_vld;
    assign tx_dat = md_dat;
    assign md_rdy = tx_rdy;

end: datapath_bypass
endgenerate

endmodule: register_slice
