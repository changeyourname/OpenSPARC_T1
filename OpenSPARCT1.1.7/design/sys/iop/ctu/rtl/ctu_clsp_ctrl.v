// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: ctu_clsp_ctrl.v
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
//    Unit Name: ctu_clsp_rstctrl
//
//-----------------------------------------------------------------------------

//---------------------------------------------
// reset signal behavior summary:
//---------------------------------------------
//


`include "ctu.h"
module ctu_clsp_ctrl (/*AUTOARG*/
// Outputs
start_clk_jl, start_clk_early_jl, start_2clk_early_jl, 
update_shadow_jl, ctu_dram_selfrsh, de_grst_jl, a_grst_jl, 
dram_a_grst_jl, wrm_rst_ref, wrm_rst_fc_ref, tst_rst_ref, 
ctu_efc_read_start, ctu_iob_wake_thr, creg_cken_vld_jl, ctu_io_j_err, 
ctu_tst_pre_grst_l, ctu_ddr0_iodll_rst_jl_l, ctu_ddr1_iodll_rst_jl_l, 
ctu_ddr2_iodll_rst_jl_l, ctu_ddr3_iodll_rst_jl_l, clsp_bist_dobist, 
clsp_bist_type, clsp_bist_ctrl, rstctrl_disclk_jl, rstctrl_enclk_jl, 
rstctrl_idle_jl, ssiclk_enable, ctu_iob_resetstat_wr, 
ctu_iob_resetstat, 
// Inputs
jbus_clk, io_pwron_rst_l, pll_locked_jl, io_j_rst_l, 
frq_chng_pending_jl, clsp_ctrl_srarm_jl, clkctrl_dn_jl, 
jbus_grst_jl_l, io_do_bist, io_pll_char_in, dft_wake_thr, 
de_dll_rst_dn, ctu_io_j_err_jl, testmode_l, bypclksel, 
jtag_clsp_ignore_wrm_rst
);


   input       jbus_clk;
   input       io_pwron_rst_l;
   input       pll_locked_jl;
   input       io_j_rst_l;
   input       frq_chng_pending_jl; //asserted high when write to freq reg
   input       clsp_ctrl_srarm_jl; //arm dram self refresh
   input       clkctrl_dn_jl;
   input       jbus_grst_jl_l;
   input       io_do_bist;
   input       io_pll_char_in;
   input       dft_wake_thr;
   input       de_dll_rst_dn;
   input       ctu_io_j_err_jl;
   input       testmode_l;
   input       bypclksel;
   input       jtag_clsp_ignore_wrm_rst;

   output      start_clk_jl;
   output      start_clk_early_jl;
   output      start_2clk_early_jl;
   output      update_shadow_jl;
   output      ctu_dram_selfrsh;
   output      de_grst_jl;
   output      a_grst_jl;
   output      dram_a_grst_jl;
   output      wrm_rst_ref;
   output      wrm_rst_fc_ref;
   output      tst_rst_ref;
   output      ctu_efc_read_start;
   output      ctu_iob_wake_thr;
   output      creg_cken_vld_jl;
   output      ctu_io_j_err;

    // resets

   output      ctu_tst_pre_grst_l;
   output      ctu_ddr0_iodll_rst_jl_l;   // deskew reset
   output      ctu_ddr1_iodll_rst_jl_l;   // deskew reset
   output      ctu_ddr2_iodll_rst_jl_l;   // deskew reset
   output      ctu_ddr3_iodll_rst_jl_l;   // deskew reset
   output      clsp_bist_dobist;
  // output      clsp_bist_dobisi;
   output      clsp_bist_type;
   output      [5:0] clsp_bist_ctrl;
   output      rstctrl_disclk_jl;
   output      rstctrl_enclk_jl;
   output      rstctrl_idle_jl;
   output      ssiclk_enable;
  


   // iob status
   output       ctu_iob_resetstat_wr;
   output [2:0] ctu_iob_resetstat;

   parameter    DRAM_GRST_CNT = 12'h640; // 1600 cycles  CTRLSM_DE_GRST 200Mhz
   parameter    EFC_CNT = 13'h1F40;      // 8000 cycles  CTRLSM_DE_GRST 200Mhz
   parameter    BIST_CTRLCNT = 3'b110;
 
   wire wrm_rst_jl;
   wire wrm_rst_fc_jl;
   wire tst_rst_jl;

   wire jtag_clsp_ignore_wrm_rst_jl;
   wire frq_change;
   wire frq_change_nxt;
   wire jbus_grst_jl_l;
   wire j_rst_l;
   wire j_rst_l_dly_l;
   wire j_rst_l_1sht;
   wire j_rst_l_1sht_dly;
   
   
    wire ssiclk_enable_nxt;
    wire pll_char_in_jl;
    wire wrm_rst_nxt;
    wire wrm_rst_fc_nxt;
    wire tst_rst_nxt;


    wire start_clk_cnt_dn;
    wire start_clk_cnt_en;
    wire [3:0] start_clk_cnt_nxt;
    wire [3:0] start_clk_cnt;

    wire dram_grst_cnt_dn;
    wire dram_grst_cnt_en;
    wire [11:0] dram_grst_cnt_nxt;
    wire [11:0] dram_grst_cnt;
    wire efc_rd_cnt_en; 
    wire efc_rd_cnt_dn;
    wire [12:0] efc_rd_cnt_nxt;
    wire [12:0] efc_rd_cnt;
    wire ctu_efc_read_start_nxt;
    wire ctu_efc_read_start;
    wire [5:0] clsp_bist_ctrl;
  
    reg   [13:0] nxt_ctrlsm;
    wire  [13:0] nxt_ctrlsm_gated;
    wire  [13:0] ctrlsm;

    wire dll_rst_l;
    wire dll_rst_l_nxt;
    wire de_grst_jl;
    wire a_grst_jl;
    wire rstctrl_disclk_jl;
    wire rstctrl_enclk_jl;

 
    wire start_clk_early_jl_nxt;
    wire a_grst_jl_nxt;
    wire freq_change_stat_nxt;
    wire freq_change_stat;
    wire powron_stat_nxt;
    wire powron_stat;
    wire wrmrst_stat_nxt;
    wire wrmrst_stat;
    wire tst_stat_nxt;
    wire tst_stat;
    wire [2:0] ctu_iob_resetstat;
    wire ctu_dram_selfrsh_nxt;
    wire update_shadow_jl_nxt;
    wire dram_a_grst_jl_nxt;
    wire ctu_iob_resetstat_wr_nxt;
 
    wire do_bist_pin_ff;
    wire do_bist_pin_jl;
    wire do_bist_type_jl;
    wire clsp_bist_dobist_nxt;
    wire clsp_bist_dobist;
    wire ctu_iob_wake_thr_nxt;
    wire jbus_grst_jl_l_dly1;
    wire jbus_grst_jl_l_dly2;
    wire creg_cken_vld_jl_nxt;
    wire ctu_tst_pre_grst_l_nxt;
    wire start_clk_jl_nxt;
    wire rstctrl_idle_jl_nxt;
    wire de_dll_rst_dn_ff; 
   wire do_bist_cnt_enable_nxt;
   wire do_bist_cnt_enable;
   wire do_bist_cnt_dn;
   wire [2:0] do_bist_cnt_nxt;
   wire [2:0] do_bist_cnt;
   wire bypclksel;


//------------------------------
//
//       Synchronizers
//
//------------------------------
    

   // pin -> jbus_clk
   ctu_synchronizer u_pll_char_in(
             .presyncdata( io_pll_char_in),
             .syncdata ( pll_char_in_jl),
             .clk(jbus_clk)
              );

   // tck  -> jbus_clk

   ctu_synchronizer u_jtag_clsp_ignore_wrm_rst(
             .presyncdata( jtag_clsp_ignore_wrm_rst),
             .syncdata ( jtag_clsp_ignore_wrm_rst_jl),
             .clk(jbus_clk)
              );

   ctu_synchronizer u_bypclksel(
             .presyncdata( bypclksel),
             .syncdata ( bypclksel_sync),
             .clk(jbus_clk)

              );
   //  jbus_clk -> ref

   ctu_synch_jl_ref u_wrm_rst_sync(
             .presyncdata(wrm_rst_jl),
             .syncdata (wrm_rst_ref),
             .jbus_clk(jbus_clk)
              );

   ctu_synch_jl_ref u_wrm_rst_fc_sync(
             .presyncdata(wrm_rst_fc_jl),
             .syncdata (wrm_rst_fc_ref),
             .jbus_clk(jbus_clk)
              );

   ctu_synch_jl_ref u_tst_rst_sync(
             .presyncdata(tst_rst_jl),
             .syncdata (tst_rst_ref),
             .jbus_clk(jbus_clk)
              );



//------------------------------
//
//  Register input/output on jbus_clk domain
//
//------------------------------
   

   dffrl_ns u_de_dll_rst_dn(
	     .din (de_dll_rst_dn),
             .clk(jbus_clk),
             .rst_l(start_clk_jl),
             .q (de_dll_rst_dn_ff)
              );

   dffrl_ns u_do_bist_pin_ff(
	     .din (io_do_bist),
             .clk(jbus_clk),
             .rst_l(start_clk_jl),
             .q (do_bist_pin_ff)
              );

   dffrl_async_ns u_j_rst_l(
		      .din (io_j_rst_l),
		      .clk (jbus_clk),
                      .rst_l(io_pwron_rst_l),
		      .q (j_rst_l));

   dff_ns u_clkctrl_dn_jl(
	     .din (clkctrl_dn_jl),
             .clk(jbus_clk),
             .q (clkctrl_dn)
              );

   dff_ns u_ctu_io_j_err_jl(
	     .din (ctu_io_j_err_jl),
             .clk(jbus_clk),
             .q (ctu_io_j_err)
              );

   dffrl_async_ns u_j_rst_l_1sht (
		      .din (~j_rst_l),
		      .clk (jbus_clk),
                      .rst_l(io_pwron_rst_l),
		      .q (j_rst_l_dly_l));

   assign j_rst_l_1sht = j_rst_l_dly_l & j_rst_l;

   dffrl_async_ns u_j_rst_l_1sht_dly (
		      .din (j_rst_l_1sht),
		      .clk (jbus_clk),
                      .rst_l(io_pwron_rst_l),
		      .q (j_rst_l_1sht_dly));

//------------------------------
//
// Serial interface 
//
//------------------------------
   
  
   dffrle_ns u_do_bist_pin(
             .din (do_bist_pin_ff),
             .clk(jbus_clk),
             .rst_l(start_clk_jl),
             .en(j_rst_l_1sht),
             .q (do_bist_pin_jl)
              );

   dffrle_ns u_do_bist_type(
             .din (do_bist_pin_ff),
             .clk(jbus_clk),
             .rst_l(start_clk_jl),
             .en(j_rst_l_1sht_dly),
             .q (do_bist_type_jl)
              );
   

   assign do_bist_cnt_enable_nxt =  do_bist_cnt_dn? 1'b0:
                                    j_rst_l_1sht_dly? 1'b1:
                                    do_bist_cnt_enable;

   dffrl_ns u_do_bist_cnt_enable(
             .din (do_bist_cnt_enable_nxt),
             .clk(jbus_clk),
             .rst_l(start_clk_jl),
             .q (do_bist_cnt_enable)
              );

   wire do_bist_cnt_6 = (do_bist_cnt == 3'b110);
   wire do_bist_cnt_5 = (do_bist_cnt == 3'b101);
   wire do_bist_cnt_4 = (do_bist_cnt == 3'b100);
   wire do_bist_cnt_3 = (do_bist_cnt == 3'b011);
   wire do_bist_cnt_2 = (do_bist_cnt == 3'b010);
   wire do_bist_cnt_1 = (do_bist_cnt == 3'b001);

   dffrle_ns u_do_bist_ctrl_5(
             .din (do_bist_pin_ff),
             .clk(jbus_clk),
             .rst_l(start_clk_jl),
             .en(do_bist_cnt_6),
             .q (clsp_bist_ctrl[5])
             );

   dffrle_ns u_do_bist_ctrl_4(
             .din (do_bist_pin_ff),
             .clk(jbus_clk),
             .rst_l(start_clk_jl),
             .en(do_bist_cnt_5),
             .q (clsp_bist_ctrl[4])
             );
   dffrle_ns u_do_bist_ctrl_3(
             .din (do_bist_pin_ff),
             .clk(jbus_clk),
             .rst_l(start_clk_jl),
             .en(do_bist_cnt_4),
             .q (clsp_bist_ctrl[3])
             );
   dffrle_ns u_do_bist_ctrl_2(
             .din (do_bist_pin_ff),
             .clk(jbus_clk),
             .rst_l(start_clk_jl),
             .en(do_bist_cnt_3),
             .q (clsp_bist_ctrl[2])
             );
   dffrle_ns u_do_bist_ctrl_1(
             .din (do_bist_pin_ff),
             .clk(jbus_clk),
             .rst_l(start_clk_jl),
             .en(do_bist_cnt_2),
             .q (clsp_bist_ctrl[1])
             );
   dffrle_ns u_do_bist_ctrl_0(
             .din (do_bist_pin_ff),
             .clk(jbus_clk),
             .rst_l(start_clk_jl),
             .en(do_bist_cnt_1),
             .q (clsp_bist_ctrl[0])
             );


//------------------------------
//
// do_bist  counter:
//
//------------------------------

    assign do_bist_cnt_dn = (do_bist_cnt ==   3'b001) ;
    assign do_bist_cnt_nxt = j_rst_l_1sht_dly?  BIST_CTRLCNT:
                             do_bist_cnt_enable ? do_bist_cnt - 3'b001 :
                             do_bist_cnt;

    dffrl_ns #(3) u_do_bist_cnt(
                      .din ( do_bist_cnt_nxt),
                      .clk (jbus_clk),
                      .rst_l(start_clk_jl),
                      .q (do_bist_cnt));

//------------------------------
//
// dram_rst counter:
//
//------------------------------

    assign dram_grst_cnt_en = ctrlsm[`CTRLSM_A_GRST] & clsp_ctrl_srarm_jl ;
    assign dram_grst_cnt_dn = (dram_grst_cnt ==   DRAM_GRST_CNT) ;
    assign dram_grst_cnt_nxt = dram_grst_cnt_en ? dram_grst_cnt + 12'h001 :
                               dram_grst_cnt;

    dffrl_ns #(12) u_dram_rstcnt (
                      .din ( dram_grst_cnt_nxt),
                      .clk (jbus_clk),
                      .rst_l(start_clk_jl),
                      .q (dram_grst_cnt));

//------------------------------
//
//  start_clk counter:
//
//------------------------------

    assign start_clk_cnt_en = ctrlsm[`CTRLSM_STR_CLK] &   bypclksel_sync ;
    assign start_clk_cnt_dn = (start_clk_cnt == 4'b1111) ;
    assign start_clk_cnt_nxt = start_clk_cnt_en ? start_clk_cnt + 4'b0001 :
                               start_clk_cnt;

    dffrl_ns #(4) u_startclk_cnt(
                      .din ( start_clk_cnt_nxt),
                      .clk (jbus_clk),
                      .rst_l(start_clk_jl),
                      .q (start_clk_cnt));

//------------------------------
//
// efc_rd counter
//
//------------------------------

    assign efc_rd_cnt_en = ctrlsm[`CTRLSM_EFC_RD] ;
    assign efc_rd_cnt_dn = (efc_rd_cnt ==   EFC_CNT);
    assign efc_rd_cnt_nxt = efc_rd_cnt_en ? efc_rd_cnt + 13'h0001 :
                            efc_rd_cnt;

    dffrl_ns #(13) u_efc_rdcnt(
                      .din (efc_rd_cnt_nxt),
                      .clk (jbus_clk),
                      .rst_l(start_clk_jl),
                      .q (efc_rd_cnt));
//------------------------------
//
//  State machine
//
//------------------------------

   assign nxt_ctrlsm_gated [13:1] = {13{pll_locked_jl}} &  nxt_ctrlsm [13:1];
   assign nxt_ctrlsm_gated [0] =  ~pll_locked_jl |  nxt_ctrlsm [0];


   dffrl_async_ns #(13) u_ctrlsm_13_1 (
			   .din (nxt_ctrlsm_gated[13:1]),
			   .clk (jbus_clk),
			   .rst_l (io_pwron_rst_l),
			   .q (ctrlsm[13:1]));

   dffsl_async_ns    u_ctrlsm_0 (
			   .din (nxt_ctrlsm_gated[0]),
			   .clk (jbus_clk),
			   .set_l (io_pwron_rst_l),
			   .q (ctrlsm[0]));

   always @(/*AUTOSENSE*/
	    bypclksel_sync or clkctrl_dn or clsp_ctrl_srarm_jl
	    or ctrlsm or de_dll_rst_dn_ff or dft_wake_thr
	    or do_bist_pin_jl or dram_grst_cnt_dn or efc_rd_cnt_dn
	    or frq_change or j_rst_l or jbus_grst_jl_l_dly2
	    or jtag_clsp_ignore_wrm_rst_jl or pll_locked_jl
	    or powron_stat or start_clk_cnt_dn or start_clk_jl)
   begin
   case (1'b1)                                                         //synopsys parallel_case
	  ctrlsm[`CTRLSM_WAIT_LCK]:
	    begin
               nxt_ctrlsm = pll_locked_jl & ~j_rst_l ? `ST_CTRLSM_STR_CLK 
                                                     : `ST_CTRLSM_WAIT_LCK;
	    end
	  ctrlsm[`CTRLSM_STR_CLK]:
	    begin
                          // it takes at least 6 clocks to start clocks in fstlog block
                          // in pll bypass mode (j_clk -> pll_clk_out)
                          // Cannot start clk ctrl sm when there is no cmp or dram clock
               nxt_ctrlsm = (start_clk_jl & ~bypclksel_sync)    
                          | (bypclksel_sync & start_clk_cnt_dn ) ? `ST_CTRLSM_EN_CLK 
                                                                 : `ST_CTRLSM_STR_CLK ;
	    end
	   ctrlsm[`CTRLSM_EN_CLK]:
	    begin
                   nxt_ctrlsm = clkctrl_dn ? `ST_CTRLSM_WAIT_J_RST:
                                             `ST_CTRLSM_EN_CLK;
            end
	   ctrlsm[`CTRLSM_WAIT_J_RST]:
	    begin
                   nxt_ctrlsm = j_rst_l ? `ST_CTRLSM_DE_DLLRST: 
                               `ST_CTRLSM_WAIT_J_RST;
            end
	   ctrlsm[`CTRLSM_DE_DLLRST]:
	    begin
                   nxt_ctrlsm = de_dll_rst_dn_ff ? `ST_CTRLSM_DE_GRST : 
                               `ST_CTRLSM_DE_DLLRST;
            end
	   ctrlsm[`CTRLSM_DE_GRST]:
	    begin
                                // make sure jbus_rst_l are de-asserted 
                   nxt_ctrlsm = jbus_grst_jl_l_dly2 ? 
                                (powron_stat? `ST_CTRLSM_EFC_RD : 
                                      (do_bist_pin_jl ? `ST_CTRLSM_WAIT_BISTDN: `ST_CTRLSM_IDLE)
                                ) : `ST_CTRLSM_DE_GRST;
            end
	   ctrlsm[`CTRLSM_EFC_RD]:
	    begin
                   nxt_ctrlsm = efc_rd_cnt_dn? 
                                (do_bist_pin_jl ? `ST_CTRLSM_WAIT_BISTDN: `ST_CTRLSM_IDLE)
                             : `ST_CTRLSM_EFC_RD ;
            end
	   ctrlsm[`CTRLSM_WAIT_BISTDN]:
	    begin
                   nxt_ctrlsm = dft_wake_thr?  `ST_CTRLSM_IDLE : `ST_CTRLSM_WAIT_BISTDN;
            end 
	   ctrlsm[`CTRLSM_IDLE]: 
              begin
                   // will ignore warm reset when jtag_clsp_ignore_wrm_rst is asserted
                   // will not put clsp into warm reset
                   nxt_ctrlsm = (jtag_clsp_ignore_wrm_rst_jl | j_rst_l) ? `ST_CTRLSM_IDLE : `ST_CTRLSM_A_GRST;
	      end
	   ctrlsm[`CTRLSM_A_GRST] :
             begin
                   nxt_ctrlsm =  clsp_ctrl_srarm_jl ?
                                 (dram_grst_cnt_dn ? `ST_CTRLSM_A_DGRST : `ST_CTRLSM_A_GRST):
                                 `ST_CTRLSM_DIS_CLK; 
             end
	   ctrlsm[`CTRLSM_A_DGRST] :  
	    begin
                   nxt_ctrlsm =  `ST_CTRLSM_DIS_CLK ;
	    end //
	  ctrlsm[`CTRLSM_DIS_CLK]:
            begin
                   nxt_ctrlsm =  clkctrl_dn ? 
                                (frq_change ? `ST_CTRLSM_CHNG_FRQ: `ST_CTRLSM_WAIT_RST)
                                : `ST_CTRLSM_DIS_CLK;
            end
	  ctrlsm[`CTRLSM_CHNG_FRQ]:
            begin
                 nxt_ctrlsm = `ST_CTRLSM_WAIT_RST ;
            end
	  ctrlsm[`CTRLSM_WAIT_RST]:   
            begin
                 nxt_ctrlsm = ~pll_locked_jl? `ST_CTRLSM_WAIT_LCK : `ST_CTRLSM_WAIT_RST ;
            end
         // CoverMeter line_off
	  default:
	    begin
               nxt_ctrlsm = `ST_CTRLSM_WAIT_LCK;
	    end
         // CoverMeter line_on
	endcase // case(ctrlsm)
       end // begin

// -----------------------------------------------------------
//
// state outputs as function of current state
//
// -----------------------------------------------------------

   assign start_clk_jl_nxt =  |(nxt_ctrlsm[`CTRLSM_CHNG_FRQ: `CTRLSM_STR_CLK]);

  // fstlog needs to use the 2 clock early version 
  // (use rising edge of jbus_dup_gclk_out as enable )

  dffrl_async_ns u_start_early_2clk_jl( .din (start_clk_jl_nxt & pll_locked_jl), 
                      .q (start_2clk_early_jl), 
                      .rst_l(io_pwron_rst_l),
                      .clk (jbus_clk));

  dffrl_async_ns u_start_early_clk_jl( .din (start_2clk_early_jl), 
                      .q (start_clk_early_jl_nxt), 
                      .rst_l(io_pwron_rst_l),
                      .clk (jbus_clk));

  //  start_clk_early_jl is used in  mult counters (async reset)
  assign start_clk_early_jl= testmode_l? start_clk_early_jl_nxt: 1'b1;

  dffrl_async_ns u_start_clk_jl( .din (start_clk_early_jl), 
                      .q (start_clk_jl), 
                      .rst_l(io_pwron_rst_l),
                      .clk (jbus_clk));

   // Can only write to clk_enable csr when  clkctrl sm done with turning on clock enables
  assign creg_cken_vld_jl_nxt = |(nxt_ctrlsm[`CTRLSM_A_GRST :`CTRLSM_WAIT_J_RST]);

  dffrl_async_ns u_creg_cken_vld_jl( .din (creg_cken_vld_jl_nxt & pll_locked_jl), 
                      .q (creg_cken_vld_jl), 
                      .rst_l(io_pwron_rst_l),
                      .clk (jbus_clk));

  assign ssiclk_enable_nxt = |(nxt_ctrlsm[`CTRLSM_A_DGRST:`CTRLSM_EN_CLK]);

  dffrl_async_ns u_ssiclk_enable( .din (ssiclk_enable_nxt & pll_locked_jl), 
                      .q (ssiclk_enable), 
                      .rst_l(io_pwron_rst_l),
                      .clk (jbus_clk));


  // wrm_rst, wrm_rst_fc and tst_rst are mutually exclusive
  // level signals

  assign wrm_rst_nxt =  ctrlsm[`CTRLSM_WAIT_RST]  & pll_locked_jl
                        & ~j_rst_l & ~pll_char_in_jl & ~freq_change_stat ? 1'b1:
                        ctrlsm[`CTRLSM_IDLE] ? 1'b0:
                       wrm_rst_jl;

  dffrl_async_ns u_wrm_rst( .din (wrm_rst_nxt), 
                      .q (wrm_rst_jl), 
                      .rst_l(io_pwron_rst_l),
                      .clk (jbus_clk));

  assign tst_rst_nxt =  ctrlsm[`CTRLSM_WAIT_RST]
                          & ~j_rst_l & pll_char_in_jl & pll_locked_jl? 1'b1:
                           ctrlsm[`CTRLSM_IDLE] ? 1'b0:
                           tst_rst_jl;

  dffrl_async_ns u_tst_rst( .din (tst_rst_nxt ), 
                      .q (tst_rst_jl), 
                      .rst_l(io_pwron_rst_l),
                      .clk (jbus_clk));


  assign wrm_rst_fc_nxt =  ctrlsm[`CTRLSM_DIS_CLK] & nxt_ctrlsm[`CTRLSM_CHNG_FRQ]
                        & ~j_rst_l & ~pll_char_in_jl & freq_change_stat  & pll_locked_jl ? 1'b1:
                        ctrlsm[`CTRLSM_IDLE] ? 1'b0:
                       wrm_rst_fc_jl;

  dffrl_async_ns u_wrm_rst_fc( .din (wrm_rst_fc_nxt),
                      .q (wrm_rst_fc_jl),
                      .rst_l(io_pwron_rst_l),
                      .clk (jbus_clk));

  assign ctu_efc_read_start_nxt =  nxt_ctrlsm[`CTRLSM_EFC_RD] & ctrlsm[`CTRLSM_DE_GRST];
  dff_ns u_ctu_efc_read_start_nxt ( .din (ctu_efc_read_start_nxt & pll_locked_jl), 
                                    .clk (jbus_clk), 
                                    .q(ctu_efc_read_start));

  assign ctu_iob_wake_thr_nxt = (ctrlsm[`CTRLSM_EFC_RD] & nxt_ctrlsm[`CTRLSM_IDLE]) |
                                (ctrlsm[`CTRLSM_WAIT_BISTDN] & nxt_ctrlsm[`CTRLSM_IDLE]) |
                                (ctrlsm[`CTRLSM_DE_GRST] & nxt_ctrlsm[`CTRLSM_IDLE]);

  // delay wake thr by 3 cycle in case of bist is not required. 
  dff_ns u_ctu_iob_wake_thr( .din ( ctu_iob_wake_thr_nxt & pll_locked_jl),
                                    .clk (jbus_clk),
                                    .q( ctu_iob_wake_thr));

  dff_ns u_jbus_grst_jl_l_dly1( .din ( jbus_grst_jl_l),
                                    .clk (jbus_clk),
                                    .q( jbus_grst_jl_l_dly1));

  dff_ns u_jbus_grst_jl_l_dly2( .din ( jbus_grst_jl_l_dly1),
                                    .clk (jbus_clk),
                                    .q( jbus_grst_jl_l_dly2));


  //  1 sht signal if on same clock domain

  assign clsp_bist_dobist_nxt =  ((ctrlsm[`CTRLSM_EFC_RD] & nxt_ctrlsm[`CTRLSM_WAIT_BISTDN]) |
                                  (ctrlsm[`CTRLSM_DE_GRST] & nxt_ctrlsm[`CTRLSM_WAIT_BISTDN]))
                                & do_bist_pin_jl;

  dffrl_async_ns u_clsp_bist_dobist( .din (clsp_bist_dobist_nxt & pll_locked_jl), 
                               .clk (jbus_clk), 
                               .rst_l(io_pwron_rst_l),
                               .q(clsp_bist_dobist));

  assign clsp_bist_type = do_bist_type_jl;


  // ONLY update shadow register on frequency change
  //assign update_shadow_jl_nxt = ctrlsm[`CTRLSM_DIS_CLK] & nxt_ctrlsm[`CTRLSM_CHNG_FRQ] ;

  assign update_shadow_jl_nxt = ctrlsm[`CTRLSM_CHNG_FRQ]  ;
  dffrl_async_ns u_update_shadow_jl( .din (update_shadow_jl_nxt & (pll_locked_jl | bypclksel_sync)), 
                             .q (update_shadow_jl), 
                             .rst_l(io_pwron_rst_l),
                             .clk (jbus_clk));

  assign ctu_ddr0_iodll_rst_jl_l = dll_rst_l;
  assign ctu_ddr1_iodll_rst_jl_l = dll_rst_l;
  assign ctu_ddr2_iodll_rst_jl_l = dll_rst_l;
  assign ctu_ddr3_iodll_rst_jl_l = dll_rst_l; 

  // Send before grst de-assertion
  assign dll_rst_l_nxt = |(ctrlsm[`CTRLSM_A_GRST: `CTRLSM_DE_DLLRST]);
  dffrl_async_ns u_dll_rst_l( .din (dll_rst_l_nxt & pll_locked_jl), 
                              .rst_l(io_pwron_rst_l),
                              .q (dll_rst_l), 
                              .clk (jbus_clk));

  // Send before grst de-assertion
  assign ctu_tst_pre_grst_l_nxt = ctrlsm[`CTRLSM_DE_DLLRST] & powron_stat ?
                                  1'b1: ctu_tst_pre_grst_l;
  dffrl_async_ns u_ctu_tst_pre_grst_l ( .din (ctu_tst_pre_grst_l_nxt), 
                              .rst_l(io_pwron_rst_l),
                              .q (ctu_tst_pre_grst_l), 
                              .clk (jbus_clk));

  // Assertion and de-assertion of grst 

  assign de_grst_jl=  ctrlsm[`CTRLSM_DE_GRST];

  assign a_grst_jl_nxt= (nxt_ctrlsm[`CTRLSM_A_GRST]) & ctrlsm[`CTRLSM_IDLE];
  dffrl_async_ns u_a_grst_jl( .din ( a_grst_jl_nxt & pll_locked_jl),
                                    .rst_l(io_pwron_rst_l),
                                    .clk (jbus_clk),
                                    .q( a_grst_jl));

  // Msure dram_a_grst_jl is more than 1 jbus_clock
  assign dram_a_grst_jl_nxt=  nxt_ctrlsm[`CTRLSM_A_DGRST] |  
                                  ctrlsm[`CTRLSM_A_DGRST] |
                             (nxt_ctrlsm[`CTRLSM_A_GRST] & ctrlsm[`CTRLSM_IDLE] & ~clsp_ctrl_srarm_jl) |
                             (ctrlsm[`CTRLSM_A_GRST] & ~clsp_ctrl_srarm_jl) |
                             ctrlsm[`CTRLSM_DIS_CLK] ;
  
  dffrl_async_ns u_dram_a_grst_jl( .din ( dram_a_grst_jl_nxt & pll_locked_jl),
                                    .rst_l(io_pwron_rst_l),
                                    .clk (jbus_clk),
                                    .q( dram_a_grst_jl));


  // Assertion and de-assertion of  cken

  assign rstctrl_disclk_jl=  ctrlsm[`CTRLSM_DIS_CLK] ;
  assign rstctrl_enclk_jl=  ctrlsm[`CTRLSM_EN_CLK] ;

  
  assign rstctrl_idle_jl_nxt = nxt_ctrlsm[`CTRLSM_IDLE] | nxt_ctrlsm[`CTRLSM_WAIT_RST];

  dffrl_async_ns u_rstctrl_idle_jl( .din ( rstctrl_idle_jl_nxt  & pll_locked_jl),
			 .q (rstctrl_idle_jl),
                         .rst_l(io_pwron_rst_l),
			 .clk(jbus_clk));


  // frequency change register & reset status registers

  assign frq_change_nxt = (ctrlsm[`CTRLSM_IDLE] & frq_chng_pending_jl) & pll_locked_jl ? 1'b1: 
                           ctrlsm[`CTRLSM_IDLE] ? 1'b0:
                           frq_change;

  dffrl_async_ns u_frq_change ( .din ( frq_change_nxt ),
			 .q (frq_change),
                         .rst_l(io_pwron_rst_l),
			 .clk(jbus_clk));

  assign freq_change_stat_nxt  = frq_change & ctrlsm[`CTRLSM_A_GRST]  & pll_locked_jl? 1'b1:
                                 ctu_iob_resetstat_wr ? 1'b0:
                                 freq_change_stat;
                                    
  dffrl_async_ns u_freq_change_stat (
				       .din (freq_change_stat_nxt  ),
				       .q (freq_change_stat),
				       .clk (jbus_clk),
				       .rst_l (io_pwron_rst_l));

  assign tst_stat_nxt  = nxt_ctrlsm[`CTRLSM_A_GRST] & pll_char_in_jl & pll_locked_jl ? 1'b1:
                         ctu_iob_resetstat_wr ? 1'b0:
                         tst_stat;

  dffrl_async_ns u_tst_stat (
				       .din (tst_stat_nxt & pll_locked_jl),
				       .q (tst_stat),
				       .clk (jbus_clk),
				       .rst_l (io_pwron_rst_l));

  assign wrmrst_stat_nxt  = ~frq_change & ctrlsm[`CTRLSM_A_GRST] ? 1'b1:
                            ctu_iob_resetstat_wr ? 1'b0:
                            wrmrst_stat;

  dffrl_async_ns u_wrmrst_stat (
				       .din (wrmrst_stat_nxt  ),
				       .q (wrmrst_stat),
				       .clk (jbus_clk),
				       .rst_l (io_pwron_rst_l));

  assign powron_stat_nxt  = ctu_iob_resetstat_wr ? 1'b0:
                            powron_stat;

  dffsl_async_ns u_powron_stat ( .din (powron_stat_nxt ),
				  .q (powron_stat),
				  .clk (jbus_clk),
				   .set_l (io_pwron_rst_l));


  assign ctu_iob_resetstat = {freq_change_stat, powron_stat, wrmrst_stat};
  assign ctu_iob_resetstat_wr_nxt =  (nxt_ctrlsm[`CTRLSM_IDLE] & ctrlsm[`CTRLSM_EFC_RD]) |
                                     (nxt_ctrlsm[`CTRLSM_IDLE] & ctrlsm[`CTRLSM_WAIT_BISTDN]) |
                                     (nxt_ctrlsm[`CTRLSM_IDLE] &  ctrlsm[`CTRLSM_DE_GRST]);
 
  dffrl_async_ns u_ctu_iob_resetstat_wr_nxt ( .din (ctu_iob_resetstat_wr_nxt & pll_locked_jl),
				  .q ( ctu_iob_resetstat_wr),
				  .clk (jbus_clk),
				  .rst_l (io_pwron_rst_l));
   
  // do not assert ctu_dram_selfrsh in test warm reset mode
  assign ctu_dram_selfrsh_nxt = clsp_ctrl_srarm_jl & ctrlsm[`CTRLSM_IDLE] &
                                nxt_ctrlsm[`CTRLSM_A_GRST] & ~pll_char_in_jl & pll_locked_jl ? 1'b1 :
                                ((nxt_ctrlsm[`CTRLSM_WAIT_BISTDN] & ctrlsm[`CTRLSM_DE_GRST]) | 
                                 (nxt_ctrlsm[`CTRLSM_IDLE] & ctrlsm[`CTRLSM_DE_GRST]) & pll_locked_jl ) 
                                  ? 1'b0:
                                ctu_dram_selfrsh;
                              
  dffrl_async_ns u_ctu_dram_selfrsh_jl(
				       .din (ctu_dram_selfrsh_nxt ),
				       .q (ctu_dram_selfrsh),
				       .clk (jbus_clk),
				       .rst_l (io_pwron_rst_l));

//synopsys translate_off

   reg [8*18:1] text; 

   always @(ctrlsm[13:0])
   case (1'b1)
   ctrlsm[`CTRLSM_WAIT_LCK] : text = "WLCK";
   ctrlsm[`CTRLSM_STR_CLK] : text = "STCLK";
   ctrlsm[`CTRLSM_EN_CLK] : text = "ECLK";
   ctrlsm[`CTRLSM_WAIT_J_RST] : text = "JRST";
   ctrlsm[`CTRLSM_DE_DLLRST] : text = "DLLRST";
   ctrlsm[`CTRLSM_DE_GRST] : text = "DRST";
   ctrlsm[`CTRLSM_EFC_RD] : text = "EFCRD";
   ctrlsm[`CTRLSM_WAIT_BISTDN] : text = "WBIST";
   ctrlsm[`CTRLSM_IDLE] : text = "Idle";
   ctrlsm[`CTRLSM_A_GRST] : text = "ARST";
   ctrlsm[`CTRLSM_A_DGRST] : text = "ADGRT";
   ctrlsm[`CTRLSM_DIS_CLK] : text = "DCLK";
   ctrlsm[`CTRLSM_CHNG_FRQ] : text = "FRQ";
   ctrlsm[`CTRLSM_WAIT_RST] : text = "WRST";
   default :  text = "UNKNOWN";
   endcase

//synopsys translate_on


endmodule // clsprst








