#define TESTAPP_GEN

/* $Id: xemaclite_intr_tapp_example.c,v 1.1 2007/05/16 07:17:10 mta Exp $ */
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
*       (c) Copyright 2003-2006 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/
/*****************************************************************************/
/**
* @file xemaclite_intr_tapp_example.c
*
* This file contains a example for using the EmacLite hardware and driver.
* This file contains an interrupt example outlining the use of interrupts and
* callbacks in the transmission of an ethernet frame.
*
* This example assumes that there is an interrupt controller in the hardware
* system and the EmacLite device is connected to the interrupt controller. This
* example works with a PPC processor. Refer the examples of Interrupt controller
* (XIntc) for an example of using interrupts with the MicroBlaze processor.
*
* @note
*
* None
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.01a ecm  05/21/04 First release
* 1.01a sv   06/06/05 Minor changes to comply to Doxygen and coding guidelines
* 1.01a sv   06/06/06 Minor changes for supporting Test App Interrupt examples
* </pre>
*
******************************************************************************/

/***************************** Include Files *********************************/

#include "xparameters.h"
#include "xstatus.h"
#include "xemaclite.h"
#include "xintc.h"

#ifdef __MICROBLAZE__
#include "mb_interface.h"
#else
#include "xexception_l.h"
#endif

/************************** Constant Definitions *****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#ifndef TESTAPP_GEN
#define EMACLITE_DEVICE_ID      XPAR_ETHERNET_MAC_DEVICE_ID
#define INTC_DEVICE_ID          XPAR_OPB_INTC_0_DEVICE_ID
#define EMACLITE_IRPT_INTR      XPAR_OPB_INTC_0_ETHERNET_MAC_IP2INTC_IRPT_INTR
#endif

/*
 * The Size of the Test Frame.
 */
#define EMACLITE_TEST_FRAME_SIZE          1000


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

XStatus EmacLiteExample(XIntc *IntcInstancePtr,
                        XEmacLite *EmacLiteInstPtr,
                        Xuint16 EmacLiteDeviceId,
                        Xuint16 EmacLiteIntrId);


static XStatus EmacLiteSendFrame(XEmacLite *EmacLiteInstPtr,
                                 Xuint32 PayloadSize,
                                 Xuint8 *DestAddress);


static void EmacLiteSendHandler(void *CallBackRef);

static void EmacLiteRecvHandler(void *CallBackRef);


static XStatus EmacLiteSetupIntrSystem(XIntc *IntcInstancePtr,
                                       XEmacLite *EmacLiteInstPtr,
                                       Xuint16 EmacLiteIntrId);

static void EmacLiteDisableIntrSystem(XIntc *IntcInstancePtr,
                                      Xuint16 EmacLiteIntrId);


/************************** Variable Definitions *****************************/

/*
 * Set up valid local and remote MAC addresses. The loopback tests will
 * use the LocalAddress both as source and destination, while the network
 * tests will use both RemoteAddress and LocalAddress
 */
static Xuint8 RemoteAddress[XEL_MAC_ADDR_SIZE] =
{
    0x00, 0x10, 0xa4, 0xb6, 0xfd, 0x09
};

static Xuint8 LocalAddress[XEL_MAC_ADDR_SIZE] =
{
    0x06, 0x05, 0x04, 0x03, 0x02, 0x01
};


#ifndef TESTAPP_GEN
static XIntc IntcInstance;            /* Instance of the Interrupt Controller */
static XEmacLite EmacLiteInstance;    /* Instance of the EmacLite */
#endif

/*
 * Buffers used for Transmission and Reception of Packets
 */
static Xuint8 TxFrame[XEL_MAX_FRAME_SIZE];
static Xuint8 RxFrame[XEL_MAX_FRAME_SIZE];

static volatile Xboolean TransmitComplete;


/****************************************************************************/
/**
*
* This function is the main function of the EmacLite interrupt example.
*
* @param    None.
*
* @return   XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note     None.
*
*****************************************************************************/
#ifndef TESTAPP_GEN
int main()
{

    XStatus Status;

    /*
     * Run the EmacLite interrupt example , specify the parameters
     * generated in xparameters.h.
     */
    Status = EmacLiteExample(&IntcInstance,
                             &EmacLiteInstance,
                             EMACLITE_DEVICE_ID,
                             EMACLITE_IRPT_INTR);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    return XST_SUCCESS;

}
#endif

/*****************************************************************************/
/**
*
* The main entry point for the EmacLite driver in interrupt mode example.
*
* @param    IntcInstancePtr is a pointer to the instance of the Intc.
* @param    EmacLiteInstPtr is a pointer to the instance of the EmacLite.
* @param    EmacLiteDeviceId is device ID of the XEmacLite Device , typically
*           XPAR_<EMACLITE_instance>_DEVICE_ID value from xparameters.h.
* @param    EmacLiteIntrId is the interrupt ID and is typically
*           XPAR_<INTC_instance>_<EMACLITE_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h.
*
* @return   XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
XStatus EmacLiteExample(XIntc *IntcInstancePtr,
                        XEmacLite *EmacLiteInstPtr,
                        Xuint16 EmacLiteDeviceId,
                        Xuint16 EmacLiteIntrId)
{
    XStatus Status;

    /*
     * Initialize the EmacLite device.
     */
    Status = XEmacLite_Initialize(EmacLiteInstPtr, EmacLiteDeviceId);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Set the MAC address.
     */
    XEmacLite_SetMacAddress(EmacLiteInstPtr, LocalAddress);

    /*
     * Set up the interrupt infrastructure.
     */
    Status = EmacLiteSetupIntrSystem(IntcInstancePtr,
                                     EmacLiteInstPtr,
                                     EmacLiteIntrId);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Setup the EmacLite handlers.
     */
    XEmacLite_SetRecvHandler((EmacLiteInstPtr), (void *)(EmacLiteInstPtr),
                             (XEmacLite_Handler) EmacLiteRecvHandler);
    XEmacLite_SetSendHandler((EmacLiteInstPtr), (void *)(EmacLiteInstPtr),
                             (XEmacLite_Handler) EmacLiteSendHandler);


    /*
     * Empty any existing receive frames.
     */
    XEmacLite_FlushReceive(EmacLiteInstPtr);

    /*
     * Enable the interrupts in the EmacLite controller.
     */
    XEmacLite_EnableInterrupts(EmacLiteInstPtr);

    /*
     * Check if there is a Tx buffer available, if there isn't it is an error.
     */
    if (XEmacLite_TxBufferAvailable(EmacLiteInstPtr) != XTRUE)
    {
        return XST_FAILURE;
    }

    /*
     * Transmit a ethernet frame.
     */
    Status = EmacLiteSendFrame(EmacLiteInstPtr,
                               EMACLITE_TEST_FRAME_SIZE,
                               RemoteAddress);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Wait for the frame to be transmitted.
     */
    while (TransmitComplete == XFALSE);



    /*
     * Disable and disconnect the EmacLite Interrupts.
     */
    XEmacLite_DisableInterrupts(EmacLiteInstPtr);
    EmacLiteDisableIntrSystem(IntcInstancePtr, EmacLiteIntrId);


    return XST_SUCCESS;
}

/******************************************************************************/
/**
*
* This function sends a frame of given size. This function assumes interrupt
* mode and sends the frame.
*
* @param    EmacLiteInstPtr is a pointer to the EmacLite instance.
* @param    PayloadSize is the size of the frame to create. The size only
*           reflects the payload size, it does not include the Ethernet header
*           size (14 bytes) nor the Ethernet CRC size (4 bytes).
* @param    DestAddress if the address of the remote hardware the frame is to be
*           sent to.
*
* @return   XST_SUCCESS if successful, else XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
static XStatus EmacLiteSendFrame(XEmacLite *EmacLiteInstPtr,
                                 Xuint32 PayloadSize,
                                 Xuint8 *DestAddress)
{
    XStatus Status;
    Xuint8 *FramePtr;
    Xuint8 *AddrPtr = DestAddress;
    Xuint32 Index;


    /*
     * Set the Complete flag to false
     */
    TransmitComplete = XFALSE;

    /*
     * Assemble the frame with a destination address and the source address.
     */
    FramePtr = (Xuint8 *)TxFrame;

    *FramePtr++ = *AddrPtr++;
    *FramePtr++ = *AddrPtr++;
    *FramePtr++ = *AddrPtr++;
    *FramePtr++ = *AddrPtr++;
    *FramePtr++ = *AddrPtr++;
    *FramePtr++ = *AddrPtr++;

    /*
     * Fill in the source MAC address.
     */
    *FramePtr++ = LocalAddress[0];
    *FramePtr++ = LocalAddress[1];
    *FramePtr++ = LocalAddress[2];
    *FramePtr++ = LocalAddress[3];
    *FramePtr++ = LocalAddress[4];
    *FramePtr++ = LocalAddress[5];


    /*
     * Set up the type/length field - be sure its in network order.
     */
    *((Xuint16 *)FramePtr) = PayloadSize;
    *FramePtr++;
    *FramePtr++;

    /*
     * Now fill in the data field with known values so we can verify them.
     */
    for (Index = 0; Index < PayloadSize; Index++)
    {
        *FramePtr++ = (Xuint8)Index;
    }

    /*
     * Now send the frame.
     */
    Status = XEmacLite_Send(EmacLiteInstPtr, (Xuint8 *)TxFrame,
                            PayloadSize + XEL_HEADER_SIZE);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}


/******************************************************************************/
/**
*
* This function handles the transmit callback from the EmacLite driver.
*
* @param    CallBackRef is the call back refernce provided to the Handler.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void EmacLiteSendHandler(void *CallBackRef)
{
    XEmacLite *EmacLiteInstPtr;

    /*
     * Convert the arg to something useful.
     */
    EmacLiteInstPtr = (XEmacLite *)CallBackRef;

    /*
     * Handle the Transmit callback.
     */
    TransmitComplete = XTRUE;

}

/******************************************************************************/
/**
*
* This function handles the receive callback from the EmacLite driver.
*
* @param    CallBackRef is the call back refernce provided to the Handler.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void EmacLiteRecvHandler(void *CallBackRef)
{
    XEmacLite *EmacLiteInstPtr;

    /*
     * Convert the arg to something useful.
     */
    EmacLiteInstPtr = (XEmacLite *)CallBackRef;

    /*
     * Handle the Receive callback.
     */
    XEmacLite_Recv(EmacLiteInstPtr, (Xuint8 *)RxFrame);

}

/*****************************************************************************/
/**
*
* This function setups the interrupt system such that interrupts can occur
* for the EmacLite device. This function is application specific since the
* actual system may or may not have an interrupt controller.  The EmacLite
* could be directly connected to a processor without an interrupt controller.
* The user should modify this function to fit the application.
*
* @param    IntcInstancePtr is a pointer to the instance of the Intc.
* @param    EmacLiteInstPtr is a pointer to the instance of the EmacLite.
* @param    EmacLiteIntrId is the interrupt ID and is typically
*           XPAR_<INTC_instance>_<EMACLITE_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h
*
* @return   XST_SUCCESS if successful, otherwise XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
static XStatus EmacLiteSetupIntrSystem(XIntc *IntcInstancePtr,
                                       XEmacLite *EmacLiteInstPtr,
                                       Xuint16 EmacLiteIntrId)
{

    XStatus Status;

#ifndef TESTAPP_GEN
    /*
     * Initialize the interrupt controller driver so that it is ready to use.
     */
    Status = XIntc_Initialize(IntcInstancePtr, INTC_DEVICE_ID);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
#endif

    /*
     * Connect a device driver handler that will be called when an interrupt
     * for the device occurs, the device driver handler performs the specific
     * interrupt processing for the device.
     */
    Status = XIntc_Connect(IntcInstancePtr,
                           EmacLiteIntrId,
                           XEmacLite_InterruptHandler,
                           (void *)(EmacLiteInstPtr));
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }


#ifndef TESTAPP_GEN
    /*
     * Start the interrupt controller such that interrupts are enabled for
     * all devices that cause interrupts, specific real mode so that
     * the EmacLite can cause interrupts thru the interrupt controller.
     */
    Status = XIntc_Start(IntcInstancePtr, XIN_REAL_MODE);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }
#endif


    /*
     * Enable the interrupt for the EmacLite in the Interrupt controller.
     */
    XIntc_Enable(IntcInstancePtr, EmacLiteIntrId);


#ifndef TESTAPP_GEN

    /*
     * Initialize the PPC exception table.
     */
    XExc_Init();

    /*
     * Register the interrupt controller handler with the exception table.
     */
    XExc_RegisterHandler(XEXC_ID_NON_CRITICAL_INT,
                        (XExceptionHandler)XIntc_InterruptHandler,
                         IntcInstancePtr);

    /*
     * Enable non-critical exceptions.
     */
    XExc_mEnableExceptions(XEXC_NON_CRITICAL);

#endif /* TESTAPP_GEN */

    return XST_SUCCESS;
}



/*****************************************************************************/
/**
*
* This function disables the interrupts that occur for the EmacLite device.
*
* @param    IntcInstancePtr is the pointer to the instance of the INTC
*           component.
* @param    EmacLiteIntrId is the interrupt Id and is typically
*           XPAR_<INTC_instance>_<EMACLITE_instance>_IP2INTC_IRPT_INTR
*           value from xparameters.h.
*
* @return   None.
*
* @note     None.
*
******************************************************************************/
static void EmacLiteDisableIntrSystem(XIntc *IntcInstancePtr,
                                      Xuint16 EmacLiteIntrId)
{

    /*
     * Disconnect and disable the interrupts for the EmacLite device.
     */
    XIntc_Disconnect(IntcInstancePtr, EmacLiteIntrId);

}


