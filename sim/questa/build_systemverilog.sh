#!/usr/bin/env bash

# list of top level entity
TOPLIST=`sed '/^[[:blank:]]*#/d;s/#.*//' ../systemverilog_top.lst`

# if a list of top modules is not provided as an argument, use the default
TOPS=${@:-$TOPLIST}

for TOP in ${TOPS[@]}
do
    qrun -f ../systemverilog_rtl.lst -f ../systemverilog_tb.lst -top $TOP
done
