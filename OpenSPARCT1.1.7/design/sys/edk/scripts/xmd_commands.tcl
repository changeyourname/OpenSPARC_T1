# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: xmd_commands.tcl
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
#######################################################################
## Parameters
#######################################################################
set param(diag-file)		""
set param(name)			""
set param(firmware)		""
set param(log)			""
set param(start-addr)		"0x80102000"
set param(trap-addr)		"0x8ffffff0"
set param(good-trap-addr)	"0x8ffffff4"
set param(bad-trap-addr)	"0x8ffffff8"
set param(err-trap-addr)	"0x8ffffffc"

proc writelog {filename msg} {
	set log [open $filename a+];
	puts $log $msg
	close $log
}

proc parse_cmdline_options { optc optv } {
	global param parentdir tgt

	for {set i 0} { $i < $optc } { incr i } {
		set arg [lindex $optv $i]
		switch -- $arg {
			-edk { 
				incr i
				set parentdir [lindex $optv $i]
			}
			-name {
				incr i
				set param(name) [lindex $optv $i]
			}
			-proj {
				incr i
				set param(firmware) [lindex $optv $i]
			}
			-log {
				incr i
				set param(log) [lindex $optv $i]
			}
		}
	}
}

set tgt 0

parse_cmdline_options $argc $argv

puts "Info: Using EDK Project : $parentdir"
puts "Info: Using firmware    : $param(firmware)"
puts "Info: Using log file    : $param(log)\n"

# Connect to MB through MDM
set xcmd [xconnect mb mdm -cable type xilinx_platformusb port USB2]

puts "#### Connected to MB MDM UART target"
writelog $param(log) "#### Connected to MB MDM UART target"

set elffile "$parentdir/$param(firmware)/executable.elf"
	
puts "#### Downloading Firmware ELF ####"
writelog $param(log) "#### Downloading Firmware ELF ####"

# Download firmware Elf file
xdownload $tgt $elffile

set word [xwmem $tgt $param(trap-addr) 1 w 0x50505050]
set word [xwmem $tgt $param(good-trap-addr) 1 w 0xfedcba98]
set word [xwmem $tgt $param(bad-trap-addr) 1 w 0x76543210]
set word [xwmem $tgt $param(err-trap-addr) 1 w 0xffff5555]

set word [xwmem $tgt $param(trap-addr) 1 w 0x50505050]

# Run the diag
while { 1 } {
	xcontinue $tgt

	set x 0
	while { $x < 9999999 } {
		set x [expr {$x + 1}]
	}
			
	xstop $tgt

   	set word [xrmem $tgt $param(trap-addr) 1 w]
	set gtrap [xrmem $tgt $param(good-trap-addr) 1 w]
	set btrap [xrmem $tgt $param(bad-trap-addr) 1 w]
	set etrap [xrmem $tgt $param(err-trap-addr) 1 w]
			
# Check if Good Trap or Bad Trap Reached
	if { $word == $gtrap } {
		puts "#### Done...Diag $param(name) reached Good Trap ####"
		puts "#### Exiting... ####"
		writelog $param(log) "#### Done...Diag $param(name) reached Good Trap ####"
		writelog $param(log) "#### Exiting ####"
		break
	}
	if { $word == $btrap } {
		puts "Failed...Diag $param(name) reached Bad Trap ####"
		puts "Exiting... ####"
		writelog $param(log) "Failed...Diag $param(name) reached Bad Trap ####"
		writelog $param(log) "Exiting... ####"
		break
	}
	if { $word == $etrap } {
		puts "Failed...Diag $param(name) reached unknown error condition ####"
		puts "Exiting... ####"
		writelog $param(log) "Failed...Diag $param(name) reached unknown error condition ####"
		writelog $param(log) "Exiting... ####"
		break
	}
}
# Disconnect the MB processor
xreset $tgt 0x40
xreset $tgt 0x80
xdisconnect $tgt

