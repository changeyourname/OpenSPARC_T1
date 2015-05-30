// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncio_makq_ctl.v
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


`include "jbi.h"

module jbi_ncio_makq_ctl(/*AUTOARG*/
// Outputs
makq_csn_wr, makq_waddr, makq_raddr, ncio_mondo_req, ncio_mondo_ack, 
ncio_mondo_agnt_id, ncio_mondo_cpu_id, ncio_makq_level, 
// Inputs
clk, rst_l, makq_push, makq_nack, iob_jbi_mondo_ack_ff, 
iob_jbi_mondo_nack_ff, makq_rdata, mout_mondo_pop
);

input clk;
input rst_l;

// Mondo Request Queue Interface
input makq_push;
input makq_nack;
input iob_jbi_mondo_ack_ff;
input iob_jbi_mondo_nack_ff;


// Mondo ID Queue Interface
input [`JBI_MAKQ_WIDTH-1:0] makq_rdata;
output 			    makq_csn_wr;
output [`JBI_MAKQ_ADDR_WIDTH-1:0] makq_waddr;
output [`JBI_MAKQ_ADDR_WIDTH-1:0] makq_raddr;

// Memory Out (mout) Interface
input 				  mout_mondo_pop;
output 				  ncio_mondo_req;
output 				  ncio_mondo_ack;  // 1=ack; 0=nack
output [`JBI_AD_INT_AGTID_WIDTH-1:0] ncio_mondo_agnt_id;
output [`JBI_AD_INT_CPUID_WIDTH-1:0] ncio_mondo_cpu_id;
output [`JBI_MAKQ_ADDR_WIDTH:0]      ncio_makq_level;

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 				     makq_csn_wr;
wire [`JBI_MAKQ_ADDR_WIDTH-1:0]      makq_waddr;
wire [`JBI_MAKQ_ADDR_WIDTH-1:0]      makq_raddr;
wire 				     ncio_mondo_req;
wire 				     ncio_mondo_ack;  // 1=ack; 0=nack
wire [`JBI_AD_INT_AGTID_WIDTH-1:0]   ncio_mondo_agnt_id;
wire [`JBI_AD_INT_CPUID_WIDTH-1:0]   ncio_mondo_cpu_id;
wire [`JBI_MAKQ_ADDR_WIDTH:0] 	     ncio_makq_level;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

wire [`JBI_MAKQ_ADDR_WIDTH:0] 	     id_wptr;
wire [`JBI_MAKQ_ADDR_WIDTH:0] 	     ack_wptr;
wire [`JBI_MAKQ_DEPTH-1:0] 	     ack;
wire [`JBI_MAKQ_ADDR_WIDTH:0] 	     rptr;
reg [`JBI_MAKQ_ADDR_WIDTH:0] 	     next_id_wptr;
reg [`JBI_MAKQ_ADDR_WIDTH:0] 	     next_ack_wptr;
reg [`JBI_MAKQ_DEPTH-1:0] 	     next_ack;
reg [`JBI_MAKQ_ADDR_WIDTH:0] 	     next_rptr;

reg [`JBI_MAKQ_ADDR_WIDTH:0] 	     next_ncio_makq_level;

wire 				     ack_push;
wire 				     makq_empty;

//
// Code start here 
//

//*******************************************************************************
// Push 
//*******************************************************************************

//-------------------
// Push ID
//-------------------

always @ ( /*AUTOSENSE*/id_wptr or makq_push) begin
   if (makq_push)
      next_id_wptr = id_wptr + 1'b1;
   else
      next_id_wptr = id_wptr;
end

assign makq_csn_wr = ~makq_push;
assign makq_waddr = id_wptr[`JBI_MAKQ_ADDR_WIDTH-1:0];

//-------------------
// Push Ack/Nack
//-------------------

assign ack_push =  iob_jbi_mondo_ack_ff 
                 | iob_jbi_mondo_nack_ff 
                 | (makq_push & makq_nack); // mondo with par error not forwarded to cmp but nacked on jbus

always @ ( /*AUTOSENSE*/ack or ack_push or ack_wptr
	  or iob_jbi_mondo_ack_ff or makq_nack or makq_push) begin
   next_ack = ack;
   if (ack_push)
      next_ack[ack_wptr[`JBI_MAKQ_ADDR_WIDTH-1:0]] = iob_jbi_mondo_ack_ff & ~(makq_push & makq_nack);
end

always @ ( /*AUTOSENSE*/ack_push or ack_wptr) begin
   if (ack_push)
      next_ack_wptr = ack_wptr + 1'b1;
   else
      next_ack_wptr = ack_wptr;
end

//*******************************************************************************
// Pop
//*******************************************************************************

always @ ( /*AUTOSENSE*/mout_mondo_pop or rptr) begin
   if (mout_mondo_pop)
      next_rptr = rptr + 1'b1;
   else
      next_rptr = rptr;
end

assign makq_empty = rptr == ack_wptr;

assign makq_raddr  = rptr[`JBI_MAKQ_ADDR_WIDTH-1:0];
//assign makq_csn_rd = next_rptr == id_wptr; 

assign ncio_mondo_req = ~makq_empty;
assign ncio_mondo_ack = ack[rptr[`JBI_MAKQ_ADDR_WIDTH-1:0]];
assign ncio_mondo_agnt_id = makq_rdata[`JBI_MAKQ_AGTID_HI:`JBI_MAKQ_AGTID_LO];
assign ncio_mondo_cpu_id  = makq_rdata[`JBI_MAKQ_CPUID_HI:`JBI_MAKQ_CPUID_LO];

always @ ( /*AUTOSENSE*/ack_push or mout_mondo_pop or ncio_makq_level) begin
   case ({ack_push, mout_mondo_pop})
      2'b00,
      2'b11: next_ncio_makq_level = ncio_makq_level;
      2'b01: next_ncio_makq_level = ncio_makq_level - 1'b1;
      2'b10: next_ncio_makq_level = ncio_makq_level + 1'b1;
      default: next_ncio_makq_level = {`JBI_MAKQ_ADDR_WIDTH+1{1'bx}};
   endcase
end

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************
dffrl_ns #(`JBI_MAKQ_ADDR_WIDTH+1) u_dffrl_id_wptr
   (.din(next_id_wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(id_wptr)
    );

dffrl_ns #(`JBI_MAKQ_ADDR_WIDTH+1) u_dffrl_ack_wptr
   (.din(next_ack_wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(ack_wptr)
    );

dffrl_ns #(`JBI_MAKQ_ADDR_WIDTH+1) u_dffrl_rptr
   (.din(next_rptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(rptr)
    );

dffrl_ns #(`JBI_MAKQ_DEPTH) u_dffrl_ack
   (.din(next_ack),
    .clk(clk),
    .rst_l(rst_l),
    .q(ack)
    );

dffrl_ns #(`JBI_MAKQ_ADDR_WIDTH+1) u_dffrl_ncio_makq_level
   (.din(next_ncio_makq_level),
    .clk(clk),
    .rst_l(rst_l),
    .q(ncio_makq_level)
    );

//*******************************************************************************
// Rule Checks
//*******************************************************************************

//synopsys translate_off

wire rc_makq_empty = rptr == ack_wptr;

wire rc_makq_full =   ack_wptr[`JBI_MAKQ_ADDR_WIDTH]     != rptr[`JBI_MAKQ_ADDR_WIDTH]
                    & ack_wptr[`JBI_MAKQ_ADDR_WIDTH-1:0] == rptr[`JBI_MAKQ_ADDR_WIDTH-1:0];

always @ ( /*AUTOSENSE*/makq_push or rc_makq_full) begin
   @clk;
   if (rc_makq_full && makq_push)
      $dispmon ("jbi_ncio_makq_ctl", 49,"%d %m: ERROR - MAKQ overflow!", $time);
end

always @ ( /*AUTOSENSE*/mout_mondo_pop or rc_makq_empty) begin
   @clk;
   if (rc_makq_empty && mout_mondo_pop)
      $dispmon ("jbi_ncio_makq_ctl", 49,"%d %m: ERROR - MAKQ underflow!", $time);
end

//synopsys translate_on

endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
