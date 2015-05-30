/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_addr_map.h
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
#ifndef MBFW_ADDR_MAP_H_
#define MBFW_ADDR_MAP_H_


#include "mbfw_types.h"
#include "mbfw_pcx_cpx.h"


#ifdef  __cplusplus
extern "C" {
#endif


enum addr_type translate_addr(struct pcx_pkt  *pcx_pkt,
			      taddr_t          t1_addr,
			      maddr_t         *mb_addr_ptr);


#ifdef  __cplusplus
}
#endif


#endif /* ifndef MBFW_ADDR_MAP_H_ */
