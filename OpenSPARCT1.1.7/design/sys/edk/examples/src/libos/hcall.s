/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: hcall.s
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



/*
 * Write one character to the console
 * 
 * Input: %o0 - character
 *
 * Return: -1 on failure, otherwise 0
 *
 */

ENTRY(hv_cnputchar)
	mov	CONS_WRITE, %o5
	ta	FAST_TRAP
	tst	%o0
	retl
	movnz	%xcc, -1, %o0
SET_SIZE(hv_cnputchar)



ENTRY(hv_version_init)
	set  API_SET_VERSION, %o5
	ta   CORE_TRAP
	retl
	nop
SET_SIZE(hv_version_init)

