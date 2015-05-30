// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ssi_ucbif.v
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
//  Description:	UCB Interface Block
//  Top level Module:	jbi_ssi_ucbif
//  Where Instantiated:	jbi_ssi
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

module jbi_ssi_ucbif(/*AUTOARG*/
// Outputs
ucbif_ucb_req_acpted, ucbif_ucb_rd_ack_vld, ucbif_ucb_rd_nack_vld, 
ucbif_ucb_ifill_ack_vld, ucbif_ucb_ifill_nack_vld, 
ucbif_ucb_thr_id_out, ucbif_ucb_buf_id_out, ucbif_ucb_data128, 
ucbif_ucb_data_out, ucbif_ucb_int_vld, ucbif_ucb_int_type, 
ucbif_ucb_dev_id, ucbif_sif_vld, ucbif_sif_rw, ucbif_sif_size, 
ucbif_sif_addr, ucbif_sif_wdata, ucbif_sif_rdata_accpt, 
ucbif_sif_timeout_accpt, ucbif_sif_timeval, 
// Inputs
clk, rst_l, io_jbi_ext_int_l, ucb_ucbif_rd_req_vld, 
ucb_ucbif_ifill_req_vld, ucb_ucbif_wr_req_vld, ucb_ucbif_thr_id_in, 
ucb_ucbif_buf_id_in, ucb_ucbif_size_in, ucb_ucbif_addr_in, 
ucb_ucbif_data_in, ucb_ucbif_ack_busy, ucb_ucbif_int_busy, 
sif_ucbif_busy, sif_ucbif_rdata, sif_ucbif_rdata_vld, 
sif_ucbif_timeout, sif_ucbif_timeout_rw, sif_ucbif_par_err
);
////////////////////////////////////////////////////////////////////////
// Interface signal list declarations
////////////////////////////////////////////////////////////////////////
input clk;
input rst_l;

// pad
input io_jbi_ext_int_l;

// ucb interface
input ucb_ucbif_rd_req_vld;
input ucb_ucbif_ifill_req_vld;  // 4-byte read
input ucb_ucbif_wr_req_vld;
input [`UCB_THR_HI-`UCB_THR_LO:0] ucb_ucbif_thr_id_in;
input [`UCB_BUF_HI-`UCB_BUF_LO:0] ucb_ucbif_buf_id_in;
input [`UCB_SIZE_HI-`UCB_SIZE_LO:0] ucb_ucbif_size_in;
input [`UCB_ADDR_HI-`UCB_ADDR_LO:0] ucb_ucbif_addr_in;
input [`UCB_DATA_HI-`UCB_DATA_LO:0] ucb_ucbif_data_in;
input 				    ucb_ucbif_ack_busy;
input 				    ucb_ucbif_int_busy;
output 				    ucbif_ucb_req_acpted;
output 				    ucbif_ucb_rd_ack_vld;
output 				    ucbif_ucb_rd_nack_vld;
output 				    ucbif_ucb_ifill_ack_vld;
output 				    ucbif_ucb_ifill_nack_vld;
output [`UCB_THR_HI-`UCB_THR_LO:0]  ucbif_ucb_thr_id_out;
output [`UCB_BUF_HI-`UCB_BUF_LO:0]  ucbif_ucb_buf_id_out;
output 				    ucbif_ucb_data128; // set to same as addr_in[3]
output [63:0] 			    ucbif_ucb_data_out;
output 				    ucbif_ucb_int_vld;
output [`UCB_PKT_WIDTH-1:0] 	    ucbif_ucb_int_type;
output [`UCB_INT_DEV_WIDTH-1:0]     ucbif_ucb_dev_id;

//issue SSI command
input 				    sif_ucbif_busy;
output 				    ucbif_sif_vld;
output 				    ucbif_sif_rw;            //instr w/o data will have no dlen asserted
output [`JBI_SSI_SZ_WIDTH-1:0] 	    ucbif_sif_size;
output [`JBI_SSI_ADDR_WIDTH-1:0]    ucbif_sif_addr;
output [63:0] 			    ucbif_sif_wdata;

//read return data
input [63:0] 			    sif_ucbif_rdata;
input 				    sif_ucbif_rdata_vld;
output 				    ucbif_sif_rdata_accpt;
output 				    ucbif_sif_timeout_accpt;

// SSI CSR 
input 				    sif_ucbif_timeout;
input 				    sif_ucbif_timeout_rw;
input 				    sif_ucbif_par_err;
output [`JBI_SSI_CSR_TOUT_TIMEVAL_WIDTH-1:0] ucbif_sif_timeval;


////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 				    ucbif_ucb_req_acpted;
wire 				    ucbif_ucb_rd_ack_vld;
wire 				    ucbif_ucb_rd_nack_vld;
wire 				    ucbif_ucb_ifill_ack_vld;
wire 				    ucbif_ucb_ifill_nack_vld;
wire [`UCB_THR_HI-`UCB_THR_LO:0]    ucbif_ucb_thr_id_out;
wire [`UCB_BUF_HI-`UCB_BUF_LO:0]    ucbif_ucb_buf_id_out;
wire 				    ucbif_ucb_data128; // set to same as addr_in[3]
reg [63:0] 			    ucbif_ucb_data_out;
wire 				    ucbif_ucb_int_vld;
wire [`UCB_PKT_WIDTH-1:0] 	    ucbif_ucb_int_type;
reg [`UCB_INT_DEV_WIDTH-1:0] 	    ucbif_ucb_dev_id;
wire 				    ucbif_sif_vld;
wire 				    ucbif_sif_rw;            //instr w/o data will have no dlen asserted
reg [`JBI_SSI_SZ_WIDTH-1:0] 	    ucbif_sif_size;
wire [`JBI_SSI_ADDR_WIDTH-1:0] 	    ucbif_sif_addr;
wire [63:0] 			    ucbif_sif_wdata;
wire 				    ucbif_sif_rdata_accpt;
wire 				    ucbif_sif_timeout_accpt;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
//
// Code start here 
//

parameter SSI_ADDR = 12'hFF_F,
	  SSI_ADDR_TIMEOUT_REG = 40'hFF_0001_0088,
	  SSI_ADDR_LOG_REG     = 40'hFF_0000_0018;

parameter IF_IDLE = 2'b00,
	  IF_ACPT = 2'b01,
	  IF_DROP = 2'b10;
parameter IF_SM_WIDTH = 2;

wire [IF_SM_WIDTH-1:0] if_sm;
wire 		       ifill;
wire [`JBI_SSI_CSR_TOUT_WIDTH-1:0] timeout_reg;
wire 				   log_parity_reg;
wire 				   log_tout_reg;
wire 				   err_int;
wire 				   ext_int_l_negedge;
reg [IF_SM_WIDTH-1:0] 		   next_if_sm;
wire 				   next_ifill;
reg [`JBI_SSI_CSR_TOUT_WIDTH-1:0]  next_timeout_reg;
reg 				   next_log_parity_reg;
reg 				   next_log_tout_reg;
wire 				   next_err_int;
wire 				   next_ext_int_l_negedge;

wire [`UCB_THR_HI-`UCB_THR_LO:0]   next_ucbif_ucb_thr_id_out;
wire [`UCB_BUF_HI-`UCB_BUF_LO:0]   next_ucbif_ucb_buf_id_out;

wire 				   ifill_en;
wire 				   ucbif_ucb_thr_id_out_en;
wire 				   ucbif_ucb_buf_id_out_en;
wire 				   timeout_reg_en;
wire 				   log_reg_en;
wire 				   err_int_rst_l;
wire 				   ext_int_l_negedge_rst_l;

wire 				   log_par_err;
wire 				   log_timeout;

wire [`JBI_SSI_CSR_TOUT_TIMEVAL_WIDTH-1:0] timeout_timeval;
wire 					   timeout_erren;	   
wire [`JBI_SSI_CSR_LOG_WIDTH-1:0] 	   log_reg;

wire 					   timeout_reg_addr_match;
wire 					   log_reg_addr_match;
wire 					   ssi_addr_match;

wire 					   next_ucbif_sif_rdata_accpt;
wire 					   next_ucbif_sif_timeout_accpt;
wire 					   ack_vld;

wire 					   err_int_accpt;
wire 					   ext_int_accpt;
wire 					   io_jbi_ext_int_l_sync;
wire 					   io_jbi_ext_int_l_pre_sync;

wire 					   ext_int_l;
wire 					   ext_int_l_d1;
wire 					   ext_int_l_d2;
wire 					   ext_int_l_d3;
wire 					   ext_int_l_d4;
wire 					   ext_int_l_d5;
wire 					   ext_int_l_d6;
wire 					   ext_int_l_d7;

//*******************************************************************************
// Accept UBC Request
//*******************************************************************************

always @(/*AUTOSENSE*/if_sm or sif_ucbif_busy or ssi_addr_match
	 or ucb_ucbif_ack_busy or ucb_ucbif_ifill_req_vld
	 or ucb_ucbif_rd_req_vld or ucb_ucbif_size_in
	 or ucb_ucbif_wr_req_vld) begin
   case (if_sm)
      IF_IDLE: begin
	 if ((ucb_ucbif_rd_req_vld 
	      | ucb_ucbif_wr_req_vld
	      | ucb_ucbif_ifill_req_vld)
	     & ~sif_ucbif_busy) begin
	    if (  (~ucb_ucbif_ifill_req_vld
		   & ucb_ucbif_size_in == `UCB_SIZE_16B)  //drop all 16-byte req and nack reads
		| (ucb_ucbif_ifill_req_vld
		   & ~ssi_addr_match))                 //drop ifill access to ssi csr
	       next_if_sm = IF_DROP;
	    else
	       next_if_sm = IF_ACPT;
	 end
	 else
	    next_if_sm = IF_IDLE;
      end

      IF_ACPT: begin
	 if (ssi_addr_match)
	    next_if_sm = IF_IDLE;
	 else begin
	    // reg addr match
	    if  (ucb_ucbif_rd_req_vld
		 & ucb_ucbif_ack_busy)
	       next_if_sm = IF_ACPT;    // wait until ~ack_busy to accept reg read
	    else
	       next_if_sm = IF_IDLE;
	 end
      end

      IF_DROP: begin
	 if (  (ucb_ucbif_rd_req_vld | ucb_ucbif_ifill_req_vld)
	     & ucb_ucbif_ack_busy)
	    next_if_sm = IF_DROP;
	 else
	    next_if_sm = IF_IDLE;
      end
	 
// CoverMeter line_off
      default: begin
	 next_if_sm = {IF_SM_WIDTH{1'bx}};
	 //synopsys translate_off
	 $dispmon ("jbi_ssi_ucbif", 49, "%d %m: if_sm = %b", $time, if_sm);
	 //synopsys translate_on
      end
// CoverMeter line_on
   endcase
end


assign ucbif_ucb_req_acpted =   (if_sm == IF_ACPT
				 & ~(  ~ssi_addr_match     // reg read
				     & ucb_ucbif_rd_req_vld
				     & ucb_ucbif_ack_busy))
                              | (  if_sm == IF_DROP 
				 & next_if_sm == IF_IDLE);

assign ifill_en = next_if_sm == IF_ACPT;
assign next_ifill = ucb_ucbif_ifill_req_vld;

//------------------
// Address Decode
//------------------
assign timeout_reg_addr_match = ucb_ucbif_addr_in[`UCB_ADDR_HI-`UCB_ADDR_LO:0]  == SSI_ADDR_TIMEOUT_REG;
assign log_reg_addr_match     = ucb_ucbif_addr_in[`UCB_ADDR_HI-`UCB_ADDR_LO:0]  == SSI_ADDR_LOG_REG;
assign ssi_addr_match         = ucb_ucbif_addr_in[`UCB_ADDR_HI-`UCB_ADDR_LO:28] == SSI_ADDR;

//-----------------------
// Timeout Register
//-----------------------

assign timeout_reg_en =   if_sm == IF_ACPT 
                        & timeout_reg_addr_match
		        & ucb_ucbif_wr_req_vld;

always @ ( /*AUTOSENSE*/rst_l or timeout_reg or timeout_reg_en
	  or ucb_ucbif_data_in) begin
   if (~rst_l)
      next_timeout_reg = 25'h080_0000;
   else begin
      if (timeout_reg_en)
	 next_timeout_reg = ucb_ucbif_data_in[`JBI_SSI_CSR_TOUT_WIDTH-1:0];
      else
	 next_timeout_reg = timeout_reg;
   end
end

assign timeout_timeval = timeout_reg[`JBI_SSI_CSR_TOUT_TIMEVAL_HI:`JBI_SSI_CSR_TOUT_TIMEVAL_LO];
assign timeout_erren   = timeout_reg[`JBI_SSI_CSR_TOUT_ERREN];

assign ucbif_sif_timeval = timeout_timeval;

//-----------------------
// Log Register
//-----------------------

assign log_reg[`JBI_SSI_CSR_LOG_PARITY] = log_parity_reg;
assign log_reg[`JBI_SSI_CSR_LOG_TOUT]   = log_tout_reg;

assign log_reg_en = if_sm == IF_ACPT 
		    & log_reg_addr_match
		    & ucb_ucbif_wr_req_vld;

assign log_par_err = sif_ucbif_par_err 
                     & timeout_erren
	             & (~sif_ucbif_rdata_vld
	                | ucbif_sif_rdata_accpt);
assign log_timeout = sif_ucbif_timeout 
                     & ucbif_sif_timeout_accpt 
	             & timeout_erren;

always @ ( /*AUTOSENSE*/log_par_err or log_parity_reg or log_reg_en
	  or ucb_ucbif_data_in) begin
   if (log_reg_en & ucb_ucbif_data_in[`JBI_SSI_CSR_LOG_PARITY])
      next_log_parity_reg = 1'b0;
   else begin
      if (log_par_err)
	 next_log_parity_reg = 1'b1;
      else
	 next_log_parity_reg = log_parity_reg;
   end
end

always @ ( /*AUTOSENSE*/log_reg_en or log_timeout or log_tout_reg
	  or ucb_ucbif_data_in) begin
   if (log_reg_en & ucb_ucbif_data_in[`JBI_SSI_CSR_LOG_TOUT])
      next_log_tout_reg = 1'b0;
   else begin
      if (log_timeout)
	 next_log_tout_reg = 1'b1;
      else
	 next_log_tout_reg = log_tout_reg;
   end
end

//------------------------
// Launch SSI Transaction
//------------------------
assign ucbif_sif_vld   =   if_sm == IF_IDLE
			 & next_if_sm == IF_ACPT 
			 & ssi_addr_match;
assign ucbif_sif_rw    = ~ucb_ucbif_wr_req_vld;
assign ucbif_sif_addr  = ucb_ucbif_addr_in[27:0];
assign ucbif_sif_wdata = ucb_ucbif_data_in[63:0];

always @ ( /*AUTOSENSE*/ucb_ucbif_ifill_req_vld or ucb_ucbif_size_in) begin
   if (ucb_ucbif_ifill_req_vld)
      ucbif_sif_size = `JBI_SSI_SZ_4BYTE;
   else
      ucbif_sif_size  = ucb_ucbif_size_in[1:0];
end

      
//*******************************************************************************
// Return Read Data
//*******************************************************************************
assign ack_vld =   (sif_ucbif_rdata_vld
		    & ~ucbif_sif_rdata_accpt
		    & ~ucb_ucbif_ack_busy) //SSI rd return
                 | (if_sm == IF_ACPT 
		    & ~ssi_addr_match      // reg addr match
		    & ucb_ucbif_rd_req_vld
		    & ~ucb_ucbif_ack_busy);

assign ucbif_ucb_rd_ack_vld    = ack_vld & ~sif_ucbif_par_err & ~ifill;
assign ucbif_ucb_ifill_ack_vld = ack_vld & ~sif_ucbif_par_err &  ifill;
assign ucbif_ucb_data128 = 1'b0;

assign ucbif_ucb_rd_nack_vld    =   ( ~ifill 
                                     & (  (ack_vld & sif_ucbif_par_err)
					| (sif_ucbif_timeout 
				       	   & sif_ucbif_timeout_rw 
				       	   & ~ucb_ucbif_ack_busy)))
                                  | (if_sm == IF_DROP
				     & ucb_ucbif_rd_req_vld
				     & ~ucb_ucbif_ack_busy);

assign ucbif_ucb_ifill_nack_vld =   (ifill 
                                     & (  (ack_vld & sif_ucbif_par_err)
					| (sif_ucbif_timeout 
					   & sif_ucbif_timeout_rw 
					   & ~ucb_ucbif_ack_busy)))
                                  | (if_sm == IF_DROP
				     & ucb_ucbif_ifill_req_vld
				     & ~ucb_ucbif_ack_busy);

always @(/*AUTOSENSE*/if_sm or log_reg or sif_ucbif_rdata
	 or sif_ucbif_timeout or timeout_reg or ucb_ucbif_addr_in) begin
   if (if_sm == IF_IDLE)
      ucbif_ucb_data_out[63:0] = sif_ucbif_rdata[63:0];
   else if (sif_ucbif_timeout)
      ucbif_ucb_data_out[63:0] = {64{1'b0}};
   else begin
      case (ucb_ucbif_addr_in[`UCB_ADDR_HI-`UCB_ADDR_LO:0])
	 SSI_ADDR_TIMEOUT_REG: ucbif_ucb_data_out[63:0] = { {64-`JBI_SSI_CSR_TOUT_WIDTH{1'b0}}, timeout_reg };
	 SSI_ADDR_LOG_REG:     ucbif_ucb_data_out[63:0] = { {64-`JBI_SSI_CSR_LOG_WIDTH{1'b0}}, log_reg };
	 default:              ucbif_ucb_data_out[63:0] = {64{1'b0}};
      endcase
   end
end

assign next_ucbif_sif_rdata_accpt = sif_ucbif_rdata_vld
				    & ~ucbif_sif_rdata_accpt
				    & ~ucb_ucbif_ack_busy;

assign next_ucbif_sif_timeout_accpt = sif_ucbif_timeout
                                      & ~ucbif_sif_timeout_accpt
                                      & (  ~sif_ucbif_timeout_rw
                                         | ~ucb_ucbif_ack_busy);

assign next_ucbif_ucb_thr_id_out = ucb_ucbif_thr_id_in;
assign next_ucbif_ucb_buf_id_out = ucb_ucbif_buf_id_in;
assign ucbif_ucb_thr_id_out_en = next_if_sm != IF_IDLE;
assign ucbif_ucb_buf_id_out_en = next_if_sm != IF_IDLE;

//*******************************************************************************
// Interrupt
//*******************************************************************************

// error interrupt
assign err_int_rst_l = rst_l & ~err_int_accpt;
assign next_err_int  = err_int | log_par_err | log_timeout;

// external interrupt
assign ext_int_l_negedge_rst_l = rst_l & ~ext_int_accpt;
assign next_ext_int_l_negedge  =   ~ext_int_l
                                 & ~ext_int_l_d1
                                 & ~ext_int_l_d2
                                 & ~ext_int_l_d3
                                 &  ext_int_l_d4
                                 &  ext_int_l_d5
                                 &  ext_int_l_d6
                                 &  ext_int_l_d7;

// signal interrupt
// - for simplicity, always give error interrupts priority
assign err_int_accpt = ~ucb_ucbif_int_busy &  err_int;
assign ext_int_accpt = ~ucb_ucbif_int_busy & ~err_int & ext_int_l_negedge;

assign ucbif_ucb_int_vld = err_int_accpt | ext_int_accpt;

always @ ( /*AUTOSENSE*/err_int_accpt) begin
   if (err_int_accpt)
      ucbif_ucb_dev_id   = `UCB_INT_DEV_WIDTH'd17;
   else
      ucbif_ucb_dev_id   = `UCB_INT_DEV_WIDTH'd30;
end
 
assign ucbif_ucb_int_type = `UCB_INT;

//*******************************************************************************
//  Synchronization DFF
//*******************************************************************************
//----------------------
// Async -> JBUS
//----------------------

dff_ns #(1) u_dff_io_jbi_ext_int_l_pre_sync
   (.din(io_jbi_ext_int_l),
    .clk(clk),
    .q(io_jbi_ext_int_l_pre_sync)
    );

dff_ns #(1) u_dff_io_jbi_ext_int_l_sync
   (.din(io_jbi_ext_int_l_pre_sync),
    .clk(clk),
    .q(io_jbi_ext_int_l_sync)
    );

//*******************************************************************************
// DFF Instantiations
//*******************************************************************************
dff_ns #(`JBI_SSI_CSR_TOUT_WIDTH) u_dff_timeout_reg
   (.din(next_timeout_reg),
    .clk(clk),
    .q(timeout_reg) 
    );

dff_ns #(1) u_dff_log_parity_reg
   (.din(next_log_parity_reg),
    .clk(clk),
    .q(log_parity_reg) 
    );

dff_ns #(1) u_dff_log_tout_reg
   (.din(next_log_tout_reg),
    .clk(clk),
    .q(log_tout_reg) 
    );

dff_ns #(1) u_dff_ext_int_l
   (.din(io_jbi_ext_int_l_sync),
    .clk(clk),
    .q(ext_int_l) 
    );

dff_ns #(1) u_dff_ext_int_l_d1
   (.din(ext_int_l),
    .clk(clk),
    .q(ext_int_l_d1) 
    );

dff_ns #(1) u_dff_ext_int_l_d2
   (.din(ext_int_l_d1),
    .clk(clk),
    .q(ext_int_l_d2) 
    );

dff_ns #(1) u_dff_ext_int_l_d3
   (.din(ext_int_l_d2),
    .clk(clk),
    .q(ext_int_l_d3) 
    );

dff_ns #(1) u_dff_ext_int_l_d4
   (.din(ext_int_l_d3),
    .clk(clk),
    .q(ext_int_l_d4) 
    );

dff_ns #(1) u_dff_ext_int_l_d5
   (.din(ext_int_l_d4),
    .clk(clk),
    .q(ext_int_l_d5) 
    );

dff_ns #(1) u_dff_ext_int_l_d6
   (.din(ext_int_l_d5),
    .clk(clk),
    .q(ext_int_l_d6) 
    );

dff_ns #(1) u_dff_ext_int_l_d7
   (.din(ext_int_l_d6),
    .clk(clk),
    .q(ext_int_l_d7) 
    );


//*******************************************************************************
// DFFR Instantiations
//*******************************************************************************

dffrl_ns #(IF_SM_WIDTH) u_dffrl_if_sm
   (.din(next_if_sm),
    .clk(clk),
    .rst_l(rst_l),
    .q(if_sm) 
    );

dffrl_ns #(1) u_dffrl_ucbif_sif_rdata_accpt
   (.din(next_ucbif_sif_rdata_accpt),
    .clk(clk),
    .rst_l(rst_l),
    .q(ucbif_sif_rdata_accpt) 
    );

dffrl_ns #(1) u_dffrl_ucbif_sif_timeout_accpt
   (.din(next_ucbif_sif_timeout_accpt),
    .clk(clk),
    .rst_l(rst_l),
    .q(ucbif_sif_timeout_accpt) 
    );

dffrl_ns #(1) u_dffrl_err_int
   (.din(next_err_int),
    .clk(clk),
    .rst_l(err_int_rst_l),
    .q(err_int) 
    );

dffrl_ns #(1) u_dffrl_ext_int_l_negedge
   (.din(next_ext_int_l_negedge),
    .clk(clk),
    .rst_l(ext_int_l_negedge_rst_l),
    .q(ext_int_l_negedge) 
    );

//*******************************************************************************
// DFFRE Instantiations
//*******************************************************************************

dffrle_ns #(1) u_dffrle_ifill
   (.din(next_ifill),
    .clk(clk),
    .rst_l(rst_l),
    .en(ifill_en),
    .q(ifill) 
    );

dffrle_ns #(`UCB_THR_HI-`UCB_THR_LO+1) u_dffrle_ucbif_ucb_thr_id_out
   (.din(next_ucbif_ucb_thr_id_out),
    .clk(clk),
    .rst_l(rst_l),
    .en(ucbif_ucb_thr_id_out_en),
    .q(ucbif_ucb_thr_id_out) 
    );

dffrle_ns #(`UCB_BUF_HI-`UCB_BUF_LO+1) u_dffrle_ucbif_ucb_buf_id_out
   (.din(next_ucbif_ucb_buf_id_out),
    .clk(clk),
    .rst_l(rst_l),
    .en(ucbif_ucb_buf_id_out_en),
    .q(ucbif_ucb_buf_id_out) 
    );


//*******************************************************************************
// Rule Checks
//*******************************************************************************

//synopsys translate_off

always @ ( /*AUTOSENSE*/if_sm or sif_ucbif_rdata_vld) begin
   @clk;
   if (if_sm == IF_ACPT & sif_ucbif_rdata_vld)
      $dispmon ("jbi_ssi_ucbif", 49, "%d %m: ERROR - unexpected read return in IF_ACPT state", $time);
end

//synopsys translate_on

endmodule

// Local Variables:
// verilog-library-directories:("." "../../common/rtl")
// verilog-auto-sense-defines-constant:t
// End:


