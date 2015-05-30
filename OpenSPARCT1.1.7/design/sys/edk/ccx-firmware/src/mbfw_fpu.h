/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_fpu.h
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
#ifndef MBFW_FPU_H_
#define MBFW_FPU_H_

#include "mbfw_pcx_cpx.h"


#ifdef  __cplusplus
extern "C" {
#endif

void process_fp_1(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt);
void process_fp_2(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt);


#ifdef  __cplusplus
}
#endif


#endif /* ifndef MBFW_FPU_H_ */
