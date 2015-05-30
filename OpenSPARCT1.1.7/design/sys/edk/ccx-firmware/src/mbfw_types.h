/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_types.h
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
#ifndef MBFW_TYPES_H_
#define MBFW_TYPES_H_



#ifdef  __cplusplus
extern "C" {
#endif


/*
 * MB_MEM_ADDR:  microblaze memory address
 * UART_ADDR:    uart address
 * ETH_ADDR:     ethernet address
 * IOB_ADDR:     T1 iob address
 */

enum addr_type { MB_MEM_ADDR, UART_ADDR, ETH_ADDR, IOB_ADDR };


typedef unsigned char       uchar_t;
typedef unsigned short      ushort_t;
typedef unsigned int        uint_t;

typedef unsigned char       uint8_t;
typedef unsigned short      uint16_t;
typedef unsigned int        uint32_t;
typedef unsigned long long  uint64_t;


typedef uint64_t            taddr_t;     /* T1 physical address */
typedef uint32_t            maddr_t;     /* Microblaze address */


/*
 * T1 DRAM physical address space starts from 0 and is normally less than 4GB.
 * T1 DRAM physical address can be represented in a 32-bit integer and it
 * increases the performance of the system by speeding up L2/memory accesses.
 * In REGRESSION_MODE, the DRAM physical address space is not contiguous and
 * the DRAM address may not fit in a 32-bit integer.
 */

#ifdef REGRESSION_MODE
typedef taddr_t            taddr_opt_t;
#else
typedef uint32_t           taddr_opt_t;
#endif


#define MB_INVALID_ADDR     -1U          /* invalid microblaze DRAM address */



#ifdef SIMULATION
#define mbfw_printf(format, ...)     /* In simulation environment console printing is disabled. */
#else
#define mbfw_printf(format, ...)     xil_printf(format, ## __VA_ARGS__)
#endif


#ifndef REGRESSION_MODE
#define mbfw_exit(status)            exit(status)
#endif


#ifdef  __cplusplus
}
#endif


#endif /* #ifndef MBFW_TYPES_H_ */
