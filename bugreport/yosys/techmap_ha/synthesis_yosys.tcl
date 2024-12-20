yosys -import

set PRJROOT ../..

proc debug_show {filename} {
    file mkdir out_yosys
    cd out_yosys
    show -format svg -colors 1 -width -prefix "$filename"
    write_json "$filename.json"
    exec netlistsvg "$filename.json" -o "$filename.netlist.svg"
    write_verilog "$filename.v"
    cd ..
}

set DESIGN counter_wrap

# read design
read_verilog -sv $DESIGN.sv
hierarchy -check -top $DESIGN

# the high-level stuff
# NOTE: `procs` is a TCL wrapper for yosys `proc`
procs; opt
memory; opt
fsm; opt

debug_show "proc"

# map to ripple carry adder
techmap -map rca_map.v

debug_show "techmap_rca"

# mapping to internal cell library
techmap; opt

debug_show "techmap"

# mapping logic to mycells.lib
dfflibmap -liberty $::env(HOME)/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
abc -liberty $::env(HOME)/.volare/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib
clean

debug_show "map"

# final statistics
stat
