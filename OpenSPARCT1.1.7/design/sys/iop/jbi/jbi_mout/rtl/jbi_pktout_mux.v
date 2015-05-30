// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_pktout_mux.v
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
// _____________________________________________________________________________
//
// jbi_pktout_mux -- Format J_ADTYPE and J_AD data from various sources.
// _____________________________________________________________________________
//

`include "sys.h"
`include "jbi.h"


module jbi_pktout_mux (/*AUTOARG*/
  // Outputs
  jbi_io_j_adtype, jbi_io_j_ad, jbi_io_j_adp, 
  // Inputs
  sel_queue, sel_j_adbus, sct0rdq_install_state, sct0rdq_unmapped_error, 
  sct0rdq_jid, sct0rdq_data, sct0rdq_ue_err, sct1rdq_install_state, 
  sct1rdq_unmapped_error, sct1rdq_jid, sct1rdq_data, sct1rdq_ue_err, 
  sct2rdq_install_state, sct2rdq_unmapped_error, sct2rdq_jid, sct2rdq_data, 
  sct2rdq_ue_err, sct3rdq_install_state, sct3rdq_unmapped_error, sct3rdq_jid, 
  sct3rdq_data, sct3rdq_ue_err, ncio_pio_ue, ncio_pio_be, ncio_pio_ad, 
  ncio_mondo_agnt_id, ncio_mondo_cpu_id, dbg_data, unused_jid, inj_err_j_ad, 
  csr_jbi_debug_info_enb, thread_id, sct0rdq_trans_count, sct1rdq_trans_count, 
  sct2rdq_trans_count, sct3rdq_trans_count, ncio_prqq_level, ncio_makq_level, 
  clk
  );

  `include "jbi_mout.h"

  // Select.
  input    [2:0] sel_queue;
  input    [3:0] sel_j_adbus;

  // Input sources
  // SCT0 RDQ.
  input          sct0rdq_install_state;
  input          sct0rdq_unmapped_error;
  input    [5:0] sct0rdq_jid;
  input  [127:0] sct0rdq_data;
  input 	 sct0rdq_ue_err;
  // SCT1 RDQ.
  input          sct1rdq_install_state;
  input          sct1rdq_unmapped_error;
  input    [5:0] sct1rdq_jid;
  input  [127:0] sct1rdq_data;
  input 	 sct1rdq_ue_err;
  // SCT2 RDQ.
  input          sct2rdq_install_state;
  input          sct2rdq_unmapped_error;
  input    [5:0] sct2rdq_jid;
  input  [127:0] sct2rdq_data;
  input 	 sct2rdq_ue_err;
  // SCT3 RDQ.
  input          sct3rdq_install_state;
  input          sct3rdq_unmapped_error;
  input    [5:0] sct3rdq_jid;
  input  [127:0] sct3rdq_data;
  input 	 sct3rdq_ue_err;
  // PIO RQQ.
  input 	 ncio_pio_ue;
  input   [15:0] ncio_pio_be;
  input   [63:0] ncio_pio_ad;
  // PIO ACKQ.
  input    [4:0] ncio_mondo_agnt_id;
  input    [4:0] ncio_mondo_cpu_id;
  // DBGQ.
  input  [127:0] dbg_data;

  // YID-to-JID Translation.
  input    [5:0] unused_jid;

  // J_ADTYPE, J_AD, J_ADP busses.
  output   [7:0] jbi_io_j_adtype;
  output [127:0] jbi_io_j_ad;
  output   [3:0] jbi_io_j_adp;

  // Error injection.
  input    [3:0] inj_err_j_ad;			// Inject an error on the J_AD[] (bit3=J_AD[96], bit2=J_AD[64], bit1=J_AD[32], bit0=J_AD[0]).

  // Debug Info.
  input 	 csr_jbi_debug_info_enb;	// Put these data fields in high half of JBus Address Cycles.
  input    [4:0] thread_id;
  input    [3:0] sct0rdq_trans_count;
  input    [3:0] sct1rdq_trans_count;
  input    [3:0] sct2rdq_trans_count;
  input    [3:0] sct3rdq_trans_count;
  input    [4:0] ncio_prqq_level;
  input    [4:0] ncio_makq_level;

  // Clock.
  input 	 clk;



  // Wires and Regs.
  wire 	      sct0rdq_ue_err_p1;
  wire 	      sct1rdq_ue_err_p1;
  wire 	      sct2rdq_ue_err_p1;
  wire 	      sct3rdq_ue_err_p1;
  reg [127:0] j_ad;
  reg 	[7:0] jbi_io_j_adtype;



  // Preformatting Debug Info field.
  wire [111:64] debug_info = { 11'b000_0000_0000, thread_id[4:0], sct0rdq_trans_count[3:0], sct1rdq_trans_count[3:0], sct2rdq_trans_count[3:0], sct3rdq_trans_count[3:0],
                               3'b000, ncio_prqq_level[4:0], 3'b000, ncio_makq_level[4:0] };

  // IDLE Output formatting.
  //
  wire   [7:0] idle_adtype = { 8'hff };
  wire [127:0] idle_ad = csr_jbi_debug_info_enb? { 16'hffff, debug_info[111:64],    64'hffff_ffff_ffff_ffff }:
	                                         { 64'hffff_ffff_ffff_ffff,         64'hffff_ffff_ffff_ffff };

  // SCT0 RDQ Output formatting.
  // 
  // RD16
  wire 	 [3:0] sct0rdq_target_aid =      sct0rdq_jid[5:2];
  wire 	 [1:0] sct0rdq_trans_id =        sct0rdq_jid[1:0];
  wire   [7:0] sct0rdq_rd16_adtype =     { 2'h2, sct0rdq_target_aid, sct0rdq_trans_id };				  
  wire [127:0] sct0rdq_rd16_ad =         { sct0rdq_data[127:0] };

  // RD64
  wire 	 [2:0] sct0rdq_state =           (sct0rdq_install_state == `JBI_SCTAG_TAG_INSTALL_INVALID)? INSTALL_INVALID:
												    INSTALL_SHARED;
  wire 	 [1:0] sct0rdq_uece_err =        { sct0rdq_ue_err, 1'b0 };
  wire 	 [1:0] sct0rdq_uece_err_p1 =     { sct0rdq_ue_err_p1, 1'b0 };
  dff_ns sct0rdq_ue_err_p1_reg (.din(sct0rdq_ue_err), .q(sct0rdq_ue_err_p1), .clk(clk));
  //
  wire   [7:0] sct0rdq_rd64_0_adtype =   { 2'h1, sct0rdq_target_aid, sct0rdq_trans_id };				  
  wire [127:0] sct0rdq_rd64_0_ad =       { sct0rdq_data[127:0] };
  //
  wire   [7:0] sct0rdq_rd64_1_adtype =   { 1'h0, sct0rdq_uece_err_p1, sct0rdq_uece_err, sct0rdq_state };	  
  wire [127:0] sct0rdq_rd64_1_ad =       { sct0rdq_data[127:0] };
  //
  wire   [7:0] sct0rdq_rd64_2_adtype =   { 3'h0, sct0rdq_uece_err, 3'h0 };		      
  wire [127:0] sct0rdq_rd64_2_ad =       { sct0rdq_data[127:0] };
  //
  wire   [7:0] sct0rdq_rd64_3_adtype =   { 3'h0, sct0rdq_uece_err, 3'h0 };    
  wire [127:0] sct0rdq_rd64_3_ad =       { sct0rdq_data[127:0] };

  // RDER
  wire   [7:0] sct0rdq_rder_adtype =     { 2'h0, sct0rdq_target_aid, sct0rdq_trans_id };
  wire 	 [2:0] sct0rdq_rder_error =      (sct0rdq_unmapped_error)? RDER_UNMAPPED: RDER_BUS_ERROR;		  
  wire [127:0] sct0rdq_rder_ad =         { sct0rdq_data[127:3], sct0rdq_rder_error[2:0] };


  // SCT1 RDQ Output formatting.
  //
  // RD16
  wire 	 [3:0] sct1rdq_target_aid =      sct1rdq_jid[5:2];
  wire 	 [1:0] sct1rdq_trans_id =        sct1rdq_jid[1:0];
  wire   [7:0] sct1rdq_rd16_adtype =     { 2'h2, sct1rdq_target_aid, sct1rdq_trans_id };				  
  wire [127:0] sct1rdq_rd16_ad =         { sct1rdq_data[127:0] };

  // RD64
  wire 	 [2:0] sct1rdq_state =           (sct1rdq_install_state == `JBI_SCTAG_TAG_INSTALL_INVALID)? INSTALL_INVALID:
												    INSTALL_SHARED;
  wire 	 [1:0] sct1rdq_uece_err =        { sct1rdq_ue_err, 1'b0 };
  wire 	 [1:0] sct1rdq_uece_err_p1 =     { sct1rdq_ue_err_p1, 1'b0 };
  dff_ns sct1rdq_ue_err_p1_reg (.din(sct1rdq_ue_err), .q(sct1rdq_ue_err_p1), .clk(clk));
  //
  wire   [7:0] sct1rdq_rd64_0_adtype =   { 2'h1, sct1rdq_target_aid, sct1rdq_trans_id };				  
  wire [127:0] sct1rdq_rd64_0_ad =       { sct1rdq_data[127:0] };
  //
  wire   [7:0] sct1rdq_rd64_1_adtype =   { 1'h0, sct1rdq_uece_err_p1, sct1rdq_uece_err, sct1rdq_state };	  
  wire [127:0] sct1rdq_rd64_1_ad =       { sct1rdq_data[127:0] };
  //
  wire   [7:0] sct1rdq_rd64_2_adtype =   { 3'h0, sct1rdq_uece_err, 3'h0 };		      
  wire [127:0] sct1rdq_rd64_2_ad =       { sct1rdq_data[127:0] };
  //
  wire   [7:0] sct1rdq_rd64_3_adtype =   { 3'h0, sct1rdq_uece_err, 3'h0 };    
  wire [127:0] sct1rdq_rd64_3_ad =       { sct1rdq_data[127:0] };

  // RDER
  wire   [7:0] sct1rdq_rder_adtype =     { 2'h0, sct1rdq_target_aid, sct1rdq_trans_id };				  
  wire 	 [2:0] sct1rdq_rder_error =      (sct1rdq_unmapped_error)? RDER_UNMAPPED: RDER_BUS_ERROR;		  
  wire [127:0] sct1rdq_rder_ad =         { sct1rdq_data[127:3], sct1rdq_rder_error[2:0] };


  // SCT2 RDQ Output formatting.
  //
  // RD16
  wire 	 [3:0] sct2rdq_target_aid =      sct2rdq_jid[5:2];
  wire 	 [1:0] sct2rdq_trans_id =        sct2rdq_jid[1:0];
  wire   [7:0] sct2rdq_rd16_adtype =     { 2'h2, sct2rdq_target_aid, sct2rdq_trans_id };				  
  wire [127:0] sct2rdq_rd16_ad =         { sct2rdq_data[127:0] };

  // RD64
  wire 	 [2:0] sct2rdq_state =           (sct2rdq_install_state == `JBI_SCTAG_TAG_INSTALL_INVALID)? INSTALL_INVALID:
												    INSTALL_SHARED;
  wire 	 [1:0] sct2rdq_uece_err =        { sct2rdq_ue_err, 1'b0 };
  wire 	 [1:0] sct2rdq_uece_err_p1 =     { sct2rdq_ue_err_p1, 1'b0 };
  dff_ns sct2rdq_ue_err_p1_reg (.din(sct2rdq_ue_err), .q(sct2rdq_ue_err_p1), .clk(clk));
  //
  wire   [7:0] sct2rdq_rd64_0_adtype =   { 2'h1, sct2rdq_target_aid, sct2rdq_trans_id };				  
  wire [127:0] sct2rdq_rd64_0_ad =       { sct2rdq_data[127:0] };
  //
  wire   [7:0] sct2rdq_rd64_1_adtype =   { 1'h0, sct2rdq_uece_err_p1, sct2rdq_uece_err, sct2rdq_state };	  
  wire [127:0] sct2rdq_rd64_1_ad =       { sct2rdq_data[127:0] };
  //
  wire   [7:0] sct2rdq_rd64_2_adtype =   { 3'h0, sct2rdq_uece_err, 3'h0 };		      
  wire [127:0] sct2rdq_rd64_2_ad =       { sct2rdq_data[127:0] };
  //
  wire   [7:0] sct2rdq_rd64_3_adtype =   { 3'h0, sct2rdq_uece_err, 3'h0 };    
  wire [127:0] sct2rdq_rd64_3_ad =       { sct2rdq_data[127:0] };

  // RDER
  wire   [7:0] sct2rdq_rder_adtype =     { 2'h0, sct2rdq_target_aid, sct2rdq_trans_id };				  
  wire 	 [2:0] sct2rdq_rder_error =      (sct2rdq_unmapped_error)? RDER_UNMAPPED: RDER_BUS_ERROR;		  
  wire [127:0] sct2rdq_rder_ad =         { sct2rdq_data[127:3], sct2rdq_rder_error[2:0] };


  // SCT3 RDQ Output formatting.
  //
  // RD16
  wire 	 [3:0] sct3rdq_target_aid =      sct3rdq_jid[5:2];
  wire 	 [1:0] sct3rdq_trans_id =        sct3rdq_jid[1:0];
  wire   [7:0] sct3rdq_rd16_adtype =     { 2'h2, sct3rdq_target_aid[3:0], sct3rdq_trans_id[1:0] };				  
  wire [127:0] sct3rdq_rd16_ad =         { sct3rdq_data[127:0] };

  // RD64
  wire 	 [2:0] sct3rdq_state =           (sct3rdq_install_state == `JBI_SCTAG_TAG_INSTALL_INVALID)? INSTALL_INVALID:
												    INSTALL_SHARED;
  wire 	 [1:0] sct3rdq_uece_err =        { sct3rdq_ue_err, 1'b0 };
  wire 	 [1:0] sct3rdq_uece_err_p1 =     { sct3rdq_ue_err_p1, 1'b0 };
  dff_ns sct3rdq_ue_err_p1_reg (.din(sct3rdq_ue_err), .q(sct3rdq_ue_err_p1), .clk(clk));
  //
  wire   [7:0] sct3rdq_rd64_0_adtype =   { 2'h1, sct3rdq_target_aid[3:0], sct3rdq_trans_id[1:0] };				  
  wire [127:0] sct3rdq_rd64_0_ad =       { sct3rdq_data[127:0] };
  //
  wire   [7:0] sct3rdq_rd64_1_adtype =   { 1'h0, sct3rdq_uece_err_p1, sct3rdq_uece_err, sct3rdq_state };	  
  wire [127:0] sct3rdq_rd64_1_ad =       { sct3rdq_data[127:0] };
  //
  wire   [7:0] sct3rdq_rd64_2_adtype =   { 3'h0, sct3rdq_uece_err, 3'h0 };		      
  wire [127:0] sct3rdq_rd64_2_ad =       { sct3rdq_data[127:0] };
  //
  wire   [7:0] sct3rdq_rd64_3_adtype =   { 3'h0, sct3rdq_uece_err, 3'h0 };    
  wire [127:0] sct3rdq_rd64_3_ad =       { sct3rdq_data[127:0] };

  // RDER
  wire   [7:0] sct3rdq_rder_adtype =     { 2'h0, sct3rdq_target_aid, sct3rdq_trans_id };				  
  wire 	 [2:0] sct3rdq_rder_error =      (sct3rdq_unmapped_error)? RDER_UNMAPPED: RDER_BUS_ERROR;		  
  wire [127:0] sct3rdq_rder_ad =         { sct3rdq_data[127:3], sct3rdq_rder_error[2:0] };


  // PIO RQQ Output formatting.
  //
  // NCRD
  wire   [7:0] piorqq_ncrd_adtype =   { 2'h3, unused_jid[5:2], unused_jid[1:0] };							       
  wire [127:0] piorqq_ncrd_ad = csr_jbi_debug_info_enb? { ncio_pio_be[15:0], debug_info[111:64],              ncio_pio_be[15:0], TRANS_NCRD, ncio_pio_ad[42:0] }:
							{ ncio_pio_be[15:0], TRANS_NCRD, ncio_pio_ad[42:0],   ncio_pio_be[15:0], TRANS_NCRD, ncio_pio_ad[42:0] };
  // NCWR
  wire   [7:0] piorqq_ncwr_0_adtype = { 2'h3, 4'h0, 2'h0 };										       
  wire [127:0] piorqq_ncwr_0_ad = csr_jbi_debug_info_enb? { ncio_pio_be[15:0], debug_info[111:64],              ncio_pio_be[15:0], TRANS_NCWR, ncio_pio_ad[42:0] }:
							  { ncio_pio_be[15:0], TRANS_NCWR, ncio_pio_ad[42:0],   ncio_pio_be[15:0], TRANS_NCWR, ncio_pio_ad[42:0] };
  //
  wire   [7:0] piorqq_ncwr_1_adtype = { 3'h0, ncio_pio_ue, 1'h0, 3'h0 };  
  wire [127:0] piorqq_ncwr_1_ad     = { ncio_pio_ad[63:0],                                  ncio_pio_ad[63:0] };


  // PIO ACKQ Output formatting.
  //
  // INTACK
  wire 	 [4:0] pioackq_target_aid =   ncio_mondo_agnt_id;
  wire 	 [4:0] pioackq_source_aid =   ncio_mondo_cpu_id;
  //
  wire   [7:0] pioackq_intack_adtype =  { 2'h3, 4'h0, 2'h0 };
  wire [127:0] pioackq_intack_ad = csr_jbi_debug_info_enb? { 16'h0000, debug_info[111:64],
                                                             16'h0000, TRANS_INTACK, 2'h0, pioackq_target_aid[4:0], pioackq_source_aid[4:0], 31'h0000_0000 }:
							   { 16'h0000, TRANS_INTACK, 2'h0, pioackq_target_aid[4:0], pioackq_source_aid[4:0], 31'h0000_0000,
							     16'h0000, TRANS_INTACK, 2'h0, pioackq_target_aid[4:0], pioackq_source_aid[4:0], 31'h0000_0000 };
  // INTNACK
  wire   [7:0] pioackq_intnack_adtype = { 2'h3, 4'h0, 2'h0 };
  wire [127:0] pioackq_intnack_ad = csr_jbi_debug_info_enb? { 16'h0000, debug_info[111:64],
                                                              16'h0000, TRANS_INTNACK, 2'h0, pioackq_target_aid[4:0], pioackq_source_aid[4:0], 31'h0000_0000 }:
							    { 16'h0000, TRANS_INTNACK, 2'h0, pioackq_target_aid[4:0], pioackq_source_aid[4:0], 31'h0000_0000,
                                                              16'h0000, TRANS_INTNACK, 2'h0, pioackq_target_aid[4:0], pioackq_source_aid[4:0], 31'h0000_0000 };

  // DBGQ
  wire 	 [3:0] dbgq_target_aid =      4'h4;
  wire 	 [1:0] dbgq_trans_id =        2'h0;
  wire   [7:0] dbgq_rd16_adtype =     { 2'h2, dbgq_target_aid[3:0], dbgq_trans_id[1:0] };				  
  wire [127:0] dbgq_rd16_ad =         { dbg_data[127:0] };


  // Packet assembly multiplexer.
  always @(/*AS*/dbgq_rd16_ad or dbgq_rd16_adtype or idle_ad or idle_adtype
	   or pioackq_intack_ad or pioackq_intack_adtype or pioackq_intnack_ad
	   or pioackq_intnack_adtype or piorqq_ncrd_ad or piorqq_ncrd_adtype
	   or piorqq_ncwr_0_ad or piorqq_ncwr_0_adtype or piorqq_ncwr_1_ad
	   or piorqq_ncwr_1_adtype or sct0rdq_rd16_ad or sct0rdq_rd16_adtype
	   or sct0rdq_rd64_0_ad or sct0rdq_rd64_0_adtype or sct0rdq_rd64_1_ad
	   or sct0rdq_rd64_1_adtype or sct0rdq_rd64_2_ad
	   or sct0rdq_rd64_2_adtype or sct0rdq_rd64_3_ad
	   or sct0rdq_rd64_3_adtype or sct0rdq_rder_ad or sct0rdq_rder_adtype
	   or sct1rdq_rd16_ad or sct1rdq_rd16_adtype or sct1rdq_rd64_0_ad
	   or sct1rdq_rd64_0_adtype or sct1rdq_rd64_1_ad
	   or sct1rdq_rd64_1_adtype or sct1rdq_rd64_2_ad
	   or sct1rdq_rd64_2_adtype or sct1rdq_rd64_3_ad
	   or sct1rdq_rd64_3_adtype or sct1rdq_rder_ad or sct1rdq_rder_adtype
	   or sct2rdq_rd16_ad or sct2rdq_rd16_adtype or sct2rdq_rd64_0_ad
	   or sct2rdq_rd64_0_adtype or sct2rdq_rd64_1_ad
	   or sct2rdq_rd64_1_adtype or sct2rdq_rd64_2_ad
	   or sct2rdq_rd64_2_adtype or sct2rdq_rd64_3_ad
	   or sct2rdq_rd64_3_adtype or sct2rdq_rder_ad or sct2rdq_rder_adtype
	   or sct3rdq_rd16_ad or sct3rdq_rd16_adtype or sct3rdq_rd64_0_ad
	   or sct3rdq_rd64_0_adtype or sct3rdq_rd64_1_ad
	   or sct3rdq_rd64_1_adtype or sct3rdq_rd64_2_ad
	   or sct3rdq_rd64_2_adtype or sct3rdq_rd64_3_ad
	   or sct3rdq_rd64_3_adtype or sct3rdq_rder_ad or sct3rdq_rder_adtype
	   or sel_j_adbus or sel_queue) begin
    casex ({ sel_queue, sel_j_adbus })
      { LRQ_X,       SEL_IDLE    }:  { jbi_io_j_adtype, j_ad } = { idle_adtype,             idle_ad            };

      { LRQ_SCT0RDQ, SEL_RD16    }:  { jbi_io_j_adtype, j_ad } = { sct0rdq_rd16_adtype,     sct0rdq_rd16_ad    };
      { LRQ_SCT0RDQ, SEL_RD64_0  }:  { jbi_io_j_adtype, j_ad } = { sct0rdq_rd64_0_adtype,   sct0rdq_rd64_0_ad  };
      { LRQ_SCT0RDQ, SEL_RD64_1  }:  { jbi_io_j_adtype, j_ad } = { sct0rdq_rd64_1_adtype,   sct0rdq_rd64_1_ad  };
      { LRQ_SCT0RDQ, SEL_RD64_2  }:  { jbi_io_j_adtype, j_ad } = { sct0rdq_rd64_2_adtype,   sct0rdq_rd64_2_ad  };
      { LRQ_SCT0RDQ, SEL_RD64_3  }:  { jbi_io_j_adtype, j_ad } = { sct0rdq_rd64_3_adtype,   sct0rdq_rd64_3_ad  };
      { LRQ_SCT0RDQ, SEL_RDER    }:  { jbi_io_j_adtype, j_ad } = { sct0rdq_rder_adtype,     sct0rdq_rder_ad    };

      { LRQ_SCT1RDQ, SEL_RD16    }:  { jbi_io_j_adtype, j_ad } = { sct1rdq_rd16_adtype,     sct1rdq_rd16_ad    };
      { LRQ_SCT1RDQ, SEL_RD64_0  }:  { jbi_io_j_adtype, j_ad } = { sct1rdq_rd64_0_adtype,   sct1rdq_rd64_0_ad  };
      { LRQ_SCT1RDQ, SEL_RD64_1  }:  { jbi_io_j_adtype, j_ad } = { sct1rdq_rd64_1_adtype,   sct1rdq_rd64_1_ad  };
      { LRQ_SCT1RDQ, SEL_RD64_2  }:  { jbi_io_j_adtype, j_ad } = { sct1rdq_rd64_2_adtype,   sct1rdq_rd64_2_ad  };
      { LRQ_SCT1RDQ, SEL_RD64_3  }:  { jbi_io_j_adtype, j_ad } = { sct1rdq_rd64_3_adtype,   sct1rdq_rd64_3_ad  };
      { LRQ_SCT1RDQ, SEL_RDER    }:  { jbi_io_j_adtype, j_ad } = { sct1rdq_rder_adtype,     sct1rdq_rder_ad    };

      { LRQ_SCT2RDQ, SEL_RD16    }:  { jbi_io_j_adtype, j_ad } = { sct2rdq_rd16_adtype,     sct2rdq_rd16_ad    };
      { LRQ_SCT2RDQ, SEL_RD64_0  }:  { jbi_io_j_adtype, j_ad } = { sct2rdq_rd64_0_adtype,   sct2rdq_rd64_0_ad  };
      { LRQ_SCT2RDQ, SEL_RD64_1  }:  { jbi_io_j_adtype, j_ad } = { sct2rdq_rd64_1_adtype,   sct2rdq_rd64_1_ad  };
      { LRQ_SCT2RDQ, SEL_RD64_2  }:  { jbi_io_j_adtype, j_ad } = { sct2rdq_rd64_2_adtype,   sct2rdq_rd64_2_ad  };
      { LRQ_SCT2RDQ, SEL_RD64_3  }:  { jbi_io_j_adtype, j_ad } = { sct2rdq_rd64_3_adtype,   sct2rdq_rd64_3_ad  };
      { LRQ_SCT2RDQ, SEL_RDER    }:  { jbi_io_j_adtype, j_ad } = { sct2rdq_rder_adtype,     sct2rdq_rder_ad    };

      { LRQ_SCT3RDQ, SEL_RD16    }:  { jbi_io_j_adtype, j_ad } = { sct3rdq_rd16_adtype,     sct3rdq_rd16_ad    };
      { LRQ_SCT3RDQ, SEL_RD64_0  }:  { jbi_io_j_adtype, j_ad } = { sct3rdq_rd64_0_adtype,   sct3rdq_rd64_0_ad  };
      { LRQ_SCT3RDQ, SEL_RD64_1  }:  { jbi_io_j_adtype, j_ad } = { sct3rdq_rd64_1_adtype,   sct3rdq_rd64_1_ad  };
      { LRQ_SCT3RDQ, SEL_RD64_2  }:  { jbi_io_j_adtype, j_ad } = { sct3rdq_rd64_2_adtype,   sct3rdq_rd64_2_ad  };
      { LRQ_SCT3RDQ, SEL_RD64_3  }:  { jbi_io_j_adtype, j_ad } = { sct3rdq_rd64_3_adtype,   sct3rdq_rd64_3_ad  };
      { LRQ_SCT3RDQ, SEL_RDER    }:  { jbi_io_j_adtype, j_ad } = { sct3rdq_rder_adtype,     sct3rdq_rder_ad    };

      { LRQ_PIORQQ,  SEL_NCRD    }:  { jbi_io_j_adtype, j_ad } = { piorqq_ncrd_adtype,      piorqq_ncrd_ad     };
      { LRQ_PIORQQ,  SEL_NCWR_0  }:  { jbi_io_j_adtype, j_ad } = { piorqq_ncwr_0_adtype,    piorqq_ncwr_0_ad   };
      { LRQ_PIORQQ,  SEL_NCWR_1  }:  { jbi_io_j_adtype, j_ad } = { piorqq_ncwr_1_adtype,    piorqq_ncwr_1_ad   };

      { LRQ_PIOACKQ, SEL_INTACK  }:  { jbi_io_j_adtype, j_ad } = { pioackq_intack_adtype,   pioackq_intack_ad  };
      { LRQ_PIOACKQ, SEL_INTNACK }:  { jbi_io_j_adtype, j_ad } = { pioackq_intnack_adtype,  pioackq_intnack_ad };

      { LRQ_DBGQ,    SEL_RD16    }:  { jbi_io_j_adtype, j_ad } = { dbgq_rd16_adtype,        dbgq_rd16_ad       };

      default:                       { jbi_io_j_adtype, j_ad } = { 8'bX,                    128'bX             };
    endcase
  end


  // Error injection (inj_err_j_ad[3]=J_AD[96], [2]=J_AD[64], [1]=J_AD[32], [0]=J_AD[0]).
  assign jbi_io_j_ad[127:0] = { j_ad[127:97], (j_ad[96]^inj_err_j_ad[3]),
				j_ad[ 95:65], (j_ad[64]^inj_err_j_ad[2]),
				j_ad[ 63:33], (j_ad[32]^inj_err_j_ad[1]),
				j_ad[ 31: 1], (j_ad[ 0]^inj_err_j_ad[0]) };

  // J_ADP odd parity bits generation (undriven, 1's, is correct parity [JBus Spec pg 20]).
  assign jbi_io_j_adp[3] = ~((^ j_ad[127:96]) ^ (^ jbi_io_j_adtype[7:0]));
  assign jbi_io_j_adp[2] = ~ (^ j_ad[ 95:64]);
  assign jbi_io_j_adp[1] = ~ (^ j_ad[ 63:32]);
  assign jbi_io_j_adp[0] = ~ (^ j_ad[ 31: 0]);



  // Monitors.

  // simtech modcovoff -bpen
  // synopsys translate_off

  // Check: Address halves are the same for address cycles.
  always @(posedge clk) begin
    if ((sel_j_adbus == SEL_IDLE || sel_j_adbus == SEL_INTACK || sel_j_adbus == SEL_INTNACK || sel_j_adbus == SEL_NCRD || sel_j_adbus == SEL_NCWR_0) &&
      (j_ad[127:64] != j_ad[63:0]) && !csr_jbi_debug_info_enb) begin
      $dispmon ("jbi_mout_jbi_pktout_mux", 49, "%d %m: ERROR - Upper and halves of J_AD[] must match on address cycles. (%h, %h)", $time, j_ad[127:64], j_ad[63:0]);
      end
    end

  // Check: Select of case has a valid state.
  always @(posedge clk) begin
    if ({ jbi_io_j_adtype, j_ad } === { 8'bX, 128'bX }) begin
      $dispmon ("jbi_mout_jbi_pktout_mux", 49, "%d %m: ERROR - Invalid multiplexer select value. (%b)", $time, sel_j_adbus);
      end
    end

  // synopsys translate_on
  // simtech modcovon -bpen


  endmodule


// Local Variables:
// verilog-library-directories:("." "../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-auto-read-includes:t
// verilog-module-parents:("jbi_pktout_asm")
// End:
