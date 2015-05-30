/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_snet.h
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
#ifndef MBFW_SNET_H_
#define MBFW_SNET_H_

#include "mbfw_types.h"
#include "mbfw_pcx_cpx.h"

#include <xintc.h>


#ifdef  __cplusplus
extern "C" {
#endif


#define ETH_HDR_SIZE       14

/* IP packet field offsets relative to the start of IP header */

#define IP_PKT_IHL         0
#define IP_PKT_LEN         1
#define IP_PKT_PROTOCOL    4
#define IP_PKT_CHECKSUM    5
#define IP_PKT_SRC         6
#define IP_PKT_DST         8

/* TCP packet field offsets relative to the start of TCP header */

#define TCP_PKT_CHECKSUM   8

/* Ethernet packet field offsets relative to the start of ETH header */

#define ETH_PKT_TYPE_LEN   6
#define ETH_PKT_IP         7

/* IP packet field offsets relative to the start of ETH header */

#define ETH_IP_PKT_IHL          (ETH_PKT_IP + IP_PKT_IHL)
#define ETH_IP_PKT_LEN          (ETH_PKT_IP + IP_PKT_LEN)
#define ETH_IP_PKT_PROTOCOL     (ETH_PKT_IP + IP_PKT_PROTOCOL)
#define ETH_IP_PKT_SRC          (ETH_PKT_IP + IP_PKT_SRC)
#define ETH_IP_PKT_DST          (ETH_PKT_IP + IP_PKT_DST)


#define ETH_PKT_TYPE_IP    0x0800
#define ETH_PKT_TYPE_ARP   0x0806


#define  SNET_ETH_HDR_SIZE    6
#define  SNET_MTU             1600

#define  SNET_TX_BUFS_COUNT   1
#define  SNET_RX_BUFS_COUNT   16 /* These values determine the number of descriptors used in xlltemac driver */


struct snet;


struct mac_callbacks {
    int (*eth_start)(struct snet *snetp, void *eth_instance);
    int (*eth_stop)(struct snet *snetp, void *eth_instance);
    int (*eth_set_mac_addr)(struct snet *snetp, void *eth_instance, uint8_t mac_addr[]);
    int (*eth_tx)(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size);
    int (*eth_rx)(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t *frame_size_ptr);
    int (*eth_rx_tohw)(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size);
        /* eth_rx_tohw gives control over the rx buffer to the hardware (DMA) */
};

struct eth_init_data {
    void      (*tx_handler)(void *callback_ref);
    void      (*rx_handler)(void *callback_ref);
    void      (*error_handler)(void *callback_ref);
};


int  mbfw_snet_init(XIntc *intc_instance);
void mbfw_snet_register(struct snet *snetp, void *eth_instance, struct mac_callbacks *mcp);
void mbfw_snet_load(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt, taddr_t t1_addr);
void mbfw_snet_store(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt, taddr_t t1_addr);


#ifdef  __cplusplus
}
#endif


#endif /* ifndef MBFW_SNET_H_ */

