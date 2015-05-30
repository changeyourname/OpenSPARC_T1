/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_snet.c
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
#include "mbfw_l2_emul.h"
#include "mbfw_pcx_cpx.h"
#include "mbfw_snet.h"

#include <xintc.h>

#ifdef T1_FPGA_XEMAC
#include "mbfw_xemac_intr.h"
#elsif T1_FPGA_XEMACLITE
#include "mbfw_xemaclite_intr.h"
#else
#include "mbfw_xlltemac_intr.h"
#endif


#define SNET_CMD_NONE	          0x00
#define SNET_CMD_START	          0x01
#define SNET_CMD_STOP	          0x02
#define SNET_CMD_TX	          0x04
#define SNET_CMD_RX	          0x08
#define SNET_CMD_MAC	          0x10
#define SNET_CMD_POLLING          0x20
#define SNET_CMD_TX_TCP_CHECKSUM  0x40


#define  SNET_IDLE                0
#define  SNET_RECEIVING           1
#define  SNET_SENDING             2


#define  SNET_VERBOSE_NONE        0
#define  SNET_VERBOSE_LOW         1
#define  SNET_VERBOSE_MED         2
#define  SNET_VERBOSE_HIGH        3


struct rx_buf {
    uint32_t    pkt_size;
    uint32_t    unused;
    uint64_t    buf[SNET_MTU / sizeof(uint64_t)] __attribute__ ((aligned(8)));  /* must be aligned on 8 byte boundary */
};

struct snet {
    uint32_t          recv_msg_type;
    uint32_t          recv_msg_data_size;   /* Total data to be received from OpenSPARC T1 */
    uint32_t          received_data_count;  /* Data received so far from OpenSPARC T1 */
    int               recv_state;

    uint32_t          send_msg_type;
    uint32_t          send_msg_data_size;   /* Total data to be sent to OpenSPARC T1 */
    uint32_t          sent_data_count;      /* Data sent so far to OpenSPARC T1 */
    int               send_state;


    uint8_t           mac_addr[SNET_ETH_HDR_SIZE];


    int               tx_tcp_checksum;   /* OS currently expects the default value to be 1 */
    int               start;             /* ethernet controller is active if set */
    int               polling_mode;      /* OS currently expects the default value to be 0 */
    int		      verbose_flag;


    uint64_t          tx_buf[SNET_MTU / sizeof(uint64_t)] __attribute__ ((aligned(8))) ;   /* must be aligned on 8 byte boundary */
    volatile int      transmit_complete;


    struct rx_buf     rx_bufs_memory[SNET_RX_BUFS_COUNT];
    struct rx_buf    *rx_bufs[SNET_RX_BUFS_COUNT];
    int               rx_head;
    int               rx_tail;
    int               rx_count;
    int               max_rx_count;
    int               rx_full_count;


    int               (*eth_start)(struct snet *snetp, void *eth_instance);
    int               (*eth_stop)(struct snet *snetp, void *eth_instance);
    int               (*eth_set_mac_addr)(struct snet *snetp, void *eth_instance, uint8_t mac_addr[]);
    int               (*eth_tx)(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size);
    int               (*eth_rx)(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t *frame_size_ptr);
    int               (*eth_rx_tohw)(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size);
                      /* eth_rx_tohw gives control over the rx buffer to the hardware (DMA) */

    void             *eth_instance;
};


extern int send_intr_packet;

static struct snet  snet;
static struct snet *snetp = &snet;


static ushort_t
snet_in_checksum(ushort_t *addr, int len, int sum)
{
        int nleft = len;
        ushort_t *w = addr;
        ushort_t answer;
        ushort_t odd_byte = 0;

        while (nleft > 1) {
                sum += *w++;
                nleft -= 2;
        }

        /* mop up an odd byte, if necessary */
        if (nleft == 1) {
                *(uchar_t *)(&odd_byte) = *(uchar_t *)w;
                sum += odd_byte;
        }

        /*
         * add back carry outs from top 16 bits to low 16 bits
         */
        sum = (sum >> 16) + (sum & 0xffff);     /* add hi 16 to low 16 */
        sum += (sum >> 16);                     /* add carry */
        answer = ~sum;                          /* truncate to 16 bits */
        return (answer);
}

static void
print_packet(unsigned char *ptr, int len)
{
    int index;

    for (index=0; index<len; index++) {
	if ((index % 16) == 0) {
	    xil_printf("\r\n");
	    xil_printf("MBFW_INFO: 0x%02x:", index);
	}
	if ((index % 4) == 0) {
	    xil_printf(" 0x");
	}
	xil_printf("%02x", ptr[index]);
    }
    xil_printf("\r\n");

    return;
}


static uint64_t throwaway_pkt[SNET_MTU / 8];
static uint32_t throwaway_size;

static void
snet_send_handler(void *callback_ref)
{
    struct snet *snetp = (struct snet *) callback_ref;

    snetp->transmit_complete = 1;
}

static void
snet_error_handler(void *callback_ref)
{
    struct snet *snetp = (struct snet *) callback_ref;

    mbfw_printf("MBFW_ERROR: snet_error_handler() called \r\n");
}

static void
snet_recv_handler(void *callback_ref)
{
    struct snet *snetp = (struct snet *) callback_ref;
    int rx_tail  = snetp->rx_tail;
    int rx_head  = snetp->rx_head;
    int rx_count = snetp->rx_count;

    struct rx_buf *rx_buf = snetp->rx_bufs[rx_tail];

    if (snetp->start == 0) {
	/* Shouldn't come here if xlltemac is used*/
	throwaway_size = SNET_MTU;
	(void) (*snetp->eth_rx)(snetp, snetp->eth_instance, (uint8_t *) &throwaway_pkt, &throwaway_size);
	return;
    }

    if ((rx_tail == rx_head) && (rx_count > 0)) {
	/* Shouldn't come here if xlltemac is used*/
	if ((snetp->rx_full_count & 0xFF) == 0) {
	    if (snetp->verbose_flag >= SNET_VERBOSE_LOW) {
		mbfw_printf("MBFW_INFO: snet_recv_handler: rx_full_count 0x%x \r\n", snetp->rx_full_count);
	    }
	}
	snetp->rx_full_count++;
	throwaway_size = SNET_MTU;
	(void) (*snetp->eth_rx)(snetp, snetp->eth_instance, (uint8_t *) &throwaway_pkt, &throwaway_size);
	if (snetp->polling_mode == 0) {
	    send_intr_packet = 1;
	}
	return;
    }


    rx_buf->pkt_size = SNET_MTU;
    (void) (*snetp->eth_rx)(snetp, snetp->eth_instance, (uint8_t *) &rx_buf->buf, &rx_buf->pkt_size);
    if (rx_buf->pkt_size) {
	rx_tail++;
	if (rx_tail == SNET_RX_BUFS_COUNT) {
	    rx_tail = 0;
	}
	rx_count++;
	snetp->rx_tail  = rx_tail;
	snetp->rx_count = rx_count;
	if (snetp->rx_count > snetp->max_rx_count) {
	    snetp->max_rx_count = snetp->rx_count;
	    if (snetp->max_rx_count > (SNET_RX_BUFS_COUNT >> 1)) {
		if (snetp->verbose_flag >= SNET_VERBOSE_LOW) {
		    mbfw_printf("MBFW_INFO: snet_recv_handler: max_rx_count %d \r\n", snetp->max_rx_count);
		}
	    }
	}
	if (snetp->polling_mode == 0) {
	    send_intr_packet = 1;
	}
    }

    return;
}


void
mbfw_snet_load(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt, taddr_t t1_addr)
{
    struct rx_buf  *rx_buf;
    uint32_t       *pkt;

    rx_buf = snetp->rx_bufs[ snetp->rx_head ];
    pkt    = (uint32_t *) &rx_buf->buf[ snetp->sent_data_count >> 3 ];

    switch (snetp->send_state) {
    case SNET_IDLE:
	if (snetp->rx_count) {
	    snetp->send_msg_type      = SNET_CMD_RX;
	    snetp->send_msg_data_size = rx_buf->pkt_size;
	    snetp->sent_data_count    = 0;
	    cpx_pkt->data0 = snetp->send_msg_type;
	    cpx_pkt->data1 = snetp->send_msg_data_size;
	    cpx_pkt->data2 = cpx_pkt->data0;
	    cpx_pkt->data3 = cpx_pkt->data1;
	    snetp->send_state = SNET_SENDING;
	} else {
	    cpx_pkt->data3 = 0;
	    cpx_pkt->data2 = SNET_CMD_NONE;
	    cpx_pkt->data1 = cpx_pkt->data3;
	    cpx_pkt->data0 = cpx_pkt->data2;
	}
	break;
    case SNET_SENDING:
	switch (snetp->send_msg_type) {
	case SNET_CMD_RX:
	    cpx_pkt->data3 = pkt[0];
	    cpx_pkt->data2 = pkt[1];
	    cpx_pkt->data1 = cpx_pkt->data3;
	    cpx_pkt->data0 = cpx_pkt->data2;

	    snetp->sent_data_count += 8;
	    break;
	default:
	    mbfw_printf("MBFW_ERROR: mbfw_snet_load(): unknown send_msg_type 0x%x \r\n", snetp->send_msg_type);
	    break;
	}
	break;
    default:
	mbfw_printf("MBFW_ERROR: mbfw_snet_load(): unknown send_state 0x%x \r\n", snetp->send_state);
	break;
    }

    if (snetp->sent_data_count >= snetp->send_msg_data_size) {

        switch (snetp->send_msg_type) {
	case SNET_CMD_RX:
	    if (snetp->verbose_flag >= SNET_VERBOSE_HIGH) {
		mbfw_printf("MBFW_INFO: CMD_RX completed \r\n");
	    }

	    microblaze_disable_interrupts();
	    if (snetp->eth_rx_tohw) {
		(void) (*snetp->eth_rx_tohw)(snetp, snetp->eth_instance, (uint8_t *) &rx_buf->buf, SNET_MTU);
	    }
	    snetp->rx_head++;
	    if (snetp->rx_head == SNET_RX_BUFS_COUNT) {
		snetp->rx_head = 0;
	    }
	    snetp->rx_count--;
	    microblaze_enable_interrupts();

	    break;
	default:
	    break;
	}
	snetp->send_state         = SNET_IDLE;
	snetp->send_msg_type      = SNET_CMD_NONE;
	snetp->send_msg_data_size = 0;
	snetp->sent_data_count    = 0;
    }

    return_load_req(pcx_pkt, cpx_pkt, t1_addr, MB_INVALID_ADDR, 0);

    return;
}


#define TCP_PROTOCOL       6


static void
compute_ip_tcp_checksums(uchar_t *tx_pkt, uint_t tx_pkt_size)
{
    ushort_t *eth_pkt = (ushort_t *) tx_pkt;
    ushort_t *ip_pkt  = (ushort_t *) (tx_pkt + ETH_HDR_SIZE);
    ushort_t *tcp_pkt;
    int sum, ip_hdr_len, tcp_pkt_len;

    if ((eth_pkt[ETH_PKT_TYPE_LEN] == 0x0800) && ((eth_pkt[ETH_IP_PKT_PROTOCOL] & 0xFF) == TCP_PROTOCOL)) {

	ip_hdr_len  = ((eth_pkt[ETH_IP_PKT_IHL] >> 8) & 0xF) << 2;
	tcp_pkt_len = eth_pkt[ETH_IP_PKT_LEN] - ip_hdr_len;

	sum  = eth_pkt[ETH_IP_PKT_SRC];
	sum += eth_pkt[ETH_IP_PKT_SRC+1];

	sum += eth_pkt[ETH_IP_PKT_DST];
	sum += eth_pkt[ETH_IP_PKT_DST+1];

	sum += TCP_PROTOCOL;
	sum += tcp_pkt_len;

	tcp_pkt = (ushort_t *) (tx_pkt + (ETH_HDR_SIZE + ip_hdr_len));
	tcp_pkt[TCP_PKT_CHECKSUM] = 0;
	tcp_pkt[TCP_PKT_CHECKSUM] = snet_in_checksum(tcp_pkt, tcp_pkt_len, sum);
	
	ip_pkt[IP_PKT_CHECKSUM] = 0;
	ip_pkt[IP_PKT_CHECKSUM] = snet_in_checksum(ip_pkt, ip_hdr_len, 0);
    }
}


void
mbfw_snet_store(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt, taddr_t t1_addr)
{
    int  i;
    uint32_t *pkt = (uint32_t *) &snetp->tx_buf[snetp->received_data_count / sizeof(uint64_t)];


    switch (snetp->recv_state) {
    case SNET_IDLE:
	snetp->recv_msg_type       = pcx_pkt->data0;
	snetp->recv_msg_data_size  = pcx_pkt->data1;
	snetp->received_data_count = 0;
	snetp->recv_state = SNET_RECEIVING;
	break;
    case SNET_RECEIVING:
	switch (snetp->recv_msg_type) {
	case SNET_CMD_TX:
	    pkt[0] = pcx_pkt->data1;
	    pkt[1] = pcx_pkt->data0;
	    snetp->received_data_count += 8;
	    break;
	case SNET_CMD_MAC:
	    snetp->mac_addr[0] = pcx_pkt->data1 >> 24 & 0xff;
	    snetp->mac_addr[1] = pcx_pkt->data1 >> 16 & 0xff;
	    snetp->mac_addr[2] = pcx_pkt->data1 >>  8 & 0xff;
	    snetp->mac_addr[3] = pcx_pkt->data1 >>  0 & 0xff;
	    snetp->mac_addr[4] = pcx_pkt->data0 >> 24 & 0xff;
	    snetp->mac_addr[5] = pcx_pkt->data0 >> 16 & 0xff;
	    snetp->received_data_count += 6;
	    break;
	case SNET_CMD_POLLING:
	    snetp->polling_mode = pcx_pkt->data1;
	    snetp->received_data_count += 4;
	    break;
	case SNET_CMD_TX_TCP_CHECKSUM:
	    snetp->tx_tcp_checksum = pcx_pkt->data1;
	    snetp->received_data_count += 4;
	    break;
	default:
	    mbfw_printf("MBFW_ERROR: mbfw_snet_store(): received unknown msg type 0x%x \r\n", snetp->recv_msg_type);
	    break;
	}
	break;
    default:
	mbfw_printf("MBFW_ERROR: mbfw_snet_store(): unknown recv_state 0x%x \r\n", snetp->recv_state);
	break;
    }


    if (snetp->received_data_count >= snetp->recv_msg_data_size) {
       
	/* Received the entire message */

	switch (snetp->recv_msg_type) {
	case SNET_CMD_START:
	    if (snetp->verbose_flag >= SNET_VERBOSE_LOW) {
		mbfw_printf("MBFW_INFO: CMD_START received \r\n");
	    }
	    if (snetp->start == 0) {
		(void) (*snetp->eth_set_mac_addr)(snetp, snetp->eth_instance, snetp->mac_addr);
		(void) (*snetp->eth_start)(snetp, snetp->eth_instance);
	    }
	    microblaze_disable_interrupts();
	    snetp->rx_head = 0;
	    snetp->rx_tail = 0;
	    snetp->rx_count = 0;
	    snetp->rx_full_count = 0;
	    microblaze_enable_interrupts();
	    snetp->start = 1;
	    break;
	case SNET_CMD_STOP:
	    if (snetp->verbose_flag >= SNET_VERBOSE_LOW) {
		mbfw_printf("MBFW_INFO: CMD_STOP received \r\n");
	    }
	    if (snetp->start == 1) {
		(void) (*snetp->eth_stop)(snetp, snetp->eth_instance);
	    }
	    snetp->start = 0;
	    break;
	case SNET_CMD_TX:
	    if (snetp->verbose_flag >= SNET_VERBOSE_HIGH) {
		mbfw_printf("MBFW_INFO: CMD_TX received \r\n");
	    }
	    if (snetp->tx_tcp_checksum) {
		compute_ip_tcp_checksums((uchar_t *) snetp->tx_buf, snetp->recv_msg_data_size);
	    }
	    if (snetp->start) {
		snetp->transmit_complete = 0;
		if ((*snetp->eth_tx)(snetp, snetp->eth_instance, (uint8_t *) snetp->tx_buf, snetp->recv_msg_data_size) == 0) {
		    while (snetp->transmit_complete == 0);
		}
	    }
	    break;
	case SNET_CMD_MAC:
	    if (snetp->verbose_flag >= SNET_VERBOSE_LOW) {
		mbfw_printf("MBFW_INFO: CMD_MAC received \r\n");
		mbfw_printf("MBFW_INFO: eth_store(): MAC_ADDR ");
		for (i=0; i<6; i++) {
		    mbfw_printf("%x : ", snetp->mac_addr[i]);
		}
		mbfw_printf("\r\n");
	    }
	    break;
	case SNET_CMD_POLLING:
	    if (snetp->verbose_flag >= SNET_VERBOSE_LOW) {
		mbfw_printf("MBFW_INFO: CMD_POLLING: 0x%x \r\n", snetp->polling_mode);
	    }
	    break;
	case SNET_CMD_TX_TCP_CHECKSUM:
	    if (snetp->verbose_flag >= SNET_VERBOSE_LOW) {
		mbfw_printf("MBFW_INFO: CMD_TX_TCP_CHECKSUM: 0x%x \r\n", snetp->tx_tcp_checksum);
	    }
	    break;
	default:
	    if (snetp->verbose_flag >= SNET_VERBOSE_LOW) {
		mbfw_printf("MBFW_INFO: recv_msg_type 0x%x called \r\n", snetp->recv_msg_type);
	    }
	    break;
	}
	snetp->recv_state          = SNET_IDLE;
	snetp->recv_msg_type       = SNET_CMD_NONE;
	snetp->recv_msg_data_size  = 0;
	snetp->received_data_count = 0;
    }

    return_store_ack(pcx_pkt, cpx_pkt, t1_addr, 0, INVALIDATE_NONE);

    return;
}


int
mbfw_snet_init(XIntc *intc_instance)
{
    int i;

    struct eth_init_data init_data;

    snetp->polling_mode    = 0;   /* send an interrupt to the device driver */
    snetp->tx_tcp_checksum = 1;   /* compute ip & tcp checksums */
    snetp->verbose_flag    = SNET_VERBOSE_NONE;


    for (i = 0; i < SNET_RX_BUFS_COUNT; i++) {
	snetp->rx_bufs[i] = &snetp->rx_bufs_memory[i];
    }


    init_data.tx_handler    = snet_send_handler;
    init_data.rx_handler    = snet_recv_handler;
    init_data.error_handler = snet_error_handler;

    if (eth_init(snetp, intc_instance, &init_data) < 0) {
	mbfw_printf("MBFW_ERROR: Ethernet controller initialization failed. \r\n");
	return -1;
    }

    if (snetp->eth_rx_tohw) {
	microblaze_disable_interrupts();
	for (i = 0; i < SNET_RX_BUFS_COUNT; i++) {
	    (void) (*snetp->eth_rx_tohw)(snetp, snetp->eth_instance, (uint8_t *) (snetp->rx_bufs[i]->buf), SNET_MTU);
	}
	microblaze_enable_interrupts();
    }

    mbfw_printf("MBFW_INFO: Ethernet controller initialization completed. \r\n");

    return 0;
}


void
mbfw_snet_register(struct snet *snetp, void *eth_instance, struct mac_callbacks *mcp)
{
    snetp->eth_instance      = eth_instance;

    snetp->eth_start         = mcp->eth_start;
    snetp->eth_stop          = mcp->eth_stop;
    snetp->eth_set_mac_addr  = mcp->eth_set_mac_addr;
    snetp->eth_tx            = mcp->eth_tx;
    snetp->eth_rx            = mcp->eth_rx;
    snetp->eth_rx_tohw       = mcp->eth_rx_tohw;
}
