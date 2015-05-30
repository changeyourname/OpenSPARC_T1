/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: shuffle_memory.h
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
#ifndef SHUFFLE_MEMORY_H_
#define SHUFFLE_MEMORY_H_


#include <sys/types.h>

#include "data.h"


#ifdef __cplusplus
extern "C" {
#endif


#define LOOP_COUNT         1
#define MAX_ERROR_COUNT    10



#define TEST_MEMORY_ALIGNMENT     128

#define TEST_MEMORY_SIZE          (10 * 1024)
#define TEST_MEMORY_WORDS         (TEST_MEMORY_SIZE / sizeof(Elem))



extern int shuffle_memory(Elem *test_memory);
extern int verify_results(Elem *test_memory, Elem *expected_memory);

extern int loop_count;
extern int verbose_flag;


#ifdef __cplusplus
}
#endif


#endif /* ifndef SHUFFLE_MEMORY_H_ */
