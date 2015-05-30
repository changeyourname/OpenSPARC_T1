// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: ctu_clsp_clkgn_fstlog.v
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
//    Unit Name: ctu_clsp_clkgn_fstlog
//
//-----------------------------------------------------------------------------

`include "sys.h"

module ctu_clsp_clkgn_fstlog(/*AUTOARG*/
// Outputs
cmp_div0, cmp_div1, dram_div0, dram_div1, jbus_div0, jbus_div1, 
jbus_dup_div0, cmp_div_bypass, jbus_div_bypass, so, jbus_mult_rst_l, 
jbus_alt_bypsel_l, 
// Inputs
clsp_fstlog_corepll_j_0, clsp_fstlog_corepll_d_0, 
clsp_fstlog_corepll_c_0, cdiv_vec, ddiv_vec, 
jdiv_vec, stretch_cnt_vec, bypclksel, se, si, pll_reset_ref_l, 
start_clk_jl, clk_stretch_cnt_val_6, clk_stretch_cnt_val_odd, 
clk_stretch_trig, pll_clk_out, pll_clk_out_l
);

//=============================================================================
//  I/O declarations
//-----------------------------------------------------------------------------
//  I/O declarations
output      cmp_div0;			// to bw_ctu_clk_sync_mux macro
output      cmp_div1;			// to bw_ctu_clk_sync_mux macro
output      dram_div0;			// to bw_ctu_clk_sync_mux macro
output      dram_div1;			// to bw_ctu_clk_sync_mux macro
output      jbus_div0;			// to bw_ctu_clk_sync_mux macro
output      jbus_div1;			// to bw_ctu_clk_sync_mux macro
output      jbus_dup_div0;		// to bw_ctu_clk_sync_mux macro
output      cmp_div_bypass;		// to bypass mux
output      jbus_div_bypass;		// to bypass mux
output      so;
output      jbus_mult_rst_l;
output      jbus_alt_bypsel_l;

//-----------------------------------------------------------------------------
//  CSR Divide values
//-----------------------------------------------------------------------------
input  clsp_fstlog_corepll_j_0;
input  clsp_fstlog_corepll_d_0;
input  clsp_fstlog_corepll_c_0;
input  [14:0]	cdiv_vec;
input  [14:0]	ddiv_vec;
input  [14:0]	jdiv_vec;
input  [14:0]	stretch_cnt_vec;
input  bypclksel;
input  se;
input  si;

//-----------------------------------------------------------------------------
// Reset
//-----------------------------------------------------------------------------
input       	pll_reset_ref_l;
input       	start_clk_jl;
//-----------------------------------------------------------------------------
// Clock stretch
//-----------------------------------------------------------------------------
input  clk_stretch_cnt_val_6;
input  clk_stretch_cnt_val_odd;
input  clk_stretch_trig;
//-----------------------------------------------------------------------------
// Clocks
//-----------------------------------------------------------------------------
input		pll_clk_out;		// pll_clk_out local clk
input		pll_clk_out_l;		// pll_clk_out_l local clk

//=============================================================================
//  Wire/reg declarations
//-----------------------------------------------------------------------------
wire [2:0]	clk_str_en_buf;
wire [2:0]	clk_str_en_buf_b;
wire [2:0]	clk_str_en_ff;
wire [2:0]	clk_str_en_ffb;
wire		clk_str_en_nxt;
wire            clk_str_pre_en_ff;
wire		clk_str_pre_en_ffb;
wire		cmp_div_bypass;
wire		init_div_b_l;
wire		init_div_l;
wire		init_div_ff_b_l;
wire		init_div_ff_l;
//wire		jdup_init_div_l_neg;
wire		jdup_init_div_l;
wire            jdup_align_edge;
wire            jdup_align_edge_b;
wire		pll_clk_out_l;
//wire		pll_clk_out_l_byp;
wire            pll_reset_ff_dly1_l;
//wire [1:0]      pll_rst_ff;
wire            pll_rst_ff;
wire            pll_rst_pre_ff;
wire            pll_rst_ffb;
wire [1:0]	start_clk_dly_ff;
wire            start_clk_ff;
wire		start_clk_pre_nxt;
wire		start_clk_pre_ff;
wire            pstretch;

wire      	cmp_div0_pre;
wire      	cmp_div1_pre;
wire      	dram_div0_pre;
wire      	dram_div1_pre;
wire      	jbus_div0_pre;
wire      	jbus_div1_pre;
wire      	jbus_div0_muxed;
wire      	jbus_div1_muxed;
wire      	jbus_dup_div0_pre;
//wire      	jbus_dup_div1_pre;
wire            jbus_dup_out;
wire            jbus_out;
wire            jbus_dup_1sht;
wire            jbus_1sht;
wire            clk_stretch_trig_ff;
wire            clk_stretch_trig_dly_l;
wire            clk_stretch_trig_1sht;
wire            pstretch_dly_nxt;

wire pstretch_mode_nxt;
wire pstretch_mode;
wire pstretch_dly;
wire pstretch_dly2;
wire pstretch_dly3;
wire pstretch_dly4;
wire pstretch_ff_nxt;
wire pstretch_ff;

wire init_div_ff_dly;
wire init_div_ff_dly2;
wire init_div_ff_dly2_neg;
wire init_div_ff_dly3;
wire init_div_ff_dly3_neg;
wire jbus_mult_rst_l_nxt;

wire [2:0] mstretch_pipe_nxt;
wire [2:0] mstretch_pipe;
wire mstretch_ff;
wire mstretch_ff_nxt;
wire jdup_align_edge_ff;
//wire jdup_init_div_l_neg_bar;
//wire cmp_div_bypass_bar;
wire init_div_ff_dly2_neg_bar;

//-----------------------------------------------------------------------------
//  clkfstlog Module body starts here
//-----------------------------------------------------------------------------
/*
  Conventions:
    Instance names suffixes:
        _nsr	Non-scanable register (scan to be tied off on this register)
    Port/Net/Wire name suffixes:
        _cg	Signal launched by cmp_gclk
        _cgb	Signal launched by cmp_gclk_byp (earlier version of gclk)
        _jg	Signal launched by jbus_gclk
        _jl	Signal launched by jbus_clk (jbus local clk)
        _fg	Signal launched by jbus pll feedback global clock
        _dl	Signal launched by dram_gclk (dram global clk)
        _ref	Signal launched by ref_clk (pll ref local clk)
	_ff 	Signal directly out of a FF (noninverted, phase 1 clk)
	_nxt 	Signal directly into a FF D input
	_en 	Signal directly into a FF enable input
	_ffb 	Signal directly out of a FF (inverted clk, aka phase 2)
    Additional Suffixes:
	_l 	
*/

/************************************************************
*  Synchronize pll_lock to pll_clk and pll_clk_l domain 
************************************************************/

   ctu_synchronizer  u_pll_clk_detect (
              .presyncdata( pll_reset_ref_l),
              .syncdata ( pll_reset_ff_dly1_l),
              .clk(pll_clk_out)
               );


  // synchronizer pll_clk_out -> pll_clk_out_l
  bw_zzctu_sync pll_rst_pipe_sync(
                      // Outputs
                      .so                (),
                      .sob               (),
                      .out              (pll_rst_ffb),
                      // Inputs
                      .d                (pll_reset_ff_dly1_l),
                      .si               (),
                      .sib               (),
                      .pll_out          (pll_clk_out),
                      .pll_out_l        (pll_clk_out_l),
                      .se               (se));

  dff_ns  pll_rst_pipe0(
  	 .din (pll_reset_ff_dly1_l),
  	 .clk (pll_clk_out),
  	 .q   (pll_rst_pre_ff));

 dff_ns  pll_rst_pipe1(
  	 .din (pll_rst_pre_ff),
  	 .clk (pll_clk_out),
  	 .q   (pll_rst_ff));

/************************************************************
*  Sample startc_clk_jl signal to pll_clk_out domain
************************************************************/

 assign start_clk_pre_nxt = jbus_dup_1sht? start_clk_jl: start_clk_pre_ff;

 dff_ns  start_clk_pre_reg(
	 .din (start_clk_pre_nxt),
	 .clk (pll_clk_out),
	 .q   (start_clk_pre_ff));

  // synchronizer pll_clk_out -> pll_clk_out_l
  bw_zzctu_sync stsync(
		      // Outputs
		      .so		(),
		      .sob		(),
		      .out		(start_clk_ff_b),
		      // Inputs
		      .d		(start_clk_pre_ff),
		      .si		(),
		      .sib		(),
		      .pll_out		(pll_clk_out),
		      .pll_out_l	(pll_clk_out_l),
		      .se		(se));

  // delay start clk for clk a to match delay for clock b:  result is start_clk_ff
  // is 1/2 clk prior to start_clk_ff_b
  dff_ns #(2)  strtclk_reg(
		     .din ({start_clk_dly_ff[0], start_clk_pre_ff}),
		     .clk (pll_clk_out),
		     .q   (start_clk_dly_ff[1:0]));

  assign start_clk_ff = start_clk_dly_ff[1];

  // delay jdup_align_edge by 1 clock to line up with jdup_align_edge_b

  dff_ns #(1)  jdup_align_dly1(
	 .din (jdup_align_edge),
	 .clk (pll_clk_out),
	 .q   (jdup_align_edge_ff));

 
  assign init_div_l   = jdup_align_edge_ff  ? start_clk_ff: init_div_ff_l;
  assign init_div_b_l = jdup_align_edge_b  ? start_clk_ff_b : init_div_ff_b_l;

  assign jdup_init_div_l =  pll_rst_ff; 

  dffrl_ns #(1)  init_div_reg(
	 .din (init_div_l),
	 .clk (pll_clk_out),
	 .rst_l(pll_rst_ff),
	 .q   (init_div_ff_l));

  dffrl_ns #(1)  init_divb_reg(
	 .din (init_div_b_l),
	 .clk (pll_clk_out_l),
	 .rst_l(pll_rst_ffb),
	 .q   (init_div_ff_b_l));

  dffrl_ns #(1)  u_init_div_ff_dly(
	 .din (init_div_ff_l),
	 .clk (pll_clk_out),
	 .rst_l(pll_rst_ff),
	 .q   (init_div_ff_dly));

  dffrl_ns #(1)  u_init_div_ff_dly2(
	 .din (init_div_ff_dly),
	 .clk (pll_clk_out),
	 .rst_l(pll_rst_ff),
	 .q   (init_div_ff_dly2));

  bw_u1_scanl_2x  u_init_div_ff_dly2_neg(
	 .sd (init_div_ff_dly2),
	 .ck (pll_clk_out),
	 .so (init_div_ff_dly2_neg));

  dffrl_ns #(1)  u_init_div_ff_dly3(
	 .din (init_div_ff_dly2),
	 .clk (pll_clk_out),
	 .rst_l(pll_rst_ff),
	 .q   (init_div_ff_dly3));

  bw_u1_scanl_2x  u_init_div_ff_dly3_neg(
	 .sd (init_div_ff_dly3),
	 .ck (pll_clk_out),
	 .so (init_div_ff_dly3_neg));

  assign jbus_mult_rst_l_nxt =  jbus_div0_pre? 1'b1: jbus_mult_rst_l;

  dffrl_ns #(1)  u_jbus_mult_rst_l(
	 .din (jbus_mult_rst_l_nxt),
	 .clk (pll_clk_out),
	 .rst_l(init_div_ff_l),
	 .q   (jbus_mult_rst_l));

/************************************************************
* stretch pll output
************************************************************/
// synchronize clk stretch trigger into the pll clk domain
// clock stretch is not needed in  pll_bypass mode

  dffe_ns  u_clk_stretch_trig(
         .din (clk_stretch_trig),
         .clk (pll_clk_out),
         .en (jbus_1sht),
         .q   (clk_stretch_trig_ff));

  dff_ns  u_clk_stretch_trig_dly_l(
         .din (~clk_stretch_trig_ff),
         .clk (pll_clk_out),
         .q   (clk_stretch_trig_dly_l));

  assign clk_stretch_trig_1sht =  clk_stretch_trig_ff & clk_stretch_trig_dly_l;


  assign pstretch_mode_nxt  =  pstretch ? 1'b0: 
                               clk_stretch_trig_1sht ? 1'b1 :
                               pstretch_mode;

  dff_ns  u_pstretch_mode(
                     .din (pstretch_mode_nxt & start_clk_ff),
                     .clk (pll_clk_out),
                     .q   (pstretch_mode));

   // special case on div4 ( 2 align edge pulses are generated ; take later one)

   assign pstretch_dly_nxt =stretch_cnt_vec[3] & stretch_cnt_vec[7] ?
                            pstretch & ~pstretch_mode: pstretch & pstretch_mode;

   dff_ns  u_pstretch_dly(
         .din (pstretch_dly_nxt),
         .clk (pll_clk_out),
         .q   (pstretch_dly));

   dff_ns  u_pstretch_dly2(
         .din (pstretch_dly),
         .clk (pll_clk_out),
         .q   (pstretch_dly2));

   dff_ns  u_pstretch_dly3(
         .din (pstretch_dly2),
         .clk (pll_clk_out),
         .q   (pstretch_dly3));

   dff_ns  u_pstretch_dly4(
         .din (pstretch_dly3),
         .clk (pll_clk_out),
         .q   (pstretch_dly4));

   assign mstretch_pipe_nxt  =  (clk_stretch_trig_ff & mstretch_pipe[2]) | ~clk_stretch_trig_ff ? 3'b001:
                                {mstretch_pipe [1:0],1'b0};
  
   dff_ns #(2) u_mstretch_pipe_1_0 (
                  .din(mstretch_pipe_nxt[1:0]),
                  .clk (pll_clk_out),
                  .q (mstretch_pipe[1:0]));

   dff_ns u_mstretch_pipe_2 (
                  .din(mstretch_pipe_nxt[2]),
                  .clk (pll_clk_out),
                  .q (mstretch_pipe[2]));

   assign  mstretch_ff_nxt = clk_stretch_trig_ff & mstretch_pipe[2];
            
   dff_ns  u_mstretch_ff(
         .din (mstretch_ff_nxt),
         .clk (pll_clk_out),
         .q   (mstretch_ff));


  // patch for div 2

  assign pstretch_ff_nxt = clk_stretch_cnt_val_odd ? 
                           // special case for cnt of 3
                           (pstretch_dly  & stretch_cnt_vec[4]) | (pstretch_dly4 & ~stretch_cnt_vec[4]): 
                           // special case for cnt of 2
                           (pstretch_dly  & stretch_cnt_vec[0]) | (pstretch_dly4 & ~stretch_cnt_vec[0]);

  dff_ns  u_pstretch_ff(
         .din (pstretch_ff_nxt),
         .clk (pll_clk_out),
         .q   (pstretch_ff));

  assign clk_str_en_nxt =  ~(clk_stretch_cnt_val_6 ? mstretch_ff : pstretch_ff);

  // synchronizer pll_clk_out -> pll_clk_out_l
  bw_zzctu_sync stretch_sync(
                      // Outputs
                      .so               (),
                      .sob               (),
                      .out              (clk_str_pre_en_ffb),
                      // Inputs
                      .d                (clk_str_en_nxt),
                      .si               (),
                      .sib              (),
                      .pll_out          (pll_clk_out),
                      .pll_out_l        (pll_clk_out_l),
                      .se               (se));

dff_ns  clk_str_pre_en_pipe0(
		     .din (clk_str_en_nxt),
		     .clk (pll_clk_out),
		     .q   (clk_str_pre_en_ff));

dff_ns  clk_str_pre_en_pipe1(
		     .din (clk_str_pre_en_ff),
		     .clk (pll_clk_out),
		     .q   (clk_str_pre_en_ff_dly));

dff_ns #(3)  clk_str_en(
               	     .din ({3{clk_str_pre_en_ff_dly}}),
         	     .clk (pll_clk_out),
                     .q   (clk_str_en_ff[2:0]));

dff_ns #(3)  clk_str_enb(
		     .din ({3{clk_str_pre_en_ffb}}),
		     .clk (pll_clk_out_l),
		     .q   (clk_str_en_ffb[2:0]));

assign clk_str_en_buf[2:0] = clk_str_en_ff[2:0];
assign clk_str_en_buf_b[2:0] = clk_str_en_ffb[2:0];

/************************************************************
* divide pll output by 2 or 4 to produce cmp_gclk
************************************************************/
// ctrl signal changes on pll_clk_out_l
// cmp_div_bypass clock is on before pll reset state and start clock state

  ctu_and2   u_cmp_div_bypass_gated_bar_gated ( .a( pll_clk_out),
                                                .b( init_div_ff_dly3_neg),
                                                .z(cmp_div_bypass)
                                              );



/************************************************************
* cmp clock divider
************************************************************/

   ctu_clsp_clkgn_ddiv u_cmp_clk_ddiv(
		      // Outputs
		      .dom_div0		(cmp_div0_pre),
		      .dom_div1		(cmp_div1_pre),
		      .align_edge       (),
		      .align_edge_b     (),
		      .so		(),
		      // Inputs
		      .si		(),
		      .se		(se),
		      .div_dec          (cdiv_vec[14:0]),
		      .rst_b_l          (init_div_b_l & clsp_fstlog_corepll_c_0),
		      .rst_l            (init_div_l),
		      .stretch_l        (clk_str_en_buf[2]),
		      .stretch_b_l      (clk_str_en_buf_b[2]),
		      .pll_clk_out	(pll_clk_out),
		      .pll_clk_out_l	(pll_clk_out_l));

  dff_ns  u_cmp_div0_pre(
	 .din (cmp_div0_pre),
	 .clk (pll_clk_out),
	 .q   (cmp_div0));

  dff_ns  u_cmp_div1_pre(
	 .din (cmp_div1_pre),
	 .clk (pll_clk_out_l),
	 .q   (cmp_div1));



/************************************************************
* jbus divider
************************************************************/
ctu_clsp_clkgn_ddiv u_jbc_clk_ddiv(
		      // Outputs
		      .dom_div0		(jbus_div0_pre),
		      .dom_div1		(jbus_div1_pre),
		      .align_edge       (),
		      .align_edge_b     (),
		      .so		(),
		      // Inputs
		      .si		(),
		      .se		(se),
		      .div_dec          (jdiv_vec[14:0]),
		      .rst_b_l          (init_div_b_l & clsp_fstlog_corepll_j_0),
		      .rst_l            (init_div_l),
		      .stretch_l        (clk_str_en_buf[1]),
		      .stretch_b_l      (clk_str_en_buf_b[1]),
		      .pll_clk_out	(pll_clk_out),
		      .pll_clk_out_l	(pll_clk_out_l));
 

  assign  jbus_div0_muxed = init_div_ff_l ? jbus_div0_pre : jbus_dup_div0_pre;
  dff_ns  u_jbus_div0_pre(
	 .din (jbus_div0_muxed),
	 .clk (pll_clk_out),
	 .q   (jbus_div0));

  dff_ns  u_jbus_out(
         .din (jbus_div0),
         .clk (pll_clk_out),
         .q   (jbus_out));

  assign jbus_1sht = jbus_div0 & ~jbus_out;


  // low phase
  ctu_inv u_init_div_ff_dly2_neg_gated ( .a(init_div_ff_dly2_neg), .z(init_div_ff_dly2_neg_bar));
  ctu_and2 u_jbus_div_bypass_gated (.a (pll_clk_out), .b(init_div_ff_dly2_neg_bar), .z(jbus_div_bypass));

 // assign jbus_div_bypass  = pll_clk_out & ~init_div_ff_dly2_neg;

  // bypclksel is decoded off pll_bypass_pin or tap instr
  assign jbus_alt_bypsel_l = ~init_div_ff_l & bypclksel;


  assign  jbus_div1_muxed = init_div_ff_b_l ? jbus_div1_pre : 1'b0;
  dff_ns  u_jbus_div1_pre(
	 .din (jbus_div1_muxed),
	 .clk (pll_clk_out_l),
	 .q   (jbus_div1));

/************************************************************
* duplicate jbus divider for pll feedback - no clock stretch
************************************************************/
  ctu_clsp_clkgn_1div u_jbc_clk_dup_ddiv(
		      // Outputs
		      .dom_div		(jbus_dup_div0_pre),
		      .align_edge       (jdup_align_edge),
		      .align_edge_b     (jdup_align_edge_b),
		      .so		(),
		      // Inputs
		      .si		(),
		      .se		(se),
		      .div_dec          (jdiv_vec[14:0]),
		      //.init_l           (jdup_init_div_l),
		      .init_l           (1'b1),
		      .stretch_l        (1'b1),
		      .pll_clk          (pll_clk_out),
		      .pll_clk_l	(pll_clk_out_l));

  dff_ns  u_jbus_dup_div0_pre(
	 .din (jbus_dup_div0_pre),
	 .clk (pll_clk_out),
	 .q   (jbus_dup_div0));

  dff_ns  u_jbus_dup_out(
	 .din (jbus_dup_div0),
	 .clk (pll_clk_out),
	 .q   (jbus_dup_out));

  assign jbus_dup_1sht =  jbus_dup_div0 & ~jbus_dup_out;

/************************************************************
* dram divider
************************************************************/
ctu_clsp_clkgn_ddiv u_dram_clk_ddiv(
		      // Outputs
		      .dom_div0		(dram_div0_pre),
		      .dom_div1		(dram_div1_pre),
		      .align_edge       (),
		      .align_edge_b     (),
		      .so		(),
		      // Inputs
		      .si		(),
		      .se		(se),
		      .div_dec          (ddiv_vec[14:0]),
		      .rst_b_l          (init_div_b_l & clsp_fstlog_corepll_d_0),
		      .rst_l            (init_div_l),
		      .stretch_l        (clk_str_en_buf[0]),
		      .stretch_b_l      (clk_str_en_buf_b[0]),
		      .pll_clk_out	(pll_clk_out),
		      .pll_clk_out_l	(pll_clk_out_l));

  dff_ns  u_dram_div0_pre(
	 .din (dram_div0_pre),
	 .clk (pll_clk_out),
	 .q   (dram_div0));

  dff_ns  u_dram_div1_pre(
	 .din (dram_div1_pre),
	 .clk (pll_clk_out_l),
	 .q   (dram_div1));

/************************************************************
* clock  stretch count
************************************************************/

ctu_clsp_clkgn_1div u_stretch_counter(
		      // Outputs
		      .dom_div 	      (),
		      .align_edge     (pstretch),
		      .align_edge_b     (),
		      .so		(),
		      // Inputs
		      .si		(),
		      .se		(se),
		      //.div_dec          (stretch_cnt_vec_ff[14:0]),
		      .div_dec          (stretch_cnt_vec[14:0]),
		      .init_l           (pstretch_mode),
		      .stretch_l        (1'b1),
		      .pll_clk    	(pll_clk_out),
		      .pll_clk_l	(pll_clk_out_l));

/************************************************************
* Multicycle path checks
************************************************************/

 //synopsys translate_off

//    verify sync pulses for clk_stretch_trig is generated correctly 

     wire  enable_chk;
     assign  enable_chk = /* ( bw_pll.phase_locked === 1'b1) & */
                          ( `CTU_PATH.ctu_sel_cpu[0] === 1'b1) &
                          ( `CTU_PATH.ctu_sel_jbus[0] === 1'b1) &
                          ( `CTU_PATH.ctu_sel_dram[0] === 1'b1);

     ctu_sync_pulse_check  # (6, 0) u_clk_stretch_trig_check(    // setup , hold clocks
           .enable_chk(enable_chk) ,
           .rclk(pll_clk_out),     // receive clock
           .data(clk_stretch_trig_ff),      // data signal
           .lclk(`CTU_PATH.jbus_clk)   // launch clock 
     );

     ctu_sync_pulse_check  # (6, 0) u_start_clk_check (    // setup , hold clocks
           .enable_chk(enable_chk),
           .rclk(pll_clk_out),     // receive clock
           .data(start_clk_pre_ff),      // data signal
           .lclk(`CTU_PATH.jbus_clk)   // launch clock 
     );


  // check if cdiv, ddiv and jdiv only updated when update_shadow_cl is  1'b1
  // check if stretch_cnt_vec should not be updated when io_clk_stretch is 1'b1

       reg update_shadow_dly;
       always @(posedge `CTU_PATH.cmp_clk)
       begin
       if(~init_div_l)
           update_shadow_dly <= 1'b0;
       // else
           // update_shadow_dly <=  ctu_clsp_clkgn_shadreg.div_update_shadow_cl;
       end
 
       always @ (cdiv_vec)
          if ( (init_div_l === 1'b1) & (`CTU_PATH.io_pwron_rst_l === 1'b1) &  
               (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                ~update_shadow_dly)
		`ifdef MODELSIM
               $display ( "CTU_mpath_check_error", 
                        "cdiv_vec should be updated only when div_update_shadow_cl is 1'b1");
		`else
               $error ( "CTU_mpath_check_error", 
                        "cdiv_vec should be updated only when div_update_shadow_cl is 1'b1");
		`endif
       always @ (ddiv_vec)
          if ( (init_div_l === 1'b1) &  (`CTU_PATH.io_pwron_rst_l === 1'b1) &
               (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                ~update_shadow_dly)
		`ifdef MODELSIM
               $display ( "CTU_mpath_check_error", 
                        "ddiv_vec should be updated only when div_update_shadow_cl is 1'b1");
		`else
               $error ( "CTU_mpath_check_error", 
                        "ddiv_vec should be updated only when div_update_shadow_cl is 1'b1");
		`endif
       always @ (jdiv_vec)
          if ( (init_div_l === 1'b1) &   (`CTU_PATH.io_pwron_rst_l === 1'b1) &
               (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
               ~update_shadow_dly)
		`ifdef MODELSIM
               $display ( "CTU_mpath_check_error", 
                        "jdiv_vec should be updated only when div_update_shadow_cl is 1'b1");
		`else
               $error ( "CTU_mpath_check_error", 
                        "jdiv_vec should be updated only when div_update_shadow_cl is 1'b1");
		`endif
       always @ (stretch_cnt_vec )
          if ( (init_div_l === 1'b1) &  (`CTU_PATH.io_pwron_rst_l === 1'b1) &
               (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                `CTU_PATH.io_clk_stretch)
		`ifdef MODELSIM 
               $display ( "CTU_mpath_check_error", 
                        "stretch_cnt_vec should be updated when io_clk_stretch is 1'b1");
		`else
               $error ( "CTU_mpath_check_error", 
                        "stretch_cnt_vec should be updated when io_clk_stretch is 1'b1");
		`endif
       always @ (ctu_clsp_clkgn.shadreg_div_jmult)
          if ( (init_div_l === 1'b1)  & (`CTU_PATH.io_pwron_rst_l === 1'b1) &
               (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                ~update_shadow_dly)
		`ifdef MODELSIM 
               $display ( "CTU_mpath_check_error", 
                        "shadreg_div_jmult  should be updated only when mult_update_shadow_cl is 1'b1");
		`else
               $error ( "CTU_mpath_check_error", 
                        "shadreg_div_jmult  should be updated only when mult_update_shadow_cl is 1'b1");
		`endif
       always @ (ctu_clsp_clkgn.shadreg_div_dmult)
          if ( (init_div_l === 1'b1)  & (`CTU_PATH.io_pwron_rst_l === 1'b1) &
               (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                ~update_shadow_dly)
		`ifdef MODELSIM
               $display ( "CTU_mpath_check_error", 
                        "shadreg_div_dmult  should be updated only when mult_update_shadow_cl is 1'b1");
		`else
               $error ( "CTU_mpath_check_error", 
                        "shadreg_div_dmult  should be updated only when mult_update_shadow_cl is 1'b1");
		`endif
       always @ (ctu_clsp_clkgn.shadreg_div_cmult)
          if ( (init_div_l === 1'b1)  & (`CTU_PATH.io_pwron_rst_l === 1'b1) &
               (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
               ~update_shadow_dly)
		`ifdef MODELSIM
               $display ( "CTU_mpath_check_error", 
                        "shadreg_div_cmult  should be updated only when mult_update_shadow_cl is 1'b1");
		`else
               $error ( "CTU_mpath_check_error", 
                        "shadreg_div_cmult  should be updated only when mult_update_shadow_cl is 1'b1");
		`endif
       always @ (clsp_fstlog_corepll_j_0)
          if ( (init_div_l === 1'b1)  & (`CTU_PATH.io_pwron_rst_l === 1'b1) &
               (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                ~update_shadow_dly)
	 	`ifdef MODELSIM
               $display ( "CTU_mpath_check_error", 
                        "clsp_fstlog_corepll_j_0 should be updated only when div_update_shadow_cl is 1'b1");
		`else
               $error ( "CTU_mpath_check_error", 
                        "clsp_fstlog_corepll_j_0 should be updated only when div_update_shadow_cl is 1'b1");
		`endif
       always @ (clsp_fstlog_corepll_c_0)
          if ( (init_div_l === 1'b1)  & (`CTU_PATH.io_pwron_rst_l === 1'b1) &
               (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                ~update_shadow_dly)
		`ifdef MODELSIM
               $display ( "CTU_mpath_check_error", 
                        "clsp_fstlog_corepll_c_0 should be updated only when div_update_shadow_cl is 1'b1");
		`else
               $error ( "CTU_mpath_check_error", 
                        "clsp_fstlog_corepll_c_0 should be updated only when div_update_shadow_cl is 1'b1");
		`endif
       always @ (clsp_fstlog_corepll_d_0)
          if ( (init_div_l === 1'b1)  & (`CTU_PATH.io_pwron_rst_l === 1'b1) &
               (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                ~update_shadow_dly)
	 	`ifdef MODELSIM
               $display ( "CTU_mpath_check_error", 
                        "clsp_fstlog_corepll_d_0 should be updated only when div_update_shadow_cl is 1'b1");
		`else
               $error ( "CTU_mpath_check_error", 
                        "clsp_fstlog_corepll_d_0 should be updated only when div_update_shadow_cl is 1'b1");
		`endif

  // cmp_div0, dram_div0  should be zero on rising edge of start_clk_early_jl
       
       wire start_clk_early_jl_rising;
       reg prev_start_clk_early_jl;
       reg prev_cmp_div0, prev_dram_div0, prevv_cmp_div0, prevv_dram_div0;

       always @(posedge pll_clk_out)
       if(~init_div_l)
       begin
           {prevv_cmp_div0, prev_cmp_div0} <= 2'b00;
           {prevv_dram_div0, prev_dram_div0} <= 2'b00; 
       end
       else
       begin
          {prevv_cmp_div0, prev_cmp_div0} <=   {prev_cmp_div0, cmp_div0};
          {prevv_dram_div0, prev_dram_div0} <=   {prev_dram_div0, dram_div0};
       end

       always @( posedge ctu_clsp.start_clk_early_jl)
          begin
          if (  (cmp_div0 !== 1'b0) | (prev_cmp_div0 !== 1'b0) | (prevv_cmp_div0 !== 1'b0) & 
                (jdup_init_div_l === 1'b1) & (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0)
             )
		`ifdef MODELSIM  
               $display ( "CTU_mpath_check_error", 
                        "cmp clock should not start on rising edge of start_clk_early_jl");
		`else
               $error ( "CTU_mpath_check_error", 
                        "cmp clock should not start on rising edge of start_clk_early_jl");
		`endif
          if (  (dram_div0 !== 1'b0) | (prev_dram_div0 !== 1'b0) | (prevv_dram_div0 !== 1'b0) & 
                (jdup_init_div_l === 1'b1) & (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0)
             )
		`ifdef MODELSIM
               $display ( "CTU_mpath_check_error", 
                        "dram clock should not start on rising edge of start_clk_early_jl");
		`else
               $error ( "CTU_mpath_check_error", 
                        "dram clock should not start on rising edge of start_clk_early_jl");
		`endif
          end
 //synopsys translate_on
endmodule //clkfstlog 
// Local Variables:
// verilog-library-directories:("." "../../common/rtl")
// verilog-library-files:      ("../../common/rtl/swrvr_clib.v")
// verilog-auto-sense-defines-constant:t
// End:

