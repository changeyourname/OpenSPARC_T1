/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: jbi_sct_out_queues.h
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
// jbi_sct_out_queues.h -- Include file for 'jbi_sct_out_queues' block.
// _____________________________________________________________________________
//


  // SCTAG Transaction Routing state machine  (jbi_sct_out_queues  'state')
  parameter IDLE          = { 2'b00, 4'b0000 };
  //					    
  parameter JBUS_RD16_D01 = { 2'b01, 4'b0000 };
  parameter JBUS_RD16_D02 = { 2'b01, 4'b0001 };
  parameter JBUS_RD16_D03 = { 2'b01, 4'b0010 };
  parameter JBUS_RD16_D04 = { 2'b01, 4'b0011 };
  parameter JBUS_RD16_D05 = { 2'b01, 4'b0100 };
  parameter JBUS_RD16_D06 = { 2'b01, 4'b0101 };
  parameter JBUS_RD16_D07 = { 2'b01, 4'b0110 };
  parameter JBUS_RD16_D08 = { 2'b01, 4'b0111 };
  parameter JBUS_RD16_D09 = { 2'b01, 4'b1000 };
  parameter JBUS_RD16_D10 = { 2'b01, 4'b1001 };
  parameter JBUS_RD16_D11 = { 2'b01, 4'b1010 };
  parameter JBUS_RD16_D12 = { 2'b01, 4'b1011 };
  parameter JBUS_RD16_D13 = { 2'b01, 4'b1100 };
  parameter JBUS_RD16_D14 = { 2'b01, 4'b1101 };
  parameter JBUS_RD16_D15 = { 2'b01, 4'b1110 };
  parameter JBUS_RD16_D16 = { 2'b01, 4'b1111 };
  //					    
  parameter JBUS_RD64_D01 = { 2'b10, 4'b0000 };
  parameter JBUS_RD64_D02 = { 2'b10, 4'b0001 };
  parameter JBUS_RD64_D03 = { 2'b10, 4'b0010 };
  parameter JBUS_RD64_D04 = { 2'b10, 4'b0011 };
  parameter JBUS_RD64_D05 = { 2'b10, 4'b0100 };
  parameter JBUS_RD64_D06 = { 2'b10, 4'b0101 };
  parameter JBUS_RD64_D07 = { 2'b10, 4'b0110 };
  parameter JBUS_RD64_D08 = { 2'b10, 4'b0111 };
  parameter JBUS_RD64_D09 = { 2'b10, 4'b1000 };
  parameter JBUS_RD64_D10 = { 2'b10, 4'b1001 };
  parameter JBUS_RD64_D11 = { 2'b10, 4'b1010 };
  parameter JBUS_RD64_D12 = { 2'b10, 4'b1011 };
  parameter JBUS_RD64_D13 = { 2'b10, 4'b1100 };
  parameter JBUS_RD64_D14 = { 2'b10, 4'b1101 };
  parameter JBUS_RD64_D15 = { 2'b10, 4'b1110 };
  parameter JBUS_RD64_D16 = { 2'b10, 4'b1111 };
  //					    
  parameter XXX           = { 2'bxx, 4'bxxxx };


  // SCTAG Incoming Transaction Type  (jbi_sct_out_queues 'trans_type')
  parameter TT_NONE =      2'b00;
  parameter TT_JBUS_WR =   2'b01;
  parameter TT_JBUS_RD16 = 2'b10;
  parameter TT_JBUS_RD64 = 2'b11;
  parameter TT_X =         2'bxx;


// Emacs parameters:
//   Local Variables:
//   mode: verilog
//   end:
