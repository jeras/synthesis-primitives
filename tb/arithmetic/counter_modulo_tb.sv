///////////////////////////////////////////////////////////////////////////////
// counter (modulo),
// testbench
//
// Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module counter_modulo_tb #(
    // size parameters
    int unsigned WIDTH = 4
);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 2;

    // system signals
    logic             clk;  // clock
    logic             rst;  // reset
    // control input
    logic             ena;
    logic [WIDTH-0:0] mod;
    // counter outputs
    /* verilator lint_off ASCRANGE */
    logic [WIDTH-1:0] cnt[0:IMPLEMENTATIONS-1];
    logic             wrp[0:IMPLEMENTATIONS-1];
    /* verilator lint_on ASCRANGE */
    // reference signals
    integer       ref_cnt;
    integer       ref_nxt;
    logic         ref_wrp;

    // control counter
    integer       ctl_cnt;

    // testcases
    localparam logic [WIDTH-0:0] mod_lst [4] = '{1, 2, 2**WIDTH-1, 2**WIDTH};

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    // reference counter
    always_ff @(posedge clk, posedge rst)
    begin
        if (rst) begin
            ref_cnt <= '0;
        end else begin
            if (ena) begin
                if (ref_wrp) begin
                    ref_cnt <= '0;
                end else begin
                    ref_cnt <= ref_nxt;
                end
            end
        end
    end

    // reference next
    assign ref_nxt = ref_cnt + 1;

    // reference wrap
    assign ref_wrp = ref_nxt[WIDTH-0:0] == mod;

    // check enable depending on test
    /* verilator lint_off ASCRANGE */
    bit [0:IMPLEMENTATIONS-1] check_enable = '1;
    /* verilator lint_on ASCRANGE */

    // output checking task
    task check();
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            if (check_enable[i]) begin
                assert (cnt[i] == ref_cnt[WIDTH-1:0]) else $error("IMPLEMENTATION[%0d]:  cnt != %d'b%x", i, WIDTH, ref_cnt[WIDTH-1:0]);
                assert (wrp[i] == ref_wrp           ) else $error("IMPLEMENTATION[%0d]:  wrp != 1'b%x" , i,        ref_wrp           );
            end
        end
    endtask: check

///////////////////////////////////////////////////////////////////////////////
// test
///////////////////////////////////////////////////////////////////////////////

    // clock source
    initial clk = 1'b1;
    always #T clk = ~clk;

    // test name
    string test_name;

    // test sequence
    initial
    begin
        // loop over modulo value choices
        foreach(mod_lst[i])
        begin: testcase
            // reset sequence (asynchronous set, synchronous release)
            ena = 1'b0;
            rst = 1'b1;
            repeat(4) @(posedge clk);
            rst <= 1'b0;
    
            // set the conter wrap limit
            @(posedge clk);
            mod <= mod_lst[i];
            // randomized enable
            test_name = "randomized_enable";
            ctl_cnt = 0;
            do
            begin: random
                int unsigned rnd;
                rnd = $urandom();
                @(posedge clk);
                ena <= rnd[0];
                check;
                if (rnd[0]) ctl_cnt++;
            end: random
            while (ctl_cnt < (2**WIDTH)+2);
        end: testcase

        repeat(4) @(posedge clk);
        $finish;
    end

///////////////////////////////////////////////////////////////////////////////
// DUT instance array (for each implementation)
///////////////////////////////////////////////////////////////////////////////

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: imp

        // DUT RTL instance
        counter_modulo #(
            .WIDTH (WIDTH)
        ) dut (
            // system signals
            .clk (clk),
            .rst (rst),
            // counter
            .ena (ena),
            .mod (mod),
            .cnt (cnt[i]),
            .wrp (wrp[i])
        );

    end: imp
    endgenerate

///////////////////////////////////////////////////////////////////////////////
// waveforms
///////////////////////////////////////////////////////////////////////////////

`ifdef VERILATOR
    initial
    begin
        $dumpfile("counter_modulo_tb.fst");
        $dumpvars(0, counter_modulo_tb);
    end
`endif

endmodule: counter_modulo_tb
