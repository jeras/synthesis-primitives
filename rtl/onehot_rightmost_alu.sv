module onehot_rightmost_alu #(
    int unsigned XLEN = 32
)(
    // system signals
    input  logic clk,
    input  logic rst,
    // data signals
(* IOB = "FALSE" *)    input  logic [XLEN-1:0] xi,
(* IOB = "FALSE" *)    output logic [XLEN-1:0] xo
);

    // input register
    logic [XLEN-1:0] xr;

    // use synchronous reset
    always @(posedge clk)
    if (rst)  xr <= '0;
    else      xr <= xi;

    // function definition
    function logic [XLEN-1:0] onehot_rightmost_f (logic [XLEN-1:0] x);
        x = ~x;
        onehot_rightmost_f = ~x & (x+1);
    endfunction: onehot_rightmost_f;

    // use synchronous reset
    always @(posedge clk)
    if (rst)  xo <= '0;
    else      xo <= onehot_rightmost_f(xr);

endmodule: onehot_rightmost_alu