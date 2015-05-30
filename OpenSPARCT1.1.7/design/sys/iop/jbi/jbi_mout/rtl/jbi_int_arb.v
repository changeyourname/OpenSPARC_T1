// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_int_arb.v
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
// jbi_int_arb -- Internal request collection to create a single, JBus arbiter request..
// _____________________________________________________________________________
//
// Description:
//   Flow control
//     Gates off individual requests as needed.  This prevents them from
//     getting grants.  It does not prevent in-progress multi-cycle transactions
//     from issuing dequeues to complete.
//   External request to the JBus Arbiter
//     The external request to the JBus Arbiter 'int_req', is asserted when
//     there exists any internal requests that is not being flow controlled.  To 
//     correctly assert the external request, it is important to know if there
//     is another request in a queue behind the current one that is being process.
//     Since a request may be multiple entries in a queue, simply looking for a valid
//     top-of-queue is inadaquate.
//   Tran_count is decremented on int_granted, not the queues dequeue signal.  This is
//     because the header and initial data quadword are together on the top-of-queue in some
//     queues.  Hence the header cannot be dequeued until the data is used on the next cycle.
//     So we won't get a dequeue when the header is consumed.
//
//   o No transactions can appear on the bus for 40 cycles after reset (JBus spec).
//     This will inherently not happen because the instruction fetch is to the separate
//     boot prom port.
//
//   o Single cycle transactions will not assert 'int_req' if the JBus is parked on us.
//
// _____________________________________________________________________________

`include "sys.h"
`include "jbi.h"


module jbi_int_arb (/*AUTOARG*/
  // Outputs
  sct0rdq_dec_count, sct1rdq_dec_count, sct2rdq_dec_count, sct3rdq_dec_count, 
  piorqq_req_adv, pioackq_req_adv, dbg_req_adv, int_req, have_trans_waiting, 
  int_requestors, int_req_type, jbi_log_arb_myreq, jbi_log_arb_reqtype, 
  // Inputs
  sct0rdq_data1_4, sct0rdq_trans_count, sct0rdq_ue_err, sct0rdq_unmapped_error, 
  sct1rdq_data1_4, sct1rdq_trans_count, sct1rdq_ue_err, sct1rdq_unmapped_error, 
  sct2rdq_data1_4, sct2rdq_trans_count, sct2rdq_ue_err, sct2rdq_unmapped_error, 
  sct3rdq_data1_4, sct3rdq_trans_count, sct3rdq_ue_err, sct3rdq_unmapped_error, 
  piorqq_req, piorqq_req_rw, piorqq_req_dest, pioackq_req, pioackq_ack_nack, 
  dbg_req_transparent, dbg_req_arbitrate, dbg_req_priority, int_granted, 
  parked_on_us, ok_send_address_pkt, ok_send_data_pkt_to_4, 
  ok_send_data_pkt_to_5, csr_jbi_debug_arb_aggr_arb, clk, rst_l
  );

  `include "jbi_mout.h"

  // SCT0 RDQ.
  input 	 sct0rdq_data1_4;            // If asserted, RD16 read return, else RD64 read return.
  input    [3:0] sct0rdq_trans_count;	     // Number of transactions in the queue.
  output         sct0rdq_dec_count;	     // When asserted, decrement the transactions count.
  input 	 sct0rdq_ue_err;	     // When asserted, data at top-of-queue has an Uncorrectable Error.
  input          sct0rdq_unmapped_error;     // State for cache to install the data or unmapped error flag.

  // SCT1 RDQ.
  input 	 sct1rdq_data1_4;            // If asserted, RD16 read return, else RD64 read return.
  input    [3:0] sct1rdq_trans_count;	     // Number of transactions in the queue.
  output         sct1rdq_dec_count;	     // When asserted, decrement the transactions count.
  input 	 sct1rdq_ue_err;	     // When asserted, data at top-of-queue has an Uncorrectable Error.
  input          sct1rdq_unmapped_error;     // State for cache to install the data or unmapped error flag.

  // SCT2 RDQ.
  input 	 sct2rdq_data1_4;            // If asserted, RD16 read return, else RD64 read return.
  input    [3:0] sct2rdq_trans_count;	     // Number of transactions in the queue.
  output         sct2rdq_dec_count;	     // When asserted, decrement the transactions count.
  input 	 sct2rdq_ue_err;	     // When asserted, data at top-of-queue has an Uncorrectable Error.
  input          sct2rdq_unmapped_error;     // State for cache to install the data or unmapped error flag.

  // SCT3 RDQ.
  input 	 sct3rdq_data1_4;            // If asserted, RD16 read return, else RD64 read return.
  input    [3:0] sct3rdq_trans_count;	     // Number of transactions in the queue.
  output         sct3rdq_dec_count;	     // When asserted, decrement the transactions count.
  input 	 sct3rdq_ue_err;	     // When asserted, data at top-of-queue has an Uncorrectable Error.
  input          sct3rdq_unmapped_error;     // State for cache to install the data or unmapped error flag.
  
  // PIO RQQ.
  input 	 piorqq_req;		     // The PIORQQ has a valid request.
  input 	 piorqq_req_rw;		     // If asserted, next request is read request, else it is a write request.
  input    [1:0] piorqq_req_dest;	     // If request is a write, this signal tell to which device (0 AID0, 1 AID4, 2 AID5, 3 AID Other).
  output         piorqq_req_adv;	     // When asserted, pop the transaction header from the PIORQQ_REQ queue.
  
  // PIO ACKQ.
  input          pioackq_req;		     // The PIOACKQ has a valid request.
  input          pioackq_ack_nack;           // If asserted, top-of-queue has an INT ACK request, else it is an INT NACK request.
  output         pioackq_req_adv;		     // When asserted, pop the transaction header from the PIOACKQ queue.

  // DEBUG ACKQ.
  input          dbg_req_transparent;	     // The Debug Info queue has valid request and wants it sent without impacting the JBus flow.
  input          dbg_req_arbitrate;	     // The Debug Info queue has valid request and wants fair round robin arbitration.
  input          dbg_req_priority;	     // The Debug Info queue has valid request and needs it sent right away.
  output         dbg_req_adv;		     // When asserted, pop the transaction header from the Debug Info queue.

  // JBus Arbiter.
  output 	 int_req;

  // Arb Timeout support.
  output 	 have_trans_waiting;         // There is at least one transaction that needs to go to JBus (not AOK/DOK flow controlled).

  // JBus Packet Controller.
  output   [6:0] int_requestors;	     // Current internal requestor (At most one bit of int_requestors[] is asserted at a time).
  output   [3:0] int_req_type;
  input 	 int_granted;
  input		 parked_on_us;

  // Flow Control.
  input 	 ok_send_address_pkt;
  input 	 ok_send_data_pkt_to_4;
  input 	 ok_send_data_pkt_to_5;

  // CSRs and errors.
  input 	 csr_jbi_debug_arb_aggr_arb; // AGGR_ARB bit of JBI_DEBUG_ARB register.
  output   [2:0] jbi_log_arb_myreq;	     // "Arbitration Timeout Error" data log, MYREQ
  output   [2:0] jbi_log_arb_reqtype;	     // "Arbitration Timeout Error" data log, REQTYPE.

  // Clock and reset.
  input		 clk;
  input		 rst_l;


  // Wires and Regs.
  wire [6:0] last_granted;
  reg  [3:0] int_req_type;



  // Forming the requests.
  wire [6:0] req_in;
  assign req_in[LRQ_SCT0RDQ_BIT] = (sct0rdq_trans_count != 1'b0);
  assign req_in[LRQ_SCT1RDQ_BIT] = (sct1rdq_trans_count != 1'b0);
  assign req_in[LRQ_SCT2RDQ_BIT] = (sct2rdq_trans_count != 1'b0);
  assign req_in[LRQ_SCT3RDQ_BIT] = (sct3rdq_trans_count != 1'b0);
  assign req_in[LRQ_PIORQQ_BIT]  = piorqq_req;
  assign req_in[LRQ_PIOACKQ_BIT] = pioackq_req;
  assign req_in[LRQ_DBGQ_BIT]    = (dbg_req_transparent && parked_on_us &&
	                             (!req_in[LRQ_SCT0RDQ_BIT] && !req_in[LRQ_SCT1RDQ_BIT] && !req_in[LRQ_SCT2RDQ_BIT] &&
				      !req_in[LRQ_SCT3RDQ_BIT] && !req_in[LRQ_PIORQQ_BIT]  && !req_in[LRQ_PIOACKQ_BIT])) ||
		                    dbg_req_arbitrate || dbg_req_priority;

  // Conditioning requests with AOK/DOK.
  wire [6:0] req_cond;
  assign req_cond[LRQ_SCT0RDQ_BIT] = req_in[LRQ_SCT0RDQ_BIT];
  assign req_cond[LRQ_SCT1RDQ_BIT] = req_in[LRQ_SCT1RDQ_BIT];
  assign req_cond[LRQ_SCT2RDQ_BIT] = req_in[LRQ_SCT2RDQ_BIT];
  assign req_cond[LRQ_SCT3RDQ_BIT] = req_in[LRQ_SCT3RDQ_BIT];
  assign req_cond[LRQ_PIORQQ_BIT]  = req_in[LRQ_PIORQQ_BIT] && (
    (piorqq_req_rw  && ok_send_address_pkt) ||										// NCRD requires AOK_ON.
    (!piorqq_req_rw && ok_send_address_pkt && (piorqq_req_dest == `JBI_PRQQ_DEST_4) && ok_send_data_pkt_to_4) ||  	// NCWR to AID 4 requires AOK_ON and DOK_ON(4).
    (!piorqq_req_rw && ok_send_address_pkt && (piorqq_req_dest == `JBI_PRQQ_DEST_5) && ok_send_data_pkt_to_5) ||  	// NCWR to AID 5 requires AOK_ON and DOK_ON(5).
    (!piorqq_req_rw && ok_send_address_pkt && (piorqq_req_dest == `JBI_PRQQ_DEST_0)) ||					// NCWR to AID 0 requires AOK_ON.
    (!piorqq_req_rw && ok_send_address_pkt && (piorqq_req_dest == `JBI_PRQQ_DEST_OTH))					// NCWR to AIDs 1,2,3,6, and 7 require AOK_ON.
    );
  assign req_cond[LRQ_PIOACKQ_BIT] = req_in[LRQ_PIOACKQ_BIT];
  assign req_cond[LRQ_DBGQ_BIT]    = req_in[LRQ_DBGQ_BIT];


  // Create the internal request signal to the JBus Arbiter.
  wire single_cycle_req = (int_req_type == T_RD16)    ||
                          (int_req_type == T_NCRD)    ||
                          (int_req_type == T_INTACK)  ||
                          (int_req_type == T_INTNACK);
  wire  no_req_needed = single_cycle_req && parked_on_us;
  assign int_req = ((| req_cond) && !no_req_needed) || csr_jbi_debug_arb_aggr_arb;


  // Internal Arbiter.
  //  
  // Two level arbiter.  First level is round-robin, no hold.  Second level
  // is priority to dbg queue when 'dbg_req_priority' asserted.
  //
  // First level arbiter (round-robin, no hold).
  // (Note: At most one bit of int_requestors[] is asserted at a time).
  wire [6:0] int_requestors_l1;
  assign int_requestors_l1[6] = req_cond[6] && (
      (last_granted[0]                                       ) ||
      (last_granted[1] && !(  { req_cond[  0]                })) ||
      (last_granted[2] && !(| { req_cond[1:0]                })) ||
      (last_granted[3] && !(| { req_cond[2:0]                })) ||
      (last_granted[4] && !(| { req_cond[3:0]                })) ||
      (last_granted[5] && !(| { req_cond[4:0]                })) ||
      (last_granted[6] && !(| { req_cond[5:0]                })));
  assign int_requestors_l1[5] = req_cond[5] && (
      (last_granted[6]                                       ) ||
      (last_granted[0] && !(  {                req_cond[6]   })) ||
      (last_granted[1] && !(| { req_cond[  0], req_cond[6]   })) ||
      (last_granted[2] && !(| { req_cond[1:0], req_cond[6]   })) ||
      (last_granted[3] && !(| { req_cond[2:0], req_cond[6]   })) ||
      (last_granted[4] && !(| { req_cond[3:0], req_cond[6]   })) ||
      (last_granted[5] && !(| { req_cond[4:0], req_cond[6]   })));
  assign int_requestors_l1[4] = req_cond[4] && (
      (last_granted[5]                                       ) ||
      (last_granted[6] && !(  {                req_cond[  5] })) ||
      (last_granted[0] && !(| {                req_cond[6:5] })) ||
      (last_granted[1] && !(| { req_cond[  0], req_cond[6:5] })) ||
      (last_granted[2] && !(| { req_cond[1:0], req_cond[6:5] })) ||
      (last_granted[3] && !(| { req_cond[2:0], req_cond[6:5] })) ||
      (last_granted[4] && !(| { req_cond[3:0], req_cond[6:5] })));
  assign int_requestors_l1[3] = req_cond[3] && (
      (last_granted[4]                                       ) ||
      (last_granted[5] && !(  {                req_cond[  4] })) ||
      (last_granted[6] && !(| {                req_cond[5:4] })) ||
      (last_granted[0] && !(| {                req_cond[6:4] })) ||
      (last_granted[1] && !(| { req_cond[  0], req_cond[6:4] })) ||
      (last_granted[2] && !(| { req_cond[1:0], req_cond[6:4] })) ||
      (last_granted[3] && !(| { req_cond[2:0], req_cond[6:4] })));
  assign int_requestors_l1[2] = req_cond[2] && (
      (last_granted[3]                                       ) ||
      (last_granted[4] && !(  {                req_cond[  3] })) ||
      (last_granted[5] && !(| {                req_cond[4:3] })) ||
      (last_granted[6] && !(| {                req_cond[5:3] })) ||
      (last_granted[0] && !(| {                req_cond[6:3] })) ||
      (last_granted[1] && !(| { req_cond[  0], req_cond[6:3] })) ||
      (last_granted[2] && !(| { req_cond[1:0], req_cond[6:3] })));
  assign int_requestors_l1[1] = req_cond[1] && (
      (last_granted[2]                                       ) ||
      (last_granted[3] && !(  {                req_cond[  2] })) ||
      (last_granted[4] && !(| {                req_cond[3:2] })) ||
      (last_granted[5] && !(| {                req_cond[4:2] })) ||
      (last_granted[6] && !(| {                req_cond[5:2] })) ||
      (last_granted[0] && !(| {                req_cond[6:2] })) ||
      (last_granted[1] && !(| { req_cond[  0], req_cond[6:2] })));
  assign int_requestors_l1[0] = req_cond[0] && (
      (last_granted[1]                                       ) ||
      (last_granted[2] && !(  {                req_cond[  1] })) ||
      (last_granted[3] && !(| {                req_cond[2:1] })) ||
      (last_granted[4] && !(| {                req_cond[3:1] })) ||
      (last_granted[5] && !(| {                req_cond[4:1] })) ||
      (last_granted[6] && !(| {                req_cond[5:1] })) ||
      (last_granted[0] && !(| {                req_cond[6:1] })));
  //
  // Second level arbitration (priority to dbg queue when 'dbg_req_priority' asserted).
  assign int_requestors = dbg_req_priority? (7'b000_0001 << LRQ_DBGQ_BIT): int_requestors_l1;


  // Track the last granted request 'last_granted' to aid the round-robin algorithm.
  wire [6:0] next_last_granted = int_requestors;
  wire       last_granted_en = int_granted;
  dffrle_ns #(6) last_granted_reg  (.din(next_last_granted[6:1]), .en(last_granted_en), .q(last_granted[6:1]), .rst_l(rst_l), .clk(clk));
  dffsle_ns      last_granted_reg0 (.din(next_last_granted[0]),   .en(last_granted_en), .q(last_granted[0]),   .set_l(rst_l), .clk(clk));

  
  // Determine the transaction type of the 'int_requestors'. 
  // (Note: At most one bit of int_requestors[] is asserted at a time).
  always @(/*AS*/int_requestors or pioackq_ack_nack or piorqq_req_dest
	   or piorqq_req_rw or sct0rdq_data1_4 or sct0rdq_ue_err
	   or sct0rdq_unmapped_error or sct1rdq_data1_4 or sct1rdq_ue_err
	   or sct1rdq_unmapped_error or sct2rdq_data1_4 or sct2rdq_ue_err
	   or sct2rdq_unmapped_error or sct3rdq_data1_4 or sct3rdq_ue_err
	   or sct3rdq_unmapped_error) begin
    case (1'b1)
      int_requestors[LRQ_SCT0RDQ_BIT]: int_req_type = (!sct0rdq_data1_4)?   T_RD64:   (sct0rdq_ue_err || sct0rdq_unmapped_error)? T_RDER:  T_RD16;	// SCT0 RDQ.
      int_requestors[LRQ_SCT1RDQ_BIT]: int_req_type = (!sct1rdq_data1_4)?   T_RD64:   (sct1rdq_ue_err || sct1rdq_unmapped_error)? T_RDER:  T_RD16;	// SCT1 RDQ.
      int_requestors[LRQ_SCT2RDQ_BIT]: int_req_type = (!sct2rdq_data1_4)?   T_RD64:   (sct2rdq_ue_err || sct2rdq_unmapped_error)? T_RDER:  T_RD16;	// SCT2 RDQ.
      int_requestors[LRQ_SCT3RDQ_BIT]: int_req_type = (!sct3rdq_data1_4)?   T_RD64:   (sct3rdq_ue_err || sct3rdq_unmapped_error)? T_RDER:  T_RD16;	// SCT3 RDQ.
      int_requestors[LRQ_PIORQQ_BIT]:  int_req_type = (piorqq_req_rw)?      T_NCRD:   (piorqq_req_dest == `JBI_PRQQ_DEST_0)? T_NCWR0:		   	// PIO RQQ.
                                                                                      (piorqq_req_dest == `JBI_PRQQ_DEST_4)? T_NCWR4:
				                                                      (piorqq_req_dest == `JBI_PRQQ_DEST_5)? T_NCWR5:
				                                                                                             T_NCWR_OTHER;
      int_requestors[LRQ_PIOACKQ_BIT]: int_req_type = (pioackq_ack_nack)?   T_INTACK: T_INTNACK;							// PIO ACKQ.
      int_requestors[LRQ_DBGQ_BIT]:    int_req_type = T_RD16;												// DEBUG INFO.
      default:                         int_req_type = T_NONE;
      endcase
    end


  // Decrement transaction counters.
  assign sct0rdq_dec_count = int_requestors[LRQ_SCT0RDQ_BIT] && int_granted;
  assign sct1rdq_dec_count = int_requestors[LRQ_SCT1RDQ_BIT] && int_granted;
  assign sct2rdq_dec_count = int_requestors[LRQ_SCT2RDQ_BIT] && int_granted;
  assign sct3rdq_dec_count = int_requestors[LRQ_SCT3RDQ_BIT] && int_granted;
  assign piorqq_req_adv    = int_requestors[LRQ_PIORQQ_BIT]  && int_granted;
  assign pioackq_req_adv   = int_requestors[LRQ_PIOACKQ_BIT] && int_granted;
  assign dbg_req_adv       = int_requestors[LRQ_DBGQ_BIT]    && int_granted;


  // "Arbitration Timeout Error" data to log.
  //
  // Encode the 'int_requestors' into 'jbi_log_arb_myreq'.
  reg [2:0] jbi_log_arb_myreq_m1;
  always @(/*AS*/int_requestors) begin
    case (1'b1)
      int_requestors[LRQ_PIORQQ_BIT]:  jbi_log_arb_myreq_m1 = 3'b001;	// PioReqQ
      int_requestors[LRQ_PIOACKQ_BIT]: jbi_log_arb_myreq_m1 = 3'b010;	// PioAckQ
      int_requestors[LRQ_SCT0RDQ_BIT]: jbi_log_arb_myreq_m1 = 3'b011;	// SCT0RdQ
      int_requestors[LRQ_SCT1RDQ_BIT]: jbi_log_arb_myreq_m1 = 3'b100;	// SCT1RdQ
      int_requestors[LRQ_SCT2RDQ_BIT]: jbi_log_arb_myreq_m1 = 3'b101;	// SCT2RdQ
      int_requestors[LRQ_SCT3RDQ_BIT]: jbi_log_arb_myreq_m1 = 3'b110;	// SCT3RdQ
      int_requestors[LRQ_DBGQ_BIT]:    jbi_log_arb_myreq_m1 = 3'b111;	// DbgQ
      default:                         jbi_log_arb_myreq_m1 = 3'b000;	// None or PioReqQ held by AOK/DOK flow control.
      endcase
    end
  wire [2:0] next_jbi_log_arb_myreq = jbi_log_arb_myreq_m1;
  dff_ns #(3) jbi_log_arb_myreq_reg (.din(next_jbi_log_arb_myreq), .q(jbi_log_arb_myreq), .clk(clk));
  //
  // Encode the 'int_requestors' into 'jbi_log_arb_reqtype'.
  reg [2:0] jbi_log_arb_reqtype_m1;
  always @(/*AS*/int_requestors or piorqq_req_dest or piorqq_req_rw) begin
    case (1'b1)
      int_requestors[LRQ_PIORQQ_BIT]:  jbi_log_arb_reqtype_m1 = (piorqq_req_rw)?		       3'b001:  // NCRD
								(piorqq_req_dest == `JBI_PRQQ_DEST_0)? 3'b100:  // NCWR to aid0
                                                                (piorqq_req_dest == `JBI_PRQQ_DEST_4)? 3'b101:  // NCWR to aid4
				                                (piorqq_req_dest == `JBI_PRQQ_DEST_5)? 3'b110:  // NCWR to aid5
				                                                                       3'b111;  // NCWR to aid-other
      default:                         jbi_log_arb_reqtype_m1 = 				       3'b000;	// Empty
      endcase
  end
  wire [2:0] next_jbi_log_arb_reqtype = jbi_log_arb_reqtype_m1;
  dff_ns #(3) jbi_log_arb_reqtype_reg (.din(next_jbi_log_arb_reqtype), .q(jbi_log_arb_reqtype), .clk(clk));


  // "Arbitration Timeout Error" counter support.
  assign have_trans_waiting = req_in[LRQ_SCT0RDQ_BIT] || req_in[LRQ_SCT1RDQ_BIT] || req_in[LRQ_SCT2RDQ_BIT] || req_in[LRQ_SCT3RDQ_BIT] ||
    req_in[LRQ_PIORQQ_BIT] || req_in[LRQ_PIOACKQ_BIT] || (req_in[LRQ_DBGQ_BIT] && !dbg_req_transparent);



  // Monitors.

  // simtech modcovoff -bpen
  // synopsys translate_off

  // Check: Exactly 1 bit is set in 'last_granted[]'.
  always @(posedge clk) begin
    if (rst_l && !(last_granted == 7'b000_0001 || last_granted == 7'b000_0010 || last_granted == 7'b000_0100 ||
                   last_granted == 7'b000_1000 || last_granted == 7'b001_0000 || last_granted == 7'b010_0000 ||
                   last_granted == 7'b100_0000)) begin
      $dispmon ("jbi_mout_jbi_int_arb", 49, "%d %m: ERROR - Exactly one bit must be set in 'last_granted[]' (%b).", $time, last_granted);
      end
    end

  // Check: At most one bit can be set in 'int_requestors[]'.
  always @(posedge clk) begin
    if (rst_l && !(int_requestors == 7'b000_0000 || 
      int_requestors == 7'b000_0001 || int_requestors == 7'b000_0010 || int_requestors == 7'b000_0100 ||
      int_requestors == 7'b000_1000 || int_requestors == 7'b001_0000 || int_requestors == 7'b010_0000 ||
      int_requestors == 7'b100_0000)) begin
      $dispmon ("jbi_mout_jbi_int_arb", 49, "%d %m: ERROR - At most one bit can be set in 'int_requestors[]' (%b).", $time, int_requestors);
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
