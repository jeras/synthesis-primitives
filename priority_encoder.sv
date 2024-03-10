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
    input  logic            [WIDTH      -1:0] dec_vld_h,
    input  logic            [WIDTH      -1:0] dec_vld_l,
    input  logic            [WIDTH_LOG  -1:0] enc_pri,
    output logic            [WIDTH_LOG  -1:0] enc_idx_h,
    output logic            [WIDTH_LOG  -1:0] enc_idx_l,
    output logic                              enc_vld_h,
    output logic                              enc_vld_l
);

    generate
    if (WIDTH == SPLIT) begin: leaf

        always_comb
        begin
            case (SPLIT)
                2:
                unique case (enc_pri) inside
                    1'b0:
                    begin
                        unique case ({dec_vld_h[1], dec_vld_l[1], dec_vld_h[0]}) inside
                            3'b??_1: begin enc_idx_h = 1'd0; enc_vld_h = 1'd1; end
                            3'b?1_0: begin enc_idx_h = 1'd1; enc_vld_h = 1'd1; end
                            3'b10_0: begin enc_idx_h = 1'd1; enc_vld_h = 1'd1; end
                            default: begin enc_idx_h = 1'dx; enc_vld_h = 1'd0; end
                        endcase
                                     begin enc_idx_l = 1'd0; enc_vld_l = dec_vld_l[0]; end
                    end
                    1'b1:
                    begin
                                     begin enc_idx_h = 1'd1; enc_vld_h = dec_vld_h[1]; end
                        unique case ({dec_vld_l[1], dec_vld_h[0], dec_vld_l[0]}) inside
                            3'b?_?1: begin enc_idx_l = 1'd0; enc_vld_l = 1'd1; end
                            3'b?_1?: begin enc_idx_l = 1'd0; enc_vld_l = 1'd1; end
                            3'b1_0?: begin enc_idx_l = 1'd1; enc_vld_l = 1'd1; end
                            default: begin enc_idx_l = 1'dx; enc_vld_l = 1'd0; end
                        endcase
                    end
                endcase
            endcase
        end

    end: leaf
    else begin: branch

        logic             [WIDTH_LOG-SPLIT_LOG-1:0] sub_pri;
        logic [SPLIT-1:0] [WIDTH_LOG-SPLIT_LOG-1:0] sub_idx_h;
        logic [SPLIT-1:0] [WIDTH_LOG-SPLIT_LOG-1:0] sub_idx_l;
        logic [SPLIT-1:0]                           sub_vld_h;
        logic [SPLIT-1:0]                           sub_vld_l;
        logic                       [SPLIT_LOG-1:0] brn_pri;
        logic                       [SPLIT_LOG-1:0] brn_idx_h;
        logic                       [SPLIT_LOG-1:0] brn_idx_l;

        // input priorities
        assign {brn_pri, sub_pri} = enc_pri;

        // sub-branches
        priority_encoder #(
            .WIDTH (WIDTH/SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) encoder_sub [SPLIT-1:0] (
            .dec_vld_h (dec_vld_h),
            .dec_vld_l (dec_vld_l),
            .enc_pri   (sub_pri  ),
            .enc_idx_h (sub_idx_h),
            .enc_idx_l (sub_idx_l),
            .enc_vld_h (sub_vld_h),
            .enc_vld_l (sub_vld_l)
        );

        // branch
        priority_encoder #(
            .WIDTH (SPLIT),
            .SPLIT (SPLIT),
            .IMPLEMENTATION (IMPLEMENTATION)
        ) encoder_brn (
            .dec_vld_h (sub_vld_h),
            .dec_vld_l (sub_vld_l),
            .enc_pri   (brn_pri  ),
            .enc_idx_h (brn_idx_h),
            .enc_idx_l (brn_idx_l),
            .enc_vld_h (enc_vld_h),
            .enc_vld_l (enc_vld_l)
        );

        // multiplex sub-branches into branch
        assign enc_idx_h = {brn_idx_h, sub_idx_h[brn_idx_h]};
        assign enc_idx_l = {brn_idx_l, sub_idx_l[brn_idx_l]};

    end: branch
    endgenerate

endmodule: priority_encoder
