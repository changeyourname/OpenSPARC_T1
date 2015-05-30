/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_xemac_intr.c
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
#ifdef T1_FPGA_XEMAC

#include <stdio.h>
#include <stdlib.h>

#include "xparameters.h"
#include "xstatus.h"
#include "xemac.h"
#include "xintc.h"
#include "mb_interface.h"

#include "mbfw_types.h"
#include "mbfw_xemac_intr.h"



static int xemac_start(struct snet *snetp, void *eth_instance);
static int xemac_stop(struct snet *snetp, void *eth_instance);
static int xemac_set_mac_addr(struct snet *snetp, void *eth_instance, uint8_t mac_addr[]);
static int xemac_tx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size);
static int xemac_rx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t *frame_size_ptr);



#define DEFAULT_OPTIONS      (XEM_UNICAST_OPTION | XEM_INSERT_PAD_OPTION | \
                              XEM_INSERT_FCS_OPTION | XEM_INSERT_ADDR_OPTION | \
                              XEM_OVWRT_ADDR_OPTION)

static XEmac  xemac;


static int
emac_setup_intr_system(XIntc   *xintc_instance,
		       XEmac   *xemac_instance,
		       Xuint16  xemac_device_id,
		       Xuint16  xemac_intr_id)
{
    XStatus status;


    /*
     * Register an interrupt handler for the device interrupts with
     * the interrupt controller.
     */
    status = XIntc_Connect(xintc_instance,
                           xemac_intr_id,
                           (XInterruptHandler)XEmac_IntrHandlerFifo,
                           xemac_instance);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XIntc_Connect() failed with status 0x%x \r\n", status);
        return XST_FAILURE;
    }

    /*
     * Enable the interrupt for the Emac in the interrupt controller.
     */
    XIntc_Enable(xintc_instance, xemac_intr_id);

    microblaze_register_handler((XInterruptHandler)XIntc_InterruptHandler,
                                xintc_instance);

    return XST_SUCCESS;
}

static void
xemac_error_handler(void *callback_ref, XStatus error_code)
{
    struct snet *snetp = (struct snet *) callback_ref;

    mbfw_printf("MBFW_ERROR: xemac_error_handler called with error_code 0x%x \r\n", (uint_t ) error_code);
    mbfw_printf("MBFW_ERROR: user error_handler is not called even if set during initialization \r\n");
}

int
eth_init(struct snet *snetp, XIntc *xintc_instance, struct eth_init_data *init_data)
{
    int           result;
    XStatus       status;
    Xuint32       options;
    XEmac_Config *config;

    Xuint16     xemac_device_id;
    Xuint16     xemac_intr_id;
    XEmac      *xemac_instance;

    struct mac_callbacks  mac_callbacks;

    void    (*send_handler)(void *callback_ref);
    void    (*recv_handler)(void *callback_ref);
    void    (*error_handler)(void *callback_ref);


    xemac_device_id = XPAR_ETHERNET_MAC_DEVICE_ID;
    xemac_intr_id   = XPAR_OPB_INTC_0_ETHERNET_MAC_IP2INTC_IRPT_INTR;

    xemac_instance = &xemac;

    send_handler  = init_data->tx_handler;
    recv_handler  = init_data->rx_handler;
    error_handler = init_data->error_handler;


    /*
     * We change the configuration of the device to indicate no DMA just in
     * case it was built with DMA. In order for this code to work, you
     * either need to do this or, better yet, build the hardware without DMA.
     */
    config = XEmac_LookupConfig(xemac_device_id);
    config->IpIfDmaConfig = XEM_CFG_NO_DMA;

    status = XEmac_Initialize(xemac_instance, xemac_device_id);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XEmac_Initialize() failed with status 0x%x \r\n", status);
        return -1;
    }

    status = XEmac_SelfTest(xemac_instance);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XEmac_SelfTest() failed with status 0x%x \r\n", status);
        return -1;
    }

    /*
     * Configure the device for unicast and broadcast addressing.
     */

    options = (DEFAULT_OPTIONS | XEM_BROADCAST_OPTION);
    status = XEmac_SetOptions(xemac_instance, options);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XEmac_SetOptions() failed with status 0x%x \r\n", status);
        return -1;
    }


    /*
     * Connect to the interrupt controller and enable interrupts
     */
    result = emac_setup_intr_system(xintc_instance,
                                    xemac_instance,
                                    xemac_device_id,
                                    xemac_intr_id);
    if (result < 0) {
        return -1;
    }

    /*
     * Set the FIFO callbacks and error handler. These callbacks are invoked
     * by the driver during interrupt processing.
     */
    XEmac_SetFifoSendHandler(xemac_instance, snetp, send_handler);
    XEmac_SetFifoRecvHandler(xemac_instance, snetp, recv_handler);
    /*
     * Ignoring the user error_handler because of mismatch in function types.
     * Needs to be fixed.
     */
    XEmac_SetErrorHandler(xemac_instance, snetp, xemac_error_handler);


    mac_callbacks.eth_start         = xemac_start;
    mac_callbacks.eth_stop          = xemac_stop;
    mac_callbacks.eth_set_mac_addr  = xemac_set_mac_addr;
    mac_callbacks.eth_tx            = xemac_tx;
    mac_callbacks.eth_rx            = xemac_rx;
    mac_callbacks.eth_rx_tohw       = NULL;

    mbfw_snet_register(snetp, xemac_instance, &mac_callbacks);

    return 0;
}


static int
xemac_start(struct snet *snetp, void *eth_instance)
{
    XEmac   *xemac_instance = (XEmac *) eth_instance;
    XStatus  status;

    status = XEmac_Start(xemac_instance);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XEmac_Start() failed with status 0x%x \r\n", status);
    }
    XEmac_ClearStats(xemac_instance);

    return 0;
}


static int
xemac_stop(struct snet *snetp, void *eth_instance)
{
    XEmac   *xemac_instance = (XEmac *) eth_instance;
    XStatus  status;

    status = XEmac_Stop(xemac_instance);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XEmac_Stop() failed with status 0x%x \r\n", status);
    }

    return 0;
}

static int
xemac_set_mac_addr(struct snet *snetp, void *eth_instance, uint8_t mac_addr[])
{
    XEmac   *xemac_instance = (XEmac *) eth_instance;
    XStatus  status;

    status = XEmac_SetMacAddress(xemac_instance, mac_addr);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XEmac_SetMacAddress() failed with status 0x%x \r\n", status);
    }

    return 0;
}

static int
xemac_tx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size)
{
    XEmac      *xemac_instance = (XEmac *) eth_instance;
    XStatus status;

    status = XEmac_FifoSend(xemac_instance, frame, frame_size);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_WARN: XEmac_FifoSend failed \r\n");
	return -1;
    }

    return 0;
}

static int
xemac_rx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t *frame_size_ptr)
{
    XEmac      *xemac_instance = (XEmac *) eth_instance;
    XStatus status;

    status = XEmac_FifoRecv(xemac_instance, frame, (Xuint32 *) frame_size_ptr);
    if (status != XST_SUCCESS) {
	*frame_size_ptr = 0;
	if (status != XST_NO_DATA) {
	    mbfw_printf("MBFW_ERROR: eth_rx(): XEmac_FifoRecv() failed with status 0x%x \r\n", status);
	    return -1;
	}
    }

    return 0;
}

#endif /* ifdef T1_FPGA_XEMAC */
