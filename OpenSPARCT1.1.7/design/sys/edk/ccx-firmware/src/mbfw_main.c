/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_main.c
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
#include <stdio.h>
#include <stdlib.h>

#include <mb_interface.h>
#include <xparameters.h>

#include "mbfw_types.h"
#include "mbfw_config.h"
#include "mbfw_reverse_dir.h"
#include "mbfw_l2_emul.h"
#include "mbfw_pcx_cpx.h"
#include "mbfw_rtl.h"
#include "mbfw_gunzip.h"

#include "mbfw_xintc.h"


static void
init_dram(void)
{
    uint32_t *ptr = (uint32_t *) MB_T1_DRAM_START;
    uint32_t *end = (uint32_t *) (MB_T1_DRAM_START + T1_DRAM_SIZE);

    xil_printf("MBFW_INFO: Initializing OpenSPARC T1 DRAM from 0x%x to 0x%x \r\n", (uint32_t ) ptr, (uint32_t ) end);
    while (ptr < end) {
	*ptr++ = 0;
    }
    xil_printf("MBFW_INFO: Initialized OpenSPARC T1 DRAM \r\n");
}


static void
send_poweron_interrupt(void)
{
    int  cpu_id;
    struct cpx_pkt  cpx_pkt;
    int core_id;

    core_id = T1_MASTER_CORE_ID;
    cpu_id = T1_MASTER_CPU_ID;

    cpx_pkt_init(&cpx_pkt);

    CPX_PKT_SET_RTNTYP(&cpx_pkt, CPX_PKT_RTNTYP_INT_FLUSH);
    cpx_pkt.data0 = 0x00010001 | (cpu_id << INT_FLUSH_CPU_ID_SHIFT);
    cpx_pkt.data2 = cpx_pkt.data0;

    send_cpx_pkt_to_fsl(core_id, &cpx_pkt);

    return;
}


int
main(int argc, char *argv[])
{
    XIntc *xintc_ptr;

    microblaze_init_icache_range(0, XPAR_MICROBLAZE_0_CACHE_BYTE_SIZE);
    microblaze_enable_icache();

    microblaze_init_dcache_range(0, XPAR_MICROBLAZE_0_DCACHE_BYTE_SIZE);
    microblaze_enable_dcache();

    mbfw_printf("\r\n");


#ifndef T1_FPGA_SLAVE_CORE


#ifdef REGRESSION_MODE
    print_diag_name();
#else
    mbfw_printf("MBFW_INFO: Uncompressing ram_disk .....\r\n");
    mbfw_gunzip();
    mbfw_printf("MBFW_INFO: Uncompressed ram_disk \r\n");
#endif /* ifndef REGRESSION_MODE */

    init_l1_reverse_dir();

#ifndef REGRESSION_MODE
    init_dram();

    xintc_ptr = mbfw_xintc_init();
    if (xintc_ptr == NULL) {
	mbfw_printf("MBFW_ERROR: Interrupt controller initialization failed. \r\n");
	mbfw_exit(1);
    }
    mbfw_printf("MBFW_INFO: XIntc interrupt controller initialized. \r\n");
    if (mbfw_snet_init(xintc_ptr) < 0) {
	mbfw_printf("MBFW_INFO: Network controller initialization failed \r\n");
    }
    mbfw_printf("MBFW_INFO: Network controller initialized. \r\n");
#endif /* ifndef REGRESSION_MODE */


#endif /* ifndef T1_FPGA_SLAVE_CORE */


    mbfw_printf("MBFW_INFO: Microblaze firmware initialization completed. "
								   "\r\n\r\n");
#ifndef T1_FPGA_SLAVE_CORE
    mbfw_printf("MBFW_INFO: Powering on OpenSPARC T1 \r\n");
    send_poweron_interrupt();
#endif

    t1_system_emulation_loop();

    microblaze_disable_dcache();
    microblaze_init_dcache_range(0, XPAR_MICROBLAZE_0_DCACHE_BYTE_SIZE);

    microblaze_disable_icache();
    microblaze_init_icache_range(0, XPAR_MICROBLAZE_0_CACHE_BYTE_SIZE);

    return 0;
}
