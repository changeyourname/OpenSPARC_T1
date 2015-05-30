// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_j_pack_out_gen.v
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
// jbi_j_pack_out_gen -- J_PACK_OUT generator.
// _____________________________________________________________________________
//

`include "sys.h"
`include "jbi.h"


module jbi_j_pack_out_gen (/*AUTOARG*/
  // Outputs
  jbi_io_j_pack0, jbi_io_j_pack0_en, 
  jbi_io_j_pack1, jbi_io_j_pack1_en, 
  // Inputs
  min_snp_launch, send_aok_off, send_aok_on, send_dok_off, send_dok_on, 
  dok_fatal_req_csr, dok_fatal_req_sctag, csr_jbi_error_config_fe_enb, 
  clk, rst_l, cclk, crst_l, tx_en_local_m1
  );

  `include "jbi_mout.h"

  // COHACK response requests.
  input         min_snp_launch;

  // Flow Control.
  input         send_aok_off;
  input         send_aok_on;
  input         send_dok_off;
  input         send_dok_on;

  // Fatal error control.
  input         dok_fatal_req_csr;			// CSR request for DOK Fatal.
  input   [3:0] dok_fatal_req_sctag;			// SCTAG3-0 requests for DOK Fatal.
  input         csr_jbi_error_config_fe_enb;		// Enable DOK Fatal for non-JBI fatal errors.

  // JPack out.
  output [2:0]  jbi_io_j_pack0;
  output 	jbi_io_j_pack0_en;
  output [2:0]  jbi_io_j_pack1;
  output 	jbi_io_j_pack1_en;

  // Clock and reset.
  input         clk;
  input         rst_l;
  input         cclk;
  input         crst_l;
  input         tx_en_local_m1;


  // Wires and Regs.
  wire 	     cohack_valid, send_dok_fatal;
  wire [1:0] state;
  reg 	     cohack_dequeue;
  reg  [1:0] next_state;
  reg  [2:0] jbi_io_j_pack_out;



  // Add last stage of distribution pipeline to 'tx_en'.
  dff_ns u_dff_ctu_jbi_tx_en_mout_ff (.din(tx_en_local_m1), .q(tx_en), .clk(cclk));


  // J_PACK_OUT encoded state machine.
  parameter IDLE       = 2'h0,
            DOK_FATAL2 = 2'h1,
            DOK_FATAL3 = 2'h2,
            DOK_FATAL4 = 2'h3,
            DOK_X      = 2'hx;
  parameter JBI_P_X    = 3'bx;
  dffrl_ns #(2) state_reg (.din(next_state), .q(state), .rst_l(rst_l), .clk(clk));

  always @(/*AS*/cohack_dequeue or cohack_valid
	   or jbi_io_j_pack_out or next_state or send_aok_off or send_aok_on
	   or send_dok_fatal or send_dok_off or send_dok_on
	   or state) begin
    casex ({ state, send_dok_fatal, send_aok_off, send_dok_off, send_aok_on, send_dok_on, cohack_valid })
      `define out { next_state, cohack_dequeue, jbi_io_j_pack_out }
      //                send   send   send   send   send          ][                       
      // Current        dok    aok    dok    aok    dok    cohack ][          next         cohack    j_pack
      // State          fatal  off    off    on     on     valid  ][          state        dequeue   out
      // ---------------------------------------------------------++-----------------------------------------------
      // IDLE - Waiting for a request.
      {  IDLE,          N,     N,     N,     N,     N,     N      }: `out = { IDLE,        N,       `JBI_P_IDLE    };
      {    IDLE,        Y,     x,     x,     x,     x,     x      }: `out = { DOK_FATAL2,  N,       `JBI_P_DOK_ON  };
      {    IDLE,        N,     Y,     x,     x,     x,     x      }: `out = { IDLE,        N,       `JBI_P_AOK_OFF };
      {    IDLE,        N,     N,     Y,     x,     x,     x      }: `out = { IDLE,        N,       `JBI_P_DOK_OFF };
      {    IDLE,        N,     N,     N,     Y,     x,     x      }: `out = { IDLE,        N,       `JBI_P_AOK_ON  };
      {    IDLE,        N,     N,     N,     N,     Y,     x      }: `out = { IDLE,        N,       `JBI_P_DOK_ON  };
      {    IDLE,        N,     N,     N,     N,     N,     Y      }: `out = { IDLE,        Y,       `JBI_P_COHACK  };
												  
      // DOK_FATAL - Created by sending a 'DOK_ON' for 4 cycles.
      {  DOK_FATAL2,    x,     x,     x,     x,     x,     x      }: `out = { DOK_FATAL3,  N,       `JBI_P_DOK_ON  };
      {  DOK_FATAL3,    x,     x,     x,     x,     x,     x      }: `out = { DOK_FATAL4,  N,       `JBI_P_DOK_ON  };
      {  DOK_FATAL4,    x,     x,     x,     x,     x,     x      }: `out = { IDLE,        N,       `JBI_P_DOK_ON  };

// CoverMeter line_off
      default:							     `out = { DOK_X,       x,        JBI_P_X       };
// CoverMeter line_on
      `undef out
      endcase
    end

  assign jbi_io_j_pack0 = jbi_io_j_pack_out;
  assign jbi_io_j_pack0_en = 1'b1;
  assign jbi_io_j_pack1 = jbi_io_j_pack_out;
  assign jbi_io_j_pack1_en = 1'b1;


  // Queue the snoop requests.
  jbi_snoop_out_queue  snoop_out_queue (
    // Tail of queue.
    .enqueue    (min_snp_launch),

    // Head of queue.
    .valid      (cohack_valid),
    .dequeue    (cohack_dequeue),

    // Clock and reset.
    .clk        (clk),
    .rst_l      (rst_l)
    );


  // Register, pulse catch, synchronize, and collect up cmp_clk domain DOK Fatal requests.
  //
  // Register.
  wire next_sctag_req_p1 = (|dok_fatal_req_sctag[3:0]);
  dff_ns sctag_req_p1_reg (.din(next_sctag_req_p1), .q(sctag_req_p1), .clk(cclk));
  //
  // Pulse catcher.  Cleared when transferred to 'sctag_req_presync_reg[]'.
  wire set_sctag_req_p2 = sctag_req_p1;
  wire clr_sctag_req_p2 = tx_en;			// Asserting set and clr resolves in favor of set.
  srffrl_ns sctag_req_p2_reg (.set(set_sctag_req_p2), .clr(clr_sctag_req_p2), .rst_l(crst_l), .clk(cclk), .q(sctag_req_p2));
  //
  // Cmp Clock to JBus Clock synchronizer.
  wire    next_sctag_req_presync = sctag_req_p2;
  wire    sctag_req_presync_en   = tx_en;
  dffe_ns sctag_req_presync_reg (.din(next_sctag_req_presync), .en(sctag_req_presync_en), .q(sctag_req_presync), .clk(cclk));
  //
  wire   next_sctag_req_sync = sctag_req_presync;
  dff_ns sctag_req_sync_reg (.din(next_sctag_req_sync), .q(sctag_req_sync), .clk(clk));
  //
  // (send_dok_fatal only needs to be pulsed since the state machine is constructed such that it will always see it.)
  assign send_dok_fatal = dok_fatal_req_csr || (sctag_req_sync && csr_jbi_error_config_fe_enb);



  // Monitors.

  // simtech modcovoff -bpen
  // synopsys translate_off

  // Track DOK/AOK on/off for checks.
  reg 	 dok;
  reg    aok;
  initial begin
    dok = Y;
    aok = Y;
    end
  always @(posedge clk) begin
    if (send_aok_off)
      aok <= #1 N;
    if (send_aok_on)
      aok <= #1 Y;
    if (send_dok_off)
      dok <= #1 N;
    if (send_dok_on)
      dok <= #1 Y;
    end

  // Check: Verify that offs are only requested when on, and that ons are only requested when off.
  always @(posedge clk) begin
    if (rst_l && (send_aok_off && !aok || send_aok_on && aok)) begin
      $dispmon ("jbi_mout_jbi_j_pack_out_gen", 49, "%d %m: ERROR - Duplicate on/off being sent to AOK. (on=%b, off=%b, state=%b).", $time, send_aok_on, send_aok_off, aok);
      end
    if (rst_l && !send_dok_fatal && (send_dok_off && !dok || send_dok_on && dok)) begin
      $dispmon ("jbi_mout_jbi_j_pack_out_gen", 49, "%d %m: ERROR - Duplicate on/off being sent to DOK. (on=%b, off=%b, state=%b).", $time, send_dok_on, send_dok_off, dok);
      end
    end

  // Check: State machine has valid state.
  always @(posedge clk) begin
    if (next_state === DOK_X) begin
      $dispmon ("jbi_mout_jbi_j_pack_out_gen", 49, "%d %m: ERROR - J_PACK_OUT state machine is confused about its next transition. (%b)", $time, state);
      end
    end

  // synopsys translate_on
  // simtech modcovon -bpen

  endmodule


// Local Variables:
// verilog-library-directories:("." "../../include" "../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-auto-read-includes:t
// verilog-module-parents:("jbi_mout")
// End:
