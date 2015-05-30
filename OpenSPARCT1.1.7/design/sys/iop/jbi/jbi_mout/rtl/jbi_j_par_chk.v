// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_j_par_chk.v
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
// jbi_j_par_chk -- Check the JBus J_PAR signal.
// _____________________________________________________________________________
//
// Description:
//   The 4 J_PACK busses (0,1,4,5) and the 3 J_REQs (0,4,5) are staged to the correct
//   alignment in time.  For the J_REQs, this is 2 cycles (relative to J_PAR).  For the
//   J_PACKs, this is 3 cycles (see figure in JBus Spec rev 3.3 pg 57.  Note that programmable
//   delays are to compensate for J_PACKs on local segments that do not go through a repeater.
//   Since all of out J_PACKs are on the (only) local segment, all need to be delayed.
//
//   Their odd parity is then calculated and compared against 'j_par'.  An error is reported
//   if they mismatched.
//
// Interface:
//   Note that the outputs 'jbi_io_j_req0_out_l', 'jbi_io_j_pack0', 'jbi_io_j_pack1' are
//   expected to be always enabled for output.  This negates the need for signal qualifiers.
//
// Design Notes:
//   o Note that we want the physical JBus values, not their logical values.
//   o Default values for unused J_REQ and J_PACK signals are included to maintain correct
//     parity.
//   o All ports are included in the parity tree, whether present or not.
// _____________________________________________________________________________

`include "sys.h"


module jbi_j_par_chk (/*AUTOARG*/
  // Outputs
  mout_csr_err_cpar, mout_csr_jbi_log_par_jpar, mout_csr_jbi_log_par_jpack0, 
  mout_csr_jbi_log_par_jpack1, mout_csr_jbi_log_par_jpack4, 
  mout_csr_jbi_log_par_jpack5, mout_csr_jbi_log_par_jreq, mout_port_4_present, 
  mout_port_5_present, 
  // Inputs
  j_par_p1, j_req4_in_l_p1, j_req5_in_l_p1, j_req0_out_l_m1, j_pack0_m1, 
  j_pack1_m1, j_pack4_p1, j_pack5_p1, clk, rst_l
  );

  // J_PAR signal.
  input         j_par_p1;

  // J_REQ_L signals.
  input 	j_req4_in_l_p1;
  input 	j_req5_in_l_p1;
  input 	j_req0_out_l_m1;		// (Note that this is an always enabled output so no qualifying is needed)

  // J_PACK signals.
  input   [2:0] j_pack0_m1;			// (Note that this is an always enabled output so no qualifying is needed)
  input   [2:0] j_pack1_m1;			// (Note that this is an always enabled output so no qualifying is needed)
  input   [2:0] j_pack4_p1;
  input   [2:0] j_pack5_p1;

  // Reporting a control parity error.
  output 	mout_csr_err_cpar;		// Control Parity Error:
  output 	mout_csr_jbi_log_par_jpar;	//    J_PAR
  output  [2:0] mout_csr_jbi_log_par_jpack0;	//    J_PACK0
  output  [2:0] mout_csr_jbi_log_par_jpack1;	//    J_PACK1
  output  [2:0] mout_csr_jbi_log_par_jpack4;	//    J_PACK4
  output  [2:0] mout_csr_jbi_log_par_jpack5;	//    J_PACK5
  output  [6:0] mout_csr_jbi_log_par_jreq;	//    J_REQ[6:0]

  // Port Present logic.
  output 	mout_port_4_present;
  output 	mout_port_5_present;

  // Clock and reset.
  input         clk;
  input         rst_l;



  // Wires and Regs.
  wire 	  [2:0] j_pack0, j_pack0_p1, j_pack0_p2, j_pack0_p3, j_pack0_p4, j_pack0_p5;
  wire 	  [2:0] j_pack1, j_pack1_p1, j_pack1_p2, j_pack1_p3, j_pack1_p4, j_pack1_p5;
  wire 	  [2:0] j_pack4_p2, j_pack4_p3, j_pack4_p4, j_pack4_p5;
  wire 	  [2:0] j_pack5_p2, j_pack5_p3, j_pack5_p4, j_pack5_p5;



  // Register the external J_PAR signal to avoid timing problems.
  wire next_j_par_p2 = j_par_p1;
  dff_ns j_par_p2_reg (.din(next_j_par_p2), .q(j_par_p2), .clk(clk));


  // Register the external J_REQ4/5_IN_L, and J_PACK4/5 signals to avoid timing problems.
  wire next_j_req4_in_l_p2 = j_req4_in_l_p1;
  dff_ns j_req4_in_l_p2_reg (.din(next_j_req4_in_l_p2), .q(j_req4_in_l_p2), .clk(clk));
  wire next_j_req4_in_l_p3 = j_req4_in_l_p2;
  dff_ns j_req4_in_l_p3_reg (.din(next_j_req4_in_l_p3), .q(j_req4_in_l_p3), .clk(clk));
  wire next_j_req4_in_l_p4 = j_req4_in_l_p3;
  dff_ns j_req4_in_l_p4_reg (.din(next_j_req4_in_l_p4), .q(j_req4_in_l_p4), .clk(clk));
  //
  wire next_j_req5_in_l_p2 = j_req5_in_l_p1;
  dff_ns j_req5_in_l_p2_reg (.din(next_j_req5_in_l_p2), .q(j_req5_in_l_p2), .clk(clk));
  wire next_j_req5_in_l_p3 = j_req5_in_l_p2;
  dff_ns j_req5_in_l_p3_reg (.din(next_j_req5_in_l_p3), .q(j_req5_in_l_p3), .clk(clk));
  wire next_j_req5_in_l_p4 = j_req5_in_l_p3;
  dff_ns j_req5_in_l_p4_reg (.din(next_j_req5_in_l_p4), .q(j_req5_in_l_p4), .clk(clk));
  //
  wire [2:0] next_j_pack4_p2 = j_pack4_p1;
  dff_ns #(3) j_pack4_p2_reg (.din(next_j_pack4_p2), .q(j_pack4_p2), .clk(clk));
  wire [2:0] next_j_pack4_p3 = j_pack4_p2;
  dff_ns #(3) j_pack4_p3_reg (.din(next_j_pack4_p3), .q(j_pack4_p3), .clk(clk));
  wire [2:0] next_j_pack4_p4 = j_pack4_p3;
  dff_ns #(3) j_pack4_p4_reg (.din(next_j_pack4_p4), .q(j_pack4_p4), .clk(clk));
  wire [2:0] next_j_pack4_p5 = j_pack4_p4;
  dff_ns #(3) j_pack4_p5_reg (.din(next_j_pack4_p5), .q(j_pack4_p5), .clk(clk));
  //
  wire [2:0] next_j_pack5_p2 = j_pack5_p1;
  dff_ns #(3) j_pack5_p2_reg (.din(next_j_pack5_p2), .q(j_pack5_p2), .clk(clk));
  wire [2:0] next_j_pack5_p3 = j_pack5_p2;
  dff_ns #(3) j_pack5_p3_reg (.din(next_j_pack5_p3), .q(j_pack5_p3), .clk(clk));
  wire [2:0] next_j_pack5_p4 = j_pack5_p3;
  dff_ns #(3) j_pack5_p4_reg (.din(next_j_pack5_p4), .q(j_pack5_p4), .clk(clk));
  wire [2:0] next_j_pack5_p5 = j_pack5_p4;
  dff_ns #(3) j_pack5_p5_reg (.din(next_j_pack5_p5), .q(j_pack5_p5), .clk(clk));


  // Stage our J_REQ0_OUT_L, and J_PACK0/1 signals 3 cycles to align them to those we got from the external devices.
  wire next_j_req0_out_l = j_req0_out_l_m1;
  dff_ns j_req0_out_l_reg (.din(next_j_req0_out_l), .q(j_req0_out_l), .clk(clk));
  wire next_j_req0_out_l_p1 = j_req0_out_l;
  dff_ns j_req0_out_l_p1_reg (.din(next_j_req0_out_l_p1), .q(j_req0_out_l_p1), .clk(clk));
  wire next_j_req0_out_l_p2 = j_req0_out_l_p1;
  dff_ns j_req0_out_l_p2_reg (.din(next_j_req0_out_l_p2), .q(j_req0_out_l_p2), .clk(clk));
  wire next_j_req0_out_l_p3 = j_req0_out_l_p2;
  dff_ns j_req0_out_l_p3_reg (.din(next_j_req0_out_l_p3), .q(j_req0_out_l_p3), .clk(clk));
  wire next_j_req0_out_l_p4 = j_req0_out_l_p3;
  dff_ns j_req0_out_l_p4_reg (.din(next_j_req0_out_l_p4), .q(j_req0_out_l_p4), .clk(clk));
  //
  wire [2:0] next_j_pack0 = j_pack0_m1;
  dff_ns #(3) j_pack0_reg (.din(next_j_pack0), .q(j_pack0), .clk(clk));
  wire [2:0] next_j_pack0_p1 = j_pack0;
  dff_ns #(3) j_pack0_p1_reg (.din(next_j_pack0_p1), .q(j_pack0_p1), .clk(clk));
  wire [2:0] next_j_pack0_p2 = j_pack0_p1;
  dff_ns #(3) j_pack0_p2_reg (.din(next_j_pack0_p2), .q(j_pack0_p2), .clk(clk));
  wire [2:0] next_j_pack0_p3 = j_pack0_p2;
  dff_ns #(3) j_pack0_p3_reg (.din(next_j_pack0_p3), .q(j_pack0_p3), .clk(clk));
  wire [2:0] next_j_pack0_p4 = j_pack0_p3;
  dff_ns #(3) j_pack0_p4_reg (.din(next_j_pack0_p4), .q(j_pack0_p4), .clk(clk));
  wire [2:0] next_j_pack0_p5 = j_pack0_p4;
  dff_ns #(3) j_pack0_p5_reg (.din(next_j_pack0_p5), .q(j_pack0_p5), .clk(clk));
  //
  wire [2:0] next_j_pack1 = j_pack1_m1;
  dff_ns #(3) j_pack1_reg (.din(next_j_pack1), .q(j_pack1), .clk(clk));
  wire [2:0] next_j_pack1_p1 = j_pack1;
  dff_ns #(3) j_pack1_p1_reg (.din(next_j_pack1_p1), .q(j_pack1_p1), .clk(clk));
  wire [2:0] next_j_pack1_p2 = j_pack1_p1;
  dff_ns #(3) j_pack1_p2_reg (.din(next_j_pack1_p2), .q(j_pack1_p2), .clk(clk));
  wire [2:0] next_j_pack1_p3 = j_pack1_p2;
  dff_ns #(3) j_pack1_p3_reg (.din(next_j_pack1_p3), .q(j_pack1_p3), .clk(clk));
  wire [2:0] next_j_pack1_p4 = j_pack1_p3;
  dff_ns #(3) j_pack1_p4_reg (.din(next_j_pack1_p4), .q(j_pack1_p4), .clk(clk));
  wire [2:0] next_j_pack1_p5 = j_pack1_p4;
  dff_ns #(3) j_pack1_p5_reg (.din(next_j_pack1_p5), .q(j_pack1_p5), .clk(clk));


  // Assign default values to missing signals.
  wire j_req1_in_l_p2 = 1'b1;  wire j_req1_in_l_p4 = 1'b1;
  wire j_req2_in_l_p2 = 1'b1;  wire j_req2_in_l_p4 = 1'b1;
  wire j_req3_in_l_p2 = 1'b1;  wire j_req3_in_l_p4 = 1'b1;
  wire j_req6_in_l_p2 = 1'b1;  wire j_req6_in_l_p4 = 1'b1;
  wire [2:0] j_pack2_p3 = 3'b111;
  wire [2:0] j_pack3_p3 = 3'b111;
  wire [2:0] j_pack6_p3 = 3'b111;


  // Compute parity on all of the J_PACK signals (Xnor as noted in the JBus Architecture Spec rel 3.3, sect 1.3).
  wire j_par_internal = ~^{ j_req0_out_l_p2, j_req1_in_l_p2,  j_req2_in_l_p2,  j_req3_in_l_p2,  j_req4_in_l_p2,  j_req5_in_l_p2,  j_req6_in_l_p2,
			    j_pack0_p3[2:0], j_pack1_p3[2:0], j_pack2_p3[2:0], j_pack3_p3[2:0], j_pack4_p3[2:0], j_pack5_p3[2:0], j_pack6_p3[2:0] };
  wire 	 next_j_par_internal_p1 = j_par_internal;
  dff_ns j_par_internal_p1_reg (.din(next_j_par_internal_p1), .q(j_par_internal_p1), .clk(clk));
  wire 	 next_j_par_internal_p2 = j_par_internal_p1;
  dff_ns j_par_internal_p2_reg (.din(next_j_par_internal_p2), .q(j_par_internal_p2), .clk(clk));


  // Compare J_PAR against calculated parity.
  assign mout_csr_err_cpar           = (j_par_p2 != j_par_internal_p2) && !(~rst_l);
  assign mout_csr_jbi_log_par_jpar   = j_par_p2;
  assign mout_csr_jbi_log_par_jpack0 = j_pack0_p5;
  assign mout_csr_jbi_log_par_jpack1 = j_pack1_p5;
  assign mout_csr_jbi_log_par_jpack4 = j_pack4_p5;
  assign mout_csr_jbi_log_par_jpack5 = j_pack5_p5;
  assign mout_csr_jbi_log_par_jreq   = { j_req6_in_l_p4, j_req5_in_l_p4, j_req4_in_l_p4, j_req3_in_l_p4, j_req2_in_l_p4, j_req1_in_l_p4, j_req0_out_l_p4 };


  // Let JBI_CONFIG2 register know if devices are present.
  // (This function is not related to this block, but this is a convenient location for it).
  assign mout_port_4_present = (j_pack4_p2 == 3'b000);
  assign mout_port_5_present = (j_pack5_p2 == 3'b000);

  endmodule


// Local Variables:
// verilog-library-directories:("../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-module-parents:("jbi_mout_csr")
// End:
