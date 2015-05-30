/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_debug.h
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
#ifndef MBFW_DEBUG_H_
#define MBFW_DEBUG_H_


#if  MBFW_DEBUG > 0

#include "mbfw_pcx_cpx.h"


#ifdef  __cplusplus
extern "C" {
#endif

void mbfw_debug_pcx_pkt(struct pcx_pkt *pcx_pkt);
void mbfw_debug_cpx_pkt(struct cpx_pkt *cpx_pkt);


#ifdef  __cplusplus
}
#endif

#endif /* if MBFW_DEBUG > 0 */


#endif /* ifndef MBFW_DEBUG_H_ */
