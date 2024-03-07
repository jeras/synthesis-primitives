module encoder_tb #(
    // size parameters
    int unsigned WIDTH = 4,
    int unsigned SPLIT = 2
);

    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH);
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT);

    // timing constant
    localparam time T = 10ns;

    localparam int unsigned IMPLEMENTATIONS = 5;

    // input
    logic [WIDTH    -1:0] dec_vld;
    // priority encoder
    logic [WIDTH_LOG-1:0] enc_pri;
    logic [WIDTH_LOG-1:0] enc_idx [0:IMPLEMENTATIONS-1];
    logic                 enc_vld [0:IMPLEMENTATIONS-1];
    // reference encoder
    logic [WIDTH_LOG-1:0] ref_enc_idx;
    logic                 ref_enc_vld;

    logic                 wrong   [0:IMPLEMENTATIONS-1];
    string                test;

    function  [WIDTH_LOG-1:0] encoder (
        logic [WIDTH    -1:0] dec_vld,
        logic [WIDTH_LOG-1:0] enc_pri
    );
        for (int unsigned i=0; i<WIDTH; i++) begin
            int unsigned t;
            t = (i + enc_pri) % WIDTH;
            if (dec_vld[t] === 1'b1)  return WIDTH_LOG'(t);
        end
        return 'x;
    endfunction: encoder

    // reference encoder
    always_comb
    begin
        ref_enc_idx = encoder(dec_vld, enc_pri);
        ref_enc_vld =       |(dec_vld);    
    end

    // output checking task
    task check();
        for (int unsigned i=0; i<IMPLEMENTATIONS; i++) begin
            assert (enc_vld[i] == ref_enc_vld) else $error("@%t IMPLEMENTATION[%d]:  enc_vld != 1'b%b" , $time, i,            ref_enc_vld);
            if (enc_vld[i]) begin  // do not check the encoded output, if it is not supposed to be valid
            assert (enc_idx[i] == ref_enc_idx) else $error("@%t IMPLEMENTATION[%d]:  enc_idx != %d'd%d", $time, i, WIDTH_LOG, ref_enc_idx);
            end
        end
    endtask: check

    // test sequence
    initial
    begin
        // idle test
        test = "zero";
        dec_vld <= '0;
        enc_pri <= WIDTH_LOG'(0);
        #T;
        check;
        #T;
        for (int unsigned pri=0; pri<WIDTH; pri++) begin: for_pri
            enc_pri <= WIDTH_LOG'(pri);

            // one-hot encoder test
            test = "one-hot";
            for (int unsigned i=0; i<WIDTH; i++) begin: for_oht
                logic [WIDTH-1:0] tmp_vld;
                tmp_vld = '0;
                tmp_vld[i] = 1'b1;
                dec_vld = tmp_vld;
                #T;
                check;
                #T;
            end: for_oht

            // priority encoder test (with undefined inputs)
            test = "priority";
            for (int unsigned i=0; i<WIDTH; i++) begin: for_pri
                logic [WIDTH-1:0] tmp_vld;
                for (int unsigned j=0; j<WIDTH; j++) begin
                    int unsigned t;
                    t = (j + pri) % WIDTH;
                         if (j< i)  tmp_vld[t] = 1'b0;
                    else if (j==i)  tmp_vld[t] = 1'b1;
                    else            tmp_vld[t] = 1'bx;
                end
                dec_vld <= tmp_vld;
                #T;
                check;
                #T;
            end: for_pri

            // priority encoder test (going through all input combinations)
            test = "all";
            for (logic unsigned [WIDTH-1:0] tmp_vld='1; tmp_vld!=0; tmp_vld--) begin: for_all
                dec_vld <= {<<{tmp_vld}};
                #T;
                check;
                #T;
            end: for_all
        end: for_pri
        $finish;
    end

    generate
    for (genvar i=0; i<IMPLEMENTATIONS; i++) begin: gen_imp

        // output checking
        assign wrong [i] = enc_idx[i] != ref_enc_idx;

        // DUT RTL instance
        priority_encoder #(
            .WIDTH (WIDTH),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (i)
        ) priority_encoder__casez (
            .dec_vld (dec_vld),
            .enc_pri (enc_pri),
            .enc_idx (enc_idx[i]),
            .enc_vld (enc_vld[i])
        );

    end: gen_imp
    endgenerate

endmodule: encoder_tb