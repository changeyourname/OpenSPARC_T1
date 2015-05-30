// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncio_prtq_ctl.v
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
//  Description:	PIO Return Queue Control
//  Top level Module:	jbi_ncio_prtq_ctl
//  Where Instantiated:	jbi_ncio
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

module jbi_ncio_prtq_ctl (/*AUTOARG*/
// Outputs
prtq_rd_ack_vld, prtq_rd_nack_vld, prtq_thr_id_out, prtq_buf_id_out, 
prtq_data_out, prtq_data128, prtq_int_vld, prtq_int_type, 
prtq_dev_id, ncio_mout_nack_pop, prtq_csn_wr, prtq_csn_rd, 
prtq_waddr, prtq_wdata, prtq_raddr, prtq_decr_rd_pend_cnt, 
prtq_rcv_rtrn16, 
// Inputs
clk, rst_l, csr_jbi_config2_ord_pio, csr_csr_read_data, csr_int_req, 
ucbp_ack_busy, io_jbi_j_ad_ff, min_pio_rtrn_push, min_pio_data_err, 
mout_trans_yid, mout_nack, mout_nack_thr_id, mout_nack_buf_id, 
prtq_rdata, prtq_tag_byps, prqq_ack, prqq_ack_thr_id, 
prqq_ack_buf_id, prqq_stall_rd16, prqq_rd16_thr_id, prqq_rd16_buf_id
);

input clk;
input rst_l;

// CSR Interface
input csr_jbi_config2_ord_pio;
input [`JBI_CSR_WIDTH-1:0] csr_csr_read_data;
input 			   csr_int_req;

// ucbp Interface.
output 			   prtq_rd_ack_vld;
output 			   prtq_rd_nack_vld;
output [`UCB_THR_HI-`UCB_THR_LO:0] prtq_thr_id_out;
output [`UCB_BUF_HI-`UCB_BUF_LO:0] prtq_buf_id_out;
output [127:0] 			   prtq_data_out;
output  			   prtq_data128;
output 				   prtq_int_vld;
output [`UCB_PKT_WIDTH-1:0] 	   prtq_int_type;
output [`UCB_INT_DEV_WIDTH-1:0]    prtq_dev_id;
input 				   ucbp_ack_busy;


// Memory In (min)  Interface
input [127:0] 			   io_jbi_j_ad_ff;    
input 				   min_pio_rtrn_push;
input 				   min_pio_data_err;

// Memory Out (mout) Interface
input [`JBI_YID_WIDTH-1:0] 	   mout_trans_yid;
input 				   mout_nack;
input [`UCB_THR_HI-`UCB_THR_LO:0]  mout_nack_thr_id;
input [`UCB_BUF_HI-`UCB_BUF_LO:0]  mout_nack_buf_id;
output 				   ncio_mout_nack_pop;

//PRTQ Interface
input [`JBI_PRTQ_WIDTH-1:0] 	   prtq_rdata;
input 				   prtq_tag_byps;
output 				   prtq_csn_wr;
output 				   prtq_csn_rd;
output [`JBI_PRTQ_ADDR_WIDTH-1:0]  prtq_waddr;
output [`JBI_PRTQ_WIDTH-1:0] 	   prtq_wdata;
output [`JBI_PRTQ_ADDR_WIDTH-1:0]  prtq_raddr;

// PRQQ Interface
input 				   prqq_ack;
input [`UCB_THR_HI-`UCB_THR_LO:0]  prqq_ack_thr_id;
input [`UCB_BUF_HI-`UCB_BUF_LO:0]  prqq_ack_buf_id;
input 				   prqq_stall_rd16;  //eco6592
input [`UCB_THR_HI-`UCB_THR_LO:0]  prqq_rd16_thr_id; //eco6592
input [`UCB_BUF_HI-`UCB_BUF_LO:0]  prqq_rd16_buf_id; //eco6592
output 				   prtq_decr_rd_pend_cnt;
output 				   prtq_rcv_rtrn16;  //eco6592

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
reg 				   prtq_rd_ack_vld;
reg 				   prtq_rd_nack_vld;
reg [`UCB_THR_HI-`UCB_THR_LO:0]    prtq_thr_id_out;
reg [`UCB_BUF_HI-`UCB_BUF_LO:0]    prtq_buf_id_out;
reg [127:0] 			   prtq_data_out;
wire 				   prtq_data128;
wire 				   prtq_int_vld;
wire [`UCB_PKT_WIDTH-1:0] 	   prtq_int_type;
wire [`UCB_INT_DEV_WIDTH-1:0] 	   prtq_dev_id;
wire 				   prtq_csn_wr;
wire 				   prtq_csn_rd;
wire [`JBI_PRTQ_ADDR_WIDTH-1:0]    prtq_waddr;
wire [`JBI_PRTQ_WIDTH-1:0] 	   prtq_wdata;
wire [`JBI_PRTQ_ADDR_WIDTH-1:0]    prtq_raddr;
wire 				   prtq_decr_rd_pend_cnt;
wire 				   prtq_rcv_rtrn16;  //eco6592

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

parameter POP_IDLE = 1'b0,
	  POP_WAIT = 1'b1;

wire pop_sm;
wire [`JBI_PRTQ_ADDR_WIDTH:0] wptr;
wire [`JBI_PRTQ_ADDR_WIDTH:0] rptr;
reg 			      next_pop_sm;
reg [`JBI_PRTQ_ADDR_WIDTH:0]  next_wptr;
reg [`JBI_PRTQ_ADDR_WIDTH:0]  next_rptr;

wire [`JBI_PRTQ_ADDR_WIDTH:0] wptr_d1;
wire [`JBI_PRTQ_ADDR_WIDTH:0] wptr_d2;
wire 			      prtq_drdy;
wire 			      prtq_pop;

wire 			      prtq_ack;
wire 			      prtq_nack;
reg [127:0] 		      prtq_ack_data;

//
// Code start here 
//

//*******************************************************************************
// Push Transaction Return Queue
//*******************************************************************************

//-------------------
// Write Data
//-------------------
assign prtq_wdata[`JBI_PRTQ_D_HI:`JBI_PRTQ_D_LO]     = io_jbi_j_ad_ff[127:0];
assign prtq_wdata[`JBI_PRTQ_YID_HI:`JBI_PRTQ_YID_LO] = mout_trans_yid;
assign prtq_wdata[`JBI_PRTQ_UE]                      = min_pio_data_err;

assign prtq_waddr = wptr[`JBI_PRTQ_ADDR_WIDTH-1:0];
assign prtq_csn_wr = ~min_pio_rtrn_push;

//-------------------
// Pointer Management
//-------------------
always @ ( /*AUTOSENSE*/min_pio_rtrn_push or wptr) begin
   if (min_pio_rtrn_push)
      next_wptr = wptr + 1'b1;
   else
      next_wptr = wptr;
end

//eco6592
assign prtq_rcv_rtrn16 = min_pio_rtrn_push & prtq_wdata[`JBI_PRTQ_DWORD] //==mout_trans_yid[8]
                        | (  ncio_mout_nack_pop
			   & prqq_stall_rd16
			   & mout_nack_thr_id == prqq_rd16_thr_id
			   & mout_nack_buf_id == prqq_rd16_buf_id);

//*******************************************************************************
// Pop Transaction from Return Queue
//*******************************************************************************

//-------------------
// Pop Data
//-------------------
// because of the delay in pushing an entry and when it actually shows up
// at the flopped output of prtq, need to look delayed versions
assign prtq_drdy = ~(rptr == wptr_d2)
                  & (prtq_tag_byps
		     | ~csr_jbi_config2_ord_pio);  //turn off wr-pio rd return ordering

assign prtq_ack =  pop_sm == POP_IDLE
                 & prtq_drdy
                 & ~prtq_rdata[`JBI_PRTQ_UE];

assign prtq_nack =  pop_sm == POP_IDLE
                  & prtq_drdy
                  & prtq_rdata[`JBI_PRTQ_UE];

always @ ( /*AUTOSENSE*/prtq_rdata) begin
   if (prtq_rdata[`JBI_PRTQ_DWORD])
      prtq_ack_data = prtq_rdata[`JBI_PRTQ_D_HI:`JBI_PRTQ_D_LO];
   else begin
      if (prtq_rdata[`JBI_PRTQ_WORD])
	 prtq_ack_data = {2{prtq_rdata[63:0]}};
      else
	 prtq_ack_data = {2{prtq_rdata[127:64]}};
   end
end // always @ (...

assign prtq_data128 = 1'b1;

always @ ( /*AUTOSENSE*/mout_nack or mout_nack_buf_id
	  or mout_nack_thr_id or prqq_ack or prqq_ack_buf_id
	  or prqq_ack_thr_id or prtq_ack or prtq_nack or prtq_rdata
	  or ucbp_ack_busy) begin
   if (prqq_ack) begin
      prtq_rd_ack_vld  = prqq_ack  & ~ucbp_ack_busy;
      prtq_rd_nack_vld = 1'b0;
      prtq_thr_id_out  = prqq_ack_thr_id;
      prtq_buf_id_out  = prqq_ack_buf_id;
   end
   else if (prtq_ack | prtq_nack) begin
      prtq_rd_ack_vld  = prtq_ack  & ~ucbp_ack_busy;
      prtq_rd_nack_vld = prtq_nack & ~ucbp_ack_busy;
      prtq_thr_id_out  = prtq_rdata[`JBI_PRTQ_THR_HI:`JBI_PRTQ_THR_LO];
      prtq_buf_id_out  = prtq_rdata[`JBI_PRTQ_BUF_HI:`JBI_PRTQ_BUF_LO];
   end
   else begin
      prtq_rd_ack_vld  = 1'b0;
      prtq_rd_nack_vld = mout_nack & ~ucbp_ack_busy;
      prtq_thr_id_out  = mout_nack_thr_id;
      prtq_buf_id_out  = mout_nack_buf_id;
   end      
end

always @ ( /*AUTOSENSE*/csr_csr_read_data or prqq_ack or prtq_ack_data) begin  // mout only nacks which does not have assoc. data
   if (prqq_ack)
      prtq_data_out = {2{csr_csr_read_data}};
   else
      prtq_data_out = prtq_ack_data;
end

assign ncio_mout_nack_pop =  ~prqq_ack
                           & ~(prtq_ack | prtq_nack)
                           & ~ucbp_ack_busy
                           &  mout_nack;

//-------------------
// Pop State Machine
//-------------------

// prqq acks/nacks has priority over prtq acks/nacks
assign prtq_pop =   ~ucbp_ack_busy
                  & ~prqq_ack
                  & (prtq_ack | prtq_nack);

always @ ( /*AUTOSENSE*/pop_sm or prtq_pop) begin
   case (pop_sm)
      POP_IDLE: begin
	 if (prtq_pop)
	    next_pop_sm = POP_WAIT;
	 else
	    next_pop_sm = POP_IDLE;
      end
      POP_WAIT: next_pop_sm = POP_IDLE;
// CoverMeter line_off
      default: begin
	 next_pop_sm = 1'bx;
	 //synopsys translate_off
	 $dispmon ("jbi_ncio_prtq_ctl", 49,"%d %m: pop_sm = %b", $time, pop_sm);
	 //synopsys translate_on
      end
// CoverMeter line_on
   endcase
end

//-------------------
// Pointer Management
//-------------------
always @ ( /*AUTOSENSE*/prtq_pop or rptr) begin
   if (prtq_pop)
      next_rptr = rptr + 1'b1;
   else
      next_rptr = rptr;
end

assign prtq_raddr = next_rptr[`JBI_PRTQ_ADDR_WIDTH-1:0];
assign prtq_csn_rd = next_rptr == wptr;

//*******************************************************************************
// Interrupts
//*******************************************************************************

assign prtq_int_vld  = csr_int_req;
assign prtq_dev_id   = `UCB_INT_DEV_WIDTH'd17;
assign prtq_int_type = `UCB_INT;

//*******************************************************************************
// Flow Control
// - must guarantee space for read returns
//*******************************************************************************

assign prtq_decr_rd_pend_cnt = (prtq_rd_ack_vld & ~prqq_ack)  //do not count csr reads
                              | prtq_rd_nack_vld;

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************
dffrl_ns #(1) u_dffrl_pop_sm
   (.din(next_pop_sm),
    .clk(clk),
    .rst_l(rst_l),
    .q(pop_sm)
    );

dffrl_ns #(`JBI_PRTQ_ADDR_WIDTH+1) u_dffrl_wptr
   (.din(next_wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(wptr)
    );

dffrl_ns #(`JBI_PRTQ_ADDR_WIDTH+1) u_dffrl_rptr
   (.din(next_rptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(rptr)
    );

dffrl_ns #(`JBI_PRTQ_ADDR_WIDTH+1) u_dffrl_wptr_d1
   (.din(wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(wptr_d1)
    );

dffrl_ns #(`JBI_PRTQ_ADDR_WIDTH+1) u_dffrl_wptr_d2
   (.din(wptr_d1),
    .clk(clk),
    .rst_l(rst_l),
    .q(wptr_d2)
    );


//synopsys translate_off

//*******************************************************************************
// Rule Checks
//*******************************************************************************


wire prtq_empty = rptr == wptr;

wire prtq_full =   wptr[`JBI_PRTQ_ADDR_WIDTH]     != rptr[`JBI_PRTQ_ADDR_WIDTH]
                 & wptr[`JBI_PRTQ_ADDR_WIDTH-1:0] == rptr[`JBI_PRTQ_ADDR_WIDTH-1:0];

always @ ( /*AUTOSENSE*/min_pio_rtrn_push or prtq_full) begin
   @clk;
   if (prtq_full && min_pio_rtrn_push)
      $dispmon ("jbi_ncio_prtq_ctl", 49,"%d %m: ERROR - PRTQ overflow!", $time);
end

always @ ( /*AUTOSENSE*/prtq_empty or prtq_pop) begin
   @clk;
   if (prtq_empty && prtq_pop)
      $dispmon ("jbi_ncio_prtq_ctl", 49,"%d %m: ERROR - PRTQ underflow!", $time);
end

//*******************************************************************************
// Event Coverage Signals
//*******************************************************************************

wire ev_prtq_drdy_stall = ~(rptr == wptr_d2)
                          & ~prtq_tag_byps
		          & csr_jbi_config2_ord_pio;
//synopsys translate_on


endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
