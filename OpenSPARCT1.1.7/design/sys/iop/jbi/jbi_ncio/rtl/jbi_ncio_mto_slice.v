// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncio_mto_slice.v
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
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

module jbi_ncio_mto_slice(/*AUTOARG*/
// Outputs
timeout_err, 
// Inputs
clk, timeout_wrap, int_rst_l, int_vld
);

input clk;

input timeout_wrap;
input int_rst_l;
input int_vld;

output timeout_err;

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire   timeout_err;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

wire   vld;
wire   timeout;
wire   next_vld;
wire   next_timeout;

wire   vld_rst_l;
wire   timeout_rst_l;
     

//
// Code start here 
//

assign vld_rst_l = int_rst_l;
assign next_vld  = int_vld | vld;

assign timeout_rst_l = int_rst_l;
assign next_timeout  = vld & (timeout_wrap | timeout);

assign timeout_err = vld & timeout_wrap & timeout;

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************
dffrl_ns #(1) u_dffrl_vld
   (.din(next_vld),
    .clk(clk),
    .rst_l(vld_rst_l),
    .q(vld)
    );

dffrl_ns #(1) u_dffrl_timeout
   (.din(next_timeout),
    .clk(clk),
    .rst_l(timeout_rst_l),
    .q(timeout)
    );

endmodule
