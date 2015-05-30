"""class represents a symbol table
"""
from base import SymbolTable

# message header
msghead     = __name__
msghead_dbx = "DBX-" + msghead

class NiSymbolTable (SymbolTable.SymbolTable):
    """class represents a symbol table
    """

    def __init__ (self):
	"""constructor
	"""
	SymbolTable.SymbolTable.__init__(self)
	self.traps = { }


    def oneLine (self, line):
	"""each architecture may have different symbol table format, e.g.,
	gm and ni have (slightly) different format, so the derived class can
	overwrite this method to interpreter the different input format.

	.HTRAPS.good_trap	0000000000082000 X 0000082000
	.TRAPS.good_trap	0000000000122000 0000122000 1000122000
	"""
	tokens = line.split()
	# NI format: symbol va ? ?
	name = tokens[0]
	if not self.symTable.has_key(name):
	    # we assume the (tag, va, pa) come as (int, hex, hex), 
	    # with hex being stripped of leading 0x, make sure that 
	    # is the case. We ignore the pa part and use 0xff...
	    va = eval('0x'+tokens[1])
	    try:
		if (tokens[2].lower() != 'x'):
		    ra = eval('0x'+tokens[2])
		else:
		    ra = 0x0
	    except:
		ra = 0x0
	    try:
		pa = eval('0x'+tokens[3])
	    except:
		pa = 0x0
	    entry = SymbolTable.SymbolEntry(name, -1, va, ra, pa)
	    # look for good_trap and bad_trap
	    if name.endswith('good_trap') or name.endswith('bad_trap'):
		self.traps[name] = va
	    return entry
	else:
	    #print "%s: ERROR: duplicated symbol name %s" % (msghead, name)
	    pass

	# return None if line is not a valid symbol entry.
	return None


    def getTraps(self):
	""" return the list of good_trap and bad_trap
	"""
	trapList = [ ]
	for trap in self.traps.keys():
	    trapList.append((trap,self.traps[trap]))
	return trapList


"""self-test
"""
if __name__ == "__main__":
    """
    """
    s = NiSymbolTable()
    s.load('./symbol.tbl')
    s._showByName()
    print '.RED_SEC.RESERVED_0 = %s' % (s.va2symbol(s.symbol2va('.RED_SEC.RESERVED_0')))
    print '.HTRAPS.HT0_Illegal_Instruction_0x10 + 0x4 = %s' % (s.va2symbol(0x0000000000080200+0x4))
