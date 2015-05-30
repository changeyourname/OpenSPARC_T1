// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_rq_tag_slice.v
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

module jbi_min_rq_tag_slice(/*AUTOARG*/
// Outputs
tag_byps_ff, 
// Inputs
cpu_clk, cpu_rst_l, wrtrk_oldest_wri_tag, c_tag_byps_in, c_tag_in, 
tag_cs_wr
);

input cpu_clk;
input cpu_rst_l;

input [`JBI_WRI_TAG_WIDTH-1:0] wrtrk_oldest_wri_tag;
input 			       c_tag_byps_in;
input [`JBI_WRI_TAG_WIDTH-1:0] c_tag_in;
input 			       tag_cs_wr;

output 			       tag_byps_ff;

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 				tag_byps_ff;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
wire [`JBI_WRI_TAG_WIDTH-1:0] 	tag_ff;
wire [`JBI_WRI_TAG_WIDTH-1:0] 	next_tag_ff;
reg 				next_tag_byps_ff;

reg 				comp_tag_byps;
wire 				tag_ff_en;

//
// Code start here 
//

//*******************************************************************************
// Bypass
// - if tag is oldest tag, clear tag_byps bit
//*******************************************************************************

always @ ( /*AUTOSENSE*/tag_byps_ff or tag_ff or wrtrk_oldest_wri_tag) begin
   if(tag_ff == wrtrk_oldest_wri_tag)
      comp_tag_byps = 1'b1;
   else
      comp_tag_byps = tag_byps_ff;
end

always @ ( /*AUTOSENSE*/c_tag_byps_in or comp_tag_byps or tag_cs_wr) begin
   if (tag_cs_wr)
      next_tag_byps_ff = c_tag_byps_in;
   else
      next_tag_byps_ff = comp_tag_byps;
end

//*******************************************************************************
// Tag
//*******************************************************************************
assign tag_ff_en = tag_cs_wr;
assign next_tag_ff = c_tag_in;

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************

dffrl_ns #(1) u_dffrl_tag_byps_ff
   (.din(next_tag_byps_ff),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(tag_byps_ff)
    );

//*******************************************************************************
// DFFRLE Instantiations
//*******************************************************************************

dffrle_ns #(`JBI_WRI_TAG_WIDTH) u_dffrle_tag_ff
   (.din(next_tag_ff),
    .clk(cpu_clk),
    .en(tag_ff_en),
    .rst_l(cpu_rst_l),
    .q(tag_ff)
    );


endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
