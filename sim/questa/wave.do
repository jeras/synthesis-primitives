onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /encoder_tb/WIDTH
add wave -noupdate /encoder_tb/SPLIT
add wave -noupdate /encoder_tb/T
add wave -noupdate /encoder_tb/test
add wave -noupdate -expand /encoder_tb/wrong
add wave -noupdate -radix binary -childformat {{{/encoder_tb/dec_vld[3]} -radix binary} {{/encoder_tb/dec_vld[2]} -radix binary} {{/encoder_tb/dec_vld[1]} -radix binary} {{/encoder_tb/dec_vld[0]} -radix binary}} -expand -subitemconfig {{/encoder_tb/dec_vld[3]} {-height 19 -radix binary} {/encoder_tb/dec_vld[2]} {-height 19 -radix binary} {/encoder_tb/dec_vld[1]} {-height 19 -radix binary} {/encoder_tb/dec_vld[0]} {-height 19 -radix binary}} /encoder_tb/dec_vld
add wave -noupdate /encoder_tb/enc_pri
add wave -noupdate -expand /encoder_tb/enc_idx
add wave -noupdate /encoder_tb/enc_vld
add wave -noupdate -color Orange /encoder_tb/ref_enc_idx
add wave -noupdate /encoder_tb/ref_enc_vld
add wave -noupdate /encoder_tb/enc_neg
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/WIDTH}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/SPLIT}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/dec_vld}
add wave -noupdate -radix binary {/encoder_tb/gen_imp[0]/priority_encoder__casez/dec_neg}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/enc_pri}
add wave -noupdate -color Orange {/encoder_tb/gen_imp[0]/priority_encoder__casez/enc_idx}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/enc_vld}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/enc_neg}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[0]/WIDTH}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[0]/SPLIT}
add wave -noupdate -radix binary {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[0]/dec_vld}
add wave -noupdate -radix binary {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[0]/dec_neg}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[0]/enc_pri}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[0]/enc_idx}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[0]/enc_vld}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[0]/enc_neg}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[1]/WIDTH}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[1]/SPLIT}
add wave -noupdate -radix binary {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[1]/dec_vld}
add wave -noupdate -radix binary {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[1]/dec_neg}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[1]/enc_pri}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[1]/enc_idx}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[1]/enc_vld}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_sub[1]/enc_neg}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_brn/WIDTH}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_brn/SPLIT}
add wave -noupdate -radix binary {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_brn/dec_vld}
add wave -noupdate -radix binary {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_brn/dec_neg}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_brn/enc_pri}
add wave -noupdate -color Orange {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_brn/enc_idx}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_brn/enc_vld}
add wave -noupdate {/encoder_tb/gen_imp[0]/priority_encoder__casez/branch/encoder_brn/enc_neg}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {730 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 531
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {1953 ns}
