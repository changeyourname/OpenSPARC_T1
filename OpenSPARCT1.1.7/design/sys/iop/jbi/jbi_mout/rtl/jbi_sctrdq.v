// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_sctrdq.v
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
// jbi_sctrdq - Ratio synchronous, size interfacing fifo.
//
// Description:
//   Size interfacing fifo.  Packs four 32-bit enqueued values into a single 128-bit dequeue value.
//   Data is packed left-to-right.
//
//   Additionally, an attribute is associated with each packed 128-bit data value.  The attribute
//   is written when the last 32-bit value is packed into the 128-bit line.
//
//   The input is running at CMP frequencies, and the output is running at JBus frequncies.
//   Synchronization of control signals is performed across the ratio synchronous clock domains.
// _____________________________________________________________________________

`include "sys.h"


module jbi_sctrdq (/*AUTOARG*/
  // Outputs
  full, data_out, attr_out, empty, 
  // Inputs
  enqueue, attr_in, data_in, flush, cclk, tx_en, crst_l, dequeue, clk, rst_l, 
  hold, testmux_sel, rst_tri_en, arst_l
  );

  `include "jbi_mout.h"

  // Enqueue port.
  input		 enqueue;
  input    [9:0] attr_in;
  input   [31:0] data_in;
  input 	 flush;
  output	 full;
  input 	 cclk;
  input          tx_en;
  input 	 crst_l;

  // Dequeue port.
  input		 dequeue;
  output [127:0] data_out;
  output   [9:0] attr_out;
  output	 empty;
  input 	 clk;
  input 	 rst_l;

  // Misc.
  input 	 hold;
  input		 testmux_sel;				// Memory and ATPG test mode signal.
  input          rst_tri_en;
  input 	 arst_l;

  // Wires and Regs.
  wire [31:0] data_in_w0, data_in_w1, data_in_w2, data_in_w3;
  wire 	[1:0] state;
  reg 	      data_in_w0_en, data_in_w1_en, data_in_w2_en, enqueue_fifo;
  reg 	[1:0] next_state;



  // States of Enqueue state machine.
  parameter W0 = 2'b00;
  parameter W1 = 2'b01;
  parameter W2 = 2'b10;
  parameter W3 = 2'b11;
  parameter WX = 2'bxx;

  // Enqueue state machine (initialize to W0).
  dffrl_ns #(2) state_reg (.din(next_state), .q(state), .rst_l(crst_l), .clk(cclk));
  //
  always @(/*AS*/data_in_w0_en or data_in_w1_en or data_in_w2_en or enqueue
	   or enqueue_fifo or flush or next_state or state) begin
    casex ({ state, enqueue, flush })
      `define out { next_state, data_in_w0_en, data_in_w1_en, data_in_w2_en, enqueue_fifo }
      //
      //                         ][          next     data_in  data_in  data_in  enqueue      
      // state    enqueue  flush ][          state    w0_en    w1_en    w2_en    fifo         
      // ------------------------++-----------------------------------------------------
      {  W0,      N,       x     }:  `out = { W0,     x,       x,       x,       N      };
      {    W0,    Y,       N     }:  `out = { W1,     Y,       x,       x,       N      };
      {    W0,    Y,       Y     }:  `out = { W0,     x,       x,       x,       Y      };
                                                                                 
      {  W1,      N,       x     }:  `out = { W1,     N,       x,       x,       N      };
      {    W1,    Y,       N     }:  `out = { W2,     N,       Y,       x,       N      };
      {    W1,    Y,       Y     }:  `out = { W0,     x,       x,       x,       Y      };
                                                                                 
      {  W2,      N,       x     }:  `out = { W2,     N,       N,       x,       N      };
      {    W2,    Y,       N     }:  `out = { W3,     N,       N,       Y,       N      };
      {    W2,    Y,       Y     }:  `out = { W0,     x,       x,       x,       Y      };
                                                                                 
      {  W3,      N,       x     }:  `out = { W3,     N,       N,       N,       N      };
      {    W3,    Y,       x     }:  `out = { W0,     x,       x,       x,       Y      };
                                                                                 
// CoverMeter line_off
      default:                       `out = { WX,     X,       X,       X,       X      };
// CoverMeter line_on
      `undef out
      endcase
    end


  // Saved data until ready to write row.
  dffe_ns #(32) data_in_w0_reg (.din(data_in), .en(data_in_w0_en), .q(data_in_w0), .clk(cclk));
  dffe_ns #(32) data_in_w1_reg (.din(data_in), .en(data_in_w1_en), .q(data_in_w1), .clk(cclk));
  dffe_ns #(32) data_in_w2_reg (.din(data_in), .en(data_in_w2_en), .q(data_in_w2), .clk(cclk));


  // Simple fifo.
  assign data_in_w3 = data_in;
  jbi_sctrdq_fifo  sctrdq_fifo (
    // Enqueue port.
    .enqueue		(enqueue_fifo),
    .din		({ attr_in, data_in_w0, data_in_w1, data_in_w2, data_in_w3 }),
    .full		(full),
    .cclk		(cclk),
    .tx_en              (tx_en),
    .crst_l		(crst_l),

    // Dequeue port.
    .dequeue            (dequeue),
    .dout               ({ attr_out, data_out }),
    .empty              (empty),
    .clk		(clk),
    .rst_l		(rst_l),

    // Misc.
    .hold		(hold),
    .testmux_sel	(testmux_sel),
    .rst_tri_en	        (rst_tri_en),
    .arst_l		(arst_l)
    );



  // Monitors.

  // simtech modcovoff -bpen
  // synopsys translate_off

  // Check: State machine has valid state.
  always @(posedge clk) begin
    if (next_state === WX) begin
      $dispmon ("jbi_mout_jbi_sctrdq", 49, "%d %m: ERROR - No state asserted! (state=%b)", $time, state);
      end
    end

  // synopsys translate_on
  // simtech modcovon -bpen


  endmodule


// Local Variables:
// verilog-library-directories:("." "../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-auto-read-includes:t
// verilog-module-parents:("jbi_sct_out_queues")
// End:
