// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncrd_timeout.v
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
// jbi_ncrd_timeout -- Determines transaction timeouts for out outstanding NCRD instructions on JBus.
// _____________________________________________________________________________
//

`include "sys.h"


module jbi_ncrd_timeout (/*AUTOARG*/
  // Outputs
  mout_nack, nack_error_id, mout_csr_err_read_to, 
  // Inputs
  ncrd_sent, ncrd_id, rtn_data_seen, rtn_data_id, ncio_mout_nack_pop, 
  csr_jbi_log_enb_read_to, trans_timeout_timeval, clk, rst_l
  );

  // NCRD Tracking.
  input		ncrd_sent;
  input   [3:0] ncrd_id;
  input		rtn_data_seen;
  input   [3:0] rtn_data_id;

  // Error reporting to jbi_min.
  output	mout_nack;
  output  [3:0] nack_error_id;
  input		ncio_mout_nack_pop;

  // CSR Interface.
  input 	csr_jbi_log_enb_read_to;
  output	mout_csr_err_read_to;

  // Clock and reset.
  input  [31:0] trans_timeout_timeval;	// tick counter interval.
  input		clk;
  input		rst_l;



  // Wires and Regs.
  wire tick, no_ncrds_outstanding, error_found;
  wire [15:0] error, busy, error_reported;
  wire [31:0] tick_cntr;
  wire [3:0] scrub_id;



  // Include functions: 4-to-16 Demultiplexer.
  `include "jbi_demux_4to16.v"



  // Tick counter.
  wire [31:0] next_tick_cntr = (tick || no_ncrds_outstanding)? 1'b0: tick_cntr + 1'b1;
  dffrl_ns #(32) tick_cntr_reg (.din(next_tick_cntr), .q(tick_cntr), .rst_l(rst_l), .clk(clk));
  assign tick = (tick_cntr >= trans_timeout_timeval);


  // 16 State machines.  One for each possible outstanding NCRD that we issue.
  wire [15:0] start = {16{ncrd_sent}} & jbi_demux_4to16(ncrd_id);
  wire [15:0] stopnclear = ({16{rtn_data_seen}} & jbi_demux_4to16(rtn_data_id)) | error_reported[15:0];

  //jbi_timer ncrd #(16) (
  //  .start		(start[15:0]),
  //  .stopnclear	(stopnclear[15:0]),
  //  .busy		(busy[15:0]),
  //  .error		(error[15:0]),
  //  .tick		(tick),
  //  .clk		(clk),
  //  .rst_l		(rst_l)
  //  );
  // (Needs a 'generate' statement badly.)
  jbi_timer ncrd_15 (.start(start[15]), .stopnclear(stopnclear[15]), .busy(busy[15]), .error(error[15]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_14 (.start(start[14]), .stopnclear(stopnclear[14]), .busy(busy[14]), .error(error[14]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_13 (.start(start[13]), .stopnclear(stopnclear[13]), .busy(busy[13]), .error(error[13]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_12 (.start(start[12]), .stopnclear(stopnclear[12]), .busy(busy[12]), .error(error[12]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_11 (.start(start[11]), .stopnclear(stopnclear[11]), .busy(busy[11]), .error(error[11]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_10 (.start(start[10]), .stopnclear(stopnclear[10]), .busy(busy[10]), .error(error[10]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_09 (.start(start[ 9]), .stopnclear(stopnclear[ 9]), .busy(busy[ 9]), .error(error[ 9]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_08 (.start(start[ 8]), .stopnclear(stopnclear[ 8]), .busy(busy[ 8]), .error(error[ 8]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_07 (.start(start[ 7]), .stopnclear(stopnclear[ 7]), .busy(busy[ 7]), .error(error[ 7]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_06 (.start(start[ 6]), .stopnclear(stopnclear[ 6]), .busy(busy[ 6]), .error(error[ 6]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_05 (.start(start[ 5]), .stopnclear(stopnclear[ 5]), .busy(busy[ 5]), .error(error[ 5]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_04 (.start(start[ 4]), .stopnclear(stopnclear[ 4]), .busy(busy[ 4]), .error(error[ 4]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_03 (.start(start[ 3]), .stopnclear(stopnclear[ 3]), .busy(busy[ 3]), .error(error[ 3]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_02 (.start(start[ 2]), .stopnclear(stopnclear[ 2]), .busy(busy[ 2]), .error(error[ 2]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_01 (.start(start[ 1]), .stopnclear(stopnclear[ 1]), .busy(busy[ 1]), .error(error[ 1]), .tick(tick), .clk(clk), .rst_l(rst_l));
  jbi_timer ncrd_00 (.start(start[ 0]), .stopnclear(stopnclear[ 0]), .busy(busy[ 0]), .error(error[ 0]), .tick(tick), .clk(clk), .rst_l(rst_l));

  assign no_ncrds_outstanding = (busy[15:0] == 16'b0);


  // Error reporting scrub machine.
  wire errors_to_report = (error[15:0] != 16'b0);
  wire [3:0] next_scrub_id = (!errors_to_report)?    1'b0:
			     (error_found)?          scrub_id:
	                                             scrub_id + 1'b1;
  dffrl_ns #(4) scrub_id_reg (.din(next_scrub_id), .q(scrub_id), .rst_l(rst_l), .clk(clk));
  assign error_found = |(jbi_demux_4to16(scrub_id) & error[15:0]);

  // Tell jbi_min block of error.
  wire next_mout_nack = error_found && csr_jbi_log_enb_read_to;
  dff_ns mout_nack_reg (.din(next_mout_nack), .q(mout_nack), .clk(clk));
  assign nack_error_id = scrub_id;

  // When jbi_min block acknowledges error, report to CSR logs.
  assign mout_csr_err_read_to = ncio_mout_nack_pop;

  // Clear the error.
  assign error_reported[15:0] = {16{ncio_mout_nack_pop}} & jbi_demux_4to16(scrub_id);


  endmodule


// Local Variables:
// verilog-library-directories:("." "../../../include")
// verilog-library-files:("../../../common/rtl/swrvr_clib.v")
// verilog-module-parents:("jbi_mout_csr")
// End:
