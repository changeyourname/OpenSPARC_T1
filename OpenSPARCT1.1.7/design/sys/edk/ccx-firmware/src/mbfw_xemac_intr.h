/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_xemac_intr.h
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
#ifndef MBFW_XEMAC_INTR_H_
#define MBFW_XEMAC_INTR_H_

#ifdef T1_FPGA_XEMAC

#include <xintc.h>

#include "mbfw_snet.h"


#ifdef  __cplusplus
extern "C" {
#endif

int  eth_init(struct snet *snetp, XIntc *intc_instance, struct eth_init_data *data);

#ifdef  __cplusplus
}
#endif


#endif /* ifdef T1_FPGA_XEMAC */


#endif /* ifndef MBFW_XEMAC_INTR_H_ */
