// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_1r1w_16x160.v
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
// rf_16x156_scan - DFT scan wrapper around 'rf_16x156' part.
// _____________________________________________________________________________
//
// Description:
//   The data out of the 'rf_16x156' part is not scannable.  This wrapper adds
//   a register to monitor the output of the memory array and a mux, enabled
//   by 'testmux_sel' to enable this register to control the cone of logic down
//   stream of the memories data out port.
// _____________________________________________________________________________

`include "sys.h"


module jbi_1r1w_16x160 (/*AUTOARG*/
// Outputs
dout, 
// Inputs
wrclk, wr_en, wr_adr, din, rdclk, read_en, rd_adr, rst_l, hold, 
testmux_sel, rst_tri_en
);


// Write port.
input		 wrclk;
input 		 wr_en;
input [3:0] 	 wr_adr;
input [159:0] 	 din;

// Read port.
input		 rdclk;
input		 read_en;
input [3:0] 	 rd_adr;
output [159:0] 	 dout;

// Other.
input	  	 rst_l;
input 		 hold;
input 		 testmux_sel;
input 		 rst_tri_en;

// Wires and Regs.
wire [159:0] 	 dout_array;
wire [159:0] 	 dout_scan;

wire si_r, si_w;

  // Register Array.
/* bw_r_rf16x160 AUTO_TEMPLATE (
 .dout (dout_array),
 .so_w (),
 .so_r (),
 .se (1'b0),
 .si (),
 .sehold (hold),
 .reset_l (rst_l),
 .word_wen ( {4{1'b1}} ),
 .byte_wen ( {20{1'b1}} ),
 .wr_clk (wrclk),
 .rd_clk (rdclk),
 ) */
 
bw_r_rf16x160 array (/*AUTOINST*/
		     // Outputs
		     .dout		(dout_array),		 // Templated
		     .so_w		(),			 // Templated
		     .so_r		(),			 // Templated
		     // Inputs
		     .din		(din[159:0]),
		     .rd_adr		(rd_adr[3:0]),
		     .wr_adr		(wr_adr[3:0]),
		     .read_en		(read_en),
		     .wr_en		(wr_en),
		     .rst_tri_en	(rst_tri_en),
		     .word_wen		( {4{1'b1}} ),		 // Templated
		     .byte_wen		( {20{1'b1}} ),		 // Templated
		     .rd_clk		(rdclk),		 // Templated
		     .wr_clk		(wrclk),		 // Templated
		     .se		(1'b0),			 // Templated
		     .si_r		(si_r),
		     .si_w		(si_w),
		     .reset_l		(rst_l),		 // Templated
		     .sehold		(hold));			 // Templated



// DFT Scan port.
assign 		 dout = (testmux_sel)? dout_scan: dout_array;

wire [159:0] 	 next_dout_scan = dout_array;
dff_ns #(160) dout_scan_reg (.din(next_dout_scan), .q(dout_scan), .clk(rdclk));


endmodule


// Local Variables:
// verilog-library-directories:("../../../srams/rtl")
// verilog-auto-sense-defines-constant:t
// verilog-auto-inst-ordered:t
// End:
