"""Utilities needed to emulate Python's interactive interpreter.
"""
#
# copied from RiesCode.py, for cosim & sam environment
#

import os, re, string, sys, time, types

from Pfe_Assembler import *

import traceback
from codeop import CommandCompiler, compile_command

__all__ = ["InteractiveInterpreter", "InteractiveConsole", "interact",
           "compile_command"]

# constants
PLI_RUN         = 'pli-run'
QUIT            = 'quit'
RUN_PYTHON_FILE = 'run-python-file'

DONE     = 1
DONE_NOT = 0

# when 1, ignore any exception associated with a wrong python statement
IGNORE_EXCEPT = 0

SIM = 'sim'
RSYS   = 'rsys'
CPU    = 'cpu'
CORE   = 'core'
UCORE  = 'ucore'
STRAND = 'strand'

# regular expression used to catch execfile() command
execfileRE = re.compile("^execfile(\s)*\([^\(\)]+\)$")
NEW_CMD_RE = re.compile('^@?new_command\s*\(')
DIGITAL_RE = re.compile('^[0-9]+$')

RC_SYS_CONFIG_OBJ = 'config0'
RC_PROMPT         = 'prompt'
RC_MEM_IMAGE      = 'mem_image'
RC_COMMAND        = 'command'
RC_COMMAND_EXT    = 'command_ext'
RC_FUNC_DEF       = 'func_def'


def softspace(file, newvalue):
    oldvalue = 0
    try:
        oldvalue = file.softspace
    except AttributeError:
        pass
    try:
        file.softspace = newvalue
    except (AttributeError, TypeError):
        # "attribute-less object" or "read-only attributes"
        pass
    return oldvalue

class InteractiveInterpreter:
    """Base class for InteractiveConsole.

    This class deals with parsing and interpreter state (the user's
    namespace); it doesn't deal with input buffering or prompting or
    input file naming (the filename is always passed in explicitly).

    """

    def __init__(self, locals=None):
        """Constructor.

        The optional 'locals' argument specifies the dictionary in
        which code will be executed; it defaults to a newly created
        dictionary with key "__name__" set to "__console__" and key
        "__doc__" set to None.

        """
        if locals is None:
            locals = {"__name__": "__console__", "__doc__": None}
        self.locals = locals
        self.compile = CommandCompiler()

    def runsource(self, source, filename="<input>", symbol="single"):
        """Compile and run some source in the interpreter.

        Arguments are as for compile_command().

        One several things can happen:

        1) The input is incorrect; compile_command() raised an
        exception (SyntaxError or OverflowError).  A syntax traceback
        will be printed by calling the showsyntaxerror() method.

        2) The input is incomplete, and more input is required;
        compile_command() returned None.  Nothing happens.

        3) The input is complete; compile_command() returned a code
        object.  The code is executed by calling self.runcode() (which
        also handles run-time exceptions, except for SystemExit).

        The return value is 1 in case 2, 0 in the other cases (unless
        an exception is raised).  The return value can be used to
        decide whether to use sys.ps1 or sys.ps2 to prompt the next
        line.

        """
	global IGNORE_EXCEPT

        try:
            code = self.compile(source, filename, symbol)
        except (OverflowError, SyntaxError, ValueError):
            # Case 1
	    if IGNORE_EXCEPT != 1:
		self.showsyntaxerror(filename)
	    else:
		raise
            return 0

        if code is None:
            # Case 2
            return 1

        # Case 3
        self.runcode(code)
        return 0

    def runcode(self, code):
        """Execute a code object.

        When an exception occurs, self.showtraceback() is called to
        display a traceback.  All exceptions are caught except
        SystemExit, which is reraised.

        A note about KeyboardInterrupt: this exception may occur
        elsewhere in this code, and may not always be caught.  The
        caller should be prepared to deal with it.

        """
	global IGNORE_EXCEPT

        try:
            exec code in self.locals
        except SystemExit:
	    sys.stderr.write("# %s: end riesling frontend\n" % (time.ctime()))
            raise
## 	except AttributeError:
## 	    raise
        except:
	    if IGNORE_EXCEPT != 1:
		self.showtraceback()
	    else:
		raise
        else:
            if softspace(sys.stdout, 0):
                print

    def showsyntaxerror(self, filename=None):
        """Display the syntax error that just occurred.

        This doesn't display a stack trace because there isn't one.

        If a filename is given, it is stuffed in the exception instead
        of what was there before (because Python's parser always uses
        "<string>" when reading from a string).

        The output is written by self.write(), below.

        """
        type, value, sys.last_traceback = sys.exc_info()
        sys.last_type = type
        sys.last_value = value
        if filename and type is SyntaxError:
            # Work hard to stuff the correct filename in the exception
            try:
                msg, (dummy_filename, lineno, offset, line) = value
            except:
                # Not the format we expect; leave it alone
                pass
            else:
                # Stuff in the right filename
                try:
                    # Assume SyntaxError is a class exception
                    value = SyntaxError(msg, (filename, lineno, offset, line))
                except:
                    # If that failed, assume SyntaxError is a string
                    value = msg, (filename, lineno, offset, line)
                sys.last_value = value
        list = traceback.format_exception_only(type, value)
        map(self.write, list)

    def showtraceback(self):
        """Display the exception that just occurred.

        We remove the first stack item because it is our own code.

        The output is written by self.write(), below.

        """
        try:
            type, value, tb = sys.exc_info()
            sys.last_type = type
            sys.last_value = value
            sys.last_traceback = tb
            tblist = traceback.extract_tb(tb)
            del tblist[:1]
            list = traceback.format_list(tblist)
            if list:
                list.insert(0, "Traceback (most recent call last):\n")
            list[len(list):] = traceback.format_exception_only(type, value)
        finally:
            tblist = tb = None
        map(self.write, list)

    def write(self, data):
        """Write a string.

        The base implementation writes to sys.stderr; a subclass may
        replace this with a different implementation.

        """
        sys.stderr.write(data)


class InteractiveConsole(InteractiveInterpreter):
    """Closely emulate the behavior of the interactive Python interpreter.

    This class builds on InteractiveInterpreter and adds prompting
    using the familiar sys.ps1 and sys.ps2, and input buffering.

    """

    def __init__(self, locals=None, filename="<console>"):
        """Constructor.

        The optional locals argument will be passed to the
        InteractiveInterpreter base class.

        The optional filename argument should specify the (file)name
        of the input stream; it will show up in tracebacks.

        """
        InteractiveInterpreter.__init__(self, locals)
        self.filename = filename
        self.resetbuffer()

    def resetbuffer(self):
        """Reset the input buffer."""
        self.buffer = []

    def interact(self, banner=None, **parms):
        """Closely emulate the interactive Python console.

        The optional banner argument specify the banner to print
        before the first interaction; by default it prints a banner
        similar to the one printed by the real Python interpreter,
        followed by the current class name in parentheses (so as not
        to confuse this with the real interpreter -- since it's so
        close!).

        """
	global optdir
	global rcCmd

	#sys.stderr.write("#DBX %s: enter InteractiveConsole.interact()\n" % (time.ctime()))

	# connect to command parser
	self.parser = parms['parser']

	# if there are good_trap and/or bad_trap in symbol file, register
	# those as breakpoints
	# TODO  by default, no breakpoint for good/bad_trap is set in sam,
	#       we need an option to allow setting of those breakpoints.
	if parms['reposit'].symTable and not optdir.has_key('--blaze'):
	    trapList = parms['reposit'].symTable.getTraps()
	    for (trap,vaddr) in trapList:
		cmd = 'break %#x' % (vaddr)
		if self.parser.parseCmd(cmd, **parms):
		    sys.stderr.write('ERROR: un-expected return value from parseCmd()\n')

	# if there are command(s) specified in config, execute those first
	_configRC = None
	if parms.has_key('confRC'):
	    _configRC = parms['confRC']

	tmp = '.rs_config_cmd'
	fdtmp = open(tmp, 'w')
	if _configRC:
	    if _configRC.getObjData(ReadConfigDiag.TYPE_SYS_CONFIG, RC_SYS_CONFIG_OBJ, RC_COMMAND, silent=1):
		#sys.stderr.write("# %s: process config/init cmd\n" % (time.ctime()))
		for cmd in _configRC.getObjData(ReadConfigDiag.TYPE_SYS_CONFIG, RC_SYS_CONFIG_OBJ, RC_COMMAND):
		    cmd = cmd.strip()
		    # if get_addr() is part of the command, better resolve
		    # that here, so we don't need to worry about that later
		    # when execute the command
		    index = cmd.find('get_addr')
		    if index > -1:
			lop = cmd[:index]
			rop = cmd[index:]
			try:
			    cmd = '%s%s' % (lop, eval(rop))
			except:
			    pass
		    fdtmp.write('%s\n' % (cmd))

	for cmd in rcCmd:
	    fdtmp.write('%s\n' % (cmd))

	fdtmp.close()
	# execute the commands specified in config file, if a command
	# cannot be run, just ignore it.
	self.parseExecfile('execfile("%s")' % (tmp), ignore=1, **parms)
	#sys.stderr.write("# %s: DBX: done config/init cmd\n" % (time.ctime()))

	# set prompt symbol
	prompt = _configRC.getObjData(ReadConfigDiag.TYPE_SYS_CONFIG, RC_SYS_CONFIG_OBJ, RC_PROMPT)
	parms['reposit'].prompt = prompt
        try:
            sys.ps1
        except AttributeError:
            sys.ps1 = "%s>>> " % (prompt)
        try:
            sys.ps2
        except AttributeError:
            sys.ps2 = "%s... " % (prompt)

        cprt = 'Type "copyright", "credits" or "license" for more information.'
        if banner is None:
            self.write("Python %s on %s\n%s\n(%s)\n" %
                       (sys.version, sys.platform, cprt,
                        self.__class__.__name__))
        else:
            self.write("# %s: %s\n" % (time.ctime(), str(banner)))

        more = 0
        while 1:
            try:
                if more:
                    prompt = sys.ps2
                else:
                    prompt = sys.ps1
                try:
                    line = self.raw_input(prompt)
                except EOFError:
                    self.write("\n")
                    break
                else:
		    line = self.parser.parseCmd(line, **parms)
		    if line != None:
			# most excepts are handled by push() and its inner
			# methods, so we won't see them here.
			if re.match(execfileRE, line):
			    try:
				more = self.parseExecfile(line, **parms)
			    except SystemExit:
				raise
			    except:
				more = self.push(line)
			else:
			    more = self.push(line)
		    else:
			# to play it safe, flush out buffer when parser returns
			# None
			self.resetbuffer()
			more = 0

            except KeyboardInterrupt:
                self.write("\nKeyboardInterrupt\n")
                self.resetbuffer()
                more = 0

    def push(self, line):
        """Push a line to the interpreter.

        The line should not have a trailing newline; it may have
        internal newlines.  The line is appended to a buffer and the
        interpreter's runsource() method is called with the
        concatenated contents of the buffer as source.  If this
        indicates that the command was executed or invalid, the buffer
        is reset; otherwise, the command is incomplete, and the buffer
        is left as it was after the line was appended.  The return
        value is 1 if more input is required, 0 if the line was dealt
        with in some way (this is the same as runsource()).

        """
        self.buffer.append(line)
        source = "\n".join(self.buffer)
        more = self.runsource(source, self.filename)
        if not more:
            self.resetbuffer()
        return more

    def raw_input(self, prompt=""):
        """Write a prompt and read a line.

        The returned line does not include the trailing newline.
        When the user enters the EOF key sequence, EOFError is raised.

        The base implementation uses the built-in function
        raw_input(); a subclass may replace this with a different
        implementation.

        """
        #return raw_input(prompt)
	line = raw_input(prompt)
	if re.match(NEW_CMD_RE, line):
	    if line.startswith('@'):
		line = line[1:]
	    newlist = [ line ]
	    if not line.strip().endswith(')'):
		line = raw_input(prompt)
		while line.strip() and not line.strip().endswith(')'):
		    newlist.append(line)
		    line = raw_input(prompt)
		# remember to include the last line ending with ')'
		newlist.append(line)
	    return ' '.join(newlist)
	else:
	    return line


    def parseExecfile (self, cmdLine, ignore=0, **parms):
	"""execfile() bypasses riesling cmd parser by default, so we have
	to intercept the execfile() command, and process its content line
	by line.
	"""
	global IGNORE_EXCEPT

	current_ignore_except = IGNORE_EXCEPT
	IGNORE_EXCEPT = ignore

	try:
	    self._parseExecfile(cmdLine, ignore=ignore, **parms)
	except SystemExit:
	    self.resetbuffer()
	    raise
	except Exception, ex:
	    self.resetbuffer()
	    if ignore == 0:
		raise
	    else:
		#sys.stderr.write('DBX: RiesCodeN2::parseExecfile: ignore <%s>, ex=%s\n' % (cmdLine, ex))
		pass

	IGNORE_EXCEPT = current_ignore_except


    def _parseExecfile (self, cmdLine, ignore=0, **parms):
	"""execfile() bypasses riesling cmd parser by default, so we have
	to intercept the execfile() command, and process its content line
	by line.
	"""
	global parser

	# the cmdLine is expected to be in the format of "execfile('zzz')"
	lindex = cmdLine.find('(')
	rindex = cmdLine.find(')')
	filename = eval(cmdLine[lindex+1:rindex].strip())

	fin = open(filename)
	lineBuffer = [ ]
	for line in fin.readlines():
	    if line and line.startswith('def '):
		# a new function definition
		# CmdParserNi::registerDoc (self, key, fname, type, shortdoc, longdoc)
		defline = line.strip()
		ii = defline.rfind(':')
		if ii > -1:
		    defline = defline[4:ii].strip()
		defkey = defline
		jj = defkey.find('(')
		if jj > -1:
		    defkey = defkey[:jj].strip()
		parser.registerDoc(defkey, defline, '@DEF', filename+' : @def '+defline, None)
	    # continue reading & concatenating line(s) until a complete
	    # expression is formed. Remember to remove trailing newline
	    if line[-1] == '\n':
		line = line[:-1]

	    if (line != '') and (line[-1] == "\\"):
		# exclude the trailing "\"
		lineBuffer.append(line[:-1])
	    else:
		if len(lineBuffer) > 0:
		    # make sure we include the last line of an expression
		    lineBuffer.append(line)
		    line = ' '.join(lineBuffer)
		    lineBuffer = [ ]

		# keep track of leading whitespace
		i, n = 0, len(line)
		while (i < n) and (line[i] in string.whitespace): 
		    i = i + 1
		indent = line[:i]
		cmd = line[i:]
		# if see nested execfile(), handle that recursively
		if re.match(execfileRE, cmd):
		    try:
			self.parseExecfile(cmd, ignore=ignore, **parms)
		    except Exception, ex:
			if ignore == 0:
			    more = self.push(cmd)
			else:
			    #sys.stderr.write('DBX: RiesCodeN2::_parseExecfile: ignore <%s>, ex=%s\n' % (cmd, ex))
			    self.resetbuffer()
		else:
		    # if not an execfile(), parse the line, then add back the 
		    # leading whitespace
		    try:
			cmd = self.parser.parseCmd(cmd, **parms)
			if cmd != None:
			    # for run-command-file and run-python-file
			    # commands, parser will return execfile(file-name),
			    # since the file may contains frontend commands,
			    # so we must pass them through parser line by line.
			    if re.match(execfileRE, cmd):
				self.parseExecfile(cmd, ignore=ignore, **parms)
			    else:
				newCmd = indent + cmd
				more = self.push(newCmd)
			else:
			    self.resetbuffer()
			    more = 0

		    except SystemExit:
			# if it is an exit signal, go with it.
			raise
		    except Exception, ex:
			if ignore == 0:
			    # report the error
			    more = self.push(indent + 'raise')
			else:
			    #sys.stderr.write('DBX: RiesCodeN2::_parseExecfile: ignore <%s>, ex2=%s\n' % (cmd, ex))
			    self.resetbuffer()

	fin.close()
	# send in an extra newline to close the last definition in the file.
	more = self.push("\n")


def interact(banner=None, readfunc=None, local=None, **parms):
    """Closely emulate the interactive Python interpreter.

    This is a backwards compatible interface to the InteractiveConsole
    class.  When readfunc is not specified, it attempts to import the
    readline module to enable GNU readline if it is available.

    Arguments (all optional, all default to None):

    banner -- passed to InteractiveConsole.interact()
    readfunc -- if not None, replaces InteractiveConsole.raw_input()
    local -- passed to InteractiveInterpreter.__init__()

    """
    console = InteractiveConsole(local)
    if readfunc is not None:
        console.raw_input = readfunc
    else:
        try:
            import readline
        except:
            pass
    console.interact(banner, **parms)


def usage():
    """
    """
    print
    print "usage: python %s [options]" % (sys.argv[0])
    print "options:"
    print "\t -c conf-file       # diag configuration file"
    print "\t -h                 # this usage information"
    #print "\t -s backend-config  # riesling backend configuration file"
    print "\t -x conf-file       # riesling configuration file"
    print "\t -p python-file       # python configuration file to be executed at startup"
    print "\t --blaze system     # type of system, n1"
    print "\t --blazeopt \"blaze options\"   # blaze runtime options"
    print "\t --ar system        # type of system, n1, ignore if --blaze is used"
    print "\t --rc riesling-rc   # riesling config, a combination of -c & -x"
    print
    sys.exit()


def dbxTraceBack():
    """
    """
    try:
	type, value, tb = sys.exc_info()
	sys.last_type = type
	sys.last_value = value
	sys.last_traceback = tb
	tblist = traceback.extract_tb(tb)
	del tblist[:1]
	list = traceback.format_list(tblist)
	if list:
	    list.insert(0, "Traceback (most recent call last):\n")
	list[len(list):] = traceback.format_exception_only(type, value)
    finally:
	tblist = tb = None
    
    for line in list:
	sys.stderr.write('%s' % line)


def createSystem (optdir):
    """invoke backend system constructor
    """
    sys.stderr.write("# %s: create riesling.sys\n" % (time.ctime()))

    global rsys
    global sim
    global ncpus
    global ncores
    global nucores
    global nstrands
    global nstrandObjs
    # if --blaze is specified, use that, otherwise use --ar
    if optdir.has_key('--blaze'):
  	if optdir['--blaze'] == 'n1':
	    optdir['--ar'] = 'n1'
 	    initN1(1)
	else:
	    sys.stderr.write('ERROR: unknown system %s\n' % (optdir['--blaze']))
	    sys.exit()
    else:
  	if optdir['--ar'] == 'n1':
 	    initN1(0)
	else:
	    sys.stderr.write('ERROR: unknown system %s\n' % (optdir['--ar']))
	    sys.exit()

    if nucores == 0:
	nstrandObjs = ncpus * ncores * nstrands
	sys.stderr.write('# %s: sys=(cpu,core,strand)=(%d,%d,%d)\n' % (time.ctime(), ncpus, ncores, nstrands))
    else:
	nstrandObjs = ncpus * ncores * nucores * nstrands
	sys.stderr.write('# %s: sys=(cpu,core,ucore,strand)=(%d,%d,%d,%d)\n' % (time.ctime(), ncpus, ncores, nucores, nstrands))

    sys.stderr.write("# %s: done creating riesling.sys\n" % (time.ctime()))


def initN1 (isBlaze):
    """init N1 structure/variables
    """
    #sys.stderr.write("#DBX %s: initN1\n" % (time.ctime()))

    global rsys
    global sim
    global rieslingLib
    import Riesling_N1_Model as rieslingLib

    if isBlaze:
	import riesling_n1_blaze
	rsys = rieslingLib.Model(riesling_n1_blaze,riesling_n1_blaze.Blaze_Ni_System())
    else:
	import riesling_n1
	rsys = rieslingLib.Model(riesling_n1,riesling_n1.Ni_System())

    sim = rsys
    initGenericNi(rsys)

    # then, atchitecture specific structure
    #TODO


def initGenericNi (rsys):
    """init generic Niagara structure
    """
    #sys.stderr.write("#DBX %s: initGenericNi\n" % (time.ctime()))

    global ncpus
    global ncores
    global nstrands
    global cpus
    global cores
    global strands
	# XXX
    if not rsys.__create_cpu__(1):
	print "Failed to create %d Ni cpu instance(s)" % 1
	sys.exit(-1)	


    # system configuration XXX
    ncpus = len(rsys.p)
    ncores = 8
    nstrands = 4

    for i in range(0,ncpus):
        cpus[i] = rsys.p[i]
        for j in range(0,8):
	    cores[i*8 + j] = rsys.p[i].c[j]
	    for k in range(0,4):
	        strands[i*8*4 + j*8 + k] = rsys.p[i].c[j].s[k] 	


def readConfig (optdir):
    """read configuration data
    """    
    global NEW_CONFIG
    global configRC

    #sys.stderr.write("#DBX %s: read config\n" % (time.ctime()))
    configRies = None
    configDiag = None

    # read -x config (diag.simics)
    if optdir.has_key('-x'):
	configRies = ReadConfigRies.ReadConfigRies()
	configRies.readConfig(optdir['-x'])
    #sys.stderr.write('DBX: configRies = %s\n' % (configRies))
    
    # read -c config (diag.conf)
    if optdir.has_key('-c'):
	# if -c is specified, use it
	configDiag = ReadConfigDiag.ReadConfigDiag()
	configDiag.readConfig(optdir['-c'])
    elif configRies and configRies.data.has_key(ReadConfigRies.DIAG_CONF):
	# otherwise if DIAG_CONF is specified in -x, use that
	configDiag = ReadConfigDiag.ReadConfigDiag()
	configDiag.readConfig(configRies.data[ReadConfigRies.DIAG_CONF])
    #sys.stderr.write('DBX: configDiag = %s\n' % (configDiag))

    if configRies == None or configDiag == None:
	sys.stderr.write('ERROR: no configuration data is given by either -c & -x, or --rc option\n')
	usage()
	sys.exit()

    # system config
    try:
	newline = '@conf.%s.%s = %s' % (RC_SYS_CONFIG_OBJ, RC_PROMPT, configRies.data[ReadConfigRies.PROMPT])
    except:
	# default
	newline = '@conf.%s.%s = ries' % (RC_SYS_CONFIG_OBJ, RC_PROMPT)
    configDiag.setDataLine(newline)

    try:
	newline = '@conf.%s.%s = %s' % (RC_SYS_CONFIG_OBJ, RC_MEM_IMAGE, RC_configRies.data[ReadConfigRies.MEM_IMAGE])
    except:
	# default
	newline = '@conf.%s.%s = mem.image' % (RC_SYS_CONFIG_OBJ, RC_MEM_IMAGE)
    configDiag.setDataLine(newline)

    # process @def and def specified in config file
    handleAtDef(configRies, configDiag)
    # process @conf.zzz in configRies
    handleAtConf(configRies, configDiag)
    # process commands
    if configRies.data.has_key(ReadConfigRies.CMD):
	for cmd in configRies.data[ReadConfigRies.CMD]:
	    newline = '@conf.%s.%s =+ %s' % (RC_SYS_CONFIG_OBJ, RC_COMMAND, cmd)
	    configDiag.setDataLine(newline)
    # handle new_command() --- python command extension
    if configRies and configRies.data[ReadConfigRies.NEW_CMD] != {}:
	for cmdkey in configRies.data[ReadConfigRies.NEW_CMD].keys():
	    newline = '@conf.%s.%s =+ %s=%s' % (RC_SYS_CONFIG_OBJ, RC_COMMAND_EXT, cmdkey, configRies.data[ReadConfigRies.NEW_CMD][cmdkey])
	    configDiag.setDataLine(newline)

    fdtmp = open(NEW_CONFIG, 'w')
    fdtmp.write('%s\n' % (configDiag))
    fdtmp.close()

    # create the rc object to be used from now on
    configRC = ReadConfigDiag.ReadConfigDiag()
    configRC.readConfig(NEW_CONFIG)


def constructSystem (optdir):
    """construct a backend system
    """
    global rsys
    global sysAddr

    #sys.stderr.write("#DBX %s: construct system\n" % (time.ctime()))

    # create backend system and get the sys object's address, to be passed 
    # to nasAPI or blaze.
    try:
	createSystem(optdir)
	
	# XXX
	sysAddr = rsys.__system__.getThisPtr()
    except:
	dbxTraceBack()

    #sys.stderr.write('# %s: sys addr=%u\n' % (time.ctime(), sysAddr))


#def handleAtDef (globals):
def handleAtDef (configRies, configDiag):
    """
    """
    global ATDEF

    #sys.stderr.write("#DBX %s: process @def/def\n" % (time.ctime()))

    try:
	# remove old file, if any
	os.remove(ATDEF)
    except:
	pass
    if configRies:
	tfd = open(ATDEF, 'w')
	if configRies.data[ReadConfigRies.AT_DEF] != {}:
	    for func in configRies.data[ReadConfigRies.AT_DEF].keys():
		tfd.write('%s\n' % (''.join(configRies.data[ReadConfigRies.AT_DEF][func])))
		tfd.write('\n')

	tfd.close()

    if configDiag:
	newline = '@conf.%s.%s = %s' % (RC_SYS_CONFIG_OBJ, RC_FUNC_DEF, ATDEF)
	configDiag.setDataLine(newline)

	# run the function definition in ATDEF
	if os.path.getsize(ATDEF) > 0:
	    execfile(ATDEF, globals())


def handleAtConf (configRies, configDiag):
    """
    """
    #sys.stderr.write("#DBX %s: process @conf.zzz\n" % (time.ctime()))

    if configDiag and configRies and configRies.data[ReadConfigRies.AT_CONF] != []:
	for dline in configRies.data[ReadConfigRies.AT_CONF]:
	    j = dline.find('=+')
	    if j > -1:
		# the value is to be appended to existing one(s)
		lop = dline[:j].strip()
		rop = dline[j+2:].strip()
		if re.match(DIGITAL_RE, rop):
		    # if rhs are all [0-9], leave as is
		    newline = dline
		else:
		    try:
			# we need to eval things like get_addr()
			newline = '%s =+ %#x' % (lop, eval(rop))
		    except:
			# if the right operand cannot be eval'ed, just use its 
			# original form.
			newline = dline
	    else:
		# the value is to be used to overwrite existing one
		j = dline.find('=')
		lop = dline[:j].strip()
		rop = dline[j+1:].strip()
		if re.match(DIGITAL_RE, rop):
		    # if rhs are all [0-9], leave as is
		    newline = dline
		else:
		    try:
			newline = '%s = %#x' % (lop, eval(rop))
		    except:
			newline = dline
	    # add/update value in configDiag
	    configDiag.setDataLine(newline)


def createCommandParser ():
    """
    """
    global parser
    global riesReposit
    global nstrandObjs
    global configRC

    #sys.stderr.write("#DBX %s: createCommandParser()\n" % (time.ctime()))

    parser = ni.CmdParserNi.CmdParserNi(riesReposit)
    # set the value in parser for later use
    parser.setNstrandObjs(nstrandObjs)

    # init zzz_cmd_RS() & RS_zzz() functions in ni.CmdParserNiCmd
    #sys.stderr.write("#DBX %s: create CmdParserNiCmd\n" % (time.ctime()))
    initCmdParserNiCmd(riesReposit, nstrandObjs)

    # handle new_command() --- python command extension
    if configRC.getObjData(ReadConfigDiag.TYPE_SYS_CONFIG, RC_SYS_CONFIG_OBJ, RC_COMMAND_EXT, silent=1):
	for cmd in configRC.getObjData(ReadConfigDiag.TYPE_SYS_CONFIG, RC_SYS_CONFIG_OBJ, RC_COMMAND_EXT):
	    i = cmd.find('=')
	    cmdkey = cmd[:i].strip()
	    cmdVal = cmd[i+1].strip()
	    parser.registerCommand(cmdkey, cmdVal)


def registerAtDef ():
    """
    """
    global ATDEF
    global parser

    #sys.stderr.write("#DBX %s: registerAtDef()\n" % (time.ctime()))

    try:
	if os.path.getsize(ATDEF) > 0:
	    fdtmp = open(ATDEF, 'r')
	    for line in fdtmp.readlines():
		if line.startswith('def '):
		    # def func(...):
		    lindex = line.find(' ')
		    mindex = line.find('(', lindex)
		    rindex = line.rfind(':')
		    fname = line[lindex+1:mindex].strip()
		    func = line[lindex+1:rindex].strip()
		    parser.registerDoc(fname, func, '@DEF', '@def '+func, None)
    except:
	pass


def loadSocketAPI ():
    """establish socket connection with RTL/testbench
    """
    global optdir
    global configRC
    global socketInit
    global ncpus
    global ncores
    global nstrands
    global sysAddr
    global riesReposit

    #sys.stderr.write("#DBX %s: loadSocketAPI()\n" % (time.ctime()))

    # init pli-socket module and related tso checker, swerver, etc
    if optdir['--ar'] == 'n1':
	import basAPI as socketAPI
    else:
	sys.stderr.write('ERROR: unknown system %s, no socket connection is established\n' % (optdir['--ar']))
	sys.exit()

    riesReposit.socketAPI = socketAPI

    if configRC and configRC.data.has_key(ReadConfigDiag.PLI_SOCKET):
	try:
	    socketid = int(configRC.data[ReadConfigDiag.PLI_SOCKET]["socket0"]["socket"])
	except:
	    socketid = 0
	# if replay is specified, fake a socket id so that pli-run can be used
	if ((socketid == 0) and
	    (configRC.data[ReadConfigDiag.PLI_SOCKET]["socket0"]["replay_log"] != '0')):
	    socketid = 64557
	#sys.stderr.write("DBX: RiesCodeN2: socket=%d\n" % (socketid))
	if socketid > 0:
	    # if valid socket id is specified, mark that so that pli-run cmd
	    # can be used
	    socketInit = 1
	    (ncpus, ncores, nstrands) = socketAPI.init(sysAddr, NEW_CONFIG, MEM_IMAGE)
	else:
	    socketInit = 0
	    (ncpus, ncores, nstrands) = socketAPI.init(sysAddr, NEW_CONFIG, MEM_IMAGE, 1)
    else:
	socketInit = 0
	# last parameter=1 (or any value != 0) means NO socket connection
	(ncpus, ncores, nstrands) = socketAPI.init(sysAddr, NEW_CONFIG, MEM_IMAGE, 1)


def executeSocket ():
    """this function is N1 specific
    """
    global configRC
    global parms
    global parser

    #sys.stderr.write("#DBX %s: executeSocket()\n" % (time.ctime()))

    # socket connection is used
    commands = configRC.getObjData(ReadConfigDiag.TYPE_SYS_CONFIG, RC_SYS_CONFIG_OBJ, RC_COMMAND, silent=1)
    if commands:
	#sys.stderr.write("#DBX %s: socket: process config/init cmd\n" % (time.ctime()))
	tmp = '.rs_config_cmd'
	fdtmp = open(tmp, 'w')
	for cmd in commands:
	    fdtmp.write('%s\n' % (cmd))
	fdtmp.close()
	# execute the commands specified in config file, if a command
	# cannot be recognized by frontend parser, just ignore it.
	fakeConsole = InteractiveConsole(locals=vars())
	fakeConsole.parser = parser
	fakeConsole.parseExecfile('execfile("%s")' % (tmp), ignore=1, **parms)
   

def blazercCmd (blazeopt):
    """extract riesling commands (the ones with #@) from blazerc
    """
    global riesReposit
    global optdir
    global newBlazeCmd

    #sys.stderr.write('#DBX: blazercCmd: blazeopt=%s\n' % (blazeopt)) #DBX

    cmd = [ ]
    ii = blazeopt.find('-c ')
    tmp = blazeopt[ii+3:].strip()
    jj = tmp.find(' ')
    if jj == -1:
	rcname = tmp
    else:
	rcname = tmp[:jj]
    try:
	fdrc = open(rcname, 'r')
    except:
	sys.stderr.write('ERROR: fail to open %s\n' % (rcname))
	sys.exit()

    for line in fdrc.readlines():
	line = line.strip()
	if line and line.startswith('#@'):
	    cmd.append(line[2:])
	elif line and line.startswith('conf numcpu'):
	    # record the numcpu value in blazerc and initialize the pmask value
	    # base on that.
	    tokens = line.split()
	    riesReposit.blazeNumcpu = int(tokens[2])
	    riesReposit.pmask = 1L
	    for i in range(1,riesReposit.blazeNumcpu):
		riesReposit.pmask = (riesReposit.pmask << 1) | 0x1
	elif line.startswith('sysconf'):
	    # sysconf -p ../../lib
	    # sysconf cpu name=cpu0 cpu-type=...
	    # sysconf dumbserial serial1 type=GUEST ...
	    tokens = line.split()
	    if (tokens[1].lower() != 'cpu') and (tokens[1] != '-p'):
		newBlazeCmd.append(tokens[1])
		newBlazeCmd.append(tokens[2])

    if optdir['--blaze'] == 'nn':
	# convert blaze numcpu to coreAvailable
	if (riesReposit.blazeNumcpu % riesReposit.nstrands) == 0:
	    cores = riesReposit.blazeNumcpu / riesReposit.nstrands
	else:
	    cores = (riesReposit.blazeNumcpu / riesReposit.nstrands) + 1

	for i in range(0, cores):
	    if (i % riesReposit.ncores) == 0:
		setcmp = 0
		cpuid = i / riesReposit.ncores
		coreAvail = 0xffL
	    else:
		setcmp = 0
		coreAvail = (coreAvail << ((i%riesReposit.ncores)*8)) | 0xffL
		if ((i+1) % riesReposit.ncores) == 0:
		    # re-adjust CMP registers
		    setcmp = 1
		    strandid = cpuid * riesReposit.ncores * riesReposit.nstrands
		    coreAvailable = strands[strandid].rdasi(0x41, 0x0L) & coreAvail
		    strands[strandid].wrasi(0x41, 0x0L, coreAvailable, True)
		    strands[strandid].wrasi(0x41, 0x10L, coreAvailable, True)
		    strands[strandid].wrasi(0x41, 0x20L, coreAvailable, True)
		    coreRunning = strands[strandid].rdasi(0x41, 0x50L, False) & coreAvail
		    strands[strandid].wrasi(0x41, 0x50L, coreRunning, True)
		    strands[strandid].wrasi(0x41, 0x58L, coreRunning, True)

	# final set
	if setcmp == 0:
	    strandid = cpuid * riesReposit.ncores * riesReposit.nstrands
	    coreAvailable = strands[strandid].rdasi(0x41, 0x0L) & coreAvail
	    strands[strandid].wrasi(0x41, 0x0L, coreAvailable, True)
	    strands[strandid].wrasi(0x41, 0x10L, coreAvailable, True)
	    strands[strandid].wrasi(0x41, 0x20L, coreAvailable, True)
	    coreRunning = strands[strandid].rdasi(0x41, 0x50L, False) & coreAvail
	    strands[strandid].wrasi(0x41, 0x50L, coreRunning, True)
	    strands[strandid].wrasi(0x41, 0x58L, coreRunning, True)
	    
    return cmd


########################
#####     MAIN     #####
########################
if __name__ == '__main__':
    """
    """
    import commands
    sys.stderr.write("# %s\n" % (commands.getoutput('uname -a')))
    sys.stderr.write("# Python %s\n" % sys.version)
    sys.stderr.write("# %s: start riesling frontend\n" % (time.ctime()))

    # if --blaze is specified, then Blaze_x_System should be used.
    # if --blaze is not specified, but -DMOM is specified, then --blaze
    # will be added to optdir.
    # concatenate options embraced in "..."
    #sys.stderr.write('DBX: sys.argv=%s\n' % sys.argv) #DBX
    argv = []
    argMerge = []
    for arg in sys.argv:
	if argMerge == [] and arg.startswith('"'):
	    argMerge.append(arg[1:])
	elif argMerge != [] and arg.endswith('"'):
	    argMerge.append(arg[:-1])
	    argv.append(' '.join(argMerge))
	    argMerge = []
	elif argMerge != []:
	    argMerge.append(arg)
	else:
	    argv.append(arg)
    #sys.stderr.write('DBX: argv=%s\n' % argv) #DBX
    import getopt
    # -c diag.conf
    # -h : help
    # -s conf ---> obsolete
    # -x diag.simics
    # --ar : n1
    # -rc riesling.rc : combination of -c & -x
    # --blaze : n1
    # --blazeopt : blaze options
    optlist, args = getopt.getopt(argv[1:], 'c:hs:x:p:', ['ar=','rc=','blaze=','blazeopt='])

    optdir = {}	
    for (key,value) in optlist:
	optdir[key] = value
    if not optdir.has_key('--ar'):
	optdir['--ar'] = optdir['--blaze']

    if optdir.has_key('-h'):
	usage()

    # read -x diag.simics & -c diag.conf
    import ReadConfigRies
    import ReadConfigDiag
    ATDEF = '.riesling.def'
    NEW_CONFIG = '.riesling.rc'
    configRC   = None
    if optdir.has_key('--rc'):
	# if --rc is used, then ignore -c & -x
	# NOTE  it will be tricky to use --rc in rtl cosim environment,
	#       as we need socket-id to connect with rtl, and the id will
	#       change from run to run, which is recorded in diag.conf by sims,
	#       the socket-id in --rc won't work as it was from the previous
	#       run, if at all.
	#sys.stderr.write('WARNING: cannot use --rc %s when cosim with RTL\n' % (optdir['--rc']))
	NEW_CONFIG = optdir['--rc']
	configRC = ReadConfigDiag.ReadConfigDiag()
	configRC.readConfig(optdir['--rc'])
	# run function defition specified by -x or --rc
	ATDEF = configRC.getData(RC_SYS_CONFIG_OBJ, RC_FUNC_DEF)
	#sys.stderr.write('#DBX: func-def %s\n' % (funcDef))
	if ATDEF and os.path.getsize(ATDEF) > 0:
	    execfile(ATDEF, globals())
    else:
	readConfig(optdir)

    # check if blaze/mom will be used
    if configRC:
	momObjs = configRC.getObjIds('mom', silent=1)
	if (momObjs != []):
	    # if user specifies a special version of mom, use that instead
	    # of the default file.
	    try:
		momSoPath = configRC.data['mom']['mom0']['so_path']
	    except:
		momSoPath = None
	    if (momSoPath):
		if (os.path.exists(momSoPath)):
		    cmd='ls -l *mom* ; /bin/cp -p %s . ; ls -l *mom*' % (momSoPath)
		    os.system(cmd)
		else:
		    sys.stderr.write('ERROR: mom module %s does not exist\n' % (momSoPath))
		    sys.exit()

	if (momObjs != []) and (not optdir.has_key('--blaze')):
	    prompt = configRC.data[ReadConfigDiag.TYPE_SYS_CONFIG][RC_SYS_CONFIG_OBJ][RC_PROMPT]
	    if prompt == 'bas':
		optdir['--blaze'] = 'n1'
	    else:
		sys.stderr.write('ERROR: unknown system prompt %s\n' % (prompt))
		sys.exit()
		
    # default arch configuration
    nstrandObjs = 0
    (ncpus, ncores, nucores, nstrands) = (0,0,0,0)
    (cpus, cores, ucores, strands) = ({},{},{},{})

    # construct backend system
    SYSTEM = 'rsys'
    sysAddr = 0L
    rsys = None
    sim = None
    constructSystem(optdir)
	
##     # process @def and def specified in config file
##     handleAtDef(globals())

##     # process @conf.zzz in configRies
##     handleAtConf()

    # dump modified diag.conf content to file, the new file has a well
    # organized format which may it easier to be processed by other module,
    # e.g., a loaded-in c/c++ module that needs configuration data.
##     NEW_CONFIG = '.diag.conf-addon'
##     fdtmp = open(NEW_CONFIG, 'w')
##     fdtmp.write('%s\n' % (configDiag))
##     fdtmp.close()

    # dbx: display mom-related configuration
    #debugMomConfig(NEW_CONFIG)

    MEM_IMAGE = configRC.getObjData(ReadConfigDiag.TYPE_SYS_CONFIG, RC_SYS_CONFIG_OBJ, RC_MEM_IMAGE)

    # a Repository object for variables that should be availabe globally,
    # this is most useful in interactive mode, where we may need to eval()
    # commands at various locations.
    import base.Repository
    riesReposit = base.Repository.Repository()

    # load nasAPI if needed. when --blaze is specified, riesling is to 
    # interact with blaze, no pli socket is needed, so don't load nasAPI.
    socketInit = 0
    if not optdir.has_key('--blaze'):
    	loadSocketAPI()

    riesReposit.riesling = rsys
    riesReposit.topName = SYSTEM
    # record main program's globals so other functions deep in the code
    # structure can have access to top layer values.
    riesReposit.globals = globals()
    riesReposit.sysAddr = sysAddr
    riesReposit.ncpus = ncpus
    riesReposit.ncores = ncores
    riesReposit.nucores = nucores
    riesReposit.nstrands = nstrands
    riesReposit.optdir = optdir
    riesReposit.cpus = cpus
    riesReposit.cores = cores
    riesReposit.ucores = ucores
    riesReposit.strands = strands
    riesReposit.riesLib = rieslingLib

    #declare variables for single, double and quad fp regs
    # is it ok to put nn specific constants here? ---> fp is generic enough
    riesReposit.nSpregs = 64	
    riesReposit.nDpregs = 32	
    riesReposit.nQpregs = 16	

    # create a command parser
    parser = None
    import ni.CmdParserNi
    # we have to import ni.CmdParserNiCmd* at this level so that all the
    # RS_zzz() can be globally available
    from ni.CmdParserNiCmd import *
    createCommandParser()

    parms = { 'confRC':configRC, 'socketInit':socketInit, 'reposit':riesReposit, 'parser':parser }

    # folder to keep UI commands (the ones start with #@) extracted from 
    # blazerc
    rcCmd = [ ]

    if socketInit == 1:
	# socket connection is used
	executeSocket()
	# in socket mode, we should never get into interactive mode,
	# so when socket communication is done, the program exits.
    else:
	# not in pli socket mode, load the symbol table if it is available
	symFile = 'symbol.tbl'
	symTable = None
	if os.path.exists(symFile):
	    #sys.stderr.write("#DBX %s: load symbol\n" % (time.ctime()))
	    import ni.NiSymbolTable
	    symTable = ni.NiSymbolTable.NiSymbolTable()
	    symTable.load(symFile)
	# keep it in repository
	riesReposit.symTable = symTable

	# register @def/def functions' doc, if any
	registerAtDef()

	# load personal customization, if available
	filename = os.environ.get('PYTHONSTARTUP')
	if filename and os.path.isfile(filename):
	    #sys.stderr.write('# Executing User Startup %s .. \n' % filename)
	    execfile(filename)

	#sys.stderr.write("#DBX %s: ready for interactive mode\n" % (time.ctime()))

	if optdir.has_key('--blaze'):
	    # init blaze module, the same blaze is used for all archs
	    #sys.stderr.write('DBX: importing libblazePy\n') #DBX
	    import libblazePy as blazePy
	    # connect blaze with riesling
	    if optdir.has_key('--blazeopt'):
		blazeopt = optdir['--blazeopt']
	    else:
		blazeopt = '-c ./blazerc'
	    if blazeopt.find('-c ') == -1:
		blazeopt = blazeopt + ' -c ./blazerc'
	    # find the blazerc file name
	    newBlazeCmd = [ ]
	    rcCmd = blazercCmd(blazeopt)
	    #sys.stderr.write('#DBX: rcCmd=%s\n' % (rcCmd)) #DBX
	    # init blaze
	    blazePy.init('riesling', sysAddr, blazeopt)
	    # register blaze cmooand map
	    import blaze.BlazeCmdMap
	    blazeCmdMap = blaze.BlazeCmdMap.BlazeCmdMap(blazePy)
	    parser.registerCmdMap(blazeCmdMap)
	    # register new commands introduced by sysconf in blazerc
	    for cmd in newBlazeCmd:
		blazeCmdMap.cmdMap.append(cmd)
	    # switch to use 'sam' as prompt symbol, sam is blaze 
	    # infrastructure plus risling core
	    newline = '@conf.%s.%s = sam' % (RC_SYS_CONFIG_OBJ, RC_PROMPT)
	    configRC.setDataLine(newline)

	# enter interactive mode
	if optdir.has_key('-p'):
            execfile(optdir['-p'])
	interact(banner="Riesling Frontend Reader", local=vars(), **parms)
