// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_ssi.v
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
//
//  Top level Module:	jbi_ssi
//  Where Instantiated:	jbi
//  Description:        ROM Interface Block	
//
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

`include "iop.h"
`include "jbi.h"

module jbi_ssi (/*AUTOARG*/
// Outputs
jbi_io_ssi_mosi, jbi_io_ssi_sck, jbi_iob_spi_vld, jbi_iob_spi_data, 
jbi_iob_spi_stall, 
// Inputs
clk, rst_l, arst_l, ctu_jbi_ssiclk, io_jbi_ssi_miso, 
io_jbi_ext_int_l, iob_jbi_spi_vld, iob_jbi_spi_data, 
iob_jbi_spi_stall
);

input clk;
input rst_l;
input arst_l;
input ctu_jbi_ssiclk;  // jbus clk divided by 4

// IO Pads
output jbi_io_ssi_mosi;	// Master out slave in to pad.
input  io_jbi_ssi_miso;	// Master in slave out from pad.
output jbi_io_ssi_sck;	// Serial clock to pad.
input  io_jbi_ext_int_l;

//IOB Interface
input  iob_jbi_spi_vld;	        // Valid packet from IOB.
input [3:0] iob_jbi_spi_data;	// Packet data from IOB.
input 	    iob_jbi_spi_stall;	// Flow control to stop data.
output 	    jbi_iob_spi_vld;	// Valid packet from UCB.
output [3:0] jbi_iob_spi_data;	// Packet data from UCB.
output 	     jbi_iob_spi_stall;	// Flow control to stop data.

/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
// End of automatics

/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
// End of automatics

////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

//
// Code start here 
//

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire			sif_ucbif_busy;		// From u_sif of jbi_ssi_sif.v
wire			sif_ucbif_par_err;	// From u_sif of jbi_ssi_sif.v
wire [63:0]		sif_ucbif_rdata;	// From u_sif of jbi_ssi_sif.v
wire			sif_ucbif_rdata_vld;	// From u_sif of jbi_ssi_sif.v
wire			sif_ucbif_timeout;	// From u_sif of jbi_ssi_sif.v
wire			sif_ucbif_timeout_rw;	// From u_sif of jbi_ssi_sif.v
wire			ucb_ucbif_ack_busy;	// From u_ucb of ucb_flow_spi.v
wire [`UCB_ADDR_HI-`UCB_ADDR_LO:0]ucb_ucbif_addr_in;// From u_ucb of ucb_flow_spi.v
wire [`UCB_BUF_HI-`UCB_BUF_LO:0]ucb_ucbif_buf_id_in;// From u_ucb of ucb_flow_spi.v
wire [`UCB_DATA_HI-`UCB_DATA_LO:0]ucb_ucbif_data_in;// From u_ucb of ucb_flow_spi.v
wire			ucb_ucbif_ifill_req_vld;// From u_ucb of ucb_flow_spi.v
wire			ucb_ucbif_int_busy;	// From u_ucb of ucb_flow_spi.v
wire			ucb_ucbif_rd_req_vld;	// From u_ucb of ucb_flow_spi.v
wire [`UCB_SIZE_HI-`UCB_SIZE_LO:0]ucb_ucbif_size_in;// From u_ucb of ucb_flow_spi.v
wire [`UCB_THR_HI-`UCB_THR_LO:0]ucb_ucbif_thr_id_in;// From u_ucb of ucb_flow_spi.v
wire			ucb_ucbif_wr_req_vld;	// From u_ucb of ucb_flow_spi.v
wire [`JBI_SSI_ADDR_WIDTH-1:0]ucbif_sif_addr;	// From u_ucbif of jbi_ssi_ucbif.v
wire			ucbif_sif_rdata_accpt;	// From u_ucbif of jbi_ssi_ucbif.v
wire			ucbif_sif_rw;		// From u_ucbif of jbi_ssi_ucbif.v
wire [`JBI_SSI_SZ_WIDTH-1:0]ucbif_sif_size;	// From u_ucbif of jbi_ssi_ucbif.v
wire			ucbif_sif_timeout_accpt;// From u_ucbif of jbi_ssi_ucbif.v
wire [`JBI_SSI_CSR_TOUT_TIMEVAL_WIDTH-1:0]ucbif_sif_timeval;// From u_ucbif of jbi_ssi_ucbif.v
wire			ucbif_sif_vld;		// From u_ucbif of jbi_ssi_ucbif.v
wire [63:0]		ucbif_sif_wdata;	// From u_ucbif of jbi_ssi_ucbif.v
wire [`UCB_BUF_HI-`UCB_BUF_LO:0]ucbif_ucb_buf_id_out;// From u_ucbif of jbi_ssi_ucbif.v
wire			ucbif_ucb_data128;	// From u_ucbif of jbi_ssi_ucbif.v
wire [63:0]		ucbif_ucb_data_out;	// From u_ucbif of jbi_ssi_ucbif.v
wire [`UCB_INT_DEV_WIDTH-1:0]ucbif_ucb_dev_id;	// From u_ucbif of jbi_ssi_ucbif.v
wire			ucbif_ucb_ifill_ack_vld;// From u_ucbif of jbi_ssi_ucbif.v
wire			ucbif_ucb_ifill_nack_vld;// From u_ucbif of jbi_ssi_ucbif.v
wire [`UCB_PKT_WIDTH-1:0]ucbif_ucb_int_type;	// From u_ucbif of jbi_ssi_ucbif.v
wire			ucbif_ucb_int_vld;	// From u_ucbif of jbi_ssi_ucbif.v
wire			ucbif_ucb_rd_ack_vld;	// From u_ucbif of jbi_ssi_ucbif.v
wire			ucbif_ucb_rd_nack_vld;	// From u_ucbif of jbi_ssi_ucbif.v
wire			ucbif_ucb_req_acpted;	// From u_ucbif of jbi_ssi_ucbif.v
wire [`UCB_THR_HI-`UCB_THR_LO:0]ucbif_ucb_thr_id_out;// From u_ucbif of jbi_ssi_ucbif.v
// End of automatics


/* ucb_flow_spi AUTO_TEMPLATE (
 // system input
 .iob_ucb_vld   (iob_jbi_spi_vld),
 .iob_ucb_data  (iob_jbi_spi_data[3:0]),
 .ucb_iob_stall (jbi_iob_spi_stall),
 .iob_ucb_stall (iob_jbi_spi_stall),
 .ucb_iob_vld   (jbi_iob_spi_vld),
 .ucb_iob_data  (jbi_iob_spi_data[3:0]),
 
 .\([a-z_]*\)_req_vld    (ucb_ucbif_\1_req_vld),
 .\([a-z_]*\)_in         (ucb_ucbif_\1_in[]),
 .req_acpted             (ucbif_ucb_req_acpted),
 
 .\([a-z_]*\)ack_vld     (ucbif_ucb_\1ack_vld),
 .\([a-z_]*\)_out        (ucbif_ucb_\1_out[]),
 .data_out               (ucbif_ucb_data_out[63:0]),
 .data128                (ucbif_ucb_data128),
 .ack_busy               (ucb_ucbif_ack_busy),
 
 .int_vld                (ucbif_ucb_int_vld),
 .int_typ                (ucbif_ucb_int_type),
 .int_thr_id             ({`UCB_THR_HI-`UCB_THR_LO+1{1'b0}}),
 .dev_id                 (ucbif_ucb_dev_id),
 .int_stat               ({`UCB_INT_STAT_HI-`UCB_INT_STAT_LO+1{1'b0}}),
 .int_vec                ({`UCB_INT_VEC_HI-`UCB_INT_VEC_LO+1{1'b0}}),
 .int_busy               (ucb_ucbif_int_busy),
 );*/

ucb_flow_spi #(4,4) u_ucb (/*AUTOINST*/
			   // Outputs
			   .ucb_iob_stall(jbi_iob_spi_stall),	 // Templated
			   .rd_req_vld	(ucb_ucbif_rd_req_vld),	 // Templated
			   .wr_req_vld	(ucb_ucbif_wr_req_vld),	 // Templated
			   .ifill_req_vld(ucb_ucbif_ifill_req_vld), // Templated
			   .thr_id_in	(ucb_ucbif_thr_id_in[`UCB_THR_HI-`UCB_THR_LO:0]), // Templated
			   .buf_id_in	(ucb_ucbif_buf_id_in[`UCB_BUF_HI-`UCB_BUF_LO:0]), // Templated
			   .size_in	(ucb_ucbif_size_in[`UCB_SIZE_HI-`UCB_SIZE_LO:0]), // Templated
			   .addr_in	(ucb_ucbif_addr_in[`UCB_ADDR_HI-`UCB_ADDR_LO:0]), // Templated
			   .data_in	(ucb_ucbif_data_in[`UCB_DATA_HI-`UCB_DATA_LO:0]), // Templated
			   .ack_busy	(ucb_ucbif_ack_busy),	 // Templated
			   .int_busy	(ucb_ucbif_int_busy),	 // Templated
			   .ucb_iob_vld	(jbi_iob_spi_vld),	 // Templated
			   .ucb_iob_data(jbi_iob_spi_data[3:0]), // Templated
			   // Inputs
			   .clk		(clk),
			   .rst_l	(rst_l),
			   .iob_ucb_vld	(iob_jbi_spi_vld),	 // Templated
			   .iob_ucb_data(iob_jbi_spi_data[3:0]), // Templated
			   .req_acpted	(ucbif_ucb_req_acpted),	 // Templated
			   .rd_ack_vld	(ucbif_ucb_rd_ack_vld),	 // Templated
			   .rd_nack_vld	(ucbif_ucb_rd_nack_vld), // Templated
			   .ifill_ack_vld(ucbif_ucb_ifill_ack_vld), // Templated
			   .ifill_nack_vld(ucbif_ucb_ifill_nack_vld), // Templated
			   .thr_id_out	(ucbif_ucb_thr_id_out[`UCB_THR_HI-`UCB_THR_LO:0]), // Templated
			   .buf_id_out	(ucbif_ucb_buf_id_out[`UCB_BUF_HI-`UCB_BUF_LO:0]), // Templated
			   .data128	(ucbif_ucb_data128),	 // Templated
			   .data_out	(ucbif_ucb_data_out[63:0]), // Templated
			   .int_vld	(ucbif_ucb_int_vld),	 // Templated
			   .int_typ	(ucbif_ucb_int_type),	 // Templated
			   .int_thr_id	({`UCB_THR_HI-`UCB_THR_LO+1{1'b0}}), // Templated
			   .dev_id	(ucbif_ucb_dev_id),	 // Templated
			   .int_stat	({`UCB_INT_STAT_HI-`UCB_INT_STAT_LO+1{1'b0}}), // Templated
			   .int_vec	({`UCB_INT_VEC_HI-`UCB_INT_VEC_LO+1{1'b0}}), // Templated
			   .iob_ucb_stall(iob_jbi_spi_stall));	 // Templated

jbi_ssi_ucbif  u_ucbif (/*AUTOINST*/
			// Outputs
			.ucbif_ucb_req_acpted(ucbif_ucb_req_acpted),
			.ucbif_ucb_rd_ack_vld(ucbif_ucb_rd_ack_vld),
			.ucbif_ucb_rd_nack_vld(ucbif_ucb_rd_nack_vld),
			.ucbif_ucb_ifill_ack_vld(ucbif_ucb_ifill_ack_vld),
			.ucbif_ucb_ifill_nack_vld(ucbif_ucb_ifill_nack_vld),
			.ucbif_ucb_thr_id_out(ucbif_ucb_thr_id_out[`UCB_THR_HI-`UCB_THR_LO:0]),
			.ucbif_ucb_buf_id_out(ucbif_ucb_buf_id_out[`UCB_BUF_HI-`UCB_BUF_LO:0]),
			.ucbif_ucb_data128(ucbif_ucb_data128),
			.ucbif_ucb_data_out(ucbif_ucb_data_out[63:0]),
			.ucbif_ucb_int_vld(ucbif_ucb_int_vld),
			.ucbif_ucb_int_type(ucbif_ucb_int_type[`UCB_PKT_WIDTH-1:0]),
			.ucbif_ucb_dev_id(ucbif_ucb_dev_id[`UCB_INT_DEV_WIDTH-1:0]),
			.ucbif_sif_vld	(ucbif_sif_vld),
			.ucbif_sif_rw	(ucbif_sif_rw),
			.ucbif_sif_size	(ucbif_sif_size[`JBI_SSI_SZ_WIDTH-1:0]),
			.ucbif_sif_addr	(ucbif_sif_addr[`JBI_SSI_ADDR_WIDTH-1:0]),
			.ucbif_sif_wdata(ucbif_sif_wdata[63:0]),
			.ucbif_sif_rdata_accpt(ucbif_sif_rdata_accpt),
			.ucbif_sif_timeout_accpt(ucbif_sif_timeout_accpt),
			.ucbif_sif_timeval(ucbif_sif_timeval[`JBI_SSI_CSR_TOUT_TIMEVAL_WIDTH-1:0]),
			// Inputs
			.clk		(clk),
			.rst_l		(rst_l),
			.io_jbi_ext_int_l(io_jbi_ext_int_l),
			.ucb_ucbif_rd_req_vld(ucb_ucbif_rd_req_vld),
			.ucb_ucbif_ifill_req_vld(ucb_ucbif_ifill_req_vld),
			.ucb_ucbif_wr_req_vld(ucb_ucbif_wr_req_vld),
			.ucb_ucbif_thr_id_in(ucb_ucbif_thr_id_in[`UCB_THR_HI-`UCB_THR_LO:0]),
			.ucb_ucbif_buf_id_in(ucb_ucbif_buf_id_in[`UCB_BUF_HI-`UCB_BUF_LO:0]),
			.ucb_ucbif_size_in(ucb_ucbif_size_in[`UCB_SIZE_HI-`UCB_SIZE_LO:0]),
			.ucb_ucbif_addr_in(ucb_ucbif_addr_in[`UCB_ADDR_HI-`UCB_ADDR_LO:0]),
			.ucb_ucbif_data_in(ucb_ucbif_data_in[`UCB_DATA_HI-`UCB_DATA_LO:0]),
			.ucb_ucbif_ack_busy(ucb_ucbif_ack_busy),
			.ucb_ucbif_int_busy(ucb_ucbif_int_busy),
			.sif_ucbif_busy	(sif_ucbif_busy),
			.sif_ucbif_rdata(sif_ucbif_rdata[63:0]),
			.sif_ucbif_rdata_vld(sif_ucbif_rdata_vld),
			.sif_ucbif_timeout(sif_ucbif_timeout),
			.sif_ucbif_timeout_rw(sif_ucbif_timeout_rw),
			.sif_ucbif_par_err(sif_ucbif_par_err));

jbi_ssi_sif u_sif (/*AUTOINST*/
		   // Outputs
		   .sif_ucbif_timeout	(sif_ucbif_timeout),
		   .sif_ucbif_timeout_rw(sif_ucbif_timeout_rw),
		   .sif_ucbif_par_err	(sif_ucbif_par_err),
		   .sif_ucbif_busy	(sif_ucbif_busy),
		   .sif_ucbif_rdata	(sif_ucbif_rdata[63:0]),
		   .sif_ucbif_rdata_vld	(sif_ucbif_rdata_vld),
		   .jbi_io_ssi_mosi	(jbi_io_ssi_mosi),
		   .jbi_io_ssi_sck	(jbi_io_ssi_sck),
		   // Inputs
		   .clk			(clk),
		   .rst_l		(rst_l),
		   .arst_l		(arst_l),
		   .ctu_jbi_ssiclk	(ctu_jbi_ssiclk),
		   .ucbif_sif_timeval	(ucbif_sif_timeval[`JBI_SSI_CSR_TOUT_TIMEVAL_WIDTH-1:0]),
		   .ucbif_sif_timeout_accpt(ucbif_sif_timeout_accpt),
		   .ucbif_sif_vld	(ucbif_sif_vld),
		   .ucbif_sif_rw	(ucbif_sif_rw),
		   .ucbif_sif_size	(ucbif_sif_size[`JBI_SSI_SZ_WIDTH-1:0]),
		   .ucbif_sif_addr	(ucbif_sif_addr[`JBI_SSI_ADDR_WIDTH-1:0]),
		   .ucbif_sif_wdata	(ucbif_sif_wdata[63:0]),
		   .ucbif_sif_rdata_accpt(ucbif_sif_rdata_accpt),
		   .io_jbi_ssi_miso	(io_jbi_ssi_miso));


endmodule

// Local Variables:
// verilog-library-directories:("." "../../../common/rtl/")
// verilog-auto-sense-defines-constant:t
// End:
