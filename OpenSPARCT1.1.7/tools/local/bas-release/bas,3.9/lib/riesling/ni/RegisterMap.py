# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: RegisterMap.py
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
"""map ni-simics register name to riesling counterpart
"""

"""
A reg is an integer register name. It can have any of the following values:
%r0-%r31
%g0-%g7 (global registers; same as %r0-%r7)
%o0-%o7 (out registers; same as %r8-%r15)
%l0-%l7 (local registers; same as %r16-%r23)
%i0-%i7 (in registers; same as %r24-%r31)
%fp (frame pointer; conventionally same as %i6)
%sp (stack pointer; conventionally same as %o6)
"""

import re, sys

LEVEL_SYS    = 0
LEVEL_CPU    = 1
LEVEL_CORE   = 2
LEVEL_UCORE  = 3
LEVEL_STRAND = 4

REG_TT   = 'tt'
REG_TPC  = 'tpc'
REG_TNPC = 'tnpc'
REG_G    = 'g'
REG_O    = 'o'
REG_L    = 'l'
REG_I    = 'i'


class RegisterMap:
    """
    """

    def __init__ (self):
	"""
	"""
	# simics -> riesling reg-name mapping, special rules
	self.rules = { }
	# (re, key-lenght, get-parm, set-parm)
	self.rules[REG_TT] = (re.compile('^%?tt\d+'), 2, 'tl', 'trapType')
	self.rules[REG_TPC] = (re.compile('^%?tpc\d+'), 3, 'tl', 'tpc')
	self.rules[REG_TNPC] = (re.compile('^%?tnpc\d+'), 4, 'tl', 'tnpc')
	self.rules[REG_G] = (re.compile('^%?g\d+'), 1, 'reg', 'value')
	self.rules[REG_O] = (re.compile('^%?o\d+'), 1, 'reg', 'value')
	self.rules[REG_L] = (re.compile('^%?l\d+'), 1, 'reg', 'value')
	self.rules[REG_I] = (re.compile('^%?i\d+'), 1, 'reg', 'value')

	# simics -> riesling reg-name mapping
	self.regMap = { }
	# (id,level,get-name,set-name,special-func)
	self.regMap['g0'] = (0,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regg)
	self.regMap['g1'] = (1,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regg)
	self.regMap['g2'] = (2,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regg)
	self.regMap['g3'] = (3,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regg)
	self.regMap['g4'] = (4,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regg)
	self.regMap['g5'] = (5,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regg)
	self.regMap['g6'] = (6,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regg)
	self.regMap['g7'] = (7,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regg)
	self.regMap['o0'] = (8,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.rego)
	self.regMap['o1'] = (9,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.rego)
	self.regMap['o2'] = (10,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.rego)
	self.regMap['o3'] = (11,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.rego)
	self.regMap['o4'] = (12,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.rego)
	self.regMap['o5'] = (13,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.rego)
	self.regMap['o6'] = (14,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.rego)
	self.regMap['o7'] = (15,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.rego)
	self.regMap['l0'] = (16,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regl)
	self.regMap['l1'] = (17,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regl)
	self.regMap['l2'] = (18,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regl)
	self.regMap['l3'] = (19,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regl)
	self.regMap['l4'] = (20,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regl)
	self.regMap['l5'] = (21,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regl)
	self.regMap['l6'] = (22,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regl)
	self.regMap['l7'] = (23,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regl)
	self.regMap['i0'] = (24,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regi)
	self.regMap['i1'] = (25,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regi)
	self.regMap['i2'] = (26,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regi)
	self.regMap['i3'] = (27,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regi)
	self.regMap['i4'] = (28,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regi)
	self.regMap['i5'] = (29,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regi)
	self.regMap['i6'] = (30,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regi)
	self.regMap['i7'] = (31,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regi)
	self.regMap['pc'] = (32,LEVEL_STRAND,'getArchStatePtr().getPc','getArchStatePtr().setPc',None)
	self.regMap['npc'] = (33,LEVEL_STRAND,'getArchStatePtr().getNpc','getArchStatePtr().setNpc',None)
	self.regMap['y'] = (34,LEVEL_STRAND,'getArchStatePtr().getYRegPtr().getNative','getArchStatePtr().getYRegPtr().setNative',None)
	self.regMap['ccr'] = (35,LEVEL_STRAND,'getArchStatePtr().getCcrRegPtr().getNative','getArchStatePtr().getCcrRegPtr().setNative',None)
	self.regMap['fprs'] = (36,LEVEL_STRAND,'getArchStatePtr().getFprsRegPtr().getNative','getArchStatePtr().getFprsRegPtr().setNative',None)
	self.regMap['fsr'] = (37,LEVEL_STRAND,'getArchStatePtr().getFsrRegPtr().getNative','getArchStatePtr().getFsrRegPtr().setNative',None)
	self.regMap['asi'] = (38,LEVEL_STRAND,'getArchStatePtr().getAsiRegPtr().getNative','getArchStatePtr().getAsiRegPtr().setNative',None)
	self.regMap['tick'] = (39,LEVEL_STRAND,'getArchStatePtr().getTickRegPtr().getNative','getArchStatePtr().getTickRegPtr().setNative',None)
	self.regMap['gsr'] = (40,LEVEL_STRAND,'getArchStatePtr().getGsrRegPtr().getNative','getArchStatePtr().getGsrRegPtr().setNative',None)
	self.regMap['tick_cmpr'] = (41,LEVEL_STRAND,'getArchStatePtr().getTickCmprRegPtr().getNative','getArchStatePtr().getTickCmprRegPtr().setNative',None)
	# in Ni/N2 stick is an alias of tick, but archState has separate
	# variable for each. N2_InstrEmu has stick_ = tick_ so change to 
	# either one will actually change ONLY tick, stick remains 0 always.
	#self.regMap['stick'] = (42,LEVEL_STRAND,'getArchStatePtr().stick.getNative','getArchStatePtr().stick.setNative',None)
	self.regMap['stick'] = (42,LEVEL_STRAND,'getArchStatePtr().getStickRegPtr().getNative','getArchStatePtr().getStickRegPtr().setNative',None)
	self.regMap['stick_cmpr'] = (43,LEVEL_STRAND,'getArchStatePtr().getStickCmprRegPtr().getNative','getArchStatePtr().getStickCmprRegPtr().setNative',None)
	self.regMap['pstate'] = (44,LEVEL_STRAND,'getArchStatePtr().getPstateRegPtr().getNative','getArchStatePtr().getPstateRegPtr().setNative',None)
	self.regMap['tl'] = (45,LEVEL_STRAND,'getArchStatePtr().getTrapLevelRegPtr().getNative','getArchStatePtr().getTrapLevelRegPtr().setNative',None)
	self.regMap['pil'] = (46,LEVEL_STRAND,'getArchStatePtr().getPilRegPtr().getNative','getArchStatePtr().getPilRegPtr().setNative',None)
	self.regMap['tpc1'] = (47,LEVEL_STRAND,'getArchStatePtr().getTpcRegPtr().getTpc','getArchStatePtr().getTpcRegPtr().setTpc',self.tpc)
	self.regMap['tpc2'] = (48,LEVEL_STRAND,'getArchStatePtr().getTpcRegPtr().getTpc','getArchStatePtr().getTpcRegPtr().setTpc',self.tpc)
	self.regMap['tpc3'] = (49,LEVEL_STRAND,'getArchStatePtr().getTpcRegPtr().getTpc','getArchStatePtr().getTpcRegPtr().setTpc',self.tpc)
	self.regMap['tpc4'] = (50,LEVEL_STRAND,'getArchStatePtr().getTpcRegPtr().getTpc','getArchStatePtr().getTpcRegPtr().setTpc',self.tpc)
	self.regMap['tpc5'] = (51,LEVEL_STRAND,'getArchStatePtr().getTpcRegPtr().getTpc','getArchStatePtr().getTpcRegPtr().setTpc',self.tpc)
	self.regMap['tpc6'] = (52,LEVEL_STRAND,'getArchStatePtr().getTpcRegPtr().getTpc','getArchStatePtr().getTpcRegPtr().setTpc',self.tpc)
	self.regMap['tnpc1'] = (57,LEVEL_STRAND,'getArchStatePtr().getTnpcRegPtr().getTnpc','getArchStatePtr().getTnpcRegPtr().setTnpc',self.tnpc)
	self.regMap['tnpc2'] = (58,LEVEL_STRAND,'getArchStatePtr().getTnpcRegPtr().getTnpc','getArchStatePtr().getTnpcRegPtr().setTnpc',self.tnpc)
	self.regMap['tnpc3'] = (59,LEVEL_STRAND,'getArchStatePtr().getTnpcRegPtr().getTnpc','getArchStatePtr().getTnpcRegPtr().setTnpc',self.tnpc)
	self.regMap['tnpc4'] = (60,LEVEL_STRAND,'getArchStatePtr().getTnpcRegPtr().getTnpc','getArchStatePtr().getTnpcRegPtr().setTnpc',self.tnpc)
	self.regMap['tnpc5'] = (61,LEVEL_STRAND,'getArchStatePtr().getTnpcRegPtr().getTnpc','getArchStatePtr().getTnpcRegPtr().setTnpc',self.tnpc)
	self.regMap['tnpc6'] = (62,LEVEL_STRAND,'getArchStatePtr().getTnpcRegPtr().getTnpc','getArchStatePtr().getTnpcRegPtr().setTnpc',self.tnpc)
	self.regMap['tstate1'] = (67,LEVEL_STRAND,None,None,None)
	self.regMap['tstate2'] = (68,LEVEL_STRAND,None,None,None)
	self.regMap['tstate3'] = (69,LEVEL_STRAND,None,None,None)
	self.regMap['tstate4'] = (70,LEVEL_STRAND,None,None,None)
	self.regMap['tstate5'] = (71,LEVEL_STRAND,None,None,None)
	self.regMap['tstate6'] = (72,LEVEL_STRAND,None,None,None)
	self.regMap['tt1'] = (77,LEVEL_STRAND,'getArchStatePtr().getTrapTypeRegPtr().getTrapType','getArchStatePtr().getTrapTypeRegPtr().setTrapType',self.tt)
	self.regMap['tt2'] = (78,LEVEL_STRAND,'getArchStatePtr().getTrapTypeRegPtr().getTrapType','getArchStatePtr().getTrapTypeRegPtr().setTrapType',self.tt)
	self.regMap['tt3'] = (79,LEVEL_STRAND,'getArchStatePtr().getTrapTypeRegPtr().getTrapType','getArchStatePtr().getTrapTypeRegPtr().setTrapType',self.tt)
	self.regMap['tt4'] = (80,LEVEL_STRAND,'getArchStatePtr().getTrapTypeRegPtr().getTrapType','getArchStatePtr().getTrapTypeRegPtr().setTrapType',self.tt)
	self.regMap['tt5'] = (81,LEVEL_STRAND,'getArchStatePtr().getTrapTypeRegPtr().getTrapType','getArchStatePtr().getTrapTypeRegPtr().setTrapType',self.tt)
	self.regMap['tt6'] = (82,LEVEL_STRAND,'getArchStatePtr().getTrapTypeRegPtr().getTrapType','getArchStatePtr().getTrapTypeRegPtr().setTrapType',self.tt)
	self.regMap['tba'] = (87,LEVEL_STRAND,'getArchStatePtr().getTbaRegPtr().getNative','getArchStatePtr().getTbaRegPtr().setNative',None)
	self.regMap['ver'] = (88,LEVEL_STRAND,'getArchStatePtr().getHverRegPtr().getNative','getArchStatePtr().getHverRegPtr().setNative',None)
	self.regMap['cwp'] = (89,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().getCWP','getArchStatePtr().getRegisterFilePtr().setCWP',None)
	self.regMap['cansave'] = (90,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().getCANSAVE','getArchStatePtr().getRegisterFilePtr().setCANSAVE',None)
	self.regMap['canrestore'] = (91,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().getCANRESTORE','getArchStatePtr().getRegisterFilePtr().setCANRESTORE',None)
	self.regMap['otherwin'] = (92,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().getOTHERWIN','getArchStatePtr().getRegisterFilePtr().setOTHERWIN',None)
	self.regMap['wstate'] = (93,LEVEL_STRAND,'getArchStatePtr().getWstateRegPtr().getNative','getArchStatePtr().getWstateRegPtr().setNative',None)
	self.regMap['cleanwin'] = (94,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().getCLEANWIN','getArchStatePtr().getRegisterFilePtr().setCLEANWIN',None)
	self.regMap['softint'] = (95,LEVEL_STRAND,'getArchStatePtr().getSoftIntRegPtr().getNative','getArchStatePtr().getSoftIntRegPtr().setNative',None)
	self.regMap['ecache_error_enable'] = (96,LEVEL_STRAND,None,None,None)
	self.regMap['asynchronous_fault_status'] = (97,LEVEL_STRAND,None,None,None)
	self.regMap['asynchronous_fault_address'] = (98,LEVEL_STRAND,None,None,None)
	self.regMap['out_intr_data0'] = (99,LEVEL_STRAND,None,None,None)
	self.regMap['out_intr_data1'] = (100,LEVEL_STRAND,None,None,None)
	self.regMap['out_intr_data2'] = (101,LEVEL_STRAND,None,None,None)
	self.regMap['intr_dispatch_status'] = (102,LEVEL_STRAND,None,None,None)
	self.regMap['in_intr_data0'] = (103,LEVEL_STRAND,None,None,None)
	self.regMap['in_intr_data1'] = (104,LEVEL_STRAND,None,None,None)
	self.regMap['in_intr_data2'] = (105,LEVEL_STRAND,None,None,None)
	self.regMap['intr_receive'] = (106,LEVEL_STRAND,None,None,None)
	self.regMap['gl'] = (107,LEVEL_STRAND,'getArchStatePtr().getGlobalLevelRegPtr().getNative','getArchStatePtr().getGlobalLevelRegPtr().setNative',None)
	self.regMap['hpstate'] = (108,LEVEL_STRAND,'getArchStatePtr().getHpstateRegPtr().getNative','getArchStatePtr().getHpstateRegPtr().setNative',None)
	self.regMap['htstate1'] = (109,LEVEL_STRAND,None,None,None)
	self.regMap['htstate2'] = (110,LEVEL_STRAND,None,None,None)
	self.regMap['htstate3'] = (111,LEVEL_STRAND,None,None,None)
	self.regMap['htstate4'] = (112,LEVEL_STRAND,None,None,None)
	self.regMap['htstate5'] = (113,LEVEL_STRAND,None,None,None)
	self.regMap['htstate6'] = (114,LEVEL_STRAND,None,None,None)
	self.regMap['htstate7'] = (115,LEVEL_STRAND,None,None,None)
	self.regMap['htstate8'] = (116,LEVEL_STRAND,None,None,None)
	self.regMap['htstate9'] = (117,LEVEL_STRAND,None,None,None)
	self.regMap['htstate10'] = (118,LEVEL_STRAND,None,None,None)
	self.regMap['htba'] = (119,LEVEL_STRAND,'getArchStatePtr().getHtbaRegPtr().getNative','getArchStatePtr().getHtbaRegPtr().setNative',None)
	self.regMap['hintp'] = (120,LEVEL_STRAND,'getArchStatePtr().getHintpRegPtr().getNative','getArchStatePtr().getHintpRegPtr().setNative',None)
	self.regMap['hstick_cmpr'] = (121,LEVEL_STRAND,'getArchStatePtr().getHstickCompareRegPtr().getNative','getArchStatePtr().getHstickCompareRegPtr().setNative',None)

	# a spix bug: [3d000010] sethi %hi(0x4000), %fp ---> %fp -> %i6
	self.regMap['fp'] = (30,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regHack)
	# another one: [9c8a8001] andcc     %o2, %g1, %sp ---> %sp -> %o6
	self.regMap['sp'] = (14,LEVEL_STRAND,'getArchStatePtr().getRegisterFilePtr().get','getArchStatePtr().getRegisterFilePtr().set',self.regHack)

	self.regMapId = { }
	for key in self.regMap.keys():
	    (id,parm2,parm3,parm4,parm5) = self.regMap[key]
	    if parm5 != self.regHack:
		# ignore the ones use regHack(), they overlap with regular 
		# ones.
		self.regMapId[id] = key

	# after the general register mapping initialization, we should invoke
	# arch-specific initialization, if any.


    def __str__ (self):
	"""
	"""
	buffer = [ 'regid \tregname' ]
	klist = self.regMapId.keys()
	klist.sort()
	for regid in klist:
	    buffer.append('%s \t%s' % (regid, self.regMapId[regid]))
	
	return '\n'.join(buffer)


    def mapReadRS (self, key, cmd):
	"""return ni-simics reg-name's riesling counterpart, in string format
	"""
	try:
	    (id,lvl,rrs,wrs,func) = self.regMap[key]
	    if rrs == None:
		raise RuntimeError

	    if func != None:
		rrs = func(1, rrs, cmd)
	    else:
		# no parameter is needed for this get function
		rrs = rrs + '()'
	except:
	    #rrs = None
	    raise

	return (lvl,rrs)


    def mapWriteRS (self, key, cmd):
	"""return ni-simics reg-name's riesling counterpart, in string format
	"""
	try:
	    (id,lvl,rrs,wrs,func) = self.regMap[key]
	    if wrs == None:
		raise RuntimeError

	    if func != None:
		wrs = func(0, wrs, cmd)
	    else:
		# caller must append '(value=???)' to this set function
		pass
	except:
	    #wrs = None
	    raise

	return (lvl,wrs)


    def id2key (self, id):
	"""
	"""
	return self.regMapId[id]


    def key2id (self, key):
	"""return ni-simics reg-name's id
	"""
	try:
	    (id,lvl,rrs,wrs,func) = self.regMap[key]
	except:
	    raise

	return id


    def specialRule1 (self, key, read, rs, cmd, **parms):
	"""
	% "reg-name", e.g., %pc
	<processor>.read-reg "reg-name" 
	read-reg ["cpu-name"] "reg-name" 
	<processor>.write-reg "reg-name" value 
	write-reg ["cpu-name"] "reg-name" value 
	"""
	(reObj,size,rparm,wparm) = self.rules[key]

	tokens = cmd.split()
	i = 0
	newrs = None
	while i < len(tokens):
	    if re.match(reObj, tokens[i]):
		if tokens[i].startswith('%'):
		    # %regN
		    tl = tokens[i][size+1:]
		    #newrs = '%s(%s=%s)' % (rs, rparm, tl)
		    newrs = '%s(%s)' % (rs, tl)
		    break
		else:
		    # regN
		    tl = tokens[i][size:]
		    if read == 1:
			#newrs = '%s(%s=%s)' % (rs, rparm, tl)
			newrs = '%s(%s)' % (rs, tl)
		    else:
			#newrs = '%s(%s=%s,%s=%s)' % (rs, rparm, tl, wparm, tokens[i+1])
			newrs = '%s(%s,%s)' % (rs, tl, tokens[i+1])
		    break
	    else:
		i += 1

	return newrs


    def tt (self, read, rs, cmd):
	"""
	riesling.sys.cpu0.core0.strand0.getArchStatePtr().tt.gml() => void getTrapType ([u'string tl'])
	riesling.sys.cpu0.core0.strand0.getArchStatePtr().tt.gml() => void setTrapType ([u'string trapType', u'string tl'])
	"""
	return self.specialRule1(REG_TT, read, rs, cmd)


    def tpc (self, read, rs, cmd):
	"""
	riesling.sys.cpu0.core0.strand0.getArchStatePtr().tpc.gml() => void setTpc ([u'string tl', u'string tpc'])
	riesling.sys.cpu0.core0.strand0.getArchStatePtr().tpc.gml() => void getTpc ([u'string tl'])
	"""
	return self.specialRule1(REG_TPC, read, rs, cmd)

    def tnpc (self, read, rs, cmd):
	"""
	riesling.sys.cpu0.core0.strand0.getArchStatePtr().tnpc.gml() => void setTnpc ([u'string tl', u'string tnpc'])
	riesling.sys.cpu0.core0.strand0.getArchStatePtr().tnpc.gml() => void getTnpc ([u'string tl'])
	"""
	return self.specialRule1(REG_TNPC, read, rs, cmd)

    
    def specialRule2 (self, key, read, rs, cmd, **parms):
	"""
	riesling.sys.cpu0.core0.strand0.getArchStatePtr().getRegisterFilePtr().gml() => void get ([u'string reg'])
	riesling.sys.cpu0.core0.strand0.getArchStatePtr().getRegisterFilePtr().gml() => void set ([u'string reg', u'string value'])

	% "reg-name", e.g., %pc
	<processor>.read-reg "reg-name" 
	read-reg ["cpu-name"] "reg-name" 
	<processor>.write-reg "reg-name" value 
	write-reg ["cpu-name"] "reg-name" value 
	"""
	(reObj,size,rparm,wparm) = self.rules[key]
	offset = parms['offset']

	tokens = cmd.split()
	i = 0
	newrs = None
	while i < len(tokens):
	    if re.match(reObj, tokens[i]):
		if tokens[i].startswith('%'):
		    # %regN
		    reg = int(tokens[i][size+1:]) + offset
		    #newrs = '%s(%s=%s)' % (rs, rparm, reg)
		    newrs = '%s(%s)' % (rs, reg)
		    break
		else:
		    # regN
		    reg = int(tokens[i][size:]) + offset
		    if read == 1:
			#newrs = '%s(%s=%s)' % (rs, rparm, reg)
			newrs = '%s(%s)' % (rs, reg)
		    else:
			#newrs = '%s(%s=%s,%s=%s)' % (rs, rparm, reg, wparm, tokens[i+1])
			newrs = '%s(%s,%s)' % (rs, reg, tokens[i+1])
		    break
	    else:
		i += 1

	return newrs


    def regg (self, read, rs, cmd):
	"""
	"""
	return self.specialRule2(REG_G, read, rs, cmd, offset=0)


    def rego (self, read, rs, cmd):
	"""
	"""
	return self.specialRule2(REG_O, read, rs, cmd, offset=8)


    def regl (self, read, rs, cmd):
	"""
	"""
	return self.specialRule2(REG_L, read, rs, cmd, offset=16)


    def regi (self, read, rs, cmd):
	"""
	"""
	return self.specialRule2(REG_I, read, rs, cmd, offset=24)


    def regHack (self, read, rs, cmd):
	"""a hack to get around possible spix decode bug
	"""
	tokens = cmd.split()
	i = 0
	while i < len(tokens):
	    if tokens[i] == '%fp' or tokens[i] == 'fp':
		tokens[i] = tokens[i].replace('fp', 'i6')
		newCmd = ' '.join(tokens)
		#sys.stderr.write('DBX: RegisterMap: fp <%s><%s>' % (cmd, newCmd))
		return self.specialRule2(REG_I, read, rs, newCmd, offset=24)
	    elif tokens[i] == '%sp' or tokens[i] == 'sp':
		tokens[i] = tokens[i].replace('sp', 'o6')
		newCmd = ' '.join(tokens)
		#sys.stderr.write('DBX: RegisterMap: sp <%s><%s>' % (cmd, newCmd))
		return self.specialRule2(REG_O, read, rs, newCmd, offset=8)
	    else:
		i += 1

	# get here mean trouble
	raise RuntimeError, 'DBX: RegisterMap: regHack(%s) miss' % (cmd)


    def hasKey (self, key):
	"""
	"""
	return self.regMap.has_key(key)


"""self-testing
"""
if __name__ == "__main__":
    """
    """
    pass
