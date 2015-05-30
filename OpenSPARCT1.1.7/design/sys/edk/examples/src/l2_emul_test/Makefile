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

include ../Makefile.common

OBJS = l2_emul_test.o insn_asm.o data.o shuffle_memory.o

TARGET     = l2_emul_test.mem.image
ELF_TARGET = l2_emul_test

DATA_FILES  = test_memory.data expected_memory.data
DATA_C_FILE = data.c

all: $(TARGET)

$(TARGET): $(ELF_TARGET)
	$(ROOT)/utils/elf_to_mem_image $(ELF_TARGET)

$(ELF_TARGET): $(OBJS)
	$(LD) -64 -e _start -dn -M $(ROOT)/mapfile -o $@ -z allextract -L $(LIBOS_PATH) -los $(OBJS) -L $(LIBC_PATH) -lc


data.o: $(DATA_C_FILE)


$(DATA_C_FILE): $(DATA_FILES)
	$(ROOT)/utils/file2array $(DATA_FILES) > $(DATA_C_FILE)


RANDMEM_OBJS = randmem.o insn_asm.o shuffle_memory.o
RANDMEM = randmem

$(RANDMEM): $(RANDMEM_OBJS)
	$(CC) $(CFLAGS) -o $@ $(RANDMEM_OBJS)


$(DATA_FILES): $(RANDMEM)
	./$(RANDMEM)


clean:
	$(RM) $(OBJS) $(RANDMEM_OBJS) $(DATA_C_FILE) $(DATA_FILES)

clobber: clean
	$(RM) $(TARGET) $(ELF_TARGET) $(RANDMEM)

install: $(TARGET)
	$(CP) $(TARGET) $(INSTALL_DIR)

