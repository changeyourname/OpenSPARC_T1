/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: hcall.h
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
#ifndef _HCALL_H
#define _HCALL_H

#ifndef _ASM
#include <sys/types.h>
#endif /* #ifndef _ASM */


#ifdef __cplusplus
extern "C" {
#endif


#define FAST_TRAP	        0x80
#define CORE_TRAP	        0xff

#define API_SET_VERSION		0x00


#define API_GROUP_CORE		0x1
#define CORE_MAJOR_VERSION	0x1
#define CORE_MINOR_VERSION	0x0

#define CONS_WRITE	        0x61


#ifndef _ASM

extern int64_t hv_cnputchar(uint8_t);

#endif /* ifndef _ASM */


#ifdef __cplusplus
}
#endif

#endif /* ifndef _HCALL_H */
