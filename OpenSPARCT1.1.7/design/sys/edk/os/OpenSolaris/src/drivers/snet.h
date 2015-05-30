/*
 * CDDL HEADER START
 *
 * The contents of this file are subject to the terms of the
 * Common Development and Distribution License (the "License").
 * You may not use this file except in compliance with the License.
 *
 * You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
 * or http://www.opensolaris.org/os/licensing.
 * See the License for the specific language governing permissions
 * and limitations under the License.
 *
 * When distributing Covered Code, include this CDDL HEADER in each
 * file and include the License file at usr/src/OPENSOLARIS.LICENSE.
 * If applicable, add the following below this CDDL HEADER, with the
 * fields enclosed by brackets "[]" replaced with your own identifying
 * information: Portions Copyright [yyyy] [name of copyright owner]
 *
 * CDDL HEADER END
 */
/*
 * Copyright 2007 Sun Microsystems, Inc.  All rights reserved.
 * Use is subject to license terms.
 */

#ifndef	_SYS_SNET_H
#define	_SYS_SNET_H

#pragma ident	"@(#)snet.h	1.19	07/06/06 SMI"

#ifdef	__cplusplus
extern "C" {
#endif


#ifdef _KERNEL

/* Named Dispatch Parameter Management Structure */
typedef struct param_s {
	uint32_t param_min;
	uint32_t param_max;
	uint32_t param_val;
	char   *param_name;
} param_t;

#define	SNET_PARAM_CNT	51


/*
 * kstats
 */
typedef struct stats {
	/*
	 * Link Input/Output stats
	 * ifspeed is now in bits/second.
	 */
	uint64_t	ipackets64;
	uint64_t	iipackets64;
	uint32_t	ierrors;
	uint64_t	opackets64;
	uint64_t	oerrors;
	uint32_t	collisions;
	uint64_t	ifspeed;

	/*
	 * MAC TX Event stats
	 */
	uint32_t	txmac_urun;
	uint32_t	txmac_maxpkt_err;
	uint32_t	excessive_coll;
	uint32_t	late_coll;
	uint32_t	first_coll;
	uint32_t	defer_timer_exp;
	uint32_t	peak_attempt_cnt;
	uint32_t	tx_hang;

	/*
	 * MAC RX Event stats
	 */
	uint32_t	rx_corr;
	uint32_t	no_free_rx_desc;	/* no free rx desc. */
	uint32_t	rx_overflow;
	uint32_t	rx_ovrflpkts;
	uint32_t	rx_hang;
	uint32_t	rx_align_err;
	uint32_t	rx_crc_err;
	uint32_t	rx_length_err;
	uint32_t	rx_code_viol_err;

	/*
	 * MAC Control event stats
	 */
	uint32_t	pause_rxcount;	/* PAUSE Receive cnt */
	uint32_t	pause_oncount;
	uint32_t	pause_offcount;
	uint32_t	pause_time_count;
	uint32_t	pausing;

	/*
	 * Software event stats
	 */
	uint32_t	inits;
	uint32_t	rx_inits;
	uint32_t	tx_inits;
	uint32_t	tnocar;	/* Link down counter */

	uint32_t	jab;
	uint32_t	notmds;
	uint32_t	nocanput;
	uint32_t	allocbfail;
	uint32_t	drop;
	uint32_t	rx_corrupted;
	uint32_t	rx_bad_pkts;
	uint32_t	rx_runt;
	uint32_t	rx_toolong_pkts;


	/*
	 * Fatal errors
	 */
	uint32_t	rxtag_err;

	/*
	 * parity error
	 */
	uint32_t	parity_error;

	/*
	 * Fatal error stats
	 */
	uint32_t	pci_error_int;	/* PCI error interrupt */
	uint32_t	unknown_fatal;	/* unknown fatal errors */

	/*
	 * PCI Configuration space staus register
	 */
	uint32_t	pci_data_parity_err;	/* Data parity err */
	uint32_t	pci_signal_target_abort;
	uint32_t	pci_rcvd_target_abort;
	uint32_t	pci_rcvd_master_abort;
	uint32_t	pci_signal_system_err;
	uint32_t	pci_det_parity_err;

	/*
	 * MIB II variables
	 */
	uint64_t	rbytes64;	/* # bytes received */
	uint64_t	obytes64;	/* # bytes transmitted */
	uint32_t	multircv;	/* # multicast packets received */
	uint32_t	multixmt;	/* # multicast packets for xmit */
	uint32_t	brdcstrcv;	/* # broadcast packets received */
	uint32_t	brdcstxmt;	/* # broadcast packets for xmit */
	uint32_t	norcvbuf;	/* # rcv packets discarded */
	uint32_t	noxmtbuf;	/* # xmit packets discarded */

	uint32_t	pmcap;		/* power management */

	/*
	 * Link Status
	 */
	uint32_t	link_up;
	uint32_t	link_duplex;
} stats_t;

#define	HSTAT(snetp, x)		snetp->stats.x++;
#define	HSTATN(snetp, x, n)	snetp->stats.x += n;


/*
 * Per-Stream instance state information.
 *
 * Each instance is dynamically allocated at open() and free'd
 * at close().  Each per-Stream instance points to at most one
 * per-device structure using the sb_erip field.  All instances
 * are threaded together into one list of active instances
 * ordered on minor device number.
 */

#define	NMCFILTER_BITS	256		/* # of multicast filter bits */


#define	MSECOND(t)	t
#define	SECOND(t)	t*1000
#define	SNET_TICKS	MSECOND(100)


/*
 * undefine SNET_PM_WORKAROUND this time. With SNET_PM_WORKAROUND defined,
 * each non_fatal error causes pci clock to go up for 30 seconds. Therefore,
 * no TXMAC_UNDERRUN or excessive RXFIFO_OVERFLOW should happen.
 */


/*
 * Transceivers selected for use by the driver.
 */
#define	NO_XCVR		2
#define	INTERNAL_XCVR	0
#define	EXTERNAL_XCVR	1

/*
 * SNET Device Channel instance state information.
 *
 * Each instance is dynamically allocated on first attach.
 */
struct	snet {

	/*
         * send_buffer and recv_buffer must be double word aligned. 
	 * This constraint is imposed because of performance optimizations
	 * in hv_snet_read and hv_snet_write functions in the hypervisor.
	 *
	 * SNET_HDR is stored at the beginning of these buffers.
	 * 
	 * Because of the performance optimizations in hv_snet_read and hv_snet_write
	 * implementation in the hypervisor, data is accessed in double words 
	 * even if the packet count is not a multiple of double word.
	 * 
	 */

	uint64_t                send_buffer[ETHERMTU/sizeof(uint64_t) + 1 + 15];
	uint64_t                recv_buffer[ETHERMTU/sizeof(uint64_t) + 1 + 15];
	uint64_t		send_buffer_pa;
	uint64_t		recv_buffer_pa;

	mac_handle_t		mh;		/* GLDv3 handle */
	dev_info_t		*dip;		/* associated dev_info */
	uint_t			instance;	/* instance */

	uint_t			multi_refcnt;
	boolean_t		promisc;

	uint8_t			ouraddr[ETHERADDRL];	/* unicast address */
	uint32_t		flags;		/* misc. flags */

	uint16_t		ladrf[NMCFILTER_BITS/16]; /* Multicast filter */
	uint16_t		ladrf_refcnt[NMCFILTER_BITS];


	int			global_reset_issued;
	int			init_macregs;

	int			phyad;	/* addr of the PHY in use */
	int			xcvr;  /* current PHY in use */

	caddr_t			g_nd;	/* head of the */
						/* named dispatch table */

	ddi_device_acc_attr_t	dev_attr;
	ddi_iblock_cookie_t	cookie;	/* interrupt cookie */

	kstat_t			*ksp;		/* kstat pointer */

	kmutex_t		xmitlock;	/* protect xmit-side fields */
	kmutex_t		xcvrlock;	/* */
	kmutex_t		intrlock;	/* protect intr-side fields */

	param_t		param_arr[SNET_PARAM_CNT];

	struct	stats stats;	/* kstats */

	uint32_t	starts;
};

/*
 * LADRF bit array manipulation macros.  These are for working within the
 * array of words defined by snetp->ladrf, converting a bit (0-255) into
 * the index and offset in the ladrf bit array.  Note that the array is
 * provided in "Big Endian" order.
 */
#define	LADRF_MASK(bit)		(1 << ((bit) % 16))
#define	LADRF_WORD(snetp, bit)	snetp->ladrf[(15 - ((bit) / 16))]
#define	LADRF_SET(snetp, bit)	(LADRF_WORD(snetp, bit) |= LADRF_MASK(bit))
#define	LADRF_CLR(snetp, bit)	(LADRF_WORD(snetp, bit) &= ~LADRF_MASK(bit))

/*
 * SNET IOCTLS.
 * Change : TODO : MBE
 */
#define	SNETIOC		('G' << 8)
#define	SNET_SET_LOOP_MODE	(SNETIOC|1)	/* Set Rio Loopback mode */
#define	SNET_GET_LOOP_MODE	(SNETIOC|2)	/* Get Rio Loopback modes */
#define	SNET_GET_LOOP_IFCNT	(SNETIOC|4)	/* Get Rio IF Count */

/*
 * Loopback modes: For diagnostic testing purposes the SNET card
 * can be placed in loopback mode.
 * There are three modes of loopback provided by the driver,
 * Mac loopback, PCS loopback and Serdes loopback.
 */
#define	SNET_LOOPBACK_OFF		0
#define	SNET_MAC_LOOPBACK_ON		1
#define	SNET_PCS_LOOPBACK_ON 		2
#define	SNET_SER_LOOPBACK_ON 		4
typedef struct {
	int loopback;
} loopback_t;


/*
 * flags
 * TODO : MBE
 */
#define	SNET_UNKOWN	0x00	/* unknown state	*/
#define	SNET_RUNNING	0x01	/* chip is initialized	*/
#define	SNET_STARTED	0x02	/* mac layer started */
#define	SNET_SUSPENDED	0x08	/* suspended interface	*/
#define	SNET_INITIALIZED	0x10	/* interface initialized */
#define	SNET_NOTIMEOUTS	0x20	/* disallow timeout rescheduling */
#define	SNET_TXINIT	0x40	/* TX Portion Init'ed	*/
#define	SNET_RXINIT	0x80	/* RX Portion Init'ed	*/
#define	SNET_MACLOOPBACK	0x100	/* device has MAC int lpbk (DIAG) */
#define	SNET_SERLOOPBACK	0x200	/* device has SERDES int lpbk (DIAG) */
#define	SNET_DLPI_LINKUP	0x400	/* */

/*
 * Mac address flags
 */
#define	SNET_FACTADDR_PRESENT	0x01	/* factory MAC id present */
#define	SNET_FACTADDR_USE	0x02	/* use factory MAC id */

struct snetkstat {
	/*
	 * Software event stats
	 */
	struct kstat_named	snetk_inits;
	struct kstat_named	snetk_rx_inits;
	struct kstat_named	snetk_tx_inits;

	struct kstat_named	snetk_allocbfail;
	struct kstat_named	snetk_drop;

	/*
	 * MAC Control event stats
	 */
	struct kstat_named	snetk_pause_rxcount; /* PAUSE Receive count */
	struct kstat_named	snetk_pause_oncount;
	struct kstat_named	snetk_pause_offcount;
	struct kstat_named	snetk_pause_time_count;

	/*
	 * MAC TX Event stats
	 */
	struct kstat_named	snetk_txmac_maxpkt_err;
	struct kstat_named	snetk_defer_timer_exp;
	struct kstat_named	snetk_peak_attempt_cnt;
	struct kstat_named	snetk_jab;
	struct kstat_named	snetk_notmds;
	struct kstat_named	snetk_tx_hang;

	/*
	 * MAC RX Event stats
	 */
	struct kstat_named	snetk_no_free_rx_desc; /* no free rx desc. */
	struct kstat_named	snetk_rx_hang;
	struct kstat_named	snetk_rx_length_err;
	struct kstat_named	snetk_rx_code_viol_err;
	struct kstat_named	snetk_rx_bad_pkts;

	/*
	 * Fatal errors
	 */
	struct kstat_named	snetk_rxtag_err;

	/*
	 * Parity error
	 */
	struct kstat_named	snetk_parity_error;

	/*
	 * PCI fatal error stats
	 */
	struct kstat_named	snetk_pci_error_int;  /* PCI error interrupt */
	struct kstat_named	snetk_unknown_fatal;	/* unknow fatal error */

	/*
	 * PCI Configuration space staus register
	 */
	struct kstat_named	snetk_pci_data_parity_err; /* dparity err */
	struct kstat_named	snetk_pci_signal_target_abort;
	struct kstat_named	snetk_pci_rcvd_target_abort;
	struct kstat_named	snetk_pci_rcvd_master_abort;
	struct kstat_named	snetk_pci_signal_system_err;
	struct kstat_named	snetk_pci_det_parity_err;


	struct kstat_named	snetk_pmcap;	/* Power management */
};

#define	ROUNDUP(a, n)	(((a) + ((n) - 1)) & ~((n) - 1))
#define	ROUNDUP2(a, n)	(uchar_t *)((((uintptr_t)(a)) + ((n) - 1)) & ~((n) - 1))

/*
 * Xmit/receive buffer structure.
 * This structure is organized to meet the following requirements:
 * - hb_buf starts on an SNET_BURSTSIZE boundary.
 * - eribuf is an even multiple of SNET_BURSTSIZE
 * - hb_buf[] is large enough to contain max frame (1518) plus
 *   (3 x SNET_BURSTSIZE) rounded up to the next SNET_BURSTSIZE
 */
/*
 * #define		SNET_BURSTSIZE	(64)
 */
#define		SNET_BURSTSIZE	(128)
#define		SNET_BURSTMASK	(SNETBURSTSIZE - 1)
#define		SNET_BUFSIZE	(1728)	/* (ETHERMTU + 228) */
#define		SNET_HEADROOM	(34)

/* Offset for the first byte in the receive buffer */
#define	SNET_FSTBYTE_OFFSET	2
#define	SNET_CKSUM_OFFSET	14


#define	SNET_PMCAP_NONE	0
#define	SNET_PMCAP_4MHZ	4

#endif	/* _KERNEL */

#ifdef	__cplusplus
}
#endif

#endif	/* _SYS_SNET_H */
