# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: SymbolTable.py
# Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
# 
# The above named program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License version 2 as published by the Free Software Foundation.
# 
# The above named program is distributed in the hope that it will be 
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public
# License along with this work; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
# 
# ========== Copyright Header End ============================================
"""class represents a symbol table
"""
import re
from types import *

# message header
msghead     = __name__
msghead_dbx = "DBX-" + msghead

# hexdecimal syntax
hexRE = re.compile("(\+|\-)?0[xX][0-9a-fA-F]+")


class SymbolEntry:
    """an entry in a symbol table
    """

    def __init__ (self, name, tag, va, ra, pa):
	"""constructor
	"""
	self.name = name
	self.tag = tag
	self.va = va
	self.ra = ra
	self.pa = pa


class SymbolTable:
    """class represents a symbol table
    """

    def __init__ (self):
	"""constructor
	"""
	# dictionary that uses symbol as key
	self.symTable = { }
	# dictionary that uses va as key
	self.vaTable = { }
	# dictionary that contains sorted va
	self.vaSort = { }
	# dictionary that uses pa as key
	self.paTable = { }
	# dictionary that contains sorted pa
	self.paSort = { }
	# list contains good_trap(s)' va
	self.goodTraps = [ ]


    def load (self, sfile, **parms):
	"""load a symbol table
	"""
	# throw away old values, if any.
	self.symTable = { }
	self.vaTable = { }
	self.vaSort = { }
	self.paTable = { }
	self.paSort = { }
	self.goodTraps = [ ]

	# read in symbols
	fin = open(sfile)
	for line in fin.readlines():
	    entry = self.oneLine(line)
	    if entry != None:
		self.symTable[entry.name] = entry
		self.vaTable[entry.va] = entry
		self.paTable[entry.pa] = entry
		# keep track of good_trap(s)' va
		if entry.name.find('good_trap') > -1:
		    self.goodTraps.append('%x' % (entry.va))

## 	    if not line.startswith('SYMNUM ='):
## 		tokens = line.split()
## 		if len(tokens) >= 3:
## 		    name = tokens[0]
## 		    if not self.symTable.has_key(name):
## 			# we assume the (tag, va, pa) come as (int, hex, hex), 
## 			# with hex being stripped of leading 0x, make sure that 
## 			# is the case
## 			tag = eval(tokens[1])
## 			va = eval('0x'+tokens[2])
## 			# some entries come without PA, use 0 instead
## 			try:
## 			    pa = eval('0x'+tokens[3])
## 			except:
## 			    pa = 0
## 			entry = SymbolEntry(name, tag, va, pa)
## 			self.symTable[name] = entry
## 			self.vaTable[va] = entry
## 		    else:
## 			print "%s: ERROR: duplicated symbol name %s" % (msghead, name)

	fin.close()

	# sort va table
	valist = self.vaTable.keys()
	valist.sort()
	i = 0
	for va in valist:
	    self.vaSort[i] = va
	    i += 1
	self.vaSortLast = len(self.vaSort) - 1

	# sort pa table
	palist = self.paTable.keys()
	palist.sort()
	i = 0
	for pa in palist:
	    self.paSort[i] = pa
	    i += 1
	self.paSortLast = len(self.paSort) - 1


    def oneLine (self, line):
	"""each architecture may have different symbol table format, e.g.,
	gm and ni have (slightly) different format, so the derived class can
	overwrite this method to interpreter the different input format.
	"""
	if not line.startswith('SYMNUM ='):
	    tokens = line.split()
	    if len(tokens) >= 3:
		name = tokens[0]
		if not self.symTable.has_key(name):
		    # we assume the (tag, va, pa) come as (int, hex, hex), 
		    # with hex being stripped of leading 0x, make sure that 
		    # is the case
		    tag = eval(tokens[1])
		    va = eval('0x'+tokens[2])
		    # some entries come without PA, use 0 instead
		    try:
			pa = eval('0x'+tokens[3])
		    except:
			pa = 0x0
		    entry = SymbolEntry(name, tag, va, 0x0, pa)
		    return entry
		else:
		    #print "%s: WARNING: duplicated symbol name %s" % (msghead, name)
		    pass

	# return None if line is not a valid symbol entry.
	return None


    def symbol2va (self, name):
	"""a symbol's virtual address
	"""
	try:
	    entry = self.symTable[name]
	    return entry.va
	except:
	    # if not found, return ff...
	    #print '%s: WARNING: symbol %s for VA not found' % (msghead, name)
	    #return 0xffffffffffffffff
	    return -1


    def symbol2ra (self, name):
	"""a symbol's real address
	"""
	try:
	    entry = self.symTable[name]
	    return entry.ra
	except:
	    # if not found, return ff...
	    #print '%s: WARNING: symbol %s for PA not found' % (msghead, name)
	    #return 0xffffffffffffffff
	    return -1


    def symbol2pa (self, name):
	"""a symbol's physical address
	"""
	try:
	    entry = self.symTable[name]
	    return entry.pa
	except:
	    # if not found, return ff...
	    #print '%s: WARNING: symbol %s for PA not found' % (msghead, name)
	    #return 0xffffffffffffffff
	    return -1


    def va2symbol (self, addrVA):
	"""convert va to symbol+offset
	"""
	if (type(addrVA) is IntType) or (type(addrVA) is LongType):
	    # if value already comes in as int/long, use it directly
	    addr = addrVA
	else:
	    addr = eval(str(addrVA))

	return self._searchAddrLoc(addr, 0, self.vaSortLast)


    def _searchAddrLoc (self, addr, start, end):
	"""use binary search to locate the closest symbol
	"""
	index = (start + end) / 2
	if addr < self.vaSort[index]:
	    if index > 0:
		if addr >= self.vaSort[index-1]:
		    entry = self.vaTable[self.vaSort[index-1]]
		    return self._solveAddrLoc(addr, entry)
		else:
		    start = start
		    end = index - 1
		    return self._searchAddrLoc(addr, start, end)
	    else:
		# smaller than the first entry
		return self._solveAddrLoc(addr, None)
	else:
	    if index < self.vaSortLast:
		if addr < self.vaSort[index+1]:
		    entry = self.vaTable[self.vaSort[index]]
		    return self._solveAddrLoc(addr, entry)
		else:
		    start = index + 1
		    end = end
		    return self._searchAddrLoc(addr, start, end)
	    else:
		# larger than the last entry
		entry = self.vaTable[self.vaSort[self.vaSortLast]]
		return self._solveAddrLoc(addr, entry)


    def _solveAddrLoc (self, addr, entry):
	"""construct the symbol+offset string
	"""
	if entry != None:
	    name = entry.name
	    va = entry.va
	else:
	    name = '0x0'
	    va = 0

	offset = addr - va
	if offset == 0:
	    return "%s (0x%x)" % (name, addr)
	else:
	    return "%s+0x%x (0x%x)" % (name, offset, addr)


    def pa2symbol (self, addrPA):
	"""convert pa to symbol+offset
	"""
	if (type(addrPA) is IntType) or (type(addrPA) is LongType):
	    # if value already comes in as int/long, use it directly
	    addr = addrPA
	else:
	    addr = eval(str(addrPA))

	return self._searchAddrLocPA(addr, 0, self.paSortLast)


    def _searchAddrLocPA (self, addr, start, end):
	"""use binary search to locate the closest symbol
	TODO  we can have a generic _searchAddrLoc & _solveAddrLoc, to be 
	      shared by VA and PA (and even RA)
	"""
	index = (start + end) / 2
	if addr < self.paSort[index]:
	    if index > 0:
		if addr >= self.paSort[index-1]:
		    entry = self.paTable[self.paSort[index-1]]
		    return self._solveAddrLocPA(addr, entry)
		else:
		    start = start
		    end = index - 1
		    return self._searchAddrLocPA(addr, start, end)
	    else:
		# smaller than the first entry
		return self._solveAddrLocPA(addr, None)
	else:
	    if index < self.paSortLast:
		if addr < self.paSort[index+1]:
		    entry = self.paTable[self.paSort[index]]
		    return self._solveAddrLocPA(addr, entry)
		else:
		    start = index + 1
		    end = end
		    return self._searchAddrLocPA(addr, start, end)
	    else:
		# larger than the last entry
		entry = self.paTable[self.paSort[self.paSortLast]]
		return self._solveAddrLocPA(addr, entry)


    def _solveAddrLocPA (self, addr, entry):
	"""construct the symbol+offset string
	"""
	if entry != None:
	    name = entry.name
	    pa = entry.pa
	else:
	    name = '0x0'
	    pa = 0

	offset = addr - pa
	if offset == 0:
	    return "%s (p:0x%x)" % (name, addr)
	else:
	    return "%s+0x%x (p:0x%x)" % (name, offset, addr)


    def _getSymnum (self):
	"""total number of symbol entries
	"""
	return len(self.symTable)


    def _showByName (self):
	"""show entries by symbols
	"""
	keys = self.symTable.keys()
	keys.sort()
	for key in keys:
	    entry = self.symTable[key]
	    print '%-30s \t %d  0x%016x  0x%016x' % (entry.name, entry.tag, entry.va, entry.pa)


    def isGoodTrap (self, pc):
	"""pc should be a string of hex numbers
	"""
        # strip '0x' and leading '0'
        if pc.startswith('0x') or pc.startswith('0X'):
            pc = pc[2:]
        pc = pc.lstrip('0')

        for va in self.goodTraps:
            if pc == va:
                return 1

        return 0


"""self-test
"""
if __name__ == "__main__":
    """
    """
    s = SymbolTable()
    s = s.load('/tmp/wangjc/riesling/load.map')
    s._showByName()
