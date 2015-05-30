// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_dbg_buf.v
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
//  Top level Module:	jbi_dbg_buf
//  Where Instantiated:	jbi_dbg
//  Description:        Debug Port Queue
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

module jbi_dbg_buf(/*AUTOARG*/
// Outputs
dbgq_hi_rdata, dbgq_lo_rdata, 
// Inputs
clk, hold, testmux_sel, scan_en, csr_16x65array_margin, 
dbgq_hi_raddr, dbgq_lo_raddr, dbgq_hi_waddr, dbgq_lo_waddr, 
dbgq_hi_csn_wr, dbgq_lo_csn_wr, dbgq_hi_csn_rd, dbgq_lo_csn_rd, 
dbgq_hi_wdata, dbgq_lo_wdata
);

////////////////////////////////////////////////////////////////////////
// Interface signal list declarations
////////////////////////////////////////////////////////////////////////
input clk;
input hold;
input testmux_sel;
input scan_en;

input [4:0] csr_16x65array_margin;

input [`JBI_DBGQ_ADDR_WIDTH-1:0] dbgq_hi_raddr;
input [`JBI_DBGQ_ADDR_WIDTH-1:0] dbgq_lo_raddr;
input [`JBI_DBGQ_ADDR_WIDTH-1:0] dbgq_hi_waddr;
input [`JBI_DBGQ_ADDR_WIDTH-1:0] dbgq_lo_waddr;
input 				 dbgq_hi_csn_wr;
input 				 dbgq_lo_csn_wr;
input 				 dbgq_hi_csn_rd;
input 				 dbgq_lo_csn_rd;
input [`JBI_DBGQ_WIDTH-1:0] 	 dbgq_hi_wdata;
input [`JBI_DBGQ_WIDTH-1:0] 	 dbgq_lo_wdata;

output [`JBI_DBGQ_WIDTH-1:0] 	 dbgq_hi_rdata;
output [`JBI_DBGQ_WIDTH-1:0] 	 dbgq_lo_rdata;

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
reg [`JBI_DBGQ_WIDTH-1:0] 	 dbgq_hi_rdata;
reg [`JBI_DBGQ_WIDTH-1:0] 	 dbgq_lo_rdata;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
wire 				 dbgq_hi_csn_wr0;
wire 				 dbgq_hi_csn_wr1;
wire [`JBI_DBGQ_WIDTH-1:0] 	 dbgq_hi_rdata0;
wire [`JBI_DBGQ_WIDTH-1:0] 	 dbgq_hi_rdata1;
wire 				 dbgq_hi_rdata_sel;
wire 				 next_dbgq_hi_rdata_sel;

wire 				 dbgq_lo_csn_wr0;
wire 				 dbgq_lo_csn_wr1;
wire [`JBI_DBGQ_WIDTH-1:0] 	 dbgq_lo_rdata0;
wire [`JBI_DBGQ_WIDTH-1:0] 	 dbgq_lo_rdata1;
wire 				 dbgq_lo_rdata_sel;
wire 				 next_dbgq_lo_rdata_sel;

wire [65-`JBI_DBGQ_WIDTH-1:0] 	 dangle_hi0;
wire [65-`JBI_DBGQ_WIDTH-1:0] 	 dangle_hi1;
wire [65-`JBI_DBGQ_WIDTH-1:0] 	 dangle_lo0;
wire [65-`JBI_DBGQ_WIDTH-1:0] 	 dangle_lo1;


//*******************************************************************************
// DBG HI
//*******************************************************************************

assign dbgq_hi_csn_wr0 = ~(~dbgq_hi_csn_wr & ~dbgq_hi_waddr[`JBI_DBGQ_ADDR_WIDTH-1]);
assign dbgq_hi_csn_wr1 = ~(~dbgq_hi_csn_wr &  dbgq_hi_waddr[`JBI_DBGQ_ADDR_WIDTH-1]);

