///////////////////////////////////////////////////////////////////////////////
// multiplexer with priority select,
// generic version with padding
//
// Copyright 2025 Iztok Jeras <iztok.jeras@gmail.com>
//
// Licensed under CERN-OHL-P v2 or later
///////////////////////////////////////////////////////////////////////////////

module mux_pry #(
    // data type
    parameter  type DAT_T = logic [8-1:0],
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // implementation (see `mux_pry_base` for details)
    parameter  int unsigned IMPLEMENTATION = 0
)(
    input  logic [WIDTH-1:0] pry,              // priority select
    input  DAT_T             ary [WIDTH-1:0],  // data array
    output logic             vld,              // valid (OR reduced priority)
    output DAT_T             dat               // data selected
);

    // calculate `$ceil($ln(WIDTH), $ln(SPLIT))` using just integers
    function int unsigned clogbase (int unsigned number, base);
        clogbase = 0;
        while (base**clogbase < number)  clogbase++;
    endfunction: clogbase

    // SPLIT to the power of POWER_LOG (logarithm of WIDTH base SPLIT rounded up)
    localparam int unsigned POWER_LOG = clogbase(WIDTH, SPLIT);
    localparam int unsigned POWER     = SPLIT**POWER_LOG;

    generate
    // if WIDTH is not a power of SPLIT
    if (WIDTH != POWER) begin: extend

        logic [POWER-1:0] pry_tmp;
        DAT_T             ary_tmp [WIDTH-1:0];
        
        // zero extend the priority vector
        assign pry_tmp = POWER'(pry);
        // don't care extend the data array
        always_comb
        for (int unsigned i=0; i<POWER; i++) begin
            if (i<WIDTH)  ary_tmp[i] = ary[i];
        end

        // the synthesis tool is expected to optimize out the logic for constant inputs
        mux_pry_tree #(
            .DAT_T (DAT_T),
            .WIDTH (POWER),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_pry_tree (
            .pry (pry_tmp),
            .ary (ary_tmp),
            .vld (vld    ),
            .dat (dat    )
        );

    end: extend
    // width is a power of split
    else begin: exact

        mux_pry_tree #(
            .DAT_T (DAT_T),
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) mux_pry_tree (
            .pry (pry),
            .ary (ary),
            .vld (vld),
            .dat (dat)
        );

    end: exact
    endgenerate

endmodule: mux_pry
