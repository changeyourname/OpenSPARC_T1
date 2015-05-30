/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: trap_table.s
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




/*
 *  Notes:
 *
 *  1) Hypervisor, by convention, gives control to the instruction at address 
 *     (GUEST_REALBASE + 0x20). trap_table must start at GUEST_REALBASE.
 *
 *  2) FP_DISABLED_TRAP occurs even for floating point loads. 
 *
 *  3) spill/fill traps are implemented so that nested and/or recursive function
 *     calls are supported.
 *
 *  4) Unimplemented traps call priv_trap function which prints the trap number
 *     and goes into an infinite loop
 *
 */



#define PRIV_TRAP			 \
	.global priv_trap		;\
	ba,a	priv_trap		;\
	nop				;\
	.align	32



#define PRIV_TRAP4   PRIV_TRAP; PRIV_TRAP; PRIV_TRAP; PRIV_TRAP


#define	FPRS_FEF	0x4	    /* enable fp */
#define	PSTATE_PEF	0x00000010  /* fpu enable */




#define FP_DISABLED_TRAP()		\
	rdpr	%tstate, %g1           ;\
	set	PSTATE_PEF, %g2        ;\
	sllx    %g2, 8, %g2            ;\
	or      %g2, %g1, %g1          ;\
	wrpr	%g1, %g0, %tstate      ;\
	wr	%g0, FPRS_FEF, %fprs   ;\
	retry                          ;\
	nop


#define SPILL_64bit()					         \
  	stx	%l0, [%sp + V9BIAS64 + 0]			;\
	stx	%l1, [%sp + V9BIAS64 + 8]			;\
	stx	%l2, [%sp + V9BIAS64 + 16]			;\
	stx	%l3, [%sp + V9BIAS64 + 24]			;\
	stx	%l4, [%sp + V9BIAS64 + 32]			;\
	stx	%l5, [%sp + V9BIAS64 + 40]			;\
	stx	%l6, [%sp + V9BIAS64 + 48]			;\
	stx	%l7, [%sp + V9BIAS64 + 56]			;\
	stx	%i0, [%sp + V9BIAS64 + 64]			;\
	stx	%i1, [%sp + V9BIAS64 + 72]			;\
	stx	%i2, [%sp + V9BIAS64 + 80]			;\
	stx	%i3, [%sp + V9BIAS64 + 88]			;\
	stx	%i4, [%sp + V9BIAS64 + 96]			;\
	stx	%i5, [%sp + V9BIAS64 + 104]			;\
	stx	%i6, [%sp + V9BIAS64 + 112]			;\
	stx	%i7, [%sp + V9BIAS64 + 120]			;\
	saved                                                   ;\
	retry                                                   ;\
	nop; nop; nop; nop;                                     ;\
	nop; nop; nop; nop;                                     ;\
	nop; nop; nop; nop;                                     ;\
	nop; nop


#define FILL_64bit()					         \
	ldx	[%sp + V9BIAS64 + 0], %l0			;\
	ldx	[%sp + V9BIAS64 + 8], %l1			;\
	ldx	[%sp + V9BIAS64 + 16], %l2			;\
	ldx	[%sp + V9BIAS64 + 24], %l3			;\
	ldx	[%sp + V9BIAS64 + 32], %l4			;\
	ldx	[%sp + V9BIAS64 + 40], %l5			;\
	ldx	[%sp + V9BIAS64 + 48], %l6			;\
	ldx	[%sp + V9BIAS64 + 56], %l7			;\
	ldx	[%sp + V9BIAS64 + 64], %i0			;\
	ldx	[%sp + V9BIAS64 + 72], %i1			;\
	ldx	[%sp + V9BIAS64 + 80], %i2			;\
	ldx	[%sp + V9BIAS64 + 88], %i3			;\
	ldx	[%sp + V9BIAS64 + 96], %i4			;\
	ldx	[%sp + V9BIAS64 + 104], %i5			;\
	ldx	[%sp + V9BIAS64 + 112], %i6			;\
	ldx	[%sp + V9BIAS64 + 120], %i7			;\
	restored						;\
	retry   						;\
	nop; nop; nop; nop;                                     ;\
	nop; nop; nop; nop;                                     ;\
	nop; nop; nop; nop;                                     ;\
	nop; nop




#define GOTO(label)		\
	.global label		;\
	ba,a	label		;\
	nop			;\
	.align	32






	.section ".text"
	.align	0x8000
	.global trap_table
	.type	trap_table, #function
trap_table:
trap_table0:
	PRIV_TRAP; GOTO(_start); PRIV_TRAP; PRIV_TRAP;		/* 0x000 */
	            PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x004 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x010 */
	FP_DISABLED_TRAP(); PRIV_TRAP; PRIV_TRAP; PRIV_TRAP;    /* 0x020 */
		    PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x024 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x030 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x040 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x050 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x060 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x070 */
        SPILL_64bit();                                          /* 0x080 */
	            PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x084 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x090 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0a0 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0b0 */
        FILL_64bit();                                           /* 0x0c0 */
	            PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0c4 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0d0 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0e0 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0f0 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x100 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x110 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x120 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x130 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x140 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x150 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x160 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x170 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x180 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x190 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1a0 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1b0 */
        PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1c0 */
        PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1d0 */
        PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1e0 */
        PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1f0 */
        .size	trap_table0, (.-trap_table0)
trap_table1:
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x000 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x010 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x020 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x030 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x040 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x050 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x060 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x070 */
        SPILL_64bit();                                          /* 0x080 */
	            PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x084 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x090 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0a0 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0b0 */
        FILL_64bit();                                           /* 0x0c0 */
	            PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0c4 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0d0 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0e0 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x0f0 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x100 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x110 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x120 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x130 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x140 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x150 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x160 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x170 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x180 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x190 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1a0 */
	PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1b0 */
        PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1c0 */
        PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1d0 */
        PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1e0 */
        PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4; PRIV_TRAP4;		/* 0x1f0 */
        .size	trap_table1, (.-trap_table1)
        .size	trap_table, (.-trap_table)






/*
 * This function destroys user application registers and is not
 * expected to return.
 */

ENTRY(priv_trap)

	rdpr    %tt, %g5

        ba      0f
        rd      %pc, %g6
        .asciz  "\nERROR: Unimplemented trap 0x"
        .align  4
0:
        add     %g6, 4, %o0
	call    t1_puts
	nop

        mov     %g5, %o0
	call    t1_putx
	nop

        ba      1f
        rd      %pc, %g6
        .asciz  "\n"
        .align  4
1:
        add     %g6, 4, %o0
	call    t1_puts
	nop


        ba      2f
	rd      %pc, %o0
        .asciz  "Entering infinite loop.\n"
	.align	4
2:
        add     %o0, 4, %o0
	call    t1_puts
	nop

3:
	ba,a  3b
	nop


SET_SIZE(priv_trap)
