/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_xintc.c
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
#include <xparameters.h>
#include <xintc.h>


#include "mbfw_types.h"
#include "mbfw_xintc.h"



#ifdef T1_FPGA_OPB
#define MBFW_XINTC_DEVICE_ID    XPAR_OPB_INTC_0_DEVICE_ID
#else
#define MBFW_XINTC_DEVICE_ID    XPAR_XPS_INTC_0_DEVICE_ID
#endif



static XIntc xintc;


static int
xintc_setup(XIntc *xintc_instance, Xuint16 xintc_device_id)
{
    XStatus status;

    status = XIntc_Initialize(xintc_instance, xintc_device_id);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XIntc_Initialize() failed with status 0x%x \r\n", status);
        return -1;
    }

    status = XIntc_SelfTest(xintc_instance);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XIntc_SelfTest() failed with status 0x%x \r\n", status);
        return -1;
    }

    microblaze_enable_interrupts();

    status = XIntc_Start(xintc_instance, XIN_REAL_MODE);
    if (status != XST_SUCCESS) {
	mbfw_printf("MBFW_ERROR: XIntc_Start() failed with status 0x%x \r\n", status);
        return -1;
    }

    return 0;
}


XIntc *
mbfw_xintc_init(void)
{
    XStatus  status;
    Xuint16  xintc_device_id;

    xintc_device_id = MBFW_XINTC_DEVICE_ID;
    status = xintc_setup(&xintc, xintc_device_id);
    if (status < 0) {
	return NULL;
    }

    return &xintc;
}
