// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_mout.v
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
// jbi_mout -- Process outbound JBus transaction requests.
// _____________________________________________________________________________
//

`include "sys.h"
`include "jbi.h"


module jbi_mout (/*AUTOARG*/
  // Outputs
  mout_pio_req_adv, mout_pio_pop, mout_mondo_pop, jbi_io_j_adtype, 
  jbi_io_j_adtype_en, jbi_io_j_ad, jbi_io_j_ad_en, jbi_io_j_adp, 
  jbi_io_j_adp_en, jbi_io_j_req0_out_l, jbi_io_j_req0_out_en, jbi_io_j_pack0, 
  jbi_io_j_pack0_en, jbi_io_j_pack1, jbi_io_j_pack1_en,
  mout_dsbl_sampling, mout_trans_yid, mout_trans_valid, 
  mout_scb0_jbus_wr_ack, mout_scb1_jbus_wr_ack, mout_scb2_jbus_wr_ack, 
  mout_scb3_jbus_wr_ack, mout_scb0_jbus_rd_ack, mout_scb1_jbus_rd_ack, 
  mout_scb2_jbus_rd_ack, mout_scb3_jbus_rd_ack, mout_nack, mout_nack_buf_id, 
  mout_nack_thr_id, mout_min_inject_err_done, mout_csr_inject_output_done, mout_min_jbus_owner, 
  mout_port_4_present, mout_port_5_present, mout_csr_err_cpar, mout_csr_jbi_log_par_jpar,
  mout_csr_jbi_log_par_jpack0, mout_csr_jbi_log_par_jpack1, mout_csr_jbi_log_par_jpack4, 
  mout_csr_jbi_log_par_jpack5, mout_csr_jbi_log_par_jreq, mout_csr_err_arb_to, 
  jbi_log_arb_myreq, jbi_log_arb_reqtype, jbi_log_arb_aok, jbi_log_arb_dok, jbi_log_arb_jreq, 
  mout_csr_err_fatal, mout_csr_err_read_to, 
  mout_perf_aok_off, mout_perf_dok_off, mout_dbg_pop, 
  // Inputs
  scbuf0_jbi_data, scbuf0_jbi_ctag_vld, scbuf0_jbi_ue_err, 
  sctag0_jbi_por_req_buf, scbuf1_jbi_data, scbuf1_jbi_ctag_vld, 
  scbuf1_jbi_ue_err, sctag1_jbi_por_req_buf, scbuf2_jbi_data, 
  scbuf2_jbi_ctag_vld, scbuf2_jbi_ue_err, sctag2_jbi_por_req_buf, 
  scbuf3_jbi_data, scbuf3_jbi_ctag_vld, scbuf3_jbi_ue_err, 
  sctag3_jbi_por_req_buf, ncio_pio_req, ncio_pio_req_rw, ncio_pio_req_dest, 
  ncio_pio_ad, ncio_pio_ue, ncio_pio_be, ncio_yid, ncio_mondo_req, 
  ncio_mondo_ack, ncio_mondo_agnt_id, ncio_mondo_cpu_id, ncio_prqq_level, 
  ncio_makq_level, io_jbi_j_pack4, io_jbi_j_pack5, io_jbi_j_req4_in_l, 
  io_jbi_j_req5_in_l, io_jbi_j_par, min_free, min_free_jid, min_trans_jid, 
  min_aok_on, min_aok_off, min_snp_launch, ncio_mout_nack_pop, min_mout_inject_err, 
  csr_jbi_config_arb_mode, csr_jbi_arb_timeout_timeval, 
  csr_jbi_trans_timeout_timeval, 
  csr_jbi_err_inject_errtype, csr_jbi_err_inject_xormask, 
  csr_jbi_debug_info_enb, csr_dok_on, 
  csr_jbi_debug_arb_aggr_arb, csr_jbi_error_config_fe_enb, csr_jbi_log_enb_read_to, dbg_req_transparent, 
  dbg_req_arbitrate, dbg_req_priority, dbg_data, testmux_sel, hold, rst_tri_en, 
  cclk, crst_l, clk, rst_l, tx_en_local_m1, arst_l
  );

  `include "jbi_mout.h"


  // SCTAG0.
  input   [31:0]              scbuf0_jbi_data;
  input 		      scbuf0_jbi_ctag_vld;		// Header cycle of a new response packet.
  input 		      scbuf0_jbi_ue_err;		// Current data cycle has a uncorrectable error.
  input 		      sctag0_jbi_por_req_buf;		// Request for DOK_FATAL.

  // SCTAG1.
  input   [31:0]              scbuf1_jbi_data;
  input 		      scbuf1_jbi_ctag_vld;		// Header cycle of a new response packet.
  input 		      scbuf1_jbi_ue_err;		// Current data cycle has a uncorrectable error.
  input 		      sctag1_jbi_por_req_buf;		// Request for DOK_FATAL.

  // SCTAG2.
  input   [31:0]              scbuf2_jbi_data;
  input 		      scbuf2_jbi_ctag_vld;		// Header cycle of a new response packet.
  input 		      scbuf2_jbi_ue_err;		// Current data cycle has a uncorrectable error.
  input 		      sctag2_jbi_por_req_buf;		// Request for DOK_FATAL.

  // SCTAG3.
  input   [31:0]              scbuf3_jbi_data;
  input 		      scbuf3_jbi_ctag_vld;		// Header cycle of a new response packet.
  input 		      scbuf3_jbi_ue_err;		// Current data cycle has a uncorrectable error.
  input 		      sctag3_jbi_por_req_buf;		// Request for DOK_FATAL.

  // Non-Cache IO (ncio).
  input 		      ncio_pio_req;
  input 		      ncio_pio_req_rw;
  input 		[1:0] ncio_pio_req_dest;
  output 		      mout_pio_req_adv;
  input 	       [63:0] ncio_pio_ad;
  input 		      ncio_pio_ue;
  input 	       [15:0] ncio_pio_be;
  input  [`JBI_YID_WIDTH-1:0] ncio_yid;
  output 		      mout_pio_pop;
  //
  input 		      ncio_mondo_req;
  input 		      ncio_mondo_ack;			// 1=ack; 0=nack
  input [`JBI_AD_INT_AGTID_WIDTH-1:0] ncio_mondo_agnt_id;
  input [`JBI_AD_INT_CPUID_WIDTH-1:0] ncio_mondo_cpu_id;
  output 		      mout_mondo_pop;
  input [`JBI_PRQQ_ADDR_WIDTH:0] ncio_prqq_level;		// Number of received PIO requests in queue
  input [`JBI_MAKQ_ADDR_WIDTH:0] ncio_makq_level;		// Number of INTACK/NACK transmit requests in queue.

  // IO.
  output 		[7:0] jbi_io_j_adtype;
  output 		      jbi_io_j_adtype_en;
  output 	      [127:0] jbi_io_j_ad;
  output 	        [3:0] jbi_io_j_ad_en;
  input 		[2:0] io_jbi_j_pack4;
  input 		[2:0] io_jbi_j_pack5;
  output 		[3:0] jbi_io_j_adp;
  output 		      jbi_io_j_adp_en;
  input 		      io_jbi_j_req4_in_l;
  input 		      io_jbi_j_req5_in_l;
  output 		      jbi_io_j_req0_out_l;
  output 		      jbi_io_j_req0_out_en;
  output 		[2:0] jbi_io_j_pack0;
  output 		      jbi_io_j_pack0_en;
  output 		[2:0] jbi_io_j_pack1;
  output 		      jbi_io_j_pack1_en;
  input 		      io_jbi_j_par;

  // DTL Control.
  output 		      mout_dsbl_sampling;

  // Memory In (jbi_min).
  input 		      min_free;				// Free an assignment to ...
  input 		[3:0] min_free_jid;			//   'min_free_jid[]'.
  input  [`JBI_JID_WIDTH-1:0] min_trans_jid;			// Translate this JID to a YID.
  output [`JBI_YID_WIDTH-1:0] mout_trans_yid;			//   Translated 'min_trans_jid[]'.
  output 		      mout_trans_valid;			//   Translation is valid qualifier.
  output 		      mout_scb0_jbus_wr_ack;		// Inform when L2 sends Write Ack to JBus.  (cmp clock)
  output 		      mout_scb1_jbus_wr_ack;
  output 		      mout_scb2_jbus_wr_ack;
  output 		      mout_scb3_jbus_wr_ack;
  output 		      mout_scb0_jbus_rd_ack;		// Inform when we put read return data on JBus.  (jbus clock)
  output 		      mout_scb1_jbus_rd_ack;
  output 		      mout_scb2_jbus_rd_ack;
  output 		      mout_scb3_jbus_rd_ack;
  input 		      min_aok_on;			// Requests for AOK Flow Control.
  input 		      min_aok_off;
  input 		      min_snp_launch;			// Issue COHACK.
  input 		      ncio_mout_nack_pop;		// YID recovery from Timedout JBus read request.
  output 		      mout_nack;
  output		[1:0] mout_nack_buf_id;
  output		[5:0] mout_nack_thr_id;
  input			      min_mout_inject_err;		// J_AD error injection request.
  output		      mout_min_inject_err_done;
  output		      mout_csr_inject_output_done;
  output                [5:0] mout_min_jbus_owner;		// JBus owner (logged by min block into JBI_LOG_CTRL[OWNER] as source of data return).

  // CSRs (jbi_csr).
  input 		[1:0] csr_jbi_config_arb_mode;		// "Arbiter Mode" control from JBI_CONFIG register.
  output		      mout_port_4_present;		// "Port Present" in JBI_CONFIG register.
  output		      mout_port_5_present;		//
  output 		      mout_csr_err_cpar;		// "JBus Control Parity Error" to Error Handling registers:
  output 		      mout_csr_jbi_log_par_jpar;	//    log J_PAR
  output 		[2:0] mout_csr_jbi_log_par_jpack0;	//    log J_PACK0
  output 		[2:0] mout_csr_jbi_log_par_jpack1;	//    log J_PACK1
  output 		[2:0] mout_csr_jbi_log_par_jpack4;	//    log J_PACK4
  output 		[2:0] mout_csr_jbi_log_par_jpack5;	//    log J_PACK5
  output 		[6:0] mout_csr_jbi_log_par_jreq;	//    log J_REQ[6:0]
  output 		      mout_csr_err_arb_to;		// "Arbitration Timeout Error" to Error Handling registers:
  input 	       [31:0] csr_jbi_arb_timeout_timeval;	//    "Arbitration Timeout Error" timeout interval.
  output 		[2:0] jbi_log_arb_myreq;	        //    log MYREQ.
  output 		[2:0] jbi_log_arb_reqtype;	        //    log REQTYPE.
  output 		[6:0] jbi_log_arb_aok;			//    log AOK
  output 		[6:0] jbi_log_arb_dok;			//    log DOK
  output 		[6:0] jbi_log_arb_jreq;			//    log J_REQs
  output 		[5:4] mout_csr_err_fatal;		// "Reported Fatal Error" to Error Handling registers.
  output 		      mout_csr_err_read_to;		// "Transaction Timeout - Read Req" to Error Handling registers.
  input 	       [31:0] csr_jbi_trans_timeout_timeval;    //    Interval counter wraparound value.
  input 		      csr_jbi_err_inject_errtype;	//
  input 		[3:0] csr_jbi_err_inject_xormask;	//
  output 		      mout_perf_aok_off;		// Performance Counter events - AOK OFF
  output 		      mout_perf_dok_off;		//                              DOK OFF
  input 		      csr_jbi_debug_info_enb;		// Put Debug Info in high half of JBus Address Cycles.
  input 		      csr_dok_on;			// CSR request for DOK_FATAL.
  input 		      csr_jbi_debug_arb_aggr_arb;	// AGGR_ARB bit of JBI_DEBUG_ARB register.
  input 		      csr_jbi_error_config_fe_enb;	// Enable DOK Fatal for non-JBI fatal errors.
  input 		      csr_jbi_log_enb_read_to;		// When negated, do not report Read Timeout errors.

  // Dbg.
  input             	      dbg_req_transparent;		// The Debug Info queue a valid request and wants it sent without impacting the JBus flow.
  input          	      dbg_req_arbitrate;		// The Debug Info queue a valid request and want fair round robin arbitration.
  input          	      dbg_req_priority;			// The Debug Info queue a valid request and needs it sent right away.
  input 	      [127:0] dbg_data;				// Data to put on the JBus.
  output         	      mout_dbg_pop;		     	// When asserted, pop the transaction header from the Debug Info queue.

  // Misc.
  input 		      testmux_sel;			// Memory and ATPG test mode signal.
  input                       hold;
  input 		      rst_tri_en;
  
  // Clock and reset.
  input 		      cclk;				// CMP clock.
  input 		      crst_l;				// CMP clock domain reset.
  input 		      clk;				// JBus clock.
  input 		      rst_l;				// JBus clock domain reset.
  input 		      tx_en_local_m1;			// CMP to JBI clock domain crossing synchronization pulse.
  input 		      arst_l;				// Asynch reset.



  // Wires and Regs.
  wire   [3:0] int_req_type;
  wire 	 [6:0] int_requestors;
  wire [127:0] jbi_io_j_ad;
  wire 	 [3:0] jbi_io_j_adp;
  wire 	 [7:0] jbi_io_j_adtype;
  wire 	 [3:0] sel_j_adbus;
  wire   [3:0] unused_jid;
  wire 	[31:0] scbuf0_jbi_data, scbuf1_jbi_data, scbuf2_jbi_data, scbuf3_jbi_data;
  wire 	 [3:0] sct0rdq_trans_count, sct1rdq_trans_count, sct2rdq_trans_count, sct3rdq_trans_count;
  wire 	 [5:0] sct0rdq_jid, sct1rdq_jid, sct2rdq_jid, sct3rdq_jid;
  wire [127:0] sct0rdq_data, sct1rdq_data, sct2rdq_data, sct3rdq_data;
  wire 	 [2:0] sel_queue;
  wire 	 [3:0] inj_err_j_ad;
  wire [`JBI_YID_WIDTH-1:0] mout_trans_yid;
  wire   [3:0] nack_error_id;
  wire   [1:0] ignored;



  // SCT0 Outbound Request Queues.
  jbi_sct_out_queues  sct0_out_queues (
    // SCTAG/BUF Outbound Requests and Return Data.
    .scbuf_jbi_data		(scbuf0_jbi_data),
    .scbuf_jbi_ctag_vld		(scbuf0_jbi_ctag_vld),
    .scbuf_jbi_ue_err		(scbuf0_jbi_ue_err),

    // JBI Outbound Interface.
    .sctrdq_trans_count		(sct0rdq_trans_count),
    .sctrdq_data1_4		(sct0rdq_data1_4),
    .sctrdq_install_state	(sct0rdq_install_state),
    .sctrdq_unmapped_error	(sct0rdq_unmapped_error),
    .sctrdq_jid			(sct0rdq_jid),
    .sctrdq_data		(sct0rdq_data),
    .sctrdq_ue_err		(sct0rdq_ue_err),
    .sctrdq_dec_count		(sct0rdq_dec_count),
    .sctrdq_dequeue		(sct0rdq_dequeue),

    // Memory In (jbi_min).
    .mout_scb_jbus_wr_ack	(mout_scb0_jbus_wr_ack),

    // Misc.
    .testmux_sel		(testmux_sel),
    .hold                       (hold),
    .rst_tri_en	                (rst_tri_en),

    // Clock and reset.
    .cclk			(cclk),
    .crst_l			(crst_l),
    .clk			(clk),
    .rst_l			(rst_l),
    .tx_en_local_m1		(tx_en_local_m1),
    .arst_l			(arst_l)
    );


  // SCT1 Outbound Request Queues.
  jbi_sct_out_queues  sct1_out_queues (
    // Outbound Requests and Return Data.
    .scbuf_jbi_data		(scbuf1_jbi_data),
    .scbuf_jbi_ctag_vld		(scbuf1_jbi_ctag_vld),
    .scbuf_jbi_ue_err		(scbuf1_jbi_ue_err),

    // JBI Outbound Interface.
    .sctrdq_trans_count		(sct1rdq_trans_count),
    .sctrdq_data1_4		(sct1rdq_data1_4),
    .sctrdq_install_state	(sct1rdq_install_state),
    .sctrdq_unmapped_error	(sct1rdq_unmapped_error),
    .sctrdq_jid			(sct1rdq_jid),
    .sctrdq_data		(sct1rdq_data),
    .sctrdq_ue_err		(sct1rdq_ue_err),
    .sctrdq_dec_count		(sct1rdq_dec_count),
    .sctrdq_dequeue		(sct1rdq_dequeue),

    // Memory In (jbi_min).
    .mout_scb_jbus_wr_ack	(mout_scb1_jbus_wr_ack),

    // Misc.
    .testmux_sel		(testmux_sel),
    .hold                       (hold),
    .rst_tri_en	                (rst_tri_en),

    // Clock and reset.
    .cclk			(cclk),
    .crst_l			(crst_l),
    .clk			(clk),
    .rst_l			(rst_l),
    .tx_en_local_m1		(tx_en_local_m1),
    .arst_l			(arst_l)
    );


  // SCT2 Outbound Request Queues.
  jbi_sct_out_queues  sct2_out_queues (
    // Outbound Requests and Return Data.
    .scbuf_jbi_data		(scbuf2_jbi_data),
    .scbuf_jbi_ctag_vld		(scbuf2_jbi_ctag_vld),
    .scbuf_jbi_ue_err		(scbuf2_jbi_ue_err),

    // JBI Outbound Interface.
    .sctrdq_trans_count		(sct2rdq_trans_count),
    .sctrdq_data1_4		(sct2rdq_data1_4),
    .sctrdq_install_state	(sct2rdq_install_state),
    .sctrdq_unmapped_error	(sct2rdq_unmapped_error),
    .sctrdq_jid			(sct2rdq_jid),
    .sctrdq_data		(sct2rdq_data),
    .sctrdq_ue_err		(sct2rdq_ue_err),
    .sctrdq_dec_count		(sct2rdq_dec_count),
    .sctrdq_dequeue		(sct2rdq_dequeue),

    // Memory In (jbi_min).
    .mout_scb_jbus_wr_ack	(mout_scb2_jbus_wr_ack),

    // Misc.
    .testmux_sel		(testmux_sel),
    .hold                       (hold),
    .rst_tri_en	                (rst_tri_en),

    // Clock and reset.
    .cclk			(cclk),
    .crst_l			(crst_l),
    .clk			(clk),
    .rst_l			(rst_l),
    .tx_en_local_m1		(tx_en_local_m1),
    .arst_l			(arst_l)
    );


  // SCT3 Outbound Request Queues.
  jbi_sct_out_queues  sct3_out_queues (
    // Outbound Requests and Return Data.
    .scbuf_jbi_data		(scbuf3_jbi_data),
    .scbuf_jbi_ctag_vld		(scbuf3_jbi_ctag_vld),
    .scbuf_jbi_ue_err		(scbuf3_jbi_ue_err),

    // JBI Outbound Interface.
    .sctrdq_trans_count		(sct3rdq_trans_count),
    .sctrdq_data1_4		(sct3rdq_data1_4),
    .sctrdq_install_state	(sct3rdq_install_state),
    .sctrdq_unmapped_error	(sct3rdq_unmapped_error),
    .sctrdq_jid			(sct3rdq_jid),
    .sctrdq_data		(sct3rdq_data),
    .sctrdq_ue_err		(sct3rdq_ue_err),
    .sctrdq_dec_count		(sct3rdq_dec_count),
    .sctrdq_dequeue		(sct3rdq_dequeue),

    // Memory In (jbi_min).
    .mout_scb_jbus_wr_ack	(mout_scb3_jbus_wr_ack),

    // Misc.
    .testmux_sel		(testmux_sel),
    .hold                       (hold),
    .rst_tri_en	                (rst_tri_en),

    // Clock and reset.
    .cclk			(cclk),
    .crst_l			(crst_l),
    .clk			(clk),
    .rst_l			(rst_l),
    .tx_en_local_m1		(tx_en_local_m1),
    .arst_l			(arst_l)
    );



  // YID to JID Translator.
  jbi_jid_to_yid  jid_to_yid (
    // Translation, port 0.
    .trans_jid0		(min_trans_jid[3:0]),
    .trans_yid0		(mout_trans_yid),
    .trans_valid0	(mout_trans_valid),

    // Translation, port 1.
    .trans_jid1		(nack_error_id[3:0]),
    .trans_yid1		({ignored[1:0], mout_nack_thr_id[5:0], mout_nack_buf_id[1:0]}),
    .trans_valid1	(),

    // Allocating an assignment.
    .alloc_stall	(),
    .alloc		(alloc),
    .alloc_yid		(ncio_yid),
    .alloc_jid		(unused_jid),

    // Freeing an assignment, port 0.
    .free0		(min_free),
    .free_jid0		(min_free_jid),

    // Freeing an assignment, port 1.
    .free1		(ncio_mout_nack_pop),
    .free_jid1		(nack_error_id[3:0]),

    // Clock and reset.
    .clk		(clk),
    .rst_l		(rst_l)
    );



  // Internal Arbiter.
  jbi_int_arb  int_arb (
    // SCT0 RDQ.
    .sct0rdq_data1_4		(sct0rdq_data1_4),
    .sct0rdq_trans_count	(sct0rdq_trans_count),
    .sct0rdq_dec_count		(sct0rdq_dec_count),
    .sct0rdq_ue_err		(sct0rdq_ue_err),
    .sct0rdq_unmapped_error	(sct0rdq_unmapped_error),

    // SCT1 RDQ.
    .sct1rdq_data1_4		(sct1rdq_data1_4),
    .sct1rdq_trans_count	(sct1rdq_trans_count),
    .sct1rdq_dec_count		(sct1rdq_dec_count),
    .sct1rdq_ue_err		(sct1rdq_ue_err),
    .sct1rdq_unmapped_error	(sct1rdq_unmapped_error),

    // SCT2 RDQ.
    .sct2rdq_data1_4		(sct2rdq_data1_4),
    .sct2rdq_trans_count	(sct2rdq_trans_count),
    .sct2rdq_dec_count		(sct2rdq_dec_count),
    .sct2rdq_ue_err		(sct2rdq_ue_err),
    .sct2rdq_unmapped_error	(sct2rdq_unmapped_error),

    // SCT3 RDQ.
    .sct3rdq_data1_4		(sct3rdq_data1_4),
    .sct3rdq_trans_count	(sct3rdq_trans_count),
    .sct3rdq_dec_count		(sct3rdq_dec_count),
    .sct3rdq_ue_err		(sct3rdq_ue_err),
    .sct3rdq_unmapped_error	(sct3rdq_unmapped_error),

    // PIO RQQ.
    .piorqq_req			(ncio_pio_req),
    .piorqq_req_rw		(ncio_pio_req_rw),
    .piorqq_req_dest		(ncio_pio_req_dest),
    .piorqq_req_adv		(mout_pio_req_adv),

    // PIO ACKQ.
    .pioackq_req		(ncio_mondo_req),
    .pioackq_ack_nack		(ncio_mondo_ack),
    .pioackq_req_adv		(),

    // DEBUG ACKQ.
    .dbg_req_transparent	(dbg_req_transparent),
    .dbg_req_arbitrate		(dbg_req_arbitrate),
    .dbg_req_priority		(dbg_req_priority),
    .dbg_req_adv		(),

    // JBus Arbiter.
    .int_req			(int_req),

    // Arb Timeout support.
    .have_trans_waiting		(have_trans_waiting),

    // JBus Packet Controller.
    .int_requestors		(int_requestors),
    .int_req_type		(int_req_type),
    .int_granted		(int_granted),
    .parked_on_us		(parked_on_us),

    // Flow Control.
    .ok_send_address_pkt	(ok_send_address_pkt),
    .ok_send_data_pkt_to_4	(ok_send_data_pkt_to_4),
    .ok_send_data_pkt_to_5	(ok_send_data_pkt_to_5),

    // CSRs and errors.
    .jbi_log_arb_myreq		(jbi_log_arb_myreq),
    .jbi_log_arb_reqtype	(jbi_log_arb_reqtype),
    .csr_jbi_debug_arb_aggr_arb	(csr_jbi_debug_arb_aggr_arb),


    // Clock and reset.
    .clk			(clk),
    .rst_l			(rst_l)
    );


  // JBus Arbiter.
  jbi_jbus_arb  jbus_arb (
    // Configuration.
    .csr_jbi_config_arb_mode	(csr_jbi_config_arb_mode),

    // Internal requests.
    .int_req			(int_req),
    .multiple_in_progress	(multiple_in_progress),
    .multiple_ok		(multiple_ok),
    .parked_on_us		(parked_on_us),

    // External requests.
    .io_jbi_j_req4_in_l		(io_jbi_j_req4_in_l),
    .io_jbi_j_req5_in_l		(io_jbi_j_req5_in_l),
    .jbi_io_j_req0_out_l	(jbi_io_j_req0_out_l),
    .jbi_io_j_req0_out_en	(jbi_io_j_req0_out_en),

    // Grant.
    .stream_break_point		(stream_break_point),
    .grant			(grant),

    // CSRs and errors.
    .mout_csr_err_arb_to	(mout_csr_err_arb_to),
    .csr_jbi_arb_timeout_timeval(csr_jbi_arb_timeout_timeval),
    .have_trans_waiting		(have_trans_waiting),
    .piorqq_req			(ncio_pio_req),
    .int_requestor_piorqq	(int_requestors[LRQ_PIORQQ_BIT]),
    .jbi_log_arb_jreq		(jbi_log_arb_jreq),
    .mout_min_jbus_owner	(mout_min_jbus_owner),

    // I/O buffer enable for J_ADTYPE[], J_AD[], J_ADP[].
    .jbi_io_j_adtype_en		(jbi_io_j_adtype_en),
    .jbi_io_j_ad_en		(jbi_io_j_ad_en),
    .jbi_io_j_adp_en		(jbi_io_j_adp_en),
    .mout_dsbl_sampling		(mout_dsbl_sampling),

    // Clock and reset.
    .clk			(clk),
    .rst_l			(rst_l)
    );


  // JBus Packet Controller.
  jbi_pktout_ctlr  pktout_ctlr (
    // JBus Arbiter.
    .grant			(grant),
    .multiple_in_progress	(multiple_in_progress),
    .stream_break_point		(stream_break_point),

    // Internal Arbiter.
    .multiple_ok		(multiple_ok),
    .int_req_type		(int_req_type),
    .int_requestors		(int_requestors),
    .int_granted		(int_granted),
  
    // Flow Control.
    .ok_send_address_pkt	(ok_send_address_pkt),
    .ok_send_data_pkt_to_4	(ok_send_data_pkt_to_4),
    .ok_send_data_pkt_to_5	(ok_send_data_pkt_to_5),

    // Queues.
    .sct0rdq_dequeue		(sct0rdq_dequeue),
    .sct1rdq_dequeue		(sct1rdq_dequeue),
    .sct2rdq_dequeue		(sct2rdq_dequeue),
    .sct3rdq_dequeue		(sct3rdq_dequeue),
    .piorqq_dequeue		(mout_pio_pop),
    .pioackq_dequeue		(mout_mondo_pop),
    .dbg_dequeue		(mout_dbg_pop),

    // Status bits.
    .mout_scb0_jbus_rd_ack      (mout_scb0_jbus_rd_ack),
    .mout_scb1_jbus_rd_ack      (mout_scb1_jbus_rd_ack),
    .mout_scb2_jbus_rd_ack      (mout_scb2_jbus_rd_ack),
    .mout_scb3_jbus_rd_ack      (mout_scb3_jbus_rd_ack),
    .jbus_out_addr_cycle	(jbus_out_addr_cycle),
    .jbus_out_data_cycle	(jbus_out_data_cycle),

    // JID to PIO ID map.
    .alloc			(alloc),

    // J_ADTYPE, J_AD, J_ADP busses.
    .sel_j_adbus		(sel_j_adbus),
    .sel_queue			(sel_queue),

    // Clock and reset.
    .clk			(clk),
    .rst_l			(rst_l)
    );



  // JBus Packet Assembler and Driver.
  jbi_pktout_asm  pktout_asm (
    // Outbound Packet Controller.
    .sel_j_adbus		(sel_j_adbus),
    .sel_queue			(sel_queue),	

    // Queues.
    // SCT0 RDQ.
    .sct0rdq_install_state	(sct0rdq_install_state),
    .sct0rdq_unmapped_error	(sct0rdq_unmapped_error),
    .sct0rdq_jid		(sct0rdq_jid),
    .sct0rdq_data		(sct0rdq_data),
    .sct0rdq_ue_err		(sct0rdq_ue_err),
    // SCT1 RDQ.
    .sct1rdq_install_state	(sct1rdq_install_state),
    .sct1rdq_unmapped_error	(sct1rdq_unmapped_error),
    .sct1rdq_jid		(sct1rdq_jid),
    .sct1rdq_data		(sct1rdq_data),
    .sct1rdq_ue_err		(sct1rdq_ue_err),
    // SCT2 RDQ.
    .sct2rdq_install_state	(sct2rdq_install_state),
    .sct2rdq_unmapped_error	(sct2rdq_unmapped_error),
    .sct2rdq_jid		(sct2rdq_jid),
    .sct2rdq_data		(sct2rdq_data),
    .sct2rdq_ue_err		(sct2rdq_ue_err),
    // SCT3 RDQ.
    .sct3rdq_install_state	(sct3rdq_install_state),
    .sct3rdq_unmapped_error	(sct3rdq_unmapped_error),
    .sct3rdq_jid		(sct3rdq_jid),
    .sct3rdq_data		(sct3rdq_data),
    .sct3rdq_ue_err		(sct3rdq_ue_err),
    // PIO RQQ.
    .ncio_pio_ue                (ncio_pio_ue),
    .ncio_pio_be                (ncio_pio_be),
    .ncio_pio_ad                (ncio_pio_ad),
    // PIO ACKQ.
    .ncio_mondo_agnt_id		(ncio_mondo_agnt_id),
    .ncio_mondo_cpu_id		(ncio_mondo_cpu_id),
    // DBGQ.
    .dbg_data			(dbg_data),

    // YID-to-JID Translation.
    .unused_jid			({ 2'b00, unused_jid }),

    // J_ADTYPE, J_AD, J_ADP busses.
    .jbi_io_j_adtype		(jbi_io_j_adtype),
    .jbi_io_j_ad		(jbi_io_j_ad),
    .jbi_io_j_adp		(jbi_io_j_adp),

    // Error injection.
    .inj_err_j_ad		(inj_err_j_ad),

    // Debug Info.
    .csr_jbi_debug_info_enb	(csr_jbi_debug_info_enb),	// Put these data fields in high half of JBus Address Cycles.
    .thread_id			(ncio_yid[`JBI_YID_THR_HI-1:`JBI_YID_THR_LO]),
    .sct0rdq_trans_count	(sct0rdq_trans_count[3:0]),
    .sct1rdq_trans_count	(sct1rdq_trans_count[3:0]),
    .sct2rdq_trans_count	(sct2rdq_trans_count[3:0]),
    .sct3rdq_trans_count	(sct3rdq_trans_count[3:0]),
    .ncio_prqq_level		(ncio_prqq_level[4:0]),
    .ncio_makq_level		(ncio_makq_level[4:0]),
    
    // Clock.
    .clk			(clk)
    );



  // AOK/DOK Flow Control Tracking.
  jbi_aok_dok_tracking  aok_dok_tracking (
    // J_PACK signals.
    .j_pack0_m1			(jbi_io_j_pack0),
    .j_pack1_m1			(jbi_io_j_pack1),
    .j_pack4_p1			(io_jbi_j_pack4),
    .j_pack5_p1			(io_jbi_j_pack5),

    // Flow control signals.
    .ok_send_data_pkt_to_4	(ok_send_data_pkt_to_4),
    .ok_send_data_pkt_to_5	(ok_send_data_pkt_to_5),
    .ok_send_address_pkt	(ok_send_address_pkt),

    // CSR Interface.
    .jbi_log_arb_aok		(jbi_log_arb_aok),
    .jbi_log_arb_dok		(jbi_log_arb_dok),
    .mout_csr_err_fatal		(mout_csr_err_fatal),

    // Performance Counter events.
    .mout_perf_aok_off		(mout_perf_aok_off),
    .mout_perf_dok_off		(mout_perf_dok_off),

    // Clock and reset.
    .clk			(clk),
    .rst_l			(rst_l)
    );



  // Outbound Snoop Response Generator.
  jbi_j_pack_out_gen  j_pack_out_gen (
    // COHACK response requests.
    .min_snp_launch		(min_snp_launch),

    // Flow Control.
    .send_aok_off		(min_aok_off),
    .send_aok_on		(min_aok_on),
    .send_dok_off		(1'b0),
    .send_dok_on		(1'b0),

    // Fatal error control.
    .dok_fatal_req_csr		(csr_dok_on),
    .dok_fatal_req_sctag	({ sctag0_jbi_por_req_buf, sctag1_jbi_por_req_buf, sctag2_jbi_por_req_buf, sctag3_jbi_por_req_buf }),
    .csr_jbi_error_config_fe_enb(csr_jbi_error_config_fe_enb),

    // JPack out.
    .jbi_io_j_pack0		(jbi_io_j_pack0),
    .jbi_io_j_pack0_en		(jbi_io_j_pack0_en),
    .jbi_io_j_pack1		(jbi_io_j_pack1),
    .jbi_io_j_pack1_en		(jbi_io_j_pack1_en),

    // Clock and reset.
    .clk			(clk),
    .rst_l			(rst_l),
    .cclk			(cclk),
    .crst_l			(crst_l),
    .tx_en_local_m1		(tx_en_local_m1)
    );



  // CSR interface for errors and logging.
  jbi_mout_csr  mout_csr (
    // Port Present detection.
    .mout_port_4_present	(mout_port_4_present),
    .mout_port_5_present	(mout_port_5_present),

    // Transaction Timeout error detection.
    .alloc			(alloc),
    .unused_jid			(unused_jid),
    .min_free			(min_free),
    .min_free_jid		(min_free_jid),
    .trans_timeout_timeval	(csr_jbi_trans_timeout_timeval),
    .mout_csr_err_read_to	(mout_csr_err_read_to),
    .mout_nack			(mout_nack),
    .nack_error_id		(nack_error_id),
    .ncio_mout_nack_pop		(ncio_mout_nack_pop),
    .csr_jbi_log_enb_read_to	(csr_jbi_log_enb_read_to),

    // J_PAR Error detection.
    .j_par			(io_jbi_j_par),
    .j_req4_in_l_p1		(io_jbi_j_req4_in_l),
    .j_req5_in_l_p1		(io_jbi_j_req5_in_l),
    .j_req0_out_l_m1		(jbi_io_j_req0_out_l),
    .j_pack0_m1			(jbi_io_j_pack0),
    .j_pack1_m1			(jbi_io_j_pack1),
    .j_pack4_p1			(io_jbi_j_pack4),
    .j_pack5_p1			(io_jbi_j_pack5),
    .mout_csr_err_cpar		(mout_csr_err_cpar),
    .mout_csr_jbi_log_par_jpar	(mout_csr_jbi_log_par_jpar),
    .mout_csr_jbi_log_par_jpack0(mout_csr_jbi_log_par_jpack0),
    .mout_csr_jbi_log_par_jpack1(mout_csr_jbi_log_par_jpack1),
    .mout_csr_jbi_log_par_jpack4(mout_csr_jbi_log_par_jpack4),
    .mout_csr_jbi_log_par_jpack5(mout_csr_jbi_log_par_jpack5),
    .mout_csr_jbi_log_par_jreq	(mout_csr_jbi_log_par_jreq),

    // JBus Error Injection control from JBI_ERR_INJECT.
    .min_mout_inject_err	(min_mout_inject_err),
    .jbi_err_inject_xormask	(csr_jbi_err_inject_xormask),
    .jbi_err_inject_errtype	(csr_jbi_err_inject_errtype),
    .jbus_out_addr_cycle	(jbus_out_addr_cycle),
    .jbus_out_data_cycle	(jbus_out_data_cycle),
    .inj_err_j_ad		(inj_err_j_ad),
    .mout_min_inject_err_done	(mout_min_inject_err_done),
    .mout_csr_inject_output_done(mout_csr_inject_output_done),

    // Clock and reset.
    .clk			(clk),
    .rst_l			(rst_l)
    );


  endmodule


// Local Variables:
// verilog-library-directories:("." "../../include" "../../../include" "../../rtl")
// verilog-module-parents:("jbi")
// End:
