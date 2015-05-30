
import Pfe_Strand
from Pfe_Strand import TrapStack
from Pfe_Strand import GlobalStack

class NameExistsErr(Exception):
  def __init__(self,name):
    Exception.__init__(self)
    self.name = name
  def __str__(self):
    return "Strand attribute" + self.name + "already exists"

def __getpc__(strand): return strand.getArchStatePtr().getPc()
def __setpc__(strand,value): strand.getArchStatePtr().setPc(long(value))
def __getnpc__(strand): return strand.getArchStatePtr().getNpc()
def __setnpc__(strand,value): strand.getArchStatePtr().setNpc(long(value))
def __getcwp__(strand): return strand.getArchStatePtr().getRegisterFilePtr().getCWP()
def __setcwp__(strand,value): strand.getArchStatePtr().getRegisterFilePtr().setCWP(long(value))
def __getcansave__(strand): return strand.getArchStatePtr().getRegisterFilePtr().getCANSAVE()
def __setcansave__(strand,value): strand.getArchStatePtr().getRegisterFilePtr().setCANSAVE(long(value))
def __getcanrestore__(strand): return strand.getArchStatePtr().getRegisterFilePtr().getCANRESTORE()
def __setcanrestore__(strand,value): strand.getArchStatePtr().getRegisterFilePtr().setCANRESTORE(long(value))
def __getotherwin__(strand): return strand.getArchStatePtr().getRegisterFilePtr().getOTHERWIN()
def __setotherwin__(strand,value): strand.getArchStatePtr().getRegisterFilePtr().setOTHERWIN(long(value))
def __getcleanwin__(strand): return strand.getArchStatePtr().getRegisterFilePtr().getCLEANWIN()
def __setcleanwin__(strand,value): strand.getArchStatePtr().getRegisterFilePtr().setCLEANWIN(long(value))
def __gety__(strand): return strand.getArchStatePtr().getYRegPtr().getNative()
def __sety__(strand,value): strand.getArchStatePtr().getYRegPtr().setNative(long(value))
def __getasi__(strand): return strand.getArchStatePtr().getAsiRegPtr().getNative()
def __setasi__(strand,value): strand.getArchStatePtr().getAsiRegPtr().setNative(long(value))
def __getccr__(strand): return strand.getArchStatePtr().getCcrRegPtr().getNative()
def __setccr__(strand,value): strand.getArchStatePtr().getCcrRegPtr().setNative(long(value))
def __getfsr__(strand): return strand.getArchStatePtr().getFsrRegPtr().getNative()
def __setfsr__(strand,value): strand.getArchStatePtr().getFsrRegPtr().setNative(long(value))
def __getgsr__(strand): return strand.getArchStatePtr().getGsrRegPtr().getNative()
def __setgsr__(strand,value): strand.getArchStatePtr().getGsrRegPtr().setNative(long(value))
def __getfprs__(strand): return strand.getArchStatePtr().getFprsRegPtr().getNative()
def __setfprs__(strand,value): strand.getArchStatePtr().getFprsRegPtr().setNative(long(value))
def __getpil__(strand): return strand.getArchStatePtr().getPilRegPtr().getNative()
def __setpil__(strand,value): strand.getArchStatePtr().getPilRegPtr().setNative(long(value))
def __getsoftint__(strand): return strand.getArchStatePtr().getSoftIntRegPtr().getNative()
def __setsoftint__(strand,value): strand.getArchStatePtr().getSoftIntRegPtr().setNative(long(value))
def __gettl__(strand): return strand.getArchStatePtr().getTrapLevelRegPtr().getNative()
def __settl__(strand,value): strand.getArchStatePtr().getTrapLevelRegPtr().setNative(long(value))
def __getgl__(strand): return strand.getArchStatePtr().getGlobalLevelRegPtr().getNative()
def __setgl__(strand,value): 
  strand.getArchStatePtr().getGlobalLevelRegPtr().setNative(long(value))
  strand.getArchStatePtr().getRegisterFilePtr().selectGlobalSet(value)

def __getwstate__(strand): return strand.getArchStatePtr().getWstateRegPtr().getNative()
def __setwstate__(strand,value): strand.getArchStatePtr().getWstateRegPtr().setNative(long(value))
def __getpstate__(strand): return strand.getArchStatePtr().getPstateRegPtr().getNative()
def __setpstate__(strand,value): strand.getArchStatePtr().getPstateRegPtr().setNative(long(value))
def __gethpstate__(strand): return strand.getArchStatePtr().getHpstateRegPtr().getNative()
def __sethpstate__(strand,value): strand.getArchStatePtr().getHpstateRegPtr().setNative(long(value))
def __gettba__(strand): return strand.getArchStatePtr().getTbaRegPtr().getNative()
def __settba__(strand,value): strand.getArchStatePtr().getTbaRegPtr().setNative(long(value))
def __gethtba__(strand): return strand.getArchStatePtr().getHtbaRegPtr().getNative()
def __sethtba__(strand,value): strand.getArchStatePtr().getHtbaRegPtr().setNative(long(value))
def __gethver__(strand): return strand.getArchStatePtr().getHverRegPtr().getNative()
def __sethver__(strand,value): strand.getArchStatePtr().getHverRegPtr().setNative(long(value))
def __gethintp__(strand): return strand.getArchStatePtr().getHintpRegPtr().getNative()
def __sethintp__(strand,value): strand.getArchStatePtr().getHintpRegPtr().setNative(long(value))
def __gettick__(strand): return strand.getArchStatePtr().getTickRegPtr().getNative()
def __settick__(strand,value): strand.getArchStatePtr().getTickRegPtr().setNative(long(value))
def __getstick__(strand): return strand.getArchStatePtr().getStickRegPtr().getNative()
def __setstick__(strand,value): strand.getArchStatePtr().getStickRegPtr().setNative(long(value))
def __gettick_cmpr__(strand): return strand.getArchStatePtr().getTickCmprRegPtr().getNative()
def __settick_cmpr__(strand,value): strand.getArchStatePtr().getTickCmprRegPtr().setNative(long(value))
def __getstick_cmpr__(strand): return strand.getArchStatePtr().getStickCmprRegPtr().getNative()
def __setstick_cmpr__(strand,value): strand.getArchStatePtr().getStickCmprRegPtr().setNative(long(value))
def __gethstick_cmpr__(strand): return strand.getArchStatePtr().getHstickCompareRegPtr().getNative()
def __sethstick_cmpr__(strand,value): strand.getArchStatePtr().getHstickCompareRegPtr().setNative(long(value))

def __getmax_wp__(strand): return strand.getArchStatePtr().getRegisterFilePtr().getNWINDOWS() - 1
def __getmax_tl__(strand): return strand.get_max_tl()
def __getmax_gl__(strand): return strand.get_max_gl()
def __getmax_ptl__(strand): return strand.get_max_ptl()
def __getmax_pgl__(strand): return strand.get_max_pgl()

def __getirf__(r): 
  return lambda strand: strand.getArchStatePtr().getRegisterFilePtr().get(r)

def __setirf__(r): 
  return lambda strand,value: strand.getArchStatePtr().getRegisterFilePtr().set(r,long(value))

def __getfrf__(f): 
  return lambda strand: strand.getArchStatePtr().getFloatRegisterFilePtr().getSpfp(f)

def __setfrf__(f): 
  return lambda strand,value: strand.getArchStatePtr().getFloatRegisterFilePtr().setSpfp(f,value)

def __getdrf__(d): 
  return lambda strand: strand.getArchStatePtr().getFloatRegisterFilePtr().getDpfp(d)

def __setdrf__(d): 
  return lambda strand,value: strand.getArchStatePtr().getFloatRegisterFilePtr().setDpfp(d,long(value))

def __gettt_tl__(strand,tl): 
  return strand.getArchStatePtr().getTrapTypeRegPtr().getTrapType(tl)

def __settt_tl__(strand,tl,value): 
  strand.getArchStatePtr().getTrapTypeRegPtr().setTrapType(tl,long(value))

def __gettpc_tl__(strand,tl): 
  return strand.getArchStatePtr().getTpcRegPtr().getTpc(tl)

def __settpc_tl__(strand,tl,value): 
  strand.getArchStatePtr().getTpcRegPtr().setTpc(tl,long(value))

def __gettnpc_tl__(strand,tl): 
  return strand.getArchStatePtr().getTnpcRegPtr().getTnpc(tl)

def __settnpc_tl__(strand,tl,value): 
  strand.getArchStatePtr().getTnpcRegPtr().setTnpc(tl,long(value))

def __gettstate_tl__(strand,tl): 
  tstate = strand.getArchStatePtr().getTstateRegPtr()
  entry = tstate.getTstateEntry(tl)
  return entry.getNative()

def __settstate_tl__(strand,tl,value): 
  tstate = strand.getArchStatePtr().getTstateRegPtr()
  entry = tstate.getTstateEntry(tl)
  entry.setNative(long(value))
  tstate.setTstateEntry(tl,entry)

def __gethtstate_tl__(strand,tl): 
  htstate = strand.getArchStatePtr().getHtstateRegPtr()
  entry = htstate.getHtstateEntry(tl)
  return entry.getNative()

def __sethtstate_tl__(strand,tl,value): 
  htstate = strand.getArchStatePtr().getHtstateRegPtr()
  entry = htstate.getHtstateEntry(tl)
  entry.setNative(long(value))
  htstate.setHtstateEntry(tl,entry)
 
def __getreg_stack__(r):
  return lambda strand,sp: strand.getArchStatePtr().getRegisterFilePtr().get(sp,r)

def __setreg_stack__(r):
  return lambda strand,sp,value: strand.getArchStatePtr().getRegisterFilePtr().set(sp,r,long(value))

# used by asi_alias  command, no side effects desired
def __rdasi__(strand,asi,va,nse):
  return strand.RS_asiRead(asi,long(va), nse)

def __wrasi__(strand,asi,va,value,nse):
  return strand.RS_asiWrite(asi,long(va),long(value), nse)

Pfe_Strand.TrapStack.__getfun__['tt'] = __gettt_tl__
Pfe_Strand.TrapStack.__setfun__['tt'] = __settt_tl__
Pfe_Strand.TrapStack.__getfun__['tpc'] = __gettpc_tl__
Pfe_Strand.TrapStack.__setfun__['tpc'] = __settpc_tl__
Pfe_Strand.TrapStack.__getfun__['tnpc'] = __gettnpc_tl__
Pfe_Strand.TrapStack.__setfun__['tnpc'] = __settnpc_tl__
Pfe_Strand.TrapStack.__getfun__['tstate'] = __gettstate_tl__
Pfe_Strand.TrapStack.__setfun__['tstate'] = __settstate_tl__
Pfe_Strand.TrapStack.__getfun__['htstate'] = __gethtstate_tl__
Pfe_Strand.TrapStack.__setfun__['htstate'] = __sethtstate_tl__


def __getstrand_id__(strand):
  return strand.getId()

class AsiArray:
  def __init__(self,name,asi,base_va,max_index,stride):
    self.__dict__['__name__'] = name
    self.__dict__['__base_va__'] = base_va
    self.__dict__['__asi__'] = asi	
    self.__dict__['__max_index__'] = max_index
    self.__dict__['__stride__'] = stride
    self.__dict__['__value__'] = None
    self.__dict__['__strand__'] = None

    if name == name.upper():
      self.__dict__['__nse__'] = True
    else:
      self.__dict__['__nse__'] = False

  def __getitem__(self,index):
    if self.__max_index__ < index:
      print 'invalid ASI access -> ' + self.__name__ + ('(asi = 0x%x, va = 0x%x)') % (self.__asi__,index * self.__stride__ + self.__base_va__)
      return None
    return __rdasi__(self.__strand__,self.__asi__,self.__base_va__ + self.__stride__ * index,self.__nse__)

  def __setitem__(self,index,value):
    if self.__max_index__ < index:
      print "invalid ASI access -> " + self.__name__ + ('(asi = 0x%x, va = 0x%x)') % (self.__asi__,index * self.__stride__ + self.__base_va__)
      return
    __wrasi__(self.__strand__,self.__asi__,self.__base_va__ + self.__stride__ * index,value, self.__nse__)

  def __call__(self,strand,value = None):
    self.__value__ = value
    self.__strand__ = strand
    return self


class Strand(Pfe_Strand.Strand):
  Pfe_Strand.Strand.__getfun__['strand_id'] = __getstrand_id__
  Pfe_Strand.Strand.__getfun__['max_tl'] = __getmax_tl__
  Pfe_Strand.Strand.__getfun__['max_gl'] = __getmax_gl__
  Pfe_Strand.Strand.__getfun__['max_ptl'] = __getmax_ptl__
  Pfe_Strand.Strand.__getfun__['max_pgl'] = __getmax_pgl__
  Pfe_Strand.Strand.__getfun__['max_wp'] = __getmax_wp__
  Pfe_Strand.Strand.__getfun__['pc'] = __getpc__
  Pfe_Strand.Strand.__setfun__['pc'] = __setpc__
  Pfe_Strand.Strand.__getfun__['npc'] = __getnpc__
  Pfe_Strand.Strand.__setfun__['npc'] = __setnpc__
  Pfe_Strand.Strand.__getfun__['cwp'] = __getcwp__
  Pfe_Strand.Strand.__setfun__['cwp'] = __setcwp__
  Pfe_Strand.Strand.__getfun__['cansave'] = __getcansave__
  Pfe_Strand.Strand.__setfun__['cansave'] = __setcansave__
  Pfe_Strand.Strand.__getfun__['canrestore'] = __getcanrestore__
  Pfe_Strand.Strand.__setfun__['canrestore'] = __setcanrestore__
  Pfe_Strand.Strand.__getfun__['otherwin'] = __getotherwin__
  Pfe_Strand.Strand.__setfun__['otherwin'] = __setotherwin__
  Pfe_Strand.Strand.__getfun__['cleanwin'] = __getcleanwin__
  Pfe_Strand.Strand.__setfun__['cleanwin'] = __setcleanwin__
  Pfe_Strand.Strand.__getfun__['y'] = __gety__
  Pfe_Strand.Strand.__setfun__['y'] = __sety__
  Pfe_Strand.Strand.__getfun__['asi'] = __getasi__
  Pfe_Strand.Strand.__setfun__['asi'] = __setasi__
  Pfe_Strand.Strand.__getfun__['ccr'] = __getccr__
  Pfe_Strand.Strand.__setfun__['ccr'] = __setccr__
  Pfe_Strand.Strand.__getfun__['fsr'] = __getfsr__
  Pfe_Strand.Strand.__setfun__['fsr'] = __setfsr__
  Pfe_Strand.Strand.__getfun__['gsr'] = __getgsr__
  Pfe_Strand.Strand.__setfun__['gsr'] = __setgsr__
  Pfe_Strand.Strand.__getfun__['fprs'] = __getfprs__
  Pfe_Strand.Strand.__setfun__['fprs'] = __setfprs__
  Pfe_Strand.Strand.__getfun__['pil'] = __getpil__
  Pfe_Strand.Strand.__setfun__['pil'] = __setpil__
  Pfe_Strand.Strand.__getfun__['softint'] = __getsoftint__
  Pfe_Strand.Strand.__setfun__['softint'] = __setsoftint__
  Pfe_Strand.Strand.__getfun__['tl'] = __gettl__
  Pfe_Strand.Strand.__setfun__['tl'] = __settl__
  Pfe_Strand.Strand.__getfun__['gl'] = __getgl__
  Pfe_Strand.Strand.__setfun__['gl'] = __setgl__
  Pfe_Strand.Strand.__getfun__['wstate'] = __getwstate__
  Pfe_Strand.Strand.__setfun__['wstate'] = __setwstate__
  Pfe_Strand.Strand.__getfun__['pstate'] = __getpstate__
  Pfe_Strand.Strand.__setfun__['pstate'] = __setpstate__
  Pfe_Strand.Strand.__getfun__['hpstate'] = __gethpstate__
  Pfe_Strand.Strand.__setfun__['hpstate'] = __sethpstate__
  Pfe_Strand.Strand.__getfun__['tba'] = __gettba__
  Pfe_Strand.Strand.__setfun__['tba'] = __settba__
  Pfe_Strand.Strand.__getfun__['htba'] = __gethtba__
  Pfe_Strand.Strand.__setfun__['htba'] = __sethtba__
  Pfe_Strand.Strand.__getfun__['hver'] = __gethver__
  Pfe_Strand.Strand.__setfun__['hver'] = __sethver__
  Pfe_Strand.Strand.__getfun__['hintp'] = __gethintp__
  Pfe_Strand.Strand.__setfun__['hintp'] = __sethintp__
  Pfe_Strand.Strand.__getfun__['tick'] = __gettick__
  Pfe_Strand.Strand.__setfun__['tick'] = __settick__
  Pfe_Strand.Strand.__getfun__['stick'] = __getstick__
  Pfe_Strand.Strand.__setfun__['stick'] = __setstick__
  Pfe_Strand.Strand.__getfun__['tick_cmpr'] = __gettick_cmpr__
  Pfe_Strand.Strand.__setfun__['tick_cmpr'] = __settick_cmpr__
  Pfe_Strand.Strand.__getfun__['stick_cmpr'] = __getstick_cmpr__
  Pfe_Strand.Strand.__setfun__['stick_cmpr'] = __setstick_cmpr__
  Pfe_Strand.Strand.__getfun__['hstick_cmpr'] = __gethstick_cmpr__
  Pfe_Strand.Strand.__setfun__['hstick_cmpr'] = __sethstick_cmpr__

  for i,r in enumerate(Pfe_Strand.Strand.__irf__):
    Pfe_Strand.Strand.__getfun__[r] = __getirf__(i)
    Pfe_Strand.Strand.__setfun__[r] = __setirf__(i)

  for i,f in enumerate(Pfe_Strand.Strand.__frf__):
    Pfe_Strand.Strand.__getfun__[f] = __getfrf__(i)
    Pfe_Strand.Strand.__setfun__[f] = __setfrf__(i)

  for i,d in enumerate(Pfe_Strand.Strand.__drf__):
    Pfe_Strand.Strand.__getfun__[d] = __getdrf__(i*2)
    Pfe_Strand.Strand.__setfun__[d] = __setdrf__(i*2)

  for i,g in enumerate(Pfe_Strand.Strand.__irf__[:8]):
    Pfe_Strand.GlobalStack.__getfun__[g] =  __getreg_stack__(i)
    Pfe_Strand.GlobalStack.__getfun__[i] =  __getreg_stack__(i)
    Pfe_Strand.GlobalStack.__setfun__[g] =  __setreg_stack__(i)
    Pfe_Strand.GlobalStack.__setfun__[i] =  __setreg_stack__(i)

  for i,w in enumerate(Pfe_Strand.Strand.__irf__[8:]):
    Pfe_Strand.WindowStack.__getfun__[w] = __getreg_stack__(i+8)
    Pfe_Strand.WindowStack.__getfun__[i+8] = __getreg_stack__(i+8)
    Pfe_Strand.WindowStack.__setfun__[w] = __setreg_stack__(i+8)
    Pfe_Strand.WindowStack.__setfun__[i+8] = __setreg_stack__(i+8)

  del i,r,f,d,g,w

  def __init__(self,strand,ref):
    Pfe_Strand.Strand.__init__(self,strand,ref)
    self.__dict__['__lststate__'] = {}
    self.__dict__['__lstnames__'] = ['pc','npc'] + Pfe_Strand.Strand.__irf__ + Pfe_Strand.Strand.__drf__ + [
              'y','ccr','asi','fprs','gsr','fsr','pstate','hpstate','gl','tba','htba',
	      'tl','tt','tpc','tnpc','tstate','htstate',
	      'cwp','cansave','canrestore','cleanwin','otherwin']
    for r in self.__lstnames__:
      self.__lststate__[r] = None

  def __runstep__(self,n=None):
     # when strand.step() hits a breakpoint, the breakpoint-id (> 0) is 
     # returned, otherwise 0 is returned.
     if n == None:
       bid = self.__strand__.step()
       return bid
     else:
       bid = 0
       while n and (bid == 0):
         bid = self.__strand__.step()
	 n -= 1
       return bid

  def __dis_addr__(self,addr):
    iw = self.__strand__.RS_access(self.inst_va2pa(addr),0L,1,4)
    print "%s:0x%016x [0x%08x] %s" % (self.ref,addr, iw,self.__strand__.RS_getInstrPtr(iw).toString())

  def __lststep__(self,n = None):
    if n == None:
      pc = self.__strand__.getArchStatePtr().getPc()
      if self.__listing__ == 2:
        self.__strand__.step()
        last_instr = self.__last_instr__(self.__strand__)
        print "%s:0x%016x [0x%08x] %s" % (self.ref,pc, last_instr.getNative(),last_instr.toString())
        return 0
      else:
          self.__strand__.step()
          last_instr = self.__last_instr__(self.__strand__)
          print "%s:0x%016x [0x%08x] %s" % (self.ref,pc, last_instr.getNative(),last_instr.toString())
          if self.tl == 0:
            for r in self.__lstnames__:
              if r in ['tt','tpc','tnpc','tstate','htstate']:
                value = None
              else:
                value = getattr(self,r)
              if self.__lststate__[r] != value:
                if value != None and self.__lststate__[r] != None:
                  print "\t%s:0x%x -> 0x%x" % (r,self.__lststate__[r],value)
                elif value != None:
                  print "\t%s:None -> 0x%x" % (r,value)
                else:
                  print "\t%s:0x%x -> None" % (r,self.__lststate__[r])
                self.__lststate__[r] = value
          else:
            for r in self.__lstnames__:
              value = getattr(self,r)
       	      if self.__lststate__[r] != value:
                if value != None and self.__lststate__[r] != None:
                  print "\t%s:0x%x -> 0x%x" % (r,self.__lststate__[r],value)
                elif value != None:
                  print "\t%s:None -> 0x%x" % (r,value)
                else:
                  print "\t%s:0x%x -> None" % (r,self.__lststate__[r])
	        self.__lststate__[r] = value

    else:
      while n:
        self.__lststep__()
        n -= 1
      return n

  step = __runstep__

  def rdasi(self,asi,va,nse = False):
    return self.__strand__.RS_asiRead(asi,long(va), nse)

  def wrasi(self,asi,va,value,nse = False):
    self.__strand__.RS_asiWrite(asi,long(va),long(value), nse)

  def inst_va2pa(self,va):
    return self.__strand__.RS_translate(1,long(va))

  def inst_ra2pa(self,va):
    return 'Unimplemented yet\n'

  def data_va2pa(self,va):
    return self.__strand__.RS_translate(0,long(va))
    
  def data_ra2pa(self,va):
    return 'Unimplemented yet\n'
  ## cleanup item
  def access_system_mem(self,addr,value,isread,size):
    return self.__strand__.RS_access(addr,value,isread,size)
  ## cleanup item
  def tlblookup(self,va, pid, ctxt, ra2pa, bypass):
    return self.__strand__.getMmuPtr().RS_tlblookup(va, pid, ctxt, ra2pa, bypass)	

  def asi_alias(self,name,asi,va):
    if Pfe_Strand.Strand.__getfun__.has_key(name):
      #raise NameExistsErr(name)
      print 'asi_alias:Name already aliased ' + name + '\n'
      return		
    nse = True
    if name == name.lower():
      nse = False
    elif name == name.upper():
      nse = True
    else:
      print "asi_alias:Should give an all uppercase or all lower case name " + name 
      return
    Pfe_Strand.Strand.__getfun__[name] = lambda  strand: __rdasi__(strand,asi,va,nse)
    Pfe_Strand.Strand.__setfun__[name] = lambda  strand,value: __wrasi__(strand,asi,va,value,nse)

  def asi_alias_array(self,name,asi,base_va, max_index,stride = 8):
    """
  # register an alias for an ASI with multiple VA's
  # the individual registers would be available as 
  # sim.s0.<registered name>[<index>]
  # the actual ASI VA = base_va + stride * index, ie its assumed that the user
  # would not access an invalid VA
    """
    if Pfe_Strand.Strand.__getfun__.has_key(name):
      print 'asi_alias_array:Name already aliased ' + name + '\n'
      return
    if name != name.upper() and name != name.lower():
      print "asi_alias_array:Should give an all uppercase or all lower case name" + name
      return
    Pfe_Strand.Strand.__setfun__[name] = Pfe_Strand.Strand.__getfun__[name] =  AsiArray(name,asi,base_va,max_index,stride)

  def __get_iw_ptr__(self,iw):
    iw = long(iw)
    iw = iw & 0x00000000ffffffffL
    return self.__strand__.RS_getInstrPtr(iw)






