// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: pc_cmp.v
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

`include "ifu.h"
`define GOOD_TRAP_COUNTER 32
module pc_cmp(/*AUTOARG*/
   // Inputs
	      clk,
	rst_l      
   );
   input clk;
   input rst_l;
   
  // trap register 
   reg [31:0] 	 finish_mask, diag_mask;
   reg [39:0] 	 good_trap[`GOOD_TRAP_COUNTER-1:0];
   reg [39:0] 	 bad_trap [`GOOD_TRAP_COUNTER-1:0];
   reg [31:0] 	 active_thread, back_thread, good_delay;
   
   reg [31:0] 	 good, good_for;
   reg [7:0] 	 done;
   reg           dum;
   reg           hit_bad;
   
   integer       max, time_tmp, trap_count;
   
   //wire 	 spc0_inst_done;
   wire [1:0] 	 spc0_thread_id;   
   wire [63:0] 	 spc0_rtl_pc;

   //wire 	 spc1_inst_done;
   wire [1:0] 	 spc1_thread_id;   
   wire [63:0] 	 spc1_rtl_pc;

   //wire 	 spc2_inst_done;
   wire [1:0] 	 spc2_thread_id;   
   wire [63:0] 	 spc2_rtl_pc;
   
   //wire 	 spc3_inst_done;
   wire [1:0] 	 spc3_thread_id;   
   wire [63:0] 	 spc3_rtl_pc;
   
   //wire 	 spc4_inst_done;
   wire [1:0] 	 spc4_thread_id;   
   wire [63:0] 	 spc4_rtl_pc;
   
   //wire 	 spc5_inst_done;
   wire [1:0] 	 spc5_thread_id;   
   wire [63:0] 	 spc5_rtl_pc;
   
   //wire 	 spc6_inst_done;
   wire [1:0] 	 spc6_thread_id;   
   wire [63:0] 	 spc6_rtl_pc;
   
   //wire 	 spc7_inst_done;
   wire [1:0] 	 spc7_thread_id;   
   wire [63:0] 	 spc7_rtl_pc;

   wire 	 sas_m0,  sas_m1, sas_m2, sas_m3, sas_m4, sas_m5, sas_m6, sas_m7;
   reg 		 spc0_inst_done,  spc1_inst_done, spc2_inst_done, spc3_inst_done,
		 spc4_inst_done,  spc5_inst_done, spc6_inst_done, spc7_inst_done;
   reg 		 sas_def;
   reg           max_cycle;
   reg [4:0] 	 thread_status[31:0];
   integer 	 good_trap_count;
   integer 	 bad_trap_count;
   //argment for stub
   reg [7:0] 	 stub_mask;
   reg [7:0]     stub_good;
   reg 		 good_flag;
   
   //use this for the second reset.
  initial begin
     back_thread = 0;
     good_delay  = 0;
     good_for    = 0;
     stub_good   = 0;
       
     if($test$plusargs("use_sas_tasks"))sas_def = 1;
     else sas_def = 0;
     if($test$plusargs("stop_2nd_good"))good_flag= 1;
     else good_flag = 0;
     
     max_cycle = 1;
     if($test$plusargs("thread_timeout_off"))max_cycle = 0;
  end
  //-----------------------------------------------------------
  // check bad trap   
   task check_bad_trap;
      input [39:0] pc;
      input [2:0] i;
      input [4:0] thread;
      integer l, j;
      
      begin
	 if(active_thread[thread])begin
	    for(l = 0; l < bad_trap_count; l = l + 1)begin
	       if(bad_trap[l] == pc)begin
		  hit_bad     = 1'b1;
		  good[l]     = 1;
		  `TOP_MOD.diag_done = 1;
`ifdef INCLUDE_SAS_TASKS
		  if(sas_def && ($bw_list(`TOP_MOD.list_handle, 1) == 0))begin//wait until drain out.
`else
	             if(sas_def)begin
`endif			$display("%0d: Info - > Hit Bad trap. spc(%0d) thread(%0d)", $time, i, l % 4);
			`MONITOR_PATH.fail("HIT BAD TRAP");
		     end
		     else begin
			$display("%0d: Info - > Hit Bad trap. spc(%0d) thread(%0d)", $time, i, l % 4);
			`MONITOR_PATH.fail("HIT BAD TRAP");
		     end
		  end
	       end
	    end
	 end // if (active_thread[thread])
   endtask // endtask

`ifdef INCLUDE_SAS_TASKS   
   task get_thread_status;
      begin
`ifdef RTL_SPARC0
	 thread_status[0] = `IFUPATH0.swl.thrfsm0.thr_state;
	 thread_status[1] = `IFUPATH0.swl.thrfsm1.thr_state;
	 thread_status[2] = `IFUPATH0.swl.thrfsm2.thr_state;
	 thread_status[3] = `IFUPATH0.swl.thrfsm3.thr_state;
`endif
`ifdef RTL_SPARC1
	 thread_status[4] = `IFUPATH1.swl.thrfsm0.thr_state;
	 thread_status[5] = `IFUPATH1.swl.thrfsm1.thr_state;
	 thread_status[6] = `IFUPATH1.swl.thrfsm2.thr_state;
	 thread_status[7] = `IFUPATH1.swl.thrfsm3.thr_state;
`endif
`ifdef RTL_SPARC2
	 thread_status[8]  = `IFUPATH2.swl.thrfsm0.thr_state;
	 thread_status[9]  = `IFUPATH2.swl.thrfsm1.thr_state;
	 thread_status[10] = `IFUPATH2.swl.thrfsm2.thr_state;
	 thread_status[11] = `IFUPATH2.swl.thrfsm3.thr_state;
`endif
`ifdef RTL_SPARC3
	 thread_status[12] = `IFUPATH3.swl.thrfsm0.thr_state;
	 thread_status[13] = `IFUPATH3.swl.thrfsm1.thr_state;
	 thread_status[14] = `IFUPATH3.swl.thrfsm2.thr_state;
	 thread_status[15] = `IFUPATH3.swl.thrfsm3.thr_state;
`endif	
 `ifdef RTL_SPARC4
	 thread_status[16] = `IFUPATH4.swl.thrfsm0.thr_state;
	 thread_status[17] = `IFUPATH4.swl.thrfsm1.thr_state;
	 thread_status[18] = `IFUPATH4.swl.thrfsm2.thr_state;
	 thread_status[19] = `IFUPATH4.swl.thrfsm3.thr_state;
`endif
`ifdef RTL_SPARC5
	 thread_status[20] = `IFUPATH5.swl.thrfsm0.thr_state;
	 thread_status[21] = `IFUPATH5.swl.thrfsm1.thr_state;
	 thread_status[22] = `IFUPATH5.swl.thrfsm2.thr_state;
	 thread_status[23] = `IFUPATH5.swl.thrfsm3.thr_state;
`endif
`ifdef RTL_SPARC6
	 thread_status[24] = `IFUPATH6.swl.thrfsm0.thr_state;
	 thread_status[25] = `IFUPATH6.swl.thrfsm1.thr_state;
	 thread_status[26] = `IFUPATH6.swl.thrfsm2.thr_state;
	 thread_status[27] = `IFUPATH6.swl.thrfsm3.thr_state;
`endif
`ifdef RTL_SPARC7
	 thread_status[28] = `IFUPATH7.swl.thrfsm0.thr_state;
	 thread_status[29] = `IFUPATH7.swl.thrfsm1.thr_state;
	 thread_status[30] = `IFUPATH7.swl.thrfsm2.thr_state;
	 thread_status[31] = `IFUPATH7.swl.thrfsm3.thr_state;
`endif	 	 	 
      end
   endtask // get_thread_status
`endif
  

`ifdef RTL_SPARC0

`ifdef GATE_SIM_SPARC
   assign sas_m0                = `INSTPATH0.runw_ff_u_dff_0_.d &
                                (~`INSTPATH0.exu_ifu_ecc_ce_m | `INSTPATH0.trapm_ff_u_dff_0_.q);
   assign spc0_thread_id        = {`PCPATH0.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH0.ifu_fcl.thrw_reg_q_tmp_2_,
                                       `PCPATH0.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH0.ifu_fcl.thrw_reg_q_tmp_1_};
   assign spc0_rtl_pc           = `SPCPATH0.ifu_fdp.pc_w[47:0];
`else
   assign sas_m0                = `INSTPATH0.inst_vld_m       & ~`INSTPATH0.kill_thread_m & 
	                        ~(`INSTPATH0.exu_ifu_ecc_ce_m & `INSTPATH0.inst_vld_m & ~`INSTPATH0.trap_m);
   assign spc0_thread_id        = `PCPATH0.fcl.sas_thrid_w;
   assign spc0_rtl_pc           = `SPCPATH0.ifu.fdp.pc_w[47:0];
`endif // ifdef GATE_SIM_SPARC

`else // !ifdef RTL_SPARC0
   assign spc0_rtl_pc           = 'h0;
   assign spc0_thread_id        = 'h0;
   assign sas_m0                = 0;
`endif // ifdef RTL_SPARC0


`ifdef RTL_SPARC1

`ifdef GATE_SIM_SPARC
   assign sas_m1                = `INSTPATH1.runw_ff_u_dff_0_.d &
                                (~`INSTPATH1.exu_ifu_ecc_ce_m | `INSTPATH1.trapm_ff_u_dff_0_.q);
   assign spc1_thread_id        = {`PCPATH1.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH1.ifu_fcl.thrw_reg_q_tmp_2_,
                                        `PCPATH1.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH1.ifu_fcl.thrw_reg_q_tmp_1_};
   assign spc1_rtl_pc           = `SPCPATH1.ifu_fdp.pc_w[47:0];
`else
   assign spc1_thread_id        = `PCPATH1.fcl.sas_thrid_w;
   assign sas_m1                = `INSTPATH1.inst_vld_m       & ~`INSTPATH1.kill_thread_m & 
	                        ~(`INSTPATH1.exu_ifu_ecc_ce_m & `INSTPATH1.inst_vld_m & ~`INSTPATH1.trap_m);
   assign spc1_rtl_pc           = `SPCPATH1.ifu.fdp.pc_w[47:0];
`endif // ifdef GATE_SIM_SPARC

`else // !ifdef RTL_SPARC1
   assign spc1_rtl_pc           = 'h0;
   assign spc1_thread_id        = 'h0;
   assign sas_m1                = 0;
`endif // !ifdef RTL_SPARC1


`ifdef RTL_SPARC2

`ifdef GATE_SIM_SPARC
   assign sas_m2                = `INSTPATH2.runw_ff_u_dff_0_.d &
                                (~`INSTPATH2.exu_ifu_ecc_ce_m | `INSTPATH2.trapm_ff_u_dff_0_.q);
   assign spc2_thread_id        = {`PCPATH2.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH2.ifu_fcl.thrw_reg_q_tmp_2_,
                                        `PCPATH2.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH2.ifu_fcl.thrw_reg_q_tmp_1_};
   assign spc2_rtl_pc           = `SPCPATH2.ifu_fdp.pc_w[47:0];
`else
   assign spc2_thread_id        = `PCPATH2.fcl.sas_thrid_w;
   assign sas_m2                = `INSTPATH2.inst_vld_m       & ~`INSTPATH2.kill_thread_m & 
	                        ~(`INSTPATH2.exu_ifu_ecc_ce_m & `INSTPATH2.inst_vld_m & ~`INSTPATH2.trap_m);
   assign spc2_rtl_pc           = `SPCPATH2.ifu.fdp.pc_w[47:0];
`endif // ifdef GATE_SIM_SPARC

`else // !ifdef RTL_SPARC2
   assign spc2_rtl_pc           = 'h0;
   assign spc2_thread_id        = 'h0;
   assign sas_m2                = 0;
`endif    


`ifdef RTL_SPARC3

`ifdef GATE_SIM_SPARC
   assign sas_m3                = `INSTPATH3.runw_ff_u_dff_0_.d &
                                (~`INSTPATH3.exu_ifu_ecc_ce_m | `INSTPATH3.trapm_ff_u_dff_0_.q);
   assign spc3_thread_id        = {`PCPATH3.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH3.ifu_fcl.thrw_reg_q_tmp_2_,
                                        `PCPATH3.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH3.ifu_fcl.thrw_reg_q_tmp_1_};
   assign spc3_rtl_pc           = `SPCPATH3.ifu_fdp.pc_w[47:0];
`else
   assign spc3_thread_id        = `PCPATH3.fcl.sas_thrid_w;
   assign sas_m3                = `INSTPATH3.inst_vld_m       & ~`INSTPATH3.kill_thread_m & 
	                        ~(`INSTPATH3.exu_ifu_ecc_ce_m & `INSTPATH3.inst_vld_m & ~`INSTPATH3.trap_m);
   assign spc3_rtl_pc           = `SPCPATH3.ifu.fdp.pc_w[47:0];
`endif // ifdef GATE_SIM_SPARC

`else // !ifdef RTL_SPARC3
   assign spc3_rtl_pc           = 'h0;
   assign spc3_thread_id        = 'h0;
   assign sas_m3                = 0;
`endif       


`ifdef RTL_SPARC4

`ifdef GATE_SIM_SPARC
   assign sas_m4                = `INSTPATH4.runw_ff_u_dff_0_.d &
                                (~`INSTPATH4.exu_ifu_ecc_ce_m | `INSTPATH4.trapm_ff_u_dff_0_.q);
   assign spc4_thread_id        = {`PCPATH4.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH4.ifu_fcl.thrw_reg_q_tmp_2_,
                                        `PCPATH4.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH4.ifu_fcl.thrw_reg_q_tmp_1_};
   assign spc4_rtl_pc           = `SPCPATH4.ifu_fdp.pc_w[47:0];
`else
   assign spc4_thread_id        = `PCPATH4.fcl.sas_thrid_w;
   assign sas_m4                = `INSTPATH4.inst_vld_m       & ~`INSTPATH4.kill_thread_m & 
	                        ~(`INSTPATH4.exu_ifu_ecc_ce_m & `INSTPATH4.inst_vld_m & ~`INSTPATH4.trap_m);
   assign spc4_rtl_pc           = `SPCPATH4.ifu.fdp.pc_w[47:0];
`endif // ifdef GATE_SIM_SPARC

`else
   //assign spc4_inst_done        = 'h0;
   assign spc4_rtl_pc           = 'h0;
   assign spc4_thread_id        = 'h0;
   assign sas_m4                = 0;
`endif     


`ifdef RTL_SPARC5

`ifdef GATE_SIM_SPARC
   assign sas_m5                = `INSTPATH5.runw_ff_u_dff_0_.d &
                                (~`INSTPATH5.exu_ifu_ecc_ce_m | `INSTPATH5.trapm_ff_u_dff_0_.q);
   assign spc5_thread_id        = {`PCPATH5.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH5.ifu_fcl.thrw_reg_q_tmp_2_,
                                        `PCPATH5.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH5.ifu_fcl.thrw_reg_q_tmp_1_};
   assign spc5_rtl_pc           = `SPCPATH5.ifu_fdp.pc_w[47:0];
`else
   assign spc5_thread_id        = `PCPATH5.fcl.sas_thrid_w;
   assign sas_m5                = `INSTPATH5.inst_vld_m       & ~`INSTPATH5.kill_thread_m & 
	                        ~(`INSTPATH5.exu_ifu_ecc_ce_m & `INSTPATH5.inst_vld_m & ~`INSTPATH5.trap_m);
   assign spc5_rtl_pc           = `SPCPATH5.ifu.fdp.pc_w[47:0];
`endif // ifdef GATE_SIM_SPARC

`else
   assign spc5_rtl_pc           = 'h0;
   assign spc5_thread_id        = 'h0;
   assign sas_m5                = 0;
`endif     


`ifdef RTL_SPARC6

`ifdef GATE_SIM_SPARC
   assign sas_m6                = `INSTPATH6.runw_ff_u_dff_0_.d &
                                (~`INSTPATH6.exu_ifu_ecc_ce_m | `INSTPATH6.trapm_ff_u_dff_0_.q);
   assign spc6_thread_id        = {`PCPATH6.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH6.ifu_fcl.thrw_reg_q_tmp_2_,
                                        `PCPATH6.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH6.ifu_fcl.thrw_reg_q_tmp_1_};
   assign spc6_rtl_pc           = `SPCPATH6.ifu_fdp.pc_w[47:0];
`else
   assign spc6_thread_id        = `PCPATH6.fcl.sas_thrid_w;
   assign sas_m6                = `INSTPATH6.inst_vld_m       & ~`INSTPATH6.kill_thread_m & 
	                        ~(`INSTPATH6.exu_ifu_ecc_ce_m & `INSTPATH6.inst_vld_m & ~`INSTPATH6.trap_m);
   assign spc6_rtl_pc           = `SPCPATH6.ifu.fdp.pc_w[47:0];
`endif // ifdef GATE_SIM_SPARC

`else
   assign spc6_rtl_pc           = 'h0;
   assign spc6_thread_id        = 'h0; 
   assign sas_m6                = 0;
`endif      


`ifdef RTL_SPARC7

`ifdef GATE_SIM_SPARC
   assign sas_m7                = `INSTPATH7.runw_ff_u_dff_0_.d &
                                (~`INSTPATH7.exu_ifu_ecc_ce_m | `INSTPATH7.trapm_ff_u_dff_0_.q);
   assign spc7_thread_id        = {`PCPATH7.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH7.ifu_fcl.thrw_reg_q_tmp_2_,
                                        `PCPATH7.ifu_fcl.thrw_reg_q_tmp_3_ | `PCPATH7.ifu_fcl.thrw_reg_q_tmp_1_};
   assign spc7_rtl_pc           = `SPCPATH7.ifu_fdp.pc_w[47:0];
`else
   assign spc7_thread_id        = `PCPATH7.fcl.sas_thrid_w;
   assign sas_m7                = `INSTPATH7.inst_vld_m        & ~`INSTPATH7.kill_thread_m & 
	                        ~(`INSTPATH7.exu_ifu_ecc_ce_m & `INSTPATH7.inst_vld_m & ~`INSTPATH7.trap_m);
   assign spc7_rtl_pc           = `SPCPATH7.ifu.fdp.pc_w[47:0];
`endif // ifdef GATE_SIM_SPARC

`else
   assign spc7_rtl_pc           = 'h0;
   assign spc7_thread_id        = 'h0;
   assign sas_m7                = 0;
`endif // !ifdef SP7

 reg [63:0]  spc0_phy_pc_w,  spc1_phy_pc_w,  spc2_phy_pc_w,  spc3_phy_pc_w,
	     spc4_phy_pc_w,  spc5_phy_pc_w,  spc6_phy_pc_w,  spc7_phy_pc_w;
   
`ifdef RTL_SPARC0
   reg [63:0] spc0_phy_pc_d,  spc0_phy_pc_e,  spc0_phy_pc_m, 
	      spc0_t0pc_s,    spc0_t1pc_s,    spc0_t2pc_s,  spc0_t3pc_s ;
   
   reg [3:0]  spc0_fcl_fdp_nextpcs_sel_pcf_f_l_e,
	      spc0_fcl_fdp_nextpcs_sel_pcs_f_l_e,
	      spc0_fcl_fdp_nextpcs_sel_pcd_f_l_e,
	      spc0_fcl_fdp_nextpcs_sel_pce_f_l_e;
   
   wire [3:0] pcs0 = spc0_fcl_fdp_nextpcs_sel_pcs_f_l_e;
   wire [3:0] pcf0 = spc0_fcl_fdp_nextpcs_sel_pcf_f_l_e;
   wire [3:0] pcd0 = spc0_fcl_fdp_nextpcs_sel_pcd_f_l_e;
   wire [3:0] pce0 = spc0_fcl_fdp_nextpcs_sel_pce_f_l_e;

   wire [63:0]  spc0_imiss_paddr_s ;

`ifdef  GATE_SIM_SPARC
   assign spc0_imiss_paddr_s = {`IFQDP0.itlb_ifq_paddr_s, `IFQDP0.lcl_paddr_s, 2'b0} ;
`else
   assign spc0_imiss_paddr_s = `IFQDP0.imiss_paddr_s ;
`endif // GATE_SIM_SPARC

`endif //  `ifdef RTL_SPARC0
   
`ifdef RTL_SPARC1
   reg [63:0] spc1_phy_pc_d,  spc1_phy_pc_e,  spc1_phy_pc_m,
	      spc1_t0pc_s,    spc1_t1pc_s,    spc1_t2pc_s,  spc1_t3pc_s;
   
   reg [3:0]  spc1_fcl_fdp_nextpcs_sel_pcf_f_l_e,
	      spc1_fcl_fdp_nextpcs_sel_pcs_f_l_e,
	      spc1_fcl_fdp_nextpcs_sel_pcd_f_l_e,
	      spc1_fcl_fdp_nextpcs_sel_pce_f_l_e;
   
   wire [3:0] pcs1 = spc1_fcl_fdp_nextpcs_sel_pcs_f_l_e;
   wire [3:0] pcf1 = spc1_fcl_fdp_nextpcs_sel_pcf_f_l_e;
   wire [3:0] pcd1 = spc1_fcl_fdp_nextpcs_sel_pcd_f_l_e;
   wire [3:0] pce1 = spc1_fcl_fdp_nextpcs_sel_pce_f_l_e;

   wire [63:0]  spc1_imiss_paddr_s ;

`ifdef  GATE_SIM_SPARC
   assign spc1_imiss_paddr_s = {`IFQDP1.itlb_ifq_paddr_s, `IFQDP1.lcl_paddr_s, 2'b0} ;
`else
   assign spc1_imiss_paddr_s = `IFQDP1.imiss_paddr_s ;
`endif // GATE_SIM_SPARC

`endif 
   
`ifdef RTL_SPARC2
   reg [63:0] spc2_phy_pc_d,  spc2_phy_pc_e,  spc2_phy_pc_m, 
	      spc2_t0pc_s,    spc2_t1pc_s,    spc2_t2pc_s,  spc2_t3pc_s;
   
   reg [3:0]  spc2_fcl_fdp_nextpcs_sel_pcf_f_l_e,
	      spc2_fcl_fdp_nextpcs_sel_pcs_f_l_e,
	      spc2_fcl_fdp_nextpcs_sel_pcd_f_l_e,
	      spc2_fcl_fdp_nextpcs_sel_pce_f_l_e;
   
   wire [3:0] pcs2 = spc2_fcl_fdp_nextpcs_sel_pcs_f_l_e;
   wire [3:0] pcf2 = spc2_fcl_fdp_nextpcs_sel_pcf_f_l_e;
   wire [3:0] pcd2 = spc2_fcl_fdp_nextpcs_sel_pcd_f_l_e;
   wire [3:0] pce2 = spc2_fcl_fdp_nextpcs_sel_pce_f_l_e;

   wire [63:0]  spc2_imiss_paddr_s ;

`ifdef  GATE_SIM_SPARC
   assign spc2_imiss_paddr_s = {`IFQDP2.itlb_ifq_paddr_s, `IFQDP2.lcl_paddr_s, 2'b0} ;
`else
   assign spc2_imiss_paddr_s = `IFQDP2.imiss_paddr_s ;
`endif // GATE_SIM_SPARC

`endif //  `ifdef RTL_SPARC0
   
`ifdef RTL_SPARC3
   reg [63:0] spc3_phy_pc_d,  spc3_phy_pc_e,  spc3_phy_pc_m,
	      spc3_t0pc_s,    spc3_t1pc_s,    spc3_t2pc_s, spc3_t3pc_s;
   
   reg [3:0]  spc3_fcl_fdp_nextpcs_sel_pcf_f_l_e,
	      spc3_fcl_fdp_nextpcs_sel_pcs_f_l_e,
	      spc3_fcl_fdp_nextpcs_sel_pcd_f_l_e,
	      spc3_fcl_fdp_nextpcs_sel_pce_f_l_e;
   
   wire [3:0] pcs3 = spc3_fcl_fdp_nextpcs_sel_pcs_f_l_e;
   wire [3:0] pcf3 = spc3_fcl_fdp_nextpcs_sel_pcf_f_l_e;
   wire [3:0] pcd3 = spc3_fcl_fdp_nextpcs_sel_pcd_f_l_e;
   wire [3:0] pce3 = spc3_fcl_fdp_nextpcs_sel_pce_f_l_e;

   wire [63:0]  spc3_imiss_paddr_s ;

`ifdef  GATE_SIM_SPARC
   assign spc3_imiss_paddr_s = {`IFQDP3.itlb_ifq_paddr_s, `IFQDP3.lcl_paddr_s, 2'b0} ;
`else
   assign spc3_imiss_paddr_s = `IFQDP3.imiss_paddr_s ;
`endif // GATE_SIM_SPARC

`endif //  `ifdef RTL_SPARC3

`ifdef RTL_SPARC4
   reg [63:0] spc4_phy_pc_d,  spc4_phy_pc_e,  spc4_phy_pc_m, 
	      spc4_t0pc_s,    spc4_t1pc_s,    spc4_t2pc_s,  spc4_t3pc_s;
   
   reg [3:0]  spc4_fcl_fdp_nextpcs_sel_pcf_f_l_e,
	      spc4_fcl_fdp_nextpcs_sel_pcs_f_l_e,
	      spc4_fcl_fdp_nextpcs_sel_pcd_f_l_e,
	      spc4_fcl_fdp_nextpcs_sel_pce_f_l_e;
   
   wire [3:0] pcs4 = spc4_fcl_fdp_nextpcs_sel_pcs_f_l_e;
   wire [3:0] pcf4 = spc4_fcl_fdp_nextpcs_sel_pcf_f_l_e;
   wire [3:0] pcd4 = spc4_fcl_fdp_nextpcs_sel_pcd_f_l_e;
   wire [3:0] pce4 = spc4_fcl_fdp_nextpcs_sel_pce_f_l_e;

   wire [63:0]  spc4_imiss_paddr_s ;

`ifdef  GATE_SIM_SPARC
   assign spc4_imiss_paddr_s = {`IFQDP4.itlb_ifq_paddr_s, `IFQDP4.lcl_paddr_s, 2'b0} ;
`else
   assign spc4_imiss_paddr_s = `IFQDP4.imiss_paddr_s ;
`endif // GATE_SIM_SPARC

`endif //  `ifdef RTL_SPARC4
   
`ifdef RTL_SPARC5
   reg [63:0] spc5_phy_pc_d,  spc5_phy_pc_e,  spc5_phy_pc_m,
	      spc5_t0pc_s,    spc5_t1pc_s,    spc5_t2pc_s,  spc5_t3pc_s;
   
   reg [3:0]  spc5_fcl_fdp_nextpcs_sel_pcf_f_l_e,
	      spc5_fcl_fdp_nextpcs_sel_pcs_f_l_e,
	      spc5_fcl_fdp_nextpcs_sel_pcd_f_l_e,
	      spc5_fcl_fdp_nextpcs_sel_pce_f_l_e;
   
   wire [3:0] pcs5 = spc5_fcl_fdp_nextpcs_sel_pcs_f_l_e;
   wire [3:0] pcf5 = spc5_fcl_fdp_nextpcs_sel_pcf_f_l_e;
   wire [3:0] pcd5 = spc5_fcl_fdp_nextpcs_sel_pcd_f_l_e;
   wire [3:0] pce5 = spc5_fcl_fdp_nextpcs_sel_pce_f_l_e;

   wire [63:0]  spc5_imiss_paddr_s ;

`ifdef  GATE_SIM_SPARC
   assign spc5_imiss_paddr_s = {`IFQDP5.itlb_ifq_paddr_s, `IFQDP5.lcl_paddr_s, 2'b0} ;
`else
   assign spc5_imiss_paddr_s = `IFQDP5.imiss_paddr_s ;
`endif // GATE_SIM_SPARC

`endif //  `ifdef RTL_SPARC5
   
`ifdef RTL_SPARC6
   reg [63:0] spc6_phy_pc_d,  spc6_phy_pc_e,  spc6_phy_pc_m, 
	      spc6_t0pc_s,    spc6_t1pc_s,    spc6_t2pc_s, spc6_t3pc_s;
   
   reg [3:0]  spc6_fcl_fdp_nextpcs_sel_pcf_f_l_e,
	      spc6_fcl_fdp_nextpcs_sel_pcs_f_l_e,
	      spc6_fcl_fdp_nextpcs_sel_pcd_f_l_e,
	      spc6_fcl_fdp_nextpcs_sel_pce_f_l_e;
   
   wire [3:0] pcs6 = spc6_fcl_fdp_nextpcs_sel_pcs_f_l_e;
   wire [3:0] pcf6 = spc6_fcl_fdp_nextpcs_sel_pcf_f_l_e;
   wire [3:0] pcd6 = spc6_fcl_fdp_nextpcs_sel_pcd_f_l_e;
   wire [3:0] pce6 = spc6_fcl_fdp_nextpcs_sel_pce_f_l_e;

   wire [63:0]  spc6_imiss_paddr_s ;

`ifdef  GATE_SIM_SPARC
   assign spc6_imiss_paddr_s = {`IFQDP6.itlb_ifq_paddr_s, `IFQDP6.lcl_paddr_s, 2'b0} ;
`else
   assign spc6_imiss_paddr_s = `IFQDP6.imiss_paddr_s ;
`endif // GATE_SIM_SPARC

`endif //  `ifdef RTL_SPARC6
   
`ifdef RTL_SPARC7
   reg [63:0] spc7_phy_pc_d,  spc7_phy_pc_e,  spc7_phy_pc_m,
	      spc7_t0pc_s,    spc7_t1pc_s,    spc7_t2pc_s, spc7_t3pc_s;
   
   reg [3:0]  spc7_fcl_fdp_nextpcs_sel_pcf_f_l_e,
	      spc7_fcl_fdp_nextpcs_sel_pcs_f_l_e,
	      spc7_fcl_fdp_nextpcs_sel_pcd_f_l_e,
	      spc7_fcl_fdp_nextpcs_sel_pce_f_l_e;
   
   wire [3:0] pcs7 = spc7_fcl_fdp_nextpcs_sel_pcs_f_l_e;
   wire [3:0] pcf7 = spc7_fcl_fdp_nextpcs_sel_pcf_f_l_e;
   wire [3:0] pcd7 = spc7_fcl_fdp_nextpcs_sel_pcd_f_l_e;
   wire [3:0] pce7 = spc7_fcl_fdp_nextpcs_sel_pce_f_l_e;

   wire [63:0]  spc7_imiss_paddr_s ;

`ifdef  GATE_SIM_SPARC
   assign spc7_imiss_paddr_s = {`IFQDP7.itlb_ifq_paddr_s, `IFQDP7.lcl_paddr_s, 2'b0} ;
`else
   assign spc7_imiss_paddr_s = `IFQDP7.imiss_paddr_s ;
`endif // GATE_SIM_SPARC

`endif //  `ifdef RTL_SPARC7


   always @(posedge clk) begin
`ifdef RTL_SPARC0
      //done
      spc0_inst_done                     <= sas_m0;
      
      //next pc select
      spc0_fcl_fdp_nextpcs_sel_pcs_f_l_e <= `DTUPATH0.fcl_fdp_nextpcs_sel_pcs_f_l;
      spc0_fcl_fdp_nextpcs_sel_pcf_f_l_e <= `DTUPATH0.fcl_fdp_nextpcs_sel_pcf_f_l;
      spc0_fcl_fdp_nextpcs_sel_pcd_f_l_e <= `DTUPATH0.fcl_fdp_nextpcs_sel_pcd_f_l;
      spc0_fcl_fdp_nextpcs_sel_pce_f_l_e <= `DTUPATH0.fcl_fdp_nextpcs_sel_pce_f_l;
      
      //pipe physical pc

      if(pcf0[0] == 0)spc0_t0pc_s          <= spc0_imiss_paddr_s;
      else if(pcs0[0] == 0)spc0_t0pc_s     <= spc0_t0pc_s; 
      else if(pcd0[0] == 0)spc0_t0pc_s     <= spc0_phy_pc_e; 
      else if(pce0[0] == 0)spc0_t0pc_s     <= spc0_phy_pc_m;
      
      if(pcf0[1] == 0)spc0_t1pc_s          <= spc0_imiss_paddr_s;
      else if(pcs0[1] == 0)spc0_t1pc_s     <= spc0_t1pc_s;
      else if(pcd0[1] == 0)spc0_t1pc_s     <= spc0_phy_pc_e; 
      else if(pce0[1] == 0)spc0_t1pc_s     <= spc0_phy_pc_m;
      
      if(pcf0[2] == 0)spc0_t2pc_s          <= spc0_imiss_paddr_s;
      else if(pcs0[2] == 0)spc0_t2pc_s     <= spc0_t2pc_s;
      else if(pcd0[2] == 0)spc0_t2pc_s     <= spc0_phy_pc_e; 
      else if(pce0[2] == 0)spc0_t2pc_s     <= spc0_phy_pc_m;
      
      if(pcf0[3] == 0)spc0_t3pc_s          <= spc0_imiss_paddr_s;
      else if(pcs0[3] == 0)spc0_t3pc_s     <= spc0_t3pc_s;
      else if(pcd0[3] == 0)spc0_t3pc_s     <= spc0_phy_pc_e; 
      else if(pce0[3] == 0)spc0_t3pc_s     <= spc0_phy_pc_m;
      
      if(~`DTUPATH0.fcl_fdp_thr_s2_l[0])     spc0_phy_pc_d <= pcf0[0] ? spc0_t0pc_s : spc0_imiss_paddr_s;
      else if(~`DTUPATH0.fcl_fdp_thr_s2_l[1])spc0_phy_pc_d <= pcf0[1] ? spc0_t1pc_s : spc0_imiss_paddr_s;
      else if(~`DTUPATH0.fcl_fdp_thr_s2_l[2])spc0_phy_pc_d <= pcf0[2] ? spc0_t2pc_s : spc0_imiss_paddr_s;
      else if(~`DTUPATH0.fcl_fdp_thr_s2_l[3])spc0_phy_pc_d <= pcf0[3] ? spc0_t3pc_s : spc0_imiss_paddr_s;

      spc0_phy_pc_e   <= spc0_phy_pc_d;
      spc0_phy_pc_m   <= spc0_phy_pc_e;
      spc0_phy_pc_w   <= {{8{spc0_phy_pc_m[39]}}, spc0_phy_pc_m[39:0]};
      
      if(spc0_inst_done && 
	 active_thread[{3'b000,spc0_thread_id[1:0]}])begin
/*
	 if(0 & $x_checker(`DTUPATH0.pc_w))begin
	    $display("%0d: Detected unkown pc value spc(%d) thread(%x) value(%x)", 
		     $time, 3'b000, spc0_thread_id[1:0], `DTUPATH0.pc_w);
	    `MONITOR_PATH.fail("Detected unkown pc");
	 end
*/
      end
`endif // ifdef RTL_SPARC0
      
`ifdef RTL_SPARC1
       //done
      spc1_inst_done                     <= sas_m1;
      //next pc select
      spc1_fcl_fdp_nextpcs_sel_pcs_f_l_e <= `DTUPATH1.fcl_fdp_nextpcs_sel_pcs_f_l;
      spc1_fcl_fdp_nextpcs_sel_pcf_f_l_e <= `DTUPATH1.fcl_fdp_nextpcs_sel_pcf_f_l;
      spc1_fcl_fdp_nextpcs_sel_pcd_f_l_e <= `DTUPATH1.fcl_fdp_nextpcs_sel_pcd_f_l;
      spc1_fcl_fdp_nextpcs_sel_pce_f_l_e <= `DTUPATH1.fcl_fdp_nextpcs_sel_pce_f_l;
      
      //pipe physical pc
      if(     pcf1[0] == 0)spc1_t0pc_s     <= spc1_imiss_paddr_s;
      else if(pcs1[0] == 0)spc1_t0pc_s     <= spc1_t0pc_s; 
      else if(pcd1[0] == 0)spc1_t0pc_s     <= spc1_phy_pc_e; 
      else if(pce1[0] == 0)spc1_t0pc_s     <= spc1_phy_pc_m;

      if(     pcf1[1] == 0)spc1_t1pc_s     <= spc1_imiss_paddr_s;
      else if(pcs1[1] == 0)spc1_t1pc_s     <= spc1_t1pc_s;
      else if(pcd1[1] == 0)spc1_t1pc_s     <= spc1_phy_pc_e; 
      else if(pce1[1] == 0)spc1_t1pc_s     <= spc1_phy_pc_m;
      
      if(     pcf1[2] == 0)spc1_t2pc_s     <= spc1_imiss_paddr_s;
      else if(pcs1[2] == 0)spc1_t2pc_s     <= spc1_t2pc_s;
      else if(pcd1[2] == 0)spc1_t2pc_s     <= spc1_phy_pc_e; 
      else if(pce1[2] == 0)spc1_t2pc_s     <= spc1_phy_pc_m;
      
      if(     pcf1[3] == 0)spc1_t3pc_s     <= spc1_imiss_paddr_s;
      else if(pcs1[3] == 0)spc1_t3pc_s     <= spc1_t3pc_s;
      else if(pcd1[3] == 0)spc1_t3pc_s     <= spc1_phy_pc_e; 
      else if(pce1[3] == 0)spc1_t3pc_s     <= spc1_phy_pc_m;
      
      if(     ~`DTUPATH1.fcl_fdp_thr_s2_l[0])spc1_phy_pc_d   <= pcf1[0] ? spc1_t0pc_s : spc1_imiss_paddr_s;
      else if(~`DTUPATH1.fcl_fdp_thr_s2_l[1])spc1_phy_pc_d   <= pcf1[1] ? spc1_t1pc_s : spc1_imiss_paddr_s;
      else if(~`DTUPATH1.fcl_fdp_thr_s2_l[2])spc1_phy_pc_d   <= pcf1[2] ? spc1_t2pc_s : spc1_imiss_paddr_s;
      else if(~`DTUPATH1.fcl_fdp_thr_s2_l[3])spc1_phy_pc_d   <= pcf1[3] ? spc1_t3pc_s : spc1_imiss_paddr_s;
      
      spc1_phy_pc_e   <= spc1_phy_pc_d;
      spc1_phy_pc_m   <= spc1_phy_pc_e;
      spc1_phy_pc_w   <= {{8{spc1_phy_pc_m[39]}}, spc1_phy_pc_m[39:0]};
      
      if(spc1_inst_done && 
	 active_thread[{3'b001,spc1_thread_id[1:0]}])begin
/*
	 if(0 & $x_checker(`DTUPATH1.pc_w))begin
	    $display("%0d: Detected unkown pc value spc(%d) thread(%x) value(%x)", 
		     $time, 3'b001, spc1_thread_id[1:0], `DTUPATH1.pc_w);
	    `MONITOR_PATH.fail("Detected unkown pc");
	 end
*/
      end
`endif // ifdef RTL_SPARC1

      
`ifdef RTL_SPARC2
       //done
      spc2_inst_done                     <= sas_m2;
      //next pc select
      spc2_fcl_fdp_nextpcs_sel_pcs_f_l_e <= `DTUPATH2.fcl_fdp_nextpcs_sel_pcs_f_l;
      spc2_fcl_fdp_nextpcs_sel_pcf_f_l_e <= `DTUPATH2.fcl_fdp_nextpcs_sel_pcf_f_l;
      spc2_fcl_fdp_nextpcs_sel_pcd_f_l_e <= `DTUPATH2.fcl_fdp_nextpcs_sel_pcd_f_l;
      spc2_fcl_fdp_nextpcs_sel_pce_f_l_e <= `DTUPATH2.fcl_fdp_nextpcs_sel_pce_f_l;
      
      //pipe physical pc
      if(pcf2[0] == 0)spc2_t0pc_s          <= spc2_imiss_paddr_s;
      else if(pcs2[0] == 0)spc2_t0pc_s     <= spc2_t0pc_s; 
      else if(pcd2[0] == 0)spc2_t0pc_s     <= spc2_phy_pc_e; 
      else if(pce2[0] == 0)spc2_t0pc_s     <= spc2_phy_pc_m;

      if(pcf2[1] == 0)spc2_t1pc_s          <= spc2_imiss_paddr_s;
      else if(pcs2[1] == 0)spc2_t1pc_s     <= spc2_t1pc_s;
      else if(pcd2[1] == 0)spc2_t1pc_s     <= spc2_phy_pc_e; 
      else if(pce2[1] == 0)spc2_t1pc_s     <= spc2_phy_pc_m;
      
      if(pcf2[2] == 0)spc2_t2pc_s          <= spc2_imiss_paddr_s;
      else if(pcs2[2] == 0)spc2_t2pc_s     <= spc2_t2pc_s;
      else if(pcd2[2] == 0)spc2_t2pc_s     <= spc2_phy_pc_e; 
      else if(pce2[2] == 0)spc2_t2pc_s     <= spc2_phy_pc_m;
      
      if(pcf2[3] == 0)spc2_t3pc_s          <= spc2_imiss_paddr_s;
      else if(pcs2[3] == 0)spc2_t3pc_s     <= spc2_t3pc_s;
      else if(pcd2[3] == 0)spc2_t3pc_s     <= spc2_phy_pc_e; 
      else if(pce2[3] == 0)spc2_t3pc_s     <= spc2_phy_pc_m;
      

      if(~`DTUPATH2.fcl_fdp_thr_s2_l[0])     spc2_phy_pc_d   <= pcf2[0] ? spc2_t0pc_s : spc2_imiss_paddr_s;
      else if(~`DTUPATH2.fcl_fdp_thr_s2_l[1])spc2_phy_pc_d   <= pcf2[1] ? spc2_t1pc_s : spc2_imiss_paddr_s;
      else if(~`DTUPATH2.fcl_fdp_thr_s2_l[2])spc2_phy_pc_d   <= pcf2[2] ? spc2_t2pc_s : spc2_imiss_paddr_s;
      else if(~`DTUPATH2.fcl_fdp_thr_s2_l[3])spc2_phy_pc_d   <= pcf2[3] ? spc2_t3pc_s : spc2_imiss_paddr_s;

      spc2_phy_pc_e   <= spc2_phy_pc_d;
      spc2_phy_pc_m   <= spc2_phy_pc_e;
      spc2_phy_pc_w   <= {{8{spc2_phy_pc_m[39]}}, spc2_phy_pc_m[39:0]};
      
      if(spc2_inst_done && 
	 active_thread[{3'b010,spc2_thread_id[1:0]}])begin
/*
	 if(0 & $x_checker(`DTUPATH2.pc_w))begin
	    $display("%0d: Detected unkown pc value spc(%d) thread(%x) value(%x)", 
		     $time, 3'b010, spc2_thread_id[1:0], `DTUPATH2.pc_w);
	    `MONITOR_PATH.fail("Detected unkown pc");
	 end
*/
      end
`endif // ifdef RTL_SPARC2

`ifdef RTL_SPARC3
       //done
      spc3_inst_done                     <= sas_m3;
      //next pc select
      spc3_fcl_fdp_nextpcs_sel_pcs_f_l_e <= `DTUPATH3.fcl_fdp_nextpcs_sel_pcs_f_l;
      spc3_fcl_fdp_nextpcs_sel_pcf_f_l_e <= `DTUPATH3.fcl_fdp_nextpcs_sel_pcf_f_l;
      spc3_fcl_fdp_nextpcs_sel_pcd_f_l_e <= `DTUPATH3.fcl_fdp_nextpcs_sel_pcd_f_l;
      spc3_fcl_fdp_nextpcs_sel_pce_f_l_e <= `DTUPATH3.fcl_fdp_nextpcs_sel_pce_f_l;
      
      //pipe physical pc
      if(pcf3[0] == 0)spc3_t0pc_s          <= spc3_imiss_paddr_s;
      else if(pcs3[0] == 0)spc3_t0pc_s     <= spc3_t0pc_s; 
      else if(pcd3[0] == 0)spc3_t0pc_s     <= spc3_phy_pc_e; 
      else if(pce3[0] == 0)spc3_t0pc_s     <= spc3_phy_pc_m;

      if(pcf3[1] == 0)spc3_t1pc_s          <= spc3_imiss_paddr_s;
      else if(pcs3[1] == 0)spc3_t1pc_s     <= spc3_t1pc_s;
      else if(pcd3[1] == 0)spc3_t1pc_s     <= spc3_phy_pc_e; 
      else if(pce3[1] == 0)spc3_t1pc_s     <= spc3_phy_pc_m;
      
      if(pcf3[2] == 0)spc3_t2pc_s          <= spc3_imiss_paddr_s;
      else if(pcs3[2] == 0)spc3_t2pc_s     <= spc3_t2pc_s;
      else if(pcd3[2] == 0)spc3_t2pc_s     <= spc3_phy_pc_e; 
      else if(pce3[2] == 0)spc3_t2pc_s     <= spc3_phy_pc_m;
      
      if(pcf3[3] == 0)spc3_t3pc_s          <= spc3_imiss_paddr_s;
      else if(pcs3[3] == 0)spc3_t3pc_s     <= spc3_t3pc_s;
      else if(pcd3[3] == 0)spc3_t3pc_s     <= spc3_phy_pc_e; 
      else if(pce3[3] == 0)spc3_t3pc_s     <= spc3_phy_pc_m;
      
      if(~`DTUPATH3.fcl_fdp_thr_s2_l[0])     spc3_phy_pc_d   <= pcf3[0] ? spc3_t0pc_s : spc3_imiss_paddr_s;
      else if(~`DTUPATH3.fcl_fdp_thr_s2_l[1])spc3_phy_pc_d   <= pcf3[1] ? spc3_t1pc_s : spc3_imiss_paddr_s;
      else if(~`DTUPATH3.fcl_fdp_thr_s2_l[2])spc3_phy_pc_d   <= pcf3[2] ? spc3_t2pc_s : spc3_imiss_paddr_s;
      else if(~`DTUPATH3.fcl_fdp_thr_s2_l[3])spc3_phy_pc_d   <= pcf3[3] ? spc3_t3pc_s : spc3_imiss_paddr_s;

      spc3_phy_pc_e   <= spc3_phy_pc_d;
      spc3_phy_pc_m   <= spc3_phy_pc_e;
      spc3_phy_pc_w   <= {{8{spc3_phy_pc_m[39]}}, spc3_phy_pc_m[39:0]};
      
      if(spc3_inst_done && 
	 active_thread[{3'b011,spc3_thread_id[1:0]}])begin
/*
	 if(0 & $x_checker(`DTUPATH3.pc_w))begin
	    $display("%0d: Detected unkown pc value spc(%d) thread(%x) value(%x)", 
		     $time, 3'b011, spc3_thread_id[1:0], `DTUPATH3.pc_w);
	    `MONITOR_PATH.fail("Detected unkown pc");
	 end
*/
      end
`endif // ifdef RTL_SPARC3

`ifdef RTL_SPARC4
       //done
      spc4_inst_done                     <= sas_m4;
       //next pc select
      spc4_fcl_fdp_nextpcs_sel_pcs_f_l_e <= `DTUPATH4.fcl_fdp_nextpcs_sel_pcs_f_l;
      spc4_fcl_fdp_nextpcs_sel_pcf_f_l_e <= `DTUPATH4.fcl_fdp_nextpcs_sel_pcf_f_l;
      spc4_fcl_fdp_nextpcs_sel_pcd_f_l_e <= `DTUPATH4.fcl_fdp_nextpcs_sel_pcd_f_l;
      spc4_fcl_fdp_nextpcs_sel_pce_f_l_e <= `DTUPATH4.fcl_fdp_nextpcs_sel_pce_f_l;
      
      //pipe physical pc
      if(pcf4[0] == 0)spc4_t0pc_s          <= spc4_imiss_paddr_s;
      else if(pcs4[0] == 0)spc4_t0pc_s     <= spc4_t0pc_s; 
      else if(pcd4[0] == 0)spc4_t0pc_s     <= spc4_phy_pc_e; 
      else if(pce4[0] == 0)spc4_t0pc_s     <= spc4_phy_pc_m;

      if(pcf4[1] == 0)spc4_t1pc_s          <= spc4_imiss_paddr_s;
      else if(pcs4[1] == 0)spc4_t1pc_s     <= spc4_t1pc_s;
      else if(pcd4[1] == 0)spc4_t1pc_s     <= spc4_phy_pc_e; 
      else if(pce4[1] == 0)spc4_t1pc_s     <= spc4_phy_pc_m;
      
      if(pcf4[2] == 0)spc4_t2pc_s          <= spc4_imiss_paddr_s;
      else if(pcs4[2] == 0)spc4_t2pc_s     <= spc4_t2pc_s;
      else if(pcd4[2] == 0)spc4_t2pc_s     <= spc4_phy_pc_e; 
      else if(pce4[2] == 0)spc4_t2pc_s     <= spc4_phy_pc_m;
      
      if(pcf4[3] == 0)spc4_t3pc_s          <= spc4_imiss_paddr_s;
      else if(pcs4[3] == 0)spc4_t3pc_s     <= spc4_t3pc_s;
      else if(pcd4[3] == 0)spc4_t3pc_s     <= spc4_phy_pc_e; 
      else if(pce4[3] == 0)spc4_t3pc_s     <= spc4_phy_pc_m;
      
      if(~`DTUPATH4.fcl_fdp_thr_s2_l[0])     spc4_phy_pc_d   <= pcf4[0] ? spc4_t0pc_s : spc4_imiss_paddr_s;
      else if(~`DTUPATH4.fcl_fdp_thr_s2_l[1])spc4_phy_pc_d   <= pcf4[1] ? spc4_t1pc_s : spc4_imiss_paddr_s;
      else if(~`DTUPATH4.fcl_fdp_thr_s2_l[2])spc4_phy_pc_d   <= pcf4[2] ? spc4_t2pc_s : spc4_imiss_paddr_s;
      else if(~`DTUPATH4.fcl_fdp_thr_s2_l[3])spc4_phy_pc_d   <= pcf4[3] ? spc4_t3pc_s : spc4_imiss_paddr_s;

      spc4_phy_pc_e   <= spc4_phy_pc_d;
      spc4_phy_pc_m   <= spc4_phy_pc_e;
      spc4_phy_pc_w   <= {{8{spc4_phy_pc_m[39]}}, spc4_phy_pc_m[39:0]};
      
      if(spc4_inst_done && 
	 active_thread[{3'b100,spc4_thread_id[1:0]}])begin
/*
	 if(0 & $x_checker(`DTUPATH4.pc_w))begin
	    $display("%0d: Detected unkown pc value spc(%d) thread(%x) value(%x)", 
		     $time, 3'b100, spc4_thread_id[1:0], `DTUPATH4.pc_w);
	    `MONITOR_PATH.fail("Detected unkown pc");
	 end
*/
      end
`endif // ifdef RTL_SPARC4

      
`ifdef RTL_SPARC5
       //done
      spc5_inst_done                     <= sas_m5;
        //next pc select
      spc5_fcl_fdp_nextpcs_sel_pcs_f_l_e <= `DTUPATH5.fcl_fdp_nextpcs_sel_pcs_f_l;
      spc5_fcl_fdp_nextpcs_sel_pcf_f_l_e <= `DTUPATH5.fcl_fdp_nextpcs_sel_pcf_f_l;
      spc5_fcl_fdp_nextpcs_sel_pcd_f_l_e <= `DTUPATH5.fcl_fdp_nextpcs_sel_pcd_f_l;
      spc5_fcl_fdp_nextpcs_sel_pce_f_l_e <= `DTUPATH5.fcl_fdp_nextpcs_sel_pce_f_l;
      
      //pipe physical pc
      if(pcf5[0] == 0)spc5_t0pc_s          <= spc5_imiss_paddr_s;
      else if(pcs5[0] == 0)spc5_t0pc_s     <= spc5_t0pc_s; 
      else if(pcd5[0] == 0)spc5_t0pc_s     <= spc5_phy_pc_e; 
      else if(pce5[0] == 0)spc5_t0pc_s     <= spc5_phy_pc_m;

      if(pcf5[1] == 0)spc5_t1pc_s          <= spc5_imiss_paddr_s;
      else if(pcs5[1] == 0)spc5_t1pc_s     <= spc5_t1pc_s;
      else if(pcd5[1] == 0)spc5_t1pc_s     <= spc5_phy_pc_e; 
      else if(pce5[1] == 0)spc5_t1pc_s     <= spc5_phy_pc_m;
      
      if(pcf5[2] == 0)spc5_t2pc_s          <= spc5_imiss_paddr_s;
      else if(pcs5[2] == 0)spc5_t2pc_s     <= spc5_t2pc_s;
      else if(pcd5[2] == 0)spc5_t2pc_s     <= spc5_phy_pc_e; 
      else if(pce5[2] == 0)spc5_t2pc_s     <= spc5_phy_pc_m;
      
      if(pcf5[3] == 0)spc5_t3pc_s          <= spc5_imiss_paddr_s;
      else if(pcs5[3] == 0)spc5_t3pc_s     <= spc5_t3pc_s;
      else if(pcd5[3] == 0)spc5_t3pc_s     <= spc5_phy_pc_e; 
      else if(pce5[3] == 0)spc5_t3pc_s     <= spc5_phy_pc_m;
      
      if(~`DTUPATH5.fcl_fdp_thr_s2_l[0])     spc5_phy_pc_d   <= pcf5[0] ? spc5_t0pc_s : spc5_imiss_paddr_s;
      else if(~`DTUPATH5.fcl_fdp_thr_s2_l[1])spc5_phy_pc_d   <= pcf5[1] ? spc5_t1pc_s : spc5_imiss_paddr_s;
      else if(~`DTUPATH5.fcl_fdp_thr_s2_l[2])spc5_phy_pc_d   <= pcf5[2] ? spc5_t2pc_s : spc5_imiss_paddr_s;
      else if(~`DTUPATH5.fcl_fdp_thr_s2_l[3])spc5_phy_pc_d   <= pcf5[3] ? spc5_t3pc_s : spc5_imiss_paddr_s;

      spc5_phy_pc_e   <= spc5_phy_pc_d;
      spc5_phy_pc_m   <= spc5_phy_pc_e;
      spc5_phy_pc_w   <= {{8{spc5_phy_pc_m[39]}}, spc5_phy_pc_m[39:0]};
      
      if(spc5_inst_done && 
	 active_thread[{3'b101,spc5_thread_id[1:0]}])begin
/*
	 if(0 & $x_checker(`DTUPATH5.pc_w))begin
	    $display("%0d: Detected unkown pc value spc(%d) thread(%x) value(%x)", 
		     $time, 3'b101, spc5_thread_id[1:0], `DTUPATH5.pc_w);
	    `MONITOR_PATH.fail("Detected unkown pc");
	 end
*/
      end
`endif // ifdef RTL_SPARC5

`ifdef RTL_SPARC6
       //done
      spc6_inst_done                     <= sas_m6;
        //next pc select
      spc6_fcl_fdp_nextpcs_sel_pcs_f_l_e <= `DTUPATH6.fcl_fdp_nextpcs_sel_pcs_f_l;
      spc6_fcl_fdp_nextpcs_sel_pcf_f_l_e <= `DTUPATH6.fcl_fdp_nextpcs_sel_pcf_f_l;
      spc6_fcl_fdp_nextpcs_sel_pcd_f_l_e <= `DTUPATH6.fcl_fdp_nextpcs_sel_pcd_f_l;
      spc6_fcl_fdp_nextpcs_sel_pce_f_l_e <= `DTUPATH6.fcl_fdp_nextpcs_sel_pce_f_l;
      
      //pipe physical pc
      if(pcf6[0] == 0)spc6_t0pc_s          <= spc6_imiss_paddr_s;
      else if(pcs6[0] == 0)spc6_t0pc_s     <= spc6_t0pc_s; 
      else if(pcd6[0] == 0)spc6_t0pc_s     <= spc6_phy_pc_e; 
      else if(pce6[0] == 0)spc6_t0pc_s     <= spc6_phy_pc_m;

      if(pcf6[1] == 0)spc6_t1pc_s          <= spc6_imiss_paddr_s;
      else if(pcs6[1] == 0)spc6_t1pc_s     <= spc6_t1pc_s;
      else if(pcd6[1] == 0)spc6_t1pc_s     <= spc6_phy_pc_e; 
      else if(pce6[1] == 0)spc6_t1pc_s     <= spc6_phy_pc_m;
      
      if(pcf6[2] == 0)spc6_t2pc_s          <= spc6_imiss_paddr_s;
      else if(pcs6[2] == 0)spc6_t2pc_s     <= spc6_t2pc_s;
      else if(pcd6[2] == 0)spc6_t2pc_s     <= spc6_phy_pc_e; 
      else if(pce6[2] == 0)spc6_t2pc_s     <= spc6_phy_pc_m;
      
      if(pcf6[3] == 0)spc6_t3pc_s          <= spc6_imiss_paddr_s;
      else if(pcs6[3] == 0)spc6_t3pc_s     <= spc6_t3pc_s;
      else if(pcd6[3] == 0)spc6_t3pc_s     <= spc6_phy_pc_e; 
      else if(pce6[3] == 0)spc6_t3pc_s     <= spc6_phy_pc_m;
      
      if(~`DTUPATH6.fcl_fdp_thr_s2_l[0])     spc6_phy_pc_d   <= pcf6[0] ? spc6_t0pc_s : spc6_imiss_paddr_s;
      else if(~`DTUPATH6.fcl_fdp_thr_s2_l[1])spc6_phy_pc_d   <= pcf6[1] ? spc6_t1pc_s : spc6_imiss_paddr_s;
      else if(~`DTUPATH6.fcl_fdp_thr_s2_l[2])spc6_phy_pc_d   <= pcf6[2] ? spc6_t2pc_s : spc6_imiss_paddr_s;
      else if(~`DTUPATH6.fcl_fdp_thr_s2_l[3])spc6_phy_pc_d   <= pcf6[3] ? spc6_t3pc_s : spc6_imiss_paddr_s;

      spc6_phy_pc_e   <= spc6_phy_pc_d;
      spc6_phy_pc_m   <= spc6_phy_pc_e;
      spc6_phy_pc_w   <= {{8{spc6_phy_pc_m[39]}}, spc6_phy_pc_m[39:0]};
      
      if(spc6_inst_done && 
	 active_thread[{3'b110,spc6_thread_id[1:0]}])begin
/*
	 if(0 & $x_checker(`DTUPATH6.pc_w))begin
	    $display("%0d: Detected unkown pc value spc(%d) thread(%x) value(%x)", 
		     $time, 3'b110, spc6_thread_id[1:0], `DTUPATH6.pc_w);
	    `MONITOR_PATH.fail("Detected unkown pc");
	 end
*/
      end
`endif // ifdef RTL_SPARC6

`ifdef RTL_SPARC7
       //done
      spc7_inst_done                     <= sas_m7;
      
      spc7_fcl_fdp_nextpcs_sel_pcs_f_l_e <= `DTUPATH7.fcl_fdp_nextpcs_sel_pcs_f_l;
      spc7_fcl_fdp_nextpcs_sel_pcf_f_l_e <= `DTUPATH7.fcl_fdp_nextpcs_sel_pcf_f_l;
      spc7_fcl_fdp_nextpcs_sel_pcd_f_l_e <= `DTUPATH7.fcl_fdp_nextpcs_sel_pcd_f_l;
      spc7_fcl_fdp_nextpcs_sel_pce_f_l_e <= `DTUPATH7.fcl_fdp_nextpcs_sel_pce_f_l;
      //pipe physical pc
      if(pcf7[0] == 0)spc7_t0pc_s          <= spc7_imiss_paddr_s;
      else if(pcs7[0] == 0)spc7_t0pc_s     <= spc7_t0pc_s; 
      else if(pcd7[0] == 0)spc7_t0pc_s     <= spc7_phy_pc_e; 
      else if(pce7[0] == 0)spc7_t0pc_s     <= spc7_phy_pc_m;

      if(pcf7[1] == 0)spc7_t1pc_s          <= spc7_imiss_paddr_s;
      else if(pcs7[1] == 0)spc7_t1pc_s     <= spc7_t1pc_s;
      else if(pcd7[1] == 0)spc7_t1pc_s     <= spc7_phy_pc_e; 
      else if(pce7[1] == 0)spc7_t1pc_s     <= spc7_phy_pc_m;
      
      if(pcf7[2] == 0)spc7_t2pc_s          <= spc7_imiss_paddr_s;
      else if(pcs7[2] == 0)spc7_t2pc_s     <= spc7_t2pc_s;
      else if(pcd7[2] == 0)spc7_t2pc_s     <= spc7_phy_pc_e; 
      else if(pce7[2] == 0)spc7_t2pc_s     <= spc7_phy_pc_m;
      
      if(pcf7[3] == 0)spc7_t3pc_s          <= spc7_imiss_paddr_s;
      else if(pcs7[3] == 0)spc7_t3pc_s     <= spc7_t3pc_s;
      else if(pcd7[3] == 0)spc7_t3pc_s     <= spc7_phy_pc_e; 
      else if(pce7[3] == 0)spc7_t3pc_s     <= spc7_phy_pc_m;
      
      if(~`DTUPATH7.fcl_fdp_thr_s2_l[0])     spc7_phy_pc_d   <= pcf7[0] ? spc7_t0pc_s : spc7_imiss_paddr_s;
      else if(~`DTUPATH7.fcl_fdp_thr_s2_l[1])spc7_phy_pc_d   <= pcf7[1] ? spc7_t1pc_s : spc7_imiss_paddr_s;
      else if(~`DTUPATH7.fcl_fdp_thr_s2_l[2])spc7_phy_pc_d   <= pcf7[2] ? spc7_t2pc_s : spc7_imiss_paddr_s;
      else if(~`DTUPATH7.fcl_fdp_thr_s2_l[3])spc7_phy_pc_d   <= pcf7[3] ? spc7_t3pc_s : spc7_imiss_paddr_s;
      spc7_phy_pc_e   <= spc7_phy_pc_d;
      spc7_phy_pc_m   <= spc7_phy_pc_e;
      spc7_phy_pc_w   <= {{8{spc7_phy_pc_m[39]}}, spc7_phy_pc_m[39:0]}; 

      if(spc7_inst_done && 
	 active_thread[{3'b111,spc7_thread_id[1:0]}])begin
/*
	 if(0 & $x_checker(`DTUPATH7.pc_w))begin
	    $display("%0d: Detected unkown pc value spc(%d) thread(%x) value(%x)", 
		     $time, 3'b111, spc7_thread_id[1:0], `DTUPATH7.pc_w);
	    `MONITOR_PATH.fail("Detected unkown pc");
	 end
*/
      end
`endif // ifdef RTL_SPARC7

   end
   reg 		  dummy;

   task trap_extract;
      reg [2048:0] pc_str;
      reg [63:0]  tmp_val;   
      integer     i;
      begin
	 bad_trap_count = 0;
	 finish_mask    = 1;
	 diag_mask      = 0;
	 stub_mask      = 0;
	 if($value$plusargs("finish_mask=%h", finish_mask))$display ("%t: finish_mask %h", $time, finish_mask);
	 if($value$plusargs("good_trap=%s", pc_str))       $display ("%t: good_trap list %s", $time, pc_str);
	 if($value$plusargs("stub_mask=%h", stub_mask))    $display ("%t: stub_mask  %h", $time, stub_mask);

	 for(i = 0; i < 32;i = i + 1)if(finish_mask[i] === 1'bx)finish_mask[i] = 1'b0;
	 if(sas_def)dummy = $bw_good_trap(1, finish_mask);
	 for(i = 0; i < 8;i = i + 1) if(stub_mask[i] === 1'bx)stub_mask[i] = 1'b0;
	 
	 good_trap_count = 0;	
	 while ($parse (pc_str, "%h:", tmp_val))
	  begin
	     good_trap[good_trap_count] = tmp_val;
	     $display ("%t: good_trap %h", $time, good_trap[good_trap_count]);
	     good_trap_count = good_trap_count + 1;
	     if (good_trap_count > `GOOD_TRAP_COUNTER)
	       begin
		  $display ("%t: good_trap_count more than max-count %d.", $time, `GOOD_TRAP_COUNTER);
		  `MONITOR_PATH.fail("good_trap_count more than max-count");
	       end
	  end 
	 if($value$plusargs("bad_trap=%s", pc_str))$display ("%t: bad_trap list %s", $time, pc_str);
	 bad_trap_count = 0;	
	 while ($parse (pc_str, "%h:", tmp_val))
	   begin
	      bad_trap[bad_trap_count] = tmp_val;	     
	      $display ("%t: bad_trap %h", $time, bad_trap[bad_trap_count]);
	      bad_trap_count = bad_trap_count + 1;	     
	      if (bad_trap_count > `GOOD_TRAP_COUNTER)
		begin
		   $display ("%t: bad_trap_count more than max-count %d.", $time,`GOOD_TRAP_COUNTER);
		   `MONITOR_PATH.fail("bad_trap_count more than max-count.");
		end
	   end // while ($parse (pc_str, "%h:", tmp_val))
	 trap_count = good_trap_count > bad_trap_count ? good_trap_count :  bad_trap_count;
	 
      end
   endtask // trap_extract
   // deceide pass or fail
   reg [31:0]     timeout [31:0];
   reg [63:0] 	  rpc;
   integer 	  ind;
   //post-silicon request
   reg [63:0] 	  last_hit [31:0];
   //indicate the 2nd time hit.
   reg [31:0] 	  hitted;
   initial hitted = 0;
   
   task check_done;
      input   [7:0] cpu;
      integer       j, l;
      reg     [63:0]pc;
      reg     [4:0] i;
      
      begin
	 for(i = 0; i < 8; i = i + 1)begin
	    if(cpu[i])begin
	       case(i)
		 0 : begin j = {i[2:0], spc0_thread_id};pc = spc0_phy_pc_w;rpc = spc0_rtl_pc;end
		 1 : begin j = {i[2:0], spc1_thread_id};pc = spc1_phy_pc_w;rpc = spc1_rtl_pc;end
		 2 : begin j = {i[2:0], spc2_thread_id};pc = spc2_phy_pc_w;rpc = spc2_rtl_pc;end
		 3 : begin j = {i[2:0], spc3_thread_id};pc = spc3_phy_pc_w;rpc = spc3_rtl_pc;end
		 4 : begin j = {i[2:0], spc4_thread_id};pc = spc4_phy_pc_w;rpc = spc4_rtl_pc;end
		 5 : begin j = {i[2:0], spc5_thread_id};pc = spc5_phy_pc_w;rpc = spc5_rtl_pc;end
		 6 : begin j = {i[2:0], spc6_thread_id};pc = spc6_phy_pc_w;rpc = spc6_rtl_pc;end
		 7 : begin j = {i[2:0], spc7_thread_id};pc = spc7_phy_pc_w;rpc = spc7_rtl_pc;end
	       endcase
	       timeout[j] = 0;
               check_bad_trap(pc, i, j);
	       if(active_thread[j])begin
		  for(l = 0; l < good_trap_count; l = l + 1)begin
		     if(good_trap[l] == pc[39:0])begin
			if(sas_def && (good[j] == 0))dummy = $bw_good_trap(2, j, rpc);//command thread, pc
			if(good[j] == 0)$display("Info: spc(%0x) thread(%0x) Hit Good trap", j / 4, j % 4);
			//post-silicon debug
			if((sas_def == 0) && finish_mask[j])begin
			   if(good_flag)begin
			      if(!hitted[j])begin
				 last_hit[j] = pc[39:0];
				 hitted[j]   = 1;
			      end
			      else if(last_hit[j] == pc[39:0])good[j] = 1'b1;
			   end
			   else good[j] = 1'b1;
			end
			if(sas_def && active_thread[j])good[j]   = 1'b1;
			if(sas_def && finish_mask[j])good_for[j] = 1'b1;
		     end
		     if((sas_def == 0)        && 
			(good == finish_mask) && 
			(hit_bad == 0)        &&
			(stub_mask == stub_good))begin
			`TOP_MOD.diag_done = 1; 
			@(posedge clk);
			$display("%0d: Simulation -> PASS (HIT GOOD TRAP)", $time); 
			$finish;
		     end
		     if(sas_def && (good == active_thread))`TOP_MOD.diag_done = 1; 
		     if(sas_def)
		      if($bw_good_trap(3, j) && 
		        (hit_bad == 0)      &&
			(stub_mask == stub_good))begin
			`TOP_MOD.diag_done = 1; 
			if(`TOP_MOD.fail_flag == 1'b0)begin			      
			   repeat(2) @(posedge clk);
			   $display("%0d: Simulation -> PASS (HIT GOOD TRAP)", $time);
			   dum = $bw_sas_send(`PLI_QUIT);
			   $finish;
			end
		     end
		  end // for (l = 0; l < good_trap_count; l = l + 1)
	       end // if (active_thread[j])
	    end // if (cpu[i])
	 end
      end
   endtask
// get done signal;
   task gen_done;
      begin
	 done[0]   = spc0_inst_done;//sparc 0
	 done[1]   = spc1_inst_done;//sparc 1
	 done[2]   = spc2_inst_done;//sparc 2
	 done[3]   = spc3_inst_done;//sparc 3
	 done[4]   = spc4_inst_done;//sparc 4
	 done[5]   = spc5_inst_done;//sparc 5
	 done[6]   = spc6_inst_done;//sparc 6
	 done[7]   = spc7_inst_done;//sparc 7
      end
   endtask // gen_done
   
   reg first_rst;
   initial begin
      if($value$plusargs("TIMEOUT=%d", time_tmp))max = time_tmp;
      else max = 1000;
      #20//need to wait for socket initializing.
      trap_extract;
      done    = 0;
      good    = 0;
      active_thread = 0;
      hit_bad   = 0;
      first_rst = 1;
      for(ind = 0;ind < 32; ind = ind + 1)timeout[ind] = 0;
   end // initial begin
   always @(posedge rst_l)begin
      if(first_rst)begin
	 active_thread = 0;
	 first_rst     = 0;
	 done          = 0;
	 good          = 0; 
	 hit_bad       = 0;
      end 
   end
   //speed up checkeing
   task check_time;
      input [5:0] head;
      input [5:0] tail;

      integer  ind;
      begin
     	 for(ind = head; ind < tail; ind = ind + 1)begin
	    if(timeout[ind] > max && (good[ind] == 0))begin
               if((max_cycle == 0 || finish_mask[ind] == 0) && (thread_status[ind] == `THRFSM_HALT)
		  )begin
		  timeout[ind] = 0;
               end
	       else begin
		  $display("Info: spc(%0d) thread(%0d) -> timeout happen", ind / 4, ind % 4);  
		  `MONITOR_PATH.fail("TIMEOUT");
               end
	    end
	    else if(active_thread[ind] != good[ind])begin
	       timeout[ind] = timeout[ind] + 1;
	    end // if (finish_mask[ind] != good[ind])
	 end // for (ind = head; ind < tail; ind = ind + 1)
      end
   endtask // check_time

   //check good trap status after threads hit the good trap.
   //The reason for this is that the threads stay on halt status.
   task check_good;
     begin
      if($bw_good_trap(3, 0) && (hit_bad == 0))begin
	 `TOP_MOD.diag_done = 1; 
	 if(!`TOP_MOD.fail_flag)begin			      
	    repeat(2) @(posedge clk);
	    $display("%0d: Simulation -> PASS (HIT GOOD TRAP)", $time);
	    dum = $bw_sas_send(`PLI_QUIT);
	    $finish;
	 end
      end
     end
   endtask // check_good
   
  //deceide whether stub done or not.
   task check_stub;
      reg [3:0] i;
      begin
	 for(i = 0; i < 8; i = i + 1)begin
	    if(stub_mask[i] && 
	       `TOP_MOD.stub_done[i] &&
	       `TOP_MOD.stub_pass[i])stub_good[i] = 1'b1;
	    else if(stub_mask[i] && 
		    `TOP_MOD.stub_done[i] &&
		    `TOP_MOD.stub_pass[i] == 0)begin
	       $display("Info->Simulation terminated by stub.");
	       `MONITOR_PATH.fail("HIT BAD TRAP");
	    end
	 end
	if (sas_def) begin
	 if(stub_mask                && 
	    (stub_mask == stub_good) &&
	    (active_thread && $bw_good_trap(3, 0)   || 
	     active_thread == 0))begin
	    `TOP_MOD.diag_done = 1; 
	    @(posedge clk);
	    $display("Info->Simulation terminated by stub.");
	    $display("%0d: Simulation -> PASS (HIT GOOD TRAP)", $time); 
	    $finish;
	 end
       end
       else if ((good == finish_mask) && (stub_mask == stub_good)) begin
	    `TOP_MOD.diag_done = 1; 
	    @(posedge clk);
	    $display("Info->Simulation terminated by stub.");
	    $display("%0d: Simulation -> PASS (HIT GOOD TRAP)", $time); 
	    $finish;
       end
      end
   endtask // check_stub

  
  //main routine of pc cmp to finish the simulation. 
   always @(posedge clk)begin
      if(rst_l)begin
	 if(`TOP_MOD.stub_done)check_stub;
	 gen_done;
	 if(|done[7:0])check_done(done);
	 else if(sas_def && (good_for == finish_mask))check_good;
`ifdef INCLUDE_SAS_TASKS
	 get_thread_status;
`endif
	 if(active_thread[3:0])check_time(0,  4);
	 if(active_thread[7:4])check_time(4,  8);
	 if(active_thread[19:8])check_time(8, 20);
	 if(active_thread[31:20])check_time(20, 32);
      end // if (rst_l)
   end // always @ (posedge clk)
endmodule




