/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_reverse_dir.h
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
#ifndef MBFW_REVERSE_DIR_H_
#define MBFW_REVERSE_DIR_H_

#include "mbfw_types.h"


#ifdef  __cplusplus
extern "C" {
#endif


#define  T1_ICACHE_LINE_SIZE       32
#define  T1_DCACHE_LINE_SIZE       16
#define  T1_L2_CACHE_LINE_SIZE     64


void  init_l1_reverse_dir(void);

void  add_icache_line(int core_id, taddr_opt_t t1_addr, int way);
void  add_dcache_line(int core_id, taddr_opt_t t1_addr, int way);

int   search_icache(int core_id, taddr_opt_t t1_addr);
int   search_dcache(int core_id, taddr_opt_t t1_addr);

int   invalidate_icache(int core_id, taddr_opt_t t1_addr);
int   invalidate_dcache(int core_id, taddr_opt_t t1_addr);

void  icache_invalidate_all_ways(int core_id, taddr_opt_t t1_addr);
void  dcache_invalidate_all_ways(int core_id, taddr_opt_t t1_addr);

#ifdef  __cplusplus
}
#endif


#endif /* ifndef MBFW_REVERSE_DIR_H_ */
