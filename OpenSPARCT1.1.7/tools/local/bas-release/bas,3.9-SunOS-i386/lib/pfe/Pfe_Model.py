

class uCore:
  def __init__(self):
    self.s = []

  def __populate__(self):
    for i,s in enumerate(self.s):
      self.__dict__['s' + str(i)] = s

  def __repr__(self):
    return "<uCore instance>"


class Core:
  def __init__(self):
    self.u = []
    self.s = []

  def __populate__(self):
    for i,u in enumerate(self.u):
      u.__populate__()
      self.__dict__['u' + str(i)] = u
      self.s += u.s
    for i,s in enumerate(self.s):
      self.__dict__['s' + str(i)] = s
      
  def __repr__(self):
    return "<Core instance>"


class Cpu:
  def __init__(self):
    self.c = []
    self.u = []
    self.s = []

  def __populate__(self):
    for i,c in enumerate(self.c):
      c.__populate__()
      self.__dict__['c'+str(i)] = c
      self.u += c.u
      self.s += c.s
    for i,u in enumerate(self.u):
      self.__dict__['u' + str(i)] = u
    for i,s in enumerate(self.s):
      self.__dict__['s' + str(i)] = s

  def __repr__(self):
    return "<Cpu instance>"


class Model:
  def __init__(self):
    self.mem = None
    self.p = []
    self.c = []
    self.u = []
    self.s = []

  def __populate__(self):
    for p in self.p:
      p.__populate__()
      self.c += p.c
      self.u += p.u
      self.s += p.s
    for i,c in enumerate(self.c):
      self.__dict__['c' + str(i)] = c
    for i,u in enumerate(self.u):
      self.__dict__['u' + str(i)] = u
    for i,s in enumerate(self.s):
      self.__dict__['s' + str(i)] = s

  def __create_cpu__(self,count):
    """
    create_cpu() creates n cpu instances of the specific product.
    If the product does not support creating n instances of the cpu
    then the method returns False
    """
    return False

  def __repr__(self):
    return "<Model instance>"


