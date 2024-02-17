module onehot_logarithm #(
    int unsigned WIDTH = 32
)(
    // system signals
    input  logic clk,
    input  logic rst,
    // data signals
    input  logic [       WIDTH -1:0] xi,
    output logic [$clog2(WIDTH)-1:0] idx
);

    // input register
    logic [       WIDTH -1:0] xr;
    logic [$clog2(WIDTH)-1:0] idx_tmp;

    // DEBUG
    logic [WIDTH-1:0] MASK [$clog2(WIDTH)-1:0];
    int unsigned      LEN  [$clog2(WIDTH)-1:0];

    // use synchronous reset
    always @(posedge clk)
    if (rst)  xr <= '0;
    else      xr <= xi;

    // function definition
    generate
    for (genvar i=0; i<$clog2(WIDTH); i++) begin
        assign idx_tmp[i] = |(xr & WIDTH'({WIDTH/(2**i){ { {2**i{1'b1}}, {2**i{1'b0}} } }}));
    end
    endgenerate

    // use synchronous reset
    always @(posedge clk)
    if (rst)  idx <= '0;
    else      idx <= idx_tmp;

endmodule: onehot_logarithm