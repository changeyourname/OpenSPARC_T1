/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_l2_emul.c
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
#include "mbfw_config.h"
#include "mbfw_pcx_cpx.h"
#include "mbfw_addr_map.h"
#include "mbfw_fpu.h"
#include "mbfw_reverse_dir.h"
#include "mbfw_uart.h"
#include "mbfw_iob.h"
#include "mbfw_rtl.h"
#include "mbfw_stats.h"
#include "mbfw_l2_emul.h"


int send_intr_packet = 0;


#define STORE_SIZE_1      0
#define STORE_SIZE_2      1
#define STORE_SIZE_4      2
#define STORE_SIZE_8      3
#define STORE_SIZE_16     4


#define T1_ICACHE_LINE_ALIGN_MASK         (~(0x1FULL))
#define T1_L2_CACHE_LINE_ALIGN_MASK       (~(0x3FULL))

#define MB_ADDR_ICACHE_LINE_ALIGN_MASK    (~(0x1FU))
#define MB_ADDR_QWORD_ALIGN_MASK          (~(0xFU))
#define MB_ADDR_L2_CACHE_LINE_ALIGN_MASK  (~(0x3FU))


#define T1_L2_CACHE_LINE_OFFSET      0x3F


/*
 * OpenSPARC T1 DRAM physical address starts from 0 and this fact is used to
 * optimize the conversion of T1 DRAM address to Microblaze DRAM address.
 * But in REGRESSION_MODE, T1 DRAM physical address range is not contiguous
 * and can be anywhere in the 39-bit cacheable physical address space.
 */


#ifdef REGRESSION_MODE

#define T1_DRAM_ADDR_2_MB_ADDR(pcx_pkt, t1_addr, mb_addr_ptr)    (void) translate_addr(pcx_pkt, t1_addr, mb_addr_ptr)
#define IS_T1_DRAM_ADDR(t1_addr)                                0

#else

#define T1_DRAM_ADDR_2_MB_ADDR(pcx_pkt, t1_addr, mb_addr_ptr)    *(mb_addr_ptr) = ((t1_addr) + MB_T1_DRAM_START)
#define IS_T1_DRAM_ADDR(t1_addr)                                ((t1_addr) < T1_DRAM_SIZE)

#endif /* ifndef REGRESSION_MODE */



#define VECINTR_VNET            29


static void
send_interrupt(void)
{
    struct cpx_pkt cpx_pkt;
    int core_id = T1_MASTER_CORE_ID;

    cpx_pkt_init(&cpx_pkt);

    CPX_PKT_SET_RTNTYP(&cpx_pkt, CPX_PKT_RTNTYP_INT_FLUSH);
    cpx_pkt.data0 = VECINTR_VNET;
    send_cpx_pkt_to_fsl(core_id, &cpx_pkt);
    return;
}

static int
invalidate_core_dcache(struct pcx_pkt *pcx_pkt, int core_id, int target_core_id, taddr_opt_t t1_addr)
{
    int  way, pabit54;
    struct cpx_pkt  cpx_pkt_buf;
    struct cpx_pkt  *cpx_pkt = &cpx_pkt_buf;

    way = invalidate_dcache(target_core_id, t1_addr);
    if (way == -1) {
	return way;
    }

    CPX_PKT_CTRL_EVICT_INV(cpx_pkt, 0);
    cpx_pkt->data3 = 0;
    cpx_pkt->data2 = 0;
    cpx_pkt->data1 = 0;
    cpx_pkt->data0 = 0;

    pabit54 = (t1_addr & 0x30) >> 4;

    switch (pabit54) {
    case 0:
	cpx_pkt->data0 |= (way << 2);
	cpx_pkt->data0 |= 0x1;
	cpx_pkt->data0 <<= (target_core_id * 4);
	break;
    case 1:
	cpx_pkt->data1 = (way << 1);
	cpx_pkt->data1 |= 0x1;
	cpx_pkt->data1 <<= (target_core_id * 3);
	break;
    case 2:
	/* assuming core_id < 2. this code needs to be modified if core_id >= 2 */
	cpx_pkt->data1 = (way << 2);
	cpx_pkt->data1 |= 0x1;
	cpx_pkt->data1 <<= 24;
	cpx_pkt->data1 <<= (target_core_id * 4);
	break;
    case 3:
	/* assuming core_id < 3. this code needs to be modified if core_id >= 3 */
	cpx_pkt->data2 = (way << 1);
	cpx_pkt->data2 |= 0x1;
	cpx_pkt->data2 <<= 24;
	cpx_pkt->data2 <<= (target_core_id * 3);
	break;
    }

    CPX_PKT_REFLECT_THREAD_ID(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_BIS(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_5_4(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_11_6(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_CORE_ID(cpx_pkt, pcx_pkt);

    send_cpx_pkt(target_core_id, cpx_pkt);

    return way;
}

static int
invalidate_core_icache(struct pcx_pkt *pcx_pkt, int core_id, int target_core_id, taddr_opt_t t1_addr)
{
    int  way, pabit5;
    struct cpx_pkt  cpx_pkt_buf;
    struct cpx_pkt  *cpx_pkt = &cpx_pkt_buf;

    way = invalidate_icache(target_core_id, t1_addr);
    if (way == -1) {
	return way;
    }

    CPX_PKT_CTRL_EVICT_INV(cpx_pkt, 0);
    cpx_pkt->data3 = 0;
    cpx_pkt->data2 = 0;
    cpx_pkt->data1 = 0;
    cpx_pkt->data0 = 0;

    pabit5 = (t1_addr & 0x20) >> 5;

    switch (pabit5) {
    case 0:
	cpx_pkt->data0 |= (way << 2);
	cpx_pkt->data0 |= 0x2;
	cpx_pkt->data0 <<= (target_core_id * 4);
	break;
    case 1:
	cpx_pkt->data1 |= (way << 2);
	cpx_pkt->data1 |= 0x2;
	cpx_pkt->data1 <<= 24;
	cpx_pkt->data1 <<= (target_core_id * 4);
	break;
    }

    CPX_PKT_REFLECT_THREAD_ID(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_BIS(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_5_4(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_11_6(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_CORE_ID(cpx_pkt, pcx_pkt);

    send_cpx_pkt(target_core_id, cpx_pkt);

    return way;
}

#ifdef T1_FPGA_DUAL_CORE

static void
invalidate_other_dcache(struct pcx_pkt *pcx_pkt, taddr_opt_t t1_addr)
{
    int target_core_id;

    int core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    for (target_core_id=0; target_core_id<T1_NUM_OF_CORES; target_core_id++) {
	if (target_core_id != core_id) {
	    invalidate_core_dcache(pcx_pkt, core_id, target_core_id, t1_addr);
	}
    }

    return;
}

static void
invalidate_other_icache(struct pcx_pkt *pcx_pkt, taddr_opt_t t1_addr)
{
    int target_core_id;

    int core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    for (target_core_id=0; target_core_id<T1_NUM_OF_CORES; target_core_id++) {
	if (target_core_id != core_id) {
	    invalidate_core_icache(pcx_pkt, core_id, target_core_id, t1_addr);
	}
    }

    return;
}

static void
invalidate_other_cache(struct pcx_pkt *pcx_pkt, taddr_opt_t t1_addr)
{
    int target_core_id;

    int core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    for (target_core_id=0; target_core_id<T1_NUM_OF_CORES; target_core_id++) {
	if (target_core_id != core_id) {
	    if (invalidate_core_dcache(pcx_pkt, core_id, target_core_id, t1_addr) == -1) {
		invalidate_core_icache(pcx_pkt, core_id, target_core_id, t1_addr);
	    }
	}
    }

    return;
}

#else /* ifdef T1_FPGA_DUAL_CORE */

#define invalidate_other_cache(pcx_pkt, t1_addr)
#define invalidate_other_icache(pcx_pkt, t1_addr)
#define invalidate_other_dcache(pcx_pkt, t1_addr)

#endif /* ifdef T1_FPGA_DUAL_CORE */



void
return_load_req(struct pcx_pkt  *pcx_pkt,
		struct cpx_pkt  *cpx_pkt,
	        taddr_opt_t      t1_addr,
		maddr_t          mb_addr,
		uint32_t         preinit_ctrl_flag)
{
    int      way;
    maddr_t  mb_addr_qw_align;
    int      core_id;

    core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    if (mb_addr != MB_INVALID_ADDR) {

	mb_addr_qw_align   = mb_addr & MB_ADDR_QWORD_ALIGN_MASK;

	cpx_pkt->data3 = *(uint32_t *) (mb_addr_qw_align + 0x0);
	cpx_pkt->data2 = *(uint32_t *) (mb_addr_qw_align + 0x4);
	cpx_pkt->data1 = *(uint32_t *) (mb_addr_qw_align + 0x8);
	cpx_pkt->data0 = *(uint32_t *) (mb_addr_qw_align + 0xC);
    }

    CPX_PKT_CTRL_LOAD(cpx_pkt, preinit_ctrl_flag);
    CPX_PKT_REFLECT_NC_THREAD_ID(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_PREFETCH(cpx_pkt, pcx_pkt);

    if (PCX_PKT_IS_CACHEABLE(pcx_pkt)) {

	invalidate_other_icache(pcx_pkt, t1_addr);

	way = invalidate_icache(core_id, t1_addr);
	if (way != -1) {
	    CPX_PKT_SET_WV(cpx_pkt, 1);
	    CPX_PKT_SET_WAY(cpx_pkt, way);
	}
    }
    send_cpx_pkt(core_id, cpx_pkt);

    return;
}




void
return_store_ack(struct pcx_pkt  *pcx_pkt,
		 struct cpx_pkt  *cpx_pkt,
		 taddr_opt_t      t1_addr,
		 uint_t           preinit_ctrl_flag,
		 int              inv_flag)
{
    int way;

    int pabit5, pabit54;
    int core_id;

    core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    CPX_PKT_CTRL_STORE_ACK(cpx_pkt, preinit_ctrl_flag);
    cpx_pkt->data3 = 0;
    cpx_pkt->data2 = 0;
    cpx_pkt->data1 = 0;
    cpx_pkt->data0 = 0;


    if (inv_flag != INVALIDATE_NONE) {

	invalidate_other_cache(pcx_pkt, t1_addr);

        if (inv_flag & INVALIDATE_DCACHE) {
	    way = invalidate_dcache(core_id, t1_addr);
	} else {
	    way = search_dcache(core_id, t1_addr);
	}
        if (way != -1) {
            pabit54 = (t1_addr & 0x30) >> 4;

            switch (pabit54) {
	    case 0:
		cpx_pkt->data0 |= (way << 2);
		cpx_pkt->data0 |= 0x1;
		cpx_pkt->data0 <<= (core_id * 4);
		break;
	    case 1:
		cpx_pkt->data1 = (way << 1);
		cpx_pkt->data1 |= 0x1;
		cpx_pkt->data1 <<= (core_id * 3);
		break;
	    case 2:
		/* assuming core_id < 2. this code needs to be modified if core_id >= 2 */
		cpx_pkt->data1 = (way << 2);
		cpx_pkt->data1 |= 0x1;
		cpx_pkt->data1 <<= 24;
		cpx_pkt->data1 <<= (core_id * 4);
		break;
	    case 3:
		/* assuming core_id < 3. this code needs to be modified if core_id >= 3 */
		cpx_pkt->data2 = (way << 1);
		cpx_pkt->data2 |= 0x1;
		cpx_pkt->data2 <<= 24;
		cpx_pkt->data2 <<= (core_id * 3);
		break;
            }
        } else {
	    way = invalidate_icache(core_id, t1_addr);
	    if (way != -1) {
		pabit5 = (t1_addr & 0x20) >> 5;

		switch (pabit5) {
		case 0:
		    cpx_pkt->data0 |= (way << 2);
		    cpx_pkt->data0 |= 0x2;
		    cpx_pkt->data0 <<= (core_id * 4);
		    break;
		case 1:
		    cpx_pkt->data1 |= (way << 2);
		    cpx_pkt->data1 |= 0x2;
		    cpx_pkt->data1 <<= 24;
		    cpx_pkt->data1 <<= (core_id * 4);
		    break;
		}
	    }
	}
    }

    CPX_PKT_REFLECT_THREAD_ID(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_BIS(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_5_4(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_11_6(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_CORE_ID(cpx_pkt, pcx_pkt);

    send_cpx_pkt(core_id, cpx_pkt);

    return;
}



/* send one response cpx_pkt to ifill request */

static void
return_16bytes_ifill_resp(struct pcx_pkt *pcx_pkt,
			  struct cpx_pkt *cpx_pkt,
			  maddr_t         mb_addr)
{
    maddr_t  mb_addr_qw_align = mb_addr & MB_ADDR_QWORD_ALIGN_MASK;
    int core_id;

    core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    CPX_PKT_CTRL_IFILL_4B(cpx_pkt);
    CPX_PKT_REFLECT_NC_THREAD_ID(cpx_pkt, pcx_pkt);

    cpx_pkt->data3 = *(uint32_t *) (mb_addr_qw_align + 0x0);
    cpx_pkt->data2 = *(uint32_t *) (mb_addr_qw_align + 0x4);
    cpx_pkt->data1 = *(uint32_t *) (mb_addr_qw_align + 0x8);
    cpx_pkt->data0 = *(uint32_t *) (mb_addr_qw_align + 0xC);

    send_cpx_pkt(core_id, cpx_pkt);

    return;
}


static void
process_load_invalidate(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    taddr_opt_t   t1_addr;
    int           core_id;

    core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);
    t1_addr = PCX_PKT_GET_T1_ADDR_OPT(pcx_pkt);

    // Invalidate all ways for the given index
    dcache_invalidate_all_ways(core_id, t1_addr);

    // Send store ack packet back to core to invalidate cachelines in core
    cpx_pkt->data0 = 0;
    cpx_pkt->data1 = 0;
    cpx_pkt->data2 = 0;
    cpx_pkt->data3 = 0;

    CPX_PKT_CTRL_STORE_ACK(cpx_pkt, 0);
    CPX_PKT_REFLECT_THREAD_ID(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_5_4(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_11_6(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_CORE_ID(cpx_pkt, pcx_pkt);
    CPX_PKT_SET_STORE_ACK_INVALIDATE_ALL(cpx_pkt, 0x1);

    send_cpx_pkt(core_id, cpx_pkt);

    return;
}


static void
process_load_fast(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    uint_t    l1_way;
    int       signed_way;
    int       core_id;

    taddr_opt_t  t1_addr;
    maddr_t      mb_addr, mb_addr_qw_align;

    core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    t1_addr = PCX_PKT_GET_T1_ADDR_OPT(pcx_pkt);
    T1_DRAM_ADDR_2_MB_ADDR(pcx_pkt, t1_addr, &mb_addr);

    l1_way  = PCX_PKT_GET_L1_WAY(pcx_pkt);
    add_dcache_line(core_id, t1_addr, l1_way);

    CPX_PKT_CTRL_LOAD(cpx_pkt, 0);

    mb_addr_qw_align   = mb_addr & MB_ADDR_QWORD_ALIGN_MASK;

    cpx_pkt->data3 = *(uint32_t *) (mb_addr_qw_align + 0x0);
    cpx_pkt->data2 = *(uint32_t *) (mb_addr_qw_align + 0x4);
    cpx_pkt->data1 = *(uint32_t *) (mb_addr_qw_align + 0x8);
    cpx_pkt->data0 = *(uint32_t *) (mb_addr_qw_align + 0xC);

    CPX_PKT_REFLECT_THREAD_ID(cpx_pkt, pcx_pkt);

    invalidate_other_icache(pcx_pkt, t1_addr);

    signed_way = invalidate_icache(core_id, t1_addr);
    if (signed_way != -1) {
	CPX_PKT_SET_WV(cpx_pkt, 1);
	CPX_PKT_SET_WAY(cpx_pkt, signed_way);
    }
    send_cpx_pkt(core_id, cpx_pkt);

    return;
}


static void
process_load(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    uint_t   l1_way;
    taddr_t  t1_addr;
    maddr_t  mb_addr;
    int      core_id;

    enum addr_type addr_type = MB_MEM_ADDR;

    core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    t1_addr = PCX_PKT_GET_T1_ADDR(pcx_pkt);
    if (IS_T1_DRAM_ADDR(t1_addr)) {
	T1_DRAM_ADDR_2_MB_ADDR(pcx_pkt, t1_addr, &mb_addr);
    } else {
        addr_type = translate_addr(pcx_pkt, t1_addr, &mb_addr);
    }

    switch (addr_type) {

    case MB_MEM_ADDR:
	if (PCX_PKT_IS_INVALIDATE(pcx_pkt)) {
	    process_load_invalidate(pcx_pkt, cpx_pkt);
	    return;
	}

	if (PCX_PKT_IS_CACHEABLE(pcx_pkt)) {
	    l1_way = PCX_PKT_GET_L1_WAY(pcx_pkt);
	    add_dcache_line(core_id, t1_addr, l1_way);
	}

	return_load_req(pcx_pkt, cpx_pkt, t1_addr, mb_addr, 0);
	break;

    case UART_ADDR:
	process_uart_load(pcx_pkt, cpx_pkt, t1_addr);
	break;

    case ETH_ADDR:
	mbfw_snet_load(pcx_pkt, cpx_pkt, t1_addr);
	break;

    case IOB_ADDR:
	process_iob_load(pcx_pkt, cpx_pkt, t1_addr);
	break;

    default:
	mbfw_printf("MBFW_ERROR: process_load(): Internal error. unknown "
				 "addr_type %d \r\n", addr_type);
	print_pcx_pkt(pcx_pkt);
	mbfw_exit(1);
	break;
    }

    return;
}


static void
process_store_fast(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    taddr_opt_t   t1_addr;
    maddr_t       mb_addr;

    int  way;
    int  pcx_size;
    int  pabit5, pabit54;
    int  core_id;


    core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    t1_addr = PCX_PKT_GET_T1_ADDR_OPT(pcx_pkt);
    T1_DRAM_ADDR_2_MB_ADDR(pcx_pkt, t1_addr, &mb_addr);

    pcx_size = PCX_PKT_GET_SIZE(pcx_pkt);

    switch (pcx_size) {
    case STORE_SIZE_1:
	*(uint8_t *) mb_addr = pcx_pkt->data0 & 0xFF;
	break;
    case STORE_SIZE_2:
	*(uint16_t *) mb_addr = pcx_pkt->data0 & 0xFFFF;
	break;
    case STORE_SIZE_4:
	*(uint32_t *) mb_addr = pcx_pkt->data1;
	break;
    case STORE_SIZE_8:
	*(uint32_t *)mb_addr = pcx_pkt->data1;
	*(uint32_t *)(mb_addr + 4) = pcx_pkt->data0;
	break;
    }

#ifdef REGRESSION_MODE
	uint32_t *addr_ptr;

	if (t1_addr == THREAD_EXIT_STATUS_ADDR_0 ||
		t1_addr == THREAD_EXIT_STATUS_ADDR_1) {
	    int cpu_id = PCX_PKT_GET_CPU_ID(pcx_pkt);
	    
	    if (pcx_pkt->data1) {
		return_store_ack(pcx_pkt, cpx_pkt, t1_addr, 0, INVALIDATE_ICACHE);

		mbfw_printf("MBFW_ERROR: thread %d reached bad trap. \r\n", cpu_id);
		addr_ptr  = (uint32_t *) EXITCODE_ADDR;
		*addr_ptr = EXITCODE_BADTRAP;
		exit(1);
	    } else {
		mbfw_printf("MBFW_INFO: Thread %d reached good trap.\r\n", cpu_id);
	    }

	    started_cpus &= ~(1U << cpu_id);
	    if (started_cpus == 0) {
		return_store_ack(pcx_pkt, cpx_pkt, t1_addr, 0, INVALIDATE_ICACHE);

		mbfw_printf("MBFW_INFO: All threads reached good trap. \r\n");
		addr_ptr  = (uint32_t *) EXITCODE_ADDR;
		*addr_ptr = EXITCODE_GOODTRAP;
		exit(0);
	    }
	}
#endif /* ifdef REGRESSION_MODE */

    invalidate_other_cache(pcx_pkt, t1_addr);

    cpx_pkt->data0 = 0;
    cpx_pkt->data1 = 0;
    cpx_pkt->data2 = 0;
    cpx_pkt->data3 = 0;
    CPX_PKT_CTRL_STORE_ACK(cpx_pkt, 0);

    way = search_dcache(core_id, t1_addr);
    if (way != -1) {
	pabit54 = (t1_addr & 0x30) >> 4;

	switch (pabit54) {
	case 0:
	    cpx_pkt->data0 |= (way << 2);
	    cpx_pkt->data0 |= 0x1;
	    cpx_pkt->data0 <<= (core_id * 4);
	    break;
	case 1:
	    cpx_pkt->data1 = (way << 1);
	    cpx_pkt->data1 |= 0x1;
	    cpx_pkt->data1 <<= (core_id * 3);
	    break;
	case 2:
	    /* assuming core_id < 2. this code needs to be modified if core_id >= 2 */
	    cpx_pkt->data1 = (way << 2);
	    cpx_pkt->data1 |= 0x1;
	    cpx_pkt->data1 <<= 24;
	    cpx_pkt->data1 <<= (core_id * 4);
	    break;
	case 3:
	    /* assuming core_id < 3. this code needs to be modified if core_id >= 3 */
	    cpx_pkt->data2 = (way << 1);
	    cpx_pkt->data2 |= 0x1;
	    cpx_pkt->data2 <<= 24;
	    cpx_pkt->data2 <<= (core_id * 3);
	    break;
	}
    } else {
	way = invalidate_icache(core_id, t1_addr);
	if (way != -1) {
	    pabit5 = (t1_addr & 0x20) >> 5;
	    switch (pabit5) {
	    case 0:
		cpx_pkt->data0 |= (way << 2);
		cpx_pkt->data0 |= 0x2;
		cpx_pkt->data0 <<= (core_id * 4);
		break;
	    case 1:
		cpx_pkt->data1 |= (way << 2);
		cpx_pkt->data1 |= 0x2;
		cpx_pkt->data1 <<= 24;
		cpx_pkt->data1 <<= (core_id * 4);
		break;
	    }
	}
    }

    CPX_PKT_REFLECT_THREAD_ID(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_5_4(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_11_6(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_CORE_ID(cpx_pkt, pcx_pkt);

    send_cpx_pkt(core_id, cpx_pkt);

    return;
}


static void
process_store(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    taddr_t  t1_addr;
    maddr_t  mb_addr;
    int      pcx_size;

    enum addr_type addr_type = MB_MEM_ADDR;


    t1_addr = PCX_PKT_GET_T1_ADDR(pcx_pkt);
    if (IS_T1_DRAM_ADDR(t1_addr)) {
	T1_DRAM_ADDR_2_MB_ADDR(pcx_pkt, t1_addr, &mb_addr);
    } else {
        addr_type = translate_addr(pcx_pkt, t1_addr, &mb_addr);
    }

    switch (addr_type) {

    case MB_MEM_ADDR:
	pcx_size = PCX_PKT_GET_SIZE(pcx_pkt);

	switch (pcx_size) {
	    case STORE_SIZE_1:
		*(uint8_t *) mb_addr = pcx_pkt->data0 & 0xFF;
		break;
	    case STORE_SIZE_2:
		*(uint16_t *) mb_addr = pcx_pkt->data0 & 0xFFFF;
		break;
	    case STORE_SIZE_4:
		*(uint32_t *) mb_addr = pcx_pkt->data1;
		break;
	    case STORE_SIZE_8:
		*(uint32_t *)mb_addr = pcx_pkt->data1;
		*(uint32_t *)(mb_addr + 4) = pcx_pkt->data0;
		break;
	}

	return_store_ack(pcx_pkt, cpx_pkt, t1_addr, 0, INVALIDATE_ICACHE);
	break;

    case UART_ADDR:
	process_uart_store(pcx_pkt, cpx_pkt, t1_addr);
	break;

    case ETH_ADDR:
	mbfw_snet_store(pcx_pkt, cpx_pkt, t1_addr);
	break;

    case IOB_ADDR:
	process_iob_store(pcx_pkt, cpx_pkt, t1_addr);
	break;

    default:
	mbfw_printf("MBFW_ERROR: process_store(): Internal error. unknown "
				 "addr_type %d \r\n", addr_type);
	print_pcx_pkt(pcx_pkt);
	mbfw_exit(1);
	break;
    }

    return;
}


/*
 * Since L2 cache is inclusive of L1, a memory access misses L2 if
 * it is not present in L1.
 */

static int
is_l2_miss(struct pcx_pkt *pcx_pkt, taddr_opt_t t1_addr)
{
    int  i;
    int  core_id;

    t1_addr = t1_addr & T1_L2_CACHE_LINE_ALIGN_MASK;

    for (i = 0; i < (T1_L2_CACHE_LINE_SIZE / T1_DCACHE_LINE_SIZE); i++) {
	for (core_id = 0; core_id < T1_NUM_OF_CORES; core_id++) {
	    if (search_dcache(core_id, t1_addr) != -1) {
		return 0;
	    }
	}
	t1_addr += T1_DCACHE_LINE_SIZE;
    }

    for (i = 0; i < (T1_L2_CACHE_LINE_SIZE / T1_ICACHE_LINE_SIZE); i++) {
	for (core_id = 0; core_id < T1_NUM_OF_CORES; core_id++) {
	    if (search_icache(core_id, t1_addr) != -1) {
		return 0;
	    }
	}
	t1_addr += T1_ICACHE_LINE_SIZE;
    }

    return 1;
}


static void
process_bis_bst(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    taddr_opt_t  t1_addr;
    maddr_t      mb_addr;

    int i;
    uint32_t *tmp_ptr;

    int n_words_in_l2_cache_line = T1_L2_CACHE_LINE_SIZE / sizeof(uint32_t);


    t1_addr = PCX_PKT_GET_T1_ADDR_OPT(pcx_pkt);
    T1_DRAM_ADDR_2_MB_ADDR(pcx_pkt, t1_addr, &mb_addr);

    if (PCX_PKT_GET_BST(pcx_pkt) == 0) {

	/* block store init */

	if ((t1_addr & T1_L2_CACHE_LINE_OFFSET) == 0) {
	    /* access to the first word of L2 cache line */
	    if (is_l2_miss(pcx_pkt, t1_addr)) {
		tmp_ptr = (uint32_t *) mb_addr;
		for (i = 0; i < n_words_in_l2_cache_line; i++) {
		    *tmp_ptr++ = 0;
		}
	    }
	}
    }

    *(uint32_t *) mb_addr       = pcx_pkt->data1;
    *(uint32_t *) (mb_addr + 4) = pcx_pkt->data0;

    return_store_ack(pcx_pkt, cpx_pkt, t1_addr, 0, INVALIDATE_DCACHE|INVALIDATE_ICACHE);

    return;
}


static void
process_ifill_invalidate(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    taddr_opt_t   t1_addr;
    int           core_id;

    core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);
    t1_addr = PCX_PKT_GET_T1_ADDR_OPT(pcx_pkt);

    // Invalidate all ways for the given index
    icache_invalidate_all_ways(core_id, t1_addr);

    // Send store ack packet back to core to invalidate cachelines in core
    cpx_pkt->data0 = 0;
    cpx_pkt->data1 = 0;
    cpx_pkt->data2 = 0;
    cpx_pkt->data3 = 0;

    CPX_PKT_CTRL_STORE_ACK(cpx_pkt, 0);
    CPX_PKT_REFLECT_THREAD_ID(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_5_4(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_ADDR_11_6(cpx_pkt, pcx_pkt);
    CPX_PKT_REFLECT_CORE_ID(cpx_pkt, pcx_pkt);
    CPX_PKT_SET_STORE_ACK_INVALIDATE_ALL(cpx_pkt, 0x2);

    send_cpx_pkt(core_id, cpx_pkt);

    return;
}


static void
process_ifill_fast(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    taddr_opt_t  t1_addr;
    maddr_t      mb_addr;
    int          core_id;

    uint_t    l1_way;
    int       signed_way;

    core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    t1_addr = PCX_PKT_GET_T1_ADDR_OPT(pcx_pkt);
    T1_DRAM_ADDR_2_MB_ADDR(pcx_pkt, t1_addr, &mb_addr);

    l1_way  = PCX_PKT_GET_L1_WAY(pcx_pkt);

    add_icache_line(core_id, t1_addr, l1_way);

    CPX_PKT_CTRL_IFILL_0(cpx_pkt);
    CPX_PKT_REFLECT_THREAD_ID(cpx_pkt, pcx_pkt);

    cpx_pkt->data3 = *(uint32_t *) (mb_addr + 0x0);
    cpx_pkt->data2 = *(uint32_t *) (mb_addr + 0x4);
    cpx_pkt->data1 = *(uint32_t *) (mb_addr + 0x8);
    cpx_pkt->data0 = *(uint32_t *) (mb_addr + 0xC);

    invalidate_other_dcache(pcx_pkt, t1_addr);

    signed_way = invalidate_dcache(core_id, t1_addr);
    if (signed_way != -1) {
	CPX_PKT_SET_WV(cpx_pkt, 1);
	CPX_PKT_SET_WAY(cpx_pkt, signed_way);
    }

    send_cpx_pkt(core_id, cpx_pkt);


    CPX_PKT_CTRL_IFILL_1(cpx_pkt);
    CPX_PKT_REFLECT_THREAD_ID(cpx_pkt, pcx_pkt);

    cpx_pkt->data3 = *(uint32_t *) (mb_addr + 0x10);
    cpx_pkt->data2 = *(uint32_t *) (mb_addr + 0x14);
    cpx_pkt->data1 = *(uint32_t *) (mb_addr + 0x18);
    cpx_pkt->data0 = *(uint32_t *) (mb_addr + 0x1C);

    invalidate_other_dcache(pcx_pkt, t1_addr + T1_DCACHE_LINE_SIZE);

    signed_way = invalidate_dcache(core_id, t1_addr + T1_DCACHE_LINE_SIZE);
    if (signed_way != -1) {
	CPX_PKT_SET_WV(cpx_pkt, 1);
	CPX_PKT_SET_WAY(cpx_pkt, signed_way);
    }

    send_cpx_pkt(core_id, cpx_pkt);

    return;
}

static void
process_ifill(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    taddr_t   t1_addr;
    maddr_t   mb_addr;
    int       core_id;

    maddr_t       mb_addr_ic_align;
    taddr_opt_t   t1_addr_ic_align;

    uint_t    l1_way;
    int       signed_way;


    core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    t1_addr = PCX_PKT_GET_T1_ADDR(pcx_pkt);
    if (IS_T1_DRAM_ADDR(t1_addr)) {
	T1_DRAM_ADDR_2_MB_ADDR(pcx_pkt, t1_addr, &mb_addr);
    } else {
        translate_addr(pcx_pkt, t1_addr, &mb_addr);
    }

    if (PCX_PKT_IS_INVALIDATE(pcx_pkt)) {
	process_ifill_invalidate(pcx_pkt, cpx_pkt);
    } else {
	if (PCX_PKT_IS_IO_SPACE(pcx_pkt)) {
	    /* send 16 bytes only */
	    return_16bytes_ifill_resp(pcx_pkt, cpx_pkt, mb_addr);
	} else {

	    /* send 32 bytes */

	    mb_addr_ic_align = mb_addr & MB_ADDR_ICACHE_LINE_ALIGN_MASK;
	    t1_addr_ic_align = ((taddr_opt_t ) t1_addr) & T1_ICACHE_LINE_ALIGN_MASK;

	    if (PCX_PKT_IS_CACHEABLE(pcx_pkt)) {
		l1_way  = PCX_PKT_GET_L1_WAY(pcx_pkt);
		add_icache_line(core_id, t1_addr_ic_align, l1_way);
	    }


	    CPX_PKT_CTRL_IFILL_0(cpx_pkt);
	    CPX_PKT_REFLECT_NC_THREAD_ID(cpx_pkt, pcx_pkt);

	    cpx_pkt->data3 = *(uint32_t *) (mb_addr_ic_align + 0x0);
	    cpx_pkt->data2 = *(uint32_t *) (mb_addr_ic_align + 0x4);
	    cpx_pkt->data1 = *(uint32_t *) (mb_addr_ic_align + 0x8);
	    cpx_pkt->data0 = *(uint32_t *) (mb_addr_ic_align + 0xC);


	    invalidate_other_dcache(pcx_pkt, t1_addr_ic_align);

	    signed_way = invalidate_dcache(core_id, t1_addr_ic_align);
	    if (signed_way != -1) {
		CPX_PKT_SET_WV(cpx_pkt, 1);
		CPX_PKT_SET_WAY(cpx_pkt, signed_way);
	    }

	    send_cpx_pkt(core_id, cpx_pkt);

	    CPX_PKT_CTRL_IFILL_1(cpx_pkt);
	    CPX_PKT_REFLECT_NC_THREAD_ID(cpx_pkt, pcx_pkt);

	    cpx_pkt->data3 = *(uint32_t *) (mb_addr_ic_align + 0x10);
	    cpx_pkt->data2 = *(uint32_t *) (mb_addr_ic_align + 0x14);
	    cpx_pkt->data1 = *(uint32_t *) (mb_addr_ic_align + 0x18);
	    cpx_pkt->data0 = *(uint32_t *) (mb_addr_ic_align + 0x1C);


	    invalidate_other_dcache(pcx_pkt, t1_addr_ic_align + T1_DCACHE_LINE_SIZE);

	    signed_way = invalidate_dcache(core_id, t1_addr_ic_align + T1_DCACHE_LINE_SIZE);
	    if (signed_way != -1) {
		CPX_PKT_SET_WV(cpx_pkt, 1);
		CPX_PKT_SET_WAY(cpx_pkt, signed_way);
	    }

	    send_cpx_pkt(core_id, cpx_pkt);
	}
    }

    return;
}


static void
process_swap_ldstub(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    taddr_opt_t  t1_addr;
    maddr_t      mb_addr;

    t1_addr = PCX_PKT_GET_T1_ADDR_OPT(pcx_pkt);
    T1_DRAM_ADDR_2_MB_ADDR(pcx_pkt, t1_addr, &mb_addr);

    return_load_req(pcx_pkt, cpx_pkt, t1_addr, mb_addr, CPX_PKT_CTRL_ATOMIC);

    if (PCX_PKT_GET_SIZE(pcx_pkt) == 0) {
	*(uint8_t *) mb_addr = pcx_pkt->data1;   /* LDSTUB */
    } else {
	*(uint32_t *) mb_addr = pcx_pkt->data1;  /* SWAP */
    }

    return_store_ack(pcx_pkt, cpx_pkt, t1_addr, CPX_PKT_CTRL_ATOMIC, INVALIDATE_DCACHE|INVALIDATE_ICACHE);

    return;
}


static void
process_cas(struct pcx_pkt  *load_pcx_pkt,
	    struct pcx_pkt  *pcx_pkt,
	    struct cpx_pkt  *cpx_pkt)
{
    taddr_opt_t  t1_addr;
    maddr_t      mb_addr;
    int          pcx_size;

    uint64_t     casx_cmp_value;
    uint64_t     casx_mem_value;

    t1_addr  = PCX_PKT_GET_T1_ADDR_OPT(pcx_pkt);
    T1_DRAM_ADDR_2_MB_ADDR(pcx_pkt, t1_addr, &mb_addr);
    pcx_size = PCX_PKT_GET_SIZE(pcx_pkt);

    return_load_req(pcx_pkt, cpx_pkt, t1_addr, mb_addr, CPX_PKT_CTRL_ATOMIC);

    switch (pcx_size) {

    case 0x2:    /* CASA instruction 32-bit */
	if (*(uint32_t *) mb_addr == load_pcx_pkt->data1) {
	    if ((mb_addr & 0x7) == 0) {
		*(uint32_t *) mb_addr = pcx_pkt->data1;
	    } else {
		*(uint32_t *) mb_addr = pcx_pkt->data0;
	    }
	}
	break;

    case 0x3:    /* CASXA */
	casx_cmp_value = ((uint64_t) (load_pcx_pkt->data1) << 32) | load_pcx_pkt->data0;
	casx_mem_value = *(uint64_t *) mb_addr;

	if (casx_cmp_value == casx_mem_value) {
	    uint64_t casx_write_value = ((uint64_t) (pcx_pkt->data1) << 32) | pcx_pkt->data0;
	    *(uint64_t *) mb_addr = casx_write_value;
	}
	break;

    default:
	mbfw_printf("MBFW_ERROR: process_cas(): unknown pcx_size %d \r\n",
				                                   pcx_size);
	print_pcx_pkt(pcx_pkt);
	mbfw_exit(1);
	break;
    }

    return_store_ack(load_pcx_pkt, cpx_pkt, t1_addr, CPX_PKT_CTRL_ATOMIC, INVALIDATE_DCACHE|INVALIDATE_ICACHE);

    return;
}

static void
process_int_flush(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    int target_core_id = PCX_PKT_GET_CORE_ID(pcx_pkt);

    cpx_pkt_init(cpx_pkt);

    CPX_PKT_SET_RTNTYP(cpx_pkt, CPX_PKT_RTNTYP_INT_FLUSH);
    CPX_PKT_REFLECT_NC_THREAD_ID(cpx_pkt, pcx_pkt);
    CPX_PKT_INT_FLUSH_REFLECT_BITS_17_0(cpx_pkt, pcx_pkt);
    if (PCX_PKT_GET_NC(pcx_pkt)) {
        CPX_PKT_REFLECT_ADDR_5_4(cpx_pkt, pcx_pkt);                 /* flush packet */
        CPX_PKT_REFLECT_ADDR_11_6(cpx_pkt, pcx_pkt);
        CPX_PKT_REFLECT_CORE_ID(cpx_pkt, pcx_pkt);
    } else {
	target_core_id = pcx_pkt->data0 >> INT_FLUSH_CPU_ID_SHIFT;  /* interrupt packet */
	target_core_id = target_core_id & CPU_ID_MASK;
	target_core_id = target_core_id >> CPU_ID_CORE_ID_SHIFT;
    }

    cpx_pkt->data0 = pcx_pkt->data0 & 0x3FFFF;
    cpx_pkt->data2 = cpx_pkt->data0;

    send_cpx_pkt(target_core_id, cpx_pkt);

    return;
}



void
t1_system_emulation_loop(void)
{
    struct pcx_pkt  pcx_pkt;
    struct cpx_pkt  cpx_pkt;
    struct pcx_pkt  cpu_cas1_packet[T1_NUM_OF_CPUS];
    uint_t     rqtyp;
    int toggle_flag = 1;
    int len;
    int cpu_id;
    int get_local  = 1;
#ifdef T1_FPGA_DUAL_CORE
    int get_remote = 1;
#else
    int get_remote = 0;
#endif

    for (;;) {

#ifdef T1_FPGA_SLAVE_CORE
	if (recv_pcx_pkt(&pcx_pkt, 0) < 0) {
	    if (recv_aurora_pkt(&cpx_pkt, sizeof(struct cpx_pkt), 0) == sizeof(struct cpx_pkt)) {
		send_cpx_pkt_to_fsl(T1_SLAVE_CORE_ID, &cpx_pkt);
	    }
	    continue;
	}
	if (! PCX_PKT_IS_VALID(&pcx_pkt)) {
	    continue;
	}

	send_aurora_pkt(&pcx_pkt, sizeof(struct pcx_pkt));

	do {
	    len = recv_aurora_pkt(&cpx_pkt, sizeof(struct cpx_pkt), -1);
	    if (len == sizeof(struct cpx_pkt)) {
		send_cpx_pkt_to_fsl(T1_SLAVE_CORE_ID, &cpx_pkt);
	    }
	} while (len != AURORA_HDR_SIZE);
#else /* #ifdef T1_FPGA_SLAVE_CORE */
	if (send_intr_packet) {
	    send_interrupt();
	    send_intr_packet = 0;
	}

  	if ((get_local == 1) && (get_remote == 1)) {
	    if (toggle_flag) {
		if (recv_pcx_pkt(&pcx_pkt, 0) < 0) {
		    if (recv_aurora_pcx_pkt(&pcx_pkt, sizeof(struct pcx_pkt ), 0)<0) {
			continue;
		    }
		}
	    } else {
		if (recv_aurora_pcx_pkt(&pcx_pkt, sizeof(struct pcx_pkt ), 0)<0) {
		    if (recv_pcx_pkt(&pcx_pkt, 0) < 0) {
			continue;
		    }
		}
	    }
	    if (toggle_flag) {
		toggle_flag = 0;
	    } else {
		toggle_flag = 1;
	    }
	} else if (get_local == 1) {
	    if (recv_pcx_pkt(&pcx_pkt, 0) < 0) {
		continue;
	    }
	} else {
	    if (recv_aurora_pcx_pkt(&pcx_pkt, sizeof(struct pcx_pkt ), 0)<0) {
		continue;
	    }
	}

	if (! PCX_PKT_IS_VALID(&pcx_pkt)) {
	    continue;
	}

        rqtyp = PCX_PKT_GET_RQTYP(&pcx_pkt);

	if (IS_COMMON_CASE_PCX_PKT(&pcx_pkt)) {
	    if (rqtyp == PCX_REQ_STORE) {
		process_store_fast(&pcx_pkt, &cpx_pkt);
		continue;
	    } else if (rqtyp == PCX_REQ_LOAD) {
		process_load_fast(&pcx_pkt, &cpx_pkt);
		continue;
	    } else if (rqtyp == PCX_REQ_IFILL) {
		process_ifill_fast(&pcx_pkt, &cpx_pkt);
		continue;
	    }
	}


        switch (rqtyp) {
	case PCX_REQ_LOAD:
	    process_load(&pcx_pkt, &cpx_pkt);
	    break;

	case PCX_REQ_STORE:
	    if (PCX_PKT_IS_BIS_BST(&pcx_pkt)) {
		process_bis_bst(&pcx_pkt, &cpx_pkt);
	    } else {
		process_store(&pcx_pkt, &cpx_pkt);
	    }
	    break;

	case PCX_REQ_IFILL:
	    process_ifill(&pcx_pkt, &cpx_pkt);
	    break;

	case PCX_REQ_SWAP_LDSTUB:
	    process_swap_ldstub(&pcx_pkt, &cpx_pkt);
	    break;

	case PCX_REQ_CAS_LOAD:
	    cpu_id = PCX_PKT_GET_CPU_ID(&pcx_pkt);
	    if (PCX_PKT_GET_CORE_ID(&pcx_pkt) == T1_MASTER_CORE_ID) {
	        cpu_cas1_packet[cpu_id] = pcx_pkt;
		get_remote = 0;
            } else {
	        cpu_cas1_packet[cpu_id] = pcx_pkt;
		get_local = 0;
	    }
	    break;

	case PCX_REQ_CAS_STORE:
	    cpu_id = PCX_PKT_GET_CPU_ID(&pcx_pkt);
	    process_cas(&cpu_cas1_packet[cpu_id], &pcx_pkt, &cpx_pkt);
	    get_local  = 1;
#ifdef T1_FPGA_DUAL_CORE
	    get_remote = 1;
#else
	    get_remote = 0;
#endif
	    break;

	case PCX_REQ_INT_FLUSH:
	    process_int_flush(&pcx_pkt, &cpx_pkt);
	    break;

	case PCX_REQ_FP_1:
	    process_fp_1(&pcx_pkt, &cpx_pkt);
	    break;

	case PCX_REQ_FP_2:
	    process_fp_2(&pcx_pkt, &cpx_pkt);
	    break;

	default:
	    mbfw_printf("MBFW_ERROR: t1_system_emulation_loop(): pcx rqtyp "
					 "0x%x not yet implemented \r\n", rqtyp);
	    print_pcx_pkt(&pcx_pkt);
	    mbfw_exit(1);
	    break;
	}
#endif /* #ifdef T1_FPGA_SLAVE_CORE */
    }

    return;
}


