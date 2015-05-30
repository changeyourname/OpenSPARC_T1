/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: t1_stdio.h
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
#ifndef _T1_STDIO_H
#define _T1_STDIO_H

#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif


extern int t1_puts(const char *string);
extern int t1_putx(const uint64_t lvalue);


#ifdef __cplusplus
}
#endif


#endif /* ifndef _T1_STDIO_H */
