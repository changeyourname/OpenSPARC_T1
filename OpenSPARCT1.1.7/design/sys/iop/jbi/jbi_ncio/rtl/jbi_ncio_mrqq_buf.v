// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncio_mrqq_buf.v
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
//
//  Description:	Write Decomposition Queue Buffer
//  Top level Module:	jbi_ncio_mrqq_buf
//  Where Instantiated:	jbi_ncio
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "jbi.h"

module jbi_ncio_mrqq_buf(/*AUTOARG*/
// Outputs
mrqq_rdata, 
// Inputs
clk, arst_l, hold, rst_tri_en, mrqq_wr_en, mrqq_rd_en, mrqq_waddr, 
mrqq_raddr, mrqq_wdata
);

input clk;
input arst_l;
input hold;
input rst_tri_en;

input mrqq_wr_en;
input mrqq_rd_en;
input [`JBI_MRQQ_ADDR_WIDTH-1:0] mrqq_waddr;
input [`JBI_MRQQ_ADDR_WIDTH-1:0] mrqq_raddr;
input [`JBI_MRQQ_WIDTH-1:0] 	mrqq_wdata;

output [`JBI_MRQQ_WIDTH-1:0] 	mrqq_rdata;

////////////////////////////////////////////////////////////////////////
				// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire [`JBI_MRQQ_WIDTH-1:0] 	mrqq_rdata;


////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
wire [160-`JBI_MRQQ_WIDTH-1:0] 	dangle;

//
// Code start here 
//

jbi_1r1w_16x160 u_mrqq_buf
   (// outputs
    .dout     ( {dangle, 
		 mrqq_rdata} ),

    // read inputs 
    .rdclk    (clk),
    .read_en  (mrqq_rd_en),
    .rd_adr   (mrqq_raddr),

    // write inputs
    .wrclk    (clk),
    .wr_en    (mrqq_wr_en),
    .wr_adr   (mrqq_waddr),
    .din      ( { {160-`JBI_MRQQ_WIDTH{1'b0}}, mrqq_wdata }),

    // other inputs 
    .rst_l    (arst_l),
    .hold     (hold),
    .testmux_sel (1'b1),  // always want data from FF
    .rst_tri_en (rst_tri_en)
    );


endmodule

// Local Variables:
// verilog-library-directories:("." "../../../common/mem/rtl/")
// verilog-auto-sense-defines-constant:t
// End:
