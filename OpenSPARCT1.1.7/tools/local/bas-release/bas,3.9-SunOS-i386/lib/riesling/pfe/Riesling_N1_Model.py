import Pfe_Model
import Pfe_Tlb

from Pfe_Tlb        import Tte
from Pfe_Conversion import *
from Pfe_Assembler  import asm

import Riesling_Strand 
import Riesling_Memory
import Riesling_Breakpoint

"""
sun4u format tte field
Offset  Size  Name   Description
------------------------------------------------------------------------------------------------
  0       1   RSVD1     reserved
  1       1   W         Writable
  2       1   P         Priviliegd
  3       1   E         Side-effect
  4       1   CV        Cached in virtually indexed cache
  5       1   CP        cached in phyiscally indexed cache
  6       1   L         locked
  7       1   RSVD0     was EP (Execute Permission)
  8       5   SOFT      soft
 13      27   PA        PA[39:13]
 40       3   DIAG2_0   reserved
 43       5   DIAG7_3   Diag[7]=Used bit, Diag[6]=TTE data parity, Diag[5:3]: Mux selects based
		        on page size
 48       1   SZH       Size[2]
 49      10   SOFT2     soft
 59       1   IE        Invert Endianess
 60       1   NFO       No-fault only
 61       2   SZL       Size[1:0]
 63       1   V         Valid
"""

def __tte_getvalid__(tte):  return bool(tte.data4u().getV())
def __tte_getnfo__(tte):    return bool(tte.data4u().getNFO())
def __tte_getpa__(tte):     return tte.data4u().getPA()
def __tte_getl__(tte):      return tte.data4u().getL()
def __tte_getdiag7_3__(tte):return tte.data4u().getDIAG7_3()
def __tte_getie__(tte):     return bool(tte.data4u().getIE())
def __tte_gete__(tte):      return bool(tte.data4u().getE())
def __tte_getcp__(tte):     return bool(tte.data4u().getCP())
def __tte_getcv__(tte):     return bool(tte.data4u().getCV())
def __tte_getp__(tte):      return bool(tte.data4u().getP())
def __tte_getw__(tte):      return bool(tte.data4u().getW()) 
def __tte_getszh__(tte):    return tte.data4u().getSZH()
def __tte_getszl__(tte):    return tte.data4u().getSZL()
def __tte_getctxt__(tte):   return tte.context()
def __tte_getpid__(tte):    return tte.pid()
def __tte_getvaddr__(tte):  return tte.vaddr()
def __tte_getr__(tte):      return tte.r()

def __tte_setvalid__(tte,val):  tte.data4u().setV(long(val))
def __tte_setnfo__(tte,val):    tte.data4u().setNFO(long(val))
def __tte_setpa__(tte,val):     tte.data4u().setPA(long(val))
def __tte_setl__(tte,val):      tte.data4u().setL(long(val))
def __tte_setdiag7_3__(tte,val):tte.data4u().setDIAG7_3(long(val))
def __tte_setie__(tte,val):     tte.data4u().setIE(long(val))
def __tte_sete__(tte,val):      tte.data4u().setE(long(val))
def __tte_setcp__(tte,val):     tte.data4u().setCP(long(val))
def __tte_setcv__(tte,val):     tte.data4u().setCV(long(val))
def __tte_setp__(tte,val):      tte.data4u().setP(long(val))
def __tte_setw__(tte,val):      tte.data4u().setW(long(val)) 
def __tte_setszh__(tte,val):    tte.data4u().setSZH(long(val))
def __tte_setszl__(tte,val):    tte.data4u().setSZL(long(val))
def __tte_setctxt__(tte,val):   tte.context(long(val))
def __tte_setpid__(tte,val):    tte.pid(long(val))
def __tte_setvaddr__(tte,val):  tte.vaddr(long(val))
def __tte_setr__(tte,val):      tte.r(long(val))

def __get_last_instr__(strand): return strand.getLastInstrPtr()

def __tte_getsize__(tte):
  szl = __tte_getszl__(tte)
  szh =  __tte_getszh__(tte)
  return (szl & 0x3) | (szh <<2)

def __tte_setsize__(tte,val):
  szl = val & 0x3
  __tte_setszl__(tte,szl)
  szh = val >> 2
  __tte_setszh__(tte,szh)

# for unused fields in the TTE

def __tte_getfalse__(tte): return False
def __tte_setpass__(tte,val): pass

class __tte_xlate__:
  def __init__(self,tte):
    self.tte = tte
  def __call__(self,addr):
    return self.tte.translate(long(addr))

class __tte_match__:
  def __init__(self,tte):
    self.tte = tte
  def __call__(self,addr,ctx=0,pid=0,real=False):
    return self.tte.tagMatch(long(addr),ctx,pid,real)


Pfe_Tlb.TlbTte.__getfun__['xlate'] = __tte_xlate__
Pfe_Tlb.TlbTte.__getfun__['match'] = __tte_match__

Pfe_Tlb.TlbTte.__getfun__['valid'] = __tte_getvalid__
Pfe_Tlb.TlbTte.__setfun__['valid'] = __tte_setvalid__
Pfe_Tlb.TlbTte.__getfun__['r']     = __tte_getr__
Pfe_Tlb.TlbTte.__setfun__['r']     = __tte_setr__
Pfe_Tlb.TlbTte.__getfun__['pid']   = __tte_getpid__
Pfe_Tlb.TlbTte.__setfun__['pid']   = __tte_setpid__
Pfe_Tlb.TlbTte.__getfun__['ctx']   = __tte_getctxt__
Pfe_Tlb.TlbTte.__setfun__['ctx']   = __tte_setctxt__
Pfe_Tlb.TlbTte.__setfun__['size'] = __tte_setsize__
Pfe_Tlb.TlbTte.__getfun__['size'] = __tte_getsize__
Pfe_Tlb.TlbTte.__getfun__['tag']   = __tte_getvaddr__
Pfe_Tlb.TlbTte.__setfun__['tag']   = __tte_setvaddr__
Pfe_Tlb.TlbTte.__getfun__['ie']    = __tte_getie__
Pfe_Tlb.TlbTte.__setfun__['ie']    = __tte_setie__
Pfe_Tlb.TlbTte.__getfun__['nfo']   = __tte_getnfo__
Pfe_Tlb.TlbTte.__setfun__['nfo']   = __tte_setnfo__
Pfe_Tlb.TlbTte.__getfun__['e']     = __tte_gete__
Pfe_Tlb.TlbTte.__setfun__['e']     = __tte_sete__
Pfe_Tlb.TlbTte.__getfun__['p']     = __tte_getp__
Pfe_Tlb.TlbTte.__setfun__['p']     = __tte_setp__
Pfe_Tlb.TlbTte.__getfun__['w']     = __tte_getw__
Pfe_Tlb.TlbTte.__setfun__['w']     = __tte_setw__
Pfe_Tlb.TlbTte.__getfun__['addr']  = __tte_getpa__
Pfe_Tlb.TlbTte.__setfun__['addr']  = __tte_setpa__
Pfe_Tlb.TlbTte.__setfun__['cp']    = __tte_setcp__
Pfe_Tlb.TlbTte.__getfun__['cp']    = __tte_getcp__
Pfe_Tlb.TlbTte.__setfun__['cv']    = __tte_setcv__
Pfe_Tlb.TlbTte.__getfun__['cv']    = __tte_getcv__
Pfe_Tlb.TlbTte.__getfun__['lock']    = __tte_getl__
Pfe_Tlb.TlbTte.__setfun__['lock']    = __tte_setl__
Pfe_Tlb.TlbTte.__getfun__['diag7_3']    = __tte_getdiag7_3__
Pfe_Tlb.TlbTte.__setfun__['diag7_3']    = __tte_setdiag7_3__


class N1_Tlb(Pfe_Tlb.Tlb):
  def __init__(self,tlb,riesling):
    Pfe_Tlb.Tlb.__init__(self,tlb)
    self.__riesling__ = riesling

  def size(self):
    return self.__tlb__.getNLines()

  def index(self,index):
    if index < 0 or index >= self.size():
      return IndexError
    else:
      return self.__tlb__.at(index)

  def insert(self,tte):
    if isinstance(tte, Tte):
      n1_tte = self.__riesling__.Ni_Tte()
      __tte_setvalid__(n1_tte,tte.valid)
      __tte_setr__(n1_tte, tte.real)
      __tte_setpid__(n1_tte, tte.pid)
      __tte_setctxt__(n1_tte,tte.ctx)
      __tte_setszl__(n1_tte,tte.szl)
      __tte_setszh__(n1_tte,tte.szh)
      __tte_setvaddr__(n1_tte,tte.tag)
      __tte_setie__(n1_tte,tte.ie)
      __tte_setnfo__(n1_tte,tte.nfo)
      __tte_sete__(n1_tte,tte.e)
      __tte_setp__(n1_tte,tte.p)
      __tte_setw__(n1_tte,tte.w)
      __tte_setl__(n1_tte,tte.l)
      __tte_setdiag7_3__(n1_tte,tte.diag7_3)
      __tte_setpa__(n1_tte,tte.addr)
      __tte_setcp__(n1_tte,tte.cp)
      __tte_setcv__(n1_tte,tte.cv)
      self.__tlb__.insert(n1_tte)
    else:
      raise TypeError

  def next_valid_index(self,i):
    return self.__tlb__.next_valid_index(i)


class Core(Pfe_Model.Core):
  def __init__(self,core,ref,riesling):
    Pfe_Model.Core.__init__(self)
    self.__riesling__ = riesling
    self.inst_tlb = N1_Tlb(core.getiTlbPtr(),riesling)
    self.data_tlb = N1_Tlb(core.getdTlbPtr(),riesling)
    for i in range(0,core.getNStrands()):
      strand_ref = 's'+str(i)
      strand_ptr = core.getStrandPtr(i)
      strand = Riesling_Strand.Strand(strand_ptr,ref+'.'+strand_ref)
      strand.__dict__['__last_instr__'] = __get_last_instr__	
      self.__dict__[strand_ref] = strand
      self.s.append(strand)
      strand.inst_tlb = self.inst_tlb
      strand.data_tlb = self.data_tlb      

class Cpu(Pfe_Model.Cpu):
  def __init__(self,cpu,ref,riesling):
    Pfe_Model.Cpu.__init__(self)
    self.__riesling__ = riesling
    for i in range(0,cpu.getNCores()):
      core_ref = 'c'+str(i)
      core_ptr = cpu.getCorePtr(i)
      core = Core(core_ptr,ref+'.'+core_ref, riesling)
      self.__dict__[core_ref] = core
      self.c.append(core)  


class Model(Pfe_Model.Model):

  def __create_cpu__(self,count,cpu_list=[]):
    """
    """
    if count == 1:
      for i in range(0,count):
      	cpu_ref = 'p'+str(i)
        if i < len(cpu_list):
          cpu_ptr = cpu_list[i]
        else:
      	  cpu_ptr = self.__system__.getCpuPtr(i)
      	cpu = Cpu(cpu_ptr,cpu_ref,self.__riesling__)
      	self.p.append(cpu)
      	self.__dict__[cpu_ref] = cpu
      self.__populate__()
      return True
    else:
      return False



  def __init__(self,riesling,system,mem=None):
    Pfe_Model.Model.__init__(self)
    self.__system__ = system
    self.__riesling__ = riesling
    if mem:
      self.mem = mem
    else:
      self.mem = Riesling_Memory.Memory(system,system.getRam())
    self.bp_table = Riesling_Breakpoint.breakPoint(system)

  
  def dis(self,iw):
    n1_iword = self.s[0].__get_iw_ptr__(iw)
    return n1_iword.toString()



