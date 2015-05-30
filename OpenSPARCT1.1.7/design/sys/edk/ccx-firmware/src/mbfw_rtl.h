/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_rtl.h
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
#ifndef MBFW_RTL_H_
#define MBFW_RTL_H_

#ifdef REGRESSION_MODE

#include <xparameters.h>
#include "mbfw_types.h"


#ifdef  __cplusplus
extern "C" {
#endif


#define     GOODTRAP_ADDR_0             0x1000122000ULL
#define     GOODTRAP_ADDR_1             0x82000ULL
#define     GOODTRAP_ADDR_2             0x1A00122000ULL
#define     BADTRAP_ADDR_0              0x1000122020ULL
#define     BADTRAP_ADDR_1              0x82020ULL
#define     BADTRAP_ADDR_2              0x1A00122020ULL

#define     EXITCODE_ADDR               (XPAR_DDR2_SDRAM_MPMC_BASEADDR + 0xFFFFFF0)

#define     EXITCODE_GOODTRAP           0xFEDCBA98
#define     EXITCODE_BADTRAP            0x76543210
#define     EXITCODE_ERROR              0xFFFF5555


#define     THREAD_EXIT_STATUS_ADDR_0   0x1000134c00ULL	// Supervisor
#define     THREAD_EXIT_STATUS_ADDR_1   0x94300ULL	// Hypervisor

typedef struct {
    uint64_t  index;      /* Index of the array */
    uint64_t  t1_paddr;   /* T1 Physical Address */
    uint64_t  n_dwords;   /* Size of contiguous block in double words*/
    uint64_t *data;       /* Block of contiguous double words */
} memimage_t;


extern uint32_t started_cpus;

void  print_diag_name(void);
void  mbfw_exit(int status);


#ifdef  __cplusplus
}
#endif


#endif /* ifdef REGRESSION_MODE */


#endif /* ifndef MBFW_RTL_H_ */
