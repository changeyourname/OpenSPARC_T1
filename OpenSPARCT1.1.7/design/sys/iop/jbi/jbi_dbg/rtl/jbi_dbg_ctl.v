// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_dbg_ctl.v
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

module jbi_dbg_ctl(/*AUTOARG*/
// Outputs
dbg_req_transparent, dbg_req_arbitrate, dbg_req_priority, dbg_data, 
dbgq_hi_raddr, dbgq_hi_waddr, dbgq_hi_csn_wr, dbgq_hi_csn_rd, 
dbgq_hi_wdata, dbgq_lo_raddr, dbgq_lo_waddr, dbgq_lo_csn_wr, 
dbgq_lo_csn_rd, dbgq_lo_wdata, 
// Inputs
clk, rst_l, dbg_rst_l, iob_jbi_dbg_hi_vld, iob_jbi_dbg_hi_data, 
iob_jbi_dbg_lo_vld, iob_jbi_dbg_lo_data, csr_jbi_debug_arb_max_wait, 
csr_jbi_debug_arb_hi_water, csr_jbi_debug_arb_lo_water, 
csr_jbi_debug_arb_data_arb, csr_jbi_debug_arb_tstamp_wrap, 
csr_jbi_debug_arb_alternate, csr_jbi_debug_arb_alternate_set_l, 
mout_dbg_pop, dbgq_hi_rdata, dbgq_lo_rdata
);	//Enter the name of tne module
////////////////////////////////////////////////////////////////////////
// Interface signal list declarations
////////////////////////////////////////////////////////////////////////
input clk;
input rst_l;
input dbg_rst_l;

// IOB Interface
input iob_jbi_dbg_hi_vld;
input [47:0] iob_jbi_dbg_hi_data;
input 	     iob_jbi_dbg_lo_vld;
input [47:0] iob_jbi_dbg_lo_data;

// CSR Interface
input [`JBI_CSR_DBG_MAX_WAIT_WIDTH-1:0] csr_jbi_debug_arb_max_wait;
input [`JBI_CSR_DBG_HI_WATER_WIDTH-1:0] csr_jbi_debug_arb_hi_water;
input [`JBI_CSR_DBG_LO_WATER_WIDTH-1:0] csr_jbi_debug_arb_lo_water;
input 					csr_jbi_debug_arb_data_arb;
input [`JBI_CSR_DBG_TSWRAP_WIDTH-1:0] 	csr_jbi_debug_arb_tstamp_wrap;
input 					csr_jbi_debug_arb_alternate;
input 					csr_jbi_debug_arb_alternate_set_l;

// Memory Out (mout) Interface
input 					mout_dbg_pop;
output 					dbg_req_transparent;
output 					dbg_req_arbitrate;
output 					dbg_req_priority;
output [127:0] 				dbg_data;

// DBGQ Interface
input [`JBI_DBGQ_WIDTH-1:0] 		dbgq_hi_rdata;
input [`JBI_DBGQ_WIDTH-1:0] 		dbgq_lo_rdata;
output [`JBI_DBGQ_ADDR_WIDTH-1:0] 	dbgq_hi_raddr;
output [`JBI_DBGQ_ADDR_WIDTH-1:0] 	dbgq_hi_waddr;
output 					dbgq_hi_csn_wr;
output 					dbgq_hi_csn_rd;
output [`JBI_DBGQ_WIDTH-1:0] 		dbgq_hi_wdata;
output [`JBI_DBGQ_ADDR_WIDTH-1:0] 	dbgq_lo_raddr;
output [`JBI_DBGQ_ADDR_WIDTH-1:0] 	dbgq_lo_waddr;
output 					dbgq_lo_csn_wr;
output 					dbgq_lo_csn_rd;
output [`JBI_DBGQ_WIDTH-1:0] 		dbgq_lo_wdata;

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 					dbg_req_transparent;
wire 					dbg_req_arbitrate;
wire 					dbg_req_priority;
wire [127:0] 				dbg_data;
wire [`JBI_DBGQ_ADDR_WIDTH-1:0] 	dbgq_hi_raddr;
wire [`JBI_DBGQ_ADDR_WIDTH-1:0] 	dbgq_hi_waddr;
wire 					dbgq_hi_csn_wr;
wire 					dbgq_hi_csn_rd;
wire [`JBI_DBGQ_WIDTH-1:0] 		dbgq_hi_wdata;
wire [`JBI_DBGQ_ADDR_WIDTH-1:0] 	dbgq_lo_raddr;
wire [`JBI_DBGQ_ADDR_WIDTH-1:0] 	dbgq_lo_waddr;
wire 					dbgq_lo_csn_wr;
wire 					dbgq_lo_csn_rd;
wire [`JBI_DBGQ_WIDTH-1:0] 		dbgq_lo_wdata;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

wire [`JBI_CSR_DBG_TSWRAP_WIDTH-1:0] tstamp_lo;
wire [`JBI_DBG_TSTAMP_WIDTH-`JBI_CSR_DBG_TSWRAP_WIDTH-1:0] tstamp_hi;
wire 							   alternate_hi;
wire 							   dbgq_drain;
wire [9:0] 						   max_wait_cnt;
reg [`JBI_CSR_DBG_TSWRAP_WIDTH-1:0] 			   next_tstamp_lo;
reg [`JBI_DBG_TSTAMP_WIDTH-`JBI_CSR_DBG_TSWRAP_WIDTH-1:0]  next_tstamp_hi;
reg							   next_alternate_hi;
wire 							   next_dbgq_drain;
wire [9:0] 						   next_max_wait_cnt;

wire 							   max_wait_cnt_rst_l;
wire 							   max_wait_cnt_en;
wire 							   dbgq_drain_rst_l;
wire 							   alternate_hi_set_l;

wire 							   exceed_max_wait;
wire 							   dbgq_hi_empty;
wire 							   dbgq_lo_empty;
wire 							   dbgq_hi_full;
wire 							   dbgq_lo_full;
wire [63:0] 						   dbg_hi_data;
wire [63:0] 						   dbg_lo_data;
wire 							   dbgq_hi_push;
wire 							   dbgq_lo_push;
wire 							   dbgq_hi_overflow;
wire 							   dbgq_lo_overflow;
wire 							   dbgq_hi_prev_overflow;
wire 							   dbgq_lo_prev_overflow;
wire [`JBI_DBGQ_ADDR_WIDTH:0] 				   dbgq_hi_level;
wire [`JBI_DBGQ_ADDR_WIDTH:0] 				   dbgq_lo_level;
wire 							   dbgq_empty;
wire 							   dbgq_exceed_lo_water;
wire 							   dbgq_exceed_hi_water;

wire 							   iob_jbi_dbg_hi_vld_ff;
wire [47:0] 						   iob_jbi_dbg_hi_data_ff;
wire 							   iob_jbi_dbg_lo_vld_ff;
wire [47:0] 						   iob_jbi_dbg_lo_data_ff;

wire [`JBI_DBG_TSTAMP_WIDTH-1:0] 			   tstamp;

//
// Code start here 
//

//*******************************************************************************
// Basic Queue Control Block Instanstiations
//*******************************************************************************

/* jbi_dbg_ctl_qctl AUTO_TEMPLATE (
 .\(.*\) (dbgq_hi_\1),
 .clk (clk),
 .rst_l (rst_l),
 .pop (mout_dbg_pop),
 ); */

jbi_dbg_ctl_qctl u_hi_qctl (/*AUTOINST*/
			    // Outputs
			    .prev_overflow(dbgq_hi_prev_overflow), // Templated
			    .empty	(dbgq_hi_empty),	 // Templated
			    .full	(dbgq_hi_full),		 // Templated
			    .level	(dbgq_hi_level),	 // Templated
			    .waddr	(dbgq_hi_waddr),	 // Templated
			    .raddr	(dbgq_hi_raddr),	 // Templated
			    // Inputs
			    .clk	(clk),			 // Templated
			    .rst_l	(rst_l),		 // Templated
			    .pop	(mout_dbg_pop),		 // Templated
			    .push	(dbgq_hi_push),		 // Templated
			    .overflow	(dbgq_hi_overflow));	 // Templated
       
/* jbi_dbg_ctl_qctl AUTO_TEMPLATE (
 .\(.*\) (dbgq_lo_\1),
 .clk (clk),
 .rst_l (rst_l),
 .pop (mout_dbg_pop),

  ); */

jbi_dbg_ctl_qctl u_lo_qctl (/*AUTOINST*/
			    // Outputs
			    .prev_overflow(dbgq_lo_prev_overflow), // Templated
			    .empty	(dbgq_lo_empty),	 // Templated
			    .full	(dbgq_lo_full),		 // Templated
			    .level	(dbgq_lo_level),	 // Templated
			    .waddr	(dbgq_lo_waddr),	 // Templated
			    .raddr	(dbgq_lo_raddr),	 // Templated
			    // Inputs
			    .clk	(clk),			 // Templated
			    .rst_l	(rst_l),		 // Templated
			    .pop	(mout_dbg_pop),		 // Templated
			    .push	(dbgq_lo_push),		 // Templated
			    .overflow	(dbgq_lo_overflow));	 // Templated
       
//*******************************************************************************
// Timestamp
//*******************************************************************************

always @ ( /*AUTOSENSE*/csr_jbi_debug_arb_tstamp_wrap or tstamp_hi
	  or tstamp_lo) begin
   if (tstamp_lo == csr_jbi_debug_arb_tstamp_wrap) begin
      next_tstamp_lo = {`JBI_CSR_DBG_TSWRAP_WIDTH{1'b0}};
      next_tstamp_hi = tstamp_hi + 1'b1;
   end
   else begin
      next_tstamp_lo = tstamp_lo + 1'b1;
      next_tstamp_hi = tstamp_hi;
   end
end

assign tstamp = {tstamp_hi, tstamp_lo};

//*******************************************************************************
// Push Data into DBGQ
//*******************************************************************************

//-----------------------
// Alternate Mode
// - assume simultaneous hi_vld & lo_vld assertion in alternate mode
//-----------------------

assign alternate_hi_set_l = rst_l & csr_jbi_debug_arb_alternate_set_l;

always @ ( /*AUTOSENSE*/alternate_hi or csr_jbi_debug_arb_alternate
	  or iob_jbi_dbg_hi_vld_ff) begin
   if (csr_jbi_debug_arb_alternate & iob_jbi_dbg_hi_vld_ff)
      next_alternate_hi = ~alternate_hi;
   else
      next_alternate_hi = alternate_hi;
end

//-----------------------
// Hi Queue
//-----------------------

// Drop data if dbgq is full
assign dbgq_hi_push =   iob_jbi_dbg_hi_vld_ff 
		      & (~csr_jbi_debug_arb_alternate | alternate_hi)
                      & ~dbgq_hi_full;

assign dbgq_hi_csn_wr = ~dbgq_hi_push;
assign dbgq_hi_csn_rd = (dbgq_hi_waddr == dbgq_hi_raddr) & ~dbgq_hi_full;

assign dbgq_hi_overflow =  iob_jbi_dbg_hi_vld_ff 
                         & (~csr_jbi_debug_arb_alternate | alternate_hi)
                         & dbgq_hi_full;

assign dbgq_hi_wdata[`JBI_DBGQ_D_HI:`JBI_DBGQ_D_LO]         = iob_jbi_dbg_hi_data_ff[47:0];
assign dbgq_hi_wdata[`JBI_DBGQ_TSTMP_HI:`JBI_DBGQ_TSTMP_LO] = tstamp;
assign dbgq_hi_wdata[`JBI_DBGQ_DR]                          = dbgq_hi_prev_overflow;

//-----------------------
// Lo Queue
//-----------------------

// Drop data if dbgq is full
assign dbgq_lo_push =  iob_jbi_dbg_lo_vld_ff
                     & (~csr_jbi_debug_arb_alternate | ~alternate_hi)
                     & ~dbgq_lo_full;

assign dbgq_lo_csn_wr = ~dbgq_lo_push;
assign dbgq_lo_csn_rd = (dbgq_lo_waddr == dbgq_lo_raddr) & ~dbgq_lo_full;

assign dbgq_lo_overflow =  iob_jbi_dbg_lo_vld_ff
                         & (~csr_jbi_debug_arb_alternate | ~alternate_hi)
                         & dbgq_lo_full;

assign dbgq_lo_wdata[`JBI_DBGQ_D_HI:`JBI_DBGQ_D_LO]         = iob_jbi_dbg_lo_data_ff[47:0];
assign dbgq_lo_wdata[`JBI_DBGQ_TSTMP_HI:`JBI_DBGQ_TSTMP_LO] = tstamp;
assign dbgq_lo_wdata[`JBI_DBGQ_DR]                          = dbgq_lo_prev_overflow;

//*******************************************************************************
// Pop DBGQ
//*******************************************************************************

assign dbgq_empty =  dbgq_hi_empty & dbgq_lo_empty;

assign dbgq_exceed_lo_water =  dbgq_hi_level > {1'b0, csr_jbi_debug_arb_lo_water}
	                     | dbgq_lo_level > {1'b0, csr_jbi_debug_arb_lo_water};

assign dbgq_exceed_hi_water =  dbgq_hi_level > {1'b0, csr_jbi_debug_arb_hi_water}
	                     | dbgq_lo_level > {1'b0, csr_jbi_debug_arb_hi_water};

// Max Wait Count
assign max_wait_cnt_rst_l     = rst_l & ~dbgq_drain;
assign max_wait_cnt_en        =  ~dbgq_drain & ~dbgq_empty;
assign next_max_wait_cnt[9:0] = max_wait_cnt[9:0] + 1'b1;
assign exceed_max_wait        = max_wait_cnt == csr_jbi_debug_arb_max_wait[9:0];

// When exceed max wait, drain entire queue before waiting again
assign dbgq_drain_rst_l = rst_l & ~(dbgq_drain & dbgq_empty);
assign next_dbgq_drain  = dbgq_drain | exceed_max_wait;

// dbg_req_* are 1-hot
assign dbg_req_transparent  =  ~dbgq_empty
                             & ~dbgq_drain
                             & (  ~csr_jbi_debug_arb_data_arb
				| ~dbgq_exceed_lo_water);

assign dbg_req_arbitrate    =  ~dbgq_empty
                             & csr_jbi_debug_arb_data_arb
                             & dbgq_exceed_lo_water
                             & ~dbgq_exceed_hi_water
                             & ~dbgq_drain;

assign dbg_req_priority     =  ~dbgq_empty
                             & (  (csr_jbi_debug_arb_data_arb & dbgq_exceed_hi_water)
                                | dbgq_drain);

// Format Data   
assign dbg_hi_data = {  {4{1'b0}}, 
		        dbgq_hi_rdata[`JBI_DBGQ_DR],
		       ~dbgq_hi_empty, 
		        dbgq_hi_rdata[`JBI_DBGQ_TSTMP_HI:`JBI_DBGQ_TSTMP_LO],
			dbgq_hi_rdata[`JBI_DBGQ_D_HI:`JBI_DBGQ_D_LO] };

assign dbg_lo_data = {  {4{1'b0}}, 
		        dbgq_lo_rdata[`JBI_DBGQ_DR],
		       ~dbgq_lo_empty, 
		        dbgq_lo_rdata[`JBI_DBGQ_TSTMP_HI:`JBI_DBGQ_TSTMP_LO],
			dbgq_lo_rdata[`JBI_DBGQ_D_HI:`JBI_DBGQ_D_LO] };


assign dbg_data = { (dbg_hi_data & {64{~dbgq_hi_empty}}),   // drive zeros if queue is empty 
		    (dbg_lo_data & {64{~dbgq_lo_empty}}) };

//*******************************************************************************
// DFF Instantiations
//*******************************************************************************
dff_ns #(48) u_dff_iob_jbi_dbg_hi_data_ff
   (.din(iob_jbi_dbg_hi_data),
    .clk(clk),
    .q(iob_jbi_dbg_hi_data_ff) 
    );

dff_ns #(48) u_dff_iob_jbi_dbg_lo_data_ff
   (.din(iob_jbi_dbg_lo_data),
    .clk(clk),
    .q(iob_jbi_dbg_lo_data_ff) 
    );

//*******************************************************************************
// DFFR Instantiations
//*******************************************************************************

dffrl_ns #(1) u_dffrl_dbgq_drain
   (.din(next_dbgq_drain),
    .clk(clk),
    .rst_l(dbgq_drain_rst_l),
    .q(dbgq_drain) 
    );

dffrl_ns #(1) u_dffrl_iob_jbi_dbg_hi_vld_ff
   (.din(iob_jbi_dbg_hi_vld),
    .clk(clk),
    .rst_l(rst_l),
    .q(iob_jbi_dbg_hi_vld_ff) 
    );

dffrl_ns #(1) u_dffrl_iob_jbi_dbg_lo_vld_ff
   (.din(iob_jbi_dbg_lo_vld),
    .clk(clk),
    .rst_l(rst_l),
    .q(iob_jbi_dbg_lo_vld_ff) 
    );

dffrl_ns #(`JBI_CSR_DBG_TSWRAP_WIDTH) u_dffrl_tstamp_lo
   (.din(next_tstamp_lo),
    .clk(clk),
    .rst_l(dbg_rst_l),
    .q(tstamp_lo) 
    );

dffrl_ns #(`JBI_DBG_TSTAMP_WIDTH-`JBI_CSR_DBG_TSWRAP_WIDTH) u_dffrl_tstamp_hi
   (.din(next_tstamp_hi),
    .clk(clk),
    .rst_l(dbg_rst_l),
    .q(tstamp_hi) 
    );

//*******************************************************************************
// DFFSL Instantiations
//*******************************************************************************
dffsl_ns #(1) u_dffrl_alternate_hi
   (.din(next_alternate_hi),
    .clk(clk),
    .set_l(alternate_hi_set_l),
    .q(alternate_hi) 
    );

//*******************************************************************************
// DFFRLE Instantiations
//*******************************************************************************

dffrle_ns #(10) u_dffrle_max_wait_cnt
   (.din(next_max_wait_cnt),
    .clk(clk),
    .en(max_wait_cnt_en),
    .rst_l(max_wait_cnt_rst_l),
    .q(max_wait_cnt)
    );


//*******************************************************************************
// Rule Checks
//*******************************************************************************

//synopsys translate_off

always @ ( /*AUTOSENSE*/csr_jbi_debug_arb_alternate
	  or iob_jbi_dbg_hi_vld_ff or iob_jbi_dbg_lo_vld_ff) begin
   @clk;
   if (csr_jbi_debug_arb_alternate
       & (iob_jbi_dbg_hi_vld_ff ^ iob_jbi_dbg_lo_vld_ff))
      $dispmon ("jbi_dbg_ctl", 49, "%d %m: ERROR - DEBUG ALTERNATE MODE ON and iob_jbi_dbg_hi_vld!=iob_jbi_dbg_lo_vld",
		$time);
end


//synopsys translate_on


endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:

