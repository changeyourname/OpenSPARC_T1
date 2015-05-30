// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_rq_rhq_buf.v
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
//  Description:	Request Header Queue Buffer
//  Top level Module:	jbi_min_rq_rhq_buf
//  Where Instantiated:	jbi_min_rq_rhq
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "jbi.h"

module jbi_min_rq_rhq_buf(/*AUTOARG*/
// Outputs
rhq_rdata, 
// Inputs
clk, cpu_clk, hold, csr_16x65array_margin, testmux_sel, rhq_csn_wr, 
rhq_csn_rd, rhq_waddr, rhq_raddr, wdq_rhq_wdata
);

input clk;
input cpu_clk;

input hold;
input [4:0] csr_16x65array_margin;
input 	    testmux_sel;

input rhq_csn_wr;
input rhq_csn_rd;
input [`JBI_RHQ_ADDR_WIDTH-1:0] rhq_waddr;
input [`JBI_RHQ_ADDR_WIDTH-1:0] rhq_raddr;
input [`JBI_RHQ_WIDTH-1:0] 	wdq_rhq_wdata;

output [`JBI_RHQ_WIDTH-1:0] 	rhq_rdata;

////////////////////////////////////////////////////////////////////////
				// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire [`JBI_RHQ_WIDTH-1:0] 	rhq_rdata;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
wire 				dangle;

bw_rf_16x65 u_rhq_buf
   (.rd_clk(cpu_clk),     // read clock
    .wr_clk(clk),         // read clock
    .csn_rd(rhq_csn_rd),  // read enable -- active low 
    .csn_wr(rhq_csn_wr),  // write enable -- active low
    .hold(hold),          // Bypass signal -- unflopped -- bypass input data when 0
    .scan_en(1'b0),           // Scan enable unflopped
    .margin(csr_16x65array_margin), // Delay for the circuits--- set to 10101 
    .rd_a(rhq_raddr),     // read address  
    .wr_a(rhq_waddr),     // Write address
    .di({1'b0, wdq_rhq_wdata}),       // Data input
    .testmux_sel(testmux_sel), // bypass  signal -- unflopped -- testmux_sel = 1 bypasses di to do 
    .si(),        // scan in  -- NOT CONNECTED
    .so(),        // scan out -- TIED TO ZERO 
    .listen_out({dangle, rhq_rdata}), // Listening flop-- 
    .do()          // Data out
    );



endmodule

// Local Variables:
// verilog-library-directories:("." "../../../common/mem/rtl/")
// verilog-auto-sense-defines-constant:t
// End:
