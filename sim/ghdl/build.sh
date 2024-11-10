#!/bin/bash

# get file list from file
files=`sed '/^[[:blank:]]*#/d;s/#.*//' ../vhdl_rtl.lst ../vhdl_tb.lst`

# choice of top level entity
TOPS=(
    # pipeline
    "register_slice_backpressure_tb"
    "register_slice_datapath_tb"
#    "register_slice_tb"
#    "fifo_synchronous_tb"
)

for TOP in ${TOPS[@]}
do
    # list of source files
    ghdl -i --work=work --std=08 $files
    # elaboration and simulation
    ghdl -m --std=08 work.$TOP
    ghdl -r --std=08 work.$TOP --fst=$TOP.fst
    # --ieee-asserts=disable-at-0
    # --ieee-asserts=disable
done