# priority encoder

Vivado Simulator v2023.2.1 bug report.

## How to reproduce

Open the vivado project:
```bash
vivado vivado_simulator_bug_encoder.xpr
```

Run simulation of `encoder_tb` top level module.

There should be no errors instead `IMPLEMENTATIO[3]` and `IMPLEMENTATIO[4]`
which use `unique/priority` `case () inside` statements, cause errors.

```
# run 1000ns
Error: IMPLEMENTATION[         3]:  enc_idx !=          4'd 0
Time: 30 ns  Iteration: 0  Process: /encoder_tb/check/Block43_1  Scope: encoder_tb.check.Block43_1  File: /home/izi/VLSI/synthesis-optimizations/encoder_tb.sv Line: 46
Error: IMPLEMENTATION[         4]:  enc_idx !=          4'd 0
Time: 30 ns  Iteration: 0  Process: /encoder_tb/check/Block43_1  Scope: encoder_tb.check.Block43_1  File: /home/izi/VLSI/synthesis-optimizations/encoder_tb.sv Line: 46
Error: IMPLEMENTATION[         3]:  enc_idx !=          4'd 1
Time: 50 ns  Iteration: 0  Process: /encoder_tb/check/Block43_1  Scope: encoder_tb.check.Block43_1  File: /home/izi/VLSI/synthesis-optimizations/encoder_tb.sv Line: 46
Error: IMPLEMENTATION[         4]:  enc_idx !=          4'd 1
Time: 50 ns  Iteration: 0  Process: /encoder_tb/check/Block43_1  Scope: encoder_tb.check.Block43_1  File: /home/izi/VLSI/synthesis-optimizations/encoder_tb.sv Line: 46
Error: IMPLEMENTATION[         3]:  enc_idx !=          4'd 2
Time: 70 ns  Iteration: 0  Process: /encoder_tb/check/Block43_1  Scope: encoder_tb.check.Block43_1  File: /home/izi/VLSI/synthesis-optimizations/encoder_tb.sv Line: 46
Error: IMPLEMENTATION[         4]:  enc_idx !=          4'd 2
```

## Some explanation

I encountered issues simulating `unique/priority` `case () inside` statements.

I created a testbench comparing multiple implementations of a 4 to 1 priority encoder.

When the encoders are in the same flat file as the testbench, they seem to work correctly.

When in a recursive implementation of a 16 to 4 priority encoder, the `case inside` versions of the code output `X` instead of the correct values.

For reference I tested the code in another simulator which reported no errors.

Vivado synthesis also seems to synthesize all versions correctly into the same logic.

The testbenches have automatic checking or RTL outputs,
in a correct simulation there should be no error assertions.

Xilinx documentation states this is implemented:
https://docs.xilinx.com/r/en-US/ug900-vivado-logic-simulation/Running-SystemVerilog-in-Standalone-or-prj-Mode

Set membership case statement | 12.5.4 | Supported
