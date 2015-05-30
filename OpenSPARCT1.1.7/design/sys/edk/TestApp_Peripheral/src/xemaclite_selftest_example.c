#define TESTAPP_GEN

/* $Id: xemaclite_selftest_example.c,v 1.1 2007/05/16 07:17:10 mta Exp $ */
/*****************************************************************************
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
*       (c) Copyright 2005 Xilinx Inc.
*       All rights reserved.
*
*****************************************************************************/
/****************************************************************************/
/**
*
* @file xemaclite_selftest_example.c
*
* This file contains a design example using the EMACLite driver.
*
* @note
*
* None.
*
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a ecm  01/25/05 Initial release for TestApp integration.
* 1.00a sv   06/06/05 Minor changes to comply to Doxygen and coding guidelines
*
******************************************************************************/
/***************************** Include Files *********************************/

#include "xparameters.h"
#include "xstatus.h"
#include "xemaclite.h"

/************************** Constant Definitions *****************************/

/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define EMAC_DEVICE_ID          XPAR_ETHERNET_MAC_DEVICE_ID


/**************************** Type Definitions *******************************/


/***************** Macros (Inline Functions) Definitions *********************/


/************************** Function Prototypes ******************************/

XStatus EMACLiteSelfTestExample(Xuint16 DeviceId);

/************************** Variable Definitions *****************************/

/*
 * Instance of the driver
 */
static XEmacLite EmacLite;


/****************************************************************************/
/**
*
* This function is the main function of the XEmaclite example. This function
* is not included if the example is generated from the TestAppGen test tool.
*
* @param    None
*
* @return   XST_SUCCESS to indicate success, else XST_FAILURE.
*
* @note     None
*
*****************************************************************************/
#ifndef TESTAPP_GEN
int main(void)
{
    XStatus Status;

    /*
     * Run the EmacLite Self test example, specify the Device ID that is
     * generated in xparameters.h
     */
    Status = EMACLiteSelfTestExample(EMAC_DEVICE_ID);
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
* The main entry point for the EmacLite driver selftest example.
*
* @param    DeviceId is the XPAR_<xemaclite_instance>_DEVICE_ID value from
*           xparameters.h
*
* @return   XST_SUCCESS to indicate success, else XST_FAILURE.
*
* @note     None.
*
******************************************************************************/
XStatus EMACLiteSelfTestExample(Xuint16 DeviceId)
{
    XStatus Status;
    XEmacLite *InstancePtr = &EmacLite;

    /*
     * First Initialize the device.
     */
    Status = XEmacLite_Initialize(InstancePtr, DeviceId);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    /*
     * Run the Self Test
     */
    Status = XEmacLite_SelfTest(InstancePtr);
    if (Status != XST_SUCCESS)
    {
        return XST_FAILURE;
    }

    return XST_SUCCESS;
}

