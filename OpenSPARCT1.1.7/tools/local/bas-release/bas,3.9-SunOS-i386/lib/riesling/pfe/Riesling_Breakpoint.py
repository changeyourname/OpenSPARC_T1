

class breakPoint:
  __BP_PC__ = 1
  __BP_VA__ = 2
  __BP_PA__ = 3

  def __init__(self,system):
    self.__system__ = system
    self.__bptable__ = system.getBreakpointTablePtr()

  def add(self,sid,addr,interval,symbol,type = __BP_PC__):
    return self.__bptable__.add(sid,addr,interval,symbol,type)

  def remove(self,bid):
    return self.__bptable__.remove(bid)

  def enable(self,bid):
    return self.__bptable__.enable(bid)

  def disable(self,bid):
    return self.__bptable__.disable(bid)

  def list(self):
    return self.__bptable__.list()

  def last_hit_bp(self):
    return  self.__bptable__.query()

  def last_hit_strand(self):
    return  self.__bptable__.querySid()

  def is_bad_trap(self):
    return self.__bptable__.isBadTrap()

  def hit_bp(self):
    return  self.__bptable__.queryLast()

  def hit_strand(self):
    return  self.__bptable__.queryLastSid()
