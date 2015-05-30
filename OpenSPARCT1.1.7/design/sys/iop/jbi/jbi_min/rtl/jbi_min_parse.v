// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_parse.v
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
//  Description:	JBI Inbound Txn Parse Block
//  Top level Module:	jbi_min_parse
//  Where Instantiated:	jbi_min
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

module jbi_min_parse(/*AUTOARG*/
// Outputs
min_j_ad_ff, io_jbi_j_adtype_ff, min_trans_jid, min_snp_launch, 
min_free, min_free_jid, min_mout_inject_err, min_pio_rtrn_push, 
min_pio_data_err, min_mondo_hdr_push, min_mondo_data_push, 
min_mondo_data_err, parse_wdq_push, parse_sctag_req, parse_hdr, 
parse_rw, parse_subline_req, parse_install_mode, parse_data_err, 
parse_err_nonex_rd, parse_wrm, min_csr_err_apar, min_csr_err_adtype, 
min_csr_err_dpar_wr, min_csr_err_dpar_rd, min_csr_err_dpar_o, 
min_csr_err_rep_ue, min_csr_err_illegal, min_csr_err_unsupp, 
min_csr_err_nonex_wr, min_csr_err_nonex_rd, min_csr_err_unmap_wr, 
min_csr_err_err_cycle, min_csr_err_unexp_dr, min_csr_write_log_addr, 
min_csr_log_addr_owner, min_csr_log_addr_adtype, 
min_csr_log_addr_ttype, min_csr_log_addr_addr, min_csr_log_data0, 
min_csr_log_data1, min_csr_log_ctl_owner, min_csr_log_ctl_parity, 
min_csr_log_ctl_adtype0, min_csr_log_ctl_adtype1, 
min_csr_log_ctl_adtype2, min_csr_log_ctl_adtype3, 
min_csr_log_ctl_adtype4, min_csr_log_ctl_adtype5, 
min_csr_log_ctl_adtype6, min_csr_inject_input_done, 
min_csr_perf_dma_rd_in, min_csr_perf_dma_wr, 
min_csr_perf_dma_rd_latency, 
// Inputs
clk, rst_l, io_jbi_j_ad, io_jbi_j_adtype, io_jbi_j_adp, 
mout_dsbl_sampling, mout_scb0_jbus_rd_ack, mout_scb1_jbus_rd_ack, 
mout_scb2_jbus_rd_ack, mout_scb3_jbus_rd_ack, mout_trans_valid, 
mout_min_inject_err_done, mout_min_jbus_owner, 
csr_jbi_config_port_pres, csr_jbi_error_config_erren, 
csr_jbi_log_enb_apar, csr_jbi_log_enb_dpar_wr, 
csr_jbi_log_enb_dpar_rd, csr_jbi_log_enb_dpar_o, 
csr_jbi_log_enb_rep_ue, csr_jbi_log_enb_nonex_rd, 
csr_jbi_log_enb_err_cycle, csr_jbi_log_enb_unexp_dr, 
csr_jbi_memsize_size, csr_jbi_err_inject_output, 
csr_jbi_err_inject_input, csr_jbi_err_inject_errtype, 
csr_jbi_err_inject_xormask, csr_jbi_err_inject_count
);

input clk;
input rst_l;

// JBUS signals
input [127:0] io_jbi_j_ad;
input [7:0]   io_jbi_j_adtype;
input [3:0]   io_jbi_j_adp;

output [127:0] min_j_ad_ff;
output [7:0]   io_jbi_j_adtype_ff;

// Memory Outbound Interface
input 	       mout_dsbl_sampling;
input 	       mout_scb0_jbus_rd_ack;	
input 	       mout_scb1_jbus_rd_ack;	
input 	       mout_scb2_jbus_rd_ack;	
input 	       mout_scb3_jbus_rd_ack;
input 	       mout_trans_valid;
input 	       mout_min_inject_err_done;
input [5:0]    mout_min_jbus_owner;
output [`JBI_JID_WIDTH-1:0] min_trans_jid;
output 			    min_snp_launch;
output 			    min_free;
output [`JBI_JID_WIDTH-1:0] min_free_jid;
output 			    min_mout_inject_err;

// Non-Cache IO (ncio) Interface
output 			    min_pio_rtrn_push;
output 			    min_pio_data_err;
output 			    min_mondo_hdr_push;
output 			    min_mondo_data_push;
output 			    min_mondo_data_err;

// Write Decomposition Interface
output 			    parse_wdq_push;
output [2:0] 		    parse_sctag_req;
output 			    parse_hdr;
output 			    parse_rw;
output 			    parse_subline_req;
output 			    parse_install_mode;
output 			    parse_data_err;  // parity error or ue
output 			    parse_err_nonex_rd; //error - read to non-existent mem space

// Write Tracker
output 			    parse_wrm;

// CSR Error Signals
input 	[6:0]		    csr_jbi_config_port_pres;
input 			    csr_jbi_error_config_erren;
input 			    csr_jbi_log_enb_apar;
input 			    csr_jbi_log_enb_dpar_wr;
input 			    csr_jbi_log_enb_dpar_rd;
input 			    csr_jbi_log_enb_dpar_o;
input 			    csr_jbi_log_enb_rep_ue;
input 			    csr_jbi_log_enb_nonex_rd;
input 			    csr_jbi_log_enb_err_cycle;
input 			    csr_jbi_log_enb_unexp_dr;
input [37:30] 		    csr_jbi_memsize_size;
output 			    min_csr_err_apar;
output 			    min_csr_err_adtype;
output 			    min_csr_err_dpar_wr;
output 			    min_csr_err_dpar_rd;
output 			    min_csr_err_dpar_o;
output 			    min_csr_err_rep_ue;
output 			    min_csr_err_illegal;
output 			    min_csr_err_unsupp;
output 			    min_csr_err_nonex_wr;
output 			    min_csr_err_nonex_rd;
output 			    min_csr_err_unmap_wr;
output 			    min_csr_err_err_cycle;
output 			    min_csr_err_unexp_dr;

output 			    min_csr_write_log_addr;
output 	[2:0]		    min_csr_log_addr_owner;
output 	[7:0]		    min_csr_log_addr_adtype;
output 	[4:0]		    min_csr_log_addr_ttype;
output 	[42:0]		    min_csr_log_addr_addr;
output 	[63:0]		    min_csr_log_data0;
output [63:0] 		    min_csr_log_data1;
output [2:0] 		    min_csr_log_ctl_owner;
output [3:0] 		    min_csr_log_ctl_parity;
output [7:0] 		    min_csr_log_ctl_adtype0;
output [7:0] 		    min_csr_log_ctl_adtype1;
output [7:0] 		    min_csr_log_ctl_adtype2;
output [7:0] 		    min_csr_log_ctl_adtype3;
output [7:0] 		    min_csr_log_ctl_adtype4;
output [7:0] 		    min_csr_log_ctl_adtype5;
output [7:0] 		    min_csr_log_ctl_adtype6;

input 			    csr_jbi_err_inject_output;
input 			    csr_jbi_err_inject_input;
input 			    csr_jbi_err_inject_errtype;
input [3:0] 		    csr_jbi_err_inject_xormask;
input [23:0] 		    csr_jbi_err_inject_count;
output 			    min_csr_inject_input_done;

output 			    min_csr_perf_dma_rd_in;
output 			    min_csr_perf_dma_wr;
output [4:0] 		    min_csr_perf_dma_rd_latency;

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
reg [127:0] 		    min_j_ad_ff;
wire [7:0] 		    io_jbi_j_adtype_ff;
wire 			    min_mout_inject_err;
wire [`JBI_JID_WIDTH-1:0]   min_trans_jid;
wire 			    min_snp_launch;
wire 			    min_free;
wire [`JBI_JID_WIDTH-1:0]   min_free_jid;
wire 			    min_pio_rtrn_push;
wire 			    min_pio_data_err;
wire 			    min_mondo_hdr_push;
wire 			    min_mondo_data_push;
wire 			    min_mondo_data_err;
wire 			    parse_wdq_push;
reg [2:0] 		    parse_sctag_req;
wire 			    parse_hdr;
wire 			    parse_rw;
wire 			    parse_subline_req;
reg 			    parse_install_mode;
wire 			    parse_data_err;
wire 			    parse_err_nonex_rd;
wire 			    parse_wrm;
wire 			    min_csr_err_apar;
wire 			    min_csr_err_adtype;
wire 			    min_csr_err_dpar_wr;
wire 			    min_csr_err_dpar_rd;
wire 			    min_csr_err_dpar_o;
wire 			    min_csr_err_rep_ue;
wire 			    min_csr_err_illegal;
wire 			    min_csr_err_unsupp;
wire 			    min_csr_err_nonex_wr;
wire 			    min_csr_err_nonex_rd;
wire 			    min_csr_err_unmap_wr;
wire			    min_csr_err_err_cycle;
wire 			    min_csr_err_unexp_dr;
wire [2:0] 		    min_csr_log_ctl_owner;
wire [3:0] 		    min_csr_log_ctl_parity;
wire [7:0] 		    min_csr_log_ctl_adtype0;
wire [7:0] 		    min_csr_log_ctl_adtype1;
wire [7:0] 		    min_csr_log_ctl_adtype2;
wire [7:0] 		    min_csr_log_ctl_adtype3;
wire [7:0] 		    min_csr_log_ctl_adtype4;
wire [7:0] 		    min_csr_log_ctl_adtype5;
wire [7:0] 		    min_csr_log_ctl_adtype6;
wire 			    min_csr_inject_input_done;
wire 			    min_csr_perf_dma_rd_in;
wire			    min_csr_perf_dma_wr;
wire [4:0] 		    min_csr_perf_dma_rd_latency;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

parameter ADTYPE_AD      = 4'b0000,
	  ADTYPE_WR_D0   = 4'b0100,
	  ADTYPE_WR_D1   = 4'b0101,
	  ADTYPE_WR_D2   = 4'b0111,
	  ADTYPE_WR_D3   = 4'b0110,
	  ADTYPE_SUBWR_D = 4'b0010,
	  ADTYPE_RTRN_D1 = 4'b1000,
	  ADTYPE_RTRN_D2 = 4'b1001,
	  ADTYPE_RTRN_D3 = 4'b1010,
	  ADTYPE_SM_WIDTH = 4;

wire [ADTYPE_SM_WIDTH-1:0] adtype_sm;
wire [23:0] 		   inject_out_counter;
wire [23:0] 		   inject_in_counter;
wire 			   inject_in_err_done;
wire [4:0] 		   pend_rd_count;
wire [127:0] 		   io_jbi_j_ad_ff;
wire [3:0] 		   io_jbi_j_adp_ff;
reg [ADTYPE_SM_WIDTH-1:0]  next_adtype_sm;
reg [23:0] 		   next_inject_in_counter;
reg [23:0] 		   next_inject_out_counter;
wire 			   next_inject_in_err_done;
reg [4:0] 		   next_pend_rd_count;
wire [127:0] 		   next_io_jbi_j_ad_ff;
wire [3:0] 		   next_io_jbi_j_adp_ff;

wire 			   decr_inject_counter;
wire 			   inject_out_counter_en;
wire 			   inject_out_counter_rst_l;
wire 			   inject_in_counter_en;
wire 			   inject_in_counter_rst_l;
wire 			   inject_in_err_done_rst_l;

wire 			   next_min_mout_inject_err;
wire 			   next_min_snp_launch;
wire 			   next_min_free;
wire [`JBI_JID_WIDTH-1:0]  next_min_free_jid;
wire 			   next_min_csr_perf_dma_rd_in;
wire 			   next_min_csr_perf_dma_wr;

wire 			   mem_addr_match;
wire 			   mmio_addr_match;
wire 			   addr_match;
wire 			   jid_match;
wire 			   type_addr;
wire 			   type_rtrn16;
wire 			   type_rtrn64;
wire 			   type_err;
wire 			   txn_mem_rd;
wire 			   txn_mmio_rd;
wire 			   txn_mem_wr;
wire 			   txn_mmio_wr;
wire 			   txn_rd;
wire 			   txn_wr;
wire 			   txn_int;
wire 			   txn_illegal;
wire 			   txn_unsupported;
wire 			   txn_ignored;
wire 			   txn_coh;

wire 			   wdq_vld;
wire 			   parse_wdq_push_data;
wire 			   mondo_vld;

wire 			   wdq_vld_d1;
wire 			   wdq_vld_d2;
wire 			   wdq_vld_d3;
wire 			   wdq_vld_d4;
wire 			   mondo_vld_d1;

wire [3:0] 		  par;
wire 			  par_err;
wire 			  addr_par_err;
wire 			  unmapped_mem_addr;
wire 			  inject_in_err;

wire [7:0] 		  next_io_jbi_j_adtype_ff;
wire [7:0] 		  io_jbi_j_adtype_ff_d1;
wire [7:0] 		  io_jbi_j_adtype_ff_d2;
wire [7:0] 		  io_jbi_j_adtype_ff_d3;
wire [7:0] 		  io_jbi_j_adtype_ff_d4;
wire [7:0] 		  io_jbi_j_adtype_ff_d5;
wire [7:0] 		  io_jbi_j_adtype_ff_d6;

reg [127:0] 		  j_ad_err_inj;
wire 			  csr_jbi_err_inject_output_d1;
wire 			  csr_jbi_err_inject_input_d1;

wire 			  incr_pend_rd_count;
wire 			  decr_pend_rd_count;

wire 			  apar_of_dpar_err;
wire 			  dpar_of_dpar_err;

wire 			  adtype_sm_wr_d_state;

wire 			  mout_min_jbus_owner0_d1;
wire 			  mout_min_jbus_owner0_d2;
wire 			  mout_min_jbus_owner4_d1;
wire 			  mout_min_jbus_owner4_d2;
wire 			  mout_min_jbus_owner5_d1;
wire 			  mout_min_jbus_owner5_d2;

wire 			  mout_dsbl_sampling_ff;

//
// Code start here 
//

assign 	min_trans_jid = io_jbi_j_adtype_ff[`JBI_ADTYPE_JID_HI:`JBI_ADTYPE_JID_LO];

//*******************************************************************************
// Support Dead Cycle Mode
// - force to all 1's
//*******************************************************************************

assign next_io_jbi_j_ad_ff     = io_jbi_j_ad     | {128{mout_dsbl_sampling_ff}};
assign next_io_jbi_j_adtype_ff = io_jbi_j_adtype | {  8{mout_dsbl_sampling_ff}};
assign next_io_jbi_j_adp_ff    = io_jbi_j_adp    | {  4{mout_dsbl_sampling_ff}};

//*******************************************************************************
// Parse Inbound Transaction
//*******************************************************************************

assign mem_addr_match  = io_jbi_j_ad_ff[42:38] == 5'h00;   // space for agent id 2 and 3 will return err cycle
assign mmio_addr_match = io_jbi_j_ad_ff[42:38] == 5'h18;   //drop all 8MB NC transactions
assign addr_match      = mem_addr_match | mmio_addr_match;

assign jid_match =   io_jbi_j_adtype_ff[`JBI_ADTYPE_AGTID_HI:`JBI_ADTYPE_AGTID_LO] == 4'b0000
                   | io_jbi_j_adtype_ff[`JBI_ADTYPE_AGTID_HI:`JBI_ADTYPE_AGTID_LO] == 4'b0001 
                   | io_jbi_j_adtype_ff[`JBI_ADTYPE_AGTID_HI:`JBI_ADTYPE_AGTID_LO] == 4'b0010 
                   | io_jbi_j_adtype_ff[`JBI_ADTYPE_AGTID_HI:`JBI_ADTYPE_AGTID_LO] == 4'b0011;

assign type_addr   =  io_jbi_j_adtype_ff[`JBI_ADTYPE_TYPE_HI:`JBI_ADTYPE_TYPE_LO] == `JBI_ADTYPE_ADDR
                    & io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO]           != `JBI_TRANS_IDLE;
assign type_rtrn16 =  io_jbi_j_adtype_ff[`JBI_ADTYPE_TYPE_HI:`JBI_ADTYPE_TYPE_LO] == `JBI_ADTYPE_16DRTRN;
assign type_rtrn64 =  io_jbi_j_adtype_ff[`JBI_ADTYPE_TYPE_HI:`JBI_ADTYPE_TYPE_LO] == `JBI_ADTYPE_64DRTRN;
assign type_err    =  io_jbi_j_adtype_ff[`JBI_ADTYPE_TYPE_HI:`JBI_ADTYPE_TYPE_LO] == `JBI_ADTYPE_ERR;

assign txn_mem_rd       =  io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_RD
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_RDD
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_RDS
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_RDSA;

assign txn_mem_wr       =  io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_WRI
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_WRIS
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_WRM;

assign txn_mmio_rd      =  io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_NCRD
          	         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_NCBRD;

assign txn_mmio_wr      =  io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_NCBWR
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_NCWR
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_NCWRC;

assign txn_rd           = txn_mem_rd | txn_mmio_rd;

assign txn_wr           = txn_mem_wr | txn_mmio_wr;

assign txn_int          =  io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_INT;

assign txn_illegal      =  io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO+1] == 4'b0000  // 0x00 to 0x01
          	         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO]   == 5'h09
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO+1] == 4'b1100    // 0x18 to 0x19
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO]   == 5'h1B      // --------
                         | (  io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO+2] == 3'b111  // 0x1B to 0x1E
                            & io_jbi_j_ad_ff[`JBI_AD_TRANS_LO+1:`JBI_AD_TRANS_LO] != 2'b11); // --------   

assign txn_unsupported  =  io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_RDO
          	         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_OWN
          	         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_INV
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_WRB
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_XIR
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_CHANGE;

assign txn_ignored      =  io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_WRBC
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_INTACK
                         | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_INTNACK;

assign txn_coh =  txn_mem_rd
                | txn_mem_wr
                | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_RDO
                | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_OWN
                | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_INV;

assign next_min_snp_launch = adtype_sm == ADTYPE_AD & type_addr & txn_coh & ~addr_par_err;

assign parse_hdr    = adtype_sm == ADTYPE_AD;
assign parse_rw     = txn_rd;

// if read to non-existent memory, treat as subline read to addr zero with
// error bit set in ctag
assign parse_subline_req =  io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_NCWR
                          | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_NCWRC
                          | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_NCRD
                          | parse_err_nonex_rd;
assign parse_wrm         = io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_WRM;

always @ ( /*AUTOSENSE*/io_jbi_j_ad_ff) begin
   case(io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO])
      `JBI_TRANS_RD,
      `JBI_TRANS_RDD,
      `JBI_TRANS_RDSA,
      `JBI_TRANS_RDS,
      `JBI_TRANS_NCRD,
      `JBI_TRANS_NCBRD: parse_sctag_req = `JBI_SCTAG_REQ_RDD;

      `JBI_TRANS_WRM,
      `JBI_TRANS_NCWR,
      `JBI_TRANS_NCWRC: parse_sctag_req = `JBI_SCTAG_REQ_WR8;

      `JBI_TRANS_WRI,
      `JBI_TRANS_WRIS,
      `JBI_TRANS_NCBWR: parse_sctag_req = `JBI_SCTAG_REQ_WRI;

      default: parse_sctag_req =3'd0;
   endcase
end

always @ ( /*AUTOSENSE*/io_jbi_j_ad_ff) begin
   if (  io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_RDS
       | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_RDSA)
      parse_install_mode = `JBI_SCTAG_TAG_INSTALL_SHARED;
   else
      parse_install_mode = `JBI_SCTAG_TAG_INSTALL_INVALID;
end

//------------------
// Request to Memory
//------------------
assign wdq_vld = adtype_sm == ADTYPE_AD
                 & type_addr
		 & addr_match
                 & (txn_rd | txn_wr)
                 & ~addr_par_err;

assign parse_wdq_push_data =  wdq_vld_d1 & adtype_sm == ADTYPE_WR_D0
                            | wdq_vld_d2 & adtype_sm == ADTYPE_WR_D1
                            | wdq_vld_d3 & adtype_sm == ADTYPE_WR_D2
                            | wdq_vld_d4 & adtype_sm == ADTYPE_WR_D3
                            | wdq_vld_d1 & adtype_sm == ADTYPE_SUBWR_D;

assign parse_wdq_push = wdq_vld | parse_wdq_push_data;

//-----------------------------
// Return Data for PIO Read
//-----------------------------
assign min_pio_rtrn_push = adtype_sm == ADTYPE_AD
                           & jid_match
                           & ~(min_csr_err_unexp_dr
			       & csr_jbi_error_config_erren
			       & csr_jbi_log_enb_unexp_dr)
                           & (  (type_rtrn16 
				 & mout_trans_valid
				 & ~addr_par_err)
			      | (type_err 
				 & mout_trans_valid
                                 & ~addr_par_err
				 & csr_jbi_error_config_erren 
				 & csr_jbi_log_enb_err_cycle));

// Signal to prtq data parity error or error cycle (return16 does not have ue)
assign min_pio_data_err = csr_jbi_error_config_erren 
                          & (  (type_err & csr_jbi_log_enb_err_cycle)
			     | (par_err  & csr_jbi_log_enb_dpar_rd));

assign next_min_free = min_pio_rtrn_push;
assign next_min_free_jid = io_jbi_j_adtype_ff[`JBI_ADTYPE_JID_HI:`JBI_ADTYPE_JID_LO];

//-----------------------------
// Mondo Interrupt
//-----------------------------
assign mondo_vld =  adtype_sm == ADTYPE_AD
                  & type_addr
                  & txn_int
                  & ~addr_par_err;
assign min_mondo_hdr_push = mondo_vld;
assign min_mondo_data_push =   mondo_vld_d1 
                             & adtype_sm == ADTYPE_WR_D0;
assign min_mondo_data_err = par_err 
			    & csr_jbi_error_config_erren 
			    & csr_jbi_log_enb_dpar_wr;

//*******************************************************************************
// ADTYPE State Machine
//*******************************************************************************
always @ ( /*AUTOSENSE*/addr_par_err or adtype_sm or io_jbi_j_ad_ff
	  or parse_subline_req or txn_int or txn_wr or type_addr
	  or type_rtrn64) begin
   case (adtype_sm)
      ADTYPE_AD: begin
	 if (type_addr & ~addr_par_err) begin
	     if (txn_wr & parse_subline_req)
		next_adtype_sm = ADTYPE_SUBWR_D;
	    else if (txn_wr | txn_int
		     | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_WRB
		     | io_jbi_j_ad_ff[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO] == `JBI_TRANS_WRBC)
	       next_adtype_sm = ADTYPE_WR_D0;
	    else
	       next_adtype_sm = ADTYPE_AD;
	 end
	 else if (type_rtrn64 & ~addr_par_err)
	    next_adtype_sm = ADTYPE_RTRN_D1;
	 else
	    next_adtype_sm = ADTYPE_AD;
      end

      ADTYPE_WR_D0: next_adtype_sm = ADTYPE_WR_D1;			  
      ADTYPE_WR_D1: next_adtype_sm = ADTYPE_WR_D2;			  
      ADTYPE_WR_D2: next_adtype_sm = ADTYPE_WR_D3;			  
      ADTYPE_WR_D3: next_adtype_sm = ADTYPE_AD;
      ADTYPE_SUBWR_D: next_adtype_sm = ADTYPE_AD;
      ADTYPE_RTRN_D1: next_adtype_sm = ADTYPE_RTRN_D2;  // Workaround for RDS followed by RTRN64
      ADTYPE_RTRN_D2: next_adtype_sm = ADTYPE_RTRN_D3;
      ADTYPE_RTRN_D3: next_adtype_sm = ADTYPE_AD;
