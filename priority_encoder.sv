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
    input  logic            [WIDTH_LOG  -1:0] enc_pri,
    output logic            [WIDTH_LOG  -1:0] enc_idx,
    output logic                              enc_vld
);

    generate
    if (WIDTH == SPLIT) begin: leaf

        logic [SPLIT    -1:0] tmp_vld;
        logic [SPLIT_LOG-1:0] tmp_idx;

        // reorder decoded valid array for desired priority
        for (genvar i=0; i<SPLIT; i++) begin: reorder
            assign tmp_vld[i] = dec_vld[i[SPLIT_LOG-1:0] ^ enc_pri];
        end: reorder

        always_comb
        begin
            case (SPLIT)
                2:
                unique case (tmp_vld) inside
                    2'b?1  : tmp_idx = 1'd0;
                    2'b10  : tmp_idx = 1'd1;
                    default: tmp_idx = 1'd0;
                endcase

                4: case (IMPLEMENTATION)
                    0:  // casez
                    casez (tmp_vld)
                        4'b???1: tmp_idx = 2'd0;
                        4'b??10: tmp_idx = 2'd1;
                        4'b?100: tmp_idx = 2'd2;
                        4'b1000: tmp_idx = 2'd3;
                        default: tmp_idx = 2'dx;
                    endcase
                    1:  // unique   if
                    unique   if (tmp_vld ==? 4'b???1) tmp_idx = 2'd0;
                    else     if (tmp_vld ==? 4'b??10) tmp_idx = 2'd1;
                    else     if (tmp_vld ==? 4'b?100) tmp_idx = 2'd2;
                    else     if (tmp_vld ==? 4'b1000) tmp_idx = 2'd3;
                    else                              tmp_idx = 2'dx;
                    2:  // priority if
                    priority if (tmp_vld ==? 4'b???1) tmp_idx = 2'd0;
                    else     if (tmp_vld ==? 4'b??1?) tmp_idx = 2'd1;
                    else     if (tmp_vld ==? 4'b?1??) tmp_idx = 2'd2;
                    else     if (tmp_vld ==? 4'b1???) tmp_idx = 2'd3;
                    else                              tmp_idx = 2'dx;
                    3:  // unique   case inside
                    unique case (tmp_vld) inside
                        4'b???1: tmp_idx = 2'd0;
                        4'b??10: tmp_idx = 2'd1;
                        4'b?100: tmp_idx = 2'd2;
                        4'b1000: tmp_idx = 2'd3;
                        default: tmp_idx = 2'dx;
                    endcase
                    4:  // priority case inside
                    priority case (tmp_vld) inside
                        4'b???1: tmp_idx = 2'd0;
                        4'b??1?: tmp_idx = 2'd1;
                        4'b?1??: tmp_idx = 2'd2;
                        4'b1???: tmp_idx = 2'd3;
                        default: tmp_idx = 2'dx;
                    endcase
                endcase
            endcase
            enc_vld = |dec_vld;
        end

        // reorder
        assign enc_idx = tmp_idx ^ enc_pri;

    end: leaf
    else begin: branch

        logic             [WIDTH_LOG-SPLIT_LOG-1:0] sub_pri;
        logic [SPLIT-1:0] [WIDTH_LOG-SPLIT_LOG-1:0] sub_idx;
        logic [SPLIT-1:0]                           sub_vld;
        logic                       [SPLIT_LOG-1:0] brn_pri;
        logic                       [SPLIT_LOG-1:0] brn_idx;

        // input priorities
        assign {brn_pri, sub_pri} = enc_pri;

        // sub-branches
        priority_encoder #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) encoder_sub [SPLIT-1:0] (
            .dec_vld (dec_vld),
            .enc_pri (sub_pri),
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
            .enc_pri (brn_pri),
            .enc_idx (brn_idx),
            .enc_vld (enc_vld)
        );

        // multiplex sub-branches into branch
        assign enc_idx = {brn_idx, sub_idx[brn_idx]};

    end: branch
    endgenerate

endmodule: priority_encoder
