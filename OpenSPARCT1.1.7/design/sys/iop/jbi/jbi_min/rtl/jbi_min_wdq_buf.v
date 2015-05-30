// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_wdq_buf.v
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
//  Description:	Write Decomposition Queue Buffer
//  Top level Module:	jbi_min_wdq_buf
//  Where Instantiated:	jbi_min_wdq
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "jbi.h"

module jbi_min_wdq_buf(/*AUTOARG*/
// Outputs
wdq_rdata, 
// Inputs
clk, arst_l, testmux_sel, hold, rst_tri_en, wdq_wr_en, wdq_rd_en, 
wdq_waddr, wdq_raddr, wdq_wdata, wdq_wdata_ecc0, wdq_wdata_ecc1, 
wdq_wdata_ecc2, wdq_wdata_ecc3
);

input clk;
input arst_l;
input testmux_sel;
input hold;
input rst_tri_en;

input wdq_wr_en;
input wdq_rd_en;
input [`JBI_WDQ_ADDR_WIDTH-1:0] wdq_waddr;
input [`JBI_WDQ_ADDR_WIDTH-1:0] wdq_raddr;
input [127:0] 			wdq_wdata;
input [6:0] 			wdq_wdata_ecc0;
input [6:0] 			wdq_wdata_ecc1;
input [6:0] 			wdq_wdata_ecc2;
input [6:0] 			wdq_wdata_ecc3;

output [`JBI_WDQ_WIDTH-1:0] 	wdq_rdata;

////////////////////////////////////////////////////////////////////////
				// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire [`JBI_WDQ_WIDTH-1:0] 	wdq_rdata;


////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
wire [3:0] 			dangle;

//
// Code start here 
//

jbi_1r1w_16x160 u_wdq_buf
   (// outputs
    .dout     ( {dangle[3:0],
	   	 wdq_rdata} ),

    // read inputs
    .rdclk    (clk),
    .read_en  (wdq_rd_en),
    .rd_adr   (wdq_raddr),
    
    // write inputs
    .wrclk    (clk),
    .wr_en    (wdq_wr_en),
    .wr_adr   (wdq_waddr),
    .din      ( {4'b0000,
	  	 wdq_wdata_ecc3, 
	  	 wdq_wdata_ecc2, 
	  	 wdq_wdata_ecc1, 
	  	 wdq_wdata_ecc0, 
	  	 wdq_wdata} ),
    
    // other inputs
    .rst_l    (arst_l),
    .hold     (hold),
    .testmux_sel (testmux_sel),
    .rst_tri_en (rst_tri_en)
    );

endmodule

// Local Variables:
// verilog-library-directories:("." "../../../common/mem/rtl/")
// verilog-auto-sense-defines-constant:t
// End:
