// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncio.v
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
//
//  Where Instantiated:	jbi
//  Description:	Non-Cached IO Block
//      This block includes the PIO and Mondo Interrupt blocks
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

module jbi_ncio (/*AUTOARG*/
// Outputs
ncio_csr_err_intr_to, ncio_csr_perf_pio_rd_out, ncio_csr_perf_pio_wr, 
ncio_csr_perf_pio_rd_latency, ncio_csr_read_addr, ncio_csr_write, 
ncio_csr_write_addr, ncio_csr_write_data, jbi_iob_pio_vld, 
jbi_iob_pio_data, jbi_iob_pio_stall, jbi_iob_mondo_vld, 
jbi_iob_mondo_data, ncio_pio_req, ncio_pio_req_rw, ncio_pio_req_dest, 
ncio_pio_ue, ncio_pio_be, ncio_pio_ad, ncio_yid, ncio_prqq_level, 
ncio_mondo_req, ncio_mondo_ack, ncio_mondo_agnt_id, 
ncio_mondo_cpu_id, ncio_makq_level, ncio_mout_nack_pop, 
// Inputs
clk, rst_l, arst_l, cpu_clk, cpu_rst_l, cpu_rx_en, cpu_tx_en, hold, 
testmux_sel, scan_en, rst_tri_en, csr_16x65array_margin, 
csr_16x81array_margin, csr_jbi_config2_max_pio, 
csr_jbi_config2_ord_int, csr_jbi_config2_ord_pio, 
csr_jbi_intr_timeout_timeval, csr_jbi_intr_timeout_rst_l, 
csr_int_req, csr_csr_read_data, iob_jbi_pio_stall, iob_jbi_pio_vld, 
iob_jbi_pio_data, iob_jbi_mondo_ack, iob_jbi_mondo_nack, 
io_jbi_j_ad_ff, min_pio_rtrn_push, min_pio_data_err, 
min_mondo_hdr_push, min_mondo_data_push, min_mondo_data_err, 
min_oldest_wri_tag, min_pre_wri_tag, mout_trans_yid, mout_pio_pop, 
mout_pio_req_adv, mout_mondo_pop, mout_nack, mout_nack_buf_id, 
mout_nack_thr_id
);

input clk;
input rst_l;
input arst_l;

input cpu_clk;
input cpu_rst_l;
input cpu_rx_en;
input cpu_tx_en;

input hold;
input testmux_sel;
input scan_en;
input rst_tri_en;

// CSR Interface
input [4:0] csr_16x65array_margin;
input [4:0] csr_16x81array_margin;
input [3:0] csr_jbi_config2_max_pio;
input 	    csr_jbi_config2_ord_int;
input 	    csr_jbi_config2_ord_pio;
input [31:0] csr_jbi_intr_timeout_timeval;
input 	     csr_jbi_intr_timeout_rst_l;
input 	     csr_int_req;
output [31:0] ncio_csr_err_intr_to;
output 				 ncio_csr_perf_pio_rd_out;
output 				 ncio_csr_perf_pio_wr;
output [4:0] 			 ncio_csr_perf_pio_rd_latency;

input [`JBI_CSR_WIDTH-1:0] csr_csr_read_data;
output [`JBI_CSR_ADDR_WIDTH-1:0] ncio_csr_read_addr;
output 				 ncio_csr_write;		
output [`JBI_CSR_ADDR_WIDTH-1:0] ncio_csr_write_addr;
output [`JBI_CSR_WIDTH-1:0] 	 ncio_csr_write_data;	

// IOB Interface.
input 				 iob_jbi_pio_stall;
input 				 iob_jbi_pio_vld;
input [`IOB_JBI_WIDTH-1:0] 	 iob_jbi_pio_data;
input 				 iob_jbi_mondo_ack;
input 				 iob_jbi_mondo_nack;
output 				 jbi_iob_pio_vld;
output [`JBI_IOB_WIDTH-1:0] 	 jbi_iob_pio_data;
output 				 jbi_iob_pio_stall;
output 				 jbi_iob_mondo_vld;
output [`JBI_IOB_MONDO_BUS_WIDTH-1:0] jbi_iob_mondo_data;

// Memory In (min)  Interface
input [127:0] 			      io_jbi_j_ad_ff;      // flopped version of j_ad
input 				      min_pio_rtrn_push;
input 				      min_pio_data_err;
input 				      min_mondo_hdr_push;
input 				      min_mondo_data_push;
input 				      min_mondo_data_err;
input [`JBI_WRI_TAG_WIDTH-1:0] 	      min_oldest_wri_tag;
input [`JBI_WRI_TAG_WIDTH-1:0] 	      min_pre_wri_tag;

// Memory Out (mout) Interface
input [`JBI_YID_WIDTH-1:0] 	      mout_trans_yid;
input 				      mout_pio_pop;
input 				      mout_pio_req_adv;
input 				      mout_mondo_pop;
output 				      ncio_pio_req;
output 				      ncio_pio_req_rw;
output [1:0] 			      ncio_pio_req_dest;
output 				      ncio_pio_ue;
output [15:0] 			      ncio_pio_be;
output [63:0] 			      ncio_pio_ad;
output [`JBI_YID_WIDTH-1:0] 	      ncio_yid;
output [`JBI_PRQQ_ADDR_WIDTH:0]       ncio_prqq_level;
output 				      ncio_mondo_req;
output 				      ncio_mondo_ack;  // 1=ack; 0=nack
output [`JBI_AD_INT_AGTID_WIDTH-1:0]  ncio_mondo_agnt_id;
output [`JBI_AD_INT_CPUID_WIDTH-1:0]  ncio_mondo_cpu_id;
output [`JBI_MAKQ_ADDR_WIDTH:0]       ncio_makq_level;

input 				      mout_nack;		
input [`UCB_BUF_HI-`UCB_BUF_LO:0]     mout_nack_buf_id;
input [`UCB_THR_HI-`UCB_THR_LO:0]     mout_nack_thr_id;
output 				      ncio_mout_nack_pop;

/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
// End of automatics
/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
// End of automatics

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire			cpu_rx_en_ff;		// From u_dff_cpu_rx_en_ff of dff_ns.v
wire			cpu_tx_en_ff;		// From u_dff_cpu_tx_en_ff of dff_ns.v
wire			iob_jbi_mondo_ack_ff;	// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire			iob_jbi_mondo_nack_ff;	// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire			makq_csn_wr;		// From u_makq_ctl of jbi_ncio_makq_ctl.v
wire			makq_nack;		// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire			makq_push;		// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire [`JBI_MAKQ_ADDR_WIDTH-1:0]makq_raddr;	// From u_makq_ctl of jbi_ncio_makq_ctl.v
wire [9:0]		makq_rdata;		// From u_makq_buf of jbi_1r1w_16x10.v
wire [`JBI_MAKQ_ADDR_WIDTH-1:0]makq_waddr;	// From u_makq_ctl of jbi_ncio_makq_ctl.v
wire [`JBI_MAKQ_WIDTH-1:0]makq_wdata;		// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire [`JBI_MRQQ_ADDR_WIDTH-1:0]mrqq_raddr;	// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire			mrqq_rd_en;		// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire [`JBI_MRQQ_WIDTH-1:0]mrqq_rdata;		// From u_mrqq_buf of jbi_ncio_mrqq_buf.v
wire [`JBI_MRQQ_ADDR_WIDTH-1:0]mrqq_waddr;	// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire [`JBI_MRQQ_WIDTH-1:0]mrqq_wdata;		// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire			mrqq_wr_en;		// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire			mtag_byps;		// From u_mtag of jbi_ncio_tag.v
wire			mtag_csn_wr;		// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire [3:0]		mtag_raddr;		// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire [3:0]		mtag_waddr;		// From u_mrqq_ctl of jbi_ncio_mrqq_ctl.v
wire			pio_ucbp_req_acpted;	// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire			prqq_ack;		// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire [`UCB_BUF_HI-`UCB_BUF_LO:0]prqq_ack_buf_id;// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire [`UCB_THR_HI-`UCB_THR_LO:0]prqq_ack_thr_id;// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire			prqq_csn_rd;		// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire			prqq_csn_wr;		// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire [`JBI_PRQQ_ADDR_WIDTH-1:0]prqq_raddr;	// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire [`UCB_BUF_HI-`UCB_BUF_LO:0]prqq_rd16_buf_id;// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire [`UCB_THR_HI-`UCB_THR_LO:0]prqq_rd16_thr_id;// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire [`JBI_PRQQ_WIDTH-1:0]prqq_rdata;		// From u_prqq_buf of jbi_ncio_prqq_buf.v
wire			prqq_stall_rd16;	// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire [`JBI_PRQQ_ADDR_WIDTH-1:0]prqq_waddr;	// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire [`JBI_PRQQ_WIDTH-1:0]prqq_wdata;		// From u_prqq_ctl of jbi_ncio_prqq_ctl.v
wire [`UCB_BUF_HI-`UCB_BUF_LO:0]prtq_buf_id_out;// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire			prtq_csn_rd;		// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire			prtq_csn_wr;		// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire			prtq_data128;		// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire [127:0]		prtq_data_out;		// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire			prtq_decr_rd_pend_cnt;	// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire [`UCB_INT_DEV_WIDTH-1:0]prtq_dev_id;	// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire [`UCB_PKT_WIDTH-1:0]prtq_int_type;		// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire			prtq_int_vld;		// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire [`JBI_PRTQ_ADDR_WIDTH-1:0]prtq_raddr;	// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire			prtq_rcv_rtrn16;	// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire			prtq_rd_ack_vld;	// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire			prtq_rd_nack_vld;	// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire [`JBI_PRTQ_WIDTH-1:0]prtq_rdata;		// From u_prtq_buf of jbi_ncio_prtq_buf.v
wire			prtq_tag_byps;		// From u_prtq_tag of jbi_ncio_tag.v
wire [`UCB_THR_HI-`UCB_THR_LO:0]prtq_thr_id_out;// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire [`JBI_PRTQ_ADDR_WIDTH-1:0]prtq_waddr;	// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire [`JBI_PRTQ_WIDTH-1:0]prtq_wdata;		// From u_prtq_ctl of jbi_ncio_prtq_ctl.v
wire			ucbp_ack_busy;		// From u_ncio_ucbp of ucb_flow_jbi.v
wire [`UCB_ADDR_HI-`UCB_ADDR_LO:0]ucbp_addr_in;	// From u_ncio_ucbp of ucb_flow_jbi.v
wire [`UCB_BUF_HI-`UCB_BUF_LO:0]ucbp_buf_id_in;	// From u_ncio_ucbp of ucb_flow_jbi.v
wire [`UCB_DATA_HI-`UCB_DATA_LO:0]ucbp_data_in;	// From u_ncio_ucbp of ucb_flow_jbi.v
wire			ucbp_rd_req_vld;	// From u_ncio_ucbp of ucb_flow_jbi.v
wire [`UCB_SIZE_HI-`UCB_SIZE_LO:0]ucbp_size_in;	// From u_ncio_ucbp of ucb_flow_jbi.v
wire [`UCB_THR_HI-`UCB_THR_LO:0]ucbp_thr_id_in;	// From u_ncio_ucbp of ucb_flow_jbi.v
wire			ucbp_wr_req_vld;	// From u_ncio_ucbp of ucb_flow_jbi.v
// End of automatics

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
// PIO blocks
//*******************************************************************************

//-------------------
// PIO UCB
//-------------------

/* ucb_flow_jbi AUTO_TEMPLATE (
 .iob_ucb_\(.*\)  (iob_jbi_pio_\1),
 .iob_ucb_data    (iob_jbi_pio_data),
 .ucb_iob_\(.*\)  (jbi_iob_pio_\1),
 .ucb_iob_data    (jbi_iob_pio_data),
 
 .\([a-z]*\)_req_vld   (ucbp_\1_req_vld),
 .\(.*\)_in            (ucbp_\1_in[]),
 
 .req_acpted           (pio_ucbp_req_acpted),
 .rd_ack_vld           (prtq_rd_ack_vld),
 .rd_nack_vld          (prtq_rd_nack_vld),
 .thr_id_out           (prtq_thr_id_out[]),
 .buf_id_out           (prtq_buf_id_out[]),
 .data_out             (prtq_data_out[127:0]),
 .data128              (prtq_data128),
 .ack_busy             (ucbp_ack_busy),
 
 .int_vld              (prtq_int_vld),
 .int_typ              (prtq_int_type),
 .int_thr_id           ({`UCB_THR_WIDTH{1'b0}}),
 .dev_id               (prtq_dev_id),
 .int_stat             ({`UCB_INT_STAT_WIDTH{1'b0}}),
 .int_vec              ({`UCB_INT_VEC_WIDTH{1'b0}}),
 .int_busy             (),

 ); */

ucb_flow_jbi #(`IOB_JBI_WIDTH,`JBI_IOB_WIDTH) u_ncio_ucbp (/*AUTOINST*/
							   // Outputs
							   .ucb_iob_stall(jbi_iob_pio_stall), // Templated
							   .rd_req_vld(ucbp_rd_req_vld), // Templated
							   .wr_req_vld(ucbp_wr_req_vld), // Templated
							   .thr_id_in(ucbp_thr_id_in[`UCB_THR_HI-`UCB_THR_LO:0]), // Templated
							   .buf_id_in(ucbp_buf_id_in[`UCB_BUF_HI-`UCB_BUF_LO:0]), // Templated
							   .size_in(ucbp_size_in[`UCB_SIZE_HI-`UCB_SIZE_LO:0]), // Templated
							   .addr_in(ucbp_addr_in[`UCB_ADDR_HI-`UCB_ADDR_LO:0]), // Templated
							   .data_in(ucbp_data_in[`UCB_DATA_HI-`UCB_DATA_LO:0]), // Templated
							   .ack_busy(ucbp_ack_busy), // Templated
							   .int_busy(), // Templated
							   .ucb_iob_vld(jbi_iob_pio_vld), // Templated
							   .ucb_iob_data(jbi_iob_pio_data), // Templated
							   // Inputs
							   .clk(clk),
							   .rst_l(rst_l),
							   .iob_ucb_vld(iob_jbi_pio_vld), // Templated
							   .iob_ucb_data(iob_jbi_pio_data), // Templated
							   .req_acpted(pio_ucbp_req_acpted), // Templated
							   .rd_ack_vld(prtq_rd_ack_vld), // Templated
							   .rd_nack_vld(prtq_rd_nack_vld), // Templated
							   .thr_id_out(prtq_thr_id_out[`UCB_THR_HI-`UCB_THR_LO:0]), // Templated
							   .buf_id_out(prtq_buf_id_out[`UCB_BUF_HI-`UCB_BUF_LO:0]), // Templated
							   .data128(prtq_data128), // Templated
							   .data_out(prtq_data_out[127:0]), // Templated
							   .int_vld(prtq_int_vld), // Templated
							   .int_typ(prtq_int_type), // Templated
							   .int_thr_id({`UCB_THR_WIDTH{1'b0}}), // Templated
							   .dev_id(prtq_dev_id), // Templated
							   .int_stat({`UCB_INT_STAT_WIDTH{1'b0}}), // Templated
							   .int_vec({`UCB_INT_VEC_WIDTH{1'b0}}), // Templated
							   .iob_ucb_stall(iob_jbi_pio_stall)); // Templated

//-------------------
// PIO Requeust Queue
//-------------------

jbi_ncio_prqq_ctl u_prqq_ctl (/*AUTOINST*/
			      // Outputs
			      .ncio_csr_write(ncio_csr_write),
			      .ncio_csr_write_addr(ncio_csr_write_addr[`JBI_CSR_ADDR_WIDTH-1:0]),
			      .ncio_csr_write_data(ncio_csr_write_data[`JBI_CSR_WIDTH-1:0]),
			      .ncio_csr_read_addr(ncio_csr_read_addr[`JBI_CSR_ADDR_WIDTH-1:0]),
			      .ncio_csr_perf_pio_rd_out(ncio_csr_perf_pio_rd_out),
			      .ncio_csr_perf_pio_wr(ncio_csr_perf_pio_wr),
			      .ncio_csr_perf_pio_rd_latency(ncio_csr_perf_pio_rd_latency[4:0]),
			      .pio_ucbp_req_acpted(pio_ucbp_req_acpted),
			      .ncio_pio_req(ncio_pio_req),
			      .ncio_pio_req_rw(ncio_pio_req_rw),
			      .ncio_pio_req_dest(ncio_pio_req_dest[1:0]),
			      .ncio_pio_ue(ncio_pio_ue),
			      .ncio_pio_be(ncio_pio_be[15:0]),
			      .ncio_pio_ad(ncio_pio_ad[63:0]),
			      .ncio_yid	(ncio_yid[`JBI_YID_WIDTH-1:0]),
			      .ncio_prqq_level(ncio_prqq_level[`JBI_PRQQ_ADDR_WIDTH:0]),
			      .prqq_csn_wr(prqq_csn_wr),
			      .prqq_csn_rd(prqq_csn_rd),
			      .prqq_waddr(prqq_waddr[`JBI_PRQQ_ADDR_WIDTH-1:0]),
			      .prqq_wdata(prqq_wdata[`JBI_PRQQ_WIDTH-1:0]),
			      .prqq_raddr(prqq_raddr[`JBI_PRQQ_ADDR_WIDTH-1:0]),
			      .prqq_ack	(prqq_ack),
			      .prqq_ack_thr_id(prqq_ack_thr_id[`UCB_THR_HI-`UCB_THR_LO:0]),
			      .prqq_ack_buf_id(prqq_ack_buf_id[`UCB_BUF_HI-`UCB_BUF_LO:0]),
			      .prqq_rd16_thr_id(prqq_rd16_thr_id[`UCB_THR_HI-`UCB_THR_LO:0]),
			      .prqq_rd16_buf_id(prqq_rd16_buf_id[`UCB_BUF_HI-`UCB_BUF_LO:0]),
			      .prqq_stall_rd16(prqq_stall_rd16),
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
			      .csr_jbi_config2_max_pio(csr_jbi_config2_max_pio[3:0]),
			      .ucbp_rd_req_vld(ucbp_rd_req_vld),
			      .ucbp_wr_req_vld(ucbp_wr_req_vld),
			      .ucbp_thr_id_in(ucbp_thr_id_in[`UCB_THR_HI-`UCB_THR_LO:0]),
			      .ucbp_buf_id_in(ucbp_buf_id_in[`UCB_BUF_HI-`UCB_BUF_LO:0]),
			      .ucbp_size_in(ucbp_size_in[`UCB_SIZE_HI-`UCB_SIZE_LO:0]),
			      .ucbp_addr_in(ucbp_addr_in[`UCB_ADDR_HI-`UCB_ADDR_LO:0]),
			      .ucbp_data_in(ucbp_data_in[`UCB_DATA_HI-`UCB_DATA_LO:0]),
			      .ucbp_ack_busy(ucbp_ack_busy),
			      .mout_pio_pop(mout_pio_pop),
			      .mout_pio_req_adv(mout_pio_req_adv),
			      .prqq_rdata(prqq_rdata[`JBI_PRQQ_WIDTH-1:0]),
			      .prtq_decr_rd_pend_cnt(prtq_decr_rd_pend_cnt),
			      .prtq_rcv_rtrn16(prtq_rcv_rtrn16));

jbi_ncio_prqq_buf u_prqq_buf (/*AUTOINST*/
			      // Outputs
			      .prqq_rdata(prqq_rdata[`JBI_PRQQ_WIDTH-1:0]),
			      // Inputs
			      .clk	(clk),
			      .hold	(hold),
			      .testmux_sel(testmux_sel),
			      .scan_en	(scan_en),
			      .csr_16x81array_margin(csr_16x81array_margin[4:0]),
			      .prqq_csn_wr(prqq_csn_wr),
			      .prqq_csn_rd(prqq_csn_rd),
			      .prqq_waddr(prqq_waddr[`JBI_PRQQ_ADDR_WIDTH-1:0]),
			      .prqq_raddr(prqq_raddr[`JBI_PRQQ_ADDR_WIDTH-1:0]),
			      .prqq_wdata(prqq_wdata[`JBI_PRQQ_WIDTH-1:0]));

//----------------------
// PIO Data Return Queue
//----------------------

jbi_ncio_prtq_ctl u_prtq_ctl (/*AUTOINST*/
			      // Outputs
			      .prtq_rd_ack_vld(prtq_rd_ack_vld),
			      .prtq_rd_nack_vld(prtq_rd_nack_vld),
			      .prtq_thr_id_out(prtq_thr_id_out[`UCB_THR_HI-`UCB_THR_LO:0]),
			      .prtq_buf_id_out(prtq_buf_id_out[`UCB_BUF_HI-`UCB_BUF_LO:0]),
			      .prtq_data_out(prtq_data_out[127:0]),
			      .prtq_data128(prtq_data128),
			      .prtq_int_vld(prtq_int_vld),
			      .prtq_int_type(prtq_int_type[`UCB_PKT_WIDTH-1:0]),
			      .prtq_dev_id(prtq_dev_id[`UCB_INT_DEV_WIDTH-1:0]),
			      .ncio_mout_nack_pop(ncio_mout_nack_pop),
			      .prtq_csn_wr(prtq_csn_wr),
			      .prtq_csn_rd(prtq_csn_rd),
			      .prtq_waddr(prtq_waddr[`JBI_PRTQ_ADDR_WIDTH-1:0]),
			      .prtq_wdata(prtq_wdata[`JBI_PRTQ_WIDTH-1:0]),
			      .prtq_raddr(prtq_raddr[`JBI_PRTQ_ADDR_WIDTH-1:0]),
			      .prtq_decr_rd_pend_cnt(prtq_decr_rd_pend_cnt),
			      .prtq_rcv_rtrn16(prtq_rcv_rtrn16),
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
			      .csr_jbi_config2_ord_pio(csr_jbi_config2_ord_pio),
			      .csr_csr_read_data(csr_csr_read_data[`JBI_CSR_WIDTH-1:0]),
			      .csr_int_req(csr_int_req),
			      .ucbp_ack_busy(ucbp_ack_busy),
			      .io_jbi_j_ad_ff(io_jbi_j_ad_ff[127:0]),
			      .min_pio_rtrn_push(min_pio_rtrn_push),
			      .min_pio_data_err(min_pio_data_err),
			      .mout_trans_yid(mout_trans_yid[`JBI_YID_WIDTH-1:0]),
			      .mout_nack(mout_nack),
			      .mout_nack_thr_id(mout_nack_thr_id[`UCB_THR_HI-`UCB_THR_LO:0]),
			      .mout_nack_buf_id(mout_nack_buf_id[`UCB_BUF_HI-`UCB_BUF_LO:0]),
			      .prtq_rdata(prtq_rdata[`JBI_PRTQ_WIDTH-1:0]),
			      .prtq_tag_byps(prtq_tag_byps),
			      .prqq_ack	(prqq_ack),
			      .prqq_ack_thr_id(prqq_ack_thr_id[`UCB_THR_HI-`UCB_THR_LO:0]),
			      .prqq_ack_buf_id(prqq_ack_buf_id[`UCB_BUF_HI-`UCB_BUF_LO:0]),
			      .prqq_stall_rd16(prqq_stall_rd16),
			      .prqq_rd16_thr_id(prqq_rd16_thr_id[`UCB_THR_HI-`UCB_THR_LO:0]),
			      .prqq_rd16_buf_id(prqq_rd16_buf_id[`UCB_BUF_HI-`UCB_BUF_LO:0]));

jbi_ncio_prtq_buf u_prtq_buf (/*AUTOINST*/
			      // Outputs
			      .prtq_rdata(prtq_rdata[`JBI_PRTQ_WIDTH-1:0]),
			      // Inputs
			      .clk	(clk),
			      .hold	(hold),
			      .testmux_sel(testmux_sel),
			      .scan_en	(scan_en),
			      .csr_16x81array_margin(csr_16x81array_margin[4:0]),
			      .csr_16x65array_margin(csr_16x65array_margin[4:0]),
			      .prtq_csn_wr(prtq_csn_wr),
			      .prtq_csn_rd(prtq_csn_rd),
			      .prtq_waddr(prtq_waddr[`JBI_PRTQ_ADDR_WIDTH-1:0]),
			      .prtq_raddr(prtq_raddr[`JBI_PRTQ_ADDR_WIDTH-1:0]),
			      .prtq_wdata(prtq_wdata[`JBI_PRTQ_WIDTH-1:0]));



/* jbi_ncio_tag AUTO_TEMPLATE (
 .raddr (prtq_raddr[]),
 .waddr (prtq_waddr[]),
 .csn_wr (prtq_csn_wr),
 .tag_in (min_pre_wri_tag[]),
 .tag_byps_in (1'b0),
 .j_tag_byps_out (prtq_tag_byps),
 .cpu_tx_en	(cpu_tx_en_ff),
 .cpu_rx_en	(cpu_rx_en_ff),
); */
jbi_ncio_tag u_prtq_tag (/*AUTOINST*/
			 // Outputs
			 .j_tag_byps_out(prtq_tag_byps),	 // Templated
			 // Inputs
			 .clk		(clk),
			 .rst_l		(rst_l),
			 .cpu_clk	(cpu_clk),
			 .cpu_rst_l	(cpu_rst_l),
			 .cpu_rx_en	(cpu_rx_en_ff),		 // Templated
			 .cpu_tx_en	(cpu_tx_en_ff),		 // Templated
			 .min_oldest_wri_tag(min_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
			 .tag_byps_in	(1'b0),			 // Templated
			 .tag_in	(min_pre_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]), // Templated
			 .csn_wr	(prtq_csn_wr),		 // Templated
			 .waddr		(prtq_waddr[3:0]),	 // Templated
			 .raddr		(prtq_raddr[3:0]));	 // Templated


//*******************************************************************************
// Mondo Block
//*******************************************************************************

//---------------------
// Mondo Requeust Queue
//---------------------
jbi_ncio_mrqq_ctl u_mrqq_ctl (/*AUTOINST*/
			      // Outputs
			      .jbi_iob_mondo_vld(jbi_iob_mondo_vld),
			      .jbi_iob_mondo_data(jbi_iob_mondo_data[`JBI_IOB_MONDO_BUS_WIDTH-1:0]),
			      .iob_jbi_mondo_ack_ff(iob_jbi_mondo_ack_ff),
			      .iob_jbi_mondo_nack_ff(iob_jbi_mondo_nack_ff),
			      .makq_push(makq_push),
			      .makq_wdata(makq_wdata[`JBI_MAKQ_WIDTH-1:0]),
			      .makq_nack(makq_nack),
			      .mrqq_wr_en(mrqq_wr_en),
			      .mrqq_rd_en(mrqq_rd_en),
			      .mrqq_waddr(mrqq_waddr[`JBI_MRQQ_ADDR_WIDTH-1:0]),
			      .mrqq_wdata(mrqq_wdata[`JBI_MRQQ_WIDTH-1:0]),
			      .mrqq_raddr(mrqq_raddr[`JBI_MRQQ_ADDR_WIDTH-1:0]),
			      .mtag_csn_wr(mtag_csn_wr),
			      .mtag_waddr(mtag_waddr[3:0]),
			      .mtag_raddr(mtag_raddr[3:0]),
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
			      .csr_jbi_config2_ord_int(csr_jbi_config2_ord_int),
			      .io_jbi_j_ad_ff(io_jbi_j_ad_ff[127:0]),
			      .min_mondo_hdr_push(min_mondo_hdr_push),
			      .min_mondo_data_push(min_mondo_data_push),
			      .min_mondo_data_err(min_mondo_data_err),
			      .iob_jbi_mondo_ack(iob_jbi_mondo_ack),
			      .iob_jbi_mondo_nack(iob_jbi_mondo_nack),
			      .mrqq_rdata(mrqq_rdata[`JBI_MRQQ_WIDTH-1:0]),
			      .mtag_byps(mtag_byps));

jbi_ncio_mrqq_buf u_mrqq_buf (/*AUTOINST*/
			      // Outputs
			      .mrqq_rdata(mrqq_rdata[`JBI_MRQQ_WIDTH-1:0]),
			      // Inputs
			      .clk	(clk),
			      .arst_l	(arst_l),
			      .hold	(hold),
			      .rst_tri_en(rst_tri_en),
			      .mrqq_wr_en(mrqq_wr_en),
			      .mrqq_rd_en(mrqq_rd_en),
			      .mrqq_waddr(mrqq_waddr[`JBI_MRQQ_ADDR_WIDTH-1:0]),
			      .mrqq_raddr(mrqq_raddr[`JBI_MRQQ_ADDR_WIDTH-1:0]),
			      .mrqq_wdata(mrqq_wdata[`JBI_MRQQ_WIDTH-1:0]));


/* jbi_ncio_tag AUTO_TEMPLATE (
 .raddr (mtag_raddr[]),
 .waddr (mtag_waddr[]),
 .csn_wr (mtag_csn_wr),
 .tag_in (min_pre_wri_tag[]),
 .tag_byps_in (1'b0),
 .j_tag_byps_out (mtag_byps),
 .cpu_tx_en	(cpu_tx_en_ff),
 .cpu_rx_en	(cpu_rx_en_ff),
); */
jbi_ncio_tag u_mtag (/*AUTOINST*/
		     // Outputs
		     .j_tag_byps_out	(mtag_byps),		 // Templated
		     // Inputs
		     .clk		(clk),
		     .rst_l		(rst_l),
		     .cpu_clk		(cpu_clk),
		     .cpu_rst_l		(cpu_rst_l),
		     .cpu_rx_en		(cpu_rx_en_ff),		 // Templated
		     .cpu_tx_en		(cpu_tx_en_ff),		 // Templated
		     .min_oldest_wri_tag(min_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		     .tag_byps_in	(1'b0),			 // Templated
		     .tag_in		(min_pre_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]), // Templated
		     .csn_wr		(mtag_csn_wr),		 // Templated
		     .waddr		(mtag_waddr[3:0]),	 // Templated
		     .raddr		(mtag_raddr[3:0]));	 // Templated

//---------------------
// Mondo Ack Queue
//---------------------
jbi_ncio_makq_ctl u_makq_ctl (/*AUTOINST*/
			      // Outputs
			      .makq_csn_wr(makq_csn_wr),
			      .makq_waddr(makq_waddr[`JBI_MAKQ_ADDR_WIDTH-1:0]),
			      .makq_raddr(makq_raddr[`JBI_MAKQ_ADDR_WIDTH-1:0]),
			      .ncio_mondo_req(ncio_mondo_req),
			      .ncio_mondo_ack(ncio_mondo_ack),
			      .ncio_mondo_agnt_id(ncio_mondo_agnt_id[`JBI_AD_INT_AGTID_WIDTH-1:0]),
			      .ncio_mondo_cpu_id(ncio_mondo_cpu_id[`JBI_AD_INT_CPUID_WIDTH-1:0]),
			      .ncio_makq_level(ncio_makq_level[`JBI_MAKQ_ADDR_WIDTH:0]),
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
			      .makq_push(makq_push),
			      .makq_nack(makq_nack),
			      .iob_jbi_mondo_ack_ff(iob_jbi_mondo_ack_ff),
			      .iob_jbi_mondo_nack_ff(iob_jbi_mondo_nack_ff),
			      .makq_rdata(makq_rdata[`JBI_MAKQ_WIDTH-1:0]),
			      .mout_mondo_pop(mout_mondo_pop));

/*jbi_1r1w_16x10 AUTO_TEMPLATE (
 .do (makq_rdata[]),
 .rd_a (makq_raddr[]),
 .wr_a (makq_waddr[]),
 .di   (makq_wdata[]),
 .rd_clk (clk),
 .wr_clk (clk),
 .csn_rd (makq_csn_rd),
 .csn_wr (makq_csn_wr),
 ); */
jbi_1r1w_16x10 u_makq_buf (/*AUTOINST*/
			   // Outputs
			   .do		(makq_rdata[9:0]),	 // Templated
			   // Inputs
			   .rd_a	(makq_raddr[3:0]),	 // Templated
			   .wr_a	(makq_waddr[3:0]),	 // Templated
			   .di		(makq_wdata[9:0]),	 // Templated
			   .rd_clk	(clk),			 // Templated
			   .wr_clk	(clk),			 // Templated
			   .csn_wr	(makq_csn_wr));		 // Templated

//---------------------
// Mondo IntAck Timeout
//---------------------

jbi_ncio_mto_ctl u_mto (/*AUTOINST*/
			// Outputs
			.ncio_csr_err_intr_to(ncio_csr_err_intr_to[31:0]),
			// Inputs
			.clk		(clk),
			.rst_l		(rst_l),
			.csr_jbi_intr_timeout_timeval(csr_jbi_intr_timeout_timeval[31:0]),
			.csr_jbi_intr_timeout_rst_l(csr_jbi_intr_timeout_rst_l),
			.mout_mondo_pop	(mout_mondo_pop),
			.ncio_mondo_ack	(ncio_mondo_ack),
			.ncio_mondo_cpu_id(ncio_mondo_cpu_id[`JBI_AD_INT_CPUID_WIDTH-1:0]),
			.min_mondo_hdr_push(min_mondo_hdr_push),
			.io_jbi_j_ad_ff	(io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO]));


endmodule

// Local Variables:
// verilog-library-directories:("." "../../common/rtl" "../../../common/rtl")
// verilog-library-files:("../../../common/rtl/swrvr_u1_clib.v")
// verilog-auto-sense-defines-constant:t
// End:
