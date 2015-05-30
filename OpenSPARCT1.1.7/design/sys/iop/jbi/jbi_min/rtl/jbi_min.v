// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min.v
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
/////////////////////////////////////////////////////////////////////////
/*
//  Description:	JBI Memory Inbound Block
//  Top level Module:	jbi_min
//  Where Instantiated:	jbi
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "jbi.h"

module jbi_min (/*AUTOARG*/
// Outputs
min_csr_inject_input_done, min_csr_err_apar, min_csr_err_adtype, 
min_csr_err_dpar_wr, min_csr_err_dpar_rd, min_csr_err_dpar_o, 
min_csr_err_rep_ue, min_csr_err_illegal, min_csr_err_unsupp, 
min_csr_err_nonex_wr, min_csr_err_nonex_rd, min_csr_err_unmap_wr, 
min_csr_err_err_cycle, min_csr_err_unexp_dr, min_csr_err_l2_to0, 
min_csr_err_l2_to1, min_csr_err_l2_to2, min_csr_err_l2_to3, 
min_csr_write_log_addr, min_csr_log_addr_owner, 
min_csr_log_addr_adtype, min_csr_log_addr_ttype, 
min_csr_log_addr_addr, min_csr_log_data0, min_csr_log_data1, 
min_csr_log_ctl_owner, min_csr_log_ctl_parity, 
min_csr_log_ctl_adtype0, min_csr_log_ctl_adtype1, 
min_csr_log_ctl_adtype2, min_csr_log_ctl_adtype3, 
min_csr_log_ctl_adtype4, min_csr_log_ctl_adtype5, 
min_csr_log_ctl_adtype6, min_csr_perf_dma_rd_in, min_csr_perf_dma_wr, 
min_csr_perf_dma_rd_latency, min_csr_perf_dma_wr8, 
min_csr_perf_blk_q0, min_csr_perf_blk_q1, min_csr_perf_blk_q2, 
min_csr_perf_blk_q3, jbi_sctag0_req, jbi_scbuf0_ecc, 
jbi_sctag0_req_vld, jbi_sctag1_req, jbi_scbuf1_ecc, 
jbi_sctag1_req_vld, jbi_sctag2_req, jbi_scbuf2_ecc, 
jbi_sctag2_req_vld, jbi_sctag3_req, jbi_scbuf3_ecc, 
jbi_sctag3_req_vld, min_mout_inject_err, min_trans_jid, 
min_snp_launch, min_free, min_free_jid, min_aok_on, min_aok_off, 
min_j_ad_ff, min_pio_rtrn_push, min_pio_data_err, min_mondo_hdr_push, 
min_mondo_data_push, min_mondo_data_err, min_oldest_wri_tag, 
min_pre_wri_tag, 
// Inputs
clk, rst_l, arst_l, testmux_sel, rst_tri_en, cpu_clk, cpu_rst_l, 
cpu_tx_en, cpu_rx_en, hold, csr_16x65array_margin, 
csr_jbi_config_port_pres, csr_jbi_error_config_erren, 
csr_jbi_log_enb_apar, csr_jbi_log_enb_dpar_wr, 
csr_jbi_log_enb_dpar_rd, csr_jbi_log_enb_rep_ue, 
csr_jbi_log_enb_nonex_rd, csr_jbi_log_enb_err_cycle, 
csr_jbi_log_enb_dpar_o, csr_jbi_log_enb_unexp_dr, 
csr_jbi_config2_iq_high, csr_jbi_config2_iq_low, 
csr_jbi_config2_max_rd, csr_jbi_config2_max_wr, 
csr_jbi_config2_ord_rd, csr_jbi_config2_ord_wr, csr_jbi_memsize_size, 
csr_jbi_config2_max_wris, csr_jbi_l2_timeout_timeval, 
csr_jbi_err_inject_input, csr_jbi_err_inject_output, 
csr_jbi_err_inject_errtype, csr_jbi_err_inject_xormask, 
csr_jbi_err_inject_count, sctag0_jbi_iq_dequeue, 
sctag0_jbi_wib_dequeue, sctag1_jbi_iq_dequeue, 
sctag1_jbi_wib_dequeue, sctag2_jbi_iq_dequeue, 
sctag2_jbi_wib_dequeue, sctag3_jbi_iq_dequeue, 
sctag3_jbi_wib_dequeue, io_jbi_j_adtype, io_jbi_j_ad, io_jbi_j_adp, 
mout_dsbl_sampling, mout_scb0_jbus_wr_ack, mout_scb1_jbus_wr_ack, 
mout_scb2_jbus_wr_ack, mout_scb3_jbus_wr_ack, mout_scb0_jbus_rd_ack, 
mout_scb1_jbus_rd_ack, mout_scb2_jbus_rd_ack, mout_scb3_jbus_rd_ack, 
mout_trans_valid, mout_min_inject_err_done, mout_min_jbus_owner
);

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
input clk;
input rst_l;
input arst_l;
input testmux_sel;
input rst_tri_en;

input cpu_clk;
input cpu_rst_l;
input cpu_tx_en;
input cpu_rx_en;

input hold;

// CSR Block Interface
input [4:0] csr_16x65array_margin;	
input [6:0] csr_jbi_config_port_pres;
input 	    csr_jbi_error_config_erren;
input 	    csr_jbi_log_enb_apar;	
input 	    csr_jbi_log_enb_dpar_wr;
input 	    csr_jbi_log_enb_dpar_rd;
input 	    csr_jbi_log_enb_rep_ue;
input 	    csr_jbi_log_enb_nonex_rd;
input 	    csr_jbi_log_enb_err_cycle;
input 	    csr_jbi_log_enb_dpar_o;
input 	    csr_jbi_log_enb_unexp_dr;
input [3:0] csr_jbi_config2_iq_high;
input [3:0] csr_jbi_config2_iq_low;
input [1:0] csr_jbi_config2_max_rd;
input [3:0] csr_jbi_config2_max_wr;
input 	    csr_jbi_config2_ord_rd;
input 	    csr_jbi_config2_ord_wr;
input [37:30] csr_jbi_memsize_size;
input [1:0]   csr_jbi_config2_max_wris;
input [31:0]  csr_jbi_l2_timeout_timeval;
input 	      csr_jbi_err_inject_input;
input 	      csr_jbi_err_inject_output;
input 	      csr_jbi_err_inject_errtype;
input [3:0]   csr_jbi_err_inject_xormask;
input [23:0]  csr_jbi_err_inject_count;
output 	      min_csr_inject_input_done;
output 	      min_csr_err_apar;
output 	      min_csr_err_adtype;
output 	      min_csr_err_dpar_wr;
output 	      min_csr_err_dpar_rd;
output 	      min_csr_err_dpar_o;
output 	      min_csr_err_rep_ue;
output 	      min_csr_err_illegal;
output 	      min_csr_err_unsupp;
output 	      min_csr_err_nonex_wr;
output 	      min_csr_err_nonex_rd;
output 	      min_csr_err_unmap_wr;
output 	      min_csr_err_err_cycle;
output 	      min_csr_err_unexp_dr;
output 	      min_csr_err_l2_to0;
output 	      min_csr_err_l2_to1;
output 	      min_csr_err_l2_to2;
output 	      min_csr_err_l2_to3;
output 	      min_csr_write_log_addr;
output [2:0]  min_csr_log_addr_owner;
output [7:0]  min_csr_log_addr_adtype;
output [4:0]  min_csr_log_addr_ttype;
output [42:0] min_csr_log_addr_addr;
output [63:0] min_csr_log_data0;
output [63:0] min_csr_log_data1;
output [2:0]  min_csr_log_ctl_owner;
output [3:0]  min_csr_log_ctl_parity;
output [7:0]  min_csr_log_ctl_adtype0;
output [7:0]  min_csr_log_ctl_adtype1;
output [7:0]  min_csr_log_ctl_adtype2;
output [7:0]  min_csr_log_ctl_adtype3;
output [7:0]  min_csr_log_ctl_adtype4;
output [7:0]  min_csr_log_ctl_adtype5;
output [7:0]  min_csr_log_ctl_adtype6;
output 	      min_csr_perf_dma_rd_in;
output 	      min_csr_perf_dma_wr;
output [4:0]  min_csr_perf_dma_rd_latency;
output 	      min_csr_perf_dma_wr8;
output [3:0]  min_csr_perf_blk_q0;
output [3:0]  min_csr_perf_blk_q1;
output [3:0]  min_csr_perf_blk_q2;
output [3:0]  min_csr_perf_blk_q3;

// SCBuf0/SCTag0 Interface.
output [31:0] jbi_sctag0_req;
output [6:0]  jbi_scbuf0_ecc;
output 	      jbi_sctag0_req_vld;		// Next cycle will be Header of a new request packet.
input 	      sctag0_jbi_iq_dequeue;		// SCTag is unloading a request from its 2 req queue.
input 	      sctag0_jbi_wib_dequeue;		// Write invalidate buffer (size=4) is being unloaded.

// SCBuf1/SCTag1 Interface.
output [31:0] jbi_sctag1_req;
output [6:0]  jbi_scbuf1_ecc;
output 	      jbi_sctag1_req_vld;		// Next cycle will be Header of a new request packet.
input 	      sctag1_jbi_iq_dequeue;		// SCTag is unloading a request from its 2 req queue.
input 	      sctag1_jbi_wib_dequeue;		// Write invalidate buffer (size=4) is being unloaded.

// SCBuf2/SCTag2 Interface.
output [31:0] jbi_sctag2_req;
output [6:0]  jbi_scbuf2_ecc;
output 	      jbi_sctag2_req_vld;		// Next cycle will be Header of a new request packet.
input 	      sctag2_jbi_iq_dequeue;		// SCTag is unloading a request from its 2 req queue.
input 	      sctag2_jbi_wib_dequeue;		// Write invalidate buffer (size=4) is being unloaded.

// SCBuf3/SCTag3 Interface.
output [31:0] jbi_sctag3_req;
output [6:0]  jbi_scbuf3_ecc;
output 	      jbi_sctag3_req_vld;		// Next cycle will be Header of a new request packet.
input 	      sctag3_jbi_iq_dequeue;		// SCTag is unloading a request from its 2 req queue.
input 	      sctag3_jbi_wib_dequeue;		// Write invalidate buffer (size=4) is being unloaded.

// BSC Interface.
//input 	      bsc_jbi_sctag0_req_vld;
//input [63:0]  bsc_jbi_sctag0_req;
//output 	      jbi_bsc_sctag0_rdy;
//
//input 	      bsc_jbi_sctag1_req_vld;
//input [63:0]  bsc_jbi_sctag1_req;
//output 	      jbi_bsc_sctag1_rdy;

//input 	      bsc_jbi_sctag2_req_vld;
//input [63:0]  bsc_jbi_sctag2_req;
//output 	      jbi_bsc_sctag2_rdy;
//
//input 	      bsc_jbi_sctag3_req_vld;
//input [63:0]  bsc_jbi_sctag3_req;
//output 	      jbi_bsc_sctag3_rdy;

//IO Interface
input [7:0]   io_jbi_j_adtype;
input [127:0] io_jbi_j_ad;
input [3:0]   io_jbi_j_adp;

// Memory Out (mout) Interface
input 	      mout_dsbl_sampling;
input 	      mout_scb0_jbus_wr_ack;
input 	      mout_scb1_jbus_wr_ack;
input 	      mout_scb2_jbus_wr_ack;
input 	      mout_scb3_jbus_wr_ack;
//input 	      mout_scb0_bsc_txn_ack;	
//input 	      mout_scb1_bsc_txn_ack;	
//input 	      mout_scb2_bsc_txn_ack;	
//input 	      mout_scb3_bsc_txn_ack;	
input 	      mout_scb0_jbus_rd_ack;	
input 	      mout_scb1_jbus_rd_ack;	
input 	      mout_scb2_jbus_rd_ack;	
input 	      mout_scb3_jbus_rd_ack;
input 	      mout_trans_valid;	
input 	      mout_min_inject_err_done;
input [5:0]   mout_min_jbus_owner;
output 	      min_mout_inject_err;
output [`JBI_JID_WIDTH-1:0] min_trans_jid;        // index to jid/btu_id and jid/pio_id table
output 			    min_snp_launch;       // mout should issue COHACK
output 			    min_free;
output [`JBI_JID_WIDTH-1:0] min_free_jid;
output 			    min_aok_on;
output 			    min_aok_off;

// Non-Cache IO (ncio) Interface
output [127:0] 		    min_j_ad_ff;
output 			    min_pio_rtrn_push;
output 			    min_pio_data_err;
output 			    min_mondo_hdr_push;
output 			    min_mondo_data_push;
output 			    min_mondo_data_err;
output [`JBI_WRI_TAG_WIDTH-1:0] min_oldest_wri_tag;
output [`JBI_WRI_TAG_WIDTH-1:0] min_pre_wri_tag;

/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
// End of automatics
/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
// End of automatics

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire			cpu_rst_l_ff;		// From u_dffrl_async_cpu_rst_l_ff of dffrl_async_ns.v
wire [4:0]		csr_16x65array_margin_c;// From u_dffsle_0_csr_16x65array_margin_c of dffsle_ns.v, ...
wire [4:0]		csr_16x65array_margin_ff;// From u_dffrl_0_csr_16x65array_margin_ff of dffsl_ns.v, ...
wire [7:0]		io_jbi_j_adtype_ff;	// From u_parse of jbi_min_parse.v
wire			parse_data_err;		// From u_parse of jbi_min_parse.v
wire			parse_err_nonex_rd;	// From u_parse of jbi_min_parse.v
wire			parse_hdr;		// From u_parse of jbi_min_parse.v
wire			parse_install_mode;	// From u_parse of jbi_min_parse.v
wire			parse_rw;		// From u_parse of jbi_min_parse.v
wire [2:0]		parse_sctag_req;	// From u_parse of jbi_min_parse.v
wire			parse_subline_req;	// From u_parse of jbi_min_parse.v
wire			parse_wdq_push;		// From u_parse of jbi_min_parse.v
wire			parse_wrm;		// From u_parse of jbi_min_parse.v
wire			rdq0_full;		// From u_rq0 of jbi_min_rq.v
wire			rdq1_full;		// From u_rq1 of jbi_min_rq.v
wire			rdq2_full;		// From u_rq2 of jbi_min_rq.v
wire			rdq3_full;		// From u_rq3 of jbi_min_rq.v
wire			rhq0_full;		// From u_rq0 of jbi_min_rq.v
wire			rhq1_full;		// From u_rq1 of jbi_min_rq.v
wire			rhq2_full;		// From u_rq2 of jbi_min_rq.v
wire			rhq3_full;		// From u_rq3 of jbi_min_rq.v
wire			rq_cpu_rst_l_ff0;	// From u_dffrl_async_rq_cpu_rst_l_ff0 of dffrl_async_ns.v
wire			rq_cpu_rst_l_ff1;	// From u_dffrl_async_rq_cpu_rst_l_ff1 of dffrl_async_ns.v
wire			rq_cpu_rst_l_ff2;	// From u_dffrl_async_rq_cpu_rst_l_ff2 of dffrl_async_ns.v
wire			rq_cpu_rst_l_ff3;	// From u_dffrl_async_rq_cpu_rst_l_ff3 of dffrl_async_ns.v
wire			wdq_rdq0_push;		// From u_wdq of jbi_min_wdq.v
wire			wdq_rdq1_push;		// From u_wdq of jbi_min_wdq.v
wire			wdq_rdq2_push;		// From u_wdq of jbi_min_wdq.v
wire			wdq_rdq3_push;		// From u_wdq of jbi_min_wdq.v
wire [`JBI_RDQ_WIDTH-1:0]wdq_rdq_wdata;		// From u_wdq of jbi_min_wdq.v
wire			wdq_rhq0_push;		// From u_wdq of jbi_min_wdq.v
wire			wdq_rhq1_push;		// From u_wdq of jbi_min_wdq.v
wire			wdq_rhq2_push;		// From u_wdq of jbi_min_wdq.v
wire			wdq_rhq3_push;		// From u_wdq of jbi_min_wdq.v
wire [`JBI_RHQ_WIDTH-1:0]wdq_rhq_wdata;		// From u_wdq of jbi_min_wdq.v
wire			wdq_rq_tag_byps;	// From u_wdq of jbi_min_wdq.v
wire			wdq_wr_vld;		// From u_wdq of jbi_min_wdq.v
wire [`JBI_WRI_TAG_WIDTH-1:0]wrtrk_new_wri_tag;	// From u_wrtrk of jbi_min_wrtrk.v
wire [`JBI_WRI_TAG_WIDTH-1:0]wrtrk_rq0_oldest_wri_tag;// From u_wrtrk of jbi_min_wrtrk.v
wire [`JBI_WRI_TAG_WIDTH-1:0]wrtrk_rq1_oldest_wri_tag;// From u_wrtrk of jbi_min_wrtrk.v
wire [`JBI_WRI_TAG_WIDTH-1:0]wrtrk_rq2_oldest_wri_tag;// From u_wrtrk of jbi_min_wrtrk.v
wire [`JBI_WRI_TAG_WIDTH-1:0]wrtrk_rq3_oldest_wri_tag;// From u_wrtrk of jbi_min_wrtrk.v
// End of automatics

//
// Code start here 
//

//*******************************************************************************
// Synchronization DFFRLEs
//*******************************************************************************
//----------------------
// JBUS -> CPU
//----------------------
/* dffsl_ns AUTO_TEMPLATE (
 .din(csr_16x65array_margin[@]),
 .clk(clk),
 .set_l(rst_l),
 .q(csr_16x65array_margin_ff[@]  ),
 ); */
/* dffrl_ns AUTO_TEMPLATE (
 .din(csr_16x65array_margin[@]),
 .clk(clk),
 .rst_l(rst_l),
 .q(csr_16x65array_margin_ff[@]  ),
 ); */
dffsl_ns #(1) u_dffrl_0_csr_16x65array_margin_ff (/*AUTOINST*/
						  // Outputs
						  .q(csr_16x65array_margin_ff[0]  ), // Templated
						  // Inputs
						  .din(csr_16x65array_margin[0]), // Templated
						  .clk(clk),	 // Templated
						  .set_l(rst_l)); // Templated
dffrl_ns #(1) u_dffrl_1_csr_16x65array_margin_ff (/*AUTOINST*/
						  // Outputs
						  .q(csr_16x65array_margin_ff[1]  ), // Templated
						  // Inputs
						  .din(csr_16x65array_margin[1]), // Templated
						  .clk(clk),	 // Templated
						  .rst_l(rst_l)); // Templated
dffsl_ns #(1) u_dffrl_2_csr_16x65array_margin_ff (/*AUTOINST*/
						  // Outputs
						  .q(csr_16x65array_margin_ff[2]  ), // Templated
						  // Inputs
						  .din(csr_16x65array_margin[2]), // Templated
						  .clk(clk),	 // Templated
						  .set_l(rst_l)); // Templated
dffrl_ns #(1) u_dffrl_3_csr_16x65array_margin_ff (/*AUTOINST*/
						  // Outputs
						  .q(csr_16x65array_margin_ff[3]  ), // Templated
						  // Inputs
						  .din(csr_16x65array_margin[3]), // Templated
						  .clk(clk),	 // Templated
						  .rst_l(rst_l)); // Templated
dffsl_ns #(1) u_dffrl_4_csr_16x65array_margin_ff (/*AUTOINST*/
						  // Outputs
						  .q(csr_16x65array_margin_ff[4]  ), // Templated
						  // Inputs
						  .din(csr_16x65array_margin[4]), // Templated
						  .clk(clk),	 // Templated
						  .set_l(rst_l)); // Templated

/* dffsle_ns AUTO_TEMPLATE (
 .din(csr_16x65array_margin_ff[@]),
 .clk(cpu_clk),
 .en(cpu_rx_en),
 .set_l(cpu_rst_l_ff),
 .q(csr_16x65array_margin_c[@]),
 ); */
/* dffrle_ns AUTO_TEMPLATE (
 .din(csr_16x65array_margin_ff[@]),
 .clk(cpu_clk),
 .en(cpu_rx_en),
 .rst_l(cpu_rst_l_ff),
 .q(csr_16x65array_margin_c[@]),
 ); */

// Reset value csr_16x65array_margin_c = 5'b10101
dffsle_ns #(1) u_dffsle_0_csr_16x65array_margin_c (/*AUTOINST*/
						   // Outputs
						   .q(csr_16x65array_margin_c[0]), // Templated
						   // Inputs
						   .din(csr_16x65array_margin_ff[0]), // Templated
						   .en(cpu_rx_en), // Templated
						   .set_l(cpu_rst_l_ff), // Templated
						   .clk(cpu_clk)); // Templated
dffrle_ns #(1) u_dffrle_1_csr_16x65array_margin_c (/*AUTOINST*/
						   // Outputs
						   .q(csr_16x65array_margin_c[1]), // Templated
						   // Inputs
						   .din(csr_16x65array_margin_ff[1]), // Templated
						   .en(cpu_rx_en), // Templated
						   .rst_l(cpu_rst_l_ff), // Templated
						   .clk(cpu_clk)); // Templated
dffsle_ns #(1) u_dffsle_2_csr_16x65array_margin_c (/*AUTOINST*/
						   // Outputs
						   .q(csr_16x65array_margin_c[2]), // Templated
						   // Inputs
						   .din(csr_16x65array_margin_ff[2]), // Templated
						   .en(cpu_rx_en), // Templated
						   .set_l(cpu_rst_l_ff), // Templated
						   .clk(cpu_clk)); // Templated
dffrle_ns #(1) u_dffrle_3_csr_16x65array_margin_c (/*AUTOINST*/
						   // Outputs
						   .q(csr_16x65array_margin_c[3]), // Templated
						   // Inputs
						   .din(csr_16x65array_margin_ff[3]), // Templated
						   .en(cpu_rx_en), // Templated
						   .rst_l(cpu_rst_l_ff), // Templated
						   .clk(cpu_clk)); // Templated
dffsle_ns #(1) u_dffsle_4_csr_16x65array_margin_c (/*AUTOINST*/
						   // Outputs
						   .q(csr_16x65array_margin_c[4]), // Templated
						   // Inputs
						   .din(csr_16x65array_margin_ff[4]), // Templated
						   .en(cpu_rx_en), // Templated
						   .set_l(cpu_rst_l_ff), // Templated
						   .clk(cpu_clk)); // Templated

//*******************************************************************************
// CMP RESET FLOPS (for timing)
//*******************************************************************************
/* dffrl_async_ns AUTO_TEMPLATE (
 .din (cpu_rst_l),
 .clk (cpu_clk),
 .rst_l (arst_l),
 .q (cpu_rst_l_ff),
 ); */
dffrl_async_ns u_dffrl_async_cpu_rst_l_ff (/*AUTOINST*/
					   // Outputs
					   .q(cpu_rst_l_ff),	 // Templated
					   // Inputs
					   .din(cpu_rst_l),	 // Templated
					   .clk(cpu_clk),	 // Templated
					   .rst_l(arst_l));	 // Templated

/* dffrl_async_ns AUTO_TEMPLATE (
 .din (cpu_rst_l),
 .clk (cpu_clk),
 .rst_l (arst_l),
 .q (rq_cpu_rst_l_ff@),
 ); */

dffrl_async_ns u_dffrl_async_rq_cpu_rst_l_ff0 (/*AUTOINST*/
					       // Outputs
					       .q(rq_cpu_rst_l_ff0), // Templated
					       // Inputs
					       .din(cpu_rst_l),	 // Templated
					       .clk(cpu_clk),	 // Templated
					       .rst_l(arst_l));	 // Templated
dffrl_async_ns u_dffrl_async_rq_cpu_rst_l_ff1 (/*AUTOINST*/
					       // Outputs
					       .q(rq_cpu_rst_l_ff1), // Templated
					       // Inputs
					       .din(cpu_rst_l),	 // Templated
					       .clk(cpu_clk),	 // Templated
					       .rst_l(arst_l));	 // Templated
dffrl_async_ns u_dffrl_async_rq_cpu_rst_l_ff2 (/*AUTOINST*/
					       // Outputs
					       .q(rq_cpu_rst_l_ff2), // Templated
					       // Inputs
					       .din(cpu_rst_l),	 // Templated
					       .clk(cpu_clk),	 // Templated
					       .rst_l(arst_l));	 // Templated
dffrl_async_ns u_dffrl_async_rq_cpu_rst_l_ff3 (/*AUTOINST*/
					       // Outputs
					       .q(rq_cpu_rst_l_ff3), // Templated
					       // Inputs
					       .din(cpu_rst_l),	 // Templated
					       .clk(cpu_clk),	 // Templated
					       .rst_l(arst_l));	 // Templated
 
 

//*******************************************************************************
// Parse Unit
//*******************************************************************************

jbi_min_parse u_parse (/*AUTOINST*/
		       // Outputs
		       .min_j_ad_ff	(min_j_ad_ff[127:0]),
		       .io_jbi_j_adtype_ff(io_jbi_j_adtype_ff[7:0]),
		       .min_trans_jid	(min_trans_jid[`JBI_JID_WIDTH-1:0]),
		       .min_snp_launch	(min_snp_launch),
		       .min_free	(min_free),
		       .min_free_jid	(min_free_jid[`JBI_JID_WIDTH-1:0]),
		       .min_mout_inject_err(min_mout_inject_err),
		       .min_pio_rtrn_push(min_pio_rtrn_push),
		       .min_pio_data_err(min_pio_data_err),
		       .min_mondo_hdr_push(min_mondo_hdr_push),
		       .min_mondo_data_push(min_mondo_data_push),
		       .min_mondo_data_err(min_mondo_data_err),
		       .parse_wdq_push	(parse_wdq_push),
		       .parse_sctag_req	(parse_sctag_req[2:0]),
		       .parse_hdr	(parse_hdr),
		       .parse_rw	(parse_rw),
		       .parse_subline_req(parse_subline_req),
		       .parse_install_mode(parse_install_mode),
		       .parse_data_err	(parse_data_err),
		       .parse_err_nonex_rd(parse_err_nonex_rd),
		       .parse_wrm	(parse_wrm),
		       .min_csr_err_apar(min_csr_err_apar),
		       .min_csr_err_adtype(min_csr_err_adtype),
		       .min_csr_err_dpar_wr(min_csr_err_dpar_wr),
		       .min_csr_err_dpar_rd(min_csr_err_dpar_rd),
		       .min_csr_err_dpar_o(min_csr_err_dpar_o),
		       .min_csr_err_rep_ue(min_csr_err_rep_ue),
		       .min_csr_err_illegal(min_csr_err_illegal),
		       .min_csr_err_unsupp(min_csr_err_unsupp),
		       .min_csr_err_nonex_wr(min_csr_err_nonex_wr),
		       .min_csr_err_nonex_rd(min_csr_err_nonex_rd),
		       .min_csr_err_unmap_wr(min_csr_err_unmap_wr),
		       .min_csr_err_err_cycle(min_csr_err_err_cycle),
		       .min_csr_err_unexp_dr(min_csr_err_unexp_dr),
		       .min_csr_write_log_addr(min_csr_write_log_addr),
		       .min_csr_log_addr_owner(min_csr_log_addr_owner[2:0]),
		       .min_csr_log_addr_adtype(min_csr_log_addr_adtype[7:0]),
		       .min_csr_log_addr_ttype(min_csr_log_addr_ttype[4:0]),
		       .min_csr_log_addr_addr(min_csr_log_addr_addr[42:0]),
		       .min_csr_log_data0(min_csr_log_data0[63:0]),
		       .min_csr_log_data1(min_csr_log_data1[63:0]),
		       .min_csr_log_ctl_owner(min_csr_log_ctl_owner[2:0]),
		       .min_csr_log_ctl_parity(min_csr_log_ctl_parity[3:0]),
		       .min_csr_log_ctl_adtype0(min_csr_log_ctl_adtype0[7:0]),
		       .min_csr_log_ctl_adtype1(min_csr_log_ctl_adtype1[7:0]),
		       .min_csr_log_ctl_adtype2(min_csr_log_ctl_adtype2[7:0]),
		       .min_csr_log_ctl_adtype3(min_csr_log_ctl_adtype3[7:0]),
		       .min_csr_log_ctl_adtype4(min_csr_log_ctl_adtype4[7:0]),
		       .min_csr_log_ctl_adtype5(min_csr_log_ctl_adtype5[7:0]),
		       .min_csr_log_ctl_adtype6(min_csr_log_ctl_adtype6[7:0]),
		       .min_csr_inject_input_done(min_csr_inject_input_done),
		       .min_csr_perf_dma_rd_in(min_csr_perf_dma_rd_in),
		       .min_csr_perf_dma_wr(min_csr_perf_dma_wr),
		       .min_csr_perf_dma_rd_latency(min_csr_perf_dma_rd_latency[4:0]),
		       // Inputs
		       .clk		(clk),
		       .rst_l		(rst_l),
		       .io_jbi_j_ad	(io_jbi_j_ad[127:0]),
		       .io_jbi_j_adtype	(io_jbi_j_adtype[7:0]),
		       .io_jbi_j_adp	(io_jbi_j_adp[3:0]),
		       .mout_dsbl_sampling(mout_dsbl_sampling),
		       .mout_scb0_jbus_rd_ack(mout_scb0_jbus_rd_ack),
		       .mout_scb1_jbus_rd_ack(mout_scb1_jbus_rd_ack),
		       .mout_scb2_jbus_rd_ack(mout_scb2_jbus_rd_ack),
		       .mout_scb3_jbus_rd_ack(mout_scb3_jbus_rd_ack),
		       .mout_trans_valid(mout_trans_valid),
		       .mout_min_inject_err_done(mout_min_inject_err_done),
		       .mout_min_jbus_owner(mout_min_jbus_owner[5:0]),
		       .csr_jbi_config_port_pres(csr_jbi_config_port_pres[6:0]),
		       .csr_jbi_error_config_erren(csr_jbi_error_config_erren),
		       .csr_jbi_log_enb_apar(csr_jbi_log_enb_apar),
		       .csr_jbi_log_enb_dpar_wr(csr_jbi_log_enb_dpar_wr),
		       .csr_jbi_log_enb_dpar_rd(csr_jbi_log_enb_dpar_rd),
		       .csr_jbi_log_enb_dpar_o(csr_jbi_log_enb_dpar_o),
		       .csr_jbi_log_enb_rep_ue(csr_jbi_log_enb_rep_ue),
		       .csr_jbi_log_enb_nonex_rd(csr_jbi_log_enb_nonex_rd),
		       .csr_jbi_log_enb_err_cycle(csr_jbi_log_enb_err_cycle),
		       .csr_jbi_log_enb_unexp_dr(csr_jbi_log_enb_unexp_dr),
		       .csr_jbi_memsize_size(csr_jbi_memsize_size[37:30]),
		       .csr_jbi_err_inject_output(csr_jbi_err_inject_output),
		       .csr_jbi_err_inject_input(csr_jbi_err_inject_input),
		       .csr_jbi_err_inject_errtype(csr_jbi_err_inject_errtype),
		       .csr_jbi_err_inject_xormask(csr_jbi_err_inject_xormask[3:0]),
		       .csr_jbi_err_inject_count(csr_jbi_err_inject_count[23:0]));

//*******************************************************************************
// Write Decomposition Queue
//*******************************************************************************
/* jbi_min_wdq AUTO_TEMPLATE (
 .io_jbi_j_ad_ff (min_j_ad_ff[]),
 ); */

jbi_min_wdq u_wdq (/*AUTOINST*/
		   // Outputs
		   .min_aok_off		(min_aok_off),
		   .min_aok_on		(min_aok_on),
		   .min_csr_perf_dma_wr8(min_csr_perf_dma_wr8),
		   .wdq_rdq0_push	(wdq_rdq0_push),
		   .wdq_rdq1_push	(wdq_rdq1_push),
		   .wdq_rdq2_push	(wdq_rdq2_push),
		   .wdq_rdq3_push	(wdq_rdq3_push),
		   .wdq_rdq_wdata	(wdq_rdq_wdata[`JBI_RDQ_WIDTH-1:0]),
		   .wdq_rhq0_push	(wdq_rhq0_push),
		   .wdq_rhq1_push	(wdq_rhq1_push),
		   .wdq_rhq2_push	(wdq_rhq2_push),
		   .wdq_rhq3_push	(wdq_rhq3_push),
		   .wdq_rhq_wdata	(wdq_rhq_wdata[`JBI_RHQ_WIDTH-1:0]),
		   .wdq_rq_tag_byps	(wdq_rq_tag_byps),
		   .wdq_wr_vld		(wdq_wr_vld),
		   // Inputs
		   .arst_l		(arst_l),
		   .clk			(clk),
		   .csr_jbi_config2_iq_high(csr_jbi_config2_iq_high[3:0]),
		   .csr_jbi_config2_iq_low(csr_jbi_config2_iq_low[3:0]),
		   .csr_jbi_config2_ord_rd(csr_jbi_config2_ord_rd),
		   .csr_jbi_config2_ord_wr(csr_jbi_config2_ord_wr),
		   .hold		(hold),
		   .io_jbi_j_adtype_ff	(io_jbi_j_adtype_ff[`JBI_ADTYPE_JID_HI:`JBI_ADTYPE_JID_LO]),
		   .parse_data_err	(parse_data_err),
		   .parse_err_nonex_rd	(parse_err_nonex_rd),
		   .parse_hdr		(parse_hdr),
		   .parse_install_mode	(parse_install_mode),
		   .parse_rw		(parse_rw),
		   .parse_sctag_req	(parse_sctag_req[2:0]),
		   .parse_subline_req	(parse_subline_req),
		   .parse_wdq_push	(parse_wdq_push),
		   .rdq0_full		(rdq0_full),
		   .rdq1_full		(rdq1_full),
		   .rdq2_full		(rdq2_full),
		   .rdq3_full		(rdq3_full),
		   .rhq0_full		(rhq0_full),
		   .rhq1_full		(rhq1_full),
		   .rhq2_full		(rhq2_full),
		   .rhq3_full		(rhq3_full),
		   .rst_l		(rst_l),
		   .rst_tri_en		(rst_tri_en),
		   .testmux_sel		(testmux_sel),
		   .io_jbi_j_ad_ff	(min_j_ad_ff[127:0]));	 // Templated


//*******************************************************************************
// Write Tracking
//*******************************************************************************

/* jbi_min_wrtrk AUTO_TEMPLATE (
 .io_jbi_j_ad_ff (min_j_ad_ff[]),
 .cpu_rst_l (cpu_rst_l_ff),
 ); */

jbi_min_wrtrk u_wrtrk (/*AUTOINST*/
		       // Outputs
		       .min_oldest_wri_tag(min_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		       .min_pre_wri_tag	(min_pre_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		       .wrtrk_new_wri_tag(wrtrk_new_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		       .wrtrk_rq0_oldest_wri_tag(wrtrk_rq0_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		       .wrtrk_rq1_oldest_wri_tag(wrtrk_rq1_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		       .wrtrk_rq2_oldest_wri_tag(wrtrk_rq2_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		       .wrtrk_rq3_oldest_wri_tag(wrtrk_rq3_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		       // Inputs
		       .clk		(clk),
		       .rst_l		(rst_l),
		       .cpu_clk		(cpu_clk),
		       .cpu_rst_l	(cpu_rst_l_ff),		 // Templated
		       .io_jbi_j_ad_ff	(min_j_ad_ff[127:64]),	 // Templated
		       .parse_wdq_push	(parse_wdq_push),
		       .parse_hdr	(parse_hdr),
		       .parse_rw	(parse_rw),
		       .parse_wrm	(parse_wrm),
		       .parse_subline_req(parse_subline_req),
		       .wdq_wr_vld	(wdq_wr_vld),
		       .mout_scb0_jbus_wr_ack(mout_scb0_jbus_wr_ack),
		       .mout_scb1_jbus_wr_ack(mout_scb1_jbus_wr_ack),
		       .mout_scb2_jbus_wr_ack(mout_scb2_jbus_wr_ack),
		       .mout_scb3_jbus_wr_ack(mout_scb3_jbus_wr_ack));

//*******************************************************************************
// Request Queue (4)
//*******************************************************************************

/* jbi_min_rq AUTO_TEMPLATE (
 .cpu_rst_l            (rq_cpu_rst_l_ff@),
 .bsc_jbi_sctag_\(.*\) (bsc_jbi_sctag@_\1),
 .sctag_\(.*\)         (sctag@_\1),
 .jbi_bsc_sctag_\(.*\) (jbi_bsc_sctag@_\1),
 .jbi_sctag_\(.*\)     (jbi_sctag@_\1),
 .jbi_scbuf_\(.*\)     (jbi_scbuf@_\1),
 .wdq_rhq_push         (wdq_rhq@_push),
 .wdq_rdq_push         (wdq_rdq@_push),
 .rhq_\(.*\)           (rhq@_\1),
 .rdq_\(.*\)           (rdq@_\1),
 .mout_scb_\(.*\)      (mout_scb@_\1),
 .min_csr_err_l2_to    (min_csr_err_l2_to@),
 .min_csr_perf_blk_q   (min_csr_perf_blk_q@),
 .csr_16x65array_margin(csr_16x65array_margin_c[]),
 .wrtrk_oldest_wri_tag (wrtrk_rq@_oldest_wri_tag[]),
 ); */

jbi_min_rq u_rq0 (/*AUTOINST*/
		  // Outputs
		  .jbi_scbuf_ecc	(jbi_scbuf0_ecc),	 // Templated
		  .jbi_sctag_req	(jbi_sctag0_req),	 // Templated
		  .jbi_sctag_req_vld	(jbi_sctag0_req_vld),	 // Templated
		  .min_csr_err_l2_to	(min_csr_err_l2_to0),	 // Templated
		  .min_csr_perf_blk_q	(min_csr_perf_blk_q0),	 // Templated
		  .rdq_full		(rdq0_full),		 // Templated
		  .rhq_full		(rhq0_full),		 // Templated
		  // Inputs
		  .arst_l		(arst_l),
		  .clk			(clk),
		  .cpu_clk		(cpu_clk),
		  .cpu_rst_l		(rq_cpu_rst_l_ff0),	 // Templated
		  .cpu_rx_en		(cpu_rx_en),
		  .cpu_tx_en		(cpu_tx_en),
		  .csr_16x65array_margin(csr_16x65array_margin_c[4:0]), // Templated
		  .csr_jbi_config2_max_rd(csr_jbi_config2_max_rd[1:0]),
		  .csr_jbi_config2_max_wr(csr_jbi_config2_max_wr[3:0]),
		  .csr_jbi_config2_max_wris(csr_jbi_config2_max_wris[1:0]),
		  .csr_jbi_l2_timeout_timeval(csr_jbi_l2_timeout_timeval[31:0]),
		  .hold			(hold),
		  .mout_scb_jbus_rd_ack	(mout_scb0_jbus_rd_ack), // Templated
		  .mout_scb_jbus_wr_ack	(mout_scb0_jbus_wr_ack), // Templated
		  .rst_l		(rst_l),
		  .rst_tri_en		(rst_tri_en),
		  .sctag_jbi_iq_dequeue	(sctag0_jbi_iq_dequeue), // Templated
		  .sctag_jbi_wib_dequeue(sctag0_jbi_wib_dequeue), // Templated
		  .testmux_sel		(testmux_sel),
		  .wdq_rdq_push		(wdq_rdq0_push),	 // Templated
		  .wdq_rdq_wdata	(wdq_rdq_wdata[`JBI_RDQ_WIDTH-1:0]),
		  .wdq_rhq_push		(wdq_rhq0_push),	 // Templated
		  .wdq_rhq_wdata	(wdq_rhq_wdata[`JBI_RHQ_WIDTH-1:0]),
		  .wdq_rq_tag_byps	(wdq_rq_tag_byps),
		  .wrtrk_new_wri_tag	(wrtrk_new_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		  .wrtrk_oldest_wri_tag	(wrtrk_rq0_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0])); // Templated

jbi_min_rq u_rq1 (/*AUTOINST*/
		  // Outputs
		  .jbi_scbuf_ecc	(jbi_scbuf1_ecc),	 // Templated
		  .jbi_sctag_req	(jbi_sctag1_req),	 // Templated
		  .jbi_sctag_req_vld	(jbi_sctag1_req_vld),	 // Templated
		  .min_csr_err_l2_to	(min_csr_err_l2_to1),	 // Templated
		  .min_csr_perf_blk_q	(min_csr_perf_blk_q1),	 // Templated
		  .rdq_full		(rdq1_full),		 // Templated
		  .rhq_full		(rhq1_full),		 // Templated
		  // Inputs
		  .arst_l		(arst_l),
		  .clk			(clk),
		  .cpu_clk		(cpu_clk),
		  .cpu_rst_l		(rq_cpu_rst_l_ff1),	 // Templated
		  .cpu_rx_en		(cpu_rx_en),
		  .cpu_tx_en		(cpu_tx_en),
		  .csr_16x65array_margin(csr_16x65array_margin_c[4:0]), // Templated
		  .csr_jbi_config2_max_rd(csr_jbi_config2_max_rd[1:0]),
		  .csr_jbi_config2_max_wr(csr_jbi_config2_max_wr[3:0]),
		  .csr_jbi_config2_max_wris(csr_jbi_config2_max_wris[1:0]),
		  .csr_jbi_l2_timeout_timeval(csr_jbi_l2_timeout_timeval[31:0]),
		  .hold			(hold),
		  .mout_scb_jbus_rd_ack	(mout_scb1_jbus_rd_ack), // Templated
		  .mout_scb_jbus_wr_ack	(mout_scb1_jbus_wr_ack), // Templated
		  .rst_l		(rst_l),
		  .rst_tri_en		(rst_tri_en),
		  .sctag_jbi_iq_dequeue	(sctag1_jbi_iq_dequeue), // Templated
		  .sctag_jbi_wib_dequeue(sctag1_jbi_wib_dequeue), // Templated
		  .testmux_sel		(testmux_sel),
		  .wdq_rdq_push		(wdq_rdq1_push),	 // Templated
		  .wdq_rdq_wdata	(wdq_rdq_wdata[`JBI_RDQ_WIDTH-1:0]),
		  .wdq_rhq_push		(wdq_rhq1_push),	 // Templated
		  .wdq_rhq_wdata	(wdq_rhq_wdata[`JBI_RHQ_WIDTH-1:0]),
		  .wdq_rq_tag_byps	(wdq_rq_tag_byps),
		  .wrtrk_new_wri_tag	(wrtrk_new_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		  .wrtrk_oldest_wri_tag	(wrtrk_rq1_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0])); // Templated

jbi_min_rq u_rq2 (/*AUTOINST*/
		  // Outputs
		  .jbi_scbuf_ecc	(jbi_scbuf2_ecc),	 // Templated
		  .jbi_sctag_req	(jbi_sctag2_req),	 // Templated
		  .jbi_sctag_req_vld	(jbi_sctag2_req_vld),	 // Templated
		  .min_csr_err_l2_to	(min_csr_err_l2_to2),	 // Templated
		  .min_csr_perf_blk_q	(min_csr_perf_blk_q2),	 // Templated
		  .rdq_full		(rdq2_full),		 // Templated
		  .rhq_full		(rhq2_full),		 // Templated
		  // Inputs
		  .arst_l		(arst_l),
		  .clk			(clk),
		  .cpu_clk		(cpu_clk),
		  .cpu_rst_l		(rq_cpu_rst_l_ff2),	 // Templated
		  .cpu_rx_en		(cpu_rx_en),
		  .cpu_tx_en		(cpu_tx_en),
		  .csr_16x65array_margin(csr_16x65array_margin_c[4:0]), // Templated
		  .csr_jbi_config2_max_rd(csr_jbi_config2_max_rd[1:0]),
		  .csr_jbi_config2_max_wr(csr_jbi_config2_max_wr[3:0]),
		  .csr_jbi_config2_max_wris(csr_jbi_config2_max_wris[1:0]),
		  .csr_jbi_l2_timeout_timeval(csr_jbi_l2_timeout_timeval[31:0]),
		  .hold			(hold),
		  .mout_scb_jbus_rd_ack	(mout_scb2_jbus_rd_ack), // Templated
		  .mout_scb_jbus_wr_ack	(mout_scb2_jbus_wr_ack), // Templated
		  .rst_l		(rst_l),
		  .rst_tri_en		(rst_tri_en),
		  .sctag_jbi_iq_dequeue	(sctag2_jbi_iq_dequeue), // Templated
		  .sctag_jbi_wib_dequeue(sctag2_jbi_wib_dequeue), // Templated
		  .testmux_sel		(testmux_sel),
		  .wdq_rdq_push		(wdq_rdq2_push),	 // Templated
		  .wdq_rdq_wdata	(wdq_rdq_wdata[`JBI_RDQ_WIDTH-1:0]),
		  .wdq_rhq_push		(wdq_rhq2_push),	 // Templated
		  .wdq_rhq_wdata	(wdq_rhq_wdata[`JBI_RHQ_WIDTH-1:0]),
		  .wdq_rq_tag_byps	(wdq_rq_tag_byps),
		  .wrtrk_new_wri_tag	(wrtrk_new_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		  .wrtrk_oldest_wri_tag	(wrtrk_rq2_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0])); // Templated

jbi_min_rq u_rq3 (/*AUTOINST*/
		  // Outputs
		  .jbi_scbuf_ecc	(jbi_scbuf3_ecc),	 // Templated
		  .jbi_sctag_req	(jbi_sctag3_req),	 // Templated
		  .jbi_sctag_req_vld	(jbi_sctag3_req_vld),	 // Templated
		  .min_csr_err_l2_to	(min_csr_err_l2_to3),	 // Templated
		  .min_csr_perf_blk_q	(min_csr_perf_blk_q3),	 // Templated
		  .rdq_full		(rdq3_full),		 // Templated
		  .rhq_full		(rhq3_full),		 // Templated
		  // Inputs
		  .arst_l		(arst_l),
		  .clk			(clk),
		  .cpu_clk		(cpu_clk),
		  .cpu_rst_l		(rq_cpu_rst_l_ff3),	 // Templated
		  .cpu_rx_en		(cpu_rx_en),
		  .cpu_tx_en		(cpu_tx_en),
		  .csr_16x65array_margin(csr_16x65array_margin_c[4:0]), // Templated
		  .csr_jbi_config2_max_rd(csr_jbi_config2_max_rd[1:0]),
		  .csr_jbi_config2_max_wr(csr_jbi_config2_max_wr[3:0]),
		  .csr_jbi_config2_max_wris(csr_jbi_config2_max_wris[1:0]),
		  .csr_jbi_l2_timeout_timeval(csr_jbi_l2_timeout_timeval[31:0]),
		  .hold			(hold),
		  .mout_scb_jbus_rd_ack	(mout_scb3_jbus_rd_ack), // Templated
		  .mout_scb_jbus_wr_ack	(mout_scb3_jbus_wr_ack), // Templated
		  .rst_l		(rst_l),
		  .rst_tri_en		(rst_tri_en),
		  .sctag_jbi_iq_dequeue	(sctag3_jbi_iq_dequeue), // Templated
		  .sctag_jbi_wib_dequeue(sctag3_jbi_wib_dequeue), // Templated
		  .testmux_sel		(testmux_sel),
		  .wdq_rdq_push		(wdq_rdq3_push),	 // Templated
		  .wdq_rdq_wdata	(wdq_rdq_wdata[`JBI_RDQ_WIDTH-1:0]),
		  .wdq_rhq_push		(wdq_rhq3_push),	 // Templated
		  .wdq_rhq_wdata	(wdq_rhq_wdata[`JBI_RHQ_WIDTH-1:0]),
		  .wdq_rq_tag_byps	(wdq_rq_tag_byps),
		  .wrtrk_new_wri_tag	(wrtrk_new_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		  .wrtrk_oldest_wri_tag	(wrtrk_rq3_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0])); // Templated

//*******************************************************************************
// Rule Checks
//*******************************************************************************

//synopsys translate_off

always @ ( /*AUTOSENSE*/min_pre_wri_tag or u_wdq.u_wdq_ctl.wdq_empty
	  or wrtrk_new_wri_tag) begin
   @clk;
   if (u_wdq.u_wdq_ctl.wdq_empty 
       && min_pre_wri_tag != wrtrk_new_wri_tag)
      $dispmon ("jbi_min", 49,"%d %m: ERROR - min_pre_wri_tag(0x%x) & wrtrk_new_wri_tag(0x%x) are out of sync!",
		$time, min_pre_wri_tag, wrtrk_new_wri_tag);
end


always @ ( /*AUTOSENSE*/csr_jbi_config2_ord_wr
	  or mout_scb0_jbus_wr_ack or mout_scb1_jbus_wr_ack
	  or mout_scb2_jbus_wr_ack or mout_scb3_jbus_wr_ack) begin
   @cpu_clk;
   if (csr_jbi_config2_ord_wr
       && ((mout_scb0_jbus_wr_ack
       	    + mout_scb1_jbus_wr_ack
       	    + mout_scb2_jbus_wr_ack
       	    + mout_scb3_jbus_wr_ack) > 1))
      $dispmon ("jbi_min", 49,"%d %m: ERROR - more than one mout_scb*_jbu_wr_ack asserted", $time);
end

//synopsys translate_on

endmodule

// Local Variables:
// verilog-library-directories:("." "../../jbi_mout/rtl/")
// verilog-library-files:("../../../common/rtl/swrvr_u1_clib.v")
// verilog-auto-sense-defines-constant:t
// End:
