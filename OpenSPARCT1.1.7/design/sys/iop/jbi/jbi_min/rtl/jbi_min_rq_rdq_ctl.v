// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_rq_rdq_ctl.v
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
//  Description:	Request Header Queue Control
//  Top level Module:	jbi_min_rq_rdq_ctl
//  Where Instantiated:	jbi_min_rq
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "jbi.h"

module jbi_min_rq_rdq_ctl(/*AUTOARG*/
// Outputs
rdq_full, rdq_wr_en, rdq_rd_en, rdq_waddr, rdq_raddr, 
// Inputs
clk, rst_l, cpu_clk, cpu_rst_l, cpu_tx_en, cpu_rx_en, wdq_rdq_push, 
issue_rdq_pop
);

input clk;
input rst_l;

input cpu_clk;
input cpu_rst_l;
input cpu_tx_en;
input cpu_rx_en;

// WDQ Interface
input wdq_rdq_push;
output rdq_full;

// SCTAG Issue Interface
input issue_rdq_pop;

// Request Header Queue Interface
output rdq_wr_en;
output rdq_rd_en;
output [`JBI_RDQ_ADDR_WIDTH-1:0] rdq_waddr;
output [`JBI_RDQ_ADDR_WIDTH-1:0] rdq_raddr;

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 				 rdq_full;
wire 				 rdq_wr_en;
wire 				 rdq_rd_en;
wire [`JBI_RDQ_ADDR_WIDTH-1:0] 	 rdq_waddr;
wire [`JBI_RDQ_ADDR_WIDTH-1:0] 	 rdq_raddr;


////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

wire [`JBI_RDQ_ADDR_WIDTH:0] 	 rdq_wptr;
wire [`JBI_RDQ_ADDR_WIDTH:0] 	 rdq_rptr;
reg [`JBI_RDQ_ADDR_WIDTH:0] 	 next_rdq_wptr;
reg [`JBI_RDQ_ADDR_WIDTH:0] 	 next_rdq_rptr;
wire [`JBI_RDQ_ADDR_WIDTH:0] 	 tx_rdq_rptr;
wire [`JBI_RDQ_ADDR_WIDTH:0] 	 j_rdq_rptr;

wire 				 next_j_rdq_empty;
wire [`JBI_RDQ_ADDR_WIDTH:0] 	 next_free;
wire 				 next_rdq_full;

wire [`JBI_RDQ_ADDR_WIDTH:0] 	 rdq_wptr_d1;
wire [`JBI_RDQ_ADDR_WIDTH:0] 	 rdq_wptr_d2;

wire [`JBI_RDQ_ADDR_WIDTH:0] 	 c_rdq_wptr;

//
// Code start here 
//

//*******************************************************************************
// Push Header Queue (JBUS CLK)
//*******************************************************************************

//----------------------
// Pointer Management
//----------------------
always @ ( /*AUTOSENSE*/rdq_wptr or wdq_rdq_push) begin
   if (wdq_rdq_push)
      next_rdq_wptr = rdq_wptr + 1'b1;
   else
      next_rdq_wptr = rdq_wptr;
end

assign rdq_waddr  = rdq_wptr[`JBI_RDQ_ADDR_WIDTH-1:0];
assign rdq_wr_en = rst_l & wdq_rdq_push;


//*******************************************************************************
// Pop Header Queue (CPU  CLK)
//*******************************************************************************

always @ ( /*AUTOSENSE*/issue_rdq_pop or rdq_rptr) begin
   if (issue_rdq_pop)
      next_rdq_rptr = rdq_rptr + 1'b1;
   else
      next_rdq_rptr = rdq_rptr;
end

assign rdq_raddr = next_rdq_rptr[`JBI_RDQ_ADDR_WIDTH-1:0];
assign rdq_rd_en = next_rdq_rptr !=  c_rdq_wptr;

//*******************************************************************************
// Flow Control (JBUS CLK)
//*******************************************************************************
assign next_j_rdq_empty =  next_rdq_wptr == j_rdq_rptr;
assign next_free = j_rdq_rptr - next_rdq_wptr;
assign next_rdq_full = next_free[`JBI_RDQ_ADDR_WIDTH-1:0]  <  `JBI_RDQ_ADDR_WIDTH'd5
                      & ~next_j_rdq_empty;


//*******************************************************************************
// Synchronization DFFRLEs
//*******************************************************************************

//----------------------
// CPU -> JBUS
//----------------------
dffrle_ns #(`JBI_RDQ_ADDR_WIDTH+1) u_dffrle_tx_rdq_rptr
   (.din(rdq_rptr),
    .clk(cpu_clk),
    .en(cpu_tx_en),
    .rst_l(cpu_rst_l),
    .q(tx_rdq_rptr)
    );

dffrl_ns #(`JBI_RDQ_ADDR_WIDTH+1) u_dffrl_j_rdq_rptr
   (.din(tx_rdq_rptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(j_rdq_rptr)
    );

//----------------------
// JBUS -> CPU
//----------------------

dffrle_ns #(`JBI_RDQ_ADDR_WIDTH+1) u_dffrle_c_rdq_wptr
   (.din(rdq_wptr_d2),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_rdq_wptr)
    );


///*******************************************************************************
// DFF Instantiations
//*******************************************************************************
//----------------------
// JBUS CLK
//----------------------
dff_ns #(`JBI_RDQ_ADDR_WIDTH+1) u_dff_rdq_wptr_d1
   (.din(rdq_wptr),
    .clk(clk),
    .q(rdq_wptr_d1)
    );

dff_ns #(`JBI_RDQ_ADDR_WIDTH+1) u_dff_rdq_wptr_d2
   (.din(rdq_wptr_d1),
    .clk(clk),
    .q(rdq_wptr_d2)
    );

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************

//----------------------
// JBUS CLK
//----------------------
dffrl_ns #(`JBI_RDQ_ADDR_WIDTH+1) u_dffrl_rdq_wptr
   (.din(next_rdq_wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(rdq_wptr)
    );

dffrl_ns #(1) u_dffrl_rdq_full
   (.din(next_rdq_full),
    .clk(clk),
    .rst_l(rst_l),
    .q(rdq_full)
    );

//----------------------
// CPU CLK
//----------------------
dffrl_ns #(`JBI_RDQ_ADDR_WIDTH+1) u_dffrl_rdq_rptr
   (.din(next_rdq_rptr),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(rdq_rptr)
    );


//*******************************************************************************
// Rule Checks
//*******************************************************************************

//synopsys translate_off

wire rc_rdq_full =  rdq_wptr[`JBI_RDQ_ADDR_WIDTH]     != j_rdq_rptr[`JBI_RDQ_ADDR_WIDTH]
                 & rdq_wptr[`JBI_RDQ_ADDR_WIDTH-1:0] == j_rdq_rptr[`JBI_RDQ_ADDR_WIDTH-1:0];
wire rc_rdq_empty = c_rdq_wptr[`JBI_RDQ_ADDR_WIDTH:0] == rdq_rptr[`JBI_RDQ_ADDR_WIDTH:0];

always @ ( /*AUTOSENSE*/rc_rdq_full or wdq_rdq_push) begin
   @clk;
   if (rc_rdq_full && wdq_rdq_push)
      $dispmon ("jbi_min_rq_rdq_ctl", 49,"%d %m: ERROR - RDQ overflow!", $time);
end

always @ ( /*AUTOSENSE*/issue_rdq_pop or rc_rdq_empty) begin
   @cpu_clk;
   if (rc_rdq_empty && issue_rdq_pop)
      $dispmon ("jbi_min_rq_rdq_ctl", 49,"%d %m: ERROR - RDQ underflow!", $time);
end



//synopsys translate_on

endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
