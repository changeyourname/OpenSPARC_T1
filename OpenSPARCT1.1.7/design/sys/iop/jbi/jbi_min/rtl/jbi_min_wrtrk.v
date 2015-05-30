// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_wrtrk.v
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
//
//
//  Top level Module:	jbi_min_wrtrk
//  Where Instantiated:	jbi_min
//
//  Description:	WRI Tracker
//  
//  The WRI Tracker keeps count of the number of outstanding WRI (received by 
//  JBI but not yet acknowledged by SCTAG) and the oldest WRI in JBI.  This block 
//  contains 3 counters: one  WRI pending counter and two tag counters.
//
//  The wri_pend counter is incremented when a WRI is inserted into a
//  MemReqQ and decremented when SCTAG gives an acknowledgement (sends Write Ack packet).
//  Because no more than one port can have outstanding WRI (issued WRI waiting for ack),
//  only one counter is necessary for 4 SCTAGs.
//
//  There are two 6-bit tag counters (upper bit to resolve wrap ambiguity): 
//  new_wri_tag[5:0] increments with each new WRI* received from Jbus (all WRI* 
//  are assigned a tag #) and oldest_wri_tag is incremented with each WrAck 
//  received from the SCTAGs.
//
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition


`include "jbi.h"

module jbi_min_wrtrk (/*AUTOARG*/
// Outputs
min_oldest_wri_tag, min_pre_wri_tag, wrtrk_new_wri_tag, 
wrtrk_rq0_oldest_wri_tag, wrtrk_rq1_oldest_wri_tag, 
wrtrk_rq2_oldest_wri_tag, wrtrk_rq3_oldest_wri_tag, 
// Inputs
clk, rst_l, cpu_clk, cpu_rst_l, io_jbi_j_ad_ff, parse_wdq_push, 
parse_hdr, parse_rw, parse_wrm, parse_subline_req, wdq_wr_vld, 
mout_scb0_jbus_wr_ack, mout_scb1_jbus_wr_ack, mout_scb2_jbus_wr_ack, 
mout_scb3_jbus_wr_ack
);

input clk;
input rst_l;

input cpu_clk;
input cpu_rst_l;

// Parse Block Interface
input [127:64] io_jbi_j_ad_ff;
input 	       parse_wdq_push;
input 	       parse_hdr;
input 	       parse_rw;
input 	       parse_wrm;
input 	       parse_subline_req;

// Write Decomposition Interface
input 	       wdq_wr_vld;  // pushed write txn to a rhq

// Memory Outbound Interface - cpu clock domain
input 	       mout_scb0_jbus_wr_ack;
input 	       mout_scb1_jbus_wr_ack;
input 	       mout_scb2_jbus_wr_ack;
input 	       mout_scb3_jbus_wr_ack;


// To Non-Cache IO
output [`JBI_WRI_TAG_WIDTH-1:0] min_oldest_wri_tag;  // same as wrtrk_oldest_wri_tag
output [`JBI_WRI_TAG_WIDTH-1:0] min_pre_wri_tag;

// Request Queue Interface
output [`JBI_WRI_TAG_WIDTH-1:0] wrtrk_new_wri_tag;
output [`JBI_WRI_TAG_WIDTH-1:0] wrtrk_rq0_oldest_wri_tag;
output [`JBI_WRI_TAG_WIDTH-1:0] wrtrk_rq1_oldest_wri_tag;
output [`JBI_WRI_TAG_WIDTH-1:0] wrtrk_rq2_oldest_wri_tag;
output [`JBI_WRI_TAG_WIDTH-1:0] wrtrk_rq3_oldest_wri_tag;


////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire [`JBI_WRI_TAG_WIDTH-1:0] 	min_oldest_wri_tag;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	min_pre_wri_tag;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	wrtrk_new_wri_tag;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	wrtrk_rq0_oldest_wri_tag;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	wrtrk_rq1_oldest_wri_tag;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	wrtrk_rq2_oldest_wri_tag;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	wrtrk_rq3_oldest_wri_tag;


////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

//
// Code start here 
//

wire [`JBI_WRI_TAG_WIDTH-1:0] 	wrtrk_oldest_wri_tag;
reg [`JBI_WRI_TAG_WIDTH-1:0] 	next_wrtrk_new_wri_tag;
reg [`JBI_WRI_TAG_WIDTH-1:0] 	next_wrtrk_oldest_wri_tag;
reg [`JBI_WRI_TAG_WIDTH-1:0] 	next_min_pre_wri_tag;

wire 				incr_wrtrk_new_wri_tag;
wire 				incr_wrtrk_oldest_wri_tag;

wire [5:0] 			pre_tag_incr;

reg [63:0] 			be;

//*******************************************************************************
// New WRI Tag (JBUS CLK)
// - assigned to a txn as it exits WDQ
//*******************************************************************************
assign incr_wrtrk_new_wri_tag = wdq_wr_vld;

always @ ( /*AUTOSENSE*/incr_wrtrk_new_wri_tag or wrtrk_new_wri_tag) begin
   if (incr_wrtrk_new_wri_tag)
      next_wrtrk_new_wri_tag = wrtrk_new_wri_tag + 1'b1;
   else
      next_wrtrk_new_wri_tag = wrtrk_new_wri_tag;
end

//*******************************************************************************
// Predicted WRI Tag (JBUS CLK)
// - computed as a txn enters WDQ
// - predicts what new_wri_tag would be by calculating the number of WR8 txns
//   a WRM will expand to (from right to left, look for 0<-1 transitions in groups
//   of 8-bit BE)
// - used for PIO read returns and Mondos
//*******************************************************************************

always @ ( /*AUTOSENSE*/io_jbi_j_ad_ff or parse_wrm) begin
   if (parse_wrm)
      be = io_jbi_j_ad_ff[127:64];
   else
      be = { io_jbi_j_ad_ff[127:112], {48{1'b0}} };
end

jbi_min_wrtrk_ptag_sum u_wrtrk_ptag_sum
   (.io_jbi_j_ad_ff(be[63:0]),
    .pre_tag_incr(pre_tag_incr[5:0])
    );

always @ ( /*AUTOSENSE*/min_pre_wri_tag or parse_hdr or parse_rw
	  or parse_subline_req or parse_wdq_push or parse_wrm
	  or pre_tag_incr) begin
   if (parse_wdq_push & parse_hdr & ~parse_rw) begin
      if (parse_wrm | parse_subline_req)
	 next_min_pre_wri_tag = min_pre_wri_tag
                               + {{`JBI_WRI_TAG_WIDTH-6{1'b0}}, pre_tag_incr[5:0]};
      else
	 next_min_pre_wri_tag = min_pre_wri_tag + 1'b1;
   end
   else
      next_min_pre_wri_tag = min_pre_wri_tag;
end

//*******************************************************************************
// Oldest WRI Tag (CPU CLK)
//*******************************************************************************
assign incr_wrtrk_oldest_wri_tag = mout_scb0_jbus_wr_ack
			      | mout_scb1_jbus_wr_ack
			      | mout_scb2_jbus_wr_ack
			      | mout_scb3_jbus_wr_ack;

always @ ( /*AUTOSENSE*/incr_wrtrk_oldest_wri_tag
	  or wrtrk_oldest_wri_tag) begin
   if (incr_wrtrk_oldest_wri_tag)
      next_wrtrk_oldest_wri_tag = wrtrk_oldest_wri_tag + 1'b1;
   else
      next_wrtrk_oldest_wri_tag = wrtrk_oldest_wri_tag;
end

assign min_oldest_wri_tag       = wrtrk_oldest_wri_tag;
assign wrtrk_rq0_oldest_wri_tag = wrtrk_oldest_wri_tag;
assign wrtrk_rq1_oldest_wri_tag = wrtrk_oldest_wri_tag;
assign wrtrk_rq2_oldest_wri_tag = wrtrk_oldest_wri_tag;
assign wrtrk_rq3_oldest_wri_tag = wrtrk_oldest_wri_tag;

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************
//----------------------
// JBUS CLK
//----------------------
dffrl_ns #(`JBI_WRI_TAG_WIDTH) u_dffrl_wrtrk_new_wri_tag
   (.din(next_wrtrk_new_wri_tag),
    .clk(clk),
    .rst_l(rst_l),
    .q(wrtrk_new_wri_tag)
    );

dffrl_ns #(`JBI_WRI_TAG_WIDTH) u_dffrl_min_pre_wri_tag
   (.din(next_min_pre_wri_tag),
    .clk(clk),
    .rst_l(rst_l),
    .q(min_pre_wri_tag)
    );

//----------------------
// CPU CLK
//----------------------

dffrl_ns #(`JBI_WRI_TAG_WIDTH) u_dffrl_wrtrk_oldest_wri_tag
   (.din(next_wrtrk_oldest_wri_tag),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(wrtrk_oldest_wri_tag)
    );

//*******************************************************************************
// Rule Checks
//*******************************************************************************

//synopsys translate_off

//synopsys translate_on

endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
