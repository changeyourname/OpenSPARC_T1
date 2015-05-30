# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: CmdParserNi.py
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
"""Niagara command parser
"""

import re, string, sys, types

## # if nasAPI is not available (which is the case in MOM mode), we can make do
## # without it.
## try:
##     import nasAPI
## except:
##     #sys.stderr.write('WARNING: nasAPI module is not available\n')
##     pass

from ni import RegisterMap
from ni.CmdParserNiCmd import *

# the following breakpoint constants (BP_*) must be consistent with
# include/system/BreakpointEntry.h
BP_PC = 1
BP_VA = 2
BP_PA = 3

hexRE = re.compile('^0[xX][0-9A-Fa-f]+$')
octRE = re.compile('^0[0-7]+$')
# split command line to locate any % variable, e.g., %pc
splitRE = re.compile('[^%_\w]')

### need to support the following commands:

SYM_PA = 'p:'
SYM_VA = 'v:'

NAME_CPU = 'cpu'
NAME_CORE = 'core'
NAME_UCORE = 'ucore'
NAME_STRAND = 'strand'

NAME_breakpoint = 'phys_mem'
NAME_context = 'TODO'
NAME_image = 'TODO'
NAME_memory_space = 'phys_mem'
NAME_port_space = 'TODO'
NAME_processor = 'th'
NAME_rtl_intf = 'TODO'
NAME_swerver_memory = 'swvmem'
NAME_swerver_proc_mmu = 'swmmu'
NAME_swerver_thread_mmu = 'stmmu'

CMD_action = 'action'
CMD_add_directory = 'add-directory'
CMD_api_apropos = 'api-apropos'
CMD_api_help = 'api-help'
CMD_apropos = 'apropos'
CMD_break_cr = 'break-cr'
CMD_break_exception = 'break-exception'
CMD_break_hap = 'break-hap'
CMD_break_io = 'break-io'
CMD_breakpoint_break = 'break'
CMD_catch_exception = 'catch-exception'
CMD_clear_directories = 'clear-directories'
CMD_cmpregs = 'cmpregs'
CMD_command_list = 'command-list'
CMD_context_off = 'off'
CMD_context_on = 'on'
CMD_cycle_break = 'cycle-break'
CMD_cycle_break_absolute = 'cycle-break-absolute'
CMD_debug_level = 'debug-level'
CMD_delete = 'delete'
CMD_device_interrupt = 'device-interrupt'
CMD_devs = 'devs'
CMD_disable = 'disable'
CMD_disable_real_time_mode = 'disable-real-time-mode'
CMD_disassemble = 'disassemble'
CMD_display = 'display'
CMD_dstc_disable = 'dstc-disable'
CMD_dstc_enable = 'dstc-enable'
CMD_echo = 'echo'
CMD_enable = 'enable'
CMD_enable_external_commands = 'enable-external-commands'
CMD_enable_real_time_mode = 'enable-real-time-mode'
CMD_eosl = 'eosl'
CMD_expect = 'expect'
CMD_gdb_remote = 'gdb-remote'
CMD_get = 'get'
CMD_help = 'help'
CMD_hex = 'hex'
CMD_ignore = 'ignore'
CMD_image_add_diff_file = 'add-diff-file'
CMD_image_add_partial_diff_file = 'add-partial-diff-file'
CMD_image_commit = 'commit'
CMD_image_limit_memory = 'limit-memory'
CMD_image_save = 'save'
CMD_image_x = 'x'
CMD_instruction_profile_mode = 'instruction-profile-mode'
CMD_io = 'io'
CMD_io_buffer = 'io-buffer'
CMD_istc_disable = 'istc-disable'
CMD_istc_enable = 'istc-enable'
CMD_le_checksum = 'le-checksum'
CMD_le_permissions = 'le-permissions'
CMD_list_attributes = 'list-attributes'
CMD_list_breakpoints = 'list-breakpoints'
CMD_list_classes = 'list-classes'
CMD_list_failed_modules = 'list-failed-modules'
CMD_list_haps = 'list-haps'
CMD_list_modules = 'list-modules'
CMD_list_namespaces = 'list-namespaces'
CMD_list_profilers = 'list-profilers'
CMD_list_vars = 'list-vars'
CMD_load_binary = 'load-binary'
CMD_load_file = 'load-file'
CMD_load_module = 'load-module'
CMD_load_veri_file = 'load-veri-file'
CMD_logical_to_physical = 'logical-to-physical'
CMD_magic_break_disable = 'magic-break-disable'
CMD_magic_break_enable = 'magic-break-enable'
CMD_memory_profile = 'memory-profile'
CMD_memory_space_map = 'map'
CMD_module_list_refresh = 'module-list-refresh'
CMD_mmuregs = 'mmuregs'
CMD_native_path = 'native-path'
CMD_new_command = 'new_command'
CMD_new_context = 'new-context'
CMD_output_radix = 'output-radix'
CMD_pdisable = 'pdisable'
CMD_pdisassemble = 'pdisassemble'
CMD_penable = 'penable'
CMD_pio = 'pio'
CMD_pipe = 'pipe'
CMD_pli_run = 'pli-run'
CMD_port_space_map = 'map'
CMD_pregs = 'pregs'
CMD_fpregs = 'fpregs'
CMD_pregs_all = 'pregs-all'
CMD_pregs_hyper = 'pregs-hyper'
#CMD_print = 'print'
CMD_print_directories = 'print-directories'
CMD_print_double_regs = 'print-double-regs'
CMD_print_event_queue = 'print-event-queue'
CMD_print_float_regs = 'print-float-regs'
CMD_print_float_regs_raw = 'print-float-regs-raw'
CMD_print_instruction_queue = 'print-instruction-queue'
CMD_print_profile = 'print-profile'
CMD_print_statistics = 'print-statistics'
CMD_print_time = 'print-time'
CMD_prof_page_details = 'prof-page-details'
CMD_prof_page_map = 'prof-page-map'
CMD_prof_weight = 'prof-weight'
CMD_pselect = 'pselect'
CMD_quit = 'quit'
CMD_read_configuration = 'read-configuration'
CMD_read_fp_reg_i = 'read-fp-reg-i'
CMD_read_fp_reg_x = 'read-fp-reg-x'
CMD_read_reg = 'read-reg'
CMD_read_sw_pcs = 'read-sw-pcs'
CMD_read_th_ctl_reg = 'read-th-ctl-reg'
CMD_read_th_fp_reg_i = 'read-th-fp-reg-i'
CMD_read_th_fp_reg_x = 'read-th-fp-reg-x'
CMD_read_thread_status = 'read-thread-status'
CMD_read_th_reg = 'read-th-reg'
CMD_resolve_file = 'resolve-file'
CMD_rtl_cycle = 'rtl_cycle'
CMD_rtl_intf_info = 'info'
CMD_run = 'run'
CMD_runfast = 'runfast'
CMD_whatis = 'whatis'
CMD_run_command_file = 'run-command-file'
CMD_run_python_file = 'run-python-file'
CMD_set = 'set'
CMD_set_context = 'set-context'
CMD_set_pattern = 'set-pattern'
CMD_set_pc = 'set-pc'
CMD_set_prefix = 'set-prefix'
CMD_set_prof_weight = 'set-prof-weight'
CMD_set_substr = 'set-substr'
CMD_special_interrupt = 'special-interrupt'
CMD_sstepi = 'sstepi'
CMD_stc_status = 'stc-status'
CMD_step_break = 'step-break'
CMD_step_break_absolute = 'step-break-absolute'
CMD_step_cycle = 'step-cycle'
CMD_step_instruction = 'step-instruction'
CMD_stop = 'stop'
CMD_swerver_memory_debug = 'debug'
CMD_swerver_memory_info = 'info'
CMD_swerver_proc_mmu_i_tlb_entry = 'i-tlb-entry'
CMD_swerver_proc_mmu_probe = 'probe'
CMD_swerver_proc_mmu_regs = 'regs'
CMD_swerver_proc_mmu_tlb = 'tlb'
CMD_swerver_proc_mmu_trace = 'trace'
CMD_swerver_thread_mmu_probe = 'probe'
CMD_swerver_thread_mmu_read_spu_trap = 'read-spu-trap'
CMD_swerver_thread_mmu_regs = 'regs'
CMD_swerver_thread_mmu_set_spu_trap = 'set-spu-trap'
CMD_swerver_thread_mmu_trace = 'trace'
CMD_swrun = 'swrun'
CMD_trace_cr = 'trace-cr'
CMD_trace_exception = 'trace-exception'
CMD_trace_hap = 'trace-hap'
CMD_trace_io = 'trace-io'
CMD_trap_info = 'trap-info'
CMD_unbreak = 'unbreak'
CMD_undisplay = 'undisplay'
CMD_unload_module = 'unload-module'
CMD_write_configuration = 'write-configuration'
CMD_write_fp_reg_i = 'write-fp-reg-i'
CMD_write_fp_reg_x = 'write-fp-reg-x'
CMD_write_reg = 'write-reg'
CMD_write_th_ctl_reg = 'write-th-ctl-reg'
CMD_write_th_fp_reg_i = 'write-th-fp-reg-i'
CMD_write_th_fp_reg_x = 'write-th-fp-reg-x'
CMD_write_thread_status = 'write-thread-status'
CMD_x = 'x'
CMD_xp = 'xp'

# extra commands
CMD_ssi      = 'ssi'
CMD_ALIAS    = 'alias'
CMD_UNALIAS  = 'unalias'
#CMD_RESET    = 'reset'


class BreakPoint:
    """
    """
    def __init__ (self, id, sid, addr, cmd, type):
	"""
	"""
	self.id = id
	self.sid = sid
	self.addr = addr
	self.hitCount = 0
	self.ignore = 0
	self.enable = 1
	self.justHit = 0
	self.type = type
	self.action = []
	i = cmd.find('{')
	if i > -1:
	    j = cmd.rfind('}')
	    tokens = cmd[i+1:j].split(';')
	    #print 'DBX: cmd=%s, tokens=%s' % (cmd, tokens) #DBX
	    k = 0
	    while k < len(tokens):
		self.action.append(tokens[k].strip())
		k += 1


    def __str__ (self):
	"""
	"""
	return 'breakpoint=%d, sid=%d, addr=%#x, type=%s, enable=%d, hit=%d, ignore=%d, action=%s' % (self.id, self.sid, self.addr, self.type, self.enable, self.hitCount, self.ignore, self.action)


    def isHit (self, pc):
	"""
	TODO  we don't really use this any more, as of 5/10/05, and this
	      function only handle PC
	"""
	if self.enable == 1 and self.addr == pc:
	    # a hit, is there an ignore count or do we just hit this same pc
	    # in the previous step?
	    self.hitCount += 1
	    if ((self.ignore == 0 and self.justHit == 0) or
		(self.ignore > 0 and self.hitCount > self.ignore)):
		hit = 1
		self.justHit = 1
		self.hitCount = 0
	    else:
		hit = 0
		self.justHit = 0

## 	    if self.hitCount > self.ignore:
## 		self.hitCount = 0
## 		if (self.justHit == 1) and (self.ignore > 0):
## 		    self.justHit = 0
## 		else:
## 		    self.justHit = 1
## 		    hit = 1
## 	    else:
## 		self.justHit = 1

	else:
	    hit = 0
	    self.justHit = 0

	return hit


class CmdParserNi:
    """
    """

    def __init__ (self, riesReposit):
	"""
	"""
	self.riesReposit = riesReposit

	self.topName = self.riesReposit.topName
	self.ncpus = self.riesReposit.ncpus
	self.ncores = self.riesReposit.ncores
	self.nucores = self.riesReposit.nucores
	self.nstrands = self.riesReposit.nstrands

	self.nSpregs = self.riesReposit.nSpregs
	self.nDpregs = self.riesReposit.nDpregs
	self.nQpregs = self.riesReposit.nQpregs
	self.nWinregs = 16	#************CONSTANTS***********
	self.nWin = 8		#there should be a better way to initialize from backend


	#sys.stderr.write('***config\n');
	#sys.stderr.write(str(self.topName+' '))
	#sys.stderr.write(str(self.ncpus))
	#sys.stderr.write(str(self.ncores))
	#sys.stderr.write(str(self.nstrands))
	#sys.stderr.write('\nend config***\n')

	if self.nucores == 0:
	    self.cpusize = self.ncores * self.nstrands
	    self.coresize = self.nstrands
	    self.ucoresize = 1
	else:
	    self.cpusize = self.ncores * self.nucores * self.nstrands
	    self.coresize = self.nucores * self.nstrands
	    self.ucoresize = self.nstrands

	self.nstrandObjs = self.cpusize * self.ncpus

	# thread state: 1 == enabled
	self.thdEnable = { 0:1 }
	# instr executed on each strand
	self.instrCount = { 0:0 }

	# breakpoint, id:vaddr (in uint64 format)
	self.bpoint = { }
	# next breakpoint id
	self.nextBpoint = 0

	# the last strand that issued 'ssi'.
	# TODO  if a user call backend step() directly, it will bypass this 
	#       lastTid tracking, it will also bypass breakpoint handling.
	# ---> with breakpoint set in backend strand.step(), we can catch
	#      breakpoint now. 4/13/05
	self.lastTid = 0
	# thread/core/cpu mapping
	self.strandMap = { }
	self.ucoreMap = { }
	self.coreMap = { }
	self.cpuMap = { }
	# command alias
	self.alias = { }

	self.regmap = RegisterMap.RegisterMap()
	# command mapping
	self.cmdRE = { }
	# docs
	self.DOCS = { }
	# command extension
	self.cmdExt = { }
	# register interactive commands
	self.initCmd()
	# allow registration of a command map to re-direct commands to
	# a different command parser.
	self.cmdMap = None

#######################################
#Function to check the argument types

	self.intStr = '(^[0-9]+[lL]?$)|(^0[xX][0-9a-fA-F]+[lL]?$)'
	self.intStrRE = re.compile(self.intStr)
		
    def checkArgs(self,Args):
	"""Return a list of boolean values.
		True if the arg is an int/long
		False otherwise
	"""
	retval = []
	for arg in Args:
		matchOb = self.intStrRE.match(arg)
		if matchOb == None:
			retval.append(False)
		else:
			retval.append(True)
	return retval


    # Function to code double and quad precision 
    # register numbers
    def codeFpreg(self,regnum, type):
	"""type = 0, code double precision
	   	= 1, code quad precision
	"""
	val = int(regnum)
	if type == 0:
		return str(val << 1) # | (val & 0x10 >> 4)) 
	else:
		return str(val << 2) # & ~0x3) << 1) | (val & 0x10 >> 4))


    def truncVal(self, val, type):
	"""truncate string if larger than
	   16 or 8 bytes depending on 
           whether type is 1 or 0
	"""
	#sys.stderr.write('DB: truncVal(): <%s>\n' % val)
	if val.startswith('0X') or val.startswith('0x'):
	    intval = long(val,16)
	else:
	    intval = long(val,10)

	# append 'L' to value to quiet complain about larger than 32bit value
	hexval = '%xL' % intval
	length = len(hexval) - 1
	#sys.stderr.write('DBX: truncVal(): int=%#x, hex=%s, len=%d\n' % (intval, hexval, length)) #DBX
	if type == 0 and length > 8:
	    return '0x'+hexval[length-8:]
	elif type == 1 and length > 16:
	    return '0x'+hexval[length-16:]
	else:
	    return '0x'+hexval


    def myInt(self,val):
	val = val.upper()
	if val.startswith('0X'):
		return int(val,16)
	else:
		return int(val)

    def polishCommand (self, cmd):
	"""append 'L' to hex values and remove the command's trailing comment
	"""
	#sys.stderr.write('DBX: polishCommand: cmd=<%s>\n' % (cmd)) #DBX

	# TODO  be aware that if '#' is part of a valid expression, this will
	#       cause problem.
## 	i = cmd.find('#')
## 	if i > -1:
## 	    cmd = cmd[:i]
	#print 'input cmd=%s' % cmd #DBX
	prev = 0
	i = cmd.find('#')
	while i > -1:
	    # make sure the # is not embedded in '...' or "..."
	    # 'break' command can have {action...}, so don't remove the # in
	    # there either.
	    j1 = cmd.rfind("'", prev, i)
	    j2 = cmd.find("'", i)
	    k1 = cmd.rfind('"', prev, i)
	    k2 = cmd.find('"', i)
	    l1 = cmd.rfind('{', 0, i)
	    l2 = cmd.find('}', i)
	    #print 'i=%d j1=%d j2=%d k1=%d k2=%d l1=%d l2=%d' % (i, j1, j2, k1, k2, l1, l2) #DBX
	    if (((j1 > -1) and (j2 > -1) and (j1 < i) and (i < j2)) or
		((k1 > -1) and (k2 > -1) and (k1 < i) and (i < k2)) or
		((l1 > -1) and (l2 > -1) and (l1 < i) and (i < l2))):
		# this one is embedded in '...' or "...", not a comment sign
		# let's look for the next one
		prev = i
		i = cmd.find('#', i+1)
	    else:
		break
	#print 'i=%d before cmd=%s' % (i, cmd) #DBX
	if i > -1:
	    cmd = cmd[:i]
	#print '     after  cmd=%s' % cmd #DBX

	# append 'L' to any hex value that has at least 32 bits, no, just
	# do it to all hex is simplier. Be aware of the overhead involved.
	# TODO  take this out once python 2.4 fix the problem, i.e.,
	#       treats number like 0x80000000 as negative int32.
	tokens = cmd.split()
	i = 1
	while i < len(tokens):
	    if re.match(hexRE, tokens[i]) and tokens[i][-1].upper() != 'L':
		tokens[i] = tokens[i] + 'L'
	    i += 1

	#sys.stderr.write('DBX: polishCommand: cmd2=<%s>\n' % ' '.join(tokens)) #DBX
	return ' '.join(tokens)


    def initCmd (self):
	"""
	"""
	#self.dbx('enter initCmd\n')

	# NAME
	#    % - read register by name 
	# SYNOPSIS
	#    % "reg-name" 
	cmdSyntax = '^%[a-zA-Z]+[a-zA-Z_\d]*'
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleRegName

	# NAME
	#    <breakpoint>.break, <breakpoint>.tbreak, break - set breakpoint 
	# SYNOPSIS
	#    <breakpoint>.break address [length] [-r] [-w] [-x] 
	#    <breakpoint>.tbreak address [length] [-r] [-w] [-x] 
	#    break address [length] [-r] [-w] [-x] 
	#cmdSyntax = '^(%s\d+\.)?(t)?%s\s+0[Xx][\dA-Fa-f]+' % (NAME_breakpoint, CMD_breakpoint_break)
	cmdSyntax = '^(%s\d+\.)?(t)?%s\s+' % (NAME_breakpoint, CMD_breakpoint_break)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleBreak

	# NAME
	#    <context>.on, <context>.off - switch on context object 
	# SYNOPSIS
	#    <context>.off
	#    <context>.on
	cmdSyntax = '^%s\d+\.(%s|%s)' % (NAME_context, CMD_context_on, CMD_context_off)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <image>.add-diff-file - add a diff file to the image 
	# SYNOPSIS
	#    <image>.add-diff-file filename 
	# <image>: memory0_image, memory_cache_image, memory_ciop_image
	cmdSyntax = '^%s\d+\.%s' % (NAME_image, CMD_image_add_diff_file)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <image>.add-partial-diff-file - add a partial diff file to the image 
	# SYNOPSIS
	#    <image>.add-partial-diff-file filename start size 
	cmdSyntax = '^%s\d+\.%s' % (NAME_image, CMD_image_add_partial_diff_file)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <image>.commit - commit modifies pages 
	# SYNOPSIS
	#    <image>.commit
	cmdSyntax = '^%s\d+\.%s' % (NAME_image, CMD_image_commit)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <image>.limit-memory - limit memory usage 
	# SYNOPSIS
	#    <image>.limit-memory [Mb] ["swapfile"] ["swapdir"] [-k] [-r] 
	cmdSyntax = '^%s\d+\.%s' % (NAME_image, CMD_image_limit_memory)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <image>.save - save image to disk 
	# SYNOPSIS
	#    <image>.save filename [start-byte] [length] 
	cmdSyntax = '^%s\d+\.%s' % (NAME_image, CMD_image_save)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <image>.x - examine image data 
	# SYNOPSIS
	#    <image>.x offset [size] 
	cmdSyntax = '^%s\d+\.%s' % (NAME_image, CMD_image_x)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <memory-space>.map - list memory map 
	# SYNOPSIS
	#    <memory-space>.map
	cmdSyntax = '^%s\d+\.%s' % (NAME_memory_space, CMD_memory_space_map)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <port-space>.map - list port map 
	# SYNOPSIS
	#    <port-space>.map
	cmdSyntax = '^%s\d+\.%s' % (NAME_port_space, CMD_port_space_map)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <rtl-intf>.info - Drive and expect of rtl 
	# SYNOPSIS
	#    <rtl-intf>.info
	cmdSyntax = '^%s\d+\.%s' % (NAME_rtl_intf, CMD_rtl_intf_info)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <swerver-memory>.debug - setup the memory modeling debug level 
	# SYNOPSIS
	#    <swerver-memory>.debug debug_level 
	cmdSyntax = '^%s\d+\.%s' % (NAME_swerver_memory, CMD_swerver_memory_debug)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <swerver-memory>.info - print information about swerver-memory model 
	# SYNOPSIS
	#    <swerver-memory>.info
	cmdSyntax = '^%s\d+\.%s' % (NAME_swerver_memory, CMD_swerver_memory_info)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <swerver-proc-mmu>.d-probe, <swerver-proc-mmu>.i-probe - check data tlb for 
	#    translation 
	# SYNOPSIS
	#    <swerver-proc-mmu>.d-probe address 
	#    <swerver-proc-mmu>.i-probe address 
	cmdSyntax = '^%s\d+\.[di]-%s' % (NAME_swerver_proc_mmu, CMD_swerver_proc_mmu_probe)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <swerver-proc-mmu>.d-tlb, <swerver-proc-mmu>.i-tlb, <
	#    swerver-proc-mmu>.i-tlb-entry - print data tlb contents 
	# SYNOPSIS
	#    <swerver-proc-mmu>.d-tlb
	#    <swerver-proc-mmu>.i-tlb
	#    <swerver-proc-mmu>.i-tlb-entry idx 
	cmdSyntax = '^%s\d+\.[di]-%s' % (NAME_swerver_proc_mmu, CMD_swerver_proc_mmu_tlb)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleTLB

	cmdSyntax = '^%s\d+\.%s' % (NAME_swerver_proc_mmu, CMD_swerver_proc_mmu_i_tlb_entry)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleTLB

	# NAME
	#    <swerver-proc-mmu>.regs - print mmu registers 
	# SYNOPSIS
	#    <swerver-proc-mmu>.regs
	cmdSyntax = '^%s\d+\.%s' % (NAME_swerver_proc_mmu, CMD_swerver_proc_mmu_regs)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <swerver-proc-mmu>.trace - toggle trace functionality 
	# SYNOPSIS
	#    <swerver-proc-mmu>.trace
	cmdSyntax = '^%s\d+\.%s' % (NAME_swerver_proc_mmu, CMD_swerver_proc_mmu_trace)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <swerver-thread-mmu>.d-probe, <swerver-thread-mmu>.i-probe - check data tlb 
	#    for translation 
	# SYNOPSIS
	#    <swerver-thread-mmu>.d-probe address 
	#    <swerver-thread-mmu>.i-probe address 
	cmdSyntax = '^%s\d+\.[di]-%s' % (NAME_swerver_thread_mmu, CMD_swerver_thread_mmu_probe)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <swerver-thread-mmu>.read-spu-trap - Display SPU traps. 
	# SYNOPSIS
	#    <swerver-thread-mmu>.read-spu-trap
	cmdSyntax = '^%s\d+\.%s' % (NAME_swerver_thread_mmu, CMD_swerver_thread_mmu_read_spu_trap)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <swerver-thread-mmu>.regs - print mmu registers 
	# SYNOPSIS
	#    <swerver-thread-mmu>.regs
	cmdSyntax = '^%s\d+\.%s' % (NAME_swerver_thread_mmu, CMD_swerver_thread_mmu_regs)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleMmu

	# NAME
	#    <swerver-thread-mmu>.set-spu-trap - Set SPU traps. 
	# SYNOPSIS
	#    <swerver-thread-mmu>.set-spu-trap trap-type 
	cmdSyntax = '^%s\d+\.%s' % (NAME_swerver_thread_mmu, CMD_swerver_thread_mmu_set_spu_trap)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    <swerver-thread-mmu>.trace - toggle trace functionality 
	# SYNOPSIS
	#    <swerver-thread-mmu>.trace
	cmdSyntax = '^%s\d+\.%s' % (NAME_swerver_thread_mmu, CMD_swerver_thread_mmu_trace)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    action - bind action to breakpoint 
	# SYNOPSIS
	#    action id "action" 
	cmdSyntax = '^%s\s+\d+' % (CMD_action)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    add-directory, clear-directories, print-directories - add a directory to 
	#    the search path 
	# SYNOPSIS
	#    add-directory "path" [-prepend] 
	#    clear-directories
	#    print-directories
	cmdSyntax = '^%s' % (CMD_add_directory)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^%s' % (CMD_clear_directories)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^%s' % (CMD_print_directories)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    api-apropos - search API help 
	# SYNOPSIS
	#    api-apropos "search-string" 
	cmdSyntax = '^%s' % (CMD_api_apropos)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    api-help - get API help 
	# SYNOPSIS
	#    api-help "help-string" 
	cmdSyntax = '^%s' % (CMD_api_help)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    apropos - search for text in documentation 
	# SYNOPSIS
	#    apropos [-r] "string" 
	cmdSyntax = '^%s' % (CMD_apropos)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    break-cr, unbreak-cr - break on control register updates 
	# SYNOPSIS
	#    break-cr ("register"|-all|-list) 
	#    unbreak-cr ("register"|-all|-list) 
	cmdSyntax = '^(un)?%s' % (CMD_break_cr)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    break-exception, unbreak-exception - break on control register updates 
	# SYNOPSIS
	#    break-exception ("name"|number|-all|-list) 
	#    unbreak-exception ("name"|number|-all|-list) 
	cmdSyntax = '^(un)?%s' % (CMD_break_exception)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    break-hap, unbreak-hap - break on haps 
	# SYNOPSIS
	#    break-hap ("hap"|-all|-list) 
	#    unbreak-hap ("hap"|-all|-list) 
	cmdSyntax = '^(un)?%s' % (CMD_break_hap)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    break-io, unbreak-io - break on device accesses 
	# SYNOPSIS
	#    break-io ("device"|-all|-list) 
	#    unbreak-io ("device"|-all|-list) 
	cmdSyntax = '^(un)?%s' % (CMD_break_io)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    catch-exception, uncatch-exception - catch exceptions 
	# SYNOPSIS
	#    catch-exception [("name"|number|-all)] 
	#    uncatch-exception [("name"|vector|-all)] 
	cmdSyntax = '^(un)?%s' % (CMD_catch_exception)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    command-list - generate html document describing commands 
	# SYNOPSIS
	#    command-list file 
	#cmdSyntax = '^%s\s+\S+' % (CMD_command_list)
	cmdSyntax = '^%s' % (CMD_command_list)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    cycle-break-absolute, <processor>.cycle-break, <
	#    processor>.cycle-break-absolute, cycle-break - set absolute cycle 
	#    breakpoint 
	# SYNOPSIS
	#    <processor>.cycle-break cycles 
	#    <processor>.cycle-break-absolute cycles 
	#    cycle-break ["cpu-name"] cycles 
	#    cycle-break-absolute ["cpu-name"] cycles 
	cmdSyntax = '^(%s\d+\.)?%s' % (NAME_processor, CMD_cycle_break_absolute)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^(%s\d+\.)?%s' % (NAME_processor, CMD_cycle_break)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    debug-level - set or get the debug level 
	# SYNOPSIS
	#    debug-level "object-name" [level] 
	cmdSyntax = '^%s' % (CMD_debug_level)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    delete - remove a breakpoint 
	# SYNOPSIS
	#    delete (-all|id) 
	#cmdSyntax = '^%s\s+(-all|\d+(\s+\d+)*)' % (CMD_delete)
	cmdSyntax = '^%s\s+' % (CMD_delete)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleDelete

	# NAME
	#    device-interrupt - Device interrupt 
	# SYNOPSIS
	#    device-interrupt issue-device target-thread intvec 
	cmdSyntax = '^%s' % (CMD_device_interrupt)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    devs - list all devices in system
	# SYNOPSIS
	#    devs ["object-name"] 
	cmdSyntax = '^%s' % (CMD_devs)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    disassemble, <processor>.disassemble - disassemble instructions 
	# SYNOPSIS
	#    <processor>.disassemble [address] [count] 
	#    disassemble ["cpu-name"] [address] [count] 
	cmdSyntax ='^(%s\d+\.%s\s*)|^(%s(\s*%s\d+)?\s*)' % (NAME_processor, CMD_disassemble,CMD_disassemble,NAME_processor)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleDisassemble

	# NAME
	#    display - print expression at prompt 
	# SYNOPSIS
	#    display ["expression"] [-l] [-p] [-t] 
	cmdSyntax = '^%s' % (CMD_display)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    echo - echo a value to screen 
	# SYNOPSIS
	#    echo [("string"|integer|float)] 
	#cmdSyntax = '^(%s|%s\s+.*)' % (CMD_echo, CMD_echo)
	cmdSyntax = '^%s' % (CMD_echo)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleEcho

	# NAME
	#    enable, disable - enable/disable breakpoint 
	# SYNOPSIS
	#    disable (-all|id) 
	#    enable (-all|id) 
	#cmdSyntax = '^%s\s+(-all|\d+)' % (CMD_enable)
	cmdSyntax = '^(%s|%s\s+.*)' % (CMD_enable, CMD_enable)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleEnable

	cmdSyntax = '^(%s|%s\s+.*)' % (CMD_disable, CMD_disable)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleDisable

	# NAME
	#    enable-external-commands - enable external command port 
	# SYNOPSIS
	#    enable-external-commands [port] 
	cmdSyntax = '^%s' % (CMD_enable_external_commands)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    enable-real-time-mode, disable-real-time-mode - set real time mode
	# SYNOPSIS
	#    disable-real-time-mode
	#    enable-real-time-mode [speed] [check_interval] 
	cmdSyntax = '^%s' % (CMD_enable_real_time_mode)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^%s' % (CMD_disable_real_time_mode)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    eosl - end-of-sas-line 
	# SYNOPSIS
	#    eosl
	cmdSyntax = '^%s' % (CMD_eosl)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    expect - fail if not equal 
	# SYNOPSIS
	#    expect i1 i2 [-v] 
	#cmdSyntax = '^%s\s+(\(.+\)\s+(\d+|0[Xx][\dA-Fa-f]+)|(\d+|0[Xx][\dA-Fa-f]+)\s+(\d+|0[Xx][\dA-Fa-f]+))' % (CMD_expect)
	cmdSyntax = '^%s\s+\S+' % (CMD_expect)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleExpect

	# NAME
	#    gdb-remote - start gdb-remote 
	# SYNOPSIS
	#    gdb-remote [port] 
	cmdSyntax = '^%s' % (CMD_gdb_remote)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    get, <memory-space>.get - get value of physical address 
	# SYNOPSIS
	#    <memory-space>.get address [size] [-l] [-b] 
	#    get address [size] [-l] [-b] 
	#cmdSyntax = '^(%s\d+\.)?%s\s+0[Xx][\dA-Fa-f]+' % (NAME_memory_space, CMD_get)
	cmdSyntax = '^(%s\d+\.)?%s\s+' % (NAME_memory_space, CMD_get)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleGet

	# NAME
	#    help - help command 
	# SYNOPSIS
	#    help [("help-string"|-all)] 
	cmdSyntax = '^(%s\s*$|%s\s+\S+)' % (CMD_help, CMD_help)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleHelp

	# NAME
	#    hex - display integer in hexadecimal notation 
	# SYNOPSIS
	#    hex value 
	cmdSyntax = '^%s\s+\d+' % (CMD_hex)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    ignore - set ignore count for a breakpoint 
	# SYNOPSIS
	#    ignore id num 
	#cmdSyntax = '^%s\s+\d+\s+\d+' % (CMD_ignore)
	cmdSyntax = '^%s\s+' % (CMD_ignore)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleIgnore

	# NAME
	#    instruction-profile-mode - set or get current mode for instruction 
	#    profiling 
	# SYNOPSIS
	#    instruction-profile-mode ["mode"] 
	cmdSyntax = '^%s' % (CMD_instruction_profile_mode)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    io - print I/O trace 
	# SYNOPSIS
	#    io ["object-name"] [count] 
	cmdSyntax = '^%s' % (CMD_io)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    io-buffer - set I/O buffer size 
	# SYNOPSIS
	#    io-buffer ["object-name"] [size] 
	cmdSyntax = '^%s' % (CMD_io_buffer)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    istc-enable, dstc-disable, dstc-enable, istc-disable, stc-status - enable 
	#    or disable internal caches 
	# SYNOPSIS
	#    dstc-disable
	#    dstc-enable
	#    istc-disable
	#    istc-enable
	#    stc-status
	cmdSyntax = '^%s' % (CMD_dstc_disable)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^%s' % (CMD_dstc_enable)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^%s' % (CMD_istc_disable)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^%s' % (CMD_istc_enable)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^%s' % (CMD_stc_status)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    le-checksum - display the checksum of the module-list attribute 
	# SYNOPSIS
	#    le-checksum ["obj"] 
	cmdSyntax = '^%s' % (CMD_le_checksum)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    le-permissions - describe the current 'Limited Edition' permissions 
	# SYNOPSIS
	#    le-permissions ["obj"] 
	cmdSyntax = '^%s' % (CMD_le_permissions)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    list-attributes - list all attributes 
	# SYNOPSIS
	#    list-attributes "object-name" ["attribute-name"] 
	cmdSyntax = '^%s' % (CMD_list_attributes)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    list-breakpoints - print information about breakpoints 
	# SYNOPSIS
	#    list-breakpoints [-all] 
	cmdSyntax = '^%s' % (CMD_list_breakpoints)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleListBreak

	# NAME
	#    list-classes - list all configuration classes 
	# SYNOPSIS
	#    list-classes
	cmdSyntax = '^%s' % (CMD_list_classes)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    list-failed-modules - show list of failed modules 
	# SYNOPSIS
	#    list-failed-modules ["substr"] [-v] 
	cmdSyntax = '^%s' % (CMD_list_failed_modules)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    list-haps - print list of haps 
	# SYNOPSIS
	#    list-haps ["substring"] 
	cmdSyntax = '^%s' % (CMD_list_haps)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    list-modules - list loadable modules 
	# SYNOPSIS
	#    list-modules ["substr"] [-v] 
	cmdSyntax = '^%s' % (CMD_list_modules)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    list-namespaces - list all namespaces 
	# SYNOPSIS
	#    list-namespaces
	cmdSyntax = '^%s' % (CMD_list_namespaces)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    list-profilers - list description of active profilers 
	# SYNOPSIS
	#    list-profilers
	cmdSyntax = '^%s' % (CMD_list_profilers)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    list-vars - list environment variables 
	# SYNOPSIS
	#    list-vars
	cmdSyntax = '^%s' % (CMD_list_vars)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    load-binary, <memory-space>.load-binary - load binary (executable) file 
	#    into memory 
	# SYNOPSIS
	#    <memory-space>.load-binary filename [offset] [-v] [-pa] 
	#    load-binary filename [offset] [-v] [-pa] 
	#cmdSyntax = '^(%s\d+\.)?%s\s+\S+' % (NAME_memory_space, CMD_load_binary)
	cmdSyntax = '^(%s\d+\.)?%s' % (NAME_memory_space, CMD_load_binary)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    load-file, <memory-space>.load-file - load file into memory 
	# SYNOPSIS
	#    <memory-space>.load-file filename [offset] 
	#    load-file filename [offset] 
	#cmdSyntax = '^(%s\d+\.)?%s\s+\S+' % (NAME_memory_space, CMD_load_file)
	cmdSyntax = '^(%s\d+\.)?%s' % (NAME_memory_space, CMD_load_file)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    load-module - load module into system
	# SYNOPSIS
	#    load-module "module" 
	cmdSyntax = '^%s' % (CMD_load_module)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    load-veri-file - load the physical addres from verilog memory format file 
	# SYNOPSIS
	#    load-veri-file "verilog-mem-format-file-name" 
	cmdSyntax = '^%s' % (CMD_load_veri_file)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    logical-to-physical, <processor>.logical-to-physical - translate logical 
	#    address to physical 
	# SYNOPSIS
	#    <processor>.logical-to-physical address 
	#    logical-to-physical ["cpu-name"] address 
	cmdSyntax = '^(%s\d+\.)?%s' % (NAME_processor, CMD_logical_to_physical)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleVa2Pa

	# NAME
	#    magic-break-enable, magic-break-disable - install magic instruction hap 
	#    handler 
	# SYNOPSIS
	#    magic-break-disable
	#    magic-break-enable
	cmdSyntax = '^%s' % (CMD_magic_break_enable)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^%s' % (CMD_magic_break_disable)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    memory-profile - enable or disable memory profiling 
	# SYNOPSIS
	#    memory-profile ["mode"] 
	cmdSyntax = '^%s' % (CMD_memory_profile)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    module-list-refresh - create a new list of loadable modules 
	# SYNOPSIS
	#    module-list-refresh
	cmdSyntax = '^%s' % (CMD_module_list_refresh)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    native-path - convert a filename to host native form 
	# SYNOPSIS
	#    native-path "filename" 
	cmdSyntax = '^%s' % (CMD_native_path)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    new-context - create a new context 
	# SYNOPSIS
	#    new-context "name" 
	cmdSyntax = '^%s' % (CMD_new_context)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    output-radix - change the default output radix 
	# SYNOPSIS
	#    output-radix [base] 
	cmdSyntax = '^%s' % (CMD_output_radix)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    pdisassemble - disassemble instructions in physical memory 
	# SYNOPSIS
	#    pdisassemble [address] [count] 
	cmdSyntax = '^%s' % (CMD_pdisassemble)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    penable, <processor>.disable, <processor>.enable, pdisable - switch 
	#    processor on 
	# SYNOPSIS
	#    <processor>.disable
	#    <processor>.enable
	#    pdisable [("cpu-name"|-all)] 
	#    penable [("cpu-name"|-all)] 
	cmdSyntax = '^(%s|%s\d+\.%s)' % (CMD_penable, NAME_processor, CMD_enable)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handlePenable

	cmdSyntax = '^(%s|%s\d+\.%s)' % (CMD_pdisable, NAME_processor, CMD_disable)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handlePdisable

	# NAME
	#    pio - print information about an object 
	# SYNOPSIS
	#    pio "object-name" 
	cmdSyntax = '^%s' % (CMD_pio)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    pipe - run commands through a pipe 
	# SYNOPSIS
	#    pipe "command" "pipe" 
	cmdSyntax = '^%s' % (CMD_pipe)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    pli-run - Run # of instruction through PLI command interface 
	# SYNOPSIS
	#    pli-run value 
	#cmdSyntax = '^%s\s+\d+' % (CMD_pli_run)
	cmdSyntax = '^%s' % (CMD_pli_run)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handlePlirun

	# NAME
	#    pregs, <processor>.pregs - print cpu registers 
	# SYNOPSIS
	#    <processor>.pregs [-all] 
	#    pregs ["cpu-name"] [-all] 
	cmdSyntax = '^(%s\d+\.)?%s$|^(%s\d+\.)?%s\s+' % (NAME_processor, CMD_pregs, NAME_processor, CMD_pregs)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handlePregs

	# NAME
	#    fpregs, <processor>.fpregs - print cpu fp registers 
	# SYNOPSIS
	#    <processor>.fpregs
	#    fpregs ["cpu-name"]
	cmdSyntax = '^(%s\d+\.)?%s$|^(%s\d+\.)?%s\s+' % (NAME_processor, CMD_fpregs, NAME_processor, CMD_fpregs)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleFpregs

	# NAME
	#    cmpregs, <processor>.cmpregs - print cmp registers 
	# SYNOPSIS
	#    <processor>.cmpregs
	#    cmpregs ["cpu-name"]
	cmdSyntax = '^(%s\d+\.)?%s$|^(%s\d+\.)?%s\s+' % (NAME_processor, CMD_cmpregs, NAME_processor, CMD_cmpregs)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleCmpregs

	# NAME
	#    mmuregs, <processor>.mmuregs - print mmu registers 
	# SYNOPSIS
	#    <processor>.mmuregs
	#    mmuregs ["cpu-name"]
	cmdSyntax = '^(%s\d+\.)?%s$|^(%s\d+\.)?%s\s+' % (NAME_processor, CMD_mmuregs, NAME_processor, CMD_mmuregs)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleMmuregs

	# NAME
	#    pregs-all - print all cpu registers 
	# SYNOPSIS
	#    pregs-all ["cpu-name"] 
	cmdSyntax = '^%s' % (CMD_pregs_all)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    pregs-hyper, <processor>.pregs-hyper - print hypervisor registers 
	# SYNOPSIS
	#    <processor>.pregs-hyper [-all] 
	#    pregs-hyper ["cpu-name"] [-all] 
	cmdSyntax = '^(%s\d+\.)?%s' % (NAME_processor, CMD_pregs_hyper)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    print - display integer in various bases 
	# SYNOPSIS
	#    print [(-x|-o|-b|-s|-d)] value [size] 
	#cmdSyntax = '^%s' % (CMD_print)
	#cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    print-double-regs - print floating point registers as doubles 
	# SYNOPSIS
	#    print-double-regs
	cmdSyntax = '^%s' % (CMD_print_double_regs)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    print-event-queue - print event queue for processor 
	# SYNOPSIS
	#    print-event-queue ["cpu-name"] [queue] 
	cmdSyntax = '^%s' % (CMD_print_event_queue)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    print-float-regs - print floating point registers 
	# SYNOPSIS
	#    print-float-regs
	cmdSyntax = '^%s' % (CMD_print_float_regs)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    print-float-regs-raw - print raw floating point register contents 
	# SYNOPSIS
	#    print-float-regs-raw
	cmdSyntax = '^%s' % (CMD_print_float_regs_raw)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    print-instruction-queue - print instruction queue 
	# SYNOPSIS
	#    print-instruction-queue [-v] 
	cmdSyntax = '^%s' % (CMD_print_instruction_queue)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    print-profile - print execution profile 
	# SYNOPSIS
	#    print-profile [address] [length] 
	cmdSyntax = '^%s' % (CMD_print_profile)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    print-statistics, <processor>.print-statistics - print various statistics 
	# SYNOPSIS
	#    <processor>.print-statistics
	#    print-statistics [("cpu-name"|-all)] 
	cmdSyntax = '^(%s\d+\.)?%s' % (NAME_processor, CMD_print_statistics)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    print-time, <processor>.print-time - print simulated time 
	# SYNOPSIS
	#    <processor>.print-time
	#    print-time ["cpu-name"] 
	cmdSyntax = '^(%s\d+\.)?%s' % (NAME_processor, CMD_print_time)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    prof-page-details - print profile details for a page 
	# SYNOPSIS
	#    prof-page-details [address] [strand] 
	cmdSyntax = '^%s' % (CMD_prof_page_details)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    prof-page-map - print summary profile statistics for each page 
	# SYNOPSIS
	#    prof-page-map
	cmdSyntax = '^%s' % (CMD_prof_page_map)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    prof-weight, set-prof-weight - print weighted result of profilers 
	# SYNOPSIS
	#    prof-weight [block-size] [count] 
	#    set-prof-weight profiler weight 
	cmdSyntax = '^%s' % (CMD_prof_weight)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^%s' % (CMD_set_prof_weight)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    pselect - select a processor 
	# SYNOPSIS
	#    pselect ["cpu-name"] 
	cmdSyntax = '^%s' % (CMD_pselect)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handlePselect

	# NAME
	#    quit - quit from system
	# SYNOPSIS
	#    quit [status] 
	cmdSyntax = '^%s(\s+\d+)?' % (CMD_quit)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleQuit

	# NAME
	#    read-configuration - restore configuration 
	# SYNOPSIS
	#    read-configuration file 
	cmdSyntax = '^%s' % (CMD_read_configuration)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    read-fp-reg-i - print floating point single register as integer 
	# SYNOPSIS
	#    read-fp-reg-i reg-num 
	#cmdSyntax = '^%s\s+\d+' % (CMD_read_fp_reg_i)
	cmdSyntax = '^%s\s+' % (CMD_read_fp_reg_i)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleReadFpi

	# NAME
	#    read-fp-reg-x - print floating point double register as integer 
	# SYNOPSIS
	#    read-fp-reg-x reg-num 
	#cmdSyntax = '^%s\s+\d+' % (CMD_read_fp_reg_x)
	cmdSyntax = '^%s\s+' % (CMD_read_fp_reg_x)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleReadFpx

	# NAME
	#    read-reg, <processor>.read-reg - read a register 
	# SYNOPSIS
	#    <processor>.read-reg "reg-name" 
	#    read-reg ["cpu-name"] "reg-name" 
	#cmdSyntax = '^(%s\d+\.%s\s+\S+|%s(\s+%s\d+)?\s+\S+' % (NAME_processor, CMD_read_reg, CMD_read_reg, NAME_cpu)
	cmdSyntax = '^(%s\d+\.)?%s\s+' % (NAME_processor, CMD_read_reg)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleReadReg

	# NAME
	#    read-sw-pcs - read all pc and npc of a swerver processor 
	# SYNOPSIS
	#    read-sw-pcs "swerver-num" 
	cmdSyntax = '^%s' % (CMD_read_sw_pcs)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    read-th-ctl-reg - Control Register value of a thread 
	# SYNOPSIS
	#    read-th-ctl-reg thread control-register-num 
	#cmdSyntax = '^%s\s+\d+\s+\d+' % (CMD_read_th_ctl_reg)
	cmdSyntax = '^%s\s+' % (CMD_read_th_ctl_reg)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleReadCtlReg

	# NAME
	#    write-th-ctl-reg - Control Register value of a thread 
	# SYNOPSIS
	#    write-th-ctl-reg thread control-register-num value
	cmdSyntax = '^%s\s+' % (CMD_write_th_ctl_reg)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleWriteCtlReg

	# NAME
	#    read-th-fp-reg-i - Read single Fp Register value of a thread 
	# SYNOPSIS
	#    read-th-fp-reg-i thread register-num 
	#cmdSyntax = '^%s\s+\d+\s+\d+' % (CMD_read_th_fp_reg_i)
	cmdSyntax = '^%s\s+' % (CMD_read_th_fp_reg_i)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleReadThFpi

	# NAME
	#    read-th-fp-reg-x - Read double Fp Register value of a thread 
	# SYNOPSIS
	#    read-th-fp-reg-x thread register-num 
	#cmdSyntax = '^%s\s+\d+\s+\d+' % (CMD_read_th_fp_reg_x)
	cmdSyntax = '^%s\s+' % (CMD_read_th_fp_reg_x)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleReadThFpx

	# NAME
	#    read-th-reg - Register value of a window on a thread 
	# SYNOPSIS
	#    read-th-reg thread window register-num 
	#cmdSyntax = '^%s\s+\d+\s+\d+\s+\d+' % (CMD_read_th_reg)
	cmdSyntax = '^%s\s+' % (CMD_read_th_reg)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleReadThReg

	# NAME
	#    read-thread-status - Read Thread Status Register 
	# SYNOPSIS
	#    read-thread-status "thread" 
	cmdSyntax = '^%s' % (CMD_read_thread_status)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    resolve-file - resolve a filename 
	# SYNOPSIS
	#    resolve-file "filename" 
	cmdSyntax = '^%s' % (CMD_resolve_file)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    rtl_cycle - update the interface 
	# SYNOPSIS
	#    rtl_cycle
	cmdSyntax = '^%s' % (CMD_rtl_cycle)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    run - start execution 
	# SYNOPSIS
	#    run [count] [sid]
	cmdSyntax = '^(%s$|%s\s+\d+)' % (CMD_run, CMD_run)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleRun

	# NAME
	#    runfast - start execution 
	# SYNOPSIS
	#    runfast [count] [sid]
	cmdSyntax = '^(%s$|%s\s+\d+)' % (CMD_runfast, CMD_runfast)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleRunfast

	# NAME
	#    whatis - map va to symbol
	# SYNOPSIS
	#    whatis va
	cmdSyntax = '^%s' % (CMD_whatis)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleWhatis

	# NAME
	#    run-command-file - run commands from a file 
	# SYNOPSIS
	#    run-command-file file 
	#cmdSyntax = '^%s\s+\S+' % (CMD_run_command_file)
	cmdSyntax = '^%s\s+' % (CMD_run_command_file)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleRunCommandFile

	# NAME
	#    run-python-file - execute Python file 
	# SYNOPSIS
	#    run-python-file filename 
	#cmdSyntax = '^%s\s+\S+' % (CMD_run_python_file)
	cmdSyntax = '^%s\s+' % (CMD_run_python_file)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleRunPythonFile

	# NAME
	#    set, <memory-space>.set - set physical address to specified value 
	# SYNOPSIS
	#    <memory-space>.set address value [size] [-l] [-b] 
	#    set address value [size] [-l] [-b] 
	#cmdSyntax = '^(%s\d+\.)%s\s+0[xX][\dA-Fa-f]+\s+0[xX][\dA-Fa-f]+' % (NAME_memory_space, CMD_set)
	cmdSyntax = '^(%s\d+\.)?%s\s+' % (NAME_memory_space, CMD_set)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleSet

	# NAME
	#    set-context, <processor>.set-context - set the current context of a cpu 
	# SYNOPSIS
	#    <processor>.set-context "context" 
	#    set-context "context" 
	cmdSyntax = '^(%s\d+\.)?%s' % (NAME_processor, CMD_set_context)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    set-pattern - set an instruction pattern for a breakpoint 
	# SYNOPSIS
	#    set-pattern id "pattern" "mask" 
	cmdSyntax = '^%s' % (CMD_set_pattern)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    set-pc, <processor>.set-pc - set the current processor's program counter 
	# SYNOPSIS
	#    <processor>.set-pc address 
	#    set-pc address 
	cmdSyntax = '^(%s\d+\.)?%s\s+' % (NAME_processor, CMD_set_pc)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleSetPc

	# NAME
	#    set-prefix - set a syntax prefix for a breakpoint 
	# SYNOPSIS
	#    set-prefix id "prefix" 
	cmdSyntax = '^%s' % (CMD_set_prefix)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    set-substr - set a syntax substring for a breakpoint 
	# SYNOPSIS
	#    set-substr id "substr" 
	cmdSyntax = '^%s' % (CMD_set_substr)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    special-interrupt - Special interrupt 
	# SYNOPSIS
	#    special-interrupt reset-type target-thread rstvec 
	cmdSyntax = '^%s' % (CMD_special_interrupt)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    sstepi - step one instr of all swerver processor 
	# SYNOPSIS
	#    sstepi "thread_seq" 
	cmdSyntax = '^%s' % (CMD_sstepi)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    step-break-absolute, <processor>.step-break, <
	#    processor>.step-break-absolute, step-break - set step breakpoints 
	# SYNOPSIS
	#    <processor>.step-break instructions 
	#    <processor>.step-break-absolute instructions 
	#    step-break ["cpu-name"] instructions 
	#    step-break-absolute ["cpu-name"] instructions 
	cmdSyntax = '^(%s\d+\.)?%s' % (NAME_processor, CMD_step_break)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^(%s\d+\.)?%s' % (NAME_processor, CMD_step_break_absolute)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    step-cycle - step one or more cycles 
	# SYNOPSIS
	#    step-cycle [count] 
	#cmdSyntax = '^%s(\s+\d+)?' % (CMD_step_cycle)
	cmdSyntax = '^%s' % (CMD_step_cycle)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    step-instruction - step one or more instructions 
	# SYNOPSIS
	#    step-instruction [count] 
	#cmdSyntax = '^%s(\s+\d+)?' % (CMD_step_instruction)
	cmdSyntax = '^%s' % (CMD_step_instruction)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    stop - interrupt simulation 
	# SYNOPSIS
	#    stop
	cmdSyntax = '^%s' % (CMD_stop)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    swrun - start execution 
	# SYNOPSIS
	#    swrun [count] 
	#cmdSyntax = '^%s(\s+\d+)?' % (CMD_swrun)
	cmdSyntax = '^%s' % (CMD_swrun)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    trace-cr, untrace-cr - trace control register updates 
	# SYNOPSIS
	#    trace-cr ("register"|-all|-list) 
	#    untrace-cr ("register"|-all|-list) 
	cmdSyntax = '^(un)?%s' % (CMD_trace_cr)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    trace-exception, untrace-exception - trace exceptions 
	# SYNOPSIS
	#    trace-exception ("name"|number|-all|-list) 
	#    untrace-exception ("name"|number|-all|-list) 
	cmdSyntax = '^(un)?%s' % (CMD_trace_exception)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    trace-hap, untrace-hap - trace haps 
	# SYNOPSIS
	#    trace-hap ("hap"|-all|-list) 
	#    untrace-hap ("hap"|-all|-list) 
	cmdSyntax = '^(un)?%s' % (CMD_trace_hap)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    trace-io, untrace-io - trace device accesses 
	# SYNOPSIS
	#    trace-io ("device"|-all|-list) 
	#    untrace-io ("device"|-all|-list) 
	cmdSyntax = '^(un)?%s' % (CMD_trace_io)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    trap-info - print information about current traps 
	# SYNOPSIS
	#    trap-info
	cmdSyntax = '^%s' % (CMD_trap_info)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    unbreak - remove breakpoint range 
	# SYNOPSIS
	#    unbreak (id|-all) address length [-r] [-w] [-x] 
	#cmdSyntax = '^%s\s+(\d+|-all)' % (CMD_unbreak)
	cmdSyntax = '^%s' % (CMD_unbreak)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    undisplay - remove expression installed by display 
	# SYNOPSIS
	#    undisplay expression-id 
	cmdSyntax = '^%s' % (CMD_undisplay)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    unload-module - unload module 
	# SYNOPSIS
	#    unload-module "module" 
	cmdSyntax = '^%s' % (CMD_unload_module)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    write-configuration - save configuration 
	# SYNOPSIS
	#    write-configuration file 
	cmdSyntax = '^%s' % (CMD_write_configuration)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    write-fp-reg-i - write floating point single register as integer 
	# SYNOPSIS
	#    write-fp-reg-i reg-num value 
	#cmdSyntax = '^%s\s+\d+\s+(\d+|0[xX][\da-fA-F]+)' % (CMD_write_fp_reg_i)
	cmdSyntax = '^%s\s+' % (CMD_write_fp_reg_i)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleWriteFpi

	# NAME
	#    write-fp-reg-x - write floating point double register as integer 
	# SYNOPSIS
	#    write-fp-reg-x reg-num value 
	#cmdSyntax = '^%s\s+\d+\s+(\d+|0[xX][\da-fA-F]+)' % (CMD_write_fp_reg_x)
	cmdSyntax = '^%s\s+' % (CMD_write_fp_reg_x)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleWriteFpx

	# NAME
	#    write-reg, <processor>.write-reg - write to register 
	# SYNOPSIS
	#    <processor>.write-reg "reg-name" value 
	#    write-reg ["cpu-name"] "reg-name" value 
	cmdSyntax = '^(%s\d+\.)?%s\s+' % (NAME_processor, CMD_write_reg)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleWriteReg

	# NAME
	#    write-th-fp-reg-i - Write double Fp Register value of a thread 
	# SYNOPSIS
	#    write-th-fp-reg-i thread register-num value 
	cmdSyntax = '^%s\s+' % (CMD_write_th_fp_reg_i)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleWriteThFpi

	# NAME
	#    write-th-fp-reg-x - Write double Fp Register value of a thread 
	# SYNOPSIS
	#    write-th-fp-reg-x thread register-num value 
	cmdSyntax = '^%s\s+' % (CMD_write_th_fp_reg_x)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleWriteThFpx

	# NAME
	#    write-thread-status - Write Thread Status Register 
	# SYNOPSIS
	#    write-thread-status "thread" value 
	cmdSyntax = '^%s' % (CMD_write_thread_status)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	# NAME
	#    x, <memory-space>.x, <processor>.x, xp - examine raw memory contents 
	# SYNOPSIS
	#    <memory-space>.x address [size] 
	#    <processor>.x address [size] 
	#    x ["cpu-name"] address [size] 
	#    xp address [size] 
	cmdSyntax = '^(%s\d+|%s\d+)\.%s\s+0[xX][\da-fA-F]+' % (NAME_memory_space, NAME_processor, CMD_x)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^%s(\s+%s\d+)?\s+0[xX][\da-fA-F]+' % (CMD_x, NAME_processor)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	cmdSyntax = '^%s\s+0[xX][\da-fA-F]+' % (CMD_xp)
	cmdRE = re.compile(cmdSyntax)
	#self.cmdRE[cmdRE] = self.handleTodo

	##### extra commands #####
	cmdSyntax = '^%s\s+' % (CMD_ssi)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleStep

	cmdSyntax = '^%s' % (CMD_ALIAS)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleAlias

	cmdSyntax = '^%s' % (CMD_UNALIAS)
	cmdRE = re.compile(cmdSyntax)
	self.cmdRE[cmdRE] = self.handleUnalias

	#TODO  reset, in current form, does not work as intended.
## 	cmdSyntax = '^%s' % (CMD_RESET)
## 	cmdRE = re.compile(cmdSyntax)
## 	self.cmdRE[cmdRE] = self.handleReset

	# keep a list of all the keys, do this AFTER all the commands are
	# registered
	self.cmdList = self.cmdRE.keys()
	#self.dbx('cmdList=%s\n' % (self.cmdList))
	# init docs
	self.initDoc()


    def initDoc (self):
	"""
	"""
	# DOCS[cmd]=('cmd syntax', 'CMD', 'short-desc', 'long-desc')
	self.DOCS['set-pc'] = ("set-pc", 'CMD', "set a strand's pc", 'syntax: set-pc address')
	self.DOCS['set'] = ("set", 'CMD', 'set value at a memory location', 'syntax: set [v:]address value [size]')
	self.DOCS['get'] = ("get", 'CMD', 'get value from a memory location', 'syntax: get [v:]address [size]')
	self.DOCS['write-th-fp-reg-i'] = ("write-th-fp-reg-i", 'CMD', 'write to a floating-point single register', 'syntax: write-th-fp-reg-i thread register-num value')
	self.DOCS['write-th-fp-reg-x'] = ("write-th-fp-reg-x", 'CMD', 'write to a floating-point double register', 'syntax: write-th-fp-reg-x thread register-num value')
	self.DOCS['read-th-fp-reg-i'] = ("read-th-fp-reg-i", 'CMD', 'read a floating-point single register', 'syntax: read-th-fp-reg-i thread reg-num')
	self.DOCS['read-th-fp-reg-x'] = ("read-th-fp-reg-x", 'CMD', 'read a floating-point double register', 'syntax: read-th-fp-reg-x thread reg-num')
	self.DOCS['write-fp-reg-i'] = ("write-fp-reg-i", 'CMD', 'write to a floating-point single register of current strand', 'syntax: write-fp-reg-i register-num value')
	self.DOCS['write-fp-reg-x'] = ("write-fp-reg-x", 'CMD', 'write to a floating-point double register of current strand', 'syntax: write-fp-reg-x register-num value')
	self.DOCS['read-fp-reg-i'] = ("read-fp-reg-i", 'CMD', 'read a floating-point single register of current strand', 'syntax: read-fp-reg-i register-num')
	self.DOCS['read-fp-reg-x'] = ("read-fp-reg-x", 'CMD', 'read a floating-point double register of current strand', 'syntax: read-fp-reg-x register-num')
	self.DOCS['write-reg'] = ("write-reg", 'CMD', 'write to a register', 'syntax: write-reg [cpu-name] reg-name value')
	self.DOCS['read-reg'] = ("read-reg", 'CMD', 'read a register', 'syntax: read-reg [cpu-name] reg-name')
	self.DOCS['read-th-reg'] = ("read-th-reg", 'CMD', 'read a register of a specified strand', 'syntax: read-th-reg thread window register-num')
	self.DOCS['read-th-ctl-reg'] = ("read-th-ctl-reg", 'CMD', 'read a control register of a specified strand', 'syntax: read-th-ctl-reg thread control-register-num')
	self.DOCS['write-th-ctl-reg'] = ("write-th-ctl-reg", 'CMD', 'write to a control register of a specified strand', 'syntax: write-th-ctl-reg thread control-register-num value')
	self.DOCS['echo'] = ("echo", 'CMD', 'echo a string or value', 'syntax: echo [("string"|integer|float)]')
	self.DOCS['expect'] = ("expect", 'CMD', 'compare two values, exit if the values do not match', 'syntax: expect i1 i2')
	self.DOCS['%'] = ("%", 'CMD', 'read a register', 'syntax: %regname')
	self.DOCS['ssi'] = ("ssi", 'CMD', 'step instruction(s) on strand(s)', 'syntax: ssi cN, ssi sN, ssi lN')
	self.DOCS['pregs'] = ("pregs", 'CMD', 'print out integer/floating-point/control registers', 'syntax: pregs [cpu-name] [-all]')
	self.DOCS['fpregs'] = ("fpregs", 'CMD', 'print out floating-point registers', 'syntax: fpregs [cpu-name]')
	self.DOCS['cmpregs'] = ("cmpregs", 'CMD', 'print out cmp registers', 'syntax: cmpregs [cpu-name]')
	self.DOCS['mmuregs'] = ("mmuregs", 'CMD', 'print out mmu registers', 'syntax: mmuregs [cpu-name]')
	self.DOCS['stmmuN.regs'] = ("stmmuN.regs", 'CMD', 'print out mmu registers', 'syntax: stmmuN.regs')
	self.DOCS['swmmuN.d-tlb'] = ("swmmuN.d-tlb", 'CMD', 'print out d-tlb values', 'syntax: swmmuN.d-tlb')
	self.DOCS['swmmuN.i-tlb'] = ("swmmuN.i-tlb", 'CMD', 'print out i-tlb values', 'syntax: swmmuN.i-tlb')
	self.DOCS['break'] = ("break", 'CMD', 'set a breakpoint', 'syntax: break 0xpc|v:0xva|p:0xpa [sid=-1], break &symbol [sid=-1]')
	self.DOCS['delete'] = ("delete", 'CMD', 'delete a breakpoint', 'syntax: delete (-all|id)')
	self.DOCS['enable'] = ("enable", 'CMD', 'enable a breakpoint', 'syntax: enable (-all|id)')
	self.DOCS['disable'] = ("disable", 'CMD', 'disable a breakpoint', 'syntax: disable (-all|id)')
	self.DOCS['pdisable'] = ("pdisable", 'CMD', 'disable a strand', 'syntax: pdisable [(cpu-name|-all)]')
	self.DOCS['penable'] = ("penable", 'CMD', 'enable one or more strands', 'syntax: penable [(cpu-name|-all|0x3210)]')
	self.DOCS['run'] = ("run", 'CMD', 'continue to execute instructions, until hit breakpoint or exit', 'syntax: run [count] [strand-id]')
	self.DOCS['runfast'] = ("runfast", 'CMD', 'execute instructions in fast mode', 'syntax: runfast [count] [strand-id]')
	self.DOCS['whatis'] = ("whatis", 'CMD', 'map a VA/PA to symbol+offset', 'syntax: whatis 0xva|p:0xpa')
	self.DOCS['alias'] = ("alias", 'CMD', 'set an alias', 'syntax: alias zzz z1')
	self.DOCS['unalias'] = ("unalias", 'CMD', 'unalias an alias', 'syntax: unalias zzz')
	#self.DOCS['reset'] = ("reset", 'CMD', "reset all strands' back to a system reset state", 'syntax: reset [traptype=0x1]')
	#self.DOCS['ignore'] = ("ignore", 'CMD', 'ignore hitting breakpoint N times', 'syntax: ignore id num')
	self.DOCS['list-breakpoints'] = ("list-breakpoints", 'CMD', 'list all breakpoints', 'syntax: list-breakpoints')
	self.DOCS['pselect'] = ("pselect", 'CMD', 'select a strand to be the current strand', 'syntax: pselect [cpu-name]')
	self.DOCS['quit'] = ("quit", 'CMD', 'terminate the execution', 'syntax: quit [status]')
	self.DOCS['run-command-file'] = ("run-command-file", 'CMD', 'execute a command file', 'syntax: run-command-file file')
	self.DOCS['run-python-file'] = ("run-python-file", 'CMD', 'execute a python file', 'syntax: run-python-file file')
	self.DOCS['logical-to-physical'] = ("logical-to-physical", 'CMD', 'convert logical address to physical address', 'syntax: logical-to-physical [cpu-name] address')
	self.DOCS['disassemble'] = ("disassemble", 'CMD', 'disassembler one or more instructions', 'syntax: [thN.]disassemble [address [count]]')


    def showDoc (self, key=None):
	"""return 1 means a match is found, 0 means no match
	"""
	found = 0
	if key:
	    # strip off ' ', '(', or ')',  they are not part of the key
	    i = key.find('(')
	    if i > -1:
		key = key[:i]
	    key = key.strip()
	    if self.DOCS.has_key(key):
		(func,type,shortd,longd) = self.DOCS[key]
		print '%s: %s: \t%s' % (type, func, shortd)
		if longd and longd != 'TODO':
		    print '\t\t%s' % (longd)
		found = 1
	    else:
		found = 0
	else:
	    # show all docs
	    byType = { }
	    for (key2,(func,type,shortd,longd)) in self.DOCS.items():
		if not byType.has_key(type):
		    byType[type] = { }
		byType[type][key2] = (func,type,shortd,longd)
	    klist = byType.keys()
	    klist.sort()
	    for key2 in klist:
		klist3 = byType[key2].keys()
		klist3.sort()
		for key3 in klist3:
		    (func,type,shortd,longd) = byType[key2][key3]
		    #print '%s: %s: \t%s' % (type, func, shortd)
		    print '%s: %s' % (type, func)
	    # also show API docs
	    showApiDoc()
	    found = 1

	if found == 0:
	    found = showApiDoc(key)

	return found


    def registerCommand (self, key, cmdlist):
	"""
	"""
	#@new_command("write-th-fp-reg-x", write_th_fp_reg_x_cmd,
	#    args = [arg(int_t, "thread"), arg(int_t, "register-num"), arg(integer_t, "value")],
	#    type  = "niagara commands",
	#    short = "Write double Fp Register value of a thread",
	#    doc = """
	#    Write double precision fp-reg. """)

	#self.dbx('key=%s, cmdlist=%s\n' % (key, cmdlist))
	if type(cmdlist) is types.ListType:
	    oneline = ''
	    for cmd in cmdlist:
		oneline += ' ' + cmd.strip()
	else:
	    oneline = cmdlist
	#self.dbx('oneline=%s\n' % (oneline))

	# function name
	lindex = oneline.find(',')
	rindex = oneline.find(',', lindex+1)
	if lindex > -1 and rindex > -1:
	    func = oneline[lindex+1:rindex].strip()
	else:
	    #self.wrongSyntax(oneline)
	    raise RuntimeError

	argcount = 0
	# TODO  we don't keep track the following values yet
	ctype = ''
	short = ''
	doc = ''

	more = 1

	# args
	lindex = oneline.find('[', rindex+1)
	rindex = oneline.find(']', lindex+1)
	if lindex > -1 and rindex > -1:
	    args = oneline[lindex+1:rindex].strip()
	    # squeeze out blank space(s)
	    tokens = args.split()
	    args = ''.join(tokens)
	    argcount = args.count('arg(')
	else:
	    more = 0

	# ctype
	if more == 1:
	    lindex = oneline.find('"', rindex+1)
	    rindex = oneline.find('"', lindex+1)
	    if lindex > -1 and rindex > -1:
		ctype = oneline[lindex+1:rindex].strip()
	    else:
		more = 0

	# short description
	if more == 1:
	    lindex = oneline.find('"', rindex+1)
	    rindex = oneline.find('"', lindex+1)
	    if lindex > -1 and rindex > -1:
		short = oneline[lindex+1:rindex].strip()
	    else:
		more = 0

	# long description
	if more == 1:
	    lindex = oneline.find('"', rindex+1)
	    rindex = oneline.rfind('"', lindex+1)
	    if lindex > -1 and rindex > -1:
		doc = oneline[lindex+1:rindex].strip('"').strip()
	    else:
		more = 0

	#self.dbx('key=%s\n' % (key))
	#self.dbx('func=%s\n' % (func))
	#self.dbx('args=%s\n' % (args))
	#self.dbx('argcount=%s\n' % (argcount))
	#self.dbx('ctype=%s\n' % (ctype))
	#self.dbx('short=%s\n' % (short))
	#self.dbx('doc=%s\n' % (doc))
	
	if argcount > 0:
	    cmdSyntax = '^%s\s+' % (key)
	else:
	    cmdSyntax = '^%s$' % (key)
	cmdRE = re.compile(cmdSyntax)
	self.cmdExt[cmdRE] = (func, argcount)
	
	# add entry in DOCS
	self.registerDoc(key, key, 'CMD-EXT', short, doc)


    def registerDoc (self, key, fname, type, shortdoc, longdoc):
	"""
	"""
	self.DOCS[key] = (fname, type, shortdoc, longdoc)

	
    def setNstrandObjs (self, count):
	"""
	"""
	if self.nstrandObjs != count:
	    sys.stderr.write('WARNING: CmdParserNi: setNstrandObjs: self.nstrandObjs=%d, count=%d\n' % (self.nstrandObjs, count))

	self.nstrandObjs = count
	i = 0
	while i < self.nstrandObjs:
	    # 5/25/05: penable/pdisable will update CMP registers, and step()
	    # is controlled by core_running_status, so frontend thdEnable[]
	    # will always be true.
	    self.thdEnable[i] = 1
	    self.instrCount[i] = 0
	    i += 1


    def registerCmdMap (self, cmdMap):
	"""
	"""
	self.cmdMap = cmdMap


    def parseCmd (self, line, **parms):
	"""
	"""
	if not line:
	    return line

	try:
	    return self._parseCmd(line, **parms)
	except SystemExit:
	    raise
	except Exception, ex:
	    sys.stderr.write('Wrong command syntax: <%s>, ex=%s\n' % (line, ex))
	    #self.showtraceback()
	    #return line
	    return None


    def _parseCmd (self, line, **parms):
	"""
	"""
	#self.dbx('DBX: enter _parseCmd(%s)\n' % (line)) #DBX

	# preserve leading white space
	i, n = 0, len(line)
	while (i < n) and (line[i] in string.whitespace): 
	    i = i + 1
	indent = line[:i]
	cmd = line[i:]

	if not cmd:
	    return line

	# resolve command alias
	tokens = cmd.split()
	if self.alias.has_key(tokens[0]):
	    cmd = self.alias[tokens[0]] + ' ' + ' '.join(tokens[1:])

	if tokens[0] == CMD_ALIAS:
	    self.handleAlias(cmd)
	    return None

	# replace % variable, e.g., %pc, with RS_read_register_name(), so they
	# can be used in any expression, e.g., "print '%#x' % %pc", hex(%pc),
	# hex(%pc+4), etc.
	cmd = self.replaceToken(cmd)

	# TODO  we would like to collect cmd ouput in variable 'cmdOut' so that
	#       the output can be processed, but current structure does not 
	#       allow that.
	if self.cmdMap != None:
	    cmdOut = None
	    returnCmd = self.cmdMap.issueCmd(cmd, cmdOut, self.riesReposit)
	    if returnCmd == None:
		# return of 'None' means the command has a match in cmdMap and
		# had been executed, so go no further.
		# for 'run N' and 'stepi N', we need to check if there is
		# a breakpoint hit
		tokens = cmd.split()
		bpCmd = None
		if ((tokens[0] == 'run') or (tokens[0] == 'stepi')):
		    bid = self.riesReposit.riesling.getBreakpointTablePtr().query()
		    if (bid > 0):
			sid = self.riesReposit.riesling.getBreakpointTablePtr().querySid()
			bpCmd = self.showBreakpoint(sid, bid)
		return bpCmd
	    else:
		# if no match, use the returned command (likely the original
		# cmd) for further processing
		cmd = returnCmd

	cmdkey = cmd.split()[0]
	newCmd = None
	#sys.stderr.write('DBX: line=<%s>, cmd=<%s>, cmdkey=<%s>\n' % (line, cmd, cmdkey)) #DBX
	if cmdkey == CMD_pli_run and (parms['socketInit'] == 1):
	    # pli-run command is valid only if pli-socket layer is init'ed
	    try:
		tokens = cmd.split()
		if len(tokens) > 1:
		    self.riesReposit.socketAPI.plirun(int(tokens[1]))
		else:
		    self.riesReposit.socketAPI.plirun()
	    except Exception, ex:
		sys.stderr.write('WARNING: socketAPI exception, ex=%s\n' % (ex))
	    return None

	elif cmdkey == '@def':
	    #sys.stderr.write('DBX: @def=<%s>\n' % (cmd)) #DBX
	    # simics uses @def foo() ---> @foo() syntax, bring
	    # it back to normal def foo() ---> foo()
	    newCmd = cmd[1:]
	    # register it in doc
	    lindex = cmd.find(' ')
	    mindex = cmd.find('(', lindex)
	    rindex = cmd.rfind(':')
	    fname = cmd[lindex+1:mindex].strip()
	    func = cmd[lindex+1:rindex].strip()
	    self.registerDoc(fname, func, '@DEF', '@def '+func, None)
	    
	elif cmdkey.startswith('@new_command') or cmdkey.startswith('new_command'):
	    eindex = cmd.find(',')
	    lindex = cmd.find('"', 0, eindex)
	    rindex = cmd.find('"', lindex+1, eindex)
	    if lindex == -1 or rindex == -1:
		#self.wrongSyntax(cmd)
		raise RuntimeError
	    else:
		key = cmd[lindex+1:rindex]
		self.registerCommand(key, cmd)
	    return None

	else:
	    # match command extension first
	    for key in self.cmdExt.keys():
		if re.match(key, cmd):
		    cmd = self.polishCommand(cmd)
		    (func,argcount) = self.cmdExt[key]
		    return self.dispatcher(cmd, func, argcount)

	    # if no match in extension, try matching registered commands
	    for key in self.cmdList:
		if re.match(key, cmd):
		    cmd = self.polishCommand(cmd)
		    newCmd = self.cmdRE[key](cmd)
		    if newCmd == None:
			return None
		    else:
			return indent + newCmd
	    
	    # get here only if we cannot find any match
	    newCmd = cmd

	if newCmd == None:
	    return None
	else:
	    return indent + newCmd


    def mapRS (self, tid, level):
	"""
	"""
	if level == RegisterMap.LEVEL_STRAND:
	    return self.mapThdid(tid)
	elif level == RegisterMap.LEVEL_UCORE:
	    return self.mapuCoreid(tid)
	elif level == RegisterMap.LEVEL_CORE:
	    return self.mapCoreid(tid)
	elif level == RegisterMap.LEVEL_CPU:
	    return self.mapCpuid(tid)
	else:
	    return self.topName


    def mapThdid (self, tid):
	"""
	"""
	if tid >= self.nstrandObjs:
	    return None

	if not self.strandMap.has_key(tid):
	    self.strandMap[tid] = 'strands[%d]' % tid
## 	    cpuid = tid / self.cpusize
## 	    leftover = tid % self.cpusize
## 	    coreid = leftover / self.nstrands
## 	    strandid = leftover % self.nstrands
## 	    self.strandMap[tid] = '%s.%s%d.%s%d.%s%d' % (self.topName, NAME_CPU, cpuid, NAME_CORE, coreid, NAME_STRAND, strandid)

	return self.strandMap[tid]


    def mapuCoreid (self, tid):
	"""
	"""
	if tid >= self.nstrandObjs:
	    return None

	if not self.ucoreMap.has_key(tid):
	    ucoreid = tid / self.ucoresize
	    self.ucoreMap[tid] = 'ucores[%d]' % ucoreid
## 	    cpuid = tid / self.cpusize
## 	    leftover = tid % self.cpusize
## 	    coreid = leftover / self.nstrands
## 	    self.coreMap[tid] = '%s.%s%d.%s%d' % (self.topName, NAME_CPU, cpuid, NAME_CORE, coreid)

	return self.ucoreMap[tid]


    def mapCoreid (self, tid):
	"""
	"""
	if tid >= self.nstrandObjs:
	    return None

	if not self.coreMap.has_key(tid):
	    coreid = tid / self.coresize
	    self.coreMap[tid] = 'cores[%d]' % coreid
## 	    cpuid = tid / self.cpusize
## 	    leftover = tid % self.cpusize
## 	    coreid = leftover / self.nstrands
## 	    self.coreMap[tid] = '%s.%s%d.%s%d' % (self.topName, NAME_CPU, cpuid, NAME_CORE, coreid)

	return self.coreMap[tid]


    def mapCpuid (self, tid):
	"""
	"""
	if tid >= self.nstrandObjs:
	    return None

	if not self.cpuMap.has_key(tid):
	    cpuid = tid / self.cpusize
	    self.cpuMap[tid] = 'cpus[%d]' % cpuid
## 	    self.cpuMap[tid] = '%s.%s%d' % (self.topName, NAME_CPU, cpuid)

	return self.cpuMap[tid]


    def dbx (self, msg):
	"""
	"""
	sys.stderr.write('DBX: CmdParserNi.py: %s' % (msg))

	
    def todo (self, msg):
	"""
	"""
	sys.stderr.write('TODO: CmdParserNi.py: %s' % (msg))


    def _eval (self, cmd):
	"""
	"""
	return eval(cmd, self.riesReposit.globals)


    def dispatcher (self, cmd, func, argcount):
	"""
	"""
	if argcount == 0:
	    return self._eval('%s()' % (func))
	else:
	    tokens = cmd.split()
	    if len(tokens) != (argcount+1):
		raise RuntimeError, 'input parameters do not match command syntax, cmd=<%s>' % (cmd)
	    else:
		#self.dbx('%s(%s)\n' % (func, ','.join(tokens[1:])))
		return self._eval('%s(%s)' % (func, ','.join(tokens[1:])))


    def handleSetPc (self, cmd):
	"""
	<processor>.set-pc address 
	set-pc address 

	e.g., set-pc 0x00010000
	"""
	#self.dbx('handleSetPC(%s)\n' % (cmd))
	tokens = cmd.split()
	if tokens[0].startswith(CMD_set_pc):
	    # set-pc 0x00010000
	    # use current tid
	    tid = self.lastTid
	else:
	    # <processor>.set-pc 0x00010000
	    i = tokens[0].find('.')
	    tid = int(tokens[0][len(NAME_processor):i])

	retval = self.checkArgs([tokens[1]])
	if retval[0] ==False:
		sys.stderr.write('ERROR: invalid argument\n')
		return ''

	newCmd = '%s.getArchStatePtr().setPc(%s)' % (self.mapThdid(tid), tokens[1])
	#eval(newCmd, self.riesReposit.globals)
	return newCmd


    def handleSet (self, cmd):
	"""
	TODO  <memory-space>.set address value size [-l] [-b] 
	set address value size [-l] [-b] 

	1 <= size [4] <= 8
	TODO  -l/-b: little-endian/big-endian byte order

	e.g., set 0x00010004 0xafa0188b     # fitos %f11, %f23
	"""
	#print 'DBX: handleSet(): <%s>' % (cmd) #DBX
	tokens = cmd.split()
	addrStr = tokens[1]
	tid = self.lastTid

	if addrStr.startswith(SYM_VA):
	    # logical address: v:0x...
	    # try itlb first
	    addr = RS_logical_to_physical(tid, 1, eval(addrStr[len(SYM_VA):]))
	    if addr == 0xdeadbeefL:
		# if no luck, try dtlb
		addr = RS_logical_to_physical(tid, 0, eval(addrStr[len(SYM_VA):]))
	elif addrStr.startswith(SYM_PA):
	    addr = eval(addrStr[len(SYM_PA):])
	else:
	    if self.checkArgs([addrStr]) != [True]:
		sys.stderr.write('ERROR: wrong addr argument\n')
		return	
	    else:
		addr = eval(addrStr)
			
	if self.checkArgs([tokens[2]]) != [True]:
	    sys.stderr.write('ERROR: wrong value argument\n')
	    return

	if len(tokens) >= 4 and self.checkArgs([tokens[3]]) != [True]:
	    sys.stderr.write('ERROR: wrong value or size argument\n')
	    return
	
	value = eval(self.truncVal(tokens[2],1))
	
	# set 4 or 8 bytes
	try:
	    size = eval(tokens[3])
	except:
	    # if size is not provided, or is not valid, use 4 bytes
	    #raise	
	    size = 4

	#print 'DBX: handleSet(): tid=%d, addr=%#x, value=%#x, size=%d' % (tid, addr, value, size) #DBX
	if not size in [1,2,4,8]:
	    sys.stderr.write('ERROR: set: wrong size %d, must be 1,2,4,8-byte\n' % (size))
	elif (addr % size) != 0:
	    sys.stderr.write('ERROR: set: misaligned address\n')	
	else:
	    RS_write_phys_memory(tid, addr, value, size)

	return None


    def handleGet (self, cmd):
	"""
	TODO  <memory-space>.get address [size] [-l] [-b] 
	get address size [-l] [-b] 

	1 <= size [4] <= 8
	TODO  -l/-b: little-endian/big-endian byte order

	e.g., get 0x00010004
	"""
	tokens = cmd.split()
	addrStr = tokens[1]
	tid = self.lastTid
	if addrStr.startswith(SYM_VA):
	    # logical address: v:0x...
	    # first look in itlb
	    addr = RS_logical_to_physical(tid, 1, eval(addrStr[len(SYM_VA):]))
	    if addr == 0xdeadbeefL:
		# if nothing there, try dtlb
		addr = RS_logical_to_physical(tid, 0, eval(addrStr[len(SYM_VA):]))
	elif addrStr.startswith(SYM_PA):
	    addr = eval(addrStr[len(SYM_PA):])
	else:
	    if self.checkArgs([addrStr]) != [True]:
		sys.stderr.write('ERROR: wrong addr argument\n')
		return
	    addr = eval(addrStr)

	if len(tokens) >=3 and self.checkArgs([tokens[2]]) != [True]:
	    sys.stderr.write('ERROR: wrong size argument\n')
	    return
	    
	# retrieve 4 or 8 bytes
	try:
	    size = eval(tokens[2])
	except:
	    # if tokens[2] is not provided or not valid, use 4 bytes
	    #raise
	    size = 4

	if (not size in [1,2,4]) and ((size % 8) != 0):
	    sys.stderr.write('ERROR: get: wrong size %d, must be 1,2,4,8N-byte\n' % (size))
	    return None

	if (size <= 8) and ((addr % size) != 0):
	    sys.stderr.write('ERROR: get: addr %#x is not aligned to %d\n' % (addr, size))
	    return None

	if (size > 8) and ((addr % 8) != 0):
	    sys.stderr.write('ERROR: get: addr %#x is not aligned to %d\n' % (addr, 8))
	    return None	

	if size >= 8:
	    i = 0
	    while i < size/8:
		#newCmd = 'hex(%s)' % (RS_read_phys_memory(0, addr+8*i, 8))
		#print eval(newCmd)
		sys.stdout.write('%#018x ' % (RS_read_phys_memory(tid, addr+8*i, 8)))
		i += 1
		if (i % 4) == 0:
		    sys.stdout.write('\n');
	    # make sure we finish off the last value with an EOL
	    if (i % 4) != 0:
		    sys.stdout.write('\n');
	    return None
	else:
	    #newCmd = 'hex(%s)' % (RS_read_phys_memory(0, addr, size))
	    #return newCmd
	    print '%#010x' % (RS_read_phys_memory(tid, addr, size))
	    return None


    def handleWriteThFpi (self, cmd):
	"""
	write-th-fp-reg-i thread register-num value 

	e.g., write-th-fp-reg-i  0 10 0x00000000fbff1391
	"""
	tokens = cmd.split()
	if self.checkArgs([tokens[1],tokens[2],tokens[3]]) != [True,True,True]:
	    sys.stderr.write('ERROR: wrong input paramters\n')
	    return ''

	tid = int(tokens[1])
	regid = tokens[2]
	value = tokens[3]

	if tid < self.nstrandObjs and self.myInt(regid) < self.nSpregs:
	    value = self.truncVal(value,0)
	    #newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().setSpfp(reg=%s,value=%s)' % (self.mapThdid(tid), regid, value)
	    newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().setSpfp(%s,%s)' % (self.mapThdid(tid), regid, value)
	    # eval(newCmd, self.riesReposit.globals)
	    return newCmd
	else:
	    sys.stderr.write('ERROR: out of bounds tid or regid\n')
	    return ''


    def handleWriteThFpx (self, cmd):
	"""
	write-th-fp-reg-x thread register-num value 

	e.g., write-th-fp-reg-x  0 10 0x00000000fbff1391
	"""
	tokens = cmd.split()
	if self.checkArgs([tokens[1],tokens[2],tokens[3]]) != [True,True,True]:
	    sys.stderr.write('ERROR: wrong input paramters\n')
	    return ''

	tid = int(tokens[1])
	regid = tokens[2]
	value = tokens[3]

	if tid < self.nstrandObjs and self.myInt(regid) < self.nDpregs:
	    value = self.truncVal(value,1)
	    #newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().setDpfp(reg=%s,value=%s)' % (self.mapThdid(tid), self.codeFpreg(regid,0), value)
	    newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().setDpfp(%s,%s)' % (self.mapThdid(tid), self.codeFpreg(regid,0), value)
	    # eval(newCmd, self.riesReposit.globals)
	    return newCmd
	else:
	    sys.stderr.write('ERROR: out of bounds tid or regid\n')
	    return ''


    def handleReadThFpi (self, cmd):
	"""
	read-th-fp-reg-i thread reg-num 
	"""
	tokens = cmd.split()
	if self.checkArgs([tokens[1],tokens[2]]) != [True,True]:
	    system.stderr.write('ERROR: wrong input parameters\n')
	    return ''

	if (int(tokens[1]) < self.nstrandObjs) and (int(tokens[2]) < self.nSpregs):
	    #newCmd = 'hex(%s.getArchStatePtr().getFloatRegisterFilePtr().getSpfp(reg=%s))' % (self.mapThdid(int(tokens[1])), tokens[2])
	    newCmd = 'hex(%s.getArchStatePtr().getFloatRegisterFilePtr().getSpfp(%s))' % (self.mapThdid(int(tokens[1])), tokens[2])
	    # as the result will be passed through python interpreter, it must
	    # be in string format.
	    #return str(eval(newCmd, self.riesReposit.globals))
	    return newCmd
	else:
	    sys.stderr.write("ERROR: thread id or register number out of bounds\n")
	    return ''


    def handleReadThFpx (self, cmd):
	"""
	read-th-fp-reg-x thread reg-num 
	"""
	tokens = cmd.split()
	if self.checkArgs([tokens[1],tokens[2]]) != [True,True]:
	    system.stderr.write('ERROR: wrong input parameters\n')
	    return ''

	if (int(tokens[1]) < self.nstrandObjs) and (int(tokens[2]) < self.nDpregs):
	    #newCmd = 'hex(%s.getArchStatePtr().getFloatRegisterFilePtr().getDpfp(reg=%s))' % (self.mapThdid(int(tokens[1])), self.codeFpreg(tokens[2],0))
	    newCmd = 'hex(%s.getArchStatePtr().getFloatRegisterFilePtr().getDpfp(%s))' % (self.mapThdid(int(tokens[1])), self.codeFpreg(tokens[2],0))
	    # as the result will be passed through python interpreter, it must
	    # be in string format.
	    #return str(eval(newCmd, self.riesReposit.globals))
	    return newCmd
	else:
	    sys.stderr.write("ERROR: thread id or register number out of bounds\n")
	    return ''


    def handleWriteFpi (self, cmd):
	"""
	write-fp-reg-i register-num value 
	"""
	tokens = cmd.split()
	regid = tokens[1]
	value = tokens[2]
	if self.checkArgs([regid,value]) != [True, True]:
	    sys.stderr.write('ERROR: wrong command arguments\n')
	    return ''

	if int(regid) < self.nSpregs:
	    value = self.truncVal(value,0)	
	    #newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().setSpfp(reg=%s,value=%s)' % (self.mapThdid(self.lastTid), regid, value)
	    newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().setSpfp(%s,%s)' % (self.mapThdid(self.lastTid), regid, value)
	    # eval(newCmd, self.riesReposit.globals)
	    return newCmd
	else:
	    sys.stderr.write('ERROR: register index %s out of bound %s\n' % (regid,self.nSpregs - 1))
	    return '' 


    def handleWriteFpx (self, cmd):
	"""
	write-fp-reg-x thread register-num value 
	"""
	tokens = cmd.split()
	regid = tokens[1]
	value = tokens[2]
	if self.checkArgs([regid,value]) != [True, True]:
	    sys.stderr.write('ERROR: wrong command arguments\n')
	    return ''

	if int(regid) < self.nDpregs:
	    regid = self.codeFpreg(tokens[1],0)
	    value = self.truncVal(value,1)	
	    #newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().setDpfp(reg=%s,value=%s)' % (self.mapThdid(self.lastTid), regid, value)
	    newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().setDpfp(%s,%s)' % (self.mapThdid(self.lastTid), regid, value)
	    #eval(newCmd, self.riesReposit.globals)
	    return newCmd
	else:
	    sys.stderr.write('ERROR: register index %s out of bound %s\n' % (regid,self.nDpregs - 1))
	    return '' 


    def handleReadFpi (self, cmd):
	"""
	read-fp-reg-i reg-num 

	e.g., read-fp-reg-i 22
	"""
	#self.dbx('handleReadFpx(%s)\n' % (cmd))
	tokens = cmd.split()
	if self.checkArgs([tokens[1]]) != [True]:
	    sys.stderr.write('ERROR: wrong input argument\n')
	    return ''

	if int(tokens[1]) < self.nSpregs:
	    #newCmd = 'hex(%s.getArchStatePtr().getFloatRegisterFilePtr().getSpfp(reg=%s))' % (self.mapThdid(self.lastTid), tokens[1])
	    newCmd = 'hex(%s.getArchStatePtr().getFloatRegisterFilePtr().getSpfp(%s))' % (self.mapThdid(self.lastTid), tokens[1])
	    # as the result will be passed through python interpreter, it must
	    # be in string format.
	    #return str(eval(newCmd, self.riesReposit.globals))
	    return newCmd
	else:
	    sys.stderr.write('ERROR: register index %s out of bound %s\n' % (tokens[1],self.nSpregs - 1))
	    return ''


    def handleReadFpx (self, cmd):
	"""
	read-fp-reg-x reg-num 

	e.g., read-fp-reg-x 22
	"""
	#self.dbx('handleReadFpx(%s)\n' % (cmd))
	tokens = cmd.split()
	if self.checkArgs([tokens[1]]) != [True]:
	    sys.stderr.write('ERROR: wrong input argument\n')
	    return ''

	if int(tokens[1]) < self.nDpregs:
	    regid = self.codeFpreg(tokens[1],0)
	    #newCmd = 'hex(%s.getArchStatePtr().getFloatRegisterFilePtr().getDpfp(reg=%s))' % (self.mapThdid(self.lastTid), regid)
	    newCmd = 'hex(%s.getArchStatePtr().getFloatRegisterFilePtr().getDpfp(%s))' % (self.mapThdid(self.lastTid), regid)
	    # as the result will be passed through python interpreter, it must
	    # be in string format.
	    #return str(eval(newCmd, self.riesReposit.globals))
	    return newCmd
	else:
	    sys.stderr.write('ERROR: register index %s out of bound %s\n' % (tokens[1],self.nDpregs - 1))
	    return ''


    def handleWriteReg (self, cmd):
	"""
	<processor>.write-reg "reg-name" value 
	write-reg ["cpu-name"] "reg-name" value 

	e.g., write-reg fsr 0x40000be0
	"""
	tokens = cmd.split()
	if tokens[0].startswith(CMD_write_reg):
	    # write-reg ['cpu-name'] fsr 0x40000be0
	    if tokens[1].startswith(NAME_processor):
		# use specified tid
		tid = int(tokens[1][len(NAME_processor):])
		name = tokens[2]
		value = tokens[3]
	    else:
		# use current tid
		tid = self.lastTid
		name = tokens[1]
		value = tokens[2]
	else:
	    # <processor>.write-reg fsr 0x40000be0
	    index = tokens[0].find('.')
	    tid = int(tokens[0][len(NAME_processor):index])
	    name = tokens[1]
	    value = tokens[2]

	value = self.truncVal(value,1)

	(level,wrs) = self.regmap.mapWriteRS(name, cmd)
	toprs = self.mapRS(tid, level)
	if wrs.endswith(')'):
	    # all parameters are set, no more action
	    newCmd = '%s.%s' % (toprs, wrs)
	else:
	    #newCmd = '%s.%s(value=%s)' % (toprs, wrs, value)
	    newCmd = '%s.%s(%s)' % (toprs, wrs, value)

	#eval(newCmd, self.riesReposit.globals)
	#sys.stderr.write('DBX: handleWriteReg: newCmd=%s\n' % newCmd) #DBX
	return newCmd


    def handleReadReg (self, cmd):
	"""
	<processor>.read-reg "reg-name" 
	read-reg ["cpu-name"] "reg-name" 

	e.g., read-reg fsr
	"""
	tokens = cmd.split()
	if tokens[0].startswith(CMD_read_reg):
	    # read-reg ['cpu-name'] fsr
	    if tokens[1].startswith(NAME_processor):
		# use specified tid
		tid = int(tokens[1][len(NAME_processor):])
		name = tokens[2]
	    else:
		# use current tid
		tid = self.lastTid
		name = tokens[1]
	else:
	    # <processor>.read-reg fsr
	    i = tokens[0].find('.')
	    tid = int(tokens[0][len(NAME_processor):i])
	    name = tokens[1]

	(level,rrs) = self.regmap.mapReadRS(name, cmd)
	toprs = self.mapRS(tid, level)
	newCmd = 'hex(%s.%s)' % (toprs, rrs)
	#eval(newCmd, self.riesReposit.globals)
	return newCmd


    def handleReadThReg (self, cmd):
	"""
	read-th-reg thread window register-num 
	"""
	tokens = cmd.split()
	if len(tokens) < 4:
	    sys.stderr.write('ERROR: wrong number of arguments\n')
	    return ''

	if self.checkArgs([tokens[1],tokens[2],tokens[3]]) != [True,True,True]:
	    sys.stderr.write('ERROR: wrong input argument\n')
	    return ''

	tid = int(tokens[1])
	win = tokens[2]
	reg = tokens[3]
	if tid >= self.nstrandObjs or int(reg) >= self.nWinregs or int(win) >= self.nWin:
	    sys.stderr.write('ERROR: thread id or register # or  win # out of bounds\n')
	    return ''
		
	toprs = self.mapRS(tid, RegisterMap.LEVEL_STRAND)
	#newCmd = 'hex(%s.%s(cwp=%s,reg=%s))' % (toprs, 'archstate.regfile.getAltCwp', win, reg)
	#newCmd = 'hex(%s.%s(%s,%s))' % (toprs, 'archstate.regfile.getAltCwp', win, reg)
	newCmd = 'hex(%s.%s(%s,%s))' % (toprs, 'getArchStatePtr().getRegisterFilePtr().get', win, reg)
	return newCmd


    def handleReadCtlReg (self, cmd):
	"""
	read-th-ctl-reg thread control-register-num 
	"""
	tokens = cmd.split()
	tid = int(tokens[1])
	rid = int(tokens[2])
	reg = self.regmap.id2key(rid)
	newCmd = '%s %s' % (CMD_read_reg, reg)
	(level,rrs) = self.regmap.mapReadRS(reg, newCmd)
	toprs = self.mapRS(tid, level)
	newCmd = 'hex(%s.%s)' % (toprs, rrs)
	return newCmd


    def handleWriteCtlReg (self, cmd):
	"""
	write-th-ctl-reg thread control-register-num value
	"""
	tokens = cmd.split()
	tid = int(tokens[1])
	rid = int(tokens[2])
	reg = self.regmap.id2key(rid)
	value = tokens[3]
	value = self.truncVal(value,1)
	newCmd = '%s %s %s' % (CMD_write_reg, reg, value)
	(level,wrs) = self.regmap.mapWriteRS(reg, newCmd)
	toprs = self.mapRS(tid, level)
	if wrs.endswith(')'):
	    # all parameters are set, no more action
	    newCmd = '%s.%s' % (toprs, wrs)
	else:
	    #newCmd = '%s.%s(value=%s)' % (toprs, wrs, value)
	    newCmd = '%s.%s(%s)' % (toprs, wrs, value)
	#sys.stderr.write('DBX: handleWriteCtlReg: newCmd=%s\n' % (newCmd)) #DBX
	return newCmd


    def handleEcho (self, cmd):
	"""
	echo [("string"|integer|float)] 

	e.g., echo ?Checking fsr ..?
	"""
	#self.dbx('handleEcho(%s)\n' % (cmd))
	cmd = cmd[len(CMD_echo):].strip()
	if ((cmd.startswith("'") and cmd.endswith("'")) or
	    (cmd.startswith('"') and cmd.endswith('"'))):
	    cmd = cmd[1:-1]
	cmd = cmd.replace("'", "\\'")
	newCmd = 'print \'%s\'' % (cmd)
	return newCmd


    def handleExpect (self, cmd):
	"""
	expect i1 i2 [-v] 
	
	e.g., expect (read-fp-reg-x 22) 0xb06dd828cc801d8d
	"""
	#self.dbx('handleExpect(%s)\n' % (cmd))
	lindex = cmd.find('(')
	if lindex > -1:
	    # expect (expr) value2
	    rindex = cmd.rfind(')')
	    expr1 = cmd[lindex+1:rindex].strip()
	    tokens = cmd[rindex+1:].split()
	    expr2 = tokens[0].strip()
	else:
	    # expect value1 value2
	    tokens = cmd.split()
	    expr1 = tokens[1]
	    expr2 = tokens[2]

## 	# make sure 0x87654321 does not turn into negative value
## 	if re.match(hexRE, expr1) or re.match(octRE, expr1):
## 	    expr1 = expr1 + 'L'
## 	if re.match(hexRE, expr2) or re.match(octRE, expr2):
## 	    expr2 = expr2 + 'L'

	value1 = self._eval(self.parseCmd(expr1))
	if type(value1) is types.StringType:
	    value1 = self._eval(value1)
	value2 = self._eval(expr2)

	if value1 != value2:
	    sys.stdout.write('ERROR: EXPECT mismatch: (%s = %s) != (%s = %s)\n' % (expr1, value1, expr2, value2))
	    sys.exit(1)

	return None


    def handleRegName (self, cmd):
	"""
	% "reg-name" 
	"""
	name = cmd[1:]
	(level,rrs) = self.regmap.mapReadRS(name, cmd)
	toprs = self.mapRS(self.lastTid, level)
	newCmd = 'hex(%s.%s)' % (toprs, rrs)
	#sys.stderr.write('DBX: lastTid=%d newCmd=%s\n' % (self.lastTid, newCmd)) #DBX
	return newCmd


    def handleStep (self, cmd):
	""" ssi cN, ssi sN, ssi lNN
	"""
	bpCmd = None
	tokens = cmd.split()
	if tokens[1].startswith('s'):
	    self.stepOverPreviousHit()
	    # every strand executes one instr in round-robin fashion, until
	    # every strand has executed N instrs.
	    count = int(tokens[1][1:])
	    done = 0
	    i = 0
	    while done == 0 and i < count:
		j = 0
		while done == 0 and j < self.nstrandObjs:
		    if self.thdEnable[j] == 1:
			bid = self.riesReposit.strands[j].step()
			if (bid > 0):
			    # hit a breakpoint
			    #self.lastTid = j
			    self.handlePselect('pselect th%d' % j)
			    bpCmd = self.showBreakpoint(j, bid)
			    done = 1
			else:
			    self.instrCount[j] += 1
			    #self.lastTid = j
			    #self.showLastInstr(j, thd, pc)
		    j += 1
		i += 1
	    return bpCmd

	elif tokens[1].startswith('c'):
	    self.stepOverPreviousHit()
	    # strand 0 in each core executes one instr in round-robin 
	    # fashion, until every strand 0 has executed N instrs.
	    count = int(tokens[1][1:])
	    done = 0
	    i = 0
	    while done == 0 and i < count:
		j = 0
		while done == 0 and j < self.nstrandObjs:
		    if self.thdEnable[j] == 1:
			bid = self.riesReposit.strands[j].step()
			if (bid > 0):
			    # hit a breakpoint
			    #self.lastTid = j
			    self.handlePselect('pselect th%d' % j)
			    bpCmd = self.showBreakpoint(j, bid)
			    done = 1
			else:
			    self.instrCount[j] += 1
			    #self.lastTid = j
			    #self.showLastInstr(j, thd, pc)
		    j += self.nstrands
		i += 1
	    return bpCmd

	elif tokens[1].startswith('l'):
	    tid = int(tokens[1][1:])
	    if tid < self.nstrandObjs:
		j = tid
		if self.thdEnable[j] == 1:
		    bid = self.riesReposit.strands[j].step()
		    if (bid > 0):
			# hit a breakpoint
			#self.lastTid = j
			self.handlePselect('pselect th%d' % j)
			bpCmd = self.showBreakpoint(j, bid)
			done = 1
		    else:
			self.instrCount[j] += 1
			#self.lastTid = j
			#self.showLastInstr(j, thd, pc)

	return bpCmd


    def showLastInstr (self, tid, thd, pc):
	"""
	"""
	if isVerbose() == 1:
	    # get stepped instruction word
	    newCmd = thd + '.lastInstr()'
	    iw = eval(newCmd, self.riesReposit.globals)
	    newCmd = thd + '.lastInstrToString()'
	    iwstr = eval(newCmd, self.riesReposit.globals)
	    # display the stepped instr
	    sys.stderr.write('T%d: %d: <v:%016x> [%08x] %s\n' % (tid, self.instrCount[tid], pc, iw, iwstr))


    def handlePregs (self, cmd):
	""" 
	<processor>.pregs [-all] 
	pregs ["cpu-name"] [-all] 

	pregs, thNN.pregs
	"""
	tokens = cmd.split()
	if cmd.startswith(CMD_pregs):
	    if len(tokens) > 1: 
		if tokens[1].startswith(NAME_processor):
		    tid = int(tokens[1][len(NAME_processor):])
		else:
		    tid = self.lastTid