assign next_dbgq_hi_rdata_sel = dbgq_hi_raddr[`JBI_DBGQ_ADDR_WIDTH-1];

always @ ( /*AUTOSENSE*/dbgq_hi_rdata0 or dbgq_hi_rdata1
	  or dbgq_hi_rdata_sel) begin
   if (dbgq_hi_rdata_sel)
      dbgq_hi_rdata = dbgq_hi_rdata1;
   else
      dbgq_hi_rdata = dbgq_hi_rdata0;
end


bw_rf_16x65 #(1, 1, 1, 0) u_dbg_hi_buf0
   (.rd_clk(clk),             // read clock
    .wr_clk(clk),             // read clock
    .csn_rd(dbgq_hi_csn_rd),  // read enable -- active low 
    .csn_wr(dbgq_hi_csn_wr0),  // write enable -- active low
    .hold(hold),              // Bypass signal -- unflopped -- bypass input data when 0
    .scan_en(scan_en),        // Scan enable unflopped
    .margin(csr_16x65array_margin),     // Delay for the circuits--- set to 10101 
    .rd_a(dbgq_hi_raddr[`JBI_DBGQ_ADDR_WIDTH-2:0]),     // read address  
    .wr_a(dbgq_hi_waddr[`JBI_DBGQ_ADDR_WIDTH-2:0]),     // Write address
    .di({ {65-`JBI_DBGQ_WIDTH{1'b0}},
	  dbgq_hi_wdata[`JBI_DBGQ_WIDTH-1:0] }),       // Data input
    .testmux_sel(testmux_sel), // bypass  signal -- unflopped -- testmux_sel = 1 bypasses di to do 
    .si(),        // scan in  -- NOT CONNECTED
    .so(),        // scan out -- TIED TO ZERO 
    .listen_out(), // Listening flop-- 
    .do( {dangle_hi0,
	  dbgq_hi_rdata0[`JBI_DBGQ_WIDTH-1:0]} )         // Data out
    );

bw_rf_16x65 #(1, 1, 1, 0) u_dbg_hi_buf1
   (.rd_clk(clk),             // read clock
    .wr_clk(clk),             // read clock
    .csn_rd(dbgq_hi_csn_rd),  // read enable -- active low 
    .csn_wr(dbgq_hi_csn_wr1),  // write enable -- active low
    .hold(hold),              // Bypass signal -- unflopped -- bypass input data when 0
    .scan_en(scan_en),        // Scan enable unflopped
    .margin(csr_16x65array_margin),     // Delay for the circuits--- set to 10101 
    .rd_a(dbgq_hi_raddr[`JBI_DBGQ_ADDR_WIDTH-2:0]),     // read address  
    .wr_a(dbgq_hi_waddr[`JBI_DBGQ_ADDR_WIDTH-2:0]),     // Write address
    .di({ {65-`JBI_DBGQ_WIDTH{1'b0}},
	  dbgq_hi_wdata[`JBI_DBGQ_WIDTH-1:0] }),       // Data input
    .testmux_sel(testmux_sel), // bypass  signal -- unflopped -- testmux_sel = 1 bypasses di to do 
    .si(),        // scan in  -- NOT CONNECTED
    .so(),        // scan out -- TIED TO ZERO 
    .listen_out(), // Listening flop-- 
    .do( {dangle_hi1,
	  dbgq_hi_rdata1[`JBI_DBGQ_WIDTH-1:0]} )         // Data out
    );

dff_ns #(1) u_dff_dbgq_hi_rdata_sel
   (.din(next_dbgq_hi_rdata_sel),
    .clk(clk),
    .q(dbgq_hi_rdata_sel)
    );

//*******************************************************************************
// DBG HI
//*******************************************************************************

assign dbgq_lo_csn_wr0 = ~(~dbgq_lo_csn_wr & ~dbgq_lo_waddr[`JBI_DBGQ_ADDR_WIDTH-1]);
assign dbgq_lo_csn_wr1 = ~(~dbgq_lo_csn_wr &  dbgq_lo_waddr[`JBI_DBGQ_ADDR_WIDTH-1]);

assign next_dbgq_lo_rdata_sel = dbgq_lo_raddr[`JBI_DBGQ_ADDR_WIDTH-1];

always @ ( /*AUTOSENSE*/dbgq_lo_rdata0 or dbgq_lo_rdata1
	  or dbgq_lo_rdata_sel) begin
   if (dbgq_lo_rdata_sel)
      dbgq_lo_rdata = dbgq_lo_rdata1;
   else
      dbgq_lo_rdata = dbgq_lo_rdata0;
end


bw_rf_16x65 #(1, 1, 1, 0) u_dbg_lo_buf0
   (.rd_clk(clk),             // read clock
    .wr_clk(clk),             // read clock
    .csn_rd(dbgq_lo_csn_rd),  // read enable -- active low 
    .csn_wr(dbgq_lo_csn_wr0),  // write enable -- active low
    .hold(hold),              // Bypass signal -- unflopped -- bypass input data when 0
    .scan_en(scan_en),        // Scan enable unflopped
    .margin(csr_16x65array_margin),     // Delay for the circuits--- set to 10101 
    .rd_a(dbgq_lo_raddr[`JBI_DBGQ_ADDR_WIDTH-2:0]),     // read address  
    .wr_a(dbgq_lo_waddr[`JBI_DBGQ_ADDR_WIDTH-2:0]),     // Write address
    .di({ {65-`JBI_DBGQ_WIDTH{1'b0}},
	  dbgq_lo_wdata[`JBI_DBGQ_WIDTH-1:0] }),       // Data input
    .testmux_sel(testmux_sel), // bypass  signal -- unflopped -- testmux_sel = 1 bypasses di to do 
    .si(),        // scan in  -- NOT CONNECTED
    .so(),        // scan out -- TIED TO ZERO 
    .listen_out(), // Listening flop-- 
    .do( {dangle_lo0,
	  dbgq_lo_rdata0[`JBI_DBGQ_WIDTH-1:0]} )         // Data out
    );

bw_rf_16x65 #(1, 1, 1, 0) u_dbg_lo_buf1
   (.rd_clk(clk),             // read clock
    .wr_clk(clk),             // read clock
    .csn_rd(dbgq_lo_csn_rd),  // read enable -- active low 
    .csn_wr(dbgq_lo_csn_wr1),  // write enable -- active low
    .hold(hold),              // Bypass signal -- unflopped -- bypass input data when 0
    .scan_en(scan_en),        // Scan enable unflopped
    .margin(csr_16x65array_margin),     // Delay for the circuits--- set to 10101 
    .rd_a(dbgq_lo_raddr[`JBI_DBGQ_ADDR_WIDTH-2:0]),     // read address  
    .wr_a(dbgq_lo_waddr[`JBI_DBGQ_ADDR_WIDTH-2:0]),     // Write address
    .di({ {65-`JBI_DBGQ_WIDTH{1'b0}},
	  dbgq_lo_wdata[`JBI_DBGQ_WIDTH-1:0] }),       // Data input
    .testmux_sel(testmux_sel), // bypass  signal -- unflopped -- testmux_sel = 1 bypasses di to do 
    .si(),        // scan in  -- NOT CONNECTED
    .so(),        // scan out -- TIED TO ZERO 
    .listen_out(), // Listening flop-- 
    .do( {dangle_lo1,
	  dbgq_lo_rdata1[`JBI_DBGQ_WIDTH-1:0]} )         // Data out
    );

dff_ns #(1) u_dff_dbgq_lo_rdata_sel
   (.din(next_dbgq_lo_rdata_sel),
    .clk(clk),
    .q(dbgq_lo_rdata_sel)
    );


endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-library-files:("../../../common/rtl/swrvr_u1_clib.v")
// verilog-auto-sense-defines-constant:t
// End:

		   
