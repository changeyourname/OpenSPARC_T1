// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_pktout_ctlr.v
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
// jbi_pktout_ctlr -- JBus Packet Controller.
// _____________________________________________________________________________
//
// Design Notes:
//   o Request
//   o Grant - Parked
//   o Grant - Not Parked
//   o Grant - Stream
//   o Interrupting stream due to fairness
// _____________________________________________________________________________

`include "sys.h"


module jbi_pktout_ctlr (/*AUTOARG*/
  // Outputs
  multiple_in_progress, stream_break_point, int_granted, sct0rdq_dequeue, 
  sct1rdq_dequeue, sct2rdq_dequeue, sct3rdq_dequeue, piorqq_dequeue, 
  pioackq_dequeue, dbg_dequeue, mout_scb0_jbus_rd_ack, mout_scb1_jbus_rd_ack, 
  mout_scb2_jbus_rd_ack, mout_scb3_jbus_rd_ack, jbus_out_addr_cycle, 
  jbus_out_data_cycle, alloc, sel_j_adbus, sel_queue, 
  // Inputs
  grant, multiple_ok, int_req_type, int_requestors, ok_send_address_pkt, 
  ok_send_data_pkt_to_4, ok_send_data_pkt_to_5, clk, rst_l
  );

  `include "jbi_mout.h"
  `include "jbi_pktout_ctlr.h"

  // JBus Arbiter.
  input		 grant;
  output         multiple_in_progress;
  output         stream_break_point;

  // Internal Arbiter.
  input 	 multiple_ok;
  input    [3:0] int_req_type;
  input    [6:0] int_requestors;
  output         int_granted;
  
  // Flow Control.
  input 	 ok_send_address_pkt;
  input 	 ok_send_data_pkt_to_4;
  input 	 ok_send_data_pkt_to_5;

  // Queues.
  output 	 sct0rdq_dequeue;
  output 	 sct1rdq_dequeue;
  output 	 sct2rdq_dequeue;
  output 	 sct3rdq_dequeue;
  output 	 piorqq_dequeue;
  output 	 pioackq_dequeue;
  output 	 dbg_dequeue;

  // Status bits.
  output 	 mout_scb0_jbus_rd_ack;
  output 	 mout_scb1_jbus_rd_ack;
  output 	 mout_scb2_jbus_rd_ack;
  output 	 mout_scb3_jbus_rd_ack;
  output	 jbus_out_addr_cycle;
  output 	 jbus_out_data_cycle;

  // JID to PIO ID map.
  output         alloc;
  
  // J_ADTYPE, J_AD, J_ADP busses.
  output   [3:0] sel_j_adbus;
  output   [2:0] sel_queue;

  // Clock and reset.
  input		 clk;
  input		 rst_l;



  // Wires and Regs.
  wire 	[6:0] int_requestors_p1;
  wire 	[6:0] next_int_requestors_p1;
  wire  [2:0] state;
  wire  [6:0] sel_queue_demux;
  reg 	      alloc, dequeue, int_granted, multiple_in_progress, sel_use_last_req, stream_break_point, jbus_out_addr_cycle, jbus_out_data_cycle, rd_ack;
  reg   [2:0] sel_queue;
  reg 	[3:0] sel_j_adbus;
  reg   [2:0] next_state;




  // Packet assembly state machine (encoded, initialized to IDLE).
  dffrl_ns #(3) state_reg  (.din(next_state), .q(state), .rst_l(rst_l), .clk(clk));
  //
  always @(/*AS*/alloc or dequeue or grant or int_granted or int_req_type
	   or jbus_out_addr_cycle or jbus_out_data_cycle or multiple_in_progress
	   or multiple_ok or next_state or ok_send_address_pkt
	   or ok_send_data_pkt_to_4 or ok_send_data_pkt_to_5 or rd_ack
	   or sel_j_adbus or sel_use_last_req or state or stream_break_point) begin
    casex ({ state, grant, int_req_type, multiple_ok, ok_send_address_pkt, ok_send_data_pkt_to_4, ok_send_data_pkt_to_5 })
      `define out { next_state, sel_j_adbus, sel_use_last_req, dequeue, alloc, int_granted, multiple_in_progress, stream_break_point, jbus_out_addr_cycle, jbus_out_data_cycle, rd_ack }
      //
      //                                                                 ][                                    sel                                       jbus   jbus
      //                                             ok     ok     ok    ][                                    use                         mult   stream out    out       
      //                     int              multi  send   send   send  ][          next        sel           last          alloc  int    in     break  addr   data        
      // state        grant  req_type         ok     addr   data4  data5 ][          state       j_adbus       req    dq     jid    grant  prog   point  cycle  cycle  rd_ack   
      // ----------------------------------------------------------------++---------------------------------------------------------------------------------------------------
                                                                                                                                                                             
      {  IDLE,        N,     T_X,             x,     x,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NONE,          x,     x,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     Y,     N,     N,     N     };
      {    IDLE,      Y,     T_RD16,          x,     x,     x,     x     }: `out = { IDLE,       SEL_RD16,     N,     Y,     N,     Y,     N,     Y,     N,     Y,     Y     };
      {    IDLE,      Y,     T_RD64,          N,     x,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_RD64,          Y,     x,     x,     x     }: `out = { RD64_1,     SEL_RD64_0,   N,     Y,     N,     Y,     Y,     N,     N,     Y,     N     };
      {    IDLE,      Y,     T_NCRD,          x,     N,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NCRD,          x,     Y,     x,     x     }: `out = { IDLE,       SEL_NCRD,     N,     Y,     Y,     Y,     N,     Y,     Y,     N,     N     };
      {    IDLE,      Y,     T_NCWR0,         N,     x,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NCWR0,         x,     N,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NCWR0,         Y,     Y,     x,     x     }: `out = { NCWR_1,     SEL_NCWR_0,   N,     Y,     N,     Y,     N,     Y,     Y,     N,     N     };
      {    IDLE,      Y,     T_NCWR4,         N,     x,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NCWR4,         x,     N,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NCWR4,         x,     x,     N,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NCWR4,         Y,     Y,     Y,     x     }: `out = { NCWR_1,     SEL_NCWR_0,   N,     Y,     N,     Y,     N,     Y,     Y,     N,     N     };
      {    IDLE,      Y,     T_NCWR5,         N,     x,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NCWR5,         x,     N,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NCWR5,         x,     x,     x,     N     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NCWR5,         Y,     Y,     x,     Y     }: `out = { NCWR_1,     SEL_NCWR_0,   N,     Y,     N,     Y,     N,     Y,     Y,     N,     N     };
      {    IDLE,      Y,     T_NCWR_OTHER,    N,     x,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NCWR_OTHER,    x,     N,     x,     x     }: `out = { IDLE,       SEL_IDLE,     N,     N,     N,     N,     N,     N,     N,     N,     N     };
      {    IDLE,      Y,     T_NCWR_OTHER,    Y,     Y,     x,     x     }: `out = { NCWR_1,     SEL_NCWR_0,   N,     Y,     N,     Y,     N,     Y,     Y,     N,     N     };
      {    IDLE,      Y,     T_INTACK,        x,     x,     x,     x     }: `out = { IDLE,       SEL_INTACK,   N,     Y,     N,     Y,     N,     Y,     Y,     N,     N     };
      {    IDLE,      Y,     T_INTNACK,       x,     x,     x,     x     }: `out = { IDLE,       SEL_INTNACK,  N,     Y,     N,     Y,     N,     Y,     Y,     N,     N     };
      {    IDLE,      Y,     T_RDER,          x,     x,     x,     x     }: `out = { IDLE,       SEL_RDER,     N,     Y,     N,     Y,     N,     Y,     N,     Y,     Y     };
                                                                                                        		         	             	               
      // RD64 - Issue RD64 packet from SCTnRDQ.        				                 	             					               
      {  RD64_1,      x,     T_X,      	      x,     x,     x,     x     }: `out = { RD64_2,     SEL_RD64_1,   Y,     Y,     N,     N,     Y,     N,     N,     Y,     N     };
      {  RD64_2,      x,     T_X,      	      x,     x,     x,     x     }: `out = { RD64_3,     SEL_RD64_2,   Y,     Y,     N,     N,     N,     Y,     N,     Y,     N     };
      {  RD64_3,      x,     T_X,      	      x,     x,     x,     x     }: `out = { IDLE,       SEL_RD64_3,   Y,     Y,     N,     N,     N,     N,     N,     Y,     Y     };
					                                	       		 			         	                           
      // NCWR - Issue NCWR packet from PIO RQQ.	                 		       		          	             			               
      {  NCWR_1,      x,     T_X,      	      x,     x,     x,     x     }: `out = { IDLE,       SEL_NCWR_1,   Y,     Y,     N,     N,     N,     N,     N,     Y,     N     };
					                                	       		 			         	                           
// CoverMeter line_off
      default:								    `out = { XXXX,       SEL_X,        x,     x,     x,     x,     x,     x,     x,     x,     x     };
// CoverMeter line_on
      `undef out
      endcase
    end


  // Create the 'sel_queue_demux' mux select.
  assign sel_queue_demux = (sel_use_last_req)? int_requestors_p1: int_requestors;
  assign next_int_requestors_p1 = sel_queue_demux;
  dff_ns #(7) int_requestors_p1_reg (.din(next_int_requestors_p1), .q(int_requestors_p1), .clk(clk));


  // Create the individual queue dequeue signals.
  assign sct0rdq_dequeue = dequeue && sel_queue_demux[LRQ_SCT0RDQ_BIT];
  assign sct1rdq_dequeue = dequeue && sel_queue_demux[LRQ_SCT1RDQ_BIT];
  assign sct2rdq_dequeue = dequeue && sel_queue_demux[LRQ_SCT2RDQ_BIT];
  assign sct3rdq_dequeue = dequeue && sel_queue_demux[LRQ_SCT3RDQ_BIT];
  assign piorqq_dequeue  = dequeue && sel_queue_demux[LRQ_PIORQQ_BIT];
  assign pioackq_dequeue = dequeue && sel_queue_demux[LRQ_PIOACKQ_BIT];
  assign dbg_dequeue     = dequeue && sel_queue_demux[LRQ_DBGQ_BIT];


  // Create the individual 'mout_scb*_jbus_rd_ack' signals from 'rd_ack'.
  assign mout_scb0_jbus_rd_ack = rd_ack && sel_queue_demux[LRQ_SCT0RDQ_BIT];
  assign mout_scb1_jbus_rd_ack = rd_ack && sel_queue_demux[LRQ_SCT1RDQ_BIT];
  assign mout_scb2_jbus_rd_ack = rd_ack && sel_queue_demux[LRQ_SCT2RDQ_BIT];
  assign mout_scb3_jbus_rd_ack = rd_ack && sel_queue_demux[LRQ_SCT3RDQ_BIT];


  // Encode 'sel_queue_demux' into 'sel_queue'.
  always @(/*AS*/sel_queue_demux) begin
    case (1'b1)
      sel_queue_demux[LRQ_PIOACKQ_BIT]: sel_queue = LRQ_PIOACKQ;
      sel_queue_demux[LRQ_PIORQQ_BIT]:  sel_queue = LRQ_PIORQQ;
      sel_queue_demux[LRQ_SCT3RDQ_BIT]: sel_queue = LRQ_SCT3RDQ;
      sel_queue_demux[LRQ_SCT2RDQ_BIT]: sel_queue = LRQ_SCT2RDQ;
      sel_queue_demux[LRQ_SCT1RDQ_BIT]: sel_queue = LRQ_SCT1RDQ;
      sel_queue_demux[LRQ_SCT0RDQ_BIT]: sel_queue = LRQ_SCT0RDQ;
      sel_queue_demux[LRQ_DBGQ_BIT]:    sel_queue = LRQ_DBGQ;
      default:                          sel_queue = LRQ_NONE;
    endcase
  end



  // Monitors.

  // simtech modcovoff -bpen
  // synopsys translate_off

  // Check: 'grant' is asserted for states NCWR_1, RD64_1, RD64_2, and RD64_3.
  always @(posedge clk) begin
    if (!(~rst_l) && (state == NCWR_1 || state == RD64_1 || state == RD64_2 || state == RD64_3) && !grant) begin
      $dispmon ("jbi_mout_jbi_pktout_ctlr", 49, "%d %m: ERROR - Expected 'grant' to be asserted in state %b.", $time, state);
      end
    end

  // Check: State machine has valid state.
  always @(posedge clk) begin
    if (!(~rst_l) && next_state === XXXX) begin
      $dispmon ("jbi_mout_jbi_pktout_ctlr", 49, "%d %m: ERROR - No state asserted! (state=%b)", $time, state);
      end
    end

  // Check: sel_queue_demux does not have multiple bits set (will upset encoder).
  always @(posedge clk) begin
    if (!(~rst_l) && !(sel_queue_demux == 7'b000_0000 || sel_queue_demux == 7'b000_0001 || sel_queue_demux == 7'b000_0010 || 
		       sel_queue_demux == 7'b000_0100 || sel_queue_demux == 7'b000_1000 || sel_queue_demux == 7'b001_0000 ||
                       sel_queue_demux == 7'b010_0000 || sel_queue_demux == 7'b100_0000)) begin
      $dispmon ("jbi_mout_jbi_pktout_ctlr", 49, "%d %m: ERROR - sel_queue_demux has multiple bits set! (sel_queue_demux=%b)", $time, sel_queue_demux);
      end
    end

  // synopsys translate_on
  // simtech modcovon -bpen


  endmodule


// Local Variables:
// verilog-library-directories:("." "../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-auto-read-includes:t
// verilog-module-parents:("jbi_mout")
// End:
