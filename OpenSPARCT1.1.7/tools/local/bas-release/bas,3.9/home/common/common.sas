// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: common.sas
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================

@SIM_set_prompt ("bas");

//  Machine configuration
read-configuration "common.conf"

#ifdef ELF
load-kernel common.exe
#else
load-veri-file mem.image
#endif   // ifdef ELF

#if defined(RTL) || defined(PLI_REPLAY)
#undef CIOP0
#undef MOM
#endif

#ifdef CIOP0
ciop0.cmd    "config_all"
#endif

#ifdef ONE_THREAD
pdisable -all
penable th00
#elif defined(TWO_THREADS)
pdisable -all
penable th00
penable th01
#elif defined(FOUR_THREADS)
pdisable -all
penable th00
penable th01
penable th02
penable th03
#endif   // ifdef ONE_THREAD

// get symbol address
@def get_addr(name):
	cmd= "$PERL_CMD -ne 'if(/%s\s+(\w+)/){ print$1;last}' symbol.tbl " % name
	addr_str= os.popen(cmd, "r").readline();
	if not addr_str:
		addr = 0
	else:
		addr =  string.atol(addr_str,16)
	return addr

// Script to single step
@def ss_n(thid, num) :
	th_str= "l%d" % thid
	while (num > 0) :
		sstepi_cmd_RS(th_str)
		num = num-1;

// Script to step and print regs for N cycles
@def ss_and_pr(thid, num) :
	th_str= "l%d" % thid
	a_str = "-all"
	while (num > 0) :
		sstepi_cmd_RS(th_str)
		pregs_cmd_RS(thid,a_str)
		num = num-1;

// riesling shortcut
@arch00 = rsys.getCpuPtr(0).getCorePtr(0).getStrandPtr(0).getArchStatePtr()
@mmu00 = rsys.getCpuPtr(0).getCorePtr(0).getStrandPtr(0).getMmuPtr()

// if defined, step through instructions silently, also turn off all debugging
// output.
#ifdef STEP_QUIET
@RS_set_quiet(1)
@conf.socket0.setvar = "debug_level=0"
@conf.socket0.setvar = "tlb_debug=0"
@conf.swvmem0.setvar = "debug_level=0"
#endif   // ifdef STEP_QUIET

#if defined(MOM)

@conf.mom0.call= "init-anno-sas"
@conf.mom0.setvar= "itlb0_size_v=0"
@conf.mom0.setvar= "dtlb0_size_v=0"
@conf.mom0.setvar= "SKIP_UNCACHED=0"
@conf.mom0.setvar= "en_thrd_prio_v=0"
@conf.mom0.setvar= "dram_banknum_v=8"
@conf.mom0.setvar= "dram_dimmpos_v=38"
@conf.mom0.setvar= "delay_dram_ras_v=4"
@conf.mom0.setvar= "delay_dram_ras2ras_samebank_v=14"
@conf.mom0.setvar= "delay_dram_rd_rndtrp_v=3"
@conf.mom0.setvar= "delay_missq_dram_v=0"
@conf.mom0.setvar= "VERIF_ENV=1"

#if defined(MOM_DRAM_CLOCK_RATIO_9)
@conf.mom0.setvar= "dram_clock_ratio_v=9"
#else
@conf.mom0.setvar= "dram_clock_ratio_v=7"
#endif

#if defined(MOM_RSLT)
@conf.mom0.setvar= "PRINT_RSLT=1"
#endif

#ifdef ONE_THREAD
@conf.mom0.setvar= "thread_num_per_proc_v=1"
#else
@conf.mom0.setvar= "thread_num_per_proc_v=4"
#endif

#if defined(SP7)
@conf.mom0.setvar= "proc_num_v=8"
#elif defined(SP6)
@conf.mom0.setvar= "proc_num_v=7"
#elif defined(SP5)
@conf.mom0.setvar= "proc_num_v=6"
#elif defined(SP4)
@conf.mom0.setvar= "proc_num_v=5"
#elif defined(SP3)
@conf.mom0.setvar= "proc_num_v=4"
#elif defined(SP2)
@conf.mom0.setvar= "proc_num_v=3"
#elif defined(SP1)
@conf.mom0.setvar= "proc_num_v=2"
#elif defined(SP0)
@conf.mom0.setvar= "proc_num_v=1"
#endif

@conf.mom0.PASS= get_addr(' T0_GoodTrap_0x100')
@conf.mom0.FAIL= get_addr(' T0_BadTrap_0x101')
@conf.mom0.T1PASS= get_addr(' T1_GoodTrap_0x101')
@conf.mom0.T1FAIL= get_addr(' T1_BadTrap_0x101')
@conf.mom0.HPASS= get_addr(' HT0_GoodTrap_0x100')
@conf.mom0.HFAIL= get_addr(' HT0_BadTrap_0x101')
@conf.mom0.DC_ON= get_addr('mom_enable_l1d')
@conf.mom0.DC_OFF= get_addr('mom_disable_l1d')
@conf.mom0.IC_ON= get_addr('mom_enable_l1i')
@conf.mom0.IC_OFF= get_addr('mom_disable_l1i')
@conf.mom0.PRINTF= get_addr('simics_printf')

#ifdef FINISH_COUNT
@conf.mom0.FINI_CNT= FINISH_COUNT
#endif

#if defined(MAX_CYCLE)
@conf.mom0.MAX_CYC= MAX_CYCLE
#endif

#if defined(MOM_STAT)
@conf.mom0.setvar= "THREAD_BASED_STAT=1"
@conf.mom0.setvar= "print_all_mom_stat=1"
#endif

@conf.mom0.setvar= "START_SIM_IMM=1"
@conf.mom0.start_cycle= 1

#ifndef MOM_STEP
run 
quit
#endif

#else   // if defined(MOM)

// intend to replace THREADS+SPx, THREAD_MASK=10xxxx01 is equivalent to
// 'SP0 SP3 THREADS=10000001'
#if defined(THREAD_MASK)

@conf.swvmem0.thread_mask = THREAD_MASK

#else

// THREADS must work with SPx to set proper CMP registers
#if defined(THREADS)
@conf.swvmem0.threads = THREADS
#endif

#if defined(IGNORE_SP0) || !defined(SP0)
@conf.swvmem0.ignore_sparc =+ 0
#endif   // if defined(IGNORE_SP0) || !defined(SP0)
#if defined(IGNORE_SP1) || !defined(SP1)
@conf.swvmem0.ignore_sparc =+ 1
#endif   // if defined(IGNORE_SP1) || !defined(SP1)
#if defined(IGNORE_SP2) || !defined(SP2)
@conf.swvmem0.ignore_sparc =+ 2
#endif   // if defined(IGNORE_SP2) || !defined(SP2)
#if defined(IGNORE_SP3) || !defined(SP3)
@conf.swvmem0.ignore_sparc =+ 3
#endif   // if defined(IGNORE_SP3) || !defined(SP3)
#if defined(IGNORE_SP4) || !defined(SP4)
@conf.swvmem0.ignore_sparc =+ 4
#endif   // if defined(IGNORE_SP4) || !defined(SP4)
#if defined(IGNORE_SP5) || !defined(SP5)
@conf.swvmem0.ignore_sparc =+ 5
#endif   // if defined(IGNORE_SP5) || !defined(SP5)
#if defined(IGNORE_SP6) || !defined(SP6)
@conf.swvmem0.ignore_sparc =+ 6
#endif   // if defined(IGNORE_SP6) || !defined(SP6)
#if defined(IGNORE_SP7) || !defined(SP7)
@conf.swvmem0.ignore_sparc =+ 7
#endif   // if defined(IGNORE_SP7) || !defined(SP7)

#endif   // if defined(THREAD_MASK)

#if defined(THREAD_STATUS_ADDR)
@conf.swvmem0.thread_status= THREAD_STATUS_ADDR
#endif   // if defined(THREAD_STATUS_ADDR)

//TODO  riesling does not support these options yet. 5/5/05
#if defined(CONSOLE)
@conf.swvmem0.console = 1
#else
@conf.swvmem0.printf= get_addr('simics_printf')
#endif

#if defined(SAS_RUN)

#if defined(THREAD_MASK)
penable -mask=THREAD_MASK
#else
pdisable -all
penable th00
#endif   // if defined(THREAD_MASK)

// we will rely on the good/bad_trap symbols in symbol.table to determine
// proper good/bad trap setting
//#if !defined(SAS_IACT) || !(defined(RTL) || defined(PLI_RUN))
//// set the breakpoints only in interactive mode or batch mode
////@conf.swvmem0.good_trap =+ get_addr('\.TRAPS\.T0_GoodTrap_0x100')
////@conf.swvmem0.good_trap =+ get_addr('\.TRAPS\.T1_GoodTrap_0x100')
////@conf.swvmem0.good_trap =+ get_addr('\.HTRAPS\.HT0_GoodTrap_0x100')
////@conf.swvmem0.good_trap =+ get_addr('\.HTRAPS\.HT0_GoodTrap_0x1a0')
////@conf.swvmem0.bad_trap =+ get_addr('\.TRAPS\.T0_BadTrap_0x101')
////@conf.swvmem0.bad_trap =+ get_addr('\.TRAPS\.T1_BadTrap_0x101')
////@conf.swvmem0.bad_trap =+ get_addr('\.HTRAPS\.HT0_BadTrap_0x101')
////@conf.swvmem0.bad_trap =+ get_addr('\.HTRAPS\.HT0_BadTrap_0x1a1')
//@conf.swvmem0.good_trap =+ get_addr('\.HTRAPS\.good_trap')
//@conf.swvmem0.bad_trap =+ get_addr('\.HTRAPS\.bad_trap')
//#endif

#if defined(MAX_CYCLE)
@conf.swvmem0.max_cycle = MAX_CYCLE
#endif   // if defined(MAX_CYCLE)

// if not to go into interactive mode, then let it run until hit a breakpoint
#if !defined(SAS_IACT)
run
quit
#endif   // if !defined(SAS_IACT)

#elif defined(RTL) || defined(PLI_RUN)
pli-run -1
quit
#endif   // if-else defined(SAS_RUN)

#endif   // if-else defined(MOM)

