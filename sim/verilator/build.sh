#!/bin/bash

TOPS=(
    # logic
    "eql_cmp_tb"
    "bin2oht_tb"
    "oht2bin_tb"
    "pry2thr_tb"
    "pry2oht_tb"
    "mag_cmp_tb"
    # multiplexer
    "mux_oht_tb"
    "mux_pry_tb"
    "mux_bin_tb"
    # arithmetic
    "counter_wrap_tb"
    "counter_maximum_tb"
    "counter_modulo_tb"
    "counter_fractional_tb"
    # pipeline
    "register_slice_backpressure_tb"
    "register_slice_datapath_tb"
    "register_slice_tb"
#   "fifo_synchronous_tb"
)

# override to debug a single testcase
TOPS=("register_slice_datapath_tb")

CONF=" -Wno-INITIALDLY"
CONF+=" -Wno-UNOPTFLAT"

for TOP in ${TOPS[@]}
do
    verilator -j 0 --lint-only --timing          --top $TOP -f ../systemverilog_rtl.lst -f ../systemverilog_tb.lst $CONF
#   verilator -j 0 --binary    --timing --assert --top $TOP -f ../systemverilog_rtl.lst -f ../systemverilog_tb.lst -Wall
    verilator -j 0 --binary    --timing --assert --top $TOP -f ../systemverilog_rtl.lst -f ../systemverilog_tb.lst $CONF --trace-fst
    obj_dir/V${TOP}
done