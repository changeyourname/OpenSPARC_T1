# Make sure to set EDK to compile for verilog
do system.do

set edk_project "../.."
set board_model_path $edk_project/boardsim
set ddr_model_path $edk_project/boardsim/dram_model
#vlog -incr -work work +define+sg5 +define+x16 +define+FULL_MEM \
#   +incdir+$ddr_model_path $ddr_model_path/ddr.v
vlog -incr -work work +define+sg37e +define+x16 +define+SODIMM +define+MAX_MEM \
   +incdir+$ddr_model_path $ddr_model_path/ddr2.v
vlog -incr -work work +define+x16 +define+SODIMM \
   +incdir+$ddr_model_path $ddr_model_path/ddr2_module.v
vlog -incr -work work $board_model_path/pcx_monitor.v {+incdir+}
vlog -incr -work work $board_model_path/board.v {+incdir+}

#vsim -voptargs="+acc=rnbmpl" board system_conf glbl 
vsim -t ps -L unisims_ver -voptargs="+acc=rnbmpl" board system_conf glbl 
# Add Board-level signals
add wave -divider {Board Clock & Reset}
add wave -radix hexadecimal /board/sys_rst_pin
add wave -radix hexadecimal /board/sys_clk_pin
add wave -divider {MicroBlaze PC}
set mb_path "/board/system_0/microblaze_0"
add wave -radix hexadecimal $mb_path/trace_pc
add wave $mb_path/trace_valid_instr
add wave -radix hexadecimal $mb_path/trace_instruction
add wave -radix hexadecimal $mb_path/trace_reg_write
add wave -radix hexadecimal $mb_path/trace_reg_addr
# Add SPARC signals
set sparc_path "/board/system_0/iop_fpga_0/iop_fpga_0"
add wave -divider {Sparc PCX Bus}
add wave -radix binary $sparc_path/spc_pcx_req_pq
add wave -radix binary $sparc_path/spc_pcx_atom_pq
add wave -radix hexadecimal $sparc_path/spc_pcx_data_pa
add wave -radix binary $sparc_path/pcx_spc_grant_px
add wave -divider {Sparc CPX Bus}
add wave -radix binary $sparc_path/cpx_spc_data_rdy_cx2
add wave -radix hexadecimal $sparc_path/cpx_spc_data_cx2
add wave -divider {Sparc I/O Signals}
add wave -radix hexadecimal -ports $sparc_path/sparc0/*
quietly WaveActivateNextPane
add wave -divider {DDR2 DRAM DIMM I/O}
add wave -radix hexadecimal -ports /board/ddr2_module/*
force /board/sys_rst_pin 0, 1 1us
force /board/sys_clk_pin 0, 1 5ns -r 10ns
run 16000us
vsim -quit
