///////////////////////////////////////////////////////////////////////////////
// multiplexer with one-hot select,
// testbench
//
// Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_oht_tb #(
    // data type
    parameter  type DAT_T = logic [8-1:0],
    // size parameters
    int unsigned WIDTH = 16
);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 2;

    // one-hot select and data array inputs
    logic [WIDTH-1:0] oht;
    DAT_T             ary [WIDTH-1:0];
    // data and valid outputs
    /* verilator lint_off ASCRANGE */
    logic             vld [0:IMPLEMENTATIONS-1];
    DAT_T             dat [0:IMPLEMENTATIONS-1];
    /* verilator lint_on ASCRANGE */
    // reference signals
    logic         ref_vld;
    DAT_T         ref_dat;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    function automatic DAT_T ref_mux_oht (
        logic [WIDTH-1:0] oht,
        DAT_T             ary [WIDTH-1:0]
    );
        for (int i=0; i<WIDTH; i++) begin
            if (oht[i])  ref_mux_oht = ary[i];
        end
    endfunction: ref_mux_oht

    // reference
    always_comb
    begin
        ref_vld =           |(oht     );
        ref_dat = ref_mux_oht(oht, ary);
    end

    // check enable depending on test
    /* verilator lint_off ASCRANGE */
    bit [0:IMPLEMENTATIONS-1] check_enable;
    /* verilator lint_on ASCRANGE */

    // output checking task
    task check();
        #T;
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            if (check_enable[i]) begin
                assert (vld[i] == ref_vld) else $error("IMPLEMENTATION[%0d]:  vld != 1'b%b"  , i,        ref_vld);
                assert (dat[i] == ref_dat) else $error("IMPLEMENTATION[%0d]:  dat != %0d'b%b", i, WIDTH, ref_dat);
            end
        end
        #T;
    endtask: check

///////////////////////////////////////////////////////////////////////////////
// test
///////////////////////////////////////////////////////////////////////////////

    // test name
    string        test_name;

    // test sequence
    /* verilator lint_off INITIALDLY */
    initial
    begin
        // initialize input array
        for (int unsigned i=0; i<WIDTH; i++) begin
            ary[i] = DAT_T'(i);
        end

        // idle test
        test_name = "idle";
        check_enable = IMPLEMENTATIONS'({1'b1, 1'b1});
        oht <= '0;
        check;

        // one-hot test
        test_name = "one-hot";
        check_enable = IMPLEMENTATIONS'({1'b1, 1'b1});
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_oht;
            tmp_oht = '0;
            tmp_oht[i] = 1'b1;
            oht <= tmp_oht;
            check;
        end

        $finish;
    end
    /* verilator lint_on INITIALDLY */

///////////////////////////////////////////////////////////////////////////////
// DUT instance array (for each implementation)
///////////////////////////////////////////////////////////////////////////////

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: imp

        // DUT RTL instance
        mux_oht #(
            .DAT_T (DAT_T),
            .WIDTH (WIDTH),
            .IMPLEMENTATION (i)
        ) dut (
            .oht (oht),
            .ary (ary),
            .vld (vld[i]),
            .dat (dat[i])
        );

    end: imp
    endgenerate

///////////////////////////////////////////////////////////////////////////////
// waveforms
///////////////////////////////////////////////////////////////////////////////

    `ifdef VERILATOR
    initial
    begin
        $dumpfile("mux_oht_tb.fst");
        $dumpvars(0, mux_oht_tb);
    end
`endif

endmodule: mux_oht_tb
