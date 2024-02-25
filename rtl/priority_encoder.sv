module priority_encoder #(
    int unsigned WIDTH = 32,
    int unsigned DIV = 2,
    bit mode = 1'b1
)(
    input  logic [       WIDTH -1:0] dec_vld,
    output logic [$clog2(WIDTH)-1:0] enc_idx,
    output logic                     enc_vld
);

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
    
        if (WIDTH == DIV) begin: leaf

            // leaf
            assign enc_idx =  dec_vld[0] ? 1'b0 : dec_vld[1];
            assign enc_vld = |dec_vld;

        end: leaf
        else begin: branch

            logic [DIV-1:0] [$clog2(WIDTH/DIV)-1:0] tmp_idx;
            logic [DIV-1:0]                         tmp_vld;

            priority_encoder #(
               .WIDTH (WIDTH/DIV)
            ) encoder [DIV-1:0] (
                .dec_vld (dec_vld),
                .enc_idx (tmp_idx),
                .enc_vld (tmp_vld)
            );
        
            // branch
            assign enc_idx = tmp_vld[DIV-2:0] ? {'0, tmp_idx[0]} : {tmp_vld[1], tmp_idx[1]};
            assign enc_vld = |tmp_vld;

        end: branch

    end: recursive
    endgenerate

endmodule: priority_encoder
