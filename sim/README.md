# Simulation

Simulation `bash` scripts for running all tests are provided.

| Language      | [Verilator](https://github.com/verilator/verilator) | [GHDL](https://github.com/ghdl/ghdl) | Questa |
|---------------|-----------------------------------------------------|--------------------------------------|--------|
| Verilog       | 
| SystemVerilog | [`verilator/build.sh`](verilator/build.sh) | | [`questa/build.sh`](questa/build.sh) |
| VHDL          | | [`ghdl/build.sh`](ghdl/build.sh)           | [`questa/build.sh`](questa/build.sh) |

## Common source file lists

Source files are listed in this folder separately for
RTL and testbench code and for each language.
Top modules for simulation are listed in separate files.

The files contain paths to source files,
comment lines starting with the `#` character
and empty lines.

| Language      | RTL | testbench | top |
|---------------|-----|-----------|-----|
| Verilog       | [`verilog_rtl.lst`](verilog_rtl.lst) | [`verilog_tb.lst`](verilog_tb.lst) | [`verilog_top.lst`](verilog_top.lst) |
| SystemVerilog | [`systemverilog_rtl.lst`](systemverilog_rtl.lst) | [`systemverilog_tb.lst`](systemverilog_tb.lst) | [`systemverilog_top.lst`](systemverilog_top.lst) |
| VHDL          | [`vhdl_rtl.lst`](vhdl_rtl.lst) | [`vhdl_tb.lst`](vhdl_tb.lst) | [`vhdl_top.lst`](vhdl_top.lst) |

While Questa and Verilator can parse the list files and remove the comments,
GHDL does not have the option for providing a list file as an argument.

Therefore some bash code is used to convert
list files for GHDL and TOP files into `bash` arrays.

```bash
sed '/^[[:blank:]]*#/d;s/#.*//' *.lst
```