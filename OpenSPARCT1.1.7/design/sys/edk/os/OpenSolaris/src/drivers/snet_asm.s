/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: snet_asm.s
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
/*
 * Copyright 2007 Sun Microsystems, Inc.  All rights reserved.
 * Use is subject to license terms.
 */

#pragma ident	"@(#)snet_asm.s	1.2	06/06/27 SMI"

/*
 * Hypervisor simulation net read/write calls
 */

#include <sys/asm_linkage.h>
#include <sys/machasi.h>
#include <sys/machparam.h>
#include <sys/hypervisor_api.h>

#ifndef NET_READ
#define	NET_READ	0xf2
#endif
#ifndef NET_WRITE
#define	NET_WRITE	0xf3
#endif

#if defined(lint) || defined(__lint)	/* { */

/*ARGSUSED*/
size_t
hv_snet_read(uint64_t offset, uint64_t pa, size_t size)
{
	return (0);
}

/*ARGSUSED*/
size_t
hv_snet_write(uint64_t pa, size_t size)
{
	return (0);
}

#else	/* } { lint || __lint */

	/*
	 * %o0 - net offset
	 * %o1 - target real address
	 * %o2 - size
	 */
	ENTRY(hv_snet_read)
	mov	NET_READ, %o5
	ta	FAST_TRAP
	tst	%o0
	movz	%xcc, %o1, %o0
	retl
	movnz	%xcc, -1, %o0
	SET_SIZE(hv_snet_read)

	/*
	 * %o0 - net offset
	 * %o1 - target real address
	 * %o2 - size
	 */
	ENTRY(hv_snet_write)
	mov	NET_WRITE, %o5
	ta	FAST_TRAP
	tst	%o0
	movz	%xcc, %o1, %o0
	retl
	movnz	%xcc, -1, %o0
	SET_SIZE(hv_snet_write)

#endif	/* } lint || __lint */