## 			sys.stderr.write('ERROR: wrong command argument, enter tid as thN\n')
## 			return None
	    else:
		tid = self.lastTid
	else:
	        i = cmd.find('.pregs')
	        tid = int(cmd[len(NAME_processor):i])

	all = ''
	if cmd.find(' -all') > -1:
	    all = '-all'

	RS_print_archregs(tid, all)


    def handleFpregs (self, cmd):
	""" 
	<processor>.fpregs
	fpregs ["cpu-name"]

	fpregs, thNN.fpregs
	"""
	tokens = cmd.split()
	if cmd.startswith(CMD_fpregs):
	    if len(tokens) > 1: 
		if tokens[1].startswith(NAME_processor):
			tid = int(tokens[1][len(NAME_processor):])
		else:
			sys.stderr.write('ERROR: wrong command argument, enter tid as thN\n') 
			return 
	    else:
		tid = self.lastTid
	else:
	    i = cmd.find('.fpregs')
	    tid = int(cmd[len(NAME_processor):i])
	sys.stderr.write('Strand %d\n' % (tid,))	
	RS_print_fpregs(tid)


    def handleMmu (self, cmd):
	""" 
	<swerver-thread-mmu>.regs
	"""
	i = cmd.find('.regs')
	tid = int(cmd[len(NAME_swerver_thread_mmu):i])
	RS_print_mmuregs(tid)


    def handleMmuregs (self, cmd):
	""" 
	<processor>.mmuregs
	mmuregs ["cpu-name"]

	mmuregs, thNN.mmuregs
	"""
	tokens = cmd.split()
	if cmd.startswith(CMD_mmuregs):
	    if len(tokens) > 1:
		if tokens[1].startswith(NAME_processor):
			tid = int(tokens[1][len(NAME_processor):])
		else:
			sys.stderr.write('ERROR: wrong command syntax\n')
			return
	    else:
		tid = self.lastTid
	else:
	    i = cmd.find('.mmuregs')
	    tid = int(cmd[len(NAME_processor):i])
	    	
	if tid >= self.nstrandObjs:
		sys.stderr.write('ERRORL tid out of bound\n')
		return	
	RS_print_mmuregs(tid)


    def handleCmpregs (self, cmd):
	""" 
	<processor>.cmpregs
	cmpregs ["cpu-name"]

	cmpregs, thNN.cmpregs
	"""
	tokens = cmd.split()
	if cmd.startswith(CMD_cmpregs):
	    if len(tokens) > 1:
		if tokens[1].startswith(NAME_processor):
			tid = int(tokens[1][len(NAME_processor):])
		else:
			sys.stderr.write('ERROR: wrong command syntax\n')
			return
	    else:
		tid = self.lastTid
	else:
	    i = cmd.find('.cmpregs')
	    tid = int(cmd[len(NAME_processor):i])
	    	
	if tid >= self.nstrandObjs:
		sys.stderr.write('ERRORL tid out of bound\n')
		return	
	RS_print_cmpregs(tid)


    def handleTLB (self, cmd):
	""" 
	<swerver-proc-mmu>.d-tlb
	<swerver-proc-mmu>.i-tlb
	<swerver-proc-mmu>.i-tlb-entry idx 

	swmmuN.i-tlb, swmmuN.d-tlb, N is strand-id
	"""
	# TODO  no support for i-tlb-entry
	if cmd.find(CMD_swerver_proc_mmu_i_tlb_entry) > -1:
	    raise RuntimeError

	index = cmd.find('.i-tlb')
	if index > -1:
	    tid = int(cmd[len(NAME_swerver_proc_mmu):index])
	    core = self.mapCoreid(tid)
	    if core == None:
		# core id out of range
		raise RuntimeError
	    else:
		newCmd = 'print %s.getiTlbPtr().toString()' % (core)
	else:
	    index = cmd.find('.d-tlb')
	    if index > -1:
		tid = int(cmd[len(NAME_swerver_proc_mmu):index])
		core = self.mapCoreid(tid)
		if core == None:
		    # core id out of range
		    raise RuntimeError
		else:
		    newCmd = 'print %s.getdTlbPtr().toString()' % (core)
	    else:
		# not an expected syntax, return to interpreter
		raise RuntimeError

	return newCmd


    def handleBreak (self, cmd):
	"""
	<breakpoint>.break address [length] [-r] [-w] [-x] 
	<breakpoint>.tbreak address [length] [-r] [-w] [-x] 
	break address [length] [-r] [-w] [-x] 

	break v:0xaddr
	break p:0xaddr
	break symbol

	currently we support: (4/13/05)
	break [0x]pc [sid] [{cmd;cmd;cmd}]
	break v:[0x]vaddr [sid] [{cmd;cmd;cmd}]
	break p:[0x]paddr [sid] [{cmd;cmd;cmd}]
	break &symbol [sid] [{cmd;cmd;cmd}]
	"""
	# TODO  we don't handle <breakpoint>.break, <breakpoint>.tbreak
	# TODO  we don't handle [length] [-r] [-w] [-x]
	if not cmd.startswith(CMD_breakpoint_break):
	    raise RuntimeError

	# 'break' by itself is a python keyword, cannot use it alone for
	# displaying the list of breakpoints, use enable|disable for that
	tokens = cmd.split()
	if len(tokens) >= 2:
	    if len(tokens) >= 3 and not tokens[2].startswith('{'):
		# breakpoint ona specific strand
		sid = int(tokens[2])
	    else:
		# breakpoint on all strands
		sid = -1
	    if tokens[1].startswith('&'):
		# symbol is used, it is considered a vaddr for PC breakpoint
		try:
		    if self.riesReposit.symTable:
			va = self.riesReposit.symTable.symbol2va(tokens[1][1:])
			if va >= 0:
			    self.setBpoint(va, sid, cmd, 'PC')
			else:
			    sys.stderr.write('WARNING: break: symbol %s not found\n' % (tokens[1][1:]))
			    return None
		    else:
			sys.stderr.write('WARNING: break: symbol table is not available\n')
			return None
		except Exception, ex:
		    self.wrongSyntax('1 %s, ex=%s' % (cmd, ex))
		    return None
	    else:
		# if not symbol, then the value must be in hex format, 
		# with or without 0x
		try:
		    if tokens[1].startswith('v:'):
			addr = long(tokens[1][2:], 16)
			self.setBpoint(addr, sid, cmd, 'VA')
		    elif tokens[1].startswith('p:'):
			addr = long(tokens[1][2:], 16)
			self.setBpoint(addr, sid, cmd, 'PA')
		    else:
			addr = long(tokens[1], 16)
			self.setBpoint(addr, sid, cmd, 'PC')
		except Exception, ex:
		    self.wrongSyntax('2 %s, ex=%s' % (cmd, ex))
		    return None
	else:
	    self.wrongSyntax('3 %s' % (cmd))
	    return None

	return None


    def setBpoint (self, addr, sid, cmd, type):
	"""
	"""
	if self.riesReposit.running == 1:
	    sys.stderr.write('Simulator is running, issue "stop" before adding breakpoint\n')
	    return
	elif addr % 4 != 0:
	    sys.stderr.write('ERROR: unaligned address\n')
	    return

	# right now we only support interval=1
	if self.riesReposit.symTable:
	    if type == 'PC':
		bid = self.riesReposit.riesling.getBreakpointTablePtr().add(sid, long(addr), 1, self.riesReposit.symTable.va2symbol(addr), BP_PC)
	    elif type == 'VA':
		bid = self.riesReposit.riesling.getBreakpointTablePtr().add(sid, long(addr), 1, self.riesReposit.symTable.va2symbol(addr), BP_VA)
	    else:
		bid = self.riesReposit.riesling.getBreakpointTablePtr().add(sid, long(addr), 1, self.riesReposit.symTable.pa2symbol(addr), BP_PA)
		
	else:
	    if type == 'PC':
		bid = self.riesReposit.riesling.getBreakpointTablePtr().add(sid, long(addr), 1, '', BP_PC)
	    elif type == 'VA':
		bid = self.riesReposit.riesling.getBreakpointTablePtr().add(sid, long(addr), 1, '', BP_VA)
	    else:
		bid = self.riesReposit.riesling.getBreakpointTablePtr().add(sid, long(addr), 1, '', BP_PA)

	self.bpoint[bid] = BreakPoint(bid, sid, addr, cmd, type)
	sys.stderr.write('Break id: %d at %#x\n' % (bid, addr))
	self.nextBpoint = bid + 1


    def handleDelete (self, cmd):
	"""
	delete (-all|id)
	"""
	if self.riesReposit.running == 1:
	    sys.stderr.write('Simulator is running, issue "stop" before deleting breakpoint\n')
	    return

	cmd = cmd.replace(',',' ')
	tokens = cmd.split()
	if tokens[1] == '-all':
	    # delete all
	    self.bpoint = { }
	    self.riesReposit.riesling.getBreakpointTablePtr().remove(-1)
	else:
	    i = 1
	    while i < len(tokens):
		bid = int(tokens[i])
		if self.bpoint.has_key(bid):
		    del self.bpoint[bid]
		    self.riesReposit.riesling.getBreakpointTablePtr().remove(bid)
		else:
		    sys.stderr.write('break id %d not found\n' % (bid))
		i += 1
	return None


    def handleEnable (self, cmd):
	"""
	"""
	return self._handleEnable(cmd, 1)


    def handleDisable (self, cmd):
	"""
	"""
	return self._handleEnable(cmd, 0)


    def _handleEnable (self, cmd, enable):
	"""
	disable (-all|id) 
	enable (-all|id) 
	"""
	if self.riesReposit.running == 1:
	    sys.stderr.write('Simulator is running, issue "stop" before enabling/disabling breakpoint\n')
	    return

	cmd = cmd.replace(',',' ')
	tokens = cmd.split()
	if len(tokens) == 1:
	    # display all breakpoints, regardless it is enabled or not
	    sys.stdout.write('%s\n' % (self.riesReposit.riesling.getBreakpointTablePtr().list()))
	    ##########DBX
