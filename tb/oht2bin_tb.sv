///////////////////////////////////////////////////////////////////////////////
// one-hot ref_oht2bin,
// testbench
//
// @author: Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module oht2bin_tb #(
    // size parameters
    int unsigned WIDTH = 16,
    int unsigned SPLIT = 4
);

    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH);
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 3;

    // one-hot input
    logic [WIDTH    -1:0] oht;
    // binary and valid outputs
    logic [WIDTH_LOG-1:0] bin [0:IMPLEMENTATIONS-1];
    logic                 vld [0:IMPLEMENTATIONS-1];
    // reference signals
    logic [WIDTH_LOG-1:0] ref_bin;
    logic                 ref_vld;

///////////////////////////////////////////////////////////////////////////////
// reference calculation and checking of DUT outputs against reference
///////////////////////////////////////////////////////////////////////////////

    // reference function
    function automatic [WIDTH_LOG-1:0] ref_oht2bin (
        logic [WIDTH-1:0] oht
    );
        for (int unsigned i=0; i<WIDTH; i++) begin
            if (oht[i] == 1'b1)  return WIDTH_LOG'(i);
        end
        return 'x;
    endfunction: ref_oht2bin

    // reference assignment
    always_comb
    begin
        ref_bin = ref_oht2bin(oht);
        ref_vld =           |(oht);    
    end

    // check enable depending on test
    bit [0:IMPLEMENTATIONS-1] check_enable;

    // output checking task
    task check();
        #T;
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            if (check_enable[i]) begin
                assert (vld[i] ==  ref_vld) else $error("IMPLEMENTATION[%0d]:  vld != 1'b%b"  , i,            ref_vld);
                assert (bin[i] ==? ref_bin) else $error("IMPLEMENTATION[%0d]:  bin != %0d'd%d", i, WIDTH_LOG, ref_bin);
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
    initial
    begin
        // idle test
        test_name = "idle";
        check_enable = IMPLEMENTATIONS'('1);
        oht <= '0;
        check;

        // one-hot test
        test_name = "one-hot";
        check_enable = IMPLEMENTATIONS'('1);
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_oht;
            tmp_oht = '0;
            tmp_oht[i] = 1'b1;
            oht <= tmp_oht;
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
        oht2bin #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (i)
        ) dut (
            .oht (oht),
            .bin (bin[i]),
            .vld (vld[i])
        );

    end: imp
    endgenerate

endmodule: oht2bin_tb