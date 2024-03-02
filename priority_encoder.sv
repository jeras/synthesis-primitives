module priority_encoder #(
    // size parameters
    parameter  int unsigned WIDTH = 32,
    parameter  int unsigned SPLIT = 2,
    // size local parameters
    localparam int unsigned WIDTH_LOG = $clog2(WIDTH),
    localparam int unsigned SPLIT_LOG = $clog2(SPLIT),
    // implementation
    // 0 - casez
    // 1 - unique   if
    // 2 - priority if
    // 3 - unique   case inside
    // 4 - priority case inside
    parameter  int unsigned IMPLEMENTATION = 4
)(
//    input  logic [SPLIT-1:0][WIDTH/SPLIT-1:0] dec_vld,
    input  logic            [WIDTH      -1:0] dec_vld,
    output logic            [WIDTH_LOG  -1:0] enc_idx,
    output logic                              enc_vld
);

    generate
    if (WIDTH == SPLIT) begin: leaf

        always_comb
        begin
            case (SPLIT)
                2:
                unique case (dec_vld) inside
                    2'b?1  : enc_idx = 1'd0;
                    2'b10  : enc_idx = 1'd1;
                    default: enc_idx = 1'd0;
                endcase

                4: case (IMPLEMENTATION)
                    0:  // casez
                    casez (dec_vld)
                        4'b???1: enc_idx = 2'd0;
                        4'b??10: enc_idx = 2'd1;
                        4'b?100: enc_idx = 2'd2;
                        4'b1000: enc_idx = 2'd3;
                        default: enc_idx = 2'dx;
                    endcase
                    1:  // unique   if
                    unique   if (dec_vld ==? 4'b???1) enc_idx = 2'd0;
                    else     if (dec_vld ==? 4'b??10) enc_idx = 2'd1;
                    else     if (dec_vld ==? 4'b?100) enc_idx = 2'd2;
                    else     if (dec_vld ==? 4'b1000) enc_idx = 2'd3;
                    else                              enc_idx = 2'dx;
                    2:  // priority if
                    priority if (dec_vld ==? 4'b???1) enc_idx = 2'd0;
                    else     if (dec_vld ==? 4'b??1?) enc_idx = 2'd1;
                    else     if (dec_vld ==? 4'b?1??) enc_idx = 2'd2;
                    else     if (dec_vld ==? 4'b1???) enc_idx = 2'd3;
                    else                              enc_idx = 2'dx;
                    3:  // unique   case inside
                    unique case (dec_vld) inside
                        4'b???1: enc_idx = 2'd0;
                        4'b??10: enc_idx = 2'd1;
                        4'b?100: enc_idx = 2'd2;
                        4'b1000: enc_idx = 2'd3;
                        default: enc_idx = 2'dx;
                    endcase
                    4:  // priority case inside
                    priority case (dec_vld) inside
                        4'b???1: enc_idx = 2'd0;
                        4'b??1?: enc_idx = 2'd1;
                        4'b?1??: enc_idx = 2'd2;
                        4'b1???: enc_idx = 2'd3;
                        default: enc_idx = 2'dx;
                    endcase
                endcase
            endcase
            enc_vld = |dec_vld;
        end

    end: leaf
    else begin: branch

        logic [SPLIT-1:0] [WIDTH_LOG-SPLIT_LOG-1:0] sub_idx;
        logic [SPLIT-1:0]                           sub_vld;
        logic                       [SPLIT_LOG-1:0] brn_idx;

        // sub-branches
        priority_encoder #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) encoder_sub [SPLIT-1:0] (
            .dec_vld (dec_vld),
            .enc_idx (sub_idx),
            .enc_vld (sub_vld)
        );

        // branch
        priority_encoder #(
            .WIDTH (SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
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
