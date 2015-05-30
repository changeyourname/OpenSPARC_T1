#if (! defined T1_FPGA_XEMAC) && (! defined T1_FPGA_XEMACLITE)

#include <stdio.h>
#include <stdlib.h>

#include "xparameters.h"
#include "xstatus.h"
#include "xlltemac.h"
#include "xllfifo.h"
#include "xlldma.h"
#include "xintc.h"
#include "mb_interface.h"

#include "mbfw_types.h"
#include "mbfw_xlltemac_intr.h"



static int xlltemac_start(struct snet *snetp, void *eth_instance);
static int xlltemac_stop(struct snet *snetp, void *eth_instance);
static int xlltemac_set_mac_addr(struct snet *snetp, void *eth_instance, uint8_t mac_addr[]);
static int xlltemac_tx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size);
static int xlltemac_rx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t *frame_size_ptr);
static int xlltemac_rx_tohw(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size);



struct t1_lltemac {
    XLlTemac        xlltemac;
    XLlDma          xlldma;
    Xuint16         device_id;
    XIntc          *xintc_ptr;
    Xuint16         intr_id;
    Xuint16         dma_rx_intr_id;
    Xuint16         dma_tx_intr_id;
    XLlDma_BdRing  *tx_ring;
    XLlDma_BdRing  *rx_ring;
    volatile int    tx_done;
    int             err_count;
    void            (*snet_send_handler)(void *arg);
    void            (*snet_recv_handler)(void *arg);
    struct snet    *snetp;
};


static struct t1_lltemac   t1_lltemac;



#define TX_BD_CNT        (SNET_TX_BUFS_COUNT * 2)
#define RX_BD_CNT        SNET_RX_BUFS_COUNT

#define BD_ALIGNMENT     XLLDMA_BD_MINIMUM_ALIGNMENT


#define TX_BD_SPACE_BYTES  XLlDma_mBdRingMemCalc(BD_ALIGNMENT, TX_BD_CNT)
#define RX_BD_SPACE_BYTES  XLlDma_mBdRingMemCalc(BD_ALIGNMENT, RX_BD_CNT)


static char tx_bd_space[TX_BD_SPACE_BYTES] __attribute__ ((aligned(BD_ALIGNMENT)));
static char rx_bd_space[RX_BD_SPACE_BYTES] __attribute__ ((aligned(BD_ALIGNMENT)));



#ifdef T1_FPGA_BEE3
#define XLLTEMAC_OPERATING_SPEED   1000
#else
#define XLLTEMAC_OPERATING_SPEED   100
#endif


static void
xlltemac_error(char *str)
{
    mbfw_printf("MBFW_ERROR: %s \r\n", str);
}

static void
xlltemac_tx_intr_handler(struct t1_lltemac *tep)
{
    Xuint32  irq_status;

    irq_status = XLlDma_mBdRingGetIrq(tep->tx_ring);

    XLlDma_mBdRingAckIrq(tep->tx_ring, irq_status);

    if (irq_status & XLLDMA_IRQ_ALL_ERR_MASK) {
	tep->err_count++;
	mbfw_printf("MBFW_ERROR: xlltemac_tx_intr_handler(): DMA error occurred with irq_status 0x%x \r\n", irq_status);
	XLlDma_Reset(&tep->xlldma);
	return;
    }

    if ((irq_status & (XLLDMA_IRQ_DELAY_MASK | XLLDMA_IRQ_COALESCE_MASK))) {
	XLlDma_mBdRingIntDisable(tep->tx_ring, XLLDMA_CR_IRQ_ALL_EN_MASK);
	tep->tx_done = 1;
    }

    return;
}

static void
xlltemac_rx_intr_handler(struct t1_lltemac *tep)
{
    Xuint32  irq_status;

    irq_status = XLlDma_mBdRingGetIrq(tep->rx_ring);

    XLlDma_mBdRingAckIrq(tep->rx_ring, irq_status);

    if ((irq_status & XLLDMA_IRQ_ALL_ERR_MASK)) {
	tep->err_count++;
	mbfw_printf("MBFW_ERROR: xlltemac_rx_intr_handler(): DMA error occurred with irq_status 0x%x \r\n", irq_status);
	XLlDma_Reset(&tep->xlldma);
	return;
    }

    if ((irq_status & (XLLDMA_IRQ_DELAY_MASK | XLLDMA_IRQ_COALESCE_MASK))) {
	XLlDma_mBdRingIntDisable(tep->rx_ring, XLLDMA_CR_IRQ_ALL_EN_MASK);
	(*tep->snet_recv_handler)(tep->snetp);
    }

    return;
}



static void
xlltemac_error_handler(struct t1_lltemac *tep)
{
    Xuint32  pending = XLlTemac_IntPending(&tep->xlltemac);
    static int err_warn_count = 0;

    if (pending & XTE_INT_RXRJECT_MASK) {
	err_warn_count++;
	if ((err_warn_count < 10) || ((err_warn_count % 100) == 0)) {
	    mbfw_printf("MBFW_WARN: xlltemac_error_handler(): Rx packet rejected. warn_count %d \r\n", err_warn_count);
	}
    }

    if (pending & XTE_INT_RXFIFOOVR_MASK) {
	xlltemac_error("xlltemac_error_handler(): Rx fifo overrun");
    }

    XLlTemac_IntClear(&tep->xlltemac, pending);
    tep->err_count++;

    return;
}

static int
xlltemac_setup_intr_system(struct t1_lltemac *tep)
{
    int status;

    status = XIntc_Connect(tep->xintc_ptr, 
			   tep->intr_id, 
			   (XInterruptHandler) xlltemac_error_handler, 
			   &tep->xlltemac);

    status |= XIntc_Connect(tep->xintc_ptr, 
			    tep->dma_tx_intr_id,
			    (XInterruptHandler) xlltemac_tx_intr_handler,
			    tep);

    status |= XIntc_Connect(tep->xintc_ptr,
			    tep->dma_rx_intr_id,
			    (XInterruptHandler) xlltemac_rx_intr_handler,
			    tep);

    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: xlltemac_setup_intr_system(): unable to connect ISR to the interrupt controller. status 0x%x \r\n", status);
	return -1;
    }

    XIntc_Enable(tep->xintc_ptr, tep->intr_id);
    XIntc_Enable(tep->xintc_ptr, tep->dma_tx_intr_id);
    XIntc_Enable(tep->xintc_ptr, tep->dma_rx_intr_id);

    return 0;
}

int
eth_init(struct snet *snetp, XIntc *xintc_instance, struct eth_init_data *init_data)
{
    int     status;
    int     dma_mode;
    uint_t  rdy;

    struct mac_callbacks  mac_callbacks;

    struct t1_lltemac  *tep = &t1_lltemac;

    XLlTemac_Config  *mac_cfg_ptr;
    XLlDma_Bd         bd_template;


    tep->xintc_ptr          = xintc_instance;
    tep->device_id          = XPAR_LLTEMAC_0_DEVICE_ID;
    tep->intr_id            = XPAR_INTC_0_LLTEMAC_0_VEC_ID;
#ifdef T1_FPGA_BEE3
    tep->dma_rx_intr_id     = XPAR_INTC_0_BEE3_MPMC_0_SDMA3_RX_INTOUT_VEC_ID; 
    tep->dma_tx_intr_id     = XPAR_INTC_0_BEE3_MPMC_0_SDMA3_TX_INTOUT_VEC_ID;
#else
    tep->dma_rx_intr_id     = XPAR_INTC_0_MPMC_0_SDMA3_RX_INTOUT_VEC_ID; 
    tep->dma_tx_intr_id     = XPAR_INTC_0_MPMC_0_SDMA3_TX_INTOUT_VEC_ID;
#endif

    tep->snet_send_handler  = init_data->tx_handler;
    tep->snet_recv_handler  = init_data->rx_handler;
    tep->snetp              = snetp;



    mac_cfg_ptr = XLlTemac_LookupConfig(tep->device_id);
    status = XLlTemac_CfgInitialize(&tep->xlltemac, mac_cfg_ptr, mac_cfg_ptr->BaseAddress);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: eth_init(): XLlTemac_CfgInitialize() failed with status 0x%x \r\n", status);
	return -1;
    }


    XLlDma_Initialize(&tep->xlldma, tep->xlltemac.Config.LLDevBaseAddress);

    dma_mode = XLlTemac_IsDma(&tep->xlltemac);
    if (! dma_mode) {
	xlltemac_error("eth_init(): Device HW not configured for SGDMA mode. \r\n");
	return -1;
    }

    tep->rx_ring = &XLlDma_mGetRxRing(&tep->xlldma);
    tep->tx_ring = &XLlDma_mGetTxRing(&tep->xlldma);


    XLlDma_mBdClear(&bd_template);

    status = XLlDma_BdRingCreate(tep->tx_ring, (Xuint32) &tx_bd_space, (Xuint32) &tx_bd_space, BD_ALIGNMENT, TX_BD_CNT);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: eth_init(): XLlDma_BdRingCreate() for tx, failed with status 0x%x \r\n", status);
	return -1;
    }

    status = XLlDma_BdRingClone(tep->tx_ring, &bd_template);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: eth_init(): XLlDma_BdRingClone() for tx, failed with status 0x%x \r\n", status);
	return -1;
    }


    status = XLlDma_BdRingCreate(tep->rx_ring, (Xuint32) &rx_bd_space, (Xuint32) &rx_bd_space, BD_ALIGNMENT, RX_BD_CNT);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: eth_init(): XLlDma_BdRingCreate() for rx, failed with status 0x%x \r\n", status);
	return -1;
    }
    status = XLlDma_BdRingClone(tep->rx_ring, &bd_template);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: eth_init(): XLlDma_BdRingClone() for rx, failed with status 0x%x \r\n", status);
	return -1;
    }

    do {
	rdy = XLlTemac_ReadReg(tep->xlltemac.Config.BaseAddress, XTE_RDY_OFFSET);
    } while ((rdy & XTE_RDY_HARD_ACS_RDY_MASK) == 0);

    mbfw_printf("MBFW_INFO: Setting Temac operating speed to %d Mbit/sec \r\n", XLLTEMAC_OPERATING_SPEED);
    XLlTemac_SetOperatingSpeed(&tep->xlltemac, XLLTEMAC_OPERATING_SPEED);

    status = xlltemac_setup_intr_system(tep);
    if (status < 0) {
	return -1;
    }

    mac_callbacks.eth_start         = xlltemac_start;
    mac_callbacks.eth_stop          = xlltemac_stop;
    mac_callbacks.eth_set_mac_addr  = xlltemac_set_mac_addr;
    mac_callbacks.eth_tx            = xlltemac_tx;
    mac_callbacks.eth_rx            = xlltemac_rx;
    mac_callbacks.eth_rx_tohw       = xlltemac_rx_tohw;

    mbfw_snet_register(snetp, tep, &mac_callbacks);

    return 0;
}


static int
xlltemac_start(struct snet *snetp, void *eth_instance)
{
    struct t1_lltemac *tep = (struct t1_lltemac *) eth_instance;
    int status;


    XLlTemac_Start(&tep->xlltemac);
    XLlTemac_IntEnable(&tep->xlltemac, XTE_INT_RECV_ERROR_MASK);

    XLlDma_mBdRingIntEnable(tep->tx_ring, XLLDMA_CR_IRQ_ALL_EN_MASK);
    status = XLlDma_BdRingStart(tep->tx_ring);
    if (status != XST_SUCCESS) {
	return -1;
    }

    XLlDma_mBdRingIntEnable(tep->rx_ring, XLLDMA_CR_IRQ_ALL_EN_MASK);
    status = XLlDma_BdRingStart(tep->rx_ring);
    if (status != XST_SUCCESS) {
	return -1;
    }

    return 0;
}


static int
xlltemac_stop(struct snet *snetp, void *eth_instance)
{
    struct t1_lltemac *tep = (struct t1_lltemac *) eth_instance;

    XLlTemac_Stop(&tep->xlltemac);

    return 0;
}

static int
xlltemac_set_mac_addr(struct snet *snetp, void *eth_instance, uint8_t mac_addr[])
{
    struct t1_lltemac *tep = (struct t1_lltemac *) eth_instance;

    XLlTemac_SetMacAddress(&tep->xlltemac, mac_addr);

    return 0;
}


static int
xlltemac_tx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size)
{
    struct t1_lltemac *tep = (struct t1_lltemac *) eth_instance;
    XLlDma_Bd *bd1_ptr;
    XLlDma_Bd *bd2_ptr;
    int status;

    XCACHE_FLUSH_DCACHE_RANGE(frame, frame_size);

    tep->tx_done = 0;

    status = XLlDma_BdRingAlloc(tep->tx_ring, 2, &bd1_ptr);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: xlltemac_tx(): XLlDma_BdRingAlloc() failed with status 0x%x \r\n", status);
	return -1;
    }


    XLlDma_mBdSetBufAddr(bd1_ptr, frame);
    XLlDma_mBdSetLength(bd1_ptr, 32);
    XLlDma_mBdSetStsCtrl(bd1_ptr, XLLDMA_BD_STSCTRL_SOP_MASK);

    bd2_ptr = XLlDma_mBdRingNext(tep->tx_ring, bd1_ptr);
    XLlDma_mBdSetBufAddr(bd2_ptr, (Xuint32) (frame) + 32);
    XLlDma_mBdSetLength(bd2_ptr, frame_size - 32);
    XLlDma_mBdSetStsCtrl(bd2_ptr, XLLDMA_BD_STSCTRL_EOP_MASK);

    status = XLlDma_BdRingToHw(tep->tx_ring, 2, bd1_ptr);
    if (status != XST_SUCCESS) {
	XLlDma_BdRingUnAlloc(tep->tx_ring, 2, bd1_ptr);
	mbfw_printf("MBFW_ERROR: xlltemac_tx(): XLlDma_BdRingToHw() failed with status 0x%x \r\n", status);
	return -1;
    }

    /*
     * For transmitting small packets, the wait is ~ 30 iterations through the while loop and
     * ~ 130 iterations for large packets.
     */

    while (!tep->tx_done);

    if (XLlDma_BdRingFromHw(tep->tx_ring, 2, &bd1_ptr) == 0) {
	xlltemac_error("xlltemac_tx(): TxBDs were not ready for post processing");
	return -1;
    }

    status = XLlDma_BdRingFree(tep->tx_ring, 2, bd1_ptr);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: xlltemac_tx(): XLlDma_BdRingFree() failed with status 0x%x \r\n", status);
	return -1;
    }

    XLlDma_mBdRingIntEnable(tep->tx_ring, XLLDMA_CR_IRQ_ALL_EN_MASK);

    (*tep->snet_send_handler)(tep->snetp);

    return 0;
}

static int
xlltemac_rx(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t *frame_size_ptr)
{
    struct t1_lltemac *tep = (struct t1_lltemac *) eth_instance;
    static int rx_warn_count = 0;


    XLlDma_Bd *bd1_ptr;
    int        status;
    uint_t     frame_size;


    *frame_size_ptr = 0;

    if (XLlDma_BdRingFromHw(tep->rx_ring, 1, &bd1_ptr) == 0) {
	rx_warn_count++;
	if ((rx_warn_count < 10) || ((rx_warn_count % 100) == 0)) {
	    mbfw_printf("MBFW_WARN: xlltemac_rx(): RxBD was not ready for post processing. warn_count %d \r\n", rx_warn_count);
	}
	XLlDma_mBdRingIntEnable(tep->rx_ring, XLLDMA_CR_IRQ_ALL_EN_MASK);
	return -1;
    }

    frame_size = XLlDma_mBdRead(bd1_ptr, XLLDMA_BD_USR4_OFFSET);

    status = XLlDma_BdRingFree(tep->rx_ring, 1, bd1_ptr);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: xlltemac_rx(): XLlDma_BdRingFree() failed with status 0x%x \r\n", status);
	XLlDma_mBdRingIntEnable(tep->rx_ring, XLLDMA_CR_IRQ_ALL_EN_MASK);
	return -1;
    }

    XLlDma_mBdRingIntEnable(tep->rx_ring, XLLDMA_CR_IRQ_ALL_EN_MASK);

    *frame_size_ptr = frame_size;

    return 0;
}

static int
xlltemac_rx_tohw(struct snet *snetp, void *eth_instance, uint8_t *frame, uint_t frame_size)
{
    struct t1_lltemac *tep = (struct t1_lltemac *) eth_instance;

    XLlDma_Bd *bd1_ptr;
    int        status;


    XCACHE_FLUSH_DCACHE_RANGE(frame, frame_size);
    XCACHE_INVALIDATE_DCACHE_RANGE(frame, frame_size);

    status = XLlDma_BdRingAlloc(tep->rx_ring, 1, &bd1_ptr);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: xlltemac_rx_tohw(): XLlDma_BdRingAlloc() for rx, failed with status 0x%x \r\n", status);
	return -1;
    }

    XLlDma_mBdSetBufAddr(bd1_ptr, frame);
    XLlDma_mBdSetLength(bd1_ptr,  frame_size);
    XLlDma_mBdSetStsCtrl(bd1_ptr, XLLDMA_BD_STSCTRL_SOP_MASK | XLLDMA_BD_STSCTRL_EOP_MASK);

    status = XLlDma_BdRingToHw(tep->rx_ring, 1, bd1_ptr);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: xlltemac_rx_tohw(): XLlDma_BdRingToHw() failed with status 0x%x \r\n", status);
	return -1;
    }

    return 0;
}

#endif /* if (! defined T1_FPGA_XEMAC) && (! defined T1_FPGA_XEMACLITE) */
