/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_uart.c
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

#include <xparameters.h>
#include <xuartlite_l.h>

#include "mbfw_types.h"
#include "mbfw_config.h"
#include "mbfw_l2_emul.h"
#include "mbfw_pcx_cpx.h"
#include "mbfw_uart.h"


/* fpga board uartlite address map */

#define  MBFW_XUL_BASE_ADDR     XPAR_RS232_UART_1_BASEADDR

#define  MBFW_XUL_RX_FIFO_ADDR  (MBFW_XUL_BASE_ADDR + XUL_RX_FIFO_OFFSET)
#define  MBFW_XUL_TX_FIFO_ADDR  (MBFW_XUL_BASE_ADDR + XUL_TX_FIFO_OFFSET)
#define  MBFW_XUL_STATUS_ADDR   (MBFW_XUL_BASE_ADDR + XUL_STATUS_REG_OFFSET)
#define  MBFW_XUL_CONTROL_ADDR  (MBFW_XUL_BASE_ADDR + XUL_CONTROL_REG_OFFSET)




/* T1 UART 16550 registers */

#define	 MBFW_UART_RBR_REG            0x0
#define	 MBFW_UART_THR_REG            0x0
#define	 MBFW_UART_LSR_REG            0x5

#define  MBFW_UART_LSR_RDRY           0x01
#define  MBFW_UART_LSR_THRE           0x20
#define  MBFW_UART_LSR_TEMT           0x40


void
process_uart_load(struct pcx_pkt  *pcx_pkt,
		  struct cpx_pkt  *cpx_pkt,
		  taddr_t          t1_addr)
{
    uint_t    reg_offset;
    uint32_t  uart_word, uart_byte;


    reg_offset = t1_addr - T1_UART_PADDR_START;

    switch (reg_offset) {

    case MBFW_UART_RBR_REG:
	uart_word = *(uint32_t *) MBFW_XUL_RX_FIFO_ADDR;
	break;

    case MBFW_UART_LSR_REG:
	uart_word = 0;
	if (! XUartLite_mIsReceiveEmpty(MBFW_XUL_BASE_ADDR)) {
	    uart_word |= MBFW_UART_LSR_RDRY;
	}
	/* otherwise console writes crawl */
	uart_word |= (MBFW_UART_LSR_THRE | MBFW_UART_LSR_TEMT);
	break;

    default:
	mbfw_printf("MBFW_ERROR: process_uart_load(): unimplemented UART "
				    "register 0x%x accessed \r\n", reg_offset);
	print_pcx_pkt(pcx_pkt);
	mbfw_exit(1);
	break;
    }
    uart_byte = uart_word & 0xff;
    uart_word = (uart_byte << 24) | (uart_byte << 16) | \
		(uart_byte << 8) | uart_byte;

    cpx_pkt->data0 = uart_word;
    cpx_pkt->data1 = uart_word;
    cpx_pkt->data2 = uart_word;
    cpx_pkt->data3 = uart_word;

    return_load_req(pcx_pkt, cpx_pkt, t1_addr, MB_INVALID_ADDR, 0);

    return;
}


void
process_uart_store(struct pcx_pkt  *pcx_pkt,
		   struct cpx_pkt  *cpx_pkt,
		   taddr_t          t1_addr)
{
    uint_t  reg_offset;
    int     ch;


    reg_offset = (uint_t ) t1_addr - T1_UART_PADDR_START;

    switch (reg_offset) {

    case MBFW_UART_THR_REG:
	ch = pcx_pkt->data1 & 0xff;
	XUartLite_SendByte(MBFW_XUL_BASE_ADDR, ch);
	break;

    default:
	/*
	 * Hypervisor stores to other registers only during UART initialization
	 * and can be ignored.
	 */
	break;
    }

    return_store_ack(pcx_pkt, cpx_pkt, t1_addr, 0, INVALIDATE_NONE);

    return;
}
