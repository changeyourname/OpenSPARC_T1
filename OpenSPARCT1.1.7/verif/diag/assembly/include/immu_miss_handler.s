/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: immu_miss_handler.s
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
#ifdef EX_TRAPCHECK
	! extended trapcheck returns traptype
	mov	0x64,	%o0
#endif
	mov	0x30, %g7
	ldxa	[%g7] 0x50, %g2		! get va/context from tag-access
	ldxa	[%g0] 0x51, %g1		! immu ps0 ptr
#ifdef MIMIC_SOLARIS
	srlx	%g0, %g0, %g0
	brnz	%g0, HT0_Fast_Instr_Access_MMU_Miss_0x64
	sll	%g0, %g0, %g0
	xor	%g0, %g0, %g0
#endif
	ldda	[%g1] 0x24, %g4		! load tte from ps0 tsb
	cmp	%g2, %g4
	bne	%xcc, immu_miss_handler_ext
	nop
	ba	immu_trap_done
	mov	0x80, %g1		! offset (VA) for patrition id

