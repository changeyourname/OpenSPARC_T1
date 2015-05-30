
class GetAttrError(Exception):
  def __init__(self,name):
    Exception.__init__(self)
    self.name = name
  def __str__(self):
    return "The TLB has no getable field member '"+self.name+"'"

class DelAttrError(Exception):
  def __init__(self,name):
    Exception.__init__(self)
    self.name = name
  def __str__(self):
    return "TLB attributes such as "+name+" can not be deleted"

class SetAttrError(Exception):
  def __init__(self,name):
    Exception.__init__(self)
    self.name = name
  def __str__(self):
    return "The TLB has no setable field member '"+self.name+"'"


def __geterror_fun__(name,strand):
  raise GetAttrError(name)
def __seterror_fun__(name,strand,value):
  raise SetAttrError(name)

def __geterror__(name):
  return lambda strand: __geterror_fun__(name,strand)
def __seterror__(name):
  return lambda strand,value: __seterror_fun__(name,strand,value)


class Tte:
  PAGE_SIZE = ['8K','64K','512K','4M','32M','256M','2G']

  def __init__(self,tte_ref=None,**args):
    if tte_ref == None:
      self.valid = False
      self.real  = False
      self.pid   = 0
      self.ctx   = 0
      self.size  = 0
      self.tag   = 0
      self.ie    = False
      self.nfo   = False
      self.x     = False
      self.p     = False
      self.w     = False
      self.e     = False
      self.cv    = False
      self.cp    = False
      self.lock  = False
      self.addr  = 0
      # other specific TTE fields
      self.sw0    = 0
      self.sw1    = 0
      self.soft   = 0 
      # N1 specific TTE fields
      self.diag7_3 = 0
      self.szh    = 0
      self.szl    = 0      
      self.l      = 0
    elif isinstance(tte_ref,TlbTte) or isinstance(tte_ref,Tte):
      self.valid = tte_ref.valid
      self.real  = tte_ref.real
      self.ctx   = tte_ref.ctx
      self.pid   = tte_ref.pid
      self.tag   = tte_ref.tag
      self.size  = tte_ref.size
      self.ie    = tte_ref.ie
      self.nfo   = tte_ref.nfo
      self.x     = tte_ref.x
      self.p     = tte_ref.p
      self.w     = tte_ref.w
      self.e     = tte_ref.e
      self.cv    = tte_ref.cv
      self.cp    = tte_ref.cp
      self.lock  = tte_ref.lock
      self.addr  = tte_ref.addr
      # other specific TTE fields
      self.soft_flds   = tte_ref.soft_flds
      # N1 specific TTE fields
      self.diag7_3 = tte_ref.diag7_3
    for arg in args:
      if self.__dict__.has_key(arg):
	      setattr(self,arg,args[arg])
      else:
        raise AttributeError(arg)

  def __str__(self):
    """ 
    return a string of the most common looked at fields of the TTE
    """
    if not self.valid:
      return '-------'
    elif self.real:
      s = 'r'
      ctx = ''
    else:
      s = 'v'
      ctx = ' 0x%04x' % self.ctx

    s += self.p   and 'p' or '-'
    s += self.x   and 'x' or '-'
    s += self.w   and 'w' or '-'
    s += self.e   and 'e' or '-'
    s += self.nfo and 'n' or '-'
    s += self.ie  and 'i' or '-'

    tag = self.tag
    if tag < 0:
      tag = 0x10000000000000000 + tag
    addr = self.addr
    if addr < 0:
      addr = 0x10000000000000000 + addr

    size = self.PAGE_SIZE[self.size]
    s += '%4s 0x%016x 0x%016x 0x%02x' % (size,tag,addr,self.pid)
    s += ctx

    return s

  
class TlbTte:
  PAGE_SIZE = ['8K','64K','512K','4M','32M','256M','2G']

  __getfun__ = { 'xlate': __geterror__('xlate'), 'match': __geterror__('match') }
  __setfun__ = {}

  for field in ['valid','real','pid','ctx','size','tag','ie','nfo',
                'x','p','w','e','cv','cp','lock','addr''soft_flds',
                'diag7_3','data','tag']:
    __getfun__[field] = __geterror__(field)
    __setfun__[field] = __seterror__(field)
  
  def __init__(self,tlb,index_fun,index_arg):
    self.__dict__['__tlb__'] = tlb
    self.__dict__['__fun__'] = index_fun
    self.__dict__['__arg__'] = index_arg

  def __getattr__(self,name):
    if TlbTte.__getfun__.has_key(name):
      return TlbTte.__getfun__[name](self.__fun__(self.__arg__))
    else:
      raise AttributeError

  def __setattr__(self,name,value):
    if TlbTte.__setfun__.has_key(name):
      tte = self.__fun__(self.__arg__)
      TlbTte.__setfun__[name](tte,value)
      if 'flush' in dir(self.__tlb__):
	self.__tlb__.flush(tte)
    else:
      raise AttributeError

  def __repr__(self):
    return '<TlbTte instance>'

  def __str__(self):
    """ 
    return a string of the most common looked at fields of the TTE
    """
    if not self.valid:
      return '-------'
    elif self.real:
      s = 'r'
      ctx = ''
    else:
      s = 'v'
      ctx = ' 0x%04x' % self.ctx

    s += self.p   and 'p' or '-'
    s += self.x   and 'x' or '-'
    s += self.w   and 'w' or '-'
    s += self.e   and 'e' or '-'
    s += self.nfo and 'n' or '-'
    s += self.ie  and 'i' or '-'

    tag = self.tag
    if tag < 0:
      tag = 0x10000000000000000 + tag
    addr = self.addr
    if addr < 0:
      addr = 0x10000000000000000 + addr

    size = self.PAGE_SIZE[self.size]
    s += '%4s 0x%016x 0x%016x 0x%02x' % (size,tag,addr,self.pid)
    s += ctx

    return s


class TlbIter:
  def __init__(self,tlb):
    self.tlb = tlb
    self.idx = 0

  def __iter__(self):
    return self

  def next(self):
    index = self.tlb.next_valid_index(self.idx)
    if index >= 0:
      self.idx = index + 1
      return index
    raise StopIteration


class Tlb:
  def __init__(self,tlb):
    self.__dict__['__tlb__'] = tlb
    self.__dict__['tte'] = {}
    for i in range(0,self.size()):
      self.tte[i] = TlbTte(tlb,self.index,i)

  def __len__(self):
    n = 0
    i = self.next_valid_index(0)
    while i >= 0:
      n += 1
      i = self.next_valid_index(i+1)
    return n

  def __iter__(self):
    return TlbIter(self.__tlb__)

  def __repr__(self):
    l = {}
    i = self.__tlb__.next_valid_index(0)
    while i >= 0:
      l[i] = self.tte[i]
      i = self.__tlb__.next_valid_index(i+1)
    return str(l)

  def __str__(self):
    s = ''
    i = self.__tlb__.next_valid_index(0)
    while i >= 0:
      s += '0x%03x: %s\n' % (i,str(self.tte[i]))
      i = self.__tlb__.next_valid_index(i+1)
    return s

  def __getitem__(self,index):
    return self.tte[index]

  def __setitem__(self,index,tte):
    if isinstance(tte,Tte):
      lhs = self.tte[index]
      lhs.valid = tte.valid
      lhs.real  = tte.real
      lhs.ctx   = tte.ctx
      lhs.pid   = tte.pid
      lhs.tag   = tte.tag
      lhs.size  = tte.size
      lhs.ie    = tte.ie
      lhs.nfo   = tte.nfo
      lhs.x     = tte.x
      lhs.p     = tte.p
      lhs.w     = tte.w
      lhs.e     = tte.e
      lhs.cv    = tte.cv
      lhs.cp    = tte.cp
      lhs.lock  = tte.lock
      lhs.addr  = tte.addr
    else:
      raise TypeError

  # size() returns the fixed size of the TLB in number of TTEs.

  def size(self):
    pass

  # index() returns the TTE currently at index i of the TLB.

  def index(self,i):
    pass

  # insert() inserts the TTE in the TLB.

  def insert(self,tte):
    pass

  # next_valid_index() returns the next valid TTE in the TLB
  # starting from i. If none are found the -1 is returned.

  def next_valid_index(self,i):
    if 0 <= i:
      while i < index.size():
        if self.tte[i].valid:
          return i
        i += 1
      return -1

  # return reference to the tte that got inserted
  def insert4v(self,pid,tag,data,tag_bits21_13,real):
    pass

  def insert4u(self,pid,tag,data,va,real):
    pass




