module vivado_simulator_bug_encoder_tb #(
    // size parameters
    int unsigned WIDTH = 4
);

    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH);

    // timing constant
    localparam time T = 10ns;

    // input
    logic [WIDTH    -1:0] dec_vld;
    // reference encoder
    logic [WIDTH_LOG-1:0] enc_idx;
    logic                 enc_vld;

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
        enc_idx = encoder(dec_vld);
        enc_vld =       |(dec_vld);    
    end

    // unique if
    logic [WIDTH_LOG-1:0] enc_idx__unique_if;

    always_comb
    begin
        unique   if (dec_vld ==? 4'b???1) enc_idx__unique_if = 2'd0;
        else     if (dec_vld ==? 4'b??10) enc_idx__unique_if = 2'd1;
        else     if (dec_vld ==? 4'b?100) enc_idx__unique_if = 2'd2;
        else     if (dec_vld ==? 4'b1000) enc_idx__unique_if = 2'd3;
        else                              enc_idx__unique_if = 2'dx;
    end

    // priority if
    logic [WIDTH_LOG-1:0] enc_idx__priority_if;

    always_comb
    begin
        priority if (dec_vld[0]) enc_idx__priority_if = 2'd0;
        else     if (dec_vld[1]) enc_idx__priority_if = 2'd1;
        else     if (dec_vld[2]) enc_idx__priority_if = 2'd2;
        else     if (dec_vld[3]) enc_idx__priority_if = 2'd3;
        else                     enc_idx__priority_if = 2'dx;
    end

    // casez
    logic [WIDTH_LOG-1:0] enc_idx__casez;

    always_comb
    begin
        casez (dec_vld)
            4'b???1: enc_idx__casez = 2'd0;
            4'b??10: enc_idx__casez = 2'd1;
            4'b?100: enc_idx__casez = 2'd2;
            4'b1000: enc_idx__casez = 2'd3;
            default: enc_idx__casez = 2'dx;
        endcase
    end

    // unique case inside
    logic [WIDTH_LOG-1:0] enc_idx__unique_case_inside;

    always_comb
    begin
        unique case (dec_vld) inside
            4'b???1: enc_idx__unique_case_inside = 2'd0;
            4'b??10: enc_idx__unique_case_inside = 2'd1;
            4'b?100: enc_idx__unique_case_inside = 2'd2;
            4'b1000: enc_idx__unique_case_inside = 2'd3;
            default: enc_idx__unique_case_inside = 2'dx;
        endcase
    end

    // priority case inside
    logic [WIDTH_LOG-1:0] enc_idx__priority_case_inside;

    always_comb
    begin
        priority case (dec_vld) inside
            4'b???1: enc_idx__priority_case_inside = 2'd0;
            4'b??1?: enc_idx__priority_case_inside = 2'd1;
            4'b?1??: enc_idx__priority_case_inside = 2'd2;
            4'b1???: enc_idx__priority_case_inside = 2'd3;
            default: enc_idx__priority_case_inside = 2'dx;
        endcase
    end

    // test sequence
    initial
    begin
        // idle test
        dec_vld <= '0;
        #T;
        assert (enc_idx__unique_if            === enc_idx) else $error("enc_idx__unique_if            !== %d'd%d", WIDTH_LOG, enc_idx);
        assert (enc_idx__priority_if          === enc_idx) else $error("enc_idx__priority_if          !== %d'd%d", WIDTH_LOG, enc_idx);
        assert (enc_idx__casez                === enc_idx) else $error("enc_idx__casez                !== %d'd%d", WIDTH_LOG, enc_idx);
        assert (enc_idx__unique_case_inside   === enc_idx) else $error("enc_idx__unique_case_inside   !== %d'd%d", WIDTH_LOG, enc_idx);
        assert (enc_idx__priority_case_inside === enc_idx) else $error("enc_idx__priority_case_inside !== %d'd%d", WIDTH_LOG, enc_idx);
        #T;

        // one-hot encoder test
        for (int unsigned i=0; i<WIDTH; i++) begin
            logic [WIDTH-1:0] tmp_vld;
            tmp_vld = '0;
            tmp_vld[i] = 1'b1;
            dec_vld <= tmp_vld;
            #T;
            assert (enc_idx__unique_if            === enc_idx) else $error("enc_idx__unique_if            !== %d'd%d", WIDTH_LOG, enc_idx);
            assert (enc_idx__priority_if          == enc_idx) else $error("enc_idx__priority_if          != %d'd%d", WIDTH_LOG, enc_idx);
            assert (enc_idx__casez                == enc_idx) else $error("enc_idx__casez                != %d'd%d", WIDTH_LOG, enc_idx);
            assert (enc_idx__unique_case_inside   == enc_idx) else $error("enc_idx__unique_case_inside   != %d'd%d", WIDTH_LOG, enc_idx);
            assert (enc_idx__priority_case_inside == enc_idx) else $error("enc_idx__priority_case_inside != %d'd%d", WIDTH_LOG, enc_idx);
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
            assert (enc_idx__unique_if            === enc_idx) else $error("enc_idx__unique_if            !== %d'd%d", WIDTH_LOG, enc_idx);
            assert (enc_idx__priority_if          == enc_idx) else $error("enc_idx__priority_if          != %d'd%d", WIDTH_LOG, enc_idx);
            assert (enc_idx__casez                == enc_idx) else $error("enc_idx__casez                != %d'd%d", WIDTH_LOG, enc_idx);
            assert (enc_idx__unique_case_inside   == enc_idx) else $error("enc_idx__unique_case_inside   != %d'd%d", WIDTH_LOG, enc_idx);
            assert (enc_idx__priority_case_inside == enc_idx) else $error("enc_idx__priority_case_inside != %d'd%d", WIDTH_LOG, enc_idx);
            #T;
        end
        $finish;
    end

endmodule: vivado_simulator_bug_encoder_tb