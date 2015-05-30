
import os
import Pfe_Memory

class Memory(Pfe_Memory.Memory):
  def __init__(self,system,memory):
    Pfe_Memory.Memory.__init__(self)
    self.__system__ = system
    self.__memory__ = memory

  def load(self,filename):
    os.stat(filename)			# Test for excisting filename
    self.__system__.loadMemdatImage(filename)

  def __ldb__(self,addr):  
    return (self.__memory__.read32(long(addr) &~ 3L) >> (8*(3-(addr & 3L)))) & 0xff

  def __ldh__(self,addr):  
    return (self.__memory__.read32(long(addr) &~ 3L) >> (8*(2-(addr & 2L)))) & 0xffff

  def __ldw__(self,addr):  
    return self.__memory__.read32(long(addr) &~ 3L)
  
  def __ldx__(self,addr):  
    return self.__memory__.read64(long(addr) &~ 7L)

  def __stb__(self,addr,data):  
    word = self.__ldw__(addr)
    shft = 8*(3-(addr & 3L))
    mask = 0xff << shft
    data = data << shft
    self.__stw__(addr,(data & mask) | (word & ~mask))

  def __sth__(self,addr,data):  
    word = self.__ldw__(addr)
    shft = 8*(2-(addr & 2L))
    mask = 0xffff << shft
    data = data << shft
    self.__stw__(addr,(data & mask) | (word & ~mask))

  def __stw__(self,addr,data):  
    self.__memory__.write32(long(addr) &~ 3L,long(data))
    
  def __stx__(self,addr,data):  
    self.__memory__.write64(long(addr) &~ 7L,long(data))



