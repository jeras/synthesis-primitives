module onehot_rightmost_loop #(
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
    function automatic logic [XLEN-1:0] onehot_rightmost_f (logic [XLEN-1:0] x);
        logic set = 1'b0;
        for (int i=0; i<XLEN; i++) begin
            if (set) begin
                onehot_rightmost_f[i] = 1'b0;
            end else begin
                onehot_rightmost_f[i] = x[i];
                if (x[i]) begin
                    set = 1'b1;
                end
            end
        end
    endfunction: onehot_rightmost_f;

    // use synchronous reset
    always @(posedge clk)
    if (rst)  xo <= '0;
    else      xo <= onehot_rightmost_f(xr);

endmodule: onehot_rightmost_loop