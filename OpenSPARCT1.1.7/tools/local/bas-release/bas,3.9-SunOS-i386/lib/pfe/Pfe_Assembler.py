
import os
import tempfile

as = "/usr/ccs/bin/as"
dis = "/usr/ccs/bin/dis"
grep = "/bin/egrep"

class AssemblerError(Exception):
  def __init__(self,*args):
    Exception.__init__(self,args)


def asm(instr):
  """
  asm() takes a string of assembly code and produces a list of
  instruction words. When asm() is passed a list of strings it
  will produce a list of list of instruction words. For example
  asm('done;nop') returns [0x81f00000,0x1000000] and 
  asm(['done','nop']) returns [[0x81f00000],[0x1000000]].
  """
  if type(instr) == list:
    result = []
    [result.append(asm_instr(i)) for i in instr]
  else:
    result = asm_instr(instr)  
  return result


def asm_instr(instr):
  s_list = []

  s_name = tempfile.mktemp(suffix=".s")
  o_name = tempfile.mktemp(suffix=".o")
  d_name = tempfile.mktemp(suffix=".d")
  e_name = tempfile.mktemp(suffix=".2")
  t_name = tempfile.mktemp(suffix=".t")

  s_file = open(s_name,'w') 
  s_file.writelines([
      ".register %g2,#scratch\n",
      ".register %g3,#scratch\n",
      ".register %g6,#scratch\n",
      ".register %g7,#scratch\n",
      "main:\n", 
      instr])
  s_file.write("\n")
  s_file.close()

  s_exec = "%s -xarch=v9c -o %s %s 2> %s" % (as,o_name,s_name,e_name) 
  if os.system(s_exec) == 0:
    d_exec = "%s %s | /bin/awk '{print $2$3$4$5}' | %s '^[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]' > %s 2> /dev/null" % (dis,o_name,grep,d_name)
    if os.system(d_exec) == 0:
      d_file = open(d_name)
      s_list = [int(nr,16) for nr in d_file.readlines()]
      d_file.close()
      os.unlink(d_name)
      os.unlink(s_name)
    os.unlink(o_name)
  else:
    os.unlink(s_name)
    t_exec = "/bin/sed -e 's/[^:]*:[^:]*:\ //g' %s > %s" % (e_name,t_name)
    os.system(t_exec)
    t_file = open(t_name,'r')
    x = t_file.readlines()
    t_file.close()
    raise AssemblerError(x)
  return s_list


if __name__ == '__main__':
  print asm("adx %g0, %g1, %g2")
  print asm("add %g4, %g5, %g3\nadd %g0, %g1, %g2")
  try:
    print asm(['add %g0, %g1, %o6', 'asd %g7, %g6, %g2'])
  except AssemblerError, e:
    print e




