module negative #(
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

    // use synchronous reset
    always @(posedge clk)
    if (rst)  xr <= '0;
    else      xr <= xi;

    // use synchronous reset
    always @(posedge clk)
    if (rst)  xo <= '0;
    else      xo <= -xr;

endmodule: negative