// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: dram_ucb.v
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

`include "sys.h"

module dram_ucb(/*AUTOARG*/
   // Outputs
   ucb_dram_rd_req_vld0, ucb_dram_rd_req_vld1, ucb_dram_wr_req_vld0, 
   ucb_dram_wr_req_vld1, ucb_dram_addr, ucb_dram_data, ucb_iob_data, 
   ucb_iob_stall, ucb_iob_vld, ddr_clk_tr, 
   ucb_l2if_selfrsh, 
   // Inputs
   clk, rst_l, clspine_dram_selfrsh, 
   iob_ucb_data, iob_ucb_stall, iob_ucb_vld, dram_ucb_ack_vld0, 
   dram_ucb_ack_vld1, dram_ucb_nack_vld0, dram_ucb_nack_vld1, 
   dram_ucb_data0, dram_ucb_data1, l2if_err_intr0, l2if_err_intr1, 
   l2if_ucb_trig0, l2if_ucb_trig1
   );

///////////////////////////////////////////////////////////////////
// OUTPUTS
///////////////////////////////////////////////////////////////////
// TO DRAM
output           	ucb_dram_rd_req_vld0;
output           	ucb_dram_rd_req_vld1;
output           	ucb_dram_wr_req_vld0;
output           	ucb_dram_wr_req_vld1;
output [31:0]    	ucb_dram_addr;
output [63:0]    	ucb_dram_data;

// TO IO BRIDGE
output [3:0]		ucb_iob_data;	
output			ucb_iob_stall;		
output			ucb_iob_vld;	

output			ddr_clk_tr;
output			ucb_l2if_selfrsh;

///////////////////////////////////////////////////////////////////
// INPUTS
///////////////////////////////////////////////////////////////////
input			clk;		
input           	rst_l;

input			clspine_dram_selfrsh;

// FROM IO BRIDGE
input [3:0]		iob_ucb_data;		
input			iob_ucb_stall;		
input			iob_ucb_vld;		

// FROM QUE
input          		dram_ucb_ack_vld0;
input          		dram_ucb_ack_vld1;
input          		dram_ucb_nack_vld0;
input          		dram_ucb_nack_vld1;
input [63:0]   		dram_ucb_data0;
input [63:0]   		dram_ucb_data1;

// FROM L2IF
input			l2if_err_intr0;
input			l2if_err_intr1;
input			l2if_ucb_trig0;
input			l2if_ucb_trig1;

///////////////////////////////////////////////////////////////////
// WIRES
///////////////////////////////////////////////////////////////////
wire [63:0]	dram_ucb_data;
wire [5:0]	thr_id_in;
wire [1:0]	buf_id_in;
//wire [2:0]	size_in;
wire [39:0]	addr_in;
wire [63:0]	ucb_data_in;
wire [5:0]	thr_id_out;
wire [1:0]	buf_id_out;
wire [3:0]	ucb_int_typ;
wire [8:0]	ucb_dev_id;
wire [31:0]	ucb_int_stat;
wire		ucb_req_pend;
wire		ucb_req_pend_en;
wire		ucb_req_pend_reset;
wire		ucb_wr_req_vld;
wire		ucb_wr_req_ack;
wire [63:0]	ucb_data0;
wire [63:0]	ucb_data1;
wire		dram_ucb_ack_vld;
wire		ucb_rd_req_vld0;
wire		ucb_rd_req_vld1;
wire		ucb_wr_req_vld0;
wire		ucb_wr_req_vld1;
wire [5:0]	int_vec;
wire [5:0]	int_thr_id;
wire		wr_req_vld;

///////////////////////////////////////////////////////////////////
// CODE
///////////////////////////////////////////////////////////////////

// Flop the freq 200 sel signal

dff_ns #(1) 	ff_test_signals(
		.din({clspine_dram_selfrsh}), 
		.q({ucb_l2if_selfrsh}),
        	.clk(clk));

// Flop the l2if interface trigger signals

dff_ns #(2) 	ff_trig_signals(
		.din({l2if_ucb_trig0, l2if_ucb_trig1}), 
		.q({ucb_trig0, ucb_trig1}),
        	.clk(clk));


// Flop the inputs from the dramctl interface

dffrl_ns #(4) ff_inputs_vlds(
		.din({dram_ucb_ack_vld0, dram_ucb_ack_vld1, dram_ucb_nack_vld0, dram_ucb_nack_vld1}),
		.q({ucb_ack_vld0, ucb_ack_vld1, ucb_nack_vld0, ucb_nack_vld1}),
		.rst_l(rst_l),
        	.clk(clk));

dff_ns #(128) ff_input_data(
		.din({dram_ucb_data0[63:0], dram_ucb_data1[63:0]}),
		.q({ucb_data0[63:0], ucb_data1[63:0]}),
        	.clk(clk));

// Flop the outputs going to dramctl block

dffrl_ns #(4) 	ff_outputs_vals(
		.din({ucb_rd_req_vld0, ucb_rd_req_vld1, ucb_wr_req_vld0, ucb_wr_req_vld1}),
		.q({ucb_dram_rd_req_vld0, ucb_dram_rd_req_vld1, ucb_dram_wr_req_vld0, ucb_dram_wr_req_vld1}),
		.rst_l(rst_l),
        	.clk(clk));

wire [31:0] ucb_rd_wr_addr = {addr_in[31:14], 2'h0, addr_in[11:0]};
 
dff_ns #(96) 	ff_outputs_data(
		.din({ucb_rd_wr_addr[31:0], ucb_data_in[63:0]}),
		.q({ucb_dram_addr[31:0], ucb_dram_data[63:0]}),
        	.clk(clk));

// Interrupt for crossing max cnt of errors
dff_ns #(2) 	ff_err_intr(
		.din({l2if_err_intr0, l2if_err_intr1}), 
		.q({ucb_err_intr0, ucb_err_intr1}),
        	.clk(clk));

// Instantiate the UCB module that does 4bit - 64 bit and vice versa.
ucb_flow_2buf #(4,4,64)	ucb_flow_2buf(
			      // Outputs
			      .ucb_iob_stall(ucb_iob_stall),
			      .rd_req_vld(rd_req_vld),
			      .wr_req_vld(wr_req_vld),
			      .thr_id_in(thr_id_in[`UCB_THR_HI-`UCB_THR_LO:0]),
			      .buf_id_in(buf_id_in[`UCB_BUF_HI-`UCB_BUF_LO:0]),
			      //.size_in(size_in[`UCB_SIZE_HI-`UCB_SIZE_LO:0]),
			      .addr_in	(addr_in[`UCB_ADDR_HI-`UCB_ADDR_LO:0]),
			      .data_in	(ucb_data_in[`UCB_DATA_HI-`UCB_DATA_LO:0]),
			      .ack_busy	(ucb_dram_ack_busy),
			      .int_busy	(ucb_dram_int_busy),
			      .ucb_iob_vld(ucb_iob_vld),
			      .ucb_iob_data(ucb_iob_data[3:0]),
			      // Inputs
			      .clk	(clk),
			      .rst_l	(rst_l),
			      .iob_ucb_vld(iob_ucb_vld),
			      .iob_ucb_data(iob_ucb_data[3:0]),
			      .req_acpted(dram_ucb_req_acpted),
			      .rd_ack_vld(dram_ucb_ack_vld),
			      .rd_nack_vld(dram_ucb_nack_vld),
			      .thr_id_out(thr_id_out[`UCB_THR_HI-`UCB_THR_LO:0]),
			      .buf_id_out(buf_id_out[`UCB_BUF_HI-`UCB_BUF_LO:0]),
			      .data128(1'b0),
			      .data_out	(dram_ucb_data[63:0]),
			      .int_vld	(ucb_int_vld),
			      .int_typ	(ucb_int_typ[`UCB_PKT_HI-`UCB_PKT_LO:0]),
			      .int_thr_id (int_thr_id[`UCB_THR_HI-`UCB_THR_LO:0]),
			      .dev_id	(ucb_dev_id[`UCB_INT_DEV_HI-`UCB_INT_DEV_LO:0]),
			      .int_stat	(ucb_int_stat[`UCB_INT_STAT_HI-`UCB_INT_STAT_LO:0]),
			      .int_vec  (int_vec[`UCB_INT_VEC_HI-`UCB_INT_VEC_LO:0]),
			      .iob_ucb_stall(iob_ucb_stall));

assign ucb_wr_req_vld0 = wr_req_vld & (addr_in[39:32] == 8'h97) & (addr_in[13] == 1'h0);
assign ucb_wr_req_vld1 = wr_req_vld & (addr_in[39:32] == 8'h97) & (addr_in[13] == 1'h1);
assign ucb_rd_req_vld0 = rd_req_vld & (addr_in[39:32] == 8'h97) & (addr_in[13] == 1'h0) & ~ucb_req_pend;
assign ucb_rd_req_vld1 = rd_req_vld & (addr_in[39:32] == 8'h97) & (addr_in[13] == 1'h1) & ~ucb_req_pend;

assign dram_ucb_req_acpted = ~ucb_req_pend & 
				(ucb_rd_req_vld0 | ucb_rd_req_vld1 | ucb_wr_req_vld0 | ucb_wr_req_vld1);
assign dram_ucb_ack_vld = (ucb_ack_vld0 | ucb_ack_vld1) & ~ucb_dram_ack_busy;
assign dram_ucb_nack_vld = (ucb_nack_vld0 | ucb_nack_vld1) & ~ucb_dram_ack_busy;
assign dram_ucb_data[63:0] = ucb_ack_vld0 ? ucb_data0 : ucb_data1;

// Keep track of pending request till ack came back...

assign ucb_req_pend_en = ucb_wr_req_vld0 | ucb_wr_req_vld1 | ucb_rd_req_vld0 | ucb_rd_req_vld1;
assign ucb_req_pend_reset = ~rst_l | ucb_ack_vld0 | ucb_ack_vld1 | ucb_wr_req_ack |
					ucb_nack_vld0 | ucb_nack_vld1;

dffrle_ns #(1) 	ff_req_pend(
		.din(1'b1),
		.q(ucb_req_pend),
		.en(ucb_req_pend_en),
		.rst_l(~ucb_req_pend_reset),
        	.clk(clk));

// For stores need to create a fake ack_vld after three cycle...
assign ucb_wr_req_vld =  ucb_wr_req_vld0 | ucb_wr_req_vld1;

dffrl_ns #(1) 	ff_wr_ack_d1(
		.din(ucb_wr_req_vld),
		.q(ucb_wr_req_ack),
		.rst_l(rst_l),
        	.clk(clk));

// Save the params so return back to UCB

dffe_ns #(`UCB_THR_HI-`UCB_THR_LO+1+`UCB_BUF_HI-`UCB_BUF_LO+1) ff_thr_id(
        .din({thr_id_in[`UCB_THR_HI-`UCB_THR_LO:0], buf_id_in[`UCB_BUF_HI-`UCB_BUF_LO:0]}),
        .q({thr_id_out[`UCB_THR_HI-`UCB_THR_LO:0], buf_id_out[`UCB_BUF_HI-`UCB_BUF_LO:0]}),
	.en(rd_req_vld),
        .clk(clk));

assign ucb_int_vld = (ucb_err_intr0 | ucb_err_intr1) & ~ucb_dram_int_busy;
assign ucb_dev_id = 9'h1;
assign ucb_int_typ = `UCB_INT;
assign ucb_int_stat = 32'h0;
assign int_thr_id = 6'h0;
assign int_vec = 6'h0;
assign ddr_clk_tr = ucb_trig0 | ucb_trig1;

endmodule

// Local Variables:
// verilog-library-directories:("." "../../../common/rtl")
// End:    
