// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_snoop_out_queue.v
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
// jbi_snoop_out_queue -- Tracks outbound snoop requests.
// _____________________________________________________________________________
//
// Description:
//   Since there is no data, this is the degenerative case of a queue.  It is
//   implemented as a counter instead of pointers.
// _____________________________________________________________________________

`include "sys.h"


module jbi_snoop_out_queue (/*AUTOARG*/
  // Outputs
  valid, 
  // Inputs
  enqueue, dequeue, clk, rst_l
  );

  `include "jbi_mout.h"

  // Tail of queue.
  input         enqueue;

  // Head of queue.
  output        valid;
  input         dequeue;

  // Clock and reset.
  input         clk;
  input         rst_l;


  // Wires and Regs.
  wire [15:0] next_counter;
  wire [15:0] counter;




  // Counter and controls.
  dffrle_ns #(JBI_SNOOP_OUT_QUEUE_SIZE) counter_reg (.din(next_counter), .en(counter_en), .q(counter), .rst_l(rst_l), .clk(clk));
  assign counter_en = enqueue ^ dequeue;
  assign next_counter = (enqueue)?   counter + 1'b1:
                      /*(dequeue)?*/ counter - 1'b1;

  // Counter status.
  assign valid = (counter != 1'b0);


  endmodule


// Local Variables:
// verilog-library-directories:("." "../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-module-parents:("jbi_j_pack_out_gen")
// End:
