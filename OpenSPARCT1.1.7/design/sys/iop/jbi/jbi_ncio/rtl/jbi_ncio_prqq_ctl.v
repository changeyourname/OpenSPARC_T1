// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ncio_prqq_ctl.v
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
//  Description:	PIO Control module
//  Top level Module:	jbi_ncio_prqq_ctl
//  Where Instantiated:	jbi_ncio
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

module jbi_ncio_prqq_ctl (/*AUTOARG*/
// Outputs
ncio_csr_write, ncio_csr_write_addr, ncio_csr_write_data, 
ncio_csr_read_addr, ncio_csr_perf_pio_rd_out, ncio_csr_perf_pio_wr, 
ncio_csr_perf_pio_rd_latency, pio_ucbp_req_acpted, ncio_pio_req, 
ncio_pio_req_rw, ncio_pio_req_dest, ncio_pio_ue, ncio_pio_be, 
ncio_pio_ad, ncio_yid, ncio_prqq_level, prqq_csn_wr, prqq_csn_rd, 
prqq_waddr, prqq_wdata, prqq_raddr, prqq_ack, prqq_ack_thr_id, 
prqq_ack_buf_id, prqq_rd16_thr_id, prqq_rd16_buf_id, prqq_stall_rd16, 
// Inputs
clk, rst_l, csr_jbi_config2_max_pio, ucbp_rd_req_vld, 
ucbp_wr_req_vld, ucbp_thr_id_in, ucbp_buf_id_in, ucbp_size_in, 
ucbp_addr_in, ucbp_data_in, ucbp_ack_busy, mout_pio_pop, 
mout_pio_req_adv, prqq_rdata, prtq_decr_rd_pend_cnt, prtq_rcv_rtrn16
);

input clk;
input rst_l;

// CSR Interface
input [3:0] csr_jbi_config2_max_pio;
output 	    ncio_csr_write;
output [`JBI_CSR_ADDR_WIDTH-1:0] ncio_csr_write_addr;
output [`JBI_CSR_WIDTH-1:0] 	 ncio_csr_write_data;
output [`JBI_CSR_ADDR_WIDTH-1:0] ncio_csr_read_addr;
output 				 ncio_csr_perf_pio_rd_out;
output 				 ncio_csr_perf_pio_wr;
output [4:0] 			 ncio_csr_perf_pio_rd_latency;

// ucbp Interface.
input 				     ucbp_rd_req_vld;
input 				     ucbp_wr_req_vld;
input [`UCB_THR_HI-`UCB_THR_LO:0]    ucbp_thr_id_in;
input [`UCB_BUF_HI-`UCB_BUF_LO:0]    ucbp_buf_id_in;
input [`UCB_SIZE_HI-`UCB_SIZE_LO:0]  ucbp_size_in;
input [`UCB_ADDR_HI-`UCB_ADDR_LO:0]  ucbp_addr_in;
input [`UCB_DATA_HI-`UCB_DATA_LO:0]  ucbp_data_in;
input 				     ucbp_ack_busy;
output 				     pio_ucbp_req_acpted;

// Memory Out (mout) Interface
input 				    mout_pio_pop;
input 				    mout_pio_req_adv;
output 				    ncio_pio_req;
output 				    ncio_pio_req_rw;
output [1:0] 			    ncio_pio_req_dest;
output 				    ncio_pio_ue;
output [15:0] 			    ncio_pio_be;
output [63:0] 			    ncio_pio_ad;
output [`JBI_YID_WIDTH-1:0] 	    ncio_yid;
output [`JBI_PRQQ_ADDR_WIDTH:0]     ncio_prqq_level;

//PRQQ Interface
input [`JBI_PRQQ_WIDTH-1:0] 	    prqq_rdata;
output 				    prqq_csn_wr;
output 				    prqq_csn_rd;
output [`JBI_PRQQ_ADDR_WIDTH-1:0]   prqq_waddr;
output [`JBI_PRQQ_WIDTH-1:0] 	    prqq_wdata;
output [`JBI_PRQQ_ADDR_WIDTH-1:0]   prqq_raddr;

// PIO Return Data Queue Interface
input 				    prtq_decr_rd_pend_cnt;
input 				    prtq_rcv_rtrn16; //eco6592
output 				    prqq_ack;
output [`UCB_THR_HI-`UCB_THR_LO:0]  prqq_ack_thr_id;
output [`UCB_BUF_HI-`UCB_BUF_LO:0]  prqq_ack_buf_id;
output [`UCB_THR_HI-`UCB_THR_LO:0]  prqq_rd16_thr_id; //eco6592
output [`UCB_BUF_HI-`UCB_BUF_LO:0]  prqq_rd16_buf_id; //eco6592
output 				    prqq_stall_rd16;  //eco6592


////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 				    ncio_csr_write;
wire [`JBI_CSR_ADDR_WIDTH-1:0] 	    ncio_csr_write_addr;
wire [`JBI_CSR_ADDR_WIDTH-1:0] 	    ncio_csr_read_addr;
wire 				    ncio_csr_perf_pio_rd_out;
wire 				    ncio_csr_perf_pio_wr;
wire [4:0] 			    ncio_csr_perf_pio_rd_latency;
wire 				    pio_ucbp_req_acpted;
wire 				    ncio_pio_req;
wire 				    ncio_pio_req_rw;
wire [1:0] 			    ncio_pio_req_dest;
wire 				    ncio_pio_ue;
reg [15:0] 			    ncio_pio_be;
wire [63:0] 			    ncio_pio_ad;
wire [`JBI_YID_WIDTH-1:0] 	    ncio_yid;
wire [`JBI_PRQQ_ADDR_WIDTH:0] 	    ncio_prqq_level;
wire 				    prqq_csn_wr;
wire 				    prqq_csn_rd;
wire [`JBI_PRQQ_ADDR_WIDTH-1:0]     prqq_waddr;
wire [`JBI_PRQQ_WIDTH-1:0] 	    prqq_wdata;
wire [`JBI_PRQQ_ADDR_WIDTH-1:0]     prqq_raddr;
wire 				    prqq_ack;
wire [`UCB_THR_HI-`UCB_THR_LO:0]    prqq_ack_thr_id;
wire [`UCB_BUF_HI-`UCB_BUF_LO:0]    prqq_ack_buf_id;
wire [`UCB_THR_HI-`UCB_THR_LO:0]    prqq_rd16_thr_id; //eco6592
wire [`UCB_BUF_HI-`UCB_BUF_LO:0]    prqq_rd16_buf_id; //eco6592
wire 				    prqq_stall_rd16;  //eco6592


////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
parameter PUSH_IDLE = 2'b00,
	  PUSH_HDR  = 2'b01,
	  PUSH_DATA = 2'b10,
	  PUSH_HDR_BIT  = 0,
	  PUSH_DATA_BIT = 1,
	  PUSH_SM_WIDTH = 2;

wire [PUSH_SM_WIDTH-1:0] push_sm;
wire [`JBI_PRQQ_ADDR_WIDTH:0] wptr;
wire [`JBI_PRQQ_ADDR_WIDTH:0] rptr;
wire [`JBI_PRQQ_ADDR_WIDTH:0] level;
wire [`JBI_PRQQ_ADDR_WIDTH:0] entry_wptr;
wire [`JBI_PRQQ_ADDR_WIDTH:0] entry_rptr;
wire [`JBI_PRQQ_DEPTH-1:0]    entry_rw;
wire [`JBI_PRQQ_DEPTH-1:0]    entry_dest0;
wire [`JBI_PRQQ_DEPTH-1:0]    entry_dest1;
wire [`JBI_PRQQ_ADDR_WIDTH:0] rd_pend_cnt;
reg [PUSH_SM_WIDTH-1:0]       next_push_sm;
reg [`JBI_PRQQ_ADDR_WIDTH:0]  next_wptr;
reg [`JBI_PRQQ_ADDR_WIDTH:0]  next_rptr;
reg [`JBI_PRQQ_ADDR_WIDTH:0]  next_level;
reg [`JBI_PRQQ_ADDR_WIDTH:0]  next_entry_wptr;
reg [`JBI_PRQQ_ADDR_WIDTH:0]  next_entry_rptr;
reg [`JBI_PRQQ_DEPTH-1:0]     next_entry_rw;
reg [`JBI_PRQQ_DEPTH-1:0]     next_entry_dest0;
reg [`JBI_PRQQ_DEPTH-1:0]     next_entry_dest1;
reg [`JBI_PRQQ_ADDR_WIDTH:0]  next_rd_pend_cnt;

