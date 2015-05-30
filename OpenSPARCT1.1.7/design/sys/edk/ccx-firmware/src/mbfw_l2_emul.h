/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_l2_emul.h
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
#ifndef MBFW_L2_EMUL_H_
#define MBFW_L2_EMUL_H_

#include "mbfw_types.h"
#include "mbfw_pcx_cpx.h"


#ifdef  __cplusplus
extern "C" {
#endif


#define  INVALIDATE_NONE 	       0x0
#define  INVALIDATE_ICACHE 	       0x1
#define  INVALIDATE_DCACHE 	       0x2


void return_load_req(struct pcx_pkt  *pcx_pkt,
		     struct cpx_pkt  *cpx_pkt,
		     taddr_opt_t      t1_addr,
		     maddr_t          mb_addr,
		     uint32_t         preinit_ctrl_flag);

void return_store_ack(struct pcx_pkt  *pcx_pkt,
		      struct cpx_pkt  *cpx_pkt,
		      taddr_opt_t      t1_addr,
		      uint_t           preinit_ctrl_flag,
		      int              inv_flag);

void t1_system_emulation_loop(void);


#ifdef  __cplusplus
}
#endif


#endif /* ifndef MBFW_L2_EMUL_H_ */
