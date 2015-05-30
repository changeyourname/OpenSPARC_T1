// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncio_mto_ctl.v
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
//  Description:	Mondo Timeout Control Block
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include "sys.h"
`include "jbi.h"


module jbi_ncio_mto_ctl(/*AUTOARG*/
// Outputs
ncio_csr_err_intr_to, 
// Inputs
clk, rst_l, csr_jbi_intr_timeout_timeval, csr_jbi_intr_timeout_rst_l, 
mout_mondo_pop, ncio_mondo_ack, ncio_mondo_cpu_id, 
min_mondo_hdr_push, io_jbi_j_ad_ff
);

input clk;
input rst_l;

// CSR Interface
input [31:0] csr_jbi_intr_timeout_timeval;
input 	     csr_jbi_intr_timeout_rst_l;
output [31:0] ncio_csr_err_intr_to;

// Mout <-> NCIO
input 	     mout_mondo_pop;
input 	     ncio_mondo_ack;
input [`JBI_AD_INT_CPUID_WIDTH-1:0] ncio_mondo_cpu_id;

// Min -> NCIO
input 				    min_mondo_hdr_push;
input [`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] io_jbi_j_ad_ff;

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire [31:0] 					  ncio_csr_err_intr_to;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

wire [31:0]  timeout_cnt;
wire [31:0]  next_timeout_cnt;

wire 	     timeout_cnt_rst_l;
wire 	     timeout_wrap;

wire [31:0]  int_rst_l;  // clear interrupt entry
wire [31:0]  int_vld;    // validate interrupt entry

//
// Code start here 
//

//*******************************************************************************
// Error Handling - Mondo INTACK Timeout
//*******************************************************************************

// Free-running timeout counter
assign next_timeout_cnt = timeout_cnt + 1'b1;
assign timeout_cnt_rst_l = rst_l & csr_jbi_intr_timeout_rst_l & ~timeout_wrap;

assign timeout_wrap = timeout_cnt == csr_jbi_intr_timeout_timeval;

dffrl_ns #(32) u_dffrl_timeout_cnt
   (.din(next_timeout_cnt),
    .clk(clk),
    .rst_l(timeout_cnt_rst_l),
    .q(timeout_cnt)
    );

// Validate interrupt entry when receive a mondo interrupt on JBUS
assign int_vld[0] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd0;
assign int_vld[1] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd1;
assign int_vld[2] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd2;
assign int_vld[3] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd3;
assign int_vld[4] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd4;
assign int_vld[5] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd5;
assign int_vld[6] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd6;
assign int_vld[7] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd7;
assign int_vld[8] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd8;
assign int_vld[9] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd9;
assign int_vld[10] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd10;
assign int_vld[11] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd11;
assign int_vld[12] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd12;
assign int_vld[13] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd13;
assign int_vld[14] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd14;
assign int_vld[15] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd15;
assign int_vld[16] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd16;
assign int_vld[17] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd17;
assign int_vld[18] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd18;
assign int_vld[19] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd19;
assign int_vld[20] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd20;
assign int_vld[21] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd21;
assign int_vld[22] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd22;
assign int_vld[23] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd23;
assign int_vld[24] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd24;
assign int_vld[25] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd25;
assign int_vld[26] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd26;
assign int_vld[27] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd27;
assign int_vld[28] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd28;
assign int_vld[29] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd29;
assign int_vld[30] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd30;
assign int_vld[31] = min_mondo_hdr_push & io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO] == 5'd31;

// Clear interrupt entry when when issue an ack on JBUS
// - this bit resets both timeout and valid bit
assign int_rst_l[0] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd0);
assign int_rst_l[1] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd1);
assign int_rst_l[2] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd2);
assign int_rst_l[3] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd3);
assign int_rst_l[4] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd4);
assign int_rst_l[5] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd5);
assign int_rst_l[6] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd6);
assign int_rst_l[7] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd7);
assign int_rst_l[8] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd8);
assign int_rst_l[9] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd9);
assign int_rst_l[10] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd10);
assign int_rst_l[11] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd11);
assign int_rst_l[12] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd12);
assign int_rst_l[13] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd13);
assign int_rst_l[14] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd14);
assign int_rst_l[15] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd15);
assign int_rst_l[16] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd16);
assign int_rst_l[17] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd17);
assign int_rst_l[18] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd18);
assign int_rst_l[19] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd19);
assign int_rst_l[20] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd20);
assign int_rst_l[21] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd21);
assign int_rst_l[22] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd22);
assign int_rst_l[23] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd23);
assign int_rst_l[24] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd24);
assign int_rst_l[25] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd25);
assign int_rst_l[26] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd26);
assign int_rst_l[27] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd27);
assign int_rst_l[28] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd28);
assign int_rst_l[29] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd29);
assign int_rst_l[30] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd30);
assign int_rst_l[31] = rst_l & ~(mout_mondo_pop & ncio_mondo_ack & ncio_mondo_cpu_id == 5'd31);

// Slice instantiation

/* jbi_ncio_mto_slice AUTO_TEMPLATE (
 .int_rst_l (int_rst_l[@]),
 .int_vld   (int_vld[@]),
 .timeout_err (ncio_csr_err_intr_to[@]),
 ); */

jbi_ncio_mto_slice u_mto_slice0 (/*AUTOINST*/
				 // Outputs
				 .timeout_err(ncio_csr_err_intr_to[0]), // Templated
				 // Inputs
				 .clk	(clk),
				 .timeout_wrap(timeout_wrap),
				 .int_rst_l(int_rst_l[0]),	 // Templated
				 .int_vld(int_vld[0]));		 // Templated
jbi_ncio_mto_slice u_mto_slice1 (/*AUTOINST*/
				 // Outputs
				 .timeout_err(ncio_csr_err_intr_to[1]), // Templated
				 // Inputs
				 .clk	(clk),
				 .timeout_wrap(timeout_wrap),
				 .int_rst_l(int_rst_l[1]),	 // Templated
				 .int_vld(int_vld[1]));		 // Templated
jbi_ncio_mto_slice u_mto_slice2 (/*AUTOINST*/
				 // Outputs
				 .timeout_err(ncio_csr_err_intr_to[2]), // Templated
				 // Inputs
				 .clk	(clk),
				 .timeout_wrap(timeout_wrap),
				 .int_rst_l(int_rst_l[2]),	 // Templated
				 .int_vld(int_vld[2]));		 // Templated
jbi_ncio_mto_slice u_mto_slice3 (/*AUTOINST*/
				 // Outputs
				 .timeout_err(ncio_csr_err_intr_to[3]), // Templated
				 // Inputs
				 .clk	(clk),
				 .timeout_wrap(timeout_wrap),
				 .int_rst_l(int_rst_l[3]),	 // Templated
				 .int_vld(int_vld[3]));		 // Templated
jbi_ncio_mto_slice u_mto_slice4 (/*AUTOINST*/
				 // Outputs
				 .timeout_err(ncio_csr_err_intr_to[4]), // Templated
				 // Inputs
				 .clk	(clk),
				 .timeout_wrap(timeout_wrap),
				 .int_rst_l(int_rst_l[4]),	 // Templated
				 .int_vld(int_vld[4]));		 // Templated
jbi_ncio_mto_slice u_mto_slice5 (/*AUTOINST*/
				 // Outputs
				 .timeout_err(ncio_csr_err_intr_to[5]), // Templated
				 // Inputs
				 .clk	(clk),
				 .timeout_wrap(timeout_wrap),
				 .int_rst_l(int_rst_l[5]),	 // Templated
				 .int_vld(int_vld[5]));		 // Templated
jbi_ncio_mto_slice u_mto_slice6 (/*AUTOINST*/
				 // Outputs
				 .timeout_err(ncio_csr_err_intr_to[6]), // Templated
				 // Inputs
				 .clk	(clk),
				 .timeout_wrap(timeout_wrap),
				 .int_rst_l(int_rst_l[6]),	 // Templated
				 .int_vld(int_vld[6]));		 // Templated
jbi_ncio_mto_slice u_mto_slice7 (/*AUTOINST*/
				 // Outputs
				 .timeout_err(ncio_csr_err_intr_to[7]), // Templated
				 // Inputs
				 .clk	(clk),
				 .timeout_wrap(timeout_wrap),
				 .int_rst_l(int_rst_l[7]),	 // Templated
				 .int_vld(int_vld[7]));		 // Templated
jbi_ncio_mto_slice u_mto_slice8 (/*AUTOINST*/
				 // Outputs
				 .timeout_err(ncio_csr_err_intr_to[8]), // Templated
				 // Inputs
				 .clk	(clk),
				 .timeout_wrap(timeout_wrap),
				 .int_rst_l(int_rst_l[8]),	 // Templated
				 .int_vld(int_vld[8]));		 // Templated
jbi_ncio_mto_slice u_mto_slice9 (/*AUTOINST*/
				 // Outputs
				 .timeout_err(ncio_csr_err_intr_to[9]), // Templated
				 // Inputs
				 .clk	(clk),
				 .timeout_wrap(timeout_wrap),
				 .int_rst_l(int_rst_l[9]),	 // Templated
				 .int_vld(int_vld[9]));		 // Templated
jbi_ncio_mto_slice u_mto_slice10 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[10]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[10]),	 // Templated
				  .int_vld(int_vld[10]));	 // Templated
jbi_ncio_mto_slice u_mto_slice11 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[11]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[11]),	 // Templated
				  .int_vld(int_vld[11]));	 // Templated
jbi_ncio_mto_slice u_mto_slice12 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[12]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[12]),	 // Templated
				  .int_vld(int_vld[12]));	 // Templated
jbi_ncio_mto_slice u_mto_slice13 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[13]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[13]),	 // Templated
				  .int_vld(int_vld[13]));	 // Templated
jbi_ncio_mto_slice u_mto_slice14 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[14]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[14]),	 // Templated
				  .int_vld(int_vld[14]));	 // Templated
jbi_ncio_mto_slice u_mto_slice15 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[15]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[15]),	 // Templated
				  .int_vld(int_vld[15]));	 // Templated
jbi_ncio_mto_slice u_mto_slice16 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[16]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[16]),	 // Templated
				  .int_vld(int_vld[16]));	 // Templated
jbi_ncio_mto_slice u_mto_slice17 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[17]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[17]),	 // Templated
				  .int_vld(int_vld[17]));	 // Templated
jbi_ncio_mto_slice u_mto_slice18 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[18]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[18]),	 // Templated
				  .int_vld(int_vld[18]));	 // Templated
jbi_ncio_mto_slice u_mto_slice19 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[19]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[19]),	 // Templated
				  .int_vld(int_vld[19]));	 // Templated
jbi_ncio_mto_slice u_mto_slice20 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[20]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[20]),	 // Templated
				  .int_vld(int_vld[20]));	 // Templated
jbi_ncio_mto_slice u_mto_slice21 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[21]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[21]),	 // Templated
				  .int_vld(int_vld[21]));	 // Templated
jbi_ncio_mto_slice u_mto_slice22 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[22]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[22]),	 // Templated
				  .int_vld(int_vld[22]));	 // Templated
jbi_ncio_mto_slice u_mto_slice23 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[23]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[23]),	 // Templated
				  .int_vld(int_vld[23]));	 // Templated
jbi_ncio_mto_slice u_mto_slice24 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[24]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[24]),	 // Templated
				  .int_vld(int_vld[24]));	 // Templated
jbi_ncio_mto_slice u_mto_slice25 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[25]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[25]),	 // Templated
				  .int_vld(int_vld[25]));	 // Templated
jbi_ncio_mto_slice u_mto_slice26 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[26]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[26]),	 // Templated
				  .int_vld(int_vld[26]));	 // Templated
jbi_ncio_mto_slice u_mto_slice27 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[27]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[27]),	 // Templated
				  .int_vld(int_vld[27]));	 // Templated
jbi_ncio_mto_slice u_mto_slice28 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[28]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[28]),	 // Templated
				  .int_vld(int_vld[28]));	 // Templated
jbi_ncio_mto_slice u_mto_slice29 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[29]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[29]),	 // Templated
				  .int_vld(int_vld[29]));	 // Templated
jbi_ncio_mto_slice u_mto_slice30 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[30]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[30]),	 // Templated
				  .int_vld(int_vld[30]));	 // Templated
jbi_ncio_mto_slice u_mto_slice31 (/*AUTOINST*/
				  // Outputs
				  .timeout_err(ncio_csr_err_intr_to[31]), // Templated
				  // Inputs
				  .clk	(clk),
				  .timeout_wrap(timeout_wrap),
				  .int_rst_l(int_rst_l[31]),	 // Templated
				  .int_vld(int_vld[31]));	 // Templated

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:

endmodule
