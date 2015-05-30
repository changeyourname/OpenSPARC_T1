#ifndef MBFW_XLLTEMAC_INTR_H_
#define MBFW_XLLTEMAC_INTR_H_

#if (! defined T1_FPGA_XEMAC) && (! defined T1_FPGA_XEMACLITE)

#include <xintc.h>

#include "mbfw_snet.h"

#ifdef  __cplusplus
extern "C" {
#endif


int  eth_init(struct snet *snetp, XIntc *intc_instance, struct eth_init_data *data);


#ifdef  __cplusplus
}
#endif


#endif /* if (! defined T1_FPGA_XEMAC) && (! defined T1_FPGA_XEMACLITE) */


#endif /* ifndef MBFW_XLLTEMAC_INTR_H_ */
