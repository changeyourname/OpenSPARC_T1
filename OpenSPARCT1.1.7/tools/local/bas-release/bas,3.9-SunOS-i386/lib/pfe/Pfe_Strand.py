
class GetAttrError(Exception):
  def __init__(self,name):
    Exception.__init__(self)
    self.name = name
  def __str__(self):
    return "The strand has no getable state member '"+self.name+"'"

class DelAttrError(Exception):
  def __init__(self,name):
    Exception.__init__(self)
    self.name = name
  def __str__(self):
    return "Strand attributes such as "+self.name+" can not be deleted"

class SetAttrError(Exception):
  def __init__(self,name):
    Exception.__init__(self)
    self.name = name
  def __str__(self):
    return "The strand has no setable state member '"+name+"'"

class TrapLevelZeroError(Exception):
  def __init__(self):
    Exception.__init__(self)
  def __str__(self):
    return "Trap state can not be accessed when tl=0"


def __geterror_fun__(name,strand):
  raise GetAttrError(name)
def __seterror_fun__(name,strand,value):
  raise SetAttrError(name)

def __geterror__(name):
  return lambda strand: __geterror_fun__(name,strand)
def __seterror__(name):
  return lambda strand,value: __seterror_fun__(name,strand,value)


def __gettl_check__(strand):
  tl = Strand.__getfun__['tl'](strand)
  if tl == 0:
    raise TrapLevelZeroError()
  return tl

def __gettt__(strand): return TrapStack.__getfun__['tt'](strand,__gettl_check__(strand)) 
def __settt__(strand,value): TrapStack.__setfun__['tt'](strand,__gettl_check__(strand),value) 
def __gettpc__(strand): return TrapStack.__getfun__['tpc'](strand,__gettl_check__(strand)) 
def __settpc__(strand,value): TrapStack.__setfun__['tpc'](strand,__gettl_check__(strand),value) 
def __gettnpc__(strand): return TrapStack.__getfun__['tnpc'](strand,__gettl_check__(strand)) 
def __settnpc__(strand,value): TrapStack.__setfun__['tnpc'](strand,__gettl_check__(strand),value) 
def __gettstate__(strand): return TrapStack.__getfun__['tstate'](strand,__gettl_check__(strand)) 
def __settstate__(strand,value): TrapStack.__setfun__['tstate'](strand,__gettl_check__(strand),value) 
def __gethtstate__(strand): return TrapStack.__getfun__['htstate'](strand,__gettl_check__(strand)) 
def __sethtstate__(strand,value): TrapStack.__setfun__['htstate'](strand,__gettl_check__(strand),value)
  

class Strand:
  __getfun__= {
    'tt': __gettt__,
    'tpc': __gettpc__,
    'tnpc': __gettnpc__,
    'tstate': __gettstate__,
    'htstate': __gethtstate__
  }
  __setfun__ = {
    'tt': __settt__,
    'tpc': __settpc__,
    'tnpc': __settnpc__,
    'tstate': __settstate__,
    'htstate': __sethtstate__
  }

  for i in ['pc', 'npc', 'cwp', 'cansave', 'canrestore', 'otherwin', 'cleanwin', 'wstate',
	    'y', 'asi', 'ccr', 'fsr', 'gsr', 'fprs', 'pil', 'softint',
	    'tl', 'gl', 'pstate', 'hpstate', 'tba', 'htba', 'hver', 'hintp',
	    'tick', 'stick', 'tick_cmpr', 'stick_cmpr', 'hstick_cmpr', 'rstv_addr'
	    'max_tl', 'max_gl', 'max_ptl', 'max_pgl','max_wp','strand_id']:
    __getfun__[i] = __geterror__(i)
    __setfun__[i] = __seterror__(i)

  __irf__ = ['g%d' % i for i in range(0,8)]\
          + ['o%d' % i for i in range(0,8)]\
          + ['l%d' % i for i in range(0,8)]\
          + ['i%d' % i for i in range(0,8)]
  __frf__ = ['f%d' % i for i in range(0,64)]
  __drf__ = ['d%d' % i for i in range(0,64,2)]
  __qrf__ = ['q%d' % i for i in range(0,64,4)]
  __asr__ = ['asr%d' % i for i in range(0,32)]
  __pr__  = ['pr%d' % i for i in range(0,32)]
  __hpr__ = ['hpr%d' % i for i in range(0,32)]
  __sim__ = ['sim%d' % i for i in range(0,32)]

  for i in __irf__:
    __getfun__[i] = __geterror__(i)
    __setfun__[i] = __seterror__(i)
  for i in __frf__:
    __getfun__[i] = __geterror__(i)
    __setfun__[i] = __seterror__(i)
  for i in __drf__:
    __getfun__[i] = __geterror__(i)
    __setfun__[i] = __seterror__(i)
  for i in __qrf__:
    __getfun__[i] = __geterror__(i)
    __setfun__[i] = __seterror__(i)
  for i in __asr__:
    __getfun__[i] = __geterror__(i)
    __setfun__[i] = __seterror__(i)
  for i in __pr__:
    __getfun__[i] = __geterror__(i)
    __setfun__[i] = __seterror__(i)
  for i in __hpr__:
    __getfun__[i] = __geterror__(i)
    __setfun__[i] = __seterror__(i)
  for i in __sim__:
    __getfun__[i] = __geterror__(i)
    __setfun__[i] = __seterror__(i)

  del i

  def __init__(self,strand,ref):
    self.__dict__['__strand__'] = strand
    self.__dict__['ref'] = ref
    self.__dict__['inst_tlb'] = {}
    self.__dict__['data_tlb'] = {}
    self.__dict__['brk'] = {}
    self.__dict__['t'] = TrapStack(strand) 
    self.__dict__['g'] = GlobalStack(strand)
    self.__dict__['w'] = WindowStack(strand)
    self.__dict__['__listing__'] = 0
    self.__dict__['__verify__'] = False
    self.__dict__['__ras__'] = False
    
  def __getattr__(self,name):
    if Strand.__getfun__.has_key(name):
      return Strand.__getfun__[name](self.__strand__)
    raise GetAttrError(name)

  def __setattr__(self,name,data):
    if Strand.__setfun__.has_key(name):
      return Strand.__setfun__[name](self.__strand__,data)
    #self.__dict__[name] = data
    if self.__dict__.has_key(name):
      self.__dict__[name] = data
      return
    #else:
    #  print 'Cant set. No strand attribute %s\n' % (name,)

    try:
      getattr(self,name)
    except GetAttrError:
       return 'Cant set. No strand attribute %s\n' % (name,)
    else:
      self.__dict__[name] = data


  def __delattr__(self,name):
    if name == 'brk':
      for i in self.brk:
	del self.brk[i]
    elif name == 'inst_tlb':
      for i in self.inst_tbl:
	del self.inst_tlb[i]
    elif name == 'data_tlb':
      for i in self.data_tbl:
	del self.data_tlb[i]
    elif name == '__strand__' or name == 't':
      DelAttrError(name)
    else:
      del self.__dict__[name]

  def __repr__(self):
    return "<Strand instance>"

  def __str__(self):
    return "<Strand instance>"

  #------------------------------------------------------------------------
  # mode switching related interface
  #------------------------------------------------------------------------

  def lstmode(self,lstval = None):
    """
    lstmode() switches the strand to listing mode based on the value of lstval
    a value of 0 disables the list mode.
    a value of 1 enables the list mode where the executed instruction along
	with the sideeffects are displayed.
    a value of 2 enables the list mode where only the executed instruction 
	is displayed.
    w/o an argument the current listing mode is returned
    """
    if lstval == None:
      return self.__listing__
    elif type(lstval) != int:
      raise TypeError

    self.__listing__ = lstval

    if lstval != 0:
      self.step = self.__lststep__
      if lstval == 1:
	if self.__dict__.has_key('__lstnames__'):
          if self.tl == 0:
            for r in self.__lstnames__:
              if r in ['tt','tpc','tnpc','tstate','htstate']:
                self.__lststate__[r] = None
              else:
                self.__lststate__[r] = getattr(self,r)
          else:
            for r in self.__lststate__:
              self.__lststate__[r] = getattr(self,r)
    else:
      self.step = self.__runstep__


  def vrfmode(self,on):
    """
    vrfmode() switches the strand to verification mode when on=True, e.g turn of optimisations for 
    run mode. This means that every load/store and instruction fetch goes through the
    mmu.
    """
    if on == None:
      return self.__verify__
    elif type(on) != bool:
      raise TypeError

    self.__verify__ = on


  def rasmode(self,on):
    """
    rasmode() switches the strand into ras mode when on=True, expects vrfmode to be on
    """
    if on == None:
      return self.__ras__
    elif type(on) != bool:
      raise TypeError

    self.__ras__ = on

  #------------------------------------------------------------------------
  # translate addresses 
  #------------------------------------------------------------------------

  def va2pa(self,va,ctx=None,pid=None):
    pass

  def ra2pa(self,ra,pid=None):
    pass

  #------------------------------------------------------------------------
  # CMP related interface
  #------------------------------------------------------------------------
  
  def available(self,on=None):
    pass

  def enable(self,on=None):
    pass

  def running(self,on=None):
    pass

  def stepping(self,on=None):
    pass
    
  #------------------------------------------------------------------------
  # step related interface
  #------------------------------------------------------------------------

  def step(self,n=None):
    """
    step() steps the simulator n instructions forward
    The method is switched between __runstep__ and __lststep__ by lstmode()
    """
    pass

  def __runstep__(self,n=None):
    """
    runstep() steps the simulator n instruction without echoing inpstr to output 
    """
    pass

  def __lststep__(self,n=None):
    """
    lststep() steps the simulator n instruction and echo instr to output 
    """
    pass



class TrapStackEntry:
  def __init__(self,strand,tl):
    self.__dict__['strand'] = strand
    self.__dict__['tl']     = tl
  
  def __getattr__(self,name):
    return TrapStack.__getfun__[name](self.strand,self.tl)

  def __setattr__(self,name,value):
    return TrapStack.__setfun__[name](self.strand,self.tl,value)


class TrapStack:
  MAXTL = 15

  __getfun__ = {}
  __setfun__ = {}

  for field in ['tt','tpc','tnpc','tstate','htstate']:
    __getfun__[field] = __geterror__(field)
    __setfun__[field] = __seterror__(field)
  del field

  def __init__(self,strand):
    self.trap_stack = {}
    for tl in range(1,TrapStack.MAXTL):
      self.trap_stack[tl] = TrapStackEntry(strand,tl)

  def __getitem__(self,index):
    if index == 0:
      raise TrapLevelZeroError()
    return self.trap_stack[index]


class GlobalStackEntry:
  def __init__(self,strand,gl):
    self.__dict__['strand'] = strand
    self.__dict__['gl'] = gl

  def __getattr__(self,name):
    return GlobalStack.__getfun__[name](self.strand,self.gl)

  def __setattr__(self,name,value):
    return GlobalStack.__setfun__[name](self.strand,self.gl,value)

  def __getitem__(self,index):
    return GlobalStack.__getfun__[index](self.strand,self.gl)

  def setitem__(self,index,value):
    return GlobalStack.__setfun__[index](self.strand,self.gl,value)

class GlobalStack:
  MAXGL=15

  __getfun__ = {}
  __setfun__ = {}

  for r in ['g%d' % i for i in range(0,8)]:
    __getfun__[r] = __geterror__(r)
    __setfun__[r] = __seterror__(r)

  def __init__(self,strand):
    self.global_stack = {}
    for gl in range(0,GlobalStack.MAXGL + 1):
      self.global_stack[gl] = GlobalStackEntry(strand,gl)

  def __getitem__(self,index):
    return self.global_stack[index]
  
class WindowRegEntry:
  def __init__(self,strand,win):
    self.__dict__['strand'] = strand
    self.__dict__['win'] = win

  def __getattr__(self,name):
    return WindowStack.__getfun__[name](self.strand,self.win)

  def __setattr__(self,name,value):
    return WindowStack.__setfun__[name](self.strand,self.win,value)

  def __getitem__(self,index):
    return WindowStack.__getfun__[index](self.strand,self.win)

  def __setitem__(self,index,value):
    return WindowStack.__setfun__[index](self.strand,self.win,value)
    

class WindowStack:
  MAXWP = 32
  
  __getfun__ = {}
  __setfun__ = {}

  for r in Strand.__irf__[8:]:
    __getfun__[r] = __geterror__(r)
    __setfun__[r] = __seterror__(r)

  def __init__(self,strand):
    self.window_stack = {}
    for win in range(0,WindowStack.MAXWP):
      self.window_stack[win] = WindowRegEntry(strand,win)

  def __getitem__(self,index):
    return self.window_stack[index]














