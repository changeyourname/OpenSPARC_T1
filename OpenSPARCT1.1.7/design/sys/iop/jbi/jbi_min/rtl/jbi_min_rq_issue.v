// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_rq_issue.v
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
//  Description:	Request Issue Block (Control logic)
//  Top level Module:	jbi_min_rq_issue
//  Where Instantiated:	jbi_min_rq
//
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

module jbi_min_rq_issue (/*AUTOARG*/
// Outputs
issue_rhq_pop, issue_rdq_pop, rhq_rdata_rw, issue_biq_data_pop, 
issue_biq_hdr_pop, jbi_sctag_req_vld, jbi_sctag_req, jbi_scbuf_ecc, 
// Inputs
clk, rst_l, cpu_clk, cpu_rst_l, cpu_rx_en, csr_jbi_config2_max_wris, 
rhq_drdy, rhq_rdata, rdq_rdata, biq_drdy, biq_rdata_data, 
biq_rdata_ecc, sctag_jbi_iq_dequeue, sctag_jbi_wib_dequeue
);

input clk;
input rst_l;

input cpu_clk;
input cpu_rst_l;
input cpu_rx_en;

// CSR Interface
input [1:0]  csr_jbi_config2_max_wris;

// Request Header Queue Interface
input 	     rhq_drdy;
input [`JBI_RHQ_WIDTH-1:0] rhq_rdata;
output 			   issue_rhq_pop;

// Request Data Queue Interface
input [`JBI_RDQ_WIDTH-1:0] rdq_rdata;
output 			   issue_rdq_pop;
output 			   rhq_rdata_rw;

// BSC Inbound Queue Interface
input 			   biq_drdy;
input [`JBI_BIQ_DATA_WIDTH-1:0] biq_rdata_data;
input [`JBI_BIQ_ECC_WIDTH-1:0] 	biq_rdata_ecc;
output 				issue_biq_data_pop;
output 				issue_biq_hdr_pop;

// SCTAG Interface
input 				sctag_jbi_iq_dequeue;
input 				sctag_jbi_wib_dequeue;
output 				jbi_sctag_req_vld;
output [31:0] 			jbi_sctag_req;
output [6:0] 			jbi_scbuf_ecc;


////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 				issue_rhq_pop;
wire 				rhq_rdata_rw;
wire 				issue_rdq_pop;
wire 				issue_biq_data_pop;
wire 				issue_biq_hdr_pop;
wire 				jbi_sctag_req_vld;
wire [31:0] 			jbi_sctag_req;
wire [6:0] 			jbi_scbuf_ecc;


////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
parameter POP_IDLE     = 8'b00000001,
	  POP_HDR0     = 8'b00000010,
	  POP_HDR1     = 8'b00000100,
	  POP_WRI_D    = 8'b00001000,
	  POP_WRM_D0   = 8'b00010000,
	  POP_WRM_D1   = 8'b00100000,
	  POP_RD_WAIT0 = 8'b01000000,
	  POP_RD_WAIT1 = 8'b10000000;
parameter POP_IDLE_BIT     = 0,
	  POP_HDR0_BIT     = 1,
	  POP_HDR1_BIT     = 2,
	  POP_WRI_D_BIT    = 3,
	  POP_WRM_D0_BIT   = 4,
	  POP_WRM_D1_BIT   = 5,
	  POP_SM_WIDTH     = 8;

//
// Code start here 
//

wire [POP_SM_WIDTH-1:0] pop_sm;
wire 			driving_bsc;
wire 			priority_bsc;
wire [3:0] 		pop_data_cnt;
wire [1:0] 		ib_cnt;
wire [2:0] 		wib_cnt;
wire 			pop_ib;
wire 			incr_wib_cnt;
reg [POP_SM_WIDTH-1:0] 	next_pop_sm;
wire 			next_driving_bsc;
reg 			next_priority_bsc;
reg [3:0] 		next_pop_data_cnt;
reg [1:0] 		next_iq_cnt;
reg [2:0] 		next_wib_cnt;
wire 			next_pop_ib;
wire 			next_incr_wib_cnt;

wire 			pop_data_cnt_en;
wire 			driving_bsc_en;

