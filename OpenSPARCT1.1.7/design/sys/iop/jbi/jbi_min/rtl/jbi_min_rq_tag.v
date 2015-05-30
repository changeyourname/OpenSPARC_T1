// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_rq_tag.v
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
//  Description:        Tag Queue	
//  Top level Module:	jbi_min_rq_rhq_tag
//  Where Instantiated:	jbi_min_rq
//
//  Description: This block tracks 16 entries of tag and wait info bits for a 
//               corresponding queue entry.  If a tag is the oldest tag in jbi, 
//               the wait bit is cleared.
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "jbi.h"

module jbi_min_rq_tag(/*AUTOARG*/
// Outputs
c_tag_byps_out, 
// Inputs
clk, rst_l, cpu_clk, cpu_rst_l, cpu_rx_en, wrtrk_oldest_wri_tag, 
raddr, tag_byps_in, tag_in, csn_wr, waddr
);

input clk;
input rst_l;

input cpu_clk;
input cpu_rst_l;
input cpu_rx_en;

//cpu_clk
input [`JBI_WRI_TAG_WIDTH-1:0] wrtrk_oldest_wri_tag;
input [3:0] 		       raddr;

//jbus clk
input 			       tag_byps_in;
input [`JBI_WRI_TAG_WIDTH-1:0] tag_in;
input 			       csn_wr;
input [3:0] 		       waddr;

output 			       c_tag_byps_out;


////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
reg 			       c_tag_byps_out;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

wire 			       tag0_byps_ff;
wire 			       tag1_byps_ff;
wire 			       tag2_byps_ff;
wire 			       tag3_byps_ff;
wire 			       tag4_byps_ff;
wire 			       tag5_byps_ff;
wire 			       tag6_byps_ff;
wire 			       tag7_byps_ff;
wire 			       tag8_byps_ff;
wire 			       tag9_byps_ff;
wire 			       tag10_byps_ff;
wire 			       tag11_byps_ff;
wire 			       tag12_byps_ff;
wire 			       tag13_byps_ff;
wire 			       tag14_byps_ff;
wire 			       tag15_byps_ff;

wire 			       tag0_cs_wr;
wire 			       tag1_cs_wr;
wire 			       tag2_cs_wr;
wire 			       tag3_cs_wr;
wire 			       tag4_cs_wr;
wire 			       tag5_cs_wr;
wire 			       tag6_cs_wr;
wire 			       tag7_cs_wr;
wire 			       tag8_cs_wr;
wire 			       tag9_cs_wr;
wire 			       tag10_cs_wr;
wire 			       tag11_cs_wr;
wire 			       tag12_cs_wr;
wire 			       tag13_cs_wr;
wire 			       tag14_cs_wr;
wire 			       tag15_cs_wr;

wire 			       tag_byps_in_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0]  tag_in_ff;
wire 			       csn_wr_ff;
wire [3:0] 		       waddr_ff;
wire 			       c_tag_byps_in;
wire [`JBI_WRI_TAG_WIDTH-1:0]  c_tag_in;
wire 			       c_csn_wr;
wire [3:0] 		      c_waddr;

//
// Code start here 
//

//*******************************************************************************
// Write - CPU Clk
//*******************************************************************************

assign tag0_cs_wr = ~c_csn_wr & c_waddr == 4'd0;
assign tag1_cs_wr = ~c_csn_wr & c_waddr == 4'd1;
assign tag2_cs_wr = ~c_csn_wr & c_waddr == 4'd2;
assign tag3_cs_wr = ~c_csn_wr & c_waddr == 4'd3;
assign tag4_cs_wr = ~c_csn_wr & c_waddr == 4'd4;
assign tag5_cs_wr = ~c_csn_wr & c_waddr == 4'd5;
assign tag6_cs_wr = ~c_csn_wr & c_waddr == 4'd6;
assign tag7_cs_wr = ~c_csn_wr & c_waddr == 4'd7;
assign tag8_cs_wr = ~c_csn_wr & c_waddr == 4'd8;
assign tag9_cs_wr = ~c_csn_wr & c_waddr == 4'd9;
assign tag10_cs_wr = ~c_csn_wr & c_waddr == 4'd10;
assign tag11_cs_wr = ~c_csn_wr & c_waddr == 4'd11;
assign tag12_cs_wr = ~c_csn_wr & c_waddr == 4'd12;
assign tag13_cs_wr = ~c_csn_wr & c_waddr == 4'd13;
assign tag14_cs_wr = ~c_csn_wr & c_waddr == 4'd14;
assign tag15_cs_wr = ~c_csn_wr & c_waddr == 4'd15;

//*******************************************************************************
// Read - CPU clk
//*******************************************************************************

always @ ( /*AUTOSENSE*/raddr or tag0_byps_ff or tag10_byps_ff
	  or tag11_byps_ff or tag12_byps_ff or tag13_byps_ff
	  or tag14_byps_ff or tag15_byps_ff or tag1_byps_ff
	  or tag2_byps_ff or tag3_byps_ff or tag4_byps_ff
	  or tag5_byps_ff or tag6_byps_ff or tag7_byps_ff
	  or tag8_byps_ff or tag9_byps_ff) begin
   case(raddr)
      4'd0: c_tag_byps_out = tag0_byps_ff;
      4'd1: c_tag_byps_out = tag1_byps_ff;
      4'd2: c_tag_byps_out = tag2_byps_ff;
      4'd3: c_tag_byps_out = tag3_byps_ff;
      4'd4: c_tag_byps_out = tag4_byps_ff;
      4'd5: c_tag_byps_out = tag5_byps_ff;
      4'd6: c_tag_byps_out = tag6_byps_ff;
      4'd7: c_tag_byps_out = tag7_byps_ff;
      4'd8: c_tag_byps_out = tag8_byps_ff;
      4'd9: c_tag_byps_out = tag9_byps_ff;
      4'd10: c_tag_byps_out = tag10_byps_ff;
      4'd11: c_tag_byps_out = tag11_byps_ff;
      4'd12: c_tag_byps_out = tag12_byps_ff;
      4'd13: c_tag_byps_out = tag13_byps_ff;
      4'd14: c_tag_byps_out = tag14_byps_ff;
      4'd15: c_tag_byps_out = tag15_byps_ff;
// CoverMeter line_off
      default: c_tag_byps_out = 1'bx;
// CoverMeter line_on
   endcase
end


//*******************************************************************************
// Tag Slice Instantiation
//*******************************************************************************

/* jbi_min_rq_tag_slice AUTO_TEMPLATE (
 .tag_cs_wr (tag@_cs_wr),
 .tag_byps_ff (tag@_byps_ff),
 ); */

jbi_min_rq_tag_slice u_rq_tag0 (/*AUTOINST*/
				// Outputs
				.tag_byps_ff(tag0_byps_ff),	 // Templated
				// Inputs
				.cpu_clk(cpu_clk),
				.cpu_rst_l(cpu_rst_l),
				.wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				.c_tag_byps_in(c_tag_byps_in),
				.c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				.tag_cs_wr(tag0_cs_wr));		 // Templated
jbi_min_rq_tag_slice u_rq_tag1 (/*AUTOINST*/
				// Outputs
				.tag_byps_ff(tag1_byps_ff),	 // Templated
				// Inputs
				.cpu_clk(cpu_clk),
				.cpu_rst_l(cpu_rst_l),
				.wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				.c_tag_byps_in(c_tag_byps_in),
				.c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				.tag_cs_wr(tag1_cs_wr));		 // Templated
jbi_min_rq_tag_slice u_rq_tag2 (/*AUTOINST*/
				// Outputs
				.tag_byps_ff(tag2_byps_ff),	 // Templated
				// Inputs
				.cpu_clk(cpu_clk),
				.cpu_rst_l(cpu_rst_l),
				.wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				.c_tag_byps_in(c_tag_byps_in),
				.c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				.tag_cs_wr(tag2_cs_wr));		 // Templated
jbi_min_rq_tag_slice u_rq_tag3 (/*AUTOINST*/
				// Outputs
				.tag_byps_ff(tag3_byps_ff),	 // Templated
				// Inputs
				.cpu_clk(cpu_clk),
				.cpu_rst_l(cpu_rst_l),
				.wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				.c_tag_byps_in(c_tag_byps_in),
				.c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				.tag_cs_wr(tag3_cs_wr));		 // Templated
jbi_min_rq_tag_slice u_rq_tag4 (/*AUTOINST*/
				// Outputs
				.tag_byps_ff(tag4_byps_ff),	 // Templated
				// Inputs
				.cpu_clk(cpu_clk),
				.cpu_rst_l(cpu_rst_l),
				.wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				.c_tag_byps_in(c_tag_byps_in),
				.c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				.tag_cs_wr(tag4_cs_wr));		 // Templated
jbi_min_rq_tag_slice u_rq_tag5 (/*AUTOINST*/
				// Outputs
				.tag_byps_ff(tag5_byps_ff),	 // Templated
				// Inputs
				.cpu_clk(cpu_clk),
				.cpu_rst_l(cpu_rst_l),
				.wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				.c_tag_byps_in(c_tag_byps_in),
				.c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				.tag_cs_wr(tag5_cs_wr));		 // Templated
jbi_min_rq_tag_slice u_rq_tag6 (/*AUTOINST*/
				// Outputs
				.tag_byps_ff(tag6_byps_ff),	 // Templated
				// Inputs
				.cpu_clk(cpu_clk),
				.cpu_rst_l(cpu_rst_l),
				.wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				.c_tag_byps_in(c_tag_byps_in),
				.c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				.tag_cs_wr(tag6_cs_wr));		 // Templated
jbi_min_rq_tag_slice u_rq_tag7 (/*AUTOINST*/
				// Outputs
				.tag_byps_ff(tag7_byps_ff),	 // Templated
				// Inputs
				.cpu_clk(cpu_clk),
				.cpu_rst_l(cpu_rst_l),
				.wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				.c_tag_byps_in(c_tag_byps_in),
				.c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				.tag_cs_wr(tag7_cs_wr));		 // Templated
jbi_min_rq_tag_slice u_rq_tag8 (/*AUTOINST*/
				// Outputs
				.tag_byps_ff(tag8_byps_ff),	 // Templated
				// Inputs
				.cpu_clk(cpu_clk),
				.cpu_rst_l(cpu_rst_l),
				.wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				.c_tag_byps_in(c_tag_byps_in),
				.c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				.tag_cs_wr(tag8_cs_wr));		 // Templated
jbi_min_rq_tag_slice u_rq_tag9 (/*AUTOINST*/
				// Outputs
				.tag_byps_ff(tag9_byps_ff),	 // Templated
				// Inputs
				.cpu_clk(cpu_clk),
				.cpu_rst_l(cpu_rst_l),
				.wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				.c_tag_byps_in(c_tag_byps_in),
				.c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				.tag_cs_wr(tag9_cs_wr));		 // Templated
jbi_min_rq_tag_slice u_rq_tag10 (/*AUTOINST*/
				 // Outputs
				 .tag_byps_ff(tag10_byps_ff),	 // Templated
				 // Inputs
				 .cpu_clk(cpu_clk),
				 .cpu_rst_l(cpu_rst_l),
				 .wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				 .c_tag_byps_in(c_tag_byps_in),
				 .c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				 .tag_cs_wr(tag10_cs_wr));	 // Templated
jbi_min_rq_tag_slice u_rq_tag11 (/*AUTOINST*/
				 // Outputs
				 .tag_byps_ff(tag11_byps_ff),	 // Templated
				 // Inputs
				 .cpu_clk(cpu_clk),
				 .cpu_rst_l(cpu_rst_l),
				 .wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				 .c_tag_byps_in(c_tag_byps_in),
				 .c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				 .tag_cs_wr(tag11_cs_wr));	 // Templated
jbi_min_rq_tag_slice u_rq_tag12 (/*AUTOINST*/
				 // Outputs
				 .tag_byps_ff(tag12_byps_ff),	 // Templated
				 // Inputs
				 .cpu_clk(cpu_clk),
				 .cpu_rst_l(cpu_rst_l),
				 .wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				 .c_tag_byps_in(c_tag_byps_in),
				 .c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				 .tag_cs_wr(tag12_cs_wr));	 // Templated
jbi_min_rq_tag_slice u_rq_tag13 (/*AUTOINST*/
				 // Outputs
				 .tag_byps_ff(tag13_byps_ff),	 // Templated
				 // Inputs
				 .cpu_clk(cpu_clk),
				 .cpu_rst_l(cpu_rst_l),
				 .wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				 .c_tag_byps_in(c_tag_byps_in),
				 .c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				 .tag_cs_wr(tag13_cs_wr));	 // Templated
jbi_min_rq_tag_slice u_rq_tag14 (/*AUTOINST*/
				 // Outputs
				 .tag_byps_ff(tag14_byps_ff),	 // Templated
				 // Inputs
				 .cpu_clk(cpu_clk),
				 .cpu_rst_l(cpu_rst_l),
				 .wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				 .c_tag_byps_in(c_tag_byps_in),
				 .c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				 .tag_cs_wr(tag14_cs_wr));	 // Templated
jbi_min_rq_tag_slice u_rq_tag15 (/*AUTOINST*/
				 // Outputs
				 .tag_byps_ff(tag15_byps_ff),	 // Templated
				 // Inputs
				 .cpu_clk(cpu_clk),
				 .cpu_rst_l(cpu_rst_l),
				 .wrtrk_oldest_wri_tag(wrtrk_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
				 .c_tag_byps_in(c_tag_byps_in),
				 .c_tag_in(c_tag_in[`JBI_WRI_TAG_WIDTH-1:0]),
				 .tag_cs_wr(tag15_cs_wr));	 // Templated

//*******************************************************************************
// Synchronization DFFRLEs
//*******************************************************************************

//----------------------
// JBUS -> CPU
//----------------------

// waddr
dffrl_ns #(4) u_dffrl_waddr_ff
   (.din(waddr),
    .clk(clk),
    .rst_l(rst_l),
    .q(waddr_ff)
    );

dffrle_ns #(4) u_dffrle_c_waddr
   (.din(waddr_ff),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_waddr)
    );

// csn_wr
dffrl_ns #(1) u_dffrl_csn_wr_ff
   (.din(csn_wr),
    .clk(clk),
    .rst_l(rst_l),
    .q(csn_wr_ff)
    );

dffrle_ns #(1) u_dffrle_c_csn_wr
   (.din(csn_wr_ff),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_csn_wr)
    );

// tag_in
dffrl_ns #(`JBI_WRI_TAG_WIDTH) u_dffrl_tag_in_ff
   (.din(tag_in),
    .clk(clk),
    .rst_l(rst_l),
    .q(tag_in_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_c_tag_in
   (.din(tag_in_ff),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_tag_in)
    );

// tag_byps_in
dffrl_ns #(1) u_dffrl_tag_byps_in_ff
   (.din(tag_byps_in),
    .clk(clk),
    .rst_l(rst_l),
    .q(tag_byps_in_ff)
    );

dffrle_ns #(1) u_dffrle_c_tag_byps_in
   (.din(tag_byps_in_ff),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_tag_byps_in)
    );

endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
