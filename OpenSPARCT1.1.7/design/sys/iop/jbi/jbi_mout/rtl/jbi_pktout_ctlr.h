/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: jbi_pktout_ctlr.h
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
// jbi_pktout_ctlr.h -- Include file for 'jbi_pktout_ctlr' block.
// _____________________________________________________________________________


// jbi_pktout_ctlr
// ---------------

  //  States of outbound packet controller.  (jbi_pktout_ctlr 'state[]')
  parameter IDLE     = 3'b000;
  parameter RD64_1   = 3'b001;
  parameter RD64_2   = 3'b010;
  parameter RD64_3   = 3'b011;
  parameter NCWR_1   = 3'b100;
  parameter XXXX     = 3'bxxx;



// Emacs parameters:
//   Local Variables:
//   mode: verilog
//   end:
