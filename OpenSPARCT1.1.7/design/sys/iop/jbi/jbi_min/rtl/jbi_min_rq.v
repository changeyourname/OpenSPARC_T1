// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_rq.v
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
//  Description:	Request Queue
//  Top level Module:	jbi_min_rq
//  Where Instantiated:	jbi_min
//
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "jbi.h"


module jbi_min_rq(/*AUTOARG*/
// Outputs
rhq_full, rdq_full, min_csr_perf_blk_q, min_csr_err_l2_to, 
jbi_sctag_req_vld, jbi_sctag_req, jbi_scbuf_ecc, 
// Inputs
wrtrk_oldest_wri_tag, wrtrk_new_wri_tag, wdq_rq_tag_byps, 
wdq_rhq_wdata, wdq_rhq_push, wdq_rdq_wdata, wdq_rdq_push, 
testmux_sel, sctag_jbi_wib_dequeue, sctag_jbi_iq_dequeue, rst_tri_en, 
rst_l, mout_scb_jbus_wr_ack, mout_scb_jbus_rd_ack, hold, 
csr_jbi_l2_timeout_timeval, csr_jbi_config2_max_wris, 
csr_jbi_config2_max_wr, csr_jbi_config2_max_rd, 
csr_16x65array_margin, cpu_tx_en, cpu_rx_en, cpu_rst_l, cpu_clk, clk, 
arst_l
);

/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
input			arst_l;			// To u_rdq_buf of jbi_min_rq_rdq_buf.v
input			clk;			// To u_issue of jbi_min_rq_issue.v, ...
input			cpu_clk;		// To u_dff_cpu_rx_en_ff of dff_ns.v, ...
input			cpu_rst_l;		// To u_issue of jbi_min_rq_issue.v, ...
input			cpu_rx_en;		// To u_dff_cpu_rx_en_ff of dff_ns.v
input			cpu_tx_en;		// To u_dff_cpu_tx_en_ff of dff_ns.v
input [4:0]		csr_16x65array_margin;	// To u_rhq_buf of jbi_min_rq_rhq_buf.v
input [1:0]		csr_jbi_config2_max_rd;	// To u_rhq_ctl of jbi_min_rq_rhq_ctl.v
input [3:0]		csr_jbi_config2_max_wr;	// To u_rhq_ctl of jbi_min_rq_rhq_ctl.v
input [1:0]		csr_jbi_config2_max_wris;// To u_issue of jbi_min_rq_issue.v
input [31:0]		csr_jbi_l2_timeout_timeval;// To u_rhq_ctl of jbi_min_rq_rhq_ctl.v
input			hold;			// To u_rhq_buf of jbi_min_rq_rhq_buf.v, ...
input			mout_scb_jbus_rd_ack;	// To u_rhq_ctl of jbi_min_rq_rhq_ctl.v
input			mout_scb_jbus_wr_ack;	// To u_rhq_ctl of jbi_min_rq_rhq_ctl.v
input			rst_l;			// To u_issue of jbi_min_rq_issue.v, ...
input			rst_tri_en;		// To u_rdq_buf of jbi_min_rq_rdq_buf.v
input			sctag_jbi_iq_dequeue;	// To u_issue of jbi_min_rq_issue.v
input			sctag_jbi_wib_dequeue;	// To u_issue of jbi_min_rq_issue.v
input			testmux_sel;		// To u_rhq_buf of jbi_min_rq_rhq_buf.v
input			wdq_rdq_push;		// To u_rdq_ctl of jbi_min_rq_rdq_ctl.v
input [`JBI_RDQ_WIDTH-1:0]wdq_rdq_wdata;	// To u_rdq_buf of jbi_min_rq_rdq_buf.v
input			wdq_rhq_push;		// To u_rhq_ctl of jbi_min_rq_rhq_ctl.v
input [`JBI_RHQ_WIDTH-1:0]wdq_rhq_wdata;	// To u_rhq_buf of jbi_min_rq_rhq_buf.v
input			wdq_rq_tag_byps;	// To u_rhq_tag of jbi_min_rq_tag.v
input [`JBI_WRI_TAG_WIDTH-1:0]wrtrk_new_wri_tag;// To u_rhq_tag of jbi_min_rq_tag.v
input [`JBI_WRI_TAG_WIDTH-1:0]wrtrk_oldest_wri_tag;// To u_rhq_tag of jbi_min_rq_tag.v
// End of automatics

/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
output [6:0]		jbi_scbuf_ecc;		// From u_issue of jbi_min_rq_issue.v
output [31:0]		jbi_sctag_req;		// From u_issue of jbi_min_rq_issue.v
output			jbi_sctag_req_vld;	// From u_issue of jbi_min_rq_issue.v
output			min_csr_err_l2_to;	// From u_rhq_ctl of jbi_min_rq_rhq_ctl.v
output [3:0]		min_csr_perf_blk_q;	// From u_rhq_ctl of jbi_min_rq_rhq_ctl.v
output			rdq_full;		// From u_rdq_ctl of jbi_min_rq_rdq_ctl.v
output			rhq_full;		// From u_rhq_ctl of jbi_min_rq_rhq_ctl.v
// End of automatics

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire			cpu_rx_en_ff;		// From u_dff_cpu_rx_en_ff of dff_ns.v
wire			cpu_tx_en_ff;		// From u_dff_cpu_tx_en_ff of dff_ns.v
wire			issue_rdq_pop;		// From u_issue of jbi_min_rq_issue.v
wire			issue_rhq_pop;		// From u_issue of jbi_min_rq_issue.v
wire [`JBI_RDQ_ADDR_WIDTH-1:0]rdq_raddr;	// From u_rdq_ctl of jbi_min_rq_rdq_ctl.v
wire			rdq_rd_en;		// From u_rdq_ctl of jbi_min_rq_rdq_ctl.v
wire [`JBI_RDQ_WIDTH-1:0]rdq_rdata;		// From u_rdq_buf of jbi_min_rq_rdq_buf.v
wire [`JBI_RDQ_ADDR_WIDTH-1:0]rdq_waddr;	// From u_rdq_ctl of jbi_min_rq_rdq_ctl.v
wire			rdq_wr_en;		// From u_rdq_ctl of jbi_min_rq_rdq_ctl.v
wire			rhq_csn_rd;		// From u_rhq_ctl of jbi_min_rq_rhq_ctl.v
wire			rhq_csn_wr;		// From u_rhq_ctl of jbi_min_rq_rhq_ctl.v
wire			rhq_drdy;		// From u_rhq_ctl of jbi_min_rq_rhq_ctl.v
wire [`JBI_RHQ_ADDR_WIDTH-1:0]rhq_raddr;	// From u_rhq_ctl of jbi_min_rq_rhq_ctl.v
wire [`JBI_RHQ_WIDTH-1:0]rhq_rdata;		// From u_rhq_buf of jbi_min_rq_rhq_buf.v
wire			rhq_rdata_rw;		// From u_issue of jbi_min_rq_issue.v
wire			rhq_rdata_tag_byps;	// From u_rhq_tag of jbi_min_rq_tag.v
wire [`JBI_RHQ_ADDR_WIDTH-1:0]rhq_tag_raddr;	// From u_rhq_ctl of jbi_min_rq_rhq_ctl.v
wire [`JBI_RHQ_ADDR_WIDTH-1:0]rhq_waddr;	// From u_rhq_ctl of jbi_min_rq_rhq_ctl.v
// End of automatics

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

//
// Code start here 
//

//*******************************************************************************
// Flop Sync Pulses
//*******************************************************************************

/* dff_ns AUTO_TEMPLATE (
 .din(cpu_rx_en),
 .clk(cpu_clk),
 .q(cpu_rx_en_ff),
 ); */

dff_ns #(1) u_dff_cpu_rx_en_ff (/*AUTOINST*/
				// Outputs
				.q	(cpu_rx_en_ff),		 // Templated
				// Inputs
				.din	(cpu_rx_en),		 // Templated
				.clk	(cpu_clk));		 // Templated

/* dff_ns AUTO_TEMPLATE (
 .din(cpu_tx_en),
 .clk(cpu_clk),
 .q(cpu_tx_en_ff),
 ); */

dff_ns #(1) u_dff_cpu_tx_en_ff (/*AUTOINST*/
				// Outputs
				.q	(cpu_tx_en_ff),		 // Templated
				// Inputs
				.din	(cpu_tx_en),		 // Templated
				.clk	(cpu_clk));		 // Templated

//*******************************************************************************
// Request Issue Block
//*******************************************************************************

/* jbi_min_rq_issue AUTO_TEMPLATE (
 .cpu_rx_en	(cpu_rx_en_ff),
 .biq_drdy      (1'b0),
 .biq_rdata_data ({`JBI_BIQ_DATA_WIDTH{1'b0}}),
 .biq_rdata_ecc  ({`JBI_BIQ_ECC_WIDTH{1'b0}}),
 .issue_biq_\(.*\) (),
 ); */

jbi_min_rq_issue u_issue (/*AUTOINST*/
			  // Outputs
			  .issue_rhq_pop(issue_rhq_pop),
			  .issue_rdq_pop(issue_rdq_pop),
			  .rhq_rdata_rw	(rhq_rdata_rw),
			  .issue_biq_data_pop(),		 // Templated
			  .issue_biq_hdr_pop(),			 // Templated
			  .jbi_sctag_req_vld(jbi_sctag_req_vld),
			  .jbi_sctag_req(jbi_sctag_req[31:0]),
			  .jbi_scbuf_ecc(jbi_scbuf_ecc[6:0]),
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .cpu_clk	(cpu_clk),
			  .cpu_rst_l	(cpu_rst_l),
			  .cpu_rx_en	(cpu_rx_en_ff),		 // Templated
			  .csr_jbi_config2_max_wris(csr_jbi_config2_max_wris[1:0]),
			  .rhq_drdy	(rhq_drdy),
			  .rhq_rdata	(rhq_rdata[`JBI_RHQ_WIDTH-1:0]),
			  .rdq_rdata	(rdq_rdata[`JBI_RDQ_WIDTH-1:0]),
			  .biq_drdy	(1'b0),			 // Templated
			  .biq_rdata_data({`JBI_BIQ_DATA_WIDTH{1'b0}}), // Templated
			  .biq_rdata_ecc({`JBI_BIQ_ECC_WIDTH{1'b0}}), // Templated
			  .sctag_jbi_iq_dequeue(sctag_jbi_iq_dequeue),
			  .sctag_jbi_wib_dequeue(sctag_jbi_wib_dequeue));

//*******************************************************************************
// Request Header Queue
//*******************************************************************************

/* jbi_min_rq_rhq_ctl AUTO_TEMPLATE (
 .cpu_tx_en	(cpu_tx_en_ff),
 .cpu_rx_en	(cpu_rx_en_ff),
 ); */

jbi_min_rq_rhq_ctl u_rhq_ctl (/*AUTOINST*/
			      // Outputs
			      .min_csr_err_l2_to(min_csr_err_l2_to),
			      .min_csr_perf_blk_q(min_csr_perf_blk_q[3:0]),
			      .rhq_full	(rhq_full),
			      .rhq_drdy	(rhq_drdy),
			      .rhq_csn_wr(rhq_csn_wr),
			      .rhq_csn_rd(rhq_csn_rd),
			      .rhq_waddr(rhq_waddr[`JBI_RHQ_ADDR_WIDTH-1:0]),
			      .rhq_raddr(rhq_raddr[`JBI_RHQ_ADDR_WIDTH-1:0]),
			      .rhq_tag_raddr(rhq_tag_raddr[`JBI_RHQ_ADDR_WIDTH-1:0]),
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
			      .cpu_clk	(cpu_clk),
			      .cpu_rst_l(cpu_rst_l),
			      .cpu_tx_en(cpu_tx_en_ff),		 // Templated
			      .cpu_rx_en(cpu_rx_en_ff),		 // Templated
			      .csr_jbi_l2_timeout_timeval(csr_jbi_l2_timeout_timeval[31:0]),
			      .csr_jbi_config2_max_rd(csr_jbi_config2_max_rd[1:0]),
			      .csr_jbi_config2_max_wr(csr_jbi_config2_max_wr[3:0]),
			      .wdq_rhq_push(wdq_rhq_push),
			      .issue_rhq_pop(issue_rhq_pop),
			      .rhq_rdata_rw(rhq_rdata_rw),
			      .rhq_rdata_tag_byps(rhq_rdata_tag_byps),
			      .mout_scb_jbus_rd_ack(mout_scb_jbus_rd_ack),
			      .mout_scb_jbus_wr_ack(mout_scb_jbus_wr_ack));

jbi_min_rq_rhq_buf u_rhq_buf (/*AUTOINST*/
			      // Outputs
			      .rhq_rdata(rhq_rdata[`JBI_RHQ_WIDTH-1:0]),
			      // Inputs
			      .clk	(clk),
			      .cpu_clk	(cpu_clk),
			      .hold	(hold),
			      .csr_16x65array_margin(csr_16x65array_margin[4:0]),
			      .testmux_sel(testmux_sel),
			      .rhq_csn_wr(rhq_csn_wr),
			      .rhq_csn_rd(rhq_csn_rd),
			      .rhq_waddr(rhq_waddr[`JBI_RHQ_ADDR_WIDTH-1:0]),
			      .rhq_raddr(rhq_raddr[`JBI_RHQ_ADDR_WIDTH-1:0]),
			      .wdq_rhq_wdata(wdq_rhq_wdata[`JBI_RHQ_WIDTH-1:0]));

/* jbi_min_rq_tag AUTO_TEMPLATE (
 .raddr (rhq_tag_raddr[]),
 .tag_byps_in (wdq_rq_tag_byps),
 .tag_in (wrtrk_new_wri_tag[]),
 .csn_wr (rhq_csn_wr),
 .waddr (rhq_waddr[]),
 .c_tag_byps_out (rhq_rdata_tag_byps),
 .cpu_rx_en	(cpu_rx_en_ff),
 ); */

jbi_min_rq_tag u_rhq_tag (/*AUTOINST*/
			  // Outputs
			  .c_tag_byps_out(rhq_rdata_tag_byps),	 // Templated
			  // Inputs
			  .clk		(clk),
			  .rst_l	(rst_l),
			  .cpu_clk	(cpu_clk),
			  .cpu_rst_l	(cpu_rst_l),
			  .cpu_rx_en	(cpu_rx_en_ff),		 // Templated
			  .wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
			  .raddr	(rhq_tag_raddr[3:0]),	 // Templated
			  .tag_byps_in	(wdq_rq_tag_byps),	 // Templated
			  .tag_in	(wrtrk_new_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]), // Templated
			  .csn_wr	(rhq_csn_wr),		 // Templated
			  .waddr	(rhq_waddr[3:0]));	 // Templated

//*******************************************************************************
// Request Data Queue
//*******************************************************************************

/* jbi_min_rq_rdq_ctl AUTO_TEMPLATE (
 .cpu_tx_en	(cpu_tx_en_ff),
 .cpu_rx_en	(cpu_rx_en_ff),
 ); */

jbi_min_rq_rdq_ctl u_rdq_ctl (/*AUTOINST*/
			      // Outputs
			      .rdq_full	(rdq_full),
			      .rdq_wr_en(rdq_wr_en),
			      .rdq_rd_en(rdq_rd_en),
			      .rdq_waddr(rdq_waddr[`JBI_RDQ_ADDR_WIDTH-1:0]),
			      .rdq_raddr(rdq_raddr[`JBI_RDQ_ADDR_WIDTH-1:0]),
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
			      .cpu_clk	(cpu_clk),
			      .cpu_rst_l(cpu_rst_l),
			      .cpu_tx_en(cpu_tx_en_ff),		 // Templated
			      .cpu_rx_en(cpu_rx_en_ff),		 // Templated
			      .wdq_rdq_push(wdq_rdq_push),
			      .issue_rdq_pop(issue_rdq_pop));

jbi_min_rq_rdq_buf u_rdq_buf (/*AUTOINST*/
			      // Outputs
			      .rdq_rdata(rdq_rdata[`JBI_RDQ_WIDTH-1:0]),
			      // Inputs
			      .clk	(clk),
			      .cpu_clk	(cpu_clk),
			      .arst_l	(arst_l),
			      .hold	(hold),
			      .rst_tri_en(rst_tri_en),
			      .rdq_wr_en(rdq_wr_en),
			      .rdq_rd_en(rdq_rd_en),
			      .rdq_waddr(rdq_waddr[`JBI_RDQ_ADDR_WIDTH-1:0]),
			      .rdq_raddr(rdq_raddr[`JBI_RDQ_ADDR_WIDTH-1:0]),
			      .wdq_rdq_wdata(wdq_rdq_wdata[`JBI_RDQ_WIDTH-1:0]));

//*******************************************************************************
// Request Header Queue
//*******************************************************************************

/* zzecc_sctag_pgen_32b AUTO_TEMPLATE (
 .dout (),
 .parity (biq_wdata_ecc@[]),
 .din (bsc_jbi_sctag_req_ff[((@+1)*32-1):(@*32)]),
 ); */

//zzecc_sctag_pgen_32b u_biq_ecc0 (/*AUTOINST*/);
//zzecc_sctag_pgen_32b u_biq_ecc1 (/*AUTOINST*/);
   

/* jbi_min_rq_biq_ctl AUTO_TEMPLATE (
 .cpu_tx_en	(cpu_tx_en_ff),
 .cpu_rx_en	(cpu_rx_en_ff),
 ); */

//jbi_min_rq_biq_ctl u_biq_ctl (/*AUTOINST*/);

//jbi_min_rq_biq_buf u_biq_buf (/*AUTOINST*/);




endmodule

// Local Variables:
// verilog-library-directories:("." "../../common/rtl")
// verilog-library-files:("../../../common/rtl/swrvr_macro.v" "../../../common/rtl/swrvr_u1_clib.v")
// verilog-auto-sense-defines-constant:t
// End:
