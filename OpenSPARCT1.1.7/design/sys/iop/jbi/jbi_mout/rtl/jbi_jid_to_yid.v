// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_jid_to_yid.v
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
// jbi_jid_to_yid -- JBus JID to YID translator.
// _____________________________________________________________________________
//
// Description:
//   Responsible for performing the YID to JID translations for outbound local PIO 
//   transactions, and inbound local data returns.
//   For outbound local transactions, an interface is provided for allocating an unused JID
//   and remembering the JID to YID translation.
//   For inbound local data returns, an interface is provided to perform a JID to YID lookup,
//   and to free a JID translation from the table.
//   The PIO JID pool has 16 JIDs which can be associated with any 9-bit YID value.
//
// Interface:
//   Translation request:
//     A JID 'trans_jid0' is given to the 'jid_to_yid_table' which returns the YID 'trans_yid0'
//     on the same cycle.  There are no qualifier signals.
//   
//   Allocating an assignment request:
//     When 'alloc' is asserted, the YID 'alloc_yid' will be associated with the next available
//     JID and that associated JID returned in 'alloc_jid'.  Note that 'alloc_jid' is only valid
//     during the current cycle that 'alloc' is valid.  'alloc_stall' denotes that there are
//     no more available JIDs and 'alloc' must not be asserted until one is freed.  When a JID
//     is allocated, it is removed from the free jid pool 'free_jid_pool'.
//
//   Freeing an assignment request:
//     When '*' is asserted, the JID in 'free*_jid' is added to the JID free space
//     pool maintained by 'free_jid_pool'.
// _____________________________________________________________________________

`include "sys.h"


module jbi_jid_to_yid (/*AUTOARG*/
  // Outputs
  trans_yid0, trans_valid0, trans_yid1, trans_valid1, alloc_stall, alloc_jid, 
  // Inputs
  trans_jid0, trans_jid1, alloc, alloc_yid, free0, free_jid0, free1, free_jid1, 
  clk, rst_l
  );

  // Translation, port 0.
  input   [3:0] trans_jid0;
  output  [9:0] trans_yid0;
  output	trans_valid0;

  // Translation, port 1.
  input   [3:0] trans_jid1;
  output  [9:0] trans_yid1;
  output	trans_valid1;

  // Allocating an assignment.
  output 	alloc_stall;
  input 	alloc;
  input   [9:0] alloc_yid;
  output  [3:0] alloc_jid;

  // Free an assignment, port 0.
  input 	free0;
  input   [3:0] free_jid0;	 

  // Free an assignment, port 1.
  input 	free1;
  input   [3:0] free_jid1;	 

  // Clock and reset.
  input 	clk;
  input 	rst_l;


  // Wires and Regs.




  // JID to YID translation table.
  jbi_jid_to_yid_table jid_to_yid_table (
    //
    // Translation, port 0.
    .trans_jid0		(trans_jid0),
    .trans_yid0		(trans_yid0),
    //
    // Translation, port 1.
    .trans_jid1		(trans_jid1),
    .trans_yid1		(trans_yid1),
    //
    // Allocating an assignment.
    .alloc		(alloc),
    .alloc_jid		(alloc_jid),
    .alloc_yid		(alloc_yid),
    //
    // Clock and reset.
    .clk		(clk),
    .rst_l		(rst_l)
    );


  // Free JID pool.
  jbi_jid_to_yid_pool jid_to_yid_pool (
    //
    // Removing from pool (allocating jid).
    .jid_is_avail	(jid_is_avail),
    .jid		(alloc_jid),
    .remove		(alloc),
    //
    // Adding to pool, port 0.
    .add0		(free0),
    .add_jid0		(free_jid0),
    //
    // Adding to pool, port 1.
    .add1		(free1),
    .add_jid1		(free_jid1),
    //
    // Translation validation, port0.
    .trans_jid0		(trans_jid0),
    .trans_valid0	(trans_valid0),
    //
    // Translation validation, port1.
    .trans_jid1		(trans_jid1),
    .trans_valid1	(trans_valid1),
    //
    // System interface.
    .clk		(clk),
    .rst_l		(rst_l)
    );
  
  assign alloc_stall = ~jid_is_avail;



  // Monitors.

  // simtech modcovoff -bpen
  // synopsys translate_off

  // Checks: 'alloc' not asserted while 'alloc_stall'.
  always @(posedge clk) begin
    if (alloc_stall && alloc) begin
      $dispmon ("jbi_mout_jbi_jid_to_yid", 49, "%d %m: ERROR - Attempt made to allocate a JID when none are available.", $time);
      end
    end

  // synopsys translate_on
  // simtech modcovon -bpen

endmodule


// Local Variables:
// verilog-library-directories:("." "../../../include")
// verilog-module-parents:("jbi_mout")
// End:
