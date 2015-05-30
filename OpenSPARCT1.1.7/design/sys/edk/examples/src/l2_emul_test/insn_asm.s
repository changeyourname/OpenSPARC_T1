/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: insn_asm.s
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/
#include <sys/asm_linkage.h>


ENTRY(ldub)
    ldub  [%o0], %o0
    jmpl  %o7 + 8, %g0
    nop
SET_SIZE(ldub)


ENTRY(lduh)
    lduh  [%o0], %o0
    jmpl  %o7 + 8, %g0
    nop
SET_SIZE(lduh)


ENTRY(lduw)
    lduw  [%o0], %o0
    jmpl  %o7 + 8, %g0
    nop
SET_SIZE(lduw)


ENTRY(ldx)
    ldx   [%o0], %o0
    jmpl  %o7 + 8, %g0
    nop
SET_SIZE(ldx)





ENTRY(stb)
    stb   %o1, [%o0]
    jmpl  %o7 + 8, %g0
    nop
SET_SIZE(stb)


ENTRY(sth)
    sth   %o1, [%o0]
    jmpl  %o7 + 8, %g0
    nop
SET_SIZE(sth)


ENTRY(stw)
    stw   %o1, [%o0]
    jmpl  %o7 + 8, %g0
    nop
SET_SIZE(stw)


ENTRY(stx)
    stx   %o1, [%o0]
    jmpl  %o7 + 8, %g0
    nop
SET_SIZE(stx)



ENTRY(swap)
    swap  [%o0], %o1
    mov   %o1, %o0
    jmpl  %o7 + 8, %g0
    nop
SET_SIZE(swap)


ENTRY(cas)
    cas   [%o0], %o1, %o2
    mov   %o2, %o0
    jmpl  %o7 + 8, %g0
    nop
SET_SIZE(cas)


ENTRY(casx)
    casx  [%o0], %o1, %o2
    mov   %o2, %o0
    jmpl  %o7 + 8, %g0
    nop
SET_SIZE(casx)


ENTRY(ldstub)
    ldstub [%o0], %o0
    jmpl   %o7 + 8, %g0
    nop
SET_SIZE(ldstub)
