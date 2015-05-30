// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: monitor.v
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
`include "cross_module.h"
`include "iop.h"
//define and will move all the define to cross.h later
`define PLI_QUIT  1    /* None */


module monitor(/*AUTOARG*/
   // Inputs
   clk, cmp_gclk, rst_l
   );

   input clk;
   input cmp_gclk;
   input rst_l;

`ifdef MSS_SAT

    integer number, num, max_cycle, cycle;

    initial begin
        number = 2;
        num    = 0;
        cycle  = 0;

        if($value$plusargs("max_cycle=%d", max_cycle)) $display("max cycles = %d", max_cycle);
    end // initial begin
   
    always @(posedge clk)begin
        cycle = cycle + 1;
      
        if(cycle == max_cycle) begin
            $display("%0d : Simulation -> (terminated by reaching max cycles = %0d)", $time, max_cycle);
            $finish;
        end
    end

`else

   wire  reset = ~rst_l;
   integer number, num, f_time, max_cycle, cycle;
   reg [1023:0] err;
   reg 		err_f;
   reg 		bad;
   reg 		sas_def;
   reg          dum;
   
   initial
     begin
	number = 2;
	num    = 0;
	err_f  = 1;
	bad    = 0;
	max_cycle = 30000;
	cycle  = 0;
	if($test$plusargs("use_sas_tasks"))sas_def = 1;
      	else sas_def = 0;
	if($value$plusargs("wait_cycle_to_kill=%d", number))$display("wait cycles = %d", number);
	if($value$plusargs("max_cycle=%d", max_cycle))$display("max cycles = %d", max_cycle);
     end // initial begin
   always @(posedge clk)begin
     if(`TOP_MOD.diag_done == 0)cycle = cycle + 1;
      if(cycle == max_cycle)begin
	 $display("%0d : Simulation -> (terminated by reaching max cycles = %0d)", $time, max_cycle);
	 //$sas_client("quit");
	 if(sas_def)dum = $bw_sas_send(`PLI_QUIT);
	 $finish;
      end
   end
   
// central fail task. all the monitor should call this task to finish simulation.
   task fail;
      input [1023:0] comment;
      begin
	 if(bad)begin
	    $display("%0d : Simulation -> FAIL(%0s)", $time, comment);
	    if(sas_def)dum = $bw_sas_send(`PLI_QUIT);
	    //$sas_client("quit");
	    $finish; 
	 end
	 if(err_f)begin
	    err = comment;
	    f_time = $time;
	 end // if (err_f)
	 err_f = 0;
	 `TOP_MOD.fail_flag = 1'b1;
      end 
   endtask // fail
   always @(posedge clk)begin
      if(`TOP_MOD.fail_flag)begin
	 num = num+1;
	 if(num == number)begin
	    $display("%0d : Simulation -> FAIL(%0s)", f_time, err);
	    if(sas_def)dum = $bw_sas_send(`PLI_QUIT);
	    //$sas_client("quit");
	    $finish;
	 end
      end // if (`TOP_MOD.fail_flag)
   end
   
   /* l_cache_mon AUTO_TEMPLATE(

     //ICT
     .wrtag_f         (`IFUPATH@.ifq_ict_wrtag_f[28:0]),
     .wrway_f         (`IFUPATH@.icd.wrway_f[1:0]),
     .index_f         (`ICTPATH@.index_y[6:0]),
     .wrreq_f         (`ICTPATH@.wrreq_y),
    
    //ICV
     .wrreq_bf        (`ICVPATH@.wr_en),
     .wrindex_bf      (`ICVPATH@.wr_adr[6:2]),
     .wr_data         (`ICVPATH@.din_d1),
     .wren_f          (`ICVPATH@.bit_wen_d1[15:0]),

     .cpx_spc_data_cx (`PCXPATH@.cpx_spc_data_cx2),
     .cpx_spc_data_rdy_cx (`PCXPATH@.cpx_spc_data_rdy_cx2),
     .spc_pcx_data_pa (`TOP_DESIGN.sparc@.spc_pcx_data_pa),
     .spc_pcx_req_pq (`TOP_DESIGN.sparc@.spc_pcx_req_pq),
     .w0              (128'b0),
     .w1              (128'b0),
     .w2              (128'b0),
     .w3              (128'b0),
     .spc(@),
     );
    */
    /*thrfsm_mon AUTO_TEMPLATE(
     .wm_imiss        (`TOP_DESIGN.sparc@.ifu.swl.wm_imiss[3:0]),
     .wm_other        (`TOP_DESIGN.sparc@.ifu.swl.wm_other[3:0]),
     .wm_stbwait      (`TOP_DESIGN.sparc@.ifu.swl.wm_stbwait[3:0]),
     .thr_state0      (`TOP_DESIGN.sparc@.ifu.swl.thrfsm0.thr_state[4:0]),
     .thr_state1      (`TOP_DESIGN.sparc@.ifu.swl.thrfsm1.thr_state[4:0]),
     .thr_state2      (`TOP_DESIGN.sparc@.ifu.swl.thrfsm2.thr_state[4:0]),
     .thr_state3      (`TOP_DESIGN.sparc@.ifu.swl.thrfsm3.thr_state[4:0]),
     .rst_stallreq    (`TOP_DESIGN.sparc@.ifu.fcl.rst_stallreq),
     .ifq_fcl_stallreq (`TOP_DESIGN.sparc@.ifu.fcl.ifq_fcl_stallreq),
     .lsu_ifu_stallreq (`TOP_DESIGN.sparc@.ifu.fcl.lsu_ifu_stallreq),
     .ffu_ifu_stallreq (`TOP_DESIGN.sparc@.ifu.fcl.ffu_ifu_stallreq),
     .completion      (`TOP_DESIGN.sparc@.ifu.swl.completion),
     .mul_wait        (`TOP_DESIGN.sparc@.ifu.swl.mul_wait),
     .div_wait        (`TOP_DESIGN.sparc@.ifu.swl.div_wait),
     .fp_wait         (`TOP_DESIGN.sparc@.ifu.swl.fp_wait),
     .mul_wait_nxt    (`TOP_DESIGN.sparc@.ifu.swl.mul_wait_nxt),
     .div_wait_nxt    (`TOP_DESIGN.sparc@.ifu.swl.div_wait_nxt),
     .fp_wait_nxt     (`TOP_DESIGN.sparc@.ifu.swl.fp_wait_nxt),
     .mul_busy_d      (`TOP_DESIGN.sparc@.ifu.swl.mul_busy_d),
     .div_busy_d      (`TOP_DESIGN.sparc@.ifu.swl.div_busy_d),
     .fp_busy_d       (`TOP_DESIGN.sparc@.ifu.swl.fp_busy_d), 
     .ifet_ue_vec_d1  (`TOP_DESIGN.sparc@.ifu.fcl.ifet_ue_vec_d1),
     .cpu_id(3'h@));
    */
   /* spu_ma_mon AUTO_TEMPLATE(
    .wrmi_mamul_1sthalf   (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
    .wrmi_mamul_2ndhalf   (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
    .wrmi_maaeqb_1sthalf  (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
    .wrmi_maaeqb_2ndhalf  (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
    .iptr             (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
    .iminus_lenminus1 (`TOP_DESIGN.sparc@.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
    .mul_data         (`TOP_DESIGN.sparc@.spu.spu_madp.spu_madp_evedata[63:0]));
    */
    /* cmp_pcxandcpx  AUTO_TEMPLATE(
     .spc_pcx_data_pa(`PCXPATH@.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
     .cpx_spc_data_cx(`PCXPATH@.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
     .cpu(@),
     );
   
    */

   /*
    mask_mon AUTO_TEMPLATE(
    .wm_imiss (`TOP_DESIGN.sparc@.ifu.swl.wm_imiss),
    .wm_other (`TOP_DESIGN.sparc@.ifu.swl.wm_other),    
    .wm_stbwait (`TOP_DESIGN.sparc@.ifu.swl.wm_stbwait),        
    .mul_wait (`TOP_DESIGN.sparc@.ifu.swl.mul_wait),            
    .div_wait (`TOP_DESIGN.sparc@.ifu.swl.div_wait),                
    .fp_wait (`TOP_DESIGN.sparc@.ifu.swl.fp_wait),                    
    .mul_busy_e (`TOP_DESIGN.sparc@.ifu.swl.mul_busy_e),                        
    .div_busy_e (`TOP_DESIGN.sparc@.ifu.swl.div_busy_e),                            
    .fp_busy_e (`TOP_DESIGN.sparc@.ifu.swl.fp_busy_e),                                
    .ldmiss (`TOP_DESIGN.sparc@.ifu.swl.ldmiss),     
    .coreid (3'h@),                               
    );
    */
   
   /*
    nc_inv_chk AUTO_TEMPLATE(
    .cpxpkt_vld (`TOP_DESIGN.sparc@.ifu.lsu_ifu_cpxpkt_i1[144]),
    .cpxpkt_rtntype (`TOP_DESIGN.sparc@.ifu.lsu_ifu_cpxpkt_i1[143:140]),
    .nc (`TOP_DESIGN.sparc@.ifu.lsu_ifu_cpxpkt_i1[136]),
    .wv (`TOP_DESIGN.sparc@.ifu.lsu_ifu_cpxpkt_i1[133]),
    .coreid (3'h@),
    );
    */
   
   /*
    pc_muxsel_mon AUTO_TEMPLATE(
    .pc_f  (`TOP_DESIGN.sparc@.ifu.fdp.pc_f[47:0]),
    .thr_f (`TOP_DESIGN.sparc@.ifu.fcl.thr_f[3:0]),
    .t0pc_f (`TOP_DESIGN.sparc@.ifu.fdp.t0pc_f[47:0]),
    .t1pc_f (`TOP_DESIGN.sparc@.ifu.fdp.t1pc_f[47:0]),
    .t2pc_f (`TOP_DESIGN.sparc@.ifu.fdp.t2pc_f[47:0]),
    .t3pc_f (`TOP_DESIGN.sparc@.ifu.fdp.t3pc_f[47:0]),            
    .inst_vld_f (`TOP_DESIGN.sparc@.ifu.fcl.inst_vld_f),
    .dtu_fcl_running_s (`TOP_DESIGN.sparc@.ifu.dtu_fcl_running_s),
    .coreid(3'h@),
    );
    */
   
   /*
    nukeint_mon AUTO_TEMPLATE(
    .nukeint (`TOP_DESIGN.sparc@.ifu.tlu_ifu_nukeint_i2), 
    .resumint (`TOP_DESIGN.sparc@.ifu.tlu_ifu_resumint_i2),
    .rstint (`TOP_DESIGN.sparc@.ifu.tlu_ifu_rstint_i2),    
    .rstthr (`TOP_DESIGN.sparc@.ifu.tlu_ifu_rstthr_i2[3:0]), 
    .thr_state0 (`TOP_DESIGN.sparc@.ifu.swl.thrfsm0.thr_state[4:0]), 
    .thr_state1 (`TOP_DESIGN.sparc@.ifu.swl.thrfsm1.thr_state[4:0]), 
    .thr_state2 (`TOP_DESIGN.sparc@.ifu.swl.thrfsm2.thr_state[4:0]), 
    .thr_state3 (`TOP_DESIGN.sparc@.ifu.swl.thrfsm3.thr_state[4:0]),
    .coreid(3'h@),    
    );
    */
   
   /*
    stb_ovfl_mon AUTO_TEMPLATE(
    .lsu_ifu_stbcnt3 (`TOP_DESIGN.sparc@.ifu.lsu_ifu_stbcnt3), 
    .lsu_ifu_stbcnt2 (`TOP_DESIGN.sparc@.ifu.lsu_ifu_stbcnt2), 
    .lsu_ifu_stbcnt1 (`TOP_DESIGN.sparc@.ifu.lsu_ifu_stbcnt1), 
    .lsu_ifu_stbcnt0 (`TOP_DESIGN.sparc@.ifu.lsu_ifu_stbcnt0), 
    .stb_ctl_reset3 (`TOP_DESIGN.sparc@.lsu.stb_ctl3.reset), 
    .stb_ctl_reset2 (`TOP_DESIGN.sparc@.lsu.stb_ctl2.reset), 
    .stb_ctl_reset1 (`TOP_DESIGN.sparc@.lsu.stb_ctl1.reset), 
    .stb_ctl_reset0 (`TOP_DESIGN.sparc@.lsu.stb_ctl0.reset),
    .coreid(3'h@),
    );
   */

   /*
    icache_mutex_mon AUTO_TEMPLATE(
    .waysel_buf_s1 (`TOP_DESIGN.sparc@.ifu.wseldp.waysel_buf_s1),
    .alltag_err_s1 (`TOP_DESIGN.sparc@.ifu.errctl.alltag_err_s1),
    .tlb_cam_miss_s1 (`TOP_DESIGN.sparc@.ifu.fcl.tlb_cam_miss_s1),
    .cam_vld_s1 (`TOP_DESIGN.sparc@.ifu.fcl.cam_vld_s1),
    .coreid(3'h@),
    );
   */
   
   /*
   exu_mon AUTO_TEMPLATE(
    .exu_irf_wen    (`EXUPATH@.ecl_irf_wen_w),
    .exu_irf_wen2   (`EXUPATH@.ecl_irf_wen_w2),
    .exu_irf_data   (`EXUPATH@.byp_irf_rd_data_w),
    .exu_irf_data2  (`EXUPATH@.byp_irf_rd_data_w2),
    .exu_rd	    (`EXUPATH@.irf.ecl_irf_rd_w ),
    .restore_request(`EXUPATH@.ecl.writeback.restore_request),
    .divcntl_wb_req_g	    (`EXUPATH@.ecl.writeback.divcntl_wb_req_g),
    );
    */

   /*
    tlu_mon AUTO_TEMPLATE(
    .clk			(`TOP_DESIGN.sparc@.tlu.rclk),
    .grst_l			(`TOP_DESIGN.sparc@.tlu.grst_l),
    .rst_l			(`TOP_DESIGN.sparc@.tlu.tcl.tlu_rst_l),
	.lsu_ifu_flush_pipe_w		(`TOP_DESIGN.sparc@.lsu_ifu_flush_pipe_w),
	.tlu_lsu_int_ldxa_vld_w2	(`TOP_DESIGN.sparc@.tlu_lsu_int_ldxa_vld_w2),
	.tlu_lsu_int_ld_ill_va_w2	(`TOP_DESIGN.sparc@.tlu_lsu_int_ld_ill_va_w2),
	.tlu_scpd_wr_vld_g			(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
	.cpu_mondo_head_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
	.cpu_mondo_tail_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
	.dev_mondo_head_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.dev_mondo_head_wr_g),
	.dev_mondo_tail_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
	.resum_err_head_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.resum_err_head_wr_g),
	.resum_err_tail_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.resum_err_tail_wr_g),
	.nresum_err_head_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.nresum_err_head_wr_g),
	.nresum_err_tail_wr_g		(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.nresum_err_tail_wr_g),
	.ifu_lsu_ld_inst_e		(`TOP_DESIGN.sparc@.tlu.ifu_lsu_ld_inst_e),
	.ifu_lsu_st_inst_e		(`TOP_DESIGN.sparc@.tlu.ifu_lsu_st_inst_e),
	.ifu_lsu_alt_space_e	(`TOP_DESIGN.sparc@.tlu.ifu_lsu_alt_space_e),
	.tlu_early_flush_pipe_w	(`TOP_DESIGN.sparc@.tlu.tlu_early_flush_pipe_w),
	.tlu_asi_state_e		(`TOP_DESIGN.sparc@.tlu.tlu_asi_state_e),
	.exu_lsu_ldst_va_e		(`TOP_DESIGN.sparc@.tlu.exu_lsu_ldst_va_e),
	.por_rstint0_w2	(`TOP_DESIGN.sparc@.tlu.tcl.por_rstint0_w2),
	.por_rstint1_w2	(`TOP_DESIGN.sparc@.tlu.tcl.por_rstint1_w2),
	.por_rstint2_w2	(`TOP_DESIGN.sparc@.tlu.tcl.por_rstint2_w2),
	.por_rstint3_w2	(`TOP_DESIGN.sparc@.tlu.tcl.por_rstint3_w2),
	.tlu_gl_lvl0	(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.gl_lvl0),
	.tlu_gl_lvl1	(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.gl_lvl1),
	.tlu_gl_lvl2	(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.gl_lvl2),
	.tlu_gl_lvl3	(`TOP_DESIGN.sparc@.tlu.tlu_hyperv.gl_lvl3),
	.exu_gl_lvl0	(`TOP_DESIGN.sparc@.exu.rml.agp_thr0_next),
	.exu_gl_lvl1	(`TOP_DESIGN.sparc@.exu.rml.agp_thr1_next),
	.exu_gl_lvl2	(`TOP_DESIGN.sparc@.exu.rml.agp_thr2_next),
	.exu_gl_lvl3	(`TOP_DESIGN.sparc@.exu.rml.agp_thr3_next),
    .ifu_tlu_thrid_d		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_thrid_d), 
    .ifu_tlu_inst_vld_m		(`TOP_DESIGN.sparc@.tlu.ifu_tlu_inst_vld_m), 
    .ifu_tlu_imiss_e		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_imiss_e), 
    .ifu_tlu_immu_miss_m	(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_immu_miss_m),
    .ifu_tlu_flush_fd_w		(`TOP_DESIGN.sparc@.tlu.ifu_tlu_flush_fd_w),
    .tlu_thread_inst_vld_g	(`TOP_DESIGN.sparc@.tlu.tlu_pib.tlu_thread_inst_vld_g), 
    .tlu_thread_wsel_g		(`TOP_DESIGN.sparc@.tlu.tlu_pib.tlu_thread_wsel_g), 
    .ifu_tlu_l2imiss		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_l2imiss), 
    .ifu_tlu_sraddr_d		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_sraddr_d),
    .ifu_tlu_rsr_inst_d		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_rsr_inst_d), 
    .lsu_tlu_wsr_inst_e		(`TOP_DESIGN.sparc@.tlu.lsu_tlu_wsr_inst_e), 
    .tlu_wsr_inst_nq_g		(`TOP_DESIGN.sparc@.tlu.tlu_pib.tlu_wsr_inst_nq_g), 
    .tlu_wsr_data_w		(`TOP_DESIGN.sparc@.tlu.tlu_pib.tlu_wsr_data_w),
    .lsu_tlu_dcache_miss_w2	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), 
    .lsu_tlu_l2_dmiss		(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_l2_dmiss), 
    .lsu_tlu_stb_full_w2	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_stb_full_w2), 
    .lsu_tlu_dmmu_miss_g	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_dmmu_miss_g),
    .ffu_tlu_fpu_tid		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ffu_tlu_fpu_tid), 
    .ffu_tlu_fpu_cmplt		(`TOP_DESIGN.sparc@.tlu.tlu_pib.ffu_tlu_fpu_cmplt), 
    .tlu_pstate_priv		(`TOP_DESIGN.sparc@.tlu.local_pstate_priv),
    .tlu_hpstate_priv		(`TOP_DESIGN.sparc@.tlu.tlu_hpstate_priv), 
    .tlu_hpstate_enb		(`TOP_DESIGN.sparc@.tlu.tlu_hpstate_enb), 
    .tlu_pstate_ie		(`TOP_DESIGN.sparc@.tlu.local_pstate_ie), 
    .wsr_thread_inst_g		(`TOP_DESIGN.sparc@.tlu.tlu_pib.wsr_thread_inst_g),
    .lsu_tlu_defr_trp_taken_g	(`TOP_DESIGN.sparc@.tlu.lsu_tlu_defr_trp_taken_g), 
    .lsu_tlu_async_ttype_vld_w1	(`TOP_DESIGN.sparc@.tlu.lsu_tlu_async_ttype_vld_g), 
    .lsu_tlu_ttype_vld_m2	(`TOP_DESIGN.sparc@.tlu.lsu_tlu_ttype_vld_m2),
    .tlu_ifu_flush_pipe_w	(`TOP_DESIGN.sparc@.tlu.tcl.tlu_ifu_flush_pipe_w), 
    .tlu_pib_rsr_data_e		(`TOP_DESIGN.sparc@.tlu.tlu_pib.tlu_pib_rsr_data_e), 
    .tlu_pib_priv_act_trap_m	(`TOP_DESIGN.sparc@.tlu.tlu_pib.pib_priv_act_trap_m), 
    .tlu_pib_picl_wrap		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pib_picl_wrap), 
    .tlu_pib_pich_wrap		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pich_onebelow_flg), 
    .tlu_ifu_trappc_vld_w1	(`TOP_DESIGN.sparc@.tlu.tlu_ifu_trappc_vld_w1), 
    .tlu_ifu_trappc_w2		(`TOP_DESIGN.sparc@.tlu.tlu_ifu_trappc_w2), 
    .tlu_final_ttype_w2		(`TOP_DESIGN.sparc@.tlu.tlu_final_ttype_w2), 
    .tlu_ifu_trap_tid_w1	(`TOP_DESIGN.sparc@.tlu.tlu_ifu_trap_tid_w1), 
    .tlu_full_flush_pipe_w2	(`TOP_DESIGN.sparc@.tlu.tlu_full_flush_pipe_w2),
    .rtl_pcr0			(`TOP_DESIGN.sparc@.tlu.tlu_pib.pcr0), 
    .rtl_pcr1			(`TOP_DESIGN.sparc@.tlu.tlu_pib.pcr1), 
    .rtl_pcr2			(`TOP_DESIGN.sparc@.tlu.tlu_pib.pcr2), 
    .rtl_pcr3			(`TOP_DESIGN.sparc@.tlu.tlu_pib.pcr3),
    .rtl_lsu_tlu_stb_full_w2	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_stb_full_w2), 
    .rtl_fpu_cmplt_thread	(`TOP_DESIGN.sparc@.tlu.tlu_pib.fpu_cmplt_thread), 
    .rtl_imiss_thread_g		(`TOP_DESIGN.sparc@.tlu.tlu_pib.imiss_thread_g), 
    .rtl_lsu_tlu_dcache_miss_w2	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), 
    .rtl_immu_miss_thread_g	(`TOP_DESIGN.sparc@.tlu.tlu_pib.immu_miss_thread_g), 
    .rtl_dmmu_miss_thread_g	(`TOP_DESIGN.sparc@.tlu.tlu_pib.dmmu_miss_thread_g), 
    .rtl_ifu_tlu_l2imiss	(`TOP_DESIGN.sparc@.tlu.tlu_pib.ifu_tlu_l2imiss), 
    .rtl_lsu_tlu_l2_dmiss	(`TOP_DESIGN.sparc@.tlu.tlu_pib.lsu_tlu_l2_dmiss),
    .true_pil0			(`TOP_DESIGN.sparc@.tlu.tcl.true_pil0),
    .true_pil1			(`TOP_DESIGN.sparc@.tlu.tcl.true_pil1),
    .true_pil2			(`TOP_DESIGN.sparc@.tlu.tcl.true_pil2),
    .true_pil3			(`TOP_DESIGN.sparc@.tlu.tcl.true_pil3),
    .rtl_trp_lvl0		(`TOP_DESIGN.sparc@.tlu.tcl.trp_lvl0),
    .rtl_trp_lvl1		(`TOP_DESIGN.sparc@.tlu.tcl.trp_lvl1),
    .rtl_trp_lvl2		(`TOP_DESIGN.sparc@.tlu.tcl.trp_lvl2),
    .rtl_trp_lvl3		(`TOP_DESIGN.sparc@.tlu.tcl.trp_lvl3),
    .tcc_inst_w2		(`TOP_DESIGN.sparc@.tlu.tlu_pib.tcc_inst_w2),
    .rtl_pich_cnt0		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pich_cnt0),
    .rtl_pich_cnt1		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pich_cnt1),
    .rtl_pich_cnt2		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pich_cnt2),
    .rtl_pich_cnt3		(`TOP_DESIGN.sparc@.tlu.tlu_pib.pich_cnt3),
    .rtl_picl_cnt0		(`TOP_DESIGN.sparc@.tlu.tlu_pib.picl_cnt0),
    .rtl_picl_cnt1		(`TOP_DESIGN.sparc@.tlu.tlu_pib.picl_cnt1),
    .rtl_picl_cnt2		(`TOP_DESIGN.sparc@.tlu.tlu_pib.picl_cnt2),
    .rtl_picl_cnt3		(`TOP_DESIGN.sparc@.tlu.tlu_pib.picl_cnt3),
    .tlz_thread			(`TOP_DESIGN.sparc@.tlu.tcl.tlz_thread),
    .th0_sftint_15		(`TOP_DESIGN.sparc@.tlu.tdp.sftint0[15]),
    .th1_sftint_15		(`TOP_DESIGN.sparc@.tlu.tdp.sftint1[15]),
    .th2_sftint_15		(`TOP_DESIGN.sparc@.tlu.tdp.sftint2[15]),
    .th3_sftint_15		(`TOP_DESIGN.sparc@.tlu.tdp.sftint3[15]),
    .ifu_swint_g		(`TOP_DESIGN.sparc@.tlu.tcl.swint_g),
    .core_id			(3'h@),
    .tlu_itlb_wr_vld_g          (`TOP_DESIGN.sparc@.tlu_itlb_wr_vld_g),
    .tlu_itlb_dmp_vld_g         (`TOP_DESIGN.sparc@.tlu_itlb_dmp_vld_g),
    .tlu_itlb_tte_tag_w2        (`TOP_DESIGN.sparc@.tlu_itlb_tte_tag_w2),
    .tlu_itlb_tte_data_w2       (`TOP_DESIGN.sparc@.tlu_itlb_tte_data_w2),
    .itlb_wr_vld                (`TOP_DESIGN.sparc@.ifu.itlb.tlb_wr_vld),
    .dtlb_wr_vld                (`TOP_DESIGN.sparc@.lsu.dtlb.tlb_wr_vld),
    .tlu_tlb_access_en_l_d1     (`TOP_DESIGN.sparc@.tlu.mmu_dp.tlu_tlb_access_en_l_d1),
    .tlu_lng_ltncy_en_l         (`TOP_DESIGN.sparc@.tlu.mmu_dp.tlu_lng_ltncy_en_l),
    );
   */

   /*
    softint_mon AUTO_TEMPLATE(
    .rtl_softint0       (`TOP_DESIGN.sparc@.tlu.tdp.sftint0),
    .rtl_softint1       (`TOP_DESIGN.sparc@.tlu.tdp.sftint1),
    .rtl_softint2       (`TOP_DESIGN.sparc@.tlu.tdp.sftint2),
    .rtl_softint3       (`TOP_DESIGN.sparc@.tlu.tdp.sftint3),
    .rtl_wsr_data_w     (`TOP_DESIGN.sparc@.tlu.tdp.wsr_data_w),
    .rtl_sftint_en_l_g  (`TOP_DESIGN.sparc@.tlu.tdp.tlu_sftint_en_l_g),
    .rtl_sftint_b0_en   (`TOP_DESIGN.sparc@.tlu.tdp.sftint_b0_en),
    .rtl_tickcmp_int    (`TOP_DESIGN.sparc@.tlu.tdp.tickcmp_int),
    .rtl_sftint_b16_en  (`TOP_DESIGN.sparc@.tlu.tdp.sftint_b16_en),
    .rtl_stickcmp_int   (`TOP_DESIGN.sparc@.tlu.tdp.stickcmp_int),
    .rtl_sftint_b15_en  (`TOP_DESIGN.sparc@.tlu.tdp.sftint_b15_en),
    .rtl_pib_picl_wrap  (`TOP_DESIGN.sparc@.tlu.tdp.pib_picl_wrap),
    .rtl_pib_pich_wrap  (`TOP_DESIGN.sparc@.tlu.tdp.pib_pich_wrap),
    .rtl_wr_sftint_l_g  (`TOP_DESIGN.sparc@.tlu.tdp.tlu_wr_sftint_l_g),
    .rtl_set_sftint_l_g (`TOP_DESIGN.sparc@.tlu.tdp.tlu_set_sftint_l_g),
    .rtl_clr_sftint_l_g (`TOP_DESIGN.sparc@.tlu.tdp.tlu_clr_sftint_l_g),
    .rtl_clk		(`TOP_DESIGN.sparc@.tlu.tdp.rclk),
    .rtl_reset		(`TOP_DESIGN.sparc@.tlu.tdp.tlu_rst),
    .core_id		(3'h@),
    );
   */

`ifdef GATE_SIM
`else

`ifdef RTL_SPARC0
   l_cache_mon l_cache_mon0(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(0),			 // Templated
			    .index_f	(`ICTPATH0.index_y[6:0]), // Templated
			    .wrreq_f	(`ICTPATH0.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH0.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH0.ifq_ict_wrtag_f[28:0]), // Templated
			    .wr_data	(`ICVPATH0.din_d1),	 // Templated
			    .wren_f	(`ICVPATH0.bit_wen_d1[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH0.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH0.wr_adr[6:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH0.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH0.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`TOP_DESIGN.sparc0.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`TOP_DESIGN.sparc0.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon0(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .wm_imiss	(`TOP_DESIGN.sparc0.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`TOP_DESIGN.sparc0.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`TOP_DESIGN.sparc0.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`TOP_DESIGN.sparc0.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			  .thr_state1	(`TOP_DESIGN.sparc0.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			  .thr_state2	(`TOP_DESIGN.sparc0.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			  .thr_state3	(`TOP_DESIGN.sparc0.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			  .rst_stallreq	(`TOP_DESIGN.sparc0.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`TOP_DESIGN.sparc0.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`TOP_DESIGN.sparc0.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`TOP_DESIGN.sparc0.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`TOP_DESIGN.sparc0.ifu.swl.completion), // Templated
			  .mul_wait	(`TOP_DESIGN.sparc0.ifu.swl.mul_wait), // Templated
			  .div_wait	(`TOP_DESIGN.sparc0.ifu.swl.div_wait), // Templated
			  .fp_wait	(`TOP_DESIGN.sparc0.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`TOP_DESIGN.sparc0.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`TOP_DESIGN.sparc0.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`TOP_DESIGN.sparc0.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`TOP_DESIGN.sparc0.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`TOP_DESIGN.sparc0.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`TOP_DESIGN.sparc0.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`TOP_DESIGN.sparc0.ifu.fcl.ifet_ue_vec_d1), // Templated
			  .cpu_id	(3'h0));			 // Templated
   exu_mon exu_mon0(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH0.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH0.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH0.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH0.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH0.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH0.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH0.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon0(/*AUTOINST*/
		    // Inputs
		    .clk		(`TOP_DESIGN.sparc0.tlu.rclk), // Templated
		    .grst_l		(`TOP_DESIGN.sparc0.tlu.grst_l), // Templated
		    .rst_l		(`TOP_DESIGN.sparc0.tlu.tcl.tlu_rst_l), // Templated
			.lsu_ifu_flush_pipe_w	(`TOP_DESIGN.sparc0.lsu_ifu_flush_pipe_w),
			.tlu_lsu_int_ldxa_vld_w2(`TOP_DESIGN.sparc0.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`TOP_DESIGN.sparc0.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`TOP_DESIGN.sparc0.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`TOP_DESIGN.sparc0.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`TOP_DESIGN.sparc0.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`TOP_DESIGN.sparc0.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`TOP_DESIGN.sparc0.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`TOP_DESIGN.sparc0.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`TOP_DESIGN.sparc0.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`TOP_DESIGN.sparc0.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`TOP_DESIGN.sparc0.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`TOP_DESIGN.sparc0.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`TOP_DESIGN.sparc0.tlu.tlu_hyperv.gl_lvl3),
			.exu_gl_lvl0	(`TOP_DESIGN.sparc0.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`TOP_DESIGN.sparc0.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`TOP_DESIGN.sparc0.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`TOP_DESIGN.sparc0.exu.rml.agp_thr3_next),
		    .ifu_tlu_thrid_d	(`TOP_DESIGN.sparc0.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`TOP_DESIGN.sparc0.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`TOP_DESIGN.sparc0.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`TOP_DESIGN.sparc0.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`TOP_DESIGN.sparc0.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`TOP_DESIGN.sparc0.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`TOP_DESIGN.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`TOP_DESIGN.sparc0.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`TOP_DESIGN.sparc0.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`TOP_DESIGN.sparc0.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`TOP_DESIGN.sparc0.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`TOP_DESIGN.sparc0.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`TOP_DESIGN.sparc0.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`TOP_DESIGN.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`TOP_DESIGN.sparc0.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`TOP_DESIGN.sparc0.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`TOP_DESIGN.sparc0.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`TOP_DESIGN.sparc0.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`TOP_DESIGN.sparc0.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`TOP_DESIGN.sparc0.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`TOP_DESIGN.sparc0.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`TOP_DESIGN.sparc0.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`TOP_DESIGN.sparc0.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`TOP_DESIGN.sparc0.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`TOP_DESIGN.sparc0.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`TOP_DESIGN.sparc0.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`TOP_DESIGN.sparc0.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`TOP_DESIGN.sparc0.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`TOP_DESIGN.sparc0.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`TOP_DESIGN.sparc0.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`TOP_DESIGN.sparc0.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`TOP_DESIGN.sparc0.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`TOP_DESIGN.sparc0.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`TOP_DESIGN.sparc0.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`TOP_DESIGN.sparc0.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`TOP_DESIGN.sparc0.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`TOP_DESIGN.sparc0.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`TOP_DESIGN.sparc0.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`TOP_DESIGN.sparc0.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`TOP_DESIGN.sparc0.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`TOP_DESIGN.sparc0.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`TOP_DESIGN.sparc0.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`TOP_DESIGN.sparc0.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`TOP_DESIGN.sparc0.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`TOP_DESIGN.sparc0.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`TOP_DESIGN.sparc0.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`TOP_DESIGN.sparc0.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`TOP_DESIGN.sparc0.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc0.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`TOP_DESIGN.sparc0.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`TOP_DESIGN.sparc0.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc0.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`TOP_DESIGN.sparc0.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`TOP_DESIGN.sparc0.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`TOP_DESIGN.sparc0.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`TOP_DESIGN.sparc0.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`TOP_DESIGN.sparc0.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`TOP_DESIGN.sparc0.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`TOP_DESIGN.sparc0.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`TOP_DESIGN.sparc0.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`TOP_DESIGN.sparc0.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`TOP_DESIGN.sparc0.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`TOP_DESIGN.sparc0.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`TOP_DESIGN.sparc0.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`TOP_DESIGN.sparc0.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`TOP_DESIGN.sparc0.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`TOP_DESIGN.sparc0.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`TOP_DESIGN.sparc0.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`TOP_DESIGN.sparc0.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`TOP_DESIGN.sparc0.tlu.tcl.swint_g), // Templated
		    .core_id		(3'h0),			 // Templated
		    .tlu_itlb_wr_vld_g	(`TOP_DESIGN.sparc0.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`TOP_DESIGN.sparc0.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`TOP_DESIGN.sparc0.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`TOP_DESIGN.sparc0.tlu_itlb_tte_data_w2), // Templated
		    .itlb_wr_vld	(`TOP_DESIGN.sparc0.ifu.itlb.tlb_wr_vld), // Templated
		    .dtlb_wr_vld	(`TOP_DESIGN.sparc0.lsu.dtlb.tlb_wr_vld), // Templated
		    .tlu_tlb_access_en_l_d1(`TOP_DESIGN.sparc0.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
		    .tlu_lng_ltncy_en_l	(`TOP_DESIGN.sparc0.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon0 (/*AUTOINST*/
			      // Inputs
			      .rtl_softint0(`TOP_DESIGN.sparc0.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`TOP_DESIGN.sparc0.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`TOP_DESIGN.sparc0.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`TOP_DESIGN.sparc0.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`TOP_DESIGN.sparc0.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`TOP_DESIGN.sparc0.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`TOP_DESIGN.sparc0.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`TOP_DESIGN.sparc0.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`TOP_DESIGN.sparc0.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`TOP_DESIGN.sparc0.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`TOP_DESIGN.sparc0.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`TOP_DESIGN.sparc0.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`TOP_DESIGN.sparc0.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`TOP_DESIGN.sparc0.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`TOP_DESIGN.sparc0.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`TOP_DESIGN.sparc0.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`TOP_DESIGN.sparc0.tlu.tdp.rclk), // Templated
			      .rtl_reset(`TOP_DESIGN.sparc0.tlu.tdp.tlu_rst), // Templated
			      .core_id	(3'h0));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon0(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .thr_state0	(`TOP_DESIGN.sparc0.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			    .thr_state1	(`TOP_DESIGN.sparc0.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			    .thr_state2	(`TOP_DESIGN.sparc0.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			    .thr_state3	(`TOP_DESIGN.sparc0.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			    .rstthr	(`TOP_DESIGN.sparc0.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			    .nukeint	(`TOP_DESIGN.sparc0.ifu.tlu_ifu_nukeint_i2), // Templated
			    .resumint	(`TOP_DESIGN.sparc0.ifu.tlu_ifu_resumint_i2), // Templated
			    .rstint	(`TOP_DESIGN.sparc0.ifu.tlu_ifu_rstint_i2), // Templated
			    .coreid	(3'h0));			 // Templated
   mask_mon mask_mon0(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
		      .wm_imiss		(`TOP_DESIGN.sparc0.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`TOP_DESIGN.sparc0.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`TOP_DESIGN.sparc0.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`TOP_DESIGN.sparc0.ifu.swl.mul_wait), // Templated
		      .div_wait		(`TOP_DESIGN.sparc0.ifu.swl.div_wait), // Templated
		      .fp_wait		(`TOP_DESIGN.sparc0.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`TOP_DESIGN.sparc0.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`TOP_DESIGN.sparc0.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`TOP_DESIGN.sparc0.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`TOP_DESIGN.sparc0.ifu.swl.ldmiss), // Templated
		      .coreid		(3'h0));			 // Templated
   pc_muxsel_mon pc_muxsel_mon0(/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.t0pc_f	(`TOP_DESIGN.sparc0.ifu.fdp.t0pc_f[47:0]), // Templated
				.t1pc_f	(`TOP_DESIGN.sparc0.ifu.fdp.t1pc_f[47:0]), // Templated
				.t2pc_f	(`TOP_DESIGN.sparc0.ifu.fdp.t2pc_f[47:0]), // Templated
				.t3pc_f	(`TOP_DESIGN.sparc0.ifu.fdp.t3pc_f[47:0]), // Templated
				.pc_f	(`TOP_DESIGN.sparc0.ifu.fdp.pc_f[47:0]), // Templated
				.inst_vld_f(`TOP_DESIGN.sparc0.ifu.fcl.inst_vld_f), // Templated
				.dtu_fcl_running_s(`TOP_DESIGN.sparc0.ifu.dtu_fcl_running_s), // Templated
				.thr_f	(`TOP_DESIGN.sparc0.ifu.fcl.thr_f[3:0]), // Templated
				.coreid	(3'h0));			 // Templated
   stb_ovfl_mon stb_ovfl_mon0(/*AUTOINST*/
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
			      .lsu_ifu_stbcnt3(`TOP_DESIGN.sparc0.ifu.lsu_ifu_stbcnt3), // Templated
			      .lsu_ifu_stbcnt2(`TOP_DESIGN.sparc0.ifu.lsu_ifu_stbcnt2), // Templated
			      .lsu_ifu_stbcnt1(`TOP_DESIGN.sparc0.ifu.lsu_ifu_stbcnt1), // Templated
			      .lsu_ifu_stbcnt0(`TOP_DESIGN.sparc0.ifu.lsu_ifu_stbcnt0), // Templated
			      .stb_ctl_reset3(`TOP_DESIGN.sparc0.lsu.stb_ctl3.reset), // Templated
			      .stb_ctl_reset2(`TOP_DESIGN.sparc0.lsu.stb_ctl2.reset), // Templated
			      .stb_ctl_reset1(`TOP_DESIGN.sparc0.lsu.stb_ctl1.reset), // Templated
			      .stb_ctl_reset0(`TOP_DESIGN.sparc0.lsu.stb_ctl0.reset), // Templated
			      .coreid	(3'h0));			 // Templated
   icache_mutex_mon icache_mutex_mon0(/*AUTOINST*/
				      // Inputs
				      .clk(clk),
				      .rst_l(rst_l),
				      .waysel_buf_s1(`TOP_DESIGN.sparc0.ifu.wseldp.waysel_buf_s1), // Templated
				      .alltag_err_s1(`TOP_DESIGN.sparc0.ifu.errctl.alltag_err_s1), // Templated
				      .tlb_cam_miss_s1(`TOP_DESIGN.sparc0.ifu.fcl.tlb_cam_miss_s1), // Templated
				      .cam_vld_s1(`TOP_DESIGN.sparc0.ifu.fcl.cam_vld_s1), // Templated
				      .coreid(3'h0));		 // Templated
   nc_inv_chk nc_inv_chk0(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .cpxpkt_vld	(`TOP_DESIGN.sparc0.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`TOP_DESIGN.sparc0.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`TOP_DESIGN.sparc0.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`TOP_DESIGN.sparc0.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
			  .coreid	(3'h0));			 // Templated
   
   spu_ma_mon spu_ma_mon0(/* AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .wrmi_mamul_1sthalf(`TOP_DESIGN.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
			  .wrmi_mamul_2ndhalf(`TOP_DESIGN.sparc0.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
			  .wrmi_maaeqb_1sthalf(`TOP_DESIGN.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
			  .wrmi_maaeqb_2ndhalf(`TOP_DESIGN.sparc0.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
			  .iptr		(`TOP_DESIGN.sparc0.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
			  .iminus_lenminus1(`TOP_DESIGN.sparc0.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
			  .mul_data	(`TOP_DESIGN.sparc0.spu.spu_madp.spu_madp_evedata[63:0]));
   
//   cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
//				// Inputs
//				.clk	(clk),
//				.rst_l	(rst_l),
//				.spc_pcx_data_pa(`PCXPATH0.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
//				.cpx_spc_data_cx(`PCXPATH0.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
//				.cpu	(0));

   tso_mon tso_mon0( .clk       (clk), .rst_l   (rst_l));

   lsu_mon lsu_mon0( .clk       (clk), .rst_l   (rst_l));
   lsu_mon2 lsu_mon2( .clk       (clk), .rst_l   (rst_l));
   multicycle_mon multicycle_mon(.clk       (clk), .rst_l   (rst_l));

   `ifdef RTL_IOBDG
   ctu_mon ctu_mon0( );
   dbginit_mon dbginit_mon( );
   `endif

        // tlb monitor
//   tlb_mon tlb_mon0 ( /* AUTOINST*/
//                            // Outputs
//                            // Inputs
//                                .clk    (clk),
//                                .reset  (rst_l),
//                                .cpuid  (3'b000),
//                                .ifu_tlu_thrid_e(`TOP_DESIGN.sparc0.lsu.ifu_tlu_thrid_e),
//                                .exu_lsu_rs3_data_e(`TOP_DESIGN.sparc0.lsu.exu_lsu_rs3_data_e),
//                                .exu_lsu_ldst_va_e(`TOP_DESIGN.sparc0.lsu.exu_lsu_ldst_va_e),
//                                .ifu_lsu_ld_inst_e(`TOP_DESIGN.sparc0.lsu.ifu_lsu_ld_inst_e),
//                                .ifu_lsu_st_inst_e(`TOP_DESIGN.sparc0.lsu.ifu_lsu_st_inst_e),
//                                .asi_d(`TOP_DESIGN.sparc0.lsu.dctl.asi_d),
//                                .dtlb_wr_vld(`TOP_DESIGN.sparc0.lsu.dtlb.tlb_wr_vld),
//                                .dtlb_rw_index(`TOP_DESIGN.sparc0.lsu.dtlb.tlb_rw_index),
//                                .dtlb_rw_index_vld(`TOP_DESIGN.sparc0.lsu.dtlb.tlb_rw_index_vld),
//                                .tlu_dtlb_tte_data_w2(`TOP_DESIGN.sparc0.tlu.mmu_dp.tlu_dtlb_tte_data_w2),
//                                .tlu_dtlb_tte_tag_w2(`TOP_DESIGN.sparc0.tlu.mmu_dp.tlu_dtlb_tte_tag_w2),
//                                .dtlb_entry_replace(`TOP_DESIGN.sparc0.lsu.dtlb.tlb_entry_replace),
//                                .dtlb_entry_vld(`TOP_DESIGN.sparc0.lsu.dtlb.tlb_entry_vld),
//                                .tlb_access_sel_thrd0(`TOP_DESIGN.sparc0.lsu.dctl.tlb_access_sel_thrd0),
//                                .tlb_access_sel_thrd1(`TOP_DESIGN.sparc0.lsu.dctl.tlb_access_sel_thrd1),
//                                .tlb_access_sel_thrd2(`TOP_DESIGN.sparc0.lsu.dctl.tlb_access_sel_thrd2),
//                                .tlb_access_sel_thrd3(`TOP_DESIGN.sparc0.lsu.dctl.tlb_access_sel_thrd3),
//                                .lsu_tlu_tlb_st_inst_m(`TOP_DESIGN.sparc0.lsu.dctl.lsu_tlu_tlb_st_inst_m),
//                                .itlb_wr_vld(`TOP_DESIGN.sparc0.ifu.itlb.tlb_wr_vld),
//                                .itlb_rw_index(`TOP_DESIGN.sparc0.ifu.itlb.tlb_rw_index),
//                                .itlb_rw_index_vld(`TOP_DESIGN.sparc0.ifu.itlb.tlb_rw_index_vld),
//                                .tlu_itlb_tte_data_w2(`TOP_DESIGN.sparc0.tlu.mmu_dp.tlu_itlb_tte_data_w2),
//                                .tlu_itlb_tte_tag_w2(`TOP_DESIGN.sparc0.tlu.mmu_dp.tlu_itlb_tte_tag_w2),
//                                .itlb_entry_replace(`TOP_DESIGN.sparc0.ifu.itlb.tlb_entry_replace),
//                                .itlb_entry_vld(`TOP_DESIGN.sparc0.ifu.itlb.tlb_entry_vld),
//                                .pg_size(`TOP_DESIGN.sparc0.tlu.mmu_ctl.pg_size)
//   ); // tlb monitor

   
`endif // ifdef RTL_SPARC0
`ifdef RTL_SPARC1
   l_cache_mon l_cache_mon1(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(1),			 // Templated
			    .index_f	(`ICTPATH1.index_y[6:0]), // Templated
			    .wrreq_f	(`ICTPATH1.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH1.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH1.ifq_ict_wrtag_f[28:0]), // Templated
			    .wr_data	(`ICVPATH1.din_d1),	 // Templated
			    .wren_f	(`ICVPATH1.bit_wen_d1[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH1.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH1.wr_adr[6:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH1.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH1.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`TOP_DESIGN.sparc1.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`TOP_DESIGN.sparc1.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon1(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .wm_imiss	(`TOP_DESIGN.sparc1.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`TOP_DESIGN.sparc1.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`TOP_DESIGN.sparc1.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`TOP_DESIGN.sparc1.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			  .thr_state1	(`TOP_DESIGN.sparc1.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			  .thr_state2	(`TOP_DESIGN.sparc1.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			  .thr_state3	(`TOP_DESIGN.sparc1.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			  .rst_stallreq	(`TOP_DESIGN.sparc1.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`TOP_DESIGN.sparc1.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`TOP_DESIGN.sparc1.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`TOP_DESIGN.sparc1.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`TOP_DESIGN.sparc1.ifu.swl.completion), // Templated
			  .mul_wait	(`TOP_DESIGN.sparc1.ifu.swl.mul_wait), // Templated
			  .div_wait	(`TOP_DESIGN.sparc1.ifu.swl.div_wait), // Templated
			  .fp_wait	(`TOP_DESIGN.sparc1.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`TOP_DESIGN.sparc1.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`TOP_DESIGN.sparc1.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`TOP_DESIGN.sparc1.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`TOP_DESIGN.sparc1.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`TOP_DESIGN.sparc1.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`TOP_DESIGN.sparc1.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`TOP_DESIGN.sparc1.ifu.fcl.ifet_ue_vec_d1), // Templated
			  .cpu_id	(3'h1));			 // Templated
   exu_mon exu_mon1(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH1.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH1.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH1.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH1.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH1.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH1.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH1.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon1(/*AUTOINST*/
		    // Inputs
		    .clk		(`TOP_DESIGN.sparc1.tlu.rclk), // Templated
		    .grst_l		(`TOP_DESIGN.sparc1.tlu.grst_l), // Templated
		    .rst_l		(`TOP_DESIGN.sparc1.tlu.tcl.tlu_rst_l), // Templated
			.lsu_ifu_flush_pipe_w	(`TOP_DESIGN.sparc1.lsu_ifu_flush_pipe_w),
			.tlu_lsu_int_ldxa_vld_w2(`TOP_DESIGN.sparc1.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`TOP_DESIGN.sparc1.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`TOP_DESIGN.sparc1.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`TOP_DESIGN.sparc1.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`TOP_DESIGN.sparc1.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`TOP_DESIGN.sparc1.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`TOP_DESIGN.sparc1.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`TOP_DESIGN.sparc1.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`TOP_DESIGN.sparc1.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`TOP_DESIGN.sparc1.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`TOP_DESIGN.sparc1.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`TOP_DESIGN.sparc1.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`TOP_DESIGN.sparc1.tlu.tlu_hyperv.gl_lvl3),
			.exu_gl_lvl0	(`TOP_DESIGN.sparc1.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`TOP_DESIGN.sparc1.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`TOP_DESIGN.sparc1.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`TOP_DESIGN.sparc1.exu.rml.agp_thr3_next),
		    .ifu_tlu_thrid_d	(`TOP_DESIGN.sparc1.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`TOP_DESIGN.sparc1.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`TOP_DESIGN.sparc1.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`TOP_DESIGN.sparc1.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`TOP_DESIGN.sparc1.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`TOP_DESIGN.sparc1.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`TOP_DESIGN.sparc1.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`TOP_DESIGN.sparc1.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`TOP_DESIGN.sparc1.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`TOP_DESIGN.sparc1.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`TOP_DESIGN.sparc1.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`TOP_DESIGN.sparc1.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`TOP_DESIGN.sparc1.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc1.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`TOP_DESIGN.sparc1.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc1.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`TOP_DESIGN.sparc1.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`TOP_DESIGN.sparc1.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`TOP_DESIGN.sparc1.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`TOP_DESIGN.sparc1.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`TOP_DESIGN.sparc1.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`TOP_DESIGN.sparc1.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`TOP_DESIGN.sparc1.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`TOP_DESIGN.sparc1.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`TOP_DESIGN.sparc1.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`TOP_DESIGN.sparc1.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`TOP_DESIGN.sparc1.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`TOP_DESIGN.sparc1.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`TOP_DESIGN.sparc1.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`TOP_DESIGN.sparc1.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`TOP_DESIGN.sparc1.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`TOP_DESIGN.sparc1.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`TOP_DESIGN.sparc1.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`TOP_DESIGN.sparc1.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`TOP_DESIGN.sparc1.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`TOP_DESIGN.sparc1.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`TOP_DESIGN.sparc1.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`TOP_DESIGN.sparc1.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`TOP_DESIGN.sparc1.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`TOP_DESIGN.sparc1.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`TOP_DESIGN.sparc1.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`TOP_DESIGN.sparc1.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`TOP_DESIGN.sparc1.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`TOP_DESIGN.sparc1.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`TOP_DESIGN.sparc1.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`TOP_DESIGN.sparc1.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`TOP_DESIGN.sparc1.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`TOP_DESIGN.sparc1.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`TOP_DESIGN.sparc1.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`TOP_DESIGN.sparc1.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc1.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`TOP_DESIGN.sparc1.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`TOP_DESIGN.sparc1.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc1.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`TOP_DESIGN.sparc1.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`TOP_DESIGN.sparc1.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`TOP_DESIGN.sparc1.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`TOP_DESIGN.sparc1.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`TOP_DESIGN.sparc1.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`TOP_DESIGN.sparc1.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`TOP_DESIGN.sparc1.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`TOP_DESIGN.sparc1.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`TOP_DESIGN.sparc1.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`TOP_DESIGN.sparc1.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`TOP_DESIGN.sparc1.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`TOP_DESIGN.sparc1.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`TOP_DESIGN.sparc1.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`TOP_DESIGN.sparc1.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`TOP_DESIGN.sparc1.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`TOP_DESIGN.sparc1.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`TOP_DESIGN.sparc1.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`TOP_DESIGN.sparc1.tlu.tcl.swint_g), // Templated
		    .core_id		(3'h1),			 // Templated
		    .tlu_itlb_wr_vld_g	(`TOP_DESIGN.sparc1.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`TOP_DESIGN.sparc1.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`TOP_DESIGN.sparc1.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`TOP_DESIGN.sparc1.tlu_itlb_tte_data_w2), // Templated
		    .itlb_wr_vld	(`TOP_DESIGN.sparc1.ifu.itlb.tlb_wr_vld), // Templated
		    .dtlb_wr_vld	(`TOP_DESIGN.sparc1.lsu.dtlb.tlb_wr_vld), // Templated
		    .tlu_tlb_access_en_l_d1(`TOP_DESIGN.sparc1.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
		    .tlu_lng_ltncy_en_l	(`TOP_DESIGN.sparc1.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon1 (/*AUTOINST*/
			      // Inputs
			      .rtl_softint0(`TOP_DESIGN.sparc1.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`TOP_DESIGN.sparc1.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`TOP_DESIGN.sparc1.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`TOP_DESIGN.sparc1.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`TOP_DESIGN.sparc1.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`TOP_DESIGN.sparc1.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`TOP_DESIGN.sparc1.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`TOP_DESIGN.sparc1.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`TOP_DESIGN.sparc1.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`TOP_DESIGN.sparc1.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`TOP_DESIGN.sparc1.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`TOP_DESIGN.sparc1.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`TOP_DESIGN.sparc1.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`TOP_DESIGN.sparc1.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`TOP_DESIGN.sparc1.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`TOP_DESIGN.sparc1.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`TOP_DESIGN.sparc1.tlu.tdp.rclk), // Templated
			      .rtl_reset(`TOP_DESIGN.sparc1.tlu.tdp.tlu_rst), // Templated
			      .core_id	(3'h1));			 // Templated
`endif // ifdef GATE_SIM


   nukeint_mon nukeint_mon1 (/*AUTOINST*/
			     // Inputs
			     .clk	(clk),
			     .rst_l	(rst_l),
			     .thr_state0(`TOP_DESIGN.sparc1.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			     .thr_state1(`TOP_DESIGN.sparc1.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			     .thr_state2(`TOP_DESIGN.sparc1.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			     .thr_state3(`TOP_DESIGN.sparc1.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			     .rstthr	(`TOP_DESIGN.sparc1.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			     .nukeint	(`TOP_DESIGN.sparc1.ifu.tlu_ifu_nukeint_i2), // Templated
			     .resumint	(`TOP_DESIGN.sparc1.ifu.tlu_ifu_resumint_i2), // Templated
			     .rstint	(`TOP_DESIGN.sparc1.ifu.tlu_ifu_rstint_i2), // Templated
			     .coreid	(3'h1));			 // Templated
   mask_mon mask_mon1(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
		      .wm_imiss		(`TOP_DESIGN.sparc1.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`TOP_DESIGN.sparc1.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`TOP_DESIGN.sparc1.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`TOP_DESIGN.sparc1.ifu.swl.mul_wait), // Templated
		      .div_wait		(`TOP_DESIGN.sparc1.ifu.swl.div_wait), // Templated
		      .fp_wait		(`TOP_DESIGN.sparc1.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`TOP_DESIGN.sparc1.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`TOP_DESIGN.sparc1.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`TOP_DESIGN.sparc1.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`TOP_DESIGN.sparc1.ifu.swl.ldmiss), // Templated
		      .coreid		(3'h1));			 // Templated
   pc_muxsel_mon pc_muxsel_mon1 (/*AUTOINST*/
				 // Inputs
				 .clk	(clk),
				 .rst_l	(rst_l),
				 .t0pc_f(`TOP_DESIGN.sparc1.ifu.fdp.t0pc_f[47:0]), // Templated
				 .t1pc_f(`TOP_DESIGN.sparc1.ifu.fdp.t1pc_f[47:0]), // Templated
				 .t2pc_f(`TOP_DESIGN.sparc1.ifu.fdp.t2pc_f[47:0]), // Templated
				 .t3pc_f(`TOP_DESIGN.sparc1.ifu.fdp.t3pc_f[47:0]), // Templated
				 .pc_f	(`TOP_DESIGN.sparc1.ifu.fdp.pc_f[47:0]), // Templated
				 .inst_vld_f(`TOP_DESIGN.sparc1.ifu.fcl.inst_vld_f), // Templated
				 .dtu_fcl_running_s(`TOP_DESIGN.sparc1.ifu.dtu_fcl_running_s), // Templated
				 .thr_f	(`TOP_DESIGN.sparc1.ifu.fcl.thr_f[3:0]), // Templated
				 .coreid(3'h1));			 // Templated
   stb_ovfl_mon stb_ovfl_mon1  (/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.lsu_ifu_stbcnt3(`TOP_DESIGN.sparc1.ifu.lsu_ifu_stbcnt3), // Templated
				.lsu_ifu_stbcnt2(`TOP_DESIGN.sparc1.ifu.lsu_ifu_stbcnt2), // Templated
				.lsu_ifu_stbcnt1(`TOP_DESIGN.sparc1.ifu.lsu_ifu_stbcnt1), // Templated
				.lsu_ifu_stbcnt0(`TOP_DESIGN.sparc1.ifu.lsu_ifu_stbcnt0), // Templated
				.stb_ctl_reset3(`TOP_DESIGN.sparc1.lsu.stb_ctl3.reset), // Templated
				.stb_ctl_reset2(`TOP_DESIGN.sparc1.lsu.stb_ctl2.reset), // Templated
				.stb_ctl_reset1(`TOP_DESIGN.sparc1.lsu.stb_ctl1.reset), // Templated
				.stb_ctl_reset0(`TOP_DESIGN.sparc1.lsu.stb_ctl0.reset), // Templated
				.coreid	(3'h1));			 // Templated
   icache_mutex_mon icache_mutex_mon1 (/*AUTOINST*/
				       // Inputs
				       .clk(clk),
				       .rst_l(rst_l),
				       .waysel_buf_s1(`TOP_DESIGN.sparc1.ifu.wseldp.waysel_buf_s1), // Templated
				       .alltag_err_s1(`TOP_DESIGN.sparc1.ifu.errctl.alltag_err_s1), // Templated
				       .tlb_cam_miss_s1(`TOP_DESIGN.sparc1.ifu.fcl.tlb_cam_miss_s1), // Templated
				       .cam_vld_s1(`TOP_DESIGN.sparc1.ifu.fcl.cam_vld_s1), // Templated
				       .coreid(3'h1));		 // Templated
   nc_inv_chk nc_inv_chk1(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .cpxpkt_vld	(`TOP_DESIGN.sparc1.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`TOP_DESIGN.sparc1.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`TOP_DESIGN.sparc1.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`TOP_DESIGN.sparc1.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
			  .coreid	(3'h1));			 // Templated
   
   spu_ma_mon spu_ma_mon1(/* AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .wrmi_mamul_1sthalf(`TOP_DESIGN.sparc1.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
			  .wrmi_mamul_2ndhalf(`TOP_DESIGN.sparc1.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
			  .wrmi_maaeqb_1sthalf(`TOP_DESIGN.sparc1.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
			  .wrmi_maaeqb_2ndhalf(`TOP_DESIGN.sparc1.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
			  .iptr		(`TOP_DESIGN.sparc1.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
			  .iminus_lenminus1(`TOP_DESIGN.sparc1.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
			  .mul_data	(`TOP_DESIGN.sparc1.spu.spu_madp.spu_madp_evedata[63:0]));

//   cmp_pcxandcpx cmp_pcxandcpx1(/* AUTOINST*/
//				// Inputs
//				.clk	(clk),
//				.rst_l	(rst_l),
//				.spc_pcx_data_pa(`PCXPATH1.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
//				.cpx_spc_data_cx(`PCXPATH1.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
//				.cpu	(1));
`endif
`ifdef RTL_SPARC2
   l_cache_mon l_cache_mon2(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(2),			 // Templated
			    .index_f	(`ICTPATH2.index_y[6:0]), // Templated
			    .wrreq_f	(`ICTPATH2.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH2.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH2.ifq_ict_wrtag_f[28:0]), // Templated
			    .wr_data	(`ICVPATH2.din_d1),	 // Templated
			    .wren_f	(`ICVPATH2.bit_wen_d1[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH2.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH2.wr_adr[6:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH2.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH2.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`TOP_DESIGN.sparc2.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`TOP_DESIGN.sparc2.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated,
			    
   thrfsm_mon thrfsm_mon2(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .wm_imiss	(`TOP_DESIGN.sparc2.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`TOP_DESIGN.sparc2.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`TOP_DESIGN.sparc2.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`TOP_DESIGN.sparc2.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			  .thr_state1	(`TOP_DESIGN.sparc2.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			  .thr_state2	(`TOP_DESIGN.sparc2.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			  .thr_state3	(`TOP_DESIGN.sparc2.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			  .rst_stallreq	(`TOP_DESIGN.sparc2.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`TOP_DESIGN.sparc2.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`TOP_DESIGN.sparc2.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`TOP_DESIGN.sparc2.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`TOP_DESIGN.sparc2.ifu.swl.completion), // Templated
			  .mul_wait	(`TOP_DESIGN.sparc2.ifu.swl.mul_wait), // Templated
			  .div_wait	(`TOP_DESIGN.sparc2.ifu.swl.div_wait), // Templated
			  .fp_wait	(`TOP_DESIGN.sparc2.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`TOP_DESIGN.sparc2.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`TOP_DESIGN.sparc2.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`TOP_DESIGN.sparc2.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`TOP_DESIGN.sparc2.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`TOP_DESIGN.sparc2.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`TOP_DESIGN.sparc2.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`TOP_DESIGN.sparc2.ifu.fcl.ifet_ue_vec_d1), // Templated
			  .cpu_id	(3'h2));			 // Templated
   exu_mon exu_mon2(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH2.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH2.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH2.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH2.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH2.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH2.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH2.ecl.writeback.divcntl_wb_req_g)); // Templated
   
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon2(/*AUTOINST*/
		    // Inputs
		    .clk		(`TOP_DESIGN.sparc2.tlu.rclk), // Templated
		    .grst_l		(`TOP_DESIGN.sparc2.tlu.grst_l), // Templated
		    .rst_l		(`TOP_DESIGN.sparc2.tlu.tcl.tlu_rst_l), // Templated
			.lsu_ifu_flush_pipe_w	(`TOP_DESIGN.sparc2.lsu_ifu_flush_pipe_w),
			.tlu_lsu_int_ldxa_vld_w2(`TOP_DESIGN.sparc2.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`TOP_DESIGN.sparc2.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`TOP_DESIGN.sparc2.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`TOP_DESIGN.sparc2.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`TOP_DESIGN.sparc2.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`TOP_DESIGN.sparc2.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`TOP_DESIGN.sparc2.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`TOP_DESIGN.sparc2.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`TOP_DESIGN.sparc2.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`TOP_DESIGN.sparc2.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`TOP_DESIGN.sparc2.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`TOP_DESIGN.sparc2.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`TOP_DESIGN.sparc2.tlu.tlu_hyperv.gl_lvl3),
			.exu_gl_lvl0	(`TOP_DESIGN.sparc2.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`TOP_DESIGN.sparc2.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`TOP_DESIGN.sparc2.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`TOP_DESIGN.sparc2.exu.rml.agp_thr3_next),
		    .ifu_tlu_thrid_d	(`TOP_DESIGN.sparc2.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`TOP_DESIGN.sparc2.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`TOP_DESIGN.sparc2.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`TOP_DESIGN.sparc2.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`TOP_DESIGN.sparc2.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`TOP_DESIGN.sparc2.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`TOP_DESIGN.sparc2.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`TOP_DESIGN.sparc2.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`TOP_DESIGN.sparc2.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`TOP_DESIGN.sparc2.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`TOP_DESIGN.sparc2.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`TOP_DESIGN.sparc2.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`TOP_DESIGN.sparc2.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc2.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`TOP_DESIGN.sparc2.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc2.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`TOP_DESIGN.sparc2.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`TOP_DESIGN.sparc2.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`TOP_DESIGN.sparc2.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`TOP_DESIGN.sparc2.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`TOP_DESIGN.sparc2.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`TOP_DESIGN.sparc2.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`TOP_DESIGN.sparc2.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`TOP_DESIGN.sparc2.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`TOP_DESIGN.sparc2.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`TOP_DESIGN.sparc2.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`TOP_DESIGN.sparc2.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`TOP_DESIGN.sparc2.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`TOP_DESIGN.sparc2.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`TOP_DESIGN.sparc2.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`TOP_DESIGN.sparc2.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`TOP_DESIGN.sparc2.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`TOP_DESIGN.sparc2.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`TOP_DESIGN.sparc2.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`TOP_DESIGN.sparc2.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`TOP_DESIGN.sparc2.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`TOP_DESIGN.sparc2.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`TOP_DESIGN.sparc2.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`TOP_DESIGN.sparc2.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`TOP_DESIGN.sparc2.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`TOP_DESIGN.sparc2.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`TOP_DESIGN.sparc2.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`TOP_DESIGN.sparc2.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`TOP_DESIGN.sparc2.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`TOP_DESIGN.sparc2.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`TOP_DESIGN.sparc2.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`TOP_DESIGN.sparc2.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`TOP_DESIGN.sparc2.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`TOP_DESIGN.sparc2.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`TOP_DESIGN.sparc2.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc2.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`TOP_DESIGN.sparc2.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`TOP_DESIGN.sparc2.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc2.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`TOP_DESIGN.sparc2.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`TOP_DESIGN.sparc2.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`TOP_DESIGN.sparc2.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`TOP_DESIGN.sparc2.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`TOP_DESIGN.sparc2.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`TOP_DESIGN.sparc2.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`TOP_DESIGN.sparc2.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`TOP_DESIGN.sparc2.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`TOP_DESIGN.sparc2.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`TOP_DESIGN.sparc2.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`TOP_DESIGN.sparc2.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`TOP_DESIGN.sparc2.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`TOP_DESIGN.sparc2.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`TOP_DESIGN.sparc2.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`TOP_DESIGN.sparc2.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`TOP_DESIGN.sparc2.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`TOP_DESIGN.sparc2.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`TOP_DESIGN.sparc2.tlu.tcl.swint_g), // Templated
		    .core_id		(3'h2),			 // Templated
		    .tlu_itlb_wr_vld_g	(`TOP_DESIGN.sparc2.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`TOP_DESIGN.sparc2.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`TOP_DESIGN.sparc2.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`TOP_DESIGN.sparc2.tlu_itlb_tte_data_w2), // Templated
		    .itlb_wr_vld	(`TOP_DESIGN.sparc2.ifu.itlb.tlb_wr_vld), // Templated
		    .dtlb_wr_vld	(`TOP_DESIGN.sparc2.lsu.dtlb.tlb_wr_vld), // Templated
		    .tlu_tlb_access_en_l_d1(`TOP_DESIGN.sparc2.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
		    .tlu_lng_ltncy_en_l	(`TOP_DESIGN.sparc2.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon2 (/*AUTOINST*/
			      // Inputs
			      .rtl_softint0(`TOP_DESIGN.sparc2.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`TOP_DESIGN.sparc2.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`TOP_DESIGN.sparc2.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`TOP_DESIGN.sparc2.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`TOP_DESIGN.sparc2.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`TOP_DESIGN.sparc2.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`TOP_DESIGN.sparc2.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`TOP_DESIGN.sparc2.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`TOP_DESIGN.sparc2.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`TOP_DESIGN.sparc2.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`TOP_DESIGN.sparc2.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`TOP_DESIGN.sparc2.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`TOP_DESIGN.sparc2.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`TOP_DESIGN.sparc2.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`TOP_DESIGN.sparc2.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`TOP_DESIGN.sparc2.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`TOP_DESIGN.sparc2.tlu.tdp.rclk), // Templated
			      .rtl_reset(`TOP_DESIGN.sparc2.tlu.tdp.tlu_rst), // Templated
			      .core_id	(3'h2));			 // Templated
`endif // ifdef GATE_SIM



   nukeint_mon nukeint_mon2 (/*AUTOINST*/
			     // Inputs
			     .clk	(clk),
			     .rst_l	(rst_l),
			     .thr_state0(`TOP_DESIGN.sparc2.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			     .thr_state1(`TOP_DESIGN.sparc2.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			     .thr_state2(`TOP_DESIGN.sparc2.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			     .thr_state3(`TOP_DESIGN.sparc2.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			     .rstthr	(`TOP_DESIGN.sparc2.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			     .nukeint	(`TOP_DESIGN.sparc2.ifu.tlu_ifu_nukeint_i2), // Templated
			     .resumint	(`TOP_DESIGN.sparc2.ifu.tlu_ifu_resumint_i2), // Templated
			     .rstint	(`TOP_DESIGN.sparc2.ifu.tlu_ifu_rstint_i2), // Templated
			     .coreid	(3'h2));			 // Templated
   mask_mon mask_mon2(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
		      .wm_imiss		(`TOP_DESIGN.sparc2.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`TOP_DESIGN.sparc2.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`TOP_DESIGN.sparc2.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`TOP_DESIGN.sparc2.ifu.swl.mul_wait), // Templated
		      .div_wait		(`TOP_DESIGN.sparc2.ifu.swl.div_wait), // Templated
		      .fp_wait		(`TOP_DESIGN.sparc2.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`TOP_DESIGN.sparc2.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`TOP_DESIGN.sparc2.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`TOP_DESIGN.sparc2.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`TOP_DESIGN.sparc2.ifu.swl.ldmiss), // Templated
		      .coreid		(3'h2));			 // Templated
   pc_muxsel_mon pc_muxsel_mon2 (/*AUTOINST*/
				 // Inputs
				 .clk	(clk),
				 .rst_l	(rst_l),
				 .t0pc_f(`TOP_DESIGN.sparc2.ifu.fdp.t0pc_f[47:0]), // Templated
				 .t1pc_f(`TOP_DESIGN.sparc2.ifu.fdp.t1pc_f[47:0]), // Templated
				 .t2pc_f(`TOP_DESIGN.sparc2.ifu.fdp.t2pc_f[47:0]), // Templated
				 .t3pc_f(`TOP_DESIGN.sparc2.ifu.fdp.t3pc_f[47:0]), // Templated
				 .pc_f	(`TOP_DESIGN.sparc2.ifu.fdp.pc_f[47:0]), // Templated
				 .inst_vld_f(`TOP_DESIGN.sparc2.ifu.fcl.inst_vld_f), // Templated
				 .dtu_fcl_running_s(`TOP_DESIGN.sparc2.ifu.dtu_fcl_running_s), // Templated
				 .thr_f	(`TOP_DESIGN.sparc2.ifu.fcl.thr_f[3:0]), // Templated
				 .coreid(3'h2));			 // Templated
   stb_ovfl_mon stb_ovfl_mon2  (/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.lsu_ifu_stbcnt3(`TOP_DESIGN.sparc2.ifu.lsu_ifu_stbcnt3), // Templated
				.lsu_ifu_stbcnt2(`TOP_DESIGN.sparc2.ifu.lsu_ifu_stbcnt2), // Templated
				.lsu_ifu_stbcnt1(`TOP_DESIGN.sparc2.ifu.lsu_ifu_stbcnt1), // Templated
				.lsu_ifu_stbcnt0(`TOP_DESIGN.sparc2.ifu.lsu_ifu_stbcnt0), // Templated
				.stb_ctl_reset3(`TOP_DESIGN.sparc2.lsu.stb_ctl3.reset), // Templated
				.stb_ctl_reset2(`TOP_DESIGN.sparc2.lsu.stb_ctl2.reset), // Templated
				.stb_ctl_reset1(`TOP_DESIGN.sparc2.lsu.stb_ctl1.reset), // Templated
				.stb_ctl_reset0(`TOP_DESIGN.sparc2.lsu.stb_ctl0.reset), // Templated
				.coreid	(3'h2));			 // Templated
   icache_mutex_mon icache_mutex_mon2 (/*AUTOINST*/
				       // Inputs
				       .clk(clk),
				       .rst_l(rst_l),
				       .waysel_buf_s1(`TOP_DESIGN.sparc2.ifu.wseldp.waysel_buf_s1), // Templated
				       .alltag_err_s1(`TOP_DESIGN.sparc2.ifu.errctl.alltag_err_s1), // Templated
				       .tlb_cam_miss_s1(`TOP_DESIGN.sparc2.ifu.fcl.tlb_cam_miss_s1), // Templated
				       .cam_vld_s1(`TOP_DESIGN.sparc2.ifu.fcl.cam_vld_s1), // Templated
				       .coreid(3'h2));		 // Templated
   nc_inv_chk nc_inv_chk2(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .cpxpkt_vld	(`TOP_DESIGN.sparc2.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`TOP_DESIGN.sparc2.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`TOP_DESIGN.sparc2.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`TOP_DESIGN.sparc2.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
			  .coreid	(3'h2));			 // Templated
   
   spu_ma_mon spu_ma_mon2(/* AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .wrmi_mamul_1sthalf(`TOP_DESIGN.sparc2.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
			  .wrmi_mamul_2ndhalf(`TOP_DESIGN.sparc2.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
			  .wrmi_maaeqb_1sthalf(`TOP_DESIGN.sparc2.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
			  .wrmi_maaeqb_2ndhalf(`TOP_DESIGN.sparc2.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
			  .iptr		(`TOP_DESIGN.sparc2.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
			  .iminus_lenminus1(`TOP_DESIGN.sparc2.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
			  .mul_data	(`TOP_DESIGN.sparc2.spu.spu_madp.spu_madp_evedata[63:0]));

//   cmp_pcxandcpx cmp_pcxandcpx2(/* AUTOINST*/
//				// Inputs
//				.clk	(clk),
//				.rst_l	(rst_l),
//				.spc_pcx_data_pa(`PCXPATH2.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
//				.cpx_spc_data_cx(`PCXPATH2.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
//				.cpu	(2));
`endif
`ifdef RTL_SPARC3
   l_cache_mon l_cache_mon3(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(3),			 // Templated
			    .index_f	(`ICTPATH3.index_y[6:0]), // Templated
			    .wrreq_f	(`ICTPATH3.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH3.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH3.ifq_ict_wrtag_f[28:0]), // Templated
			    .wr_data	(`ICVPATH3.din_d1),	 // Templated
			    .wren_f	(`ICVPATH3.bit_wen_d1[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH3.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH3.wr_adr[6:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH3.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH3.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`TOP_DESIGN.sparc3.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`TOP_DESIGN.sparc3.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated		 // Templated,
			   
   thrfsm_mon thrfsm_mon3(/* AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .wm_imiss	(`TOP_DESIGN.sparc3.ifu.swl.wm_imiss[3:0]),
			  .wm_other	(`TOP_DESIGN.sparc3.ifu.swl.wm_other[3:0]),
			  .wm_stbwait	(`TOP_DESIGN.sparc3.ifu.swl.wm_stbwait[3:0]),
			  .thr_state0	(`TOP_DESIGN.sparc3.ifu.swl.thrfsm0.thr_state[4:0]),
			  .thr_state1	(`TOP_DESIGN.sparc3.ifu.swl.thrfsm1.thr_state[4:0]),
			  .thr_state2	(`TOP_DESIGN.sparc3.ifu.swl.thrfsm2.thr_state[4:0]),
			  .thr_state3	(`TOP_DESIGN.sparc3.ifu.swl.thrfsm3.thr_state[4:0]));
   exu_mon exu_mon3(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH3.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH3.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH3.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH3.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH3.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH3.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH3.ecl.writeback.divcntl_wb_req_g)); // Templated
   
   
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon3(/*AUTOINST*/
		    // Inputs
		    .clk		(`TOP_DESIGN.sparc3.tlu.rclk), // Templated
		    .grst_l		(`TOP_DESIGN.sparc3.tlu.grst_l), // Templated
		    .rst_l		(`TOP_DESIGN.sparc3.tlu.tcl.tlu_rst_l), // Templated
			.lsu_ifu_flush_pipe_w	(`TOP_DESIGN.sparc3.lsu_ifu_flush_pipe_w),
			.tlu_lsu_int_ldxa_vld_w2(`TOP_DESIGN.sparc3.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`TOP_DESIGN.sparc3.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`TOP_DESIGN.sparc3.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`TOP_DESIGN.sparc3.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`TOP_DESIGN.sparc3.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`TOP_DESIGN.sparc3.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`TOP_DESIGN.sparc3.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`TOP_DESIGN.sparc3.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`TOP_DESIGN.sparc3.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`TOP_DESIGN.sparc3.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`TOP_DESIGN.sparc3.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`TOP_DESIGN.sparc3.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`TOP_DESIGN.sparc3.tlu.tlu_hyperv.gl_lvl3),
			.exu_gl_lvl0	(`TOP_DESIGN.sparc3.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`TOP_DESIGN.sparc3.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`TOP_DESIGN.sparc3.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`TOP_DESIGN.sparc3.exu.rml.agp_thr3_next),
		    .ifu_tlu_thrid_d	(`TOP_DESIGN.sparc3.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`TOP_DESIGN.sparc3.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`TOP_DESIGN.sparc3.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`TOP_DESIGN.sparc3.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`TOP_DESIGN.sparc3.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`TOP_DESIGN.sparc3.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`TOP_DESIGN.sparc3.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`TOP_DESIGN.sparc3.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`TOP_DESIGN.sparc3.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`TOP_DESIGN.sparc3.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`TOP_DESIGN.sparc3.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`TOP_DESIGN.sparc3.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`TOP_DESIGN.sparc3.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc3.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`TOP_DESIGN.sparc3.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc3.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`TOP_DESIGN.sparc3.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`TOP_DESIGN.sparc3.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`TOP_DESIGN.sparc3.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`TOP_DESIGN.sparc3.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`TOP_DESIGN.sparc3.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`TOP_DESIGN.sparc3.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`TOP_DESIGN.sparc3.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`TOP_DESIGN.sparc3.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`TOP_DESIGN.sparc3.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`TOP_DESIGN.sparc3.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`TOP_DESIGN.sparc3.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`TOP_DESIGN.sparc3.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`TOP_DESIGN.sparc3.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`TOP_DESIGN.sparc3.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`TOP_DESIGN.sparc3.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`TOP_DESIGN.sparc3.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`TOP_DESIGN.sparc3.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`TOP_DESIGN.sparc3.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`TOP_DESIGN.sparc3.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`TOP_DESIGN.sparc3.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`TOP_DESIGN.sparc3.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`TOP_DESIGN.sparc3.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`TOP_DESIGN.sparc3.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`TOP_DESIGN.sparc3.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`TOP_DESIGN.sparc3.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`TOP_DESIGN.sparc3.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`TOP_DESIGN.sparc3.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`TOP_DESIGN.sparc3.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`TOP_DESIGN.sparc3.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`TOP_DESIGN.sparc3.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`TOP_DESIGN.sparc3.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`TOP_DESIGN.sparc3.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`TOP_DESIGN.sparc3.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`TOP_DESIGN.sparc3.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc3.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`TOP_DESIGN.sparc3.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`TOP_DESIGN.sparc3.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc3.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`TOP_DESIGN.sparc3.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`TOP_DESIGN.sparc3.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`TOP_DESIGN.sparc3.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`TOP_DESIGN.sparc3.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`TOP_DESIGN.sparc3.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`TOP_DESIGN.sparc3.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`TOP_DESIGN.sparc3.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`TOP_DESIGN.sparc3.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`TOP_DESIGN.sparc3.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`TOP_DESIGN.sparc3.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`TOP_DESIGN.sparc3.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`TOP_DESIGN.sparc3.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`TOP_DESIGN.sparc3.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`TOP_DESIGN.sparc3.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`TOP_DESIGN.sparc3.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`TOP_DESIGN.sparc3.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`TOP_DESIGN.sparc3.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`TOP_DESIGN.sparc3.tlu.tcl.swint_g), // Templated
		    .core_id		(3'h3),			 // Templated
		    .tlu_itlb_wr_vld_g	(`TOP_DESIGN.sparc3.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`TOP_DESIGN.sparc3.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`TOP_DESIGN.sparc3.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`TOP_DESIGN.sparc3.tlu_itlb_tte_data_w2), // Templated
		    .itlb_wr_vld	(`TOP_DESIGN.sparc3.ifu.itlb.tlb_wr_vld), // Templated
		    .dtlb_wr_vld	(`TOP_DESIGN.sparc3.lsu.dtlb.tlb_wr_vld), // Templated
		    .tlu_tlb_access_en_l_d1(`TOP_DESIGN.sparc3.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
		    .tlu_lng_ltncy_en_l	(`TOP_DESIGN.sparc3.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon3 (/*AUTOINST*/
			      // Inputs
			      .rtl_softint0(`TOP_DESIGN.sparc3.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`TOP_DESIGN.sparc3.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`TOP_DESIGN.sparc3.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`TOP_DESIGN.sparc3.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`TOP_DESIGN.sparc3.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`TOP_DESIGN.sparc3.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`TOP_DESIGN.sparc3.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`TOP_DESIGN.sparc3.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`TOP_DESIGN.sparc3.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`TOP_DESIGN.sparc3.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`TOP_DESIGN.sparc3.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`TOP_DESIGN.sparc3.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`TOP_DESIGN.sparc3.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`TOP_DESIGN.sparc3.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`TOP_DESIGN.sparc3.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`TOP_DESIGN.sparc3.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`TOP_DESIGN.sparc3.tlu.tdp.rclk), // Templated
			      .rtl_reset(`TOP_DESIGN.sparc3.tlu.tdp.tlu_rst), // Templated
			      .core_id	(3'h3));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon3 (/*AUTOINST*/
			     // Inputs
			     .clk	(clk),
			     .rst_l	(rst_l),
			     .thr_state0(`TOP_DESIGN.sparc3.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			     .thr_state1(`TOP_DESIGN.sparc3.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			     .thr_state2(`TOP_DESIGN.sparc3.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			     .thr_state3(`TOP_DESIGN.sparc3.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			     .rstthr	(`TOP_DESIGN.sparc3.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			     .nukeint	(`TOP_DESIGN.sparc3.ifu.tlu_ifu_nukeint_i2), // Templated
			     .resumint	(`TOP_DESIGN.sparc3.ifu.tlu_ifu_resumint_i2), // Templated
			     .rstint	(`TOP_DESIGN.sparc3.ifu.tlu_ifu_rstint_i2), // Templated
			     .coreid	(3'h3));			 // Templated
   mask_mon mask_mon3(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
		      .wm_imiss		(`TOP_DESIGN.sparc3.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`TOP_DESIGN.sparc3.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`TOP_DESIGN.sparc3.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`TOP_DESIGN.sparc3.ifu.swl.mul_wait), // Templated
		      .div_wait		(`TOP_DESIGN.sparc3.ifu.swl.div_wait), // Templated
		      .fp_wait		(`TOP_DESIGN.sparc3.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`TOP_DESIGN.sparc3.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`TOP_DESIGN.sparc3.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`TOP_DESIGN.sparc3.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`TOP_DESIGN.sparc3.ifu.swl.ldmiss), // Templated
		      .coreid		(3'h3));			 // Templated
   pc_muxsel_mon pc_muxsel_mon3 (/*AUTOINST*/
				 // Inputs
				 .clk	(clk),
				 .rst_l	(rst_l),
				 .t0pc_f(`TOP_DESIGN.sparc3.ifu.fdp.t0pc_f[47:0]), // Templated
				 .t1pc_f(`TOP_DESIGN.sparc3.ifu.fdp.t1pc_f[47:0]), // Templated
				 .t2pc_f(`TOP_DESIGN.sparc3.ifu.fdp.t2pc_f[47:0]), // Templated
				 .t3pc_f(`TOP_DESIGN.sparc3.ifu.fdp.t3pc_f[47:0]), // Templated
				 .pc_f	(`TOP_DESIGN.sparc3.ifu.fdp.pc_f[47:0]), // Templated
				 .inst_vld_f(`TOP_DESIGN.sparc3.ifu.fcl.inst_vld_f), // Templated
				 .dtu_fcl_running_s(`TOP_DESIGN.sparc3.ifu.dtu_fcl_running_s), // Templated
				 .thr_f	(`TOP_DESIGN.sparc3.ifu.fcl.thr_f[3:0]), // Templated
				 .coreid(3'h3));			 // Templated
   stb_ovfl_mon stb_ovfl_mon3  (/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.lsu_ifu_stbcnt3(`TOP_DESIGN.sparc3.ifu.lsu_ifu_stbcnt3), // Templated
				.lsu_ifu_stbcnt2(`TOP_DESIGN.sparc3.ifu.lsu_ifu_stbcnt2), // Templated
				.lsu_ifu_stbcnt1(`TOP_DESIGN.sparc3.ifu.lsu_ifu_stbcnt1), // Templated
				.lsu_ifu_stbcnt0(`TOP_DESIGN.sparc3.ifu.lsu_ifu_stbcnt0), // Templated
				.stb_ctl_reset3(`TOP_DESIGN.sparc3.lsu.stb_ctl3.reset), // Templated
				.stb_ctl_reset2(`TOP_DESIGN.sparc3.lsu.stb_ctl2.reset), // Templated
				.stb_ctl_reset1(`TOP_DESIGN.sparc3.lsu.stb_ctl1.reset), // Templated
				.stb_ctl_reset0(`TOP_DESIGN.sparc3.lsu.stb_ctl0.reset), // Templated
				.coreid	(3'h3));			 // Templated
   icache_mutex_mon icache_mutex_mon3 (/*AUTOINST*/
				       // Inputs
				       .clk(clk),
				       .rst_l(rst_l),
				       .waysel_buf_s1(`TOP_DESIGN.sparc3.ifu.wseldp.waysel_buf_s1), // Templated
				       .alltag_err_s1(`TOP_DESIGN.sparc3.ifu.errctl.alltag_err_s1), // Templated
				       .tlb_cam_miss_s1(`TOP_DESIGN.sparc3.ifu.fcl.tlb_cam_miss_s1), // Templated
				       .cam_vld_s1(`TOP_DESIGN.sparc3.ifu.fcl.cam_vld_s1), // Templated
				       .coreid(3'h3));		 // Templated
   nc_inv_chk nc_inv_chk3(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .cpxpkt_vld	(`TOP_DESIGN.sparc3.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`TOP_DESIGN.sparc3.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`TOP_DESIGN.sparc3.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`TOP_DESIGN.sparc3.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
			  .coreid	(3'h3));			 // Templated
   
   spu_ma_mon spu_ma_mon3(/* AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .wrmi_mamul_1sthalf(`TOP_DESIGN.sparc3.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
			  .wrmi_mamul_2ndhalf(`TOP_DESIGN.sparc3.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
			  .wrmi_maaeqb_1sthalf(`TOP_DESIGN.sparc3.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
			  .wrmi_maaeqb_2ndhalf(`TOP_DESIGN.sparc3.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
			  .iptr		(`TOP_DESIGN.sparc3.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
			  .iminus_lenminus1(`TOP_DESIGN.sparc3.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
			  .mul_data	(`TOP_DESIGN.sparc3.spu.spu_madp.spu_madp_evedata[63:0]));

//   cmp_pcxandcpx cmp_pcxandcpx3(/* AUTOINST*/
//				// Inputs
//				.clk	(clk),
//				.rst_l	(rst_l),
//				.spc_pcx_data_pa(`PCXPATH3.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
//				.cpx_spc_data_cx(`PCXPATH3.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
//				.cpu	(3));
`endif
`ifdef RTL_SPARC4
   l_cache_mon l_cache_mon4(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(4),			 // Templated
			    .index_f	(`ICTPATH4.index_y[6:0]), // Templated
			    .wrreq_f	(`ICTPATH4.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH4.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH4.ifq_ict_wrtag_f[28:0]), // Templated
			    .wr_data	(`ICVPATH4.din_d1),	 // Templated
			    .wren_f	(`ICVPATH4.bit_wen_d1[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH4.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH4.wr_adr[6:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH4.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH4.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`TOP_DESIGN.sparc4.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`TOP_DESIGN.sparc4.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon4(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .wm_imiss	(`TOP_DESIGN.sparc4.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`TOP_DESIGN.sparc4.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`TOP_DESIGN.sparc4.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`TOP_DESIGN.sparc4.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			  .thr_state1	(`TOP_DESIGN.sparc4.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			  .thr_state2	(`TOP_DESIGN.sparc4.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			  .thr_state3	(`TOP_DESIGN.sparc4.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			  .rst_stallreq	(`TOP_DESIGN.sparc4.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`TOP_DESIGN.sparc4.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`TOP_DESIGN.sparc4.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`TOP_DESIGN.sparc4.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`TOP_DESIGN.sparc4.ifu.swl.completion), // Templated
			  .mul_wait	(`TOP_DESIGN.sparc4.ifu.swl.mul_wait), // Templated
			  .div_wait	(`TOP_DESIGN.sparc4.ifu.swl.div_wait), // Templated
			  .fp_wait	(`TOP_DESIGN.sparc4.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`TOP_DESIGN.sparc4.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`TOP_DESIGN.sparc4.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`TOP_DESIGN.sparc4.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`TOP_DESIGN.sparc4.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`TOP_DESIGN.sparc4.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`TOP_DESIGN.sparc4.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`TOP_DESIGN.sparc4.ifu.fcl.ifet_ue_vec_d1), // Templated
			  .cpu_id	(3'h4));			 // Templated
   exu_mon exu_mon4(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH4.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH4.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH4.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH4.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH4.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH4.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH4.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon4(/*AUTOINST*/
		    // Inputs
		    .clk		(`TOP_DESIGN.sparc4.tlu.rclk), // Templated
		    .grst_l		(`TOP_DESIGN.sparc4.tlu.grst_l), // Templated
		    .rst_l		(`TOP_DESIGN.sparc4.tlu.tcl.tlu_rst_l), // Templated
			.lsu_ifu_flush_pipe_w	(`TOP_DESIGN.sparc4.lsu_ifu_flush_pipe_w),
			.tlu_lsu_int_ldxa_vld_w2(`TOP_DESIGN.sparc4.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`TOP_DESIGN.sparc4.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`TOP_DESIGN.sparc4.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`TOP_DESIGN.sparc4.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`TOP_DESIGN.sparc4.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`TOP_DESIGN.sparc4.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`TOP_DESIGN.sparc4.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`TOP_DESIGN.sparc4.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`TOP_DESIGN.sparc4.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`TOP_DESIGN.sparc4.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`TOP_DESIGN.sparc4.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`TOP_DESIGN.sparc4.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`TOP_DESIGN.sparc4.tlu.tlu_hyperv.gl_lvl3),
			.exu_gl_lvl0	(`TOP_DESIGN.sparc4.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`TOP_DESIGN.sparc4.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`TOP_DESIGN.sparc4.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`TOP_DESIGN.sparc4.exu.rml.agp_thr3_next),
		    .ifu_tlu_thrid_d	(`TOP_DESIGN.sparc4.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`TOP_DESIGN.sparc4.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`TOP_DESIGN.sparc4.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`TOP_DESIGN.sparc4.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`TOP_DESIGN.sparc4.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`TOP_DESIGN.sparc4.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`TOP_DESIGN.sparc4.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`TOP_DESIGN.sparc4.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`TOP_DESIGN.sparc4.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`TOP_DESIGN.sparc4.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`TOP_DESIGN.sparc4.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`TOP_DESIGN.sparc4.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`TOP_DESIGN.sparc4.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc4.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`TOP_DESIGN.sparc4.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc4.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`TOP_DESIGN.sparc4.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`TOP_DESIGN.sparc4.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`TOP_DESIGN.sparc4.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`TOP_DESIGN.sparc4.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`TOP_DESIGN.sparc4.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`TOP_DESIGN.sparc4.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`TOP_DESIGN.sparc4.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`TOP_DESIGN.sparc4.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`TOP_DESIGN.sparc4.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`TOP_DESIGN.sparc4.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`TOP_DESIGN.sparc4.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`TOP_DESIGN.sparc4.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`TOP_DESIGN.sparc4.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`TOP_DESIGN.sparc4.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`TOP_DESIGN.sparc4.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`TOP_DESIGN.sparc4.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`TOP_DESIGN.sparc4.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`TOP_DESIGN.sparc4.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`TOP_DESIGN.sparc4.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`TOP_DESIGN.sparc4.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`TOP_DESIGN.sparc4.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`TOP_DESIGN.sparc4.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`TOP_DESIGN.sparc4.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`TOP_DESIGN.sparc4.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`TOP_DESIGN.sparc4.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`TOP_DESIGN.sparc4.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`TOP_DESIGN.sparc4.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`TOP_DESIGN.sparc4.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`TOP_DESIGN.sparc4.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`TOP_DESIGN.sparc4.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`TOP_DESIGN.sparc4.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`TOP_DESIGN.sparc4.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`TOP_DESIGN.sparc4.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`TOP_DESIGN.sparc4.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc4.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`TOP_DESIGN.sparc4.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`TOP_DESIGN.sparc4.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc4.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`TOP_DESIGN.sparc4.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`TOP_DESIGN.sparc4.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`TOP_DESIGN.sparc4.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`TOP_DESIGN.sparc4.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`TOP_DESIGN.sparc4.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`TOP_DESIGN.sparc4.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`TOP_DESIGN.sparc4.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`TOP_DESIGN.sparc4.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`TOP_DESIGN.sparc4.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`TOP_DESIGN.sparc4.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`TOP_DESIGN.sparc4.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`TOP_DESIGN.sparc4.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`TOP_DESIGN.sparc4.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`TOP_DESIGN.sparc4.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`TOP_DESIGN.sparc4.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`TOP_DESIGN.sparc4.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`TOP_DESIGN.sparc4.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`TOP_DESIGN.sparc4.tlu.tcl.swint_g), // Templated
		    .core_id		(3'h4),			 // Templated
		    .tlu_itlb_wr_vld_g	(`TOP_DESIGN.sparc4.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`TOP_DESIGN.sparc4.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`TOP_DESIGN.sparc4.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`TOP_DESIGN.sparc4.tlu_itlb_tte_data_w2), // Templated
		    .itlb_wr_vld	(`TOP_DESIGN.sparc4.ifu.itlb.tlb_wr_vld), // Templated
		    .dtlb_wr_vld	(`TOP_DESIGN.sparc4.lsu.dtlb.tlb_wr_vld), // Templated
		    .tlu_tlb_access_en_l_d1(`TOP_DESIGN.sparc4.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
		    .tlu_lng_ltncy_en_l	(`TOP_DESIGN.sparc4.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon4 (/*AUTOINST*/
			      // Inputs
			      .rtl_softint0(`TOP_DESIGN.sparc4.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`TOP_DESIGN.sparc4.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`TOP_DESIGN.sparc4.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`TOP_DESIGN.sparc4.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`TOP_DESIGN.sparc4.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`TOP_DESIGN.sparc4.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`TOP_DESIGN.sparc4.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`TOP_DESIGN.sparc4.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`TOP_DESIGN.sparc4.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`TOP_DESIGN.sparc4.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`TOP_DESIGN.sparc4.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`TOP_DESIGN.sparc4.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`TOP_DESIGN.sparc4.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`TOP_DESIGN.sparc4.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`TOP_DESIGN.sparc4.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`TOP_DESIGN.sparc4.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`TOP_DESIGN.sparc4.tlu.tdp.rclk), // Templated
			      .rtl_reset(`TOP_DESIGN.sparc4.tlu.tdp.tlu_rst), // Templated
			      .core_id	(3'h4));			 // Templated
`endif // ifdef GATE_SIM


   nukeint_mon nukeint_mon4 (/*AUTOINST*/
			     // Inputs
			     .clk	(clk),
			     .rst_l	(rst_l),
			     .thr_state0(`TOP_DESIGN.sparc4.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			     .thr_state1(`TOP_DESIGN.sparc4.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			     .thr_state2(`TOP_DESIGN.sparc4.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			     .thr_state3(`TOP_DESIGN.sparc4.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			     .rstthr	(`TOP_DESIGN.sparc4.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			     .nukeint	(`TOP_DESIGN.sparc4.ifu.tlu_ifu_nukeint_i2), // Templated
			     .resumint	(`TOP_DESIGN.sparc4.ifu.tlu_ifu_resumint_i2), // Templated
			     .rstint	(`TOP_DESIGN.sparc4.ifu.tlu_ifu_rstint_i2), // Templated
			     .coreid	(3'h4));			 // Templated
   mask_mon mask_mon4(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
		      .wm_imiss		(`TOP_DESIGN.sparc4.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`TOP_DESIGN.sparc4.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`TOP_DESIGN.sparc4.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`TOP_DESIGN.sparc4.ifu.swl.mul_wait), // Templated
		      .div_wait		(`TOP_DESIGN.sparc4.ifu.swl.div_wait), // Templated
		      .fp_wait		(`TOP_DESIGN.sparc4.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`TOP_DESIGN.sparc4.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`TOP_DESIGN.sparc4.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`TOP_DESIGN.sparc4.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`TOP_DESIGN.sparc4.ifu.swl.ldmiss), // Templated
		      .coreid		(3'h4));			 // Templated
   pc_muxsel_mon pc_muxsel_mon4 (/*AUTOINST*/
				 // Inputs
				 .clk	(clk),
				 .rst_l	(rst_l),
				 .t0pc_f(`TOP_DESIGN.sparc4.ifu.fdp.t0pc_f[47:0]), // Templated
				 .t1pc_f(`TOP_DESIGN.sparc4.ifu.fdp.t1pc_f[47:0]), // Templated
				 .t2pc_f(`TOP_DESIGN.sparc4.ifu.fdp.t2pc_f[47:0]), // Templated
				 .t3pc_f(`TOP_DESIGN.sparc4.ifu.fdp.t3pc_f[47:0]), // Templated
				 .pc_f	(`TOP_DESIGN.sparc4.ifu.fdp.pc_f[47:0]), // Templated
				 .inst_vld_f(`TOP_DESIGN.sparc4.ifu.fcl.inst_vld_f), // Templated
				 .dtu_fcl_running_s(`TOP_DESIGN.sparc4.ifu.dtu_fcl_running_s), // Templated
				 .thr_f	(`TOP_DESIGN.sparc4.ifu.fcl.thr_f[3:0]), // Templated
				 .coreid(3'h4));			 // Templated
   stb_ovfl_mon stb_ovfl_mon4  (/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.lsu_ifu_stbcnt3(`TOP_DESIGN.sparc4.ifu.lsu_ifu_stbcnt3), // Templated
				.lsu_ifu_stbcnt2(`TOP_DESIGN.sparc4.ifu.lsu_ifu_stbcnt2), // Templated
				.lsu_ifu_stbcnt1(`TOP_DESIGN.sparc4.ifu.lsu_ifu_stbcnt1), // Templated
				.lsu_ifu_stbcnt0(`TOP_DESIGN.sparc4.ifu.lsu_ifu_stbcnt0), // Templated
				.stb_ctl_reset3(`TOP_DESIGN.sparc4.lsu.stb_ctl3.reset), // Templated
				.stb_ctl_reset2(`TOP_DESIGN.sparc4.lsu.stb_ctl2.reset), // Templated
				.stb_ctl_reset1(`TOP_DESIGN.sparc4.lsu.stb_ctl1.reset), // Templated
				.stb_ctl_reset0(`TOP_DESIGN.sparc4.lsu.stb_ctl0.reset), // Templated
				.coreid	(3'h4));			 // Templated
   icache_mutex_mon icache_mutex_mon4 (/*AUTOINST*/
				       // Inputs
				       .clk(clk),
				       .rst_l(rst_l),
				       .waysel_buf_s1(`TOP_DESIGN.sparc4.ifu.wseldp.waysel_buf_s1), // Templated
				       .alltag_err_s1(`TOP_DESIGN.sparc4.ifu.errctl.alltag_err_s1), // Templated
				       .tlb_cam_miss_s1(`TOP_DESIGN.sparc4.ifu.fcl.tlb_cam_miss_s1), // Templated
				       .cam_vld_s1(`TOP_DESIGN.sparc4.ifu.fcl.cam_vld_s1), // Templated
				       .coreid(3'h4));		 // Templated
   nc_inv_chk nc_inv_chk4(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .cpxpkt_vld	(`TOP_DESIGN.sparc4.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`TOP_DESIGN.sparc4.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`TOP_DESIGN.sparc4.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`TOP_DESIGN.sparc4.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
			  .coreid	(3'h4));			 // Templated
   
   spu_ma_mon spu_ma_mon4(/* AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .wrmi_mamul_1sthalf(`TOP_DESIGN.sparc4.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
			  .wrmi_mamul_2ndhalf(`TOP_DESIGN.sparc4.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
			  .wrmi_maaeqb_1sthalf(`TOP_DESIGN.sparc4.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
			  .wrmi_maaeqb_2ndhalf(`TOP_DESIGN.sparc4.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
			  .iptr		(`TOP_DESIGN.sparc4.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
			  .iminus_lenminus1(`TOP_DESIGN.sparc4.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
			  .mul_data	(`TOP_DESIGN.sparc4.spu.spu_madp.spu_madp_evedata[63:0]));

//   cmp_pcxandcpx cmp_pcxandcpx4(/* AUTOINST*/
//				// Inputs
//				.clk	(clk),
//				.rst_l	(rst_l),
//				.spc_pcx_data_pa(`PCXPATH4.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
//				.cpx_spc_data_cx(`PCXPATH4.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
//				.cpu	(4));
`endif
`ifdef RTL_SPARC5
   l_cache_mon l_cache_mon5(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(5),			 // Templated
			    .index_f	(`ICTPATH5.index_y[6:0]), // Templated
			    .wrreq_f	(`ICTPATH5.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH5.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH5.ifq_ict_wrtag_f[28:0]), // Templated
			    .wr_data	(`ICVPATH5.din_d1),	 // Templated
			    .wren_f	(`ICVPATH5.bit_wen_d1[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH5.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH5.wr_adr[6:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH5.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH5.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`TOP_DESIGN.sparc5.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`TOP_DESIGN.sparc5.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon5(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .wm_imiss	(`TOP_DESIGN.sparc5.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`TOP_DESIGN.sparc5.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`TOP_DESIGN.sparc5.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`TOP_DESIGN.sparc5.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			  .thr_state1	(`TOP_DESIGN.sparc5.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			  .thr_state2	(`TOP_DESIGN.sparc5.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			  .thr_state3	(`TOP_DESIGN.sparc5.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			  .rst_stallreq	(`TOP_DESIGN.sparc5.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`TOP_DESIGN.sparc5.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`TOP_DESIGN.sparc5.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`TOP_DESIGN.sparc5.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`TOP_DESIGN.sparc5.ifu.swl.completion), // Templated
			  .mul_wait	(`TOP_DESIGN.sparc5.ifu.swl.mul_wait), // Templated
			  .div_wait	(`TOP_DESIGN.sparc5.ifu.swl.div_wait), // Templated
			  .fp_wait	(`TOP_DESIGN.sparc5.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`TOP_DESIGN.sparc5.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`TOP_DESIGN.sparc5.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`TOP_DESIGN.sparc5.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`TOP_DESIGN.sparc5.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`TOP_DESIGN.sparc5.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`TOP_DESIGN.sparc5.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`TOP_DESIGN.sparc5.ifu.fcl.ifet_ue_vec_d1), // Templated
			  .cpu_id	(3'h5));			 // Templated
   exu_mon exu_mon5(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH5.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH5.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH5.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH5.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH5.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH5.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH5.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon5(/*AUTOINST*/
		    // Inputs
		    .clk		(`TOP_DESIGN.sparc5.tlu.rclk), // Templated
		    .grst_l		(`TOP_DESIGN.sparc5.tlu.grst_l), // Templated
		    .rst_l		(`TOP_DESIGN.sparc5.tlu.tcl.tlu_rst_l), // Templated
			.lsu_ifu_flush_pipe_w	(`TOP_DESIGN.sparc5.lsu_ifu_flush_pipe_w),
			.tlu_lsu_int_ldxa_vld_w2(`TOP_DESIGN.sparc5.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`TOP_DESIGN.sparc5.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`TOP_DESIGN.sparc5.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`TOP_DESIGN.sparc5.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`TOP_DESIGN.sparc5.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`TOP_DESIGN.sparc5.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`TOP_DESIGN.sparc5.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`TOP_DESIGN.sparc5.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`TOP_DESIGN.sparc5.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`TOP_DESIGN.sparc5.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`TOP_DESIGN.sparc5.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`TOP_DESIGN.sparc5.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`TOP_DESIGN.sparc5.tlu.tlu_hyperv.gl_lvl3),
			.exu_gl_lvl0	(`TOP_DESIGN.sparc5.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`TOP_DESIGN.sparc5.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`TOP_DESIGN.sparc5.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`TOP_DESIGN.sparc5.exu.rml.agp_thr3_next),
		    .ifu_tlu_thrid_d	(`TOP_DESIGN.sparc5.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`TOP_DESIGN.sparc5.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`TOP_DESIGN.sparc5.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`TOP_DESIGN.sparc5.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`TOP_DESIGN.sparc5.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`TOP_DESIGN.sparc5.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`TOP_DESIGN.sparc5.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`TOP_DESIGN.sparc5.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`TOP_DESIGN.sparc5.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`TOP_DESIGN.sparc5.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`TOP_DESIGN.sparc5.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`TOP_DESIGN.sparc5.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`TOP_DESIGN.sparc5.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc5.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`TOP_DESIGN.sparc5.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc5.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`TOP_DESIGN.sparc5.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`TOP_DESIGN.sparc5.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`TOP_DESIGN.sparc5.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`TOP_DESIGN.sparc5.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`TOP_DESIGN.sparc5.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`TOP_DESIGN.sparc5.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`TOP_DESIGN.sparc5.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`TOP_DESIGN.sparc5.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`TOP_DESIGN.sparc5.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`TOP_DESIGN.sparc5.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`TOP_DESIGN.sparc5.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`TOP_DESIGN.sparc5.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`TOP_DESIGN.sparc5.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`TOP_DESIGN.sparc5.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`TOP_DESIGN.sparc5.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`TOP_DESIGN.sparc5.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`TOP_DESIGN.sparc5.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`TOP_DESIGN.sparc5.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`TOP_DESIGN.sparc5.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`TOP_DESIGN.sparc5.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`TOP_DESIGN.sparc5.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`TOP_DESIGN.sparc5.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`TOP_DESIGN.sparc5.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`TOP_DESIGN.sparc5.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`TOP_DESIGN.sparc5.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`TOP_DESIGN.sparc5.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`TOP_DESIGN.sparc5.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`TOP_DESIGN.sparc5.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`TOP_DESIGN.sparc5.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`TOP_DESIGN.sparc5.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`TOP_DESIGN.sparc5.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`TOP_DESIGN.sparc5.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`TOP_DESIGN.sparc5.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`TOP_DESIGN.sparc5.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc5.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`TOP_DESIGN.sparc5.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`TOP_DESIGN.sparc5.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc5.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`TOP_DESIGN.sparc5.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`TOP_DESIGN.sparc5.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`TOP_DESIGN.sparc5.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`TOP_DESIGN.sparc5.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`TOP_DESIGN.sparc5.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`TOP_DESIGN.sparc5.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`TOP_DESIGN.sparc5.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`TOP_DESIGN.sparc5.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`TOP_DESIGN.sparc5.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`TOP_DESIGN.sparc5.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`TOP_DESIGN.sparc5.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`TOP_DESIGN.sparc5.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`TOP_DESIGN.sparc5.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`TOP_DESIGN.sparc5.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`TOP_DESIGN.sparc5.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`TOP_DESIGN.sparc5.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`TOP_DESIGN.sparc5.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`TOP_DESIGN.sparc5.tlu.tcl.swint_g), // Templated
		    .core_id		(3'h5),			 // Templated
		    .tlu_itlb_wr_vld_g	(`TOP_DESIGN.sparc5.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`TOP_DESIGN.sparc5.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`TOP_DESIGN.sparc5.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`TOP_DESIGN.sparc5.tlu_itlb_tte_data_w2), // Templated
		    .itlb_wr_vld	(`TOP_DESIGN.sparc5.ifu.itlb.tlb_wr_vld), // Templated
		    .dtlb_wr_vld	(`TOP_DESIGN.sparc5.lsu.dtlb.tlb_wr_vld), // Templated
		    .tlu_tlb_access_en_l_d1(`TOP_DESIGN.sparc5.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
		    .tlu_lng_ltncy_en_l	(`TOP_DESIGN.sparc5.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon5 (/*AUTOINST*/
			      // Inputs
			      .rtl_softint0(`TOP_DESIGN.sparc5.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`TOP_DESIGN.sparc5.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`TOP_DESIGN.sparc5.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`TOP_DESIGN.sparc5.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`TOP_DESIGN.sparc5.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`TOP_DESIGN.sparc5.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`TOP_DESIGN.sparc5.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`TOP_DESIGN.sparc5.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`TOP_DESIGN.sparc5.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`TOP_DESIGN.sparc5.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`TOP_DESIGN.sparc5.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`TOP_DESIGN.sparc5.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`TOP_DESIGN.sparc5.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`TOP_DESIGN.sparc5.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`TOP_DESIGN.sparc5.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`TOP_DESIGN.sparc5.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`TOP_DESIGN.sparc5.tlu.tdp.rclk), // Templated
			      .rtl_reset(`TOP_DESIGN.sparc5.tlu.tdp.tlu_rst), // Templated
			      .core_id	(3'h5));			 // Templated
`endif // ifdef GATE_SIM


   nukeint_mon nukeint_mon5 (/*AUTOINST*/
			     // Inputs
			     .clk	(clk),
			     .rst_l	(rst_l),
			     .thr_state0(`TOP_DESIGN.sparc5.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			     .thr_state1(`TOP_DESIGN.sparc5.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			     .thr_state2(`TOP_DESIGN.sparc5.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			     .thr_state3(`TOP_DESIGN.sparc5.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			     .rstthr	(`TOP_DESIGN.sparc5.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			     .nukeint	(`TOP_DESIGN.sparc5.ifu.tlu_ifu_nukeint_i2), // Templated
			     .resumint	(`TOP_DESIGN.sparc5.ifu.tlu_ifu_resumint_i2), // Templated
			     .rstint	(`TOP_DESIGN.sparc5.ifu.tlu_ifu_rstint_i2), // Templated
			     .coreid	(3'h5));			 // Templated
   mask_mon mask_mon5(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
		      .wm_imiss		(`TOP_DESIGN.sparc5.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`TOP_DESIGN.sparc5.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`TOP_DESIGN.sparc5.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`TOP_DESIGN.sparc5.ifu.swl.mul_wait), // Templated
		      .div_wait		(`TOP_DESIGN.sparc5.ifu.swl.div_wait), // Templated
		      .fp_wait		(`TOP_DESIGN.sparc5.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`TOP_DESIGN.sparc5.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`TOP_DESIGN.sparc5.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`TOP_DESIGN.sparc5.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`TOP_DESIGN.sparc5.ifu.swl.ldmiss), // Templated
		      .coreid		(3'h5));			 // Templated
   pc_muxsel_mon pc_muxsel_mon5 (/*AUTOINST*/
				 // Inputs
				 .clk	(clk),
				 .rst_l	(rst_l),
				 .t0pc_f(`TOP_DESIGN.sparc5.ifu.fdp.t0pc_f[47:0]), // Templated
				 .t1pc_f(`TOP_DESIGN.sparc5.ifu.fdp.t1pc_f[47:0]), // Templated
				 .t2pc_f(`TOP_DESIGN.sparc5.ifu.fdp.t2pc_f[47:0]), // Templated
				 .t3pc_f(`TOP_DESIGN.sparc5.ifu.fdp.t3pc_f[47:0]), // Templated
				 .pc_f	(`TOP_DESIGN.sparc5.ifu.fdp.pc_f[47:0]), // Templated
				 .inst_vld_f(`TOP_DESIGN.sparc5.ifu.fcl.inst_vld_f), // Templated
				 .dtu_fcl_running_s(`TOP_DESIGN.sparc5.ifu.dtu_fcl_running_s), // Templated
				 .thr_f	(`TOP_DESIGN.sparc5.ifu.fcl.thr_f[3:0]), // Templated
				 .coreid(3'h5));			 // Templated
   stb_ovfl_mon stb_ovfl_mon5  (/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.lsu_ifu_stbcnt3(`TOP_DESIGN.sparc5.ifu.lsu_ifu_stbcnt3), // Templated
				.lsu_ifu_stbcnt2(`TOP_DESIGN.sparc5.ifu.lsu_ifu_stbcnt2), // Templated
				.lsu_ifu_stbcnt1(`TOP_DESIGN.sparc5.ifu.lsu_ifu_stbcnt1), // Templated
				.lsu_ifu_stbcnt0(`TOP_DESIGN.sparc5.ifu.lsu_ifu_stbcnt0), // Templated
				.stb_ctl_reset3(`TOP_DESIGN.sparc5.lsu.stb_ctl3.reset), // Templated
				.stb_ctl_reset2(`TOP_DESIGN.sparc5.lsu.stb_ctl2.reset), // Templated
				.stb_ctl_reset1(`TOP_DESIGN.sparc5.lsu.stb_ctl1.reset), // Templated
				.stb_ctl_reset0(`TOP_DESIGN.sparc5.lsu.stb_ctl0.reset), // Templated
				.coreid	(3'h5));			 // Templated
   icache_mutex_mon icache_mutex_mon5 (/*AUTOINST*/
				       // Inputs
				       .clk(clk),
				       .rst_l(rst_l),
				       .waysel_buf_s1(`TOP_DESIGN.sparc5.ifu.wseldp.waysel_buf_s1), // Templated
				       .alltag_err_s1(`TOP_DESIGN.sparc5.ifu.errctl.alltag_err_s1), // Templated
				       .tlb_cam_miss_s1(`TOP_DESIGN.sparc5.ifu.fcl.tlb_cam_miss_s1), // Templated
				       .cam_vld_s1(`TOP_DESIGN.sparc5.ifu.fcl.cam_vld_s1), // Templated
				       .coreid(3'h5));		 // Templated
   nc_inv_chk nc_inv_chk5(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .cpxpkt_vld	(`TOP_DESIGN.sparc5.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`TOP_DESIGN.sparc5.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`TOP_DESIGN.sparc5.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`TOP_DESIGN.sparc5.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
			  .coreid	(3'h5));			 // Templated
   
   spu_ma_mon spu_ma_mon5(/* AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .wrmi_mamul_1sthalf(`TOP_DESIGN.sparc5.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
			  .wrmi_mamul_2ndhalf(`TOP_DESIGN.sparc5.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
			  .wrmi_maaeqb_1sthalf(`TOP_DESIGN.sparc5.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
			  .wrmi_maaeqb_2ndhalf(`TOP_DESIGN.sparc5.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
			  .iptr		(`TOP_DESIGN.sparc5.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
			  .iminus_lenminus1(`TOP_DESIGN.sparc5.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
			  .mul_data	(`TOP_DESIGN.sparc5.spu.spu_madp.spu_madp_evedata[63:0]));

//   cmp_pcxandcpx cmp_pcxandcpx5(/* AUTOINST*/
//				// Inputs
//				.clk	(clk),
//				.rst_l	(rst_l),
//				.spc_pcx_data_pa(`PCXPATH5.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
//				.cpx_spc_data_cx(`PCXPATH5.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
//				.cpu	(5));
`endif
`ifdef RTL_SPARC6
   l_cache_mon l_cache_mon6(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(6),			 // Templated
			    .index_f	(`ICTPATH6.index_y[6:0]), // Templated
			    .wrreq_f	(`ICTPATH6.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH6.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH6.ifq_ict_wrtag_f[28:0]), // Templated
			    .wr_data	(`ICVPATH6.din_d1),	 // Templated
			    .wren_f	(`ICVPATH6.bit_wen_d1[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH6.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH6.wr_adr[6:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH6.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH6.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`TOP_DESIGN.sparc6.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`TOP_DESIGN.sparc6.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon6(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .wm_imiss	(`TOP_DESIGN.sparc6.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`TOP_DESIGN.sparc6.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`TOP_DESIGN.sparc6.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`TOP_DESIGN.sparc6.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			  .thr_state1	(`TOP_DESIGN.sparc6.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			  .thr_state2	(`TOP_DESIGN.sparc6.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			  .thr_state3	(`TOP_DESIGN.sparc6.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			  .rst_stallreq	(`TOP_DESIGN.sparc6.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`TOP_DESIGN.sparc6.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`TOP_DESIGN.sparc6.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`TOP_DESIGN.sparc6.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`TOP_DESIGN.sparc6.ifu.swl.completion), // Templated
			  .mul_wait	(`TOP_DESIGN.sparc6.ifu.swl.mul_wait), // Templated
			  .div_wait	(`TOP_DESIGN.sparc6.ifu.swl.div_wait), // Templated
			  .fp_wait	(`TOP_DESIGN.sparc6.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`TOP_DESIGN.sparc6.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`TOP_DESIGN.sparc6.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`TOP_DESIGN.sparc6.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`TOP_DESIGN.sparc6.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`TOP_DESIGN.sparc6.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`TOP_DESIGN.sparc6.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`TOP_DESIGN.sparc6.ifu.fcl.ifet_ue_vec_d1), // Templated
			  .cpu_id	(3'h6));			 // Templated
   exu_mon exu_mon6(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH6.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH6.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH6.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH6.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH6.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH6.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH6.ecl.writeback.divcntl_wb_req_g)); // Templated

      
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon6(/*AUTOINST*/
		    // Inputs
		    .clk		(`TOP_DESIGN.sparc6.tlu.rclk), // Templated
		    .grst_l		(`TOP_DESIGN.sparc6.tlu.grst_l), // Templated
		    .rst_l		(`TOP_DESIGN.sparc6.tlu.tcl.tlu_rst_l), // Templated
			.lsu_ifu_flush_pipe_w	(`TOP_DESIGN.sparc6.lsu_ifu_flush_pipe_w),
			.tlu_lsu_int_ldxa_vld_w2(`TOP_DESIGN.sparc6.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`TOP_DESIGN.sparc6.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`TOP_DESIGN.sparc6.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`TOP_DESIGN.sparc6.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`TOP_DESIGN.sparc6.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`TOP_DESIGN.sparc6.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`TOP_DESIGN.sparc6.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`TOP_DESIGN.sparc6.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`TOP_DESIGN.sparc6.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`TOP_DESIGN.sparc6.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`TOP_DESIGN.sparc6.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`TOP_DESIGN.sparc6.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`TOP_DESIGN.sparc6.tlu.tlu_hyperv.gl_lvl3),
			.exu_gl_lvl0	(`TOP_DESIGN.sparc6.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`TOP_DESIGN.sparc6.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`TOP_DESIGN.sparc6.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`TOP_DESIGN.sparc6.exu.rml.agp_thr3_next),
		    .ifu_tlu_thrid_d	(`TOP_DESIGN.sparc6.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`TOP_DESIGN.sparc6.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`TOP_DESIGN.sparc6.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`TOP_DESIGN.sparc6.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`TOP_DESIGN.sparc6.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`TOP_DESIGN.sparc6.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`TOP_DESIGN.sparc6.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`TOP_DESIGN.sparc6.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`TOP_DESIGN.sparc6.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`TOP_DESIGN.sparc6.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`TOP_DESIGN.sparc6.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`TOP_DESIGN.sparc6.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`TOP_DESIGN.sparc6.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc6.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`TOP_DESIGN.sparc6.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc6.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`TOP_DESIGN.sparc6.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`TOP_DESIGN.sparc6.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`TOP_DESIGN.sparc6.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`TOP_DESIGN.sparc6.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`TOP_DESIGN.sparc6.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`TOP_DESIGN.sparc6.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`TOP_DESIGN.sparc6.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`TOP_DESIGN.sparc6.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`TOP_DESIGN.sparc6.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`TOP_DESIGN.sparc6.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`TOP_DESIGN.sparc6.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`TOP_DESIGN.sparc6.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`TOP_DESIGN.sparc6.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`TOP_DESIGN.sparc6.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`TOP_DESIGN.sparc6.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`TOP_DESIGN.sparc6.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`TOP_DESIGN.sparc6.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`TOP_DESIGN.sparc6.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`TOP_DESIGN.sparc6.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`TOP_DESIGN.sparc6.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`TOP_DESIGN.sparc6.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`TOP_DESIGN.sparc6.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`TOP_DESIGN.sparc6.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`TOP_DESIGN.sparc6.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`TOP_DESIGN.sparc6.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`TOP_DESIGN.sparc6.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`TOP_DESIGN.sparc6.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`TOP_DESIGN.sparc6.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`TOP_DESIGN.sparc6.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`TOP_DESIGN.sparc6.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`TOP_DESIGN.sparc6.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`TOP_DESIGN.sparc6.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`TOP_DESIGN.sparc6.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`TOP_DESIGN.sparc6.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc6.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`TOP_DESIGN.sparc6.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`TOP_DESIGN.sparc6.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc6.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`TOP_DESIGN.sparc6.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`TOP_DESIGN.sparc6.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`TOP_DESIGN.sparc6.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`TOP_DESIGN.sparc6.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`TOP_DESIGN.sparc6.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`TOP_DESIGN.sparc6.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`TOP_DESIGN.sparc6.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`TOP_DESIGN.sparc6.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`TOP_DESIGN.sparc6.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`TOP_DESIGN.sparc6.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`TOP_DESIGN.sparc6.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`TOP_DESIGN.sparc6.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`TOP_DESIGN.sparc6.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`TOP_DESIGN.sparc6.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`TOP_DESIGN.sparc6.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`TOP_DESIGN.sparc6.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`TOP_DESIGN.sparc6.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`TOP_DESIGN.sparc6.tlu.tcl.swint_g), // Templated
		    .core_id		(3'h6),			 // Templated
		    .tlu_itlb_wr_vld_g	(`TOP_DESIGN.sparc6.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`TOP_DESIGN.sparc6.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`TOP_DESIGN.sparc6.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`TOP_DESIGN.sparc6.tlu_itlb_tte_data_w2), // Templated
		    .itlb_wr_vld	(`TOP_DESIGN.sparc6.ifu.itlb.tlb_wr_vld), // Templated
		    .dtlb_wr_vld	(`TOP_DESIGN.sparc6.lsu.dtlb.tlb_wr_vld), // Templated
		    .tlu_tlb_access_en_l_d1(`TOP_DESIGN.sparc6.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
		    .tlu_lng_ltncy_en_l	(`TOP_DESIGN.sparc6.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon6 (/*AUTOINST*/
			      // Inputs
			      .rtl_softint0(`TOP_DESIGN.sparc6.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`TOP_DESIGN.sparc6.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`TOP_DESIGN.sparc6.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`TOP_DESIGN.sparc6.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`TOP_DESIGN.sparc6.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`TOP_DESIGN.sparc6.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`TOP_DESIGN.sparc6.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`TOP_DESIGN.sparc6.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`TOP_DESIGN.sparc6.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`TOP_DESIGN.sparc6.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`TOP_DESIGN.sparc6.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`TOP_DESIGN.sparc6.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`TOP_DESIGN.sparc6.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`TOP_DESIGN.sparc6.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`TOP_DESIGN.sparc6.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`TOP_DESIGN.sparc6.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`TOP_DESIGN.sparc6.tlu.tdp.rclk), // Templated
			      .rtl_reset(`TOP_DESIGN.sparc6.tlu.tdp.tlu_rst), // Templated
			      .core_id	(3'h6));			 // Templated
`endif // ifdef GATE_SIM


   nukeint_mon nukeint_mon6 (/*AUTOINST*/
			     // Inputs
			     .clk	(clk),
			     .rst_l	(rst_l),
			     .thr_state0(`TOP_DESIGN.sparc6.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			     .thr_state1(`TOP_DESIGN.sparc6.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			     .thr_state2(`TOP_DESIGN.sparc6.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			     .thr_state3(`TOP_DESIGN.sparc6.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			     .rstthr	(`TOP_DESIGN.sparc6.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			     .nukeint	(`TOP_DESIGN.sparc6.ifu.tlu_ifu_nukeint_i2), // Templated
			     .resumint	(`TOP_DESIGN.sparc6.ifu.tlu_ifu_resumint_i2), // Templated
			     .rstint	(`TOP_DESIGN.sparc6.ifu.tlu_ifu_rstint_i2), // Templated
			     .coreid	(3'h6));			 // Templated
   mask_mon mask_mon6(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
		      .wm_imiss		(`TOP_DESIGN.sparc6.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`TOP_DESIGN.sparc6.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`TOP_DESIGN.sparc6.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`TOP_DESIGN.sparc6.ifu.swl.mul_wait), // Templated
		      .div_wait		(`TOP_DESIGN.sparc6.ifu.swl.div_wait), // Templated
		      .fp_wait		(`TOP_DESIGN.sparc6.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`TOP_DESIGN.sparc6.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`TOP_DESIGN.sparc6.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`TOP_DESIGN.sparc6.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`TOP_DESIGN.sparc6.ifu.swl.ldmiss), // Templated
		      .coreid		(3'h6));			 // Templated
   pc_muxsel_mon pc_muxsel_mon6 (/*AUTOINST*/
				 // Inputs
				 .clk	(clk),
				 .rst_l	(rst_l),
				 .t0pc_f(`TOP_DESIGN.sparc6.ifu.fdp.t0pc_f[47:0]), // Templated
				 .t1pc_f(`TOP_DESIGN.sparc6.ifu.fdp.t1pc_f[47:0]), // Templated
				 .t2pc_f(`TOP_DESIGN.sparc6.ifu.fdp.t2pc_f[47:0]), // Templated
				 .t3pc_f(`TOP_DESIGN.sparc6.ifu.fdp.t3pc_f[47:0]), // Templated
				 .pc_f	(`TOP_DESIGN.sparc6.ifu.fdp.pc_f[47:0]), // Templated
				 .inst_vld_f(`TOP_DESIGN.sparc6.ifu.fcl.inst_vld_f), // Templated
				 .dtu_fcl_running_s(`TOP_DESIGN.sparc6.ifu.dtu_fcl_running_s), // Templated
				 .thr_f	(`TOP_DESIGN.sparc6.ifu.fcl.thr_f[3:0]), // Templated
				 .coreid(3'h6));			 // Templated
   stb_ovfl_mon stb_ovfl_mon6  (/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.lsu_ifu_stbcnt3(`TOP_DESIGN.sparc6.ifu.lsu_ifu_stbcnt3), // Templated
				.lsu_ifu_stbcnt2(`TOP_DESIGN.sparc6.ifu.lsu_ifu_stbcnt2), // Templated
				.lsu_ifu_stbcnt1(`TOP_DESIGN.sparc6.ifu.lsu_ifu_stbcnt1), // Templated
				.lsu_ifu_stbcnt0(`TOP_DESIGN.sparc6.ifu.lsu_ifu_stbcnt0), // Templated
				.stb_ctl_reset3(`TOP_DESIGN.sparc6.lsu.stb_ctl3.reset), // Templated
				.stb_ctl_reset2(`TOP_DESIGN.sparc6.lsu.stb_ctl2.reset), // Templated
				.stb_ctl_reset1(`TOP_DESIGN.sparc6.lsu.stb_ctl1.reset), // Templated
				.stb_ctl_reset0(`TOP_DESIGN.sparc6.lsu.stb_ctl0.reset), // Templated
				.coreid	(3'h6));			 // Templated
   icache_mutex_mon icache_mutex_mon6 (/*AUTOINST*/
				       // Inputs
				       .clk(clk),
				       .rst_l(rst_l),
				       .waysel_buf_s1(`TOP_DESIGN.sparc6.ifu.wseldp.waysel_buf_s1), // Templated
				       .alltag_err_s1(`TOP_DESIGN.sparc6.ifu.errctl.alltag_err_s1), // Templated
				       .tlb_cam_miss_s1(`TOP_DESIGN.sparc6.ifu.fcl.tlb_cam_miss_s1), // Templated
				       .cam_vld_s1(`TOP_DESIGN.sparc6.ifu.fcl.cam_vld_s1), // Templated
				       .coreid(3'h6));		 // Templated
   nc_inv_chk nc_inv_chk6(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .cpxpkt_vld	(`TOP_DESIGN.sparc6.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`TOP_DESIGN.sparc6.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`TOP_DESIGN.sparc6.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`TOP_DESIGN.sparc6.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
			  .coreid	(3'h6));			 // Templated
   
   spu_ma_mon spu_ma_mon6(/* AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .wrmi_mamul_1sthalf(`TOP_DESIGN.sparc6.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
			  .wrmi_mamul_2ndhalf(`TOP_DESIGN.sparc6.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
			  .wrmi_maaeqb_1sthalf(`TOP_DESIGN.sparc6.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
			  .wrmi_maaeqb_2ndhalf(`TOP_DESIGN.sparc6.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
			  .iptr		(`TOP_DESIGN.sparc6.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
			  .iminus_lenminus1(`TOP_DESIGN.sparc6.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
			  .mul_data	(`TOP_DESIGN.sparc6.spu.spu_madp.spu_madp_evedata[63:0]));

//   cmp_pcxandcpx cmp_pcxandcpx6(/* AUTOINST*/
//				// Inputs
//				.clk	(clk),
//				.rst_l	(rst_l),
//				.spc_pcx_data_pa(`PCXPATH6.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
//				.cpx_spc_data_cx(`PCXPATH6.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
//				.cpu	(6));
`endif
`ifdef RTL_SPARC7
   l_cache_mon l_cache_mon7(/*AUTOINST*/
			    // Inputs
			    .clk	(clk),
			    .rst_l	(rst_l),
			    .spc	(7),			 // Templated
			    .index_f	(`ICTPATH7.index_y[6:0]), // Templated
			    .wrreq_f	(`ICTPATH7.wrreq_y),	 // Templated
			    .wrway_f	(`IFUPATH7.icd.wrway_f[1:0]), // Templated
			    .wrtag_f	(`IFUPATH7.ifq_ict_wrtag_f[28:0]), // Templated
			    .wr_data	(`ICVPATH7.din_d1),	 // Templated
			    .wren_f	(`ICVPATH7.bit_wen_d1[15:0]), // Templated
			    .wrreq_bf	(`ICVPATH7.wr_en),	 // Templated
			    .wrindex_bf	(`ICVPATH7.wr_adr[6:2]), // Templated
			    .cpx_spc_data_cx(`PCXPATH7.cpx_spc_data_cx2), // Templated
			    .cpx_spc_data_rdy_cx(`PCXPATH7.cpx_spc_data_rdy_cx2), // Templated
			    .spc_pcx_data_pa(`TOP_DESIGN.sparc7.spc_pcx_data_pa), // Templated
			    .spc_pcx_req_pq(`TOP_DESIGN.sparc7.spc_pcx_req_pq), // Templated
			    .w0		(128'b0),		 // Templated
			    .w1		(128'b0),		 // Templated
			    .w2		(128'b0),		 // Templated
			    .w3		(128'b0));		 // Templated
   thrfsm_mon thrfsm_mon7(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .wm_imiss	(`TOP_DESIGN.sparc7.ifu.swl.wm_imiss[3:0]), // Templated
			  .wm_other	(`TOP_DESIGN.sparc7.ifu.swl.wm_other[3:0]), // Templated
			  .wm_stbwait	(`TOP_DESIGN.sparc7.ifu.swl.wm_stbwait[3:0]), // Templated
			  .thr_state0	(`TOP_DESIGN.sparc7.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			  .thr_state1	(`TOP_DESIGN.sparc7.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			  .thr_state2	(`TOP_DESIGN.sparc7.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			  .thr_state3	(`TOP_DESIGN.sparc7.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			  .rst_stallreq	(`TOP_DESIGN.sparc7.ifu.fcl.rst_stallreq), // Templated
			  .ifq_fcl_stallreq(`TOP_DESIGN.sparc7.ifu.fcl.ifq_fcl_stallreq), // Templated
			  .lsu_ifu_stallreq(`TOP_DESIGN.sparc7.ifu.fcl.lsu_ifu_stallreq), // Templated
			  .ffu_ifu_stallreq(`TOP_DESIGN.sparc7.ifu.fcl.ffu_ifu_stallreq), // Templated
			  .completion	(`TOP_DESIGN.sparc7.ifu.swl.completion), // Templated
			  .mul_wait	(`TOP_DESIGN.sparc7.ifu.swl.mul_wait), // Templated
			  .div_wait	(`TOP_DESIGN.sparc7.ifu.swl.div_wait), // Templated
			  .fp_wait	(`TOP_DESIGN.sparc7.ifu.swl.fp_wait), // Templated
			  .mul_wait_nxt	(`TOP_DESIGN.sparc7.ifu.swl.mul_wait_nxt), // Templated
			  .div_wait_nxt	(`TOP_DESIGN.sparc7.ifu.swl.div_wait_nxt), // Templated
			  .fp_wait_nxt	(`TOP_DESIGN.sparc7.ifu.swl.fp_wait_nxt), // Templated
			  .mul_busy_d	(`TOP_DESIGN.sparc7.ifu.swl.mul_busy_d), // Templated
			  .div_busy_d	(`TOP_DESIGN.sparc7.ifu.swl.div_busy_d), // Templated
			  .fp_busy_d	(`TOP_DESIGN.sparc7.ifu.swl.fp_busy_d), // Templated
			  .ifet_ue_vec_d1(`TOP_DESIGN.sparc7.ifu.fcl.ifet_ue_vec_d1), // Templated
			  .cpu_id	(3'h7));			 // Templated
   exu_mon exu_mon7(/*AUTOINST*/
		    // Inputs
		    .clk		(clk),
		    .rst_l		(rst_l),
		    .exu_irf_wen	(`EXUPATH7.ecl_irf_wen_w), // Templated
		    .exu_irf_wen2	(`EXUPATH7.ecl_irf_wen_w2), // Templated
		    .exu_irf_data	(`EXUPATH7.byp_irf_rd_data_w), // Templated
		    .exu_irf_data2	(`EXUPATH7.byp_irf_rd_data_w2), // Templated
		    .exu_rd		(`EXUPATH7.irf.ecl_irf_rd_w ), // Templated
		    .restore_request	(`EXUPATH7.ecl.writeback.restore_request), // Templated
		    .divcntl_wb_req_g	(`EXUPATH7.ecl.writeback.divcntl_wb_req_g)); // Templated
`ifdef GATE_SIM
`else
   tlu_mon tlu_mon7(/*AUTOINST*/
		    // Inputs
		    .clk		(`TOP_DESIGN.sparc7.tlu.rclk), // Templated
		    .grst_l		(`TOP_DESIGN.sparc7.tlu.grst_l), // Templated
		    .rst_l		(`TOP_DESIGN.sparc7.tlu.tcl.tlu_rst_l), // Templated
			.lsu_ifu_flush_pipe_w	(`TOP_DESIGN.sparc7.lsu_ifu_flush_pipe_w),
			.tlu_lsu_int_ldxa_vld_w2(`TOP_DESIGN.sparc7.tlu_lsu_int_ldxa_vld_w2),
			.tlu_lsu_int_ld_ill_va_w2(`TOP_DESIGN.sparc7.tlu_lsu_int_ld_ill_va_w2),
			.tlu_scpd_wr_vld_g		(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.tlu_scpd_wr_vld_g),
			.cpu_mondo_head_wr_g	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.cpu_mondo_head_wr_g),
			.cpu_mondo_tail_wr_g	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.cpu_mondo_tail_wr_g),
			.dev_mondo_head_wr_g	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.dev_mondo_head_wr_g),
			.dev_mondo_tail_wr_g	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.dev_mondo_tail_wr_g),
			.resum_err_head_wr_g	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.resum_err_head_wr_g),
			.resum_err_tail_wr_g	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.resum_err_tail_wr_g),
			.nresum_err_head_wr_g	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.nresum_err_head_wr_g),
			.nresum_err_tail_wr_g	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.nresum_err_tail_wr_g),
			.ifu_lsu_ld_inst_e		(`TOP_DESIGN.sparc7.tlu.ifu_lsu_ld_inst_e),
			.ifu_lsu_st_inst_e		(`TOP_DESIGN.sparc7.tlu.ifu_lsu_st_inst_e),
			.ifu_lsu_alt_space_e	(`TOP_DESIGN.sparc7.tlu.ifu_lsu_alt_space_e),
			.tlu_early_flush_pipe_w	(`TOP_DESIGN.sparc7.tlu.tlu_early_flush_pipe_w),
			.tlu_asi_state_e		(`TOP_DESIGN.sparc7.tlu.tlu_asi_state_e),
			.exu_lsu_ldst_va_e		(`TOP_DESIGN.sparc7.tlu.exu_lsu_ldst_va_e),
			.por_rstint0_w2	(`TOP_DESIGN.sparc7.tlu.tcl.por_rstint0_w2),
			.por_rstint1_w2	(`TOP_DESIGN.sparc7.tlu.tcl.por_rstint1_w2),
			.por_rstint2_w2	(`TOP_DESIGN.sparc7.tlu.tcl.por_rstint2_w2),
			.por_rstint3_w2	(`TOP_DESIGN.sparc7.tlu.tcl.por_rstint3_w2),
			.tlu_gl_lvl0	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.gl_lvl0),
			.tlu_gl_lvl1	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.gl_lvl1),
			.tlu_gl_lvl2	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.gl_lvl2),
			.tlu_gl_lvl3	(`TOP_DESIGN.sparc7.tlu.tlu_hyperv.gl_lvl3),
			.exu_gl_lvl0	(`TOP_DESIGN.sparc7.exu.rml.agp_thr0_next),
			.exu_gl_lvl1	(`TOP_DESIGN.sparc7.exu.rml.agp_thr1_next),
			.exu_gl_lvl2	(`TOP_DESIGN.sparc7.exu.rml.agp_thr2_next),
			.exu_gl_lvl3	(`TOP_DESIGN.sparc7.exu.rml.agp_thr3_next),
		    .ifu_tlu_thrid_d	(`TOP_DESIGN.sparc7.tlu.tlu_pib.ifu_tlu_thrid_d), // Templated
		    .ifu_tlu_inst_vld_m	(`TOP_DESIGN.sparc7.tlu.ifu_tlu_inst_vld_m), // Templated
		    .ifu_tlu_imiss_e	(`TOP_DESIGN.sparc7.tlu.tlu_pib.ifu_tlu_imiss_e), // Templated
		    .ifu_tlu_immu_miss_m(`TOP_DESIGN.sparc7.tlu.tlu_pib.ifu_tlu_immu_miss_m), // Templated
		    .tlu_thread_inst_vld_g(`TOP_DESIGN.sparc7.tlu.tlu_pib.tlu_thread_inst_vld_g), // Templated
		    .tlu_thread_wsel_g	(`TOP_DESIGN.sparc7.tlu.tlu_pib.tlu_thread_wsel_g), // Templated
		    .ifu_tlu_l2imiss	(`TOP_DESIGN.sparc7.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .ifu_tlu_flush_fd_w	(`TOP_DESIGN.sparc7.tlu.ifu_tlu_flush_fd_w), // Templated
		    .ifu_tlu_sraddr_d	(`TOP_DESIGN.sparc7.tlu.tlu_pib.ifu_tlu_sraddr_d), // Templated
		    .ifu_tlu_rsr_inst_d	(`TOP_DESIGN.sparc7.tlu.tlu_pib.ifu_tlu_rsr_inst_d), // Templated
		    .lsu_tlu_wsr_inst_e	(`TOP_DESIGN.sparc7.tlu.lsu_tlu_wsr_inst_e), // Templated
		    .tlu_wsr_inst_nq_g	(`TOP_DESIGN.sparc7.tlu.tlu_pib.tlu_wsr_inst_nq_g), // Templated
		    .tlu_wsr_data_w	(`TOP_DESIGN.sparc7.tlu.tlu_pib.tlu_wsr_data_w), // Templated
		    .lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc7.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .lsu_tlu_l2_dmiss	(`TOP_DESIGN.sparc7.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc7.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .lsu_tlu_dmmu_miss_g(`TOP_DESIGN.sparc7.tlu.tlu_pib.lsu_tlu_dmmu_miss_g), // Templated
		    .ffu_tlu_fpu_tid	(`TOP_DESIGN.sparc7.tlu.tlu_pib.ffu_tlu_fpu_tid), // Templated
		    .ffu_tlu_fpu_cmplt	(`TOP_DESIGN.sparc7.tlu.tlu_pib.ffu_tlu_fpu_cmplt), // Templated
		    .tlu_pstate_priv	(`TOP_DESIGN.sparc7.tlu.local_pstate_priv), // Templated
		    .tlu_hpstate_priv	(`TOP_DESIGN.sparc7.tlu.tlu_hpstate_priv), // Templated
		    .tlu_hpstate_enb	(`TOP_DESIGN.sparc7.tlu.tlu_hpstate_enb), // Templated
		    .tlu_pstate_ie	(`TOP_DESIGN.sparc7.tlu.local_pstate_ie), // Templated
		    .wsr_thread_inst_g	(`TOP_DESIGN.sparc7.tlu.tlu_pib.wsr_thread_inst_g), // Templated
		    .lsu_tlu_defr_trp_taken_g(`TOP_DESIGN.sparc7.tlu.lsu_tlu_defr_trp_taken_g), // Templated
		    .lsu_tlu_async_ttype_vld_w1(`TOP_DESIGN.sparc7.tlu.lsu_tlu_async_ttype_vld_g), // Templated
		    .lsu_tlu_ttype_vld_m2(`TOP_DESIGN.sparc7.tlu.lsu_tlu_ttype_vld_m2), // Templated
		    .tlu_ifu_flush_pipe_w(`TOP_DESIGN.sparc7.tlu.tcl.tlu_ifu_flush_pipe_w), // Templated
		    .tcc_inst_w2	(`TOP_DESIGN.sparc7.tlu.tlu_pib.tcc_inst_w2), // Templated
		    .tlu_pib_rsr_data_e	(`TOP_DESIGN.sparc7.tlu.tlu_pib.tlu_pib_rsr_data_e), // Templated
		    .tlu_pib_priv_act_trap_m(`TOP_DESIGN.sparc7.tlu.tlu_pib.pib_priv_act_trap_m), // Templated
		    .tlu_pib_picl_wrap	(`TOP_DESIGN.sparc7.tlu.tlu_pib.pib_picl_wrap), // Templated
		    .tlu_pib_pich_wrap	(`TOP_DESIGN.sparc7.tlu.tlu_pib.pich_onebelow_flg), // Templated
		    .tlu_ifu_trappc_vld_w1(`TOP_DESIGN.sparc7.tlu.tlu_ifu_trappc_vld_w1), // Templated
		    .tlu_ifu_trappc_w2	(`TOP_DESIGN.sparc7.tlu.tlu_ifu_trappc_w2), // Templated
		    .tlu_final_ttype_w2	(`TOP_DESIGN.sparc7.tlu.tlu_final_ttype_w2), // Templated
		    .tlu_ifu_trap_tid_w1(`TOP_DESIGN.sparc7.tlu.tlu_ifu_trap_tid_w1), // Templated
		    .tlu_full_flush_pipe_w2(`TOP_DESIGN.sparc7.tlu.tlu_full_flush_pipe_w2), // Templated
		    .rtl_pcr0		(`TOP_DESIGN.sparc7.tlu.tlu_pib.pcr0), // Templated
		    .rtl_pcr1		(`TOP_DESIGN.sparc7.tlu.tlu_pib.pcr1), // Templated
		    .rtl_pcr2		(`TOP_DESIGN.sparc7.tlu.tlu_pib.pcr2), // Templated
		    .rtl_pcr3		(`TOP_DESIGN.sparc7.tlu.tlu_pib.pcr3), // Templated
		    .rtl_pich_cnt0	(`TOP_DESIGN.sparc7.tlu.tlu_pib.pich_cnt0), // Templated
		    .rtl_pich_cnt1	(`TOP_DESIGN.sparc7.tlu.tlu_pib.pich_cnt1), // Templated
		    .rtl_pich_cnt2	(`TOP_DESIGN.sparc7.tlu.tlu_pib.pich_cnt2), // Templated
		    .rtl_pich_cnt3	(`TOP_DESIGN.sparc7.tlu.tlu_pib.pich_cnt3), // Templated
		    .rtl_picl_cnt0	(`TOP_DESIGN.sparc7.tlu.tlu_pib.picl_cnt0), // Templated
		    .rtl_picl_cnt1	(`TOP_DESIGN.sparc7.tlu.tlu_pib.picl_cnt1), // Templated
		    .rtl_picl_cnt2	(`TOP_DESIGN.sparc7.tlu.tlu_pib.picl_cnt2), // Templated
		    .rtl_picl_cnt3	(`TOP_DESIGN.sparc7.tlu.tlu_pib.picl_cnt3), // Templated
		    .rtl_lsu_tlu_stb_full_w2(`TOP_DESIGN.sparc7.tlu.tlu_pib.lsu_tlu_stb_full_w2), // Templated
		    .rtl_fpu_cmplt_thread(`TOP_DESIGN.sparc7.tlu.tlu_pib.fpu_cmplt_thread), // Templated
		    .rtl_imiss_thread_g	(`TOP_DESIGN.sparc7.tlu.tlu_pib.imiss_thread_g), // Templated
		    .rtl_lsu_tlu_dcache_miss_w2(`TOP_DESIGN.sparc7.tlu.tlu_pib.lsu_tlu_dcache_miss_w2), // Templated
		    .rtl_immu_miss_thread_g(`TOP_DESIGN.sparc7.tlu.tlu_pib.immu_miss_thread_g), // Templated
		    .rtl_dmmu_miss_thread_g(`TOP_DESIGN.sparc7.tlu.tlu_pib.dmmu_miss_thread_g), // Templated
		    .rtl_ifu_tlu_l2imiss(`TOP_DESIGN.sparc7.tlu.tlu_pib.ifu_tlu_l2imiss), // Templated
		    .rtl_lsu_tlu_l2_dmiss(`TOP_DESIGN.sparc7.tlu.tlu_pib.lsu_tlu_l2_dmiss), // Templated
		    .true_pil0		(`TOP_DESIGN.sparc7.tlu.tcl.true_pil0), // Templated
		    .true_pil1		(`TOP_DESIGN.sparc7.tlu.tcl.true_pil1), // Templated
		    .true_pil2		(`TOP_DESIGN.sparc7.tlu.tcl.true_pil2), // Templated
		    .true_pil3		(`TOP_DESIGN.sparc7.tlu.tcl.true_pil3), // Templated
		    .rtl_trp_lvl0	(`TOP_DESIGN.sparc7.tlu.tcl.trp_lvl0), // Templated
		    .rtl_trp_lvl1	(`TOP_DESIGN.sparc7.tlu.tcl.trp_lvl1), // Templated
		    .rtl_trp_lvl2	(`TOP_DESIGN.sparc7.tlu.tcl.trp_lvl2), // Templated
		    .rtl_trp_lvl3	(`TOP_DESIGN.sparc7.tlu.tcl.trp_lvl3), // Templated
		    .tlz_thread		(`TOP_DESIGN.sparc7.tlu.tcl.tlz_thread), // Templated
		    .th0_sftint_15	(`TOP_DESIGN.sparc7.tlu.tdp.sftint0[15]), // Templated
		    .th1_sftint_15	(`TOP_DESIGN.sparc7.tlu.tdp.sftint1[15]), // Templated
		    .th2_sftint_15	(`TOP_DESIGN.sparc7.tlu.tdp.sftint2[15]), // Templated
		    .th3_sftint_15	(`TOP_DESIGN.sparc7.tlu.tdp.sftint3[15]), // Templated
		    .ifu_swint_g	(`TOP_DESIGN.sparc7.tlu.tcl.swint_g), // Templated
		    .core_id		(3'h7),			 // Templated
		    .tlu_itlb_wr_vld_g	(`TOP_DESIGN.sparc7.tlu_itlb_wr_vld_g), // Templated
		    .tlu_itlb_dmp_vld_g	(`TOP_DESIGN.sparc7.tlu_itlb_dmp_vld_g), // Templated
		    .tlu_itlb_tte_tag_w2(`TOP_DESIGN.sparc7.tlu_itlb_tte_tag_w2), // Templated
		    .tlu_itlb_tte_data_w2(`TOP_DESIGN.sparc7.tlu_itlb_tte_data_w2), // Templated
		    .itlb_wr_vld	(`TOP_DESIGN.sparc7.ifu.itlb.tlb_wr_vld), // Templated
		    .dtlb_wr_vld	(`TOP_DESIGN.sparc7.lsu.dtlb.tlb_wr_vld), // Templated
		    .tlu_tlb_access_en_l_d1(`TOP_DESIGN.sparc7.tlu.mmu_dp.tlu_tlb_access_en_l_d1), // Templated
		    .tlu_lng_ltncy_en_l	(`TOP_DESIGN.sparc7.tlu.mmu_dp.tlu_lng_ltncy_en_l)); // Templated
`endif // ifdef GATE_SIM

`ifdef GATE_SIM
`else
    softint_mon softint_mon7 (/*AUTOINST*/
			      // Inputs
			      .rtl_softint0(`TOP_DESIGN.sparc7.tlu.tdp.sftint0), // Templated
			      .rtl_softint1(`TOP_DESIGN.sparc7.tlu.tdp.sftint1), // Templated
			      .rtl_softint2(`TOP_DESIGN.sparc7.tlu.tdp.sftint2), // Templated
			      .rtl_softint3(`TOP_DESIGN.sparc7.tlu.tdp.sftint3), // Templated
			      .rtl_wsr_data_w(`TOP_DESIGN.sparc7.tlu.tdp.wsr_data_w), // Templated
			      .rtl_sftint_en_l_g(`TOP_DESIGN.sparc7.tlu.tdp.tlu_sftint_en_l_g), // Templated
			      .rtl_sftint_b0_en(`TOP_DESIGN.sparc7.tlu.tdp.sftint_b0_en), // Templated
			      .rtl_tickcmp_int(`TOP_DESIGN.sparc7.tlu.tdp.tickcmp_int), // Templated
			      .rtl_sftint_b16_en(`TOP_DESIGN.sparc7.tlu.tdp.sftint_b16_en), // Templated
			      .rtl_stickcmp_int(`TOP_DESIGN.sparc7.tlu.tdp.stickcmp_int), // Templated
			      .rtl_sftint_b15_en(`TOP_DESIGN.sparc7.tlu.tdp.sftint_b15_en), // Templated
			      .rtl_pib_picl_wrap(`TOP_DESIGN.sparc7.tlu.tdp.pib_picl_wrap), // Templated
			      .rtl_pib_pich_wrap(`TOP_DESIGN.sparc7.tlu.tdp.pib_pich_wrap), // Templated
			      .rtl_wr_sftint_l_g(`TOP_DESIGN.sparc7.tlu.tdp.tlu_wr_sftint_l_g), // Templated
			      .rtl_set_sftint_l_g(`TOP_DESIGN.sparc7.tlu.tdp.tlu_set_sftint_l_g), // Templated
			      .rtl_clr_sftint_l_g(`TOP_DESIGN.sparc7.tlu.tdp.tlu_clr_sftint_l_g), // Templated
			      .rtl_clk	(`TOP_DESIGN.sparc7.tlu.tdp.rclk), // Templated
			      .rtl_reset(`TOP_DESIGN.sparc7.tlu.tdp.tlu_rst), // Templated
			      .core_id	(3'h7));			 // Templated
`endif // ifdef GATE_SIM

   nukeint_mon nukeint_mon7 (/*AUTOINST*/
			     // Inputs
			     .clk	(clk),
			     .rst_l	(rst_l),
			     .thr_state0(`TOP_DESIGN.sparc7.ifu.swl.thrfsm0.thr_state[4:0]), // Templated
			     .thr_state1(`TOP_DESIGN.sparc7.ifu.swl.thrfsm1.thr_state[4:0]), // Templated
			     .thr_state2(`TOP_DESIGN.sparc7.ifu.swl.thrfsm2.thr_state[4:0]), // Templated
			     .thr_state3(`TOP_DESIGN.sparc7.ifu.swl.thrfsm3.thr_state[4:0]), // Templated
			     .rstthr	(`TOP_DESIGN.sparc7.ifu.tlu_ifu_rstthr_i2[3:0]), // Templated
			     .nukeint	(`TOP_DESIGN.sparc7.ifu.tlu_ifu_nukeint_i2), // Templated
			     .resumint	(`TOP_DESIGN.sparc7.ifu.tlu_ifu_resumint_i2), // Templated
			     .rstint	(`TOP_DESIGN.sparc7.ifu.tlu_ifu_rstint_i2), // Templated
			     .coreid	(3'h7));			 // Templated
   mask_mon mask_mon7(/*AUTOINST*/
		      // Inputs
		      .clk		(clk),
		      .rst_l		(rst_l),
		      .wm_imiss		(`TOP_DESIGN.sparc7.ifu.swl.wm_imiss), // Templated
		      .wm_other		(`TOP_DESIGN.sparc7.ifu.swl.wm_other), // Templated
		      .wm_stbwait	(`TOP_DESIGN.sparc7.ifu.swl.wm_stbwait), // Templated
		      .mul_wait		(`TOP_DESIGN.sparc7.ifu.swl.mul_wait), // Templated
		      .div_wait		(`TOP_DESIGN.sparc7.ifu.swl.div_wait), // Templated
		      .fp_wait		(`TOP_DESIGN.sparc7.ifu.swl.fp_wait), // Templated
		      .mul_busy_e	(`TOP_DESIGN.sparc7.ifu.swl.mul_busy_e), // Templated
		      .div_busy_e	(`TOP_DESIGN.sparc7.ifu.swl.div_busy_e), // Templated
		      .fp_busy_e	(`TOP_DESIGN.sparc7.ifu.swl.fp_busy_e), // Templated
		      .ldmiss		(`TOP_DESIGN.sparc7.ifu.swl.ldmiss), // Templated
		      .coreid		(3'h7));			 // Templated
   pc_muxsel_mon pc_muxsel_mon7 (/*AUTOINST*/
				 // Inputs
				 .clk	(clk),
				 .rst_l	(rst_l),
				 .t0pc_f(`TOP_DESIGN.sparc7.ifu.fdp.t0pc_f[47:0]), // Templated
				 .t1pc_f(`TOP_DESIGN.sparc7.ifu.fdp.t1pc_f[47:0]), // Templated
				 .t2pc_f(`TOP_DESIGN.sparc7.ifu.fdp.t2pc_f[47:0]), // Templated
				 .t3pc_f(`TOP_DESIGN.sparc7.ifu.fdp.t3pc_f[47:0]), // Templated
				 .pc_f	(`TOP_DESIGN.sparc7.ifu.fdp.pc_f[47:0]), // Templated
				 .inst_vld_f(`TOP_DESIGN.sparc7.ifu.fcl.inst_vld_f), // Templated
				 .dtu_fcl_running_s(`TOP_DESIGN.sparc7.ifu.dtu_fcl_running_s), // Templated
				 .thr_f	(`TOP_DESIGN.sparc7.ifu.fcl.thr_f[3:0]), // Templated
				 .coreid(3'h7));			 // Templated
   stb_ovfl_mon stb_ovfl_mon7  (/*AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.lsu_ifu_stbcnt3(`TOP_DESIGN.sparc7.ifu.lsu_ifu_stbcnt3), // Templated
				.lsu_ifu_stbcnt2(`TOP_DESIGN.sparc7.ifu.lsu_ifu_stbcnt2), // Templated
				.lsu_ifu_stbcnt1(`TOP_DESIGN.sparc7.ifu.lsu_ifu_stbcnt1), // Templated
				.lsu_ifu_stbcnt0(`TOP_DESIGN.sparc7.ifu.lsu_ifu_stbcnt0), // Templated
				.stb_ctl_reset3(`TOP_DESIGN.sparc7.lsu.stb_ctl3.reset), // Templated
				.stb_ctl_reset2(`TOP_DESIGN.sparc7.lsu.stb_ctl2.reset), // Templated
				.stb_ctl_reset1(`TOP_DESIGN.sparc7.lsu.stb_ctl1.reset), // Templated
				.stb_ctl_reset0(`TOP_DESIGN.sparc7.lsu.stb_ctl0.reset), // Templated
				.coreid	(3'h7));			 // Templated
   icache_mutex_mon icache_mutex_mon7 (/*AUTOINST*/
				       // Inputs
				       .clk(clk),
				       .rst_l(rst_l),
				       .waysel_buf_s1(`TOP_DESIGN.sparc7.ifu.wseldp.waysel_buf_s1), // Templated
				       .alltag_err_s1(`TOP_DESIGN.sparc7.ifu.errctl.alltag_err_s1), // Templated
				       .tlb_cam_miss_s1(`TOP_DESIGN.sparc7.ifu.fcl.tlb_cam_miss_s1), // Templated
				       .cam_vld_s1(`TOP_DESIGN.sparc7.ifu.fcl.cam_vld_s1), // Templated
				       .coreid(3'h7));		 // Templated
   nc_inv_chk nc_inv_chk7(/*AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .cpxpkt_vld	(`TOP_DESIGN.sparc7.ifu.lsu_ifu_cpxpkt_i1[144]), // Templated
			  .cpxpkt_rtntype(`TOP_DESIGN.sparc7.ifu.lsu_ifu_cpxpkt_i1[143:140]), // Templated
			  .nc		(`TOP_DESIGN.sparc7.ifu.lsu_ifu_cpxpkt_i1[136]), // Templated
			  .wv		(`TOP_DESIGN.sparc7.ifu.lsu_ifu_cpxpkt_i1[133]), // Templated
			  .coreid	(3'h7));			 // Templated
   
   spu_ma_mon spu_ma_mon7(/* AUTOINST*/
			  // Inputs
			  .clk		(clk),
			  .wrmi_mamul_1sthalf(`TOP_DESIGN.sparc7.spu.spu_ctl.spu_mamul.spu_mamul_wr_mi),
			  .wrmi_mamul_2ndhalf(`TOP_DESIGN.sparc7.spu.spu_ctl.spu_mamul.spu_mamul_wr_miminuslenminus1),
			  .wrmi_maaeqb_1sthalf(`TOP_DESIGN.sparc7.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_mi),
			  .wrmi_maaeqb_2ndhalf(`TOP_DESIGN.sparc7.spu.spu_ctl.spu_maaeqb.spu_maaeqb_wr_miminuslenminus1),
			  .iptr		(`TOP_DESIGN.sparc7.spu.spu_ctl.spu_maaddr.i_ptr[6:0]),
			  .iminus_lenminus1(`TOP_DESIGN.sparc7.spu.spu_ctl.spu_maaddr.iminus1_lenminus1[6:0]),
			  .mul_data	(`TOP_DESIGN.sparc7.spu.spu_madp.spu_madp_evedata[63:0]));

//   cmp_pcxandcpx cmp_pcxandcpx7(/* AUTOINST*/
//				// Inputs
//				.clk	(clk),
//				.rst_l	(rst_l),
//				.spc_pcx_data_pa(`PCXPATH7.spc_pcx_data_pa[`PCX_WIDTH-1:0]),
//				.cpx_spc_data_cx(`PCXPATH7.cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
//				.cpu	(7));
`endif // ifdef RTL_SPARC7

`endif // ifdef GATE_SIM

`ifdef RTL_SPARC0
   //monitor good trap and bad trap.
   pc_cmp              pc_cmp(clk, rst_l); // Sumti - Shifting it back to clk, sas race with +fast_boot.
//dump cache
`endif // ifdef RTL_SPARC0


	// dump_cache dump_cache();
	trig_event    trig_event(/* AUTOINST*/
			// Inputs
			.clk	(clk));

	// Don't include this section if compiling for DRAM SAT Environment
	`ifdef DRAM_SAT
	`else

		cmp_pcxandcpx cmp_pcxandcpx0(/* AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.spc_pcx_req_pq(`TOP_DESIGN.spc0_pcx_req_pq[4:0]),
				.spc_pcx_data_pa(`TOP_DESIGN.spc0_pcx_data_pa[`PCX_WIDTH-1:0]),
				.cpx_spc_data_cx(`TOP_DESIGN.cpx_spc0_data_cx2[`CPX_WIDTH-1:0]),
				.cpu	(0));
		cmp_pcxandcpx cmp_pcxandcpx1(/* AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.spc_pcx_req_pq(`TOP_DESIGN.spc1_pcx_req_pq[4:0]),
				.spc_pcx_data_pa(`TOP_DESIGN.spc1_pcx_data_pa[`PCX_WIDTH-1:0]),
				.cpx_spc_data_cx(`TOP_DESIGN.cpx_spc1_data_cx2[`CPX_WIDTH-1:0]),
				.cpu	(1));
		cmp_pcxandcpx cmp_pcxandcpx2(/* AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.spc_pcx_req_pq(`TOP_DESIGN.spc2_pcx_req_pq[4:0]),
				.spc_pcx_data_pa(`TOP_DESIGN.spc2_pcx_data_pa[`PCX_WIDTH-1:0]),
				.cpx_spc_data_cx(`TOP_DESIGN.cpx_spc2_data_cx2[`CPX_WIDTH-1:0]),
				.cpu	(2));
		cmp_pcxandcpx cmp_pcxandcpx3(/* AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.spc_pcx_req_pq(`TOP_DESIGN.spc3_pcx_req_pq[4:0]),
				.spc_pcx_data_pa(`TOP_DESIGN.spc3_pcx_data_pa[`PCX_WIDTH-1:0]),
				.cpx_spc_data_cx(`TOP_DESIGN.cpx_spc3_data_cx2[`CPX_WIDTH-1:0]),
				.cpu	(3));
		cmp_pcxandcpx cmp_pcxandcpx4(/* AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.spc_pcx_req_pq(`TOP_DESIGN.spc4_pcx_req_pq[4:0]),
				.spc_pcx_data_pa(`TOP_DESIGN.spc4_pcx_data_pa[`PCX_WIDTH-1:0]),
				.cpx_spc_data_cx(`TOP_DESIGN.cpx_spc4_data_cx2[`CPX_WIDTH-1:0]),
				.cpu	(4));
		cmp_pcxandcpx cmp_pcxandcpx5(/* AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.spc_pcx_req_pq(`TOP_DESIGN.spc5_pcx_req_pq[4:0]),
				.spc_pcx_data_pa(`TOP_DESIGN.spc5_pcx_data_pa[`PCX_WIDTH-1:0]),
				.cpx_spc_data_cx(`TOP_DESIGN.cpx_spc5_data_cx2[`CPX_WIDTH-1:0]),
				.cpu	(5));
		cmp_pcxandcpx cmp_pcxandcpx6(/* AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.spc_pcx_req_pq(`TOP_DESIGN.spc6_pcx_req_pq[4:0]),
				.spc_pcx_data_pa(`TOP_DESIGN.spc6_pcx_data_pa[`PCX_WIDTH-1:0]),
				.cpx_spc_data_cx(`TOP_DESIGN.cpx_spc6_data_cx2[`CPX_WIDTH-1:0]),
				.cpu	(6));
		cmp_pcxandcpx cmp_pcxandcpx7(/* AUTOINST*/
				// Inputs
				.clk	(clk),
				.rst_l	(rst_l),
				.spc_pcx_req_pq(`TOP_DESIGN.spc7_pcx_req_pq[4:0]),
				.spc_pcx_data_pa(`TOP_DESIGN.spc7_pcx_data_pa[`PCX_WIDTH-1:0]),
				.cpx_spc_data_cx(`TOP_DESIGN.cpx_spc7_data_cx2[`CPX_WIDTH-1:0]),
				.cpu	(7));

	`endif  // ifdef DRAM_SAT

`endif // ifdef MSS_SAT

endmodule
// Local Variables:
// verilog-library-directories:("." "../../../design/sys/iop/sparc/rtl")
// verilog-library-extensions:(".v" ".h")
// End:












