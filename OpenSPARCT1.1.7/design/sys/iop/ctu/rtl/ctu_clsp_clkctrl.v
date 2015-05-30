// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: ctu_clsp_clkctrl.v
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
/*
//  Module Name: clctrls
///////////////////////////////////////////////////////////////////////
*/

`include "sys.h"
`include "iop.h"
`include "ctu.h"

module ctu_clsp_clkctrl (/*AUTOARG*/
// Outputs
clsp_ctrl_rd_bus_cl, ctu_sparc0_cken_cl, ctu_sparc1_cken_cl, 
ctu_sparc2_cken_cl, ctu_sparc3_cken_cl, ctu_sparc4_cken_cl, 
ctu_sparc5_cken_cl, ctu_sparc6_cken_cl, ctu_sparc7_cken_cl, 
ctu_scdata0_cken_cl, ctu_scdata1_cken_cl, ctu_scdata2_cken_cl, 
ctu_scdata3_cken_cl, ctu_sctag0_cken_cl, ctu_sctag1_cken_cl, 
ctu_sctag2_cken_cl, ctu_sctag3_cken_cl, ctu_dram02_cken_cl, 
ctu_dram13_cken_cl, ctu_ccx_cken_cl, ctu_fpu_cken_cl, 
ctu_ddr0_cken_cl, ctu_ddr1_cken_cl, ctu_ddr2_cken_cl, 
ctu_ddr3_cken_cl, ctu_iob_cken_cl, ctu_efc_cken_cl, ctu_dbg_cken_cl, 
ctu_jbi_cken_cl, ctu_jbusl_cken_cl, ctu_misc_cken_cl, 
ctu_jbusr_cken_cl, ctu_io_j_err_cl, clkctrl_dn_cl, 
clsp_ctrl_srarm_cl, 
// Inputs
cmp_clk, io_pwron_rst_l, creg_cken_vld_cl, jbus_tx_sync, start_clk_cl, 
rstctrl_idle_cl, rstctrl_disclk_cl, rstctrl_enclk_cl, 
sctag0_ctu_tr_cl, sctag1_ctu_tr_cl, sctag2_ctu_tr_cl, 
sctag3_ctu_tr_cl, iob_ctu_tr_cl, dram02_ctu_tr_cl, dram13_ctu_tr_cl, 
jbi_ctu_tr_cl, iob_ctu_l2_tr_cl, dbgtrig_dly_cnt_val_cl, 
update_clkctrl_reg_cl, clkctrl_data_in_reg, rd_clkctrl_reg_cl, 
stop_id_vld_cl, stop_id_decoded
);

   //unit level signals

   
   
   input 	cmp_clk; 
   input        io_pwron_rst_l;
   input        creg_cken_vld_cl;
    
   input 	jbus_tx_sync;
   input        start_clk_cl;
   input 	rstctrl_idle_cl; 
   input 	rstctrl_disclk_cl; 
   input 	rstctrl_enclk_cl; 
   input 	sctag0_ctu_tr_cl;
   input 	sctag1_ctu_tr_cl;
   input 	sctag2_ctu_tr_cl;
   input 	sctag3_ctu_tr_cl;
   input 	iob_ctu_tr_cl;
   input 	dram02_ctu_tr_cl;
   input 	dram13_ctu_tr_cl;
   input 	jbi_ctu_tr_cl;
   input 	iob_ctu_l2_tr_cl;
   input [4:0]  dbgtrig_dly_cnt_val_cl;
   input        update_clkctrl_reg_cl;
   input [63:0] clkctrl_data_in_reg;
   input        rd_clkctrl_reg_cl;

   input        stop_id_vld_cl;
   input  [`CCTRLSM_MAX_ST-1:0] stop_id_decoded;

   output [63:0]  clsp_ctrl_rd_bus_cl;
   output 	ctu_sparc0_cken_cl; 
   output 	ctu_sparc1_cken_cl;
   output 	ctu_sparc2_cken_cl;
   output 	ctu_sparc3_cken_cl;
   output 	ctu_sparc4_cken_cl;
   output 	ctu_sparc5_cken_cl;
   output 	ctu_sparc6_cken_cl;
   output 	ctu_sparc7_cken_cl;
   output 	ctu_scdata0_cken_cl;
   output 	ctu_scdata1_cken_cl;
   output 	ctu_scdata2_cken_cl;
   output 	ctu_scdata3_cken_cl;
   output 	ctu_sctag0_cken_cl;
   output 	ctu_sctag1_cken_cl;
   output 	ctu_sctag2_cken_cl;
   output 	ctu_sctag3_cken_cl;
   output 	ctu_dram02_cken_cl;
   output 	ctu_dram13_cken_cl;
   output 	ctu_ccx_cken_cl;
   output 	ctu_fpu_cken_cl;
   output 	ctu_ddr0_cken_cl;
   output 	ctu_ddr1_cken_cl;
   output 	ctu_ddr2_cken_cl;
   output 	ctu_ddr3_cken_cl;
   output 	ctu_iob_cken_cl;
   output 	ctu_efc_cken_cl;
   output 	ctu_dbg_cken_cl;
   output 	ctu_jbi_cken_cl;
   output 	ctu_jbusl_cken_cl;
   output 	ctu_misc_cken_cl;
   output 	ctu_jbusr_cken_cl;
   output       ctu_io_j_err_cl;
   
   output 	clkctrl_dn_cl;  
   output       clsp_ctrl_srarm_cl;


   // wires 

    wire [`CCTRLSM_MAX_ST-1:0] stop_id_decoded_cl;
    wire [`CCTRLSM_MAX_ST-1:0] stop_id_decoded_cl_nxt;
    wire  dummy_unused;
    wire  clsp_ctrl_misc_en_cl;
    wire  clsp_ctrl_iob_en_cl;
    wire  clsp_ctrl_jbusr_en_cl;
    wire  clsp_ctrl_jbusl_en_cl;
    wire  clsp_ctrl_jbi_en_cl;
    wire  [3:0] clsp_ctrl_ddr_en_cl;
    wire  clsp_ctrl_fpu_en_cl;
    wire  clsp_ctrl_ccx_en_cl;
    wire  clsp_ctrl_efc_en_cl;
    wire  clsp_ctrl_dbg_en_cl;
    wire  [1:0] clsp_ctrl_dram_en_cl;
    wire  [3:0] clsp_ctrl_sctag_en_cl;
    wire  [3:0] clsp_ctrl_scdata_en_cl;
    wire  [7:0] clsp_ctrl_sparc_en_cl;
    wire clsp_ctrl_ossdis_cl;
    wire clsp_ctrl_clkdis_cl;
    wire  clsp_ctrl_misc_en_nxt;
    wire  clsp_ctrl_iob_en_nxt;
    wire  clsp_ctrl_jbusr_en_nxt;
    wire  clsp_ctrl_jbusl_en_nxt;
    wire  clsp_ctrl_jbi_en_nxt;
    wire  [3:0] clsp_ctrl_ddr_en_nxt;
    wire  clsp_ctrl_fpu_en_nxt;
    wire  clsp_ctrl_ccx_en_nxt;
    wire  clsp_ctrl_efc_en_nxt;
    wire  clsp_ctrl_dbg_en_nxt;
    wire  [1:0] clsp_ctrl_dram_en_nxt;
    wire  [3:0] clsp_ctrl_sctag_en_nxt;
    wire  [3:0] clsp_ctrl_scdata_en_nxt;
    wire  [7:0] clsp_ctrl_sparc_en_nxt;
    wire clsp_ctrl_ossdis_nxt;
    wire clsp_ctrl_clkdis_nxt;
    wire clsp_ctrl_srarm_nxt;
    wire [6:0] clsp_ctrl_clkstop_dly_nxt;
    wire [6:0] clsp_ctrl_clkstop_dly_cl;
   

   wire rstctrl_disclk_cl;
   wire rstctrl_disclk_cl_dly_l;
   wire rstctrl_disclk_tr;
   wire rstctrl_enclk_cl;
   wire rstctrl_enclk_cl_dly_l;
   wire rstctrl_enclk_cl_dly;
   wire rstctrl_enclk_tr;
   wire start_clk_cl;

   wire wr_state_pending_nxt;
   wire wr_state_pending;

   wire clk_dcnt_dn;
   wire clk_dcnt_dn_nxt;
   wire [6:0]  clk_dcnt_nxt;
   wire [6:0]  clk_dcnt;

   wire [4:0]  cluster_cnt_nxt;
   wire [4:0]  cluster_cnt;

   wire clk_start_seq_nxt;
   wire clk_start_seq;
   wire clk_stop_seq_nxt;
   wire clk_stop_seq;
   wire clk_stop_nxt;
   wire clk_stop;


   wire cctrl_state_ld;
   wire [`CCTRLSM_MAX_ST-1:0] nxt_cctrl_start_state ;
   wire [`CCTRLSM_MAX_ST-1:0] cctrl_start_state ;
   wire [`CCTRLSM_MAX_ST-1:0] nxt_cctrlsm;
   wire [`CCTRLSM_MAX_ST-1:0] cctrlsm;

   wire seq_dn;
   wire clkctrl_dn_cl_nxt;
   wire clkctrl_dn_cl;
   wire cctrl_enable_dly;
   wire cctrl_enable_nxt;
   wire cctrl_enable;
   wire cctrl_enable_1st_sht;
   wire stop_id_vld_cl_dly_l;
   wire stop_id_vld_1sht;
   wire stop_id_vld_1sht_dly;
   wire stop_id_vld_1sht_dly2;
   wire dbg_trig_nxt;
   wire dbg_trig;

   wire    [63:0] clsp_ctrl_rd_bus_nxt;
   wire    rd_clkctrl_reg_1sht;
   wire    rd_clkctrl_reg_cl_dly_l;

   wire 	ctu_sparc0_cken_nxt; 
   wire 	ctu_sparc1_cken_nxt;
   wire 	ctu_sparc2_cken_nxt;
   wire 	ctu_sparc3_cken_nxt;
   wire 	ctu_sparc4_cken_nxt;
   wire 	ctu_sparc5_cken_nxt;
   wire 	ctu_sparc6_cken_nxt;
   wire 	ctu_sparc7_cken_nxt;
   wire 	ctu_scdata0_cken_nxt;
   wire 	ctu_scdata1_cken_nxt;
   wire 	ctu_scdata2_cken_nxt;
   wire 	ctu_scdata3_cken_nxt;
   wire 	ctu_sctag0_cken_nxt;
   wire 	ctu_sctag1_cken_nxt;
   wire 	ctu_sctag2_cken_nxt;
   wire 	ctu_sctag3_cken_nxt;
   wire 	ctu_dram02_cken_nxt;
   wire 	ctu_dram13_cken_nxt;
   wire 	ctu_ccx_cken_nxt;
   wire 	ctu_fpu_cken_nxt;
   wire 	ctu_iob_cken_nxt;
   wire 	ctu_efc_cken_nxt;
   wire 	ctu_dbg_cken_nxt;
   wire 	ctu_jbi_cken_nxt;
   wire 	ctu_ddr2_cken_nxt;
   wire 	ctu_jbusl_cken_nxt;
   wire 	ctu_ddr0_cken_nxt;
   wire 	ctu_ddr1_cken_nxt;
   wire 	ctu_ddr3_cken_nxt;
   wire 	ctu_misc_cken_nxt;
   wire 	ctu_jbusr_cken_nxt;
   wire         ctu_jbusr_cken_cl_nxt;
   wire         ctu_jbusl_cken_cl_nxt;
   wire         ctu_misc_cken_cl_nxt;
   wire         ctu_dbg_cken_cl_nxt;
   wire dbg_trig_stop_clk_nxt;
   wire dbg_trig_stop_clk;
   wire dbg_trig_1sht;
   wire [4:0] dbg_trig_cnt_nxt;
   wire [4:0] dbg_trig_cnt;
   wire dbg_trig_dly_l;
   wire clk_start_cnt_dn;
   wire clk_stop_cnt_dn;
   wire dbg_trig_en;
   wire dbg_trig_en_nxt;


   parameter CLKCNTL_CNT =  7'b1111110;
   parameter CLUSTER_CNT =  5'b11110;

//-----------------------------------------------------------------------
//
//    output assignment
//
//-----------------------------------------------------------------------
  
   
   dff_ns u_rstctrl_disclk_dly(
		        .din (~rstctrl_disclk_cl),
		        .clk (cmp_clk),
                        .q(rstctrl_disclk_cl_dly_l)
                       );

   assign rstctrl_disclk_tr =  rstctrl_disclk_cl & rstctrl_disclk_cl_dly_l;

   dff_ns u_rstctrl_enclk_dly(
		        .din (rstctrl_enclk_cl),
		        .clk (cmp_clk),
                        .q(rstctrl_enclk_cl_dly)
                       );

   dff_ns u_rstctrl_enclk_dly_l(
		        .din (~rstctrl_enclk_cl_dly),
		        .clk (cmp_clk),
                        .q(rstctrl_enclk_cl_dly_l)
                       );

   assign rstctrl_enclk_tr =  rstctrl_enclk_cl_dly & rstctrl_enclk_cl_dly_l;

//-----------------------------------------------------------------------
//
//    JTAG instruction write
//
//-----------------------------------------------------------------------

   dff_ns u_stop_id_vld_1sht(
		        .din (~stop_id_vld_cl),
		        .clk (cmp_clk),
                        .q(stop_id_vld_cl_dly_l)
                       );

   assign stop_id_vld_1sht = stop_id_vld_cl & stop_id_vld_cl_dly_l;

   dff_ns u_stop_id_vld_1sht_dly(
		        .din (stop_id_vld_1sht),
		        .clk (cmp_clk),
                        .q(stop_id_vld_1sht_dly)
                       );

   dff_ns u_stop_id_vld_1sht_dly2(
		        .din (stop_id_vld_1sht_dly),
		        .clk (cmp_clk),
                        .q(stop_id_vld_1sht_dly2)
                       );

// stop_id_decoded needs to be stable for 2 cycles (relax layout requirement)
   
   assign  stop_id_decoded_cl_nxt = stop_id_vld_1sht_dly ?  stop_id_decoded :  stop_id_decoded_cl;

   dffrl_async_ns #(`CCTRLSM_MAX_ST)  u_stop_id_decoded_cl(
			 .din ( stop_id_decoded_cl_nxt),
			 .clk (cmp_clk),
                         .rst_l(io_pwron_rst_l),
			 .q ( stop_id_decoded_cl)
			 );

// state machine could be busy when jtag write top id instruction is issued

   assign wr_state_pending_nxt = (stop_id_vld_1sht & cctrl_enable  ? 1'b1:
                                 ~cctrl_enable  ?  1'b0:
                                 wr_state_pending) & start_clk_cl;
                                 
   dffrl_async_ns u_wr_state_pending(
			 .din (wr_state_pending_nxt),
			 .clk (cmp_clk),
                         .rst_l(io_pwron_rst_l),
			 .q (wr_state_pending)
			 );

//-----------------------------------------------------------------------
//
//    Debug triggers    
//
//-----------------------------------------------------------------------


   assign  dbg_trig_nxt = (
          sctag0_ctu_tr_cl |
          sctag1_ctu_tr_cl |
          sctag2_ctu_tr_cl |
          sctag3_ctu_tr_cl |
          dram02_ctu_tr_cl |
          dram13_ctu_tr_cl |
          iob_ctu_l2_tr_cl |
          iob_ctu_tr_cl |
          jbi_ctu_tr_cl ) & start_clk_cl;

    // Fix for ECO 6526 - Debug trigger does not get to J_ERR  (bug 6274).
    wire eco6526_dbg_trig_nxt = dbg_trig_nxt || (dbg_trig && !jbus_tx_sync);

    dff_ns u_ctu_io_j_err_cl (
			 .din (eco6526_dbg_trig_nxt),
			 .clk (cmp_clk),
			 .q (dbg_trig)
			 );

    dff_ns u_dbg_trig_dly(
			 .din (~dbg_trig),
			 .clk (cmp_clk),
			 .q (dbg_trig_dly_l)
			 );

    // gated with clsp_ctrl_clkdis_cl to mask unknown when dbg enable is off 
    assign dbg_trig_1sht =   dbg_trig & dbg_trig_dly_l  & clsp_ctrl_clkdis_cl ;

    // level signal
    //assign ctu_io_j_err_cl = dbg_trig &  clsp_ctrl_clkdis_cl;
    // bug 5732
    assign ctu_io_j_err_cl = dbg_trig;

//-----------------------------------------------------------------------
//
//    clk delay counter 
//
//-----------------------------------------------------------------------

    // depend on doing clock start stop or clock start load different counter value
    // cannot control clock start counts (always 128 cmp clocks)

    assign clk_start_cnt_dn = (clk_dcnt == CLKCNTL_CNT);
    assign clk_stop_cnt_dn =  (clk_dcnt == clsp_ctrl_clkstop_dly_cl);

    assign clk_dcnt_dn_nxt =  clk_stop_seq? clk_stop_cnt_dn: clk_start_cnt_dn;

    dffrl_ns u_clk_dcnt_dn (
                      .din ( clk_dcnt_dn_nxt),
                      .clk (cmp_clk),
                      .rst_l(start_clk_cl),
                      .q (clk_dcnt_dn));
  

    assign clk_dcnt_nxt =  clk_dcnt_dn ? 7'b0000000:
                           cctrl_enable_dly & (|(cluster_cnt[4:0]))? clk_dcnt + 7'b0000001 :
                           clk_dcnt;

    dffrl_ns #(7) u_clk_dcnt (
                      .din ( clk_dcnt_nxt),
                      .clk (cmp_clk),
                      .rst_l(start_clk_cl),
                      .q (clk_dcnt));

//-----------------------------------------------------------------------
//
//    dbg_trig_cnt
//
//-----------------------------------------------------------------------

//  when counter matches csr register dbg trigger delay count, dbg_trig_stop_clk
//  is asserted

    assign dbg_trig_en_nxt =  ~clsp_ctrl_clkdis_cl | dbg_trig_stop_clk_nxt ? 1'b0:
                                dbg_trig_1sht  ? 1'b1: 
                                dbg_trig_en;
                               
    dffrl_ns u_dbg_trig_en(
                      .din ( dbg_trig_en_nxt ),
                      .clk (cmp_clk),
                      .rst_l(start_clk_cl),
                      .q (dbg_trig_en));

    dffrl_ns u_dbg_trig_stop_clk(
                      .din ( dbg_trig_stop_clk_nxt ),
                      .clk (cmp_clk),
                      .rst_l(start_clk_cl),
                      .q (dbg_trig_stop_clk));
  
    assign dbg_trig_cnt_nxt = dbg_trig_en ?  dbg_trig_cnt + 5'b00001:
                              dbg_trig_1sht  ? 5'b00000:
                              dbg_trig_cnt;

    dffrl_ns #(5) u_dbg_trig_cnt(
                      .din ( dbg_trig_cnt_nxt[4:0] ),
                      .clk (cmp_clk),
                      .rst_l(start_clk_cl),
                      .q (dbg_trig_cnt[4:0]));

    assign dbg_trig_stop_clk_nxt  = (dbg_trig_cnt [4:0] == dbgtrig_dly_cnt_val_cl) 
                                   & clsp_ctrl_clkdis_cl & dbg_trig_en;


//-----------------------------------------------------------------------
//
//    cluster counter 
//
//-----------------------------------------------------------------------

    // This is created to  keep track of how many cluster are processed
    // instead of check if cctrlsm are all ones

    dffrl_ns u_seq_dn (
                      .din ( seq_dn_nxt),
                      .clk (cmp_clk),
                      .rst_l(start_clk_cl),
                      .q (seq_dn));
  
    assign cluster_cnt_nxt = cctrl_enable_1st_sht ? CLUSTER_CNT :
                             (|(cluster_cnt[4:0])  & clk_dcnt_dn) ? cluster_cnt - 5'b00001 :
                             cluster_cnt;

    dffrl_ns #(5) u_cluster_cnt(
                      .din ( cluster_cnt_nxt),
                      .clk (cmp_clk),
                      .rst_l(start_clk_cl),
                      .q (cluster_cnt));

    assign seq_dn_nxt = ~(|(cluster_cnt[4:1])) & clk_dcnt_dn;

//-----------------------------------------------------------------------
//
//    Clock start and stop logic
//
//-----------------------------------------------------------------------


//  clock could be disabled by raising debug trigger or freq change (rstsm) 
//  clk_stop_seq and clk_stop should be mutually exclusive

    // start on 1sht signal of the rstctrl state machine
    // start after any reset


    assign clk_start_seq_nxt = rstctrl_enclk_tr ? 1'b1:
                               seq_dn ? 1'b0:
                               clk_start_seq;

    dffrl_ns u_clk_start_seq( .din ( clk_start_seq_nxt),
                           .clk (cmp_clk),
                           .rst_l(start_clk_cl),
                           .q ( clk_start_seq)
                          );

    // stop on 1sht signal of the rstctrl state machine (before reset)

    // debug triggers will stop clk if clsp_ctrl_clkdis_cl is 1
    //assign dbg_stop = dbg_trig_stop_clk & clsp_ctrl_clkdis_cl;

    assign clk_stop_seq_nxt  = ((dbg_trig_stop_clk & ~clsp_ctrl_ossdis_cl )
                               | rstctrl_disclk_tr)  ? 1'b1:
                                 seq_dn ? 1'b0:
                                 clk_stop_seq;

    dffrl_ns u_clk_stop_seq( .din ( clk_stop_seq_nxt),
                           .clk (cmp_clk),
                           .rst_l(start_clk_cl),
                           .q ( clk_stop_seq)
                          );

//  clk_stop and clk_stop_seq cannot be 1 the same time
 
    assign clk_stop_nxt  = (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl ) & ~rstctrl_disclk_cl;

    dff_ns u_clk_stop( .din (clk_stop_nxt), .clk (cmp_clk), .q (clk_stop));


//-----------------------------------------------------------------------
//
//   clk ctrl state machine 
//
//-----------------------------------------------------------------------

     // default to IDLE state ; only load new id if cctrlsm is not enabled
      
      assign cctrl_state_ld = ( wr_state_pending | stop_id_vld_1sht_dly2) & ~cctrl_enable_dly; 

      assign nxt_cctrl_start_state = cctrl_state_ld ? stop_id_decoded_cl : cctrl_start_state;


     // default to SPARC0
      dffrl_ns #(`CCTRLSM_MAX_ST-1) u_cctrl_start_state_30_1(
                        .din (nxt_cctrl_start_state[`CCTRLSM_MAX_ST-1:1]),
                        .clk (cmp_clk),
                        .rst_l(start_clk_cl),
                        .q(cctrl_start_state[`CCTRLSM_MAX_ST-1:1])
                        );
     
      dffsl_ns u_cctrl_start_state_0(
                        .din (nxt_cctrl_start_state[0]),
                        .clk (cmp_clk),
                        .set_l(start_clk_cl),
                        .q(cctrl_start_state[0])
                        );

      assign nxt_cctrlsm=  cctrl_enable_1st_sht ? cctrl_start_state[`CCTRLSM_MAX_ST-1:0] :
                           ~seq_dn  & clk_dcnt_dn  ? ( cctrlsm[`CCTRLSM_MAX_ST-1:0] |
                             {cctrlsm[`CCTRLSM_MAX_ST-2:0],cctrlsm[`CCTRLSM_MAX_ST-1]})  :
                           seq_dn ? { `CCTRLSM_MAX_ST {1'b0}}:
                           cctrlsm[`CCTRLSM_MAX_ST-1:0];

      dffrl_ns #(`CCTRLSM_MAX_ST) u_cctrlsm(
                        .din (nxt_cctrlsm),
                        .clk (cmp_clk),
                        .rst_l(start_clk_cl),
                        .q(cctrlsm)
                        );


//-----------------------------------------------------------------------
//
//   clk enable logic
//
//-----------------------------------------------------------------------

      //  Do not want to change XX_en_cl bit during regular reset seq
      //  Only want to change the assertion/deassertion of cken
      //  XX_en_cl will be disabled upon the reception of debug trigger 
      //  cken will automatically disabled

      //  cken =1 when:
      //  1. during clock start seq and clsp_ctrl_X_en_cl is 1
      //     and its turn of arbitation
      //  2. clsp_ctrl_X_en_cl is one when finish clock start/stop seq
      //  cken =0 when:
      //  1. during clock stop seq and its turn  of arbitration to turn of clock
      //  2. clsp_ctrl_X_en_cl is zero when finish clock start/stop seq
      //     when dbg trigger is received, clsp_ctrl_X_en_cl becomes 0 

      assign ctu_sparc0_cken_nxt =  
           (clk_start_seq &  clsp_ctrl_sparc_en_cl[0] & cctrlsm[`CCTRL_SPARC0_POS]) |
           (clsp_ctrl_sparc_en_cl[0] & creg_cken_vld_cl) ? 1'b1:
           (clk_stop_seq &  cctrlsm[`CCTRL_SPARC0_POS] & rstctrl_disclk_cl) |
           (~clsp_ctrl_sparc_en_cl[0] & creg_cken_vld_cl) ? 1'b0:
         ctu_sparc0_cken_cl;

      assign ctu_sparc1_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_sparc_en_cl[1] & cctrlsm[`CCTRL_SPARC1_POS]) |
         (clsp_ctrl_sparc_en_cl[1] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SPARC1_POS] & rstctrl_disclk_cl) |
        (~clsp_ctrl_sparc_en_cl[1] & creg_cken_vld_cl) ? 1'b0:
         ctu_sparc1_cken_cl;

      assign ctu_sparc2_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_sparc_en_cl[2] & cctrlsm[`CCTRL_SPARC2_POS]) | 
         (clsp_ctrl_sparc_en_cl[2] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SPARC2_POS] & rstctrl_disclk_cl) |
        (~clsp_ctrl_sparc_en_cl[2] & creg_cken_vld_cl) ? 1'b0:
         ctu_sparc2_cken_cl;

      assign ctu_sparc3_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_sparc_en_cl[3] & cctrlsm[`CCTRL_SPARC3_POS]) | 
         (clsp_ctrl_sparc_en_cl[3] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SPARC3_POS] & rstctrl_disclk_cl) |
        (~clsp_ctrl_sparc_en_cl[3] & creg_cken_vld_cl) ? 1'b0:
         ctu_sparc3_cken_cl;

      assign ctu_sparc4_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_sparc_en_cl[4] & cctrlsm[`CCTRL_SPARC4_POS]) | 
         (clsp_ctrl_sparc_en_cl[4] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SPARC4_POS] & rstctrl_disclk_cl) |
        (~clsp_ctrl_sparc_en_cl[4] & creg_cken_vld_cl) ? 1'b0:
         ctu_sparc4_cken_cl;

      assign ctu_sparc5_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_sparc_en_cl[5] & cctrlsm[`CCTRL_SPARC5_POS]) | 
         (clsp_ctrl_sparc_en_cl[5] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SPARC5_POS] & rstctrl_disclk_cl) |
        (~clsp_ctrl_sparc_en_cl[5] & creg_cken_vld_cl) ? 1'b0:
         ctu_sparc5_cken_cl;

      assign ctu_sparc6_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_sparc_en_cl[6] & cctrlsm[`CCTRL_SPARC6_POS]) | 
         (clsp_ctrl_sparc_en_cl[6] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SPARC6_POS] & rstctrl_disclk_cl) |
        (~clsp_ctrl_sparc_en_cl[6] & creg_cken_vld_cl) ? 1'b0:
         ctu_sparc6_cken_cl;

      assign ctu_sparc7_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_sparc_en_cl[7] & cctrlsm[`CCTRL_SPARC7_POS]) | 
         (clsp_ctrl_sparc_en_cl[7] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SPARC7_POS] & rstctrl_disclk_cl) |
        (~clsp_ctrl_sparc_en_cl[7] & creg_cken_vld_cl) ? 1'b0:
         ctu_sparc7_cken_cl;

      assign ctu_scdata0_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_scdata_en_cl[0] & cctrlsm[`CCTRL_SCDATA0_POS]) | 
         (clsp_ctrl_scdata_en_cl[0] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SCDATA0_POS] & rstctrl_disclk_cl) |
        (~clsp_ctrl_scdata_en_cl[0] & creg_cken_vld_cl) ? 1'b0:
         ctu_scdata0_cken_cl;

      assign ctu_scdata1_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_scdata_en_cl[1] & cctrlsm[`CCTRL_SCDATA1_POS]) | 
         (clsp_ctrl_scdata_en_cl[1] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SCDATA1_POS] & rstctrl_disclk_cl) |
        (~clsp_ctrl_scdata_en_cl[1] & creg_cken_vld_cl) ? 1'b0:
         ctu_scdata1_cken_cl;

      assign ctu_scdata2_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_scdata_en_cl[2] & cctrlsm[`CCTRL_SCDATA2_POS]) | 
         (clsp_ctrl_scdata_en_cl[2] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SCDATA2_POS] & rstctrl_disclk_cl) |
        (~clsp_ctrl_scdata_en_cl[2] & creg_cken_vld_cl) ? 1'b0:
         ctu_scdata2_cken_cl;

      assign ctu_scdata3_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_scdata_en_cl[3] & cctrlsm[`CCTRL_SCDATA3_POS]) | 
         (clsp_ctrl_scdata_en_cl[3] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SCDATA3_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_scdata_en_cl[3] & creg_cken_vld_cl) ? 1'b0:
         ctu_scdata3_cken_cl;

      assign ctu_sctag0_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_sctag_en_cl[0] & cctrlsm[`CCTRL_SCTAG0_POS]) | 
         (clsp_ctrl_sctag_en_cl[0] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SCTAG0_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_sctag_en_cl[0] & creg_cken_vld_cl) ? 1'b0:
         ctu_sctag0_cken_cl;

      assign ctu_sctag1_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_sctag_en_cl[1] & cctrlsm[`CCTRL_SCTAG1_POS]) | 
         (clsp_ctrl_sctag_en_cl[1] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SCTAG1_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_sctag_en_cl[1] & creg_cken_vld_cl) ? 1'b0:
         ctu_sctag1_cken_cl;

      assign ctu_sctag2_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_sctag_en_cl[2] & cctrlsm[`CCTRL_SCTAG2_POS]) | 
         (clsp_ctrl_sctag_en_cl[2] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SCTAG2_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_sctag_en_cl[2] & creg_cken_vld_cl) ? 1'b0:
         ctu_sctag2_cken_cl;

      assign ctu_sctag3_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_sctag_en_cl[3] & cctrlsm[`CCTRL_SCTAG3_POS]) | 
         (clsp_ctrl_sctag_en_cl[3] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_SCTAG3_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_sctag_en_cl[3] & creg_cken_vld_cl) ? 1'b0:
         ctu_sctag3_cken_cl;

      assign ctu_dram02_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_dram_en_cl[0] & cctrlsm[`CCTRL_DRAM02_POS]) | 
         (clsp_ctrl_dram_en_cl[0] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_DRAM02_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_dram_en_cl[0] & creg_cken_vld_cl) ? 1'b0:
         ctu_dram02_cken_cl;

      assign ctu_dram13_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_dram_en_cl[1] & cctrlsm[`CCTRL_DRAM13_POS]) | 
         (clsp_ctrl_dram_en_cl[1] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_DRAM13_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_dram_en_cl[1] & creg_cken_vld_cl) ? 1'b0:
         ctu_dram13_cken_cl;

      assign ctu_ccx_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_ccx_en_cl & cctrlsm[`CCTRL_CCX_POS]) | 
         (clsp_ctrl_ccx_en_cl & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_CCX_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_ccx_en_cl & creg_cken_vld_cl) ? 1'b0:
         ctu_ccx_cken_cl;

      assign ctu_fpu_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_fpu_en_cl & cctrlsm[`CCTRL_FPU_POS]) | 
         (clsp_ctrl_fpu_en_cl & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_FPU_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_fpu_en_cl & creg_cken_vld_cl) ? 1'b0:
         ctu_fpu_cken_cl;

      assign ctu_ddr0_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_ddr_en_cl[0] & cctrlsm[`CCTRL_DDR0_POS]) | 
         (clsp_ctrl_ddr_en_cl[0] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_DDR0_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_ddr_en_cl[0] & creg_cken_vld_cl) ? 1'b0:
         ctu_ddr0_cken_cl;

      assign ctu_ddr1_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_ddr_en_cl[1] & cctrlsm[`CCTRL_DDR1_POS]) | 
         (clsp_ctrl_ddr_en_cl[1] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_DDR1_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_ddr_en_cl[1] & creg_cken_vld_cl) ? 1'b0:
         ctu_ddr1_cken_cl;

      assign ctu_ddr2_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_ddr_en_cl[2] & cctrlsm[`CCTRL_DDR2_POS]) | 
         (clsp_ctrl_ddr_en_cl[2] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_DDR2_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_ddr_en_cl[2] & creg_cken_vld_cl) ? 1'b0:
         ctu_ddr2_cken_cl;

      assign ctu_ddr3_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_ddr_en_cl[3] & cctrlsm[`CCTRL_DDR3_POS]) | 
         (clsp_ctrl_ddr_en_cl[3] & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_DDR3_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_ddr_en_cl[3] & creg_cken_vld_cl) ? 1'b0:
         ctu_ddr3_cken_cl;

      assign ctu_jbi_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_jbi_en_cl & cctrlsm[`CCTRL_JBI_POS]) | 
         (clsp_ctrl_jbi_en_cl & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_JBI_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_jbi_en_cl  & creg_cken_vld_cl) ? 1'b0:
         ctu_jbi_cken_cl;

      // DO not want to disable clock during regular reset sequence
      // jbusr, jbusl, dbg and misc
      assign ctu_jbusr_cken_nxt =  
          (clsp_ctrl_jbusr_en_cl & creg_cken_vld_cl) ? 1'b1:
         (~clsp_ctrl_jbusr_en_cl & creg_cken_vld_cl) ? 1'b0:
         ctu_jbusr_cken_cl;

      assign ctu_jbusl_cken_nxt =  
         (clsp_ctrl_jbusl_en_cl & creg_cken_vld_cl) ? 1'b1:
         (~clsp_ctrl_jbusl_en_cl & creg_cken_vld_cl) ? 1'b0:
         ctu_jbusl_cken_cl;

      assign ctu_iob_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_iob_en_cl & cctrlsm[`CCTRL_IOB_POS]) | 
         (clsp_ctrl_iob_en_cl & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_IOB_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_iob_en_cl & creg_cken_vld_cl) ? 1'b0:
         ctu_iob_cken_cl;

      assign ctu_efc_cken_nxt =  
         (clk_start_seq &  clsp_ctrl_efc_en_cl & cctrlsm[`CCTRL_EFC_POS]) | 
         (clsp_ctrl_efc_en_cl & creg_cken_vld_cl) ? 1'b1:
         (clk_stop_seq &  cctrlsm[`CCTRL_EFC_POS] & rstctrl_disclk_cl) |
         (~clsp_ctrl_efc_en_cl & creg_cken_vld_cl) ? 1'b0:
         ctu_efc_cken_cl;


       assign ctu_dbg_cken_nxt =
         (clsp_ctrl_dbg_en_cl & creg_cken_vld_cl) ? 1'b1:
         (~clsp_ctrl_dbg_en_cl & creg_cken_vld_cl) ? 1'b0:
         ctu_dbg_cken_cl;


       assign ctu_misc_cken_nxt =
         (clsp_ctrl_misc_en_cl & creg_cken_vld_cl) ? 1'b1:
         (~clsp_ctrl_misc_en_cl & creg_cken_vld_cl) ? 1'b0:
         ctu_misc_cken_cl;



      dffrl_ns u_ctu_sparc0_cken( .din (ctu_sparc0_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                              .q(ctu_sparc0_cken_cl));

      dffrl_ns u_ctu_sparc1_cken( .din (ctu_sparc1_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_sparc1_cken_cl));

      dffrl_ns u_ctu_sparc2_cken( .din (ctu_sparc2_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_sparc2_cken_cl));

      dffrl_ns u_ctu_sparc3_cken( .din (ctu_sparc3_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_sparc3_cken_cl));

      dffrl_ns u_ctu_sparc4_cken( .din (ctu_sparc4_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_sparc4_cken_cl));

      dffrl_ns u_ctu_sparc5_cken( .din (ctu_sparc5_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_sparc5_cken_cl));

      dffrl_ns u_ctu_sparc6_cken( .din (ctu_sparc6_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_sparc6_cken_cl));

      dffrl_ns u_ctu_sparc7_cken( .din (ctu_sparc7_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_sparc7_cken_cl));

      dffrl_ns u_ctu_scdata0_cken( .din (ctu_scdata0_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                              .q(ctu_scdata0_cken_cl));

      dffrl_ns u_ctu_scdata1_cken( .din (ctu_scdata1_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_scdata1_cken_cl));

      dffrl_ns u_ctu_scdata2_cken( .din (ctu_scdata2_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_scdata2_cken_cl));

      dffrl_ns u_ctu_scdata3_cken( .din (ctu_scdata3_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_scdata3_cken_cl));

      dffrl_ns u_ctu_sctag0_cken( .din (ctu_sctag0_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                              .q(ctu_sctag0_cken_cl));

      dffrl_ns u_ctu_sctag1_cken( .din (ctu_sctag1_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_sctag1_cken_cl));

      dffrl_ns u_ctu_sctag2_cken( .din (ctu_sctag2_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_sctag2_cken_cl));

      dffrl_ns u_ctu_sctag3_cken( .din (ctu_sctag3_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_sctag3_cken_cl));

      dffrl_ns u_ctu_dram02_cken( .din (ctu_dram02_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_dram02_cken_cl));

      dffrl_ns u_ctu_dram13_cken( .din (ctu_dram13_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_dram13_cken_cl));

      dffrl_ns u_ctu_ccx_cken( .din (ctu_ccx_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_ccx_cken_cl));

      dffrl_ns u_ctu_fpu_cken( .din (ctu_fpu_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_fpu_cken_cl));

      dffrl_ns u_ctu_ddr0_cken( .din (ctu_ddr0_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                              .q(ctu_ddr0_cken_cl));

      dffrl_ns u_ctu_ddr1_cken( .din (ctu_ddr1_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_ddr1_cken_cl));

      dffrl_ns u_ctu_ddr2_cken( .din (ctu_ddr2_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_ddr2_cken_cl));

      dffrl_ns u_ctu_ddr3_cken( .din (ctu_ddr3_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_ddr3_cken_cl));

      dffrl_ns u_ctu_jbi_cken( .din (ctu_jbi_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_jbi_cken_cl));

      assign ctu_jbusr_cken_cl_nxt = start_clk_cl ? ctu_jbusr_cken_nxt: 1'b1;

      dffsl_async_ns u_ctu_jbusr_cken( .din (ctu_jbusr_cken_cl_nxt), 
                                .clk (cmp_clk), 
                                .set_l(io_pwron_rst_l),
                                .q(ctu_jbusr_cken_cl));

      assign ctu_jbusl_cken_cl_nxt = start_clk_cl ? ctu_jbusl_cken_nxt: 1'b1;
      dffsl_async_ns u_ctu_jbusl_cken( .din (ctu_jbusl_cken_cl_nxt), 
                                .clk (cmp_clk), 
                                .set_l(io_pwron_rst_l),
                                .q(ctu_jbusl_cken_cl));

      dffrl_ns u_ctu_iob_cken( .din (ctu_iob_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_iob_cken_cl));

      dffrl_ns u_ctu_efc_cken( .din (ctu_efc_cken_nxt), 
                                .clk (cmp_clk), 
                                .rst_l(start_clk_cl),
                                .q(ctu_efc_cken_cl));

      assign ctu_dbg_cken_cl_nxt = start_clk_cl ? ctu_dbg_cken_nxt: 1'b1;

      dffsl_async_ns u_ctu_dbg_cken( .din (ctu_dbg_cken_cl_nxt),
                                .clk (cmp_clk),
                                .set_l(io_pwron_rst_l),
                                .q(ctu_dbg_cken_cl));

      assign ctu_misc_cken_cl_nxt = start_clk_cl ? ctu_misc_cken_nxt: 1'b1;

      dffsl_async_ns u_ctu_misc_cken( .din (ctu_misc_cken_cl_nxt),
                                .clk (cmp_clk),
                                .set_l(io_pwron_rst_l),
                                .q(ctu_misc_cken_cl));


//-----------------------------------------------------------------------
//
//    Check if all component are done
//
//-----------------------------------------------------------------------

      // reset by pll locked ; set by all of cctrlsm states processed

      // clkctrl_dn is reset by pll_locked after reset , or idle state 

      assign  clkctrl_dn_cl_nxt  =   seq_dn | clk_stop  ? 1'b1:
                                 rstctrl_idle_cl ? 1'b0:
                                 clkctrl_dn_cl;
      dffrl_ns u_clkctrl_dn_cl( 
                      .din (clkctrl_dn_cl_nxt),
                      .clk (cmp_clk),
                      .rst_l(start_clk_cl),
                      .q(clkctrl_dn_cl));

      // signal to tell when cctrlsm is active
      assign  cctrl_enable_nxt =  seq_dn ?  1'b0:
                                  (clk_start_seq | clk_stop_seq) & ~cctrl_enable ? 1'b1:
                                  cctrl_enable;
                       
      dffrl_ns u_cctrl_enable( 
                      .din (cctrl_enable_nxt),
                      .clk (cmp_clk),
                      .rst_l(start_clk_cl),
                      .q(cctrl_enable));

      dff_ns u_cctrl_enable_dly( 
                      .din (cctrl_enable),
                      .clk (cmp_clk),
                      .q(cctrl_enable_dly));

      assign cctrl_enable_1st_sht = cctrl_enable & ~cctrl_enable_dly;


   
//---------------------------------------------------------------------------
//
// Register : Clock control
//
//---------------------------------------------------------------------------

// OSSDIS  63
// CLKDIS  62
// SRARM   61
// CLKSTOPDLY 54:48
// MISC    34 
// RTBI    33
// IOB     31
// JBUSR   30
// JBUSL   29
// JBI     27
// DDR     23:20
// FPU     19    
// CCX     18    
// DRAM    17:16 
// SCTAG   15:12 
// SCDATA  11:8  
// SPARCORE 7:0  



assign clsp_ctrl_ossdis_nxt = update_clkctrl_reg_cl ? clkctrl_data_in_reg[63]:
                              clsp_ctrl_ossdis_cl;

dffsl_async_ns u_clsp_ctrl_ossdis_cl_ff (.din(clsp_ctrl_ossdis_nxt),
                                .clk(cmp_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_ossdis_cl)
                               );

assign clsp_ctrl_clkdis_nxt = update_clkctrl_reg_cl ? clkctrl_data_in_reg[62]:
                            clsp_ctrl_clkdis_cl;

dffrl_async_ns u_clsp_ctrl_clkdis_cl_ff (.din(clsp_ctrl_clkdis_nxt), 
                                .clk(cmp_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_clkdis_cl)
                               );

assign clsp_ctrl_srarm_nxt = update_clkctrl_reg_cl ? clkctrl_data_in_reg[61]:
                             clsp_ctrl_srarm_cl;

dffrl_async_ns u_clsp_ctrl_srarm_cl_ff (.din(clsp_ctrl_srarm_nxt),
                                .clk(cmp_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_srarm_cl)
                               );


assign clsp_ctrl_clkstop_dly_nxt = update_clkctrl_reg_cl ? clkctrl_data_in_reg[54:48]:
                                   clsp_ctrl_clkstop_dly_cl;

dffsl_async_ns #(7) u_clsp_ctrl_clkstop_dly (.din(clsp_ctrl_clkstop_dly_nxt),
                                .clk(cmp_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_clkstop_dly_cl)
                               );

//---------------------------------------------------------------------------
//
//  Clock enable csr control
//
//---------------------------------------------------------------------------

//  default to 1 before clock start
assign  clsp_ctrl_misc_en_nxt = ~start_clk_cl? 1'b1:
                                //  after received dbg trigger and csr is programmed to stop in seq
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_MISC_POS]) |
                                //  after received dbg trigger and csr is programmed to stop in one shot
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                //  update csr register
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[34] :
                                 clsp_ctrl_misc_en_cl;

dffsl_async_ns u_clsp_ctrl_misc_en_ff ( .din(clsp_ctrl_misc_en_nxt ), 
                                 .clk(cmp_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (clsp_ctrl_misc_en_cl)
                               );
 
assign  clsp_ctrl_efc_en_nxt =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_EFC_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                update_clkctrl_reg_cl ? clkctrl_data_in_reg[32]:
                                clsp_ctrl_efc_en_cl;

dffsl_async_ns u_clsp_ctrl_efc_en_ff ( .din(clsp_ctrl_efc_en_nxt ), 
                                 .clk(cmp_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (clsp_ctrl_efc_en_cl)
                               );

assign  clsp_ctrl_dbg_en_nxt =   ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_DBG_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[33]:
                                 clsp_ctrl_dbg_en_cl;

dffsl_async_ns u_clsp_ctrl_dbg_en_ff ( .din(clsp_ctrl_dbg_en_nxt ), 
                                 .clk(cmp_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (clsp_ctrl_dbg_en_cl)
                               );

assign  clsp_ctrl_iob_en_nxt =   ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_IOB_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[31]:
                                 clsp_ctrl_iob_en_cl;

dffsl_async_ns u_clsp_ctrl_iob_en_ff ( .din(clsp_ctrl_iob_en_nxt ), 
                                 .clk(cmp_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (clsp_ctrl_iob_en_cl)
                               );
 
assign  clsp_ctrl_jbusr_en_nxt =  ~start_clk_cl? 1'b1: 
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_JBUSR_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                update_clkctrl_reg_cl ? clkctrl_data_in_reg[30]
                             :  clsp_ctrl_jbusr_en_cl;

dffsl_async_ns u_clsp_ctrl_jbusr_en_ff (.din(clsp_ctrl_jbusr_en_nxt ), 
                                 .clk(cmp_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (clsp_ctrl_jbusr_en_cl)
                                );

assign  clsp_ctrl_jbusl_en_nxt =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_JBUSL_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                update_clkctrl_reg_cl ? clkctrl_data_in_reg[29]
                             :  clsp_ctrl_jbusl_en_cl;

dffsl_async_ns u_clsp_ctrl_jbusl_en_ff ( .din(clsp_ctrl_jbusl_en_nxt ), 
                                 .clk(cmp_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (clsp_ctrl_jbusl_en_cl)
                               );

assign  clsp_ctrl_jbi_en_nxt =   ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_JBI_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[27]:
                                clsp_ctrl_jbi_en_cl;

dffsl_async_ns u_clsp_ctrl_jbi_en_ff ( .din(clsp_ctrl_jbi_en_nxt ), 
                                .clk(cmp_clk),
                                 .set_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_jbi_en_cl)
                              );

 
assign       clsp_ctrl_ddr_en_nxt[3]  = ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_DDR3_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[23]:
                                 clsp_ctrl_ddr_en_cl[3];
assign       clsp_ctrl_ddr_en_nxt[2]  =   ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_DDR2_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[22]:
                                 clsp_ctrl_ddr_en_cl[2];
assign       clsp_ctrl_ddr_en_nxt[1]  = ~start_clk_cl? 1'b1:  
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_DDR1_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[21]:
                                 clsp_ctrl_ddr_en_cl[1];
assign       clsp_ctrl_ddr_en_nxt[0]  =  ~start_clk_cl? 1'b1: 
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_DDR0_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[20]:
                                 clsp_ctrl_ddr_en_cl[0];


dffsl_async_ns #(4) u_clsp_ctrl_ddr_en_ff ( .din(clsp_ctrl_ddr_en_nxt ), 
                                .clk(cmp_clk),
                                 .set_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_ddr_en_cl)
                              );
 
assign    clsp_ctrl_fpu_en_nxt = ~start_clk_cl? 1'b1: 
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_FPU_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[19]:
                                 clsp_ctrl_fpu_en_cl;

dffsl_async_ns  u_clsp_ctrl_fpu_en_ff ( .din(clsp_ctrl_fpu_en_nxt ), 
                                .clk(cmp_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_fpu_en_cl)
                              );

assign    clsp_ctrl_ccx_en_nxt = ~start_clk_cl? 1'b1: 
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_CCX_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[18]:
                                 clsp_ctrl_ccx_en_cl;

dffsl_async_ns  u_clsp_ctrl_ccx_en_ff ( .din(clsp_ctrl_ccx_en_nxt ), 
                                .clk(cmp_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_ccx_en_cl)
                              );
 
assign    clsp_ctrl_dram_en_nxt[1]  = ~start_clk_cl? 1'b1:  
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_DRAM13_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[17]:
                                 clsp_ctrl_dram_en_cl[1];

assign    clsp_ctrl_dram_en_nxt[0]  =   ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_DRAM02_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
                                 update_clkctrl_reg_cl ? clkctrl_data_in_reg[16]:
                                 clsp_ctrl_dram_en_cl[0];

dffsl_async_ns  #(2) u_clsp_ctrl_dram_en_ff ( .din(clsp_ctrl_dram_en_nxt ), 
                                .clk(cmp_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_dram_en_cl)
                              );

assign    clsp_ctrl_sctag_en_nxt[3] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SCTAG3_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
      				update_clkctrl_reg_cl ? clkctrl_data_in_reg[15]:
                                 clsp_ctrl_sctag_en_cl[3];

assign    clsp_ctrl_sctag_en_nxt[2] =   ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SCTAG2_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[14]:
                                clsp_ctrl_sctag_en_cl[2];

assign    clsp_ctrl_sctag_en_nxt[1] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SCTAG1_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[13]:
                                clsp_ctrl_sctag_en_cl[1];

assign    clsp_ctrl_sctag_en_nxt[0] =   ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SCTAG0_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[12]:
                                clsp_ctrl_sctag_en_cl[0];

dffsl_async_ns  #(4) u_clsp_ctrl_sctag_en_ff ( .din(clsp_ctrl_sctag_en_nxt ), 
                                .clk(cmp_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_sctag_en_cl)
                              );

assign    clsp_ctrl_scdata_en_nxt[3] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SCDATA3_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[11]:
                                clsp_ctrl_scdata_en_cl[3];
assign    clsp_ctrl_scdata_en_nxt[2] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SCDATA2_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[10]:
                                clsp_ctrl_scdata_en_cl[2];
assign    clsp_ctrl_scdata_en_nxt[1] =   ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SCDATA1_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[9]:
                                clsp_ctrl_scdata_en_cl[1];
assign    clsp_ctrl_scdata_en_nxt[0] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SCDATA0_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[8]:
                                clsp_ctrl_scdata_en_cl[0];

dffsl_async_ns  #(4) u_clsp_ctrl_scdata_en_ff ( .din(clsp_ctrl_scdata_en_nxt ), 
                                .clk(cmp_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_scdata_en_cl)
                              );

assign    clsp_ctrl_sparc_en_nxt[7] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SPARC7_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[7]:
                                clsp_ctrl_sparc_en_cl[7];
assign    clsp_ctrl_sparc_en_nxt[6] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SPARC6_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[6]:
                                clsp_ctrl_sparc_en_cl[6];
assign    clsp_ctrl_sparc_en_nxt[5] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SPARC5_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[5]:
                                clsp_ctrl_sparc_en_cl[5];
assign    clsp_ctrl_sparc_en_nxt[4] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SPARC4_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[4]:
                                clsp_ctrl_sparc_en_cl[4];
assign    clsp_ctrl_sparc_en_nxt[3] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SPARC3_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[3]:
                                clsp_ctrl_sparc_en_cl[3];
assign    clsp_ctrl_sparc_en_nxt[2] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SPARC2_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[2]:
                                clsp_ctrl_sparc_en_cl[2];
assign    clsp_ctrl_sparc_en_nxt[1] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SPARC1_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[1]:
                                clsp_ctrl_sparc_en_cl[1];
assign    clsp_ctrl_sparc_en_nxt[0] =  ~start_clk_cl? 1'b1:
                                (clk_stop_seq &  ~rstctrl_disclk_cl  & cctrlsm[`CCTRL_SPARC0_POS]) |
                                (dbg_trig_stop_clk & clsp_ctrl_ossdis_cl) ? 1'b0:
				update_clkctrl_reg_cl ? clkctrl_data_in_reg[0]:
                                clsp_ctrl_sparc_en_cl[0];

dffsl_async_ns  #(8) u_clsp_ctrl_sparc_en_ff ( .din(clsp_ctrl_sparc_en_nxt ), 
                                .clk(cmp_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ctrl_sparc_en_cl)
                              );

dff_ns u_rd_clkctrl_reg_1sht ( .din(~rd_clkctrl_reg_cl), 
                                .clk(cmp_clk),
                                .q (rd_clkctrl_reg_cl_dly_l)
                              );
assign rd_clkctrl_reg_1sht =  rd_clkctrl_reg_cl & rd_clkctrl_reg_cl_dly_l;

assign clsp_ctrl_rd_bus_nxt    =  { clsp_ctrl_ossdis_cl,
                               clsp_ctrl_clkdis_cl,
                               clsp_ctrl_srarm_cl,
                               6'b000000,
                               clsp_ctrl_clkstop_dly_cl[6:0],
                               13'b0000000000000,
                               clsp_ctrl_misc_en_cl,
                               clsp_ctrl_dbg_en_cl,
                               clsp_ctrl_efc_en_cl,
                               clsp_ctrl_iob_en_cl,
                               clsp_ctrl_jbusr_en_cl,
                               clsp_ctrl_jbusl_en_cl,
                               1'b0,
                               clsp_ctrl_jbi_en_cl,
                               3'b000,
                               clsp_ctrl_ddr_en_cl[3:0],
                               clsp_ctrl_fpu_en_cl,
                               clsp_ctrl_ccx_en_cl,
                               clsp_ctrl_dram_en_cl[1:0],
                               clsp_ctrl_sctag_en_cl[3:0],
                               clsp_ctrl_scdata_en_cl[3:0],
                               clsp_ctrl_sparc_en_cl[7:0]};



dffrle_ns #(64) u_clsp_ctrl_rd_bus (  .din(clsp_ctrl_rd_bus_nxt), 
                                .clk(cmp_clk),
                                .en(rd_clkctrl_reg_1sht),
                                .rst_l(start_clk_cl),
                                .q (clsp_ctrl_rd_bus_cl)
                              );

assign  dummy_unused = &{clkctrl_data_in_reg[60:55],clkctrl_data_in_reg[47:24]};

//-----------------------------------------------------------------------
//
//    Multicycle path checks
//
//-----------------------------------------------------------------------

// synopsys translate_off

     reg  [`CCTRLSM_MAX_ST-1:0] prev_stop_id_decoded;
      //top_id_decoded needs to hold at least 2 cmp clocks
      always @(stop_id_vld_cl)
        begin
             prev_stop_id_decoded <= stop_id_decoded;
             @(posedge cmp_clk)
               if( (start_clk_cl  === 1'b1) &
                   (`CTU_PATH.pll_bypass === 1'b0) & ( `CTU_PATH.testmode_l === 1'b1) &
                   ( prev_stop_id_decoded !==  stop_id_decoded)
                 )
		`ifdef MODELSIM	   
               $display ( "CTU_mpath_check_error", "stop_id_decoded should hold for at least 2 cmp cycles");
		`else	   
               $error ( "CTU_mpath_check_error", "stop_id_decoded should hold for at least 2 cmp cycles");
		`endif
             @(posedge cmp_clk)
               if( (start_clk_cl  === 1'b1) &
                   (`CTU_PATH.pll_bypass === 1'b0) & ( `CTU_PATH.testmode_l === 1'b1) &
                   ( prev_stop_id_decoded !==  stop_id_decoded)
                 )
		`ifdef MODELSIM
               $display ( "CTU_mpath_check_error", "stop_id_decoded should hold for at least 2 cmp cycles");
		`else	   
               $error ( "CTU_mpath_check_error", "stop_id_decoded should hold for at least 2 cmp cycles");
		`endif
        end

        // clk_stop and clk_stop_seq should be exclusive

        always @(/*AUTOSENSE*/clk_stop or clk_stop_seq
		 or `CTU_PATH.pll_bypass or `CTU_PATH.testmode_l or start_clk_cl)
        begin
            if( (start_clk_cl === 1'b1) &  
                (`CTU_PATH.pll_bypass === 1'b0) & ( `CTU_PATH.testmode_l === 1'b1) &
                 (clk_stop === 1'b1) &  (clk_stop_seq=== 1'b1) )
		`ifdef MODELSIM
             $display ( "CTU_logic_check_err",  " clk_stop &  clk_stop_seq cannot be 1 at the same time");
		`else	 
             $error ( "CTU_logic_check_err",  " clk_stop &  clk_stop_seq cannot be 1 at the same time");
		`endif
        end

// synopsys translate_on

endmodule //  clkctrl








