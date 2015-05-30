// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_aok_dok_tracking.v
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
// jbi_aok_dok_tracking -- Incoming AOK_ON/OFF DOK_ON/OFF tracking.
// _____________________________________________________________________________
//
// Description:
//   AOK_OFF from any port, stops address cycles to anyone until that port sends an AOK_ON.
//   DOK_OFF from a port, suspends writes to that port only (but not interrupts or ack/nack returns).
// _____________________________________________________________________________

`include "sys.h"
`include "jbi.h"


module jbi_aok_dok_tracking (/*AUTOARG*/
  // Outputs
  ok_send_data_pkt_to_4, ok_send_data_pkt_to_5, ok_send_address_pkt, 
  jbi_log_arb_aok, jbi_log_arb_dok, mout_csr_err_fatal, mout_perf_aok_off, 
  mout_perf_dok_off, 
  // Inputs
  j_pack0_m1, j_pack1_m1, j_pack4_p1, j_pack5_p1, clk, rst_l
  );

  // J_PACK signals.
  input   [2:0] j_pack0_m1;
  input   [2:0] j_pack1_m1;
  input   [2:0] j_pack4_p1;
  input   [2:0] j_pack5_p1;

  // Flow control signals.
  output        ok_send_data_pkt_to_4;
  output        ok_send_data_pkt_to_5;
  output        ok_send_address_pkt;

  // CSR Interface.
  output  [6:0] jbi_log_arb_aok;	// "Arbitration Timeout Error" logged data.
  output  [6:0] jbi_log_arb_dok;
  output  [5:4] mout_csr_err_fatal;	// Report DOK Fatal on J_PACK4 or J_PACK5.

  // Performance Counter events.
  output 	mout_perf_aok_off;
  output 	mout_perf_dok_off;

  // Clock and reset.
  input         clk;
  input         rst_l;



  // Wires and Regs.
  wire [2:0] next_j_pack0, next_j_pack0_p1, next_j_pack1, next_j_pack1_p1;
  wire [2:0] j_pack0, j_pack1, j_pack0_p1, j_pack1_p1;
  wire set_aok_off_0_p1, clr_aok_off_0_p1, set_aok_off_1_p1, clr_aok_off_1_p1, set_aok_off_4_p1, clr_aok_off_4_p1, set_aok_off_5_p1, clr_aok_off_5_p1;
  wire set_dok_off_4_p1, clr_dok_off_4_p1, set_dok_off_5_p1, clr_dok_off_5_p1;



  // Stage our jpack out signals 2 cycles to align them to those we got from the external devices.
  assign next_j_pack0 = j_pack0_m1;
  dff_ns #(3) j_pack0_reg (.din(next_j_pack0), .q(j_pack0), .clk(clk));
  assign next_j_pack0_p1 = j_pack0;
  dff_ns #(3) j_pack0_p1_reg (.din(next_j_pack0_p1), .q(j_pack0_p1), .clk(clk));
  //
  assign next_j_pack1 = j_pack1_m1;
  dff_ns #(3) j_pack1_reg (.din(next_j_pack1), .q(j_pack1), .clk(clk));
  assign next_j_pack1_p1 = j_pack1;
  dff_ns #(3) j_pack1_p1_reg (.din(next_j_pack1_p1), .q(j_pack1_p1), .clk(clk));



  // Tracking AOK and DOK states for AID 0.
  //
  // AOK 0 Off
  assign set_aok_off_0_p1 = (j_pack0_p1 == `JBI_P_AOK_OFF);
  assign clr_aok_off_0_p1 = (j_pack0_p1 == `JBI_P_AOK_ON);
  srffrl_ns aok_off_0_p1_reg (.set(set_aok_off_0_p1), .clr(clr_aok_off_0_p1), .q(aok_off_0_p1), .rst_l(rst_l), .clk(clk));
  wire 	 aok_off_0 = set_aok_off_0_p1 || aok_off_0_p1;

  // DOK 0 Off
  //assign set_dok_off_0_p1 = (j_pack0_p1 == `JBI_P_DOK_OFF);
  //assign clr_dok_off_0_p1 = (j_pack0_p1 == `JBI_P_DOK_ON);
  //srffrl_ns dok_off_0_p1_reg (.set(set_dok_off_0_p1), .clr(clr_dok_off_0_p1), .q(dok_off_0_p1), .rst_l(rst_l), .clk(clk));
  //wire dok_off_0 = set_dok_off_0_p1 || dok_off_0_p1;
  wire dok_off_0 = 1'b0;

  // DOK 0 Fatal
  //wire [2:0] dok0_on_cnt;
  //wire [2:0] next_dok0_on_cnt = (j_pack0_p1 != `JBI_P_DOK_ON)? 3'b0:
  //				  (dok0_on_cnt != 3'b111)?       dok0_on_cnt + 1'b1:
  //							         dok0_on_cnt;
  //dffrl_ns #(3) dok0_on_cnt_reg (.din(next_dok0_on_cnt), .q(dok0_on_cnt), .rst_l(rst_l), .clk(clk));
  //wire dok0_fatal = (dok0_on_cnt == 3'b100);



  // Tracking AOK and DOK states for AID 1.
  //
  // AOK 1 Off
  assign set_aok_off_1_p1 = (j_pack1_p1 == `JBI_P_AOK_OFF);
  assign clr_aok_off_1_p1 = (j_pack1_p1 == `JBI_P_AOK_ON);
  srffrl_ns aok_off_1_p1_reg (.set(set_aok_off_1_p1), .clr(clr_aok_off_1_p1), .q(aok_off_1_p1), .rst_l(rst_l), .clk(clk));
  wire 	 aok_off_1 = set_aok_off_1_p1 || aok_off_1_p1;

  // DOK 1 Off
  //assign set_dok_off_1_p1 = (j_pack1_p1 == `JBI_P_DOK_OFF);
  //assign clr_dok_off_1_p1 = (j_pack1_p1 == `JBI_P_DOK_ON);
  //srffrl_ns dok_off_1_p1_reg (.set(set_dok_off_1_p1), .clr(clr_dok_off_1_p1), .q(dok_off_1_p1), .rst_l(rst_l), .clk(clk));
  //wire dok_off_1 = set_dok_off_1_p1 || dok_off_1_p1;
  wire dok_off_1 = 1'b0;

  // DOK 1 Fatal
  //wire [2:0] dok1_on_cnt;
  //wire [2:0] next_dok1_on_cnt = (j_pack1_p1 != `JBI_P_DOK_ON)? 3'b0:
  //				  (dok1_on_cnt != 3'b111)?       dok1_on_cnt + 1'b1:
  //							         dok1_on_cnt;
  //dffrl_ns #(3) dok1_on_cnt_reg (.din(next_dok1_on_cnt), .q(dok1_on_cnt), .rst_l(rst_l), .clk(clk));
  //wire dok1_fatal = (dok1_on_cnt == 3'b100);



  // Tracking AOK and DOK states for AID 2.
  //
  // AOK 2 Off
  //assign set_aok_off_2 = (j_pack2_p1 == `JBI_P_AOK_OFF);
  //assign clr_aok_off_2 = (j_pack2_p1 == `JBI_P_AOK_ON);
  //srffrl_ns aok_off_2_reg (.set(set_aok_off_2), .clr(clr_aok_off_2), .q(aok_off_2), .rst_l(rst_l), .clk(clk));
  wire aok_off_2 = 1'b0;

  // DOK 2 Off
  //assign set_dok_off_2_p1 = (j_pack2_p1 == `JBI_P_DOK_OFF);
  //assign clr_dok_off_2_p1 = (j_pack2_p1 == `JBI_P_DOK_ON);
  //srffrl_ns dok_off_2_p1_reg (.set(set_dok_off_2_p1), .clr(clr_dok_off_2_p1), .q(dok_off_2_p1), .rst_l(rst_l), .clk(clk));
  //wire dok_off_2 = set_dok_off_2_p1 || dok_off_2_p1;
  wire dok_off_2 = 1'b0;

  // DOK 2 Fatal
  //wire [2:0] dok2_on_cnt;
  //wire [2:0] next_dok2_on_cnt = (j_pack2_p1 != `JBI_P_DOK_ON)? 3'b0:
  //				  (dok2_on_cnt != 3'b111)?       dok2_on_cnt + 1'b1:
  //							         dok2_on_cnt;
  //dffrl_ns #(3) dok2_on_cnt_reg (.din(next_dok2_on_cnt), .q(dok2_on_cnt), .rst_l(rst_l), .clk(clk));
  //wire dok2_fatal = (dok2_on_cnt == 3'b100);



  // Tracking AOK and DOK states for AID 3.
  //
  // AOK 3 Off
  //assign set_aok_off_3 = (j_pack3_p1 == `JBI_P_AOK_OFF);
  //assign clr_aok_off_3 = (j_pack3_p1 == `JBI_P_AOK_ON);
  //srffrl_ns aok_off_3_reg (.set(set_aok_off_3), .clr(clr_aok_off_3), .q(aok_off_3), .rst_l(rst_l), .clk(clk));
  wire aok_off_3 = 1'b0;

  // DOK 3 Off
  //assign set_dok_off_3_p1 = (j_pack3_p1 == `JBI_P_DOK_OFF);
  //assign clr_dok_off_3_p1 = (j_pack3_p1 == `JBI_P_DOK_ON);
  //srffrl_ns dok_off_3_p1_reg (.set(set_dok_off_3_p1), .clr(clr_dok_off_3_p1), .q(dok_off_3_p1), .rst_l(rst_l), .clk(clk));
  //wire dok_off_3 = set_dok_off_3_p1 || dok_off_3_p1;
  wire dok_off_3 = 1'b0;

  // DOK 3 Fatal
  //wire [2:0] dok3_on_cnt;
  //wire [2:0] next_dok3_on_cnt = (j_pack3_p1 != `JBI_P_DOK_ON)? 3'b0:
  //				  (dok3_on_cnt != 3'b111)?       dok3_on_cnt + 1'b1:
  //							         dok3_on_cnt;
  //dffrl_ns #(3) dok3_on_cnt_reg (.din(next_dok3_on_cnt), .q(dok3_on_cnt), .rst_l(rst_l), .clk(clk));
  //wire dok3_fatal = (dok3_on_cnt == 3'b100);



  // Tracking AOK and DOK states for AID 4.
  //
  // AOK 4 Off
  assign set_aok_off_4_p1 = (j_pack4_p1 == `JBI_P_AOK_OFF);
  assign clr_aok_off_4_p1 = (j_pack4_p1 == `JBI_P_AOK_ON);
  srffrl_ns aok_off_4_p1_reg (.set(set_aok_off_4_p1), .clr(clr_aok_off_4_p1), .q(aok_off_4_p1), .rst_l(rst_l), .clk(clk));
  wire 	 aok_off_4 = set_aok_off_4_p1 || aok_off_4_p1;

  // DOK 4 Off
  assign set_dok_off_4_p1 = (j_pack4_p1 == `JBI_P_DOK_OFF);
  assign clr_dok_off_4_p1 = (j_pack4_p1 == `JBI_P_DOK_ON);
  srffrl_ns dok_off_4_p1_reg (.set(set_dok_off_4_p1), .clr(clr_dok_off_4_p1), .q(dok_off_4_p1), .rst_l(rst_l), .clk(clk));
  wire 	 dok_off_4 = set_dok_off_4_p1 || dok_off_4_p1;

  // DOK 4 Fatal
  wire [2:0] dok4_on_cnt;
  wire [2:0] next_dok4_on_cnt = (j_pack4_p1 != `JBI_P_DOK_ON)? 3'b0:
				(dok4_on_cnt != 3'b111)?       dok4_on_cnt + 1'b1:
							       dok4_on_cnt;
  dffrl_ns #(3) dok4_on_cnt_reg (.din(next_dok4_on_cnt), .q(dok4_on_cnt), .rst_l(rst_l), .clk(clk));
  wire dok4_fatal = (dok4_on_cnt == 3'b100);



  // Tracking AOK and DOK states for AID 5.
  //
  // AOK 5 Off
  assign set_aok_off_5_p1 = (j_pack5_p1 == `JBI_P_AOK_OFF);
  assign clr_aok_off_5_p1 = (j_pack5_p1 == `JBI_P_AOK_ON);
  srffrl_ns aok_off_5_p1_reg (.set(set_aok_off_5_p1), .clr(clr_aok_off_5_p1), .q(aok_off_5_p1), .rst_l(rst_l), .clk(clk));
  wire 	 aok_off_5 = set_aok_off_5_p1 || aok_off_5_p1;

  // DOK 5 Off
  assign set_dok_off_5_p1 = (j_pack5_p1 == `JBI_P_DOK_OFF);
  assign clr_dok_off_5_p1 = (j_pack5_p1 == `JBI_P_DOK_ON);
  srffrl_ns dok_off_5_p1_reg (.set(set_dok_off_5_p1), .clr(clr_dok_off_5_p1), .q(dok_off_5_p1), .rst_l(rst_l), .clk(clk));
  wire 	 dok_off_5 = set_dok_off_5_p1 || dok_off_5_p1;

  // DOK 5 Fatal
  wire [2:0] dok5_on_cnt;
  wire [2:0] next_dok5_on_cnt = (j_pack5_p1 != `JBI_P_DOK_ON)? 3'b0:
				(dok5_on_cnt != 3'b111)?       dok5_on_cnt + 1'b1:
							       dok5_on_cnt;
  dffrl_ns #(3) dok5_on_cnt_reg (.din(next_dok5_on_cnt), .q(dok5_on_cnt), .rst_l(rst_l), .clk(clk));
  wire dok5_fatal = (dok5_on_cnt == 3'b100);


  // Tracking AOK and DOK states for AID 6.
  //
  // AOK 6 Off
  //assign set_aok_off_6 = (j_pack6_p1 == `JBI_P_AOK_OFF);
  //assign clr_aok_off_6 = (j_pack6_p1 == `JBI_P_AOK_ON);
  //srffrl_ns aok_off_6_reg (.set(set_aok_off_6), .clr(clr_aok_off_6), .q(aok_off_6), .rst_l(rst_l), .clk(clk));
  wire aok_off_6 = 1'b0;

  // DOK 6 Off
  //assign set_dok_off_6_p1 = (j_pack6_p1 == `JBI_P_DOK_OFF);
  //assign clr_dok_off_6_p1 = (j_pack6_p1 == `JBI_P_DOK_ON);
  //srffrl_ns dok_off_6_p1_reg (.set(set_dok_off_6_p1), .clr(clr_dok_off_6_p1), .q(dok_off_6_p1), .rst_l(rst_l), .clk(clk));
  //wire dok_off_6 = set_dok_off_6_p1 || dok_off_6_p1;
  wire dok_off_6 = 1'b0;

  // DOK 6 Fatal
  //wire [2:0] dok6_on_cnt;
  //wire [2:0] next_dok6_on_cnt = (j_pack6_p1 != `JBI_P_DOK_ON)? 3'b0:
  //				  (dok6_on_cnt != 3'b111)?       dok6_on_cnt + 1'b1:
  //							         dok6_on_cnt;
  //dffrl_ns #(3) dok6_on_cnt_reg (.din(next_dok6_on_cnt), .q(dok6_on_cnt), .rst_l(rst_l), .clk(clk));
  //wire dok6_fatal = (dok6_on_cnt == 3'b100);



  // Flow control signals.
  assign ok_send_address_pkt = !(aok_off_0 || aok_off_1 || aok_off_4 || aok_off_5);
  assign ok_send_data_pkt_to_4 = !dok_off_4;
  assign ok_send_data_pkt_to_5 = !dok_off_5;


  // "Arbitration Timeout Error" logged data (1 = AOK is on, 0 = AOK is off).
  assign jbi_log_arb_aok = ~ { aok_off_6, aok_off_5, aok_off_4, aok_off_3, aok_off_2, aok_off_1, aok_off_0 };
  assign jbi_log_arb_dok = ~ { dok_off_6, dok_off_5, dok_off_4, dok_off_3, dok_off_2, dok_off_1, dok_off_0 };


  // Report DOK fatal on J_PACK4 or J_PACK5.
  assign mout_csr_err_fatal[5:4] = { dok5_fatal, dok4_fatal };


  // Performance Counter events.
  assign mout_perf_aok_off = (aok_off_6 || aok_off_5 || aok_off_4 || aok_off_3 || aok_off_2 || aok_off_1 || aok_off_0);
  assign mout_perf_dok_off = (dok_off_6 || dok_off_5 || dok_off_4 || dok_off_3 || dok_off_2 || dok_off_1 || dok_off_0);



  // Monitors.

  // simtech modcovoff -bpen
  // synopsys translate_off

  // synopsys translate_on
  // simtech modcovon -bpen

  endmodule


// Local Variables:
// verilog-library-directories:("." "../../include" "../../../common/rtl")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-module-parents:("jbi_mout")
// End:
