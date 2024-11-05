Setup toolchain:

```sh
source settings.sh
```

Open Questa project:
```sh
vsim encoder.mpf
```

Compiling with `qrun`:
```sh
qrun -f ../systemverilog_rtl.lst -f ../systemverilog_tb.lst -f ../vhdl_rtl.lst -f ../vhdl_tb.lst
```
