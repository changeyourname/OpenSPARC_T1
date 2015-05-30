// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_rq_rdq_buf.v
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

module jbi_min_rq_rdq_buf(/*AUTOARG*/
// Outputs
rdq_rdata, 
// Inputs
clk, cpu_clk, arst_l, hold, rst_tri_en, rdq_wr_en, rdq_rd_en, 
rdq_waddr, rdq_raddr, wdq_rdq_wdata
);

input clk;
input cpu_clk;
input arst_l;
input hold;
input rst_tri_en;

input rdq_wr_en;
input rdq_rd_en;
input [`JBI_RDQ_ADDR_WIDTH-1:0] rdq_waddr;
input [`JBI_RDQ_ADDR_WIDTH-1:0] rdq_raddr;
input [`JBI_RDQ_WIDTH-1:0] 	wdq_rdq_wdata;

output [`JBI_RDQ_WIDTH-1:0] 	rdq_rdata;

////////////////////////////////////////////////////////////////////////
				// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire [`JBI_RDQ_WIDTH-1:0] 	rdq_rdata;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
///////////////////////////////////////////////////////////////////////
wire [3:0] 			dangle;

//
// Code start here 
//


jbi_1r1w_16x160 u_rdq_buf
   (// outputs
    .dout     ( {dangle[3:0],
		 rdq_rdata} ),

    // read inputs
    .rdclk    (cpu_clk),
    .read_en  (rdq_rd_en),
    .rd_adr   (rdq_raddr),

    // write inputs
    .wrclk    (clk),
    .wr_en    (rdq_wr_en),
    .wr_adr   (rdq_waddr),
    .din      ( {4'b0000,
		 wdq_rdq_wdata} ),

    // other inputs
    .rst_l    (arst_l),
    .hold     (hold),
    .testmux_sel (1'b1), // always want data from FF
    .rst_tri_en	(rst_tri_en)
    );

endmodule

// Local Variables:
// verilog-library-directories:("." "../../../common/mem/rtl/")
// verilog-auto-sense-defines-constant:t
// End:
