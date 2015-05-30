"""repository for focus object, breakpoints, watchpoints, etc.
"""

# message header
msghead     = __name__
msghead_dbx = "DBX-" + msghead


# a global id counter to generate unique ids for watchpoints, breakpoints,
# etc. Use Repository.nextid() to receive the next available id.
__objectid = 0

def nextid():
    """function used to generate a unique id for watchpoints, breakpoints, etc.
    """
    global __objectid
    __objectid += 1
    return str(__objectid)


class Repository:
    """class that serves as repository for shared data
    """

    def __init__ (self):
	"""
	globals - top level globals(), so that we can eval() expression in
                  other places as they are at top level.
	"""
	self.console = None
	self.topName = None
	self.globals = None
	self.riesling = None
	self.fldTable = None
	self.modTable = None
	self.cmdTable = None
	self.symTable = None
	self.memLoad = None

	#self.cycle = 0L
	# the current focus module, in original string
	self.focusSrc = None
	# the corresponding riesling backend module
	self.focus = None
	self.groups = { }
	self.breakpoints = { }
	self.watchpoints = { }
	self.cmdAlias = { }
	# 1 means in rioesling interpreter mode, otherwise in normal python
	# mode
	self.imode = 0
	# 1 means output message will be printed
	self.echo = 1

	# arch config
	self.ncpus = 0
	self.ncores = 0
	self.nucores = 0
	self.nstrands = 0
	# pointer (as uint64_t) to backend system object
	self.sysAddr = 0L
	self.optdir = None
	# fp values
	self.nSpregs = 0
	self.nDpregs = 0
	self.nQpregs = 0
	# array to cpu/core/strand objects
	self.cpus = None
	self.cores = None
	self.ucores = None
	self.strands = None
	self.riesLib = None
	self.socketAPI = None
	self.prompt = 'NA'
	# used in sam mode to indicate whether blaze is running or not,
	# blaze must be in 'stop" mode when conduct breakpoint operaiton.
	# this variable remains as 0 when not in sam mode.
	self.running = 0
	# keep track of blaze numcpu and corresponding pmask
	self.blazeNumcpu = 1
	self.pmask = 0x1L


    def addBreakpoint (self, breakpoint):
	"""
	"""
	if self.breakpoints.has_key(breakpoint.id):
	    raise KeyError, "duplicated breakpoint id %d" % breakpoint.id

	self.breakpoints[breakpoint.id] = breakpoint


    def deleteBreakpoint (self, id):
	"""
	"""
	idstr = str(id)
	if self.breakpoints.has_key(idstr):
	    del self.breakpoints[idstr]
	else:
	    raise KeyError, "does not have breakpoint with id=%s" % idstr


    def showBreakpoint (self, focus=None):
	"""
	"""
	ids = self.breakpoints.keys()
	ids.sort()
	result = [ ]
	for id in ids:
	    bpoint = self.breakpoints[id]
	    if (focus == None) or (focus == bpoint.modSrc):
		result.append("id=%s, mod=%s, cmd='%s', action=%s" % (bpoint.id, bpoint.modSrc, bpoint.src, bpoint.action))

	return '\n'.join(result)


    def addWatchpoint (self, watchpoint):
	"""
	"""
	if self.watchpoints.has_key(watchpoint.id):
	    raise KeyError, "duplicated watchpoint id %d" % watchpoint.id

	self.watchpoints[watchpoint.id] = watchpoint


    def showWatchpoint (self):
	"""
	"""
	ids = self.watchpoints.keys()
	ids.sort()
	result = [ ]
	for id in ids:
	    wpoint = self.watchpoints[id]
	    result.append("id=%s, disable=%d, cmd='%s', watch='%s', action=%s" % (wpoint.id, wpoint.disable, wpoint.src, wpoint.watch, wpoint.action))
	    result.append("DBX: id=%s, watchExpr=%s" % (wpoint.id, wpoint.watchExpr))   #dbx
	return '\n'.join(result)


"""self-testing
"""
if __name__ == "__main__":
    pass
