module priority_encoder #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation
    bit mode = 1'b1
)(
    input  logic [SPLIT-1:0][WIDTH/SPLIT-1:0] dec_vld,
    output logic            [WIDTH_LOG  -1:0] enc_idx,
    output logic                              enc_vld
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

            logic [SPLIT-1:0] [WIDTH_LOG-SPLIT_LOG-1:0] sub_idx;
            logic [SPLIT-1:0]                           sub_vld;
            logic                       [SPLIT_LOG-1:0] tmp_idx;

            priority_encoder #(
               .WIDTH (WIDTH/SPLIT),
               .SPLIT (SPLIT)
            ) encoder [SPLIT-1:0] (
                .dec_vld (dec_vld),
                .enc_idx (sub_idx),
                .enc_vld (sub_vld)
            );

            // branch
            assign tmp_idx = encode(sub_vld);
            assign enc_idx = {tmp_idx, sub_idx[tmp_idx]};
            assign enc_vld = |sub_vld;

        end: branch

    end: recursive
    endgenerate

endmodule: priority_encoder
