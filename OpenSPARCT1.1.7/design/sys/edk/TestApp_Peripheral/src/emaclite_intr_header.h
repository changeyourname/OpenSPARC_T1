#define TESTAPP_GEN

/* $Id: emaclite_intr_header.h,v 1.1 2007/05/16 07:17:10 mta Exp $ */


#include "xbasic_types.h"
#include "xstatus.h"

XStatus EmacLiteExample(XIntc* IntcInstancePtr,
                        XEmacLite* EmacLiteInstPtr,
                        Xuint16 EmacLiteDeviceId,
                        Xuint16 EmacLiteIntrId);


