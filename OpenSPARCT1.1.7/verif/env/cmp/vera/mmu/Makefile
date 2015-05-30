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
##
## File:	Makefile.inc
## Description:
## -----------
##	Common part of Makefile for unit directories.
##	This is included in <unit>/Makefile
## Caution:
## -------
##	Only works with "gmake".
##
##
################################################################################

################################################################################
# variable declarations
################################################################################

ECHO	:= echo
INDENT	:= "  "

.SUFFIXES:

ifndef UNIT
    UNIT         := $(CURDIR)
    UNIT         := $(notdir $(UNIT))
endif

VERA_LIBDIR  ?= ../lib
MAKEFILES    := Makefile

SRC_FILES    := $(wildcard *.vr)

## put PAL files in order they need to be built
SRC_PAL_FIRST := $(wildcard *ports_binds*) $(wildcard *vcon*)
SRC_PAL_FIRST += $(wildcard *if.vrh*) $(VERA_DEFINES)
SRC_PAL_SEC   := $(wildcard *pal)
#SRC_PAL_SEC   := l1_stub.vrpal l1_checker.vrpal
SRC_PAL_SEC   := $(filter-out $(SRC_PAL_FIRST) %.pal,$(SRC_PAL_SEC))
SRC_PAL_FILES := $(SRC_PAL_FIRST) $(SRC_PAL_SEC)

## now go through gyrations to get build order right
DEST_FILES    := $(SRC_PAL_FILES:%pal=$(VERA_LIBDIR)/%)
DEST_FILES    += $(SRC_FILES:%=$(VERA_LIBDIR)/%)
DEST_STAGE1   := $(DEST_FILES)
DEST_VR       := $(filter %.vr,$(DEST_FILES))
DEST_FILES    := $(filter-out $(DEST_VR),$(DEST_FILES))
DEST_VRO      := $(DEST_VR:.vr=.vro)
DEST_VRO_LAST := $(filter %_coverage.vro,$(DEST_VRO))
DEST_VRO      := $(filter-out $(DEST_VRO_LAST),$(DEST_VRO))
DEST_STAGE2   := $(DEST_VRO)
DEST_VRO      += $(DEST_VRO_LAST)
DEST_STAGE3   := $(DEST_VRO_LAST) $(DEST_VRO_LAST:.vro=.vrh)
DEST_VRH      := $(DEST_VRO:.vro=.vrh)
DEST_FILES    += $(DEST_VRH) $(DEST_VRO) $(DEST_VR)
DEST_FILES    += $(DEST_TOP_BLT)

VERA_VRH   ?= vera -cmp -I . -max_error 5 -q -H $(VFLAGS)
VERA_VRO   ?= vera -cmp -I . -max_error 5 -q $(VFLAGS)

## PAL_OPTS gets overridden by command line argument for multi-core sims.
## For example, for sys=cmp1, cmd line is:
##	gmake PAL_OPTS="sys=CMP1"
## or
##	gmake PAL_OPTS="cores=2"
##
PAL_OPTS=

################################################################################
# rules
################################################################################

###################
# preprocessing
###################

$(VERA_LIBDIR)/%.vcon: %.vconpal $(PAL_INCLUDES)
	@$(ECHO) $(INDENT) "Expanding $<"
	pal -r $(PAL_OPTS) -o $@ $<

$(VERA_LIBDIR)/%.vrh: %.vrhpal $(PAL_INCLUDES)
	@$(ECHO) $(INDENT) "Expanding $<"
	pal -r $(PAL_OPTS) -o $@ $<

$(VERA_LIBDIR)/%.vr: %.vrpal $(PAL_INCLUDES)
	@$(ECHO) $(INDENT) "Expanding $<"
	pal -r $(PAL_OPTS) -o $@ $<

$(VERA_LIBDIR)/%.vrh: $(VERA_LIBDIR)/%.vr $(HEADERS)
	@$(ECHO) $(INDENT) "Vera: generating headers for $(notdir $<)"
	cd $(VERA_LIBDIR); $(VERA_VRH) $(notdir $<) $(notdir $(@:%.vrh=%))

$(VERA_LIBDIR)/%.vro: $(VERA_LIBDIR)/%.vr $(VERA_LIBDIR)/%.vrh $(HEADERS)
	@$(ECHO) $(INDENT) "Vera: compiling $(notdir $<)"
	cd $(VERA_LIBDIR); $(VERA_VRO) $(notdir $<) $(notdir $@)

$(VERA_LIBDIR)/%: %
	@$(ECHO) $(INDENT) "Copying $<"
	cp -f $< $@

################################################################################
# all
################################################################################
.PHONY: all clean srcs dests unit
ifndef DEBUG
.SILENT:
endif

all: $(DEST_FILES)

################################################################################
# additional dependences and flag target
################################################################################
$(DEST_TOP_VR):

$(DEST_TOP_BLT): $(DEST_TOP_VRO)
	echo $(PAL_OPTS) > $@

$(DEST_STAGE2): $(DEST_STAGE1)

$(DEST_STAGE3): $(DEST_STAGE2)

$(DEST_STAGE1): $(MAKEFILES)

################################################################################
# clean
################################################################################

clean:
	rm -f $(DEST_FILES)

srcs:
	@ echo $(SRC_FILES)
dests:
	@ echo $(DEST_FILES)

unit:
	@ echo $(UNIT)

