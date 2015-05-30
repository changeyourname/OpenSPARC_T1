/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_fpu.c
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

#include "mbfw_types.h"
#include "mbfw_config.h"
#include "mbfw_l2_emul.h"
#include "mbfw_pcx_cpx.h"
#include "mbfw_fpu.h"

#include "softfloat.h"



#define FP_OPCODE_FADDS     0x41
#define FP_OPCODE_FADDD     0x42
#define FP_OPCODE_FSUBS     0x45
#define FP_OPCODE_FSUBD     0x46
#define FP_OPCODE_FMULS     0x49
#define FP_OPCODE_FMULD     0x4a
#define FP_OPCODE_FDIVS     0x4d
#define FP_OPCODE_FDIVD     0x4e

#define FP_OPCODE_FCMPS     0x51
#define FP_OPCODE_FCMPD     0x52

#define FP_OPCODE_FCMPES    0x55
#define FP_OPCODE_FCMPED    0x56

#define FP_OPCODE_FSTOX     0x81
#define FP_OPCODE_FDTOX     0x82
#define FP_OPCODE_FSTOI     0xd1
#define FP_OPCODE_FDTOI     0xd2

#define FP_OPCODE_FXTOS     0x84
#define FP_OPCODE_FXTOD     0x88
#define FP_OPCODE_FITOS     0xc4
#define FP_OPCODE_FITOD     0xc8

#define FP_OPCODE_FSTOD     0xc9
#define FP_OPCODE_FDTOS     0xc6

#define FP_OPCODE_FSMULD    0x69



/*
 * NOTE: For multi-core support, the following global variables
 *       may need to be in a data structure indexed by core id.
 */

static float64  fp_rs2_double;
static float32  fp_rs2_float;

static uint_t   fp_opcode;
static uint_t   fp_cc;
static uint_t   fp_rnd_mode;



static float64  cpu_fp_rs2_double[T1_NUM_OF_CPUS];
static float32  cpu_fp_rs2_float[T1_NUM_OF_CPUS];

static uint_t   cpu_fp_opcode[T1_NUM_OF_CPUS];
static uint_t   cpu_fp_cc[T1_NUM_OF_CPUS];
static uint_t   cpu_fp_rnd_mode[T1_NUM_OF_CPUS];



static void
return_fp_packet(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt,
		 uint64_t fp_rd, uint32_t fsr)
{
    cpx_pkt_init(cpx_pkt);

    CPX_PKT_SET_RTNTYP(cpx_pkt, CPX_PKT_RTNTYP_FP);
    CPX_PKT_REFLECT_NC_THREAD_ID(cpx_pkt, pcx_pkt);

    cpx_pkt->data0 = (uint32_t) fp_rd;
    cpx_pkt->data1 = (uint32_t) (fp_rd >> 32);
    cpx_pkt->data2 = fsr;

    send_cpx_pkt(PCX_PKT_GET_CORE_ID(pcx_pkt), cpx_pkt);

    return;
}

void
process_fp_1(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    float64  fp_rd;
    uint32_t fp_fsr;
    int cpu_id;

    fp_opcode   = PCX_PKT_GET_FP_OPCODE(pcx_pkt);
    fp_cc       = PCX_PKT_GET_FP_CC(pcx_pkt);
    fp_rnd_mode = PCX_PKT_GET_FP_RND_MODE(pcx_pkt);

    cpu_id = PCX_PKT_GET_CPU_ID(pcx_pkt);

    fp_rs2_double = ((float64)pcx_pkt->data1 << 32) | pcx_pkt->data0;
    fp_rs2_float  = pcx_pkt->data1;

    cpu_fp_rs2_double[cpu_id] = fp_rs2_double;
    cpu_fp_rs2_float[cpu_id]  = fp_rs2_float;

    cpu_fp_opcode[cpu_id]   = fp_opcode;
    cpu_fp_cc[cpu_id]       = fp_cc;
    cpu_fp_rnd_mode[cpu_id] = fp_rnd_mode;

    float_exception_flags = 0;
    float_rounding_mode   = fp_rnd_mode;

    switch (fp_opcode) {
    case FP_OPCODE_FITOS:
    case FP_OPCODE_FITOD:
    case FP_OPCODE_FSTOI:
    case FP_OPCODE_FDTOI:

    case FP_OPCODE_FXTOS:
    case FP_OPCODE_FXTOD:
    case FP_OPCODE_FSTOX:
    case FP_OPCODE_FDTOX:

    case FP_OPCODE_FSTOD:
    case FP_OPCODE_FDTOS:
	fp_fsr = 0;

	switch (fp_opcode) {

	case FP_OPCODE_FITOS:
	    fp_rd = int32_to_float32(fp_rs2_float);
	    fp_rd <<= 32;
	    break;

	case FP_OPCODE_FITOD:
	    fp_rd = int32_to_float64(fp_rs2_float);
	    break;

	case FP_OPCODE_FSTOD:
	    fp_rd = float32_to_float64(fp_rs2_float);
	    break;

	case FP_OPCODE_FSTOI:
	    float_rounding_mode = float_round_to_zero;  /* always round to zero */
	    fp_rd = float32_to_int32(fp_rs2_float);
	    fp_rd <<= 32;
	    break;

	case FP_OPCODE_FDTOI:
	    float_rounding_mode = float_round_to_zero;  /* always round to zero */
	    fp_rd = float64_to_int32(fp_rs2_double);
	    fp_rd <<= 32;
	    break;

	case FP_OPCODE_FDTOS:
	    fp_rd = float64_to_float32(fp_rs2_double);
	    fp_rd <<= 32;
	    break;

	case FP_OPCODE_FXTOS:
	    fp_rd = int64_to_float32(fp_rs2_double);
	    fp_rd <<= 32;
	    break;

	case FP_OPCODE_FXTOD:
	    fp_rd = int64_to_float64(fp_rs2_double);
	    break;

	case FP_OPCODE_FSTOX:
	    float_rounding_mode = float_round_to_zero;  /* always round to zero */
	    fp_rd = float32_to_int64(fp_rs2_float);
	    break;

	case FP_OPCODE_FDTOX:
	    float_rounding_mode = float_round_to_zero;  /* always round to zero */
	    fp_rd = float64_to_int64(fp_rs2_double);
	    break;

	default:
	    mbfw_printf("MBFW_ERROR: unknown single operand floating point "
				    "instruction opcode 0x%x \r\n", fp_opcode);
	    print_pcx_pkt(pcx_pkt);
	    mbfw_exit(1);
	    break;
	}

	CPX_PKT_SET_FP_CC(fp_fsr, fp_cc);
	CPX_PKT_SET_FP_EXC(fp_fsr, float_exception_flags);

	return_fp_packet(pcx_pkt, cpx_pkt, fp_rd, fp_fsr);
	break;

    default:
        /* two operand floating point instruction */
	break;
    }

    return;
}


void
process_fp_2(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt)
{
    float64   fp_rd;
    uint32_t  fp_fsr;

    uint_t    fp_cmp_fcc;
    int       fp_cmp_result;

    float64   fp_rs1_double;
    float32   fp_rs1_float;

    int       cpu_id;


    cpu_id = PCX_PKT_GET_CPU_ID(pcx_pkt);
    fp_rs2_double = cpu_fp_rs2_double[cpu_id];
    fp_rs2_float  = cpu_fp_rs2_float[cpu_id];

    fp_opcode   = cpu_fp_opcode[cpu_id];
    fp_cc       = cpu_fp_cc[cpu_id];
    fp_rnd_mode = cpu_fp_rnd_mode[cpu_id];


    fp_rs1_double = ((float64)pcx_pkt->data1 << 32) | pcx_pkt->data0;
    fp_rs1_float  = pcx_pkt->data1;

    fp_fsr = 0;
    float_exception_flags = 0;

    switch (fp_opcode) {

    case FP_OPCODE_FADDS:
	fp_rd = float32_add(fp_rs1_float, fp_rs2_float);
	fp_rd <<= 32;
	break;

    case FP_OPCODE_FADDD:
	fp_rd = float64_add(fp_rs1_double, fp_rs2_double);
	break;

    case FP_OPCODE_FSUBS:
	fp_rd = float32_sub(fp_rs1_float, fp_rs2_float);
	fp_rd <<= 32;
	break;

    case FP_OPCODE_FSUBD:
	fp_rd = float64_sub(fp_rs1_double, fp_rs2_double);
	break;

    case FP_OPCODE_FMULS:
	fp_rd = float32_mul(fp_rs1_float, fp_rs2_float);
	fp_rd <<= 32;
	break;

    case FP_OPCODE_FMULD:
	fp_rd = float64_mul(fp_rs1_double, fp_rs2_double);
	break;

    case FP_OPCODE_FSMULD:
	fp_rs1_double = float32_to_float64(fp_rs1_float);
	fp_rs2_double = float32_to_float64(fp_rs2_float);
	fp_rd = float64_mul(fp_rs1_double, fp_rs2_double);
	break;

    case FP_OPCODE_FDIVS:
	fp_rd = float32_div(fp_rs1_float, fp_rs2_float);
	fp_rd <<= 32;
	break;

    case FP_OPCODE_FDIVD:
	fp_rd = float64_div(fp_rs1_double, fp_rs2_double);
	break;

    case FP_OPCODE_FCMPS:
	fp_cmp_result = float32_eq(fp_rs1_float, fp_rs2_float);
	if (fp_cmp_result == 0) {
	    fp_cmp_result = float32_lt(fp_rs1_float, fp_rs2_float);
	    if (fp_cmp_result) {
		fp_cmp_fcc = 1;
	    } else {
		fp_cmp_fcc = 2;
	    }
	} else {
	    fp_cmp_fcc = 0;
	}
	CPX_PKT_SET_FP_CMP_FCC(fp_fsr, fp_cmp_fcc);
	CPX_PKT_SET_FP_CMP(fp_fsr, 1);

	float_exception_flags &= ~float_flag_invalid;
	if (float32_is_signaling_nan(fp_rs1_float) ||
	    float32_is_signaling_nan(fp_rs2_float)) {
	    float_exception_flags |= float_flag_invalid;
	}
	break;

    case FP_OPCODE_FCMPD:
	fp_cmp_result = float64_eq(fp_rs1_double, fp_rs2_double);
	if (fp_cmp_result == 0) {
	    fp_cmp_result = float64_lt(fp_rs1_double, fp_rs2_double);
	    if (fp_cmp_result) {
		fp_cmp_fcc = 1;
	    } else {
		fp_cmp_fcc = 2;
	    }
	} else {
	    fp_cmp_fcc = 0;
	}
	CPX_PKT_SET_FP_CMP_FCC(fp_fsr, fp_cmp_fcc);
	CPX_PKT_SET_FP_CMP(fp_fsr, 1);

	float_exception_flags &= ~float_flag_invalid;
	if (float64_is_signaling_nan(fp_rs1_double) ||
	    float64_is_signaling_nan(fp_rs2_double)) {
	    float_exception_flags |= float_flag_invalid;
	}
	break;

    case FP_OPCODE_FCMPES:
	fp_cmp_result = float32_eq(fp_rs1_float, fp_rs2_float);
	if (fp_cmp_result == 0) {
	    fp_cmp_result = float32_lt(fp_rs1_float, fp_rs2_float);
	    if (fp_cmp_result) {
		fp_cmp_fcc = 1;
	    } else {
		fp_cmp_fcc = 2;
	    }
	} else {
	    fp_cmp_fcc = 0;
	}
	CPX_PKT_SET_FP_CMP_FCC(fp_fsr, fp_cmp_fcc);
	CPX_PKT_SET_FP_CMP(fp_fsr, 1);
	break;

    case FP_OPCODE_FCMPED:
	fp_cmp_result = float64_eq(fp_rs1_double, fp_rs2_double);
	if (fp_cmp_result == 0) {
	    fp_cmp_result = float64_lt(fp_rs1_double, fp_rs2_double);
	    if (fp_cmp_result) {
		fp_cmp_fcc = 1;
	    } else {
		fp_cmp_fcc = 2;
	    }
	} else {
	    fp_cmp_fcc = 0;
	}
	CPX_PKT_SET_FP_CMP_FCC(fp_fsr, fp_cmp_fcc);
	CPX_PKT_SET_FP_CMP(fp_fsr, 1);
	break;
    default:
	mbfw_printf("MBFW_ERROR: process_fp_2(): unknown two operand floating "
			       "point instruction opcode 0x%x \r\n", fp_opcode);
	print_pcx_pkt(pcx_pkt);
	mbfw_exit(1);
	break;
    }

    CPX_PKT_SET_FP_CC(fp_fsr, fp_cc);
    CPX_PKT_SET_FP_EXC(fp_fsr, float_exception_flags);

    return_fp_packet(pcx_pkt, cpx_pkt, fp_rd, fp_fsr);

    return;
}
