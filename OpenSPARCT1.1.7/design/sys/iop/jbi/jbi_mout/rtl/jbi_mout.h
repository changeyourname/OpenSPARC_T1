/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: jbi_mout.h
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/
// _____________________________________________________________________________
// jbi_mout.h -- Include file for 'jbi_mout_*' blocks.
// _____________________________________________________________________________


// General
// -------
  //
  // Single bit values.  (jbi_bsctq, jbi_int_arb, jbi_j_pack_out_gen, jbi_pktout_ctlr, jbi_pktout_mux, jbi_sct_out_queues, jbi_sctrdq, jbi_snoop_out_queue)
  parameter T = 1'b1;
  parameter F = 1'b0;
  parameter Y = 1'b1;
  parameter N = 1'b0;
  parameter X = 1'bx;
  parameter x = 1'bx;


// jbi_snoop_out_queue
// -------------------
  parameter JBI_SNOOP_OUT_QUEUE_SIZE = 16;


// jbi_pktout_ctlr
// ---------------
  //
  // ADBUS mux selects (partial).  (jbi_pktout_ctlr -> jbi_pktout_mux)
  parameter SEL_IDLE    = 4'b0000;
  parameter SEL_INTACK  = 4'b0001;
  parameter SEL_INTNACK = 4'b0010;
  parameter SEL_NCRD    = 4'b0011;
  parameter SEL_NCWR_0  = 4'b0100;
  parameter SEL_NCWR_1  = 4'b0101;
  parameter SEL_RD16    = 4'b0110;
  parameter SEL_RD64_0  = 4'b0111;
  parameter SEL_RD64_1  = 4'b1000;
  parameter SEL_RD64_2  = 4'b1001;
  parameter SEL_RD64_3  = 4'b1010;
  parameter SEL_RDER    = 4'b1011;
  parameter SEL_X       = 4'bxxxx;


// jbi_int_arb
// -----------
  //
  // Internal requestors.  (jbi_int_arb -> jbi_pktout_ctlr, jbi_pktout_mux)
  // (Note: This encoding is referenced in JBI_LOG_ARB register description in the ERS document)
  parameter LRQ_NONE    = 3'h0;
  parameter LRQ_PIOACKQ = 3'h1,  LRQ_PIOACKQ_BIT = 3'h0;
  parameter LRQ_PIORQQ  = 3'h2,  LRQ_PIORQQ_BIT  = 3'h1;
  parameter LRQ_SCT3RDQ = 3'h3,  LRQ_SCT3RDQ_BIT = 3'h2;
  parameter LRQ_SCT2RDQ = 3'h4,  LRQ_SCT2RDQ_BIT = 3'h3;
  parameter LRQ_SCT1RDQ = 3'h5,  LRQ_SCT1RDQ_BIT = 3'h4;
  parameter LRQ_SCT0RDQ = 3'h6,  LRQ_SCT0RDQ_BIT = 3'h5;
  parameter LRQ_DBGQ    = 3'h7,  LRQ_DBGQ_BIT    = 3'h6;
  parameter LRQ_X       = 3'bx,  LRQ_X_BIT       = 3'hx;
  //
  // Internal requestor's type  (jbi_int_arb -> jbi_pktout_ctlr)
  // (Note: This encoding is referenced in JBI_LOG_ARB register description in the ERS document)
  parameter T_RD16       = 4'b0000;
  parameter T_RD64       = 4'b0001;
  parameter T_INTACK     = 4'b0010;
  parameter T_INTNACK    = 4'b0011;
  parameter T_NCRD       = 4'b0100;
  parameter T_NCWR0      = 4'b0101;
  parameter T_NCWR4      = 4'b0110;
  parameter T_NCWR5      = 4'b0111;
  parameter T_NCWR_OTHER = 4'b1000;
  parameter T_RDER       = 4'b1001;
  parameter T_NONE       = 4'b1010;
  parameter T_X          = 4'bxxxx;


// jbi_pktout_mux
// --------------
  //
  //  Read64 MOESI Install states.  (sctag/buf -> jbi_pktout_mux)
  parameter INSTALL_INVALID   = 3'b000;
  parameter INSTALL_SHARED    = 3'b001;
  parameter INSTALL_EXCLUSIVE = 3'b011;
  parameter INSTALL_OWNED     = 3'b101;
  parameter INSTALL_MODIFIED  = 3'b111;
  //
  //  JBus Transaction Types.  (jbi_pktout_mux)
  parameter TRANS_INTACK  = 5'h15;
  parameter TRANS_INTNACK = 5'h16;
  parameter TRANS_NCRD    = 5'h10;
  parameter TRANS_NCWR    = 5'h12;
  //
  // Read Data Error Cycle error types.
  parameter RDER_TIME_OUT  = 3'h0;
  parameter RDER_BUS_ERROR = 3'h1;
  parameter RDER_UNMAPPED  = 3'h2;




// Emacs parameters:
//   Local Variables:
//   mode: verilog
//   end:
