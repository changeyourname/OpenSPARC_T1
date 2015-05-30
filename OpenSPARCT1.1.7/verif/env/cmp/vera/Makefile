# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: Makefile
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
################################################################################
## File:	Makefile
## Notes:	runs with "gmake" only, not with "make"
## Description:
## -----------
##	Top level Makefile for compiling Vera cmp/ciop environment.
##	Makefiles in coverage directories are called from here.
################################################################################

################################################################################
# variable declarations
################################################################################

SYS := cmp
## Coverage top level directory
CTOP := .
ifeq ($(SYS),ciop)
CTOP := ../../cmp/vera
endif

# ISS_TOP to get to jbi_coverage directory 
ISS_TOP := $(DV_ROOT)/verif/env/iss/vera

ECHO := echo
PID  := $(shell echo $$$$)	## :-). Just get a random number

## parallel make at sub-dir level
ifndef p
p := 1
endif

.SUFFIXES:

VERA_LIBDIR    ?= ./lib

## Coverage users
## -------- ----- 
##	1. add <unit> to COV_UNITS
##      2. Add entry for <unit> below "all"
##
## Look for "Coverage edit", below.
## Remember to use "gmake" instead of "make" when testing.

## Selectively turn on coverage units needed
## Coverage edit (1)
EXCLUDED_UNITS := mmu lsu spu tso ifu ffu fpu exu err tlu mt
EXCLUDED_UNITS += dram cmpmss coreccx iob_cov jbi

COV_UNITS      :=
VERA_DEFS      ?=
ifdef LSU_COVERAGE
COV_UNITS      += lsu
VERA_DEFS      += -DLSU_COVERAGE
endif
ifdef LSUEXT_COVERAGE
ifeq (,$(findstring lsu,$(COV_UNITS)))
COV_UNITS      += lsu
endif
ifeq (,$(findstring LSU_COVERAGE,$(VERA_DEFS)))
VERA_DEFS      += -DLSU_COVERAGE
endif
VERA_DEFS      += -DLSUEXT_COVERAGE
endif
ifdef SPU_COVERAGE
COV_UNITS      += spu
VERA_DEFS      += -DSPU_COVERAGE
endif
ifdef TSO_COVERAGE
COV_UNITS      += tso
VERA_DEFS      += -DTSO_COVERAGE
endif
ifdef IFU_COVERAGE
COV_UNITS      += ifu
VERA_DEFS      += -DIFU_COVERAGE
endif
ifdef MMU_COVERAGE
COV_UNITS      += mmu
VERA_DEFS      += -DMMU_COVERAGE
endif
ifdef FFU_COVERAGE
COV_UNITS      += ffu
VERA_DEFS      += -DFFU_COVERAGE
endif
ifdef FPU_COVERAGE
COV_UNITS      += fpu
VERA_DEFS      += -DFPU_COVERAGE
endif
ifdef EXU_COVERAGE
COV_UNITS      += exu
VERA_DEFS      += -DEXU_COVERAGE
endif
ifdef ERR_COVERAGE
COV_UNITS      += err
VERA_DEFS      += -DERR_COVERAGE
endif
ifdef TLU_COVERAGE
COV_UNITS      += tlu
VERA_DEFS      += -DTLU_COVERAGE
endif
ifdef MT_COVERAGE
COV_UNITS      += mt
VERA_DEFS      += -DMT_COVERAGE
endif
ifdef DRAM_COVERAGE
COV_UNITS      += dram
VERA_DEFS      += -DDRAM_COVERAGE
endif
ifdef CMPMSS_COVERAGE
COV_UNITS      += cmpmss
VERA_DEFS      += -DCMPMSS_COVERAGE
endif
ifdef CORECCX_COVERAGE
COV_UNITS      += coreccx
VERA_DEFS      += -DCORECCX_COVERAGE
endif
ifdef IOB_COVERAGE
COV_UNITS      += iob_cov 
VERA_DEFS      += -DIOB_COVERAGE
endif
ifdef JBI_COVERAGE
COV_UNITS      += jbi
VERA_DEFS      += -DJBI_COVERAGE
endif
EXCLUDED_UNITS := $(filter-out $(COV_UNITS),$(EXCLUDED_UNITS))

## Checker or stub units 
ifdef NO_CHECKERS
VERA_DEFS	+= -DNO_CHECKERS
else
UNITS      	:= L1 IOB MMU
endif
ifdef JBI_CKR
UNITS           += JBI
VERA_DEFS       += -DJBI_CKR
endif

## When top level coverage objects are built, they update <unit>_built
## target file.
## These are used to decide if $(SYS)_top.vro needs to be recompiled
COV_BUILT      := $(COV_UNITS:%=$(VERA_LIBDIR)/%_built)

VFLAGS   ?=
VRHFLAGS := $(VFLAGS)
VROFLAGS := $(VFLAGS)

VRHFLAGS += $(VERA_DEFS)
VROFLAGS += $(VERA_DEFS)

VERA_VRH       ?= vera -cmp -I . -max_error 5 -q $(VRHFLAGS) -H
VERA_VRO       ?= vera -cmp -I . -max_error 5 -q $(VROFLAGS)

HDL_INCLUDE    := $(VERA_LIBDIR)/iop_rtl.h $(VERA_LIBDIR)/sys_rtl.h 
## jbi.h may not be needed since defines placed explicitly 
## HDL_INCLUDE    += $(VERA_LIBDIR)/jbi_rtl.h

VERA_INCLUDE   := $(wildcard include/*ports_binds*) $(wildcard include/*vcon*)
VERA_INCLUDE   += $(wildcard include/*if.vrh*) $(wildcard include/*.vrh*)
VERA_INCLUDE   += $(wildcard include/$(SYS)_defines.vri)
VERA_INCLUDE   := $(subst include,$(VERA_LIBDIR),$(VERA_INCLUDE))
                   
RECORDS        := cpx_record.vr pcx_record.vr
RECORDS_VRH    := $(patsubst %.vr,$(VERA_LIBDIR)/%.vrh,$(RECORDS))
RECORDS_VRO    := $(patsubst %.vr,$(VERA_LIBDIR)/%.vro,$(RECORDS))

PACKETS        := cpxpacket.vr pcxpacket.vr
PACKETS_VRH    := $(patsubst %.vr,$(VERA_LIBDIR)/%.vrh,$(PACKETS))
PACKETS_VRO    := $(patsubst %.vr,$(VERA_LIBDIR)/%.vro,$(PACKETS))

BWSNIPER       := $(wildcard bwsniper/*.vr)
BWSNIPER       := $(notdir $(BWSNIPER))
BWSNIPER_VRH   := $(patsubst %.vr,$(VERA_LIBDIR)/%.vrh,$(BWSNIPER))
BWSNIPER_VRO   := $(patsubst %.vr,$(VERA_LIBDIR)/%.vro,$(BWSNIPER))

MISC           := dram.vr vera_event.vr \
                  cmp_tasks.vr err_inject.vr l2order.vr cpxorder.vr l2jbi.vr
MISC_VRH       := $(patsubst %.vr,$(VERA_LIBDIR)/%.vrh,$(MISC))
MISC_VRO       := $(patsubst %.vr,$(VERA_LIBDIR)/%.vro,$(MISC))

################################################################################
# generic rule to make a .vro file
################################################################################

$(VERA_LIBDIR)/%.vrh: $(VERA_LIBDIR)/%.vr $(HDL_INCLUDE) $(VERA_INCLUDE)
	@$(ECHO) $(INDENT) "Vera: generating headers for $(notdir $<)"
	@$(ECHO) $(VERA_VRH) $(notdir $<) $(notdir $(@:%.vrh=%))
	cd $(VERA_LIBDIR); $(VERA_VRH) $(notdir $<) $(notdir $(@:%.vrh=%))

$(VERA_LIBDIR)/%.vro: $(VERA_LIBDIR)/%.vr $(HDL_INCLUDE) $(VERA_INCLUDE)
	@$(ECHO) $(INDENT) "Vera: compiling $(notdir $<)"
	@$(ECHO) $(VERA_VRO) $(notdir $<) $(notdir $@)
	cd $(VERA_LIBDIR); $(VERA_VRO) $(notdir $<) $(notdir $@)

$(VERA_LIBDIR)/%: include/%
	@$(ECHO) $(INDENT) "Copying $<"
	cp -f $< $@

$(VERA_LIBDIR)/%: bwsniper/%
	@$(ECHO) $(INDENT) "Copying $<"
	cp -f $< $@

$(VERA_LIBDIR)/%: %
	@$(ECHO) $(INDENT) "Copying $<"
	cp -f $< $@

################################################################################
# all
################################################################################

all: dir $(HDL_INCLUDE) $(COV_UNITS) $(VERA_INCLUDE) \
     $(VERA_LIBDIR)/diag.vri \
     $(RECORDS_VRH) $(RECORDS_VRO) \
     $(PACKETS_VRH) $(PACKETS_VRO) \
     $(BWSNIPER_VRH) $(BWSNIPER_VRO) \
     $(MISC_VRH) $(MISC_VRO) \
     $(UNITS) \
     $(VERA_LIBDIR)/$(SYS)_top.vrh $(VERA_LIBDIR)/$(SYS)_top.vro

dir:
	if (test ! -d  $(VERA_LIBDIR)) then mkdir  $(VERA_LIBDIR) ; fi

################################################################################
### Begin checker and stub targets
################################################################################
MAKE_CMD := $(MAKE) --no-print-directory -j $(p)

L1:
	@$(ECHO) "[Building l1"
	if (test -d $(CTOP)/l1) then \
	( cd $(CTOP)/l1; \
		if (test -f Makefile) then $(MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with l1]"
	@$(ECHO) ""

IOB:
	@$(ECHO) "[Building iob"
	if (test -d $(CTOP)/iob) then \
	( cd $(CTOP)/iob; \
		if (test -f Makefile) then $(MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with iob]"
	@$(ECHO) ""

MMU:
	@$(ECHO) "[Building mmu"
	if (test -d $(CTOP)/mmu) then \
	( cd $(CTOP)/mmu; \
	if (test -f Makefile) then $(MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with mmu]"
	@$(ECHO) ""

JBI: 
	@$(ECHO) "[Building jbi_ckr"
	if (test -d $(ISS_TOP)) then \
	( cd $(ISS_TOP); \
	if (test -f Makefile) then \
		gmake TOP_PATH_STR=cmp_top jbi_ckr ; fi ) \
	fi
	@$(ECHO) "Done with jbi_ckr]"
	@$(ECHO) ""

#		$(MAKE_CMD) TOP_PATH_STR=cmp_top jbi_ckr ; fi ) \


################################################################################
### Begin coverage related targets
################################################################################
COV_MAKE_CMD := $(MAKE) --no-print-directory -j $(p)

lsu: $(HDL_INCLUDE)
	@$(ECHO) "[Building lsu_coverage"
	if (test -d $(CTOP)/lsu_coverage) then \
	( cd $(CTOP)/lsu_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with lsu_coverage]"
	@$(ECHO) ""

spu: $(HDL_INCLUDE)
	@$(ECHO) "[Building spu_coverage"
	if (test -d $(CTOP)/spu_coverage) then \
	( cd $(CTOP)/spu_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with spu_coverage]"
	@$(ECHO) ""

tso: $(HDL_INCLUDE)
	@$(ECHO) "[Building tso_coverage"
	if (test -d $(CTOP)/tso_coverage) then \
	( cd $(CTOP)/tso_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with tso_coverage]"
	@$(ECHO) ""

tlu: $(HDL_INCLUDE)
	@$(ECHO) "[Building tlu_coverage"
	if (test -d $(CTOP)/tlu_coverage) then \
	( cd $(CTOP)/tlu_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with tlu_coverage]"
	@$(ECHO) ""

ifu: $(HDL_INCLUDE)
	@$(ECHO) "[Building ifu_coverage"
	if (test -d $(CTOP)/ifu_coverage) then \
	( cd $(CTOP)/ifu_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with ifu_coverage]"
	@$(ECHO) ""

mmu: $(HDL_INCLUDE)
	@$(ECHO) "[Building mmu_coverage"
	if (test -d $(CTOP)/mmu_coverage) then \
	( cd $(CTOP)/mmu_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with mmu_coverage]"
	@$(ECHO) ""

ffu: $(HDL_INCLUDE)
	@$(ECHO) "[Building ffu_coverage"
	if (test -d $(CTOP)/ffu_coverage) then \
	( cd $(CTOP)/ffu_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with ffu_coverage]"
	@$(ECHO) ""

fpu: $(HDL_INCLUDE)
	@$(ECHO) "[Building fpu_coverage"
	if (test -d $(CTOP)/fpu_coverage) then \
	( cd $(CTOP)/fpu_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with fpu_coverage]"
	@$(ECHO) ""

exu: $(HDL_INCLUDE)
	@$(ECHO) "[Building exu_coverage"
	if (test -d $(CTOP)/exu_coverage) then \
	( cd $(CTOP)/exu_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with exu_coverage]"
	@$(ECHO) ""

err: $(HDL_INCLUDE)
	@$(ECHO) "[Building err_coverage"
	if (test -d $(CTOP)/err_coverage) then \
	( cd $(CTOP)/err_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with err_coverage]"
	@$(ECHO) ""

mt: $(HDL_INCLUDE)
	@$(ECHO) "[Building mt_coverage"
	if (test -d $(CTOP)/mt_coverage) then \
	( cd $(CTOP)/mt_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with mt_coverage]"
	@$(ECHO) ""

dram: $(HDL_INCLUDE)
	@$(ECHO) "[Building dram_coverage"
	if (test -d $(CTOP)/dram_coverage) then \
	( cd $(CTOP)/dram_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with dram_coverage]"
	@$(ECHO) ""

cmpmss: $(HDL_INCLUDE)
	@$(ECHO) "[Building cmpmss_coverage"
	if (test -d $(CTOP)/cmpmss_coverage) then \
	( cd $(CTOP)/cmpmss_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with cmpmss_coverage]"
	@$(ECHO) ""

coreccx: $(HDL_INCLUDE)
	@$(ECHO) "[Building coreccx_coverage"
	if (test -d $(CTOP)/coreccx_coverage) then \
	( cd $(CTOP)/coreccx_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with coreccx_coverage]"
	@$(ECHO) ""

iob_cov: $(HDL_INCLUDE)
	@$(ECHO) "[Building iob_coverage"
	if (test -d $(CTOP)/iob_coverage) then \
	( cd $(CTOP)/iob_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with iob_coverage]"
	@$(ECHO) ""

jbi: $(HDL_INCLUDE)
	@$(ECHO) "[Building jbi_coverage"
	if (test -d $(ISS_TOP)/jbi_coverage) then \
	( cd $(ISS_TOP)/jbi_coverage; \
		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
	fi
	@$(ECHO) "Done with jbi_coverage]"
	@$(ECHO) ""

## Coverage edit (2)
## Copy next three lines, paste above, edit <unit> and uncomment
#<unit>: $(HDL_INCLUDE)
#	@$(ECHO) "[Building <unit>_coverage"
#	if (test -d $(CTOP)/<unit>_coverage) then \
#	( cd $(CTOP)/<unit>_coverage; \
#		if (test -f Makefile) then $(COV_MAKE_CMD) ; fi ) \
#	fi
#	@$(ECHO) "Done with <unit>_coverage]"
#	@$(ECHO) ""

### End coverage related targets

################################################################################
# rule to make HDL_INCLUDE
################################################################################

$(VERA_LIBDIR)/sys_rtl.h: $(DV_ROOT)/design/sys/iop/include/sys.h
	@$(ECHO) "generating $@ from $(DV_ROOT)/design/sys/iop/include/sys.h"
	grep '^`define' $< | sed -e 's/^`define/#define/'  > $@

$(VERA_LIBDIR)/iop_rtl.h: $(DV_ROOT)/design/sys/iop/include/iop.h
	@$(ECHO) "generating $@ from $(DV_ROOT)/design/sys/iop/include/iop.h"
	grep '^`define' $< | sed -e 's/^`define/#define/'  > $@

## jbi.h may not be needed since defines placed explicitly 
## $(VERA_LIBDIR)/jbi_rtl.h: $(DV_ROOT)/design/sys/iop/jbi/include/jbi.h
##	@$(ECHO) "generating $@ from $$(DV_ROOT)/design/sys/iop/jbi/include/jbi.h"
##	grep '^`define' $< | sed -e 's/^`define/#define/'  > $@

################################################################################
# Extra dependences for special rebuilds
################################################################################
$(VERA_LIBDIR)/$(SYS)_top.vro: $(COV_BUILT) $(VERA_LIBDIR)/units_used
$(VERA_LIBDIR)/$(SYS)_top.vrh: $(VERA_LIBDIR)/units_used
$(VERA_LIBDIR)/units_used: FORCE
	test -f $@ || touch $@
	$(ECHO) $(COV_UNITS) > /tmp/units_used.$(PID)
	diff /tmp/units_used.$(PID) $@ > /dev/null || \
		mv /tmp/units_used.$(PID) $@
	rm -f /tmp/units_used.$(PID)
	$(ECHO) $(EXCLUDED_UNITS) > $(VERA_LIBDIR)/excluded_cov_units

## Dummy target to get above to always fire
FORCE:

.PHONY: FORCE

ifndef DEBUG
.SILENT:
endif

################################################################################
# clean
################################################################################

clean:
	@$(ECHO) "cleaning $(VERA_LIBDIR)"
	cd $(VERA_LIBDIR); rm -rf *

