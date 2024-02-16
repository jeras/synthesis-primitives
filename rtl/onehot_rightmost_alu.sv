module onehot_rightmost_alu #(
    int unsigned WIDTH = 32
)(
    // system signals
    input  logic clk,
    input  logic rst,
    // data signals
(* IOB = "FALSE" *)    input  logic [WIDTH-1:0] xi,
(* IOB = "FALSE" *)    output logic [WIDTH-1:0] xo
);

    // input register
    logic [WIDTH-1:0] xr;
(* keep = "true" *)    logic [WIDTH-1:0] xr_neg;  // negative

    // use synchronous reset
    always @(posedge clk)
    if (rst)  xr <= '0;
    else      xr <= xi;

    assign xr_neg = -xr;

    // function definition
    function logic [WIDTH-1:0] onehot_rightmost_f (logic [WIDTH-1:0] x);
        onehot_rightmost_f = x & (-x);
    endfunction: onehot_rightmost_f;

    // use synchronous reset
    always @(posedge clk)
    if (rst)  xo <= '0;
//    else      xo <= onehot_rightmost_f(xr);
    else      xo <= xr & xr_neg;

endmodule: onehot_rightmost_alu