// CoverMeter line_off
      default: begin
	 next_adtype_sm = {ADTYPE_SM_WIDTH{1'bx}};
	 //synopsys translate_off
	 $dispmon ("jbi_min_parse", 49,"%d %m: adtype_sm=%b", $time, adtype_sm);
	 //synopsys translate_on
      end
// CoverMeter line_on
   endcase
end

//*******************************************************************************
// Error Handling
//*******************************************************************************

assign decr_inject_counter =   (  csr_jbi_err_inject_errtype   //address cycles excluding idle cycles
			        & adtype_sm == ADTYPE_AD
			        & type_addr)
                             | (  ~csr_jbi_err_inject_errtype  //data cycles
                                & (  (  adtype_sm == ADTYPE_AD
				      & (type_rtrn16 | type_rtrn64 | type_err))
				   | adtype_sm != ADTYPE_AD));

//-----------------------
// Output Error Injection
// - tell mout when do inject error in outgoing transaction
//-----------------------
assign inject_out_counter_en = csr_jbi_err_inject_output;
assign inject_out_counter_rst_l = rst_l & csr_jbi_err_inject_output;

always @ ( /*AUTOSENSE*/csr_jbi_err_inject_count
	  or csr_jbi_err_inject_output_d1 or decr_inject_counter
	  or inject_out_counter) begin
   if (~csr_jbi_err_inject_output_d1)
      next_inject_out_counter = csr_jbi_err_inject_count;
   else begin
      if (inject_out_counter == 24'd0 | ~decr_inject_counter)
	 next_inject_out_counter = inject_out_counter;
      else
	 next_inject_out_counter = inject_out_counter - 1'b1;
   end
end

// tell mout to inject error once when inject_out_counter decrements to zero
// until mout signals that it has done so
assign next_min_mout_inject_err = csr_jbi_err_inject_output
				  & csr_jbi_err_inject_output_d1
				  & next_inject_out_counter == 24'd0
				  & ~mout_min_inject_err_done;

//-----------------------
// Input Error Injection
//-----------------------
assign inject_in_counter_en = csr_jbi_err_inject_input;
assign inject_in_counter_rst_l = rst_l & csr_jbi_err_inject_input;

always @ ( /*AUTOSENSE*/csr_jbi_err_inject_count
	  or csr_jbi_err_inject_input_d1 or decr_inject_counter
	  or inject_in_counter) begin
   if (~csr_jbi_err_inject_input_d1)
      next_inject_in_counter = csr_jbi_err_inject_count;
   else begin
      if (inject_in_counter == 24'd0 | ~decr_inject_counter)
	 next_inject_in_counter = inject_in_counter;
      else
	 next_inject_in_counter = inject_in_counter - 1'b1;
   end
end

// inject error once when inject_in_counter decrements to zero,
// then clear csr_jbi_err_inject_input
assign inject_in_err = csr_jbi_err_inject_input
		       & csr_jbi_err_inject_input_d1
		       & inject_in_counter == 24'd0
                       & ~inject_in_err_done
		       & (  (  csr_jbi_err_inject_errtype   // inject address parity error
			     & (  (adtype_sm == ADTYPE_AD  //wdq_vld 
				   & type_addr
				   & addr_match
				   & (txn_rd | txn_wr))
				| (adtype_sm == ADTYPE_AD   // mondo_vld
				   & type_addr
				   & txn_int)))       
			  | (  ~csr_jbi_err_inject_errtype  // inject data parity error
			     & (  parse_wdq_push_data
				| min_mondo_data_push
				| (adtype_sm == ADTYPE_AD   //min_pio_rtrn_push
                                   & jid_match
                                   & ~(min_csr_err_unexp_dr
			       	       & csr_jbi_error_config_erren
			       	       & csr_jbi_log_enb_unexp_dr)
                                   & (  (type_rtrn16 
					 & mout_trans_valid)
				      | (type_err
					 & mout_trans_valid
					 & csr_jbi_error_config_erren 
					 & csr_jbi_log_enb_err_cycle))))));


assign inject_in_err_done_rst_l = rst_l & csr_jbi_err_inject_input;
assign next_inject_in_err_done = inject_in_err;

always @ ( /*AUTOSENSE*/csr_jbi_err_inject_xormask or inject_in_err
	  or io_jbi_j_ad_ff) begin
   if (inject_in_err)
      j_ad_err_inj = { io_jbi_j_ad_ff[127:97],
		       (io_jbi_j_ad_ff[    96] ^ csr_jbi_err_inject_xormask[3]),
		       io_jbi_j_ad_ff[ 95:65],
		       (io_jbi_j_ad_ff[    64] ^ csr_jbi_err_inject_xormask[2]),
		       io_jbi_j_ad_ff[ 63:33],
		       (io_jbi_j_ad_ff[    32] ^ csr_jbi_err_inject_xormask[1]),
		       io_jbi_j_ad_ff[ 31: 1],
		       (io_jbi_j_ad_ff[     0] ^ csr_jbi_err_inject_xormask[0]) };
   else
      j_ad_err_inj = io_jbi_j_ad_ff;
end

assign min_csr_inject_input_done = inject_in_err_done;

//-----------------------
// Parity
//-----------------------

// parity is calculated on address that has gone through the error injection stage
assign par[0] = ~(^j_ad_err_inj[ 31: 0]);
assign par[1] = ~(^j_ad_err_inj[ 63:32]);
assign par[2] = ~(^j_ad_err_inj[ 95:64]);
assign par[3] = ~(^j_ad_err_inj[127:96] ^ (^io_jbi_j_adtype_ff[7:0]));

assign par_err  = |(io_jbi_j_adp_ff[3:0] ^ par[3:0]);

// On the first cycle of data packets, a parity error over 
// J_ADP[3] / J_ADTYPE / J_AD[127:96] should be treated as an address 
// parity error, since there is no way to know that the error 
// didn't convert the ADTYPE from ADDRESS_Cycle to DATA_Cycle.

assign apar_of_dpar_err = io_jbi_j_adp_ff[3] ^ par[3];
assign dpar_of_dpar_err = |(io_jbi_j_adp_ff[2:0] ^ par[2:0]);


// Need to ignore transactions with address parity errors
assign addr_par_err =   csr_jbi_error_config_erren
                      & csr_jbi_log_enb_apar
                      & (  (par_err & type_addr)
			 | (  apar_of_dpar_err
			    & (type_rtrn16 | type_rtrn64 | type_err)));

// Signal to WDQ data parity error or ue
assign parse_data_err = csr_jbi_error_config_erren 
                        & (  (par_err            & csr_jbi_log_enb_dpar_wr)
			   | (min_csr_err_rep_ue & csr_jbi_log_enb_rep_ue));

//-----------------------
// Log Parity Errors
//-----------------------

// Address Parity Error
// On the first cycle of data packets, a parity error over 
// J_ADP[3] / J_ADTYPE / J_AD[127:96] should be treated as an address 
// parity error, since there is no way to know that the error 
// didn't convert the ADTYPE from ADDRESS_Cycle to DATA_Cycle.

assign min_csr_err_apar =   adtype_sm ==  ADTYPE_AD
                          & (  (   par_err 
			        &  io_jbi_j_adtype_ff[`JBI_ADTYPE_TYPE_HI:`JBI_ADTYPE_TYPE_LO] == `JBI_ADTYPE_ADDR)
			     | (apar_of_dpar_err
				& (type_rtrn16 | type_rtrn64 | type_err)));

// Illegal ADTYPE Error
// - during data cycle, adtype[7] must be 1'b0
assign adtype_sm_wr_d_state = adtype_sm[2] | adtype_sm == ADTYPE_SUBWR_D;

assign min_csr_err_adtype =  (adtype_sm_wr_d_state 
			      & (  io_jbi_j_adtype_ff[7:5] != 3'd0
				 | io_jbi_j_adtype_ff[3:0] != 4'd0))
                           | (adtype_sm == ADTYPE_RTRN_D1
			      & io_jbi_j_adtype_ff[7])
                           | (  (adtype_sm == ADTYPE_RTRN_D2 | adtype_sm == ADTYPE_RTRN_D3)
			      & (  io_jbi_j_adtype_ff[7:5] != 3'd0
				 | io_jbi_j_adtype_ff[2:0] != 3'd0));

// Write Data Parity Error - write or interrupt targetted to us
assign min_csr_err_dpar_wr = par_err
                            & (  parse_wdq_push_data
			       | min_mondo_data_push);

// Read Data Parity Error - read return targetted to Niagara
assign min_csr_err_dpar_rd =  dpar_of_dpar_err & min_pio_rtrn_push;

// Other Data Parity Error - Niagara not target
assign min_csr_err_dpar_o =   (  par_err                            // Data cycle
			       & ~parse_wdq_push_data
			       & ~min_mondo_data_push
			       & ~min_pio_rtrn_push
			       & adtype_sm != ADTYPE_AD )
                            | (dpar_of_dpar_err                     // Data portion of first data return cycle
			       & adtype_sm == ADTYPE_AD
                               & (  ((type_rtrn16 | type_err) & ~jid_match)
				  | type_rtrn64));

// Reported UE Error - Niagara is recipient
assign min_csr_err_rep_ue = parse_wdq_push_data & io_jbi_j_adtype_ff[4];

// Illegal JBUS Command
assign min_csr_err_illegal = adtype_sm == ADTYPE_AD & type_addr & txn_illegal;

// Unsupported JBUS Command
assign min_csr_err_unsupp = adtype_sm == ADTYPE_AD & type_addr & addr_match & txn_unsupported;

// Non-existent Memory Error
assign unmapped_mem_addr =  (j_ad_err_inj[42:38] == 5'h00 & j_ad_err_inj[37:30] >= csr_jbi_memsize_size[37:30])
                          | (j_ad_err_inj[42:38] == 5'h18 & j_ad_err_inj[37:30] >= csr_jbi_memsize_size[37:30]) //[42:36] == 7'h60 | 7'h61
                          | (j_ad_err_inj[42:41] == 2'b10 & j_ad_err_inj[27:25] == 3'b000)  // no 8MB NC for agent id 0 thru 3
                          | (j_ad_err_inj[42:41] == 2'b11 & j_ad_err_inj[40:37] == 4'b0001); // not 64GB NC space for agent id 2 or 3

// Non-existent Memory Error - write
assign min_csr_err_nonex_wr =   adtype_sm == ADTYPE_AD 
                              & type_addr 
                              & (  (txn_wr      & unmapped_mem_addr)
				 | (txn_mem_wr  & mmio_addr_match)
				 | (txn_mmio_wr & mem_addr_match));

// Non-existent Memory Error - read
assign min_csr_err_nonex_rd =   adtype_sm == ADTYPE_AD 
                              & type_addr 
                              & (  (txn_rd      & unmapped_mem_addr)
				 | (txn_mem_rd  & mmio_addr_match)
				 | (txn_mmio_rd & mem_addr_match));

// Unmapped Target - Write Req
assign min_csr_err_unmap_wr =   adtype_sm == ADTYPE_AD 
                              & type_addr
                              & txn_wr
                              & jid_match
                              & (  (  ~csr_jbi_config_port_pres[0]
				    & (  (  j_ad_err_inj[42:41] == 2'b10          /// 8MB NC
					  & j_ad_err_inj[26:23] == 4'b0000)
				       | (  j_ad_err_inj[42:41] == 2'b11          // 64GB NC
					  & j_ad_err_inj[39:36] == 4'b0000)
				       | (  j_ad_err_inj[42:41] == 2'b00          // 64GB Cachable
					  & j_ad_err_inj[39:36] == 4'b0000)))
                                 | (  ~csr_jbi_config_port_pres[1]
				    & (  (  j_ad_err_inj[42:41] == 2'b10          /// 8MB NC
					  & j_ad_err_inj[26:23] == 4'b0001)
				       | (  j_ad_err_inj[42:41] == 2'b11          // 64GB NC
					  & j_ad_err_inj[39:36] == 4'b0001)
				       | (  j_ad_err_inj[42:41] == 2'b00          // 64GB Cachable
					  & j_ad_err_inj[39:36] == 4'b0001)))
                                 | (  ~csr_jbi_config_port_pres[2]
				    & (  (  j_ad_err_inj[42:41] == 2'b10          /// 8MB NC
					  & j_ad_err_inj[26:23] == 4'b0010)
				       | (  j_ad_err_inj[42:41] == 2'b11          // 64GB NC
					  & j_ad_err_inj[39:36] == 4'b0010)
				       | (  j_ad_err_inj[42:41] == 2'b00          // 64GB Cachable
					  & j_ad_err_inj[39:36] == 4'b0010)))
                                 | (  ~csr_jbi_config_port_pres[3]
				    & (  (  j_ad_err_inj[42:41] == 2'b10          /// 8MB NC
					  & j_ad_err_inj[26:23] == 4'b0011)
				       | (  j_ad_err_inj[42:41] == 2'b11          // 64GB NC
					  & j_ad_err_inj[39:36] == 4'b0011)
				       | (  j_ad_err_inj[42:41] == 2'b00          // 64GB Cachable
					  & j_ad_err_inj[39:36] == 4'b0011)))
                                 | (  ~csr_jbi_config_port_pres[4]
				    & (  (  j_ad_err_inj[42:41] == 2'b10          /// 8MB NC
					  & (  j_ad_err_inj[26:24] == 3'b110 
					     | j_ad_err_inj[26:23] == 4'b0100))
				       | (  j_ad_err_inj[42:41] == 2'b11          // 64GB NC
					  & (  j_ad_err_inj[39:37] == 3'b110 
					     | j_ad_err_inj[39:36] == 4'b0100))
				       | (  j_ad_err_inj[42:41] == 2'b00          // 64GB Cachable
					  & (  j_ad_err_inj[39:37] == 3'b110 
					     | j_ad_err_inj[39:36] == 4'b0100))))
				 | (  ~csr_jbi_config_port_pres[5]
				    & (  (  j_ad_err_inj[42:41] == 2'b10          /// 8MB NC
					  & j_ad_err_inj[26:24] == 3'b111)
				       | (  j_ad_err_inj[42:41] == 2'b11          // 64GB NC
					  & j_ad_err_inj[39:37] == 3'b111)
				       | (  j_ad_err_inj[42:41] == 2'b00          // 64GB Cachable
					  & j_ad_err_inj[39:37] == 3'b111)))
                                 | (  ~csr_jbi_config_port_pres[6]
				    & (  (  j_ad_err_inj[42:41] == 2'b10          /// 8MB NC
					  & (  j_ad_err_inj[26:25] == 2'b10 
					     | j_ad_err_inj[26:23] == 4'b0101))
				       | (  j_ad_err_inj[42:41] == 2'b11          // 64GB NC
					  & (  j_ad_err_inj[39:38] == 2'b10 
					     | j_ad_err_inj[39:36] == 4'b0101))
				       | (  j_ad_err_inj[42:41] == 2'b00          // 64GB Cachable
					  & (  j_ad_err_inj[39:38] == 2'b10 
					     | j_ad_err_inj[39:36] == 4'b0101)))));

// JBUS Read Data Error Cycle
assign min_csr_err_err_cycle =  adtype_sm == ADTYPE_AD
                              & jid_match
                              & type_err;

// Unexpected Data Return
assign min_csr_err_unexp_dr  =   adtype_sm == ADTYPE_AD
                               & jid_match
                               & (  type_rtrn64
				  | (  ~mout_trans_valid)
				     & (type_rtrn16 | type_err));

// Log Error Info
assign min_csr_write_log_addr = adtype_sm == ADTYPE_AD & type_addr;
assign min_csr_log_addr_owner = {mout_min_jbus_owner0_d2, 
			 	 mout_min_jbus_owner5_d2, 
			 	 mout_min_jbus_owner4_d2};
assign min_csr_log_addr_adtype = io_jbi_j_adtype_ff;
assign min_csr_log_addr_ttype  = j_ad_err_inj[`JBI_AD_TRANS_HI:`JBI_AD_TRANS_LO];
assign min_csr_log_addr_addr   = j_ad_err_inj[42:0];

assign min_csr_log_data0       = j_ad_err_inj[127:64];
assign min_csr_log_data1       = j_ad_err_inj[ 63: 0];

assign min_csr_log_ctl_owner = min_csr_log_addr_owner;
assign min_csr_log_ctl_parity  = io_jbi_j_adp_ff[3:0];
assign min_csr_log_ctl_adtype0 = io_jbi_j_adtype_ff;
assign min_csr_log_ctl_adtype1 = io_jbi_j_adtype_ff_d1;
assign min_csr_log_ctl_adtype2 = io_jbi_j_adtype_ff_d2;
assign min_csr_log_ctl_adtype3 = io_jbi_j_adtype_ff_d3;
assign min_csr_log_ctl_adtype4 = io_jbi_j_adtype_ff_d4;
assign min_csr_log_ctl_adtype5 = io_jbi_j_adtype_ff_d5;
assign min_csr_log_ctl_adtype6 = io_jbi_j_adtype_ff_d6;

// if read to non-existent memory, treat as subline read to addr zero with
// error bit set in ctag
assign parse_err_nonex_rd =  min_csr_err_nonex_rd
                           & csr_jbi_error_config_erren 
                           & csr_jbi_log_enb_nonex_rd;

always @ ( /*AUTOSENSE*/j_ad_err_inj or parse_err_nonex_rd) begin
   if (parse_err_nonex_rd)
      min_j_ad_ff[127:0] = {128{1'b0}};
   else 
      min_j_ad_ff[127:0] = j_ad_err_inj;
end

//*******************************************************************************
// Performance Counters
//*******************************************************************************

// dma read txns
assign next_min_csr_perf_dma_rd_in = wdq_vld & txn_rd;

// dma write txns
assign next_min_csr_perf_dma_wr    = wdq_vld & txn_wr;

// dma read latency
assign incr_pend_rd_count = wdq_vld & txn_rd;
assign decr_pend_rd_count =  mout_scb0_jbus_rd_ack
                           | mout_scb1_jbus_rd_ack
                           | mout_scb2_jbus_rd_ack
                           | mout_scb3_jbus_rd_ack;

always @ ( /*AUTOSENSE*/decr_pend_rd_count or incr_pend_rd_count
	  or pend_rd_count) begin
   case ({incr_pend_rd_count, decr_pend_rd_count})
      2'b00,
      2'b11: next_pend_rd_count = pend_rd_count;
      2'b01: next_pend_rd_count = pend_rd_count - 1'b1;
      2'b10: next_pend_rd_count = pend_rd_count + 1'b1;
      default: next_pend_rd_count = {5{1'bx}};
   endcase
end

assign min_csr_perf_dma_rd_latency = pend_rd_count;


//*******************************************************************************
// DFF Instantiations
//*******************************************************************************

dff_ns #(1) u_dff_wdq_vld_d1
   (.din(wdq_vld),
    .clk(clk),
    .q(wdq_vld_d1) 
    );

dff_ns #(1) u_dff_wdq_vld_d2
   (.din(wdq_vld_d1),
    .clk(clk),
    .q(wdq_vld_d2) 
    );

dff_ns #(1) u_dff_wdq_vld_d3
   (.din(wdq_vld_d2),
    .clk(clk),
    .q(wdq_vld_d3) 
    );

dff_ns #(1) u_dff_wdq_vld_d4
   (.din(wdq_vld_d3),
    .clk(clk),
    .q(wdq_vld_d4) 
    );

dff_ns #(1) u_dff_mondo_vld_d1
   (.din(mondo_vld),
    .clk(clk),
    .q(mondo_vld_d1) 
    );

dff_ns #(128) u_dff_io_jbi_j_ad_ff
   (.din(next_io_jbi_j_ad_ff),
    .clk(clk),
    .q(io_jbi_j_ad_ff) 
    );

dff_ns #(8) u_dff_io_jbi_j_adtype_ff
   (.din(next_io_jbi_j_adtype_ff),
    .clk(clk),
    .q(io_jbi_j_adtype_ff) 
    );

dff_ns #(4) u_dff_io_jbi_j_adp_ff
   (.din(next_io_jbi_j_adp_ff),
    .clk(clk),
    .q(io_jbi_j_adp_ff) 
    );

dff_ns #(`JBI_JID_WIDTH) u_dff_min_free_jid
   (.din(next_min_free_jid),
    .clk(clk),
    .q(min_free_jid) 
    );

dff_ns #(8) u_dff_io_jbi_j_adtype_ff_d1
   (.din(io_jbi_j_adtype_ff),
    .clk(clk),
    .q(io_jbi_j_adtype_ff_d1) 
    );

dff_ns #(8) u_dff_io_jbi_j_adtype_ff_d2
   (.din(io_jbi_j_adtype_ff_d1),
    .clk(clk),
    .q(io_jbi_j_adtype_ff_d2) 
    );

dff_ns #(8) u_dff_io_jbi_j_adtype_ff_d3
   (.din(io_jbi_j_adtype_ff_d2),
    .clk(clk),
    .q(io_jbi_j_adtype_ff_d3) 
    );

dff_ns #(8) u_dff_io_jbi_j_adtype_ff_d4
   (.din(io_jbi_j_adtype_ff_d3),
    .clk(clk),
    .q(io_jbi_j_adtype_ff_d4) 
    );

dff_ns #(8) u_dff_io_jbi_j_adtype_ff_d5
   (.din(io_jbi_j_adtype_ff_d4),
    .clk(clk),
    .q(io_jbi_j_adtype_ff_d5) 
    );

dff_ns #(8) u_dff_io_jbi_j_adtype_ff_d6
   (.din(io_jbi_j_adtype_ff_d5),
    .clk(clk),
    .q(io_jbi_j_adtype_ff_d6) 
    );

dff_ns #(1) u_dff_csr_jbi_err_inject_output_d1
   (.din(csr_jbi_err_inject_output),
    .clk(clk),
    .q(csr_jbi_err_inject_output_d1) 
    );

dff_ns #(1) u_dff_csr_jbi_err_inject_input_d1
   (.din(csr_jbi_err_inject_input),
    .clk(clk),
    .q(csr_jbi_err_inject_input_d1) 
    );

dff_ns #(1) u_dff_mout_min_jbus_owner0_d1
   (.din(mout_min_jbus_owner[0]),
    .clk(clk),
    .q(mout_min_jbus_owner0_d1) 
    );

dff_ns #(1) u_dff_mout_min_jbus_owner0_d2
   (.din(mout_min_jbus_owner0_d1),
    .clk(clk),
    .q(mout_min_jbus_owner0_d2) 
    );

dff_ns #(1) u_dff_mout_min_jbus_owner4_d1
   (.din(mout_min_jbus_owner[4]),
    .clk(clk),
    .q(mout_min_jbus_owner4_d1) 
    );

dff_ns #(1) u_dff_mout_min_jbus_owner4_d2
   (.din(mout_min_jbus_owner4_d1),
    .clk(clk),
    .q(mout_min_jbus_owner4_d2) 
    );

dff_ns #(1) u_dff_mout_min_jbus_owner5_d1
   (.din(mout_min_jbus_owner[5]),
    .clk(clk),
    .q(mout_min_jbus_owner5_d1) 
    );

dff_ns #(1) u_dff_mout_min_jbus_owner5_d2
   (.din(mout_min_jbus_owner5_d1),
    .clk(clk),
    .q(mout_min_jbus_owner5_d2) 
    );

dff_ns #(1) u_dff_mout_dsbl_sampling_ff
   (.din(mout_dsbl_sampling),
    .clk(clk),
    .q(mout_dsbl_sampling_ff) 
    );

//*******************************************************************************
// DFFRL Instantiations
//*******************************************************************************
dffrl_ns #(ADTYPE_SM_WIDTH) u_dffrl_adtype_sm
   (.din(next_adtype_sm),
    .clk(clk),
    .rst_l(rst_l),
    .q(adtype_sm)
    );

dffrl_ns #(1) u_dffrl_min_mout_inject_err
   (.din(next_min_mout_inject_err),
    .clk(clk),
    .rst_l(rst_l),
    .q(min_mout_inject_err)
    );

dffrl_ns #(1) u_dffrl_min_snp_launch
   (.din(next_min_snp_launch),
    .clk(clk),
    .rst_l(rst_l),
    .q(min_snp_launch)
    );

dffrl_ns #(1) u_dffrl_min_free
   (.din(next_min_free),
    .clk(clk),
    .rst_l(rst_l),
    .q(min_free)
    );

dffrl_ns #(1) u_dffrl_inject_in_err_done
   (.din(next_inject_in_err_done),
    .clk(clk),
    .rst_l(inject_in_err_done_rst_l),
    .q(inject_in_err_done)
    );

dffrl_ns #(1) u_dffrl_min_csr_perf_dma_rd_in
   (.din(next_min_csr_perf_dma_rd_in),
    .clk(clk),
    .rst_l(rst_l),
    .q(min_csr_perf_dma_rd_in)
    );

dffrl_ns #(1) u_dffrl_min_csr_perf_dma_wr
   (.din(next_min_csr_perf_dma_wr),
    .clk(clk),
    .rst_l(rst_l),
    .q(min_csr_perf_dma_wr)
    );

dffrl_ns #(5) u_dffrl_pend_rd_count
   (.din(next_pend_rd_count),
    .clk(clk),
    .rst_l(rst_l),
    .q(pend_rd_count)
    );


//*******************************************************************************
// DFFRLE Instantiations
//*******************************************************************************
dffrle_ns #(24) u_dffrle_inject_out_counter
   (.din(next_inject_out_counter),
    .clk(clk),
    .en(inject_out_counter_en),
    .rst_l(inject_out_counter_rst_l),
    .q(inject_out_counter)
    );

dffrle_ns #(24) u_dffrle_inject_in_counter
   (.din(next_inject_in_counter),
    .clk(clk),
    .en(inject_in_counter_en),
    .rst_l(inject_in_counter_rst_l),
    .q(inject_in_counter)
    );


//*******************************************************************************
// Rule Checks
//*******************************************************************************

//synopsys translate_off

always @(/*AUTOSENSE*/adtype_sm or jid_match or type_rtrn64) begin
   @clk;
   if (adtype_sm == ADTYPE_AD & type_rtrn64 & jid_match)
      $dispmon ("jbi_min_parse", 49, "%d %m: ERROR - JBI receives illegal Read64 data return",
		$time);
end

//synopsys translate_on

endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:
