// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_jbus_arb.v
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
// jbi_jbus_arb -- Distributed JBus Arbitration.
// _____________________________________________________________________________
//


`include "sys.h"
`include "jbi.h"


module jbi_jbus_arb (/*AUTOARG*/
  // Outputs
  multiple_ok, parked_on_us, jbi_io_j_req0_out_l, jbi_io_j_req0_out_en, grant, 
  mout_csr_err_arb_to, jbi_log_arb_jreq, mout_min_jbus_owner, jbi_io_j_adtype_en, jbi_io_j_ad_en, 
  jbi_io_j_adp_en, mout_dsbl_sampling, 
  // Inputs
  csr_jbi_config_arb_mode, int_req, multiple_in_progress, io_jbi_j_req4_in_l, 
  io_jbi_j_req5_in_l, stream_break_point, csr_jbi_arb_timeout_timeval, have_trans_waiting,
  piorqq_req, int_requestor_piorqq, clk, rst_l
  );

  // Configuration.
  input  [1:0] csr_jbi_config_arb_mode;		// Dead cycle control from Control and Status Register.

  // Internal requests.
  input        int_req;				// Internal JBus request.
  input        multiple_in_progress;		// Asserted after multiple_ok, multi-cycle packet going to output registers. Can't let request deassert.
  output       multiple_ok;			// Okay to drive a multiple cycle packet (for next cycle).
  output       parked_on_us;			// We have the bus and no-one else is requesting it.

  // External requests.
  input        io_jbi_j_req4_in_l;		// Registered JBus request 4.
  input        io_jbi_j_req5_in_l;		// Registered JBus request 5.
  output       jbi_io_j_req0_out_l;		// Request for JBus, to j_regs block.
  output       jbi_io_j_req0_out_en;		// Output enable for 'jbi_io_j_req0_out_l'.

  // Grant.
  input        stream_break_point;		// Allow streaming output to be interrupted.
  output       grant;				// Grant from Arbiter to drive packet on JBus.

  // CSRs and errors.
  output       mout_csr_err_arb_to;		// Report "Arbitration Timeout Error".
  input [31:0] csr_jbi_arb_timeout_timeval;	//    "Arbitration Timeout Error" timeout interval.
  input	       have_trans_waiting;		//    There is at least one transaction that needs to go to JBus (not AOK/DOK flow controlled).
  input        piorqq_req;			//    The PIORQQ has at least one entry in it.
  input	       int_requestor_piorqq;		//    When we get a JBus grant, send the trans in the PIORQQ.
  output [6:0] jbi_log_arb_jreq;		//    log J_REQs
  output [5:0] mout_min_jbus_owner;		// JBus owner (logged by min block into JBI_LOG_CTRL[OWNER] as source of data return).

  // I/O buffer enable for J_ADTYPE[], J_AD[], J_ADP[].
  output       jbi_io_j_adtype_en;		// Enable drive of J_AD[],J_ADP[], & J_ADTYPE[].
  output [3:0] jbi_io_j_ad_en;
  output       jbi_io_j_adp_en;
  output       mout_dsbl_sampling;		// Disable sampling JBus bidirs during dead cycle. Affects JBus input in jbi_min.

  // Clock and reset.
  input        clk;				// Input clock.
  input        rst_l;				// Synchronous reset.


  // Wires and Regs.
  wire arb_dead_cycle_no_sampling, arb_dead_cycle_sampling, arb_dead_cycles, arb_no_dead_cycles, force_off_int_req;
  wire grant_switch, hold_grant, int_driving_bus, int_req_in, io_jbi_j_req4_in, io_jbi_j_req5_in, j_req_othan;
  wire next_grant_switch_p1, next_int_req_in_p1, next_int_req_in_p2, arb_to;
  wire [2:0] req_in;
  wire [2:0] grants_p1;
  wire [31:0] arb_timeout_cntr;



  // Gate off the request for fairness when others are requesting JBus.
  assign int_req_in = (int_req || multiple_in_progress) && !force_off_int_req;


  // Register internal request 2 times to align it against external requests from I/O's.
  assign next_int_req_in_p1 = int_req_in;
  dff_ns int_req_in_p1_reg (.din(next_int_req_in_p1), .q(int_req_in_p1), .clk(clk));
  //
  assign next_int_req_in_p2 = int_req_in_p1;
  dff_ns int_req_in_p2_reg (.din(next_int_req_in_p2), .q(int_req_in_p2), .clk(clk));


  // Arbitration.
  //
  // Hold last grant as long as arbiter does not see a non-granted requestor.  Otherwise,
  // do round robin arbitration.
  assign io_jbi_j_req4_in = (~io_jbi_j_req4_in_l);
  assign io_jbi_j_req5_in = (~io_jbi_j_req5_in_l);
  assign req_in[2:0] = { io_jbi_j_req5_in, io_jbi_j_req4_in, int_req_in_p2 };
  //
  assign hold_grant = !((req_in[2] && !grants_p1[2]) || (req_in[1] && !grants_p1[1]) || (req_in[0] && !grants_p1[0]));
  //
  wire [2:0] grants;
  assign grants[0] = hold_grant? grants_p1[0]: (
    req_in[0] && (
      (grants_p1[2] && !(| { req_in[2], req_in[1] })) || 	// Priority = 2,1,0.
      (grants_p1[1] && !(| { req_in[1]            })) ||  	// Priority = 1,0,2.
      (grants_p1[0])						// Priority = 0,2,1.
    ));
  assign grants[1] = hold_grant? grants_p1[1]: (
    req_in[1] && (
      (grants_p1[0] && !(| { req_in[0], req_in[2] })) || 	// Priority = 0,2,1.
      (grants_p1[2] && !(| { req_in[2]            })) || 	// Priority = 2,1,0.
      (grants_p1[1])						// Priority = 1,0,2.
    ));
  assign grants[2] = hold_grant? grants_p1[2]: (
    req_in[2] && (
      (grants_p1[1] && !(| { req_in[1], req_in[0] })) || 	// Priority = 1,0,2.
      (grants_p1[0] && !(| { req_in[0]            })) ||  	// Priority = 0,2,1.
      (grants_p1[2])						// Priority = 2,1,0.
    ));


  // Remember who was last granted in 'grants_p1'.
  // On reset, initialize last granted to be us.
  wire [2:0] next_grants_p1 = grants;
  dffrl_ns #(2) grants_p1_reg  (.din(next_grants_p1[2:1]),   .q(grants_p1[2:1]),   .rst_l(rst_l), .clk(clk));
  dffsl_ns      grants_p1_reg0 (.din(next_grants_p1[0]),     .q(grants_p1[0]),     .set_l(rst_l), .clk(clk));


  // Arbiter mode CSR controls.
  wire [1:0] arb_mode_p1;
  wire [1:0] next_arb_mode_p1 = csr_jbi_config_arb_mode;
  dff_ns #(2) arb_mode_p1_reg (.din(next_arb_mode_p1), .q(arb_mode_p1), .clk(clk));
  // Defined modes.
  assign arb_dead_cycle_sampling =    (arb_mode_p1 == 2'b00);
  assign arb_dead_cycle_no_sampling = (arb_mode_p1 == 2'b01);
  assign arb_no_dead_cycles =         (arb_mode_p1 == 2'b10);
  // Derived modes.
  assign arb_dead_cycles = (arb_dead_cycle_sampling || arb_dead_cycle_no_sampling);


  // During dead cycle modes wait an extra cycle after a grant transition before claiming we got the grant.
  assign grant = grants[0] && (!arb_dead_cycles || grants_p1[0]);


  // Enable J_AD[], J_ADP[], J_ADTYPE[] output drivers.
  assign { jbi_io_j_adtype_en, jbi_io_j_ad_en, jbi_io_j_adp_en } = {6 {grant}};


  // Disable sampling during dead cycles when arb_mode = `b01.
  // (Note that "Disable when I'm Driving" is handled with OE in the iopads, not here)
  assign grant_switch = (| (grants[2:0] & ~grants_p1[2:0]));
  //
  assign next_grant_switch_p1 = grant_switch;
  dff_ns grant_switch_p1_reg (.din(next_grant_switch_p1), .q(grant_switch_p1), .clk(clk));
  //
  assign mout_dsbl_sampling = arb_dead_cycle_no_sampling && grant_switch_p1;


  // Mark when it is safe to send a multi-cycle transaction.
  assign multiple_ok  = grant && int_req_in_p1;

  // Notes when we will continue to own the bus.
  assign parked_on_us = grants_p1[0] && !j_req_othan;

  // We have to try and release the our internal request if we are streaming data and someone else wants the JBus.
  assign j_req_othan = (| req_in[2:1]);
  assign int_driving_bus = int_req_in_p2 && grant;
  assign force_off_int_req = int_driving_bus && j_req_othan && stream_break_point && !multiple_in_progress;


  // Send out the external request to the other distributed arbiters.
  assign jbi_io_j_req0_out_l = (~int_req_in);
  assign jbi_io_j_req0_out_en = 1'b1;


  // "Arbitration Timeout Error" counter.
  wire [31:0] next_arb_timeout_cntr = (arb_to)?  					32'b0:			  // Clear on Reported arb timeout, or ...
				      (!have_trans_waiting)?				32'b0:			  //          No transactions to send to JBus, or ...
				      (piorqq_req && grant && int_requestor_piorqq)?	32'b0:			  //          PioRQ has trans and we sent one, or ...
				      (!piorqq_req && grant)?				32'b0:			  //          No trans in PioRQ but we sent another trans.
											arb_timeout_cntr + 1'b1;  // Otherwise count.
  dffrl_ns #(32) arb_timeout_cntr_reg (.din(next_arb_timeout_cntr), .q(arb_timeout_cntr), .rst_l(rst_l), .clk(clk));
  //
  assign arb_to = (arb_timeout_cntr == csr_jbi_arb_timeout_timeval);
  wire 	 next_arb_to_p1 = arb_to;
  dff_ns arb_to_p1_reg (.din(next_arb_to_p1), .q(arb_to_p1), .clk(clk));
  assign mout_csr_err_arb_to = arb_to_p1 && !arb_to;		// Create an "Arbitration Timeout Error" pulse (edge detector).


  // "Arbitration Timeout Error" data to log.
  wire [6:0] next_jbi_log_arb_jreq = { 1'b0, io_jbi_j_req5_in, io_jbi_j_req4_in, 1'b0, 1'b0, 1'b0, int_req_in_p2 };
  dff_ns #(7) jbi_log_arb_jreq_reg (.din(next_jbi_log_arb_jreq), .q(jbi_log_arb_jreq), .clk(clk));


  // Bus owner information to min block for use in logging to JBI_LOG_CTRL[OWNER] the source of data return.
  assign mout_min_jbus_owner[5:0] = { grants_p1[2], grants_p1[1], 1'b0, 1'b0, 1'b0, grants_p1[0] };

  endmodule


// Local Variables:
// verilog-library-directories:("../../include" "../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-module-parents:("jbi_mout")
// End:
