///////////////////////////////////////////////////////////////////////////////
// register slice for forward data path,
// testbench
//
// Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module register_slice_datapath_tb #(
    type DAT_T = logic [8-1:0]
);

    // clock period
    localparam time T = 10ns;

    // system signals
    logic clk = 1'b0;  // clock
    logic rst = 1'b1;  // reset

    // data type

    // RX interface
    logic rx_vld;  // valid
    DAT_T rx_dat;  // data
    logic rx_rdy;  // ready

    // TX interface
    logic tx_vld;  // valid
    DAT_T tx_dat;  // data
    logic tx_rdy;  // ready

    // wait for a number of clock periods
    task automatic clk_period (int unsigned num);
        repeat(num) @(posedge clk);
        #1;  // TODO: the unit delay is only here as a workaround for a Verilator bug
    endtask: clk_period

///////////////////////////////////////////////////////////////////////////////
// test
///////////////////////////////////////////////////////////////////////////////

    // clock
    initial       clk = 1'b1;
    always #(T/2) clk = ~clk;

    // test sequence
    initial
    begin
        // TX/RX init
        rx_vld = 1'b0;
        rx_dat = 'x;
        tx_rdy = 1'b1;
        // T0 (reset)
        rst = 1'b1;
        clk_period(1);
        // T1
        rst <= 1'b0;
        clk_period(1);
        // T2
        rx_vld <= 1'b1;
        rx_dat <= DAT_T'(0);
        clk_period(1);
        // T3
        rx_vld <= 1'b1;
        rx_dat <= DAT_T'(1);
        @(posedge clk);
        assert (tx_dat == DAT_T'(0)) else $error("Step 3: TX data mismatch");
        // T4
        rx_vld <= 1'b0;
        rx_dat <= 'x;
        tx_rdy <= 1'b0;
        clk_period(1);
        // T5
        tx_rdy <= 1'b1;
        @(posedge clk);
        assert (tx_dat == DAT_T'(1)) else $error("Step 5: TX data mismatch");
        // T6
        tx_rdy <= 1'b1;
        clk_period(1);

        // end simulation
        $finish;
    end

///////////////////////////////////////////////////////////////////////////////
// DUT instance array (for each implementation)
///////////////////////////////////////////////////////////////////////////////

    register_slice_datapath #(
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
        $dumpfile("register_slice_datapath_tb.fst");
        $dumpvars(0, register_slice_datapath_tb);
    end
`endif

endmodule: register_slice_datapath_tb
