#!/usr/bin/env bash

# list of top level entity
TOPS=`sed '/^[[:blank:]]*#/d;s/#.*//' ../systemverilog_top.lst`

# override to debug a single testcase
TOPS=("register_slice_datapath_tb")

OPTIONS=" -Wno-INITIALDLY"
OPTIONS+=" -Wno-UNOPTFLAT"

for TOP in ${TOPS[@]}
do
#   verilator -j 0 --lint-only --timing          --top $TOP -f ../systemverilog_rtl.lst -f ../systemverilog_tb.lst $OPTIONS
#   verilator -j 0 --binary    --timing --assert --top $TOP -f ../systemverilog_rtl.lst -f ../systemverilog_tb.lst -Wall
    verilator -j 0 --binary    --timing --assert --top $TOP -f ../systemverilog_rtl.lst -f ../systemverilog_tb.lst $OPTIONS --trace-fst
    obj_dir/V${TOP}
done
