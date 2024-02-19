# synthesis-optimizations
Observing and optimizing synthesis of common bit manipulation operations for FPGA and ASIC

I checked the book, the formula for _a word with a single 1-bit at the position of the rightmost 0-bit in x_ would be:
```Verilog
onehot = ~x & (x+1);
```

```Verilog
x_rev = ~bitreverse(x);
onehot = bitreverse(~(x_rev & (x_rev+1));
```
This operation is explicitely using addition.

A for loop formula would be (I did not run it, so it might be wrong):
```SystemVerilog
function [XLEN-1:0] onehot (
  input [XLEN-1:0] x
);
  for (int i=XLEN; i>0; i++) begin
  end
endfunction: onehot
```

I was wandering how different synthesis tools would handle this equation in comparison to a for loop formula.

A FPGA tool could do a better job with the addition formula

TODO:
* test -x and observe schematic
* test adder and mux primitives

# References

* http://www-graphics.stanford.edu/~seander/bithacks.html
* https://www.beyond-circuits.com/wordpress/2009/01/recursive-modules/
* https://books.google.si/books/about/Hacker_s_Delight.html?id=VicPJYM0I5QC
* https://www.edaboard.com/threads/verilog-bit-mask-to-index-converter.274344/
