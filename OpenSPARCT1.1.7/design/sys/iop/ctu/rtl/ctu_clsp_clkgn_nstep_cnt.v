// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: ctu_clsp_clkgn_nstep_cnt.v
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
//
//    Cluster Name:  CTU
//    Unit Name: ctu_clsp_clkgn_nstep_cnt
//
//-----------------------------------------------------------------------------
`include "sys.h"

module ctu_clsp_clkgn_nstep_cnt(/*AUTOARG*/
// Outputs
nstep_sel, 
// Inputs
io_pwron_rst_l, clk, jtag_clock_dr, jtag_nstep_count, 
jtag_nstep_domain, jtag_nstep_vld, capture_l, testmode_l, 
start_clk_early_jl, shadreg_div_mult, force_cken
);

  

   // global inputs

   input io_pwron_rst_l;
   input clk;
   input jtag_clock_dr;
   input [3:0] jtag_nstep_count;
   input jtag_nstep_domain;
   input jtag_nstep_vld;
   input capture_l;
   input testmode_l;
   input start_clk_early_jl;
   input [13:0] shadreg_div_mult;
   input force_cken;
   output nstep_sel;

   wire cnt_ld_sync;
   wire cnt_ld_sync_dly_l;
   wire cnt_ld_1sht;
   wire [3:0] nstep_init_cnt_nxt;
   wire [3:0] nstep_init_cnt;
   wire [3:0] nstep_cnt_nxt;
   wire [3:0] nstep_cnt;
   wire [3:0] nstep_cnt_minus_1;
   wire trigger_sync;
   wire nstep_start;
   wire nstep_start_1sht;
   wire nstep_start_1sht_dly;
   wire nstep_start_dly;
   wire nstep_start_dly1;
   wire nstep_start_nxt;
   wire nstep_en_nxt;
   wire nstep_active;
   wire coin_edge_nxt;
   wire nstep_sel_pre;


   wire cnt_ld;
   wire cnt_ld_nxt;
   wire [13:0] lcm_cnt_minus_1;
   wire [13:0] lcm_cnt_nxt;
   wire [13:0] lcm_cnt;
   wire coin_edge;
   wire force_cken_l;


   // -----------------------------------------------
   // 
   // Synchronizers
   // 
   // -----------------------------------------------

   // tck -> clk

    //assign  nstep_active = jtag_clock_dr & ~capture_l ;
    // to get rid of comb. logic

    dffrl_async_ns  u_nstep_active_nsr(
                           .din (~capture_l),
                           .rst_l(io_pwron_rst_l),
                           .clk (jtag_clock_dr),
                           .q (nstep_active));

    ctu_synchronizer u_jtag_nstep_vld_nsr(
             .presyncdata(jtag_nstep_vld),
             .syncdata (cnt_ld_sync),
             .clk(clk)
              );

    ctu_synchronizer u_jtag_trigger_nsr(
             .presyncdata(nstep_active),
             .syncdata (trigger_sync),
             .clk(clk)
              );


   // -----------------------------------------------
   // 
   //  Synchronization checks
   // 
   // -----------------------------------------------

    // start the clock relative to coincident edge

    assign nstep_start_nxt =  coin_edge? trigger_sync: nstep_start; 

    dffrl_async_ns  u_nstep_start_nsr(
                           .din (nstep_start_nxt),
                           .rst_l(io_pwron_rst_l),
                           .clk (clk),
                           .q (nstep_start));
    dff_ns  u_nstep_start_dly_nsr(
                           .din (nstep_start),
                           .clk (clk),
                           .q (nstep_start_dly));

    assign nstep_start_1sht = nstep_start & ~nstep_start_dly  ;

    dff_ns  u_nstep_start_dly1_nsr(
                           .din (nstep_start_dly),
                           .clk (clk),
                           .q (nstep_start_dly1));

    assign nstep_start_1sht_dly = nstep_start_dly & ~nstep_start_dly1 ;




   // -----------------------------------------------
   // 
   //   nstep_cnt
   // 
   // -----------------------------------------------

    dff_ns  u_cnt_ld_sync_nsr(
                         .din (~cnt_ld_sync),
                         .clk (clk),
                         .q(cnt_ld_sync_dly_l));

    assign cnt_ld_1sht = cnt_ld_sync & cnt_ld_sync_dly_l;

    // jtag_nstep_domain and jtag_nstep_count must hold for 3 cycles min.

    assign nstep_init_cnt_nxt = cnt_ld_1sht &  jtag_nstep_domain ?  jtag_nstep_count:
                                 nstep_init_cnt;

     dffrl_async_ns #(4) u_nstep_init_cnt_nsr(
                         .din (nstep_init_cnt_nxt),
                         .clk (clk),
                         .rst_l(io_pwron_rst_l),
                         .q(nstep_init_cnt));

     // nstep =1 , nstep > 0 ;  nstep =  15

     assign nstep_en_nxt =  ((nstep_init_cnt == 4'b0001) & nstep_start_1sht_dly)  | // delay start if cnt == 1
                              (|(nstep_cnt[3:1]))      // when cnt >=  1
                           |  (&(nstep_init_cnt[3:0]));  // always enable if count == 15

     dffrl_async_ns  u_nstep_en_nsr(
                         .din (nstep_en_nxt),
                         .clk (clk),
                         .rst_l(io_pwron_rst_l),
                         .q(nstep_sel_pre));
 
     //assign nstep_sel = nstep_sel_pre & testmode_l;

     ctu_inv  u_force_cken_l(.a (force_cken), .z(force_cken_l));
     ctu_and3  u_nstep_sel (.a (nstep_sel_pre), .b(force_cken_l), .c(testmode_l), .z(nstep_sel));

     


    // clock gating is done in clksw block
    //ctu_and2 u_nstep_clk_gated (.a (clk), .b(nstep_en), .z(nstep_clk));


     assign nstep_cnt_minus_1  = nstep_cnt - 4'b0001;

     assign nstep_cnt_nxt = nstep_start_1sht  ? nstep_init_cnt :
                            nstep_sel & (|(nstep_init_cnt[3:0]))  ? nstep_cnt_minus_1:
                            nstep_cnt;

     dffrl_async_ns #(4) u_nstep_cnt_nsr(
                         .din (nstep_cnt_nxt),
                         .clk (clk),
                         .rst_l(io_pwron_rst_l),
                         .q(nstep_cnt));

   // -----------------------------------------------
   // 
   //  lcm cnt for repeatability
   //  start nstep clock relative to coincident edge
   // 
   // -----------------------------------------------

    assign cnt_ld_nxt  =  cnt_ld ? 1'b0: cnt_ld;

    dffsl_async_ns  u_cnt_ld_nsr(
                   .din (cnt_ld_nxt),
                   .clk (clk),
                   .set_l (start_clk_early_jl),
                   .q(cnt_ld));

    assign lcm_cnt_minus_1 = lcm_cnt - 14'h0001;

    assign lcm_cnt_nxt =  cnt_ld? shadreg_div_mult[13:0]:
                          (|(lcm_cnt[13:1])) ?   lcm_cnt_minus_1: 
                          shadreg_div_mult[13:0];

    dffrl_async_ns #(14) u_lcm_ff_nsr (
                   .din (lcm_cnt_nxt),
                   .clk (clk),
                   .rst_l (start_clk_early_jl),
                   .q(lcm_cnt));

    assign coin_edge_nxt =  (lcm_cnt[13:0] == 14'd3) ;

    dff_ns  u_start_clk_edge_nsr(
                           .din (coin_edge_nxt),
                           .clk (clk),
                           .q (coin_edge));

   // -----------------------------------------------
   // 
   //  Synchronization checks
   // 
   // -----------------------------------------------

    //synopsys translate_off

        // values of jtag_nstep_domain & jtag_nstep_count should remain unchanged
        // for at least 3 clocks

        reg  prev_jtag_nstep_domain;
        reg  [3:0]  prev_jtag_nstep_count;

        always @(posedge jtag_nstep_vld)
        begin
            prev_jtag_nstep_domain <= jtag_nstep_domain;
            prev_jtag_nstep_count  <= jtag_nstep_count;
            @(posedge clk)
            begin
              if(  `CTU_PATH.start_clk_jl & 
                  (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                  (prev_jtag_nstep_domain !== jtag_nstep_domain) &
                  (`CTU_PATH.io_trst_l === 1'b1))
		`ifdef MODELSIM
              $display ( "CTU_sync_check_error", "jtag_nstep_domain should hold for at least 3 cycles");
		`else	  
              $error ( "CTU_sync_check_error", "jtag_nstep_domain should hold for at least 3 cycles");
		`endif
              if(  `CTU_PATH.start_clk_jl & 
                  (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                 ( prev_jtag_nstep_count !== jtag_nstep_count) &
                  (`CTU_PATH.io_trst_l === 1'b1))
		`ifdef MODELSIM	  
              $display ( "CTU_sync_check_error", "jtag_nstep_count should hold for at least 3 cycles");
		`else	  
              $error ( "CTU_sync_check_error", "jtag_nstep_count should hold for at least 3 cycles");
		`endif
            end
            @(posedge clk)
            begin
              if(  `CTU_PATH.start_clk_jl & 
                  (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                  (prev_jtag_nstep_domain !== jtag_nstep_domain) &
                  (`CTU_PATH.io_trst_l === 1'b1))
		`ifdef MODELSIM	  
              $display ( "CTU_sync_check_error", "jtag_nstep_domain should hold for at least 3 cycles");
		`else	  
              $error ( "CTU_sync_check_error", "jtag_nstep_domain should hold for at least 3 cycles");
		`endif
              if(  `CTU_PATH.start_clk_jl & 
                  (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                  (prev_jtag_nstep_count !== jtag_nstep_count) &
                  (`CTU_PATH.io_trst_l === 1'b1))
		`ifdef MODELSIM
              $display ( "CTU_sync_check_error", "jtag_nstep_count should hold for at least 3 cycles");
		`else	  	
              $error ( "CTU_sync_check_error", "jtag_nstep_count should hold for at least 3 cycles");
		`endif
            end
            @(posedge clk)
            begin
              if(  `CTU_PATH.start_clk_jl & 
                  (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                   (prev_jtag_nstep_domain !== jtag_nstep_domain) &
                  (`CTU_PATH.io_trst_l === 1'b1))
		`ifdef MODELSIM
              $display ( "CTU_sync_check_error", "jtag_nstep_domain should hold for at least 3 cycles");
		`else	  
              $error ( "CTU_sync_check_error", "jtag_nstep_domain should hold for at least 3 cycles");
		`endif
              if(  `CTU_PATH.start_clk_jl & 
                  (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                  ( prev_jtag_nstep_count !== jtag_nstep_count) &
                  (`CTU_PATH.io_trst_l === 1'b1))
		`ifdef MODELSIM
              $display ( "CTU_sync_check_error", "jtag_nstep_count should hold for at least 3 cycles");
		`else	  
              $error ( "CTU_sync_check_error", "jtag_nstep_count should hold for at least 3 cycles");
		`endif
            end
       end

   //synopsys translate_on


endmodule // ctu_clsp_clkgn_nstep









