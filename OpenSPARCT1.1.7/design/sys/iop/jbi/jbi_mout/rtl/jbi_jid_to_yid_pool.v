// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_jid_to_yid_pool.v
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
// jbi_jid_to_yid_pool -- JID tracking unit.
// _____________________________________________________________________________
//
// Description:
//   Provides a table 'used_jids[]' to manage unused JIDs.  Provides 16 entries
//   each 1 bit wide to hold up to 16 JIDs.  Access is one read port and one write
//   port.
// _____________________________________________________________________________

`include "sys.h"


module jbi_jid_to_yid_pool (/*AUTOARG*/
// Outputs
jid_is_avail, jid, trans_valid0, trans_valid1, 
// Inputs
remove, add0, add_jid0, add1, add_jid1, trans_jid0, trans_jid1, clk, 
rst_l
);

  // Removing from pool.
  output	jid_is_avail;		// Asserted if an unused JID is available.
  output [3:0]	jid;			// An unused JID.  Valid only if 'jid_is_avail' is asserted.
  input		remove;			// When asserted, the JID specified in 'jid' will be removed from the JID pool on the next cycle.
  //
  // Adding to pool, port0.
  input		add0;			// If asserted, the JID in 'add_jid0' will be added to the JID pool.
  input	 [3:0]	add_jid0;		// The JID to add to the JID pool.
  //
  // Adding to pool, port 1.
  input		add1;			// If asserted, the JID in 'add_jid1' will be added to the JID pool.
  input	 [3:0]	add_jid1;		// The JID to add to the JID pool.
  //
  // Translation validation, port 0.
  input   [3:0] trans_jid0;		// Verify that transaction exists for this JID.
  output    	trans_valid0;		// Translation for 'trans_jid0[]' exists and is valid.
  //
  // Translation validation, port 1.
  input   [3:0] trans_jid1;		// Verify that transaction exists for this JID.
  output    	trans_valid1;		// Translation for 'trans_jid1[]' exists and is valid.
  //
  // System interface.
  input 	clk;			// JBus clock.
  input 	rst_l;			// Reset.

  
  // Wires and Regs.
  wire last_avail_jid_en;
  wire  [3:0] next_last_avail_jid, last_avail_jid;
  wire [15:0] used_jids, next_used_jids;
  wire [15:0] used_jids_en;
  wire [15:0] next_used_jids_clr;
  wire [15:0] next_used_jids_set;
  wire [15:0] unused_jids;
  wire [15:0] unused_jids_reordered;
  wire [15:0] avail_jids_reordered;
  wire [15:0] decoded_jid;
  reg         trans_valid0, trans_valid1;
  reg 	[3:0] jid;



  // JID Pool.
  dffrle_ns used_jids_reg00 (.din(next_used_jids[ 0]), .en(used_jids_en[ 0]), .q(used_jids[ 0]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg01 (.din(next_used_jids[ 1]), .en(used_jids_en[ 1]), .q(used_jids[ 1]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg02 (.din(next_used_jids[ 2]), .en(used_jids_en[ 2]), .q(used_jids[ 2]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg03 (.din(next_used_jids[ 3]), .en(used_jids_en[ 3]), .q(used_jids[ 3]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg04 (.din(next_used_jids[ 4]), .en(used_jids_en[ 4]), .q(used_jids[ 4]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg05 (.din(next_used_jids[ 5]), .en(used_jids_en[ 5]), .q(used_jids[ 5]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg06 (.din(next_used_jids[ 6]), .en(used_jids_en[ 6]), .q(used_jids[ 6]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg07 (.din(next_used_jids[ 7]), .en(used_jids_en[ 7]), .q(used_jids[ 7]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg08 (.din(next_used_jids[ 8]), .en(used_jids_en[ 8]), .q(used_jids[ 8]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg09 (.din(next_used_jids[ 9]), .en(used_jids_en[ 9]), .q(used_jids[ 9]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg10 (.din(next_used_jids[10]), .en(used_jids_en[10]), .q(used_jids[10]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg11 (.din(next_used_jids[11]), .en(used_jids_en[11]), .q(used_jids[11]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg12 (.din(next_used_jids[12]), .en(used_jids_en[12]), .q(used_jids[12]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg13 (.din(next_used_jids[13]), .en(used_jids_en[13]), .q(used_jids[13]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg14 (.din(next_used_jids[14]), .en(used_jids_en[14]), .q(used_jids[14]), .rst_l(rst_l), .clk(clk));
  dffrle_ns used_jids_reg15 (.din(next_used_jids[15]), .en(used_jids_en[15]), .q(used_jids[15]), .rst_l(rst_l), .clk(clk));


  // Altering the JID Pool.
  assign used_jids_en[15:0] = (next_used_jids_set[15:0] | next_used_jids_clr[15:0]);
  assign next_used_jids[15:0] = next_used_jids_set[15:0];
  //
  assign next_used_jids_clr[ 0] = (add0 && (add_jid0 == 4'b0000)) || (add1 && (add_jid1 == 4'b0000));
  assign next_used_jids_set[ 0] = (remove &&    (jid == 4'b0000));
  assign next_used_jids_clr[ 1] = (add0 && (add_jid0 == 4'b0001)) || (add1 && (add_jid1 == 4'b0001));
  assign next_used_jids_set[ 1] = (remove &&    (jid == 4'b0001));
  assign next_used_jids_clr[ 2] = (add0 && (add_jid0 == 4'b0010)) || (add1 && (add_jid1 == 4'b0010));
  assign next_used_jids_set[ 2] = (remove &&    (jid == 4'b0010));
  assign next_used_jids_clr[ 3] = (add0 && (add_jid0 == 4'b0011)) || (add1 && (add_jid1 == 4'b0011));
  assign next_used_jids_set[ 3] = (remove &&    (jid == 4'b0011));
  assign next_used_jids_clr[ 4] = (add0 && (add_jid0 == 4'b0100)) || (add1 && (add_jid1 == 4'b0100));
  assign next_used_jids_set[ 4] = (remove &&    (jid == 4'b0100));
  assign next_used_jids_clr[ 5] = (add0 && (add_jid0 == 4'b0101)) || (add1 && (add_jid1 == 4'b0101));
  assign next_used_jids_set[ 5] = (remove &&    (jid == 4'b0101));
  assign next_used_jids_clr[ 6] = (add0 && (add_jid0 == 4'b0110)) || (add1 && (add_jid1 == 4'b0110));
  assign next_used_jids_set[ 6] = (remove &&    (jid == 4'b0110));
  assign next_used_jids_clr[ 7] = (add0 && (add_jid0 == 4'b0111)) || (add1 && (add_jid1 == 4'b0111));
  assign next_used_jids_set[ 7] = (remove &&    (jid == 4'b0111));
  assign next_used_jids_clr[ 8] = (add0 && (add_jid0 == 4'b1000)) || (add1 && (add_jid1 == 4'b1000));
  assign next_used_jids_set[ 8] = (remove &&    (jid == 4'b1000));
  assign next_used_jids_clr[ 9] = (add0 && (add_jid0 == 4'b1001)) || (add1 && (add_jid1 == 4'b1001));
  assign next_used_jids_set[ 9] = (remove &&    (jid == 4'b1001));
  assign next_used_jids_clr[10] = (add0 && (add_jid0 == 4'b1010)) || (add1 && (add_jid1 == 4'b1010));
  assign next_used_jids_set[10] = (remove &&    (jid == 4'b1010));
  assign next_used_jids_clr[11] = (add0 && (add_jid0 == 4'b1011)) || (add1 && (add_jid1 == 4'b1011));
  assign next_used_jids_set[11] = (remove &&    (jid == 4'b1011));
  assign next_used_jids_clr[12] = (add0 && (add_jid0 == 4'b1100)) || (add1 && (add_jid1 == 4'b1100));
  assign next_used_jids_set[12] = (remove &&    (jid == 4'b1100));
  assign next_used_jids_clr[13] = (add0 && (add_jid0 == 4'b1101)) || (add1 && (add_jid1 == 4'b1101));
  assign next_used_jids_set[13] = (remove &&    (jid == 4'b1101));
  assign next_used_jids_clr[14] = (add0 && (add_jid0 == 4'b1110)) || (add1 && (add_jid1 == 4'b1110));
  assign next_used_jids_set[14] = (remove &&    (jid == 4'b1110));
  assign next_used_jids_clr[15] = (add0 && (add_jid0 == 4'b1111)) || (add1 && (add_jid1 == 4'b1111));
  assign next_used_jids_set[15] = (remove &&    (jid == 4'b1111));


  // Verify that a translation exists, port 0
  always @(/*AS*/trans_jid0 or used_jids) begin
    case (trans_jid0)		// synopsys infer_mux
      4'd00: trans_valid0 = used_jids[ 0];
      4'd01: trans_valid0 = used_jids[ 1];
      4'd02: trans_valid0 = used_jids[ 2];
      4'd03: trans_valid0 = used_jids[ 3];
      4'd04: trans_valid0 = used_jids[ 4];
      4'd05: trans_valid0 = used_jids[ 5];
      4'd06: trans_valid0 = used_jids[ 6];
      4'd07: trans_valid0 = used_jids[ 7];
      4'd08: trans_valid0 = used_jids[ 8];
      4'd09: trans_valid0 = used_jids[ 9];
      4'd10: trans_valid0 = used_jids[10];
      4'd11: trans_valid0 = used_jids[11];
      4'd12: trans_valid0 = used_jids[12];
      4'd13: trans_valid0 = used_jids[13];
      4'd14: trans_valid0 = used_jids[14];
      4'd15: trans_valid0 = used_jids[15];
      endcase
    end

  
  // Verify that a translation exists, port 1
  always @(/*AS*/trans_jid1 or used_jids) begin
    case (trans_jid1)		// synopsys infer_mux
      4'd00: trans_valid1 = used_jids[ 0];
      4'd01: trans_valid1 = used_jids[ 1];
      4'd02: trans_valid1 = used_jids[ 2];
      4'd03: trans_valid1 = used_jids[ 3];
      4'd04: trans_valid1 = used_jids[ 4];
      4'd05: trans_valid1 = used_jids[ 5];
      4'd06: trans_valid1 = used_jids[ 6];
      4'd07: trans_valid1 = used_jids[ 7];
      4'd08: trans_valid1 = used_jids[ 8];
      4'd09: trans_valid1 = used_jids[ 9];
      4'd10: trans_valid1 = used_jids[10];
      4'd11: trans_valid1 = used_jids[11];
      4'd12: trans_valid1 = used_jids[12];
      4'd13: trans_valid1 = used_jids[13];
      4'd14: trans_valid1 = used_jids[14];
      4'd15: trans_valid1 = used_jids[15];
      endcase
    end

  
  // Any JID available?
  assign jid_is_avail = (used_jids != 16'b1111_1111_1111_1111);

  
  // Save the last consumed jid as a reference for the round-robin arbiter.
  assign next_last_avail_jid = jid;
  assign last_avail_jid_en = remove;
  dffrle_ns #(4) last_avail_jid_reg (.din(next_last_avail_jid), .en(last_avail_jid_en), .q(last_avail_jid), .rst_l(rst_l), .clk(clk));


  // Finding next available JID in pool.
  //
  // Always issuing just released JIDs would make transaction tracking in verification and
  // bringup difficult.  So we try and cycle through the JIDs here.
  //
  // We want to know the unused jids.
  assign unused_jids[15:0] = ~used_jids[15:0];
  //
  // Reorder the 'unused_jids[]' based on the 'last_avail_jid' such that highest priority is in the MSB
  // and lowest priority is in the LSB.
  assign unused_jids_reordered[15:0] =
    ((last_avail_jid == 4'd00)? {unused_jids[15:0]                    }: 16'b0) |  /* last_avail_jid ==  0 -> priority = 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0 */ 
    ((last_avail_jid == 4'd15)? {unused_jids[14:0], unused_jids[15]   }: 16'b0) |  /* last_avail_jid == 15 -> priority = 14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,15 */ 
    ((last_avail_jid == 4'd14)? {unused_jids[13:0], unused_jids[15:14]}: 16'b0) |  /* last_avail_jid == 14 -> priority = 13,12,11,10,9,8,7,6,5,4,3,2,1,0,15,14 */ 
    ((last_avail_jid == 4'd13)? {unused_jids[12:0], unused_jids[15:13]}: 16'b0) |  /* last_avail_jid == 13 -> priority = 12,11,10,9,8,7,6,5,4,3,2,1,0,15,14,13 */ 
    ((last_avail_jid == 4'd12)? {unused_jids[11:0], unused_jids[15:12]}: 16'b0) |  /* last_avail_jid == 12 -> priority = 11,10,9,8,7,6,5,4,3,2,1,0,15,14,13,12 */ 
    ((last_avail_jid == 4'd11)? {unused_jids[10:0], unused_jids[15:11]}: 16'b0) |  /* last_avail_jid == 11 -> priority = 10,9,8,7,6,5,4,3,2,1,0,15,14,13,12,11 */ 
    ((last_avail_jid == 4'd10)? {unused_jids[ 9:0], unused_jids[15:10]}: 16'b0) |  /* last_avail_jid == 10 -> priority = 9,8,7,6,5,4,3,2,1,0,15,14,13,12,11,10 */ 
    ((last_avail_jid == 4'd09)? {unused_jids[ 8:0], unused_jids[15: 9]}: 16'b0) |  /* last_avail_jid ==  9 -> priority = 8,7,6,5,4,3,2,1,0,15,14,13,12,11,10,9 */ 
    ((last_avail_jid == 4'd08)? {unused_jids[ 7:0], unused_jids[15: 8]}: 16'b0) |  /* last_avail_jid ==  8 -> priority = 7,6,5,4,3,2,1,0,15,14,13,12,11,10,9,8 */ 
    ((last_avail_jid == 4'd07)? {unused_jids[ 6:0], unused_jids[15: 7]}: 16'b0) |  /* last_avail_jid ==  7 -> priority = 6,5,4,3,2,1,0,15,14,13,12,11,10,9,8,7 */ 
    ((last_avail_jid == 4'd06)? {unused_jids[ 5:0], unused_jids[15: 6]}: 16'b0) |  /* last_avail_jid ==  6 -> priority = 5,4,3,2,1,0,15,14,13,12,11,10,9,8,7,6 */ 
    ((last_avail_jid == 4'd05)? {unused_jids[ 4:0], unused_jids[15: 5]}: 16'b0) |  /* last_avail_jid ==  5 -> priority = 4,3,2,1,0,15,14,13,12,11,10,9,8,7,6,5 */ 
    ((last_avail_jid == 4'd04)? {unused_jids[ 3:0], unused_jids[15: 4]}: 16'b0) |  /* last_avail_jid ==  4 -> priority = 3,2,1,0,15,14,13,12,11,10,9,8,7,6,5,4 */ 
    ((last_avail_jid == 4'd03)? {unused_jids[ 2:0], unused_jids[15: 3]}: 16'b0) |  /* last_avail_jid ==  3 -> priority = 2,1,0,15,14,13,12,11,10,9,8,7,6,5,4,3 */ 
    ((last_avail_jid == 4'd02)? {unused_jids[ 1:0], unused_jids[15: 2]}: 16'b0) |  /* last_avail_jid ==  2 -> priority = 1,0,15,14,13,12,11,10,9,8,7,6,5,4,3,2 */ 
    ((last_avail_jid == 4'd01)? {unused_jids[   0], unused_jids[15: 1]}: 16'b0) ;  /* last_avail_jid ==  1 -> priority = 0,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1 */ 
  //
  // Do a priority encode.
  assign avail_jids_reordered[15:0] = {
    (unused_jids_reordered[15]                                     ),
    (unused_jids_reordered[14] && !(| unused_jids_reordered[15]   )),
    (unused_jids_reordered[13] && !(| unused_jids_reordered[15:14])),
    (unused_jids_reordered[12] && !(| unused_jids_reordered[15:13])),
    (unused_jids_reordered[11] && !(| unused_jids_reordered[15:12])),
    (unused_jids_reordered[10] && !(| unused_jids_reordered[15:11])),
    (unused_jids_reordered[ 9] && !(| unused_jids_reordered[15:10])),
    (unused_jids_reordered[ 8] && !(| unused_jids_reordered[15: 9])),
    (unused_jids_reordered[ 7] && !(| unused_jids_reordered[15: 8])),
    (unused_jids_reordered[ 6] && !(| unused_jids_reordered[15: 7])),
    (unused_jids_reordered[ 5] && !(| unused_jids_reordered[15: 6])),
    (unused_jids_reordered[ 4] && !(| unused_jids_reordered[15: 5])),
    (unused_jids_reordered[ 3] && !(| unused_jids_reordered[15: 4])),
    (unused_jids_reordered[ 2] && !(| unused_jids_reordered[15: 3])),
    (unused_jids_reordered[ 1] && !(| unused_jids_reordered[15: 2])),
    (unused_jids_reordered[ 0] && !(| unused_jids_reordered[15: 1]))
    };
  //
  // Reverse the reordering mapping done in 'unused_jids_reordered[]'.
  assign decoded_jid[15:0] =
    ((last_avail_jid == 4'd00)? {                            avail_jids_reordered[15: 0]}: 16'b0) |
    ((last_avail_jid == 4'd15)? {avail_jids_reordered[ 0]  , avail_jids_reordered[15: 1]}: 16'b0) |
    ((last_avail_jid == 4'd14)? {avail_jids_reordered[ 1:0], avail_jids_reordered[15: 2]}: 16'b0) |
    ((last_avail_jid == 4'd13)? {avail_jids_reordered[ 2:0], avail_jids_reordered[15: 3]}: 16'b0) |
    ((last_avail_jid == 4'd12)? {avail_jids_reordered[ 3:0], avail_jids_reordered[15: 4]}: 16'b0) |
    ((last_avail_jid == 4'd11)? {avail_jids_reordered[ 4:0], avail_jids_reordered[15: 5]}: 16'b0) |
    ((last_avail_jid == 4'd10)? {avail_jids_reordered[ 5:0], avail_jids_reordered[15: 6]}: 16'b0) |
    ((last_avail_jid == 4'd09)? {avail_jids_reordered[ 6:0], avail_jids_reordered[15: 7]}: 16'b0) |
    ((last_avail_jid == 4'd08)? {avail_jids_reordered[ 7:0], avail_jids_reordered[15: 8]}: 16'b0) |
    ((last_avail_jid == 4'd07)? {avail_jids_reordered[ 8:0], avail_jids_reordered[15: 9]}: 16'b0) |
    ((last_avail_jid == 4'd06)? {avail_jids_reordered[ 9:0], avail_jids_reordered[15:10]}: 16'b0) |
    ((last_avail_jid == 4'd05)? {avail_jids_reordered[10:0], avail_jids_reordered[15:11]}: 16'b0) |
    ((last_avail_jid == 4'd04)? {avail_jids_reordered[11:0], avail_jids_reordered[15:12]}: 16'b0) |
    ((last_avail_jid == 4'd03)? {avail_jids_reordered[12:0], avail_jids_reordered[15:13]}: 16'b0) |
    ((last_avail_jid == 4'd02)? {avail_jids_reordered[13:0], avail_jids_reordered[15:14]}: 16'b0) |
    ((last_avail_jid == 4'd01)? {avail_jids_reordered[14:0], avail_jids_reordered[15   ]}: 16'b0);
  //
  // Encode the JID.
  always @(/*AS*/decoded_jid) begin
    case (1'b1)
      decoded_jid[15]: jid = 4'd15;
      decoded_jid[14]: jid = 4'd14;
      decoded_jid[13]: jid = 4'd13;
      decoded_jid[12]: jid = 4'd12;
      decoded_jid[11]: jid = 4'd11;
      decoded_jid[10]: jid = 4'd10;
      decoded_jid[ 9]: jid = 4'd09;
      decoded_jid[ 8]: jid = 4'd08;
      decoded_jid[ 7]: jid = 4'd07;
      decoded_jid[ 6]: jid = 4'd06;
      decoded_jid[ 5]: jid = 4'd05;
      decoded_jid[ 4]: jid = 4'd04;
      decoded_jid[ 3]: jid = 4'd03;
      decoded_jid[ 2]: jid = 4'd02;
      decoded_jid[ 1]: jid = 4'd01;
      decoded_jid[ 0]: jid = 4'd00;
// CoverMeter line_off
      default:         jid = 4'bX;
// CoverMeter line_on
    endcase
  end

  


  // Monitors.

  // simtech modcovoff -bpen
  // synopsys translate_off

  always @(posedge clk) begin
    // Check: 'remove' should never be asserted when '!jid_is_avail'.
    if (remove && !jid_is_avail) begin
      $dispmon ("jbi_mout_jbi_jid_to_yid_pool", 49, "%d %m: ERROR - JID Pool has underflowed!", $time);
      end

    // (This check is commented out because an 'Unexpected Data Return' after a 'Read Return Timeout' is legal)
    //
    //// Check: Adding a JID should not already be there.
    //if (add0 && unused_jids[add_jid0]) begin
    //  $dispmon ("jbi_mout_jbi_jid_to_yid_pool", 49, "%d %m: ERROR - Attempted to add an existing JID to the JID Pool! (add_jid0=%h, unused_jids[add_jid0]=%h)", $time, add_jid0, unused_jids[add_jid0]);
    //  end
    //if (add1 && unused_jids[add_jid1]) begin
    //  $dispmon ("jbi_mout_jbi_jid_to_yid_pool", 49, "%d %m: ERROR - Attempted to add an existing JID to the JID Pool! (add_jid1=%h, unused_jids[add_jid1]=%h)", $time, add_jid1, unused_jids[add_jid1]);
    //  end
  end

 
  
  // synopsys translate_on
  // simtech modcovon -bpen

endmodule


// Local Variables:
// verilog-library-directories:("../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-module-parents:("jbi_jid_to_yid")
// End:
