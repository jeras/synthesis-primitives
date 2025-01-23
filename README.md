# Synthesis primitives

The document is divided into the following sections:

- [logic primitives](doc/logic.adoc),
- multiplexer,
  - decoder/encoder,
  - one-hot/priority/thermometer encoding,
  - Gray encoder/decoder,
  - equivalence comparator,
  - population count,
- [multiplexers](doc/multiplexers.md),
  - shifter,
- [arithmetic primitives](doc/arithmetic.adoc),
  - magnitude comparator,
  - adder architectures,
  - multipliers,
  - ...
- [coding theory primitives](doc/coding.md),
  - SECDED,
  - Hamming code,
  - ...
- [sorting networks](doc/sorting.md),
- [interconnect](doc/interconnect.md)
  - fixed priority and round-robin arbiters,
  - mask/range address decoder,
- [VALID/READY handshake](doc/handshake.adoc)
  - [Datapath register slice](doc/handshake.adoc#42-datapath-register-slice)
  - [Backpressure register slice](doc/handshake.adoc#43-backpressure-register-slice)
- [pipelining](doc/pipeline.md)
  - synchronous/asynchronous FIFO,
  - pipeline stages,
  - skid buffer,
- [memories](doc/memory.md),
  - memory inference,
  - synchronous/asynchronous static RAM,
- ...

Each section contains a variety of RTL primitives and discusses them in terms of:

- **syntax**
  - Verilog, SystemVerilog and VHDL syntax,
  - parameterization/generalization,
  - inference,
  - iterative algorithms,
  - loop unwinding and vectorization,
  - recursion,
- **simulation**,
  - simulating combinational/sequential circuits,
  - achieving good coverage,
- **synthesis**
  - timing/area complexity
  - timing/area/power optimizations/compromises,
  - parallel prefix network structures,
  - ASIC specific optimizations (flip-flops without reset, clock gating, ...),
  - FPGA specific optimizations (fast carry chains, LUT size, ...).

## License

If not stated otherwise, the documents are published under under
[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 





