// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_timer.v
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
// jbi_timer -- Simple timer.
// _____________________________________________________________________________
//

`include "sys.h"


module jbi_timer (/*AUTOARG*/
  // Outputs
  busy, error, 
  // Inputs
  start, stopnclear, tick, clk, rst_l
  );

  `include "jbi_mout.h"

  input             start;		//
  input             stopnclear;		//
  output            busy;		//
  output            error;		//
  
  input 	    tick;		// Count timer by 1.
  input 	    clk;		// Clock.
  input 	    rst_l;		// Reset.


  // Wires and Regs.
  wire [1:0] state;
  reg busy, error;
  reg [1:0] next_state;


  // States.
  parameter UNUSED   = 2'b00;
  parameter COUNT_0  = 2'b01;
  parameter COUNT_1  = 2'b10;
  parameter OVERFLOW = 2'b11;
  parameter STATE_x  = 2'bxx;

  // Machine State (initialize to IDLE).
  dffrl_ns #(2) state_reg (.din(next_state), .q(state), .rst_l(rst_l), .clk(clk));

  always @(/*AS*/start or state or stopnclear or tick) begin
    `define out { next_state, error, busy }
    casex ({ state, start, stopnclear, tick })
      //
      //                      stop          ][
      // Current              n             ][          Next             
      // State        start   clear   tick  ][          State       error  busy
      // -----------------------------------++----------------------------------
      // Counter not being used.
      {  UNUSED,      N,      x,      x     }:  `out = { UNUSED,    N,     N   };
      {    UNUSED,    Y,      x,      x     }:  `out = { COUNT_0,   N,     N   };

      // Counter started.  No counts yet.
      {  COUNT_0,     x,      N,      N     }:  `out = { COUNT_0,   N,     Y   };
      {    COUNT_0,   x,      Y,      x     }:  `out = { UNUSED,    N,     Y   };
      {    COUNT_0,   x,      N,      Y     }:  `out = { COUNT_1,   N,     Y   };

      // Counter started.  Have seen one "tick".
      {  COUNT_1,     x,      N,      N     }:  `out = { COUNT_1,   N,     Y   };
      {    COUNT_1,   x,      Y,      x     }:  `out = { UNUSED,    N,     Y   };
      {    COUNT_1,   x,      N,      Y     }:  `out = { OVERFLOW,  N,     Y   };

      // Saw two "tick"s and have reported the overflow.
      {  OVERFLOW,    x,      N,      x     }:  `out = { OVERFLOW,  Y,     Y   };
      {    OVERFLOW,  x,      Y,      x     }:  `out = { UNUSED,    Y,     Y   };
       
      default:					`out = { STATE_x,   x,     x   };
      endcase
    `undef out
    end



  // Monitors.

  // simtech modcovoff -bpen
  // synopsys translate_off

  // Check: 'Start' never asserted when in OVERFLOW state.
  always @(posedge clk) begin
    if (!(~rst_l) && state == OVERFLOW && start) begin
      $dispmon ("jbi_mout_jbi_timer", 49, "%d %m: ERROR - JID reused before being released!", $time, state);
      end
    end

  // Check: State machine has valid state.
  always @(posedge clk) begin
    if (!(~rst_l) && next_state === STATE_x) begin
      $dispmon ("jbi_mout_jbi_timer", 49, "%d %m: ERROR - No state asserted! (state=%b)", $time, state);
      end
    end

  // synopsys translate_on
  // simtech modcovon -bpen


  endmodule


// Local Variables:
// verilog-library-directories:("." "../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-auto-read-includes:t
// verilog-module-parents:("jbi_ncrd_timeout")
// End:
