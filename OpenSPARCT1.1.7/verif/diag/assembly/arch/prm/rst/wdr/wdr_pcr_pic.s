/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: wdr_pcr_pic.s
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
/***********************************************************************
 * Name:   
 * Date:   
 *
 * Description:
 *
 **********************************************************************/

#define MY_PASS setx 0x82000, %r1, %r2; jmp %r2;nop
#define MY_FAIL setx 0x82020, %r1, %r2; jmp %r2;nop

#include "err_defines.h"

#define ASI_LSU_CTL_REG 0x45
#define ASI_SPARC_ERROR_EN_REG 0x4b
#define  L2_BANK_ADDR       0x40

#define  My_Power_On_Reset setx check,  %g2, %g1;  jmpl    %g1, %g0; nop 

.global check 

SECTION .RED_SEC0 TEXT_VA=3006000, DATA_VA=3008000

attr_text {
        Name=.RED_SEC0,
        hypervisor
}

attr_data {
        Name=.RED_SEC0,
        hypervisor
}


check:
	nop
!	wr  %g0, 0, %ccr
!	wr  %g0, 0, %asi
        wrpr    %g0, 0, %cwp
	clr %g6

change_regs_values:
        setx red_data, %i5, %g7
       	ldx [%g7], %g1 !! set an integer register

	wr %g0, %g1, %asr16 !! perf_control reg
	wr %g0, %g1, %asr17 !! perf_instrumentation_counter reg
	nop;nop;nop;nop


set_wdr:
        setx    0x9800000800, %i0, %i1  ! PA of INT_VEC_DIS
        setx    0x0000010002, %i0, %i2  ! type=reset traptype=WDR

read_pic:
	rd      %asr17, %g5

        stx     %i2, [%i1]

wdr_loop:
        add %g0, 1, %o1
        cmp %o1, 100
        ble wdr_loop
        nop

        MY_FAIL
        nop


#define  My_Watchdog_Reset rd      %asr17, %g4; \
			   setx    pcr,  %o5, %o6; \
                           jmpl    %o6, %g0; nop


.global pcr 
pcr:
	set	0x222, %i1
        rd 	%asr16, %i2
        sub     %i2, %i1, %i3
        brnz    %i3, bad_end
        nop

pic:
	cmp	%g4, %g5
	bne	bad_end
	nop


        MY_PASS

bad_end:
        MY_FAIL

good_end:
        MY_PASS

.data
red_data:
        .word 0x5aaaaaaa, 0x5aaaaaaa
        .word 0x00000000, 0x00000000

temp_data:
        .word 0x00000000, 0x00000000


#include "boot.s"

.text
.global main
main:
    MY_FAIL


