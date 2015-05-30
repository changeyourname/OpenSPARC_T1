// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncio_prtq_buf.v
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
//  Description:	Request Dqta Queue Buffer
//  Top level Module:	jbi_min_rdq_buf
//  Where Instantiated:	jbi_min_rdq
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "jbi.h"

module jbi_ncio_prtq_buf(/*AUTOARG*/
// Outputs
prtq_rdata, 
// Inputs
clk, hold, testmux_sel, scan_en, csr_16x81array_margin, 
csr_16x65array_margin, prtq_csn_wr, prtq_csn_rd, prtq_waddr, 
prtq_raddr, prtq_wdata
);

input clk;
input hold;
input testmux_sel;
input scan_en;
input [4:0] csr_16x81array_margin;
input [4:0] csr_16x65array_margin;

input prtq_csn_wr;
input prtq_csn_rd;
input [`JBI_PRTQ_ADDR_WIDTH-1:0] prtq_waddr;
input [`JBI_PRTQ_ADDR_WIDTH-1:0] prtq_raddr;
input [`JBI_PRTQ_WIDTH-1:0] 	 prtq_wdata;

output [`JBI_PRTQ_WIDTH-1:0] 	 prtq_rdata;

////////////////////////////////////////////////////////////////////////
				 // Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire [`JBI_PRTQ_WIDTH-1:0] 	 prtq_rdata;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
wire [146-`JBI_PRTQ_WIDTH-1:0] 	 dangle;

//
// Code start here 
//

bw_rf_16x81 #(1, 1, 1, 0) u_prtq_buf0
   (.rd_clk(clk),          // read clock
    .wr_clk(clk),         // read clock
    .csn_rd(prtq_csn_rd),  // read enable -- active low 
    .csn_wr(prtq_csn_wr),  // write enable -- active low
    .hold(hold),          // Bypass signal -- unflopped -- bypass input data when 0
    .scan_en(scan_en),    // Scan enable unflopped
    .margin(csr_16x81array_margin), // Delay for the circuits--- set to 10101 
    .rd_a(prtq_raddr),     // read address  
    .wr_a(prtq_waddr),     // Write address
    .di(prtq_wdata[80:0]),       // Data input
    .testmux_sel(testmux_sel), // bypass  signal -- unflopped -- testmux_sel = 1 bypasses di to do 
    .si(),        // scan in  -- NOT CONNECTED
    .so(),        // scan out -- TIED TO ZERO 
    .listen_out(prtq_rdata[80:0]), // Listening flop-- 
    .do()          // Data out
    );

bw_rf_16x65 #(1, 1, 1, 0) u_prtq_buf1
   (.rd_clk(clk),          // read clock
    .wr_clk(clk),         // read clock
    .csn_rd(prtq_csn_rd),  // read enable -- active low 
    .csn_wr(prtq_csn_wr),  // write enable -- active low
    .hold(hold),          // Bypass signal -- unflopped -- bypass input data when 0
    .scan_en(scan_en),    // Scan enable unflopped
    .margin(csr_16x65array_margin), // Delay for the circuits--- set to 10101 
    .rd_a(prtq_raddr),     // read address  
    .wr_a(prtq_waddr),     // Write address
    .di({ {146-`JBI_PRTQ_WIDTH{1'b0}},
	  prtq_wdata[`JBI_PRTQ_WIDTH-1:81] }),// Data input
    .testmux_sel(testmux_sel), // bypass  signal -- unflopped -- testmux_sel = 1 bypasses di to do 
    .si(),        // scan in  -- NOT CONNECTED
    .so(),        // scan out -- TIED TO ZERO 
    .listen_out({ dangle,
		  prtq_rdata[`JBI_PRTQ_WIDTH-1:81] }), // Listening flop-- 
    .do()          // Data out
    );



endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
