/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: dmmu_miss_handler_ext.s
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
dmmu_miss_handler_ext:
dmmu_ps0:
	cmp	%g4, -1			! if all 1's, follow link
	be,a	%xcc, dmmu_ptr_chase
	mov	0, %g7			! remember ptr chase from ps0
	srlx	%g5, 63, %g3		! if not valid, check ps1
	brz	%g3, dmmu_ps1

#ifndef SUN4V
	sllx	%g5, 15, %g3		! extract size[2]
	srlx	%g3, 61, %g3
	sllx	%g5, 1, %g1		! extract size[1:0]
	srlx	%g1, 62, %g1
	or	%g3, %g1, %g1		! %g1 = size[2:0]
#else
	sllx	%g5, 61, %g1
	srlx	%g1, 61, %g1            ! %g1 = size[2:0]
#endif
	mulx	%g1, 3, %g1
	sub	%g0, 1, %g3
	sllx	%g3, 13, %g3
	sllx	%g3, %g1, %g3
        sethi   %hi(0x00001fff), %g1
        or      %g1, 0xfff, %g1
	or	%g3, %g1, %g3		! %g3 = va/ctxt mask based on size[2:0]

	and	%g2, %g3, %g3		! apply mask
	cmp	%g3, %g4		! check if va/ctxt match
	be,a	%xcc, dmmu_trap_done
	mov	0x80, %g1		! offset (VA) for patrition id
		
dmmu_ps1:
	ldxa	[%g0] 0x5a, %g1		! dmmu ps1 ptr
	ldda	[%g1] 0x24, %g4		! load tte from ps1 tsb
	cmp	%g4, -1			! if all 1's, follow link
	be,a	%xcc, dmmu_ptr_chase
	mov	1, %g7			! remember ptr chase from ps1
	srlx	%g5, 63, %g3		! if not valid, bad_trap
	cmp	%g3, %g0
	te	%xcc, T_BAD_TRAP

#ifndef SUN4V
	sllx	%g5, 15, %g3		! extract size[2]
	srlx	%g3, 61, %g3
	sllx	%g5, 1, %g1		! extract size[1:0]
	srlx	%g1, 62, %g1
	or	%g3, %g1, %g1		! %g1 = size[2:0]
#else
	sllx	%g5, 61, %g1
	srlx	%g1, 61, %g1            ! %g1 = size[2:0]
#endif
	mulx	%g1, 3, %g1
	sub	%g0, 1, %g3
	sllx	%g3, 13, %g3
	sllx	%g3, %g1, %g3
        sethi   %hi(0x00001fff), %g1
        or      %g1, 0xfff, %g1
	or	%g3, %g1, %g3		! %g3 = va/ctxt mask based on size[2:0]

	and	%g2, %g3, %g3		! apply mask
	cmp	%g3, %g4		! check if va/ctxt match
	be,a	%xcc, dmmu_trap_done
	mov	0x80, %g1		! offset (VA) for patrition id

 	ta	T_BAD_TRAP
	nop
	
dmmu_ptr_chase:
 	or 	%g5, %g0, %g6           ! %g6 is link-reg
dmmu_ptr_chase_loop:
	ldda	[%g6] 0x24, %g4		! load tte from tsb

#ifndef SUN4V
	sllx	%g5, 15, %g3		! extract size[2]
	srlx	%g3, 61, %g3
	sllx	%g5, 1, %g1		! extract size[1:0]
	srlx	%g1, 62, %g1
	or	%g3, %g1, %g1		! %g1 = size[2:0]
#else
	sllx	%g5, 61, %g1
	srlx	%g1, 61, %g1            ! %g1 = size[2:0]
#endif
	mulx	%g1, 3, %g1
	sub	%g0, 1, %g3
	sllx	%g3, 13, %g3
	sllx	%g3, %g1, %g3
        sethi   %hi(0x00001fff), %g1
        or      %g1, 0xfff, %g1
	or	%g3, %g1, %g3		! %g3 = va/ctxt mask based on size[2:0]

	and	%g2, %g3, %g3		! apply mask
	cmp	%g3, %g4		! check if va/ctxt match
	be,a	%xcc, dmmu_trap_done
	mov	0x80, %g1		! offset (VA) for patrition id
	
	ldx	[%g6+16], %g6
	cmp	%g6, -1
	bne	%xcc, dmmu_ptr_chase_loop ! keep chasing pointer
	nop
	brz	%g7, dmmu_ps1		! finished ps0 pointer chasing, go to ps1
	nop
	ta	T_BAD_TRAP		! finished ps1 pointer chasing, go to bad_trap
	nop

dmmu_trap_done:
	! check to see if RA[39] is set.
	! RA[39] = 0 means accessing memory space
	! RA[39] = 1 means accessing I/O space
	mov	%g5, %g3
	sllx	%g3, 24, %g3
	srlx	%g3, 63, %g3
	brnz	%g3, dmmu_skip_part_base
	! add partition base to data-in
	setx	partition_base_list, %g3, %g2	! for partition base
	ldxa	[%g1] 0x58, %g3		! partition id
	sllx	%g3, 3, %g3		! offset - partition list
	ldx	[%g2 + %g3], %g1
	add	%g5, %g1, %g5
dmmu_skip_part_base:
#ifndef SUN4V
	stxa	%g5, [ %g0 ] 0x5c	! data-in
#else
	mov	0x400, %g6
	stxa	%g5, [ %g6 ] 0x5c	! data-in
#endif
	retry 

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
dmmu_real_miss_handler_ext:
	! check to see if RA[39] is set.
	! RA[39] = 0 means accessing memory space
	! RA[39] = 1 means accessing I/O space
	mov	%g2, %g4
	sllx	%g2, 24, %g2
	srlx	%g2, 63, %g2
	brnz	%g2, dmmu_real_skip_part_base
	mov	%g0, %g1		! %g1 will contain partition base

#ifndef DISABLE_PART_LIMIT_CHECK
	! if we get here, access is to memory space
	mov	%g4, %g2
	srlx	%g2, 33, %g2		! check to see if ra exceeds 8GB limit
	cmp	%g2, %g0
	tne	%xcc, T_BAD_TRAP
#endif

	! add partition base to data-in
	setx	partition_base_list, %g1, %g2	! for partition base
	mov	0x80, %g1		! offset (VA) for patrition id
	ldxa	[%g1] 0x58, %g3		! partition id
	sllx	%g3, 3, %g3		! offset - partition list
	ldx	[%g2 + %g3], %g1

dmmu_real_skip_part_base:
#ifdef REAL_DATA_ATTR
        setx    REAL_DATA_ATTR, %g2, %g5 ! user defined attributes
#else
#ifndef SUN4V
	setx	0x8000000000000022, %g2, %g5 ! CP W
#else
	setx	0x8000000000000440, %g2, %g5 ! CP W
#endif
#endif
	srlx	%g4, 13, %g4		! get rid of garbage in context field
	sllx	%g4, 13, %g4
	or	%g4, %g5, %g5
	add	%g5, %g1, %g5		! add partition base %g1 is zero
					! if we choose to skip the add
	mov	0x30, %g7
#ifndef SUN4V
	mov	0x200, %g6
#else
	mov	0x600, %g6
#endif
	stxa	%g4, [ %g7 ] 0x58	! {tag-access, data-in}
	stxa	%g5, [ %g6 ] 0x5c
	retry 
