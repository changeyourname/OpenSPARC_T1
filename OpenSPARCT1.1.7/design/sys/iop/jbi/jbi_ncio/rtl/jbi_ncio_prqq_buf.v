// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncio_prqq_buf.v
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
//  Top level Module:	jbi_ncio_prqq_buf
//  Where Instantiated:	jbi_ncio
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

module jbi_ncio_prqq_buf(/*AUTOARG*/
// Outputs
prqq_rdata, 
// Inputs
clk, hold, testmux_sel, scan_en, csr_16x81array_margin, prqq_csn_wr, 
prqq_csn_rd, prqq_waddr, prqq_raddr, prqq_wdata
);

input clk;
input hold;
input testmux_sel;
input scan_en;
input [4:0] csr_16x81array_margin;

input prqq_csn_wr;
input prqq_csn_rd;
input [`JBI_PRQQ_ADDR_WIDTH-1:0] prqq_waddr;
input [`JBI_PRQQ_ADDR_WIDTH-1:0] prqq_raddr;
input [`JBI_PRQQ_WIDTH-1:0] 	 prqq_wdata;

output [`JBI_PRQQ_WIDTH-1:0] 	 prqq_rdata;

////////////////////////////////////////////////////////////////////////
				 // Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire [`JBI_PRQQ_WIDTH-1:0] 	 prqq_rdata;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
wire [81-`JBI_PRQQ_WIDTH-1:0] 	 dangle;

//
// Code start here 
//

bw_rf_16x81 #(1, 1, 1, 0) u_prqq_buf
   (.rd_clk(clk),          // read clock
    .wr_clk(clk),         // read clock
    .csn_rd(prqq_csn_rd),  // read enable -- active low 
    .csn_wr(prqq_csn_wr),  // write enable -- active low
    .hold(hold),          // Bypass signal -- unflopped -- bypass input data when 0
    .scan_en(scan_en),    // Scan enable unflopped
    .margin(csr_16x81array_margin), // Delay for the circuits--- set to 10101 
    .rd_a(prqq_raddr),     // read address  
    .wr_a(prqq_waddr),     // Write address
    .di({ {81-`JBI_PRQQ_WIDTH{1'b0}},
	  prqq_wdata[`JBI_PRQQ_WIDTH-1:0] }),       // Data input
    .testmux_sel(testmux_sel), // bypass  signal -- unflopped -- testmux_sel = 1 bypasses di to do 
    .si(),        // scan in  -- NOT CONNECTED
    .so(),        // scan out -- TIED TO ZERO 
    .listen_out(), // Listening flop-- 
    .do( {dangle,
	  prqq_rdata[`JBI_PRQQ_WIDTH-1:0]} )          // Data out
    );


endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
