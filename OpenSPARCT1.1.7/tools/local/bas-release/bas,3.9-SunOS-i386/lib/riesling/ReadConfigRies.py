"""handle riesling frontend's '-x config' option
"""

import re

PROMPT       = '@SIM_set_prompt'
DIAG_CONF    = 'read-configuration'
MEM_IMAGE    = 'load-veri-file'
IGNORE_SPARC = 'ignore_sparc'
AT_DEF       = '@def'
CMD          = 'cmd'
NEW_CMD      = '@new_command'
AT_CONF      = '@conf'


class ReadConfigRies:
    """handle -x config option
    """

    def __init__ (self):
	"""
	"""
	self.data = { }
	self.data[PROMPT] = ''
	self.data[DIAG_CONF] = ''
	self.data[MEM_IMAGE] = ''
	self.data[AT_DEF] = { }
	self.data[CMD] = [ ]
	self.data[IGNORE_SPARC] = [ ]
	self.data[NEW_CMD] = { }
	self.data[AT_CONF] = [ ]

	self.initKeyword()


    def __str__ (self):
	"""
	"""
	buffer = [ '-----ReadConfigRies.py-----\n' ]
	buffer.append('%s = %s\n' % (PROMPT, self.data[PROMPT]))
	buffer.append('%s = %s\n' % (DIAG_CONF, self.data[DIAG_CONF]))
	buffer.append('%s = %s\n' % (MEM_IMAGE, self.data[MEM_IMAGE]))
	buffer.append('%s = %s\n' % (IGNORE_SPARC, self.data[IGNORE_SPARC]))
	buffer.append('---%s---\n' % (AT_DEF))
	for key in self.data[AT_DEF].keys():
	    buffer.append(''.join(self.data[AT_DEF][key]))
	buffer.append('---%s---\n' % (NEW_CMD))
	for key in self.data[NEW_CMD].keys():
	    buffer.append(''.join(self.data[NEW_CMD][key]))
	buffer.append('---%s---\n' % (CMD))
	buffer.append(''.join(self.data[CMD]))
	
	return ''.join(buffer)


    def initKeyword (self):
	"""
	"""
	self.keywords = { }
	self.keywords[re.compile('^@num_processors')] = self.ignore
	self.keywords[re.compile('^\$sim_no_magic_breakpoint')] = self.ignore
	self.keywords[re.compile('^@SIM_set_prompt')] = self.handlePrompt
	self.keywords[re.compile('^//')] = self.ignore
	self.keywords[re.compile('^read-configuration')] = self.handleReadConfig
	self.keywords[re.compile('^load-kernel')] = self.handleLoadMem
	self.keywords[re.compile('^load-veri-file')] = self.handleLoadMem
	self.keywords[re.compile('^@init_swerver')] = self.ignore
	self.keywords[re.compile('^ciop\d+\.cmd')] = self.ignore
	self.keywords[re.compile('^ciop\d+\.setvar')] = self.ignore
	self.keywords[re.compile('^pdisable')] = self.handlePdisable
	#self.keywords[re.compile('^@conf\.spu\d+\.spu_ignore_asi_check')] = self.ignore
	self.keywords[re.compile('^@?def\s+')] = self.handleAtDef
	self.keywords[re.compile('^@?new_command\s*\(')] = self.handleNewcmd
	#self.keywords[re.compile('^@conf\.mom\d+\.setvar')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.call')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.thread_status')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.PASS')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.FAIL')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.HPASS')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.HFAIL')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.DC_ON')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.DC_OFF')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.IC_ON')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.IC_OFF')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.APASS')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.AFAIL')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.start_cycle')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.reset_all_stat')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.T1PASS')] = self.ignore
	#self.keywords[re.compile('^@conf\.mom\d+\.T1FAIL')] = self.ignore
	self.keywords[re.compile('^run')] = self.handleRun
	self.keywords[re.compile('^quit')] = self.handleQuit
	#self.keywords[re.compile('^@conf\.swvmem\d+\.ignore_sparc')] = self.handleIgnoreSparc
	#self.keywords[re.compile('^@conf\.swvmem\d+\.printf')] = self.ignore
	#self.keywords[re.compile('^@conf\.swvmem\d+\.thread_status')] = self.ignore
	self.keywords[re.compile('^th\d+\.write-reg')] = self.handleWriteReg
	self.keywords[re.compile('^th\d+\.read-reg')] = self.handleReadReg
	#self.keywords[re.compile('^@conf\.swvmem\d+\.good_trap')] = self.handleTrap
	#self.keywords[re.compile('^@conf\.swvmem\d+\.bad_trap')] = self.handleTrap
	#self.keywords[re.compile('^@conf\.swvmem\d+\.max_cycle')] = self.ignore
	self.keywords[re.compile('^pli-run')] = self.handlePlirun
	self.keywords[re.compile('^@.*riesling\.sys\.')] = self.handleRiesling
	self.keywords[re.compile('^@conf\.')] = self.handleAtConf

	self.klist = self.keywords.keys()


    def ignore (self, line):
	"""
	"""
	self.fdtmp.write(line)
	return None


    def arbitrary (self, line):
	"""
	"""
	# even though we may not know what to do with this line, we will
	# try to execute it, and ignore any exception it may raise.
	if line.startswith('@'):
	    line = line[1:]
	self.data[CMD].append(line)
	return None


    def handlePrompt (self, line):
	"""
	"""
	lindex = line.find('"')
	rindex = line.find('"', lindex+1)
	self.data[PROMPT] = line[lindex+1:rindex]
	return None


    def handleReadConfig (self, line):
	"""
	"""
	lindex = line.find('"')
	rindex = line.find('"', lindex+1)
	self.data[DIAG_CONF] = line[lindex+1:rindex]
	return None


    def handleLoadMem (self, line):
	"""
	"""
	self.data[MEM_IMAGE] = line.split()[1]
	return None


    def handlePdisable (self, line):
	"""
	"""
	self.data[CMD].append(line)
	return None


    def handleAtDef (self, line):
	"""
	"""
	# @def get_addr(name):
	# def get_addr(name):
	if line.startswith('@'):
	    line = line[1:]
	tokens = line.split()
	index = tokens[1].find('(')
	fname = tokens[1][:index].strip()
	if self.data[AT_DEF].has_key(fname):
	    raise RuntimeError, 'function %s is already defined' % (fname)
	else:
	    self.data[AT_DEF][fname] = [ line ]
	    line = self.fd.readline()
	    # process until encounter a line starting with non-blank char
	    # at the 1st column
	    while re.match('^\s', line):
		self.data[AT_DEF][fname].append(line)
		line = self.fd.readline()

	return line


    def handleNewcmd (self, line):
	"""
	"""
	# @new_command(...)
	# new_command(...)
	if line.startswith('@'):
	    line = line[1:]
	lindex = line.find('"')
	rindex = line.find('"', lindex+1)
	cmd = line[lindex+1:rindex]
	if self.data[NEW_CMD].has_key(cmd):
	    raise RuntimeError, 'command %s is already defined' % (cmd)
	else:
	    self.data[NEW_CMD][cmd] = [ line ]
	    line = self.fd.readline()
	    while line.strip():
		self.data[NEW_CMD][cmd].append(line)
		line = self.fd.readline()
	return None


    def handleRun (self, line):
	"""
	"""
	self.data[CMD].append(line)
	return None


    def handleQuit (self, line):
	"""
	"""
	self.data[CMD].append(line)
	return None


    def handleIgnoreSparc (self, line):
	"""
	@conf.swvmem0.ignore_sparc = 0
	"""
	i = line.find('=')
	id = line[i+1:].split()[0]
	self.data[IGNORE_SPARC].append(id)
	return None


    def handleThreadMask (self, line):
	"""
	# @conf.swvmem0.thread_mask0 = THREAD_MASK
	# @conf.swvmem0.thread_mask1 = THREAD_MASK1
	
	use THREAD_MASK to produce THREADS and SPx (for IGNORE_SPARC)
	"""
	MAX_CORE = 8

	ii = line.find('thread_mask') + len('thread_mask')
	cpu = int(line[ii:ii+1])
	tokens = line.replace('=', ' ').split()
	tokens[1] = tokens[1].lower()
	if tokens[1].startswith('0x'):
	    tokens[1] = tokens[1][2:]
	# make sure we have even number of characters, for ease process.
	if len(tokens[1])%2 != 0:
	    if tokens[1][0] == 'x':
		tokens[1] = 'x' + tokens[1]
	    else:
		tokens[1] = '0' + tokens[1]

	# produce IGNORE_SPARC
	# thread_mask = 00xx11xx, each core is presented by two characters
	# (8 bits, one for each strand). A 'xx' mean this core should be
	# disabled, a 'not-mentioned' core is also disabled, otherwise it is 
	# enabled.
	for i in range(MAX_CORE):
	    if ((2*(i+1) > len(tokens[1])) or
		(tokens[1][(-2*i)-1] == 'x' and tokens[1][(-2*i)-2] == 'x')):
		coreid = i + (cpu * MAX_CORE)
		self.data[IGNORE_SPARC].append(coreid)
		self.data[AT_CONF].append('@conf.swvmem0.ignore_sparc =+ %d' % (coreid))
	    if (2*i < len(tokens[1])):
		if (tokens[1][2*i] == 'x') and (tokens[1][(2*i)+1] != 'x'):
		    if i == 0:
			tokens[1] = '0' + tokens[1][1:]
		    else:
			tokens[1] = tokens[1][:2*i] + '0' + tokens[1][(2*i)+1:]
		elif (tokens[1][2*i] != 'x') and (tokens[1][(2*i)+1] == 'x'):
		    if 2*(i+1) >= len(tokens[1]):
			tokens[1] = tokens[1][:-1] + '0'
		    else:
			tokens[1] = tokens[1][:(2*i)+1] + '0' + tokens[1][2*(i+1):]
		
	# produce THREADS
	self.data[AT_CONF].append('@conf.swvmem0.threads%d = %s' % (cpu, tokens[1].replace('x', '0')))

	# we don't really use thread_mask to set CMP registers, instead we
	# use the threads and ignore_sparc produced by thread_mask to do that.
	# this is mainly for backward compatibility.

	# keep the revised line to be added to list
	line = ' = '.join(tokens)

	return line


    def handleWriteReg (self, line):
	"""
	th00.write-reg reg-name = ccr 0x00
	"""
	# just to make sure there are space before/after the = sign
	tokens = line.replace('=', ' = ').split()
	cmd = '%s %s %s\n' % (tokens[0], tokens[3], tokens[4])
	self.data[CMD].append(cmd)
	return None


    def handleReadReg (self, line):
	"""
	th00.read-reg reg-name = ccr
	"""
	# just to make sure there are space before/after the = sign
	tokens = line.replace('=', ' = ').split()
	cmd = '%s %s\n' % (tokens[0], tokens[3])
	self.data[CMD].append(cmd)
	return None


    def handleTrap (self, line):
	"""
	@conf.swvmem0.good_trap = get_addr('\.HTRAPS\.HT0_GoodTrap_0x100')
	@conf.swvmem0.bad_trap = get_addr('\.TRAPS\.T0_BadTrap_0x101')
	"""
	lindex = line.find('get_addr')
	lindex = line.find("'", lindex)
	rindex = line.find("'", lindex+1)
	symbol = line[lindex+1:rindex]
	symbol = symbol.replace('\\', '')
	# convert it into a break command
	cmd = 'break &%s' % (symbol)
	self.data[CMD].append(cmd)
	return None


    def handlePlirun (self, line):
	"""
	"""
	self.data[CMD].append(line)
	return None


    def handleRiesling (self, line):
	"""allow riesling frontend native calls in configuration file
	@riesling.sys.frontend-native-call, e.g.,
	@riesling.sys.cpu0.core0.strand0.archstate.getPc()
	"""
	self.data[CMD].append(line[1:])
	return None


    def handleAtConf (self, line):
	"""
	"""
	if line.find('ignore_sparc') > -1:
	    self.handleIgnoreSparc(line)
	elif line.find('good_trap') > -1 or line.find('bad_trap') > -1:
	    self.handleTrap(line)
	elif line.startswith('@conf.swvmem0.thread_mask'):
	    # @conf.swvmem0.thread_mask = THREAD_MASK
	    line = self.handleThreadMask(line)
## 	elif line.startswith('@conf.swvmem0.cpu'):
## 	    # @conf.swvmem0.cpu = 1
## 	    tokens = line.replace('=', ' ').split()
## 	    cpu = int(tokens[1])
## 	    if cpu < 1:
## 		cpu = 1
## 	    elif cpu > 4:
## 		cpu = 4
## 	    tokens[1] = str(cpu)
## 	    line = ' = '.join(tokens)

	# keep all @conf.zzz statements in AT_CONF
	self.data[AT_CONF].append(line)
	
	# @conf.mom0's, which is used by blaze/mom, can mix with other 
	# commands, e.g.,
	#     @conf.mom0.call= "init-anno-sas"
	#     @conf.mom0.setvar= "itlb0_size_v=0"
	#     @conf.mom0.PASS= get_addr('\.TRAPS\.T0_GoodTrap_0x100')
	#     @conf.mom0.thread_status= THREAD_STATUS_ADDR
	#     @conf.mom0.start_cycle= 1
	#     run 200
	#     @conf.mom0.reset_all_stat= 1
	# their execution order is important, so we have to keep @conf.mom0
	# as part of CMD, blaze use 'mom setvar' as keyword
	CONF_MOM = '@conf.mom0.'
	CONF_MOM_SET = '@conf.mom0.setvar'
	sline = line.strip()
	if sline.startswith(CONF_MOM):
	    sline = sline[len(CONF_MOM):]
	    sline = sline.replace('=', ' ').replace('"', ' ')
	    tokens = sline.split()
	    cmd = 'mom %s\n' % (' '.join(tokens))
	    self.data[CMD].append(cmd)
	return None

## 	CONF_MOM = '@conf.mom0.'
## 	CONF_MOM_SET = '@conf.mom0.setvar'
## 	sline = line.strip()
## 	if sline.startswith(CONF_MOM):
## 	    if sline.startswith(CONF_MOM_SET):
## 		lindex = sline.find('"')
## 		rindex = sline.find('"', lindex+1)
## 		setcmd = sline[lindex+1:rindex]
## 	    else:
## 		setcmd = sline[len(CONF_MOM):]

## 	    index = setcmd.find('=')
## 	    lop = setcmd[0:index].strip()
## 	    rop = setcmd[index+1:].strip()
## 	    cmd = 'mom setvar %s %s\n' % (lop, rop)
## 	    self.data[CMD].append(cmd)
## 	return None


    def readConfig (self, fname):
	"""
	"""
	try:
	    TMP = '.rs_config_ignore'
	    self.fdtmp = open(TMP, 'w')
	    self.fd = open(fname, 'r')
	    line = self.fd.readline()
	    while line:
		sline = line.strip()
		rline = None
		if sline:
		    match = 0
		    for key in self.klist:
			if key.match(sline):
			    rline = self.keywords[key](line)
			    match = 1
			    break   # out of for loop
		    if match == 0:
			# if cannot find a match, handle it as arbitrary
			# statement
			self.arbitrary(line)
			
		# next line
		if rline != None:
		    line = rline
		else:
		    line = self.fd.readline()

	    self.fdtmp.close()
	    self.fd.close()
	except:
	    raise


"""self-testing
"""
if __name__ == "__main__":
    """
    """
    # unit test here
    import sys
    reader = ReadConfigRies()
    reader.readConfig(sys.argv[1])
    print reader
