///////////////////////////////////////////////////////////////////////////////
// binary to one-hot conversion (one-hot decoder),
// testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module bin2oht_tb #(
    // size parameters
    int unsigned WIDTH = 16,
    int unsigned SPLIT = 4
);

    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH);
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 4;

    // valid and binary inputs
    logic                 vld;
    logic [WIDTH_LOG-1:0] bin;
    // one-hot output
    logic [WIDTH    -1:0] oht [0:IMPLEMENTATIONS-1];
    // reference signals
    logic [WIDTH    -1:0] ref_oht;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    function automatic [WIDTH-1:0] ref_bin2oht (
        logic                 vld,
        logic [WIDTH_LOG-1:0] bin
    );
        for (int unsigned i=0; i<WIDTH; i++) begin
            ref_bin2oht[i] = vld ? (bin == i[WIDTH_LOG-1:0]) : 1'b0;
        end
    endfunction: ref_bin2oht

    // reference ref_bin2oht
    always_comb
    begin
        ref_oht = ref_bin2oht(vld, bin);
    end

    // output checking task
    task check();
        #T;
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            assert (oht[i] ==  ref_oht) else $error("IMPLEMENTATION[%0d]:  oht != %0d'b%b", i, WIDTH, ref_oht);
        end
        #T;
    endtask: check

///////////////////////////////////////////////////////////////////////////////
// test
///////////////////////////////////////////////////////////////////////////////

    // test name
    string        test_name;

    // test sequence
    initial
    begin
        // idle test
        test_name = "idle";
        vld <= 1'b0;
        bin <= 'x;
        check;

        // test all binary combinations
        test_name = "one-hot";
        vld <= 1'b1;
        for (int unsigned i=0; i<WIDTH; i++) begin
            bin = i[WIDTH_LOG-1:0];
            check;
        end
        $finish;
    end

///////////////////////////////////////////////////////////////////////////////
// DUT instance array (for each implementation)
///////////////////////////////////////////////////////////////////////////////

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: imp

        // DUT RTL instance
        bin2oht #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (i)
        ) dut (
            .vld (vld),
            .bin (bin),
            .oht (oht[i])
        );

    end: imp
    endgenerate

endmodule: bin2oht_tb