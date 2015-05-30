// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc_exu_rml.v
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
////////////////////////////////////////////////////////////////////////
/*
//  Module Name: sparc_exu_rml
//	Description: Register management logic.  Contains CWP, CANSAVE, CANRESTORE
//		and other window management registers.  Generates RF related traps
//  		and switches the global registers to alternate globals.  All the registers
//		are written in the W stage (there is no bypassing so they must
//		swap out) and will either get a new value generated by a window management
//		Instruction or by a WRPS instruction.  The following traps can be generated:
//			Fill: restore with canrestore == 0
//			clean_window: save with cleanwin-canrestore == 0
//			spill: flushw with cansave != nwindows -2 or
//				save with cansave == 0
//		It is assumed that the contents of the new window will get squashed
//		on a clean_window or fill trap so the save or restore gets executed
//		normally.  Spill traps or WRCWPs mean that all 16 windowed registers
//		must be saved and restored (a 4 cycle operation).
*/
module sparc_exu_rml (/*AUTOARG*/
   // Outputs
   exu_tlu_spill_wtype, exu_tlu_spill_other, exu_tlu_cwp_retry, 
   exu_tlu_cwp3_w, exu_tlu_cwp2_w, exu_tlu_cwp1_w, exu_tlu_cwp0_w, 
   so, exu_tlu_cwp_cmplt, exu_tlu_cwp_cmplt_tid, rml_ecl_cwp_d, 
   rml_ecl_cansave_d, rml_ecl_canrestore_d, rml_ecl_otherwin_d, 
   rml_ecl_wstate_d, rml_ecl_cleanwin_d, rml_ecl_fill_e, 
   rml_ecl_clean_window_e, rml_ecl_other_e, rml_ecl_wtype_e, 
   exu_ifu_spill_e, rml_ecl_gl_e, rml_irf_old_lo_cwp_e, 
   rml_irf_new_lo_cwp_e, rml_irf_old_e_cwp_e, rml_irf_new_e_cwp_e, 
   rml_irf_swap_even_e, rml_irf_swap_odd_e, rml_irf_swap_local_e, 
   rml_irf_kill_restore_w, rml_irf_cwpswap_tid_e, rml_ecl_swap_done, 
   rml_ecl_rmlop_done_e, exu_ifu_oddwin_s, exu_tlu_spill, 
   exu_tlu_spill_tid, rml_ecl_kill_m, rml_irf_old_agp, 
   rml_irf_new_agp, rml_irf_swap_global, rml_irf_global_tid, 
   // Inputs
   tlu_exu_cwp_retry_m, rst_tri_en, rclk, se, si, grst_l, arst_l, 
   ifu_exu_tid_s2, ifu_exu_save_d, ifu_exu_restore_d, 
   ifu_exu_saved_e, ifu_exu_restored_e, ifu_exu_flushw_e, 
   ecl_rml_thr_m, ecl_rml_thr_w, ecl_rml_cwp_wen_e, 
   ecl_rml_cansave_wen_w, ecl_rml_canrestore_wen_w, 
   ecl_rml_otherwin_wen_w, ecl_rml_wstate_wen_w, 
   ecl_rml_cleanwin_wen_w, ecl_rml_xor_data_e, ecl_rml_kill_e, 
   ecl_rml_kill_w, ecl_rml_early_flush_w, exu_tlu_wsr_data_w, 
   tlu_exu_agp, tlu_exu_agp_swap, tlu_exu_agp_tid, tlu_exu_cwp_m, 
   tlu_exu_cwpccr_update_m, ecl_rml_inst_vld_w
   ) ;
   input rclk;
   input se;
   input si;
   input grst_l;
   input arst_l;
   input [1:0] ifu_exu_tid_s2;
   input       ifu_exu_save_d;
   input       ifu_exu_restore_d;
   input       ifu_exu_saved_e;
   input       ifu_exu_restored_e;
   input       ifu_exu_flushw_e;
   input [3:0] ecl_rml_thr_m;
   input [3:0] ecl_rml_thr_w;
   input       ecl_rml_cwp_wen_e;
   input       ecl_rml_cansave_wen_w;
   input       ecl_rml_canrestore_wen_w;
   input       ecl_rml_otherwin_wen_w;
   input       ecl_rml_wstate_wen_w;
   input       ecl_rml_cleanwin_wen_w;
   input [2:0] ecl_rml_xor_data_e;
   input       ecl_rml_kill_e;// needed for oddwin updates
   input       ecl_rml_kill_w;
   input       ecl_rml_early_flush_w;
   input [5:0] exu_tlu_wsr_data_w; // for wstate
   input [1:0]   tlu_exu_agp;   // alternate global pointer
   input         tlu_exu_agp_swap;// switch globals
   input [1:0]   tlu_exu_agp_tid;// thread that agp refers to
   input [2:0] tlu_exu_cwp_m;   // for switching cwp on return from trap
   input       tlu_exu_cwpccr_update_m;
   input       ecl_rml_inst_vld_w;
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   input                rst_tri_en;             // To cwp of sparc_exu_rml_cwp.v
   input                tlu_exu_cwp_retry_m;    // To cwp of sparc_exu_rml_cwp.v
   // End of automatics

   /*AUTOOUTPUT*/
   // Beginning of automatic outputs (from unused autoinst outputs)
   output [2:0]         exu_tlu_cwp0_w;         // From cwp of sparc_exu_rml_cwp.v
   output [2:0]         exu_tlu_cwp1_w;         // From cwp of sparc_exu_rml_cwp.v
   output [2:0]         exu_tlu_cwp2_w;         // From cwp of sparc_exu_rml_cwp.v
   output [2:0]         exu_tlu_cwp3_w;         // From cwp of sparc_exu_rml_cwp.v
   output               exu_tlu_cwp_retry;      // From cwp of sparc_exu_rml_cwp.v
   output               exu_tlu_spill_other;    // From cwp of sparc_exu_rml_cwp.v
   output [2:0]         exu_tlu_spill_wtype;    // From cwp of sparc_exu_rml_cwp.v
   // End of automatics
   output               so;
   output      exu_tlu_cwp_cmplt;
   output [1:0] exu_tlu_cwp_cmplt_tid;
   output [2:0]  rml_ecl_cwp_d;
   output [2:0]  rml_ecl_cansave_d;
   output [2:0]  rml_ecl_canrestore_d;
   output [2:0]  rml_ecl_otherwin_d;
   output [5:0]  rml_ecl_wstate_d;
   output [2:0]  rml_ecl_cleanwin_d;
   output        rml_ecl_fill_e;
   output        rml_ecl_clean_window_e;
   output        rml_ecl_other_e;
   output [2:0] rml_ecl_wtype_e;
   output       exu_ifu_spill_e;
   output [1:0] rml_ecl_gl_e;

   output [2:0]  rml_irf_old_lo_cwp_e;  // current window pointer for locals and odds
   output [2:0]  rml_irf_new_lo_cwp_e;  // current window pointer for locals and odd
   output [1:0]  rml_irf_old_e_cwp_e;  // current window pointer for evens
   output [1:0]  rml_irf_new_e_cwp_e;  // current window pointer for evens
   output        rml_irf_swap_even_e;
   output        rml_irf_swap_odd_e;
   output        rml_irf_swap_local_e;
   output        rml_irf_kill_restore_w;
   output [1:0]  rml_irf_cwpswap_tid_e;

   output [3:0] rml_ecl_swap_done;
   output       rml_ecl_rmlop_done_e;   
   output [3:0] exu_ifu_oddwin_s;
   output       exu_tlu_spill;
   output [1:0] exu_tlu_spill_tid;
   output       rml_ecl_kill_m;
   
   output [1:0]  rml_irf_old_agp; // alternate global pointer
   output [1:0]  rml_irf_new_agp; // alternate global pointer
   output        rml_irf_swap_global;
   output [1:0]  rml_irf_global_tid;

   wire          clk;
   wire [1:0]    tid_d;
   wire [3:0]    thr_d;
   wire [1:0]    tid_e;
   wire          rml_reset_l;
   wire          reset;
   wire          save_e;
   wire          save_m;
   wire          restore_e;
   wire          swap_e;
   wire          agp_wen;
   wire [1:0]    agp_thr0;
   wire [1:0]    agp_thr1;
   wire [1:0]    agp_thr2;
   wire [1:0]    agp_thr3;
   wire [1:0]    agp_thr0_next;
   wire [1:0]    agp_thr1_next;
   wire [1:0]    agp_thr2_next;
   wire [1:0]    agp_thr3_next;
   wire          agp_wen_thr0_w;
   wire          agp_wen_thr1_w;
   wire          agp_wen_thr2_w;
   wire          agp_wen_thr3_w;
   wire [1:0]    new_agp;   
   wire [1:0]    agp_tid;
   wire [3:0]    agp_thr;
   wire        full_swap_e;
   wire   did_restore_m;
   wire   did_restore_w;
   wire   kill_restore_m;
   wire   kill_restore_w;

   wire [2:0]  rml_ecl_cwp_e;
   wire [2:0]  rml_ecl_cansave_e;
   wire [2:0]  rml_ecl_canrestore_e;
   wire [2:0]  rml_ecl_otherwin_e;
   wire [2:0]  rml_ecl_cleanwin_e;

   wire [2:0]  rml_next_cwp_e;        
   wire [2:0]  rml_next_cansave_e;// e-stage of rml generated new data
   wire [2:0]  rml_next_canrestore_e;
   wire [2:0]  rml_next_otherwin_e;
   wire [2:0]  rml_next_cleanwin_e;
   
   wire [2:0]  next_cwp_e;      
   wire [2:0]  next_cansave_e;  // e-stage of new data
   wire [2:0]  next_canrestore_e;
   wire [2:0]  next_otherwin_e;
   wire [2:0]  next_cleanwin_e;
   wire [2:0]  next_cwp_m;      // m-stage of new data
   wire [2:0]  next_cansave_m;
   wire [2:0]  next_canrestore_m;
   wire [2:0]  next_otherwin_m;
   wire [2:0]  next_cleanwin_m;
   wire [2:0]  next_cansave_w;// w-stage of new data
   wire [2:0]  next_canrestore_w;
   wire [2:0]  next_otherwin_w;
   wire [2:0]  next_cleanwin_w;
   wire [2:0]  next_cwp_noreset_w;
   wire [2:0]  next_cwp_w;

   wire   rml_cwp_wen_e;        // wen for cwp from rml
   wire   rml_cwp_wen_m;        // wen for cwp from rml
   wire [2:0] spill_cwp_e;      // next cwp if there is a spill trap 
   wire       spill_cwp_carry0; // carry bit from spill cwp computations
   wire       spill_cwp_carry1;
   wire       next_cwp_sel_inc; // select line to next_cwp mux

   wire        rml_cansave_wen_w;// rml generated wen
   wire        rml_canrestore_wen_w;
   wire        rml_otherwin_wen_w;
   wire        rml_cleanwin_wen_w;

   wire        cansave_wen_w;// wen to registers
   wire        canrestore_wen_w;
   wire        otherwin_wen_w;
   wire        cleanwin_wen_w;
   wire        cwp_wen_nokill_w;
   wire        cwp_wen_w;
   wire        wstate_wen_w;

   wire        cwp_wen_m;       // rml generated wen w/o kills
   wire        cansave_wen_m;
   wire        canrestore_wen_m;
   wire        otherwin_wen_m;
   wire        cleanwin_wen_m;
   wire        cansave_wen_valid_m;	// rml generated wen w/ kills
   wire        canrestore_wen_valid_m;
   wire        otherwin_wen_valid_m;
   wire        cleanwin_wen_valid_m;

   wire      	 cwp_wen_e;       // rml generated wen_e
   wire        cansave_wen_e;
   wire        canrestore_wen_e;
   wire        otherwin_wen_e;
   wire        cleanwin_wen_e;

   wire        cansave_inc_e;
   wire        canrestore_inc_e;

   wire        spill_trap_save;
   wire        spill_trap_flush;
   wire        spill_m;
   wire [2:0]  cleanwin_xor_canrestore;

   wire        otherwin_is0_e;
   wire        cansave_is0_e;
   wire        canrestore_is0_e;

   wire        swap_locals_ins;
   wire        swap_outs;
   wire [2:0]  old_cwp_e;
   wire [2:0]  new_cwp_e;

   wire [2:0]   rml_ecl_wtype_d;
   wire [2:0]   rml_ecl_wtype_e;
   wire         rml_ecl_other_d;
   wire         rml_ecl_other_e;
   wire        exu_tlu_spill_e;
   wire         rml_ecl_kill_e;
   wire         rml_kill_w;
   wire         vld_w;
   wire         win_trap_e;
   wire         win_trap_m;
   wire         win_trap_w;

   assign       clk = rclk;
   // Reset flop
    dffrl_async rstff(.din (grst_l),
                        .q   (rml_reset_l),
                        .clk (clk),
                        .rst_l (arst_l), .se(se), .si(), .so());
   assign       reset = ~rml_reset_l;
 
   dff_s #(2) tid_s2d(.din(ifu_exu_tid_s2[1:0]), .clk(clk), .q(tid_d[1:0]), .se(se), .si(), .so());
   dff_s #(2) tid_d2e(.din(tid_d[1:0]), .clk(clk), .q(tid_e[1:0]), .se(se), .si(), .so());
   assign       thr_d[3] = tid_d[1] & tid_d[0];
   assign       thr_d[2] = tid_d[1] & ~tid_d[0];
   assign       thr_d[1] = ~tid_d[1] & tid_d[0];
   assign       thr_d[0] = ~tid_d[1] & ~tid_d[0];
   
   dff_s save_d2e(.din(ifu_exu_save_d), .clk(clk), .q(save_e), .se(se), .si(), .so());
   dff_s save_e2m(.din(save_e), .clk(clk), .q(save_m), .se(se), .si(), .so());
   dff_s restore_d2e(.din(ifu_exu_restore_d), .clk(clk), .q(restore_e), .se(se), .si(), .so());

   // don't check flush_pipe in w if caused by rml trap.  Things with a higher priority
   // than a window trap have been accumulated into ecl_rml_kill_w
   assign       vld_w = ecl_rml_inst_vld_w & (~ecl_rml_early_flush_w | win_trap_w);
   assign     rml_kill_w = ecl_rml_kill_w | ~vld_w;

   assign     win_trap_e = rml_ecl_fill_e | exu_tlu_spill_e | rml_ecl_clean_window_e;
   dff_s win_trap_e2m(.din(win_trap_e), .clk(clk), .q(win_trap_m), .se(se), .si(), .so());
   dff_s win_trap_m2w(.din(win_trap_m), .clk(clk), .q(win_trap_w), .se(se), .si(), .so());
   
   assign canrestore_is0_e = (~rml_ecl_canrestore_e[0] & ~rml_ecl_canrestore_e[1] 
                              & ~rml_ecl_canrestore_e[2]);
   assign cansave_is0_e = (~rml_ecl_cansave_e[0] & ~rml_ecl_cansave_e[1] & 
                           ~rml_ecl_cansave_e[2]);
   assign otherwin_is0_e = ~rml_ecl_other_e;

   ///////////////////////////////////////
   // Signals that operations are done
   // restore/return is not signalled here
   // because it depends on the write to the
   // irf (computed in ecl_wb)
   ////////////////////////////////////////
   assign rml_ecl_rmlop_done_e = (ifu_exu_saved_e | ifu_exu_restored_e |
                                  (ifu_exu_flushw_e & ~spill_trap_flush));
   
   //////////////////////////
   // Trap generation
   //////////////////////////
   // Fill trap generated on restore and canrestore == 0
   assign rml_ecl_fill_e = restore_e & canrestore_is0_e; 
   
   // Spill trap on save with cansave == 0
   assign spill_trap_save = save_e & cansave_is0_e;
   assign exu_ifu_spill_e = spill_trap_save;
   // Spill trap on wflush with cansave != (NWINDOWS - 2 = 6)
   assign spill_trap_flush = (ifu_exu_flushw_e & ~(rml_ecl_cansave_e[2] &
                                                 rml_ecl_cansave_e[1] & 
                                                 ~rml_ecl_cansave_e[0]));
   assign exu_tlu_spill_e = (spill_trap_save | spill_trap_flush);
   dff_s spill_e2m(.din(exu_tlu_spill_e), .clk(clk), .q(spill_m), .se(se), .si(), .so());

   // Clean window trap on save w/ cleanwin - canrestore == 0
   // or cleanwin == canrestore
   // (not signalled on spill traps because spill is higher priority)
   assign cleanwin_xor_canrestore = rml_ecl_cleanwin_e ^ rml_ecl_canrestore_e;
   assign rml_ecl_clean_window_e = ~(cleanwin_xor_canrestore[2] |
                                cleanwin_xor_canrestore[1] |
                                cleanwin_xor_canrestore[0]) & save_e & ~exu_tlu_spill_e;

   // Kill signal for w1 wen bit (all others don't care)
   assign rml_ecl_kill_e = rml_ecl_fill_e | exu_tlu_spill_e;
   dff_s rml_kill_e2m(.din(rml_ecl_kill_e), .clk(clk), .q(rml_ecl_kill_m),
                    .se(se), .si(), .so());
   

   // WTYPE generation
   assign rml_ecl_other_d = (rml_ecl_otherwin_d[0] | rml_ecl_otherwin_d[1] 
                            | rml_ecl_otherwin_d[2]);
   dff_s other_d2e(.din(rml_ecl_other_d), .clk(clk), .q(rml_ecl_other_e), .se(se),
                 .si(), .so());
   mux2ds #(3) wtype_mux(.dout(rml_ecl_wtype_d[2:0]),
                          .in0(rml_ecl_wstate_d[2:0]),
                          .in1(rml_ecl_wstate_d[5:3]),
                          .sel0(~rml_ecl_other_d),
                          .sel1(rml_ecl_other_d));
   dff_s #(3) wtype_d2e(.din(rml_ecl_wtype_d[2:0]), .clk(clk), .q(rml_ecl_wtype_e[2:0]),
                    .se(se), .si(), .so());


   ////////////////////////////
   // Interface with IRF
   ////////////////////////////
   assign rml_irf_old_lo_cwp_e[2:0] = old_cwp_e[2:0];
   assign rml_irf_new_lo_cwp_e[2:0] = new_cwp_e[2:0];
   assign rml_irf_old_e_cwp_e[1:0] = (old_cwp_e[0])? old_cwp_e[2:1] + 2'b01: old_cwp_e[2:1];
   assign rml_irf_new_e_cwp_e[1:0] = (new_cwp_e[0])? new_cwp_e[2:1] + 2'b01: new_cwp_e[2:1];
   
   assign rml_irf_swap_local_e = (swap_e | swap_locals_ins);
   assign rml_irf_swap_odd_e = ((save_e | ecl_rml_cwp_wen_e | spill_trap_flush | swap_locals_ins) & old_cwp_e[0]) | 
                                 ((restore_e | swap_outs) & ~old_cwp_e[0]);
   assign rml_irf_swap_even_e = ((save_e | ecl_rml_cwp_wen_e | spill_trap_flush | swap_locals_ins) & ~old_cwp_e[0]) |
                                  ((restore_e | swap_outs) & old_cwp_e[0]);

   assign swap_e = save_e | restore_e | ecl_rml_cwp_wen_e | spill_trap_flush;
   dff_s dff_did_restore_e2m(.din(swap_e), .clk(clk),
                       .q(did_restore_m), .se(se),
                       .si(), .so());
   dff_s dff_did_restore_m2w(.din(did_restore_m), .clk(clk),
                       .q(did_restore_w), .se(se),
                       .si(), .so());
   // kill restore on all saves (except those that spill) and any swaps that
   // get kill signals
   assign kill_restore_m = (~spill_m & save_m);
   dff_s dff_kill_restore_m2w(.din(kill_restore_m), .clk(clk), .q(kill_restore_w),
                            .se(se), .si(), .so());
   assign rml_irf_kill_restore_w = kill_restore_w | (did_restore_w & rml_kill_w);


   ///////////////////////////////
   // CWP logic
   ///////////////////////////////
   // Logic to compute next_cwp on spill trap.
   //  CWP = CWP + CANSAVE + 2
   assign spill_cwp_e[0] = rml_ecl_cwp_e[0] ^ rml_ecl_cansave_e[0];
   assign spill_cwp_carry0 = rml_ecl_cwp_e[0] & rml_ecl_cansave_e[0];
   assign spill_cwp_e[1] = rml_ecl_cwp_e[1] ^ rml_ecl_cansave_e[1] ^ ~spill_cwp_carry0;
   assign spill_cwp_carry1 = (rml_ecl_cwp_e[1] | rml_ecl_cansave_e[1] |
                              spill_cwp_carry0) & ~(rml_ecl_cwp_e[1] &
                                                    rml_ecl_cansave_e[1] &
                                                    spill_cwp_carry0);
   assign spill_cwp_e[2] = rml_ecl_cwp_e[2] ^ rml_ecl_cansave_e[2] ^ spill_cwp_carry1;

   assign rml_cwp_wen_e = (save_e | restore_e) & ~exu_tlu_spill_e;
   assign cwp_wen_e = (rml_cwp_wen_e | ecl_rml_cwp_wen_e) & ~ecl_rml_kill_e;
   sparc_exu_rml_inc3 cwp_inc(.dout(rml_next_cwp_e[2:0]), .din(rml_ecl_cwp_e[2:0]),
                                  .inc(save_e));

   assign     next_cwp_sel_inc = ~(ecl_rml_cwp_wen_e | exu_tlu_spill_e);
   mux3ds #(3) next_cwp_mux(.dout(next_cwp_e[2:0]), 
                          .in0(rml_next_cwp_e[2:0]),
                          .in1(ecl_rml_xor_data_e[2:0]),
                          .in2(spill_cwp_e[2:0]),
                          .sel0(next_cwp_sel_inc),
                          .sel1(ecl_rml_cwp_wen_e),
                          .sel2(exu_tlu_spill_e));

   dff_s cwp_wen_e2m(.din(cwp_wen_e), .clk(clk), .q(rml_cwp_wen_m),
                       .se(se), .si(), .so());
   dff_s #(3) next_cwp_e2m(.din(next_cwp_e[2:0]), .clk(clk), .q(next_cwp_m[2:0]),
                           .se(se), .si(), .so());
   assign     cwp_wen_m = rml_cwp_wen_m;
   dff_s #(3) next_cwp_m2w(.din(next_cwp_m[2:0]), .clk(clk), .q(next_cwp_noreset_w[2:0]),
                         .se(se), .si(), .so());
   dff_s cwp_wen_m2w(.din(cwp_wen_m), .clk(clk), .q(cwp_wen_nokill_w),
                       .se(se), .si(), .so());
   assign cwp_wen_w = cwp_wen_nokill_w & ~rml_kill_w;
   assign next_cwp_w[2:0] = next_cwp_noreset_w[2:0];

   assign full_swap_e = (exu_tlu_spill_e | ecl_rml_cwp_wen_e);


   // oddwin signal for ifu needs bypass from w.  It is done in M and staged for timing.
   // This is possible because the thread is switched out so there is only one bypass condition.
   // Only save/return will switch in fast enough for a bypass so this is the only write condition
   // we need to check
   wire [3:0] oddwin_m;
   wire [3:0] oddwin_w;
   assign     oddwin_m[3] = (cwp_wen_m & ecl_rml_thr_m[3])? next_cwp_m[0]: oddwin_w[3];
   assign     oddwin_m[2] = (cwp_wen_m & ecl_rml_thr_m[2])? next_cwp_m[0]: oddwin_w[2];
   assign     oddwin_m[1] = (cwp_wen_m & ecl_rml_thr_m[1])? next_cwp_m[0]: oddwin_w[1];
   assign     oddwin_m[0] = (cwp_wen_m & ecl_rml_thr_m[0])? next_cwp_m[0]: oddwin_w[0];
   dff_s #(4) oddwin_dff(.din(oddwin_m[3:0]), .clk(clk), .q(exu_ifu_oddwin_s[3:0]),
                       .se(se), .si(), .so());

   sparc_exu_rml_cwp cwp(
                         .swap_outs     (swap_outs),
                         .swap_locals_ins(swap_locals_ins),
                         .rml_ecl_cwp_e (rml_ecl_cwp_e[2:0]),
                         .old_cwp_e     (old_cwp_e[2:0]),
                         .new_cwp_e     (new_cwp_e[2:0]),
                         .oddwin_w     (oddwin_w[3:0]),
                         /*AUTOINST*/
                         // Outputs
                         .rml_ecl_cwp_d (rml_ecl_cwp_d[2:0]),
                         .exu_tlu_cwp0_w(exu_tlu_cwp0_w[2:0]),
                         .exu_tlu_cwp1_w(exu_tlu_cwp1_w[2:0]),
                         .exu_tlu_cwp2_w(exu_tlu_cwp2_w[2:0]),
                         .exu_tlu_cwp3_w(exu_tlu_cwp3_w[2:0]),
                         .rml_irf_cwpswap_tid_e(rml_irf_cwpswap_tid_e[1:0]),
                         .exu_tlu_spill (exu_tlu_spill),
                         .exu_tlu_spill_wtype(exu_tlu_spill_wtype[2:0]),
                         .exu_tlu_spill_other(exu_tlu_spill_other),
                         .exu_tlu_spill_tid(exu_tlu_spill_tid[1:0]),
                         .rml_ecl_swap_done(rml_ecl_swap_done[3:0]),
                         .exu_tlu_cwp_cmplt(exu_tlu_cwp_cmplt),
                         .exu_tlu_cwp_cmplt_tid(exu_tlu_cwp_cmplt_tid[1:0]),
                         .exu_tlu_cwp_retry(exu_tlu_cwp_retry),
                         // Inputs
                         .clk           (clk),
                         .se            (se),
                         .reset         (reset),
                         .rst_tri_en    (rst_tri_en),
                         .rml_ecl_wtype_e(rml_ecl_wtype_e[2:0]),
                         .rml_ecl_other_e(rml_ecl_other_e),
                         .exu_tlu_spill_e(exu_tlu_spill_e),
                         .tlu_exu_cwpccr_update_m(tlu_exu_cwpccr_update_m),
                         .tlu_exu_cwp_retry_m(tlu_exu_cwp_retry_m),
                         .tlu_exu_cwp_m (tlu_exu_cwp_m[2:0]),
                         .thr_d         (thr_d[3:0]),
                         .ecl_rml_thr_m (ecl_rml_thr_m[3:0]),
                         .ecl_rml_thr_w (ecl_rml_thr_w[3:0]),
                         .tid_e         (tid_e[1:0]),
                         .next_cwp_w    (next_cwp_w[2:0]),
                         .next_cwp_e    (next_cwp_e[2:0]),
                         .cwp_wen_w     (cwp_wen_w),
                         .save_e        (save_e),
                         .restore_e     (restore_e),
                         .ifu_exu_flushw_e(ifu_exu_flushw_e),
                         .ecl_rml_cwp_wen_e(ecl_rml_cwp_wen_e),
                         .full_swap_e   (full_swap_e),
                         .rml_kill_w    (rml_kill_w));

   ///////////////////////////////
   // Cansave logic
   ///////////////////////////////
   assign cansave_wen_e = ((save_e & ~cansave_is0_e & ~rml_ecl_clean_window_e) |
                           ifu_exu_saved_e |
                           (restore_e & ~canrestore_is0_e) |
                           (ifu_exu_restored_e & otherwin_is0_e));
   sparc_exu_rml_inc3 cansave_inc(.dout(rml_next_cansave_e[2:0]), .din(rml_ecl_cansave_e[2:0]),
                                  .inc(cansave_inc_e));
   assign cansave_inc_e = restore_e | ifu_exu_saved_e;

   mux2ds #(3) next_cansave_mux(.dout(next_cansave_e[2:0]),
                              .in0(ecl_rml_xor_data_e[2:0]),
                              .in1(rml_next_cansave_e[2:0]),
                              .sel0(~cansave_wen_e),
                              .sel1(cansave_wen_e));
   dff_s cansave_wen_e2m(.din(cansave_wen_e), .clk(clk), .q(cansave_wen_m),
                       .se(se), .si(), .so());
   dff_s #(3) next_cansave_e2m(.din(next_cansave_e[2:0]), .clk(clk), .q(next_cansave_m[2:0]),
                           .se(se), .si(), .so());
   assign cansave_wen_valid_m = cansave_wen_m;
   dff_s cansave_wen_m2w(.din(cansave_wen_valid_m), .clk(clk), .q(rml_cansave_wen_w),
                       .se(se), .si(), .so());
   dff_s #(3) next_cansave_m2w(.din(next_cansave_m[2:0]), .clk(clk), .q(next_cansave_w[2:0]),
                           .se(se), .si(), .so());
   assign cansave_wen_w = (rml_cansave_wen_w | ecl_rml_cansave_wen_w) & ~rml_kill_w;

   ///////////////////////////////
   // Canrestore logic
   ///////////////////////////////
   assign canrestore_wen_e = ((save_e & ~cansave_is0_e & ~rml_ecl_clean_window_e) |
                              ifu_exu_restored_e |
                              (restore_e & ~canrestore_is0_e) |
                              (ifu_exu_saved_e & otherwin_is0_e));
   sparc_exu_rml_inc3 canrestore_inc(.dout(rml_next_canrestore_e[2:0]),
                                     .din(rml_ecl_canrestore_e[2:0]),
                                     .inc(canrestore_inc_e));
   assign canrestore_inc_e = ifu_exu_restored_e | save_e;
   
   mux2ds #(3) next_canrestore_mux(.dout(next_canrestore_e[2:0]),
                                    .in0(ecl_rml_xor_data_e[2:0]),
                                    .in1(rml_next_canrestore_e[2:0]),
                                    .sel0(~canrestore_wen_e),
                                    .sel1(canrestore_wen_e));
   dff_s canrestore_wen_e2m(.din(canrestore_wen_e), .clk(clk), .q(canrestore_wen_m),
                       .se(se), .si(), .so());
   dff_s #(3) next_canrestore_e2m(.din(next_canrestore_e[2:0]), .clk(clk), .q(next_canrestore_m[2:0]),
                           .se(se), .si(), .so());
   assign canrestore_wen_valid_m = canrestore_wen_m;
   dff_s canrestore_wen_m2w(.din(canrestore_wen_valid_m), .clk(clk), .q(rml_canrestore_wen_w),
                       .se(se), .si(), .so());
   dff_s #(3) next_canrestore_m2w(.din(next_canrestore_m[2:0]), .clk(clk), .q(next_canrestore_w[2:0]),
                           .se(se), .si(), .so());
   assign canrestore_wen_w = (rml_canrestore_wen_w | ecl_rml_canrestore_wen_w) & ~rml_kill_w;

   ///////////////////////////////
   // Otherwin logic
   ///////////////////////////////
   // Decrements on saved or restored if otherwin != 0
   assign otherwin_wen_e = ((ifu_exu_saved_e | ifu_exu_restored_e) 
                            & ~otherwin_is0_e);
   assign rml_next_otherwin_e[2] = ((rml_ecl_otherwin_e[2] & rml_ecl_otherwin_e[1]) |
                                (rml_ecl_otherwin_e[2] & rml_ecl_otherwin_e[0]));
   assign rml_next_otherwin_e[1] = rml_ecl_otherwin_e[1] ^ ~rml_ecl_otherwin_e[0];
   assign rml_next_otherwin_e[0] = ~rml_ecl_otherwin_e[0];

   mux2ds #(3) next_otherwin_mux(.dout(next_otherwin_e[2:0]),
                               .in0(ecl_rml_xor_data_e[2:0]),
                               .in1(rml_next_otherwin_e[2:0]),
                               .sel0(~otherwin_wen_e),
                               .sel1(otherwin_wen_e));
   dff_s otherwin_wen_e2m(.din(otherwin_wen_e), .clk(clk), .q(otherwin_wen_m),
                       .se(se), .si(), .so());
   dff_s #(3) next_otherwin_e2m(.din(next_otherwin_e[2:0]), .clk(clk), .q(next_otherwin_m[2:0]),
                           .se(se), .si(), .so());
   assign otherwin_wen_valid_m = otherwin_wen_m;
   dff_s otherwin_wen_m2w(.din(otherwin_wen_valid_m), .clk(clk), .q(rml_otherwin_wen_w),
                       .se(se), .si(), .so());
   dff_s #(3) next_otherwin_m2w(.din(next_otherwin_m[2:0]), .clk(clk), .q(next_otherwin_w[2:0]),
                           .se(se), .si(), .so());
   assign otherwin_wen_w = (rml_otherwin_wen_w | ecl_rml_otherwin_wen_w) & ~rml_kill_w;

   ///////////////////////////////
   // Cleanwin logic
   ///////////////////////////////
   // increments on restored if cleanwin != 7
   assign cleanwin_wen_e = (ifu_exu_restored_e &
                            ~(rml_ecl_cleanwin_e[2] & rml_ecl_cleanwin_e[1] 
                              & rml_ecl_cleanwin_e[0]));
   assign rml_next_cleanwin_e[2] = ((~rml_ecl_cleanwin_e[2] & rml_ecl_cleanwin_e[1] 
                                 & rml_ecl_cleanwin_e[0]) | rml_ecl_cleanwin_e[2]);
   assign rml_next_cleanwin_e[1] = rml_ecl_cleanwin_e[1] ^ rml_ecl_cleanwin_e[0];
   assign rml_next_cleanwin_e[0] = ~rml_ecl_cleanwin_e[0];
   
   mux2ds #(3) next_cleanwin_mux(.dout(next_cleanwin_e[2:0]),
                                  .in0(ecl_rml_xor_data_e[2:0]),
                                  .in1(rml_next_cleanwin_e[2:0]),
                                  .sel0(~cleanwin_wen_e),
                                  .sel1(cleanwin_wen_e));
   dff_s cleanwin_wen_e2m(.din(cleanwin_wen_e), .clk(clk), .q(cleanwin_wen_m),
                       .se(se), .si(), .so());
   dff_s #(3) next_cleanwin_e2m(.din(next_cleanwin_e[2:0]), .clk(clk), .q(next_cleanwin_m[2:0]),
                           .se(se), .si(), .so());
   assign cleanwin_wen_valid_m = cleanwin_wen_m;
   dff_s cleanwin_wen_m2w(.din(cleanwin_wen_valid_m), .clk(clk), .q(rml_cleanwin_wen_w),
                       .se(se), .si(), .so());
   dff_s #(3) next_cleanwin_m2w(.din(next_cleanwin_m[2:0]), .clk(clk), .q(next_cleanwin_w[2:0]),
                           .se(se), .si(), .so());
   assign cleanwin_wen_w = (rml_cleanwin_wen_w | ecl_rml_cleanwin_wen_w) & ~rml_kill_w;

   ///////////////////////////////
   // WSTATE logic
   ///////////////////////////////
   assign wstate_wen_w = ecl_rml_wstate_wen_w & ~rml_kill_w;

   ///////////////////////////////
   // Storage of other WMRs
   ///////////////////////////////
   sparc_exu_reg  cansave_reg(.clk(clk), .se(se),
                                .data_out(rml_ecl_cansave_d[2:0]), .thr_out(thr_d[3:0]), 
                                .thr_w(ecl_rml_thr_w[3:0]),
                              .wen_w(cansave_wen_w), .data_in_w(next_cansave_w[2:0]));
   dff_s #(3) cansave_d2e(.din(rml_ecl_cansave_d[2:0]), .clk(clk), .q(rml_ecl_cansave_e[2:0]), .se(se),
                  .si(), .so());
   sparc_exu_reg  canrestore_reg(.clk(clk), .se(se),
                                   .data_out(rml_ecl_canrestore_d[2:0]), .thr_out(thr_d[3:0]),
                                   .thr_w(ecl_rml_thr_w[3:0]),
                                   .wen_w(canrestore_wen_w),
                                   .data_in_w(next_canrestore_w[2:0]));
   dff_s #(3) canrestore_d2e(.din(rml_ecl_canrestore_d[2:0]), .clk(clk), .q(rml_ecl_canrestore_e[2:0]),
                         .se(se), .si(), .so());
   sparc_exu_reg  otherwin_reg(.clk(clk), .se(se),
                                 .data_out(rml_ecl_otherwin_d[2:0]), .thr_out(thr_d[3:0]),
                                 .thr_w(ecl_rml_thr_w[3:0]),
                                 .wen_w(otherwin_wen_w), .data_in_w(next_otherwin_w[2:0]));
   dff_s #(3) otherwin_d2e(.din(rml_ecl_otherwin_d[2:0]), .clk(clk), .q(rml_ecl_otherwin_e[2:0]),
                       .se(se), .si(), .so());
   sparc_exu_reg  cleanwin_reg(.clk(clk), .se(se),
                                 .data_out(rml_ecl_cleanwin_d[2:0]), .thr_out(thr_d[3:0]),
                                 .thr_w(ecl_rml_thr_w[3:0]),
                                 .wen_w(cleanwin_wen_w), .data_in_w(next_cleanwin_w[2:0]));
   dff_s #(3) cleanwin_d2e(.din(rml_ecl_cleanwin_d[2:0]), .clk(clk), .q(rml_ecl_cleanwin_e[2:0]),
                       .se(se), .si(), .so());
   sparc_exu_reg hi_wstate_reg(.clk(clk), .se(se),
                               .data_out(rml_ecl_wstate_d[5:3]), .thr_out(thr_d[3:0]),
                               .thr_w(ecl_rml_thr_w[3:0]),
                               .wen_w(wstate_wen_w), 
                               .data_in_w(exu_tlu_wsr_data_w[5:3]));
   sparc_exu_reg lo_wstate_reg(.clk(clk), .se(se),
                               .data_out(rml_ecl_wstate_d[2:0]), .thr_out(thr_d[3:0]),
                               .thr_w(ecl_rml_thr_w[3:0]),
                               .wen_w(wstate_wen_w), 
                               .data_in_w(exu_tlu_wsr_data_w[2:0]));


   /////////////////////////////////
   // Alternate Globals control
   //----------------------------
   /////////////////////////////////
   assign rml_irf_new_agp[1:0] = tlu_exu_agp[1:0];
   assign agp_tid[1:0] = tlu_exu_agp_tid[1:0];

`ifdef FPGA_SYN_1THREAD
   assign rml_irf_old_agp[1:0] = agp_thr0[1:0];
   assign        agp_wen_thr0_w = (agp_thr[0] & agp_wen) | reset;   
   // mux between new and current value
   mux2ds #(2) agp_next0_mux(.dout(agp_thr0_next[1:0]),
                               .in0(agp_thr0[1:0]),
                               .in1(new_agp[1:0]),
                               .sel0(~agp_wen_thr0_w),
                               .sel1(agp_wen_thr0_w));
   dff_s #(2) dff_agp_thr0(.din(agp_thr0_next[1:0]), .clk(clk), .q(agp_thr0[1:0]),
                       .se(se), .si(), .so());
   // generation of controls
   assign        agp_wen = tlu_exu_agp_swap;
   assign        rml_irf_swap_global = agp_wen;
   assign        rml_irf_global_tid[1:0] = agp_tid[1:0];

   // decode tids
   assign        agp_thr[0] = ~agp_tid[1] & ~agp_tid[0];
      // Decode agp input
   assign new_agp[1:0] = rml_irf_new_agp[1:0] | {2{reset}};

   // send current global level to ecl for error logging
   assign rml_ecl_gl_e[1:0] = agp_thr0[1:0];
   
`else
	   
   //  Output selection for current agp
   mux4ds #(2) mux_agp_out1(.dout(rml_irf_old_agp[1:0]), 
                            .sel0(agp_thr[0]),
                            .sel1(agp_thr[1]),
                            .sel2(agp_thr[2]),
                            .sel3(agp_thr[3]),
                            .in0(agp_thr0[1:0]),
                            .in1(agp_thr1[1:0]),
                            .in2(agp_thr2[1:0]),
                            .in3(agp_thr3[1:0]));

   //////////////////////////////////////
   //  Storage of agp
   //////////////////////////////////////
   
   // enable input for each thread
   assign        agp_wen_thr0_w = (agp_thr[0] & agp_wen) | reset;
   assign        agp_wen_thr1_w = (agp_thr[1] & agp_wen) | reset;
   assign        agp_wen_thr2_w = (agp_thr[2] & agp_wen) | reset;
   assign        agp_wen_thr3_w = (agp_thr[3] & agp_wen) | reset;

   // mux between new and current value
   mux2ds #(2) agp_next0_mux(.dout(agp_thr0_next[1:0]),
                               .in0(agp_thr0[1:0]),
                               .in1(new_agp[1:0]),
                               .sel0(~agp_wen_thr0_w),
                               .sel1(agp_wen_thr0_w));
   mux2ds #(2) agp_next1_mux(.dout(agp_thr1_next[1:0]),
                               .in0(agp_thr1[1:0]),
                               .in1(new_agp[1:0]),
                               .sel0(~agp_wen_thr1_w),
                               .sel1(agp_wen_thr1_w));
   mux2ds #(2) agp_next2_mux(.dout(agp_thr2_next[1:0]),
                               .in0(agp_thr2[1:0]),
                               .in1(new_agp[1:0]),
                               .sel0(~agp_wen_thr2_w),
                               .sel1(agp_wen_thr2_w));
   mux2ds #(2) agp_next3_mux(.dout(agp_thr3_next[1:0]),
                               .in0(agp_thr3[1:0]),
                               .in1(new_agp[1:0]),
                               .sel0(~agp_wen_thr3_w),
                               .sel1(agp_wen_thr3_w));

   // store new value
   dff_s #(2) dff_agp_thr0(.din(agp_thr0_next[1:0]), .clk(clk), .q(agp_thr0[1:0]),
                       .se(se), .si(), .so());
   dff_s #(2) dff_agp_thr1(.din(agp_thr1_next[1:0]), .clk(clk), .q(agp_thr1[1:0]),
                       .se(se), .si(), .so());
   dff_s #(2) dff_agp_thr2(.din(agp_thr2_next[1:0]), .clk(clk), .q(agp_thr2[1:0]),
                       .se(se), .si(), .so());
   dff_s #(2) dff_agp_thr3(.din(agp_thr3_next[1:0]), .clk(clk), .q(agp_thr3[1:0]),
                       .se(se), .si(), .so());
   
   // generation of controls
   assign        agp_wen = tlu_exu_agp_swap;
   assign        rml_irf_swap_global = agp_wen;
   assign        rml_irf_global_tid[1:0] = agp_tid[1:0];

   // decode tids
   assign        agp_thr[0] = ~agp_tid[1] & ~agp_tid[0];
   assign        agp_thr[1] = ~agp_tid[1] & agp_tid[0];
   assign        agp_thr[2] = agp_tid[1] & ~agp_tid[0];
   assign        agp_thr[3] = agp_tid[1] & agp_tid[0];
   
   // Decode agp input
   assign new_agp[1:0] = rml_irf_new_agp[1:0] | {2{reset}};

   // send current global level to ecl for error logging
   assign rml_ecl_gl_e[1:0] = ((tid_e[1:0] == 2'b00)? agp_thr0[1:0]:
                               (tid_e[1:0] == 2'b01)? agp_thr1[1:0]:
                               (tid_e[1:0] == 2'b10)? agp_thr2[1:0]:
                                                              agp_thr3[1:0]);
`endif // !`ifdef FPGA_SYN_1THREAD
   
endmodule // sparc_exu_rml
