// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_jid_to_yid_table.v
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
// jbi_jid_to_yid_table -- JBus JID to YID translation table.
// _____________________________________________________________________________
//
// Description:
//   Provides a JID to YID translation table.  Provides 16 direct mapped JID to YID
//   entries.  Access is one read port ('trans_*' signals), and one write port
//   ('alloc_*' signals).
//
// Interface:
//   Translation request:
//     A JID 'trans_jid' is given which returns the YID 'trans_yid' on the same cycle.
//     There are no qualifier signals.
//   
//   Allocating an assignment request:
//     When 'alloc' is asserted, the YID 'alloc_yid' will be associated with the JID 'alloc_yid'.
//
// Design Notes:
//   o The table 'yid_table' is indexed by the 'jid' to provide the associated 'yid'.
//   o This is a one read port, one write port structure that uses 208 storage bits.
// _____________________________________________________________________________

`include "sys.h"


module jbi_jid_to_yid_table (/*AUTOARG*/
  // Outputs
  trans_yid0, trans_yid1, 
  // Inputs
  trans_jid0, trans_jid1, alloc, alloc_jid, alloc_yid, clk, rst_l
  );

  // Translation, port 0.
  input    [3:0] trans_jid0;
  output   [9:0] trans_yid0;

  // Translation, port 1.
  input    [3:0] trans_jid1;
  output   [9:0] trans_yid1;

  // Allocating an assignment.
  input 	 alloc;
  input    [3:0] alloc_jid;
  input    [9:0] alloc_yid;

  // Clock and reset.
  input		 clk;
  input		 rst_l;


  // Wires and Regs.
  wire write_00, write_01, write_02, write_03, write_04, write_05, write_06, write_07;
  wire write_08, write_09, write_10, write_11, write_12, write_13, write_14, write_15;
  wire [9:0] next_yid_table_00, yid_table_00;
  wire [9:0] next_yid_table_01, yid_table_01;
  wire [9:0] next_yid_table_02, yid_table_02;
  wire [9:0] next_yid_table_03, yid_table_03;
  wire [9:0] next_yid_table_04, yid_table_04;
  wire [9:0] next_yid_table_05, yid_table_05;
  wire [9:0] next_yid_table_06, yid_table_06;
  wire [9:0] next_yid_table_07, yid_table_07;
  wire [9:0] next_yid_table_08, yid_table_08;
  wire [9:0] next_yid_table_09, yid_table_09;
  wire [9:0] next_yid_table_10, yid_table_10;
  wire [9:0] next_yid_table_11, yid_table_11;
  wire [9:0] next_yid_table_12, yid_table_12;
  wire [9:0] next_yid_table_13, yid_table_13;
  wire [9:0] next_yid_table_14, yid_table_14;
  wire [9:0] next_yid_table_15, yid_table_15;
  reg  [9:0] trans_yid0, trans_yid1;



  // YID Table Read Port0.
  always @(/*AS*/trans_jid0 or yid_table_00 or yid_table_01 or yid_table_02
	   or yid_table_03 or yid_table_04 or yid_table_05 or yid_table_06
	   or yid_table_07 or yid_table_08 or yid_table_09 or yid_table_10
	   or yid_table_11 or yid_table_12 or yid_table_13 or yid_table_14
	   or yid_table_15) begin
    case(trans_jid0)		// synopsys infer_mux
      4'd00: trans_yid0 = yid_table_00;
      4'd01: trans_yid0 = yid_table_01;
      4'd02: trans_yid0 = yid_table_02;
      4'd03: trans_yid0 = yid_table_03;
      4'd04: trans_yid0 = yid_table_04;
      4'd05: trans_yid0 = yid_table_05;
      4'd06: trans_yid0 = yid_table_06;
      4'd07: trans_yid0 = yid_table_07;
      4'd08: trans_yid0 = yid_table_08;
      4'd09: trans_yid0 = yid_table_09;
      4'd10: trans_yid0 = yid_table_10;
      4'd11: trans_yid0 = yid_table_11;
      4'd12: trans_yid0 = yid_table_12;
      4'd13: trans_yid0 = yid_table_13;
      4'd14: trans_yid0 = yid_table_14;
      4'd15: trans_yid0 = yid_table_15;
      endcase
    end


  // YID Table Read Port1.
  always @(/*AS*/trans_jid1 or yid_table_00 or yid_table_01 or yid_table_02
	   or yid_table_03 or yid_table_04 or yid_table_05 or yid_table_06
	   or yid_table_07 or yid_table_08 or yid_table_09 or yid_table_10
	   or yid_table_11 or yid_table_12 or yid_table_13 or yid_table_14
	   or yid_table_15) begin
    case(trans_jid1)		// synopsys infer_mux
      4'd00: trans_yid1 = yid_table_00;
      4'd01: trans_yid1 = yid_table_01;
      4'd02: trans_yid1 = yid_table_02;
      4'd03: trans_yid1 = yid_table_03;
      4'd04: trans_yid1 = yid_table_04;
      4'd05: trans_yid1 = yid_table_05;
      4'd06: trans_yid1 = yid_table_06;
      4'd07: trans_yid1 = yid_table_07;
      4'd08: trans_yid1 = yid_table_08;
      4'd09: trans_yid1 = yid_table_09;
      4'd10: trans_yid1 = yid_table_10;
      4'd11: trans_yid1 = yid_table_11;
      4'd12: trans_yid1 = yid_table_12;
      4'd13: trans_yid1 = yid_table_13;
      4'd14: trans_yid1 = yid_table_14;
      4'd15: trans_yid1 = yid_table_15;
      endcase
    end


  // YID Table Write Port.
  assign write_00 = alloc && (alloc_jid == 4'd00);
  assign write_01 = alloc && (alloc_jid == 4'd01);
  assign write_02 = alloc && (alloc_jid == 4'd02);
  assign write_03 = alloc && (alloc_jid == 4'd03);
  assign write_04 = alloc && (alloc_jid == 4'd04);
  assign write_05 = alloc && (alloc_jid == 4'd05);
  assign write_06 = alloc && (alloc_jid == 4'd06);
  assign write_07 = alloc && (alloc_jid == 4'd07);
  assign write_08 = alloc && (alloc_jid == 4'd08);
  assign write_09 = alloc && (alloc_jid == 4'd09);
  assign write_10 = alloc && (alloc_jid == 4'd10);
  assign write_11 = alloc && (alloc_jid == 4'd11);
  assign write_12 = alloc && (alloc_jid == 4'd12);
  assign write_13 = alloc && (alloc_jid == 4'd13);
  assign write_14 = alloc && (alloc_jid == 4'd14);
  assign write_15 = alloc && (alloc_jid == 4'd15);
  assign next_yid_table_00 = alloc_yid;
  assign next_yid_table_01 = alloc_yid;
  assign next_yid_table_02 = alloc_yid;
  assign next_yid_table_03 = alloc_yid;
  assign next_yid_table_04 = alloc_yid;
  assign next_yid_table_05 = alloc_yid;
  assign next_yid_table_06 = alloc_yid;
  assign next_yid_table_07 = alloc_yid;
  assign next_yid_table_08 = alloc_yid;
  assign next_yid_table_09 = alloc_yid;
  assign next_yid_table_10 = alloc_yid;
  assign next_yid_table_11 = alloc_yid;
  assign next_yid_table_12 = alloc_yid;
  assign next_yid_table_13 = alloc_yid;
  assign next_yid_table_14 = alloc_yid;
  assign next_yid_table_15 = alloc_yid;

  // YID Table.
  dffrle_ns #(10) yid_table_00_reg (.din(next_yid_table_00), .en(write_00), .q(yid_table_00), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_01_reg (.din(next_yid_table_01), .en(write_01), .q(yid_table_01), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_02_reg (.din(next_yid_table_02), .en(write_02), .q(yid_table_02), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_03_reg (.din(next_yid_table_03), .en(write_03), .q(yid_table_03), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_04_reg (.din(next_yid_table_04), .en(write_04), .q(yid_table_04), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_05_reg (.din(next_yid_table_05), .en(write_05), .q(yid_table_05), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_06_reg (.din(next_yid_table_06), .en(write_06), .q(yid_table_06), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_07_reg (.din(next_yid_table_07), .en(write_07), .q(yid_table_07), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_08_reg (.din(next_yid_table_08), .en(write_08), .q(yid_table_08), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_09_reg (.din(next_yid_table_09), .en(write_09), .q(yid_table_09), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_10_reg (.din(next_yid_table_10), .en(write_10), .q(yid_table_10), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_11_reg (.din(next_yid_table_11), .en(write_11), .q(yid_table_11), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_12_reg (.din(next_yid_table_12), .en(write_12), .q(yid_table_12), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_13_reg (.din(next_yid_table_13), .en(write_13), .q(yid_table_13), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_14_reg (.din(next_yid_table_14), .en(write_14), .q(yid_table_14), .rst_l(rst_l), .clk(clk));
  dffrle_ns #(10) yid_table_15_reg (.din(next_yid_table_15), .en(write_15), .q(yid_table_15), .rst_l(rst_l), .clk(clk));

endmodule


// Local Variables:
// verilog-library-directories:("../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-module-parents:("jbi_jid_to_yid")
// End:
