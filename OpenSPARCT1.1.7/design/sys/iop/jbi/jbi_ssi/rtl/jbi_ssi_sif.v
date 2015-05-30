// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ssi_sif.v
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
//  Description:	SPI block
//  Top level Module:	jbi_ssi_sif
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

module jbi_ssi_sif(/*AUTOARG*/
// Outputs
sif_ucbif_timeout, sif_ucbif_timeout_rw, sif_ucbif_par_err, 
sif_ucbif_busy, sif_ucbif_rdata, sif_ucbif_rdata_vld, 
jbi_io_ssi_mosi, jbi_io_ssi_sck, 
// Inputs
clk, rst_l, arst_l, ctu_jbi_ssiclk, ucbif_sif_timeval, 
ucbif_sif_timeout_accpt, ucbif_sif_vld, ucbif_sif_rw, ucbif_sif_size, 
ucbif_sif_addr, ucbif_sif_wdata, ucbif_sif_rdata_accpt, 
io_jbi_ssi_miso
);
////////////////////////////////////////////////////////////////////////
// Interface signal list declarations
////////////////////////////////////////////////////////////////////////
input clk;
input rst_l;
input arst_l;
input ctu_jbi_ssiclk;  // jbus clk divided by 4

// CSR
input [`JBI_SSI_CSR_TOUT_TIMEVAL_WIDTH-1:0] ucbif_sif_timeval;
input 					    ucbif_sif_timeout_accpt;
output 					    sif_ucbif_timeout;     //assert until accepted
output 					    sif_ucbif_timeout_rw;  //timeout of a rd or wr
output 					    sif_ucbif_par_err;     //for rd par err, assert until accepted

//issue SSI command
output sif_ucbif_busy;
input  ucbif_sif_vld;
input  ucbif_sif_rw;            //instr w/o data will have no dlen asserted
input [`JBI_SSI_SZ_WIDTH-1:0] ucbif_sif_size;
input [`JBI_SSI_ADDR_WIDTH-1:0] ucbif_sif_addr;
input [63:0] 			ucbif_sif_wdata;

//read return data
input 				ucbif_sif_rdata_accpt;
output [63:0] 			sif_ucbif_rdata;
output 				sif_ucbif_rdata_vld;

// SSI bus signals
input 				io_jbi_ssi_miso;
output 				jbi_io_ssi_mosi;
output 				jbi_io_ssi_sck;

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire 				sif_ucbif_timeout;
wire 				sif_ucbif_timeout_rw;
wire 				sif_ucbif_par_err;
wire 				sif_ucbif_busy;
wire [63:0] 			sif_ucbif_rdata;
wire 				sif_ucbif_rdata_vld;
wire 				jbi_io_ssi_mosi;
wire 				jbi_io_ssi_sck;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////
//
// Code start here 
//
parameter SCK_CYC_CNT_WIDTH = 7;

parameter SSI_IDLE    = 3'b000,
	  SSI_REQ     = 3'b001,
	  SSI_WDATA   = 3'b011,
	  SSI_REQ_PAR = 3'b101,
	  SSI_ACK     = 3'b111,
	  SSI_RDATA   = 3'b110,
	  SSI_ACK_PAR = 3'b010;
parameter SSI_SM_WIDTH = 3;

wire [63:0] wdata;
wire [2:0]  wdata_sel;
wire [1:0]  size;
wire 	    rw;
wire [SSI_SM_WIDTH-1:0] ssi_sm;
wire [SCK_CYC_CNT_WIDTH-1:0]  sck_cyc_cnt;
wire 			      par;
wire [`JBI_SSI_CSR_TOUT_TIMEVAL_WIDTH-1:0] timeout_cnt;
wire [63:0] 				   next_wdata;
wire [2:0] 				   next_wdata_sel;
wire [1:0] 				   next_size;
wire 					   next_rw;
reg [SSI_SM_WIDTH-1:0] 			   next_ssi_sm;
reg [SCK_CYC_CNT_WIDTH-1:0] 		   next_sck_cyc_cnt;
reg 					   next_par;
wire [`JBI_SSI_CSR_TOUT_TIMEVAL_WIDTH-1:0] next_timeout_cnt;

wire 					   ctu_jbi_ssiclk_ff;
wire 					   ctu_jbi_ssiclk_d1;

reg [63:0] 				   next_sif_ucbif_rdata;
wire 					   next_sif_ucbif_rdata_vld;
wire 					   next_jbi_io_ssi_sck;
reg 					   next_jbi_io_ssi_mosi;
wire 					   next_sif_ucbif_par_err;
wire 					   next_sif_ucbif_timeout;

wire 					   wdata_en;
wire 					   wdata_sel_en;
wire 					   size_en;
wire 					   rw_en;
wire 					   sif_ucbif_rdata_en;
wire 					   par_en;
wire 					   timeout_cnt_en;

wire 					   ssi_sm_rst_l;
wire 					   sck_cyc_cnt_rst_l;
wire 					   par_rst_l;
wire 					   timeout_cnt_rst_l;
wire 					   sif_ucbif_timeout_rst_l;

wire 					   req_info_en;
wire 					   sck_posedge;
wire 					   sck_posedge_d1;
//wire 					   sck_posedge_d2;
//wire 					   sck_negedge;
wire 					   sck_negedge_d1;
wire 					   sck_negedge_d2;

wire [`JBI_SSI_REQ_WIDTH-1:0] 		   ssi_req;
wire 					   mosi_load_n;
reg [63:0] 				   mosi_shreg_din;
wire 					   mosi_shift_n;
reg 					   mosi_wdata_bit;
wire 					   mosi_shreg0_s_in;
wire 					   mosi_shreg1_s_in;
wire 					   mosi_shreg2_s_in;
wire 					   mosi_shreg3_s_in;
wire 					   mosi_shreg4_s_in;
wire 					   mosi_shreg5_s_in;
wire 					   mosi_shreg6_s_in;
wire 					   mosi_shreg7_s_in;
wire [7:0] 				   mosi_shreg0_p_in;
wire [7:0] 				   mosi_shreg1_p_in;
wire [7:0] 				   mosi_shreg2_p_in;
wire [7:0] 				   mosi_shreg3_p_in;
wire [7:0] 				   mosi_shreg4_p_in;
wire [7:0] 				   mosi_shreg5_p_in;
wire [7:0] 				   mosi_shreg6_p_in;
wire [7:0] 				   mosi_shreg7_p_in;
wire [7:0] 				   mosi_shreg0_p_out;
wire [7:0] 				   mosi_shreg1_p_out;
wire [7:0] 				   mosi_shreg2_p_out;
wire [7:0] 				   mosi_shreg3_p_out;
wire [7:0] 				   mosi_shreg4_p_out;
wire [7:0] 				   mosi_shreg5_p_out;
wire [7:0] 				   mosi_shreg6_p_out;
wire [7:0] 				   mosi_shreg7_p_out;
wire 					   rdata_shift_n;
wire [63:0] 				   rdata_shreg;

wire 					   io_jbi_ssi_miso_ff;
wire 					   ack_par_rdy;

//*******************************************************************************
// Accept new request
//*******************************************************************************

assign sif_ucbif_busy = ssi_sm != SSI_IDLE 
			| sif_ucbif_rdata_vld
                        | sif_ucbif_timeout
                        | ~sck_posedge_d1;
assign req_info_en = ucbif_sif_vld & ~sif_ucbif_busy;


// Store command info
assign next_wdata = ucbif_sif_wdata;
assign wdata_en = req_info_en;

assign next_wdata_sel = ucbif_sif_addr[2:0];
assign wdata_sel_en   = req_info_en;

assign next_size = ucbif_sif_size;
assign size_en   = req_info_en;

assign next_rw = ucbif_sif_rw;
assign rw_en   = req_info_en;

//*******************************************************************************
// SSI State Machine
//*******************************************************************************

assign ssi_sm_rst_l = rst_l & ~sif_ucbif_timeout; // stop processing after timeout

always @(/*AUTOSENSE*/io_jbi_ssi_miso_ff or rw or sck_cyc_cnt
	 or sck_posedge or sck_posedge_d1 or sif_ucbif_timeout or size
	 or ssi_sm or ucbif_sif_vld) begin
   case(ssi_sm)
      SSI_IDLE: begin
	 if (ucbif_sif_vld & sck_posedge_d1)  // must line up with mosi
	    next_ssi_sm = SSI_REQ;
	 else
	    next_ssi_sm = SSI_IDLE;
      end

      SSI_REQ: begin  
	 if (sck_cyc_cnt[5]) begin // == 32 which includes start bit
	    if (rw)
	       next_ssi_sm = SSI_REQ_PAR;
	    else 
	       next_ssi_sm = SSI_WDATA;
	 end
	 else
	    next_ssi_sm = SSI_REQ;
      end

      SSI_WDATA: begin
	 if (  (size == `JBI_SSI_SZ_1BYTE & sck_cyc_cnt[3])
	     | (size == `JBI_SSI_SZ_2BYTE & sck_cyc_cnt[4])
	     | (size == `JBI_SSI_SZ_4BYTE & sck_cyc_cnt[5])
	     | (size == `JBI_SSI_SZ_8BYTE & sck_cyc_cnt[6]))
	    next_ssi_sm = SSI_REQ_PAR;
	 else
	    next_ssi_sm = SSI_WDATA;
      end

      SSI_REQ_PAR: begin
	 if (sck_cyc_cnt[0])
	    next_ssi_sm = SSI_ACK;
	 else
	    next_ssi_sm = SSI_REQ_PAR;
      end

      SSI_ACK: begin  //sample at posedge of sck period + 4 cycle delay from sck gen to recv
	 if (sck_posedge & io_jbi_ssi_miso_ff) begin
	    if (rw)
	       next_ssi_sm = SSI_RDATA;
	    else
	       next_ssi_sm = SSI_ACK_PAR;
	 end
	 else if (sif_ucbif_timeout)
	    next_ssi_sm = SSI_IDLE;
	 else
	    next_ssi_sm = SSI_ACK;
      end

      SSI_RDATA: begin //sample at  posedge of sck period + 4 cycle delay from sck gen to recv
	if (  (size == `JBI_SSI_SZ_1BYTE & sck_cyc_cnt[3])  //cnt incr @ sck_posedge_d1 but FF miso @ sck_posedge
	    | (size == `JBI_SSI_SZ_2BYTE & sck_cyc_cnt[4])
	    | (size == `JBI_SSI_SZ_4BYTE & sck_cyc_cnt[5])
	    | (size == `JBI_SSI_SZ_8BYTE & sck_cyc_cnt[6]))
	   next_ssi_sm = SSI_ACK_PAR;
	else
	   next_ssi_sm = SSI_RDATA;
      end
      
      SSI_ACK_PAR: begin
	 if (sck_cyc_cnt[0])
	    next_ssi_sm = SSI_IDLE;
	 else
	    next_ssi_sm = SSI_ACK_PAR;
      end

// CoverMeter line_off
      default: begin
	 next_ssi_sm = {SSI_SM_WIDTH{1'bx}};
	 //synopsys translate_off
	 $dispmon ("jbi_ssi_sif", 49, "%d %m: ssi_sm = %b", $time, ssi_sm);
	 //synopsys translate_on
      end
// CoverMeter line_on
   endcase
end


//*******************************************************************************
// SCK Dependencies
// - ctu_jbi_ssiclk is jbus clk divided by 4
//*******************************************************************************

assign sck_posedge_d1 = ~ctu_jbi_ssiclk_d1 &  ctu_jbi_ssiclk_ff;
assign sck_negedge_d1 =  ctu_jbi_ssiclk_d1 & ~ctu_jbi_ssiclk_ff;

assign sck_posedge = sck_negedge_d2;
//assign sck_negedge = sck_posedge_d2;

//sck cycle count increments at rising edge of sck
assign sck_cyc_cnt_rst_l = rst_l & ssi_sm == next_ssi_sm;  //clear count when jumping into new state
always @(/*AUTOSENSE*/sck_cyc_cnt or sck_negedge_d1 or sck_posedge
	 or ssi_sm) begin
   if (  (  (ssi_sm == SSI_RDATA | ssi_sm == SSI_ACK_PAR) & sck_negedge_d1)
       | ( ~(ssi_sm == SSI_RDATA | ssi_sm == SSI_ACK_PAR) & sck_posedge))
      next_sck_cyc_cnt = sck_cyc_cnt + 1'b1;
   else
      next_sck_cyc_cnt = sck_cyc_cnt;
end

assign next_jbi_io_ssi_sck = ctu_jbi_ssiclk_ff;

//*******************************************************************************
// SI generation
//*******************************************************************************
//           |  0  |  1  |  2  |  3  |  4  |  5  |  6  |
//            __    __    __    __    __    __    __    __    
//clk      __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \
//            ___________             ___________             
//sck      __/           \___________/           \_________  
//         ________ _______________________ _______________
//mosi     ________X_________data__________X_______________ 
//         __ _______________________ _____________________
//miso     __X_________data__________X_____________________ 
//                                   ^
//                              sample miso


// Load miso shift register
assign ssi_req[`JBI_SSI_REQ_ADDR_HI:`JBI_SSI_REQ_ADDR_LO] = ucbif_sif_addr;
assign ssi_req[`JBI_SSI_REQ_SZ_HI:`JBI_SSI_REQ_SZ_LO]     = ucbif_sif_size;
assign ssi_req[`JBI_SSI_REQ_RW]                           = ucbif_sif_rw;

always @(/*AUTOSENSE*/ssi_req or ssi_sm or wdata) begin
   if (ssi_sm == SSI_IDLE)
      mosi_shreg_din[63:0] = { {33{1'b1}}, ssi_req };
   else
      mosi_shreg_din[63:0] = wdata;
end

assign mosi_load_n = ~(ssi_sm == SSI_IDLE
		       | (ssi_sm == SSI_REQ   // & next_ssi_sm == SSI_WDATA
			  & sck_cyc_cnt[5]
			  & ~rw));

// Advance miso shift register
assign mosi_shift_n = ~(sck_posedge_d1
			& (ssi_sm == SSI_REQ | ssi_sm == SSI_WDATA));

// Determine where wdata is to be taken
always @ ( /*AUTOSENSE*/mosi_shreg0_p_out or mosi_shreg1_p_out
	  or mosi_shreg2_p_out or mosi_shreg3_p_out
	  or mosi_shreg4_p_out or mosi_shreg5_p_out
	  or mosi_shreg6_p_out or mosi_shreg7_p_out or wdata_sel) begin
   case(wdata_sel)
      3'd0: mosi_wdata_bit = mosi_shreg7_p_out[7];
      3'd1: mosi_wdata_bit = mosi_shreg6_p_out[7];
      3'd2: mosi_wdata_bit = mosi_shreg5_p_out[7];
      3'd3: mosi_wdata_bit = mosi_shreg4_p_out[7];
      3'd4: mosi_wdata_bit = mosi_shreg3_p_out[7];
      3'd5: mosi_wdata_bit = mosi_shreg2_p_out[7];
      3'd6: mosi_wdata_bit = mosi_shreg1_p_out[7];
      3'd7: mosi_wdata_bit = mosi_shreg0_p_out[7];
// CoverMeter line_off
      default: mosi_wdata_bit = 1'bx;
// CoverMeter line_on
   endcase
end

// Generate parity
assign par_en =   (  sck_posedge_d1  // gen par
		   & (ssi_sm == SSI_REQ | ssi_sm == SSI_WDATA))
                | (  sck_posedge  // check par
		   & (ssi_sm == SSI_ACK | ssi_sm == SSI_RDATA | ssi_sm == SSI_ACK_PAR));
			  
assign par_rst_l =  rst_l 
                  & ~(  ssi_sm == SSI_IDLE
	              | ssi_sm == SSI_ACK & ~(sck_posedge & io_jbi_ssi_miso_ff));

always @ ( /*AUTOSENSE*/io_jbi_ssi_miso_ff or next_jbi_io_ssi_mosi
	  or par or ssi_sm) begin
   case (ssi_sm)
      SSI_REQ,
      SSI_WDATA:   next_par = par ^ next_jbi_io_ssi_mosi;
      SSI_ACK,
      SSI_RDATA,
      SSI_ACK_PAR: next_par = par ^ io_jbi_ssi_miso_ff;
      default:     next_par = 1'b0;
   endcase
end


// Output MOSI
always @ ( /*AUTOSENSE*/mosi_shreg3_p_out or mosi_wdata_bit or par
	  or ssi_sm) begin
   case (ssi_sm)
      SSI_REQ:      next_jbi_io_ssi_mosi = mosi_shreg3_p_out[7]; // include start bit
      SSI_WDATA:    next_jbi_io_ssi_mosi = mosi_wdata_bit;
      SSI_REQ_PAR:  next_jbi_io_ssi_mosi = par;
      default: next_jbi_io_ssi_mosi = 1'b0;
   endcase
end

//------------------
// Shift Registers
//------------------

assign mosi_shreg0_s_in = 1'b0;
assign mosi_shreg1_s_in = mosi_shreg0_p_out[7];
assign mosi_shreg2_s_in = mosi_shreg1_p_out[7];
assign mosi_shreg3_s_in = mosi_shreg2_p_out[7];
assign mosi_shreg4_s_in = mosi_shreg3_p_out[7];
assign mosi_shreg5_s_in = mosi_shreg4_p_out[7];
assign mosi_shreg6_s_in = mosi_shreg5_p_out[7];
assign mosi_shreg7_s_in = mosi_shreg6_p_out[7];

assign mosi_shreg0_p_in = mosi_shreg_din[ 7: 0];
assign mosi_shreg1_p_in = mosi_shreg_din[15: 8];
assign mosi_shreg2_p_in = mosi_shreg_din[23:16];
assign mosi_shreg3_p_in = mosi_shreg_din[31:24];
assign mosi_shreg4_p_in = mosi_shreg_din[39:32];
assign mosi_shreg5_p_in = mosi_shreg_din[47:40];
assign mosi_shreg6_p_in = mosi_shreg_din[55:48];
assign mosi_shreg7_p_in = mosi_shreg_din[63:56];

jbi_shift_8  u_mosi_shreg0 (/*AUTOINST*/
				 // Outputs
				 .d_out	(mosi_shreg0_p_out),	 // Templated
				 // Inputs
				 .ck	(clk),
				 .ser_in	(mosi_shreg0_s_in),	 // Templated
				 .d_in	(mosi_shreg0_p_in),	 // Templated
				 .shift_l(mosi_shift_n),	 // Templated
				 .load_l(mosi_load_n));		 // Templated
jbi_shift_8 u_mosi_shreg1 (/*AUTOINST*/
				 // Outputs
				 .d_out	(mosi_shreg1_p_out),	 // Templated
				 // Inputs
				 .ck	(clk),
				 .ser_in	(mosi_shreg1_s_in),	 // Templated
				 .d_in	(mosi_shreg1_p_in),	 // Templated
				 .shift_l(mosi_shift_n),	 // Templated
				 .load_l(mosi_load_n));		 // Templated
jbi_shift_8 u_mosi_shreg2 (/*AUTOINST*/
				 // Outputs
				 .d_out	(mosi_shreg2_p_out),	 // Templated
				 // Inputs
				 .ck	(clk),
				 .ser_in	(mosi_shreg2_s_in),	 // Templated
				 .d_in	(mosi_shreg2_p_in),	 // Templated
				 .shift_l(mosi_shift_n),	 // Templated
				 .load_l(mosi_load_n));		 // Templated
jbi_shift_8 u_mosi_shreg3 (/*AUTOINST*/
				 // Outputs
				 .d_out	(mosi_shreg3_p_out),	 // Templated
				 // Inputs
				 .ck	(clk),
				 .ser_in	(mosi_shreg3_s_in),	 // Templated
				 .d_in	(mosi_shreg3_p_in),	 // Templated
				 .shift_l(mosi_shift_n),	 // Templated
				 .load_l(mosi_load_n));		 // Templated
jbi_shift_8 u_mosi_shreg4 (/*AUTOINST*/
				 // Outputs
				 .d_out	(mosi_shreg4_p_out),	 // Templated
				 // Inputs
				 .ck	(clk),
				 .ser_in	(mosi_shreg4_s_in),	 // Templated
				 .d_in	(mosi_shreg4_p_in),	 // Templated
				 .shift_l(mosi_shift_n),	 // Templated
				 .load_l(mosi_load_n));		 // Templated
jbi_shift_8 u_mosi_shreg5 (/*AUTOINST*/
				 // Outputs
				 .d_out	(mosi_shreg5_p_out),	 // Templated
				 // Inputs
				 .ck	(clk),
				 .ser_in	(mosi_shreg5_s_in),	 // Templated
				 .d_in	(mosi_shreg5_p_in),	 // Templated
				 .shift_l(mosi_shift_n),	 // Templated
				 .load_l(mosi_load_n));		 // Templated
jbi_shift_8 u_mosi_shreg6 (/*AUTOINST*/
				 // Outputs
				 .d_out	(mosi_shreg6_p_out),	 // Templated
				 // Inputs
				 .ck	(clk),
				 .ser_in	(mosi_shreg6_s_in),	 // Templated
				 .d_in	(mosi_shreg6_p_in),	 // Templated
				 .shift_l(mosi_shift_n),	 // Templated
				 .load_l(mosi_load_n));		 // Templated
jbi_shift_8 u_mosi_shreg7 (/*AUTOINST*/
				 // Outputs
				 .d_out	(mosi_shreg7_p_out),	 // Templated
				 // Inputs
				 .ck	(clk),
				 .ser_in	(mosi_shreg7_s_in),	 // Templated
				 .d_in	(mosi_shreg7_p_in),	 // Templated
				 .shift_l(mosi_shift_n),	 // Templated
				 .load_l(mosi_load_n));		 // Templated

//*******************************************************************************
// SO Packing
//*******************************************************************************

assign rdata_shift_n = ~(ssi_sm == SSI_RDATA & sck_posedge);

jbi_shift_64 u_rdata_shreg
   (.ck(clk),
    .ser_in(io_jbi_ssi_miso_ff),
    .d_in({64{1'b0}}),
    .shift_l(rdata_shift_n),
    .load_l(rst_l),
    .d_out(rdata_shreg)
    );

// Signal read return data
assign sif_ucbif_rdata_en = ssi_sm == SSI_ACK_PAR;
always @ ( /*AUTOSENSE*/rdata_shreg or size) begin
   case (size)
      `JBI_SSI_SZ_1BYTE: next_sif_ucbif_rdata = {8{rdata_shreg[7:0]}};
      `JBI_SSI_SZ_2BYTE: next_sif_ucbif_rdata = {4{rdata_shreg[15:0]}};
      `JBI_SSI_SZ_4BYTE: next_sif_ucbif_rdata = {2{rdata_shreg[31:0]}};
      `JBI_SSI_SZ_8BYTE: next_sif_ucbif_rdata = rdata_shreg;
// CoverMeter line_off
      default: next_sif_ucbif_rdata = {64{1'bx}};
// CoverMeter line_on
   endcase
end

assign next_sif_ucbif_rdata_vld = ack_par_rdy & rw
				  | (sif_ucbif_rdata_vld 
				     & ~ucbif_sif_rdata_accpt);

//*******************************************************************************
// Error Handling
// - Ack Timeout
// - Parity 
//*******************************************************************************

// Timeout
assign timeout_cnt_en = ssi_sm == SSI_ACK;
assign timeout_cnt_rst_l = rst_l & ssi_sm == SSI_ACK;
assign next_timeout_cnt = timeout_cnt + 1'b1;

assign sif_ucbif_timeout_rst_l = rst_l & ~ucbif_sif_timeout_accpt;

assign next_sif_ucbif_timeout = sif_ucbif_timeout | timeout_cnt == ucbif_sif_timeval;

assign sif_ucbif_timeout_rw = rw;

// Parity - even parity
assign ack_par_rdy = ssi_sm == SSI_ACK_PAR & next_ssi_sm != SSI_ACK_PAR;
assign next_sif_ucbif_par_err =  ack_par_rdy & next_par 
                               | (sif_ucbif_par_err
				  & sif_ucbif_rdata_vld
				  & ~ucbif_sif_rdata_accpt);


//*******************************************************************************
// Async Reset DFFRL Instantiations
//*******************************************************************************
dffrl_async_ns u_dffrl_async_ctu_jbi_ssiclk_ff 
   ( .din (ctu_jbi_ssiclk),
     .clk (clk),
     .rst_l (arst_l),
     .q (ctu_jbi_ssiclk_ff));

dffrl_async_ns #(1) u_dffrl_async_jbi_io_ssi_sck
   (.din(next_jbi_io_ssi_sck),
    .clk(clk),
    .rst_l(arst_l),
    .q(jbi_io_ssi_sck) 
    );

//*******************************************************************************
// DFF Instantiations
//*******************************************************************************

dff_ns #(1) u_dff_io_jbi_ssi_miso_ff
   (.din(io_jbi_ssi_miso),
    .clk(clk),
    .q(io_jbi_ssi_miso_ff) 
    );

dff_ns #(1) u_dff_ctu_jbi_ssiclk_d1
   (.din(ctu_jbi_ssiclk_ff),
    .clk(clk),
    .q(ctu_jbi_ssiclk_d1) 
    );

dff_ns #(1) u_dff_sck_negedge_d2
   (.din(sck_negedge_d1),
    .clk(clk),
    .q(sck_negedge_d2) 
    );

//dff_ns #(1) u_dff_sck_posedge_d2
//   (.din(sck_posedge_d1),
//    .clk(clk),
//    .q(sck_posedge_d2) 
//    );

//*******************************************************************************
// DFFR Instantiations
//*******************************************************************************

dffrl_ns #(SSI_SM_WIDTH) u_dffrl_ssi_sm
   (.din(next_ssi_sm),
    .clk(clk),
    .rst_l(ssi_sm_rst_l),
    .q(ssi_sm) 
    );

dffrl_ns #(SCK_CYC_CNT_WIDTH) u_dffrl_sck_cyc_cnt
   (.din(next_sck_cyc_cnt),
    .clk(clk),
    .rst_l(sck_cyc_cnt_rst_l),
    .q(sck_cyc_cnt) 
    );

dffrl_ns #(1) u_dffrl_sif_ucbif_rdata_vld
   (.din(next_sif_ucbif_rdata_vld),
    .clk(clk),
    .rst_l(rst_l),
    .q(sif_ucbif_rdata_vld) 
    );

dffrl_ns #(1) u_dffrl_sif_ucbif_timeout
   (.din(next_sif_ucbif_timeout),
    .clk(clk),
    .rst_l(sif_ucbif_timeout_rst_l),
    .q(sif_ucbif_timeout) 
    );

dffrl_ns #(1) u_dffrl_sif_ucbif_par_err
   (.din(next_sif_ucbif_par_err),
    .clk(clk),
    .rst_l(rst_l),
    .q(sif_ucbif_par_err) 
    );

dffrl_ns #(1) u_dffrl_jbi_io_ssi_mosi
   (.din(next_jbi_io_ssi_mosi),
    .clk(clk),
    .rst_l(rst_l),
    .q(jbi_io_ssi_mosi) 
    );

//*******************************************************************************
// DFFRE Instantiations
//*******************************************************************************

dffrle_ns #(1) u_dffrle_rw
   (.din(next_rw),
    .clk(clk),
    .rst_l(rst_l),
    .en(rw_en),
    .q(rw) 
    );

dffrle_ns #(2) u_dffrle_size
   (.din(next_size),
    .clk(clk),
    .rst_l(rst_l),
    .en(size_en),
    .q(size) 
    );

dffrle_ns #(64) u_dffrle_wdata
   (.din(next_wdata),
    .clk(clk),
    .rst_l(rst_l),
    .en(wdata_en),
    .q(wdata) 
    );

dffrle_ns #(3) u_dffrle_wdata_sel
   (.din(next_wdata_sel),
    .clk(clk),
    .rst_l(rst_l),
    .en(wdata_sel_en),
    .q(wdata_sel) 
    );

dffrle_ns #(64) u_dffrle_sif_ucbif_rdata
   (.din(next_sif_ucbif_rdata),
    .clk(clk),
    .rst_l(rst_l),
    .en(sif_ucbif_rdata_en),
    .q(sif_ucbif_rdata) 
    );

dffrle_ns #(1) u_dffrle_par
   (.din(next_par),
    .clk(clk),
    .rst_l(par_rst_l),
    .en(par_en),
    .q(par) 
    );

dffrle_ns #(`JBI_SSI_CSR_TOUT_TIMEVAL_WIDTH) u_dffrle_timeout_cnt
   (.din(next_timeout_cnt),
    .clk(clk),
    .rst_l(timeout_cnt_rst_l),
    .en(timeout_cnt_en),
    .q(timeout_cnt) 
    );


endmodule


module jbi_shift_8
(ck, ser_in, d_in, shift_l, load_l, d_out);

input	ck;		// Clock
input	ser_in;		// Serial data in
input	[7:0] d_in;	// Data in
input	shift_l;	// Shift control Active low
input	load_l;		// Load control Active low

output	[7:0] d_out;	// Data out

reg [7:0] d, next_d;

    always @(shift_l or load_l or ser_in or d_in or d)
    begin

   	if (load_l == 1'b0) next_d = d_in;
	else if (load_l == 1'b1)
	begin
	    if (shift_l == 1'b1) next_d = d;
	    else if (shift_l == 1'b0) 
	    begin
		next_d = {d[6:0],ser_in};
	    end
	    else next_d = 8'bxxxx_xxxx;
	end
        else next_d = 8'bxxxx_xxxx;
	
    end

    always @(posedge ck) d <= next_d ;

    assign d_out = d;

endmodule



module jbi_shift_64
(ck, ser_in, d_in, shift_l, load_l, d_out);

input	ck;		// Clock
input	ser_in;		// Serial data in
input	[63:0] d_in;	// Data in
input	shift_l;	// Shift control Active low
input	load_l;		// Load control Active low

output	[63:0] d_out;	// Data out

reg [63:0] d, next_d;

    always @(shift_l or load_l or ser_in or d_in or d)
    begin
   	if (load_l == 1'b0) next_d = d_in;
	else if (load_l == 1'b1)
	begin
	    if (shift_l == 1'b1) next_d = d;
	    else if (shift_l == 1'b0) 
	    begin
		next_d = {d[62:0],ser_in};
	    end
	    else next_d = {64{1'bx}};
	end
        else next_d = {64{1'bx}};
	
    end

    always @(posedge ck) d <= next_d ;

    assign d_out = d;

endmodule


