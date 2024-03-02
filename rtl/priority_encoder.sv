module priority_encoder #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation
    parameter  int unsigned MODE = 0  // supported modes are 0-LUT, 1-ADDER and 2-FUNCTION
)(
    input  logic [SPLIT-1:0][WIDTH/SPLIT-1:0] dec_vld,
    output logic            [WIDTH_LOG  -1:0] enc_idx,
    output logic                              enc_vld
);

    generate
    if (WIDTH == SPLIT) begin: leaf

        case (MODE)

            0:  // LUT
            always_comb
            begin
                case (SPLIT)
                    2:
                    unique case (dec_vld) inside
                        2'b?1  : enc_idx = 1'd0;
                        2'b10  : enc_idx = 1'd1;
                        default: enc_idx = 1'd0;
                    endcase
                    4:
                    priority if (dec_vld[0]) enc_idx = 2'd0;
                    else     if (dec_vld[1]) enc_idx = 2'd1;
                    else     if (dec_vld[2]) enc_idx = 2'd2;
                    else     if (dec_vld[3]) enc_idx = 2'd3;
                    else                     enc_idx = 2'dx;
//                    casez (dec_vld)
//                        4'b???1: enc_idx = 2'd0;
//                        4'b??10: enc_idx = 2'd1;
//                        4'b?100: enc_idx = 2'd2;
//                        4'b1000: enc_idx = 2'd3;
//                        default: enc_idx = 2'dx;
//                    endcase
//                    unique case (dec_vld) inside
//                        4'b???1: enc_idx = 2'd0;
//                        4'b??10: enc_idx = 2'd1;
//                        4'b?100: enc_idx = 2'd2;
//                        4'b1000: enc_idx = 2'd3;
//                        default: enc_idx = 2'dx;
//                    endcase
//                    priority case (dec_vld) inside
//                        4'b???1: enc_idx = 2'd0;
//                        4'b??1?: enc_idx = 2'd1;
//                        4'b?1??: enc_idx = 2'd2;
//                        4'b1???: enc_idx = 2'd3;
//                        default: enc_idx = 2'dx;
//                    endcase
                endcase
                enc_vld = |dec_vld;
            end


            1:  // ADDER
            always_comb
            begin
                logic [SPLIT-1:0] oht_vld;
                logic [SPLIT-1:0] neg_vld;
                {enc_vld, neg_vld} = $signed(-dec_vld);
                oht_vld = dec_vld & neg_vld;
                case (SPLIT)
                    2:
                    case (dec_vld)
                        2'b01  : enc_idx = 1'd0;
                        2'b10  : enc_idx = 1'd1;
                        default: enc_idx = 1'dx;
                    endcase
                    4:
                    case (dec_vld)
                        4'b0001: enc_idx = 2'd0;
                        4'b0010: enc_idx = 2'd1;
                        4'b0100: enc_idx = 2'd2;
                        4'b1000: enc_idx = 2'd3;
                        default: enc_idx = 2'dx;
                    endcase
                endcase
            end

        endcase

    end: leaf
    else begin: branch

        logic [SPLIT-1:0] [WIDTH_LOG-SPLIT_LOG-1:0] sub_idx;
        logic [SPLIT-1:0]                           sub_vld;
        logic                       [SPLIT_LOG-1:0] brn_idx;

        // sub-branches
        priority_encoder #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT)
        ) encoder_sub [SPLIT-1:0] (
            .dec_vld (dec_vld),
            .enc_idx (sub_idx),
            .enc_vld (sub_vld)
        );

        // branch
        priority_encoder #(
            .WIDTH (SPLIT),
            .SPLIT (SPLIT)
        ) encoder_brn (
            .dec_vld (sub_vld),
            .enc_idx (brn_idx),
            .enc_vld (enc_vld)
        );

        // multiplex sub-branches into branch
        assign enc_idx = {brn_idx, sub_idx[brn_idx]};

    end: branch
    endgenerate

endmodule: priority_encoder
