///////////////////////////////////////////////////////////////////////////////
// register slice for backpressure,
// testbench
//
// Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module register_slice_backpressure_tb #(
    // size parameters
    int unsigned WIDTH = 8
);

    // clock period
    localparam time T = 10ns;

    // system signals
    logic clk = 1'b0;  // clock
    logic rst = 1'b1;  // reset

    // data type
    localparam type DAT_T = logic [WIDTH-1:0];

    // check enable depending on test
    struct packed {
        bit shift;      // 3
        bit power;      // 2
        bit loop;       // 1
    } check_enable;

    // timing constant
    localparam time T = 10ns;

    // RX interface
    logic rx_vld;  // valid
    DAT_T rx_dat;  // data
    logic rx_rdy;  // ready

    // TX interface
    logic rx_vld;  // valid
    DAT_T rx_dat;  // data
    logic rx_rdy;  // ready

///////////////////////////////////////////////////////////////////////////////
// test
///////////////////////////////////////////////////////////////////////////////

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
        repeat(1) @(posedge clk);
        // T1
        rst <= 1'b0;
        repeat(1) @(posedge clk);
        // T2
        rx_vld <= 1'b1;
        rx_dat <= 8X"00";
        tx_rdy <= 1'b0;
        repeat(1) @(posedge clk);
        // T3
        repeat(1) @(posedge clk);
        // T4
        tx_rdy <= 1'b1;
        repeat(1) @(posedge clk);
        assert (tx_dat = DAT_T'(0)) else $error("Step 5: TX data mismatch");
        // T5
        rx_vld <= 1'b1;
        rx_dat <= 8X"01";
        tx_rdy <= 1'b1;
        repeat(1) @(posedge clk);
        assert (tx_dat = DAT_T'(1)) else $error("Step 6: TX data mismatch");
        // T6
        rx_vld <= 1'b0;
        rx_dat <= 'x;
        tx_rdy <= 1'b0;
        repeat(1) @(posedge clk);

        // end simulation
        $finish;
    end
    /* verilator lint_on INITIALDLY */

///////////////////////////////////////////////////////////////////////////////
// DUT instance array (for each implementation)
///////////////////////////////////////////////////////////////////////////////

    register_slice_backpressure #(
        .DAT_T (DAT_T)
    ) dut (
        // system signals
        .clk    (clk),
        .rst    (rst),
        // RX interface
        .rx_vld (rx_vld),
        .rx_dat (rx_dat),
        .rx_rdy (rx_rdy),
        // TX interface
        .rx_vld (rx_vld),
        .rx_dat (rx_dat),
        .rx_rdy (rx_rdy)
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
