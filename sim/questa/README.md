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
qrun -f ../files_rtl.lst -f ../files_tb.lst
```
