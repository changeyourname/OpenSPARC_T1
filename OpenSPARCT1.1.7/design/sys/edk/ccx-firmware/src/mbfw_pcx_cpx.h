/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_pcx_cpx.h
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
#ifndef MBFW_PCX_CPX_H_
#define MBFW_PCX_CPX_H_


#include "mbfw_types.h"



#ifdef  __cplusplus
extern "C" {
#endif


#define  PCX_PKT_VALID_BIT_POS            (123 - 96)
#define  PCX_PKT_RQTYP_BIT_POS            (118 - 96)
#define  PCX_PKT_NC_BIT_POS               (117 - 96)
#define  PCX_PKT_CPU_ID_BIT_POS           (112 - 96)
#define  PCX_PKT_CORE_ID_BIT_POS          (114 - 96)
#define  PCX_PKT_THREAD_ID_BIT_POS        (112 - 96)
#define  PCX_PKT_INVALIDATE_BIT_POS       (111 - 96)
#define  PCX_PKT_PREFETCH_BIT_POS         (110 - 96)
#define  PCX_PKT_BIS_BIT_POS              (109 - 96)
#define  PCX_PKT_BIS_BST_BIT_POS          (109 - 96)
#define  PCX_PKT_BST_BIT_POS              (110 - 96)
#define  PCX_PKT_L1_WAY_BIT_POS           (107 - 96)
#define  PCX_PKT_SIZE_BIT_POS             (104 - 96)
#define  PCX_PKT_IO_SPACE_BIT_POS         (103 - 96)


#define  PCX_PKT_GET_VALID(pcx_pkt)       (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_VALID_BIT_POS)      & 0x1)
#define  PCX_PKT_GET_RQTYP(pcx_pkt)       (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_RQTYP_BIT_POS)      & 0x1F)
#define  PCX_PKT_GET_NC(pcx_pkt)          (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_NC_BIT_POS)         & 0x1)
#define  PCX_PKT_GET_THREAD_ID(pcx_pkt)   (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_THREAD_ID_BIT_POS)  & 0x3)
#define  PCX_PKT_GET_CORE_ID(pcx_pkt)     (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_CORE_ID_BIT_POS)    & 0x7)
#define  PCX_PKT_GET_CPU_ID(pcx_pkt)      (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_CPU_ID_BIT_POS)     & 0x1F)
#define  PCX_PKT_GET_INVALIDATE(pcx_pkt)  (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_INVALIDATE_BIT_POS) & 0x1)
#define  PCX_PKT_GET_PREFETCH(pcx_pkt)    (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_PREFETCH_BIT_POS)   & 0x1)
#define  PCX_PKT_GET_BIS(pcx_pkt)         (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_BIS_BIT_POS)        & 0x1)
#define  PCX_PKT_GET_BST(pcx_pkt)         (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_BST_BIT_POS)        & 0x1)
#define  PCX_PKT_GET_BIS_BST(pcx_pkt)     (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_BIS_BST_BIT_POS)    & 0x3)
#define  PCX_PKT_GET_L1_WAY(pcx_pkt)      (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_L1_WAY_BIT_POS)     & 0x3)
#define  PCX_PKT_GET_SIZE(pcx_pkt)        (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_SIZE_BIT_POS)       & 0x7)
#define  PCX_PKT_GET_IO_SPACE(pcx_pkt)    (((pcx_pkt)->addr_hi_ctrl >> PCX_PKT_IO_SPACE_BIT_POS)   & 0x1)


#define  PCX_PKT_GET_T1_ADDR(pcx_pkt)     ((((uint64_t)((pcx_pkt)->addr_hi_ctrl & 0xff)) << 32) | (pcx_pkt)->addr_lo)


/* See the comments at the definition of taddr_opt_t */

#ifdef REGRESSION_MODE
#define  PCX_PKT_GET_T1_ADDR_OPT(pcx_pkt)   PCX_PKT_GET_T1_ADDR(pcx_pkt)
#else
#define  PCX_PKT_GET_T1_ADDR_OPT(pcx_pkt)   ((pcx_pkt)->addr_lo)
#endif


#define  PCX_PKT_IS_VALID(pcx_pkt)       ((pcx_pkt)->addr_hi_ctrl & (0x1 << PCX_PKT_VALID_BIT_POS))
#define  PCX_PKT_IS_NC(pcx_pkt)          ((pcx_pkt)->addr_hi_ctrl & (0x1 << PCX_PKT_NC_BIT_POS))
#define  PCX_PKT_IS_INVALIDATE(pcx_pkt)  ((pcx_pkt)->addr_hi_ctrl & (0x1 << PCX_PKT_INVALIDATE_BIT_POS))
#define  PCX_PKT_IS_PREFETCH(pcx_pkt)    ((pcx_pkt)->addr_hi_ctrl & (0x1 << PCX_PKT_PREFETCH_BIT_POS))
#define  PCX_PKT_IS_BIS_BST(pcx_pkt)     ((pcx_pkt)->addr_hi_ctrl & (0x3 << PCX_PKT_BIS_BST_BIT_POS))
#define  PCX_PKT_IS_IO_SPACE(pcx_pkt)    ((pcx_pkt)->addr_hi_ctrl & (0x1 << PCX_PKT_IO_SPACE_BIT_POS))

#define  PCX_PKT_IS_CACHEABLE(pcx_pkt)   (!PCX_PKT_IS_NC(pcx_pkt))



#define  PCX_PKT_FP_OPCODE_BIT_POS       (72 - 64)
#define  PCX_PKT_FP_CC_BIT_POS           (66 - 64)
#define  PCX_PKT_FP_RND_MODE_BIT_POS     (64 - 64)



#define  PCX_PKT_GET_FP_OPCODE(pcx_pkt)   (((pcx_pkt)->addr_lo >> PCX_PKT_FP_OPCODE_BIT_POS) & 0xff)
#define  PCX_PKT_GET_FP_CC(pcx_pkt)       (((pcx_pkt)->addr_lo >> PCX_PKT_FP_CC_BIT_POS) & 0x3)
#define  PCX_PKT_GET_FP_RND_MODE(pcx_pkt) (((pcx_pkt)->addr_lo >> PCX_PKT_FP_RND_MODE_BIT_POS) & 0x3)


/*
 *  fast path is provided for processing common case pcx packets.
 *  fast path is provided for load/store/ifill requests to cacheable
 *  T1 DRAM memory. T1 DRAM address must be < 4GB
 */


#define  PCX_PKT_COMMON_BIT_MASK  ((1 << PCX_PKT_NC_BIT_POS)         |  \
				   (1 << PCX_PKT_IO_SPACE_BIT_POS)   |  \
				   (1 << PCX_PKT_BIS_BIT_POS)        |  \
				   (1 << PCX_PKT_BST_BIT_POS)        |  \
				   (1 << PCX_PKT_PREFETCH_BIT_POS)   |  \
				   (1 << PCX_PKT_INVALIDATE_BIT_POS) |  \
				   (0xE << PCX_PKT_RQTYP_BIT_POS)    |  \
				   (0xFF))


#define  IS_COMMON_CASE_PCX_PKT(pcx_pkt)  (((pcx_pkt)->addr_hi_ctrl & PCX_PKT_COMMON_BIT_MASK) == 0)




#define  CPX_PKT_VALID_BIT_POS                  (144 - 128)
#define  CPX_PKT_RTNTYP_BIT_POS                 (140 - 128)
#define  CPX_PKT_L2MISS_BIT_POS                 (139 - 128)
#define  CPX_PKT_NC_BIT_POS                     (136 - 128)
#define  CPX_PKT_THREAD_ID_BIT_POS              (134 - 128)
#define  CPX_PKT_WV_BIT_POS                     (133 - 128)
#define  CPX_PKT_WAY_BIT_POS                    (131 - 128)
#define  CPX_PKT_IFILL_4B_BIT_POS               (130 - 128)
#define  CPX_PKT_ATOMIC_BIT_POS                 (129 - 128)
#define  CPX_PKT_PREFETCH_BIT_POS               (128 - 128)
#define  CPX_PKT_BIS_BIT_POS                    (125 - 96)


#define  CPX_PKT_SET_VALID(cpx_pkt, value)      ((cpx_pkt)->ctrl |= ((value & 0x1) << CPX_PKT_VALID_BIT_POS))
#define  CPX_PKT_SET_RTNTYP(cpx_pkt, value)     ((cpx_pkt)->ctrl |= ((value & 0xF) << CPX_PKT_RTNTYP_BIT_POS))
#define  CPX_PKT_SET_L2MISS(cpx_pkt, value)     ((cpx_pkt)->ctrl |= ((value & 0x1) << CPX_PKT_L2MISS_BIT_POS))
#define  CPX_PKT_SET_NC(cpx_pkt, value)         ((cpx_pkt)->ctrl |= ((value & 0x1) << CPX_PKT_NC_BIT_POS))
#define  CPX_PKT_SET_THREAD_ID(cpx_pkt, value)  ((cpx_pkt)->ctrl |= ((value & 0x3) << CPX_PKT_THREAD_ID_BIT_POS))
#define  CPX_PKT_SET_WV(cpx_pkt, value)         ((cpx_pkt)->ctrl |= ((value & 0x1) << CPX_PKT_WV_BIT_POS))
#define  CPX_PKT_SET_WAY(cpx_pkt, value)        ((cpx_pkt)->ctrl |= ((value & 0x3) << CPX_PKT_WAY_BIT_POS))
#define  CPX_PKT_SET_IFILL_4B(cpx_pkt, value)   ((cpx_pkt)->ctrl |= ((value & 0x1) << CPX_PKT_IFILL_4B_BIT_POS))
#define  CPX_PKT_SET_ATOMIC(cpx_pkt, value)     ((cpx_pkt)->ctrl |= ((value & 0x1) << CPX_PKT_ATOMIC_BIT_POS))
#define  CPX_PKT_SET_PREFETCH(cpx_pkt, value)   ((cpx_pkt)->ctrl |= ((value & 0x1) << CPX_PKT_PREFETCH_BIT_POS))
#define  CPX_PKT_SET_BIS(cpx_pkt, value)        ((cpx_pkt)->data3 |= ((value & 0x1) << CPX_PKT_BIS_BIT_POS))



#define  CPX_PKT_FP_CC_BIT_POS                (65 - 64)
#define  CPX_PKT_FP_CMP_FCC_BIT_POS           (67 - 64)
#define  CPX_PKT_FP_CMP_BIT_POS               (69 - 64)
#define  CPX_PKT_FP_EXC_BIT_POS               (72 - 64)

#define  CPX_PKT_SET_FP_CC(word, value)       ((word) |= ((value & 0x3) << CPX_PKT_FP_CC_BIT_POS))
#define  CPX_PKT_SET_FP_CMP_FCC(word, value)  ((word) |= ((value & 0x3) << CPX_PKT_FP_CMP_FCC_BIT_POS))
#define  CPX_PKT_SET_FP_CMP(word, value)      ((word) |= ((value & 0x1) << CPX_PKT_FP_CMP_BIT_POS))
#define  CPX_PKT_SET_FP_EXC(word, value)      ((word) |= ((value & 0x1F) << CPX_PKT_FP_EXC_BIT_POS))


#define  CPX_PKT_CTRL_ATOMIC                  (0x1 << CPX_PKT_ATOMIC_BIT_POS)


#define  CPX_PKT_STORE_ACK_INVALIDATE_ALL_BIT_POS   (123 - 96)

#define  CPX_PKT_SET_STORE_ACK_INVALIDATE_ALL(cpx_pkt, value)         \
				 ((cpx_pkt)->data3 |= ((value & 0x3) << CPX_PKT_STORE_ACK_INVALIDATE_ALL_BIT_POS))



#define INT_FLUSH_CPU_ID_SHIFT      8
#define INT_FLUSH_CPU_ID_MASK       0x1F
#define INT_FLUSH_INTR_TYPE_SHIFT   16
#define INT_FLUSH_INTR_TYPE_MASK    0x3
 
#define INT_FLUSH_INTR_TYPE_RESET   0x1

#define INT_FLUSH_DATA_MASK         0x3FFFF


#define CPU_ID_THREAD_ID_SHIFT      0x0
#define CPU_ID_THREAD_ID_MASK       0x3
#define CPU_ID_CORE_ID_SHIFT        0x2
#define CPU_ID_CORE_ID_MASK         0x7
#define CPU_ID_MASK                 0x1F


#define  CPX_PKT_RTNTYP_LOAD        0x0
#define  CPX_PKT_RTNTYP_IFILL       0x1
#define  CPX_PKT_RTNTYP_EVICT_INV   0x3
#define  CPX_PKT_RTNTYP_STORE_ACK   0x4
#define  CPX_PKT_RTNTYP_INT_FLUSH   0x7
#define  CPX_PKT_RTNTYP_FP          0x8


/* pflags is pre-initialized control bits */

#define  CPX_PKT_CTRL_LOAD(cpx_pkt, pflags)  ((cpx_pkt)->ctrl = ((1 << CPX_PKT_VALID_BIT_POS)  | \
						                 (pflags)                      | \
							         (1 << CPX_PKT_L2MISS_BIT_POS) | \
							         (CPX_PKT_RTNTYP_LOAD << CPX_PKT_RTNTYP_BIT_POS)))

#define  CPX_PKT_CTRL_STORE_ACK(cpx_pkt, pflags)  ((cpx_pkt)->ctrl = ((1 << CPX_PKT_VALID_BIT_POS) | \
							              (pflags)                     | \
							              (1 << CPX_PKT_NC_BIT_POS)    | \
							              (CPX_PKT_RTNTYP_STORE_ACK << CPX_PKT_RTNTYP_BIT_POS)))

#define  CPX_PKT_CTRL_EVICT_INV(cpx_pkt, pflags)  ((cpx_pkt)->ctrl = ((1 << CPX_PKT_VALID_BIT_POS) | \
							              (pflags)                     | \
							              (1 << CPX_PKT_NC_BIT_POS)    | \
							              (CPX_PKT_RTNTYP_EVICT_INV << CPX_PKT_RTNTYP_BIT_POS)))

#define  CPX_PKT_CTRL_EVICT_INVAL(cpx_pkt, pflags)  CPX_PKT_CTRL_EVICT_INV(cpx_pkt, pflags)  

#define  CPX_PKT_CTRL_IFILL_4B(cpx_pkt)  ((cpx_pkt)->ctrl = ((1 << CPX_PKT_VALID_BIT_POS)    | \
							     (1 << CPX_PKT_L2MISS_BIT_POS)   | \
							     (1 << CPX_PKT_IFILL_4B_BIT_POS) | \
							     (CPX_PKT_RTNTYP_IFILL << CPX_PKT_RTNTYP_BIT_POS)))

#define  CPX_PKT_CTRL_IFILL_0(cpx_pkt)   ((cpx_pkt)->ctrl = ((1 << CPX_PKT_VALID_BIT_POS)    | \
							     (1 << CPX_PKT_L2MISS_BIT_POS)   | \
							     (CPX_PKT_RTNTYP_IFILL << CPX_PKT_RTNTYP_BIT_POS)))

#define  CPX_PKT_CTRL_IFILL_1(cpx_pkt)   ((cpx_pkt)->ctrl = ((1 << CPX_PKT_VALID_BIT_POS)    | \
							     (1 << CPX_PKT_ATOMIC_BIT_POS)   | \
							     (CPX_PKT_RTNTYP_IFILL << CPX_PKT_RTNTYP_BIT_POS)))


#define  CPX_PKT_REFLECT_NC_THREAD_ID(cpx_pkt, pcx_pkt)                                                   \
                 ((cpx_pkt)->ctrl |= ( ((PCX_PKT_GET_THREAD_ID(pcx_pkt)) << CPX_PKT_THREAD_ID_BIT_POS) |  \
		                       ((PCX_PKT_GET_NC(pcx_pkt)) << CPX_PKT_NC_BIT_POS) ))


#define  CPX_PKT_REFLECT_THREAD_ID(cpx_pkt, pcx_pkt)  \
	       ((cpx_pkt)->ctrl |= ((PCX_PKT_GET_THREAD_ID(pcx_pkt)) << CPX_PKT_THREAD_ID_BIT_POS))
#define  CPX_PKT_REFLECT_NC(cpx_pkt, pcx_pkt)         \
	       ((cpx_pkt)->ctrl |= ((PCX_PKT_GET_NC(pcx_pkt)) << CPX_PKT_NC_BIT_POS))
#define  CPX_PKT_REFLECT_PREFETCH(cpx_pkt, pcx_pkt)   \
	       ((cpx_pkt)->ctrl |= ((PCX_PKT_GET_PREFETCH(pcx_pkt)) << CPX_PKT_PREFETCH_BIT_POS))


#define  CPX_PKT_REFLECT_BIS(cpx_pkt, pcx_pkt)        \
	       ((cpx_pkt)->data3 |= ((pcx_pkt)->addr_hi_ctrl & 0x00002000) << 16)
#define  CPX_PKT_REFLECT_ADDR_5_4(cpx_pkt, pcx_pkt)   \
	       ((cpx_pkt)->data3 |= ((pcx_pkt)->addr_lo & 0x00000030) << 21)
#define  CPX_PKT_REFLECT_ADDR_11_6(cpx_pkt, pcx_pkt)  \
	       ((cpx_pkt)->data3 |= ((pcx_pkt)->addr_lo & 0x00000fc0) << 10)
#define  CPX_PKT_REFLECT_CORE_ID(cpx_pkt, pcx_pkt)  \
	       ((cpx_pkt)->data3 |= (PCX_PKT_GET_CORE_ID(pcx_pkt) << (118 - 96)))


#define  CPX_PKT_INT_FLUSH_REFLECT_BITS_17_0(cpx_pkt, pcx_pkt) \
	       ((cpx_pkt)->data0 = ((pcx_pkt)->data0 & 0x0003FFFF))



#define  PCX_REQ_LOAD           0x00
#define  PCX_REQ_STORE          0x01
#define  PCX_REQ_CAS_LOAD       0x02
#define  PCX_REQ_CAS_STORE      0x03
#define  PCX_REQ_STREAM_LOAD    0x04
#define  PCX_REQ_STREAM_STORE   0x05
#define  PCX_REQ_SWAP_LDSTUB    0x06
#define  PCX_REQ_INT_FLUSH      0x09
#define  PCX_REQ_FP_1           0x0A
#define  PCX_REQ_FP_2           0x0B
#define  PCX_REQ_IFILL          0x10
#define  PCX_REQ_MAX            0x11







/*
 * OpenSPARC PCX Packet Format
 */

struct pcx_pkt {
#ifdef PCX2MB_5_BIT_REQ
    uint32_t  hi_ctrl;             /* bit 129 128  */
#endif
    uint32_t  addr_hi_ctrl;        /* bits 127:96  */
    uint32_t  addr_lo;             /* bits 95:64   */
    uint32_t  data1;               /* bits 63:32   */
    uint32_t  data0;               /* bits 31:0    */
};


/*
 * OpenSPARC CPX Packet Format
 */

struct cpx_pkt {
				   /* Note that bits 159:146 are ignored*/
    uint32_t  ctrl;                /* bits 144:128 */
    uint32_t  data3;               /* bits 127:96  */
    uint32_t  data2;               /* bits 95:64   */
    uint32_t  data1;               /* bits 63:32   */
    uint32_t  data0;               /* bits 31:0    */
};



#ifdef AURORA_CHECKSUM
#define  AURORA_HDR_SIZE  12
#else
#define  AURORA_HDR_SIZE  4
#endif


void  cpx_pkt_init(struct cpx_pkt *cpx_pkt);
void  print_cpx_pkt(struct cpx_pkt *pkt);
void  print_pcx_pkt(struct pcx_pkt *pcx_pkt);
void  send_cpx_pkt(int core_id, struct cpx_pkt *cpx_pkt);
int   recv_pcx_pkt(struct pcx_pkt *pcx_pkt, int timeout_count);

void send_aurora_pkt(void *pkt, int pkt_size);
int  recv_aurora_pkt(void *pkt, int pkt_size, int timeout_count);



#ifdef  __cplusplus
}
#endif


#endif /* ifndef MBFW_PCX_CPX_H_ */
