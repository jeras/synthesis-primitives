module onehot_rightmost_alu #(
    int unsigned WIDTH = 32
)(
    // system signals
    input  logic clk,
    input  logic rst,
    // data signals
    input  logic [WIDTH-1:0] xi,
    output logic [WIDTH-1:0] xo
);

    // input register
    logic [WIDTH-1:0] xr;
    logic [WIDTH-1:0] xr_neg;  // negative

    // use synchronous reset
    always @(posedge clk)
    if (rst)  xr <= '0;
    else      xr <= xi;

    assign xr_neg = -xr;

    // use synchronous reset
    always @(posedge clk)
    if (rst)  xo <= '0;
    else      xo <= xr & xr_neg;

endmodule: onehot_rightmost_alu