wire 			sctag_jbi_iq_dequeue_ff;
wire 			sctag_jbi_wib_dequeue_ff;
wire 			next_jbi_sctag_req_vld;
reg [31:0] 		next_jbi_sctag_req;
reg [6:0] 		next_jbi_scbuf_ecc;

wire 			bsc_drdy_ok;
wire 			rhq_drdy_ok;
wire 			driving_data;
wire 			stall_ib;
wire 			stall_wib;
wire 			issue_txn;
reg [31:0] 		biq_data;
reg [6:0] 		biq_ecc;
reg [3:0] 		pop_data_sel;
wire [31:0] 		rq_wr_data;
wire [6:0] 		rq_ecc;
reg [31:0] 		rq_hdr;
reg [31:0] 		rq_data;

wire 			biq_rdata_rw;
wire [2:0] 		rhq_rdata_req;
wire [11:0] 		rhq_rdata_tag;

wire [2:0] 		next_jbi_sctag_req_req;
wire 			jbi_sctag_req_vld_dup;


wire [1:0] 		csr_jbi_config2_max_wris_ff;
wire [1:0] 		c_csr_jbi_config2_max_wris;

//*******************************************************************************
// Pop Transaction From Request Queue
//*******************************************************************************

// Pop State Machine
always @ ( /*AUTOSENSE*/biq_rdata_rw or driving_bsc or issue_txn
	  or pop_data_cnt or pop_sm or rhq_rdata_req or rhq_rdata_rw) begin
   case (pop_sm)
      POP_IDLE: begin
	 if (issue_txn)
	    next_pop_sm = POP_HDR0;
	 else
	    next_pop_sm = POP_IDLE;
      end

      POP_HDR0: next_pop_sm = POP_HDR1;

      POP_HDR1: begin
	 if (  ( driving_bsc & biq_rdata_rw)
	       | (~driving_bsc & rhq_rdata_rw))
	    next_pop_sm = POP_RD_WAIT0;
	 else if (~driving_bsc 
		  & rhq_rdata_req[`JBI_SCTAG_REQ_WR8_BIT])
	    next_pop_sm = POP_WRM_D0;
	 else
	    next_pop_sm = POP_WRI_D;
      end

      POP_WRI_D: begin
	 if (&pop_data_cnt[3:0])
	    next_pop_sm = POP_IDLE;
	 else
	    next_pop_sm = POP_WRI_D;
      end
      
      POP_WRM_D0: next_pop_sm = POP_WRM_D1;

      POP_WRM_D1: next_pop_sm = POP_IDLE;

      POP_RD_WAIT0: next_pop_sm = POP_RD_WAIT1;

      POP_RD_WAIT1: next_pop_sm = POP_IDLE;

      // CoverMeter line_off
      default: begin
	 next_pop_sm = {POP_SM_WIDTH{1'bx}};
	 //synopsys translate_off
	 $dispmon ("jbi_min_rq_issue", 49,"%d %m: pop_sm=%b", $time, pop_sm);
	 //synopsys translate_on
      end
      // CoverMeter line_on
   endcase
end

assign driving_data =  pop_sm[POP_WRI_D_BIT]
                     | pop_sm[POP_WRM_D0_BIT]
                     | pop_sm[POP_WRM_D1_BIT];

assign pop_data_cnt_en    = pop_sm[POP_HDR1_BIT] | driving_data;

always @ ( /*AUTOSENSE*/driving_bsc or pop_data_cnt or pop_sm
	  or rhq_rdata) begin
   if (pop_sm[POP_HDR1_BIT]) begin
// CoverMeter line_off
      if (driving_bsc)
	 next_pop_data_cnt  = 4'd0;
// CoverMeter line_on
      else
	 next_pop_data_cnt  = {rhq_rdata[5:3], 1'b0};
   end
   else
      next_pop_data_cnt  = pop_data_cnt + 1'b1;
end

assign issue_rhq_pop =   pop_sm[POP_HDR0_BIT]
                       & rhq_drdy_ok
                       & ~driving_bsc;

assign issue_rdq_pop = ~driving_bsc 
                      & (  (pop_data_cnt[1:0] == 2'd2 // pop data after every quadword
                            & pop_sm[POP_WRI_D_BIT])  // and allow for 2cycle delay
			 | pop_sm[POP_WRM_D0_BIT]);   

assign issue_biq_data_pop =   ~pop_data_cnt[0]        // pop data after every double word
                            & driving_data            // and allow for 2cycle delay
                            & driving_bsc;
assign issue_biq_hdr_pop =   pop_sm[POP_HDR0_BIT] // pop header
                           & bsc_drdy_ok
                           & driving_bsc;

//*******************************************************************************
// Arbitration
// - round robin
//*******************************************************************************

assign biq_rdata_rw  = biq_rdata_data[`JBI_SCTAG_IN_RSV0_RW];
assign rhq_rdata_req = rhq_rdata[`JBI_SCTAG_IN_REQ_HI:`JBI_SCTAG_IN_REQ_LO];
assign rhq_rdata_tag = rhq_rdata[`JBI_SCTAG_IN_TAG_HI:`JBI_SCTAG_IN_TAG_LO];
assign rhq_rdata_rw  = rhq_rdata_tag[`JBI_SCTAG_TAG_RW];

assign bsc_drdy_ok = biq_drdy
                     & ~stall_ib
                     & ~(stall_wib & ~biq_rdata_rw);

assign rhq_drdy_ok = rhq_drdy
                     & ~stall_ib
                     & ~(stall_wib & rhq_rdata_req[`JBI_SCTAG_REQ_WRI_BIT]);

assign issue_txn = bsc_drdy_ok | rhq_drdy_ok;

assign driving_bsc_en = next_pop_sm[POP_HDR0_BIT];
assign next_driving_bsc =  bsc_drdy_ok
                         & (  priority_bsc
		            | ~rhq_drdy_ok);

always @ ( /*AUTOSENSE*/driving_bsc_en or next_driving_bsc
	  or priority_bsc) begin
   if (driving_bsc_en)
      next_priority_bsc = ~next_driving_bsc;
   else
      next_priority_bsc = priority_bsc;
end

		 
//*******************************************************************************
// Flow Control
//*******************************************************************************

//----------------------------------------
// ?Invalidate? Buffer (IB)
// - applies to WRI, WR8, and RDD
//----------------------------------------

assign next_pop_ib = next_jbi_sctag_req_vld;

always @ ( /*AUTOSENSE*/cpu_rst_l or ib_cnt or pop_ib
	  or sctag_jbi_iq_dequeue_ff) begin
   if (~cpu_rst_l)
      next_iq_cnt = 2'd2;
   else begin
      case({sctag_jbi_iq_dequeue_ff, pop_ib})
	 2'b00,
	 2'b11: next_iq_cnt = ib_cnt;
	 2'b01: next_iq_cnt = ib_cnt - 1'b1;
	 2'b10: next_iq_cnt = ib_cnt + 1'b1;
// CoverMeter line_off
	 default: begin
	    next_iq_cnt = 2'bxx;
	    //synopsys translate_off
	    $dispmon ("jbi_min_rq_issue", 49,"%d %m: sctag_jbi_iq_dequeue_ff=%b pop_ib=%b", 
		      $time, sctag_jbi_iq_dequeue_ff, pop_ib);
	    //synopsys translate_on
	 end
// CoverMeter line_on
      endcase
   end
end

assign stall_ib = ib_cnt == 2'd0;

