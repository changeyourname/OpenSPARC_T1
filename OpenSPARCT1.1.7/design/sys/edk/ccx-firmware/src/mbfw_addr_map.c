/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_addr_map.c
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


#ifndef REGRESSION_MODE

/*
 * This file is used for booting hypervisor/Operating System.
 */

#define  T1_PADDR_SEGMENT_COUNT   6

struct addr_map_info {
    taddr_t         t1_paddr_start;
    taddr_t         t1_paddr_end;
    maddr_t         mb_start;
    enum addr_type  addr_type;
};


/*
 * The following order is used for speeding up accesses to frequently used
 * address spaces while running hypervisor/Operating System.
 */

static struct addr_map_info  addr_map[T1_PADDR_SEGMENT_COUNT] = {
    { T1_ETH_PADDR_START,      T1_ETH_PADDR_END,      MB_INVALID_ADDR,      ETH_ADDR    },
    { T1_RAM_DISK_PADDR_START, T1_RAM_DISK_PADDR_END, MB_T1_RAM_DISK_START, MB_MEM_ADDR },
    { T1_PROM_PADDR_START,     T1_PROM_PADDR_END,     MB_T1_PROM_START,     MB_MEM_ADDR },
    { T1_UART_PADDR_START,     T1_UART_PADDR_END,     MB_INVALID_ADDR,      UART_ADDR   },
    { T1_DRAM_PADDR_START,     T1_DRAM_PADDR_END,     MB_T1_DRAM_START,     MB_MEM_ADDR },
    { T1_IOB_PADDR_START,      T1_IOB_PADDR_END,      MB_INVALID_ADDR,      IOB_ADDR    }
};


/*
 * Map T1 physical address space to microblaze address space. T1 dram, ram_disk
 * and prom address spaces are mapped to microblaze dram address space.
 */

enum addr_type
translate_addr(struct pcx_pkt *pcx_pkt, taddr_t t1_addr, maddr_t *mb_addr_ptr)
{
    int i;

    for (i = 0; i < T1_PADDR_SEGMENT_COUNT; i++) {
	if ((t1_addr >= addr_map[i].t1_paddr_start) && (t1_addr < addr_map[i].t1_paddr_end)) {
	    *mb_addr_ptr = addr_map[i].mb_start + (t1_addr - addr_map[i].t1_paddr_start);
            return addr_map[i].addr_type;
	}
    }

    mbfw_printf("MBFW_ERROR: translate_addr(): Couldn't find T1 to Microblaze "
			       "mapping for physical address 0x%x%08x \r\n",
			       (uint32_t)(t1_addr >> 32), (uint32_t) t1_addr);
    print_pcx_pkt(pcx_pkt);
    mbfw_exit(1);

    return -1;
}

#endif /* ifndef REGRESSION_MODE */
