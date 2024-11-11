#!/usr/bin/env bash

# get file list from file
FILES=`sed '/^[[:blank:]]*#/d;s/#.*//' ../vhdl_rtl.lst ../vhdl_tb.lst`

# list of top level entity
TOPS=`sed '/^[[:blank:]]*#/d;s/#.*//' ../vhdl_top.lst`

for TOP in ${TOPS[@]}
do
    # list of source files
    ghdl -i --work=work --std=08 $FILES
    # elaboration and simulation
    ghdl -m --std=08 work.$TOP
    ghdl -r --std=08 work.$TOP --fst=$TOP.fst
    # --ieee-asserts=disable-at-0
    # --ieee-asserts=disable
done
