module priority_encoder #(
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    bit mode = 1'b1
)(
    input  logic [       WIDTH -1:0] dec_vld,
    output logic [$clog2(WIDTH)-1:0] enc_idx,
    output logic                     enc_vld
);

    function logic [SPLIT_LOG-1:0] encode (logic [SPLIT-1:0] valid);
        case (SPLIT)
            2:  case (valid)
                    2'bx1  : encode = 1'd0;
                    2'b10  : encode = 1'd1;
                    default: encode = 1'd0;
                endcase
            4:  case (valid)
                    4'bxxx1: encode = 2'd0;
                    4'bxx10: encode = 2'd1;
                    4'bx100: encode = 2'd2;
                    4'b1000: encode = 2'd3;
                    default: encode = 2'd0;
                endcase
        endcase
    endfunction: encode

    generate
    if (mode == 1'b0) begin: simple

    simple_encoder #(
        .WIDTH (WIDTH)
    ) simple_encoder (
        .dec_vld (dec_vld & (-dec_vld)),
        .enc_idx (enc_idx),
        .enc_vld (enc_vld)
    );

    end: simple
    else begin: recursive
    
        if (WIDTH == SPLIT) begin: leaf

            // leaf
            assign enc_idx = encode(dec_vld);
            assign enc_vld = |dec_vld;

        end: leaf
        else begin: branch

            logic [SPLIT-1:0] [$clog2(WIDTH/SPLIT)-1:0] tmp_idx;
            logic [SPLIT-1:0]                           tmp_vld;

            priority_encoder #(
               .WIDTH (WIDTH/SPLIT),
               .SPLIT (SPLIT)
            ) encoder [SPLIT-1:0] (
                .dec_vld (dec_vld),
                .enc_idx (tmp_idx),
                .enc_vld (tmp_vld)
            );
        
            // branch
            assign enc_idx[WIDTH_LOG-1-:SPLIT_LOG  ] = encode(tmp_vld);
            assign enc_idx[WIDTH_LOG-1- SPLIT_LOG:0] = tmp_idx[enc_idx[WIDTH_LOG-1-:SPLIT_LOG]];
            assign enc_vld = |tmp_vld;

        end: branch

    end: recursive
    endgenerate

endmodule: priority_encoder
