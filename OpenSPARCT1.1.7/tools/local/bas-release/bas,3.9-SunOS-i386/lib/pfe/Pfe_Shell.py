
import os
import sys
import atexit
import readline
import Pfe_Version

from optparse   import OptionParser, Option, OptionValueError
from string     import join
from copy       import copy
from Pfe_Slicer import Slicer


def history(name):
  histfile = os.path.join(os.environ["HOME"],name)
  try:
    readline.read_history_file(histfile)
    atexit.register(readline.write_history_file, histfile)
  except IOError:
    pass


def check_slice(option,opt,value):
  for s in value.split(','):
    try:
      eval('slice('+join(s.split(':'),',')+')')
    except NameError, ValueError:
      raise OptionValueError("option %s: invalid slice: %r" % (opt, value))
  return value


class SliceOption (Option):
  TYPES = Option.TYPES + ("slice",)
  TYPE_CHECKER = copy(Option.TYPE_CHECKER)
  TYPE_CHECKER["slice"] = check_slice


opts = None
args = None

def options(prog):
  argv_parser = OptionParser(usage="usage: "+prog+" [options]",
                             version=Pfe_Version.version(),
			     option_class=SliceOption)
  argv_parser.disable_interspersed_args()

  argv_parser.add_option(
    "-i","--interactive",
    action="store_true",dest="interactive",default=False,
    help="switch to interactive (inspect) mode")
    
  #argv_parser.add_option(
    #"-f","--file",
    #action="append",type="string",dest="file",default=[],
    #metavar="FILE",help="load one or more elf or memory image files")

  argv_parser.add_option(
    "-l","--lstmode",
    action="store_true",dest="lstmode",default=False,
    help="switch to lstmode, default is runmode")
    
  #argv_parser.add_option(
    #"-n","--steps",
    #action="store",type="int",dest="steps",
    #metavar="STEPS",help="step the simulator STEPS instructions per strand")

  #argv_parser.add_option(
    #"-a","--available",
    #action="store",type="slice",dest="available",default="0",
    #metavar="SLICE",help="CMP: Make the SLICE of strands available for stepping (default=0)")

  #argv_parser.add_option(
    #"-e","--enable",
    #action="store",type="slice",dest="enable",default="0",
    #metavar="SLICE",help="CMP: Set the SLICE of strands to enabled for stepping (default=0)")

  #argv_parser.add_option(
    #"-r","--running",
    #action="store",type="slice",dest="running",default="0",
    #metavar="SLICE",help="CMP: Put the SLICE of strands in running mode for stepping (default=0)")

  #argv_parser.add_option(
    #"-s","--stepping",
    #action="store",type="slice",dest="stepping",default="0",
    #metavar="SLICE",help="Enable the SLICE of strands for stepping (default=0)")

  global opts
  global args

  (opts,args) = argv_parser.parse_args()


def setup(sim):
  global opts
  global args

  #for strand in eval('Slicer(sim.s)['+opts.available+']'):
    #strand.available()
  #for strand in eval('Slicer(sim.s)['+opts.enable+']'):
    #strand.enable()
  #for strand in eval('Slicer(sim.s)['+opts.running+']'):
    #strand.running()
  #for strand in eval('Slicer(sim.s)['+opts.stepping+']'):
    #strand.stepping()

  #for file in opts.file:
    #sim.mem.load(file)

  for strand in sim.s:
    strand.lstmode(opts.lstmode and 1 or 0)

  if opts.interactive or len(args) == 0:
    os.environ['PYTHONINSPECT'] = 'x'








