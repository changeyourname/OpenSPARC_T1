/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: jbi.h
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
/////////////////////////////////////////////////////////////////////////
`include "iop.h"

`define JBI_P_IDLE      3'b000
`define JBI_P_COHACK    3'b001
`define JBI_P_COHACKS   3'b010
`define JBI_P_COHACKD   3'b011
`define JBI_P_AOK_OFF   3'b100
`define JBI_P_AOK_ON    3'b101
`define JBI_P_DOK_OFF   3'b110
`define JBI_P_DOK_ON    3'b111

`define JBI_ADTYPE_JID_LO     0
`define JBI_ADTYPE_JID_HI     5
`define JBI_ADTYPE_AGTID_LO   2
`define JBI_ADTYPE_AGTID_HI   5
`define JBI_ADTYPE_TYPE_LO    6
`define JBI_ADTYPE_TYPE_HI    7

`define JBI_ADTYPE_IDLE    8'hFF
`define JBI_ADTYPE_ADDR    2'h3
`define JBI_ADTYPE_16DRTRN 2'h2
`define JBI_ADTYPE_64DRTRN 2'h1
`define JBI_ADTYPE_ERR     2'h0
`define JBI_ADTYPE_WRD     2'h0

`define JBI_AD_REPLACE_LO     0
`define JBI_AD_REPLACE_HI     4
`define JBI_AD_BTU_NUM_LO     6
`define JBI_AD_BTU_NUM_HI     7
`define JBI_AD_ADDR_LO        0
`define JBI_AD_ADDR_HI       42
`define JBI_AD_TRANS_LO      43
`define JBI_AD_TRANS_HI      47
`define JBI_AD_BE_LO         48
`define JBI_AD_BE_HI         63

`define JBI_AD_INT_CPUID_HI  40
`define JBI_AD_INT_CPUID_LO  36
`define JBI_AD_INT_AGTID_HI  35
`define JBI_AD_INT_AGTID_LO  31
`define JBI_AD_INT_AGTID_WIDTH  5
`define JBI_AD_INT_CPUID_WIDTH  5

`define JBI_TRANS_RD      5'h02
`define JBI_TRANS_RDD     5'h03
`define JBI_TRANS_RDS     5'h04
`define JBI_TRANS_RDSA    5'h05
`define JBI_TRANS_RDO     5'h06
`define JBI_TRANS_OWN     5'h07
`define JBI_TRANS_INV     5'h08
`define JBI_TRANS_NCWRC   5'h0A
`define JBI_TRANS_WRM     5'h0B
`define JBI_TRANS_WRB     5'h0C
`define JBI_TRANS_WRBC    5'h0D
`define JBI_TRANS_WRI     5'h0E
`define JBI_TRANS_WRIS    5'h0F
`define JBI_TRANS_NCRD    5'h10
`define JBI_TRANS_NCBRD   5'h11
`define JBI_TRANS_NCWR    5'h12
`define JBI_TRANS_NCBWR   5'h13
`define JBI_TRANS_INT     5'h14
`define JBI_TRANS_INTACK  5'h15
`define JBI_TRANS_INTNACK 5'h16
`define JBI_TRANS_XIR     5'h17
`define JBI_TRANS_CHANGE  5'h1A
`define JBI_TRANS_IDLE    5'h1F

`define JBI_INSTALL_INVALID 2'b00
`define JBI_INSTALL_SHARED  2'b01

`define JBI_JID_WIDTH        6
`define JBI_YID_WIDTH       10
`define JBI_YID_BUF_LO  0
`define JBI_YID_BUF_HI  1
`define JBI_YID_THR_LO  2
`define JBI_YID_THR_HI  7
`define JBI_YID_DWORD   8  // is read rtrn 16bytes
`define JBI_YID_WORD    9  // if read rtrn NOT 16bytes, which half is valid

//*****************************
// Memory Inbound
//*****************************
`define JBI_WDQ_DEPTH  16
`define JBI_WDQ_WIDTH  156
`define JBI_WDQ_ADDR_WIDTH 4

`define JBI_RDQ_DEPTH        16
`define JBI_RDQ_ADDR_WIDTH    4
`define JBI_RDQ_WIDTH       156
`define JBI_RDQ_DATA_WIDTH  128
`define JBI_RDQ_ECC_WIDTH    28

`define JBI_RHQ_DEPTH        16
`define JBI_RHQ_ADDR_WIDTH    4
`define JBI_RHQ_WIDTH        64

`define JBI_BIQ_DEPTH        16
`define JBI_BIQ_ADDR_WIDTH    4
`define JBI_BIQ_WIDTH        78
`define JBI_BIQ_DATA_WIDTH   64
`define JBI_BIQ_ECC_WIDTH    14

`define JBI_WRI_TAG_WIDTH   8

`define JBI_SCTAG_TAG_JID_LO      0
`define JBI_SCTAG_TAG_JID_HI      5
`define JBI_SCTAG_TAG_INSTALL     6
`define JBI_SCTAG_TAG_ERR         7
`define JBI_SCTAG_TAG_SUBLINE     8
`define JBI_SCTAG_TAG_RW          9
`define JBI_SCTAG_TAG_DEST_LO    10
`define JBI_SCTAG_TAG_DEST_HI    11
`define JBI_SCTAG_TAG_WIDTH      12
`define JBI_SCTAG_TAG_INSTALL_INVALID 1'b0
`define JBI_SCTAG_TAG_INSTALL_SHARED  1'b1

`define JBI_SCTAG_IN_RSV0_RW `JBI_SCTAG_IN_RSV0

//*****************************
// NCIO
//*****************************

// PRQQ
`define JBI_PRQQ_DEPTH      16
`define JBI_PRQQ_WIDTH      77  //64 + `JBI_YID_WIDTH + `UCB_SIZE_WIDTH
`define JBI_PRQQ_ADDR_WIDTH  4
`define JBI_PRQQ_HI_THRES   5'd1

`define JBI_PRQQ_D_LO        0
`define JBI_PRQQ_D_HI       63
`define JBI_PRQQ_BUF_LO     64
`define JBI_PRQQ_BUF_HI     65
`define JBI_PRQQ_THR_LO     66
`define JBI_PRQQ_THR_HI     71
`define JBI_PRQQ_DWORD      72 
`define JBI_PRQQ_WORD       73 
`define JBI_PRQQ_SZ_LO      74
`define JBI_PRQQ_SZ_HI      76

`define JBI_PRQQ_YID_LO     64  //`JBI_PRQQ_BUF_LO
`define JBI_PRQQ_YID_HI     73  //`JBI_PRQQ_WORD

`define JBI_PRQQ_DEST_0	    2'b00
`define JBI_PRQQ_DEST_4	    2'b01
`define JBI_PRQQ_DEST_5	    2'b10
`define JBI_PRQQ_DEST_OTH   2'b11

// PRTQ
`define JBI_PRTQ_DEPTH       16
`define JBI_PRTQ_WIDTH      139  //128 + `JBI_YID_WIDTH +1
`define JBI_PRTQ_ADDR_WIDTH   4
`define JBI_PRTQ_HI_THRES  5'd1

`define JBI_PRTQ_D_LO         0
`define JBI_PRTQ_D_HI       127
`define JBI_PRTQ_BUF_LO     128
`define JBI_PRTQ_BUF_HI     129
`define JBI_PRTQ_THR_LO     130
`define JBI_PRTQ_THR_HI     135
`define JBI_PRTQ_DWORD      136
`define JBI_PRTQ_WORD       137
`define JBI_PRTQ_UE         138

`define JBI_PRTQ_YID_LO     128 //`JBI_PRTQ_BUF_LO
`define JBI_PRTQ_YID_HI     137 //`JBI_PRTQ_WORD

// Mondo
`define JBI_MRQQ_DEPTH       16
`define JBI_MRQQ_WIDTH      139
`define JBI_MRQQ_ADDR_WIDTH   4

`define JBI_MRQQ_DATA_LO     0
`define JBI_MRQQ_DATA_HI   127
`define JBI_MRQQ_AGTID_LO  128
`define JBI_MRQQ_AGTID_HI  132
`define JBI_MRQQ_CPUID_LO  133
`define JBI_MRQQ_CPUID_HI  137
`define JBI_MRQQ_ERR       138

`define JBI_MAKQ_DEPTH      16
`define JBI_MAKQ_WIDTH      10
`define JBI_MAKQ_ADDR_WIDTH  4

`define JBI_MAKQ_AGTID_LO   0
`define JBI_MAKQ_AGTID_HI   4
`define JBI_MAKQ_CPUID_LO   5
`define JBI_MAKQ_CPUID_HI   9

//*****************************
// DEBUG
//*****************************
`define JBI_DBGQ_DEPTH        32
`define JBI_DBGQ_WIDTH        59
`define JBI_DBGQ_ADDR_WIDTH    5
`define JBI_DBG_ARB_THRES     30

`define JBI_DBGQ_D_LO       0
`define JBI_DBGQ_D_HI      47
`define JBI_DBGQ_TSTMP_LO  48
`define JBI_DBGQ_TSTMP_HI  57
`define JBI_DBGQ_DR        58

`define JBI_DBG_TSTAMP_WIDTH 10

//*****************************
// SSI (System Serial Interface)
//*****************************
`define JBI_SSI_ADDR_WIDTH  28
`define JBI_SSI_SZ_WIDTH     2
`define JBI_SSI_SZ_1BYTE    2'b00
`define JBI_SSI_SZ_2BYTE    2'b01
`define JBI_SSI_SZ_4BYTE    2'b10
`define JBI_SSI_SZ_8BYTE    2'b11

`define JBI_SSI_REQ_ADDR_LO   0
`define JBI_SSI_REQ_ADDR_HI  27
`define JBI_SSI_REQ_SZ_LO    28
`define JBI_SSI_REQ_SZ_HI    29
`define JBI_SSI_REQ_RW       30
`define JBI_SSI_REQ_WIDTH    31
`define JBI_SSI_REQ_START_LEN  6'd32

`define JBI_SSI_SCK_WIDTH  2
`define JBI_SSI_SCK_HI_CNT  `JBI_SSI_SCK_WIDTH'd2
`define JBI_SSI_SCK_LO_CNT  `JBI_SSI_SCK_WIDTH'd2

`define JBI_SSI_CSR_TOUT_WIDTH         25
`define JBI_SSI_CSR_TOUT_TIMEVAL_WIDTH 24
`define JBI_SSI_CSR_TOUT_TIMEVAL_LO     0
`define JBI_SSI_CSR_TOUT_TIMEVAL_HI    23
`define JBI_SSI_CSR_TOUT_ERREN         24

`define JBI_SSI_CSR_LOG_WIDTH    2
`define JBI_SSI_CSR_LOG_PARITY   1
`define JBI_SSI_CSR_LOG_TOUT     0

//*****************************
// CSR
//*****************************

`define MANUFACTURER_ID    6'h3E

`define JBI_CSR_ADDR_CONFIG         24'h00_0000
`define JBI_CSR_ADDR_CONFIG2        24'h00_0008
`define JBI_CSR_ADDR_INT_MRGN       24'h00_0010
`define JBI_CSR_ADDR_DEBUG          24'h00_4000
`define JBI_CSR_ADDR_DEBUG_ARB      24'h00_4100
`define JBI_CSR_ADDR_TEST_REG       24'h00_4400
`define JBI_CSR_ADDR_ERR_INJECT     24'h00_4800
`define JBI_CSR_ADDR_ERROR_CONFIG   24'h01_0000
`define JBI_CSR_ADDR_ERROR_LOG      24'h01_0020
`define JBI_CSR_ADDR_ERROR_OVF      24'h01_0028
`define JBI_CSR_ADDR_LOG_ENB        24'h01_0030
`define JBI_CSR_ADDR_SIG_ENB        24'h01_0038
`define JBI_CSR_ADDR_LOG_ADDR       24'h01_0040
`define JBI_CSR_ADDR_LOG_CTRL       24'h01_0048
`define JBI_CSR_ADDR_LOG_DATA0      24'h01_0050
`define JBI_CSR_ADDR_LOG_DATA1      24'h01_0058
`define JBI_CSR_ADDR_LOG_PAR        24'h01_0060
`define JBI_CSR_ADDR_LOG_NACK       24'h01_0070
`define JBI_CSR_ADDR_LOG_ARB        24'h01_0078
`define JBI_CSR_ADDR_L2_TIMEOUT     24'h01_0080
`define JBI_CSR_ADDR_ARB_TIMEOUT    24'h01_0088
`define JBI_CSR_ADDR_TRANS_TIMEOUT  24'h01_0090
`define JBI_CSR_ADDR_INTR_TIMEOUT   24'h01_0098
`define JBI_CSR_ADDR_MEMSIZE        24'h01_00A0
`define JBI_CSR_ADDR_PERF_CTL       24'h02_0000
`define JBI_CSR_ADDR_PERF_COUNT     24'h02_0008

`define JBI_CSR_ADDR_WIDTH  24
`define JBI_CSR_WIDTH       64

`define JBI_CSR_DBG_RSVD_WIDTH     33
`define JBI_CSR_DBG_TSWRAP_WIDTH    7
`define JBI_CSR_DBG_HI_WATER_WIDTH  5
`define JBI_CSR_DBG_LO_WATER_WIDTH  5
`define JBI_CSR_DBG_MAX_WAIT_WIDTH 10

`define JBI_CSR_DBG_MAX_WAIT_LO   0
`define JBI_CSR_DBG_MAX_WAIT_HI   9
`define JBI_CSR_DBG_AGGR_ARB     10
`define JBI_CSR_DBG_DATA_ARB     11
`define JBI_CSR_DBG_LO_WATER_LO  12
`define JBI_CSR_DBG_LO_WATER_HI  16
`define JBI_CSR_DBG_RSVD2        17
`define JBI_CSR_DBG_HI_WATER_LO  18
`define JBI_CSR_DBG_HI_WATER_HI  22
`define JBI_CSR_DBG_RSVD1        23
`define JBI_CSR_DBG_ALT          24
`define JBI_CSR_DBG_TSWRAP_LO    25
`define JBI_CSR_DBG_TSWRAP_HI    31
`define JBI_CSR_DBG_RSVD_LO      32
`define JBI_CSR_DBG_RSVD_HI      63

