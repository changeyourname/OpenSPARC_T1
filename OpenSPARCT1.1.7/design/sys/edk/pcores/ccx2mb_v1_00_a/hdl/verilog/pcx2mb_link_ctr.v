// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: pcx2mb_link_ctr.v
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
/***************************************************************************
 * pcx2mb_link_cnt.v:	A counter to keep track of outstanding transactions
 *		to one of the five destinations of the PCX request.  This 
 *		counter will be instantiated 5 times.
 *
 *		The core has a link credit of 2 transactions.  However, it will
 *		speculatively send a third transaction, assuming that a grant
 *		will be received in time.  If this block is not ready to grant
 *		the first transaction, then the third one must be dropped,
 *		because the core will re-send it.
 *
 *		NOTE:  Pipeline stages from SPARC point of view are
 *			PQ	Initial Request
 *			PA	Data sent for request.
 *			PX	Grant returned, Request sent to cache
 *			PX2	Data sent to cache
 *
 * $Id: pcx2mb_link_ctr.v,v 1.1 2007/06/30 00:23:40 tt147840 Exp $
 ***************************************************************************/

// Global header file includes


// Local header file includes

`include "ccx2mb.h"

module pcx2mb_link_ctr (
	// Outputs
	request_mask_pa,

	// Inputs
	rclk,
	reset_l,

	pcx_req_pa,
	pcx_req_px,
	pcx_atom_px,

	pcx_grant_px
	);

    output request_mask_pa;

    input rclk;
    input reset_l;

    input pcx_req_pa;
    input pcx_req_px;
    input pcx_atom_px;

    input pcx_grant_px;


    reg [1:0] link_count_pa;
    wire      request_mask_pa;
    wire      count_inc;
    wire      count_dec;

    assign count_inc = pcx_req_pa || (pcx_req_px && pcx_atom_px);
    assign count_dec = pcx_grant_px;


    always @(posedge rclk) begin
	if (!reset_l) begin
	    link_count_pa <= 2'b00;
	end
	else if (count_inc && count_dec) begin
	    link_count_pa <= link_count_pa;
	end
	else if (count_inc && !link_count_pa[1]) begin
	    link_count_pa <= link_count_pa + 2'b01;
	end
	else if (count_dec) begin
	    link_count_pa <= link_count_pa - 2'b01;
	end
	else begin
	    link_count_pa <= link_count_pa;
	end
    end

    assign request_mask_pa = link_count_pa[1];

endmodule




