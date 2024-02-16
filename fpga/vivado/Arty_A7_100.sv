`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent inc.
// Engineer: Samuel Lowe
// Engineer Email: samuel.lowe@ni.com
// Create Date: 05/28/2015 03:26:51 PM
// Design Name: XADCdemo
// Module Name: XADCdemo: 
// Target Devices: ARTY
// Tool Versions: Vivado 15.1
// Description: A top level design for reading values off of the XADC Pmod port of the ARTY FPGA
// 
// Dependencies: 
// 
// Revision: 3/3/2015
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////
 

module Arty_A7_100 (
    // clock
    input  wire        CLK100MHZ,
    input  wire  [8:0] ck_an_p,
    input  wire  [8:0] ck_an_n,
    input  wire        vp_in,
    input  wire        vn_in,
    // GPIO
    input  wire  [3:0] sw,
    input  wire  [3:0] btn,
    output wire  [7:4] led,
    // GPIO
    inout  wire [41:0] ck_io,
    // PMOD
    input  wire [10:1] ja,
    input  wire [10:1] jb,
    input  wire [10:1] jc,
    input  wire [10:1] jd
);

////////////////////////////////////////////////////////////////////////////////
// local signals
////////////////////////////////////////////////////////////////////////////////

    logic clk;
    logic rst;

    localparam int unsigned WIDTH = 82;

    logic [WIDTH-1:0] xi;
    logic [WIDTH-1:0] xo_neg;
    logic [WIDTH-1:0] xo_loop;
    logic [WIDTH-1:0] xo_alu;
    
    logic             xor_neg;
    logic             xor_loop;
    logic             xor_alu;

////////////////////////////////////////////////////////////////////////////////
// xpm_cdc_async_rst: Asynchronous Reset Synchronizer
// Xilinx Parameterized Macro, version 2023.2
////////////////////////////////////////////////////////////////////////////////

    assign clk = CLK100MHZ;

    xpm_cdc_async_rst #(
       .DEST_SYNC_FF(4),    // DECIMAL; range: 2-10
       .INIT_SYNC_FF(1),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
       .RST_ACTIVE_HIGH(1)  // DECIMAL; 0=active low reset, 1=active high reset
    ) xpm_cdc_async_rst_inst (
       .dest_clk  (clk),     // Destination clock.
       .src_arst  (btn[0]),  // Source asynchronous reset signal.
       .dest_arst (rst)
    );

////////////////////////////////////////////////////////////////////////////////
// define test inputs
////////////////////////////////////////////////////////////////////////////////

    // concatenate signals (4*10+42=82) and cut the 
    assign xi = WIDTH'({jd, jc, jb, ja, ck_io});

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
        .xi    (xi),
        .xo    (xo_neg)
    );

    (* KEEP_HIERARCHY = "TRUE" *) onehot_rightmost_loop #(
        .WIDTH  (WIDTH)
    ) onehot_rightmost_loop (
        // system signals
        .clk   (clk),
        .rst   (rst),
        // data signals
        .xi    (xi),
        .xo    (xo_loop)
    );

    (* KEEP_HIERARCHY = "TRUE" *) onehot_rightmost_alu #(
        .WIDTH  (WIDTH)
    ) onehot_rightmost_alu (
        // system signals
        .clk   (clk),
        .rst   (rst),
        // data signals
        .xi    (xi),
        .xo    (xo_alu)
    );

////////////////////////////////////////////////////////////////////////////////
// avoid minimizing test outputs
////////////////////////////////////////////////////////////////////////////////

    always @(posedge clk)
    begin
        xor_neg  <= ^(xo_neg );
        xor_loop <= ^(xo_loop);
        xor_alu  <= ^(xo_alu );
    end

    assign led[4] = xor_neg ;
    assign led[5] = xor_loop;
    assign led[6] = xor_alu ;

endmodule: Arty_A7_100
