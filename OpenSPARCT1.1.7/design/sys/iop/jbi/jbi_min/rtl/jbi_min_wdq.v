// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_wdq.v
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
//  Description:	Write Decomposition Block
//  Top level Module:	jbi_min_wdq
//  Where Instantiated:	jbi_min
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "jbi.h"


module jbi_min_wdq(/*AUTOARG*/
// Outputs
wdq_wr_vld, wdq_rq_tag_byps, wdq_rhq_wdata, wdq_rhq3_push, 
wdq_rhq2_push, wdq_rhq1_push, wdq_rhq0_push, wdq_rdq_wdata, 
wdq_rdq3_push, wdq_rdq2_push, wdq_rdq1_push, wdq_rdq0_push, 
min_csr_perf_dma_wr8, min_aok_on, min_aok_off, 
// Inputs
testmux_sel, rst_tri_en, rst_l, rhq3_full, rhq2_full, rhq1_full, 
rhq0_full, rdq3_full, rdq2_full, rdq1_full, rdq0_full, 
parse_wdq_push, parse_subline_req, parse_sctag_req, parse_rw, 
parse_install_mode, parse_hdr, parse_err_nonex_rd, parse_data_err, 
io_jbi_j_adtype_ff, hold, csr_jbi_config2_ord_wr, 
csr_jbi_config2_ord_rd, csr_jbi_config2_iq_low, 
csr_jbi_config2_iq_high, clk, arst_l, io_jbi_j_ad_ff
);

/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
input			arst_l;			// To u_wdq_buf of jbi_min_wdq_buf.v
input			clk;			// To u_wdq_ctl of jbi_min_wdq_ctl.v, ...
input [3:0]		csr_jbi_config2_iq_high;// To u_wdq_ctl of jbi_min_wdq_ctl.v
input [3:0]		csr_jbi_config2_iq_low;	// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			csr_jbi_config2_ord_rd;	// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			csr_jbi_config2_ord_wr;	// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			hold;			// To u_wdq_buf of jbi_min_wdq_buf.v
input [`JBI_ADTYPE_JID_HI:`JBI_ADTYPE_JID_LO]io_jbi_j_adtype_ff;// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			parse_data_err;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			parse_err_nonex_rd;	// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			parse_hdr;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			parse_install_mode;	// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			parse_rw;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input [2:0]		parse_sctag_req;	// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			parse_subline_req;	// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			parse_wdq_push;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			rdq0_full;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			rdq1_full;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			rdq2_full;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			rdq3_full;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			rhq0_full;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			rhq1_full;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			rhq2_full;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			rhq3_full;		// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			rst_l;			// To u_wdq_ctl of jbi_min_wdq_ctl.v
input			rst_tri_en;		// To u_wdq_buf of jbi_min_wdq_buf.v
input			testmux_sel;		// To u_wdq_buf of jbi_min_wdq_buf.v
// End of automatics

input [127:0] 		io_jbi_j_ad_ff;


/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
output			min_aok_off;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			min_aok_on;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			min_csr_perf_dma_wr8;	// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			wdq_rdq0_push;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			wdq_rdq1_push;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			wdq_rdq2_push;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			wdq_rdq3_push;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
output [`JBI_RDQ_WIDTH-1:0]wdq_rdq_wdata;	// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			wdq_rhq0_push;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			wdq_rhq1_push;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			wdq_rhq2_push;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			wdq_rhq3_push;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
output [`JBI_RHQ_WIDTH-1:0]wdq_rhq_wdata;	// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			wdq_rq_tag_byps;	// From u_wdq_ctl of jbi_min_wdq_ctl.v
output			wdq_wr_vld;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
// End of automatics

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [`JBI_WDQ_ADDR_WIDTH-1:0]wdq_raddr;	// From u_wdq_ctl of jbi_min_wdq_ctl.v
wire			wdq_rd_en;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
wire [`JBI_WDQ_WIDTH-1:0]wdq_rdata;		// From u_wdq_buf of jbi_min_wdq_buf.v
wire [`JBI_WDQ_ADDR_WIDTH-1:0]wdq_waddr;	// From u_wdq_ctl of jbi_min_wdq_ctl.v
wire [127:0]		wdq_wdata;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
wire [6:0]		wdq_wdata_ecc0;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
wire [6:0]		wdq_wdata_ecc1;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
wire [6:0]		wdq_wdata_ecc2;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
wire [6:0]		wdq_wdata_ecc3;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
wire			wdq_wr_en;		// From u_wdq_ctl of jbi_min_wdq_ctl.v
// End of automatics

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

//
// Code start here 
//

   
jbi_min_wdq_ctl u_wdq_ctl (/*AUTOINST*/
			   // Outputs
			   .min_csr_perf_dma_wr8(min_csr_perf_dma_wr8),
			   .wdq_wr_en	(wdq_wr_en),
			   .wdq_wdata	(wdq_wdata[127:0]),
			   .wdq_wdata_ecc0(wdq_wdata_ecc0[6:0]),
			   .wdq_wdata_ecc1(wdq_wdata_ecc1[6:0]),
			   .wdq_wdata_ecc2(wdq_wdata_ecc2[6:0]),
			   .wdq_wdata_ecc3(wdq_wdata_ecc3[6:0]),
			   .wdq_waddr	(wdq_waddr[`JBI_WDQ_ADDR_WIDTH-1:0]),
			   .wdq_rd_en	(wdq_rd_en),
			   .wdq_raddr	(wdq_raddr[`JBI_WDQ_ADDR_WIDTH-1:0]),
			   .wdq_rdq0_push(wdq_rdq0_push),
			   .wdq_rdq1_push(wdq_rdq1_push),
			   .wdq_rdq2_push(wdq_rdq2_push),
			   .wdq_rdq3_push(wdq_rdq3_push),
			   .wdq_rdq_wdata(wdq_rdq_wdata[`JBI_RDQ_WIDTH-1:0]),
			   .wdq_rhq0_push(wdq_rhq0_push),
			   .wdq_rhq1_push(wdq_rhq1_push),
			   .wdq_rhq2_push(wdq_rhq2_push),
			   .wdq_rhq3_push(wdq_rhq3_push),
			   .wdq_rhq_wdata(wdq_rhq_wdata[`JBI_RHQ_WIDTH-1:0]),
			   .wdq_rq_tag_byps(wdq_rq_tag_byps),
			   .wdq_wr_vld	(wdq_wr_vld),
			   .min_aok_on	(min_aok_on),
			   .min_aok_off	(min_aok_off),
			   // Inputs
			   .clk		(clk),
			   .rst_l	(rst_l),
			   .csr_jbi_config2_iq_high(csr_jbi_config2_iq_high[3:0]),
			   .csr_jbi_config2_iq_low(csr_jbi_config2_iq_low[3:0]),
			   .csr_jbi_config2_ord_wr(csr_jbi_config2_ord_wr),
			   .csr_jbi_config2_ord_rd(csr_jbi_config2_ord_rd),
			   .io_jbi_j_ad_ff(io_jbi_j_ad_ff[127:0]),
			   .io_jbi_j_adtype_ff(io_jbi_j_adtype_ff[`JBI_ADTYPE_JID_HI:`JBI_ADTYPE_JID_LO]),
			   .parse_wdq_push(parse_wdq_push),
			   .parse_sctag_req(parse_sctag_req[2:0]),
			   .parse_hdr	(parse_hdr),
			   .parse_rw	(parse_rw),
			   .parse_subline_req(parse_subline_req),
			   .parse_install_mode(parse_install_mode),
			   .parse_data_err(parse_data_err),
			   .parse_err_nonex_rd(parse_err_nonex_rd),
			   .rdq0_full	(rdq0_full),
			   .rdq1_full	(rdq1_full),
			   .rdq2_full	(rdq2_full),
			   .rdq3_full	(rdq3_full),
			   .wdq_rdata	(wdq_rdata[`JBI_WDQ_WIDTH-1:0]),
			   .rhq0_full	(rhq0_full),
			   .rhq1_full	(rhq1_full),
			   .rhq2_full	(rhq2_full),
			   .rhq3_full	(rhq3_full));

jbi_min_wdq_buf u_wdq_buf (/*AUTOINST*/
			   // Outputs
			   .wdq_rdata	(wdq_rdata[`JBI_WDQ_WIDTH-1:0]),
			   // Inputs
			   .clk		(clk),
			   .arst_l	(arst_l),
			   .testmux_sel	(testmux_sel),
			   .hold	(hold),
			   .rst_tri_en	(rst_tri_en),
			   .wdq_wr_en	(wdq_wr_en),
			   .wdq_rd_en	(wdq_rd_en),
			   .wdq_waddr	(wdq_waddr[`JBI_WDQ_ADDR_WIDTH-1:0]),
			   .wdq_raddr	(wdq_raddr[`JBI_WDQ_ADDR_WIDTH-1:0]),
			   .wdq_wdata	(wdq_wdata[127:0]),
			   .wdq_wdata_ecc0(wdq_wdata_ecc0[6:0]),
			   .wdq_wdata_ecc1(wdq_wdata_ecc1[6:0]),
			   .wdq_wdata_ecc2(wdq_wdata_ecc2[6:0]),
			   .wdq_wdata_ecc3(wdq_wdata_ecc3[6:0]));


endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
