module simple_encoder #(
    int unsigned WIDTH = 32
)(
    input  logic [       WIDTH -1:0] dec_vld,
    output logic [$clog2(WIDTH)-1:0] enc_idx,
    output logic                     enc_vld
);

    typedef bit [WIDTH-1:0] log_mask_t [$clog2(WIDTH)-1:0];

    // function definition
    function log_mask_t log_mask_f();
        for (int unsigned i=0; i<$clog2(WIDTH); i++) begin
            for (int unsigned j=0; j<WIDTH; j++) begin
                log_mask_f[i][j] = j[i];
            end
        end
    endfunction: log_mask_f

    localparam log_mask_t LOG_MASK = log_mask_f();

    function logic [$clog2(WIDTH)-1:0] logarithm_f (
        logic [WIDTH-1:0] value
    );
        for (int unsigned i=0; i<$clog2(WIDTH); i++) begin
            logarithm_f[i] = |(value & LOG_MASK[i]);
        end
    endfunction: logarithm_f

    assign enc_idx = logarithm_f(dec_vld);
    assign enc_vld = |dec_vld;

endmodule: simple_encoder
