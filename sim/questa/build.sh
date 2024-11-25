#!/usr/bin/env bash

###############################################################################
# SystemVerilog
###############################################################################

# list of top level entity
TOPS=`sed '/^[[:blank:]]*#/d;s/#.*//' ../systemverilog_top.lst`

# override to debug a single testcase
TOPS=("register_slice_datapath_tb")

for TOP in ${TOPS[@]}
do
    qrun -f ../systemverilog_rtl.lst -f ../systemverilog_tb.lst -top $TOP
done

###############################################################################
# VHDL
###############################################################################

# list of top level entity
TOPS=`sed '/^[[:blank:]]*#/d;s/#.*//' ../vhdl_top.lst`

# override to debug a single testcase
TOPS=("register_slice_backpressure_tb")

OPTIONS="-2008"

for TOP in ${TOPS[@]}
do
    qrun -f ../vhdl_rtl.lst -f ../vhdl_tb.lst $OPTIONS -top $TOP
done
