#!/usr/bin/env bash

# list of top level entity
TOPLIST=`sed '/^[[:blank:]]*#/d;s/#.*//' ../vhdl_top.lst`

# if a list of top modules is not provided as an argument, use the default
TOPS=${@:-$TOPLIST}

# compile for VHDL-2008
OPTIONS="-2008"

for TOP in ${TOPS[@]}
do
    qrun -f ../vhdl_rtl.lst -f ../vhdl_tb.lst $OPTIONS -top $TOP
done
