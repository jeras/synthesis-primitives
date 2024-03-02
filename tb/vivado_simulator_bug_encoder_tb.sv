module encoder_tb #(
    // size parameters
    int unsigned WIDTH = 16,
    int unsigned SPLIT = 4
);

    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH);
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT);

    // timing constant
    localparam time T = 10ns;

    // input
    logic [WIDTH    -1:0] dec_vld;
    // priority encoder
    logic [WIDTH_LOG-1:0] enc_idx;
    logic                 enc_vld;
    // reference encoder
    logic [WIDTH_LOG-1:0] ref_enc_idx;
    logic                 ref_enc_vld;

    function  [WIDTH_LOG-1:0] encoder (
        logic [WIDTH    -1:0] dec_vld
    );
        for (int unsigned i=0; i<WIDTH; i++) begin
            if (dec_vld[i] == 1'b1)  return WIDTH_LOG'(i);
        end
        return 'x;
    endfunction: encoder

    // reference encoder
    always_comb
    begin
        ref_enc_idx = encoder(dec_vld);
        ref_enc_vld =       |(dec_vld);    
    end

    // test sequence
    initial
    begin
        // idle test
        dec_vld <= '0;
        #T;
        assert (enc_vld == ref_enc_vld) else $error("enc_vld != 1'b%b"            , ref_enc_vld);
//      assert (enc_idx == ref_enc_idx) else $error("enc_idx != %d'd%d", WIDTH_LOG, ref_enc_idx);
        #T;

        // one-hot encoder test
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_vld;
            tmp_vld = '0;
            tmp_vld[i] = 1'b1;
            dec_vld <= tmp_vld;
            #T;
            assert (enc_vld == ref_enc_vld) else $error("enc_vld != 1'b%b"            , ref_enc_vld);
            assert (enc_idx == ref_enc_idx) else $error("enc_idx != %d'd%d", WIDTH_LOG, ref_enc_idx);
            #T;
        end

        // priority encoder test (with undefined inputs)
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_vld;
            tmp_vld = 'X;
            for (int unsigned j=0; j<i; j++) begin
                tmp_vld[j] = 1'b0;
            end
            tmp_vld[i] = 1'b1;
            dec_vld <= tmp_vld;
            #T;
            assert (enc_vld == ref_enc_vld) else $error("enc_vld != 1'b%b"            , ref_enc_vld);
            assert (enc_idx == ref_enc_idx) else $error("enc_idx != %d'd%d", WIDTH_LOG, ref_enc_idx);
            #T;
        end
        $finish;

        // priority encoder test (going through all input combinations)
        for (logic unsigned [WIDTH-1:0] tmp_vld='1; tmp_vld>0; tmp_vld--) begin
            dec_vld <= {<<{tmp_vld}};
            #T;
            assert (enc_vld == ref_enc_vld) else $error("enc_vld != 1'b%b"            , ref_enc_vld);
            assert (enc_idx == ref_enc_idx) else $error("enc_idx != %d'd%d", WIDTH_LOG, ref_enc_idx);
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