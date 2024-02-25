////////////////////////////////////////////////////////////////////////////////
// Placeholder (ser-des)
//
// Just a module to keep signals from beeing optimized out.
// It is using a shift refister, so not to affect timing and routability.
////////////////////////////////////////////////////////////////////////////////

module placeholder #(
    int unsigned WIDTH = 32
)(
    // system signals
    input  logic             clk,    // clock
    input  logic             rst,    // reset
    // control inputs
    input  logic             pld,    // parallel load (serial load otherwise)
    // data inputs
    input  logic             ser_i,
    input  logic [WIDTH-1:0] par_i,
    // data outputs
    output logic [WIDTH-1:0] par_o,
    output logic             ser_o
);

    always @(posedge clk, posedge rst)
    if (rst) begin
        par_o <= '0;
    end else begin
        if (pld)  par_o <= par_i;
        else      par_o <= {par_o[WIDTH-2:0], ser_i};
    end

    assign ser_o = par_o[WIDTH-1];

endmodule: placeholder