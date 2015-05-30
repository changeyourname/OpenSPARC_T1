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

#ifndef	_SYS_SNET_COMMON_H
#define	_SYS_SNET_COMMON_H

#pragma ident	"@(#)snet_common.h	1.8	07/06/06 SMI"

#ifdef	__cplusplus
extern "C" {
#endif

#ifdef _KERNEL

typedef enum {
	SNET_NO_MSG		= 0,
	SNET_CON_MSG  		= 1,
	SNET_BUF_MSG		= 2,
	SNET_VERB_MSG		= 3,
	SNET_LOG_MSG		= 4
} msg_t;


#ifdef	DEBUG
static msg_t snet_msg_out = SNET_VERB_MSG | SNET_CON_MSG;
#endif

#ifdef	LATER
static char	*fault_msg_string[] = {
	"NONE       ",
	"LOW        ",
	"MID        ",
	"HIGH       ",
	"UNKNOWN    "

};
#endif

#define	SEVERITY_UNKNOWN 0
#define	SEVERITY_NONE   0
#define	SEVERITY_LOW    0
#define	SEVERITY_MID    1
#define	SEVERITY_HIGH   2


#define	SNET_FAULT_MSG1(p, t, f, a) \
    snet_fault_msg((p), (t), (f), (a));

#define	SNET_FAULT_MSG2(p, t, f, a, b) \
    snet_fault_msg((p), (t), (f), (a), (b));

#define	SNET_FAULT_MSG3(p, t, f, a, b, c) \
    snet_fault_msg((p), (t), (f), (a), (b), (c));

#define	SNET_FAULT_MSG4(p, t, f, a, b, c, d) \
    snet_fault_msg((p), (t), (f), (a), (b), (c), (d));

#ifdef  DEBUG
typedef enum {
	NO_MSG		= 0,
	AUTOCONFIG_MSG  = 1,
	STREAMS_MSG	= 2,
	IOCTL_MSG	= 3,
	PROTO_MSG	= 4,
	INIT_MSG	= 5,
	TX_MSG		= 6,
	RX_MSG		= 7,
	INTR_MSG	= 8,
	UNINIT_MSG	= 9,
	CONFIG_MSG	= 10,
	PROP_MSG	= 11,
	ENTER_MSG	= 12,
	RESUME_MSG	= 13,
	AUTONEG_MSG	= 14,
	NAUTONEG_MSG	= 15,
	FATAL_ERR_MSG   = 16,
	NONFATAL_MSG  = 17,
	NDD_MSG		= 18,
	PHY_MSG		= 19,
	XCVR_MSG	= 20,
	NSUPPORT_MSG	= 21,
	ERX_MSG		= 22,
	FREE_MSG	= 23,
	IPG_MSG		= 24,
	DDI_MSG		= 25,
	DEFAULT_MSG	= 26,
	DISPLAY_MSG	= 27,
	DIAG_MSG	= 28,
	END_TRACE1_MSG	= 29,
	END_TRACE2_MSG	= 30,
	ASSERT_MSG	= 31,
	FRM_MSG		= 32,
	MIF_MSG		= 33,
	LINK_MSG	= 34,
	RESOURCE_MSG	= 35,
	LOOPBACK_MSG	= 36,
	VERBOSE_MSG	= 37,
	MODCTL_MSG	= 38,
	HWCSUM_MSG	= 39,
	CORRUPTION_MSG	= 40,
	EXIT_MSG	= 41,
	DLCAPAB_MSG	= 42

} debug_msg_t;

static debug_msg_t	snet_debug_level = NO_MSG | DEFAULT_MSG;
static debug_msg_t	snet_debug_all = NO_MSG;

static char	*debug_msg_string[] = {
	"NONE       ",
	"AUTOCONFIG ",
	"STREAMS    ",
	"IOCTL      ",
	"PROTO      ",
	"INIT       ",
	"TX         ",
	"RX         ",
	"INTR       ",
	"UNINIT         ",
	"CONFIG ",
	"PROP   ",
	"ENTER  ",
	"RESUME ",
	"AUTONEG        ",
	"NAUTONEG       ",
	"FATAL_ERR      ",
	"NFATAL_ERR     ",
	"NDD    ",
	"PHY    ",
	"XCVR   ",
	"NSUPPOR        ",
	"ERX    ",
	"FREE   ",
	"IPG    ",
	"DDI    ",
	"DEFAULT        ",
	"DISPLAY        ",
	"DIAG	",
	"TRACE1 ",
	"TRACE2 ",
	"ASSERT",
	"FRM	",
	"MIF	",
	"LINK	",
	"RESOURCE",
	"LOOPBACK",
	"VERBOSE",
	"MODCTL",
	"HWCSUM",
	"CORRUPTION",
	"EXIT",
	"DLCAPAB"
};

static void	snet_debug_msg(const char *, int, struct snet *, debug_msg_t,
    const char *, ...);

#define	SNET_DEBUG_MSG1(t, f, a) \
    snet_debug_msg(__FILE__, __LINE__, (t), (f), (a));

#define	SNET_DEBUG_MSG2(t, f, a, b) \
    snet_debug_msg(__FILE__, __LINE__, (t), (f), (a), (b));

#define	SNET_DEBUG_MSG3(t, f, a, b, c) \
    snet_debug_msg(__FILE__, __LINE__, (t), (f), (a), (b), (c));

#define	SNET_DEBUG_MSG4(t, f, a, b, c, d) \
    snet_debug_msg(__FILE__, __LINE__, (t), (f), (a), (b), (c), (d));

#define	SNET_DEBUG_MSG5(t, f, a, b, c, d, e) \
    snet_debug_msg(__FILE__, __LINE__, (t), (f), (a), (b), (c), (d), (e));

#else

#define	SNET_DEBUG_MSG1(t, f, a)
#define	SNET_DEBUG_MSG2(t, f, a, b)
#define	SNET_DEBUG_MSG3(t, f, a, b, c)
#define	SNET_DEBUG_MSG4(t, f, a, b, c, d)
#define	SNET_DEBUG_MSG5(t, f, a, b, c, d, e)
#define	SNET_DEBUG_MSG6(t, f, a, b, c, d, e, g, h)
#endif

/*
 * The following parameters may be configured by the user. If they are not
 * configured by the user, the values will be based on the capabilities of
 * the transceiver.
 * The value "SNET_NOTUSR" is ORed with the parameter value to indicate values
 * which are NOT configured by the user.
 */

/* command */

#define	ND_BASE		('N' << 8)	/* base */
#define	ND_GET		(ND_BASE + 0)	/* Get a value */
#define	ND_SET		(ND_BASE + 1)	/* Set a value */

#define	SNET_ND_GET	ND_GET
#define	SNET_ND_SET	ND_SET
#define	SNET_NOTUSR	0x0f000000
#define	SNET_MASK_1BIT	0x1
#define	SNET_MASK_2BIT	0x3
#define	SNET_MASK_8BIT	0xff

#define	param_transceiver	(snetp->param_arr[0].param_val)
#define	param_linkup		(snetp->param_arr[1].param_val)
#define	param_speed		(snetp->param_arr[2].param_val)
#define	param_mode		(snetp->param_arr[3].param_val)
#define	param_ipg1		(snetp->param_arr[4].param_val)
#define	param_ipg2		(snetp->param_arr[5].param_val)
#define	param_use_intphy	(snetp->param_arr[6].param_val)
#define	param_pace_count	(snetp->param_arr[7].param_val)
#define	param_autoneg		(snetp->param_arr[8].param_val)
#define	param_anar_100T4	(snetp->param_arr[9].param_val)

#define	param_anar_100fdx	(snetp->param_arr[10].param_val)
#define	param_anar_100hdx	(snetp->param_arr[11].param_val)
#define	param_anar_10fdx	(snetp->param_arr[12].param_val)
#define	param_anar_10hdx	(snetp->param_arr[13].param_val)
#define	param_bmsr_ancap	(snetp->param_arr[14].param_val)
#define	param_bmsr_100T4	(snetp->param_arr[15].param_val)
#define	param_bmsr_100fdx	(snetp->param_arr[16].param_val)
#define	param_bmsr_100hdx	(snetp->param_arr[17].param_val)
#define	param_bmsr_10fdx	(snetp->param_arr[18].param_val)
#define	param_bmsr_10hdx	(snetp->param_arr[19].param_val)

#define	param_aner_lpancap	(snetp->param_arr[20].param_val)
#define	param_anlpar_100T4	(snetp->param_arr[21].param_val)
#define	param_anlpar_100fdx	(snetp->param_arr[22].param_val)
#define	param_anlpar_100hdx	(snetp->param_arr[23].param_val)
#define	param_anlpar_10fdx	(snetp->param_arr[24].param_val)
#define	param_anlpar_10hdx	(snetp->param_arr[25].param_val)
#define	param_lance_mode	(snetp->param_arr[26].param_val)
#define	param_ipg0		(snetp->param_arr[27].param_val)
#define	param_intr_blank_time		(snetp->param_arr[28].param_val)
#define	param_intr_blank_packets	(snetp->param_arr[29].param_val)
#define	param_serial_link	(snetp->param_arr[30].param_val)

#define	param_non_serial_link	(snetp->param_arr[31].param_val)
#define	param_select_link	(snetp->param_arr[32].param_val)
#define	param_default_link	(snetp->param_arr[33].param_val)
#define	param_link_in_use	(snetp->param_arr[34].param_val)
#define	param_anar_asm_dir	(snetp->param_arr[35].param_val)
#define	param_anar_pause	(snetp->param_arr[36].param_val)
#define	param_bmsr_asm_dir	(snetp->param_arr[37].param_val)
#define	param_bmsr_pause	(snetp->param_arr[38].param_val)
#define	param_anlpar_pauseTX 	(snetp->param_arr[49].param_val)
#define	param_anlpar_pauseRX 	(snetp->param_arr[40].param_val)

/*
 * Ether-type is specifically big-endian, but data region is unknown endian
 * Ether-type lives at offset 12 from the start of the packet.
 */

#define	get_ether_type(ptr) \
	(((((uint8_t *)ptr)[12] << 8) | (((uint8_t *)ptr)[13])))

#endif	/* _KERNEL */

#ifdef	__cplusplus
}
#endif

#endif	/* _SYS_SNET_COMMON_H */
