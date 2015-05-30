/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: stand_init.s
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

#include <hcall.h>
#include <config.h>


/*
 * Notes:
 *
 * 1) "Power-on-reset" trap calls this function _start. Hypervisor
 *     first gives control to the instruction at "power-on-reset" trap.
 *
 * 2) When the function main() returns, control comes back to this function
 *    and eventually goes into infinite loop. Currently there is no mechanism
 *    to restart the stand-alone program automatically.
 *
 * 3) stand-alone program's stack is setup at the end of the guest memory.
 *    The hypervisor passes GUEST_MEM_BASE and GUEST_MEM_SIZE in %i0 and %i1
 *    registers.
 *
 */


ENTRY(_start)
	wrpr   %g0, 7, %cleanwin
        wrpr   %g0, 0, %otherwin
        wrpr   %g0, 0, %wstate
        wrpr   %g0, 0, %canrestore
        wrpr   %g0, 6, %cansave
        wrpr   %g0, 0, %cwp
        wrpr   %g0, 1, %gl
        wrpr   %g0, 1, %tl

	setx   trap_table, %o0, %o1
	wrpr   %o1, %tba

	add    %i0, %i1, %o0                 /* end of guest memory */
	set    (V9BIAS64 + MINFRAME64), %o1
	sub    %o0, %o1, %fp
	sub    %fp, MINFRAME64, %sp

	set    API_GROUP_CORE,     %o0
	set    CORE_MAJOR_VERSION, %o1
	set    CORE_MINOR_VERSION, %o2

	call   hv_version_init
	nop

        mov    %g0, %o0
        mov    %g0, %o1
        mov    %g0, %o2
        mov    %g0, %o3
        mov    %g0, %o4
        mov    %g0, %o5

        wrpr   %g0, 0, %gl
        wrpr   %g0, 0, %tl

	call   main
	nop

        ba     0f
	rd     %pc, %o0
        .ascii "Guest stand-alone program has terminated."
	.asciz	"\n"
	.align	4
0:
        add    %o0, 4, %o0
	call   t1_puts
	nop

        ba     1f
	rd     %pc, %o0
        .ascii "Entering infinite loop."
	.asciz	"\n"
	.align	4
1:
        add    %o0, 4, %o0
	call   t1_puts
	nop

infinite_loop:
	ba,a  infinite_loop
	nop

SET_SIZE(_start)