//----------------------------------------
// Write Invalidate Buffer (WIB)
//  - applies to WRI
//----------------------------------------
assign next_jbi_sctag_req_req[2:0] = next_jbi_sctag_req[`JBI_SCTAG_IN_REQ_HI-32:`JBI_SCTAG_IN_REQ_LO-32];
assign next_incr_wib_cnt=   jbi_sctag_req_vld_dup
                      & next_jbi_sctag_req_req[`JBI_SCTAG_REQ_WRI_BIT];

always @ ( /*AUTOSENSE*/incr_wib_cnt or sctag_jbi_wib_dequeue_ff
	  or wib_cnt) begin
   case({incr_wib_cnt, sctag_jbi_wib_dequeue_ff})
      2'b00,
      2'b11: next_wib_cnt = wib_cnt;
      2'b01: next_wib_cnt = wib_cnt - 1'b1;
      2'b10: next_wib_cnt = wib_cnt + 1'b1;
      default: begin
	 next_wib_cnt = 3'bxxx;
	 //synopsys translate_off
	 $dispmon ("jbi_min_rq_issue", 49,"%d %m: sctag_jbi_wib_dequeue_ff=%b incr_wib_cnt=%b", 
		   $time, sctag_jbi_wib_dequeue_ff, incr_wib_cnt);
	 //synopsys translate_on
      end
   endcase
end

assign stall_wib = wib_cnt > {1'b0, c_csr_jbi_config2_max_wris[1:0]};

//*******************************************************************************
// Mux SCTAG Data
//*******************************************************************************

//----------------------------------------
// BSC data
//----------------------------------------
always @ ( /*AUTOSENSE*/biq_rdata_data or biq_rdata_ecc
	  or driving_data or pop_data_cnt or pop_sm) begin
   if (  (driving_data & pop_data_cnt[0])
       | pop_sm[POP_HDR1_BIT]) begin
      biq_data = biq_rdata_data[31:0];
      biq_ecc  = biq_rdata_ecc[6:0];
   end
   else begin
      biq_data = biq_rdata_data[63:32];
      biq_ecc  = biq_rdata_ecc[13:7];
   end
end

//----------------------------------------
// RQ data
//----------------------------------------

// WRI/WR8 data
always @ ( /*AUTOSENSE*/pop_data_cnt) begin
   case(pop_data_cnt[1:0]) 
      2'b00: pop_data_sel = 4'b0001;
      2'b01: pop_data_sel = 4'b0010;
      2'b10: pop_data_sel = 4'b0100;
      2'b11: pop_data_sel = 4'b1000;
// CoverMeter line_off
      default: pop_data_sel = {4{1'bx}};
// CoverMeter line_on
   endcase
end

mux4ds #(32) u_mux4ds_rq_wr_data
   (.dout(rq_wr_data),
    .in0(rdq_rdata[127:96]),
    .in1(rdq_rdata[ 95:64]),
    .in2(rdq_rdata[ 63:32]),
    .in3(rdq_rdata[ 31: 0]),
    .sel0(pop_data_sel[0]),
    .sel1(pop_data_sel[1]),
    .sel2(pop_data_sel[2]),
    .sel3(pop_data_sel[3])
    );

mux4ds #(7) u_mux4ds_rq_ecc
   (.dout(rq_ecc),
    .in0(rdq_rdata[155:149]),
    .in1(rdq_rdata[148:142]),
    .in2(rdq_rdata[141:135]),
    .in3(rdq_rdata[134:128]),
    .sel0(pop_data_sel[0]),
    .sel1(pop_data_sel[1]),
    .sel2(pop_data_sel[2]),
    .sel3(pop_data_sel[3])
    );


// header
always @ ( /*AUTOSENSE*/pop_sm or rhq_rdata) begin
   if (pop_sm[POP_HDR1_BIT])
      rq_hdr = rhq_rdata[31:0];
   else
      rq_hdr = rhq_rdata[63:32];
end


always @ ( /*AUTOSENSE*/driving_data or rq_hdr or rq_wr_data) begin
   if (driving_data)
      rq_data = rq_wr_data;
   else
      rq_data = rq_hdr;
end

//----------------------------------------
// SCTAG Data
//----------------------------------------
always @ ( /*AUTOSENSE*/biq_data or biq_ecc or driving_bsc or rq_data
	  or rq_ecc) begin
// CoverMeter line_off
   if (driving_bsc) begin
      next_jbi_sctag_req = biq_data;
      next_jbi_scbuf_ecc = biq_ecc;
   end
// CoverMeter line_on
   else begin
      next_jbi_sctag_req = rq_data;
      next_jbi_scbuf_ecc = rq_ecc;
   end
end

assign next_jbi_sctag_req_vld = next_pop_sm[POP_HDR0_BIT];

//*******************************************************************************
// Synchronization DFFRLEs
//*******************************************************************************

//----------------------
// JBUS -> CPU
//----------------------

// csr_jbi_config2_max_wris
dffrl_ns #(2) u_dffrl_csr_jbi_config2_max_wris_ff
   (.din(csr_jbi_config2_max_wris),
    .clk(clk),
    .rst_l(rst_l),
    .q(csr_jbi_config2_max_wris_ff)
    );
dffrle_ns #(2) u_dffrle_c_csr_jbi_config2_max_wris
   (.din(csr_jbi_config2_max_wris_ff),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_csr_jbi_config2_max_wris)
    );

//*******************************************************************************
// DFF Instantiations
//*******************************************************************************
dff_ns #(2) u_dff_iq_cnt
   (.din(next_iq_cnt),
    .clk(cpu_clk),
    .q(ib_cnt)
    );

dff_ns #(1) u_dff_sctag_jbi_iq_dequeue_ff
   (.din(sctag_jbi_iq_dequeue),
    .clk(cpu_clk),
    .q(sctag_jbi_iq_dequeue_ff)
    );

dff_ns #(1) u_dff_sctag_jbi_wib_dequeue_ff
   (.din(sctag_jbi_wib_dequeue),
    .clk(cpu_clk),
    .q(sctag_jbi_wib_dequeue_ff)
    );

dff_ns #(32) u_dff_jbi_sctag_req
   (.din(next_jbi_sctag_req),
    .clk(cpu_clk),
    .q(jbi_sctag_req)
    );

dff_ns #(7) u_dff_jbi_scbuf_ecc
   (.din(next_jbi_scbuf_ecc),
    .clk(cpu_clk),
    .q(jbi_scbuf_ecc)
    );

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************

dffrl_ns #(POP_SM_WIDTH-1) u_dff_pop_sm
   (.din(next_pop_sm[POP_SM_WIDTH-1:1]),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(pop_sm[POP_SM_WIDTH-1:1])
    );

dffsl_ns #(1) u_dff_pop_sm0
   (.din(next_pop_sm[POP_IDLE_BIT]),
    .clk(cpu_clk),
    .set_l(cpu_rst_l),
    .q(pop_sm[POP_IDLE_BIT])
    );

dffrl_ns #(1) u_dffrl_priority_bsc
   (.din(next_priority_bsc),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(priority_bsc)
    );

dffrl_ns #(1) u_dffrl_pop_ib
   (.din(next_pop_ib),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(pop_ib)
    );

dffrl_ns #(1) u_dffrl_incr_wib_cnt
   (.din(next_incr_wib_cnt),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(incr_wib_cnt)
    );

dffrl_ns #(1) u_dffrl_jbi_sctag_req_vld
   (.din(next_jbi_sctag_req_vld),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(jbi_sctag_req_vld)
    );

dffrl_ns #(1) u_dffrl_jbi_sctag_req_vld_dup
   (.din(next_jbi_sctag_req_vld),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(jbi_sctag_req_vld_dup)
    );

dffrl_ns #(3) u_dffrl_wib_cnt
   (.din(next_wib_cnt),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(wib_cnt)
    );

//*******************************************************************************
// DFFRLE Instantiations
//*******************************************************************************

dffrle_ns #(4) u_dffrle_pop_data_cnt
   (.din(next_pop_data_cnt),
    .clk(cpu_clk),
    .en(pop_data_cnt_en),
    .rst_l(cpu_rst_l),
    .q(pop_data_cnt)
    );

dffrle_ns #(1) u_dffrle_driving_bsc
   (.din(next_driving_bsc),
    .clk(cpu_clk),
    .en(driving_bsc_en),
    .rst_l(cpu_rst_l),
    .q(driving_bsc)
    );

//*******************************************************************************
// Rule Checks
//*******************************************************************************

//synopsys translate_off

//-------------------------------

always @ ( /*AUTOSENSE*/driving_bsc or pop_sm) begin
   @cpu_clk;
   if (pop_sm[POP_WRM_D0_BIT] && driving_bsc)
      $dispmon ("jbi_min_rq_issue", 49,"%d %m: ERROR - thinks bsc is driving WRM txn", $time);
end

//-------------------------------
always @ ( /*AUTOSENSE*/driving_bsc or next_pop_sm or pop_sm
	  or rhq_rdata) begin
   @cpu_clk;
   if (pop_sm[POP_HDR1_BIT] 
       && next_pop_sm[POP_WRI_D_BIT]
       && ~driving_bsc 
       && rhq_rdata[5:0] != 6'd0)
       $dispmon ("jbi_min_rq_issue", 49,"%d %m: ERROR - WRI addr from Jbus not cacheline alligned",
		 $time);
end


//synopsys translate_on

endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
