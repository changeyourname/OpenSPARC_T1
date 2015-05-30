/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_xemaclite_intr.c
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
#ifdef T1_FPGA_XEMACLITE

#include <stdio.h>
#include <stdlib.h>

#include "xparameters.h"
#include "xstatus.h"
#include "xemaclite.h"
#include "xintc.h"
#include "mb_interface.h"


#include "mbfw_types.h"
#include "mbfw_xemaclite_intr.h"


/* 
 * The xemaclite device driver doesn't return the correct length of
 * the packet. It returns XEL_MAX_FRAME_SIZE as the length for most of
 * the packets.
 */

#define  XEMACLITE_PKT_LENGTH_BUG_WORKAROUND   1


static int xemaclite_start(struct snet *snetp, void *eth_instance);
static int xemaclite_stop(struct snet *snetp, void *eth_instance);
static int xemaclite_set_mac_addr(struct snet *snetp, void *eth_instance, uint8_t mac_addr[]);
static int xemaclite_tx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size);
static int xemaclite_rx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t *frame_size_ptr);



static XEmacLite  xemaclite;


static int
xemaclite_setup_intr_system(XIntc     *xintc_instance,
		            XEmacLite *xemaclite_instance,
		            Xuint16    xemaclite_intr_id)
{
    XStatus status;

    /*
     * Register an interrupt handler for the device interrupts with
     * the interrupt controller.
     */
    status = XIntc_Connect(xintc_instance,
                           xemaclite_intr_id,
                           XEmacLite_InterruptHandler,
                           xemaclite_instance);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XIntc_Connect() failed with status 0x%x \r\n", status);
        return -1;
    }


    /*
     * Enable the interrupt for the EmacLite in the interrupt controller.
     */
    XIntc_Enable(xintc_instance, xemaclite_intr_id);

    return 0;
}


int
eth_init(struct snet *snetp, XIntc *xintc_instance, struct eth_init_data *init_data)
{
    XStatus     status;
    int		result;
    Xuint16     xemaclite_device_id;
    Xuint16     xemaclite_intr_id;
    XEmacLite  *xemaclite_instance;

    struct mac_callbacks  mac_callbacks;

    void    (*send_handler)(void *callback_ref);
    void    (*recv_handler)(void *callback_ref);


    xemaclite_device_id = XPAR_ETHERNET_MAC_DEVICE_ID;
    xemaclite_intr_id   = XPAR_XPS_INTC_0_ETHERNET_MAC_IP2INTC_IRPT_INTR;

    xemaclite_instance = &xemaclite;

    send_handler  = init_data->tx_handler;
    recv_handler  = init_data->rx_handler;


    status = XEmacLite_Initialize(xemaclite_instance, xemaclite_device_id);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XEmacLite_Initialize() failed with status 0x%x. \r\n", status);
	return -1;
    }

    result = xemaclite_setup_intr_system(xintc_instance,
				         xemaclite_instance,
				         xemaclite_intr_id);
    if (result < 0) {
        return result;
    }


    if (send_handler) {
	XEmacLite_SetSendHandler(xemaclite_instance, snetp,
				 (XEmacLite_Handler) send_handler);
    }

    if (recv_handler) {
	XEmacLite_SetRecvHandler(xemaclite_instance, snetp,
				 (XEmacLite_Handler) recv_handler);
    }

    mac_callbacks.eth_start         = xemaclite_start;
    mac_callbacks.eth_stop          = xemaclite_stop;
    mac_callbacks.eth_set_mac_addr  = xemaclite_set_mac_addr;
    mac_callbacks.eth_tx            = xemaclite_tx;
    mac_callbacks.eth_rx            = xemaclite_rx;
    mac_callbacks.eth_rx_tohw       = NULL;

    mbfw_snet_register(snetp, xemaclite_instance, &mac_callbacks);

    return 0;
}


static int
xemaclite_start(struct snet *snetp, void *eth_instance)
{
    XEmacLite *xemaclite_instance = (XEmacLite *) eth_instance;
    XStatus  status;

    XEmacLite_FlushReceive(xemaclite_instance);
    status = XEmacLite_EnableInterrupts(xemaclite_instance);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XEmacLite_EnableInterrupts() failed with status 0x%x \r\n", status);
	mbfw_exit(1);
	return -1;
    }

    return 0;
}


static int
xemaclite_stop(struct snet *snetp, void *eth_instance)
{
    XEmacLite *xemaclite_instance = (XEmacLite *) eth_instance;

    XEmacLite_DisableInterrupts(xemaclite_instance);

    return 0;
}

static int
xemaclite_set_mac_addr(struct snet *snetp, void *eth_instance, uint8_t mac_addr[])
{
    XEmacLite *xemaclite_instance = (XEmacLite *) eth_instance;

    XEmacLite_SetMacAddress(xemaclite_instance, mac_addr);

    return 0;
}


static int
xemaclite_tx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size)
{
    XEmacLite *xemaclite_instance = (XEmacLite *) eth_instance;

    XStatus status;

    status = XEmacLite_Send(xemaclite_instance, frame, frame_size);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XEmacLite_Send() failed with status 0x%x \r\n", status);
	return -1;
    }

    return 0;
}

static int
xemaclite_rx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t *frame_size_ptr)
{
    XEmacLite *xemaclite_instance = (XEmacLite *) eth_instance;

    ushort_t   *eth_pkt;

    *frame_size_ptr = XEmacLite_Recv(xemaclite_instance, frame);

#ifdef XEMACLITE_PKT_LENGTH_BUG_WORKAROUND
    if (*frame_size_ptr == XEL_MAX_FRAME_SIZE) {
	eth_pkt = (ushort_t *) frame;
	if (eth_pkt[ETH_PKT_TYPE_LEN] == ETH_PKT_TYPE_IP) {
	    *frame_size_ptr = eth_pkt[ETH_IP_PKT_LEN] + ETH_HDR_SIZE;
	} else if (eth_pkt[ETH_PKT_TYPE_LEN] == ETH_PKT_TYPE_ARP) {
	    *frame_size_ptr = 60;
	} else {
	    // mbfw_printf("MBFW_WARN: xemaclite_rx(): unknown packet type 0x%x \r\n", eth_pkt[ETH_PKT_TYPE_LEN]);
	}
    }
#endif /* ifdef XEMACLITE_PKT_LENGTH_BUG_WORKAROUND */

    return 0;
}


#endif /* ifdef T1_FPGA_XEMACLITE */
