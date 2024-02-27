module encoder_tb #(
    int unsigned WIDTH = 16,
    int unsigned SPLIT = 4
);

    localparam time T = 10ns;

    // input
    logic [WIDTH-1:0] dec_vld;
    logic [WIDTH-1:0] tmp_vld = '0;
    // priority encoder
    logic [$clog2(WIDTH)-1:0] enc_idx;
    logic                     enc_vld;

    initial
    begin
        // simple encoder test
        dec_vld <= '0;
        #T;
        for (int unsigned i=0; i<WIDTH; i++) begin
            tmp_vld = '0;
            tmp_vld[i] = 1'b1;
            dec_vld <= tmp_vld;
            #T;
        end
        // priority encoder test
        dec_vld <= '0;
        #T;
        for (int unsigned i=0; i<WIDTH; i++) begin
            tmp_vld = 'X;
            for (int unsigned j=0; j<i; j++) begin
                tmp_vld[j] = 1'b0;
            end
            tmp_vld[i] = 1'b1;
            dec_vld <= tmp_vld;
            #T;
        end
        $finish;
    end

    priority_encoder #(
        .WIDTH (WIDTH),
        .SPLIT (SPLIT)
    ) priority_encoder (
        .dec_vld (dec_vld),
        .enc_idx (enc_idx),
        .enc_vld (enc_vld)
    );

endmodule: encoder_tb