///////////////////////////////////////////////////////////////////////////////
// register slice for backpressure,
// testbench
//
// Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module register_slice_backpressure_tb #(
    // data type and reset value
    // by default 'x synthesizes into a datapath without reset
    parameter type    DAT_TYP = logic [8-1:0],
    parameter DAT_TYP DAT_RST = DAT_TYP'('x),
    // low power mode reduces propagation of non valid data from RX to TX
    parameter bit     LOW_PWR = 1'b1
);

    // clock period
    localparam time T = 10ns;

    // system signals
    logic clk = 1'b0;  // clock
    logic rst = 1'b1;  // reset

    // RX interface
    logic   rx_vld;  // valid
    DAT_TYP rx_dat;  // data
    logic   rx_rdy;  // ready

    // TX interface
    logic   tx_vld;  // valid
    DAT_TYP tx_dat;  // data
    logic   tx_rdy;  // ready

///////////////////////////////////////////////////////////////////////////////
// test
///////////////////////////////////////////////////////////////////////////////

    // clock
    initial       clk = 1'b1;
    always #(T/2) clk = ~clk;

    // test sequence
    /* verilator lint_off INITIALDLY */
    initial
    begin
        // TX/RX init
        rx_vld <= 1'b0;
        rx_dat <= 'x;
        tx_rdy <= 1'b1;
        // T0 (reset)
        rst <= 1'b1;
        @(posedge clk);
        // T1
        rst <= 1'b0;
        @(posedge clk);
        // T2
        rx_vld <= 1'b1;
        rx_dat <= DAT_TYP'(0);
        tx_rdy <= 1'b0;
        @(posedge clk);
        // T3
        @(posedge clk);
        // T4
        tx_rdy <= 1'b1;
        @(posedge clk);
        assert (tx_dat == DAT_TYP'(0)) else $error("Step 5: TX data mismatch");
        // T5
        rx_vld <= 1'b1;
        rx_dat <= DAT_TYP'(1);
        tx_rdy <= 1'b1;
        @(posedge clk);
        assert (tx_dat == DAT_TYP'(1)) else $error("Step 6: TX data mismatch");
        // T6
        rx_vld <= 1'b0;
        rx_dat <= 'x;
        tx_rdy <= 1'b0;
        @(posedge clk);
        // T...
        @(posedge clk);

        // end simulation
        $display("SUCCESS running %m");
        $finish;
    end
    /* verilator lint_on INITIALDLY */

///////////////////////////////////////////////////////////////////////////////
// DUT instance
///////////////////////////////////////////////////////////////////////////////

    register_slice_backpressure #(
        .DAT_TYP (DAT_TYP),
        .DAT_RST (DAT_RST),
        .LOW_PWR (LOW_PWR)
    ) dut (
        // system signals
        .clk    (clk),
        .rst    (rst),
        // RX interface
        .rx_vld (rx_vld),
        .rx_dat (rx_dat),
        .rx_rdy (rx_rdy),
        // TX interface
        .tx_vld (tx_vld),
        .tx_dat (tx_dat),
        .tx_rdy (tx_rdy)
    );
    
///////////////////////////////////////////////////////////////////////////////
// waveforms
///////////////////////////////////////////////////////////////////////////////

`ifdef VERILATOR
    initial
    begin
        $dumpfile("register_slice_backpressure_tb.fst");
        $dumpvars(0, register_slice_backpressure_tb);
    end
`endif

endmodule: register_slice_backpressure_tb
