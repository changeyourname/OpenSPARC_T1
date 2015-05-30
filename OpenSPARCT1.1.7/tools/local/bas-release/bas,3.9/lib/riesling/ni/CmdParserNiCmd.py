# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: CmdParserNiCmd.py
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
"""provide user commands' equivalent of function calls.
"""

import re, sys

from ni import RegisterMap


NAME_CPU    = 'cpu'
NAME_CORE   = 'core'
NAME_UCORE   = 'ucore'
NAME_STRAND = 'strand'

TRAP_LEVEL = 6

# before any function in this file is used, the following global variables 
# must be assigned a valid object.
_myReposit = None   # RiesReposit object
_myRegmap = RegisterMap.RegisterMap()

_myNstrandObj = 1
_myCpusize = 0
_myCoresize = 0
_myuCoresize = 0

_myStrandMap = { }
_myuCoreMap = { }
_myCoreMap = { }
_myCpuMap = { }

_myInstrCount = { }
_myLastTid = 0

_myVerbose = 1

# zzz_cmd_RS() function registry
# API_DOCS[api-ext]=('api-ext syntax', 'API-EXT', 'short-desc', 'long-desc')
# RS_zzz() API registry
# API_DOCS[api]=('api syntax', 'API', 'short-desc', 'long-desc')
API_DOCS = { }


class InstrInfo:
    """a class contins instr information
    TODO  need more work/fields
    """
    def __init__ (self, name, type):
	"""
	"""
	self.name = name
	self.type = type


def initCmdParserNiCmd (reposit, nstrandObjs):
    """this function must be called before any other functions in this file
    can be used.
    """
    global _myReposit
    global _myNstrandObj
    global _myCpusize
    global _myCoresize
    global _myuCoresize
    global _myInstrCount

##     global nasUtil

    _myReposit = reposit

    if _myReposit.nucores == 0:
	_myCpusize = _myReposit.ncores * _myReposit.nstrands
	_myCoresize = _myReposit.nstrands
	_myuCoresize = 1
    else:
	_myCpusize = _myReposit.ncores * _myReposit.nucores * _myReposit.nstrands
	_myCoresize = _myReposit.nucores * _myReposit.nstrands
	_myuCoresize = _myReposit.nstrands

    total = _myCpusize * _myReposit.ncpus
    if total != nstrandObjs:
	sys.stderr.write('WARNING: CmdParserNiCmd: initCmdParserNiCmd: total=%d, nstrandObjs=%d\n' % (total, nstrandObjs))

    _myNstrandObj = nstrandObjs
    i = 0
    while i < _myNstrandObj:
	_myInstrCount[i] = 0
	i += 1

##     if _myReposit.optdir.has_key('--blaze'):
## 	if _myReposit.optdir['--blaze'] == 'n2':
## 	    import nasUtil
## 	elif _myReposit.optdir['--blaze'] == 'ni':
## 	    import basUtil as nasUtil
## 	elif _myReposit.optdir['--blaze'] == 'rk':
## 	    import rockUtil as nasUtil
##     else:
## 	import nasUtil

##     # init nas utility
##     nasUtil.init(_myReposit.sysAddr)
    # register cmd_func and api
    _initDoc()


def _initDoc ():
    """ATTENTION!! remember to register any additional zzz_cmd_RS() or
    RS_zzz() document.
    """
    global API_DOCS

    #API_DOCS['sstepi_cmd_RS'] = ("sstepi_cmd_RS(thStr)", 'API-EXT', 'step one instruction of a specified strand', 'thStr has a format of "l"+strandid')
    #API_DOCS['obj_read_reg_cmd_RS'] = ("obj_read_reg_cmd_RS(tid,regname)", 'API-EXT', 'read a register by regname', 'TODO')

    API_DOCS['RS_set_quiet'] = ("RS_set_quiet(num)", 'API', 'num=1 enable quiet mode, 0 disable it', 'TODO')
    API_DOCS['RS_proc_no_2_ptr'] = ("RS_proc_no_2_ptr(tid)", 'API', 'nop, return the input strand id', 'TODO')
    #API_DOCS['RS_current_processor'] = ("RS_current_processor()", 'API', 'return the current strand id', 'TODO')
    API_DOCS['RS_logical_to_physical'] = ("RS_logical_to_physical(tid,type,addr)", 'API', 'convert logical address to physical address', 'TODO')
    API_DOCS['RS_write_phys_memory'] = ("RS_write_phys_memory(tid,addr,value,size)", 'API', 'write to a physical memory', 'TODO')
    API_DOCS['RS_read_phys_memory'] = ("RS_read_phys_memory(tid,addr,size)", 'API', 'read from a physical memory', 'TODO')
    API_DOCS['RS_disassemble'] = ("RS_disassemble(tid,addr,isva)", 'API', 'disassemble an instruction', 'TODO')
    API_DOCS['RS_disassemblePC'] = ("RS_disassemblePC(tid)", 'API', 'disassemble the just executed instruction', 'TODO')
    #API_DOCS['RS_instruction_info'] = ("RS_instruction_info(tid,currpc)", 'API', 'retrieve information of an instruction', 'TODO')
    API_DOCS['RS_read_fp_register_x'] = ("RS_read_fp_register_x(tid,regid)", 'API', 'read from a floating-point double register' ,'TODO')
    API_DOCS['RS_read_fp_register_i'] = ("RS_read_fp_register_i(tid,regid)", 'API', 'read from a floating-point single register' ,'TODO')
    API_DOCS['RS_write_fp_register_x'] = ("RS_write_fp_register_x(tid,regid,value)", 'API', 'write to a floating-point double register' ,'TODO')
    API_DOCS['RS_write_fp_register_i'] = ("RS_write_fp_register_i(tid,regid,value)", 'API', 'write to a floating-point single register' ,'TODO')
    API_DOCS['RS_print_archregs'] = ("RS_print_archregs(tid=0,a_str='')", 'API', 'print out integer/floating-point/control registers', 'TODO')
    API_DOCS['RS_print_regs'] = ("RS_print_regs(tid=0,a_str='')", 'API', 'print out integer/floating-point/control registers', 'TODO')
    API_DOCS['RS_print_fpregs'] = ("RS_print_fpregs(tid=0)", 'API', 'print out floating-point registers', 'TODO')
    API_DOCS['RS_print_mmuregs'] = ("RS_print_mmuregs(tid=0)", 'API', 'print out mmu regsiters', 'TODO')
    API_DOCS['RS_print_cmpregs'] = ("RS_print_cmpregs(tid=0)", 'API', 'print out cmp regsiters', 'TODO')
    API_DOCS['RS_get_register_number'] = ("RS_get_register_number(tid,regname)", 'API', 'convert a regname to a regid', 'TODO')
    API_DOCS['RS_write_register'] = ("RS_write_register(tid,regid,value)", 'API', 'write to a register by regid', 'TODO')
    API_DOCS['RS_write_register_name'] = ("RS_write_register_name(regname,value,tid=0)", 'API', 'write to a register by regname', 'TODO')
    API_DOCS['RS_read_register'] = ("RS_read_register(tid,regid)", 'API', 'read a register by regid', 'TODO')
    API_DOCS['RS_read_register_name'] = ("RS_read_register_name(regname,tid=0)", 'API', 'read a register by regname', 'TODO')
    #API_DOCS['RS_reset'] = ("RS_reset(traptype=0x1)", 'API', 'reset all strands back to a system state', 'TODO')
    API_DOCS['RS_asi_read'] = ("RS_asi_read(asi,va,tid)", 'API', 'read an asi value by asi/va', 'TODO')
    API_DOCS['RS_asi_write'] = ("RS_asi_write(asi,va,value,tid)", 'API', 'write an asi value by asi/va', 'TODO')
    API_DOCS['RS_dump_tlb'] = ("RS_dump_tlb(tid,itlb,valid)", 'API', 'dump i/d-tlb content', 'TODO')


def showApiDoc (key=None):
    """return 1 means a match is found, 0 means no match
    """
    if key:
	# strip off ' ', '(', or ')',  they are not part of the key
	i = key.find('(')
	if i > -1:
	    key = key[:i]
	key = key.strip()
	if API_DOCS.has_key(key):
	    (func,type,shortd,longd) = API_DOCS[key]
	    print '%s: %s: \t%s' % (type, func, shortd)
	    if longd and longd != 'TODO':
		print '\t\t%s' % (longd)
	    return 1
	else:
	    return 0
    else:
	# show all docs
	byType = { }
	for (key2,(func,type,shortd,longd)) in API_DOCS.items():
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
    return 1


def _mapRS (tid, level=RegisterMap.LEVEL_STRAND):
    """
    """
    if level == RegisterMap.LEVEL_STRAND:
	return _mapThdid(tid)
    elif level == RegisterMap.LEVEL_UCORE:
	return _mapuCoreid(tid)
    elif level == RegisterMap.LEVEL_CORE:
	return _mapCoreid(tid)
    elif level == RegisterMap.LEVEL_CPU:
	return _mapCpuid(tid)
    else:
	return _myReposit.topName


def _mapThdid (tid):
    """
    """
    global _myStrandMap

    if tid >= _myNstrandObj:
	return None
    
    if not _myStrandMap.has_key(tid):
	_myStrandMap[tid] = 'strands[%d]' % tid

##     if not _myStrandMap.has_key(tid):
## 	cpuid = tid / _myCpusize
## 	leftover = tid % _myCpusize
## 	coreid = leftover / _myReposit.nstrands
## 	strandid = leftover % _myReposit.nstrands
## 	_myStrandMap[tid] = '%s.%s%d.%s%d.%s%d' % (_myReposit.topName, NAME_CPU, cpuid, NAME_CORE, coreid, NAME_STRAND, strandid)

    return _myStrandMap[tid]


def _mapuCoreid (tid):
    """
    """
    global _myuCoreMap

    if tid >= _myNstrandObj:
	return None

    if not _myuCoreMap.has_key(tid):
	ucoreid = tid / _myuCoresize
	_myuCoreMap[tid] = 'ucores[%d]' % ucoreid


def _mapCoreid (tid):
    """
    """
    global _myCoreMap

    if tid >= _myNstrandObj:
	return None

    if not _myCoreMap.has_key(tid):
	coreid = tid / self.coresize
	_myCoreMap[tid] = 'cores[%d]' % coreid

## 	cpuid = tid / _myCpusize
## 	leftover = tid % _myCpusize
## 	coreid = leftover / _myReposit.nstrands
## 	_myCoreMap[tid] = '%s.%s%d.%s%d' % (_myReposit.topName, NAME_CPU, cpuid, NAME_CORE, coreid)

    return _myCoreMap[tid]


def _mapCpuid (tid):
    """
    """
    global _myCpuMap

    if tid >= _myNstrandObj:
	return None
    
    if not _myCpuMap.has_key(tid):
	cpuid = tid / self.cpusize
	_myCpuMap[tid] = 'cpus[%d]' % cpuid

## 	cpuid = tid / _myCpusize
## 	_myCpuMap[tid] = '%s.%s%d' % (_myReposit.topName, NAME_CPU, cpuid)

    return _myCpuMap[tid]


def _evalCmd (cmd):
    """
    """
    #print '#DBX: cmd=', cmd
    return eval(cmd, _myReposit.globals)

###############################################################################

def incrIcount_RSI (tid, count=1):
    """RSI means riesling internal, not meant for general users
    """
    global _myInstrCount
    global _myLastTid

    _myInstrCount[tid] += count
    _myLastTid = tid


def getIcount_RSI (tid):
    """
    """
    return _myInstrCount[tid]


def setLastTid_RSI (tid):
    """
    """
    global _myLastTid

    _myLastTid = tid
    

def getLastTid_RSI ():
    """
    """
    return _myLastTid


def isVerbose ():
    """
    """
    return _myVerbose

###############################################################################

def sstepi_cmd_RS (thStr):
    """e.g., thStr='l0'
    """
    tid = int(thStr[1:])
    thd = _mapRS(tid)
    # get the pc before stepping
    newCmd = '%s.%s()' % (thd, 'getArchStatePtr().getPc')
    pc = _evalCmd(newCmd)
    # step one instr
    newCmd = '%s.%s()' % (thd, 'step')
    _evalCmd(newCmd)
    # increase instr count
    incrIcount_RSI(tid)

##     # display the stepped instr
##     if _myVerbose == 1:
## 	# get stepped instruction word
## 	newCmd = '%s.%s()' % (thd, 'lastInstr')
## 	iw = _evalCmd(newCmd)
## 	newCmd = '%s.%s()' % (thd, 'lastInstrToString')
## 	iwstr = _evalCmd(newCmd)
## 	sys.stdout.write('T%d: %d: <v:%016x> [%08x] %s\n' % (tid, getIcount_RSI(tid), pc, iw, iwstr))

    
def pregs_cmd_RS (tid=0, a_str=''):
    """wrapper for RS_print_archregs(), depricated.
    """
    RS_print_archregs(tid, a_str)

    
def pregsMmu_cmd_RS (tid=0):
    """wrapper for RS_print_mmuregs(), depricated.
    """
    RS_print_mmuregs(tid)


def _readCtlReg(cmd, regname, i, stride, buffer):
    """
    """
    buffer.append('%s=%#x  ' % (regname, _evalCmd(cmd)))
    i = _addEOL(i, stride, buffer)
    return i


def _addEOL (i, stride, buffer):
    """
    """
    i += 1
    if i % stride == 0:
	buffer.append('\n')
    return i
    

def obj_read_reg_cmd_RS (tid, regname):
    """obj_read_reg_cmd(th_obj, "pc"):
    """
    cmd = '%s %s' % ('read-reg', regname)
    (level,rrs) = _myRegmap.mapReadRS(regname, cmd)
    toprs = _mapRS(tid, level)
    newCmd = '%s.%s' % (toprs, rrs)
    return _evalCmd(newCmd)

###############################################################################

def RS_set_quiet(num):
    """1 --- enable quiet mode, 0 disable it.
    """
    global _myVerbose

    #nasUtil.stepQuiet_cmd(num);
    if num:
	_myReposit.riesLib.N2_CBInterface.suspendCB();
    else:
	_myReposit.riesLib.N2_CBInterface.resumeCB();

    if num == 1:
	_myVerbose = 0
    elif num == 0:
	_myVerbose = 1
    else:
	raise RuntimeError


def RS_proc_no_2_ptr(tid):
    """th_obj= RS_proc_no_2_ptr(tid)
    """
    # for our Ni command parsing purpose, the tid is quite enough
    return tid


def RS_current_processor ():
    """
    """
    return _myLastTid


def RS_logical_to_physical (tid, type, vaddr):
    """type == 1: instr, 0: data
    """
    #sys.stderr.write('DBX: RS_logical_to_physical: tid=%d, type=%d, vaddr=%#x\n' % (tid, type, vaddr))
    # TODO  python -> C/C++ complains about 0xf--------------- too big a
    #       long to be converted, mask out the highest bit as a workaround
    #return nasUtil.translate_cmd(tid, type, (vaddr & 0x7fffffffffffffff))
    #sys.stderr.write('DBX: RS_logical_to_physical: pa=%#x\n' % (_myReposit.strands[tid].RS_translate(type, long(vaddr))))
    return _myReposit.strands[tid].RS_translate(type, long(vaddr))


def RS_write_phys_memory (tid, addr, value, size):
    """RS_write_phys_memory(th_obj, 0x9a00000000, orig_tid, 4):
    """
    #sys.stderr.write('DBX: RS_write_phys_memory: tid=%d, addr=%#x, value=%#x, size=%d\n' % (tid, addr, value, size))

    if not size in [1,2,4,8]:
	sys.stderr.write('ERROR: write_phys_memory: wrong size %d, must be 1,2,4,8-byte\n' % (size))
    else:
	#nasUtil.access_cmd(addr, value, tid, 0, size)
	_myReposit.strands[tid].RS_access(long(addr), long(value), 0, size)

	# with type 'K', we can pass over uint64_t value with bit63=1
## 	if size == 8 and value > 0x7fffffffffffffff:
## 	    #TODO  I am having difficulty in passing larger value to c++ code,
## 	    #      always get "OverflowError: long too big to convert" error,
## 	    #      have to split the large value into two 4-byte pieces --- 
## 	    #      waiting for an explanation/solution from python community. 
## 	    #      10/13/04
## 	    value1 = value >> 32                   # upper 32-bit
## 	    value2 = value & 0x00000000ffffffffL   # lower 32-bit
## 	    nasUtil.access_cmd(addr, value1, tid, 0, 4)
## 	    nasUtil.access_cmd(addr+4, value2, tid, 0, 4)
## 	else:
## 	    nasUtil.access_cmd(addr, value, tid, 0, size)


def RS_read_phys_memory (tid, addr, size):
    """
    """
    #sys.stderr.write('DBX: RS_read_phys_memory: tid=%d, addr=%#x, size=%d\n' % (tid, addr, size))
    # the data is returned as L, if the highest bit (bit63) is 1, python
    # will present it as negative long, so have to convert it back because
    # we want uint64. ---> change type to K does not help, still return
    # negative.
    if not size in [1,2,4,8]:
	sys.stderr.write('ERROR: RS_read_phys_memory: wrong size %d, must be 1,2,4,8-byte\n' % (size))
	return None

    if long(addr) % size:
	sys.stderr.write('ERROR: RS_read_phys_memory: addr %#x is not %d-byte aligned\n' % (addr, size))
	return None
			 
    #data = nasUtil.access_cmd(addr, 0, tid, 1, size)
    data = _myReposit.strands[tid].RS_access(long(addr), 0L, 1, size)
    if (data < 0):
	data = 0xffffffffffffffffL + data + 1
    return data


def RS_disassemble (tid, addr, isva):
    """(_, dis_str ) = RS_disassemble(th_obj, currpc, 1)
    """
    #sys.stderr.write('DBX: RS_disassemble: tid=%d, addr=%#x, isva=%d\n' % (tid, addr, isva))
    if isva == 1:
	# logical address, have to convert it to physical addr
	paddr = RS_logical_to_physical(tid, 1, addr)
    else:
	paddr = addr

    # get instr word
    #iw = nasUtil.access_cmd(paddr, 0, tid, 1, 4)
    iw = _myReposit.strands[tid].RS_access(long(paddr), 0L, 1, 4)
    # disassemble the instr
    #iwStr = '[%08x] %s' % (iw, nasUtil.disassemble_cmd(tid, iw))
    #sys.stderr.write('DBX: RS_disassemble: iw=%#x\n' % (iw))
    iword = _myReposit.strands[tid].RS_getInstrPtr(iw);
    iwStr = '[%08x] %s' % (iw, iword.toString())

    return (4, iwStr)


def RS_disassemblePC (tid):
    """(_, dis_str ) = RS_disassemblePC(th_obj)
    """
    # disassemble the just executed instr
    #return (4, nasUtil.disassemblePC_cmd(tid))
    iword = _myReposit.strands[tid].getLastInstrPtr();
    # rock iword does not always have valid ppc
    #iwStr = 'vpc=%#010x (ppc=%#010x), [%08x] %s' % (iword.getPc(), iword.getPpc(), iword.getNative(), iword.toString())
    iwStr = 'vpc=%#010x, [%08x] %s' % (iword.getPc(), iword.getNative(), iword.toString())
    return (4, iwStr)


def RS_instruction_info (tid, currpc):
    """instr = RS_instruction_info(RS_current_processor(), currpc)
    """
    # TODO  InstrInfo should contain more information
    (size,iw) = RS_disassemble(tid, currpc, 1)
    tokens = re.split('\s+|,', iw)
    return InstrInfo(tokens[1], -99)


def RS_read_fp_register_x (tid, regid):
    """dest_val = RS_read_fp_register_x(th_obj, rd_n)
    """
    thd = _mapRS(tid)
    newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().getDpfp(%s)' % (thd, regid)
    return _evalCmd(newCmd)


def RS_read_fp_register_i (tid, regid):
    """dest_val = RS_read_fp_register_i(th_obj, rd_n)
    """
    thd = _mapRS(tid)
    newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().getSpfp(%s)' % (thd, regid)
    return _evalCmd(newCmd)


def RS_write_fp_register_x (tid, regid, value):
    """
    """
    thd = _mapRS(tid)
    newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().setDpfp(%s,%sL)' % (thd, regid, value)
    _evalCmd(newCmd)


def RS_write_fp_register_i (tid, regid, value):
    """
    """
    thd = _mapRS(tid)
    newCmd = '%s.getArchStatePtr().getFloatRegisterFilePtr().setSpfp(%s,%s)' % (thd, regid, value)
    _evalCmd(newCmd)


def RS_print_archregs (tid=0, a_str=''):
    """
    """
    sys.stdout.write('Strand %d:\n' % tid)
    archState = _myReposit.strands[tid].getArchStatePtr()
    regfile = archState.getRegisterFilePtr()
    if a_str != '-all':
	# show current register window
	sys.stdout.write('\t%g \t\t%o \t\t\t%l \t\t%i\n')
	for i in range(8):
	    sys.stdout.write('%d %#018x' % (i, regfile.get(i)))
	    sys.stdout.write('  %#018x' % regfile.get(i+8))
	    sys.stdout.write('  %#018x' % regfile.get(i+16))
	    sys.stdout.write('  %#018x' % regfile.get(i+24))
	    sys.stdout.write('\n')
    else:
	# show all global register sets
	sys.stdout.write('\t%g (set 0) \t%g (set 1) \t\t%g (set 2) \t%g (set 3)\n')
	for i in range(8):
	    sys.stdout.write('%d %#018x' % (i, regfile.get(0, i)))
	    sys.stdout.write('  %#018x' % regfile.get(1, i))
	    sys.stdout.write('  %#018x' % regfile.get(2, i))
	    sys.stdout.write('  %#018x' % regfile.get(3, i))
	    sys.stdout.write('\n')

	# show all register windows
	sys.stdout.write('\n')
	sys.stdout.write('\t%o \t\t%l \t\t\t%i\n')
	nwindows = regfile.getNWINDOWS();
	for j in range(nwindows):
	    sys.stdout.write('Window %d:\n' % j)
	    for i in range(8):
		sys.stdout.write('  %#018x' % regfile.get(j, i+8))
		sys.stdout.write('  %#018x' % regfile.get(j, i+16))
		sys.stdout.write('  %#018x' % regfile.get(j, i+24))
		sys.stdout.write('\n')
    sys.stdout.write('\n')
    sys.stdout.write('\t%pc \t\t%npc \t\t\t%tba \t\t%cwp\n')
    sys.stdout.write('  %#018x' % archState.getPc())
    sys.stdout.write('  %#018x' % archState.getNpc())
    sys.stdout.write('  %#018x' % archState.getTbaRegPtr().getNative())
    sys.stdout.write('  %#018x' % regfile.getCWP())
    sys.stdout.write('\n')
    sys.stdout.write('\t%ccr \t\t%fprs \t\t\t%fsr \t\t%pstate\n')
    sys.stdout.write('  %#018x' % archState.getCcrRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getFprsRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getFsrRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getPstateRegPtr().getNative())
    sys.stdout.write('\n')
    sys.stdout.write('\t%asi \t\t%tick \t\t\t%tl \t\t%pil\n')
    sys.stdout.write('  %#018x' % archState.getAsiRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getTickRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getTrapLevelRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getPilRegPtr().getNative())
    sys.stdout.write('\n')
    sys.stdout.write('\t%cansave \t%canrestore \t\t%cleanwin \t%otherwin\n')
    sys.stdout.write('  %#018x' % regfile.getCANSAVE())
    sys.stdout.write('  %#018x' % regfile.getCANRESTORE())
    sys.stdout.write('  %#018x' % regfile.getCLEANWIN())
    sys.stdout.write('  %#018x' % regfile.getOTHERWIN())
    sys.stdout.write('\n')
    sys.stdout.write('\t%ver \t\t%wstate \t\t%y \t\t$globals\n')
    sys.stdout.write('  %#018x' % archState.getHverRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getWstateRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getYRegPtr().getNative())
    sys.stdout.write('  %#018x' % 0xdeadbeefL) #TODO
    sys.stdout.write('\n')
    sys.stdout.write('\t%tick_cmpr \t%softint \t\t%gsr \t\t%thread_status\n')
    sys.stdout.write('  %#018x' % archState.getTickCmprRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getSoftIntRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getGsrRegPtr().getNative())
    sys.stdout.write('  %#018x' % 0xdeadbeefL) #TODO
    sys.stdout.write('\n')
    sys.stdout.write('\t%intr_recv_status \t%gl \t\t%hpstate \t%htba\n')
    sys.stdout.write('  %#018x' % 0xdeadbeefL) #TODO
    sys.stdout.write('  %#018x' % archState.getGlobalLevelRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getHpstateRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getHtbaRegPtr().getNative())
    sys.stdout.write('\n')
    sys.stdout.write('\t%hintp \t\t%hstick_cmpr\n')
    sys.stdout.write('  %#018x' % archState.getHintpRegPtr().getNative())
    sys.stdout.write('  %#018x' % archState.getHstickCompareRegPtr().getNative())
    sys.stdout.write('\n\n')
    sys.stdout.write('\t%tpc \t\t%tnpc \t\t\t%tstate \t%tt\n')
    tpcPtr = archState.getTpcRegPtr()
    tnpcPtr = archState.getTnpcRegPtr()
    tstatePtr = archState.getTstateRegPtr()
    ttPtr = archState.getTrapTypeRegPtr()
    maxTl = tpcPtr.getMaxTl()
    for i in range(maxTl):
	ii = i + 1
	sys.stdout.write('%d %#018x' % (ii, tpcPtr.getTpc(ii)))
	sys.stdout.write('  %#018x' % tnpcPtr.getTnpc(ii))
	sys.stdout.write('  %#018x' % tstatePtr.getTstateEntry(ii).getNative())
	sys.stdout.write('  %#018x' % ttPtr.getTrapType(ii))
	sys.stdout.write('\n')
    sys.stdout.write('\t%htstate\n')
    htstatePrt = archState.getHtstateRegPtr()
    maxTl = htstatePrt.getMaxTl()
    for i in range(maxTl):
	ii = i + 1
	sys.stdout.write('%d %#018x' % (ii, htstatePrt.getHtstateEntry(ii).getNative()))
	sys.stdout.write('\n')

    # always output floating point registers
    sys.stdout.write('\n')
    RS_print_fpregs(tid)


def RS_print_regs (tid=0, a_str=''):
    """
    """
    RS_print_archregs(tid, a_str)


def RS_print_fpregs (tid=0):
    """
    """
    print _myReposit.strands[tid].getArchStatePtr().getFloatRegisterFilePtr().toString()

    
def RS_print_mmuregs (tid=0):
    """
    """
    mmu = _myReposit.strands[tid].getMmuPtr()
    sys.stdout.write('Context registers:\n')
    for i in range(mmu.getContextSize()):
	sys.stdout.write('Primary_%d: \t%#018x\t' % (i, mmu.getPrimaryContextPtr(i).getNative()))
	sys.stdout.write('Secondary_%d: \t%#018x\n' % (i, mmu.getSecondaryContextPtr(i).getNative()))

    sys.stdout.write('I-TSB tag target register: \t\t%#018x\n' % mmu.getItagTargetPtr().getNative())
    sys.stdout.write('D-TSB tag target register: \t\t%#018x\n' % mmu.getDtagTargetPtr().getNative())
    sys.stdout.write('I-TLB sync fault status register: \t%#018x\n' % mmu.getIsfsrPtr().getNative())
    sys.stdout.write('D-TLB sync fault status register: \t%#018x\n' % mmu.getDsfsrPtr().getNative())
    sys.stdout.write('D-TLB sync fault address register: \t%#018x\n' % mmu.getDsfarPtr().getNative())
    sys.stdout.write('I-TLB tag access register: \t\t%#018x\n' % mmu.getItagAccessPtr().getNative())
    sys.stdout.write('D-TLB tag access register: \t\t%#018x\n' % mmu.getDtagAccessPtr().getNative())
    sys.stdout.write('PID register: \t\t\t\t%#018x\n' % mmu.getPartitionIdPtr().getNative())
    sys.stdout.write('Real Range 0-3:\n')
    for i in range(mmu.getTsbConfigSize()):
	sys.stdout.write('%#018x ' % mmu.getRealRangePtr(i).getNative())
    sys.stdout.write('\n')

    sys.stdout.write('Physical Offset 0-3:\n')
    for i in range(mmu.getTsbConfigSize()):
	sys.stdout.write('%#018x ' % mmu.getPhysOffsetPtr(i).getNative())
    sys.stdout.write('\n')
    sys.stdout.write('Ctx Zero TSB Cfg 0-3:\n')
    for i in range(mmu.getTsbConfigSize()):
	sys.stdout.write('%#018x ' % mmu.getZeroContextTsbConfigPtr(i).getNative())
    sys.stdout.write('\n')
    sys.stdout.write('Ctx Non-Zero TSB Cfg 0-3:\n')
    for i in range(mmu.getTsbConfigSize()):
	sys.stdout.write('%#018x ' % mmu.getNonzeroContextTsbConfigPtr(i).getNative())
    sys.stdout.write('\n')
    sys.stdout.write('ITSB Ptr 0-3:\n')
    for i in range(mmu.getTsbConfigSize()):
	sys.stdout.write('%#018x ' % mmu.getItsbPointerPtr(i).getNative())
    sys.stdout.write('\n')
    sys.stdout.write('DTSB Ptr 0-3:\n')
    for i in range(mmu.getTsbConfigSize()):
	sys.stdout.write('%#018x ' % mmu.getDtsbPointerPtr(i).getNative())
    sys.stdout.write('\n')
    sys.stdout.write('I-TLB data in register: \t%#018x\n' % mmu.getItlbDataInPtr().getNative())
    sys.stdout.write('D-TLB data in register: \t%#018x\n' % mmu.getDtlbDataInPtr().getNative())
    sys.stdout.write('I-TLB data access register: \t%#018x\n' % mmu.getItlbDataAccessPtr().getNative())
    sys.stdout.write('D-TLB data access register: \t%#018x\n' % mmu.getDtlbDataAccessPtr().getNative())

    sys.stdout.write('VA/PA watchpoint address: \t%#018x\n' % _myReposit.strands[tid].getWatchpointPtr().getNative())
    sys.stdout.write('LSU control register: \t\t%#018x\n' % _myReposit.strands[tid].getLsuControlPtr().getNative())

   
def RS_print_cmpregs (tid=0):
    """
    """
    cpuLevelCmp = _myReposit.cpus[(tid/_myCpusize)].getCpuLevelCmpRegsPtr()
    archState = _myReposit.strands[tid].getArchStatePtr()
##     print cpuLevelCmp.toString()
##     print archState.getCmpCoreIdRegPtr().toString()
##     print archState.getCmpCoreIntrIdRegPtr().toString()
##     for i in range(8):
## 	print archState.getScratchPadPtr(i).toString()

    print 'core_available: \t%#018x' % cpuLevelCmp.getCoreAvailableRegPtr().getNative()
    print 'core_enable: \t\t%#018x' % cpuLevelCmp.getCoreEnableRegPtr().getNative()
    print 'core_enable_status: \t%#018x' % cpuLevelCmp.getCoreEnabledRegPtr().getNative()
    print 'core_running: \t\t%#018x' % cpuLevelCmp.getCoreRunningRegPtr().getNative()
    print 'core_running_status: \t%#018x' % cpuLevelCmp.getCoreRunningStatusRegPtr().getNative()
    print 'error_steering: \t%#018x' % cpuLevelCmp.getErrorSteeringRegPtr().getNative()
    print 'xir_steering: \t\t%#018x' % cpuLevelCmp.getXirSteeringRegPtr().getNative()
    print 'cmp_core_id: \t\t%#018x' % archState.getCmpCoreIdRegPtr().getNative()
    print 'cmp_core_intr_id: \t%#018x' % archState.getCmpCoreIntrIdRegPtr().getNative()
    for i in range(8):
	print 'scratchpad_%d" \t\t%#018x' % (i, archState.getScratchPadPtr(i).getNative())


def RS_get_register_number (tid, regname):
    """rd_n = RS_get_register_number(th_obj, dest_reg)
    """
    return _myRegmap.key2id(regname)


def RS_write_register (tid, regid, value):
    """RS_write_register(th_obj, rd_n, new_dest_val)
    """
    reg = _myRegmap.id2key(regid)
    newCmd = '%s %s %s' % ('write-reg', reg, value)
    (level,wrs) = _myRegmap.mapWriteRS(reg, newCmd)
    toprs = _mapRS(tid, level)
    if wrs.endswith(')'):
	# all parameters are set, no more action
	newCmd = '%s.%s' % (toprs, wrs)
    else:
	newCmd = '%s.%s(%sL)' % (toprs, wrs, value)

    _evalCmd(newCmd)


def RS_write_register_name (regname, value, tid=0):
    """
    """
    #reg = _myRegmap.id2key(regid)
    #newCmd = '%s %s %s' % ('write-reg', reg, value)
    #(level,wrs) = _myRegmap.mapWriteRS(reg, newCmd)
    cpuname = 'th'+str(tid)
    newCmd = '%s %s %s %s' % ('write-reg', cpuname, regname, value)
    (level,wrs) = _myRegmap.mapWriteRS(regname, newCmd)
    toprs = _mapRS(tid, level)
    if wrs.endswith(')'):
	# all parameters are set, no more action
	newCmd = '%s.%s' % (toprs, wrs)
    else:
	newCmd = '%s.%s(%sL)' % (toprs, wrs, value)

    _evalCmd(newCmd)


def RS_read_register (tid, regid):
    """prev_tl = RS_read_register(th_obj, RS_get_register_number(th_obj, "tl"))
    """
    reg = _myRegmap.id2key(regid)
    newCmd = '%s %s' % ('read-reg', reg)
    (level,rrs) = _myRegmap.mapReadRS(reg, newCmd)
    toprs = _mapRS(tid, level)
    newCmd = '%s.%s' % (toprs, rrs)
    return _evalCmd(newCmd)


def RS_read_register_name (regname, tid=0):
    """
    """
    (level,rrs) = _myRegmap.mapReadRS(regname, '%'+regname)
    toprs = _mapRS(tid, level)
    newCmd = '(%s.%s)' % (toprs, rrs)
    return _evalCmd(newCmd)


## def RS_reset (traptype):
##     """
##     """
##     nasUtil.reset_cmd(traptype)


def RS_asi_read (asi, va, tid=0):
    """read asi by asi/va
    """
    return _myReposit.strands[tid].RS_asiRead(asi, long(va))


def RS_asi_write (asi, va, value, tid=0):
    """write asi by asi/va/value
    """
    _myReposit.strands[tid].RS_asiWrite(asi, long(va), long(value))


def RS_dump_tlb (tid=0, itlb=1, valid=1):
    """dump i/d-talb content
    """
    return _myReposit.strands[tid].RS_dumpTlb(itlb, valid)
