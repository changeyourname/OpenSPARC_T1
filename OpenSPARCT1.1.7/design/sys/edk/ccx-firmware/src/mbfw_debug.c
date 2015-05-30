/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_debug.c
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
#include "mbfw_debug.h"


#if  MBFW_DEBUG > 0

static char *rqtyp2names[PCX_REQ_MAX] = { "   LD",
					  "   ST",
					  "  CLD",
					  "  CST",
					  "  SLD",
					  "  SST",
					  " SWAP",
					  "",
					  "",
					  "FLUSH",
					  "  FP1",
					  "  FP2",
					  "",
					  "",
					  "",
					  "",
					  "IFILL"
					};


static void
print_pcx_req_info(struct pcx_pkt *pcx_pkt)
{
    taddr_t  t1_addr = PCX_PKT_GET_T1_ADDR(pcx_pkt);

    int NC        = PCX_PKT_GET_NC(pcx_pkt);
    int IO        = PCX_PKT_GET_IO_SPACE(pcx_pkt);
    int rqtyp     = PCX_PKT_GET_RQTYP(pcx_pkt);
    int cpu_id    = PCX_PKT_GET_CPU_ID(pcx_pkt);

    if (rqtyp >= PCX_REQ_MAX) {
	mbfw_printf("MBFW_ERROR: pcx packet with invalid rqtyp 0x%x "
					     "received. \r\n", rqtyp);
	print_pcx_pkt(pcx_pkt);
	mbfw_exit(1);
    }

    mbfw_printf("MBFW_INFO: cpu %d: rqtyp %s t1_addr 0x%x%08x NC 0x%x "
			      "IO 0x%x \r\n", cpu_id, rqtyp2names[rqtyp],
			      (uint32_t) (t1_addr >> 32), (uint32_t) t1_addr,
			      NC, IO);
}



void
mbfw_debug_pcx_pkt(struct pcx_pkt *pcx_pkt)
{
#if MBFW_DEBUG > 1
    print_pcx_req_info(pcx_pkt);
#endif

#if MBFW_DEBUG > 2
    print_pcx_pkt(pcx_pkt);
#endif

    return;
}


void
mbfw_debug_cpx_pkt(struct cpx_pkt *cpx_pkt)
{

#if MBFW_DEBUG > 2
    print_cpx_pkt(cpx_pkt);
#endif

    return;
}

#endif /* if MBFW_DEBUG > 0 */
