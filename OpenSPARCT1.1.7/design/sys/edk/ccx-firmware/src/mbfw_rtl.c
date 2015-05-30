/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_rtl.c
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
#include "mbfw_rtl.h"



#ifdef REGRESSION_MODE


/*
 * This file is used for running RTL diags
 */

extern memimage_t  MEM_IMAGE[];
extern char        *test_name;


uint32_t started_cpus = (1U << T1_MASTER_CPU_ID);

static uint8_t speculative_ifill_data[32] __attribute__ ((aligned(32)));



/*
 * Map T1 physical address space to microblaze address space. T1 dram and prom
 * address spaces are mapped to microblaze dram address space. IO devices are
 * not supported. IOB address space is supported.
 */

enum addr_type
translate_addr(struct pcx_pkt *pcx_pkt, taddr_t t1_addr, maddr_t *mb_addr_ptr)
{
    int       i, rqtyp;
    uint32_t *addr_ptr;

    rqtyp = PCX_PKT_GET_RQTYP(pcx_pkt);


    if (rqtyp == PCX_REQ_IFILL) {
	if ((t1_addr == GOODTRAP_ADDR_0) || (t1_addr == GOODTRAP_ADDR_1) || (t1_addr == GOODTRAP_ADDR_2)) {
	    mbfw_printf("MBFW_INFO: received ifill request for good trap addr:  0x%x%08x\r\n",
		    (uint32_t)(t1_addr >> 32), (uint32_t) t1_addr);
	}
	if ((t1_addr == BADTRAP_ADDR_0) || (t1_addr == BADTRAP_ADDR_1) || (t1_addr == BADTRAP_ADDR_2)) {
	    mbfw_printf("MBFW_INFO: received ifill request for bad trap addr:  0x%x%08x\r\n",
		    (uint32_t)(t1_addr >> 32), (uint32_t) t1_addr);
	}
    }


    i = 0;
    for (;;) {
	if (MEM_IMAGE[i].index == -1) {
	    break;
	}
	if ( (t1_addr >= MEM_IMAGE[i].t1_paddr) &&
	     (t1_addr < (MEM_IMAGE[i].t1_paddr + (MEM_IMAGE[i].n_dwords * sizeof(uint64_t)))) ) {
	    *mb_addr_ptr = (maddr_t ) (((uint8_t *)MEM_IMAGE[i].data) + (t1_addr - MEM_IMAGE[i].t1_paddr));
	    return MB_MEM_ADDR;
	}
	i++;
    }


    if (rqtyp == PCX_REQ_IFILL) {
	/* the instructions in this packet should never be executed. */
	*mb_addr_ptr = (maddr_t ) speculative_ifill_data;
	mbfw_printf("MBFW_INFO: speculative_ifill_data being returned for "
				"0x%x%08x \r\n",
				(uint32_t)(t1_addr >> 32), (uint32_t) t1_addr);
	return MB_MEM_ADDR;
    }

    if ((t1_addr >= T1_IOB_PADDR_START) && (t1_addr < T1_IOB_PADDR_END)) {
	*mb_addr_ptr = MB_INVALID_ADDR;
	return IOB_ADDR;
    }


    mbfw_printf("MBFW_ERROR: translate_addr(): Couldn't find T1 to Microblaze "
			       "mapping for physical address 0x%x%08x \r\n",
			       (uint32_t)(t1_addr >> 32), (uint32_t) t1_addr);
    print_pcx_pkt(pcx_pkt);
    mbfw_exit(1);

    return -1;
}


void
print_diag_name(void)
{
    mbfw_printf("MBFW_INFO: Running RTL diag \"%s\" \r\n", test_name);
    return;
}

void
mbfw_exit(int status)
{
    uint32_t *addr_ptr;

    mbfw_printf("MBFW_INFO: exiting with error status %d \r\n", status);

    addr_ptr  = (uint32_t *) EXITCODE_ADDR;
    *addr_ptr = EXITCODE_ERROR;
    exit(status);
}


#endif /* ifdef REGRESSION_MODE */