## 	    print 'DBX: DBX DBX DBX' #DBX
## 	    klist = self.bpoint.keys()
## 	    klist.sort()
## 	    for bid in klist:
## 		if self.bpoint[bid].enable == enable:
## 		    sys.stdout.write('%s\n' % (self.bpoint[bid]))
	    ##########DBX
	elif tokens[1] == '-all':
	    # enable/disable all
	    if enable == 1:
		self.riesReposit.riesling.getBreakpointTablePtr().enable(-1)
	    else:
		self.riesReposit.riesling.getBreakpointTablePtr().disable(-1)
	    # even though we no longer rely on the frontend bpoint[] for
	    # everthing, it is good to keep it updated
	    for bid in self.bpoint.keys():
		self.bpoint[bid].enable = enable
		self.bpoint[bid].hitCount = 0
		self.bpoint[bid].justHit = 0
	else:
	    i = 1
	    while i < len(tokens):
		bid = int(tokens[i])
		if self.bpoint.has_key(bid):
		    if enable == 1:
			self.riesReposit.riesling.getBreakpointTablePtr().enable(bid)
		    else:
			self.riesReposit.riesling.getBreakpointTablePtr().disable(bid)
		    # ditto, keep it updated
		    self.bpoint[bid].enable = enable
		    self.bpoint[bid].hitCount = 0
		    self.bpoint[bid].justHit = 0
		else:
		    sys.stderr.write('break id %d not found\n' % (bid,))
		i += 1

	return None


    def handlePenable (self, cmd):
	"""
	"""
	return self._handlePenable(cmd, 1)


    def handlePdisable (self, cmd):
	"""
	"""
	return self._handlePenable(cmd, 0)


    def _handlePenable (self, cmd, enable):
	"""
	<processor>.disable
	<processor>.enable
	pdisable [("cpu-name"|-all)] 
	penable [("cpu-name"|-all|0x3210)]
	"""
	#sys.stderr.write('DBX: handlePenable(): cmd=%s enable=%d\n' % (cmd, enable)) #DBX

	if cmd.startswith(NAME_processor):
	    i = cmd.find('.')
	    tid = long(cmd[len(NAME_processor):i])
	    #TODO  this part never get called, somehow re cannot match 
	    #      thN.penable, thN.pdisable. 5/25/05
	    if tid < self.nstrandObjs:	
		if enable:
		    newRunning = long(1L<<tid) | self.riesReposit.strands[tid].RS_asiRead(0x41, 0x50L)
		else:
		    newRunning = ~long(1L<<tid) & self.riesReposit.strands[tid].RS_asiRead(0x41, 0x50L)
		self.riesReposit.strands[tid].RS_asiWrite(0x41, 0x50L, newRunning)
	    else:
		sys.stderr.write('ERROR: tid value out of bound\n') 	
	else:
	    tokens = cmd.lower().split()
	    if len(tokens) == 1:
		# list penable/pdisable
		running = self.riesReposit.strands[0].RS_asiRead(0x41, 0x50L)
		i = 0
		while i < self.nstrandObjs:
		    if ((running >> i) & 0x1L):
			sys.stdout.write('strand%d enabled\n' % (i))
		    i += 1
	    elif tokens[1] == '-all':
		if enable:
		    # enable all, asiWrite will mask the value with core_avail
		    self.riesReposit.strands[0].RS_asiWrite(0x41, 0x50L, 0xffffffffffffffffL)
		else:
		    # disable all, asiWrite will make sure one strand remains
		    # enabled.
		    self.riesReposit.strands[0].RS_asiWrite(0x41, 0x50L, 0x0L)
	    elif tokens[1].startswith('-mask='):
		# make sure we don't replace 0x with 00
		if tokens[1].startswith('-mask=0x'):
		    mask = long(tokens[1][len('-mask=0x'):].replace('x','0'),16)
		else:
		    mask = long(tokens[1][len('-mask='):].replace('x','0'),16)
		    if not enable:
			mask = 0xffffffffffffffffL ^ mask
		    self.riesReposit.strands[0].RS_asiWrite(0x41, 0x50L, mask)
	    elif tokens[1].lower().startswith('0x'):
		mask = long(tokens[1],16)
		if not enable:
		    mask = 0xffffffffffffffffL ^ mask
		self.riesReposit.strands[0].RS_asiWrite(0x41, 0x50L, mask)
	    else:
		if tokens[1].startswith(NAME_processor):
		    tid = int(tokens[1][len(NAME_processor):])
		    if tid < self.nstrandObjs:	
			if enable:
			    newRunning = long(1L<<tid) | self.riesReposit.strands[tid].RS_asiRead(0x41, 0x50L)
			else:
			    newRunning = ~long(1L<<tid) & self.riesReposit.strands[tid].RS_asiRead(0x41, 0x50L)
			self.riesReposit.strands[tid].RS_asiWrite(0x41, 0x50L, newRunning)
		    else:
			    sys.stderr.write('ERROR: tid value out of range\n')		
		else:
		    raise RuntimeError

	return None


    def handleRun (self, cmd):
	"""
	run [count] [strand-id]
	"""
	bpCmd = None
	tokens = cmd.split()
	if len(tokens) == 1:
	    # no #instr is specified, use max
	    ninstr = sys.maxint
	else:
	    # run #instr
	    ninstr = int(tokens[1])

	theTid = -1
	if len(tokens) >= 3:
	    # run on a particular strand only, otherwise round-rabin all 
	    # strands (theTid == -1)
	    theTid = int(tokens[2])

	if (theTid == -1):
	    self.stepOverPreviousHit()
	    tid = 0
	else:
	    tid = theTid
	count = 0
	done = 0
	while (done == 0) and (count < ninstr):
	    doneOne = 0
	    while (tid < self.nstrandObjs) and (doneOne == 0):
		if self.thdEnable[tid] == 1:
		    bid = self.riesReposit.strands[tid].step()
		    if (bid > 0):
			# hit a breakpoint
			#self.lastTid = tid
			self.handlePselect('pselect th%d' % tid)
			bpCmd = self.showBreakpoint(tid, bid)
			done = 1
			doneOne = 1
		    else:
			self.instrCount[tid] += 1
			#self.lastTid = tid
			#self.showLastInstr(tid, thd, pc)

		if (theTid == -1):
		    tid += 1
		else:
		    # only run on a particular strand, cut short of inner
		    # while loop
		    doneOne = 1

	    # out of inner while
	    if (theTid == -1):
		tid = 0
	    count += 1

	return bpCmd


    def handleRunfast (self, cmd):
	"""
	runfast [count] [strand-id]

	the difference between run and runfast is that with runfast, each
	strand will execute the specified number of instructions before pass
	the control to the next strand, unless a breakpoint is hit. 'run' will
	have each strand run one instruciton at a time, in a round-rabin order,
	until every strand has executed the specified number of instructions,
	or until a breakpoint is hit.
	"""
	bpCmd = None
	tokens = cmd.split()
	if (len(tokens) == 1):
	    # no #instr is specified, use 1, as control will not return
	    # until the specified number instructions have been executed,
	    # use sys.maxint here will send the execution into an endless loop
	    # ---> we have breakpoint in strand now, so treat it the same as 
	    #      run, which uses sys.maxint
	    ninstr = sys.maxint
	else:
	    # run #instr
	    ninstr = int(tokens[1])

	tid = -1
	if (len(tokens) >= 3):
	    # run on a particular strand only, otherwise round-rabin all 
	    # strands (tid == -1), but each strand runs the specified number
	    # of instructions before passes the control to the next strand,
	    # which is different to run, where each strand run one instruciton
	    # at a time.
	    tid = int(tokens[2])

	if (tid == -1):
	    self.stepOverPreviousHit()
	    i = 0
	    done = 0
	    while (done == 0 and i < self.nstrandObjs):
		if (self.thdEnable[i] == 1):
		    bid = self.riesReposit.strands[i].step(ninstr)
		    if (bid > 0):
			# hit a breakpoint, but we don't know how many
			# instructions have been executed before the breakpoint
			#self.lastTid = i
			self.handlePselect('pselect th%d' % i)
			bpCmd = self.showBreakpoint(i, bid)
			done = 1
		    else:
			self.instrCount[i] += ninstr
			#self.lastTid = i
			#self.showLastInstr(tid, thd, pc)
		i += 1
	else:
	    if (self.thdEnable[tid] == 1):
		bid = self.riesReposit.strands[tid].step(ninstr)
		if (bid > 0):
		    # hit a breakpoint, but we don't know how many
		    # instructions have been executed before the breakpoint
		    #self.lastTid = tid
		    self.handlePselect('pselect th%d' % tid)
		    bpCmd = self.showBreakpoint(tid, bid)
		    done = 1
		else:
		    self.instrCount[tid] += ninstr
		    #self.lastTid = tid
		    #self.showLastInstr(tid, thd, pc)

	return bpCmd


    def handleWhatis (self, cmd):
	"""
	whatis va
	"""
	tokens = cmd.split()
	va = 1
	if (len(tokens) == 1):
	    addr = 0
	else:
	    if tokens[1].startswith('p:'):
		addr = tokens[1][2:]
		va = 0
	    else:
		addr = tokens[1]
		
	if self.riesReposit.symTable:
	    #print 'addr=%s  va=' % (addr, va)
	    if va == 1:
		print '%s' % self.riesReposit.symTable.va2symbol(addr)
	    else:
		print '%s' % self.riesReposit.symTable.pa2symbol(addr)
	else:
	    print 'No symbol table is available'

	return None


    def hitBreakpoint (self, tid, thd):
	"""
	"""
	newCmd = '%s.getArchStatePtr().getPc()' % (thd)
	pc = eval(newCmd, self.riesReposit.globals)
	hit = 0
	for bin in self.bpoint.keys():
	    if self.bpoint[bin].isHit(pc) == 1:
		hit = 1
		newCmd = '%s.lastInstr()' % (thd)
		lastInstr = eval(newCmd, self.riesReposit.globals)
		newCmd = '%s.lastInstrToString()' % (thd)
		lastInstrCode = eval(newCmd, self.riesReposit.globals)
		symbol = self.riesReposit.symTable.va2symbol(pc)
		#sys.stdout.write('breakpoint: T%d, ic=%d, pc=<v:%#016x>[%s] [%08x] %s\n' % (tid, self.instrCount[tid], pc, symbol, lastInstr, lastInstrCode))
		sys.stdout.write('breakpoint: T%d, ic=%d, pc=<%s> [%08x] %s\n' % (tid, self.instrCount[tid], symbol, lastInstr, lastInstrCode))
		break   # out of 'for'

	return hit


    def showBreakpoint (self, tid, bid):
	"""
	"""
	thd = self.mapThdid(tid)
	newCmd = '%s.getArchStatePtr().getPc()' % (thd)
	pc = eval(newCmd, self.riesReposit.globals)
	symbol = self.riesReposit.symTable.va2symbol(pc)
	# let instrCount includes the instruction supposed to be executed, 
	# but didn't because of the breakpoint
	#sys.stdout.write('breakpoint %d: T%d, ic=%d, pc=<%s>\n' % (bid, tid, self.instrCount[tid]+1, symbol))
	# ---> ic won't be accurate when runfast is used, so might as well not
	#      showing it. 
	# ---> move the display to riesling backend, so that a basic breakpoint
	#      info is displayed there.
	#sys.stdout.write('Hit breakpoint %d: T%d, pc=<%s>\n' % (bid, tid, symbol))
	# take action(s) associated with the breakpoint
	if self.bpoint[bid].action != None and len(self.bpoint[bid].action) > 0:
	    # if 'run' or 'step' is part of a breakpoint's action, we can
	    # get into a recursive call-chain, when hitting the breakpoint
	    # triggers the 'run' (or 'step'), which in turns hits the same
	    # breakpoint, and on and on, ...
	    BP_ACTION = '.breakpoint_action'
	    fd = open(BP_ACTION, 'w')
	    for action in self.bpoint[bid].action:
		fd.write('%s\n' % action)
	    fd.close()
	    newCmd = 'execfile("%s")' % BP_ACTION
	else:
	    newCmd = None

	return newCmd

	# we check for breakpoint hit before the instruction is fetched,
	# so we don't have the instruction word yet.
	#newCmd = '%s.lastInstr()' % (thd)
	#lastInstr = eval(newCmd, self.riesReposit.globals)
	#newCmd = '%s.lastInstrToString()' % (thd)
	#lastInstrCode = eval(newCmd, self.riesReposit.globals)
	##sys.stdout.write('breakpoint: T%d, ic=%d, pc=<v:%#016x>[%s] [%08x] %s\n' % (tid, self.instrCount[tid], pc, symbol, lastInstr, lastInstrCode))
	#sys.stdout.write('breakpoint: T%d, ic=%d, pc=<%s> [%08x] %s\n' % (tid, self.instrCount[tid], symbol, lastInstr, lastInstrCode))


    def stepOverPreviousHit (self):
	"""
	every time before we step, we reset breakpoint hit status so
	that we won't hit the same point twice in a row. If T1 hits a
	breakpoint, then in the next step/run command T0 is executed first 
	T0 will reset the breakpoint hit status, so when T1 is to execute 
	again, it can hit the same breakpoint, which is not desirable, so we
	want step over that first. If user chooses to step/run a particular
	strand after a breakpoint hit, then we don't execute the function
	first, even if that means T1 in the above example will hit the same
	breakpoint twice in a row. One problem with this function is that
	the strand which hit a breakpoint in the previous step/run will execute
	one extra instruction than user specified.
	"""
	sid = self.riesReposit.riesling.getBreakpointTablePtr().querySid()
	if ((sid >= 0) and (self.thdEnable[sid] == 1)):
	    self.riesReposit.strands[sid].step()
	    self.instrCount[sid] += 1


    def handleAlias (self, cmd):
	"""alias
	alias zzz z1 [z2]*
	"""
	tokens = cmd.split()
	if len(tokens) == 1:
	    # list alias
	    klist = self.alias.keys()
	    klist.sort()
	    for key in klist:
		sys.stdout.write('alias %s == %s\n' % (key, self.alias[key]))
	elif len(tokens) >= 3:
	    # set alias
	    self.alias[tokens[1]] = ' '.join(tokens[2:])
	else:
	    self.wrongSyntax(cmd)

	return None


    def handleUnalias (self, cmd):
	"""unalias zzz [zzz]*
	"""
	cmd = cmd.replace(',', ' ')
	tokens = cmd.split()
	i = 1
	while i < len(tokens):
	    if self.alias.has_key(tokens[i]):
		del self.alias[tokens[i]]
	    i += 1
	
	return None


    def handleHelp (self, cmd):
	"""
	"""
	tokens = cmd.split()
	if len(tokens) == 1:
	    # show high level help
	    self.showDoc()
	    print '\nTo use python help utility, enter help()'
	else:
	    # get down to detail
	    if tokens[1] == 'regid' or tokens[1] == 'regname':
		# show regid to regname mapping
		print self.regmap
	    else:
		self.showDoc(tokens[1])

	return None


##     def handleReset (self, cmd):
## 	"""handle system reset
## 	syntax: reset [traptype=0x1]

## 	traptype=0x1: power_on_reset
## 	"""
## 	tokens = cmd.split()
## 	traptype = 0x1
## 	if len(tokens) >= 2:
## 	    traptype = eval(tokens[2])

## 	i = 0
## 	while i < self.nstrandObjs:
## 	    self.instrCount[i] = 0
## 	    i += 1

## 	RS_reset(traptype)
## 	return None

##     def handleReset (self, cmd):
## 	"""return every strand's pc to power-on-reset
## 	"""
## 	# .RED.Power_on_Reset	fffffffff0000020 X fff0000020
## 	try:
## 	    pc = self.riesReposit.symTable.symbol2va('.RED.Power_on_Reset')
## 	    if pc == -1:
## 		sys.stderr.write('symbol .RED.Power_on_Reset not found\n')
## 		pc = 0xfffffffff0000020
## 	except:
## 	    pc = 0xfffffffff0000020

## 	i = 0
## 	while i < self.nstrandObjs:
## 	    if self.thdEnable[i] == 1:
## 		self.instrCount[i] = 0
## 		thd = self.mapThdid(i)
## 		newCmd = '%s.getArchStatePtr().setPc(value=%u)' % (thd, pc)
## 		eval(newCmd, self.riesReposit.globals)
## 		newCmd = '%s.getArchStatePtr().setNpc(value=%u)' % (thd, pc+4)
## 		eval(newCmd, self.riesReposit.globals)
## 	    i += 1

## 	return None


    def handleIgnore (self, cmd):
	"""
	ignore id num 
	sys.stderr.write('%s\n' % (newCmd,))
	"""
	sys.stderr.write('"ignore" command is not supported\n')
	return None

	tokens = cmd.split()
	retval = self.checkArgs([tokens[1],tokens[2]])
	if not retval == [True,True]:
		sys.stderr.write('ERROR: wrong i/p paramters\n')
		return
	id = int(tokens[1])
	num = int(tokens[2])
	if self.bpoint.has_key(id):
		self.bpoint[id].ignore = num
		self.bpoint[id].hitCount = 0
		self.bpoint[id].justHit = 0
	else:
		sys.stderr.write('ERROR: Break id not found\n')
	return None


    def handleListBreak (self, cmd):
	"""
	list-breakpoints [-all]
	"""
	sys.stdout.write('%s\n' % (self.riesReposit.riesling.getBreakpointTablePtr().list()))
## 	klist = self.bpoint.keys()
## 	klist.sort()
## 	for id in klist:
## 	    sys.stdout.write('%s\n' % (self.bpoint[id]))


    def handlePselect (self, cmd):
	"""
	pselect ["cpu-name"] 
	"""
	tokens = cmd.split()
	if len(tokens) == 1:
	    sys.stdout.write('pselect: th%d\n' % (self.lastTid))
	else:
	    if tokens[1].startswith(NAME_processor):	
		    tid = int(tokens[1][len(NAME_processor):])
		    if tid < self.nstrandObjs:
			self.lastTid = tid
			sys.ps1 = "%s-th%d>>> " % (self.riesReposit.prompt, self.lastTid)
		    else:
			sys.stderr.write('ERROR: tid value out of range\n')
	    else:
		    sys.stderr.write('ERROR: wrong input parameter, enter tid as thN\n')	 	


    def handleQuit (self, cmd):
	"""
	quit [status] 
	"""
	tokens = cmd.split()
	status = 0
	if len(tokens) > 1:
	    try:
		status = int(tokens[1])
	    except:
		pass

	# if pli-socket does not present, we shouldn't make socketAPI calls
	try:
	    self.riesReposit.socketAPI.fini()
	except:
	    pass

	if (status == 0):
	    sys.exit(self.riesReposit.riesling.getBreakpointTablePtr().isBadTrap())
	else:
	    sys.exit(status)


    def handleRunCommandFile (self, cmd):
	"""
	run-command-file file 
	"""
	return self.handleRunPythonFile(cmd)


    def handleRunPythonFile (self, cmd):
	"""
	run-python-file filename 
	"""
	tokens = cmd.split()
	newCmd = 'execfile("%s")' % (tokens[1])
	return newCmd


    def handleVa2Pa (self, cmd):
	"""
	<processor>.logical-to-physical address 
	logical-to-physical ["cpu-name"] address 
	"""
	tokens = cmd.split()
	if cmd.startswith(NAME_processor):
	    i = cmd.find('.')
	    tid = int(cmd[len(NAME_processor):i])
	    va = tokens[1]
	else:
	    if tokens[1].startswith(NAME_processor):
		tid = int(tokens[1][len(NAME_processor):])
		va = tokens[2]
	    else:
		tid = self.lastTid
		va = tokens[1]

	# remove leading 'v:' if any
	if va.startswith(SYM_VA):
	    va = va[len(SYM_VA):]


	if tid >= self.nstrandObjs:
		sys.stderr.write('ERROR: strand id out of bounds\n')
		return ''

	paddr = RS_logical_to_physical(tid, 1, eval(va))
	if paddr == 0xdeadbeefL:
	    paddr = RS_logical_to_physical(tid, 0, eval(va))

	newCmd = 'hex(%s)' % (paddr)
	return newCmd

    def handleDisassemble (self, cmd):
	"""
	<processor>.disassemble [address [count]] 
	disassemble [address [count]]
	"""
	count = '1'
	addr = 'X'
	sympa = False   # default is VA
	tokens = cmd.split()
	if cmd.startswith(NAME_processor):
	    i = cmd.find('.')
	    tid = int(cmd[len(NAME_processor):i])
	else:
	    tid = self.lastTid

	if len(tokens) > 1:
	    addr = tokens[1]
	    if len(tokens) > 2:
		count = tokens[2]

	if tid >= self.nstrandObjs:
	    sys.stderr.write('ERROR: strand id out of bounds\n')
	    return

	thd = self.mapRS(tid, RegisterMap.LEVEL_STRAND)
	
	if addr.startswith(SYM_PA):
	    addr = addr[len(SYM_PA):]
	    sympa = True
	elif addr.startswith(SYM_VA):
	    addr = addr[len(SYM_VA):]
	else:
	    if addr == 'X':
		# use selected strand's pc
		newCmd = thd + '.getArchStatePtr().getPc()'
		n_addr = eval(newCmd, self.riesReposit.globals)
		addr = str(n_addr)	
	## 	    newCmd = '%s.%s(va=%s,type=1)' % (thd, 'va2pa', addr)
	## 	    pa = eval(newCmd, self.riesReposit.globals)
		#pa = RS_logical_to_physical(tid, 1, n_addr)
		#sympa = True

	if self.checkArgs([addr,count]) != [True, True]:
	    sys.stderr.write('ERROR: invalid address or count arguments\n')
	    return

	if sympa:
	    # this is a physical address already
	    pa = self.str2long(addr)
	else:
	    # virtual address
##		addr = addr[len(SYM_VA):]
## 	    newCmd = '%s.%s(va=%s,type=1)' % (thd, 'va2pa', addr)
## 	    pa = eval(newCmd, self.riesReposit.globals)
	    pa = RS_logical_to_physical(tid, 1, eval(addr))

	i = 0
	while i < int(count):
	    i += 1
	    (size,iwStr) = RS_disassemble(tid, pa, 0)
	    sys.stdout.write('%s\n' % (iwStr))
	    pa += 4

	return None


    def str2long (self, str):
	"""
	"""
	if str.startswith('0x') or str.startswith('0X'):
	    return long(str, 16)
	elif str.startswith('0'):
	    return long(str, 8)
	else:
	    return long(str, 10)


    def handleTodo (self, cmd):
	"""
	"""
	self.todo(cmd)
	raise RuntimeError


    def wrongSyntax (self, cmd):
	"""
	"""
	sys.stderr.write('Wrong command syntax: <%s>\n' % (cmd))
	raise RuntimeError
	

    def showtraceback(self):
        """Display the exception that just occurred.
        #We remove the first stack item because it is our own code.
        The output is written by self.write(), below.
        """
	import traceback

        try:
            type, value, tb = sys.exc_info()
            sys.last_type = type
            sys.last_value = value
            sys.last_traceback = tb
            tblist = traceback.extract_tb(tb)
            #del tblist[:1]
            list = traceback.format_list(tblist)
            if list:
                list.insert(0, "Traceback (most recent call last):\n")
            list[len(list):] = traceback.format_exception_only(type, value)
        finally:
            tblist = tb = None

        map(self.write, list)
	#sys.stderr.write('%s' % (list))


    def write (self, data):
	"""
	"""
	sys.stderr.write(data)


    def replaceToken (self, cmd):
	"""replace %reg with RS_read_register_name() so that the %reg can be
	treated as a variable and used in any valid python expression.
	"""
	tokens = splitRE.split(cmd)
	for token in tokens:
	    if token.startswith('%'):
		if self.regmap.hasKey(token[1:]):
		    newToken = 'RS_read_register_name("%s",tid=%d)' % (token[1:], self.lastTid)
		    #sys.stderr.write('DBX: newToken=%s\n' % (newToken)) #DBX
		    cmd = cmd.replace(token, newToken)
		    return self.replaceToken(cmd)

	return cmd

	




"""self-testing
"""
if __name__ == "__main__":
    """
    """
    from base import Repository
    niParser = CmdParserNi(Repository.Repository())




