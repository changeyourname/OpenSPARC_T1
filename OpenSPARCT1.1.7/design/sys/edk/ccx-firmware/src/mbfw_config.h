/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_config.h
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
#ifndef MBFW_CONFIG_H_
#define MBFW_CONFIG_H_


#include <xparameters.h>


#ifdef  __cplusplus
extern "C" {
#endif


/*

FPGA board 256MB DRAM memory partition

						FPGA board
						DRAM address

 ----------------------------------------------    XPAR_DDR2_SDRAM_MPMC_BASEADDR + 0x00000000
|    executable.elf                            |
|                                              |
 ----------------------------------------------    XPAR_DDR2_SDRAM_MPMC_BASEADDR + 0x00100000
|                                              |
|    T1 DRAM      0 - 0xAE00000                |
|                                              |
 ----------------------------------------------    XPAR_DDR2_SDRAM_MPMC_BASEADDR + 0x0af00000
|                                              |
|                                              |
|    T1 RAM DISK  0xfff1000000 - 0xfff6000000  |
|                                              |
 ----------------------------------------------    XPAR_DDR2_SDRAM_MPMC_BASEADDR + 0x0ff00000
|                                              |
|                                              |
|    T1 PROM      0xfff0000000 - 0xfff00100000 |
|                                              |
 ----------------------------------------------


UART and Ethernet controller are the only IO devices supported.

IOB address space doesn't require memory allocation.

*/



#define	 T1_DRAM_PADDR_START      0x0
#define	 T1_DRAM_SIZE             0x0AE00000  /* prom.bin uses only 0xAC00000 because of Linux, multiple of 4MB memory size requirement. */
#define	 T1_DRAM_PADDR_END        (T1_DRAM_PADDR_START + T1_DRAM_SIZE)

#define  T1_IOB_PADDR_START       0x9800000000ULL
#define  T1_IOB_SIZE              0x1400000000ULL
#define  T1_IOB_PADDR_END         (T1_IOB_PADDR_START + T1_IOB_SIZE) /* 0xAC00000000 */

#define  T1_PROM_PADDR_START      0xfff0000000ULL
#define  T1_PROM_SIZE             0x00100000
#define  T1_PROM_PADDR_END        (T1_PROM_PADDR_START + T1_PROM_SIZE)

#define  T1_RAM_DISK_PADDR_START  0xfff1000000ULL
#define  T1_RAM_DISK_SIZE         0x05000000
#define  T1_RAM_DISK_PADDR_END    (T1_RAM_DISK_PADDR_START + T1_RAM_DISK_SIZE)

#define	 T1_UART_PADDR_START	  0xfff0c2c000ULL
#define	 T1_UART_SIZE    	  0x8
#define	 T1_UART_PADDR_END        (T1_UART_PADDR_START + T1_UART_SIZE)

#define	 T1_ETH_PADDR_START	  0xfff0c2c050ULL
#define	 T1_ETH_SIZE    	  0x30
#define	 T1_ETH_PADDR_END         (T1_ETH_PADDR_START + T1_ETH_SIZE)



#define	 MB_T1_DRAM_START         (XPAR_DDR2_SDRAM_MPMC_BASEADDR + 0x100000)
#define  MB_T1_RAM_DISK_START     (MB_T1_DRAM_START + T1_DRAM_SIZE)
#define  MB_T1_PROM_START         (MB_T1_RAM_DISK_START + T1_RAM_DISK_SIZE)


#define  T1_MASTER_CORE_ID        0
#define  T1_SLAVE_CORE_ID         1

#define  T1_MASTER_CPU_ID         0
#define  T1_SLAVE_CPU_ID          4

#ifdef T1_FPGA_DUAL_CORE
#define  T1_NUM_OF_CORES          2
#define  T1_NUM_OF_CPUS           8
#else
#define  T1_NUM_OF_CORES          1
#define  T1_NUM_OF_CPUS           4
#endif


#ifdef  __cplusplus
}
#endif


#endif /* ifndef MBFW_CONFIG_H_ */