wire 			      next_ncio_csr_perf_pio_rd_out;
wire 			      next_ncio_csr_perf_pio_wr;

wire 			      prqq_push;
reg [42:0] 		      addr;
reg [63:0] 		      data;

wire 			      prqq_push_hdr;
wire 			      prqq_push_data;
wire 			      prqq_full;

wire [`UCB_SIZE_WIDTH-1:0]    pio_size;
wire 			      pio_dword;
wire 			      pio_word;
reg [7:0] 		      pre_be;
wire [7:0] 		      shift_be;

wire 			      incr_rd_pend_cnt;
wire 			      stall_rd;
reg [1:0] 		      dest;

wire [`JBI_PRQQ_ADDR_WIDTH:0] entry_wptr_d1;

wire 			      csr_addr_match;

//eco6592
wire [`JBI_PRQQ_DEPTH-1:0]    entry_dword;
reg [`JBI_PRQQ_DEPTH-1:0]     next_entry_dword;
wire 			      next_prqq_stall_rd16;
reg [`UCB_THR_HI-`UCB_THR_LO:0] next_prqq_rd16_thr_id;
reg [`UCB_BUF_HI-`UCB_BUF_LO:0] next_prqq_rd16_buf_id;
wire 				prqq_stall_rd16_rst_l;
wire 				pio_req_dword;

//
// Code start here 
//

//*******************************************************************************
// Push Transaction into Request Queue
//*******************************************************************************
//-------------------
// Push State Machine
//-------------------

always @ ( /*AUTOSENSE*/csr_addr_match or prqq_full or push_sm
	  or ucbp_rd_req_vld or ucbp_wr_req_vld) begin
   case (push_sm)
      PUSH_IDLE: begin
	 if (~prqq_full
	     & ~csr_addr_match
	     & (ucbp_wr_req_vld | ucbp_rd_req_vld))
	    next_push_sm = PUSH_HDR;
	 else
	    next_push_sm = PUSH_IDLE;
      end

      PUSH_HDR: begin
	 if (ucbp_wr_req_vld)
	    next_push_sm = PUSH_DATA;
	 else
	    next_push_sm = PUSH_IDLE;
      end

      PUSH_DATA: next_push_sm = PUSH_IDLE;

// CoverMeter line_off
      default: begin
	 next_push_sm = {PUSH_SM_WIDTH{1'bx}};
	 //synopsys translate_off
	 $dispmon ("jbi_ncio_prqq_ctl", 49,"%d %m: push_sm = %b", $time, push_sm);
	 //synopsys translate_on
      end
// CoverMeter line_on
   endcase
end

assign pio_ucbp_req_acpted =  (push_sm[PUSH_HDR_BIT] & ~ucbp_wr_req_vld)
                            | push_sm[PUSH_DATA_BIT]
                            | (~ucbp_ack_busy & prqq_ack)
                            | (push_sm == PUSH_IDLE & ucbp_wr_req_vld & csr_addr_match);
                              //accept all writes; drop if appropriate

//-------------------
// Push Data
//-------------------
assign prqq_push_hdr  = push_sm[PUSH_HDR_BIT] & ~csr_addr_match;
assign prqq_push_data = push_sm[PUSH_DATA_BIT];
assign prqq_push      = prqq_push_hdr | prqq_push_data;

assign prqq_csn_wr = ~prqq_push;

always @ ( /*AUTOSENSE*/ucbp_addr_in) begin
   if (ucbp_addr_in[39:32] == 8'h80) begin
      if (ucbp_addr_in[31:28] == 4'h0) begin
	  addr[42:0] = { 15'h400_0, ucbp_addr_in[27:0]};  //ucbp_addr_in[39:24] == 16'h80_0E | 16'h80_0F
	 if (ucbp_addr_in[27:24] == 4'hE)
	    dest = `JBI_PRQQ_DEST_4;
	 else if (ucbp_addr_in[27:24] == 4'hF)
	    dest = `JBI_PRQQ_DEST_5;
	 else
	    dest = `JBI_PRQQ_DEST_OTH;
      end
      else begin
	 addr[42:0] = { 11'h600, ucbp_addr_in[31:0] };   //ucbp_addr_in[39:28] == 12'h80_1 to 12'h80_F
	 dest = `JBI_PRQQ_DEST_0;
      end
   end
   else begin
      addr[42:0] = { 3'h7, ucbp_addr_in[39:0] };       
      if (ucbp_addr_in[39:38] == 2'b11) begin            //ucbp_addr_in[39:36] == 4'hC | 4'hD | 4'hE | 4'hF
	 if (ucbp_addr_in[37])
	    dest = `JBI_PRQQ_DEST_5;
	 else
	    dest = `JBI_PRQQ_DEST_4;
      end
      else
	 dest = `JBI_PRQQ_DEST_OTH;                     // all other unmapped
   end
end

always @ ( /*AUTOSENSE*/addr or push_sm or ucbp_data_in) begin
   if (push_sm[PUSH_DATA_BIT])
      data = ucbp_data_in;
   else
      data = { {21{1'b0}}, addr[42:0] }; 
end

assign prqq_wdata[`JBI_PRQQ_D_HI:`JBI_PRQQ_D_LO]     = data;
assign prqq_wdata[`JBI_PRQQ_THR_HI:`JBI_PRQQ_THR_LO] = ucbp_thr_id_in;
assign prqq_wdata[`JBI_PRQQ_BUF_HI:`JBI_PRQQ_BUF_LO] = ucbp_buf_id_in;
assign prqq_wdata[`JBI_PRQQ_DWORD]                   = ucbp_size_in == `UCB_SIZE_16B;
assign prqq_wdata[`JBI_PRQQ_WORD]                    = ucbp_addr_in[3];
assign prqq_wdata[`JBI_PRQQ_SZ_HI:`JBI_PRQQ_SZ_LO]   = ucbp_size_in;

assign prqq_waddr = wptr[`JBI_PRQQ_ADDR_WIDTH-1:0];

//-------------------
// Pointer Management
//-------------------
always @ ( /*AUTOSENSE*/prqq_push or wptr) begin
   if (prqq_push)
      next_wptr = wptr + 1'b1;
   else
      next_wptr = wptr;
end


//-------------------
// Pointer Management
//-------------------
always @ ( /*AUTOSENSE*/level or mout_pio_pop or prqq_push) begin
   case ({prqq_push, mout_pio_pop})
      2'b00,
      2'b11: next_level = level;
      2'b01: next_level = level - 1'b1;
      2'b10: next_level = level + 1'b1;
      default: next_level = {`JBI_PRQQ_ADDR_WIDTH+1{1'bx}};
   endcase
end

assign prqq_full =  level > 5'd14;
assign ncio_prqq_level = level;

//-------------------
// CSR Management
//-------------------
assign csr_addr_match = ucbp_addr_in[39:24] == 16'h80_00;

assign ncio_csr_write =   push_sm == PUSH_IDLE
                        & ucbp_wr_req_vld 
                        & csr_addr_match;
assign ncio_csr_write_addr = ucbp_addr_in[`JBI_CSR_ADDR_WIDTH-1:0];
assign ncio_csr_write_data = ucbp_data_in[`JBI_CSR_WIDTH-1:0];

assign ncio_csr_read_addr  = ucbp_addr_in[`JBI_CSR_ADDR_WIDTH-1:0];

// immediately request prtq to ack a csr read
assign prqq_ack = push_sm == PUSH_IDLE
                  & ucbp_rd_req_vld 
                  & csr_addr_match;
assign prqq_ack_thr_id = ucbp_thr_id_in;
assign prqq_ack_buf_id = ucbp_buf_id_in;

//*******************************************************************************
// PIO Req
// - A separate JBI_PRQQ_DEPTHx2 array kepts track if the entry is a read or write,
//   and destination.  Logic steps thru each entry  and determines 
//   if each entry is an "issue-able" transaction and conveys that info to mout.
//   An entry is not "issue-able" if it is a read and the max number of outstanding 
//   PIO reads is reached.  The logic will stall an unissueable read until it can be
//   issued.
//*******************************************************************************

//-------------------
// Push
//-------------------
always @ ( /*AUTOSENSE*/entry_rw or entry_wptr or prqq_push_hdr
	  or ucbp_rd_req_vld) begin
   next_entry_rw = entry_rw;
   if (prqq_push_hdr)
      next_entry_rw[entry_wptr[`JBI_PRQQ_ADDR_WIDTH-1:0]] = ucbp_rd_req_vld;
end

//eco6592
always @ ( /*AUTOSENSE*/entry_dword or entry_wptr or prqq_push_hdr
	  or prqq_wdata) begin
   next_entry_dword = entry_dword;
   if (prqq_push_hdr)
      next_entry_dword[entry_wptr[`JBI_PRQQ_ADDR_WIDTH-1:0]] = prqq_wdata[`JBI_PRQQ_DWORD];
end

always @ ( /*AUTOSENSE*/dest or entry_dest0 or entry_wptr
	  or prqq_push_hdr) begin
   next_entry_dest0 = entry_dest0;
   if (prqq_push_hdr)
      next_entry_dest0[entry_wptr[`JBI_PRQQ_ADDR_WIDTH-1:0]] = dest[0];
end

always @ ( /*AUTOSENSE*/dest or entry_dest1 or entry_wptr
	  or prqq_push_hdr) begin
   next_entry_dest1 = entry_dest1;
   if (prqq_push_hdr)
      next_entry_dest1[entry_wptr[`JBI_PRQQ_ADDR_WIDTH-1:0]] = dest[1];
end

always @ ( /*AUTOSENSE*/entry_wptr or prqq_push_hdr) begin
   if (prqq_push_hdr)
      next_entry_wptr = entry_wptr + 1'b1;
   else
      next_entry_wptr = entry_wptr;
end


//-------------------
// Pop
//-------------------
always @ ( /*AUTOSENSE*/entry_rptr or mout_pio_req_adv) begin
   if (mout_pio_req_adv)  //advance to next txn
      next_entry_rptr = entry_rptr + 1'b1;
   else
      next_entry_rptr = entry_rptr;
end

assign ncio_pio_req_rw = entry_rw[entry_rptr[`JBI_PRQQ_ADDR_WIDTH-1:0]];
assign ncio_pio_req_dest = { entry_dest1[entry_rptr[`JBI_PRQQ_ADDR_WIDTH-1:0]],
			     entry_dest0[entry_rptr[`JBI_PRQQ_ADDR_WIDTH-1:0]] };

assign pio_req_dword = entry_dword[entry_rptr[`JBI_PRQQ_ADDR_WIDTH-1:0]]; //eco6592
assign ncio_pio_req =  entry_rptr != entry_wptr_d1
                     & ~(ncio_pio_req_rw
			 & (stall_rd
			    | (prqq_stall_rd16 & pio_req_dword)));  //eco6592
                      //& ~(ncio_pio_req_rw & stall_rd);
                      

//*******************************************************************************
// Pop Transaction from Request Queue
//*******************************************************************************
assign ncio_pio_ad = prqq_rdata[`JBI_PRQQ_D_HI:`JBI_PRQQ_D_LO];
assign ncio_yid    = prqq_rdata[`JBI_PRQQ_YID_HI:`JBI_PRQQ_YID_LO];
assign ncio_pio_ue = 1'b0;

assign pio_size = prqq_rdata[`JBI_PRQQ_SZ_HI:`JBI_PRQQ_SZ_LO];
assign pio_dword = prqq_rdata[`JBI_PRQQ_DWORD];
assign pio_word  = prqq_rdata[`JBI_PRQQ_WORD];

always @ ( /*AUTOSENSE*/pio_size) begin
   case (pio_size)
      `UCB_SIZE_1B: pre_be = 8'h01;
      `UCB_SIZE_2B: pre_be = 8'h03;
      `UCB_SIZE_4B: pre_be = 8'h0f;
      default: pre_be = 8'hff;
   endcase
end

assign shift_be = pre_be << ncio_pio_ad[2:0];

always @ ( /*AUTOSENSE*/pio_dword or pio_word or shift_be) begin
   if (pio_dword)
      ncio_pio_be = 16'hffff;
   else begin
      if (pio_word)
	 ncio_pio_be = {shift_be, 8'h00};
      else
	 ncio_pio_be = {8'h00, shift_be};
   end
end


//-------------------
// Pointer Management
//-------------------
always @ ( /*AUTOSENSE*/mout_pio_pop or rptr) begin
   if (mout_pio_pop)
      next_rptr = rptr + 1'b1;
   else
      next_rptr = rptr;
end

// account for 2 cycle delay in csn_wr assertion and propagation to rdata
//assign prqq_drdy = ~(rptr == wptr_d1);
//assign ncio_pio_req = prqq_drdy
//                      & ~(prtq_stall_pio_rd & ncio_pio_rw);

assign prqq_raddr = next_rptr[`JBI_PRQQ_ADDR_WIDTH-1:0];
assign prqq_csn_rd = next_rptr == wptr;

//*******************************************************************************
// Flow Control
// - must guarantee space for read returns
// - stall issuing reads if reached max outstanding pio reads
// - stall issuing 16-byte reads if one is already outstanding
//*******************************************************************************

assign incr_rd_pend_cnt =   mout_pio_req_adv
                          & ncio_pio_req_rw;

always @ ( /*AUTOSENSE*/incr_rd_pend_cnt or prtq_decr_rd_pend_cnt
	  or rd_pend_cnt) begin
   if (rd_pend_cnt == {`JBI_PRTQ_ADDR_WIDTH+1{1'b0}}
       & prtq_decr_rd_pend_cnt)
      next_rd_pend_cnt = rd_pend_cnt;
   else begin
      case ({incr_rd_pend_cnt, prtq_decr_rd_pend_cnt})
	 2'b00,
	 2'b11: next_rd_pend_cnt = rd_pend_cnt;
	 2'b01: next_rd_pend_cnt = rd_pend_cnt - 1'b1;
	 2'b10: next_rd_pend_cnt = rd_pend_cnt + 1'b1;
	 default: next_rd_pend_cnt = {`JBI_PRTQ_ADDR_WIDTH+1{1'bx}};
      endcase
   end
end

assign stall_rd = rd_pend_cnt > {1'b0, csr_jbi_config2_max_pio};

//eco6592
assign prqq_stall_rd16_rst_l = rst_l & ~(prqq_stall_rd16 & prtq_rcv_rtrn16);
assign next_prqq_stall_rd16 =  (mout_pio_req_adv & pio_req_dword & ncio_pio_req_rw)
                             | prqq_stall_rd16;
always @ ( /*AUTOSENSE*/mout_pio_req_adv or ncio_pio_req_rw
	  or pio_req_dword or prqq_rd16_buf_id or prqq_rd16_thr_id
	  or prqq_rdata) begin
   if (mout_pio_req_adv & pio_req_dword & ncio_pio_req_rw) begin
      next_prqq_rd16_thr_id = prqq_rdata[`JBI_PRQQ_THR_HI:`JBI_PRQQ_THR_LO];
      next_prqq_rd16_buf_id = prqq_rdata[`JBI_PRQQ_BUF_HI:`JBI_PRQQ_BUF_LO];
   end
   else begin
      next_prqq_rd16_thr_id = prqq_rd16_thr_id;
      next_prqq_rd16_buf_id = prqq_rd16_buf_id;
   end
end


//*******************************************************************************
// Performance Counter
//*******************************************************************************

// PIO Read Transactions
assign next_ncio_csr_perf_pio_rd_out = mout_pio_req_adv &  ncio_pio_req_rw;

// PIO Write Transactions
assign next_ncio_csr_perf_pio_wr     = mout_pio_req_adv & ~ncio_pio_req_rw;

// PIO Read Latency
assign ncio_csr_perf_pio_rd_latency = rd_pend_cnt[4:0];
      
//*******************************************************************************
// DFF Instantiations
//*******************************************************************************
dff_ns #(`JBI_PRQQ_ADDR_WIDTH+1) u_dff_entry_wptr_d1
   (.din(entry_wptr),
    .clk(clk),
    .q(entry_wptr_d1)
    );

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************
dffrl_ns #(PUSH_SM_WIDTH) u_dffrl_push_sm
   (.din(next_push_sm),
    .clk(clk),
    .rst_l(rst_l),
    .q(push_sm)
    );

dffrl_ns #(`JBI_PRQQ_ADDR_WIDTH+1) u_dffrl_wptr
   (.din(next_wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(wptr)
    );

dffrl_ns #(`JBI_PRQQ_ADDR_WIDTH+1) u_dffrl_rptr
   (.din(next_rptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(rptr)
    );

dffrl_ns #(`JBI_PRQQ_ADDR_WIDTH+1) u_dffrl_level
   (.din(next_level),
    .clk(clk),
    .rst_l(rst_l),
    .q(level)
    );

dffrl_ns #(`JBI_PRQQ_ADDR_WIDTH+1) u_dffrl_entry_wptr
   (.din(next_entry_wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(entry_wptr)
    );

dffrl_ns #(`JBI_PRQQ_ADDR_WIDTH+1) u_dffrl_entry_rptr
   (.din(next_entry_rptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(entry_rptr)
    );

dffrl_ns #(`JBI_PRQQ_DEPTH) u_dffrl_entry_rw
   (.din(next_entry_rw),
    .clk(clk),
    .rst_l(rst_l),
    .q(entry_rw)
    );

dffrl_ns #(`JBI_PRQQ_DEPTH) u_dffrl_entry_dest0
   (.din(next_entry_dest0),
    .clk(clk),
    .rst_l(rst_l),
    .q(entry_dest0)
    );

dffrl_ns #(`JBI_PRQQ_DEPTH) u_dffrl_entry_dest1
   (.din(next_entry_dest1),
    .clk(clk),
    .rst_l(rst_l),
    .q(entry_dest1)
    );

dffrl_ns #(`JBI_PRTQ_ADDR_WIDTH+1) u_dffrl_rd_pend_cnt
   (.din(next_rd_pend_cnt),
    .clk(clk),
    .rst_l(rst_l),
    .q(rd_pend_cnt)
    );

dffrl_ns #(1) u_dffrl_ncio_csr_perf_pio_rd_out
   (.din(next_ncio_csr_perf_pio_rd_out),
    .clk(clk),
    .rst_l(rst_l),
    .q(ncio_csr_perf_pio_rd_out)
    );

dffrl_ns #(1) u_dffrl_ncio_csr_perf_pio_wr
   (.din(next_ncio_csr_perf_pio_wr),
    .clk(clk),
    .rst_l(rst_l),
    .q(ncio_csr_perf_pio_wr)
    );

//eco6592
dffrl_ns #(`JBI_PRQQ_DEPTH) u_dffrl_entry_dword_eco6592
   (.din(next_entry_dword),
    .clk(clk),
    .rst_l(rst_l),
    .q(entry_dword)
    );

dffrl_ns #(1) u_dffrl_prqq_stall_rd16_eco6592
   (.din(next_prqq_stall_rd16),
    .clk(clk),
    .rst_l(prqq_stall_rd16_rst_l),
    .q(prqq_stall_rd16)
    );

dffrl_ns #(`UCB_THR_HI-`UCB_THR_LO+1) u_dffrl_prqq_rd16_thr_id_eco6592
   (.din(next_prqq_rd16_thr_id),
    .clk(clk),
    .rst_l(rst_l),
    .q(prqq_rd16_thr_id)
    );

dffrl_ns #(`UCB_BUF_HI-`UCB_BUF_LO+1) u_dffrl_prqq_rd16_buf_id_eco6592
   (.din(next_prqq_rd16_buf_id),
    .clk(clk),
    .rst_l(rst_l),
    .q(prqq_rd16_buf_id)
    );


//synopsys translate_off

//*******************************************************************************
// Rule Checks
//*******************************************************************************


wire rc_prqq_empty = rptr == wptr;
wire rc_prqq_full =  wptr[`JBI_PRQQ_ADDR_WIDTH]     != rptr[`JBI_PRQQ_ADDR_WIDTH]
                   & wptr[`JBI_PRQQ_ADDR_WIDTH-1:0] == rptr[`JBI_PRQQ_ADDR_WIDTH-1:0];


always @ ( /*AUTOSENSE*/prqq_push or rc_prqq_full) begin
   @clk;
   if (rc_prqq_full && prqq_push)
      $dispmon ("jbi_ncio_prqq_ctl", 49,"%d %m: ERROR - PRQQ overflow!", $time);
end

always @ ( /*AUTOSENSE*/mout_pio_pop or rc_prqq_empty) begin
   @clk;
   if (rc_prqq_empty && mout_pio_pop)
      $dispmon ("jbi_ncio_prqq_ctl", 49,"%d %m: ERROR - PRQQ underflow!", $time);
end

// account for 2 cycle delay in csn_wr assertion and propagation to rdata
reg [`JBI_PRQQ_ADDR_WIDTH:0] wptr_d1;
always @ (posedge clk) begin
   wptr_d1 <= wptr;
end

wire rc_prqq_drdy = ~(rptr == wptr_d1);
always @ ( /*AUTOSENSE*/mout_pio_pop or rc_prqq_drdy) begin
   @clk;
   if (mout_pio_pop & ~rc_prqq_drdy)
      $dispmon ("jbi_ncio_prqq_ctl", 49,"%d %m: ERROR - mout pops txn before data is ready", $time);
end

always @ ( /*AUTOSENSE*/push_sm or ucbp_addr_in or ucbp_rd_req_vld
	  or ucbp_wr_req_vld) begin
   @clk;
   if (push_sm == PUSH_IDLE
       && (ucbp_wr_req_vld || ucbp_rd_req_vld)
       && (   (   ucbp_addr_in[39:28] == 16'h80_0
	       && ucbp_addr_in[27:24] != 4'h0
	       && ucbp_addr_in[27:24] != 4'hE
	       && ucbp_addr_in[27:24] != 4'hF)
           || (   ucbp_addr_in[39:32] != 8'h80
	       && ucbp_addr_in[39:38] != 2'b11)
	   || ucbp_addr_in[39:32] == 8'hFF ))
      $dispmon ("jbi_ncio_prqq_ctl", 0,"%d %m: WARNING - IOB request to unexpected address 0x%x",
		$time,  ucbp_addr_in[39:0]);
end

always @ ( /*AUTOSENSE*/prtq_decr_rd_pend_cnt or rd_pend_cnt) begin
   @clk;
   if (rd_pend_cnt == 5'd0 & prtq_decr_rd_pend_cnt)
      $dispmon ("jbi_ncio_prtq_ctl", 49,"%d %m: ERROR - PIO Read Pend Count underflow!", $time);
end

always @ ( /*AUTOSENSE*/incr_rd_pend_cnt or rd_pend_cnt) begin
   @clk;
   if (&rd_pend_cnt & incr_rd_pend_cnt)
      $dispmon ("jbi_ncio_prtq_ctl", 49,"%d %m: ERROR - PIO Read Pend Count overflow!", $time);
end

//*******************************************************************************
// Event Coverage Signals
//*******************************************************************************

wire ec_entry_drdy = entry_rptr != entry_wptr_d1;

//synopsys translate_on

endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
