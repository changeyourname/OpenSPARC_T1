// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_dbg_ctl_qctl.v
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
/////////////////////////////////////////////////////////////////////////
/*
//  Top level Module:	jbi_dbg_ctl
//  Where Instantiated:	jbi_dbg
//  Description:        Debug Port Queue Control logic	
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

module jbi_dbg_ctl_qctl(/*AUTOARG*/
// Outputs
prev_overflow, empty, full, level, waddr, raddr, 
// Inputs
clk, rst_l, pop, push, overflow
);	//Enter the name of tne module
////////////////////////////////////////////////////////////////////////
// Interface signal list declarations
////////////////////////////////////////////////////////////////////////
input clk;
input rst_l;

input pop;
input push;
input overflow;

output prev_overflow;
output empty;
output full;
output [`JBI_DBGQ_ADDR_WIDTH:0] level;
output [`JBI_DBGQ_ADDR_WIDTH-1:0] waddr;
output [`JBI_DBGQ_ADDR_WIDTH-1:0] raddr;

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 				prev_overflow;
wire 				empty;
wire 				full;
wire [`JBI_DBGQ_ADDR_WIDTH:0] 	level;
wire [`JBI_DBGQ_ADDR_WIDTH-1:0] waddr;
wire [`JBI_DBGQ_ADDR_WIDTH-1:0] raddr;


////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
wire [`JBI_DBGQ_ADDR_WIDTH:0] 	rptr;
wire [`JBI_DBGQ_ADDR_WIDTH:0] 	wptr;
reg [`JBI_DBGQ_ADDR_WIDTH:0] 	next_rptr;
reg [`JBI_DBGQ_ADDR_WIDTH:0] 	next_wptr;

wire 				next_prev_overflow;
reg [`JBI_DBGQ_ADDR_WIDTH:0] 	next_level;

wire 				prev_overflow_rst_l;
wire 				popq; 				
wire [`JBI_DBGQ_ADDR_WIDTH:0] 	wptr_d1;

//
// Code start here 
//

//*******************************************************************************
// Push Data into DBGQ
//*******************************************************************************
//--------------------
// Overflow Debug Bit
//  - set overflow bit when current push overflows dbgq
//  - clear overflow bit when after storing 
//--------------------

assign prev_overflow_rst_l = rst_l & ~push;
assign next_prev_overflow =  prev_overflow | overflow;

//----------------------
// Pointer Management
//----------------------
always @ ( /*AUTOSENSE*/push or wptr) begin
   if (push)
      next_wptr = wptr + 1'b1;
   else
      next_wptr = wptr;
end

assign empty = rptr == wptr_d1;

assign full =  wptr[`JBI_DBGQ_ADDR_WIDTH]     !=  rptr[`JBI_DBGQ_ADDR_WIDTH]
             & wptr[`JBI_DBGQ_ADDR_WIDTH-1:0] ==  rptr[`JBI_DBGQ_ADDR_WIDTH-1:0];

assign waddr  = wptr[`JBI_DBGQ_ADDR_WIDTH-1:0];

//*******************************************************************************
// Pop DBGQ
//*******************************************************************************

assign popq = pop & ~empty; //may be popping only hi or lo queue, not both

always @ ( /*AUTOSENSE*/popq or rptr) begin
   if (popq)
      next_rptr = rptr + 1'b1;
   else
      next_rptr = rptr;
end

assign raddr = next_rptr[`JBI_DBGQ_ADDR_WIDTH-1:0];

//*******************************************************************************
// Level
//*******************************************************************************

always @ ( /*AUTOSENSE*/level or popq or push) begin
   case ({push, popq}) // {incr, decr}
      2'b00,
      2'b11: next_level = level;
      2'b01: next_level = level - 1'b1;
      2'b10: next_level = level + 1'b1;
// CoverMeter line_off
      default: next_level = {`JBI_DBGQ_ADDR_WIDTH+1{1'bx}};
// CoverMeter line_on
   endcase
end

//*******************************************************************************
// DFF Instantiations
//*******************************************************************************
dff_ns #(`JBI_DBGQ_ADDR_WIDTH+1) u_dff_wptr_d1
   (.din(wptr),
    .clk(clk),
    .q(wptr_d1) 
    );

//*******************************************************************************
// DFFR Instantiations
//*******************************************************************************

dffrl_ns #(`JBI_DBGQ_ADDR_WIDTH+1) u_dffrl_rptr
   (.din(next_rptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(rptr) 
    );

dffrl_ns #(`JBI_DBGQ_ADDR_WIDTH+1) u_dffrl_wptr
   (.din(next_wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(wptr) 
    );

dffrl_ns #(`JBI_DBGQ_ADDR_WIDTH+1) u_dffrl_level
   (.din(next_level),
    .clk(clk),
    .rst_l(rst_l),
    .q(level) 
    );

dffrl_ns #(1) u_dffrl_prev_overflow
   (.din(next_prev_overflow),
    .clk(clk),
    .rst_l(prev_overflow_rst_l),
    .q(prev_overflow) 
    );

//*******************************************************************************
// Rule Checks
//*******************************************************************************

//synopsys translate_off

always @ ( /*AUTOSENSE*/full or push) begin
   @clk;
   if (full && push)
      $dispmon ("jbi_dbg_ctl_qctl", 49, "%d %m: ERROR - DBGQ overflow!", $time);
end

//synopsys translate_on


endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:

