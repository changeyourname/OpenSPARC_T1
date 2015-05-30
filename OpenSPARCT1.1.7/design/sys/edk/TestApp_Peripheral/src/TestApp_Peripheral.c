/*
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A 
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR 
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION 
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE 
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO 
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO 
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE 
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY 
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
 * Xilinx EDK 10.1.03 EDK_K_SP3.6
 *
 * This file is a sample test application
 *
 * This application is intended to test and/or illustrate some 
 * functionality of your system.  The contents of this file may
 * vary depending on the IP in your system and may use existing
 * IP driver functions.  These drivers will be generated in your
 * XPS project when you run the "Generate Libraries" menu item
 * in XPS.
 *
 * Your XPS project directory is at:
 *    E:\OpenSparcT1\Virtex5_101\xup_bsb2\
 */


// Located in: microblaze_0/include/xparameters.h
#include "xparameters.h"

#include "mb_interface.h"

#include "stdio.h"

#include "xintc.h"
#include "intc_header.h"
#ifdef EDK_FPGA_ETHERNETLITE
#include "xemaclite.h"
#include "emaclite_header.h"
#include "emaclite_intr_header.h"
#else
#include "xlltemac.h"
#include "xlltemac_example.h"
#include "lltemac_header.h"
#include "lltemac_intr_header.h"
#include "xlldma.h"
#endif
#include "uartlite_header.h"

//====================================================

int main (void) {


   static XIntc intc;

   /*
    * Enable and initialize cache
    */
   #if XPAR_MICROBLAZE_0_USE_ICACHE
      microblaze_init_icache_range(0, XPAR_MICROBLAZE_0_CACHE_BYTE_SIZE);
      microblaze_enable_icache();
   #endif

   #if XPAR_MICROBLAZE_0_USE_DCACHE
      microblaze_init_dcache_range(0, XPAR_MICROBLAZE_0_DCACHE_BYTE_SIZE);
      microblaze_enable_dcache();
   #endif

#ifdef EDK_FPGA_ETHERNETLITE
   static XEmacLite Ethernet_MAC_EmacLite;
#else
   static XLlTemac Hard_Ethernet_MAC_LlTemac;
   static XLlDma  Hard_Ethernet_MAC_LlDma;
#endif


   print("-- Entering main() --\r\n");


   {
      XStatus status;
      
      print("\r\n Runnning IntcSelfTestExample() for xps_intc_0...\r\n");
      
      status = IntcSelfTestExample(XPAR_XPS_INTC_0_DEVICE_ID);
      
      if (status == 0) {
         print("IntcSelfTestExample PASSED\r\n");
      }
      else {
         print("IntcSelfTestExample FAILED\r\n");
      }
   } 
	
   {
       XStatus Status;

       Status = IntcInterruptSetup(&intc, XPAR_XPS_INTC_0_DEVICE_ID);
       if (Status == 0) {
          print("Intc Interrupt Setup PASSED\r\n");
       } 
       else {
         print("Intc Interrupt Setup FAILED\r\n");
      } 
   }

   /*
    * Peripheral SelfTest will not be run for RS232_Uart_1
    * because it has been selected as the STDOUT device
    */


#ifdef EDK_FPGA_ETHERNETLITE
   {
      XStatus status;
      
      print("\r\nRunning EMACLiteSelfTestExample() for Ethernet_MAC...\r\n");
      status = EMACLiteSelfTestExample(XPAR_ETHERNET_MAC_DEVICE_ID);
      if (status == 0) {
         print("EMACLiteSelfTestExample PASSED\r\n");
      }
      else {
         print("EMACLiteSelfTestExample FAILED\r\n");
      }
   }
   {
      XStatus Status;

      print("\r\n Running Interrupt Test  for Ethernet_MAC...\r\n");
      
      Status = EmacLiteExample(&intc, &Ethernet_MAC_EmacLite, \
                               XPAR_ETHERNET_MAC_DEVICE_ID, \
                               XPAR_XPS_INTC_0_ETHERNET_MAC_IP2INTC_IRPT_INTR);
	
      if (Status == 0) {
         print("EmacLite Interrupt Test PASSED\r\n");
      } 
      else {
         print("EmacLite Interrupt Test FAILED\r\n");
      }

   }
#else
   /* TemacPolledExample does not support SGDMA      
   {
      XStatus status;

      print("\r\n Runnning TemacPolledExample() for Hard_Ethernet_MAC...\r\n");

      status = TemacPolledExample( XPAR_HARD_ETHERNET_MAC_CHAN_0_DEVICE_ID,
                                   );

      if (status == 0) {
         print("TemacPolledExample PASSED\r\n");
      }
      else {
         print("TemacPolledExample FAILED\r\n");
      }

   }
   */

   {
      XStatus Status;

      print("\r\nRunning TemacSgDmaIntrExample() for Hard_Ethernet_MAC...\r\n");

      Status = TemacSgDmaIntrExample(&intc, &Hard_Ethernet_MAC_LlTemac,
                     &Hard_Ethernet_MAC_LlDma,
                     XPAR_HARD_ETHERNET_MAC_CHAN_0_DEVICE_ID,
                     XPAR_XPS_INTC_0_HARD_ETHERNET_MAC_TEMACINTC0_IRPT_INTR,
                     XPAR_LLTEMAC_0_LLINK_CONNECTED_DMARX_INTR,
                     XPAR_LLTEMAC_0_LLINK_CONNECTED_DMATX_INTR);

      if (Status == 0) {
         print("Temac Interrupt Test PASSED.\r\n");
      } 
      else {
         print("Temac Interrupt Test FAILED.\r\n");
      }

   }
#endif


   {
      XStatus status;
      
      print("\r\nRunning UartLiteSelfTestExample() for debug_module...\r\n");
      status = UartLiteSelfTestExample(XPAR_DEBUG_MODULE_DEVICE_ID);
      if (status == 0) {
         print("UartLiteSelfTestExample PASSED\r\n");
      }
      else {
         print("UartLiteSelfTestExample FAILED\r\n");
      }
   }
   /*
    * Disable cache and reinitialize it so that other
    * applications can be run with no problems
    */
   #if XPAR_MICROBLAZE_0_USE_DCACHE
      microblaze_disable_dcache();
      microblaze_init_dcache_range(0, XPAR_MICROBLAZE_0_DCACHE_BYTE_SIZE);
   #endif

   #if XPAR_MICROBLAZE_0_USE_ICACHE
      microblaze_disable_icache();
      microblaze_init_icache_range(0, XPAR_MICROBLAZE_0_CACHE_BYTE_SIZE);
   #endif


   print("-- Exiting main() --\r\n");
   return 0;
}

