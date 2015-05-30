# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: setupsim.tcl
# Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
# 
# The above named program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License version 2 as published by the Free Software Foundation.
# 
# The above named program is distributed in the hope that it will be 
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public
# License along with this work; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
# 
# ========== Copyright Header End ============================================
#####################################################################
## Source      : setupsim.tcl
##
## Description :
##		1. Cleans all the previous compiled executables
##		2. Sets the compiler option flags, linker script and
##			init_bram flag for the specified firmware application
##		3. Recompiles all the software application projects
##		4. Calls simgen to generate the HDL simulation files
##		5. Splits the ELF executable of the firmware application
##			into two files, bin0.dat and bin1.dat to be loaded into
##			memory array of the DDR memory model
##		6. Modifies the simulation/behavioral/system_init.v to point
##			to the new top model "board", instead of simgen
##			generated "system"
##		7. Modifies simulation/behavioral/system.do to point to the
##					SPARC simulation netlist
##		 
##		Usage  : xps -nw -scr setupsim.tcl system.xmp
##
#######################################################################

#######################################################################
## Parameters
#######################################################################
set param(firmware_app_name)	"ccx-firmware-diag"
set param(sparc_pcore_name)		"iop_fpga_v1_00_a"

set systemTime [clock seconds]
puts "\nRelease OpenSPARC 1.6 - setupsim.tcl 1.1"
puts "[clock format $systemTime]\n"

puts "Compiling with mb-gcc..."
 puts "Cleaning up existing executables..."
 run programclean

set curr_progccflags [xget_swapp_prop_value $param(firmware_app_name) progccflags]
set simmacro " -DSIMULATION"
set found [regexp -all {(?i)SIMULATION} $curr_progccflags]

if { $found } {
	puts "Compiler flags are set"
} else {
	puts "Setting compiler flags..."
	xset_swapp_prop_value $param(firmware_app_name) progccflags $curr_progccflags$simmacro
}

puts "Compiling the software apps..."
run program
puts "Calling simgen..."
run simmodel

puts "Modifying simulation files..."
if { ![file readable simulation/behavioral/system_init.v] } {
	puts "Unable to read simulation/behavioral/system_init.v!"
} else {
	exec sed {s/defparam\ system/defparam\ board.system_0/} simulation/behavioral/system_init.v > simulation/behavioral/.sinit.temp
	exec mv simulation/behavioral/.sinit.temp simulation/behavioral/system_init.v
    exec sed {s/INT_RAMB.//} simulation/behavioral/system_init.v > simulation/behavioral/.sinit.temp
	exec mv simulation/behavioral/.sinit.temp simulation/behavioral/system_init.v
}

set netlist [glob "pcores/$param(sparc_pcore_name)/sim/sparc_netlist.v"]

if { ![file readable $netlist] } {
	puts "Unable to read netlist"
} else {
exec sed {s/hdl\/verilog\/sparc\.v/sim\/sparc_netlist\.v/} simulation/behavioral/system.do > simulation/behavioral/.sdo.temp
exec mv simulation/behavioral/.sdo.temp simulation/behavioral/system.do
}

puts "Partitioning the firmware executable..."
exec mb-objcopy -O binary -R .vectors.reset -R .vectors.sw_exception -R .vectors.interrupt -R .vectors.hw_exception $param(firmware_app_name)/executable.elf $param(firmware_app_name)/executable.elf.bin
exec xilperl boardsim/bin2ascii.pl -nstripes 4 -stsize 2 -mdatawidth 8 -littleEnd $param(firmware_app_name)/executable.elf.bin boardsim/bin
exec rm -f $param(firmware_app_name)/executable.elf.bin

puts "Copying files to simulation/behavioral..."

foreach i [glob "boardsim/bin*.dat"] {
    exec cp $i simulation/behavioral/
    exec rm -f $i
}

exit


