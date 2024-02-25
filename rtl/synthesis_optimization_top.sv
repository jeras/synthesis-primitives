`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// synthesis optimization top
////////////////////////////////////////////////////////////////////////////////

module synthesis_optimization_top #(
    int unsigned NUM_I  = 4,
    int unsigned NUM_O  = 4,
    int unsigned NUM_IO = 4
)(
    // system signals
    input  logic              clk,
    input  logic              rst,
    // GPIO
    input  logic [NUM_I -1:0] gpi,
    output logic [NUM_O -1:0] gpo,
    input  logic [NUM_IO-1:0] p_i,
    output logic [NUM_IO-1:0] p_o
);

////////////////////////////////////////////////////////////////////////////////
// local signals
////////////////////////////////////////////////////////////////////////////////

    localparam int unsigned WIDTH = 32;
    localparam int unsigned NUMBER = NUM_IO;

    logic [NUMBER-1:0]             ser_i;
    logic [NUMBER-1:0] [WIDTH-1:0] par_i;
    logic [NUMBER-1:0] [WIDTH-1:0] par_o;
    logic [NUMBER-1:0]             ser_o;

    assign ser_i = p_i;
    assign p_o = ser_o;

    assign gpo = '0;

////////////////////////////////////////////////////////////////////////////////
// define test inputs
////////////////////////////////////////////////////////////////////////////////

    placeholder #(
        .WIDTH  (WIDTH)
    ) placeholder [0:NUMBER-1] (
        // system signals
        .clk    (clk),
        .rst    (rst),
        // control inputs
        .pld    (gpi[0]),
        // data inputs
        .ser_i  (ser_i),
        .par_i  (par_i),
        // data outputs
        .par_o  (par_o),
        .ser_o  (ser_o)
    );

////////////////////////////////////////////////////////////////////////////////
// RTL instances
////////////////////////////////////////////////////////////////////////////////

    (* KEEP_HIERARCHY = "TRUE" *) negative #(
        .WIDTH  (WIDTH)
    ) negative (
        // system signals
        .clk   (clk),
        .rst   (rst),
        // data signals
        .xi    (par_o[0]),
        .xo    (par_i[0])
    );

    (* KEEP_HIERARCHY = "TRUE" *) onehot_rightmost_loop #(
        .WIDTH  (WIDTH)
    ) onehot_rightmost_loop (
        // system signals
        .clk   (clk),
        .rst   (rst),
        // data signals
        .xi    (par_o[1]),
        .xo    (par_i[1])
    );

    (* KEEP_HIERARCHY = "TRUE" *) onehot_rightmost_alu #(
        .WIDTH  (WIDTH)
    ) onehot_rightmost_alu (
        // system signals
        .clk   (clk),
        .rst   (rst),
        // data signals
        .xi    (par_o[2]),
        .xo    (par_i[2])
    );

    (* KEEP_HIERARCHY = "TRUE" *) onehot_logarithm #(
        .WIDTH  (WIDTH)
    ) onehot_logarithm (
        // system signals
        .clk   (clk),
        .rst   (rst),
        // data signals
        .xi    (par_o[3]),
        .idx   (par_i[3][$clog2(WIDTH)-1:0])
    );

endmodule: synthesis_optimization_top
