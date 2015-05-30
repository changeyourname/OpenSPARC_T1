"""handle riesling frontend's '-c config' option
"""
import sys, types

OBJECT = 'OBJECT'
TYPE   = 'TYPE'
OTHER  = 'other'

PLI_SOCKET = 'pli-socket'

TYPE_NIAGARA    = 'niagara'
TYPE_SYS_CONFIG = 'sys_config'

class ReadConfigDiag:
    """handle -c config option
    """

    def __init__ (self):
	"""
	"""
	# data[objType][objId][dataType]
	self.data = { }
	# object[objId] = data[objType][objId]
	self.object = { }
	self.count = { }


    def __str__ (self):
	"""
	"""
	#buffer = [ '-----ReadConfigDiag.py-----\n' ]
	buffer = [ ]
	klist1 = self.data.keys()
	klist1.sort()
	for tkey in klist1:
	#for tkey in self.data.keys():
	    klist2 = self.data[tkey].keys()
	    klist2.sort()
	    for okey in klist2:
	    #for okey in self.data[tkey].keys():
		buffer.append('%s %s %s %s {\n' % (OBJECT, okey, TYPE, tkey))
		klist3 = self.data[tkey][okey].keys()
		klist3.sort()
		for ikey in klist3:
		    buffer.append('\t%s : %s\n' % (ikey, self.data[tkey][okey][ikey]))
		buffer.append('}\n')
	return ''.join(buffer)


    def readConfig (self, fname):
	"""
	"""
	try:
	    self.fd = open(fname, 'r')
	    line = self.fd.readline()
	    while line:
		if line.startswith(OBJECT):
		    self.readObject(line)
		else:
		    if line.strip():
			self.data[OTHER].append(line)
		# next line
		line = self.fd.readline()
	    self.fd.close()
	except IOError, (errno, strerror):
	    print "readConfig : (%s): %s %s" % (errno, strerror,fname)
        except:
	    raise 	


    def readObject (self, line):
	"""read an OBJECT description of format like:
	OBJECT th00 TYPE niagara {
	   ...
	}
	"""
	tokens = line.split()
	if (not tokens[0] == OBJECT) or (not tokens[2] == TYPE):
	    raise RuntimeError, 'ERROR: wrong format %s' % (line)
	else:
	    key = tokens[1]
	    type = tokens[3]
	    if not self.data.has_key(type):
		self.data[type] = { }
		self.count[type] = 0

	    if self.data[type].has_key(key):
		raise RuntimeError, 'ERROR: %s already defined in %s' % (key, type)
	    else:
		self.count[type] += 1
		self.data[type][key] = { }
		line = self.fd.readline()
		while line.strip() != '}':
		    if line.strip():
			i = line.find(':')
			if i > -1:
			    kword = line[:i].strip()
			    value = line[i+1:].strip()
			    self.data[type][key][kword] = value
			else:
			    # a continue data from previous line
			    self.data[type][key][kword] += ' ' + line.strip()
		    line = self.fd.readline()
		# when done with the object, create a shortcut
		self.object[key] = self.data[type][key]


    def getCount (self, type):
	"""
	"""
	if self.count.has_key(type):
	    return self.count[type]
	else:
	    return 0


    def getObjTypes (self):
	"""return a list of object types available in the configuration
	"""
	return self.data.keys()


    def getObjIds (self, objType, silent=0):
	"""return a list of object ids of the specified type
	"""
	try:
	    return self.data[objType].keys()
	except Exception, ex:
	    if not silent:
		sys.stderr.write('WARNING: ReadConfigDiag: wrong keyword (%s), ex=%s\n' % (objType, ex))
	    return []


    def getObjKeys (self, objType, objId, silent=0):
	"""return a list of data keywords of the specified object type+id
	"""
	try:
	    return self.data[objType][objId].keys()
	except Exception, ex:
	    if not silent:
		sys.stderr.write('WARNING: ReadConfigDiag: wrong keyword(s) (%s,%s), ex=%s\n' % (objType, objId, ex))
	    return []


    def getObjData (self, objType, objId, key, silent=0):
	"""return the data field of the specified object type+id+keyword
	"""
	try:
	    data = self.data[objType][objId][key]
	    if data.startswith('[') and data.endswith(']'):
		data = self.convertList(data[1:-1])
	    return data
	except Exception, ex:
	    if not silent:
		sys.stderr.write('WARNING: ReadConfigDiag: wrong keyword(s) (%s,%s,%s), ex=%s\n' % (objType, objId, key, ex))
	    return None


    def getData (self, objId, key, silent=0):
	"""return the data field of the specified object id+keyword
	"""
	try:
	    data = self.object[objId][key]
	    if data.startswith('[') and data.endswith(']'):
		data = self.convertList(data[1:-1])
	    return data
	except Exception, ex:
	    if not silent:
		sys.stderr.write('WARNING: ReadConfigDiag: wrong keyword(s) (%s,%s), ex=%s\n' % (objId, key, ex))
	    return None


    def setDataLine (self, line):
	"""
	@conf.mom0.setvar= "THREAD_BASED_STAT=1"
	@conf.swvmem0.good_trap = get_addr('\.TRAPS\.T0_GoodTrap_0x100')
                                => eval'ed value
	@conf.mom0.start_cycle= 1
	"""
	AT_CONF = '@conf.'
	SETVAR = 'setvar'
	if line.startswith(AT_CONF):
	    #sys.stderr.write('DBX: ReadConfigDiag: @conf: %s\n' % (line))
	    append = 0
	    line = line[len(AT_CONF):]
	    i = line.find('.')
	    objId = line[:i]
	    j = line.find('=+', i)
	    if j > -1:
		append = 1
	    else:
		j = line.find('=', i)
	    key = line[i+1:j].strip()
	    if key == SETVAR:
		# "key=value"
		if append == 0:
		    expr = line[j+1:].strip()
		else:
		    expr = line[j+2:].strip()
		# strip "
		expr = expr[1:-1]
		k = expr.find('=')
		key = expr[:k].strip()
		value = expr[k+1:].strip()
	    else:
		if append == 0:
		    value = line[j+1:].strip()
		else:
		    value = line[j+2:].strip()

	    self.setData(objId, key, value, append=append)

	else:
	    sys.stderr.write('WARNING: ReadConfigDiag: wrong %s syntax <%s>\n' % (AT_CONF, line))


    def setData (self, objId, key, value, append=0):
	"""
	"""
	#sys.stderr.write('DBX: ReadConfigDiag: objId=%s, key=%s, value=%s, append=%s\n' % (objId, key, value, append))

	if not self.object.has_key(objId):
	    # OBJECT config0 TYPE sys_config {
	    #   # a default system config to store basic system config info
	    # }
	    if not self.data.has_key(TYPE_SYS_CONFIG):
		self.data[TYPE_SYS_CONFIG] = { }
		self.count[TYPE_SYS_CONFIG] = 0

	    self.count[TYPE_SYS_CONFIG] += 1
	    self.data[TYPE_SYS_CONFIG][objId] = { }
	    self.object[objId] = self.data[TYPE_SYS_CONFIG][objId]

	try:
	    if self.object[objId].has_key(key) and append == 0:
		sys.stderr.write('WARNING: ReadConfigDiag: overwrite (%s,%s)=%s, new value=%s\n' % (objId, key, self.object[objId][key], value))
	    if append == 0:
		self.object[objId][key] = value
	    else:
		if not self.object[objId].has_key(key):
		    self.object[objId][key] = [ ]
		self.object[objId][key].append(value)
	except Exception, ex:
	    sys.stderr.write('WARNING: ReadConfigDiag: wrong keyword(s) (%s,%s), ex=%s\n' % (objId, key, ex))


    def convertList(self, data):
	"""convert string (of list syntax) to real list
	"""
	#sys.stderr.write('#DBX: data=%s\n' % (data)) #DBX
	tokens = data.split(',')
	datalist = []
	for token in tokens:
	    token = token.strip().strip("'")
	    #sys.stderr.write('#DBX: token=%s\n' % (token)) #DBX
	    datalist.append(token)
	    #sys.stderr.write('#DBX: datalist=%s\n' % (datalist)) #DBX
	return datalist


"""self-testing
"""
if __name__ == "__main__":
    """
    """
    # unit test here
    import sys
    reader = ReadConfigDiag()
    reader.readConfig(sys.argv[1])
    print reader
