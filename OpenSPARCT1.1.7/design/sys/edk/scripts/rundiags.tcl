# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: rundiags.tcl
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
##
## Description : Scans through the "diags" directory. For each of the diag :
##		 i.	Recompiles the EDK Application Project with the
##			new memimage.c
##		 ii.	Configures FPGA with download.bit through Impact
##		 iii.	Connects to MB through MDM using XMD
##		 iv.	Downloads the mb-firmware/executable.elf
##		 v.		Downloads the binary version of the diag
##				executable at address location 0x240fc000
##		 vi.	Runs the diag
##		 vii. 	Points to memory location and the corresponding
##			value indicates whether Good/Bad/Unknown Trap
##		 
##		Usage  : xmd -tcl xmd_connect.tcl -d <diag-directory>
##				 -firmware <firmware-directory>
##				 -log <log-file-name>
##
##
#######################################################################

#######################################################################
## Parameters
#######################################################################
set param(diag_file)		""
set param(diag_dir)		"diags/"
set param(firmware)		"ccx-firmware-diag"
set param(log)			"rundiags.log"
set param(xmd_script)		"scripts/xmd_commands.tcl"
set param(model)		""
set param(suite)		""

#######################################################################
## Procedures
#######################################################################
proc writelogheader {filename msg} {
	set sysDate [clock seconds];
	set logfname [open $filename w];
	puts $logfname "############New Run##############\n";
	puts $logfname "Date : [clock format $sysDate -format %D]\n";
	close $logfname
}

proc writelog {filename msg} {
	set log [open $filename a+];
	puts $log $msg
	close $log
}


proc binaryStringToInt {binarystring} {
    set len [string length $binarystring]
    set retval 0
    for {set i 0} {$i < $len} {incr i} {
        set retval [expr $retval << 1]
        if {[string index $binarystring $i] == "1"} {
            set retval [expr $retval | 1]
        }
    }
    return $retval
}

proc parse_cmdline_options { optc optv } {
	global param parentdir

	set list_count 0
	set edk_count  0
	set d_count    0
	set proj_count 0
	set model_count 0
	set suite_count 0
	set log_count  0
	set xmd_count  0

	for {set i 0} { $i < $optc } { incr i } {
		set arg [lindex $optv $i]
		switch -- $arg {
	    	-edk { 
				incr i
				set parentdir [lindex $optv $i]
				if { $parentdir eq "" } {
					error "Must specify an EDK Project Directory\n"
				} elseif { ![file isdirectory $parentdir] } {
					error "$parentdir is not a valid directory\n"
				}
				incr edk_count
	    	}
			-list {
				incr i
				set param(diag_file) [lindex $optv $i]
				if { $param(diag_file) eq "" } {
					error "Must specify a diag list\n"
				} elseif { ![file exists $param(diag_file)] } {
					error "$param(diag_file) does not exist. Enter a valid diag list\n"
				} elseif { ![file readable $param(diag_file)] } {
					error "$param(diag_file) is not readable\n"
				}
				incr list_count
			}
			-model {
				incr i
				set param(model) [lindex $optv $i]
				incr model_count
			}
			-suite {
				incr i
				set param(suite) [lindex $optv $i]
				incr suite_count
			}
			-xmd_script {
				incr i
				set param(xmd_script) [lindex $optv $i]
				if { ![file exists $param(xmd_script)] } {
					error "$param(xmd_script) does not exist\n"
				} elseif { ![file readable $param(xmd_script)] } {
					error "$param(xmd_script) is not readable\n"
				}
				incr xmd_count
			}
			-d {
				incr i
				set param(diag_dir) [lindex $optv $i]
				if { ![file isdirectory $param(diag_dir)] } {
					error "$param(diag_dir) is not a valid directory"
				}	
				incr d_count
			}
			-proj {
				incr i
				set param(firmware) [lindex $optv $i]
				if { ![file isdirectory $parentdir/$param(firmware)] } {
					error "$parentdir/$param(firmware) is not a valid EDK software project\n"
				}
				incr proj_count
			}
			-log {
				incr i
				set param(log) [lindex $optv $i]
				if { ![file exists $param(log)] || ![file writeable $param(log)] } {
					puts "Info: Using default log file : $param(log)\n"
				} else {
					puts "Info: Using log file : $param(log)\n"
				}
				incr log_count
			}
		}
	}
	
	if { $edk_count eq 0 } {
		error "Must specify an EDK Project directory\n"
	} else {
		puts "Info: Using EDK Project : $parentdir\n"
	}
	
	if { $list_count eq 0 } {
		error "Must specify a diag list\n"
	} else {
		puts "Info: Using diag list : $param(diag_file)\n"
	}

	if { $model_count eq 0 } {
		error "Must specify a valid model\n"
	} else {
		puts "Info: Using model : $param(model)\n"
	}
	
	if { $suite_count eq 0 } {
		error "Must specify a valid regression suite\n"
	} else {
		puts "Info: Using regression suite : $param(suite)\n"
	}
	
	if { $xmd_count eq 0 } {
		puts "Info: Using default script : $param(xmd_script)\n"
	} else {
		puts "Info: Using XMD script : $param(xmd_script)\n"
	}
	
	if { $d_count eq 0 } {
		puts "Info: Using default diags directory : $parentdir$param(diag_dir)\n"
		set param(diag_dir) $parentdir$param(diag_dir)
	} else {
		puts "Info: Using diags directory : $param(diag_dir)\n"
	}
	
	if { $proj_count eq 0 } {
		puts "Info: Using default EDK software project : $param(firmware)\n"
	} else {
		puts "Info: Using EDK software project : $param(firmware)\n"
	}

	if { $log_count eq 0 } {
		puts "Info: Using default log file : $param(log)\n"
	}
}

#######################################################################
## Main Code
#######################################################################

set retval 0

set usage "\nUsage :\txtclsh.exe rundiags.tcl -edk <dir> -list <file> \[-d <dir>\]\n \
	\t\[-proj <name>\]\n\n \
	\t-edk <dir>\tPath to the EDK Project Directory\n \
	\t-list <file>\tList of diags to be processed\n \
	\t-model <string>\tmodel=core1, chip8, etc\n \
	\t-suite <string>\tsuite=core1_mini, thread1_mini, core1_full, etc\n \
        \t\t\twhere N=number of cores, M=threads per core,\n \
	\t\t\tand K=iteration id of sims\n \
	\t\[-xmd_script <file>\]\tScript with XMD commands running diags on FPGA\n \
	\t\[-d <dir>\]\tDirectory containing diag memory images\n \
	\t\[-proj <name>\]\tName of the EDK Software Application Project\n \
	\t\[-log <file>\]\tLog File\n\n"

set systemTime [clock seconds]
puts "\nRelease OpenSPARC 1.5 - rundiags.tcl 1.0"
puts "[clock format $systemTime]\n"


# Parse command line options
if { [catch {parse_cmdline_options $argc $argv} err] } {
    puts "\nError: $err"
    puts $usage
    return
}



set logfile $param(log)
writelogheader $logfile "default"


puts "#### Started Impact FPGA Configuration ####"
writelog $logfile "#### Started Impact FPGA Configuration ####"


# Download bit file to FPGA
# Impact is writing messages to STDERR, which causes catch to fail
# For now, redirect STDERR output from Impact to STDOUT so we can
# continue

if { [catch { exec xbash -q -c "cd $parentdir; \
	impact -batch etc/download.cmd 2>&1; exit;" } msg] } { 
	error $msg
}

puts "#### FPGA Configured Successfully"
writelog $logfile "#### FPGA Configured Successfully"


# Read list of diags to run
set infile [open $param(diag_file) r]
set name ""

while { [gets $infile name] >= 0 } {
    if { [string match "#*" $name] } {
		continue
	}
	if { [string match "" $name] } {
		continue
	}
	
	puts "#### Start processing diag : $name"
	writelog $logfile "#### Start processing diag : $name"

	set diagpath [glob "$param(diag_dir)/$param(model)/$param(suite)/$name"]

	if { ![file isdirectory $diagpath] } {
		puts "Warning: $diagpath is not found"
		puts "Warning: $name not processed"
		writelog $logfile "Warning: $diagpath is not found"
		writelog $logfile "Warning: $name not processed"
		continue
	}
	
# Get the memory image dump
	set mem_image [glob "$diagpath/mbfw_diag_memimage.c"];
	if { ![file readable $mem_image] } {
		puts "#### Unable to read T1 Mem Image File mbfw_diag_memimage.c"
		puts "Warning: $name not processed"
		writelog $logfile "#### Unable to read T1 Mem Image File mbfw_diag_memimage.c"
		writelog $logfile "Warning: $name not processed"
		continue
	} else {
		puts "#### Memory image mbfw_diag_memimage.c Found"
		puts "####    Path: $mem_image"
		writelog $logfile "#### Memory image mbfw_diag_memimage.c Found"
		writelog $logfile "####    Path: $mem_image"
	}
# Delete the previous executable
	puts "#### Deleting previous executable ####"
	if { [file exists "$parentdir/$param(firmware)/executable.elf"] } {
		if { [catch { exec rm -f "$parentdir/$param(firmware)/executable.elf" } msg] } {
			puts "Previous executable deletion error\n";
			puts "Check the file permissions\n";
			writelog $logfile "Previous executable deletion error\n";
			writelog $logfile "Check the file permissions\n";
			error $msg
		} else {
			puts "#### Previous executable removed ####"
		}
	} else {
		puts "#### No old executable ####"
		writelog $logfile "#### Previous executable not found ####"
	}
# Copy the memory image of the current diag to the EDK software project
# directory and recompile
	if { [catch { exec cp $mem_image "$parentdir/$param(firmware)/src/mbfw_diag_memimage.c" } msg] } {
		puts "Error: Copy of mbfw_diag_memimage.c Failed -- $msg"
		puts "Warning: $name not processed"
		writelog $logfile "Error: Copy of mbfw_diag_memimage.c Failed -- $msg"
		writelog $logfile "Warning: $name not processed"
		continue
	}
# Regenerate executable.elf
	if { [catch { exec xbash -q -c "cd $parentdir; \
				/usr/bin/make -f system.make $param(firmware)_program; \
				exit;" } msg] } {
		puts "#### Error in compiling new firmware source files -- $msg"
		puts "Warning: $name not processed"
		writelog $logfile "#### Error in compiling new firmware source files -- $msg"
		writelog $logfile "Warning: $name not processed"
		continue
	}

	puts "#### Firmware Code compiled ####"
	writelog $logfile "#### Firmware Code compiled ####"
	

	puts "#### Running Diag $name ####"
	writelog $logfile "#### Running Diag $name ####"

	set xcmd [exec xmd -tcl "$param(xmd_script)" -edk  "$parentdir" \
			-name "$name" \
			-proj "$param(firmware)" \
			-log  "$param(log)"]
	
	puts "#### Diag $name processed ####"
	writelog $logfile "#### Diag $name processed ####"
}

close $infile

puts "#### Run Complete...Exiting ####"
writelog $logfile "#### Run Complete...Exiting ####"


