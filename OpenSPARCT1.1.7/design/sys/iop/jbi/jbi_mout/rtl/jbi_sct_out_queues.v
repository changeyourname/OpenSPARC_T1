// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_sct_out_queues.v
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
// jbi_sct_out_queues -- Outbound JBus Return Data queues from an SCTAG.
// _____________________________________________________________________________
//
// Design Notes:
//   o 'sctrdq_trans_count' synchronizer can support clock ratios up to 32:2.
// _____________________________________________________________________________

`include "sys.h"
`include "iop.h"
`include "jbi.h"


module jbi_sct_out_queues (/*AUTOARG*/
  // Outputs
  sctrdq_trans_count, sctrdq_data1_4, sctrdq_install_state, 
  sctrdq_unmapped_error, sctrdq_jid, sctrdq_data, sctrdq_ue_err, 
  mout_scb_jbus_wr_ack,
  // Inputs
  scbuf_jbi_data, scbuf_jbi_ctag_vld, scbuf_jbi_ue_err,
  sctrdq_dec_count, sctrdq_dequeue, testmux_sel, hold, rst_tri_en, cclk, crst_l, 
  clk, rst_l, tx_en_local_m1, arst_l
  );

  `include "jbi_mout.h"
  `include "jbi_sct_out_queues.h"

  // SCTAG/BUF Outbound Requests and Return Data (Cmp clock).
  input   [31:0] scbuf_jbi_data;
  input 	 scbuf_jbi_ctag_vld;			// Header cycle of a new response packet.
  input 	 scbuf_jbi_ue_err;			// Current data cycle has a uncorrectable error.

  // JBI Outbound Interface (JBus clock).
  output   [3:0] sctrdq_trans_count;
  output 	 sctrdq_data1_4;
  output         sctrdq_install_state;
  output         sctrdq_unmapped_error;
  output   [5:0] sctrdq_jid;
  output [127:0] sctrdq_data;
  output 	 sctrdq_ue_err;
  input		 sctrdq_dec_count;
  input		 sctrdq_dequeue;

  // Memory In (jbi_min) (Cmp clock).
  output 	 mout_scb_jbus_wr_ack;

  // Misc.
  input		 testmux_sel;				// Memory and ATPG test mode signal.
  input          hold;
  input          rst_tri_en;

  // Clock and reset.
  input		 cclk;					// CMP clock.
  input 	 crst_l;				// CMP clock domain reset.
  input 	 clk;					// JBus clock.
  input 	 rst_l;					// JBus clock domain reset.
  input 	 tx_en_local_m1;			// CMP to JBI clock domain crossing synchronization pulse.
  input 	 arst_l;				// Asynch reset.


  // Wires and Regs.
  wire  [5:0] state;
  wire 	[5:0] saved_jid;
  wire 	[3:0] inc_count_cntr, inc_count_cntr_presync, inc_count_cntr_sync;
  wire [31:0] scbuf_jbi_data_p1;
  reg 	      save_sctrdq_header, sctrdq_enqueue, sctrdq_inc_count, mout_scb_jbus_wr_ack, start_running_ue;
  reg 	[5:0] next_state;



  // Add last stage of distribution pipeline to 'tx_en'.
  dff_ns u_dff_ctu_jbi_tx_en_mout_ff     (.din(tx_en_local_m1),      .q(tx_en),                .clk(cclk));

  // Stage SC interface for timing reasons.
  dff_ns #(32) scbuf_jbi_data_p1_reg     (.din(scbuf_jbi_data),     .q(scbuf_jbi_data_p1),     .clk(cclk));
  dff_ns       scbuf_jbi_ctag_vld_p1_reg (.din(scbuf_jbi_ctag_vld), .q(scbuf_jbi_ctag_vld_p1), .clk(cclk));
  dff_ns       scbuf_jbi_ue_err_p1_reg   (.din(scbuf_jbi_ue_err),   .q(scbuf_jbi_ue_err_p1),   .clk(cclk));


  // Decode SCBUF header.
  wire  [1:0] critical_byte = scbuf_jbi_data_p1[`L2_BSC_CBA_HI:`L2_BSC_CBA_LO];
  wire        read_write    = scbuf_jbi_data_p1[`L2_BSC_READ];
  wire [11:0] tag           = scbuf_jbi_data_p1[`L2_BSC_CTAG_HI:`L2_BSC_CTAG_LO];


  // Break the 'tag' field down furthur.
  wire 	[1:0] tag_destination    = tag[`JBI_SCTAG_TAG_DEST_HI:`JBI_SCTAG_TAG_DEST_LO];
  wire 	      tag_read_write     = tag[`JBI_SCTAG_TAG_RW];
  wire 	      tag_subline        = tag[`JBI_SCTAG_TAG_SUBLINE];
  wire 	      tag_install_state  = tag[`JBI_SCTAG_TAG_INSTALL];
  wire 	      tag_unmapped_error = tag[`JBI_SCTAG_TAG_ERR];
  wire 	[5:0] tag_jid            = tag[`JBI_SCTAG_TAG_JID_HI:`JBI_SCTAG_TAG_JID_LO];


  // Determine the transaction type being sent by the SCBUF.
  wire [1:0] trans_type = (scbuf_jbi_ctag_vld_p1 && (tag_destination == `JBI_CTAG_PRE) && !read_write)?                TT_JBUS_WR:
                          (scbuf_jbi_ctag_vld_p1 && (tag_destination == `JBI_CTAG_PRE) && read_write && tag_subline)?  TT_JBUS_RD16:
                          (scbuf_jbi_ctag_vld_p1 && (tag_destination == `JBI_CTAG_PRE) && read_write && !tag_subline)? TT_JBUS_RD64:
				 										       TT_NONE;

  // SCBUF Transaction Routing state machine (initialize to IDLE).
  dffrl_ns #(6) state_reg  (.din(next_state[5:0]), .q(state[5:0]), .rst_l(crst_l), .clk(cclk));
  //
  always @(/*AS*/mout_scb_jbus_wr_ack
	   or next_state or save_sctrdq_header or sctrdq_enqueue
	   or sctrdq_inc_count or start_running_ue or state or trans_type) begin
    casex ({ state, trans_type })
      `define out { next_state, save_sctrdq_header, sctrdq_enqueue, sctrdq_inc_count, mout_scb_jbus_wr_ack, start_running_ue }
      //
      //                              ][                          save	            sctrdq   scb      start
      //                 trans        ][          next            sctrdq   sctrdq   inc      jbus     running
      // state           type         ][          state           header   enqueue  count    wr_ack   ue
      // -----------------------------++---------------------------------------------------------------------
      // IDLE - Waiting for transaction.						     
      {  IDLE,           TT_NONE      }: `out = { IDLE,           x,	   N,       N,       N,       x      };
      {    IDLE,         TT_JBUS_WR   }: `out = { IDLE,           x,	   N,       N,       Y,       x      };
      {    IDLE,         TT_JBUS_RD16 }: `out = { JBUS_RD16_D01,  Y,	   N,       N,       N,       x      };
      {    IDLE,         TT_JBUS_RD64 }: `out = { JBUS_RD64_D01,  Y,	   N,       N,       N,       x      };
								    			     
      // JBus Read Return Data 16 bytes.						     
      // Save Header; Bump transcount.  Write 4 w/ header and w/ ue.  Ignore last 12 cycles. 
      {  JBUS_RD16_D01,  TT_X         }: `out = { JBUS_RD16_D02,  N,	   Y,       N,       N,       Y      };
      {  JBUS_RD16_D02,  TT_X         }: `out = { JBUS_RD16_D03,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD16_D03,  TT_X         }: `out = { JBUS_RD16_D04,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD16_D04,  TT_X         }: `out = { JBUS_RD16_D05,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD16_D05,  TT_X         }: `out = { JBUS_RD16_D06,  N,	   N,       N,       N,       x      };
      {  JBUS_RD16_D06,  TT_X         }: `out = { JBUS_RD16_D07,  N,	   N,       N,       N,       x      };
      {  JBUS_RD16_D07,  TT_X         }: `out = { JBUS_RD16_D08,  N,	   N,       N,       N,       x      };
      {  JBUS_RD16_D08,  TT_X         }: `out = { JBUS_RD16_D09,  N,	   N,       N,       N,       x      };
      {  JBUS_RD16_D09,  TT_X         }: `out = { JBUS_RD16_D10,  N,	   N,       N,       N,       x      };
      {  JBUS_RD16_D10,  TT_X         }: `out = { JBUS_RD16_D11,  N,	   N,       N,       N,       x      };
      {  JBUS_RD16_D11,  TT_X         }: `out = { JBUS_RD16_D12,  N,	   N,       N,       N,       x      };
      {  JBUS_RD16_D12,  TT_X         }: `out = { JBUS_RD16_D13,  N,	   N,       N,       N,       x      };
      {  JBUS_RD16_D13,  TT_X         }: `out = { JBUS_RD16_D14,  N,	   N,       N,       N,       x      };
      {  JBUS_RD16_D14,  TT_X         }: `out = { JBUS_RD16_D15,  N,	   N,       N,       N,       x      };
      {  JBUS_RD16_D15,  TT_X         }: `out = { JBUS_RD16_D16,  N,	   N,       N,       N,       x      };
      {  JBUS_RD16_D16,  TT_X         }: `out = { IDLE,           N,	   N,       Y,       N,       x      };
											     
      //                              ][                          save	            sctrdq   scb      start
      //                 trans        ][          next            sctrdq   sctrdq   inc      jbus     running
      // state           type         ][          state           header   enqueue  count    wr_ack   ue
      // -----------------------------++---------------------------------------------------------------------
											     
      // JBus Read Return Data 64 bytes.						     
      // Save Header; Bump transcount.  Write 16 w/ header and w/ ue.			     
      {  JBUS_RD64_D01,  TT_X         }: `out = { JBUS_RD64_D02,  N,	   Y,       N,       N,       Y      };
      {  JBUS_RD64_D02,  TT_X         }: `out = { JBUS_RD64_D03,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD64_D03,  TT_X         }: `out = { JBUS_RD64_D04,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD64_D04,  TT_X         }: `out = { JBUS_RD64_D05,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD64_D05,  TT_X         }: `out = { JBUS_RD64_D06,  N,	   Y,       N,       N,       Y      };
      {  JBUS_RD64_D06,  TT_X         }: `out = { JBUS_RD64_D07,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD64_D07,  TT_X         }: `out = { JBUS_RD64_D08,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD64_D08,  TT_X         }: `out = { JBUS_RD64_D09,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD64_D09,  TT_X         }: `out = { JBUS_RD64_D10,  N,	   Y,       N,       N,       Y      };
      {  JBUS_RD64_D10,  TT_X         }: `out = { JBUS_RD64_D11,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD64_D11,  TT_X         }: `out = { JBUS_RD64_D12,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD64_D12,  TT_X         }: `out = { JBUS_RD64_D13,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD64_D13,  TT_X         }: `out = { JBUS_RD64_D14,  N,	   Y,       N,       N,       Y      };
      {  JBUS_RD64_D14,  TT_X         }: `out = { JBUS_RD64_D15,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD64_D15,  TT_X         }: `out = { JBUS_RD64_D16,  N,	   Y,       N,       N,       N      };
      {  JBUS_RD64_D16,  TT_X         }: `out = { IDLE,           N,	   Y,       Y,       N,       N      };
											     
// CoverMeter line_off
      default:				 `out = { XXX,            x,	   x,       x,       x,       x      };
// CoverMeter line_on
      `undef out
      endcase
    end


  // Saving the SCTRDQ header.
  // When 'save_sctrdq_header' is asserted, save the subline, install_state, and jid from the SCBUF.
  dffe_ns      saved_subline_reg        (.din(tag_subline),        .en(save_sctrdq_header), .q(saved_subline),        .clk(cclk));
  dffe_ns      saved_install_state_reg  (.din(tag_install_state),  .en(save_sctrdq_header), .q(saved_install_state),  .clk(cclk));
  dffe_ns      saved_unmapped_error_reg (.din(tag_unmapped_error), .en(save_sctrdq_header), .q(saved_unmapped_error), .clk(cclk));
  dffe_ns #(6) saved_jid_reg            (.din(tag_jid),            .en(save_sctrdq_header), .q(saved_jid),            .clk(cclk));


  // Running UE accumulator.
  // Create 'ue' signal by or'ing sequential 'scbuf_jbi_ue_err_p1' values from SCBUF.   Asserting 'start_running_ue'
  // will make "ue = scbuf_jbi_ue_err_p1".  Otherwise, it accumulates "ue = scbuf_jbi_ue_err_p1 || ue_p1".
  dffrl_ns ue_p1_reg (.din(ue), .q(ue_p1), .rst_l(crst_l), .clk(cclk));
  assign ue = (start_running_ue)? scbuf_jbi_ue_err_p1: scbuf_jbi_ue_err_p1 || ue_p1;


  // SCTAG Return Data Queue (SCTxRQQ).
  // 4 to 1 packing with header, 32 + 10 -> 128 + 10.  Write header last cycle, read first cycle.
  jbi_sctrdq  sctrdq (
    // Head of queue.
    .enqueue            (sctrdq_enqueue),
    .attr_in            ({ saved_subline, saved_install_state, saved_unmapped_error, saved_jid[5:0], ue }),
    .data_in            (scbuf_jbi_data_p1),
    .flush		(1'b0),
    .full               (sctrdq_full),
    .cclk		(cclk),
    .tx_en		(tx_en),
    .crst_l		(crst_l),

    // Tail of queue.
    .dequeue            (sctrdq_dequeue),
    .data_out           (sctrdq_data),
    .attr_out           ({ sctrdq_data1_4, sctrdq_install_state, sctrdq_unmapped_error, sctrdq_jid[5:0], sctrdq_ue_err }),
    .empty              (sctrdq_empty),
    .clk                (clk),
    .rst_l              (rst_l),

    // Misc.
    .hold		(hold),
    .testmux_sel	(testmux_sel),
    .rst_tri_en	        (rst_tri_en),
    .arst_l              (arst_l)
    );


  // SCTRDQ Transaction counter.
  //
  // Implemented as a up/down counter in the Jbus clock domain.  The 'sctrdq_inc_count'
  // is in the Cmp clock domain and may pulse multiple times before a Jbus clock.  So
  // it increments its own counter and this is passed between the clock domains to
  // update the SCTRDQ Transaction counter.  Can support clock ratios up to 32:2.
  //
  // 'inc_count_cntr' accumulates the 'sctrdq_inc_count' pulses.
  wire [3:0] next_inc_count_cntr = (sctrdq_inc_count)? (inc_count_cntr + 1'b1): inc_count_cntr;
  wire       inc_count_cntr_rst_l = ~(tx_en);
  dffrl_ns #(4) inc_count_cntr_reg (.din(next_inc_count_cntr), .q(inc_count_cntr), .rst_l(inc_count_cntr_rst_l), .clk(cclk));
  //
  // Synchonize 'inc_count_cntr' to the JBus clock domain (Cmp -> JBus).
  wire [3:0] next_inc_count_cntr_presync = next_inc_count_cntr;
  wire       inc_count_cntr_presync_en = tx_en;
  dffe_ns #(4) inc_count_cntr_presync_reg (.din(next_inc_count_cntr_presync), .en(inc_count_cntr_presync_en), .q(inc_count_cntr_presync), .clk(cclk));
  //
  wire [3:0] next_inc_count_cntr_sync = inc_count_cntr_presync;
  dff_ns #(4) inc_count_cntr_sync_reg (.din(next_inc_count_cntr_sync), .q(inc_count_cntr_sync), .clk(clk));
  //
  // Create the SCTRDQ Transaction counter 'sctrdq_trans_count'.
  wire [3:0] next_sctrdq_trans_count = (sctrdq_dec_count)? (sctrdq_trans_count + inc_count_cntr_sync - 1'b1): (sctrdq_trans_count + inc_count_cntr_sync);
  dffrl_ns #(4) sctrdq_trans_count_reg (.din(next_sctrdq_trans_count), .q(sctrdq_trans_count), .rst_l(rst_l), .clk(clk));



  // Monitors.

  // simtech modcovoff -bpen
  // synopsys translate_off

  // Check: State machine has valid state.
  always @(posedge clk) begin
    if (!(~rst_l) && next_state === XXX) begin
      $dispmon ("jbi_mout_jbi_sct_out_queues", 49, "%d %m: ERROR - No state asserted! (state=%b)", $time, state);
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
