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
                    unique case (dec_vld) inside
                        2'b?1  : begin enc_idx_h = 1'd0; enc_idx_l = 1'd0;  enc_vld_h = 1'd0; enc_vld_l = 1'd0; end
                        2'b10  : begin enc_idx_h = 1'd1; enc_idx_l = 1'd1;  enc_vld_h = 1'd1; enc_vld_l = 1'd1; end
                        default: begin enc_idx_h = 1'd0; enc_idx_l = 1'd0;  enc_vld_h = 1'd0; enc_vld_l = 1'd0; end
                    endcase
                    1'b1:
                    unique case (dec_vld) inside
                        2'b?1  : begin enc_idx_h = 1'd0; enc_idx_l = 1'd0;  enc_vld_h = 1'd0; enc_vld_l = 1'd0; end
                        2'b10  : begin enc_idx_h = 1'd1; enc_idx_l = 1'd1;  enc_vld_h = 1'd1; enc_vld_l = 1'd1; end
                        default: begin enc_idx_h = 1'd0; enc_idx_l = 1'd0;  enc_vld_h = 1'd0; enc_vld_l = 1'd0; end
                    endcase
                endcase

//                4: case (IMPLEMENTATION)
//                    0:  // casez
//                    casez (dec_vld)
//                        4'b???1: enc_idx = 2'd0;
//                        4'b??10: enc_idx = 2'd1;
//                        4'b?100: enc_idx = 2'd2;
//                        4'b1000: enc_idx = 2'd3;
//                        default: enc_idx = 2'dx;
//                    endcase
//                    1:  // unique   if
//                    unique   if (dec_vld ==? 4'b???1) enc_idx = 2'd0;
//                    else     if (dec_vld ==? 4'b??10) enc_idx = 2'd1;
//                    else     if (dec_vld ==? 4'b?100) enc_idx = 2'd2;
//                    else     if (dec_vld ==? 4'b1000) enc_idx = 2'd3;
//                    else                              enc_idx = 2'dx;
//                    2:  // priority if
//                    priority if (dec_vld ==? 4'b???1) enc_idx = 2'd0;
//                    else     if (dec_vld ==? 4'b??1?) enc_idx = 2'd1;
//                    else     if (dec_vld ==? 4'b?1??) enc_idx = 2'd2;
//                    else     if (dec_vld ==? 4'b1???) enc_idx = 2'd3;
//                    else                              enc_idx = 2'dx;
//                    3:  // unique   case inside
//                    unique case (dec_vld) inside
//                        4'b???1: enc_idx = 2'd0;
//                        4'b??10: enc_idx = 2'd1;
//                        4'b?100: enc_idx = 2'd2;
//                        4'b1000: enc_idx = 2'd3;
//                        default: enc_idx = 2'dx;
//                    endcase
//                    4:  // priority case inside
//                    priority case (dec_vld) inside
//                        4'b???1: enc_idx = 2'd0;
//                        4'b??1?: enc_idx = 2'd1;
//                        4'b?1??: enc_idx = 2'd2;
//                        4'b1???: enc_idx = 2'd3;
//                        default: enc_idx = 2'dx;
//                    endcase
//                endcase
//                enc_vld = |dec_vld;
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
