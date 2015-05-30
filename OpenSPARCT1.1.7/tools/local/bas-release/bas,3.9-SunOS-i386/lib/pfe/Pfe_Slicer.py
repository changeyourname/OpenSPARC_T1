

class Slicer:
  """
  Slicer(list) takes a list as argument. When a Slicer
  object is subscribted it returns a sublist of the list.
  For example:

  s = Slicer(range(0,64))
  s[0]			=> [0]
  s[0,2]		=> [0,2]
  s[0:2]		=> [0,1]
  s[0:2,4]		=> [0,1,4]
  s[0:4:2]		=> [0,2,4]
  s[0:2,4:6]		=> [0,1,4,5]

  """
  def __init__(self,list):
    self.list = list

  def __getitem__(self,index):
    if type(index) == tuple:
      l = []
      for i in index:
	if type(i) == slice:
          l.extend(self.list[i])
	else:
	  l.append(self.list[i])
      return l
    elif type(index) == slice:
      return self.list[index]
    else:
      return [self.list[index]]


if __name__ == '__main__':
  s=Slicer(range(0,64))

  print s[0]
  print s[0:32]
  print s[0,8,16,56,64]
  print s[0:32:8]
  print s[0:8,8:16]
  print s[0:8,8:16,32,56:64]


  

