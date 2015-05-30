// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncio_tag.v
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
//  Top level Module:	jbi_ncio_tag
//  Where Instantiated:	jbi_ncio
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

module jbi_ncio_tag(/*AUTOARG*/
// Outputs
j_tag_byps_out, 
// Inputs
clk, rst_l, cpu_clk, cpu_rst_l, cpu_rx_en, cpu_tx_en, 
min_oldest_wri_tag, tag_byps_in, tag_in, csn_wr, waddr, raddr
);

input clk;
input rst_l;

input cpu_clk;
input cpu_rst_l;
input cpu_rx_en;
input cpu_tx_en;

//cpu_clk
input [`JBI_WRI_TAG_WIDTH-1:0] min_oldest_wri_tag;

//jbus clk
input 			       tag_byps_in;
input [`JBI_WRI_TAG_WIDTH-1:0] tag_in;
input 			       csn_wr;
input [3:0] 		       waddr;
input [3:0] 		       raddr;
output 				j_tag_byps_out;


////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 				j_tag_byps_out;


////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

wire [15:0] 			tag_byps_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag0_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag1_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag2_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag3_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag4_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag5_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag6_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag7_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag8_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag9_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag10_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag11_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag12_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag13_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag14_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag15_ff;
reg  [15:0] 			next_tag_byps_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag0_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag1_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag2_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag3_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag4_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag5_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag6_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag7_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag8_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag9_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag10_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag11_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag12_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag13_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag14_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag15_ff;

reg [15:0] 			comp_tag_byps_ff;

wire 				tag0_ff_en;
wire 				tag1_ff_en;
wire 				tag2_ff_en;
wire 				tag3_ff_en;
wire 				tag4_ff_en;
wire 				tag5_ff_en;
wire 				tag6_ff_en;
wire 				tag7_ff_en;
wire 				tag8_ff_en;
wire 				tag9_ff_en;
wire 				tag10_ff_en;
wire 				tag11_ff_en;
wire 				tag12_ff_en;
wire 				tag13_ff_en;
wire 				tag14_ff_en;
wire 				tag15_ff_en;

wire 				tag_byps_in_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag_in_ff;
wire 				csn_wr_ff;
wire [3:0] 			raddr_ff;
wire [3:0] 			waddr_ff;
wire 				c_tag_byps_in;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	c_tag_in;
wire 				c_csn_wr;
wire [3:0] 			c_waddr;
wire [3:0] 			c_raddr;

wire 				c_tag_byps_out;
wire 				next_c_tag_byps_out;
wire 				tx_tag_byps_out;


//
// Code start here 
//

//*******************************************************************************
// Compare and Write - CPU Clk
//*******************************************************************************


//----------------------
// Tag_byps Bit
// - if tag is oldest tag, clear tag_byps bit
//----------------------

always @ ( /*AUTOSENSE*/min_oldest_wri_tag or tag0_ff or tag10_ff
	  or tag11_ff or tag12_ff or tag13_ff or tag14_ff or tag15_ff
	  or tag1_ff or tag2_ff or tag3_ff or tag4_ff or tag5_ff
	  or tag6_ff or tag7_ff or tag8_ff or tag9_ff or tag_byps_ff) begin
   if(tag0_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[0] = 1'b1;
   else
      comp_tag_byps_ff[0] = tag_byps_ff[0];

   if(tag1_ff== min_oldest_wri_tag)
      comp_tag_byps_ff[1] = 1'b1;
   else
      comp_tag_byps_ff[1] = tag_byps_ff[1];

   if(tag2_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[2] = 1'b1;
   else
      comp_tag_byps_ff[2] = tag_byps_ff[2];

   if(tag3_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[3] = 1'b1;
   else
      comp_tag_byps_ff[3] = tag_byps_ff[3];

   if(tag4_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[4] = 1'b1;
   else
      comp_tag_byps_ff[4] = tag_byps_ff[4];

   if(tag5_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[5] = 1'b1;
   else
      comp_tag_byps_ff[5] = tag_byps_ff[5];

   if(tag6_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[6] = 1'b1;
   else
      comp_tag_byps_ff[6] = tag_byps_ff[6];

   if(tag7_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[7] = 1'b1;
   else
      comp_tag_byps_ff[7] = tag_byps_ff[7];

   if(tag8_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[8] = 1'b1;
   else
      comp_tag_byps_ff[8] = tag_byps_ff[8];

   if(tag9_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[9] = 1'b1;
   else
      comp_tag_byps_ff[9] = tag_byps_ff[9];

   if(tag10_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[10] = 1'b1;
   else
      comp_tag_byps_ff[10] = tag_byps_ff[10];

   if(tag11_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[11] = 1'b1;
   else
      comp_tag_byps_ff[11] = tag_byps_ff[11];

   if(tag12_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[12] = 1'b1;
   else
      comp_tag_byps_ff[12] = tag_byps_ff[12];

   if(tag13_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[13] = 1'b1;
   else
      comp_tag_byps_ff[13] = tag_byps_ff[13];

   if(tag14_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[14] = 1'b1;
   else
      comp_tag_byps_ff[14] = tag_byps_ff[14];

   if(tag15_ff == min_oldest_wri_tag)
      comp_tag_byps_ff[15] = 1'b1;
   else
      comp_tag_byps_ff[15] = tag_byps_ff[15];
end


always @ ( /*AUTOSENSE*/c_csn_wr or c_tag_byps_in or c_waddr
	  or comp_tag_byps_ff) begin
   next_tag_byps_ff = comp_tag_byps_ff;
   if (~c_csn_wr)
      next_tag_byps_ff[c_waddr] = c_tag_byps_in;
end

//----------------------
// Tag
//----------------------
assign tag0_ff_en = ~c_csn_wr & c_waddr == 4'd0;
assign tag1_ff_en = ~c_csn_wr & c_waddr == 4'd1;
assign tag2_ff_en = ~c_csn_wr & c_waddr == 4'd2;
assign tag3_ff_en = ~c_csn_wr & c_waddr == 4'd3;
assign tag4_ff_en = ~c_csn_wr & c_waddr == 4'd4;
assign tag5_ff_en = ~c_csn_wr & c_waddr == 4'd5;
assign tag6_ff_en = ~c_csn_wr & c_waddr == 4'd6;
assign tag7_ff_en = ~c_csn_wr & c_waddr == 4'd7;
assign tag8_ff_en = ~c_csn_wr & c_waddr == 4'd8;
assign tag9_ff_en = ~c_csn_wr & c_waddr == 4'd9;
assign tag10_ff_en = ~c_csn_wr & c_waddr == 4'd10;
assign tag11_ff_en = ~c_csn_wr & c_waddr == 4'd11;
assign tag12_ff_en = ~c_csn_wr & c_waddr == 4'd12;
assign tag13_ff_en = ~c_csn_wr & c_waddr == 4'd13;
assign tag14_ff_en = ~c_csn_wr & c_waddr == 4'd14;
assign tag15_ff_en = ~c_csn_wr & c_waddr == 4'd15;

assign next_tag0_ff = c_tag_in;
assign next_tag1_ff = c_tag_in;
assign next_tag2_ff = c_tag_in;
assign next_tag3_ff = c_tag_in;
assign next_tag4_ff = c_tag_in;
assign next_tag5_ff = c_tag_in;
assign next_tag6_ff = c_tag_in;
assign next_tag7_ff = c_tag_in;
assign next_tag8_ff = c_tag_in;
assign next_tag9_ff = c_tag_in;
assign next_tag10_ff = c_tag_in;
assign next_tag11_ff = c_tag_in;
assign next_tag12_ff = c_tag_in;
assign next_tag13_ff = c_tag_in;
assign next_tag14_ff = c_tag_in;
assign next_tag15_ff = c_tag_in;

//*******************************************************************************
// Read - CPU clk
//*******************************************************************************

assign next_c_tag_byps_out = tag_byps_ff[c_raddr];

//*******************************************************************************
// Synchronization DFFRLEs
//*******************************************************************************

//----------------------
// JBUS -> CPU
//----------------------

// raddr
dffrl_ns #(4) u_dffrl_raddr_ff
   (.din(raddr),
    .clk(clk),
    .rst_l(rst_l),
    .q(raddr_ff)
    );

dffrle_ns #(4) u_dffrle_c_raddr
   (.din(raddr_ff),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_raddr)
    );

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

//----------------------
// CPU -> JBUS
//----------------------

// j_tag_byps_out
dffrle_ns #(1) u_dffrle_tx_tag_byps_out
   (.din(c_tag_byps_out),
    .clk(cpu_clk),
    .en(cpu_tx_en),
    .rst_l(cpu_rst_l),
    .q(tx_tag_byps_out)
    );

dffrl_ns #(1) u_dffrl_j_tag_byps_out
   (.din(tx_tag_byps_out),
    .clk(clk),
    .rst_l(rst_l),
    .q(j_tag_byps_out)
    );


//*******************************************************************************
// DFF Instantiations
//*******************************************************************************

dff_ns #(1) u_dffrl_c_tag_byps_out
   (.din(next_c_tag_byps_out),
    .clk(cpu_clk),
    .q(c_tag_byps_out)
    );

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************

dffrl_ns #(16) u_dffrl_tag_byps_ff
   (.din(next_tag_byps_ff),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(tag_byps_ff)
    );

//*******************************************************************************
// DFFRLE Instantiations
//*******************************************************************************

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag0_ff
   (.din(next_tag0_ff),
    .clk(cpu_clk),
    .en(tag0_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag0_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag1_ff
   (.din(next_tag1_ff),
    .clk(cpu_clk),
    .en(tag1_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag1_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag2_ff
   (.din(next_tag2_ff),
    .clk(cpu_clk),
    .en(tag2_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag2_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag3_ff
   (.din(next_tag3_ff),
    .clk(cpu_clk),
    .en(tag3_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag3_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag4_ff
   (.din(next_tag4_ff),
    .clk(cpu_clk),
    .en(tag4_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag4_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag5_ff
   (.din(next_tag5_ff),
    .clk(cpu_clk),
    .en(tag5_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag5_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag6_ff
   (.din(next_tag6_ff),
    .clk(cpu_clk),
    .en(tag6_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag6_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag7_ff
   (.din(next_tag7_ff),
    .clk(cpu_clk),
    .en(tag7_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag7_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag8_ff
   (.din(next_tag8_ff),
    .clk(cpu_clk),
    .en(tag8_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag8_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag9_ff
   (.din(next_tag9_ff),
    .clk(cpu_clk),
    .en(tag9_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag9_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag10_ff
   (.din(next_tag10_ff),
    .clk(cpu_clk),
    .en(tag10_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag10_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag11_ff
   (.din(next_tag11_ff),
    .clk(cpu_clk),
    .en(tag11_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag11_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag12_ff
   (.din(next_tag12_ff),
    .clk(cpu_clk),
    .en(tag12_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag12_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag13_ff
   (.din(next_tag13_ff),
    .clk(cpu_clk),
    .en(tag13_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag13_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag14_ff
   (.din(next_tag14_ff),
    .clk(cpu_clk),
    .en(tag14_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag14_ff)
    );

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag15_ff
   (.din(next_tag15_ff),
    .clk(cpu_clk),
    .en(tag15_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag15_ff)
    );

endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
