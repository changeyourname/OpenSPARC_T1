/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: insn_asm.h
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
#ifndef INSN_ASM_H_
#define INSN_ASM_H_


#include <sys/types.h>


#ifdef __cplusplus
extern "C" {
#endif

#ifndef _ASM

extern uint64_t ldub(uintptr_t addr);
extern uint64_t lduh(uintptr_t addr);
extern uint64_t lduw(uintptr_t addr);
extern uint64_t ldx(uintptr_t addr);

extern void     stb(uintptr_t addr, uint64_t lvalue);
extern void     sth(uintptr_t addr, uint64_t lvalue);
extern void     stw(uintptr_t addr, uint64_t lvalue);
extern void     stx(uintptr_t addr, uint64_t lvalue);

extern uint64_t swap(uintptr_t addr, uint64_t lvalue);
extern uint64_t cas(uintptr_t addr, uint64_t old_value, uint64_t lvalue);
extern uint64_t casx(uintptr_t addr, uint64_t old_value, uint64_t lvalue);
extern uint64_t ldstub(uintptr_t addr);


#endif /* #ifndef _ASM */


#ifdef __cplusplus
}
#endif

#endif /* ifndef INSN_ASM_H_ */
