/* $Id: xmpmc.h,v 1.2.2.1 2008/02/11 08:38:39 svemula Exp $ */
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
*       (c) Copyright 2007-2008 Xilinx Inc.
*       All rights reserved.
*
******************************************************************************/
/*****************************************************************************/
/**
*
* @file xmpmc.h
*
* The Xilinx XMpmc driver supports the following functionality in the Xilinx
* Multi-Port Memory Controller (MPMC), a soft IP core designed for Xilinx FPGAs:
* 		- Error Correction Code (ECC) capability
*		- Performance Monitoring
*		- Static PHY
*
* The device driver is not necessary for the MPMC device unless one of the
* three functionalities is enabled in the MPMC device.
*
* This header file contains the interfaces for the MPMC device driver.
*
* ECC is a mode that detects and corrects single memory errors and detects the
* double memory errors. The XMpmc device driver provides the following abilities
* for ECC:
*  - Enable and Disable ECC mode in Read logic/Write logic or both.
*  - Enable and Disable interrupts for specific ECC errors.
*  - Error injection for testing of ECC mode.
*  - Statistics for specific ECC errors detected.
*  - Information about address where the last error was detected.
*
* The XMpmc device driver provides the following abilities for Performance
* Monitoring:
*  - Enable and Disable Performance Monitoring.
*  - Clear the Performance Monitoring Data Bins.
*  - Get and Clear the the Performance Monitoring Data Bins Clear Status.
*  - Get the Global Cycle Count, Dead Cycle Count and Peformance Monitoring Data
* 	for the Data Bins.
*
* The XMpmc device driver provides the following abilities for Static Phy:
*  - Read and Write to the Static PHY register.
*
*
*<b> Initialization and Configuration </b>
*
* The device driver enables higher layer software (for example, an application)
* to communicate with the MPMC device.
*
* XMpmc_CfgInitialize() API is used to initialize the XMpmc device instance.
* The user needs to first call the XMpmc_LookupConfig() API which returns the
* Configuration structure pointer which is passed as a parameter to the
* XMpmc_CfgInitialize() API.
*
*<b> Interrupts</b>
*
* The MPMC device has one physical interrupt which must be connected to
* the interrupt controller in the system. The driver does not provide any
* interrupt handler for handling the interrupt. The users of this driver
* must connect their own interrupt handler with the interrupt system.
*
* <b> Asserts </b>
*
* Asserts are used within all Xilinx drivers to enforce constraints on argument
* values. Asserts can be turned off on a system-wide basis by defining, at
* compile time, the NDEBUG identifier. By default, asserts are turned on and it
* is recommended that users leave asserts on during development.
*
** <b> Threads </b>
*
* This driver is not thread safe. Any needs for threads or thread mutual
* exclusion must be satisfied by the layer above this driver.
*
*<b> Hardware Parameters Needed</b>
*
* To use this driver with the MPMC device one of the following functionalities
* must be enabled:
* 		- ECC capability
*		- Performance Monitoring
*		- Static PHY
*
* The interrupt capability for the device must be enabled in the hardware
* if interrupts are to be used with the driver. The interrupt functions of
* the device driver will assert when called if interrupt support is not
* present in the hardware.
*
* The ability to force errors is a test mode and it must be enabled
* in the hardware if the control register is to be used to force ECC errors.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver   Who  Date     Changes
* ----- ---- -------- -----------------------------------------------
* 1.00a mta  02/24/07 First release
* 2.00a mta  10/24/07 Added support for Performance Monitoring and Static PHY
* </pre>
*
******************************************************************************/

#ifndef XMPMC_H			/* prevent circular inclusions */
#define XMPMC_H			/* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/

#include "xmpmc_hw.h"
#include "xstatus.h"

/************************** Constant Definitions *****************************/

/**
 * @name Indexes for the different ports in MPMC.
 * @{
 */
#define XMPMC_PM_PORT0		0  /**< Port 0 */
#define XMPMC_PM_PORT1		1  /**< Port 1 */
#define XMPMC_PM_PORT2		2  /**< Port 2 */
#define XMPMC_PM_PORT3		3  /**< Port 3 */
#define XMPMC_PM_PORT4		4  /**< Port 4 */
#define XMPMC_PM_PORT5		5  /**< Port 5 */
#define XMPMC_PM_PORT6		6  /**< Port 6 */
#define XMPMC_PM_PORT7		7  /**< Port 7 */

/*@}*/


/**************************** Type Definitions *******************************/

/**
 * This typedef contains configuration information for the device.
 */
typedef struct {
	u16 DeviceId;          /**< Device Id */
	u32 BaseAddress;       /**< Register Base Address */
	int EccSupportPresent; /**< TRUE if ECC Support is enabled else FALSE */
	int StaticPhyPresent;  /**< TRUE if Static Phy Support is enabled else
					FALSE */
	int PerfMonitorEnable; /**< TRUE if Peformance Monitor is enabled else
					FALSE */
} XMpmc_Config;


/**
 * The XMpmc driver stats data. A pointer to a variable of this type is
 * passed to the driver API functions.
 */
typedef struct {
	u16 SingleErrorCount; /**< Single Error Count */
	u16 DoubleErrorCount; /**< Double Error Count */
	u16 ParityErrorCount; /**< Parity Error Count */
	u32 LastErrorAddress; /**< Address of memory where error occurred */
	u8 EccErrorSyndrome;  /**< Indicates the ECC error syndrome value */
	u8 EccErrorTransSize; /**< Size of transaction where error occured */
	u8 ErrorReadWrite;    /**< Indicates if error occurred in read/write */
} XMpmc_Stats;

/**
 * The XMpmc driver instance data. The user is required to allocate a
 * variable of this type for every MPMC device in the system. A pointer
 * to a variable of this type is then passed to the driver API functions.
 */
typedef struct {
	XMpmc_Config ConfigPtr; /**< Instance of the configuration structure */
	u32 IsReady;		/**< Device is initialized and ready */
} XMpmc;

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/

/************************** Variable Definitions *****************************/

/*
 * API Basic functions implemented in xmpmc.c.
 */
int XMpmc_CfgInitialize(XMpmc * InstancePtr, XMpmc_Config * ConfigPtr,
			u32 EffectiveAddr);

void XMpmc_EnableEcc(XMpmc * InstancePtr);
void XMpmc_DisableEcc(XMpmc * InstancePtr);
void XMpmc_SetControlEcc(XMpmc * InstancePtr, u32 Control);
u32 XMpmc_GetControlEcc(XMpmc * InstancePtr);
u32 XMpmc_GetStatusEcc(XMpmc * InstancePtr);
void XMpmc_ClearStatusEcc(XMpmc * InstancePtr);


void XMpmc_EnablePm(XMpmc *InstancePtr, u32 Mask);
void XMpmc_DisablePm(XMpmc *InstancePtr, u32 Mask);
void XMpmc_ClearDataBinPm(XMpmc * InstancePtr, u32 Mask);
u32 XMpmc_GetStatusPm(XMpmc * InstancePtr);
void XMpmc_ClearStatusPm(XMpmc * InstancePtr, u32 Mask);
Xuint64 XMpmc_GetGlobalCycleCountPm(XMpmc * InstancePtr);
Xuint64 XMpmc_GetDeadCycleCountPm(XMpmc * InstancePtr, u8 PortNum);
Xuint64 XMpmc_GetDataBinCountPm(XMpmc * InstancePtr, u8 PortNum , u8 Qualifier,
				u8 AccessType, u8 BinNumber);

void XMpmc_SetStaticPhyReg(XMpmc * InstancePtr, u32 Data);
u32 XMpmc_GetStaticPhyReg(XMpmc * InstancePtr);

XMpmc_Config *XMpmc_LookupConfig(u16 DeviceId);

/*
 * API Functions implemented in xmpmc_stats.c.
 */
void XMpmc_GetStatsEcc(XMpmc * InstancePtr, XMpmc_Stats * StatsPtr);
void XMpmc_ClearStatsEcc(XMpmc * InstancePtr);

/*
 * API Functions implemented in xmpmc_selftest.c.
 */
int XMpmc_SelfTest(XMpmc * InstancePtr);

/*
 * API Functions implemented in xmpmc_intr.c.
 */
void XMpmc_IntrGlobalEnable(XMpmc * InstancePtr);
void XMpmc_IntrGlobalDisable(XMpmc * InstancePtr);

void XMpmc_IntrEnable(XMpmc * InstancePtr, u32 Mask);
void XMpmc_IntrDisable(XMpmc * InstancePtr, u32 Mask);
void XMpmc_IntrClear(XMpmc * InstancePtr, u32 Mask);
u32 XMpmc_IntrGetEnabled(XMpmc * InstancePtr);
u32 XMpmc_IntrGetStatus(XMpmc * InstancePtr);

#ifdef __cplusplus
}
#endif

#endif /* end of protection macro */


