module encoder_tb #(
    int unsigned WIDTH = 4
);

    localparam time T = 10ns;

    // input
    logic [WIDTH-1:0] dec_vld;
    logic [WIDTH-1:0] tmp_vld = '0;
    // simple encoder output
    logic [$clog2(WIDTH)-1:0] enc_idx_smp;
    logic                     enc_vld_smp;
    // priority encoder output
    logic [$clog2(WIDTH)-1:0] enc_idx_pri;
    logic                     enc_vld_pri;

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

    simple_encoder #(
        .WIDTH (WIDTH)
    ) simple_encoder (
        .dec_vld (dec_vld),
        .enc_idx (enc_idx_smp),
        .enc_vld (enc_vld_smp)
    );

    priority_encoder #(
        .WIDTH (WIDTH)
    ) priority_encoder (
        .dec_vld (dec_vld),
        .enc_idx (enc_idx_pri),
        .enc_vld (enc_vld_pri)
    );

endmodule: encoder_tb