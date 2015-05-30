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


/*
 * This ethernet driver code is based on sun4/io/eri.c .
 * 
 * snet ethernet device provides an interface to the OS
 * to access Xilinx xemaclite ethernet controller. xemaclite
 * ethernet controller has very limited capabilities and this
 * device driver is meant to be used within the constraints of
 * the capabilities of xemaclite ethernet controller. xemaclite
 * doesn't support multicast, loopback etc.
 * 
 */

/*
 * SunOS MT STREAMS SNET 10/100 Mb Ethernet Device Driver
 */

#include	<sys/types.h>
#include	<sys/debug.h>
#include	<sys/stropts.h>
#include	<sys/stream.h>
#include	<sys/strlog.h>
#include	<sys/strsubr.h>
#include	<sys/kmem.h>
#include	<sys/crc32.h>
#include	<sys/ddi.h>
#include	<sys/sunddi.h>
#include	<sys/strsun.h>
#include	<sys/stat.h>
#include	<sys/cpu.h>
#include	<sys/kstat.h>
#include	<inet/common.h>
#include	<sys/pattr.h>
#include	<inet/mi.h>
#include	<inet/nd.h>
#include	<sys/ethernet.h>
#include	<sys/policy.h>
#include	<sys/mac.h>
#include	<sys/mac_ether.h>
#include	<sys/dlpi.h>

#include	<sys/pci.h>

#include	<snet.h>
#include	<snet_common.h>

#include	<snet_msg.h>

#ifdef	DEBUG
#include	<sys/spl.h>
#endif
/*
 *  **** Function Prototypes *****
 */
/*
 * Entry points (man9e)
 */
static	int	snet_attach(dev_info_t *, ddi_attach_cmd_t);
static	int	snet_detach(dev_info_t *, ddi_detach_cmd_t);
static	uint_t	snet_intr(caddr_t);

/*
 * I/O (Input/Output) Functions
 */
static	boolean_t	snet_send_msg(struct snet *, mblk_t *);

/* New functions */

static void set_mac_address(struct snet *snetp);
static void disable_all_intrs(struct snet *snetp);
static void set_promisc(struct snet *snetp);
static void set_loopback(struct snet *snetp);
static mblk_t *hv_read_pkt(struct snet *snetp);
static void hv_snet_stop(struct snet *snetp);
static void hv_snet_start(struct snet *snetp);
static void enable_txmac(struct snet *snetp);
static void enable_mac(struct snet *snetp);

/*
 * Initialization Functions
 */
static  boolean_t	snet_init(struct snet *);
static  int	snet_init_xfer_params(struct snet *);
static  void	snet_statinit(struct snet *);

static	void	snet_setup_mac_address(struct snet *, dev_info_t *);

static	void	snet_init_rx(struct snet *);
static	void	snet_init_txmac(struct snet *);

/*
 * Un-init Functions
 */
static	uint32_t snet_txmac_disable(struct snet *);
static	uint32_t snet_rxmac_disable(struct snet *);
static	int	snet_stop(struct snet *);
static	void	snet_uninit(struct snet *snetp);

/*
 * Hardening Functions
 */
static void snet_fault_msg(struct snet *, uint_t, msg_t, const char *, ...);

/*
 * Misc Functions
 */
static void	snet_savecntrs(struct snet *);

/*
 * Utility Functions
 */
static	mblk_t *snet_allocb(size_t size);
static	mblk_t *snet_allocb_sp(size_t size);
static	int	snet_param_get(queue_t *q, mblk_t *mp, caddr_t cp);
static	int	snet_param_set(queue_t *, mblk_t *, char *, caddr_t);

/*
 * Functions to support ndd
 */
static	void	snet_nd_free(caddr_t *nd_pparam);

static	boolean_t	snet_nd_load(caddr_t *nd_pparam, char *name,
				pfi_t get_pfi, pfi_t set_pfi, caddr_t data);

static	int	snet_nd_getset(queue_t *q, caddr_t nd_param, MBLKP mp);
static	void	snet_param_cleanup(struct snet *);
static	int	snet_param_register(struct snet *, param_t *, int);
static	void	snet_process_ndd_ioctl(struct snet *, queue_t *, mblk_t *, int);
static	int	snet_mk_mblk_tail_space(mblk_t *, mblk_t **, size_t);


static	void snet_loopback(struct snet *, queue_t *, mblk_t *);

static uint32_t	snet_ladrf_bit(const uint8_t *);


/*
 * Nemo (GLDv3) Functions.
 */
static	int		snet_m_stat(void *, uint_t, uint64_t *);
static	int		snet_m_start(void *);
static	void		snet_m_stop(void *);
static	int		snet_m_promisc(void *, boolean_t);
static	int		snet_m_multicst(void *, boolean_t, const uint8_t *);
static	int		snet_m_unicst(void *, const uint8_t *);
static	void		snet_m_ioctl(void *, queue_t *, mblk_t *);
static	boolean_t	snet_m_getcapab(void *, mac_capab_t, void *);
static	mblk_t		*snet_m_tx(void *, mblk_t *);

static mac_callbacks_t snet_m_callbacks = {
	MC_IOCTL | MC_GETCAPAB,
	snet_m_stat,
	snet_m_start,
	snet_m_stop,
	snet_m_promisc,
	snet_m_multicst,
	snet_m_unicst,
	snet_m_tx,
	NULL,
	snet_m_ioctl,
	snet_m_getcapab
};

/*
 * MIB II broadcast/multicast packets
 */

#define	IS_BROADCAST(pkt) (bcmp(pkt, &etherbroadcastaddr, ETHERADDRL) == 0)
#define	IS_MULTICAST(pkt) ((pkt[0] & 01) == 1)

#define	BUMP_InNUcast(snetp, pkt) \
		if (IS_BROADCAST(pkt)) { \
			HSTAT(snetp, brdcstrcv); \
		} else if (IS_MULTICAST(pkt)) { \
			HSTAT(snetp, multircv); \
		}

#define	BUMP_OutNUcast(snetp, pkt) \
		if (IS_BROADCAST(pkt)) { \
			HSTAT(snetp, brdcstxmt); \
		} else if (IS_MULTICAST(pkt)) { \
			HSTAT(snetp, multixmt); \
		}

#define	ETHERHEADER_SIZE (sizeof (struct ether_header))

#define	SNET_PROCESS_READ(snetp, bp)				\
{								\
	t_uscalar_t	type;					\
	type = get_ether_type(bp->b_rptr);			\
								\
	/*							\
	 * update MIB II statistics				\
	 */							\
	HSTAT(snetp, ipackets64);				\
	HSTATN(snetp, rbytes64, len);				\
	BUMP_InNUcast(snetp, bp->b_rptr);			\
	/*							\
	 * Strip the PADS for 802.3				\
	 */							\
	if (type <= ETHERMTU)					\
		bp->b_wptr = bp->b_rptr + ETHERHEADER_SIZE + 	\
			type;					\
}

/*
 * Ethernet broadcast address definition.
 */
static uint8_t	etherbroadcastaddr[] = {
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff
};


/*
 * SNET Configuration Register Value
 * Used to configure parameters that define DMA burst
 * and internal arbitration behavior.
 * for equal TX and RX bursts, set the following in global
 * configuration register.
 * static	int	global_config = 0x42;
 */

/*
 * SNET ERX Interrupt Blanking Time
 * Each count is about 16 us (2048 clocks) for 66 MHz PCI.
 */
static	int	intr_blank_time = 6;	/* for about 96 us */
static	int	intr_blank_packets = 8;	/*  */

/*
 * Link Configuration variables
 *
 * On Motherboard implementations, 10/100 Mbps speeds may be supported
 * by using both the Serial Link and the MII on Non-serial-link interface.
 * When both links are present, the driver automatically tries to bring up
 * both. If both are up, the Gigabit Serial Link is selected for use, by
 * default. The following configuration variable is used to force the selection
 * of one of the links when both are up.
 * To change the default selection to the MII link when both the Serial
 * Link and the MII link are up, change snet_default_link to 1.
 *
 * Once a link is in use, the driver will continue to use that link till it
 * goes down. When it goes down, the driver will look at the status of both the
 * links again for link selection.
 *
 * Currently the standard is not stable w.r.t. gigabit link configuration
 * using auto-negotiation procedures. Meanwhile, the link may be configured
 * in "forced" mode using the "autonegotiation enable" bit (bit-12) in the
 * PCS MII Command Register. In this mode the PCS sends "idles" until sees
 * "idles" as initialization instead of the Link Configuration protocol
 * where a Config register is exchanged. In this mode, the SNET is programmed
 * for full-duplex operation with both pauseTX and pauseRX (for flow control)
 * enabled.
 */

static	int	select_link = 0; /* automatic selection */
static	int	default_link = 0; /* Select Serial link if both are up */

/*
 * The following variables are used for configuring link-operation
 * for all the "snet" interfaces in the system.
 * Later these parameters may be changed per interface using "ndd" command
 * These parameters may also be specified as properties using the .conf
 * file mechanism for each interface.
 */

/*
 * The following variable value will be overridden by "link-pulse-disabled"
 * property which may be created by OBP or snet.conf file. This property is
 * applicable only for 10 Mbps links.
 */
static	int	link_pulse_disabled = 0;	/* link pulse disabled */

/* For MII-based FastEthernet links */
static	int	adv_autoneg_cap = 1;
static	int	adv_100T4_cap = 0;
static	int	adv_100fdx_cap = 1;
static	int	adv_100hdx_cap = 1;
static	int	adv_10fdx_cap = 1;
static	int	adv_10hdx_cap = 1;
static	int	adv_pauseTX_cap =  0;
static	int	adv_pauseRX_cap =  0;

/*
 * The following gap parameters are in terms of byte times.
 */
static	int	ipg0 = 8;
static	int	ipg1 = 8;
static	int	ipg2 = 4;

static	int	lance_mode = 1;		/* to enable LANCE mode */

/* The following parameters may be configured by the user. If they are not
 * configured by the user, the values will be based on the capabilities of
 * the transceiver.
 * The value "SNET_NOTUSR" is ORed with the parameter value to indicate values
 * which are NOT configured by the user.
 */

#define	SNET_NOTUSR	0x0f000000
#define	SNET_MASK_1BIT	0x1
#define	SNET_MASK_2BIT	0x3
#define	SNET_MASK_8BIT	0xff


/*
 * Note:
 * SNET has all of the above capabilities.
 * Only when an External Transceiver is selected for MII-based FastEthernet
 * link operation, the capabilities depend upon the capabilities of the
 * External Transceiver.
 */

/*
 * For the MII interface, the External Transceiver is selected when present.
 * The following variable is used to select the Internal Transceiver even
 * when the External Transceiver is present.
*/
static  int     use_int_xcvr = 0;
static  int     pace_size = 0;  /* Do not use pacing for now */


/* ------------------------------------------------------------------------- */

static  param_t	param_arr[] = {
	/* min		max		value	r/w/hidden+name */
	{  0,		2,		2,	"-transceiver_inuse"},
	{  0,		1,		0,	"-link_status"},
	{  0,		1,		0,	"-link_speed"},
	{  0,		1,		0,	"-link_mode"},
	{  0,		255,		8,	"+ipg1"},
	{  0,		255,		4,	"+ipg2"},
	{  0,           1,              0,      "+use_int_xcvr"},
	{  0,           255,            0,      "+pace_size"},
	{  0,		1,		1,	"+adv_autoneg_cap"},
	{  0,		1,		1,	"+adv_100T4_cap"},
	{  0,		1,		1,	"+adv_100fdx_cap"},
	{  0,		1,		1,	"+adv_100hdx_cap"},
	{  0,		1,		1,	"+adv_10fdx_cap"},
	{  0,		1,		1,	"+adv_10hdx_cap"},
	{  0,		1,		1,	"-autoneg_cap"},
	{  0,		1,		1,	"-100T4_cap"},
	{  0,		1,		1,	"-100fdx_cap"},
	{  0,		1,		1,	"-100hdx_cap"},
	{  0,		1,		1,	"-10fdx_cap"},
	{  0,		1,		1,	"-10hdx_cap"},
	{  0,		1,		0,	"-lp_autoneg_cap"},
	{  0,		1,		0,	"-lp_100T4_cap"},
	{  0,		1,		0,	"-lp_100fdx_cap"},
	{  0,		1,		0,	"-lp_100hdx_cap"},
	{  0,		1,		0,	"-lp_10fdx_cap"},
	{  0,		1,		0,	"-lp_10hdx_cap"},
	{  0,		1,		1,	"+lance_mode"},
	{  0,		31,		8,	"+ipg0"},
	{  0,		127,		6,	"+intr_blank_time"},
	{  0,		255,		8,	"+intr_blank_packets"},
	{  0,		1,		1,	"!serial-link"},
	{  0,		2,		1,	"!non-serial-link"},
	{  0,		1,		0,	"%select-link"},
	{  0,		1,		0,	"%default-link"},
	{  0,		2,		0,	"!link-in-use"},
	{  0,		1,		1,	"%adv_asm_dir_cap"},
	{  0,		1,		1,	"%adv_pause_cap"},
	{  0,		1,		0,	"!asm_dir_cap"},
	{  0,		1,		0,	"!pause_cap"},
	{  0,		1,		0,	"!lp_asm_dir_cap"},
	{  0,		1,		0,	"!lp_pause_cap"},
};

DDI_DEFINE_STREAM_OPS(snet_dev_ops, nulldev, nulldev, snet_attach, snet_detach,
	nodev, NULL, D_MP, NULL);



/*
 * The device driver communicates with the snet device through
 * messages. Every message consists of an snet header followed by
 * optional data. 
 *
 * struct snet_hdr {
 *       uint32_t  data_size;
 *       uint32_t  cmd;
 * }
 *
 * The hypervisor doesn't interpret the contents of the header
 * or the data. It simply provides a mechanism to send messages
 * to the snet device.
 *
 * For performance reasons, the hypervisor reads/writes double
 * words even if data count is not a multiple of double word.
 *
 */


#define SNET_CMD_START       0x01
#define SNET_CMD_STOP        0x02
#define SNET_CMD_TX          0x04
#define SNET_CMD_RX          0x08
#define SNET_CMD_MAC         0x10

#define SNET_HDR_SIZE        8

#define SNET_HDR_CMD_SHIFT   0
#define SNET_HDR_SIZE_SHIFT  32

extern int hv_snet_read(void *pa, size_t size);
extern int hv_snet_write(void *pa, size_t size);




/*
 * This is the loadable module wrapper.
 */
#include <sys/modctl.h>

/*
 * Module linkage information for the kernel.
 */
static struct modldrv modldrv = {
	&mod_driverops,	/* Type of module.  This one is a driver */
	"Sun SNET 10/100 Mb Ethernet",
	&snet_dev_ops,	/* driver ops */
};

static struct modlinkage modlinkage = {
	MODREV_1, &modldrv, NULL
};

/*
 * Hardware Independent Functions
 * New Section
 */

int
_init(void)
{
	int	status;

	mac_init_ops(&snet_dev_ops, "snet");
	if ((status = mod_install(&modlinkage)) != 0) {
		mac_fini_ops(&snet_dev_ops);
	}
	return (status);
}

int
_fini(void)
{
	int status;

	status = mod_remove(&modlinkage);
	if (status == 0) {
		mac_fini_ops(&snet_dev_ops);
	}
	return (status);
}

int
_info(struct modinfo *modinfop)
{
	return (mod_info(&modlinkage, modinfop));
}

/*
 * Interface exists: make available by filling in network interface
 * record.  System will initialize the interface when it is ready
 * to accept packets.
 */
static int
snet_attach(dev_info_t *dip, ddi_attach_cmd_t cmd)
{
	struct snet *snetp = NULL;
	mac_register_t *macp = NULL;
	boolean_t	doinit;
	boolean_t	mutex_inited = B_FALSE;
	boolean_t	intr_add = B_FALSE;

	switch (cmd) {
	case DDI_ATTACH:
		break;

	case DDI_RESUME:
		if ((snetp = ddi_get_driver_private(dip)) == NULL)
			return (DDI_FAILURE);

		mutex_enter(&snetp->intrlock);
		snetp->flags &= ~SNET_SUSPENDED;
		snetp->init_macregs = 1;
		param_linkup = 0;
		snetp->stats.link_up = LINK_STATE_DOWN;

		doinit =  (snetp->flags & SNET_STARTED) ? B_TRUE : B_FALSE;
		mutex_exit(&snetp->intrlock);

		if (doinit && !snet_init(snetp)) {
			return (DDI_FAILURE);
		}
		return (DDI_SUCCESS);

	default:
		return (DDI_FAILURE);
	}

	/*
	 * Allocate soft device data structure
	 */
	snetp = kmem_zalloc(sizeof (struct snet), KM_SLEEP);

	/*
	 * Initialize as many elements as possible.
	 */
	ddi_set_driver_private(dip, snetp);
	snetp->dip = dip;			/* dip	*/
	snetp->instance = ddi_get_instance(dip);	/* instance */
	snetp->flags = 0;
	snetp->multi_refcnt = 0;
	snetp->promisc = B_FALSE;

	if ((macp = mac_alloc(MAC_VERSION)) == NULL) {
		SNET_FAULT_MSG1(snetp, SEVERITY_HIGH, SNET_VERB_MSG,
		    "mac_alloc failed");
		goto attach_fail;
	}
	macp->m_type_ident = MAC_PLUGIN_IDENT_ETHER;
	macp->m_driver = snetp;
	macp->m_dip = dip;
	macp->m_src_addr = snetp->ouraddr;
	macp->m_callbacks = &snet_m_callbacks;
	macp->m_min_sdu = 0;
	macp->m_max_sdu = ETHERMTU;

	snetp->send_buffer_pa = va_to_pa(snetp->send_buffer);
	snetp->recv_buffer_pa = va_to_pa(snetp->recv_buffer);
	
	/*
	 * Initialize device attributes structure
	 */
	snetp->dev_attr.devacc_attr_version =	DDI_DEVICE_ATTR_V0;
	snetp->dev_attr.devacc_attr_dataorder =	DDI_STRICTORDER_ACC;
	snetp->dev_attr.devacc_attr_endian_flags =	DDI_STRUCTURE_BE_ACC;


	/*
	 * Try and stop the device.
	 * This is done until we want to handle interrupts.
	 */
	if (snet_stop(snetp))
		goto attach_fail;

	if (ddi_intr_hilevel(dip, 0)) {
		SNET_FAULT_MSG1(snetp, SEVERITY_NONE, SNET_VERB_MSG,
		    " high-level interrupts are not supported");
		goto attach_fail;
	}

	/*
	 * Get the interrupt cookie so the mutexes can be
	 * Initialized.
	 */
	if (ddi_get_iblock_cookie(dip, 0, &snetp->cookie) != DDI_SUCCESS)
		goto attach_fail;

	/*
	 * Initialize mutex's for this device.
	 */
	mutex_init(&snetp->xmitlock, NULL, MUTEX_DRIVER, (void *)snetp->cookie);
	mutex_init(&snetp->intrlock, NULL, MUTEX_DRIVER, (void *)snetp->cookie);
	mutex_init(&snetp->xcvrlock, NULL, MUTEX_DRIVER, (void *)snetp->cookie);

	mutex_inited = B_TRUE;

	/*
	 * Add interrupt to system
	 */
	if (ddi_add_intr(dip, 0, &snetp->cookie, 0, snet_intr, (caddr_t)snetp) ==
	    DDI_SUCCESS)
		intr_add = B_TRUE;
	else {
		goto attach_fail;
	}

	/*
	 * Set up the ethernet mac address.
	 */
	(void) snet_setup_mac_address(snetp, dip);

	if (snet_init_xfer_params(snetp))
		goto attach_fail;

	snetp->stats.pmcap = SNET_PMCAP_NONE;
	if (pci_report_pmcap(dip, PCI_PM_IDLESPEED, (void *)4000) ==
	    DDI_SUCCESS)
		snetp->stats.pmcap = SNET_PMCAP_4MHZ;

	if (mac_register(macp, &snetp->mh) != 0)
		goto attach_fail;

	mac_free(macp);

	return (DDI_SUCCESS);

attach_fail:
	if (mutex_inited) {
		mutex_destroy(&snetp->xmitlock);
		mutex_destroy(&snetp->intrlock);
		mutex_destroy(&snetp->xcvrlock);
	}

	SNET_FAULT_MSG1(snetp, SEVERITY_NONE, SNET_VERB_MSG, attach_fail_msg);

	if (intr_add)
		ddi_remove_intr(dip, 0, snetp->cookie);

	if (macp != NULL)
		mac_free(macp);
	if (snetp != NULL)
		kmem_free(snetp, sizeof (*snetp));

	return (DDI_FAILURE);
}

static int
snet_detach(dev_info_t *dip, ddi_detach_cmd_t cmd)
{
	struct snet 	*snetp;
	int i;

	if ((snetp = ddi_get_driver_private(dip)) == NULL) {
		/*
		 * No resources allocated.
		 */
		return (DDI_FAILURE);
	}

	switch (cmd) {
	case DDI_DETACH:
		break;

	case DDI_SUSPEND:
		snetp->flags |= SNET_SUSPENDED;
		snet_uninit(snetp);
		return (DDI_SUCCESS);

	default:
		return (DDI_FAILURE);
	}

	if (snetp->flags & (SNET_RUNNING | SNET_SUSPENDED)) {
		SNET_FAULT_MSG1(snetp, SEVERITY_NONE, SNET_VERB_MSG, busy_msg);
		return (DDI_FAILURE);
	}

	if (mac_unregister(snetp->mh) != 0) {
		return (DDI_FAILURE);
	}

	/*
	 * Make the device quiescent
	 */
	(void) snet_stop(snetp);

	/*
	 * Remove instance of the intr
	 */
	ddi_remove_intr(dip, 0, snetp->cookie);

	/*
	 * Destroy all mutexes and data structures allocated during
	 * attach time.
	 */

	if (snetp->ksp)
		kstat_delete(snetp->ksp);

	mutex_destroy(&snetp->xmitlock);
	mutex_destroy(&snetp->intrlock);
	mutex_destroy(&snetp->xcvrlock);

	snet_param_cleanup(snetp);

	ddi_set_driver_private(dip, NULL);
	kmem_free((caddr_t)snetp, sizeof (struct snet));

	return (DDI_SUCCESS);
}

/*
 * To set up the mac address for the network interface:
 * The adapter card may support a local mac address which is published
 * in a device node property "local-mac-address". This mac address is
 * treated as the factory-installed mac address for DLPI interface.
 * If the adapter firmware has used the device for diskless boot
 * operation it publishes a property called "mac-address" for use by
 * inetboot and the device driver.
 * If "mac-address" is not found, the system options property
 * "local-mac-address" is used to select the mac-address. If this option
 * is set to "true", and "local-mac-address" has been found, then
 * local-mac-address is used; otherwise the system mac address is used
 * by calling the "localetheraddr()" function.
 */

static void
snet_setup_mac_address(struct snet *snetp, dev_info_t *dip)
{
	uchar_t			*prop;
	char			*uselocal;
	unsigned		prop_len;
	uint32_t		addrflags = 0;
	struct ether_addr	factaddr;

	/*
	 * Check if it is an adapter with its own local mac address
	 * If it is present, save it as the "factory-address"
	 * for this adapter.
	 */
	if (ddi_prop_lookup_byte_array(DDI_DEV_T_ANY, dip, DDI_PROP_DONTPASS,
	    "local-mac-address", &prop, &prop_len) == DDI_PROP_SUCCESS) {
		if (prop_len == ETHERADDRL) {
			addrflags = SNET_FACTADDR_PRESENT;
			bcopy(prop, &factaddr, ETHERADDRL);
			SNET_FAULT_MSG2(snetp, SEVERITY_NONE, SNET_VERB_MSG,
			    lether_addr_msg, ether_sprintf(&factaddr));
		}
		ddi_prop_free(prop);
	}
	/*
	 * Check if the adapter has published "mac-address" property.
	 * If it is present, use it as the mac address for this device.
	 */
	if (ddi_prop_lookup_byte_array(DDI_DEV_T_ANY, dip, DDI_PROP_DONTPASS,
	    "mac-address", &prop, &prop_len) == DDI_PROP_SUCCESS) {
		if (prop_len >= ETHERADDRL) {
			bcopy(prop, snetp->ouraddr, ETHERADDRL);
			ddi_prop_free(prop);
			return;
		}
		ddi_prop_free(prop);
	}

	if (ddi_prop_lookup_string(DDI_DEV_T_ANY, dip, 0, "local-mac-address?",
	    &uselocal) == DDI_PROP_SUCCESS) {
		if ((strcmp("true", uselocal) == 0) &&
		    (addrflags & SNET_FACTADDR_PRESENT)) {
			addrflags |= SNET_FACTADDR_USE;
			bcopy(&factaddr, snetp->ouraddr, ETHERADDRL);
			ddi_prop_free(uselocal);
			SNET_FAULT_MSG1(snetp, SEVERITY_NONE, SNET_VERB_MSG,
			    lmac_addr_msg);
			return;
		}
		ddi_prop_free(uselocal);
	}

	/*
	 * Get the system ethernet address.
	 */
	(void) localetheraddr(NULL, &factaddr);
	bcopy(&factaddr, snetp->ouraddr, ETHERADDRL);
}


/*
 * Calculate the bit in the multicast address filter that selects the given
 * address.
 * Note: For SNET, the last 8-bits are used.
 */

static uint32_t
snet_ladrf_bit(const uint8_t *addr)
{
	uint32_t crc;

	CRC32(crc, addr, ETHERADDRL, -1U, crc32_table);

	/*
	 * Just want the 8 most significant bits.
	 */
	return ((~crc) >> 24);
}

static void
snet_m_ioctl(void *arg, queue_t *wq, mblk_t *mp)
{
	struct	snet	*snetp = arg;
	struct	iocblk	*iocp = (void *)mp->b_rptr;
	int	err;


	ASSERT(snetp != NULL);

	/*
	 * Privilege checks.
	 */
	switch (iocp->ioc_cmd) {
	case SNET_SET_LOOP_MODE:
	case SNET_ND_SET:
		err = secpolicy_net_config(iocp->ioc_cr, B_FALSE);
		if (err != 0) {
			miocnak(wq, mp, 0, err);
			return;
		}
		break;
	default:
		break;
	}

	switch (iocp->ioc_cmd) {
	case SNET_ND_GET:
	case SNET_ND_SET:
		snet_process_ndd_ioctl(snetp, wq, mp, iocp->ioc_cmd);
		break;

	case SNET_SET_LOOP_MODE:
	case SNET_GET_LOOP_MODE:
		/*
		 * XXX: Consider updating this to the new netlb ioctls.
		 */
		snet_loopback(snetp, wq, mp);
		break;

	default:
		miocnak(wq, mp, 0, EINVAL);
		break;
	}
}

static void
snet_loopback(struct snet *snetp, queue_t *wq, mblk_t *mp)
{
	struct	iocblk	*iocp = (void *)mp->b_rptr;
	loopback_t	*al;


	/*LINTED E_PTRDIFF_OVERFLOW*/
	if (mp->b_cont == NULL || MBLKL(mp->b_cont) < sizeof (loopback_t)) {
		miocnak(wq, mp, 0, EINVAL);
		return;
	}

	al = (void *)mp->b_cont->b_rptr;

	switch (iocp->ioc_cmd) {
	case SNET_SET_LOOP_MODE:
		switch (al->loopback) {
		case SNET_LOOPBACK_OFF:
			snetp->flags &= (~SNET_MACLOOPBACK & ~SNET_SERLOOPBACK);
			/* force link status to go down */
			param_linkup = 0;
			snetp->stats.link_up = LINK_STATE_DOWN;
			snetp->stats.link_duplex = LINK_DUPLEX_UNKNOWN;
			(void) snet_init(snetp);
			break;

		case SNET_MAC_LOOPBACK_ON:
			snetp->flags |= SNET_MACLOOPBACK;
			snetp->flags &= ~SNET_SERLOOPBACK;
			param_linkup = 0;
			snetp->stats.link_up = LINK_STATE_DOWN;
			snetp->stats.link_duplex = LINK_DUPLEX_UNKNOWN;
			(void) snet_init(snetp);
			break;

		case SNET_PCS_LOOPBACK_ON:
			break;

		case SNET_SER_LOOPBACK_ON:
			snetp->flags |= SNET_SERLOOPBACK;
			snetp->flags &= ~SNET_MACLOOPBACK;
			/* force link status to go down */
			param_linkup = 0;
			snetp->stats.link_up = LINK_STATE_DOWN;
			snetp->stats.link_duplex = LINK_DUPLEX_UNKNOWN;
			(void) snet_init(snetp);
			break;

		default:
			SNET_FAULT_MSG1(snetp, SEVERITY_NONE, SNET_VERB_MSG,
			    loopback_val_default);
			miocnak(wq, mp, 0, EINVAL);
			return;
		}
		miocnak(wq, mp, 0, 0);
		break;

	case SNET_GET_LOOP_MODE:
		al->loopback =	SNET_MAC_LOOPBACK_ON | SNET_PCS_LOOPBACK_ON |
		    SNET_SER_LOOPBACK_ON;
		miocack(wq, mp, sizeof (loopback_t), 0);
		break;

	default:
		SNET_FAULT_MSG1(snetp, SEVERITY_LOW, SNET_VERB_MSG,
		    loopback_cmd_default);
	}
}

static int
snet_m_promisc(void *arg, boolean_t on)
{
	struct	snet	*snetp = arg;


	mutex_enter(&snetp->intrlock);
	snetp->promisc = on;
	snet_init_rx(snetp);
	mutex_exit(&snetp->intrlock);
	return (0);
}

/*
 * This is to support unlimited number of members
 * in Multicast.
 */
static int
snet_m_multicst(void *arg, boolean_t add, const uint8_t *mca)
{
	struct snet		*snetp = arg;
	uint32_t 		ladrf_bit;


	/*
	 * If this address's bit was not already set in the local address
	 * filter, add it and re-initialize the Hardware.
	 */
	ladrf_bit = snet_ladrf_bit(mca);

	mutex_enter(&snetp->intrlock);
	if (add) {
		snetp->ladrf_refcnt[ladrf_bit]++;
		if (snetp->ladrf_refcnt[ladrf_bit] == 1) {
			LADRF_SET(snetp, ladrf_bit);
			snetp->multi_refcnt++;
			snet_init_rx(snetp);
		}
	} else {
		snetp->ladrf_refcnt[ladrf_bit]--;
		if (snetp->ladrf_refcnt[ladrf_bit] == 0) {
			LADRF_CLR(snetp, ladrf_bit);
			snetp->multi_refcnt--;
			snet_init_rx(snetp);
		}
	}
	mutex_exit(&snetp->intrlock);
	return (0);
}

static int
snet_m_unicst(void *arg, const uint8_t *macaddr)
{
	struct	snet	*snetp = arg;


	/*
	 * Set new interface local address and re-init device.
	 * This is destructive to any other streams attached
	 * to this device.
	 */
	mutex_enter(&snetp->intrlock);
	bcopy(macaddr, &snetp->ouraddr, ETHERADDRL);
	snet_init_rx(snetp);
	mutex_exit(&snetp->intrlock);
	return (0);
}

/*ARGSUSED*/
static boolean_t
snet_m_getcapab(void *arg, mac_capab_t cap, void *cap_data)
{
	switch (cap) {
	case MAC_CAPAB_HCKSUM: {
		uint32_t *hcksum_txflags = cap_data;
		*hcksum_txflags = HCKSUM_INET_FULL_V4 | HCKSUM_IPHDRCKSUM;
		return (B_TRUE);
	}
	case MAC_CAPAB_POLL:
	default:
		return (B_FALSE);
	}
}

static int
snet_m_start(void *arg)
{
	struct snet	*snetp = arg;


	mutex_enter(&snetp->intrlock);
	snetp->flags |= SNET_STARTED;
	mutex_exit(&snetp->intrlock);

	if (!snet_init(snetp)) {
		mutex_enter(&snetp->intrlock);
		snetp->flags &= ~SNET_STARTED;
		mutex_exit(&snetp->intrlock);
		return (EIO);
	}
	return (0);
}

static void
snet_m_stop(void *arg)
{
	struct snet	*snetp = arg;


	mutex_enter(&snetp->intrlock);
	snetp->flags &= ~SNET_STARTED;
	mutex_exit(&snetp->intrlock);
	snet_uninit(snetp);
}

static int
snet_m_stat(void *arg, uint_t stat, uint64_t *val)
{
	struct snet	*snetp = arg;
	struct stats	*esp;
	boolean_t	macupdate = B_FALSE;


	esp = &snetp->stats;

	mutex_enter(&snetp->xmitlock);
	if ((snetp->flags & SNET_RUNNING) && (snetp->flags & SNET_TXINIT)) {
		macupdate = B_TRUE;
	}
	mutex_exit(&snetp->xmitlock);
	if (macupdate)
		mac_tx_update(snetp->mh);

	snet_savecntrs(snetp);

	switch (stat) {
	case MAC_STAT_IFSPEED:
		*val = esp->ifspeed * 1000000ULL;
		break;
	case MAC_STAT_MULTIRCV:
		*val = esp->multircv;
		break;
	case MAC_STAT_BRDCSTRCV:
		*val = esp->brdcstrcv;
		break;
	case MAC_STAT_IPACKETS:
		*val = esp->ipackets64;
		break;
	case MAC_STAT_RBYTES:
		*val = esp->rbytes64;
		break;
	case MAC_STAT_OBYTES:
		*val = esp->obytes64;
		break;
	case MAC_STAT_OPACKETS:
		*val = esp->opackets64;
		break;
	case MAC_STAT_IERRORS:
		*val = esp->ierrors;
		break;
	case MAC_STAT_OERRORS:
		*val = esp->oerrors;
		break;
	case MAC_STAT_MULTIXMT:
		*val = esp->multixmt;
		break;
	case MAC_STAT_BRDCSTXMT:
		*val = esp->brdcstxmt;
		break;
	case MAC_STAT_NORCVBUF:
		*val = esp->norcvbuf;
		break;
	case MAC_STAT_NOXMTBUF:
		*val = esp->noxmtbuf;
		break;
	case MAC_STAT_UNDERFLOWS:
		*val = esp->txmac_urun;
		break;
	case MAC_STAT_OVERFLOWS:
		*val = esp->rx_overflow;
		break;
	case MAC_STAT_COLLISIONS:
		*val = esp->collisions;
		break;
	case ETHER_STAT_ALIGN_ERRORS:
		*val = esp->rx_align_err;
		break;
	case ETHER_STAT_FCS_ERRORS:
		*val = esp->rx_crc_err;
		break;
	case ETHER_STAT_EX_COLLISIONS:
		*val = esp->excessive_coll;
		break;
	case ETHER_STAT_TX_LATE_COLLISIONS:
		*val = esp->late_coll;
		break;
	case ETHER_STAT_FIRST_COLLISIONS:
		*val = esp->first_coll;
		break;
	case ETHER_STAT_LINK_DUPLEX:
		*val = esp->link_duplex;
		break;
	case ETHER_STAT_TOOLONG_ERRORS:
		*val = esp->rx_toolong_pkts;
		break;
	case ETHER_STAT_TOOSHORT_ERRORS:
		*val = esp->rx_runt;
		break;

	case ETHER_STAT_XCVR_ADDR:
		*val = snetp->phyad;
		break;

	case ETHER_STAT_XCVR_INUSE:
		*val = XCVR_100X;	/* should always be 100X for now */
		break;

	case ETHER_STAT_CAP_100FDX:
		*val = param_bmsr_100fdx;
		break;
	case ETHER_STAT_CAP_100HDX:
		*val = param_bmsr_100hdx;
		break;
	case ETHER_STAT_CAP_10FDX:
		*val = param_bmsr_10fdx;
		break;
	case ETHER_STAT_CAP_10HDX:
		*val = param_bmsr_10hdx;
		break;
	case ETHER_STAT_CAP_AUTONEG:
		*val = param_bmsr_ancap;
		break;
	case ETHER_STAT_CAP_ASMPAUSE:
		*val = param_bmsr_asm_dir;
		break;
	case ETHER_STAT_CAP_PAUSE:
		*val = param_bmsr_pause;
		break;
	case ETHER_STAT_ADV_CAP_100FDX:
		*val = param_anar_100fdx;
		break;
	case ETHER_STAT_ADV_CAP_100HDX:
		*val = param_anar_100hdx;
		break;
	case ETHER_STAT_ADV_CAP_10FDX:
		*val = param_anar_10fdx;
		break;
	case ETHER_STAT_ADV_CAP_10HDX:
		*val = param_anar_10hdx;
		break;
	case ETHER_STAT_ADV_CAP_AUTONEG:
		*val = param_autoneg;
		break;
	case ETHER_STAT_ADV_CAP_ASMPAUSE:
		*val = param_anar_asm_dir;
		break;
	case ETHER_STAT_ADV_CAP_PAUSE:
		*val = param_anar_pause;
		break;
	case ETHER_STAT_LP_CAP_100FDX:
		*val = param_anlpar_100fdx;
		break;
	case ETHER_STAT_LP_CAP_100HDX:
		*val = param_anlpar_100hdx;
		break;
	case ETHER_STAT_LP_CAP_10FDX:
		*val = param_anlpar_10fdx;
		break;
	case ETHER_STAT_LP_CAP_10HDX:
		*val = param_anlpar_10hdx;
		break;
	case ETHER_STAT_LP_CAP_AUTONEG:
		*val = param_aner_lpancap;
		break;
	case ETHER_STAT_LP_CAP_ASMPAUSE:
		*val = param_anlpar_pauseTX;
		break;
	case ETHER_STAT_LP_CAP_PAUSE:
		*val = param_anlpar_pauseRX;
		break;
	case ETHER_STAT_LINK_PAUSE:
		*val = esp->pausing;
		break;
	case ETHER_STAT_LINK_ASMPAUSE:
		*val = param_anar_asm_dir &&
		    param_anlpar_pauseTX &&
		    (param_anar_pause != param_anlpar_pauseRX);
		break;
	case ETHER_STAT_LINK_AUTONEG:
		*val = param_autoneg && param_aner_lpancap;
		break;
	default:
		break;
	}
	return (0);
}

/*
 * Hardware Functions
 * New Section
 */

/*
 * Initialize the MAC registers. Some of of the MAC  registers are initialized
 * just once since  Global Reset or MAC reset doesn't clear them. Others (like
 * Host MAC Address Registers) are cleared on every reset and have to be
 * reinitialized.
 */
static void
snet_init_macregs_generic(struct snet *snetp)
{
	if ((snetp->stats.inits == 1) || (snetp->init_macregs)) {
		snetp->init_macregs = 0;
	}

	/*
	 * Program BigMAC with local individual ethernet address.
	 */

	 set_mac_address(snetp);
}

static uint32_t
snet_txmac_disable(struct snet *snetp)
{
        hv_snet_stop(snetp);
	return (0);
}

static uint32_t
snet_rxmac_disable(struct snet *snetp)
{
        hv_snet_stop(snetp);
	return (0);
}

/*
 * Return 0 upon success, 1 on failure.
 */
static int
snet_stop(struct snet *snetp)
{


        hv_snet_stop(snetp);

	param_linkup = 0;
	snetp->stats.link_up = LINK_STATE_DOWN;
	snetp->stats.link_duplex = LINK_DUPLEX_UNKNOWN;
	snetp->global_reset_issued = -1;

	return (0);
}

/*
 * Initialize the TX DMA registers and Enable the TX DMA.
 */
static uint32_t
snet_init_txregs(struct snet *snetp)
{
	enable_mac(snetp);
	return (0);
}


/*
 * Initialize the RX DMA registers and Enable the RX DMA.
 */
static uint32_t
snet_init_rxregs(struct snet *snetp)
{
	return (0);
}

static void
snet_init_rx(struct snet *snetp)
{
	uint16_t	*ladrf;

	/*
	 * First of all make sure the Receive MAC is stop.
	 */
	(void) snet_rxmac_disable(snetp); /* Disable the RX MAC */

	/*
	 * Program BigMAC with local individual ethernet address.
	 */

        set_mac_address(snetp);

	/*
	 * Set up multicast address filter by passing all multicast
	 * addresses through a crc generator, and then using the
	 * low order 8 bits as a index into the 256 bit logical
	 * address filter. The high order four bits select the word,
	 * while the rest of the bits select the bit within the word.
	 */

	ladrf = snetp->ladrf;

	set_promisc(snetp);

        hv_snet_start(snetp);

	HSTAT(snetp, rx_inits);
}

/*
 * This routine is used to init the TX MAC only.
 *	&snetp->xmitlock is held before calling this routine.
 */
void
snet_init_txmac(struct snet *snetp)
{
	snetp->flags &= ~SNET_TXINIT;

	(void) snet_txmac_disable(snetp);

	enable_txmac(snetp);

	HSTAT(snetp, tx_inits);
	snetp->flags |= SNET_TXINIT;
}


static boolean_t
snet_init(struct snet *snetp)
{
	uint32_t	init_stat = 0;
	boolean_t	ret;
	link_state_t	linkupdate = LINK_STATE_UNKNOWN;

	/*
	 * Just return successfully if device is suspended.
	 * snet_init() will be called again from resume.
	 */
	ASSERT(snetp != NULL);


	if (snetp->flags & SNET_SUSPENDED) {
		ret = B_TRUE;
		goto init_exit;
	}

	mutex_enter(&snetp->intrlock);
	mutex_enter(&snetp->xmitlock);
	snetp->flags &= (SNET_DLPI_LINKUP | SNET_STARTED);
	HSTAT(snetp, inits);

	if ((snetp->stats.inits > 1) && (snetp->init_macregs == 0))
		snet_savecntrs(snetp);

	mutex_enter(&snetp->xcvrlock);
	if (!param_linkup) {
		linkupdate = LINK_STATE_DOWN;
		(void) snet_stop(snetp);
	}
	if (!(snetp->flags & SNET_DLPI_LINKUP) || !param_linkup) {
	    snetp->flags |= SNET_DLPI_LINKUP;
	    snetp->stats.link_up = LINK_STATE_UP;
	    linkupdate = LINK_STATE_UP;
	}

	mutex_exit(&snetp->xcvrlock);

	/*
	 * BigMAC requires that we confirm that tx, rx and hash are in
	 * quiescent state.
	 * MAC will not reset successfully if the transceiver is not reset and
	 * brought out of Isolate mode correctly. TXMAC reset may fail if the
	 * ext. transceiver is just disconnected. If it fails, try again by
	 * checking the transceiver.
	 */
	snet_txmac_disable(snetp);

	snet_rxmac_disable(snetp);

	snet_init_macregs_generic(snetp);

	if (snetp->global_reset_issued) {
		if (snet_init_txregs(snetp))
			goto done;
		if (snet_init_rxregs(snetp))
			goto done;
	}

	set_promisc(snetp);

	if (snetp->flags & SNET_MACLOOPBACK) {
		set_loopback(snetp);
	}

	/*
	 * Enable TX and RX MACs.
	 */
	enable_mac(snetp);
	snetp->flags |= (SNET_RUNNING | SNET_INITIALIZED |
	    SNET_TXINIT | SNET_RXINIT);
	param_linkup = 1;
	mac_tx_update(snetp->mh);
	snetp->global_reset_issued = 0;


done:
	mutex_exit(&snetp->xmitlock);
	mutex_exit(&snetp->intrlock);

	if (linkupdate != LINK_STATE_UNKNOWN)
		mac_link_update(snetp->mh, linkupdate);

	ret = (snetp->flags & SNET_RUNNING) ? B_TRUE : B_FALSE;
	if (!ret) {
		SNET_FAULT_MSG1(snetp, SEVERITY_NONE, SNET_VERB_MSG,
		    "snet_init failed");
	}

init_exit:
	return (ret);
}


/*
 * Un-initialize (STOP) SNET channel.
 */
static void
snet_uninit(struct snet *snetp)
{

	mutex_enter(&snetp->intrlock);
	mutex_enter(&snetp->xmitlock);
	mutex_enter(&snetp->xcvrlock);
	snetp->flags &= ~SNET_DLPI_LINKUP;
	mutex_exit(&snetp->xcvrlock);

	(void) snet_stop(snetp);
	snetp->flags &= ~SNET_RUNNING;

	mutex_exit(&snetp->xmitlock);
	mutex_exit(&snetp->intrlock);

	mac_link_update(snetp->mh, LINK_STATE_DOWN);
}

/* <<<<<<<<<<<<<<<<<	INTERRUPT HANDLING FUNCTION	>>>>>>>>>>>>>>>>>>>> */
/*
 *	First check to see if it is our device interrupting.
 */

static uint_t
snet_intr(caddr_t arg)
{
	struct snet *snetp = (void *)arg;
	uint32_t serviced = DDI_INTR_UNCLAIMED;
	link_state_t linkupdate = LINK_STATE_UNKNOWN;
	boolean_t macupdate = B_FALSE;
	mblk_t *mp;
	mblk_t *head;
	mblk_t **tail;

	head = NULL;
	tail = &head;

	mutex_enter(&snetp->intrlock);

	serviced = DDI_INTR_CLAIMED;

rx_done_int:
	{
		int loop_limit = 4;
		while (loop_limit) {
			/* process one packet */
			mp = hv_read_pkt(snetp);
			if (mp == NULL) {
			    break;
			}
			*tail = mp;
			tail = &mp->b_next;
			loop_limit--;
		}
	}

	mutex_exit(&snetp->intrlock);

	if (head)
		mac_rx(snetp->mh, NULL, head);

	return (serviced);
}
/*
 * if this is the first init do not bother to save the
 * counters.
 */
static void
snet_savecntrs(struct snet *snetp)
{
	uint32_t	fecnt, aecnt, lecnt, rxcv;
	uint32_t	ltcnt, excnt, fccnt;

	/* XXX What all gets added in ierrors and oerrors? */
	fecnt = 0;
	HSTATN(snetp, rx_crc_err, fecnt);

	aecnt = 0;
	HSTATN(snetp, rx_align_err, aecnt);

	lecnt = 0;
	HSTATN(snetp, rx_length_err, lecnt);

	rxcv = 0;
	HSTATN(snetp, rx_code_viol_err, rxcv);

	ltcnt = 0;
	HSTATN(snetp, late_coll, ltcnt);

	snetp->stats.collisions += ltcnt;

	excnt = 0;
	HSTATN(snetp, excessive_coll, excnt);

	fccnt = 0;
	HSTATN(snetp, first_coll, fccnt);

	/*
	 * Do not add code violations to input errors.
	 * They are already counted in CRC errors
	 */
	HSTATN(snetp, ierrors, (fecnt + aecnt + lecnt));
	HSTATN(snetp, oerrors, (ltcnt + excnt));
}

mblk_t *
snet_allocb_sp(size_t size)
{
	mblk_t  *mp;

	size += 128;
	if ((mp = allocb(size + 3 * SNET_BURSTSIZE, BPRI_HI)) == NULL) {
		return (NULL);
	}
	mp->b_wptr += 128;
	mp->b_wptr = (uint8_t *)ROUNDUP2(mp->b_wptr, SNET_BURSTSIZE);
	mp->b_rptr = mp->b_wptr;

	return (mp);
}

mblk_t *
snet_allocb(size_t size)
{
	mblk_t  *mp;

	if ((mp = allocb(size + 3 * SNET_BURSTSIZE, BPRI_HI)) == NULL) {
		return (NULL);
	}
	mp->b_wptr = (uint8_t *)ROUNDUP2(mp->b_wptr, SNET_BURSTSIZE);
	mp->b_rptr = mp->b_wptr;

	return (mp);
}

/*
 * Hardware Dependent Functions
 */

/* <<<<<<<<<<<<<<<<<	PACKET TRANSMIT FUNCTIONS	>>>>>>>>>>>>>>>>>>>> */


static boolean_t
snet_send_msg(struct snet *snetp, mblk_t *mp)
{
	uint32_t	len = 0;
	uint32_t	totlen = 0;

	int 		index;

	if (!param_linkup) {
		freemsg(mp);
		HSTAT(snetp, tnocar);
		HSTAT(snetp, oerrors);
		return (B_TRUE);
	}

	/*
	 * update MIB II statistics
	 */
	BUMP_OutNUcast(snetp, mp->b_rptr);

	mutex_enter(&snetp->xmitlock);

   	totlen = msgsize(mp);
	mcopymsg(mp, &snetp->send_buffer[1]);

	snetp->starts++;

	snetp->send_buffer[0] = (SNET_CMD_TX << SNET_HDR_CMD_SHIFT) | ((uint64_t) totlen << SNET_HDR_SIZE_SHIFT);

	if (hv_snet_write((void *) snetp->send_buffer_pa, (totlen+SNET_HDR_SIZE)) < 0) {
	    SNET_FAULT_MSG1(snetp, SEVERITY_NONE, SNET_VERB_MSG, "hv_snet_write failed in snet_send_msg");
	}

	mutex_exit(&snetp->xmitlock);

	return (B_TRUE);
}


static mblk_t *
snet_m_tx(void *arg, mblk_t *mp)
{
	struct snet *snetp = arg;
	mblk_t *next;

	while (mp != NULL) {
		next = mp->b_next;
		mp->b_next = NULL;
		if (!snet_send_msg(snetp, mp)) {
			mp->b_next = next;
			break;
		}
		mp = next;
	}

	return (mp);
}


/* <<<<<<<<<<<<<<<<<<<	PACKET RECEIVE FUNCTIONS	>>>>>>>>>>>>>>>>>>> */

static int
snet_init_xfer_params(struct snet *snetp)
{
	int	i;
	dev_info_t *dip;


	dip = snetp->dip;

	for (i = 0; i < A_CNT(param_arr); i++)
		snetp->param_arr[i] = param_arr[i];

	if (!snetp->g_nd && !snet_param_register(snetp,
	    snetp->param_arr, A_CNT(param_arr))) {
		SNET_FAULT_MSG1(snetp, SEVERITY_LOW, SNET_VERB_MSG,
		    param_reg_fail_msg);
			return (-1);
		}

	/*
	 * Set up the start-up values for user-configurable parameters
	 * Get the values from the global variables first.
	 * Use the MASK to limit the value to allowed maximum.
	 */

	param_transceiver = NO_XCVR;

/*
 * The link speed may be forced to either 10 Mbps or 100 Mbps using the
 * property "transfer-speed". This may be done in OBP by using the command
 * "apply transfer-speed=<speed> <device>". The speed may be either 10 or 100.
 */
	i = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0, "transfer-speed", 0);
	if (i != 0) {
		param_autoneg = 0;	/* force speed */
		param_anar_100T4 = 0;
		param_anar_10fdx = 0;
		param_anar_10hdx = 0;
		param_anar_100fdx = 0;
		param_anar_100hdx = 0;
		param_anar_asm_dir = 0;
		param_anar_pause = 0;

		if (i == 10)
			param_anar_10hdx = 1;
		else if (i == 100)
			param_anar_100hdx = 1;
	}

	/*
	 * Get the parameter values configured in .conf file.
	 */
	param_ipg1 = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0, "ipg1", ipg1) &
	    SNET_MASK_8BIT;

	param_ipg2 = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0, "ipg2", ipg2) &
	    SNET_MASK_8BIT;

	param_autoneg = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "adv_autoneg_cap", adv_autoneg_cap) & SNET_MASK_1BIT;

	param_autoneg = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "adv_autoneg_cap", adv_autoneg_cap) & SNET_MASK_1BIT;

	param_anar_100T4 = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "adv_100T4_cap", adv_100T4_cap) & SNET_MASK_1BIT;

	param_anar_100fdx = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "adv_100fdx_cap", adv_100fdx_cap) & SNET_MASK_1BIT;

	param_anar_100hdx = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "adv_100hdx_cap", adv_100hdx_cap) & SNET_MASK_1BIT;

	param_anar_10fdx = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "adv_10fdx_cap", adv_10fdx_cap) & SNET_MASK_1BIT;

	param_anar_10hdx = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "adv_10hdx_cap", adv_10hdx_cap) & SNET_MASK_1BIT;

	param_ipg0 = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0, "ipg0", ipg0) &
	    SNET_MASK_8BIT;

	param_intr_blank_time = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "intr_blank_time", intr_blank_time) & SNET_MASK_8BIT;

	param_intr_blank_packets = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "intr_blank_packets", intr_blank_packets) & SNET_MASK_8BIT;

	param_lance_mode = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "lance_mode", lance_mode) & SNET_MASK_1BIT;

	param_select_link = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "select_link", select_link) & SNET_MASK_1BIT;

	param_default_link = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "default_link", default_link) & SNET_MASK_1BIT;

	param_anar_asm_dir = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "adv_asm_dir_cap", adv_pauseTX_cap) & SNET_MASK_1BIT;

	param_anar_pause = ddi_prop_get_int(DDI_DEV_T_ANY, dip, 0,
	    "adv_pause_cap", adv_pauseRX_cap) & SNET_MASK_1BIT;

	snet_statinit(snetp);
	return (0);

}

static void
snet_process_ndd_ioctl(struct snet *snetp, queue_t *wq, mblk_t *mp, int cmd)
{

	uint32_t old_ipg1, old_ipg2, old_use_int_xcvr, old_autoneg;
	uint32_t old_100T4;
	uint32_t old_100fdx, old_100hdx, old_10fdx, old_10hdx;
	uint32_t old_ipg0, old_lance_mode;
	uint32_t old_intr_blank_time, old_intr_blank_packets;
	uint32_t old_asm_dir, old_pause;
	uint32_t old_select_link, old_default_link;


	switch (cmd) {
	case SNET_ND_GET:

		old_autoneg =	param_autoneg;
		old_100T4 =	param_anar_100T4;
		old_100fdx =	param_anar_100fdx;
		old_100hdx =	param_anar_100hdx;
		old_10fdx =	param_anar_10fdx;
		old_10hdx =	param_anar_10hdx;
		old_asm_dir =	param_anar_asm_dir;
		old_pause =	param_anar_pause;

		param_autoneg = old_autoneg & ~SNET_NOTUSR;
		param_anar_100T4 = old_100T4 & ~SNET_NOTUSR;
		param_anar_100fdx = old_100fdx & ~SNET_NOTUSR;
		param_anar_100hdx = old_100hdx & ~SNET_NOTUSR;
		param_anar_10fdx = old_10fdx & ~SNET_NOTUSR;
		param_anar_10hdx = old_10hdx & ~SNET_NOTUSR;
		param_anar_asm_dir = old_asm_dir & ~SNET_NOTUSR;
		param_anar_pause = old_pause & ~SNET_NOTUSR;

		if (!snet_nd_getset(wq, snetp->g_nd, mp)) {
			param_autoneg = old_autoneg;
			param_anar_100T4 = old_100T4;
			param_anar_100fdx = old_100fdx;
			param_anar_100hdx = old_100hdx;
			param_anar_10fdx = old_10fdx;
			param_anar_10hdx = old_10hdx;
			param_anar_asm_dir = old_asm_dir;
			param_anar_pause = old_pause;
			miocnak(wq, mp, 0, EINVAL);
			return;
		}
		param_autoneg = old_autoneg;
		param_anar_100T4 = old_100T4;
		param_anar_100fdx = old_100fdx;
		param_anar_100hdx = old_100hdx;
		param_anar_10fdx = old_10fdx;
		param_anar_10hdx = old_10hdx;
		param_anar_asm_dir = old_asm_dir;
		param_anar_pause = old_pause;

		qreply(wq, mp);
		break;

	case SNET_ND_SET:
		old_ipg0 = param_ipg0;
		old_intr_blank_time = param_intr_blank_time;
		old_intr_blank_packets = param_intr_blank_packets;
		old_lance_mode = param_lance_mode;
		old_ipg1 = param_ipg1;
		old_ipg2 = param_ipg2;
		old_use_int_xcvr = param_use_intphy;
		old_autoneg = param_autoneg;
		old_100T4 =	param_anar_100T4;
		old_100fdx =	param_anar_100fdx;
		old_100hdx =	param_anar_100hdx;
		old_10fdx =	param_anar_10fdx;
		old_10hdx =	param_anar_10hdx;
		param_autoneg = 0xff;
		old_asm_dir = param_anar_asm_dir;
		param_anar_asm_dir = 0xff;
		old_pause = param_anar_pause;
		param_anar_pause = 0xff;
		old_select_link = param_select_link;
		old_default_link = param_default_link;

		if (!snet_nd_getset(wq, snetp->g_nd, mp)) {
			param_autoneg = old_autoneg;
			miocnak(wq, mp, 0, EINVAL);
			return;
		}

		qreply(wq, mp);

		if (param_autoneg != 0xff) {
			SNET_DEBUG_MSG2(snetp, NDD_MSG,
			    "ndd_ioctl: new param_autoneg %d", param_autoneg);
			param_linkup = 0;
			snetp->stats.link_up = LINK_STATE_DOWN;
			snetp->stats.link_duplex = LINK_DUPLEX_UNKNOWN;
			(void) snet_init(snetp);
		} else {
			param_autoneg = old_autoneg;
			if ((old_use_int_xcvr != param_use_intphy) ||
			    (old_default_link != param_default_link) ||
			    (old_select_link != param_select_link)) {
				param_linkup = 0;
				snetp->stats.link_up = LINK_STATE_DOWN;
				snetp->stats.link_duplex = LINK_DUPLEX_UNKNOWN;
				(void) snet_init(snetp);
			} else if ((old_ipg1 != param_ipg1) ||
			    (old_ipg2 != param_ipg2) ||
			    (old_ipg0 != param_ipg0) ||
			    (old_intr_blank_time != param_intr_blank_time) ||
			    (old_intr_blank_packets !=
			    param_intr_blank_packets) ||
			    (old_lance_mode != param_lance_mode)) {
				param_linkup = 0;
				snetp->stats.link_up = LINK_STATE_DOWN;
				snetp->stats.link_duplex = LINK_DUPLEX_UNKNOWN;
				(void) snet_init(snetp);
			}
		}
		break;
	}
}


static int
snet_stat_kstat_update(kstat_t *ksp, int rw)
{
	struct snet *snetp;
	struct snetkstat *snetkp;
	struct stats *esp;
	boolean_t macupdate = B_FALSE;

	snetp = (struct snet *)ksp->ks_private;
	snetkp = (struct snetkstat *)ksp->ks_data;

	if (rw != KSTAT_READ)
		return (EACCES);
	/*
	 * Update all the stats by reading all the counter registers.
	 * Counter register stats are not updated till they overflow
	 * and interrupt.
	 */

	mutex_enter(&snetp->xmitlock);
	if ((snetp->flags & SNET_RUNNING) && (snetp->flags & SNET_TXINIT)) {
		macupdate = 1;
	}
	mutex_exit(&snetp->xmitlock);
	if (macupdate)
		mac_tx_update(snetp->mh);

	snet_savecntrs(snetp);

	esp = &snetp->stats;

	snetkp->snetk_txmac_maxpkt_err.value.ul = esp->txmac_maxpkt_err;
	snetkp->snetk_defer_timer_exp.value.ul = esp->defer_timer_exp;
	snetkp->snetk_peak_attempt_cnt.value.ul = esp->peak_attempt_cnt;
	snetkp->snetk_tx_hang.value.ul	= esp->tx_hang;

	snetkp->snetk_no_free_rx_desc.value.ul	= esp->no_free_rx_desc;

	snetkp->snetk_rx_hang.value.ul		= esp->rx_hang;
	snetkp->snetk_rx_length_err.value.ul	= esp->rx_length_err;
	snetkp->snetk_rx_code_viol_err.value.ul	= esp->rx_code_viol_err;
	snetkp->snetk_pause_rxcount.value.ul	= esp->pause_rxcount;
	snetkp->snetk_pause_oncount.value.ul	= esp->pause_oncount;
	snetkp->snetk_pause_offcount.value.ul	= esp->pause_offcount;
	snetkp->snetk_pause_time_count.value.ul	= esp->pause_time_count;

	snetkp->snetk_inits.value.ul		= esp->inits;
	snetkp->snetk_jab.value.ul		= esp->jab;
	snetkp->snetk_notmds.value.ul		= esp->notmds;
	snetkp->snetk_allocbfail.value.ul		= esp->allocbfail;
	snetkp->snetk_drop.value.ul		= esp->drop;
	snetkp->snetk_rx_bad_pkts.value.ul	= esp->rx_bad_pkts;
	snetkp->snetk_rx_inits.value.ul		= esp->rx_inits;
	snetkp->snetk_tx_inits.value.ul		= esp->tx_inits;
	snetkp->snetk_rxtag_err.value.ul		= esp->rxtag_err;
	snetkp->snetk_parity_error.value.ul	= esp->parity_error;
	snetkp->snetk_pci_error_int.value.ul	= esp->pci_error_int;
	snetkp->snetk_unknown_fatal.value.ul	= esp->unknown_fatal;
	snetkp->snetk_pci_data_parity_err.value.ul = esp->pci_data_parity_err;
	snetkp->snetk_pci_signal_target_abort.value.ul =
	    esp->pci_signal_target_abort;
	snetkp->snetk_pci_rcvd_target_abort.value.ul =
	    esp->pci_rcvd_target_abort;
	snetkp->snetk_pci_rcvd_master_abort.value.ul =
	    esp->pci_rcvd_master_abort;
	snetkp->snetk_pci_signal_system_err.value.ul =
	    esp->pci_signal_system_err;
	snetkp->snetk_pci_det_parity_err.value.ul = esp->pci_det_parity_err;

	snetkp->snetk_pmcap.value.ul = esp->pmcap;

	return (0);
}

static void
snet_statinit(struct snet *snetp)
{
	struct	kstat	*ksp;
	struct	snetkstat	*snetkp;

	if ((ksp = kstat_create("snet", snetp->instance, "driver_info", "net",
	    KSTAT_TYPE_NAMED,
	    sizeof (struct snetkstat) / sizeof (kstat_named_t), 0)) == NULL) {
		SNET_FAULT_MSG1(snetp, SEVERITY_LOW, SNET_VERB_MSG,
		    kstat_create_fail_msg);
		return;
	}

	snetp->ksp = ksp;
	snetkp = (struct snetkstat *)(ksp->ks_data);
	/*
	 * MIB II kstat variables
	 */

	kstat_named_init(&snetkp->snetk_inits, "inits", KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_txmac_maxpkt_err,	"txmac_maxpkt_err",
	    KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_defer_timer_exp, "defer_timer_exp",
	    KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_peak_attempt_cnt,	"peak_attempt_cnt",
	    KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_tx_hang, "tx_hang", KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_no_free_rx_desc, "no_free_rx_desc",
	    KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_rx_hang, "rx_hang", KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_rx_length_err, "rx_length_err",
	    KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_rx_code_viol_err,	"rx_code_viol_err",
	    KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_pause_rxcount, "pause_rcv_cnt",
	    KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_pause_oncount, "pause_on_cnt",
	    KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_pause_offcount, "pause_off_cnt",
	    KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_pause_time_count,	"pause_time_cnt",
	    KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_jab, "jabber", KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_notmds, "no_tmds", KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_allocbfail, "allocbfail",
	    KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_drop, "drop", KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_rx_bad_pkts, "bad_pkts",
	    KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_rx_inits, "rx_inits", KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_tx_inits, "tx_inits", KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_rxtag_err, "rxtag_error",
	    KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_parity_error, "parity_error",
	    KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_pci_error_int, "pci_error_interrupt",
	    KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_unknown_fatal, "unknown_fatal",
	    KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_pci_data_parity_err,
	    "pci_data_parity_err", KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_pci_signal_target_abort,
	    "pci_signal_target_abort", KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_pci_rcvd_target_abort,
	    "pci_rcvd_target_abort", KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_pci_rcvd_master_abort,
	    "pci_rcvd_master_abort", KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_pci_signal_system_err,
	    "pci_signal_system_err", KSTAT_DATA_ULONG);
	kstat_named_init(&snetkp->snetk_pci_det_parity_err,
	    "pci_det_parity_err", KSTAT_DATA_ULONG);

	kstat_named_init(&snetkp->snetk_pmcap, "pmcap", KSTAT_DATA_ULONG);


	ksp->ks_update = snet_stat_kstat_update;
	ksp->ks_private = (void *) snetp;
	kstat_install(ksp);
}


/* <<<<<<<<<<<<<<<<<<<<<<< NDD SUPPORT FUNCTIONS	>>>>>>>>>>>>>>>>>>> */
/*
 * ndd support functions to get/set parameters
 */
/* Free the Named Dispatch Table by calling snet_nd_free */
static void
snet_param_cleanup(struct snet *snetp)
{
	if (snetp->g_nd)
		(void) snet_nd_free(&snetp->g_nd);
}

/*
 * Extracts the value from the snet parameter array and prints the
 * parameter value. cp points to the required parameter.
 */
/* ARGSUSED */
static int
snet_param_get(queue_t *q, mblk_t *mp, caddr_t cp)
{
	param_t		*snetpa = (void *)cp;
	int		param_len = 1;
	uint32_t	param_val;
	mblk_t		*nmp;
	int		ok;

	param_val = snetpa->param_val;
	/*
	 * Calculate space required in mblk.
	 * Remember to include NULL terminator.
	 */
	do {
		param_len++;
		param_val /= 10;
	} while (param_val);

	ok = snet_mk_mblk_tail_space(mp, &nmp, param_len);
	if (ok == 0) {
		(void) sprintf((char *)nmp->b_wptr, "%d", snetpa->param_val);
		nmp->b_wptr += param_len;
	}

	return (ok);
}

/*
 * Check if there is space for p_val at the end if mblk.
 * If not, allocate new 1k mblk.
 */
static int
snet_mk_mblk_tail_space(mblk_t *mp, mblk_t **nmp, size_t sz)
{
	mblk_t *tmp = mp;

	while (tmp->b_cont)
		tmp = tmp->b_cont;

	/*LINTED E_BAD_PTR_CAST_ALIGN*/
	if (MBLKTAIL(tmp) < sz) {
		if ((tmp->b_cont = allocb(1024, BPRI_HI)) == NULL)
			return (ENOMEM);
		tmp = tmp->b_cont;
	}
	*nmp = tmp;
	return (0);
}

/*
 * Register each element of the parameter array with the
 * named dispatch handler. Each element is loaded using
 * snet_nd_load()
 */
static int
snet_param_register(struct snet *snetp, param_t *snetpa, int cnt)
{
	/* cnt gives the count of the number of */
	/* elements present in the parameter array */

	int i;

	for (i = 0; i < cnt; i++, snetpa++) {
		pfi_t	setter = (pfi_t)snet_param_set;

		switch (snetpa->param_name[0]) {
		case '+':	/* read-write */
			setter = (pfi_t)snet_param_set;
			break;

		case '-':	/* read-only */
			setter = NULL;
			break;

		case '!':	/* read-only, not displayed */
		case '%':	/* read-write, not displayed */
			continue;
		}

		if (!snet_nd_load(&snetp->g_nd, snetpa->param_name + 1,
		    (pfi_t)snet_param_get, setter, (caddr_t)snetpa)) {
			(void) snet_nd_free(&snetp->g_nd);
			return (B_FALSE);
		}
	}

	return (B_TRUE);
}

/*
 * Sets the snet parameter to the value in the param_register using
 * snet_nd_load().
 */
/* ARGSUSED */
static int
snet_param_set(queue_t *q, mblk_t *mp, char *value, caddr_t cp)
{
	char *end;
	long new_value;
	param_t	*snetpa = (void *)cp;

	if (ddi_strtol(value, &end, 10, &new_value) != 0)
		return (EINVAL);
	if (end == value || new_value < snetpa->param_min ||
	    new_value > snetpa->param_max) {
			return (EINVAL);
	}
	snetpa->param_val = (uint32_t)new_value;
	return (0);

}

/* Free the table pointed to by 'ndp' */
static void
snet_nd_free(caddr_t *nd_pparam)
{
	ND	*nd;

	if ((nd = (void *)(*nd_pparam)) != NULL) {
		if (nd->nd_tbl)
			kmem_free(nd->nd_tbl, nd->nd_size);
		kmem_free(nd, sizeof (ND));
		*nd_pparam = NULL;
	}
}

static int
snet_nd_getset(queue_t *q, caddr_t nd_param, MBLKP mp)
{
	int	err;
	IOCP	iocp;
	MBLKP	mp1;
	ND	*nd;
	NDE	*nde;
	char	*valp;
	size_t	avail;
	mblk_t	*nmp;

	if (!nd_param)
		return (B_FALSE);

	nd = (void *)nd_param;
	iocp = (void *)mp->b_rptr;
	if ((iocp->ioc_count == 0) || !(mp1 = mp->b_cont)) {
		mp->b_datap->db_type = M_IOCACK;
		iocp->ioc_count = 0;
		iocp->ioc_error = EINVAL;
		return (B_TRUE);
	}
	/*
	 * NOTE - logic throughout nd_xxx assumes single data block for ioctl.
	 *	However, existing code sends in some big buffers.
	 */
	avail = iocp->ioc_count;
	if (mp1->b_cont) {
		freemsg(mp1->b_cont);
		mp1->b_cont = NULL;
	}

	mp1->b_datap->db_lim[-1] = '\0';	/* Force null termination */
	valp = (char *)mp1->b_rptr;

	for (nde = nd->nd_tbl; /* */; nde++) {
		if (!nde->nde_name)
			return (B_FALSE);
		if (strcmp(nde->nde_name, valp) == 0)
			break;
	}
	err = EINVAL;

	while (*valp++)
		;

	if (!*valp || valp >= (char *)mp1->b_wptr)
		valp = NULL;

	switch (iocp->ioc_cmd) {
	case ND_GET:
	/*
	 * (XXX) hack: "*valp" is size of user buffer for copyout. If result
	 * of action routine is too big, free excess and return ioc_rval as buf
	 * size needed.  Return as many mblocks as will fit, free the rest.  For
	 * backward compatibility, assume size of orig ioctl buffer if "*valp"
	 * bad or not given.
	 */
		if (valp)
			(void) ddi_strtol(valp, NULL, 10, (long *)&avail);
		/* We overwrite the name/value with the reply data */
		{
			mblk_t *mp2 = mp1;

			while (mp2) {
				mp2->b_wptr = mp2->b_rptr;
				mp2 = mp2->b_cont;
			}
		}
		err = (*nde->nde_get_pfi)(q, mp1, nde->nde_data, iocp->ioc_cr);
		if (!err) {
			size_t	size_out;
			ssize_t	excess;

			iocp->ioc_rval = 0;

			/* Tack on the null */
			err = snet_mk_mblk_tail_space(mp1, &nmp, 1);
			if (!err) {
				*nmp->b_wptr++ = '\0';
				size_out = msgdsize(mp1);
				excess = size_out - avail;
				if (excess > 0) {
					iocp->ioc_rval = (unsigned)size_out;
					size_out -= excess;
					(void) adjmsg(mp1, -(excess + 1));
					err = snet_mk_mblk_tail_space(mp1,
					    &nmp, 1);
					if (!err)
						*nmp->b_wptr++ = '\0';
					else
						size_out = 0;
				}

			} else
				size_out = 0;

			iocp->ioc_count = size_out;
		}
		break;

	case ND_SET:
		if (valp) {
			err = (*nde->nde_set_pfi)(q, mp1, valp,
			    nde->nde_data, iocp->ioc_cr);
			iocp->ioc_count = 0;
			freemsg(mp1);
			mp->b_cont = NULL;
		}
		break;
	}

	iocp->ioc_error = err;
	mp->b_datap->db_type = M_IOCACK;
	return (B_TRUE);
}

/*
 * Load 'name' into the named dispatch table pointed to by 'ndp'.
 * 'ndp' should be the address of a char pointer cell.  If the table
 * does not exist (*ndp == 0), a new table is allocated and 'ndp'
 * is stuffed.  If there is not enough space in the table for a new
 * entry, more space is allocated.
 */
static boolean_t
snet_nd_load(caddr_t *nd_pparam, char *name, pfi_t get_pfi,
    pfi_t set_pfi, caddr_t data)
{
	ND	*nd;
	NDE	*nde;

	if (!nd_pparam)
		return (B_FALSE);

	if ((nd = (void *)(*nd_pparam)) == NULL) {
		if ((nd = (ND *)kmem_zalloc(sizeof (ND), KM_NOSLEEP))
		    == NULL)
			return (B_FALSE);
		*nd_pparam = (caddr_t)nd;
	}
	if (nd->nd_tbl) {
		for (nde = nd->nd_tbl; nde->nde_name; nde++) {
			if (strcmp(name, nde->nde_name) == 0)
				goto fill_it;
		}
	}
	if (nd->nd_free_count <= 1) {
		if ((nde = (NDE *)kmem_zalloc(nd->nd_size +
		    NDE_ALLOC_SIZE, KM_NOSLEEP)) == NULL)
			return (B_FALSE);

		nd->nd_free_count += NDE_ALLOC_COUNT;
		if (nd->nd_tbl) {
			bcopy((char *)nd->nd_tbl, (char *)nde, nd->nd_size);
			kmem_free((char *)nd->nd_tbl, nd->nd_size);
		} else {
			nd->nd_free_count--;
			nde->nde_name = "?";
			nde->nde_get_pfi = nd_get_names;
			nde->nde_set_pfi = nd_set_default;
		}
		nde->nde_data = (caddr_t)nd;
		nd->nd_tbl = nde;
		nd->nd_size += NDE_ALLOC_SIZE;
	}
	for (nde = nd->nd_tbl; nde->nde_name; nde++)
		;
	nd->nd_free_count--;
fill_it:
	nde->nde_name = name;
	nde->nde_get_pfi = get_pfi ? get_pfi : nd_get_default;
	nde->nde_set_pfi = set_pfi ? set_pfi : nd_set_default;
	nde->nde_data = data;
	return (B_TRUE);
}

/*
 * Hardening Functions
 * New Section
 */
#ifdef  DEBUG
/*PRINTFLIKE5*/
static void
snet_debug_msg(const char *file, int line, struct snet *snetp,
	debug_msg_t type, const char *fmt, ...)
{
	char	msg_buffer[255];
	va_list ap;

	static kmutex_t snetdebuglock;
	static int snet_debug_init = 0;

	if (!snet_debug_level)
		return;
	if (snet_debug_init == 0) {
		/*
		 * Block I/O interrupts
		 */
		mutex_init(&snetdebuglock, NULL, MUTEX_DRIVER, (void *)SPL3);
		snet_debug_init = 1;
	}

	mutex_enter(&snetdebuglock);
	va_start(ap, fmt);
	(void) vsprintf(msg_buffer, fmt, ap);
	va_end(ap);

	if (snet_msg_out & SNET_CON_MSG) {
		if (((type <= snet_debug_level) && snet_debug_all) ||
		    ((type == snet_debug_level) && !snet_debug_all)) {
			if (snetp)
				cmn_err(CE_CONT, "D: %s %s%d:(%s%d) %s\n",
				    debug_msg_string[type], file, line,
				    ddi_driver_name(snetp->dip), snetp->instance,
				    msg_buffer);
			else
				cmn_err(CE_CONT, "D: %s %s(%d): %s\n",
				    debug_msg_string[type], file,
				    line, msg_buffer);
		}
	}
	mutex_exit(&snetdebuglock);
}
#endif


/*PRINTFLIKE4*/
static void
snet_fault_msg(struct snet *snetp, uint_t severity, msg_t type,
	const char *fmt, ...)
{
	char	msg_buffer[255];
	va_list	ap;

	va_start(ap, fmt);
	(void) vsprintf(msg_buffer, fmt, ap);
	va_end(ap);

	if (snetp == NULL) {
		cmn_err(CE_NOTE, "snet : %s", msg_buffer);
		return;
	}

	if (severity == SEVERITY_HIGH) {
		cmn_err(CE_WARN, "%s%d : %s", ddi_driver_name(snetp->dip),
		    snetp->instance, msg_buffer);
	} else switch (type) {
	case SNET_VERB_MSG:
		cmn_err(CE_CONT, "?%s%d : %s", ddi_driver_name(snetp->dip),
		    snetp->instance, msg_buffer);
		break;
	case SNET_LOG_MSG:
		cmn_err(CE_NOTE, "^%s%d : %s", ddi_driver_name(snetp->dip),
		    snetp->instance, msg_buffer);
		break;
	case SNET_BUF_MSG:
		cmn_err(CE_NOTE, "!%s%d : %s", ddi_driver_name(snetp->dip),
		    snetp->instance, msg_buffer);
		break;
	case SNET_CON_MSG:
		cmn_err(CE_CONT, "%s%d : %s", ddi_driver_name(snetp->dip),
		    snetp->instance, msg_buffer);
	default:
		break;
	}
}




/*
 * Functions accessing hypervisor snet interface
 */


static void
set_mac_address(struct snet *snetp)
{
    uint8_t   *ptr = (uint8_t *) &snetp->send_buffer[1];
    int count = 0;


    snetp->send_buffer[0] = (SNET_CMD_MAC << SNET_HDR_CMD_SHIFT) | (6ULL << SNET_HDR_SIZE_SHIFT);
    count += SNET_HDR_SIZE;
    for (int i=0 ;i<6; i++) {
        ptr[i] = snetp->ouraddr[i];
        count++;
    }

    if (hv_snet_write((void *) snetp->send_buffer_pa, count) < 0) {
	SNET_FAULT_MSG1(snetp, SEVERITY_NONE, SNET_VERB_MSG, "hv_snet_write failed in set_mac_address");
    }

    return;
}

static void
set_promisc(struct snet *snetp)
{
    return;
}

static void
set_loopback(struct snet *snetp)
{
    return;
}

static mblk_t *
hv_read_pkt(struct snet *snetp)
{
    mblk_t  *mp = NULL;
    uchar_t *dp;

    uint_t   pkt_size;
    int result;

    if (hv_snet_read((void *) snetp->recv_buffer_pa, SNET_HDR_SIZE) < 0) {
	SNET_FAULT_MSG1(snetp, SEVERITY_NONE, SNET_VERB_MSG, "hv_snet_read failed in hv_read_pkt");
	return mp;
    }
    pkt_size = snetp->recv_buffer[0] >> SNET_HDR_SIZE_SHIFT;

    if (pkt_size) {
	hv_snet_read((void *) snetp->recv_buffer_pa, pkt_size);
	mp = allocb(SNET_HEADROOM + pkt_size, 0);
	mp->b_rptr = dp = mp->b_rptr + SNET_HEADROOM;
	bcopy(snetp->recv_buffer, dp, pkt_size);
	mp->b_wptr = dp + pkt_size;
    }

    return mp;
}

static void
hv_snet_start(struct snet *snetp)
{
    snetp->send_buffer[0] = SNET_CMD_START;
    if (hv_snet_write((void *) snetp->send_buffer_pa, SNET_HDR_SIZE) < 0) {
	SNET_FAULT_MSG1(snetp, SEVERITY_NONE, SNET_VERB_MSG, "hv_snet_write failed in hv_snet_start");
    }
}

static void
hv_snet_stop(struct snet *snetp)
{
    snetp->send_buffer[0] = SNET_CMD_STOP;
    if (hv_snet_write((void *) snetp->send_buffer_pa, SNET_HDR_SIZE) < 0) {
	SNET_FAULT_MSG1(snetp, SEVERITY_NONE, SNET_VERB_MSG, "hv_snet_write failed in hv_snet_stop");
    }
}

static void
enable_txmac(struct snet *snetp)
{
    return;
}

static void
enable_mac(struct snet *snetp)
{
    hv_snet_start(snetp);
}

