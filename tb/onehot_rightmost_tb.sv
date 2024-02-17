module onehot_rightmost_tb #(
    int unsigned WIDTH = 31
);

    localparam int unsigned CLOG_WIDTH = $clog2(WIDTH);

    // system signals
    logic clk;
    logic rst;
    // data signals
    logic [WIDTH-1:0] xi;
    logic [WIDTH-1:0] xi_loop;
    logic [WIDTH-1:0] xi_alu;
    logic [WIDTH-1:0] xo_loop;
    logic [WIDTH-1:0] xo_alu;
    // logarithms
    logic [CLOG_WIDTH-1:0] idx_clog;

    // clock
    initial clk = 1'b1;
    always  clk = #10ns ~clk;

    initial
    begin
        xi = '0;
        rst = 1'b1;
        repeat(2) @(posedge clk);
        rst <= 1'b0;
        repeat(1) @(posedge clk);
        xi = '0;
        @(posedge clk);
//        xi <= 8'b0001_0000;
//        @(posedge clk);
//        xi <= 8'b0001_0001;
//        @(posedge clk);
//        xi <= 8'b0001_0010;
//        @(posedge clk);
//        xi <= 8'b0100_0000;
//        @(posedge clk);
//        xi <= 8'b1000_0000;
//        @(posedge clk);
        for (int i=0; i<WIDTH; i++) begin
            xi <= 'd1 << i;
            @(posedge clk);
        end
        repeat(3) @(posedge clk);
        $finish;
    end

    onehot_rightmost_loop #(
        .WIDTH  (WIDTH)
    ) onehot_rightmost_loop (
        // system signals
        .clk   (clk),
        .rst   (rst),
        // data signals
        .xi    (xi),
        .xo    (xo_loop)
    );

    assign xi_loop = onehot_rightmost_loop.onehot_rightmost_f(xi);

    onehot_rightmost_alu #(
        .WIDTH  (WIDTH)
    ) onehot_rightmost_alu (
        // system signals
        .clk   (clk),
        .rst   (rst),
        // data signals
        .xi    (xi),
        .xo    (xo_alu)
    );

    onehot_logarithm #(
        .WIDTH  (WIDTH)
    ) onehot_logarithm (
        // system signals
        .clk   (clk),
        .rst   (rst),
        // data signals
        .xi    (xi),
        .idx   (idx_clog)
    );

endmodule: onehot_rightmost_tb