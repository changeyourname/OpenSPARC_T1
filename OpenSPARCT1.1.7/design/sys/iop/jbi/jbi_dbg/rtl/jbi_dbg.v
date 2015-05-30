// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_dbg.v
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
//  Top level Module:	jbi_dbg
//  Where Instantiated:	jbi
//  Description:        Debug Block	
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "jbi.h"

module jbi_dbg (/*AUTOARG*/
// Outputs
dbg_req_transparent, dbg_req_arbitrate, dbg_req_priority, dbg_data, 
// Inputs
clk, rst_l, dbg_rst_l, hold, testmux_sel, scan_en, 
csr_16x65array_margin, csr_jbi_debug_arb_max_wait, 
csr_jbi_debug_arb_hi_water, csr_jbi_debug_arb_lo_water, 
csr_jbi_debug_arb_data_arb, csr_jbi_debug_arb_tstamp_wrap, 
csr_jbi_debug_arb_alternate, csr_jbi_debug_arb_alternate_set_l, 
iob_jbi_dbg_hi_data, iob_jbi_dbg_hi_vld, iob_jbi_dbg_lo_data, 
iob_jbi_dbg_lo_vld, mout_dbg_pop
);

input clk;
input rst_l;
input dbg_rst_l;
input hold;
input testmux_sel;
input scan_en;

// CSR Interface
input [4:0] csr_16x65array_margin;
input [`JBI_CSR_DBG_MAX_WAIT_WIDTH-1:0] csr_jbi_debug_arb_max_wait;
input [`JBI_CSR_DBG_HI_WATER_WIDTH-1:0] csr_jbi_debug_arb_hi_water;
input [`JBI_CSR_DBG_LO_WATER_WIDTH-1:0] csr_jbi_debug_arb_lo_water;
input 					csr_jbi_debug_arb_data_arb;
input [`JBI_CSR_DBG_TSWRAP_WIDTH-1:0] 	csr_jbi_debug_arb_tstamp_wrap;
input 					csr_jbi_debug_arb_alternate;
input 					csr_jbi_debug_arb_alternate_set_l;

// IOB Interface.
input [47:0] 				iob_jbi_dbg_hi_data;	
input 					iob_jbi_dbg_hi_vld;
input [47:0] 				iob_jbi_dbg_lo_data;	
input 					iob_jbi_dbg_lo_vld;

// Memory Out (mout) Interface
input 					mout_dbg_pop;
output 					dbg_req_transparent;
output 					dbg_req_arbitrate;
output 					dbg_req_priority;
output [127:0] 				dbg_data;

/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
// End of automatics

/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
// End of automatics

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire			dbgq_hi_csn_rd;		// From u_dbg_ctl of jbi_dbg_ctl.v
wire			dbgq_hi_csn_wr;		// From u_dbg_ctl of jbi_dbg_ctl.v
wire [`JBI_DBGQ_ADDR_WIDTH-1:0]dbgq_hi_raddr;	// From u_dbg_ctl of jbi_dbg_ctl.v
wire [`JBI_DBGQ_WIDTH-1:0]dbgq_hi_rdata;	// From u_dbg_buf of jbi_dbg_buf.v
wire [`JBI_DBGQ_ADDR_WIDTH-1:0]dbgq_hi_waddr;	// From u_dbg_ctl of jbi_dbg_ctl.v
wire [`JBI_DBGQ_WIDTH-1:0]dbgq_hi_wdata;	// From u_dbg_ctl of jbi_dbg_ctl.v
wire			dbgq_lo_csn_rd;		// From u_dbg_ctl of jbi_dbg_ctl.v
wire			dbgq_lo_csn_wr;		// From u_dbg_ctl of jbi_dbg_ctl.v
wire [`JBI_DBGQ_ADDR_WIDTH-1:0]dbgq_lo_raddr;	// From u_dbg_ctl of jbi_dbg_ctl.v
wire [`JBI_DBGQ_WIDTH-1:0]dbgq_lo_rdata;	// From u_dbg_buf of jbi_dbg_buf.v
wire [`JBI_DBGQ_ADDR_WIDTH-1:0]dbgq_lo_waddr;	// From u_dbg_ctl of jbi_dbg_ctl.v
wire [`JBI_DBGQ_WIDTH-1:0]dbgq_lo_wdata;	// From u_dbg_ctl of jbi_dbg_ctl.v
// End of automatics

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

//
// Code start here 
//

jbi_dbg_ctl u_dbg_ctl (/*AUTOINST*/
		       // Outputs
		       .dbg_req_transparent(dbg_req_transparent),
		       .dbg_req_arbitrate(dbg_req_arbitrate),
		       .dbg_req_priority(dbg_req_priority),
		       .dbg_data	(dbg_data[127:0]),
		       .dbgq_hi_raddr	(dbgq_hi_raddr[`JBI_DBGQ_ADDR_WIDTH-1:0]),
		       .dbgq_hi_waddr	(dbgq_hi_waddr[`JBI_DBGQ_ADDR_WIDTH-1:0]),
		       .dbgq_hi_csn_wr	(dbgq_hi_csn_wr),
		       .dbgq_hi_csn_rd	(dbgq_hi_csn_rd),
		       .dbgq_hi_wdata	(dbgq_hi_wdata[`JBI_DBGQ_WIDTH-1:0]),
		       .dbgq_lo_raddr	(dbgq_lo_raddr[`JBI_DBGQ_ADDR_WIDTH-1:0]),
		       .dbgq_lo_waddr	(dbgq_lo_waddr[`JBI_DBGQ_ADDR_WIDTH-1:0]),
		       .dbgq_lo_csn_wr	(dbgq_lo_csn_wr),
		       .dbgq_lo_csn_rd	(dbgq_lo_csn_rd),
		       .dbgq_lo_wdata	(dbgq_lo_wdata[`JBI_DBGQ_WIDTH-1:0]),
		       // Inputs
		       .clk		(clk),
		       .rst_l		(rst_l),
		       .dbg_rst_l	(dbg_rst_l),
		       .iob_jbi_dbg_hi_vld(iob_jbi_dbg_hi_vld),
		       .iob_jbi_dbg_hi_data(iob_jbi_dbg_hi_data[47:0]),
		       .iob_jbi_dbg_lo_vld(iob_jbi_dbg_lo_vld),
		       .iob_jbi_dbg_lo_data(iob_jbi_dbg_lo_data[47:0]),
		       .csr_jbi_debug_arb_max_wait(csr_jbi_debug_arb_max_wait[`JBI_CSR_DBG_MAX_WAIT_WIDTH-1:0]),
		       .csr_jbi_debug_arb_hi_water(csr_jbi_debug_arb_hi_water[`JBI_CSR_DBG_HI_WATER_WIDTH-1:0]),
		       .csr_jbi_debug_arb_lo_water(csr_jbi_debug_arb_lo_water[`JBI_CSR_DBG_LO_WATER_WIDTH-1:0]),
		       .csr_jbi_debug_arb_data_arb(csr_jbi_debug_arb_data_arb),
		       .csr_jbi_debug_arb_tstamp_wrap(csr_jbi_debug_arb_tstamp_wrap[`JBI_CSR_DBG_TSWRAP_WIDTH-1:0]),
		       .csr_jbi_debug_arb_alternate(csr_jbi_debug_arb_alternate),
		       .csr_jbi_debug_arb_alternate_set_l(csr_jbi_debug_arb_alternate_set_l),
		       .mout_dbg_pop	(mout_dbg_pop),
		       .dbgq_hi_rdata	(dbgq_hi_rdata[`JBI_DBGQ_WIDTH-1:0]),
		       .dbgq_lo_rdata	(dbgq_lo_rdata[`JBI_DBGQ_WIDTH-1:0]));

jbi_dbg_buf u_dbg_buf (/*AUTOINST*/
		       // Outputs
		       .dbgq_hi_rdata	(dbgq_hi_rdata[`JBI_DBGQ_WIDTH-1:0]),
		       .dbgq_lo_rdata	(dbgq_lo_rdata[`JBI_DBGQ_WIDTH-1:0]),
		       // Inputs
		       .clk		(clk),
		       .hold		(hold),
		       .testmux_sel	(testmux_sel),
		       .scan_en		(scan_en),
		       .csr_16x65array_margin(csr_16x65array_margin[4:0]),
		       .dbgq_hi_raddr	(dbgq_hi_raddr[`JBI_DBGQ_ADDR_WIDTH-1:0]),
		       .dbgq_lo_raddr	(dbgq_lo_raddr[`JBI_DBGQ_ADDR_WIDTH-1:0]),
		       .dbgq_hi_waddr	(dbgq_hi_waddr[`JBI_DBGQ_ADDR_WIDTH-1:0]),
		       .dbgq_lo_waddr	(dbgq_lo_waddr[`JBI_DBGQ_ADDR_WIDTH-1:0]),
		       .dbgq_hi_csn_wr	(dbgq_hi_csn_wr),
		       .dbgq_lo_csn_wr	(dbgq_lo_csn_wr),
		       .dbgq_hi_csn_rd	(dbgq_hi_csn_rd),
		       .dbgq_lo_csn_rd	(dbgq_lo_csn_rd),
		       .dbgq_hi_wdata	(dbgq_hi_wdata[`JBI_DBGQ_WIDTH-1:0]),
		       .dbgq_lo_wdata	(dbgq_lo_wdata[`JBI_DBGQ_WIDTH-1:0]));

endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
