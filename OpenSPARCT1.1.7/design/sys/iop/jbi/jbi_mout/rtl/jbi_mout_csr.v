// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_mout_csr.v
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
// jbi_mout_csr -- CSR interface for errors and logging.
// _____________________________________________________________________________
//

`include "sys.h"

module jbi_mout_csr (/*AUTOARG*/
  // Outputs
  mout_port_4_present, mout_port_5_present, mout_csr_err_read_to, mout_nack, 
  nack_error_id, mout_csr_err_cpar, mout_csr_jbi_log_par_jpar,
  mout_csr_jbi_log_par_jpack0, mout_csr_jbi_log_par_jpack1, 
  mout_csr_jbi_log_par_jpack4, mout_csr_jbi_log_par_jpack5, 
  mout_csr_jbi_log_par_jreq, inj_err_j_ad, mout_min_inject_err_done, mout_csr_inject_output_done,
  // Inputs
  alloc, unused_jid, min_free, min_free_jid, trans_timeout_timeval,
  ncio_mout_nack_pop, csr_jbi_log_enb_read_to, j_par, j_req4_in_l_p1, j_req5_in_l_p1, j_req0_out_l_m1, 
  j_pack0_m1, j_pack1_m1, j_pack4_p1, j_pack5_p1,
  min_mout_inject_err, jbi_err_inject_xormask, jbi_err_inject_errtype,
  jbus_out_addr_cycle, jbus_out_data_cycle, clk, rst_l
  );

  // Port Present detection.
  output 	mout_port_4_present;
  output 	mout_port_5_present;

  // Transaction Timeout error detection.
  input          alloc;
  input    [3:0] unused_jid;
  input 	 min_free;
  input    [3:0] min_free_jid;
  input   [31:0] trans_timeout_timeval;
  output 	 mout_csr_err_read_to;
  output	 mout_nack;
  output   [3:0] nack_error_id;
  input		 ncio_mout_nack_pop;
  input 	 csr_jbi_log_enb_read_to;

  // J_PAR Error detection.
  input         j_par;
  input 	j_req4_in_l_p1;			// J_REQ_L signals.
  input 	j_req5_in_l_p1;			//
  input 	j_req0_out_l_m1;		//	(Always enabled so no qualifying is needed)
  input   [2:0] j_pack0_m1;			// J_PACK signals.	(Always enabled so no qualifying is needed)
  input   [2:0] j_pack1_m1;			//	(Always enabled so no qualifying is needed)
  input   [2:0] j_pack4_p1;			//
  input   [2:0] j_pack5_p1;			//
  output 	mout_csr_err_cpar;		// Reporting a Control Parity Error:
  output 	mout_csr_jbi_log_par_jpar;	//    J_PAR
  output  [2:0] mout_csr_jbi_log_par_jpack0;	//    J_PACK0
  output  [2:0] mout_csr_jbi_log_par_jpack1;	//    J_PACK1
  output  [2:0] mout_csr_jbi_log_par_jpack4;	//    J_PACK4
  output  [2:0] mout_csr_jbi_log_par_jpack5;	//    J_PACK5
  output  [6:0] mout_csr_jbi_log_par_jreq;	//    J_REQ[6:0]

  // JBus Error Injection control from JBI_ERR_INJECT.
  input 	min_mout_inject_err;		// Error injection request.
  input   [3:0] jbi_err_inject_xormask;		// Error injection bits (bit3=J_AD[96], bit2=J_AD[64], bit1=J_AD[32], bit0=J_AD[0]).
  input 	jbi_err_inject_errtype;		// Type of JBus cycle to count (1=Addr, 0=Data).
  input 	jbus_out_addr_cycle;		// jbi_pkt_ctrl reports that this is an address cycle.
  input 	jbus_out_data_cycle;		// jbi_pkt_ctrl reports that this is an data cycle.
  output  [3:0] inj_err_j_ad;			// Ask jbi_pktout_mux to inject an error on the J_AD[] (bit3=J_AD[96], bit2=J_AD[64], bit1=J_AD[32], bit0=J_AD[0]).
  output 	mout_min_inject_err_done;	// Tell the min block that we injected the error.
  output 	mout_csr_inject_output_done;	// Tell the csr block to clear the JBI_ERR_INJECT[INJECT_OUTPUT] bit.

  // Clock and reset.
  input		clk;
  input		rst_l;



  // Wires and Regs.
  wire inject_error_now;
  wire inject_err_p1;



  // Transaction Timeout error detection.
  jbi_ncrd_timeout ncrd_timeout (
    // NCRD Tracking.
    .ncrd_sent			(alloc),
    .ncrd_id			(unused_jid),
    .rtn_data_seen		(min_free),
    .rtn_data_id		(min_free_jid),

    // Error reporting to jbi_min.
    .mout_nack			(mout_nack),
    .nack_error_id		(nack_error_id),
    .ncio_mout_nack_pop		(ncio_mout_nack_pop),

    // CSR Interface.
    .csr_jbi_log_enb_read_to	(csr_jbi_log_enb_read_to),
    .mout_csr_err_read_to	(mout_csr_err_read_to),

    // Clock and reset.
    .trans_timeout_timeval	(trans_timeout_timeval),
    .clk			(clk),
    .rst_l			(rst_l)
    );


  // J_PAR Error detection.
  jbi_j_par_chk  j_par_chk (
    // J_PAR signal.
    .j_par_p1			(j_par),

    // J_REQ_L signals.
    .j_req4_in_l_p1		(j_req4_in_l_p1),
    .j_req5_in_l_p1		(j_req5_in_l_p1),
    .j_req0_out_l_m1		(j_req0_out_l_m1),

    // J_PACK signals.
    .j_pack0_m1			(j_pack0_m1),
    .j_pack1_m1			(j_pack1_m1),
    .j_pack4_p1			(j_pack4_p1),
    .j_pack5_p1			(j_pack5_p1),

    // Reporting a control parity error.
    .mout_csr_err_cpar		(mout_csr_err_cpar),
    .mout_csr_jbi_log_par_jpar	(mout_csr_jbi_log_par_jpar),
    .mout_csr_jbi_log_par_jpack0(mout_csr_jbi_log_par_jpack0),
    .mout_csr_jbi_log_par_jpack1(mout_csr_jbi_log_par_jpack1),
    .mout_csr_jbi_log_par_jpack4(mout_csr_jbi_log_par_jpack4),
    .mout_csr_jbi_log_par_jpack5(mout_csr_jbi_log_par_jpack5),
    .mout_csr_jbi_log_par_jreq	(mout_csr_jbi_log_par_jreq),

    // Port Present logic.
    .mout_port_4_present	(mout_port_4_present),
    .mout_port_5_present	(mout_port_5_present),

    // Clock and reset.
    .clk			(clk),
    .rst_l			(rst_l)
    );


  // JBus Error Injection control for JBI_ERR_INJECT.
  //
  // Register error injection request from min block for timing.
  wire set_err_req_p1 = min_mout_inject_err && !inject_err_p1;  // (Rising edge).
  wire clr_err_req_p1 = inject_error_now;
  srffrl_ns err_req_p1_reg (.set(set_err_req_p1), .clr(clr_err_req_p1), .q(err_req_p1), .rst_l(rst_l), .clk(clk));
  //
  wire   next_inject_err_p1 = min_mout_inject_err;
  dff_ns inject_err_p1_reg (.din(next_inject_err_p1), .q(inject_err_p1), .clk(clk));

  // On the correct driven addr/data cycle, inject the J_AD error.
  wire cycle_type_match = (jbi_err_inject_errtype)?  jbus_out_addr_cycle:  jbus_out_data_cycle;
  assign inject_error_now = err_req_p1 && cycle_type_match;
  assign inj_err_j_ad[3:0] =  jbi_err_inject_xormask[3:0] & {4{inject_error_now}};

  // Tell min block and CSRs that we did it.
  wire 	 next_inject_error_now_p1 = inject_error_now;
  dff_ns inject_error_now_p1_reg (.din(next_inject_error_now_p1), .q(inject_error_now_p1), .clk(clk));
  //
  assign mout_min_inject_err_done = inject_error_now_p1;
  assign mout_csr_inject_output_done = inject_error_now_p1;


  endmodule


// Local Variables:
// verilog-library-directories:("." "../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-module-parents:("jbi_mout")
// End:
