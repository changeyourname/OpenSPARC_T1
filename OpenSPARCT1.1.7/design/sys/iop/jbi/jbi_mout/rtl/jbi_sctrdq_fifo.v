// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_sctrdq_fifo.v
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
// jbi_sctrdq_fifo - SCTRDQ ratio synchronous fifo queue implementation.
// _____________________________________________________________________________
//
// Description:
//   The implementation uses recirculating read and write pointers to the RAM.
//
// Interface:
//   enqueue - Add the entry composed 'data' to the top-of-queue.  Should not
//     be issued if 'full' is asserted.
//
//   din - The data value to put onto the fifo.
//
//   full - No more available entries in the fifo.
//
//   dequeue - Remove the top entry from the fifo exposing the next entry if
//     available.  Should not be issued if 'empty' is asserted.
//
//   dout - The data at the top of the fifo.  Must be qualified with 'empty'.
//
//   empty - No entries currently in the fifo.
// _____________________________________________________________________________

`include "sys.h"


module jbi_sctrdq_fifo (/*AUTOARG*/
// Outputs
full, dout, empty, 
// Inputs
enqueue, din, cclk, tx_en, crst_l, dequeue, clk, rst_l, hold, 
testmux_sel, rst_tri_en, arst_l
);

  // Enqueue port.
  input		 enqueue;
  input  [137:0] din;
  output 	 full;
  input 	 cclk;
  input 	 tx_en;
  input 	 crst_l;

  // Dequeue port.
  input 	 dequeue;
  output [137:0] dout;
  output 	 empty;
  input 	 clk;
  input 	 rst_l;

  // Misc.
  input 	 hold;
  input		 testmux_sel;				// Memory and ATPG test mode signal.
  input 	 rst_tri_en;
  input 	 arst_l;

  // Wires and Regs.
  wire 	     rd_enb;
  wire [4:0] wr_addr_presync, wr_addr_sync, rd_addr_presync, rd_addr_sync;




  // Write Address pointer.
  // Points to the next available write entry.   This is the write address about to be registered into the memory.
  wire [4:0] ram_wr_addr_m1;
  wire [4:0] next_ram_wr_addr_m1 = (enqueue)? ram_wr_addr_m1+1'b1: ram_wr_addr_m1;
  dffrl_ns #(5) ram_wr_addr_m1_reg (.din(next_ram_wr_addr_m1), .q(ram_wr_addr_m1), .rst_l(crst_l), .clk(cclk));

  // Read Address pointer.
  // Points to the top-of-queue entry.  This is the read address currently in the memory.
  wire [4:0] ram_rd_addr;		// Points to the top-of-queue entry.
  wire [4:0] next_ram_rd_addr = (dequeue)? ram_rd_addr+1'b1: ram_rd_addr;
  dffrl_ns #(5) ram_rd_addr_reg (.din(next_ram_rd_addr), .q(ram_rd_addr), .rst_l(rst_l), .clk(clk));

  wire [4:0] ram_rd_addr_m1 = next_ram_rd_addr[4:0];


  // Create fifo status bits 'full' and 'empty'.
  //
  // Full status.
  assign full = (rd_addr_sync[3:0] == ram_wr_addr_m1[3:0]) && (rd_addr_sync[4] != ram_wr_addr_m1[4]);
  //
  // Empty status.
  // (Needs to delay 1-cycle when going from empty to not empty (push to an empty fifo)
  //  since the memory read enable signals are registered and take a cycle to produce the data).
  assign empty = (ram_rd_addr[4:0] == wr_addr_sync[4:0]) || !rd_enb;


  // Register Array.
  wire [21:0] unused;
  wire rd_enb_m1 = (ram_rd_addr_m1[4:0] != wr_addr_sync[4:0]);
  jbi_1r1w_16x160 array_scan (
    // Write port.
    .wrclk		(cclk),
    .wr_en		(enqueue),
    .wr_adr		(ram_wr_addr_m1[3:0]),
    .din		({ 22'b0, din }),

    // Read port.
    .rdclk		(clk),
    .read_en		(rd_enb_m1),
    .rd_adr		(ram_rd_addr_m1[3:0]),
    .dout		({ unused[21:0], dout }),

    // Other.
    .rst_l		(arst_l),
    .hold		(hold),
    .testmux_sel     	(testmux_sel),
    .rst_tri_en	        (rst_tri_en)
    );


  // Signal staging and synchronizers.
  //
  // 'rd_enb' pipeline.
  wire next_rd_enb = rd_enb_m1;
  dff_ns rd_enb_reg (.din(next_rd_enb), .q(rd_enb), .clk(clk));

  // 'ram_wr_addr' synchronizer (Cmp -> JBus).
  wire [4:0] next_wr_addr_presync = ram_wr_addr_m1;
  wire       wr_addr_presync_en = tx_en;
  dffe_ns #(5) wr_addr_presync_reg (.din(next_wr_addr_presync), .en(wr_addr_presync_en), .q(wr_addr_presync), .clk(cclk));
  //
  wire [4:0] next_wr_addr_sync = wr_addr_presync;
  dff_ns  #(5) wr_addr_sync_reg (.din(next_wr_addr_sync), .q(wr_addr_sync), .clk(clk));

  // 'ram_rd_addr' synchronizer (JBus -> Cmp).
  wire [4:0] next_rd_addr_presync = ram_rd_addr;
  dff_ns #(5) rd_addr_presync_reg (.din(next_rd_addr_presync), .q(rd_addr_presync), .clk(clk));
  //
  wire [4:0] next_rd_addr_sync = rd_addr_presync;
  dff_ns #(5) rd_addr_sync_reg (.din(next_rd_addr_sync), .q(rd_addr_sync), .clk(cclk));



  // simtech modcovoff -bpen
  // synopsys translate_off

  // Check that no dequeue is done when empty.
  always @(posedge clk) begin
    if (dequeue && empty) begin
      $dispmon ("jbi_mout_jbi_sctrdq_fifo", 49, "%d %m: ERROR - Attempt made to dequeue an empty queue.", $time);
      end
    end

  // Check that no enqueue is done when full.
  always @(posedge cclk) begin
    if (enqueue && full) begin
      $dispmon ("jbi_mout_jbi_sctrdq_fifo", 49, "%d %m: ERROR - Attempt made to enqueue a full queue.", $time);
      end
    end

  // synopsys translate_on
  // simtech modcovon -bpen

  endmodule


// Local Variables:
// verilog-library-directories:("../../../include" "../../common/rtl")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-module-parents:("jbi_sctrdq")
// End:
