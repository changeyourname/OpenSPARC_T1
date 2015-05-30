"""provide user commands' equivalent of function calls.
"""

import re, sys

from ni import RegisterMap

import Pfe_Tlb
import Pfe_Assembler

NAME_CPU    = 'cpu'
NAME_CORE   = 'core'
NAME_UCORE   = 'ucore'
NAME_STRAND = 'strand'

TRAP_LEVEL = 6

# before any function in this file is used, the following global variables 
# must be assigned a valid object.
_myReposit = None   # RiesReposit object
_myRegmap = None
_asiRegMap = {}
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
    global _asiRegMap
    global _myRegmap

##     global nasUtil

    _myReposit = reposit
    _myRegmap = RegisterMap.RegisterMap(reposit.optdir['--ar'])
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

    asiRegMap = _myRegmap.asiRegMap
    for reg in asiRegMap:
	regName = reg
	asi = asiRegMap[reg][0]
	va = asiRegMap[reg][1]
        # 3/2/06: commented this out as asi_alias is per strand
        # and should be called for each strand. This here is wrong
        # and we're having trouble gettiung the Sam Front end to work.
	#_myReposit.riesling.asi_alias(regName,asi,va)

    _asiRegMap = asiRegMap
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
    API_DOCS['RS_dump_memory'] = ("RS_dump_memory(fileName,startPA,size,binary=0)", 'API', 'dump memory content', 'TODO')


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



def _evalCmd (cmd):
    """
    """
    #print '#DBX: cmd=', cmd
    #sys.stdout.write(cmd +"\n")
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
    # get the pc before stepping
    pc = _myReposit.riesling.s[tid].pc
    # step one instr
    _myReposit.riesling.s[tid].step()
    # increase instr count
    incrIcount_RSI(tid)

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

    if not _myRegmap.hasReg(regname) or _myRegmap.feName2beName(regname) == '':
	sys.stdout.write("Unimplemented register %s access\n" % (regname,))
	return

    newCmd = '%s.s[%d].%s' % (_myReposit.topName,tid,regname)
    return _evalCmd(newCmd)

###############################################################################

def RS_set_quiet(num):
    """1 --- enable quiet mode, 0 disable it.
    """
    global _myVerbose

    if num == 1:
 	_myVerbose = 0
    else:
 	_myVerbose = 1

    #nasUtil.stepQuiet_cmd(num);
    #print 'command not supported for N1'


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
    if type == 1:
	return _myReposit.riesling.s[tid].inst_va2pa(vaddr)
    else:
	return _myReposit.riesling.s[tid].data_va2pa(vaddr)


def RS_write_phys_memory (tid, addr, value, size):
    """RS_write_phys_memory(th_obj, 0x9a00000000, orig_tid, 4):
    """
    #sys.stderr.write('DBX: RS_write_phys_memory: tid=%d, addr=%#x, value=%#x, size=%d\n' % (tid, addr, value, size))

    if not size in [1,2,4,8]:
	sys.stderr.write('ERROR: write_phys_memory: wrong size %d, must be 1,2,4,8-byte\n' % (size))
    elif _myReposit.optdir.has_key('--blaze'):
        _myReposit.riesling.s[tid].access_system_mem(long(addr), long(value), 0, size)
    else:
	if size == 1:
	    _myReposit.riesling.mem.b[addr] = value
	elif size == 2:
	    _myReposit.riesling.mem.h[addr] = value
	elif size == 4:
	    _myReposit.riesling.mem.w[addr] = value
	else:
	    _myReposit.riesling.mem.x[addr] = value

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
			 
    if 	_myReposit.optdir.has_key('--blaze'):
        # read the blaze memory
        data = _myReposit.riesling.s[tid].access_system_mem(long(addr), 0L, 1, size)        
        if (data < 0):
            data = 0xffffffffffffffffL + data + 1
        return data

    if size == 1:
	data = _myReposit.riesling.mem.__ldb__(addr)
    elif size == 2:
	data = _myReposit.riesling.mem.__ldh__(addr)
    elif size == 4:
	data = _myReposit.riesling.mem.__ldw__(addr)
    else:
	data = _myReposit.riesling.mem.__ldx__(addr)	

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
    
    #iword = _myReposit.riesling.mem.w[addr]
    iword = RS_read_phys_memory(tid,paddr,4)

    # disassemble the instr
    iwStr = '[%08x] %s' % (iword, _myReposit.riesling.dis(iword))

    return (4, iwStr)


def RS_disassemblePC (tid):
    """(_, dis_str ) = RS_disassemblePC(th_obj)
    """
    # disassemble the just executed instr
    #return (4, nasUtil.disassemblePC_cmd(tid))
    
    pc = _myReposit.riesling.s[tid].pc
    #iword = _myReposit.riesling.mem.w[pc]
    iword = RS_read_phys_memory(tid,RS_logical_to_physical(tid,1,pc),4)

    # some arch's iword does not always have valid ppc
    iwStr = 'vpc=%#010x, [%08x] %s' % (pc, iword, _myReposit.riesling.dis(iword))
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
    newCmd = '%s.s[%d].d%d' % (_myReposit.topName,tid,regid)
    return _evalCmd(newCmd)


def RS_read_fp_register_i (tid, regid):
    """dest_val = RS_read_fp_register_i(th_obj, rd_n)
    """
    newCmd = '%s.s[%d].f%d' % (_myReposit.topName,tid,regid)
    _evalCmd(newCmd)
    return _evalCmd(newCmd)


def RS_write_fp_register_x (tid, regid, value):
    """
    """
    newCmd = '%s.s[%d].d%d = %d' % (_myReposit.topName,tid,regid,value)
    code = compile(newCmd,'sys.stderr','single')
    exec code in _myReposit.globals

def RS_write_fp_register_i (tid, regid, value):
    """
    """
    newCmd = '%s.s[%d].f%d = %d' % (_myReposit.topName,tid,regid,value)
    code = compile(newCmd,'sys.stderr','single')
    exec code in _myReposit.globals


def RS_print_archregs (tid=0, a_str=''):
    """
    """
    sys.stdout.write('Strand %d:\n' % tid)

	# show the current window, gl register and other ASRs
    i = 0
    regs = _myRegmap.regMap.keys()
    regs.sort()
    for reg in regs:
	if i % 4 == 0:
	    sys.stdout.write("\n")
	if _myRegmap.regMap[reg][0] == '':
	    sys.stdout.write('%-10s%#18s' % (reg,'UNIMP'))
	else:
	    sys.stdout.write('%-10s%#018x  ' % (reg,_evalCmd('%s.s[%d].%s' % (_myReposit.topName,tid,_myRegmap.regMap[reg][0]))))
	i = i + 1

	# XXX add support for arch specific regs
		
    sys.stdout.write('\n')
    if a_str != '-all':
       return

	# show the regs for all the other windows
	# show all the global regs

    max_gl = _myReposit.riesling.s0.max_gl
    for gl in range(0,max_gl+1):
	if gl == _myReposit.riesling.s[tid].gl:
	    continue
	sys.stdout.write('\nglobal set %d' % (gl,))
	for reg in range(0,8):
	    if reg % 4 == 0:
	        sys.stdout.write("\n")
	    key = 'g%d' % (reg,)
	    sys.stdout.write('%-6s%#018x  '	% (key,_evalCmd('%s.s[%d].g[%d].%s' % (_myReposit.topName,tid,gl,_myRegmap.regMap[key][0]))))

    sys.stdout.write('\n')
	
	# show all the window regs
    max_win = _myReposit.riesling.s0.max_wp
    for win in range(0,max_win):
	if win == _myReposit.riesling.s[tid].cwp:
	    continue
	sys.stdout.write('\nwindow %d' % (win,))
        for o_reg in range(0,8):
	    if o_reg % 4 == 0:
	        sys.stdout.write("\n")
	    key = 'o%d' % (o_reg,)
	    sys.stdout.write('%-6s%#018x  '	% (key,_evalCmd('%s.s[%d].w[%d].%s' % (_myReposit.topName,tid,gl,_myRegmap.regMap[key][0])))) 
	for l_reg in range(0,8):
	    if l_reg % 4 == 0:
	        sys.stdout.write("\n")
	    key = 'l%d' % (l_reg,)
	    sys.stdout.write('%-6s%#018x  '	% (key,_evalCmd('%s.s[%d].w[%d].%s' % (_myReposit.topName,tid,gl,_myRegmap.regMap[key][0]))))
	for i_reg in range(0,8):
	    if i_reg % 4 == 0:
	        sys.stdout.write("\n")
	    key = 'i%d' % (i_reg,)
	    sys.stdout.write('%-6s%#018x  '	% (key,_evalCmd('%s.s[%d].w[%d].%s' % (_myReposit.topName,tid,gl,_myRegmap.regMap[key][0]))))
			
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
    for i in range(0,64):
	value = 'f%-6d%#010x  ' % (i,_evalCmd('%s.s[%d].f%d' % (_myReposit.topName,tid,i)))
	if i % 4 == 0:
	    sys.stdout.write('\n')
	sys.stdout.write(value)
    sys.stdout.write('\n')
    

def RS_print_mmuregs (tid=0):
    """
    """
    global _asiRegMap

    str = ''
    for reg in _asiRegMap.keys():
	if reg.startswith('MMU_'):
	    newCmd = '%s.s0.%s' % (_myReposit.topName,reg)
	    val = _evalCmd(newCmd)
	    str = str + '%-40s   %#018x' % (reg,val) + '\n'

    return str
   
def RS_print_cmpregs (tid=0):
    """
    """
    global _asiRegMap
    str = ''
    for reg in _asiRegMap.keys():
	if reg.startswith('CMP_'):
	    newCmd = '%s.s%d.%s' % (_myReposit.topName,tid,reg)
	    val = _evalCmd(newCmd)
	    str = str + '%-40s   %#018x' % (reg,val) + '\n'

    return str


def RS_get_register_number (tid, regname):
    """rd_n = RS_get_register_number(th_obj, dest_reg)
    """
    return _myRegmap.key2id(regname)


def RS_write_register (tid, regid, value):
    """RS_write_register(th_obj, rd_n, new_dest_val)
    """
    reg = _myRegmap.id2key(regid)
    if reg == '':
	sys.stdout.write("Unimplemented register id %d\n" % (regid,))
	return
    newCmd = '%s.s[%d].%s = %d' % (_myReposit.topName,tid,reg,value)
    code = compile(newCmd,'sys.stderr','single')
    exec code in _myReposit.globals	 

def RS_write_register_name (regname, value, tid=0):
    """
    """
    if not _myRegmap.hasReg(regname) or _myRegmap.feName2beName(regname) == '':
	sys.stdout.write("Unimplemented register %s access\n" % (regname,))
	return

    newCmd = '%s.s[%d].%s=%d' % (_myReposit.topName,tid,regname,value)
    code = compile(newCmd,'sys.stderr','single')
    exec code in _myReposit.globals	


def RS_read_register (tid, regid):
    """prev_tl = RS_read_register(th_obj, RS_get_register_number(th_obj, "tl"))
    """
    reg = _myRegmap.id2key(regid)
    if reg == '':
	sys.stdout.write("Unimplemented register id %d\n" % (regid,))
	return
    newCmd = '%s.s[%d].%s' % (_myReposit.topName,tid,reg)
    return _evalCmd(newCmd)


def RS_read_register_name (regname, tid=0):
    """
    """
    if not _myRegmap.hasReg(regname) or _myRegmap.feName2beName(regname) == '':
	sys.stdout.write("Unimplemented register %s access\n" % (regname,))
	return

    newCmd = '%s.s[%d].%s' % (_myReposit.topName,tid,regname)
    return _evalCmd(newCmd)


## def RS_reset (traptype):
##     """
##     """
##     nasUtil.reset_cmd(traptype)

def RS_asi_read (asi, va, tid=0):
    """read asi by asi/va
    """
    return _myReposit.riesling.s[tid].rdasi(asi, long(va))

def RS_asi_write (asi, va, value, tid=0):
    """write asi by asi/va/value
    """
    _myReposit.riesling.s[tid].wrasi(asi, long(va), long(value))


def RS_dump_tlb (tid=0, itlb=1, valid=1):
    """dump i/d-talb content
    """
    if itlb == 1:
       tlb = _myReposit.riesling.s[tid].inst_tlb
    else:
       tlb = _myReposit.riesling.s[tid].data_tlb

    prnt_f = __print_N1_Tte__

    str = ''

    if valid == 1:
	# display only valid entries
	i = 0
	while 1:
	    i = tlb.next_valid_index(i)
	    if i == -1:
		break
	    str = str + prnt_f(tlb[i])
	    i = i + 1
    else:
	i = 0
	while i < tlb.size():
	    str = str + prnt_f(tlb[i])
	    i = i + 1

    return str


def RS_dump_memory (fileName, startPA, size, binary=0):
    """dump memory content to file, in plain text or binary form
    if fileName='', then output to stdout
    """
    if fileName == '':
        fr = sys.stdout
    else:
        fr = open(fileName,'w')
    addr = startPA
    c16 = 0
    while addr < startPA + size:
        data = RS_read_phys_memory(0,addr,1)
	if binary == 1:
	    fr.write(chr(int(data)))
	else:
	    if c16 == 0 :
		fr.write("0x%016x  " % (addr,))
	    fr.write('%02x' % (data,))
            c16 = c16 + 1
 	    if c16 % 2 == 0:
		fr.write(' ')
            if c16 % 16 == 0:
                fr.write('\n')
                c16 = 0
	addr = addr + 1

    
def __print_N1_Tte__(tte):
	str = ("%-6s%#01x   " % ('r',tte.r)) + ("%-6s%#018x   " % ('pid',tte.pid)) +  ("%-6s%#018x   " % ('ctx',tte.ctx)) + "\n" + ("%-6s%#018x   " % ('tag',tte.tag)) + ("%-6s%#018x   " % ('addr',tte.addr)) + ("%-6s%#04x   " % ('size',tte.size)) + "\n" +  ("%-6s%#01x|" % ('valid',tte.valid)) + ("%-6s%#01x|" % ('nfo',tte.nfo)) +  ("%-6s%#01x|" % ('ie',tte.ie)) + ("%-6s%#01x|" % ('e',tte.e)) +  ("%-6s%#01x|" % ('cp',tte.cp)) + ("%-6s%#01x|" % ('cv',tte.cv)) + ("%-6s%#01x|" % ('p',tte.p)) + ("%-6s%#01x|" % ('w',tte.w)) +  ("%-6s%#01x|" % ('lock',tte.lock))+ ("%-6s%#01x|" % ('diag7_3',tte.diag7_3))+"\n"

	return str


def RS_tlblookup (tid, va, pid=-1, ctxt=-1, ra2pa=-1, bypass=-1):
    """
    """
    return _myReposit.strands[tid].tlblookup(va, pid, ctxt, ra2pa, bypass)


def RS_read_memory (tid, addr, size=8, pid=-1, ctxt=-1, ra2pa=-1, bypass=1):
    """
    """
    #sys.stderr.write('DBX: RS_read_memory: tid=%d, addr=%#x, size=%d\n' % (tid, addr, size))
    # the data is returned as L, if the highest bit (bit63) is 1, python
    # will present it as negative long, so have to convert it back because
    # we want uint64. ---> change type to K does not help, still return
    # negative.
    if not size in [1,2,4,8]:
	sys.stderr.write('ERROR: RS_read_memory: wrong size %d, must be 1,2,4,8-byte\n' % (size))
	return None

    if long(addr) % size:
	sys.stderr.write('ERROR: RS_read_memory: addr %#x is not %d-byte aligned\n' % (addr, size))
	return None
			 
    if bypass <= 0:
	# the address is a VA, have to translate it
	addr = RS_tlblookup(tid, addr, pid, ctxt, ra2pa, bypass)

    #data = nasUtil.access_cmd(addr, 0, tid, 1, size)
    data = _myReposit.strands[tid].access_system_mem(long(addr), 0L, 1, size)
    if (data < 0):
	data = 0xffffffffffffffffL + data + 1
    return data


