// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_wdq_ctl.v
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
//  Description:	Write Decomposition Queue Control
//  Top level Module:	jbi_min_wdq_ctl
//  Where Instantiated:	jbi_min_wdq
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

module jbi_min_wdq_ctl(/*AUTOARG*/
// Outputs
min_csr_perf_dma_wr8, wdq_wr_en, wdq_wdata, wdq_wdata_ecc0, 
wdq_wdata_ecc1, wdq_wdata_ecc2, wdq_wdata_ecc3, wdq_waddr, wdq_rd_en, 
wdq_raddr, wdq_rdq0_push, wdq_rdq1_push, wdq_rdq2_push, 
wdq_rdq3_push, wdq_rdq_wdata, wdq_rhq0_push, wdq_rhq1_push, 
wdq_rhq2_push, wdq_rhq3_push, wdq_rhq_wdata, wdq_rq_tag_byps, 
wdq_wr_vld, min_aok_on, min_aok_off, 
// Inputs
clk, rst_l, csr_jbi_config2_iq_high, csr_jbi_config2_iq_low, 
csr_jbi_config2_ord_wr, csr_jbi_config2_ord_rd, io_jbi_j_ad_ff, 
io_jbi_j_adtype_ff, parse_wdq_push, parse_sctag_req, parse_hdr, 
parse_rw, parse_subline_req, parse_install_mode, parse_data_err, 
parse_err_nonex_rd, rdq0_full, rdq1_full, rdq2_full, rdq3_full, 
wdq_rdata, rhq0_full, rhq1_full, rhq2_full, rhq3_full
);

input clk;
input rst_l;

// CSR Block Interface
input [3:0] csr_jbi_config2_iq_high;
input [3:0] csr_jbi_config2_iq_low;
input 	    csr_jbi_config2_ord_wr;
input 	    csr_jbi_config2_ord_rd;
output 	    min_csr_perf_dma_wr8;

// Parse Block Interface
input [127:0] io_jbi_j_ad_ff;
input [`JBI_ADTYPE_JID_HI:`JBI_ADTYPE_JID_LO] io_jbi_j_adtype_ff;
input 					      parse_wdq_push;
input [2:0] 				      parse_sctag_req;
input 					      parse_hdr;
input 					      parse_rw;
input 					      parse_subline_req;
input 					      parse_install_mode;
input 					      parse_data_err;
input 					      parse_err_nonex_rd;

// WDQ Interface
input 					      rdq0_full;
input 					      rdq1_full;
input 					      rdq2_full;
input 					      rdq3_full;
input [`JBI_WDQ_WIDTH-1:0] 		      wdq_rdata;
output 					      wdq_wr_en;
output [127:0] 				      wdq_wdata;
output [6:0] 				      wdq_wdata_ecc0;
output [6:0] 				      wdq_wdata_ecc1;
output [6:0] 				      wdq_wdata_ecc2;
output [6:0] 				      wdq_wdata_ecc3;
output [`JBI_WDQ_ADDR_WIDTH-1:0] 	      wdq_waddr;
output 					      wdq_rd_en;
output [`JBI_WDQ_ADDR_WIDTH-1:0] 	      wdq_raddr;

// Request Data Queue Interface
output 					      wdq_rdq0_push;
output 					      wdq_rdq1_push;
output 					      wdq_rdq2_push;
output 					      wdq_rdq3_push;
output [`JBI_RDQ_WIDTH-1:0] 		      wdq_rdq_wdata;

// Request Header Queue Interface
input 					      rhq0_full;
input 					      rhq1_full;
input 					      rhq2_full;
input 					      rhq3_full;
output 					      wdq_rhq0_push;
output 					      wdq_rhq1_push;
output 					      wdq_rhq2_push;
output 					      wdq_rhq3_push;
output [`JBI_RHQ_WIDTH-1:0] 		      wdq_rhq_wdata;

// Request Tag Queue Interface
output 					      wdq_rq_tag_byps;

// Write Tracker Interface
output 					      wdq_wr_vld;

// Memory Out Interface
output 					      min_aok_on;
output 					      min_aok_off;

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 					      min_csr_perf_dma_wr8;
wire 					      wdq_wr_en;
reg [127:0] 				      wdq_wdata;
reg [6:0] 				      wdq_wdata_ecc0;
reg [6:0] 				      wdq_wdata_ecc1;
reg [6:0] 				      wdq_wdata_ecc2;
reg [6:0] 				      wdq_wdata_ecc3;
wire [`JBI_WDQ_ADDR_WIDTH-1:0] 		      wdq_waddr;
wire 					      wdq_rd_en;
wire [`JBI_WDQ_ADDR_WIDTH-1:0] 		      wdq_raddr;
wire 					      wdq_rdq0_push;
wire 					      wdq_rdq1_push;
wire 					      wdq_rdq2_push;
wire 					      wdq_rdq3_push;
wire [`JBI_RDQ_WIDTH-1:0] 		      wdq_rdq_wdata;
wire 					      wdq_rhq0_push;
wire 					      wdq_rhq1_push;
wire 					      wdq_rhq2_push;
wire 					      wdq_rhq3_push;
reg [`JBI_RHQ_WIDTH-1:0] 		      wdq_rhq_wdata;
wire 					      wdq_rq_tag_byps;
wire 					      wdq_wr_vld;
wire					      min_aok_on;
wire 					      min_aok_off;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
parameter POP_HDR      = 3'b001,
	  POP_WRI      = 3'b010,
	  POP_WRM      = 3'b100;
parameter POP_HDR_BIT      = 0,
	  POP_WRI_BIT      = 1,
	  POP_WRM_BIT      = 2,
	  POP_SM_WIDTH     = 3;

//
// Code start here 
//

wire [POP_SM_WIDTH-1:0] pop_sm;
wire [`JBI_WDQ_ADDR_WIDTH:0] wptr;
wire [`JBI_WDQ_ADDR_WIDTH:0] rptr;
wire [`JBI_WDQ_ADDR_WIDTH:0] wdq_level;
wire [2:0] 		     wr_word_cnt;
wire [5:3] 		     wrm_addr;
wire [`JBI_WDQ_DEPTH-1:0]    wdq_data_err;
wire 			     tag_byps;
reg [POP_SM_WIDTH-1:0] 	     next_pop_sm;
reg [`JBI_WDQ_ADDR_WIDTH:0]  next_wptr;
reg [`JBI_WDQ_ADDR_WIDTH:0]  next_rptr;
reg  [`JBI_WDQ_ADDR_WIDTH:0] next_wdq_level;
reg [2:0] 		     next_wr_word_cnt;
reg [5:3] 		     next_wrm_addr;
reg [`JBI_WDQ_DEPTH-1:0]     next_wdq_data_err;
reg 			     next_tag_byps;

wire [63:0] 		     pop_hdr;
wire [63:0] 		     wrm_be;
wire [7:0] 		     be;
wire [63:0] 		     next_pop_hdr;
wire [63:0] 		     next_wrm_be;
reg [7:0] 		     next_be;

wire 			     next_min_full;
wire 			     next_min_csr_perf_dma_wr8;

wire 			     pop_hdr_en;
wire 			     wrm_be_en;
wire 			     be_en;
wire 			     wr_word_cnt_rst_l;

wire [`JBI_SCTAG_TAG_WIDTH-1:0] push_hdr_tag;
reg [4:0] 			push_hdr_addr_lo;
wire [63:0] 			push_hdr;
wire 				wdq_drdy;
wire 				wdq_rdata_rw;
wire [`JBI_SCTAG_TAG_WIDTH-1:0] wdq_rdata_tag;
wire [2:0] 			wdq_rdata_req;
reg [7:0] 			be_mask;
reg [2:0] 			size;
wire 				addr2;
reg 				addr1;
reg 				addr0;
wire 				addr1_0;
wire 				addr1_1;
reg 				addr0_0;
reg 				addr0_1;
wire 				addr0_0_0;
wire 				addr0_0_1;
wire 				addr0_1_0;
wire 				addr0_1_1;

wire [2:0] 			wrm_start_addr;
wire 				incr_wr_word_cnt;

wire [63:0] 			wrm_hdr;
wire 				wdq_rdq_push;
wire 				wdq_rhq_push;

wire [`JBI_SCTAG_TAG_WIDTH-1:0] pop_tag;
wire 				wdq_pop;

reg [1:0] 			sctag_num;

wire [`JBI_WDQ_ADDR_WIDTH:0] 	wptr_d1;

reg [1:0] 			stall_sctag_num;
wire 				wdq_stall;

wire 				push_wr8;

wire 				min_full;
wire 				min_full_d1;

wire [6:0] 			ecc0;
wire [6:0] 			ecc1;
wire [6:0] 			ecc2;
wire [6:0] 			ecc3;

wire [`JBI_SCTAG_TAG_WIDTH-1:0] wdq_rhq_wdata_tag;
wire 				wdq_rhq_wdata_rw;

//*******************************************************************************
// Push Inbound Memory Request
//*******************************************************************************

// if read to non-existent memory, treat as subline read to addr zero with
// error bit set in ctag
assign push_hdr_tag[`JBI_SCTAG_TAG_JID_HI:`JBI_SCTAG_TAG_JID_LO] = io_jbi_j_adtype_ff[`JBI_ADTYPE_JID_HI:`JBI_ADTYPE_JID_LO];
assign push_hdr_tag[`JBI_SCTAG_TAG_INSTALL]                      = parse_install_mode;
assign push_hdr_tag[`JBI_SCTAG_TAG_ERR]                          = parse_err_nonex_rd;
assign push_hdr_tag[`JBI_SCTAG_TAG_SUBLINE]                      = parse_subline_req;
assign push_hdr_tag[`JBI_SCTAG_TAG_RW]                           = parse_rw;
assign push_hdr_tag[`JBI_SCTAG_TAG_WIDTH-1:`JBI_SCTAG_TAG_WIDTH-2] = `JBI_CTAG_PRE;

always @ ( /*AUTOSENSE*/io_jbi_j_ad_ff or parse_subline_req) begin
   if (parse_subline_req)
      push_hdr_addr_lo[4:0] = {io_jbi_j_ad_ff[4], 4'd0};
   else
      push_hdr_addr_lo[4:0] = 5'd0;
end

assign push_hdr[`JBI_SCTAG_IN_ADDR_HI:`JBI_SCTAG_IN_ADDR_LO] = {io_jbi_j_ad_ff[39:5], push_hdr_addr_lo[4:0]};
assign push_hdr[`JBI_SCTAG_IN_SZ_HI:`JBI_SCTAG_IN_SZ_LO]     = 3'd0;
assign push_hdr[`JBI_SCTAG_IN_RSV0]                          = 1'b0;
assign push_hdr[`JBI_SCTAG_IN_TAG_HI:`JBI_SCTAG_IN_TAG_LO]   = push_hdr_tag[`JBI_SCTAG_TAG_WIDTH-1:0];
assign push_hdr[`JBI_SCTAG_IN_REQ_HI:`JBI_SCTAG_IN_REQ_LO]   = parse_sctag_req;
assign push_hdr[`JBI_SCTAG_IN_POISON]                        = 1'b0;
assign push_hdr[`JBI_SCTAG_IN_RSV1_HI:`JBI_SCTAG_IN_RSV1_LO] = 4'd0;

//-------------------
// Pointer Management
//-------------------

always @ ( /*AUTOSENSE*/parse_wdq_push or wptr) begin
   if (parse_wdq_push)
      next_wptr = wptr + 1'b1;
   else
      next_wptr = wptr;
end


// Note: Write CS and Addr are registered before connecting to memory element.
//       When parse_wdq_push is asserted, and the data is valid at dout 2 cycles later
//
//                |    0    |    1    |    2    |    3    |    4    |
//                 ____      ____      ____      ____      ____      ____
//             ___/    \____/    \____/    \____/    \____/    \____/    \____
//                  _________
// push        ____/         \________________________________________________
//           ______           _______________________________________
// csn_wr          \_________/
//            ______________           _______________________________________
// csn_wr_ff                \_________/
//             _________________________ _____________________________________
// rdata       _________________________X___Valid__Dout_______________________

always @ ( /*AUTOSENSE*/io_jbi_j_ad_ff or parse_hdr or push_hdr) begin
   if (parse_hdr)
      wdq_wdata = {io_jbi_j_ad_ff[127:64], push_hdr};
   else
      wdq_wdata = io_jbi_j_ad_ff[127:0];
end

assign wdq_waddr = wptr[`JBI_WDQ_ADDR_WIDTH-1:0];
assign wdq_wr_en     = rst_l & parse_wdq_push;

assign wdq_drdy = ~(rptr == wptr_d1);

//-------------------------------------------------------------------------------
// Error Handling
// - for cacheline writes, poison ecc if parity or ue error
//   * cacheline writes goes to dram  vi L2 and L2 checks ecc (over 32 bits
//     before sending it to dram
// - for wr8, ignore ecc and set poison bit in header 
//   * wr8 goes to cache which generates its own ecc, therefore wants poison
//     bit in header and ignores the jbi_scbuf*_ecc
//   * separate err array to keep track of data errors
//-------------------------------------------------------------------------------

/* zzecc_sctag_pgen_32b AUTO_TEMPLATE (
 .dout (),
 .parity (ecc@[]),
 .din (io_jbi_j_ad_ff[((@+1)*32-1):(@*32)]),
 ); */

zzecc_sctag_pgen_32b u_wdq_ecc0 (/*AUTOINST*/
				 // Outputs
				 .dout	(),			 // Templated
				 .parity(ecc0[6:0]),		 // Templated
				 // Inputs
				 .din	(io_jbi_j_ad_ff[((0+1)*32-1):(0*32)])); // Templated
zzecc_sctag_pgen_32b u_wdq_ecc1 (/*AUTOINST*/
				 // Outputs
				 .dout	(),			 // Templated
				 .parity(ecc1[6:0]),		 // Templated
				 // Inputs
				 .din	(io_jbi_j_ad_ff[((1+1)*32-1):(1*32)])); // Templated
zzecc_sctag_pgen_32b u_wdq_ecc2 (/*AUTOINST*/
				 // Outputs
				 .dout	(),			 // Templated
				 .parity(ecc2[6:0]),		 // Templated
				 // Inputs
				 .din	(io_jbi_j_ad_ff[((2+1)*32-1):(2*32)])); // Templated
zzecc_sctag_pgen_32b u_wdq_ecc3 (/*AUTOINST*/
				 // Outputs
				 .dout	(),			 // Templated
				 .parity(ecc3[6:0]),		 // Templated
				 // Inputs
				 .din	(io_jbi_j_ad_ff[((3+1)*32-1):(3*32)])); // Templated

always @ ( /*AUTOSENSE*/ecc0 or ecc1 or ecc2 or ecc3 or parse_data_err) begin
   if (parse_data_err) begin 
      //poison ecc
      wdq_wdata_ecc0 = { ecc0[6:2], ~ecc0[1:0] }; 
      wdq_wdata_ecc1 = { ecc1[6:2], ~ecc1[1:0] }; 
      wdq_wdata_ecc2 = { ecc2[6:2], ~ecc2[1:0] }; 
      wdq_wdata_ecc3 = { ecc3[6:2], ~ecc3[1:0] }; 
   end
   else begin
      wdq_wdata_ecc0 = ecc0[6:0];
      wdq_wdata_ecc1 = ecc1[6:0];
      wdq_wdata_ecc2 = ecc2[6:0];
      wdq_wdata_ecc3 = ecc3[6:0];
   end
end

always @ ( /*AUTOSENSE*/parse_data_err or parse_wdq_push
	  or wdq_data_err or wptr) begin
   next_wdq_data_err = wdq_data_err;
   if (parse_wdq_push)
      next_wdq_data_err[wptr[`JBI_WDQ_ADDR_WIDTH-1:0]] = parse_data_err;
end



//*******************************************************************************
// Pop Queue
//*******************************************************************************

assign wdq_rdata_tag = wdq_rdata[`JBI_SCTAG_IN_TAG_HI:`JBI_SCTAG_IN_TAG_LO];
assign wdq_rdata_rw  = wdq_rdata_tag[`JBI_SCTAG_TAG_RW];
assign wdq_rdata_req = wdq_rdata[`JBI_SCTAG_IN_REQ_HI:`JBI_SCTAG_IN_REQ_LO];

assign pop_hdr_en = pop_sm[POP_HDR_BIT] & wdq_drdy & ~wdq_stall;
assign next_pop_hdr = wdq_rdata[63:0];

assign pop_tag = pop_hdr[`JBI_SCTAG_IN_TAG_HI:`JBI_SCTAG_IN_TAG_LO];

//-------------------
// Pop State Machine
//-------------------
always @ ( /*AUTOSENSE*/be or be_mask or pop_sm or pop_tag or rst_l
	  or wdq_drdy or wdq_rdata_req or wdq_rdata_rw or wdq_stall
	  or wr_word_cnt) begin
   if (~rst_l)
      next_pop_sm = POP_HDR;
   else begin
      case (pop_sm)
	 
	 POP_HDR: begin
	    // if write, proceed to push data
	    if (wdq_drdy & ~wdq_stall & ~wdq_rdata_rw) begin
	       if (wdq_rdata_req[`JBI_SCTAG_REQ_WR8_BIT])
		  next_pop_sm = POP_WRM;
	       else
		  next_pop_sm = POP_WRI;
	    end
	    else
	       next_pop_sm = POP_HDR;
	 end

	 POP_WRI: begin   // once in this state, rdq guaranteed to have enough space
	    if (wr_word_cnt == 3'd3)
		  next_pop_sm = POP_HDR;
	    else
	       next_pop_sm = POP_WRI;
	 end
	 POP_WRM: begin
	    if (  ~wdq_stall 
		& ~|(be & be_mask) 
		& (  wr_word_cnt == 3'd7 
		   | (wr_word_cnt[0] & pop_tag[`JBI_SCTAG_TAG_SUBLINE])))
	       next_pop_sm = POP_HDR;
	    else
	       next_pop_sm = POP_WRM;
	 end

// CoverMeter line_off
	 default: begin
	    next_pop_sm = {POP_SM_WIDTH{1'bx}};
	    //synopsys translate_off
	    $dispmon ("jbi_min_wdq_ctl", 49,"%d %m: pop_sm=%b", $time, pop_sm);
	    //synopsys translate_on
	 end
// CoverMeter line_on
      endcase
   end
end


//-------------------
// Word Count
// - in WRI mode, this counter counts quadword being pushed into rdq
// - in WRM(WR8) mode, this counter counts double word, or more specifically,
//   keeps track of which 8-bit chunk of BE that is currently being worked on
//-------------------

assign incr_wr_word_cnt =  pop_sm[POP_WRI_BIT]
			 |(pop_sm[POP_WRM_BIT] 
			   & (~|(be & be_mask))
			   & ~wdq_stall);
assign wr_word_cnt_rst_l = rst_l & ~pop_sm[POP_HDR_BIT];

always @ ( /*AUTOSENSE*/incr_wr_word_cnt or wr_word_cnt) begin
   if (incr_wr_word_cnt)
      next_wr_word_cnt = wr_word_cnt + 1'b1;
   else
      next_wr_word_cnt = wr_word_cnt;
end

//-------------------
// Pointer Management
//-------------------
assign wdq_pop =   (pop_sm[POP_HDR_BIT] & wdq_drdy & ~wdq_stall)
                 | pop_sm[POP_WRI_BIT] 
		 | (pop_sm[POP_WRM_BIT] //done with current wrm quadword
		    & (~|(be & be_mask))
		    & wr_word_cnt[0]
 		    & ~wdq_stall);

   
always @ ( /*AUTOSENSE*/rptr or wdq_pop) begin
   if (wdq_pop)
      next_rptr = rptr + 1'b1;
   else
      next_rptr = rptr;
end

assign wdq_raddr = next_rptr[`JBI_WDQ_ADDR_WIDTH-1:0];
assign wdq_rd_en = next_rptr != wptr;

//*******************************************************************************
// Decompose WRM at Top of WDQ
//*******************************************************************************

//------------------------------------------------------
// BE
// - find first string of 1's in an 8-bit chunk of BE, 
//   mask them out, and repeat until be is all 0's then 
//   load next 8-bit chunk of BE
//------------------------------------------------------

// at the beginning of wrm txn, load entire 64 bit BE
assign wrm_be_en  = pop_sm[POP_HDR_BIT];
assign next_wrm_be =  wdq_rdata[127:64];

// as each 8-bit BE dwindle down to all zeros, load next 8-bit be chunk
//  - for subline WRM (NCWR) only 2 8-bit chunk where as WRM has 8 8-bit chunks
assign be_en  = pop_sm[POP_HDR_BIT] 
                | (pop_sm[POP_WRM_BIT] & ~wdq_stall);
always @ ( /*AUTOSENSE*/be or be_mask or incr_wr_word_cnt
	  or next_wr_word_cnt or pop_sm or pop_tag or wdq_rdata
	  or wdq_rdata_tag or wrm_be) begin
   if (pop_sm[POP_HDR_BIT]) begin
      if (wdq_rdata_tag[`JBI_SCTAG_TAG_SUBLINE])
	 next_be = wdq_rdata[119:112];
      else
	 next_be = wdq_rdata[71:64];
   end
   else if (~incr_wr_word_cnt)
      next_be = be & be_mask;
   else begin
      if (pop_tag[`JBI_SCTAG_TAG_SUBLINE])
	 next_be = wrm_be[63:56];
      else 
	 case (next_wr_word_cnt[2:0])
	    3'd0:  next_be = wrm_be[  7:  0];
	    3'd1:  next_be = wrm_be[ 15:  8];
	    3'd2:  next_be = wrm_be[ 23: 16];
	    3'd3:  next_be = wrm_be[ 31: 24];
	    3'd4:  next_be = wrm_be[ 39: 32];
	    3'd5:  next_be = wrm_be[ 47: 40];
 	    3'd6:  next_be = wrm_be[ 55: 48];
	    3'd7:  next_be = wrm_be[ 63: 56];
// CoverMeter line_off
	    default:  next_be = {8{1'bx}};
// CoverMeter line_on
	 endcase
   end
end

// - after determining the position and size of
// the first string of 1's in BE, mask it out for the
// next iteration
// - also mask out 1 bit to the left since know it's a 0 - reduce logic

always @ ( /*AUTOSENSE*/addr0 or addr1 or addr2 or size) begin
   case ({addr2, addr1, addr0}) //starting address
      3'b0: begin
	 case (size[2:0]) 
	    3'd1: be_mask = 8'b1111_1100; 
	    3'd2: be_mask = 8'b1111_1000;
	    3'd3: be_mask = 8'b1111_0000;	       
	    3'd4: be_mask = 8'b1110_0000;	       
	    3'd5: be_mask = 8'b1100_0000;	       
	    3'd6: be_mask = 8'b1000_0000;	       
	    default: be_mask = {8{1'b0}};
	 endcase
      end
      3'd1: begin
	 case (size[2:0]) 
	    3'd1: be_mask = 8'b1111_1000;
	    3'd2: be_mask = 8'b1111_0000;	       
	    3'd3: be_mask = 8'b1110_0000;	       
	    3'd4: be_mask = 8'b1100_0000;	       
	    3'd5: be_mask = 8'b1000_0000;	       
	    default: be_mask = {8{1'b0}};
	 endcase
      end
      3'd2: begin
	 case (size[2:0]) 
	    3'd1: be_mask = 8'b1111_0000;	       
	    3'd2: be_mask = 8'b1110_0000;	       
	    3'd3: be_mask = 8'b1100_0000;	       
	    3'd4: be_mask = 8'b1000_0000;	       
	    default: be_mask = {8{1'b0}};
	 endcase
      end
      3'd3: begin
	 case (size[2:0]) 
	    3'd1: be_mask = 8'b1110_0000;	       
	    3'd2: be_mask = 8'b1100_0000;	       
	    3'd3: be_mask = 8'b1000_0000;	       
	    default: be_mask = {8{1'b0}};
	 endcase
      end
      3'd4: begin
	 case (size[2:0]) 
	    3'd1: be_mask = 8'b1100_0000;	       
	    3'd2: be_mask = 8'b1000_0000;	       
	    default: be_mask = {8{1'b0}};
	 endcase
      end
      3'd5: begin
	 if (size[2:0] == 3'd1)
	    be_mask = 8'b1000_0000;
	 else
	    be_mask = {8{1'b0}};
      end
      default: be_mask = {8{1'b0}};
   endcase
end


//------------------------------
// Starting Address
//------------------------------

// addr[2:0] is starting byte
// - from right to left, search for first "1"
assign addr2     = ~|be[3:0];
assign addr1_0   = ~|be[1:0];
assign addr1_1   = ~|be[5:4];
assign addr0_0_0 = ~be[0];
assign addr0_0_1 = ~be[2];
assign addr0_1_0 = ~be[4];
assign addr0_1_1 = ~be[6];

always @ ( /*AUTOSENSE*/addr1_0 or addr1_1 or addr2) begin
   if (addr2)
      addr1 = addr1_1;
   else
      addr1 = addr1_0;
end

always @ ( /*AUTOSENSE*/addr0_0_0 or addr0_0_1 or addr1_0) begin
   if (addr1_0)
      addr0_0 = addr0_0_1;
   else
      addr0_0 = addr0_0_0;
end

always @ ( /*AUTOSENSE*/addr0_1_0 or addr0_1_1 or addr1_1) begin
   if (addr1_1)
      addr0_1 = addr0_1_1;
   else
      addr0_1 = addr0_1_0;
end

always @ ( /*AUTOSENSE*/addr0_0 or addr0_1 or addr2) begin
   if (addr2)
      addr0 = addr0_1;
   else
      addr0 = addr0_0;
end

assign wrm_start_addr[2:0] = {addr2, addr1, addr0};


//wr8_addr[5:3]
always @ ( /*AUTOSENSE*/incr_wr_word_cnt or next_pop_sm or pop_sm
	  or wdq_rdata or wrm_addr) begin
   if (pop_sm[POP_HDR_BIT] & next_pop_sm[POP_WRM_BIT])
      next_wrm_addr[5:3] = wdq_rdata[5:3];
   else begin
      if (incr_wr_word_cnt)
	 next_wrm_addr[5:3] = wrm_addr[5:3] + 1'b1;
      else
	 next_wrm_addr[5:3] = wrm_addr[5:3];
   end
end



//---------------
// Size 1-8 bytes
//---------------
always @ ( /*AUTOSENSE*/addr0 or addr1 or addr2 or be) begin
   case ({addr2, addr1, addr0})
      3'd0: begin
	 if (~be[1])
	    size = 3'd1;
	 else if (~be[2])
	    size = 3'd2;
	 else if (~be[3])
	    size = 3'd3;
	 else if (~be[4])
	    size = 3'd4;
	 else if (~be[5])
	    size = 3'd5;
	 else if (~be[6])
	    size = 3'd6;
	 else if (~be[7])
	    size = 3'd7;
	 else
	    size = 3'd0;
      end
      3'd1: begin
	 if (~be[2])
	    size = 3'd1;
	 else if (~be[3])
	    size = 3'd2;
	 else if (~be[4])
	    size = 3'd3;
	 else if (~be[5])
	    size = 3'd4;
	 else if (~be[6])
	    size = 3'd5;
	 else if (~be[7])
	    size = 3'd6;
	 else
	    size = 3'd7;
      end
      3'd2: begin
	 if (~be[3])
	    size = 3'd1;
	 else if (~be[4])
	    size = 3'd2;
	 else if (~be[5])
	    size = 3'd3;
	 else if (~be[6])
	    size = 3'd4;
         else if (~be[7])
	    size = 3'd5;
	 else
	    size = 3'd6;
      end
      3'd3: begin
	 if (~be[4])
	    size = 3'd1;
	 else if (~be[5])
	    size = 3'd2;
	 else if (~be[6])
	    size = 3'd3;
	 else if (~be[7])
	    size = 3'd4;
	 else
	    size = 3'd5;
      end
      3'd4: begin
	 if (~be[5])
	    size = 3'd1;
	 else if (~be[6])
	    size = 3'd2;
	 else if (~be[7])
	    size = 3'd3;
	 else
	    size = 3'd4;
      end
      3'd5: begin
	 if (~be[6])
	    size = 3'd1;
	 else if (~be[7])
	    size = 3'd2;
	 else
	    size = 3'd3;
      end
      3'd6: begin
	 if (~be[7])
	    size = 3'd1;
	 else
	    size = 3'd2;
      end
      3'd7: size = 3'd1;

      default: size = 3'bxxx;
   endcase
end


//---------------
// WRM Header
//---------------

assign wrm_hdr[`JBI_SCTAG_IN_ADDR_HI:`JBI_SCTAG_IN_ADDR_LO] = {pop_hdr[`JBI_SCTAG_IN_ADDR_HI:6],
							       wrm_addr[5:3],
							       wrm_start_addr[2:0]};
assign wrm_hdr[`JBI_SCTAG_IN_SZ_HI:`JBI_SCTAG_IN_SZ_LO]     = size[2:0];
assign wrm_hdr[`JBI_SCTAG_IN_REQ_HI:`JBI_SCTAG_IN_RSV0]     = pop_hdr[`JBI_SCTAG_IN_REQ_HI:`JBI_SCTAG_IN_RSV0];
assign wrm_hdr[`JBI_SCTAG_IN_POISON]                        = wdq_data_err[rptr[`JBI_WDQ_ADDR_WIDTH-1:0]];

assign wrm_hdr[`JBI_SCTAG_IN_RSV1_HI:`JBI_SCTAG_IN_RSV1_LO] = pop_hdr[`JBI_SCTAG_IN_RSV1_HI:`JBI_SCTAG_IN_RSV1_LO];
	 
//*******************************************************************************
// Push into SCTAG Header and Data Queues
//*******************************************************************************

always @ ( /*AUTOSENSE*/pop_hdr or pop_sm or wdq_rdata) begin
   if (pop_sm[POP_HDR_BIT])
      sctag_num = wdq_rdata[`JBI_AD_BTU_NUM_HI:`JBI_AD_BTU_NUM_LO];
   else
      sctag_num = pop_hdr[`JBI_AD_BTU_NUM_HI:`JBI_AD_BTU_NUM_LO];
end

assign push_wr8 = pop_sm[POP_WRM_BIT] & (|be) & ~wdq_stall;

//------------------------
// To Data Header Queue
//------------------------
assign wdq_rdq_push =   push_wr8
		      | pop_sm[POP_WRI_BIT];

assign wdq_rdq0_push = wdq_rdq_push & sctag_num==2'd0;
assign wdq_rdq1_push = wdq_rdq_push & sctag_num==2'd1;
assign wdq_rdq2_push = wdq_rdq_push & sctag_num==2'd2;
assign wdq_rdq3_push = wdq_rdq_push & sctag_num==2'd3;

assign wdq_rdq_wdata = wdq_rdata;

//------------------------
// To Request Header Queue
//------------------------

// In order to guarantee that corresponding write data is always available
// when the header is available, need to push write header the same time as
// the 3rd cycle of data (takes 4 cpu cycles to push 128bits to sctag)
assign wdq_rhq_push =   (pop_sm[POP_HDR_BIT] & wdq_drdy & ~wdq_stall & wdq_rdata_rw)
		      | (pop_sm[POP_WRI_BIT] & wr_word_cnt==3'd2)
                      | push_wr8;

assign wdq_rhq0_push = wdq_rhq_push & sctag_num==2'd0;
assign wdq_rhq1_push = wdq_rhq_push & sctag_num==2'd1;
assign wdq_rhq2_push = wdq_rhq_push & sctag_num==2'd2;
assign wdq_rhq3_push = wdq_rhq_push & sctag_num==2'd3;

always @ ( /*AUTOSENSE*/pop_hdr or pop_sm or wdq_rdata or wrm_hdr) begin
   case (pop_sm)
      POP_HDR: wdq_rhq_wdata = wdq_rdata[63:0];
      POP_WRI: wdq_rhq_wdata = pop_hdr;
      POP_WRM: wdq_rhq_wdata = wrm_hdr;
// CoverMeter line_off
      default: wdq_rhq_wdata = wdq_rdata[63:0];
// CoverMeter line_on
   endcase
end

// Writes to the same cache line do not have what for previous write acks
//  - only apply to WRM and NCWR txns for simplicity
//  - all other writes and read txn must wait for previous write acks unless
//    ordering is not turned on
//  - wr-wr ordering must be enabled for wr-rd ordering to work
always @ ( /*AUTOSENSE*/next_pop_sm or push_wr8 or tag_byps) begin
   if (next_pop_sm[POP_HDR_BIT])
      next_tag_byps = 1'b0;
   else if (push_wr8)
      next_tag_byps = 1'b1;
   else
      next_tag_byps = tag_byps;
end

assign wdq_rhq_wdata_tag = wdq_rhq_wdata[`JBI_SCTAG_IN_TAG_HI:`JBI_SCTAG_IN_TAG_LO];
assign wdq_rhq_wdata_rw  = wdq_rhq_wdata_tag[`JBI_SCTAG_TAG_RW];
assign wdq_rq_tag_byps   =   tag_byps
			   | ( wdq_rhq_wdata_rw & ~csr_jbi_config2_ord_rd)  // turn off wr-rd ordering
                           | (~wdq_rhq_wdata_rw & ~csr_jbi_config2_ord_wr); // turn off wr-wr ordering

//------------------------
// Increment Write Count
//------------------------

assign wdq_wr_vld =  (pop_sm[POP_WRI_BIT] & wr_word_cnt==3'd3)
                   | push_wr8;

//*******************************************************************************
// Flow Control
//*******************************************************************************

//--------------------------
// Restrict Pushing into RQ
//--------------------------
always @ ( /*AUTOSENSE*/pop_hdr or pop_sm or wdq_rdata) begin
   if (pop_sm[POP_HDR_BIT])
      stall_sctag_num = wdq_rdata[`JBI_AD_BTU_NUM_HI:`JBI_AD_BTU_NUM_LO];
   else
      stall_sctag_num = pop_hdr[`JBI_AD_BTU_NUM_HI:`JBI_AD_BTU_NUM_LO];
end

assign wdq_stall =  ((rhq0_full | rdq0_full) & stall_sctag_num==2'd0)
                  | ((rhq1_full | rdq1_full) & stall_sctag_num==2'd1)
                  | ((rhq2_full | rdq2_full) & stall_sctag_num==2'd2)
                  | ((rhq3_full | rdq3_full) & stall_sctag_num==2'd3);

//--------------------------
// Restrict JBUS 
//--------------------------

always @ ( /*AUTOSENSE*/parse_wdq_push or wdq_level or wdq_pop) begin
   case ({parse_wdq_push, wdq_pop})  // {incr, decr}
      2'b00,
      2'b11: next_wdq_level = wdq_level;
      2'b01: next_wdq_level = wdq_level - 1'b1;
      2'b10: next_wdq_level = wdq_level + 1'b1;
      default: next_wdq_level = {`JBI_WDQ_ADDR_WIDTH+1{1'bx}};
   endcase
end

assign next_min_full =   (~min_full &   next_wdq_level >= {1'b0, csr_jbi_config2_iq_high[3:0]} )
                       | ( min_full & ~(next_wdq_level <= {1'b0, csr_jbi_config2_iq_low[3:0]}) );

assign min_aok_off =  min_full & ~min_full_d1;
assign min_aok_on  = ~min_full &  min_full_d1;

//*******************************************************************************
// Performance Counters
//*******************************************************************************
assign next_min_csr_perf_dma_wr8 = wdq_rhq_push & pop_sm[POP_WRM_BIT];

//*******************************************************************************
// DFF Instantiations
//*******************************************************************************
dff_ns #(POP_SM_WIDTH) u_dff_pop_sm
   (.din(next_pop_sm),
    .clk(clk),
    .q(pop_sm)
    );

dff_ns #(`JBI_WDQ_ADDR_WIDTH+1) u_dff_wptr_d1
   (.din(wptr),
    .clk(clk),
    .q(wptr_d1)
    );

dff_ns #(1) u_dff_min_full_d1
   (.din(min_full),
    .clk(clk),
    .q(min_full_d1)
    );

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************
dffrl_ns #(`JBI_WDQ_ADDR_WIDTH+1) u_dffrl_wptr
   (.din(next_wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(wptr)
    );

dffrl_ns #(`JBI_WDQ_ADDR_WIDTH+1) u_dffrl_rptr
   (.din(next_rptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(rptr)
    );

dffrl_ns #(3) u_dffrl_wr_word_cnt
   (.din(next_wr_word_cnt),
    .clk(clk),
    .rst_l(wr_word_cnt_rst_l),
    .q(wr_word_cnt)
    );

dffrl_ns #(3) u_dffrl_wrm_addr
   (.din(next_wrm_addr[5:3]),
    .clk(clk),
    .rst_l(rst_l),
    .q(wrm_addr[5:3])
    );

dffrl_ns #(`JBI_WDQ_ADDR_WIDTH+1) u_dffrl_wdq_level
   (.din(next_wdq_level),
    .clk(clk),
    .rst_l(rst_l),
    .q(wdq_level)
    );

dffrl_ns #(1) u_dffrl_min_full
   (.din(next_min_full),
    .clk(clk),
    .rst_l(rst_l),
    .q(min_full)
    );

dffrl_ns #(1) u_dffrl_tag_byps
   (.din(next_tag_byps),
    .clk(clk),
    .rst_l(rst_l),
    .q(tag_byps)
    );

dffrl_ns #(`JBI_WDQ_DEPTH) u_dffrl_wdq_data_err
   (.din(next_wdq_data_err),
    .clk(clk),
    .rst_l(rst_l),
    .q(wdq_data_err)
    );


dffrl_ns #(1) u_dffrl_min_csr_perf_dma_wr8
   (.din(next_min_csr_perf_dma_wr8),
    .clk(clk),
    .rst_l(rst_l),
    .q(min_csr_perf_dma_wr8)
    );


//*******************************************************************************
// DFFRLE Instantiations
//*******************************************************************************

dffrle_ns #(64) u_dffrle_pop_hdr
   (.din(next_pop_hdr),
    .clk(clk),
    .en(pop_hdr_en),
    .rst_l(rst_l),
    .q(pop_hdr)
    );

dffrle_ns #(64) u_dffrle_wrm_be
   (.din(next_wrm_be),
    .clk(clk),
    .en(wrm_be_en),
    .rst_l(rst_l),
    .q(wrm_be)
    );

dffrle_ns #(8) u_dffrle_be
   (.din(next_be),
    .clk(clk),
    .en(be_en),
    .rst_l(rst_l),
    .q(be)
    );

//*******************************************************************************
// Rule Checks
//*******************************************************************************

//synopsys translate_off

wire wdq_empty = rptr == wptr;

wire wdq_full =   wptr[`JBI_WDQ_ADDR_WIDTH]     != rptr[`JBI_WDQ_ADDR_WIDTH]
                & wptr[`JBI_WDQ_ADDR_WIDTH-1:0] == rptr[`JBI_WDQ_ADDR_WIDTH-1:0];

always @ ( /*AUTOSENSE*/parse_wdq_push or wdq_full) begin
   @clk;
   if (wdq_full && parse_wdq_push)
      $dispmon ("jbi_min_wdq_ctl", 49,"%d %m: ERROR - WDQ overflow!", $time);
end

always @ ( /*AUTOSENSE*/wdq_empty or wdq_pop) begin
   @clk;
   if (wdq_empty && wdq_pop)
      $dispmon ("jbi_min_wdq_ctl", 49,"%d %m: ERROR - WDQ underflow!", $time);
end

//synopsys translate_on


endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-library-files:("../../../common/rtl/swrvr_macro.v")
// verilog-auto-sense-defines-constant:t
// End:
