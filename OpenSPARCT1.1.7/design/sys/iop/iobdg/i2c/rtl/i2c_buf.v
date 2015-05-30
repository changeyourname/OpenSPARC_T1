// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: i2c_buf.v
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
////////////////////////////////////////////////////////////////////////
/*
//  Module Name:	i2c_buf (io-to-cpu UCB buffer)
//  Description:	This is the interface from the UCB modules.
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
			// time scale definition
`include        "iop.h"

////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
// Interface signal list declarations
////////////////////////////////////////////////////////////////////////
module i2c_buf (/*AUTOARG*/
   // Outputs
   iob_ucb_stall, req_ack_obj, req_ack_vld, int_obj, int_vld, 
   // Inputs
   rst_l, clk, ucb_iob_vld, ucb_iob_data, rd_req_ack_dbl_buf, 
   rd_int_dbl_buf
   );

   // synopsys template

   parameter UCB_IOB_WIDTH = 8;
   parameter REG_WIDTH = 64;            // size of control register in cluster
   parameter REQ_ACK_BUF_WIDTH = 128;   // control (64 bit) + data (64/128 bit)
   parameter INT_BUF_WIDTH = 64;        // interrupt packet width
   
   
////////////////////////////////////////////////////////////////////////
// Signal declarations
////////////////////////////////////////////////////////////////////////
   // Global interface
   input                          rst_l;
   input 			  clk;


   // UCB interface
   input 			  ucb_iob_vld;
   input [UCB_IOB_WIDTH-1:0] 	  ucb_iob_data;
   output 			  iob_ucb_stall;
   

   // i2c slow control/datapath interface
   input 		          rd_req_ack_dbl_buf;
   output [REQ_ACK_BUF_WIDTH-1:0] req_ack_obj;
   output 			  req_ack_vld;
   
   input 			  rd_int_dbl_buf;
   output [INT_BUF_WIDTH-1:0] 	  int_obj;
   output 			  int_vld;

   
   // Internal signals
   wire 			  indata_buf_vld;
   wire [REG_WIDTH+63:0] 	  indata_buf;
   wire 			  iob_ucb_stall_a1;
   wire 			  int_type;
   wire 			  req_ack_pending;
   wire 			  int_pending;
   wire 			  wr_req_ack_dbl_buf;
   wire 			  req_ack_dbl_buf_full;
   wire 			  wr_int_dbl_buf;
   wire 			  int_dbl_buf_full;
   
   
////////////////////////////////////////////////////////////////////////
// Code starts here
////////////////////////////////////////////////////////////////////////
   /************************************************************
    * Assemble inbound packet
    ************************************************************/
   ucb_bus_in #(UCB_IOB_WIDTH, REG_WIDTH) ucb_bus_in (.rst_l(rst_l),
						      .clk(clk),
						      .vld(ucb_iob_vld),
						      .data(ucb_iob_data),
						      .stall(iob_ucb_stall),
						      .indata_buf_vld(indata_buf_vld),
						      .indata_buf(indata_buf),
						      .stall_a1(iob_ucb_stall_a1));

   
   /************************************************************
    * Decode inbound packet type
    ************************************************************/
   // non-interrupt packet
   assign        req_ack_pending = ~int_type & indata_buf_vld;

   // interrupt packet
   assign 	 int_type = ((indata_buf[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_INT) |
			     (indata_buf[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_INT_VEC) |
			     (indata_buf[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_RESET_VEC) |
			     (indata_buf[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_IDLE_VEC) |
			     (indata_buf[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_RESUME_VEC));
		       
   assign 	 int_pending = int_type & indata_buf_vld;

   assign 	 iob_ucb_stall_a1 = (req_ack_pending & req_ack_dbl_buf_full) |
				    (int_pending & int_dbl_buf_full);

   
   /************************************************************
    * Double buffer to store non-interrupt packets
    ************************************************************/
   assign 	 wr_req_ack_dbl_buf = req_ack_pending & ~req_ack_dbl_buf_full;
   
   dbl_buf #(REQ_ACK_BUF_WIDTH) req_ack_dbl_buf (.rst_l(rst_l),
						 .clk(clk),
						 .wr(wr_req_ack_dbl_buf),
						 .din(indata_buf[REQ_ACK_BUF_WIDTH-1:0]),
						 .rd(rd_req_ack_dbl_buf),
						 .dout(req_ack_obj),
						 .vld(req_ack_vld),
						 .full(req_ack_dbl_buf_full));


   /************************************************************
    * Double buffer to store interrupt packets
    ************************************************************/
   assign 	 wr_int_dbl_buf = int_pending & ~int_dbl_buf_full;
   
   dbl_buf #(INT_BUF_WIDTH) int_dbl_buf (.rst_l(rst_l),
					 .clk(clk),
					 .wr(wr_int_dbl_buf),
					 .din(indata_buf[INT_BUF_WIDTH-1:0]),
					 .rd(rd_int_dbl_buf),
					 .dout(int_obj),
					 .vld(int_vld),
					 .full(int_dbl_buf_full));
   

endmodule // i2c_buf


