// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncio_mrqq_ctl.v
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
//  Description:	Mondo Request Queue Control
//  Top level Module:	jbi_ncio_mrqq_ctl
//  Where Instantiated:	jbi_ncio
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

module jbi_ncio_mrqq_ctl(/*AUTOARG*/
// Outputs
jbi_iob_mondo_vld, jbi_iob_mondo_data, iob_jbi_mondo_ack_ff, 
iob_jbi_mondo_nack_ff, makq_push, makq_wdata, makq_nack, mrqq_wr_en, 
mrqq_rd_en, mrqq_waddr, mrqq_wdata, mrqq_raddr, mtag_csn_wr, 
mtag_waddr, mtag_raddr, 
// Inputs
clk, rst_l, csr_jbi_config2_ord_int, io_jbi_j_ad_ff, 
min_mondo_hdr_push, min_mondo_data_push, min_mondo_data_err, 
iob_jbi_mondo_ack, iob_jbi_mondo_nack, mrqq_rdata, mtag_byps
);

input clk;
input rst_l;

// CSR Interface
input csr_jbi_config2_ord_int;

// Memory In (min)  Interface
input [127:0] io_jbi_j_ad_ff;      // flopped version of j_ad
input 	      min_mondo_hdr_push;
input 	      min_mondo_data_push;
input 	      min_mondo_data_err;

// IOB Interface.
input 			       iob_jbi_mondo_ack;
input 			       iob_jbi_mondo_nack;
output 			       jbi_iob_mondo_vld;
output [`JBI_IOB_MONDO_BUS_WIDTH-1:0] jbi_iob_mondo_data;

// Mondo Ack Interface
output 				      iob_jbi_mondo_ack_ff;
output 				      iob_jbi_mondo_nack_ff;
output 				      makq_push;
output [`JBI_MAKQ_WIDTH-1:0] 	      makq_wdata;
output 				      makq_nack;

// Mondo Request Queue Interface
input [`JBI_MRQQ_WIDTH-1:0] 	      mrqq_rdata;
output 				      mrqq_wr_en;
output 				      mrqq_rd_en;
output [`JBI_MRQQ_ADDR_WIDTH-1:0]     mrqq_waddr;
output [`JBI_MRQQ_WIDTH-1:0] 	      mrqq_wdata;
output [`JBI_MRQQ_ADDR_WIDTH-1:0]     mrqq_raddr;

// Mondo Tag Interface
input 				      mtag_byps;
output 				      mtag_csn_wr;
output [3:0] 			      mtag_waddr;
output [3:0] 			      mtag_raddr;


////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 				      jbi_iob_mondo_vld;
wire [`JBI_IOB_MONDO_BUS_WIDTH-1:0]   jbi_iob_mondo_data;
wire 				      iob_jbi_mondo_ack_ff;
wire 				      iob_jbi_mondo_nack_ff;
wire 				      makq_push;
wire [`JBI_MAKQ_WIDTH-1:0] 	      makq_wdata;
wire 				      makq_nack;
wire 				      mrqq_wr_en;
wire 				      mrqq_rd_en;
wire [`JBI_MRQQ_ADDR_WIDTH-1:0]       mrqq_waddr;
wire [`JBI_MRQQ_WIDTH-1:0] 	      mrqq_wdata;
wire [`JBI_MRQQ_ADDR_WIDTH-1:0]       mrqq_raddr;
wire 				      mtag_csn_wr;
wire [3:0] 			      mtag_waddr;
wire [3:0] 			      mtag_raddr;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
parameter POP_HDR0     = 6'b000001,
	  POP_HDR1     = 6'b000010,
	  POP_DATA     = 6'b000100,
	  POP_ACK_WAIT = 6'b001000,
	  POP_ERR0     = 6'b010000,
	  POP_ERR1     = 6'b100000;
parameter POP_HDR0_BIT = 0,
	  POP_HDR1_BIT = 1,
	  POP_DATA_BIT = 2,
	  POP_SM_WIDTH = 6;

wire [`JBI_AD_INT_AGTID_WIDTH-1:0] agtid_ff;
wire [`JBI_AD_INT_AGTID_WIDTH-1:0] cpuid_ff;
wire [`JBI_MRQQ_ADDR_WIDTH:0] 	   wptr;
wire [`JBI_MRQQ_ADDR_WIDTH:0] 	   rptr;
wire [POP_SM_WIDTH-1:0] 	   pop_sm;
wire [3:0] 			   data_cnt;
wire [`JBI_AD_INT_AGTID_WIDTH-1:0] next_agtid_ff;
wire [`JBI_AD_INT_AGTID_WIDTH-1:0] next_cpuid_ff;
reg [`JBI_MRQQ_ADDR_WIDTH:0] 	   next_wptr;
reg [`JBI_MRQQ_ADDR_WIDTH:0] 	   next_rptr;
reg [POP_SM_WIDTH-1:0] 		   next_pop_sm;
wire [3:0] 			   next_data_cnt;

wire 				   data_cnt_rst_l;

wire 				   mrqq_drdy;
wire 				   mrqq_pop;
wire [127:0] 			   mrqq_rdata_data;
reg [`JBI_IOB_MONDO_BUS_WIDTH-1:0] mondo_data;

wire 				   next_jbi_iob_mondo_vld;
reg [`JBI_IOB_MONDO_BUS_WIDTH-1:0] next_jbi_iob_mondo_data;wire [`JBI_MRQQ_ADDR_WIDTH:0] 	   wptr_d1;
wire [`JBI_MRQQ_ADDR_WIDTH:0] 	   wptr_d2;

//
// Code start here 
//

//*******************************************************************************
// Push Transaction into Mondo Request Queue
//*******************************************************************************

// Flop agent id and cpu id during first header cycle and push into mrqq
// with data during following cycle
assign next_agtid_ff = io_jbi_j_ad_ff[`JBI_AD_INT_AGTID_HI:`JBI_AD_INT_AGTID_LO];
assign next_cpuid_ff = io_jbi_j_ad_ff[`JBI_AD_INT_CPUID_HI:`JBI_AD_INT_CPUID_LO];

assign mrqq_wr_en = min_mondo_data_push;
assign mrqq_waddr  = wptr[`JBI_MRQQ_ADDR_WIDTH-1:0];
assign mrqq_wdata[`JBI_MRQQ_DATA_HI:`JBI_MRQQ_DATA_LO]   = io_jbi_j_ad_ff;
assign mrqq_wdata[`JBI_MRQQ_AGTID_HI:`JBI_MRQQ_AGTID_LO] = agtid_ff;
assign mrqq_wdata[`JBI_MRQQ_CPUID_HI:`JBI_MRQQ_CPUID_LO] = cpuid_ff;
assign mrqq_wdata[`JBI_MRQQ_ERR]                         = min_mondo_data_err;

//-------------------
// Pointer Management
//-------------------
always @ ( /*AUTOSENSE*/min_mondo_data_push or wptr) begin
   if (min_mondo_data_push)
      next_wptr = wptr + 1'b1;
   else
      next_wptr = wptr;
end

//*******************************************************************************
// Pop Transaction from Mondo Request Queue
//*******************************************************************************

//-------------------
// Pop State Machine
//-------------------

// mondos with par error are not forwarded to cmp bit are nacked on JBUS
assign mrqq_drdy =  ~(rptr == wptr_d2)
                  & (  mtag_byps
		     | ~csr_jbi_config2_ord_int);  // turn off wr-int ordering

always @ ( /*AUTOSENSE*/data_cnt or iob_jbi_mondo_ack_ff
	  or iob_jbi_mondo_nack_ff or mrqq_drdy or mrqq_rdata
	  or pop_sm) begin
   case (pop_sm)
      POP_HDR0: begin
	 if (mrqq_drdy) begin
	    if (mrqq_rdata[`JBI_MRQQ_ERR])
	       next_pop_sm = POP_ERR0;
	    else
	       next_pop_sm = POP_HDR1;
	 end
	 else
	    next_pop_sm = POP_HDR0;
      end

      POP_HDR1: next_pop_sm = POP_DATA;

      POP_DATA: begin
	 if (&data_cnt)
	    next_pop_sm = POP_ACK_WAIT;
	 else
	    next_pop_sm = POP_DATA;
      end

      POP_ACK_WAIT: begin
	 if (iob_jbi_mondo_ack_ff | iob_jbi_mondo_nack_ff)
	    next_pop_sm = POP_HDR0;
	 else
	    next_pop_sm = POP_ACK_WAIT;
      end

      POP_ERR0: next_pop_sm = POP_ERR1;
      POP_ERR1: next_pop_sm = POP_HDR0;
      
      // CoverMeter line_off
      default: begin
	 next_pop_sm = {POP_SM_WIDTH{1'bx}};
	 //synopsys translate_off
	 $dispmon ("jbi_ncio_mrqq_ctl", 49,"%d %m: pop_sm = %b", $time, pop_sm);
	 //synopsys translate_on
      end
      // CoverMeter line_on
   endcase
end

assign data_cnt_rst_l = rst_l & pop_sm[POP_DATA_BIT];
assign next_data_cnt = data_cnt + 1'b1;

//-------------------
// Pointer Management
//-------------------
assign mrqq_pop =  (pop_sm[POP_DATA_BIT] & (&data_cnt))
                 | (pop_sm[POP_HDR0_BIT] & mrqq_drdy & mrqq_rdata[`JBI_MRQQ_ERR]); //mondow with par error

always @ ( /*AUTOSENSE*/mrqq_pop or rptr) begin
   if (mrqq_pop)
      next_rptr = rptr + 1'b1;
   else
      next_rptr = rptr;
end

assign mrqq_raddr = next_rptr[`JBI_MRQQ_ADDR_WIDTH-1:0];
assign mrqq_rd_en = next_rptr != wptr;

//-------------------
// Drive Data
//-------------------
assign mrqq_rdata_data = mrqq_rdata[`JBI_MRQQ_DATA_HI:`JBI_MRQQ_DATA_LO];
always @ ( /*AUTOSENSE*/data_cnt or mrqq_rdata_data) begin
   case (data_cnt)
      4'd0: mondo_data  = mrqq_rdata_data[127:120];
      4'd1: mondo_data  = mrqq_rdata_data[119:112];
      4'd2: mondo_data  = mrqq_rdata_data[111:104];
      4'd3: mondo_data  = mrqq_rdata_data[103: 96];
      4'd4: mondo_data  = mrqq_rdata_data[ 95: 88];
      4'd5: mondo_data  = mrqq_rdata_data[ 87: 80];
      4'd6: mondo_data  = mrqq_rdata_data[ 79: 72];
      4'd7: mondo_data  = mrqq_rdata_data[ 71: 64];
      4'd8: mondo_data  = mrqq_rdata_data[ 63: 56];
      4'd9: mondo_data  = mrqq_rdata_data[ 55: 48];
      4'd10: mondo_data = mrqq_rdata_data[ 47: 40];
      4'd11: mondo_data = mrqq_rdata_data[ 39: 32];
      4'd12: mondo_data = mrqq_rdata_data[ 31: 24];
      4'd13: mondo_data = mrqq_rdata_data[ 23: 16];
      4'd14: mondo_data = mrqq_rdata_data[ 15:  8];
      4'd15: mondo_data = mrqq_rdata_data[  7:  0];
      default: mondo_data = {8{1'bx}};
   endcase
end

assign next_jbi_iob_mondo_vld =  (pop_sm[POP_HDR0_BIT] & mrqq_drdy & ~mrqq_rdata[`JBI_MRQQ_ERR])  //next_pop_sm==POP_HDR1
				| pop_sm[POP_HDR1_BIT]
                                | pop_sm[POP_DATA_BIT];

always @ ( /*AUTOSENSE*/mondo_data or mrqq_rdata or pop_sm) begin
   if (pop_sm[POP_HDR0_BIT])
      next_jbi_iob_mondo_data = {{`JBI_IOB_MONDO_RSV1_WIDTH{1'b0}},
				 mrqq_rdata[`JBI_MRQQ_CPUID_HI:`JBI_MRQQ_CPUID_LO]};
   else if (pop_sm[POP_HDR1_BIT])
      next_jbi_iob_mondo_data = {{`JBI_IOB_MONDO_RSV0_WIDTH{1'b0}},
				 mrqq_rdata[`JBI_MRQQ_AGTID_HI:`JBI_MRQQ_AGTID_LO]};
   else
      next_jbi_iob_mondo_data = mondo_data;
end


//--------------------------
// Transfer Data to Outbound
//--------------------------

assign makq_push =  pop_sm[POP_HDR1_BIT] 
                  | (pop_sm[POP_HDR0_BIT] & mrqq_drdy & mrqq_rdata[`JBI_MRQQ_ERR]);
assign makq_wdata[`JBI_MAKQ_CPUID_HI:`JBI_MAKQ_CPUID_LO] = mrqq_rdata[`JBI_MRQQ_CPUID_HI:`JBI_MRQQ_CPUID_LO];
assign makq_wdata[`JBI_MAKQ_AGTID_HI:`JBI_MAKQ_AGTID_LO] = mrqq_rdata[`JBI_MRQQ_AGTID_HI:`JBI_MRQQ_AGTID_LO];
assign makq_nack                                         = mrqq_rdata[`JBI_MRQQ_ERR];


//*******************************************************************************
// Mondo Tag Queue
//*******************************************************************************
assign mtag_csn_wr = ~min_mondo_hdr_push;
assign mtag_waddr  = wptr[`JBI_MRQQ_ADDR_WIDTH-1:0];
assign mtag_raddr  = rptr[`JBI_MRQQ_ADDR_WIDTH-1:0];

//*******************************************************************************
// DFF Instantiations
//*******************************************************************************
dff_ns #(`JBI_AD_INT_AGTID_WIDTH) u_dff_agtid_ff
   (.din(next_agtid_ff),
    .clk(clk),
    .q(agtid_ff)
    );

dff_ns #(`JBI_AD_INT_AGTID_WIDTH) u_dff_cpuid_ff
   (.din(next_cpuid_ff),
    .clk(clk),
    .q(cpuid_ff)
    );

dff_ns #(`JBI_IOB_MONDO_BUS_WIDTH) u_dff_jbi_iob_mondo_data
   (.din(next_jbi_iob_mondo_data),
    .clk(clk),
    .q(jbi_iob_mondo_data)
    );

//*******************************************************************************
// DFFRL & DFFSL Instantiations
//*******************************************************************************
dffrl_ns #(POP_SM_WIDTH-1) u_dffrl_pop_sm
   (.din(next_pop_sm[POP_SM_WIDTH-1:1]),
    .clk(clk),
    .rst_l(rst_l),
    .q(pop_sm[POP_SM_WIDTH-1:1])
    );

dffsl_ns #(1) u_dffrl_pop_sm0
   (.din(next_pop_sm[POP_HDR0_BIT]),
    .clk(clk),
    .set_l(rst_l),
    .q(pop_sm[POP_HDR0_BIT])
    );

dffrl_ns #(`JBI_MRQQ_ADDR_WIDTH+1) u_dffrl_wptr
   (.din(next_wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(wptr)
    );

dffrl_ns #(`JBI_MRQQ_ADDR_WIDTH+1) u_dffrl_rptr
   (.din(next_rptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(rptr)
    );

dffrl_ns #(4) u_dffrl_data_cnt
   (.din(next_data_cnt),
    .clk(clk),
    .rst_l(data_cnt_rst_l),
    .q(data_cnt)
    );

dffrl_ns #(1) u_dffrl_jbi_iob_mondo_vld
   (.din(next_jbi_iob_mondo_vld),
    .clk(clk),
    .rst_l(rst_l),
    .q(jbi_iob_mondo_vld)
    );

dffrl_ns #(`JBI_MRQQ_ADDR_WIDTH+1) u_dffrl_wptr_d1
   (.din(wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(wptr_d1)
    );

dffrl_ns #(`JBI_MRQQ_ADDR_WIDTH+1) u_dffrl_wptr_d2
   (.din(wptr_d1),
    .clk(clk),
    .rst_l(rst_l),
    .q(wptr_d2)
    );

dffrl_ns #(1) u_dffrl_iob_jbi_mondo_ack_ff
   (.din(iob_jbi_mondo_ack),
    .clk(clk),
    .rst_l(rst_l),
    .q(iob_jbi_mondo_ack_ff)
    );

dffrl_ns #(1) u_dffrl_iob_jbi_mondo_nack_ff
   (.din(iob_jbi_mondo_nack),
    .clk(clk),
    .rst_l(rst_l),
    .q(iob_jbi_mondo_nack_ff)
    );

//synopsys translate_off

//*******************************************************************************
// Rule Checks
//*******************************************************************************


wire mrqq_empty = rptr == wptr;

wire mrqq_full =   wptr[`JBI_MRQQ_ADDR_WIDTH]     != rptr[`JBI_MRQQ_ADDR_WIDTH]
                 & wptr[`JBI_MRQQ_ADDR_WIDTH-1:0] == rptr[`JBI_MRQQ_ADDR_WIDTH-1:0];

always @ ( /*AUTOSENSE*/min_mondo_data_push or mrqq_full) begin
   @clk;
   if (mrqq_full && min_mondo_data_push)
      $dispmon ("jbi_ncio_mrqq_ctl", 49,"%d %m: ERROR - MRQQ overflow!", $time);
end

always @ ( /*AUTOSENSE*/mrqq_empty or mrqq_pop) begin
   @clk;
   if (mrqq_empty && mrqq_pop)
      $dispmon ("jbi_ncio_mrqq_ctl", 49,"%d %m: ERROR - MRQQ underflow!", $time);
end

//*******************************************************************************
// Event Coverage Signals
//*******************************************************************************

wire ev_mrqq_drdy_stall =  ~(rptr == wptr_d2)
                         & ~mtag_byps
	                 & csr_jbi_config2_ord_int;  // turn off wr-int ordering


//synopsys translate_on


endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
