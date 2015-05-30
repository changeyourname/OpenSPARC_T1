/* $Id: */
/******************************************************************************
*
*       XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"
*       AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND
*       SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,
*       OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
*       APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION
*       THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,
*       AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE
*       FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY
*       WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE
*       IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
*       REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF
*       INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*       FOR A PARTICULAR PURPOSE.
*
*       (c) Copyright 2007 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/
/*****************************************************************************/
/**
*
* @file xlltemac_example_intr_fifo.c
*
* Implements examples that utilize the TEMAC's interrupt driven FIFO direct
* packet transfer mode to send and receive frames.
*
* These examples demonstrate:
*
* - How to perform simple send and receive.
* - Advanced frame processing
* - Error handling
* - Device reset
*
* Functional guide to example:
*
* - TemacSingleFrameIntrExample() demonstrates the simplest way to send and
*   receive frames in interrupt driven FIFO direct mode.
*
* - TemacSingleFrameNonContIntrExample demonstrates how to handle frames that
*   are stored in more than one memory location.
*
* - TemacMultipleFramesIntrExample demonstrates how to defer frame reception so
*   that CPU intensive receive functions are not performed in interrupt context.
*
* - TemacErrorHandler() demonstrates how to manage asynchronous errors.
*
* - TemacResetDevice() demonstrates how to reset the driver/HW while
    maintaining  driver/HW state.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a rmm  06/01/05 First release
* 2.00a rmm  11/21/05 Added call to TemacUtilEnterLoopback(),
*                     added HW capability check prior to running example.
* 2.00a sv   06/12/06 Minor changes to comply to Doxygen and coding guidelines
* 2.00a xd   12/17/07 Mionr change on DeferRx's data type to make g++ happy
* </pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xlltemac_example.h"
#include "xintc.h"

#ifdef __MICROBLAZE__
#include "mb_interface.h"
#else
#include "xexception_l.h"
#endif

/*************************** Constant Definitions ****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#ifndef TESTAPP_GEN
#define TEMAC_DEVICE_ID   XPAR_XPS_LL_TEMAC34_0_DEVICE_ID
#define FIFO_DEVICE_ID    XPAR_XPS_LL_FIFO34_0_DEVICE_ID
#define INTC_DEVICE_ID    XPAR_OPB_INTC_0_DEVICE_ID
#define TEMAC_IRPT_INTR   XPAR_OPB_INTC_0_XPS_LL_TEMAC34_0_TEMACINTC0_IRPT_INTR
#define FIFO_IRPT_INTR    XPAR_OPB_INTC_0_XPS_LL_FIFO34_0_IP2INTC_IRPT_INTR
#endif

/*************************** Variable Definitions ****************************/

static EthernetFrame TxFrame;	/* Frame used to send with */
static EthernetFrame RxFrame;	/* Frame used to receive data */
volatile static int DeferRx = 0;

/*
 * Counters setup to be incremented by callbacks
 */
static volatile int FramesRx;	/* Number of received frames */
static volatile int FramesRxInts;	/* Number of ints for received frames */
static volatile int FramesTxInts;	/* Number of ints for sent frames */
static volatile int DeviceErrors;	/* Num of errors detected in the device */
static volatile int FrameDataErrors;	/* Num of times frame data check failed */

#ifndef TESTAPP_GEN
static XIntc IntcInstance;
#endif

/*************************** Function Prototypes *****************************/

/*
 * The different examples given in this file
 */
int TemacFifoIntrExample(XIntc * IntcInstancePtr,
			 XLlTemac * TemacInstancePtr,
			 XLlFifo * FifoInstancePtr,
			 u16 TemacDeviceId,
			 u16 FifoDeviceId, u16 TemacIntrId, u16 FifoIntrId);
int TemacSingleFrameIntrExample(XLlTemac * TemacInstancePtr,
				XLlFifo * FifoInstancePtr);
int TemacSingleFrameNonContIntrExample(XLlTemac * TemacInstancePtr,
				       XLlFifo * FifoInstancePtr);
int TemacMultipleFramesIntrExample(XLlTemac * TemacInstancePtr,
				   XLlFifo * FifoInstancePtr);


/*
 * The Interrupt setup and callbacks
 */
static int TemacSetupIntrSystem(XIntc * IntcInstancePtr,
				XLlTemac * TemacInstancePtr,
				XLlFifo * FifoInstancePtr,
				u16 TemacIntrId, u16 FifoIntrId);
static void TemacDisableIntrSystem(XIntc * IntcInstancePtr,
				   u16 TemacIntrId, u16 FifoIntrId);

static void FifoRecvHandler(XLlFifo * Fifo);
static void TemacErrorHandler(XLlTemac * Temac);
static void FifoHandler(XLlFifo * Fifo);

/*
 * Utility routines
 */
static int TemacResetDevice(XLlTemac * TemacInstancePtr,
			    XLlFifo * FifoInstancePtr);


/*****************************************************************************/
/**
*
* This is the main function for the Temac example. This function is not included
* if the example is generated from the TestAppGen test  tool.
*
* @param    None.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
****************************************************************************/
#ifndef TESTAPP_GEN
int main(void)
{
	int Status;


	/*
	 * Call the Temac interrupt example , specify the parameters generated
	 * in xparameters.h
	 */
	Status = TemacFifoIntrExample(&IntcInstance,
				      &TemacInstance,
				      &FifoInstance,
				      TEMAC_DEVICE_ID,
				      FIFO_DEVICE_ID,
				      TEMAC_IRPT_INTR, FIFO_IRPT_INTR);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;

}
#endif



/*****************************************************************************/
/**
*
* This function demonstrates the usage usage of the TEMAC by sending by sending
* and receiving frames in interrupt driven fifo mode.
*
*
* @param    IntcInstancePtr is a pointer to the instance of the Intc component.
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
* @param    TemacDeviceId is Device ID of the Temac Device , typically
*           XPAR_<TEMAC_instance>_DEVICE_ID value from xparameters.h.
* @param    TemacIntrId is the Interrupt ID and is typically
*           XPAR_<INTC_instance>_<TEMAC_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
int TemacFifoIntrExample(XIntc * IntcInstancePtr,
			 XLlTemac * TemacInstancePtr,
			 XLlFifo * FifoInstancePtr,
			 u16 TemacDeviceId,
			 u16 FifoDeviceId, u16 TemacIntrId, u16 FifoIntrId)
{
	int Status;
	u32 Rdy;
	XLlTemac_Config *MacCfgPtr;

    /*************************************/
	/* Setup device for first-time usage */
    /*************************************/

	/*
	 * Initialize the TEMAC instance
	 */
	MacCfgPtr = XLlTemac_LookupConfig(TemacDeviceId);
	Status = XLlTemac_CfgInitialize(TemacInstancePtr, MacCfgPtr,
					MacCfgPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error in initialize");
		return XST_FAILURE;
	}
	XLlFifo_Initialize(FifoInstancePtr,
			      XLlTemac_LlDevBaseAddress(TemacInstancePtr));


	/*
	 * Check whether the IPIF interface is correct for this example
	 */
	if (!XLlTemac_IsFifo(TemacInstancePtr)) {
		TemacUtilErrorTrap
			("Device HW not configured for FIFO direct mode\r\n");
		return XST_FAILURE;
	}

	/*
	 * Set the MAC  address
	 */
	Status = XLlTemac_SetMacAddress(TemacInstancePtr, (u8 *) TemacMAC);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error setting MAC address");
		return XST_FAILURE;
	}

	/* Make sure the hard temac is ready */
	Rdy = XLlTemac_ReadReg(TemacInstance.Config.BaseAddress,
			       XTE_RDY_OFFSET);
	while ((Rdy & XTE_RDY_HARD_ACS_RDY_MASK) == 0) {
		Rdy = XLlTemac_ReadReg(TemacInstance.Config.BaseAddress,
				       XTE_RDY_OFFSET);
	}

	/*
	 * Set PHY to loopback
	 */
	Status = TemacUtilEnterLoopback(TemacInstancePtr, TEMAC_LOOPBACK_SPEED);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error setting the PHY loopback");
		return XST_FAILURE;
	}


	/*
	 * Set PHY<-->MAC data clock
	 */
	XLlTemac_SetOperatingSpeed(TemacInstancePtr, TEMAC_LOOPBACK_SPEED);

	/*
	 * Setting the operating speed of the MAC needs a delay.  There
	 * doesn't seem to be register to poll, so please consider this
	 * during your application design.
	 */
	TemacUtilPhyDelay(2);

	/* Clear any pending FIFO interrupts from any previous
	 * examples (e.g., polled)
	 */
	XLlFifo_IntClear(FifoInstancePtr, XLLF_INT_ALL_MASK);

	/*
	 * Connect to the interrupt controller and enable interrupts
	 */
	Status = TemacSetupIntrSystem(IntcInstancePtr,
				      TemacInstancePtr,
				      FifoInstancePtr, TemacIntrId, FifoIntrId);

    /****************************/
	/* Run through the examples */
    /****************************/


	/*
	 * Run the Temac Single Frame Interrupt example
	 */
	Status = TemacSingleFrameIntrExample(TemacInstancePtr, FifoInstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Run the Temac Single Frame Non Continuous Interrupt example
	 */
	Status = TemacSingleFrameNonContIntrExample(TemacInstancePtr,
						    FifoInstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	DeferRx = 1;
	Status = TemacMultipleFramesIntrExample(TemacInstancePtr,
				   FifoInstancePtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Disable the interrupts for the Temac device
	 */
	TemacDisableIntrSystem(IntcInstancePtr, TemacIntrId, FifoIntrId);


	/*
	 * Stop the device
	 */
	XLlTemac_Stop(TemacInstancePtr);


	return XST_SUCCESS;

}


/*****************************************************************************/
/**
*
* This function demonstrates the usage of the TEMAC by sending and receiving
* a single frame in interrupt mode.
*
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
int TemacSingleFrameIntrExample(XLlTemac * TemacInstancePtr,
				XLlFifo * FifoInstancePtr)
{
	int Status;
	u32 FifoFreeBytes;
	u32 TxFrameLength;
	int PayloadSize = 100;

	/*
	 * Clear variables shared with callbacks
	 */
	FramesRx = 0;
	FramesRxInts = 0;
	FramesTxInts = 0;
	DeviceErrors = 0;
	FrameDataErrors = 0;

	/*
	 * Setup packet to be transmitted
	 */
	TemacUtilFrameHdrFormatMAC(&TxFrame, TemacMAC);
	TemacUtilFrameHdrFormatType(&TxFrame, PayloadSize);
	TemacUtilFrameSetPayloadData(&TxFrame, PayloadSize);

	/*
	 * Clear out receive packet memory area
	 */
	TemacUtilFrameMemClear(&RxFrame);

	/*
	 * Calculate frame length (not including FCS)
	 */
	TxFrameLength = XTE_HDR_SIZE + PayloadSize;

    /****************/
	/* Setup device */
    /****************/

	/*
	 * Start the device
	 */
	XLlTemac_Start(TemacInstancePtr);

	/*
	 * Enable the interrupts
	 */
	XLlFifo_IntEnable(FifoInstancePtr, XLLF_INT_ALL_MASK);
	XLlTemac_IntEnable(TemacInstancePtr,
			   XTE_INT_RXRJECT_MASK | XTE_INT_RXFIFOOVR_MASK);


    /*******************/
	/* Send the packet */
    /*******************/

	/*
	 * Find out how much room is in the FIFO
	 * Vacancy is a value in 32 bit words. Multiply by 4 to get bytes.
	 */
	FifoFreeBytes = XLlFifo_TxVacancy(FifoInstancePtr) * 4;
	if (FifoFreeBytes < TxFrameLength) {
		TemacUtilErrorTrap("Not enough room in FIFO for frame");
		return XST_FAILURE;
	}

	/*
	 * Write frame data to FIFO
	 */
	XLlFifo_Write(FifoInstancePtr, TxFrame, TxFrameLength);

	/*
	 * Initiate the transmit
	 */
	XLlFifo_TxSetLen(FifoInstancePtr, TxFrameLength);

	/*
	 * Wait for receive indication or error
	 */
	while ((FramesRx == 0) && (DeviceErrors == 0));

	/*
	 * Stop the device
	 */
	XLlTemac_Stop(TemacInstancePtr);

	return XST_SUCCESS;
}


/*****************************************************************************/
/**
*
* This example sends a packet from non-contiguous memory locations. The header
* is stored in one area. The payload data is calculated and written to the
* packet  FIFO one byte at a time.
*
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
int TemacSingleFrameNonContIntrExample(XLlTemac * TemacInstancePtr,
				       XLlFifo * FifoInstancePtr)
{
	int Status;
	u32 FifoFreeBytes;
	int PayloadSize = 20;
	u8 PayloadData;
	u32 TxFrameLength;

	/*
	 * Clear variables shared with callbacks
	 */
	FramesRx = 0;
	FramesRxInts = 0;
	FramesTxInts = 0;
	DeviceErrors = 0;
	FrameDataErrors = 0;

	/*
	 * Setup the transmit packet header
	 */
	TemacUtilFrameHdrFormatMAC(&TxFrame, TemacMAC);
	TemacUtilFrameHdrFormatType(&TxFrame, PayloadSize);

	/*
	 * Clear out receive packet memory area
	 */
	TemacUtilFrameMemClear(&RxFrame);

	/*
	 * Calculate frame length (not including FCS)
	 */
	TxFrameLength = XTE_HDR_SIZE + PayloadSize;

    /****************/
	/* Setup device */
    /****************/

	/*
	 * Start the device
	 */
	XLlTemac_Start(TemacInstancePtr);

	/*
	 * Enable interrupts
	 */
	XLlFifo_IntEnable(FifoInstancePtr, XLLF_INT_ALL_MASK);

    /*******************/
	/* Send the packet */
    /*******************/

	/*
	 * Make sure there is enough room for a full sized frame
	 * Vacancy is a value in 32 bit words. Multiply by 4 to get bytes.
	 */
	FifoFreeBytes = XLlFifo_TxVacancy(FifoInstancePtr) * 4;

	if (FifoFreeBytes < (XTE_MTU + XTE_HDR_SIZE)) {
		TemacUtilErrorTrap("Not enough room in FIFO for frame");
		return XST_FAILURE;
	}

	/*
	 * Write the header data
	 */
	XLlFifo_Write(FifoInstancePtr, TxFrame, XTE_HDR_SIZE /*TxFrameLength*/);

	/*
	 * Write payload one byte at a time. Set the payload like the
	 * TemacUtilFrameSetPayloadData() function would. This is done so that
	 * the received packet will pass validation in TemacRecvHandler().
	 *
	 * Keep PayloadSize less than 255 since TemacUtilFrameSetPayloadData()
	 * switches to a 16 bit counter at 256.
	 *
	 * This is not the fastest way to send a frame of data but it does
	 * illustrate the flexibility of the API.
	 */
	PayloadData = 0;
	while ((PayloadData < PayloadSize) && (DeviceErrors == 0)) {
		XLlFifo_Write(FifoInstancePtr, &PayloadData, 1);
		PayloadData++;
	}

	/*
	 * Did it all get written without error
	 */
	if (DeviceErrors != 0) {
		TemacUtilErrorTrap
			("Error writing payload to FIFO, reset recommended");
		return XST_FAILURE;
	}

	/*
	 * Now begin transmission
	 */
	XLlFifo_TxSetLen(FifoInstancePtr, TxFrameLength);

	/*
	 * Wait for receive indication or error
	 */
	while ((FramesRx == 0) && (DeviceErrors == 0));

	/*
	 * Stop the device
	 */
	XLlTemac_Stop(TemacInstancePtr);

	return XST_SUCCESS;
}


/*****************************************************************************/
/**
*
* This example sends and receives a batch of frames. Frame reception is handled
* in this function and not in the callback function.
*
* Use this method of reception when interrupt latency is important.
*
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
*
* @return   XST_SUCCESS to indicate success, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
int TemacMultipleFramesIntrExample(XLlTemac * TemacInstancePtr,
				   XLlFifo * FifoInstancePtr)
{
	int FramesToLoopback;
	int PayloadSize;
	int Status;
	u32 TxFrameLength;
	u32 RxFrameLength;
	int Index;

	/*
	 *  Clear variables shared with callbacks
	 */
	FramesRx = 0;
	FramesRxInts = 0;
	FramesTxInts = 0;
	DeviceErrors = 0;
	FrameDataErrors = 0;

	/*
	 * Setup the number of frames to loopback and the size of the frame to
	 * loopback. The default settings should work for every case. Modifying
	 * the settings can cause problems, see discussion below:
	 *
	 * If PayloadSize is set small and FramesToLoopback high, then it is
	 * possible to cause the transmit status FIFO to overflow.
	 *
	 * If PayloadSize is set large and FramesToLoopback high, then it is
	 * possible to cause the transmit packet FIFO to overflow.
	 *
	 * Either of these scenarios may be worth trying out to observe how the
	 * driver reacts. The exact values to cause these types of errors
	 * will vary due to the sizes of the FIFOs selected at hardware build
	 * time. But the following settings should create problems for all
	 * FIFO sizes:
	 *
	 * Transmit status FIFO overflow
	 *    PayloadSize = 1
	 *    FramesToLoopback = 1000
	 *
	 * Transmit packet FIFO overflow
	 *    PayloadSize = 1500
	 *    FramesToLoopback = 16
	 *
	 * These values should always work without error
	 *    PayloadSize = 100
	 *    FramesToLoopback = 5
	 */
	PayloadSize = 100;
	FramesToLoopback = 5;

	/*
	 * Setup the transmit packet
	 */
	TemacUtilFrameHdrFormatMAC(&TxFrame, TemacMAC);
	TemacUtilFrameHdrFormatType(&TxFrame, PayloadSize);
	TemacUtilFrameSetPayloadData(&TxFrame, PayloadSize);

	/*
	 * Calculate frame length (not including FCS)
	 */
	TxFrameLength = XTE_HDR_SIZE + PayloadSize;

    /****************/
	/* Setup device */
    /****************/

	/*
	 * Start the device
	 */
	XLlTemac_Start(TemacInstancePtr);

	/*
	 * Enable the interrupts
	 */
	XLlFifo_IntEnable(FifoInstancePtr, XLLF_INT_ALL_MASK);


    /****************/
	/* Send packets */
    /****************/

	/*
	 * Since we may be interested to see what happens when FIFOs overflow, don't
	 * check for room in the transmit packet FIFO prior to writing to it.
	 */

	/*
	 * With the xps_ll_fifo core we can't stuff the fifo with data from
	 * multiple packets and then send them. Instead, the code needs to
	 * write the data, and then immediately send the packet before writting
	 * the data for the next packet.
	 */
	for (Index = 0; Index < FramesToLoopback; Index++) {
		/*
		 * Write frame data to FIFO
		 */
		XLlFifo_Write(FifoInstancePtr, TxFrame, TxFrameLength);
		/*
		 * Initiate the transmission
		 */
		XLlFifo_TxSetLen(FifoInstancePtr, TxFrameLength);
	}

    /*******************/
	/* Receive packets */
    /*******************/

	/*
	 * Now wait for frames to be received. When the callback is executed,
	 * it will disable interrupts and set a shared variable which will
	 * trigger this routine to process received frames
	 */
	for (Index = 0; Index < FramesToLoopback; Index++) {
		/*
		 * Wait
		 */
		while (FramesRxInts == 0);

			/*
		 * Frame has arrived, so get the length
		 */
		RxFrameLength = XLlFifo_RxGetLen(FifoInstancePtr);

		/*
		 * Decision time: We can re-enable receive interrupts here or after
		 * we read the frame out of the FIFO. This is a matter of preference.
		 * and goals of an application using the driver.
		 */
		XLlFifo_IntEnable(FifoInstancePtr, XLLF_INT_RC_MASK);

		/*
		 * Frame size as expected?
		 */
		if ((RxFrameLength) != TxFrameLength) {
			TemacUtilErrorTrap("Receive length incorrect");
		}

		/*
		 * Clear out receive packet memory area
		 */
		TemacUtilFrameMemClear(&RxFrame);

		/*
		 * Read frame from packet FIFO
		 */
		XLlFifo_Read(FifoInstancePtr, &RxFrame, RxFrameLength);
		/*
		 * Verify the received data
		 */
		if (TemacUtilFrameVerify(&TxFrame, &RxFrame) != 0) {
			TemacUtilErrorTrap("Data mismatch");
			return XST_FAILURE;
		}
	}

	/*
	 * Stop the device
	 */
	XLlTemac_Stop(TemacInstancePtr);

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This is the Receive handler callback function for examples 1 and 2.
* It will increment a shared  counter, receive and validate the frame.
*
* @param    Fifo is a reference to the Fifo device instance.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void FifoRecvHandler(XLlFifo * Fifo)
{
	int Status;
	u32 FrameLength;

	/*
	 * We get the interrupt only once for multiple frames received.
	 * So get all the frames we can.
	 */
	/* While there is data in the fifo ... */
	while (XLlFifo_RxOccupancy(Fifo)) {
		/*
		 * Get the packet length
		 */
		FrameLength = XLlFifo_RxGetLen(Fifo);

		XLlFifo_Read(Fifo, RxFrame, FrameLength);
		/*
		 * Validate the packet data against the header of the TxFrame. The
		 * payload data should as placed by TemacUtilFrameSetPayloadData()
		 */
		if (TemacUtilFrameVerify(&TxFrame, &RxFrame) != 0) {
			FrameDataErrors++;
			TemacUtilErrorTrap("Data mismatch");
			return;
		}
		/*
		 * Bump counter
		 */
		FramesRx++;
	}
}

/*****************************************************************************/
/**
*
* This is the Error handler callback function and this function increments the
* the error counter so that the main thread knows the number of errors.
*
* @param    Fifo is a reference to the Temac device instance.
*
* @param    Pending is a bitmask of the pending interrupts.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void FifoErrorHandler(XLlFifo * Fifo, u32 Pending)
{
	int timeout_counter;

	if (Pending & XLLF_INT_RPURE_MASK) {
		TemacUtilErrorTrap("Fifo: Rx under-read error");
	}
	if (Pending & XLLF_INT_RPORE_MASK) {
		TemacUtilErrorTrap("Fifo: Rx over-read error");
	}
	if (Pending & XLLF_INT_RPUE_MASK) {
		TemacUtilErrorTrap("Fifo: Rx fifo empty");
	}
	if (Pending & XLLF_INT_TPOE_MASK) {
		TemacUtilErrorTrap("Fifo: Tx fifo overrun");
	}
	if (Pending & XLLF_INT_TSE_MASK) {
		TemacUtilErrorTrap("Fifo: Tx length mismatch");
	}

	/*
	 * Reset the tx or rx side of the fifo as needed
	 */
	if (Pending & XLLF_INT_RXERROR_MASK) {
		XLlFifo_IntClear(Fifo, XLLF_INT_RRC_MASK);
		XLlFifo_RxReset(Fifo);
#ifdef __MICROBLAZE__
		timeout_counter = 10000;
#else
		timeout_counter = 10;
#endif
		while ((XLlFifo_Status(Fifo) & XLLF_INT_RRC_MASK) == 0) {
#ifndef __MICROBLAZE__
			usleep(10000);
#endif
			timeout_counter--;
			if (timeout_counter == 0) {
				XLlFifo_Reset(Fifo);
				/* we've reset the whole core so just exit out */
				goto feh_exit;
			}
		}
	}

	if (Pending & XLLF_INT_TXERROR_MASK) {
		XLlFifo_IntClear(Fifo, XLLF_INT_TRC_MASK);
		XLlFifo_TxReset(Fifo);
#ifdef __MICROBLAZE__
		timeout_counter = 10000;
#else
		timeout_counter = 10;
#endif

		while ((XLlFifo_Status(Fifo) & XLLF_INT_TRC_MASK) == 0) {
#ifndef __MICROBLAZE__
			usleep(10000);
#endif
			timeout_counter--;
			if (timeout_counter == 0) {
				XLlFifo_Reset(Fifo);

				/* we've reset the whole core so just exit out */
				goto feh_exit;
			}
		}
	}

      feh_exit:
	/*
	 * Bump counter
	 */
	DeviceErrors++;
}


/*****************************************************************************/
/**
*
* This is the Fifo handler function and  will increment a shared
* counter that can be tested by the main thread of operation.
*
* @param    Fifo is a reference to the Fifo instance.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void FifoHandler(XLlFifo * Fifo)
{
	u32 Pending = XLlFifo_IntPending(Fifo);
	u32 FrameLength;

	while (Pending) {
		if (Pending & XLLF_INT_RC_MASK) {
			/*
			 * Receive the frame, unless we are deferring the receive.
			 */
			if (DeferRx) {
				FramesRxInts++;	/* We can count the interrupts, but in the
						 * handler we don't exactly know how many
						 * frames as we could get one int for multiple
						 * frames.
						 */
				/*
				 * use for example 3: Disable receive interrupts to defer
				 * frame reception to the example function.
				 */
				XLlFifo_IntDisable(Fifo, XLLF_INT_RC_MASK);
			}
			else {
				FifoRecvHandler(Fifo);
			}
			XLlFifo_IntClear(Fifo, XLLF_INT_RC_MASK);
		}
		else if (Pending & XLLF_INT_TC_MASK) {
			FramesTxInts++;	/* We can count the interrupts, but in the handler
					 * we don't exactly know how many frames as we
					 * could get one int for multiple frames.
					 */
			XLlFifo_IntClear(Fifo, XLLF_INT_TC_MASK);
		}
		else {
			FifoErrorHandler(Fifo, Pending);
			XLlFifo_IntClear(Fifo, XLLF_INT_ALL_MASK &
					 ~(XLLF_INT_RC_MASK |
					   XLLF_INT_TC_MASK));
		}
		Pending = XLlFifo_IntPending(Fifo);
	}
}


/*****************************************************************************/
/**
*
* This is the Error handler callback function and this function increments the
* the error counter so that the main thread knows the number of errors.
*
* @param    Temac is a reference to the Temac device instance.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void TemacErrorHandler(XLlTemac * Temac)
{
	u32 Pending = XLlTemac_IntPending(Temac);

	if (Pending & XTE_INT_RXRJECT_MASK) {
		TemacUtilErrorTrap("Temac: Rx packet rejected");
	}
	if (Pending & XTE_INT_RXFIFOOVR_MASK) {
		TemacUtilErrorTrap("Temac: Rx fifo over run");
	}
	XLlTemac_IntClear(Temac, Pending);

	/*
	 * Bump counter
	 */
	DeviceErrors++;
}

/******************************************************************************/
/**
* This function resets the device but preserves the options set by the user.
*
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
*
* @return   XST_SUCCESS if successful, else XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
static int TemacResetDevice(XLlTemac * TemacInstancePtr,
			    XLlFifo * FifoInstancePtr)
{
	int Status;
	u8 MacSave[6];
	u32 Options;;

	/*
	 * Stop the TEMAC device
	 */
	XLlTemac_Stop(TemacInstancePtr);


	/*
	 * Save the device state
	 */
	XLlTemac_GetMacAddress(TemacInstancePtr, MacSave);
	Options = XLlTemac_GetOptions(TemacInstancePtr);

	/*
	 * Stop and reset the TEMAC device
	 */
	XLlTemac_Reset(TemacInstancePtr, XTE_NORESET_HARD);

	/*
	 * reset the fifo
	 */
	XLlFifo_Reset(FifoInstancePtr);

	/*
	 * Restore the state
	 */
	Status = XLlTemac_SetMacAddress(TemacInstancePtr, MacSave);
	Status |= XLlTemac_SetOptions(TemacInstancePtr, Options);
	Status |= XLlTemac_ClearOptions(TemacInstancePtr, ~Options);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error restoring state after reset");
		return XST_FAILURE;
	}

	/*
	 * Restart the device
	 */
	XLlTemac_Start(TemacInstancePtr);

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
*
* This function setups the interrupt system so interrupts can occur for the
* TEMAC.  This function is application-specific since the actual system may or
* may not have an interrupt controller.  The TEMAC could be directly connected
* to a processor without an interrupt controller.  The user should modify this
* function to fit the application.
*
* @param    IntcInstancePtr is a pointer to the instance of the Intc component.
* @param    TemacInstancePtr is a pointer to the instance of the Temac
*           component.
* @param    TemacIntrId is the Interrupt ID and is typically
*           XPAR_<INTC_instance>_<TEMAC_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h.
*
* @return   XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
static int TemacSetupIntrSystem(XIntc * IntcInstancePtr,
				XLlTemac * TemacInstancePtr,
				XLlFifo * FifoInstancePtr,
				u16 TemacIntrId, u16 FifoIntrId)
{
	int Status;

#ifndef TESTAPP_GEN
	/*
	 * Initialize the interrupt controller and connect the ISR
	 */
	Status = XIntc_Initialize(IntcInstancePtr, INTC_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap
			("Unable to intialize the interrupt controller");
		return XST_FAILURE;
	}
#endif
	Status = XIntc_Connect(IntcInstancePtr, TemacIntrId,
			       (XInterruptHandler) TemacErrorHandler,
			       TemacInstancePtr);
	Status |=
		XIntc_Connect(IntcInstancePtr, FifoIntrId,
			      (XInterruptHandler) FifoHandler, FifoInstancePtr);

	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap
			("Unable to connect ISR to interrupt controller");
		return XST_FAILURE;
	}

#ifndef TESTAPP_GEN
	/*
	 * Start the interrupt controller
	 */
	Status = XIntc_Start(IntcInstancePtr, XIN_REAL_MODE);
	if (Status != XST_SUCCESS) {
		TemacUtilErrorTrap("Error starting intc");
		return XST_FAILURE;
	}
#endif


	/*
	 * Enable interrupts from the hardware
	 */
	XIntc_Enable(IntcInstancePtr, TemacIntrId);
	XIntc_Enable(IntcInstancePtr, FifoIntrId);

#ifndef TESTAPP_GEN
#ifdef __PPC__
	/*
	 * Initialize the PPC exception table
	 */
	XExc_Init();

	/*
	 * Register the interrupt controller with the exception table
	 */
	XExc_RegisterHandler(XEXC_ID_NON_CRITICAL_INT,
			     (XExceptionHandler) XIntc_InterruptHandler,
			     IntcInstancePtr);

	/*
	 * Enable non-critical exceptions
	 */
	XExc_mEnableExceptions(XEXC_NON_CRITICAL);
#else
	/*
	 * Connect the interrupt controller interrupt handler to the hardware
	 * interrupt handling logic in the microblaze processor.
	 */
	microblaze_register_handler((XInterruptHandler)
			XIntc_InterruptHandler, IntcInstancePtr);

	/*
	* Enable interrupts in the Microblaze
	*/
	microblaze_enable_interrupts();
#endif
#endif


	return XST_SUCCESS;
}


/*****************************************************************************/
/**
*
* This function disables the interrupts that occur for Temac.
*
* @param    IntcInstancePtr is the pointer to the instance of the Intc
*           component.
* @param    TemacIntrId is
*           XPAR_<INTC_instance>_<TEMAC_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void TemacDisableIntrSystem(XIntc * IntcInstancePtr,
				   u16 TemacIntrId, u16 FifoIntrId)
{
	/*
	 * Disconnect and disable the interrupt for the Temac device
	 */
	XIntc_Disconnect(IntcInstancePtr, TemacIntrId);
	/*
	 * Disconnect and disable the interrupt for the Fifo device
	 */
	XIntc_Disconnect(IntcInstancePtr, FifoIntrId);
}

