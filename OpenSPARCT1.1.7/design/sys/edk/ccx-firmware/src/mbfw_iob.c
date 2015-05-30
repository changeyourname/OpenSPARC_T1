/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_iob.c
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
#include <stdlib.h>
#include <stdio.h>

#include "mbfw_types.h"
#include "mbfw_pcx_cpx.h"
#include "mbfw_l2_emul.h"
#include "mbfw_rtl.h"
#include "mbfw_iob.h"


#define  IOB_INT_VEC_DIS               0x9800000800ULL
#define  IOB_CORE_AVAIL                0x9800000830ULL

#define  L2_BANK_0_CONTROL_REG         0xA900000000ULL
#define  L2_BANK_1_CONTROL_REG         0xA900000040ULL
#define  L2_BANK_2_CONTROL_REG         0xA900000080ULL
#define  L2_BANK_3_CONTROL_REG         0xA9000000C0ULL

#define  L2_BANK_0_ERROR_ENABLE_REG    0xAA00000000ULL
#define  L2_BANK_1_ERROR_ENABLE_REG    0xAA00000040ULL
#define  L2_BANK_2_ERROR_ENABLE_REG    0xAA00000080ULL
#define  L2_BANK_3_ERROR_ENABLE_REG    0xAA000000C0ULL

#define L2_STATUS_INIT_BEGIN           0xA600000000ULL
#define L2_STATUS_INIT_END             0xA60043ffc0ULL
#define L2_TAG_INIT_BEGIN              0xA400000000ULL
#define L2_TAG_INIT_END                0xA40043ffc0ULL


void
process_iob_load(struct pcx_pkt  *pcx_pkt,
		 struct cpx_pkt  *cpx_pkt,
		 taddr_t          t1_addr)
{
#ifdef REGRESSION_MODE
    if (t1_addr == IOB_CORE_AVAIL) {
	cpx_pkt->data3 = 0x0;   
	cpx_pkt->data2 = 0xf;
	cpx_pkt->data1 = 0x0;
	cpx_pkt->data0 = 0xf;   /* threads 0 .. 3 are available */
	return_load_req(pcx_pkt, cpx_pkt, t1_addr, MB_INVALID_ADDR, 0);
	return;
    }
#endif

    mbfw_printf("MBFW_ERROR: process_iob_load(): access to unimplemented "
			     "register. t1_addr 0x%x%08x \r\n",
			     (uint32_t )(t1_addr >> 32), (uint32_t ) t1_addr);
    print_pcx_pkt(pcx_pkt);
    mbfw_exit(1);
}





#ifdef REGRESSION_MODE

void
process_iob_store(struct pcx_pkt  *pcx_pkt,
		  struct cpx_pkt  *cpx_pkt,
		  taddr_t          t1_addr)
{
    int  target_cpu_id;
    int  intr_type;

    int core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    switch (t1_addr) {

    case IOB_INT_VEC_DIS:

        target_cpu_id = (pcx_pkt->data0 >> INT_FLUSH_CPU_ID_SHIFT)    & INT_FLUSH_CPU_ID_MASK;
	intr_type     = (pcx_pkt->data0 >> INT_FLUSH_INTR_TYPE_SHIFT) & INT_FLUSH_INTR_TYPE_MASK;

	if (intr_type == INT_FLUSH_INTR_TYPE_RESET) {
	    if ((started_cpus & (1U << target_cpu_id)) == 0) {
		started_cpus |= (1U << target_cpu_id);
		mbfw_printf("MBFW_INFO: Starting Thread  %d,   Threads active:  0x%x\r\n", target_cpu_id, started_cpus);
	    } else {
		mbfw_printf("MBFW_INFO: Sending interrupt (%h) to thread  %d\r\n", target_cpu_id, intr_type);
	    }
	}

	cpx_pkt_init(cpx_pkt);

	CPX_PKT_SET_RTNTYP(cpx_pkt, CPX_PKT_RTNTYP_INT_FLUSH);

	cpx_pkt->data0 = pcx_pkt->data0 & INT_FLUSH_DATA_MASK;
	cpx_pkt->data2 = cpx_pkt->data0;

	send_cpx_pkt(core_id, cpx_pkt);

	return_store_ack(pcx_pkt, cpx_pkt, t1_addr, 0, INVALIDATE_NONE);
	break;

    case L2_BANK_0_CONTROL_REG:
    case L2_BANK_1_CONTROL_REG:
    case L2_BANK_2_CONTROL_REG:
    case L2_BANK_3_CONTROL_REG:
    case L2_BANK_0_ERROR_ENABLE_REG:
    case L2_BANK_1_ERROR_ENABLE_REG:
    case L2_BANK_2_ERROR_ENABLE_REG:
    case L2_BANK_3_ERROR_ENABLE_REG:
	/* just keep the reset code happy */
	return_store_ack(pcx_pkt, cpx_pkt, t1_addr, 0, INVALIDATE_NONE);
	break;

    default:
	if ( (t1_addr >= L2_STATUS_INIT_BEGIN && t1_addr <= L2_STATUS_INIT_END) ||
		(t1_addr >= L2_TAG_INIT_BEGIN && t1_addr <= L2_TAG_INIT_END) ) {

	    /* just keep the reset code happy */
	    return_store_ack(pcx_pkt, cpx_pkt, t1_addr, 0, INVALIDATE_NONE);
	    break;
	}
	else {
	    mbfw_printf("MBFW_ERROR: process_iob_store(): access to "
				 "unimplemented register 0x%x%08x \r\n",
				 (uint32_t )(t1_addr >> 32), (uint32_t ) t1_addr);
	    print_pcx_pkt(pcx_pkt);
	    mbfw_exit(1);
	    break;
	}
    }
}


#else /* ifdef REGRESSION_MODE */


void
process_iob_store(struct pcx_pkt  *pcx_pkt,
		  struct cpx_pkt  *cpx_pkt,
		  taddr_t          t1_addr)
{
    int target_cpu_id;
    int intr_type;

    int target_core_id;

    if (t1_addr == IOB_INT_VEC_DIS) { /* used for communication between threads */

	cpx_pkt_init(cpx_pkt);

	CPX_PKT_SET_RTNTYP(cpx_pkt, CPX_PKT_RTNTYP_INT_FLUSH);

	cpx_pkt->data0 = pcx_pkt->data0 & INT_FLUSH_DATA_MASK;
	cpx_pkt->data2 = cpx_pkt->data0;

	target_core_id = pcx_pkt->data0 >> INT_FLUSH_CPU_ID_SHIFT;
	target_core_id = target_core_id & CPU_ID_MASK;
	target_core_id = target_core_id >> CPU_ID_CORE_ID_SHIFT;

	send_cpx_pkt(target_core_id, cpx_pkt);

	return_store_ack(pcx_pkt, cpx_pkt, t1_addr, 0, INVALIDATE_NONE);

	return;
    }

    mbfw_printf("MBFW_ERROR: process_iob_store(): access to unimplemented "
			     "register 0x%x%08x \r\n",
			      (uint32_t )(t1_addr >> 32), (uint32_t ) t1_addr);
    print_pcx_pkt(pcx_pkt);
    mbfw_exit(1);
}

#endif /* ifdef REGRESSION_MODE */
