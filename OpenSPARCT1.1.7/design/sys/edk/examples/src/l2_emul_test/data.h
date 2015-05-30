/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: data.h
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
#ifndef DATA_H_
#define DATA_H_


#include <sys/types.h>


#ifdef __cplusplus
extern "C" {
#endif


typedef uint32_t  Elem;

extern Elem test_memory_data[];
extern Elem expected_memory_data[];


#ifdef __cplusplus
}
#endif

#endif /* ifndef DATA_H_ */
