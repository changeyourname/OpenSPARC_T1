// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_rq_rhq_ctl.v
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
//  Description:	Request Header Queue Control
//  Top level Module:	jbi_min_rq_rhq_ctl
//  Where Instantiated:	jbi_min_rq
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "jbi.h"

module jbi_min_rq_rhq_ctl(/*AUTOARG*/
// Outputs
min_csr_err_l2_to, min_csr_perf_blk_q, rhq_full, rhq_drdy, 
rhq_csn_wr, rhq_csn_rd, rhq_waddr, rhq_raddr, rhq_tag_raddr, 
// Inputs
clk, rst_l, cpu_clk, cpu_rst_l, cpu_tx_en, cpu_rx_en, 
csr_jbi_l2_timeout_timeval, csr_jbi_config2_max_rd, 
csr_jbi_config2_max_wr, wdq_rhq_push, issue_rhq_pop, rhq_rdata_rw, 
rhq_rdata_tag_byps, mout_scb_jbus_rd_ack, mout_scb_jbus_wr_ack
);

input clk;
input rst_l;

input cpu_clk;
input cpu_rst_l;
input cpu_tx_en;
input cpu_rx_en;

// CSR Interface
input [31:0] csr_jbi_l2_timeout_timeval;
input [1:0]  csr_jbi_config2_max_rd;
input [3:0]  csr_jbi_config2_max_wr;
output 	     min_csr_err_l2_to;
output [3:0] min_csr_perf_blk_q;

// WDQ Interface
input 	     wdq_rhq_push;
output 	     rhq_full;

// SCTAG Issue Interface
input 	     issue_rhq_pop;
output 	     rhq_drdy;

// Request Header Queue Interface
input 	     rhq_rdata_rw;
output 	     rhq_csn_wr;
output 	     rhq_csn_rd;
output [`JBI_RHQ_ADDR_WIDTH-1:0] rhq_waddr;
output [`JBI_RHQ_ADDR_WIDTH-1:0] rhq_raddr;
output [`JBI_RHQ_ADDR_WIDTH-1:0] rhq_tag_raddr;

// Request Header Write Tracking Queue Interface
input 				 rhq_rdata_tag_byps;

// Memory Out Interface
input 				 mout_scb_jbus_rd_ack; // JBUS CLK
input 				 mout_scb_jbus_wr_ack; // CPU CLK

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 				 min_csr_err_l2_to;
wire [3:0] 			 min_csr_perf_blk_q;
wire 				 rhq_full;
wire 				 rhq_drdy;
wire 				 rhq_csn_wr;
wire 				 rhq_csn_rd;
wire [`JBI_RHQ_ADDR_WIDTH-1:0] 	 rhq_waddr;
wire [`JBI_RHQ_ADDR_WIDTH-1:0] 	 rhq_raddr;
wire [`JBI_RHQ_ADDR_WIDTH-1:0] 	 rhq_tag_raddr;


////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

wire [`JBI_RHQ_ADDR_WIDTH:0] 	 rhq_wptr;
wire [`JBI_RHQ_ADDR_WIDTH:0] 	 rhq_rptr;
wire [2:0] 			 rd_pend_cnt;
wire [4:0] 			 wr_pend_cnt;
wire [31:0] 			 l2_timeout_cnt;
wire [3:0] 			 csr_perf_blk_q;
reg [`JBI_RHQ_ADDR_WIDTH:0] 	 next_rhq_wptr;
reg [`JBI_RHQ_ADDR_WIDTH:0] 	 next_rhq_rptr;
reg [2:0] 			 next_rd_pend_cnt;
reg [4:0] 			 next_wr_pend_cnt;
reg [31:0] 			 next_l2_timeout_cnt;
reg [3:0] 			 next_csr_perf_blk_q;

wire 				 incr_csr_perf_blk_q;
wire [3:0] 			 tx_csr_perf_blk_q;

wire [`JBI_RHQ_ADDR_WIDTH:0] 	 c_rhq_wptr;
wire [`JBI_RHQ_ADDR_WIDTH:0] 	 c_rhq_wptr_early;
wire [`JBI_RHQ_ADDR_WIDTH:0] 	 tx_rhq_rptr;
wire [`JBI_RHQ_ADDR_WIDTH:0] 	 j_rhq_rptr;

wire [`JBI_RHQ_ADDR_WIDTH:0] 	 rhq_wptr_d1;
wire [`JBI_RHQ_ADDR_WIDTH:0] 	 rhq_wptr_d2;
wire 				 cpu_rx_en_d1;

wire 				 c_rhq_empty;
wire 				 j_rhq_empty;
wire [`JBI_RHQ_ADDR_WIDTH:0] 	 rhq_free;
wire 				 c_mout_scb_jbus_rd_ack;
wire 				 incr_rd_pend_cnt;
wire 				 decr_rd_pend_cnt;
wire 				 rd_pend_full;
wire 				 incr_wr_pend_cnt;
wire 				 decr_wr_pend_cnt;
wire 				 wr_pend_full;

wire 				 mout_scb_jbus_rd_ack_ff;
wire [1:0] 			 csr_jbi_config2_max_rd_ff;
wire [1:0] 			 c_csr_jbi_config2_max_rd;
wire [3:0] 			 csr_jbi_config2_max_wr_ff;
wire [3:0] 			 c_csr_jbi_config2_max_wr;
wire [31:0] 			 csr_jbi_l2_timeout_timeval_ff;
wire [31:0] 			 c_csr_jbi_l2_timeout_timeval;

wire 				 csr_err_l2_to;
wire 				 tx_csr_err_l2_to;

wire 				 issue_rhq_pop_d1;

//
// Code start here 
//

//*******************************************************************************
// Push Header Queue (JBUS CLK)
//*******************************************************************************

//----------------------
// Pointer Management
//----------------------
always @ ( /*AUTOSENSE*/rhq_wptr or wdq_rhq_push) begin
   if (wdq_rhq_push)
      next_rhq_wptr = rhq_wptr + 1'b1;
   else
      next_rhq_wptr = rhq_wptr;
end

assign rhq_waddr  = rhq_wptr[`JBI_RHQ_ADDR_WIDTH-1:0];
assign rhq_csn_wr = ~(rst_l & wdq_rhq_push);

//*******************************************************************************
// Pop Header Queue (CPU  CLK)
//*******************************************************************************

always @ ( /*AUTOSENSE*/issue_rhq_pop or rhq_rptr) begin
   if (issue_rhq_pop)
      next_rhq_rptr = rhq_rptr + 1'b1;
   else
      next_rhq_rptr = rhq_rptr;
end

assign c_rhq_empty = c_rhq_wptr[`JBI_RHQ_ADDR_WIDTH:0] == rhq_rptr[`JBI_RHQ_ADDR_WIDTH:0];

assign rhq_raddr = next_rhq_rptr[`JBI_RHQ_ADDR_WIDTH-1:0];
assign rhq_tag_raddr = rhq_rptr[`JBI_RHQ_ADDR_WIDTH-1:0];
assign rhq_csn_rd = c_rhq_wptr_early[`JBI_RHQ_ADDR_WIDTH:0] == next_rhq_rptr[`JBI_RHQ_ADDR_WIDTH:0];

assign rhq_drdy =   ~c_rhq_empty 
                  & rhq_rdata_tag_byps //need to wait on write txns
                  & ~( rhq_rdata_rw & rd_pend_full)
                  & ~(~rhq_rdata_rw & wr_pend_full);

//*******************************************************************************
// Flow Control
//*******************************************************************************

//--------------------------------
// Back pressure to WDQ - JBUS CLK
//--------------------------------
assign j_rhq_empty = j_rhq_rptr == rhq_wptr;
assign rhq_free    = j_rhq_rptr - rhq_wptr;

assign rhq_full =  rhq_free[`JBI_RHQ_ADDR_WIDTH-1:0] < `JBI_RHQ_ADDR_WIDTH'd2
                 & ~j_rhq_empty;

//--------------------------------
// Need to pre-allocate buffer space for read returns
// - assume max 4 read pending
// - allow programmable threshold
// - CPU CLK
//--------------------------------
assign incr_rd_pend_cnt = issue_rhq_pop & rhq_rdata_rw;
assign decr_rd_pend_cnt = c_mout_scb_jbus_rd_ack & cpu_rx_en_d1;

always @ ( /*AUTOSENSE*/decr_rd_pend_cnt or incr_rd_pend_cnt
	  or rd_pend_cnt) begin
   case ({ incr_rd_pend_cnt, decr_rd_pend_cnt })  // {incr, decr}
      2'b00,
      2'b11: next_rd_pend_cnt = rd_pend_cnt;
      2'b01: next_rd_pend_cnt = rd_pend_cnt - 1'b1;
      2'b10: next_rd_pend_cnt = rd_pend_cnt + 1'b1;
      default: next_rd_pend_cnt = {3{1'bx}};
   endcase
end

assign rd_pend_full = rd_pend_cnt > {1'b0, c_csr_jbi_config2_max_rd[1:0]};

//--------------------------------
// Stop issuing any writes (WRIS & WR8) if reach programmable limit
// - CPU CLK
//--------------------------------
assign incr_wr_pend_cnt = issue_rhq_pop & ~rhq_rdata_rw;
assign decr_wr_pend_cnt = mout_scb_jbus_wr_ack;

always @ ( /*AUTOSENSE*/decr_wr_pend_cnt or incr_wr_pend_cnt
	  or wr_pend_cnt) begin
   case ({ incr_wr_pend_cnt, decr_wr_pend_cnt })  // {incr, decr}
      2'b00,
      2'b11: next_wr_pend_cnt = wr_pend_cnt;
      2'b01: next_wr_pend_cnt = wr_pend_cnt - 1'b1;
      2'b10: next_wr_pend_cnt = wr_pend_cnt + 1'b1;
      default: next_wr_pend_cnt = {5{1'bx}};
   endcase
end

assign wr_pend_full = wr_pend_cnt > {1'b0, c_csr_jbi_config2_max_wr[3:0]};


//*******************************************************************************
// Error Handling - L2 Interface Flow Control Timeout
//*******************************************************************************

always @ ( /*AUTOSENSE*/c_csr_jbi_l2_timeout_timeval or c_rhq_empty
	  or cpu_tx_en or csr_err_l2_to or issue_rhq_pop_d1
	  or l2_timeout_cnt) begin
   if (  issue_rhq_pop_d1
       | c_rhq_empty
       | (csr_err_l2_to & cpu_tx_en))
      next_l2_timeout_cnt = c_csr_jbi_l2_timeout_timeval;
   else begin
      // keep l2_timeout_cnt @ zero until csr_err_l2_to crosses to jbus clk domain
      if (csr_err_l2_to)  
	 next_l2_timeout_cnt = l2_timeout_cnt;
      else 
	 next_l2_timeout_cnt = l2_timeout_cnt - 1'b1;
   end
end

assign csr_err_l2_to = l2_timeout_cnt == 32'd0;

//*******************************************************************************
// Performance Counter
//*******************************************************************************

// CPU CLK
assign  incr_csr_perf_blk_q =   ~c_rhq_empty 
                              & ~rhq_rdata_tag_byps //need to wait on write txns
                              & ~( rhq_rdata_rw & rd_pend_full)
                              & ~(~rhq_rdata_rw & wr_pend_full);
always @ ( /*AUTOSENSE*/cpu_tx_en or csr_perf_blk_q
	  or incr_csr_perf_blk_q) begin
   if (cpu_tx_en)
      next_csr_perf_blk_q = {3'd0, incr_csr_perf_blk_q};
   else begin
      if (incr_csr_perf_blk_q)
	 next_csr_perf_blk_q = csr_perf_blk_q + 1'b1;
      else
	 next_csr_perf_blk_q = csr_perf_blk_q;
   end
end


//*******************************************************************************
// Synchronization DFFRLEs
//*******************************************************************************

//----------------------
// CPU -> JBUS
//----------------------

// j_rhq_rptr
dffrle_ns #(`JBI_RHQ_ADDR_WIDTH+1) u_dffrle_tx_rhq_rptr
   (.din(rhq_rptr),
    .clk(cpu_clk),
    .en(cpu_tx_en),
    .rst_l(cpu_rst_l),
    .q(tx_rhq_rptr)
    );

dffrl_ns #(`JBI_RHQ_ADDR_WIDTH+1) u_dffrl_j_rhq_rptr
   (.din(tx_rhq_rptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(j_rhq_rptr)
    );

// min_csr_perf_blk_q
dffrle_ns #(4) u_dffrle_tx_csr_perf_blk_q
   (.din(csr_perf_blk_q),
    .clk(cpu_clk),
    .en(cpu_tx_en),
    .rst_l(cpu_rst_l),
    .q(tx_csr_perf_blk_q)
    );

dffrl_ns #(4) u_dffrl_j_csr_perf_blk_q
   (.din(tx_csr_perf_blk_q),
    .clk(clk),
    .rst_l(rst_l),
    .q(min_csr_perf_blk_q)
    );

// min_csr_err_l2_to
dffrle_ns #(1) u_dffrle_tx_csr_err_l2_to
   (.din(csr_err_l2_to),
    .clk(cpu_clk),
    .en(cpu_tx_en),
    .rst_l(cpu_rst_l),
    .q(tx_csr_err_l2_to)
    );

dffrl_ns #(1) u_dffrl_min_csr_err_l2_to
   (.din(tx_csr_err_l2_to),
    .clk(clk),
    .rst_l(rst_l),
    .q(min_csr_err_l2_to)
    );

//----------------------
// JBUS -> CPU
//----------------------

// because of the delay in pushing an entry and when it actually shows up
// at the flopped output of rhq, need to used delayed version
dffrle_ns #(`JBI_RHQ_ADDR_WIDTH+1) u_dffrle_c_rhq_wptr
   (.din(rhq_wptr_d2),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_rhq_wptr)
    );

dffrle_ns #(`JBI_RHQ_ADDR_WIDTH+1) u_dffrle_c_rhq_wptr_early
   (.din(rhq_wptr_d1),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_rhq_wptr_early)
    );

// mout_scb_jbus_rd_ack
dffrl_ns #(1) u_dffrl_mout_scb_jbus_rd_ack_ff
   (.din(mout_scb_jbus_rd_ack),
    .clk(clk),
    .rst_l(rst_l),
    .q(mout_scb_jbus_rd_ack_ff)
    );
dffrle_ns #(1) u_dffrle_c_mout_scb_jbus_rd_ack
   (.din(mout_scb_jbus_rd_ack_ff),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_mout_scb_jbus_rd_ack)
    );

// csr_jbi_config2_max_rd
dffrl_ns #(2) u_dffrl_csr_jbi_config2_max_rd_ff
   (.din(csr_jbi_config2_max_rd),
    .clk(clk),
    .rst_l(rst_l),
    .q(csr_jbi_config2_max_rd_ff)
    );
dffrle_ns #(2) u_dffrle_c_csr_jbi_config2_max_rd
   (.din(csr_jbi_config2_max_rd_ff),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_csr_jbi_config2_max_rd)
    );

// csr_jbi_config2_max_wr
dffrl_ns #(4) u_dffrl_csr_jbi_config2_max_wr_ff
   (.din(csr_jbi_config2_max_wr),
    .clk(clk),
    .rst_l(rst_l),
    .q(csr_jbi_config2_max_wr_ff)
    );
dffrle_ns #(4) u_dffrle_c_csr_jbi_config2_max_wr
   (.din(csr_jbi_config2_max_wr_ff),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_csr_jbi_config2_max_wr)
    );

// csr_jbi_l2_timeout_timeval
dffrl_ns #(32) u_dffrl_csr_jbi_l2_timeout_timeval_ff
   (.din(csr_jbi_l2_timeout_timeval),
    .clk(clk),
    .rst_l(rst_l),
    .q(csr_jbi_l2_timeout_timeval_ff)
    );
dffrle_ns #(32) u_dffrle_c_csr_jbi_l2_timeout_timeval
   (.din(csr_jbi_l2_timeout_timeval_ff),
    .clk(cpu_clk),
    .en(cpu_rx_en),
    .rst_l(cpu_rst_l),
    .q(c_csr_jbi_l2_timeout_timeval)
    );

//*******************************************************************************
// DFF Instantiations
//*******************************************************************************

//----------------------
// CPU CLK
//----------------------
dff_ns #(1) u_dff_cpu_rx_en_d1
   (.din(cpu_rx_en),
    .clk(cpu_clk),
    .q(cpu_rx_en_d1)
    );

dff_ns #(32) u_dff_l2_timeout_cnt
   (.din(next_l2_timeout_cnt),
    .clk(cpu_clk),
    .q(l2_timeout_cnt)
    );

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************

//----------------------
// JBUS CLK
//----------------------
dffrl_ns #(`JBI_RHQ_ADDR_WIDTH+1) u_dffrl_rhq_wptr
   (.din(next_rhq_wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(rhq_wptr)
    );

dffrl_ns #(`JBI_RHQ_ADDR_WIDTH+1) u_dffrl_rhq_wptr_d1
   (.din(rhq_wptr),
    .clk(clk),
    .rst_l(rst_l),
    .q(rhq_wptr_d1)
    );

dffrl_ns #(`JBI_RHQ_ADDR_WIDTH+1) u_dffrl_rhq_wptr_d2
   (.din(rhq_wptr_d1),
    .clk(clk),
    .rst_l(rst_l),
    .q(rhq_wptr_d2)
    );

//----------------------
// CPU CLK
//----------------------
dffrl_ns #(`JBI_RHQ_ADDR_WIDTH+1) u_dffrl_rhq_rptr
   (.din(next_rhq_rptr),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(rhq_rptr)
    );

dffrl_ns #(3) u_dffrl_rd_pend_cnt
   (.din(next_rd_pend_cnt),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(rd_pend_cnt)
    );

dffrl_ns #(5) u_dffrl_wr_pend_cnt
   (.din(next_wr_pend_cnt),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(wr_pend_cnt)
    );

dffrl_ns #(4) u_dffrl_csr_perf_blk_q
   (.din(next_csr_perf_blk_q),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(csr_perf_blk_q)
    );

dffrl_ns #(1) u_dffrl_issue_rhq_pop_d1
   (.din(issue_rhq_pop),
    .clk(cpu_clk),
    .rst_l(cpu_rst_l),
    .q(issue_rhq_pop_d1)
    );

//*******************************************************************************
// Rule Checks
//*******************************************************************************

//synopsys translate_off
wire rc_rhq_full =    j_rhq_rptr[`JBI_RHQ_ADDR_WIDTH]     != rhq_wptr[`JBI_RHQ_ADDR_WIDTH]
                   && j_rhq_rptr[`JBI_RHQ_ADDR_WIDTH-1:0] == rhq_wptr[`JBI_RHQ_ADDR_WIDTH-1:0];
always @ ( /*AUTOSENSE*/rc_rhq_full or wdq_rhq_push) begin
   @clk;
   if (rc_rhq_full && wdq_rhq_push)
      $dispmon ("jbi_min_rq_rhq_ctl", 49,"%d %m: ERROR - RHQ overflow!", $time);
end

always @ ( /*AUTOSENSE*/c_rhq_empty or issue_rhq_pop) begin
   @cpu_clk;
   if (c_rhq_empty && issue_rhq_pop)
      $dispmon ("jbi_min_rq_rhq_ctl", 49,"%d %m: ERROR - RHQ underflow!", $time);
end

//synopsys translate_on

endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
