/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_pcx_cpx.c
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

#include <mb_interface.h>

#include "mbfw_types.h"
#include "mbfw_debug.h"
#include "mbfw_pcx_cpx.h"



#define  FSL_ID  0
#define  AURORA_FSL_ID  1



#define  APPROX_ONE_SEC_COUNT    1200000
#define  FSL_PCX_RECV_TIMEOUT    (60 * APPROX_ONE_SEC_COUNT)


static void
recv_pcx_pkt_data_word(uint_t *buffer)
{
    int fsl_invalid;
    int fsl_error;
    int count = 0;

    do {
#if (MBFW_DEBUG > 0)
	if (count >= FSL_PCX_RECV_TIMEOUT) {
	    mbfw_printf("MBFW_WARN: timed out waiting for pcx_pkt data word "
									"\r\n");
	    count = 0;
	}
	count++;
#endif

        ngetfsl(*(buffer), FSL_ID);
        fsl_isinvalid(fsl_invalid);
        fsl_iserror(fsl_error);
    } while (fsl_invalid || fsl_error);

    return;
}


static int
recv_pcx_pkt_ctrl_word(uint_t *buffer, int timeout_count)
{
    int fsl_invalid;
    int fsl_error;
    int count = 0;

    do {

#if (MBFW_DEBUG > 0)
	if (count >= FSL_PCX_RECV_TIMEOUT) {
	    mbfw_printf("MBFW_WARN: timed out waiting for pcx_pkt ctrl word \r\n");
	    count = 0;
	}
	count++;
#endif

	if (timeout_count > 0) {
	    timeout_count--;
	}
        ncgetfsl(*(buffer), FSL_ID);
        fsl_isinvalid(fsl_invalid);
        fsl_iserror(fsl_error);
    } while ((fsl_invalid || fsl_error) && (timeout_count != 0));

    if (fsl_invalid || fsl_error) {
	return -1;
    }

    return 0;
}



int
recv_pcx_pkt(struct pcx_pkt *pcx_pkt, int timeout_count)
{

    if (recv_pcx_pkt_ctrl_word(&pcx_pkt->addr_hi_ctrl, timeout_count) < 0) {
        return -1;
    }

    recv_pcx_pkt_data_word(&pcx_pkt->addr_lo);
    recv_pcx_pkt_data_word(&pcx_pkt->data1);
    recv_pcx_pkt_data_word(&pcx_pkt->data0);


#if MBFW_DEBUG > 1
    mbfw_debug_pcx_pkt(pcx_pkt);
#endif

    return;
}



void
send_cpx_pkt_to_fsl(int core_id, struct cpx_pkt *cpx_pkt)
{
    int invalid;
    int send_error = 0;


#if MBFW_DEBUG > 1
    mbfw_debug_cpx_pkt(cpx_pkt);
#endif


    ncputfsl(cpx_pkt->ctrl, FSL_ID);
    fsl_isinvalid(invalid);
    send_error |= invalid;

    nputfsl(cpx_pkt->data3, FSL_ID);
    fsl_isinvalid(invalid);
    send_error |= invalid;

    nputfsl(cpx_pkt->data2, FSL_ID);
    fsl_isinvalid(invalid);
    send_error |= invalid;

    nputfsl(cpx_pkt->data1, FSL_ID);
    fsl_isinvalid(invalid);
    send_error |= invalid;

    nputfsl(cpx_pkt->data0, FSL_ID);
    fsl_isinvalid(invalid);
    send_error |= invalid;

    if (send_error) {
	mbfw_printf("MBFW_ERROR: Encountered FSL FIFO full condition while "
						    "sending cpx packet \r\n");
	print_cpx_pkt(cpx_pkt);
	mbfw_exit(1);
    }

    return;
}

void
cpx_pkt_init(struct cpx_pkt *cpx_pkt)
{
    cpx_pkt->ctrl  = 0x0;
    cpx_pkt->data3 = 0x0;
    cpx_pkt->data2 = 0x0;
    cpx_pkt->data1 = 0x0;
    cpx_pkt->data0 = 0x0;

    CPX_PKT_SET_VALID(cpx_pkt, 1);
}

void
print_cpx_pkt(struct cpx_pkt *pkt)
{
    mbfw_printf("\r\n");
    mbfw_printf("MBFW_INFO: cpx_pkt: ctrl  0x%08x \r\n", pkt->ctrl);
    mbfw_printf("MBFW_INFO: cpx_pkt: data3 0x%08x \r\n", pkt->data3);
    mbfw_printf("MBFW_INFO: cpx_pkt: data2 0x%08x \r\n", pkt->data2);
    mbfw_printf("MBFW_INFO: cpx_pkt: data1 0x%08x \r\n", pkt->data1);
    mbfw_printf("MBFW_INFO: cpx_pkt: data0 0x%08x \r\n", pkt->data0);
    mbfw_printf("\r\n");
}


void
print_pcx_pkt(struct pcx_pkt *pcx_pkt)
{
    mbfw_printf("\r\n");
    mbfw_printf("MBFW_INFO: pcx_pkt: addr_hi_ctrl  0x%08x \r\n", pcx_pkt->addr_hi_ctrl);
    mbfw_printf("MBFW_INFO: pcx_pkt: addr_lo       0x%08x \r\n", pcx_pkt->addr_lo);
    mbfw_printf("MBFW_INFO: pcx_pkt: data1         0x%08x \r\n", pcx_pkt->data1);
    mbfw_printf("MBFW_INFO: pcx_pkt: data0         0x%08x \r\n", pcx_pkt->data0);
    mbfw_printf("\r\n");
}


/*
 * Aurora link doesn't have flow control. If the receiver doesn't drain the fifo 
 * fast enough, packets could be overwritten by the sender. Therefore software
 * handshake has been implemented.
 */

void
send_aurora_half_word(uint_t value)
{
    int fsl_invalid;
    int fsl_error;
    uint_t loop_count = 0;

    value = value << 16;

    do {
	nputfsl(value, AURORA_FSL_ID);
	fsl_isinvalid(fsl_invalid);
        fsl_iserror(fsl_error);
    } while (fsl_invalid || fsl_error);

    return;
}

uint_t
recv_aurora_half_word(void)
{
    int fsl_invalid;
    int fsl_error;
    uint_t loop_count = 0;

    uint_t value;

    do {
	ngetfsl(value, AURORA_FSL_ID);
	fsl_isinvalid(fsl_invalid);
        fsl_iserror(fsl_error);
    } while (fsl_invalid || fsl_error);

    value = value >> 16;

    return value;
}


int
recv_aurora_half_word_timeout(uint_t *value_ptr, int timeout_count)
{
    int fsl_invalid;
    int fsl_error;
    uint_t loop_count = 0;

    uint_t value;

    do {
	ngetfsl(value, AURORA_FSL_ID);
	fsl_isinvalid(fsl_invalid);
        fsl_iserror(fsl_error);
	if (timeout_count > 0) {
	    timeout_count--;
	}
    } while ((fsl_invalid || fsl_error) && (timeout_count != 0));

    if (fsl_invalid || fsl_error) {
	return -1;
    }

    value = value >> 16;

    *value_ptr = value;

    return 0;
}


void
send_aurora_ack(void)
{
    send_aurora_half_word(AURORA_HDR_SIZE);

    return;
}

int
recv_aurora_pkt(void *pkt, int pkt_size, int timeout_count)
{
    unsigned short *sptr = (unsigned short *) pkt;
    uint32_t value;

    int i;
    uint_t len = 0;
    uint_t pkt_count;
    uint_t checksum;

    if (recv_aurora_half_word_timeout(&len, timeout_count) < 0) {
	return -1;
    }


    if (len == AURORA_HDR_SIZE) {
	return AURORA_HDR_SIZE;
    }

#if (MBFW_DEBUG > 0)
    if (pkt_size == 0) {
	mbfw_printf("MBFW_ERROR: recv_aurora_pkt: pkt_size == 0 \r\n");
	mbfw_exit(1);
    }

    if (len != (pkt_size + AURORA_HDR_SIZE)) {
	mbfw_printf("MBFW_ERROR: recv_aurora_pkt: len %d != pkt_size %d + %d \r\n", len, pkt_size, AURORA_HDR_SIZE);
	mbfw_exit(1);
    }
#endif

    i = 0;
    while (i < pkt_size) {
	value = recv_aurora_half_word();
	*sptr = value;
	sptr++;
	i += 2;
    }

    send_aurora_ack();

    return pkt_size;
}


#define MAX_PCX_PKTS 32

static int rx_head;
static int rx_tail;
static int rx_count;
static struct pcx_pkt pcx_pkts[MAX_PCX_PKTS];

static int bufferred_pcx_pkt_count;

int
recv_aurora_pcx_pkt(struct pcx_pkt *pcx_pkt, int timeout_count)
{
    int len;

    if (rx_count) {
        *pcx_pkt = pcx_pkts[rx_head];
	rx_head++;
	if (rx_head == MAX_PCX_PKTS) {
	    rx_head = 0;
	}
	rx_count--;
#if MBFW_DEBUG > 1
	if (len == sizeof(struct pcx_pkt)) {
	    mbfw_debug_pcx_pkt(pcx_pkt);
	}
#endif
	return sizeof(struct pcx_pkt);
    }
    do {
        len = recv_aurora_pkt(pcx_pkt, sizeof(struct pcx_pkt), timeout_count);
    } while (len == AURORA_HDR_SIZE);

#if MBFW_DEBUG > 1
    if (len == sizeof(struct pcx_pkt)) {
	mbfw_debug_pcx_pkt(pcx_pkt);
    }
#endif


    return len;
}

static int insert_pcx_pkt_count;

int
insert_pcx_pkt(struct pcx_pkt *pcx_pkt)
{
    if ((rx_head == rx_tail) && (rx_count > 0)) {
    	mbfw_printf("MBFW_ERROR: insert_pcx_pkt: full \r\n");
	mbfw_exit(1);
	return -1;
    }
    pcx_pkts[rx_tail] = *pcx_pkt;
    rx_tail++;
    if (rx_tail == MAX_PCX_PKTS) {
        rx_tail = 0;
    }
    rx_count++;
    return 0;
}

int
recv_aurora_ack(void)
{
    struct pcx_pkt pcx_pkt;
    int len;

    do {
	len = recv_aurora_pkt(&pcx_pkt, sizeof(struct pcx_pkt), -1);
	if (len == sizeof(struct pcx_pkt)) {
	    insert_pcx_pkt(&pcx_pkt);
	}
    } while (len != AURORA_HDR_SIZE);
}

void
send_aurora_header(void *pkt, int pkt_size)
{
    uint_t checksum;

    send_aurora_half_word(pkt_size + AURORA_HDR_SIZE);

    return;
}

void
send_aurora_pkt(void *pkt, int pkt_size)
{
    unsigned short *sptr = (unsigned short *) pkt;
    int i;
    uint32_t value;

    send_aurora_header(pkt, pkt_size);

    i = 0;
    while (i<pkt_size) {
	value = *sptr;
	send_aurora_half_word(value);
	sptr++;
	i += 2;
    }

    return;
}

void
send_cpx_pkt(int core_id, struct cpx_pkt *cpx_pkt)
{
    if (core_id == 0) {
        send_cpx_pkt_to_fsl(core_id, cpx_pkt);
    } else {

#if MBFW_DEBUG > 1
    mbfw_debug_cpx_pkt(cpx_pkt);
#endif
	send_aurora_pkt(cpx_pkt, sizeof(struct cpx_pkt));
	recv_aurora_ack();
    }
}
