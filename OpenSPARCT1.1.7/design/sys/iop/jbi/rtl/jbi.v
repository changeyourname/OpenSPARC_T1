// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi.v
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
//  Description:	JBus Interface
*/


`include "sys.h"
`include "iop.h"
`include "jbi.h"


module jbi (/*AUTOARG*/
// Outputs
jbi_ddr3_scanout18, jbi_clk_tr, jbi_jbusr_so, jbi_jbusr_se, 
jbi_sctag0_req, jbi_scbuf0_ecc, jbi_sctag0_req_vld, jbi_sctag1_req, 
jbi_scbuf1_ecc, jbi_sctag1_req_vld, jbi_sctag2_req, jbi_scbuf2_ecc, 
jbi_sctag2_req_vld, jbi_sctag3_req, jbi_scbuf3_ecc, 
jbi_sctag3_req_vld, jbi_iob_pio_vld, jbi_iob_pio_data, 
jbi_iob_pio_stall, jbi_iob_mondo_vld, jbi_iob_mondo_data, 
jbi_io_ssi_mosi, jbi_io_ssi_sck, jbi_iob_spi_vld, jbi_iob_spi_data, 
jbi_iob_spi_stall, jbi_io_j_req0_out_l, jbi_io_j_req0_out_en, 
jbi_io_j_adtype, jbi_io_j_adtype_en, jbi_io_j_ad, jbi_io_j_ad_en, 
jbi_io_j_pack0, jbi_io_j_pack0_en, jbi_io_j_pack1, jbi_io_j_pack1_en, 
jbi_io_j_adp, jbi_io_j_adp_en, jbi_io_config_dtl, 
// Inputs
cmp_gclk, cmp_arst_l, cmp_grst_l, jbus_gclk, jbus_arst_l, 
jbus_grst_l, ctu_jbi_ssiclk, ctu_jbi_tx_en, ctu_jbi_rx_en, 
ctu_jbi_fst_rst_l, clk_jbi_jbus_cken, clk_jbi_cmp_cken, 
global_shift_enable, ctu_tst_scanmode, ctu_tst_pre_grst_l, 
ctu_tst_scan_disable, ctu_tst_macrotest, ctu_tst_short_chain, 
ddr3_jbi_scanin18, jbusr_jbi_si, sctag0_jbi_iq_dequeue, 
sctag0_jbi_wib_dequeue, scbuf0_jbi_data, scbuf0_jbi_ctag_vld, 
scbuf0_jbi_ue_err, sctag0_jbi_por_req_buf, sctag1_jbi_iq_dequeue, 
sctag1_jbi_wib_dequeue, scbuf1_jbi_data, scbuf1_jbi_ctag_vld, 
scbuf1_jbi_ue_err, sctag1_jbi_por_req_buf, sctag2_jbi_iq_dequeue, 
sctag2_jbi_wib_dequeue, scbuf2_jbi_data, scbuf2_jbi_ctag_vld, 
scbuf2_jbi_ue_err, sctag2_jbi_por_req_buf, sctag3_jbi_iq_dequeue, 
sctag3_jbi_wib_dequeue, scbuf3_jbi_data, scbuf3_jbi_ctag_vld, 
scbuf3_jbi_ue_err, sctag3_jbi_por_req_buf, iob_jbi_pio_stall, 
iob_jbi_pio_vld, iob_jbi_pio_data, iob_jbi_mondo_ack, 
iob_jbi_mondo_nack, io_jbi_ssi_miso, io_jbi_ext_int_l, 
iob_jbi_spi_vld, iob_jbi_spi_data, iob_jbi_spi_stall, 
io_jbi_j_req4_in_l, io_jbi_j_req5_in_l, io_jbi_j_adtype, io_jbi_j_ad, 
io_jbi_j_pack4, io_jbi_j_pack5, io_jbi_j_adp, io_jbi_j_par, 
iob_jbi_dbg_hi_data, iob_jbi_dbg_hi_vld, iob_jbi_dbg_lo_data, 
iob_jbi_dbg_lo_vld
);

  // Clocks and reset.
  input		 cmp_gclk;					// CMP clock.
  input 	 cmp_arst_l;					// CMP clock domain async reset.
  input 	 cmp_grst_l;					// CMP clock domain reset.
  input 	 jbus_gclk;	  				// JBus clock.
  input 	 jbus_arst_l;	  				// JBus clock domain async reset.
  input 	 jbus_grst_l;	  				// JBus clock domain reset.
  input 	 ctu_jbi_ssiclk;  				// jbus clk divided by 4
  input 	 ctu_jbi_tx_en;	  				// CMP to JBI clock domain crossing synchronization pulse.
  input 	 ctu_jbi_rx_en;	  				// JBI to CMP clock domain crossing synchronization pulse.
  input 	 ctu_jbi_fst_rst_l;				// Fast reset for capturing port present bits (J_RST_L + 1).

  // Scan and DFT.
  input 	 clk_jbi_jbus_cken;                             // Jbi clock enable.
  input          clk_jbi_cmp_cken; 				// Cmp clock enable.
  input 	 global_shift_enable;				// Scan shift enable signal.
  input		 ctu_tst_scanmode;				// Scan mode.
  input 	 ctu_tst_pre_grst_l;
  input 	 ctu_tst_scan_disable;
  input 	 ctu_tst_macrotest;
  input 	 ctu_tst_short_chain;
  input    	 ddr3_jbi_scanin18;
  output 	 jbi_ddr3_scanout18;
  output 	 jbi_clk_tr;					// Debug_trigger.
  output  	 jbi_jbusr_so;
  output  	 jbi_jbusr_se;
  input   	 jbusr_jbi_si;
   
  // SCBuf0/SCTag0 Interface.
  //
  // Inbound Requests and Return Data.
  output  [31:0] jbi_sctag0_req;
  output   [6:0] jbi_scbuf0_ecc;
  output 	 jbi_sctag0_req_vld;				// Next cycle will be Header of a new request packet.
  input 	 sctag0_jbi_iq_dequeue;				// SCTag is unloading a request from its 2 req queue.
  input 	 sctag0_jbi_wib_dequeue;			// Write invalidate buffer (size=4) is being unloaded.
  //
  // Outbound Requests and Return Data.
  input   [31:0] scbuf0_jbi_data;
  input 	 scbuf0_jbi_ctag_vld;				// Header cycle of a new response packet.
  input 	 scbuf0_jbi_ue_err;				// Current data cycle has a uncorrectable error.
  input 	 sctag0_jbi_por_req_buf;			// Request for DOK_FATAL.


  // SCBuf1/SCTag1 Interface.
  //
  // Inbound Requests and Return Data.
  output  [31:0] jbi_sctag1_req;
  output   [6:0] jbi_scbuf1_ecc;
  output 	 jbi_sctag1_req_vld;				// Next cycle will be Header of a new request packet.
  input 	 sctag1_jbi_iq_dequeue;				// SCTag is unloading a request from its 2 req queue.
  input 	 sctag1_jbi_wib_dequeue;			// Write invalidate buffer (size=4) is being unloaded.
  //
  // Outbound Requests and Return Data.
  input   [31:0] scbuf1_jbi_data;
  input 	 scbuf1_jbi_ctag_vld;				// Header cycle of a new response packet.
  input 	 scbuf1_jbi_ue_err;				// Current data cycle has a uncorrectable error.
  input 	 sctag1_jbi_por_req_buf;			// Request for DOK_FATAL.


  // SCBuf2/SCTag2 Interface.
  //
  // Inbound Requests and Return Data.
  output  [31:0] jbi_sctag2_req;
  output   [6:0] jbi_scbuf2_ecc;
  output 	 jbi_sctag2_req_vld;				// Next cycle will be Header of a new request packet.
  input 	 sctag2_jbi_iq_dequeue;				// SCTag is unloading a request from its 2 req queue.
  input 	 sctag2_jbi_wib_dequeue;			// Write invalidate buffer (size=4) is being unloaded.
  //
  // Outbound Requests and Return Data.
  input   [31:0] scbuf2_jbi_data;
  input 	 scbuf2_jbi_ctag_vld;				// Header cycle of a new response packet.
  input 	 scbuf2_jbi_ue_err;				// Current data cycle has a uncorrectable error.
  input 	 sctag2_jbi_por_req_buf;			// Request for DOK_FATAL.


  // SCBuf3/SCTag3 Interface.
  //
  // Inbound Requests and Return Data.
  output  [31:0] jbi_sctag3_req;
  output   [6:0] jbi_scbuf3_ecc;
  output 	 jbi_sctag3_req_vld;				// Next cycle will be Header of a new request packet.
  input 	 sctag3_jbi_iq_dequeue;				// SCTag is unloading a request from its 2 req queue.
  input 	 sctag3_jbi_wib_dequeue;			// Write invalidate buffer (size=4) is being unloaded.
  //
  // Outbound Requests and Return Data.
  input   [31:0] scbuf3_jbi_data;
  input 	 scbuf3_jbi_ctag_vld;				// Header cycle of a new response packet.
  input 	 scbuf3_jbi_ue_err;				// Current data cycle has a uncorrectable error.
  input 	 sctag3_jbi_por_req_buf;			// Request for DOK_FATAL.


  // IOB Interface.
  // 
  // Inbound PIO Interrupt Requests, PIO Responses.
  output	                        jbi_iob_pio_vld;
  output 	   [`JBI_IOB_WIDTH-1:0] jbi_iob_pio_data;
  input 				iob_jbi_pio_stall;
  //
  // Outbound PIO Requests.
  input 				iob_jbi_pio_vld;
  input 	   [`IOB_JBI_WIDTH-1:0] iob_jbi_pio_data;
  output 				jbi_iob_pio_stall;
  //
  // Inbound Mondo Interrupt Requests.
  output 		                jbi_iob_mondo_vld;
  output [`JBI_IOB_MONDO_BUS_WIDTH-1:0] jbi_iob_mondo_data;
  //
  // Outbound Mondo Interrupt responses.
  input 				iob_jbi_mondo_ack;
  input 				iob_jbi_mondo_nack;


  // SPI Interface.
  //
  // IO Pads.
  output 		      jbi_io_ssi_mosi;			// Master out slave in to pad.
  input 		      io_jbi_ssi_miso;			// Master in slave out from pad.
  output 		      jbi_io_ssi_sck;			// Serial clock to pad.
  input 		      io_jbi_ext_int_l;
  //
  // IOB
  input 		      iob_jbi_spi_vld;			// Valid packet from IOB.
  input  [`IOB_SPI_WIDTH-1:0] iob_jbi_spi_data;			// Packet data from IOB.
  input 		      iob_jbi_spi_stall;		// Flow control to stop data.
  output 		      jbi_iob_spi_vld;			// Valid packet from UCB.
  output [`SPI_IOB_WIDTH-1:0] jbi_iob_spi_data;			// Packet data from UCB.
  output 		      jbi_iob_spi_stall;		// Flow control to stop data.


  // JBus Interface.
  //
  // JBUS Arbitration.
  output 	 jbi_io_j_req0_out_l;
  output 	 jbi_io_j_req0_out_en;
  input 	 io_jbi_j_req4_in_l;
  input 	 io_jbi_j_req5_in_l;
  // 
  // JBUS Address/Data packet.
  input    [7:0] io_jbi_j_adtype;
  output   [7:0] jbi_io_j_adtype;
  output 	 jbi_io_j_adtype_en;
  input  [127:0] io_jbi_j_ad;
  output [127:0] jbi_io_j_ad;
  output   [3:0] jbi_io_j_ad_en;
  // 
  // JBUS Cache Snooping.
  output   [2:0] jbi_io_j_pack0;
  output 	 jbi_io_j_pack0_en;
  output   [2:0] jbi_io_j_pack1;
  output 	 jbi_io_j_pack1_en;
  input    [2:0] io_jbi_j_pack4;
  input    [2:0] io_jbi_j_pack5;
  // 
  // JBUS Error Detection.
  input    [3:0] io_jbi_j_adp;
  output   [3:0] jbi_io_j_adp;
  output 	 jbi_io_j_adp_en;
  input 	 io_jbi_j_par;
  //
  // DTL Control.
  output   [1:0] jbi_io_config_dtl;


  // ENet Interface.
  //
  // Debug.
  input [47:0] 	 iob_jbi_dbg_hi_data;
  input 	 iob_jbi_dbg_hi_vld;
  input [47:0] 	 iob_jbi_dbg_lo_data;
  input 	 iob_jbi_dbg_lo_vld;



  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire			MT_so_0;		// From u_test_stub of test_stub_scan.v
  wire			cmp_rclk;		// From u_cmp_header of bw_clk_cl_jbi_cmp.v
  wire			cmp_rst_l;		// From u_cmp_header of bw_clk_cl_jbi_cmp.v
  wire [4:0]		csr_16x65array_margin;	// From u_csr of jbi_csr.v
  wire [4:0]		csr_16x81array_margin;	// From u_csr of jbi_csr.v
  wire [`JBI_CSR_WIDTH-1:0]csr_csr_read_data;	// From u_csr of jbi_csr.v
  wire			csr_dok_on;		// From u_csr of jbi_csr.v
  wire			csr_int_req;		// From u_csr of jbi_csr.v
  wire [31:0]		csr_jbi_arb_timeout_timeval;// From u_csr of jbi_csr.v
  wire [3:0]		csr_jbi_config2_iq_high;// From u_csr of jbi_csr.v
  wire [3:0]		csr_jbi_config2_iq_low;	// From u_csr of jbi_csr.v
  wire [3:0]		csr_jbi_config2_max_pio;// From u_csr of jbi_csr.v
  wire [1:0]		csr_jbi_config2_max_rd;	// From u_csr of jbi_csr.v
  wire [3:0]		csr_jbi_config2_max_wr;	// From u_csr of jbi_csr.v
  wire [1:0]		csr_jbi_config2_max_wris;// From u_csr of jbi_csr.v
  wire			csr_jbi_config2_ord_int;// From u_csr of jbi_csr.v
  wire			csr_jbi_config2_ord_pio;// From u_csr of jbi_csr.v
  wire			csr_jbi_config2_ord_rd;	// From u_csr of jbi_csr.v
  wire			csr_jbi_config2_ord_wr;	// From u_csr of jbi_csr.v
  wire [1:0]		csr_jbi_config_arb_mode;// From u_csr of jbi_csr.v
  wire [6:0]		csr_jbi_config_port_pres;// From u_csr of jbi_csr.v
  wire			csr_jbi_debug_arb_aggr_arb;// From u_csr of jbi_csr.v
  wire			csr_jbi_debug_arb_alternate;// From u_csr of jbi_csr.v
  wire			csr_jbi_debug_arb_alternate_set_l;// From u_csr of jbi_csr.v
  wire			csr_jbi_debug_arb_data_arb;// From u_csr of jbi_csr.v
  wire [4:0]		csr_jbi_debug_arb_hi_water;// From u_csr of jbi_csr.v
  wire [4:0]		csr_jbi_debug_arb_lo_water;// From u_csr of jbi_csr.v
  wire [9:0]		csr_jbi_debug_arb_max_wait;// From u_csr of jbi_csr.v
  wire [6:0]		csr_jbi_debug_arb_tstamp_wrap;// From u_csr of jbi_csr.v
  wire			csr_jbi_debug_info_enb;	// From u_csr of jbi_csr.v
  wire [23:0]		csr_jbi_err_inject_count;// From u_csr of jbi_csr.v
  wire			csr_jbi_err_inject_errtype;// From u_csr of jbi_csr.v
  wire			csr_jbi_err_inject_input;// From u_csr of jbi_csr.v
  wire			csr_jbi_err_inject_output;// From u_csr of jbi_csr.v
  wire [3:0]		csr_jbi_err_inject_xormask;// From u_csr of jbi_csr.v
  wire			csr_jbi_error_config_erren;// From u_csr of jbi_csr.v
  wire			csr_jbi_error_config_fe_enb;// From u_csr of jbi_csr.v
  wire			csr_jbi_error_config_sigen;// From u_csr of jbi_csr.v
  wire			csr_jbi_intr_timeout_rst_l;// From u_csr of jbi_csr.v
  wire [31:0]		csr_jbi_intr_timeout_timeval;// From u_csr of jbi_csr.v
  wire [31:0]		csr_jbi_l2_timeout_timeval;// From u_csr of jbi_csr.v
  wire			csr_jbi_log_enb_apar;	// From u_csr of jbi_csr.v
  wire			csr_jbi_log_enb_dpar_o;	// From u_csr of jbi_csr.v
  wire			csr_jbi_log_enb_dpar_rd;// From u_csr of jbi_csr.v
  wire			csr_jbi_log_enb_dpar_wr;// From u_csr of jbi_csr.v
  wire			csr_jbi_log_enb_err_cycle;// From u_csr of jbi_csr.v
  wire			csr_jbi_log_enb_nonex_rd;// From u_csr of jbi_csr.v
  wire			csr_jbi_log_enb_read_to;// From u_csr of jbi_csr.v
  wire			csr_jbi_log_enb_rep_ue;	// From u_csr of jbi_csr.v
  wire			csr_jbi_log_enb_unexp_dr;// From u_csr of jbi_csr.v
  wire [37:30]		csr_jbi_memsize_size;	// From u_csr of jbi_csr.v
  wire [31:0]		csr_jbi_trans_timeout_timeval;// From u_csr of jbi_csr.v
  wire [127:0]		dbg_data;		// From u_dbg of jbi_dbg.v
  wire			dbg_req_arbitrate;	// From u_dbg of jbi_dbg.v
  wire			dbg_req_priority;	// From u_dbg of jbi_dbg.v
  wire			dbg_req_transparent;	// From u_dbg of jbi_dbg.v
  wire [6:0]		jbi_log_arb_aok;	// From u_mout of jbi_mout.v
  wire [6:0]		jbi_log_arb_dok;	// From u_mout of jbi_mout.v
  wire [6:0]		jbi_log_arb_jreq;	// From u_mout of jbi_mout.v
  wire [2:0]		jbi_log_arb_myreq;	// From u_mout of jbi_mout.v
  wire [2:0]		jbi_log_arb_reqtype;	// From u_mout of jbi_mout.v
  wire			jbus_rclk;		// From u_jbus_header of bw_clk_cl_jbi_jbus.v
  wire			jbus_rst_l;		// From u_jbus_header of bw_clk_cl_jbi_jbus.v
  wire			min_aok_off;		// From u_min of jbi_min.v
  wire			min_aok_on;		// From u_min of jbi_min.v
  wire			min_csr_err_adtype;	// From u_min of jbi_min.v
  wire			min_csr_err_apar;	// From u_min of jbi_min.v
  wire			min_csr_err_dpar_o;	// From u_min of jbi_min.v
  wire			min_csr_err_dpar_rd;	// From u_min of jbi_min.v
  wire			min_csr_err_dpar_wr;	// From u_min of jbi_min.v
  wire			min_csr_err_err_cycle;	// From u_min of jbi_min.v
  wire			min_csr_err_illegal;	// From u_min of jbi_min.v
  wire			min_csr_err_l2_to0;	// From u_min of jbi_min.v
  wire			min_csr_err_l2_to1;	// From u_min of jbi_min.v
  wire			min_csr_err_l2_to2;	// From u_min of jbi_min.v
  wire			min_csr_err_l2_to3;	// From u_min of jbi_min.v
  wire			min_csr_err_nonex_rd;	// From u_min of jbi_min.v
  wire			min_csr_err_nonex_wr;	// From u_min of jbi_min.v
  wire			min_csr_err_rep_ue;	// From u_min of jbi_min.v
  wire			min_csr_err_unexp_dr;	// From u_min of jbi_min.v
  wire			min_csr_err_unmap_wr;	// From u_min of jbi_min.v
  wire			min_csr_err_unsupp;	// From u_min of jbi_min.v
  wire			min_csr_inject_input_done;// From u_min of jbi_min.v
  wire [42:0]		min_csr_log_addr_addr;	// From u_min of jbi_min.v
  wire [7:0]		min_csr_log_addr_adtype;// From u_min of jbi_min.v
  wire [2:0]		min_csr_log_addr_owner;	// From u_min of jbi_min.v
  wire [4:0]		min_csr_log_addr_ttype;	// From u_min of jbi_min.v
  wire [7:0]		min_csr_log_ctl_adtype0;// From u_min of jbi_min.v
  wire [7:0]		min_csr_log_ctl_adtype1;// From u_min of jbi_min.v
  wire [7:0]		min_csr_log_ctl_adtype2;// From u_min of jbi_min.v
  wire [7:0]		min_csr_log_ctl_adtype3;// From u_min of jbi_min.v
  wire [7:0]		min_csr_log_ctl_adtype4;// From u_min of jbi_min.v
  wire [7:0]		min_csr_log_ctl_adtype5;// From u_min of jbi_min.v
  wire [7:0]		min_csr_log_ctl_adtype6;// From u_min of jbi_min.v
  wire [2:0]		min_csr_log_ctl_owner;	// From u_min of jbi_min.v
  wire [3:0]		min_csr_log_ctl_parity;	// From u_min of jbi_min.v
  wire [63:0]		min_csr_log_data0;	// From u_min of jbi_min.v
  wire [63:0]		min_csr_log_data1;	// From u_min of jbi_min.v
  wire [3:0]		min_csr_perf_blk_q0;	// From u_min of jbi_min.v
  wire [3:0]		min_csr_perf_blk_q1;	// From u_min of jbi_min.v
  wire [3:0]		min_csr_perf_blk_q2;	// From u_min of jbi_min.v
  wire [3:0]		min_csr_perf_blk_q3;	// From u_min of jbi_min.v
  wire			min_csr_perf_dma_rd_in;	// From u_min of jbi_min.v
  wire [4:0]		min_csr_perf_dma_rd_latency;// From u_min of jbi_min.v
  wire			min_csr_perf_dma_wr;	// From u_min of jbi_min.v
  wire			min_csr_perf_dma_wr8;	// From u_min of jbi_min.v
  wire			min_csr_write_log_addr;	// From u_min of jbi_min.v
  wire			min_free;		// From u_min of jbi_min.v
  wire [`JBI_JID_WIDTH-1:0]min_free_jid;	// From u_min of jbi_min.v
  wire [127:0]		min_j_ad_ff;		// From u_min of jbi_min.v
  wire			min_mondo_data_err;	// From u_min of jbi_min.v
  wire			min_mondo_data_push;	// From u_min of jbi_min.v
  wire			min_mondo_hdr_push;	// From u_min of jbi_min.v
  wire			min_mout_inject_err;	// From u_min of jbi_min.v
  wire [`JBI_WRI_TAG_WIDTH-1:0]min_oldest_wri_tag;// From u_min of jbi_min.v
  wire			min_pio_data_err;	// From u_min of jbi_min.v
  wire			min_pio_rtrn_push;	// From u_min of jbi_min.v
  wire [`JBI_WRI_TAG_WIDTH-1:0]min_pre_wri_tag;	// From u_min of jbi_min.v
  wire			min_snp_launch;		// From u_min of jbi_min.v
  wire [`JBI_JID_WIDTH-1:0]min_trans_jid;	// From u_min of jbi_min.v
  wire			mout_csr_err_arb_to;	// From u_mout of jbi_mout.v
  wire			mout_csr_err_cpar;	// From u_mout of jbi_mout.v
  wire [5:4]		mout_csr_err_fatal;	// From u_mout of jbi_mout.v
  wire			mout_csr_err_read_to;	// From u_mout of jbi_mout.v
  wire			mout_csr_inject_output_done;// From u_mout of jbi_mout.v
  wire [2:0]		mout_csr_jbi_log_par_jpack0;// From u_mout of jbi_mout.v
  wire [2:0]		mout_csr_jbi_log_par_jpack1;// From u_mout of jbi_mout.v
  wire [2:0]		mout_csr_jbi_log_par_jpack4;// From u_mout of jbi_mout.v
  wire [2:0]		mout_csr_jbi_log_par_jpack5;// From u_mout of jbi_mout.v
  wire			mout_csr_jbi_log_par_jpar;// From u_mout of jbi_mout.v
  wire [6:0]		mout_csr_jbi_log_par_jreq;// From u_mout of jbi_mout.v
  wire			mout_dbg_pop;		// From u_mout of jbi_mout.v
  wire			mout_dsbl_sampling;	// From u_mout of jbi_mout.v
  wire			mout_min_inject_err_done;// From u_mout of jbi_mout.v
  wire [5:0]		mout_min_jbus_owner;	// From u_mout of jbi_mout.v
  wire			mout_mondo_pop;		// From u_mout of jbi_mout.v
  wire			mout_nack;		// From u_mout of jbi_mout.v
  wire [1:0]		mout_nack_buf_id;	// From u_mout of jbi_mout.v
  wire [5:0]		mout_nack_thr_id;	// From u_mout of jbi_mout.v
  wire			mout_perf_aok_off;	// From u_mout of jbi_mout.v
  wire			mout_perf_dok_off;	// From u_mout of jbi_mout.v
  wire			mout_pio_pop;		// From u_mout of jbi_mout.v
  wire			mout_pio_req_adv;	// From u_mout of jbi_mout.v
  wire			mout_port_4_present;	// From u_mout of jbi_mout.v
  wire			mout_port_5_present;	// From u_mout of jbi_mout.v
  wire			mout_scb0_jbus_rd_ack;	// From u_mout of jbi_mout.v
  wire			mout_scb0_jbus_wr_ack;	// From u_mout of jbi_mout.v
  wire			mout_scb1_jbus_rd_ack;	// From u_mout of jbi_mout.v
  wire			mout_scb1_jbus_wr_ack;	// From u_mout of jbi_mout.v
  wire			mout_scb2_jbus_rd_ack;	// From u_mout of jbi_mout.v
  wire			mout_scb2_jbus_wr_ack;	// From u_mout of jbi_mout.v
  wire			mout_scb3_jbus_rd_ack;	// From u_mout of jbi_mout.v
  wire			mout_scb3_jbus_wr_ack;	// From u_mout of jbi_mout.v
  wire			mout_trans_valid;	// From u_mout of jbi_mout.v
  wire [`JBI_YID_WIDTH-1:0]mout_trans_yid;	// From u_mout of jbi_mout.v
  wire [31:0]		ncio_csr_err_intr_to;	// From u_ncio of jbi_ncio.v
  wire [4:0]		ncio_csr_perf_pio_rd_latency;// From u_ncio of jbi_ncio.v
  wire			ncio_csr_perf_pio_rd_out;// From u_ncio of jbi_ncio.v
  wire			ncio_csr_perf_pio_wr;	// From u_ncio of jbi_ncio.v
  wire [`JBI_CSR_ADDR_WIDTH-1:0]ncio_csr_read_addr;// From u_ncio of jbi_ncio.v
  wire			ncio_csr_write;		// From u_ncio of jbi_ncio.v
  wire [`JBI_CSR_ADDR_WIDTH-1:0]ncio_csr_write_addr;// From u_ncio of jbi_ncio.v
  wire [`JBI_CSR_WIDTH-1:0]ncio_csr_write_data;	// From u_ncio of jbi_ncio.v
  wire [`JBI_MAKQ_ADDR_WIDTH:0]ncio_makq_level;	// From u_ncio of jbi_ncio.v
  wire			ncio_mondo_ack;		// From u_ncio of jbi_ncio.v
  wire [`JBI_AD_INT_AGTID_WIDTH-1:0]ncio_mondo_agnt_id;// From u_ncio of jbi_ncio.v
  wire [`JBI_AD_INT_CPUID_WIDTH-1:0]ncio_mondo_cpu_id;// From u_ncio of jbi_ncio.v
  wire			ncio_mondo_req;		// From u_ncio of jbi_ncio.v
  wire			ncio_mout_nack_pop;	// From u_ncio of jbi_ncio.v
  wire [63:0]		ncio_pio_ad;		// From u_ncio of jbi_ncio.v
  wire [15:0]		ncio_pio_be;		// From u_ncio of jbi_ncio.v
  wire			ncio_pio_req;		// From u_ncio of jbi_ncio.v
  wire [1:0]		ncio_pio_req_dest;	// From u_ncio of jbi_ncio.v
  wire			ncio_pio_req_rw;	// From u_ncio of jbi_ncio.v
  wire			ncio_pio_ue;		// From u_ncio of jbi_ncio.v
  wire [`JBI_PRQQ_ADDR_WIDTH:0]ncio_prqq_level;	// From u_ncio of jbi_ncio.v
  wire [`JBI_YID_WIDTH-1:0]ncio_yid;		// From u_ncio of jbi_ncio.v
  wire			rst_tri_en;		// From u_test_stub of test_stub_scan.v
  wire			rx_en_local;		// From u_sync_header of cluster_header_sync.v
  wire			se;			// From u_test_stub of test_stub_scan.v
  wire			sehold;			// From u_test_stub of test_stub_scan.v
  wire			testmux_sel;		// From u_test_stub of test_stub_scan.v
  wire			tx_en_local;		// From u_sync_header of cluster_header_sync.v
  // End of automatics


  wire MT_long_chain_so_0;
  wire MT_short_chain_so_0;


//*******************************************************************************
// CLUSTER HEADERS 
//*******************************************************************************

/* bw_clk_cl_jbi_jbus AUTO_TEMPLATE (
 .dbginit_l      (),
 .cluster_grst_l (jbus_rst_l),
 .rclk           (jbus_rclk),
 .so             (),
 .gclk           (jbus_gclk),
 .cluster_cken   (clk_jbi_jbus_cken),
 .arst_l         (jbus_arst_l),
 .grst_l         (jbus_grst_l),
 .adbginit_l     (1'b1),
 .gdbginit_l     (1'b1),
 .si             (),
 ); */

bw_clk_cl_jbi_jbus u_jbus_header (/*AUTOINST*/
				  // Outputs
				  .so	(),			 // Templated
				  .dbginit_l(),			 // Templated
				  .cluster_grst_l(jbus_rst_l),	 // Templated
				  .rclk	(jbus_rclk),		 // Templated
				  // Inputs
				  .si	(),			 // Templated
				  .se	(se),
				  .adbginit_l(1'b1),		 // Templated
				  .gdbginit_l(1'b1),		 // Templated
				  .arst_l(jbus_arst_l),		 // Templated
				  .grst_l(jbus_grst_l),		 // Templated
				  .cluster_cken(clk_jbi_jbus_cken), // Templated
				  .gclk	(jbus_gclk));		 // Templated

/* bw_clk_cl_jbi_cmp AUTO_TEMPLATE (
 .dbginit_l      (),
 .cluster_grst_l (cmp_rst_l),
 .rclk           (cmp_rclk),
 .so             (),
 .gclk           (cmp_gclk),
 .cluster_cken   (clk_jbi_cmp_cken),
 .arst_l         (cmp_arst_l),
 .grst_l         (cmp_grst_l),
 .adbginit_l     (1'b1),
 .gdbginit_l     (1'b1),
 .si             (),
 ); */

bw_clk_cl_jbi_cmp u_cmp_header (/*AUTOINST*/
				// Outputs
				.so	(),			 // Templated
				.dbginit_l(),			 // Templated
				.cluster_grst_l(cmp_rst_l),	 // Templated
				.rclk	(cmp_rclk),		 // Templated
				// Inputs
				.si	(),			 // Templated
				.se	(se),
				.adbginit_l(1'b1),		 // Templated
				.gdbginit_l(1'b1),		 // Templated
				.arst_l	(cmp_arst_l),		 // Templated
				.grst_l	(cmp_grst_l),		 // Templated
				.cluster_cken(clk_jbi_cmp_cken), // Templated
				.gclk	(cmp_gclk));		 // Templated

/* cluster_header_sync AUTO_TEMPLATE (
 // outputs
 .dram_rx_sync_local (),
 .dram_tx_sync_local (),
 .jbus_rx_sync_local (rx_en_local),
 .jbus_tx_sync_local (tx_en_local),
 .so (),
 
 // inputs
 .dram_rx_sync_global (1'b0),
 .dram_tx_sync_global (1'b0),
 .jbus_rx_sync_global (ctu_jbi_rx_en),
 .jbus_tx_sync_global (ctu_jbi_tx_en),
 .si (),
 ); */

cluster_header_sync u_sync_header (/*AUTOINST*/
				   // Outputs
				   .dram_rx_sync_local(),	 // Templated
				   .dram_tx_sync_local(),	 // Templated
				   .jbus_rx_sync_local(rx_en_local), // Templated
				   .jbus_tx_sync_local(tx_en_local), // Templated
				   .so	(),			 // Templated
				   // Inputs
				   .dram_rx_sync_global(1'b0),	 // Templated
				   .dram_tx_sync_global(1'b0),	 // Templated
				   .jbus_rx_sync_global(ctu_jbi_rx_en), // Templated
				   .jbus_tx_sync_global(ctu_jbi_tx_en), // Templated
				   .cmp_gclk(cmp_gclk),
				   .cmp_rclk(cmp_rclk),
				   .si	(),			 // Templated
				   .se	(se));


//*******************************************************************************
// CMP Reset Flop
//*******************************************************************************

dffrl_async_ns u_dffrl_async_cmp_rst_l_ff0
   ( .din (cmp_rst_l),
     .clk (cmp_rclk),
     .rst_l (cmp_arst_l),
     .q (cmp_rst_l_ff0)
     );

dffrl_async_ns u_dffrl_async_cmp_rst_l_ff1
   ( .din (cmp_rst_l),
     .clk (cmp_rclk),
     .rst_l (cmp_arst_l),
     .q (cmp_rst_l_ff1)
     );

//*******************************************************************************
// Test Stub
//*******************************************************************************

/*test_stub_scan AUTO_TEMPLATE (
 .testmode_l	       (),
 .tst_ctu_data_out     (test_csr_data_out[2:0]),
 .mem_bypass           (testmux_sel),
 .arst_l	       (jbus_arst_l),
 .mux_drive_disable (),            //replaces rst_tri_en for logic
 .mem_write_disable (rst_tri_en),  //replaces rst_tri_en for memory
 
 // macrotest
 .so_0                 (MT_so_0),
 .long_chain_so_0      (MT_long_chain_so_0),
 .short_chain_so_0     (MT_short_chain_so_0),
 .so_1                 (),
 .long_chain_so_1      (1'b0),
 .short_chain_so_1     (1'b0),
 .so_2                 (),
 .long_chain_so_2      (1'b0),
 .short_chain_so_2     (1'b0),
 );*/

test_stub_scan u_test_stub (/*AUTOINST*/
			    // Outputs
			    .mux_drive_disable(),		 // Templated
			    .mem_write_disable(rst_tri_en),	 // Templated
			    .sehold	(sehold),
			    .se		(se),
			    .testmode_l	(),			 // Templated
			    .mem_bypass	(testmux_sel),		 // Templated
			    .so_0	(MT_so_0),		 // Templated
			    .so_1	(),			 // Templated
			    .so_2	(),			 // Templated
			    // Inputs
			    .ctu_tst_pre_grst_l(ctu_tst_pre_grst_l),
			    .arst_l	(jbus_arst_l),		 // Templated
			    .global_shift_enable(global_shift_enable),
			    .ctu_tst_scan_disable(ctu_tst_scan_disable),
			    .ctu_tst_scanmode(ctu_tst_scanmode),
			    .ctu_tst_macrotest(ctu_tst_macrotest),
			    .ctu_tst_short_chain(ctu_tst_short_chain),
			    .long_chain_so_0(MT_long_chain_so_0), // Templated
			    .short_chain_so_0(MT_short_chain_so_0), // Templated
			    .long_chain_so_1(1'b0),		 // Templated
			    .short_chain_so_1(1'b0),		 // Templated
			    .long_chain_so_2(1'b0),		 // Templated
			    .short_chain_so_2(1'b0));		 // Templated


//*******************************************************************************
// Memory Inbound Block
//*******************************************************************************

/* jbi_min AUTO_TEMPLATE (
 .clk (jbus_rclk),
 .rst_l (jbus_rst_l),
 .arst_l (jbus_arst_l),
 .cpu_clk (cmp_rclk),
 .cpu_rst_l (cmp_rst_l),
 .hold (sehold),
 .cpu_tx_en (tx_en_local),
 .cpu_rx_en (rx_en_local),
 ); */

jbi_min u_min (/*AUTOINST*/
	       // Outputs
	       .min_csr_inject_input_done(min_csr_inject_input_done),
	       .min_csr_err_apar	(min_csr_err_apar),
	       .min_csr_err_adtype	(min_csr_err_adtype),
	       .min_csr_err_dpar_wr	(min_csr_err_dpar_wr),
	       .min_csr_err_dpar_rd	(min_csr_err_dpar_rd),
	       .min_csr_err_dpar_o	(min_csr_err_dpar_o),
	       .min_csr_err_rep_ue	(min_csr_err_rep_ue),
	       .min_csr_err_illegal	(min_csr_err_illegal),
	       .min_csr_err_unsupp	(min_csr_err_unsupp),
	       .min_csr_err_nonex_wr	(min_csr_err_nonex_wr),
	       .min_csr_err_nonex_rd	(min_csr_err_nonex_rd),
	       .min_csr_err_unmap_wr	(min_csr_err_unmap_wr),
	       .min_csr_err_err_cycle	(min_csr_err_err_cycle),
	       .min_csr_err_unexp_dr	(min_csr_err_unexp_dr),
	       .min_csr_err_l2_to0	(min_csr_err_l2_to0),
	       .min_csr_err_l2_to1	(min_csr_err_l2_to1),
	       .min_csr_err_l2_to2	(min_csr_err_l2_to2),
	       .min_csr_err_l2_to3	(min_csr_err_l2_to3),
	       .min_csr_write_log_addr	(min_csr_write_log_addr),
	       .min_csr_log_addr_owner	(min_csr_log_addr_owner[2:0]),
	       .min_csr_log_addr_adtype	(min_csr_log_addr_adtype[7:0]),
	       .min_csr_log_addr_ttype	(min_csr_log_addr_ttype[4:0]),
	       .min_csr_log_addr_addr	(min_csr_log_addr_addr[42:0]),
	       .min_csr_log_data0	(min_csr_log_data0[63:0]),
	       .min_csr_log_data1	(min_csr_log_data1[63:0]),
	       .min_csr_log_ctl_owner	(min_csr_log_ctl_owner[2:0]),
	       .min_csr_log_ctl_parity	(min_csr_log_ctl_parity[3:0]),
	       .min_csr_log_ctl_adtype0	(min_csr_log_ctl_adtype0[7:0]),
	       .min_csr_log_ctl_adtype1	(min_csr_log_ctl_adtype1[7:0]),
	       .min_csr_log_ctl_adtype2	(min_csr_log_ctl_adtype2[7:0]),
	       .min_csr_log_ctl_adtype3	(min_csr_log_ctl_adtype3[7:0]),
	       .min_csr_log_ctl_adtype4	(min_csr_log_ctl_adtype4[7:0]),
	       .min_csr_log_ctl_adtype5	(min_csr_log_ctl_adtype5[7:0]),
	       .min_csr_log_ctl_adtype6	(min_csr_log_ctl_adtype6[7:0]),
	       .min_csr_perf_dma_rd_in	(min_csr_perf_dma_rd_in),
	       .min_csr_perf_dma_wr	(min_csr_perf_dma_wr),
	       .min_csr_perf_dma_rd_latency(min_csr_perf_dma_rd_latency[4:0]),
	       .min_csr_perf_dma_wr8	(min_csr_perf_dma_wr8),
	       .min_csr_perf_blk_q0	(min_csr_perf_blk_q0[3:0]),
	       .min_csr_perf_blk_q1	(min_csr_perf_blk_q1[3:0]),
	       .min_csr_perf_blk_q2	(min_csr_perf_blk_q2[3:0]),
	       .min_csr_perf_blk_q3	(min_csr_perf_blk_q3[3:0]),
	       .jbi_sctag0_req		(jbi_sctag0_req[31:0]),
	       .jbi_scbuf0_ecc		(jbi_scbuf0_ecc[6:0]),
	       .jbi_sctag0_req_vld	(jbi_sctag0_req_vld),
	       .jbi_sctag1_req		(jbi_sctag1_req[31:0]),
	       .jbi_scbuf1_ecc		(jbi_scbuf1_ecc[6:0]),
	       .jbi_sctag1_req_vld	(jbi_sctag1_req_vld),
	       .jbi_sctag2_req		(jbi_sctag2_req[31:0]),
	       .jbi_scbuf2_ecc		(jbi_scbuf2_ecc[6:0]),
	       .jbi_sctag2_req_vld	(jbi_sctag2_req_vld),
	       .jbi_sctag3_req		(jbi_sctag3_req[31:0]),
	       .jbi_scbuf3_ecc		(jbi_scbuf3_ecc[6:0]),
	       .jbi_sctag3_req_vld	(jbi_sctag3_req_vld),
	       .min_mout_inject_err	(min_mout_inject_err),
	       .min_trans_jid		(min_trans_jid[`JBI_JID_WIDTH-1:0]),
	       .min_snp_launch		(min_snp_launch),
	       .min_free		(min_free),
	       .min_free_jid		(min_free_jid[`JBI_JID_WIDTH-1:0]),
	       .min_aok_on		(min_aok_on),
	       .min_aok_off		(min_aok_off),
	       .min_j_ad_ff		(min_j_ad_ff[127:0]),
	       .min_pio_rtrn_push	(min_pio_rtrn_push),
	       .min_pio_data_err	(min_pio_data_err),
	       .min_mondo_hdr_push	(min_mondo_hdr_push),
	       .min_mondo_data_push	(min_mondo_data_push),
	       .min_mondo_data_err	(min_mondo_data_err),
	       .min_oldest_wri_tag	(min_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
	       .min_pre_wri_tag		(min_pre_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
	       // Inputs
	       .clk			(jbus_rclk),		 // Templated
	       .rst_l			(jbus_rst_l),		 // Templated
	       .arst_l			(jbus_arst_l),		 // Templated
	       .testmux_sel		(testmux_sel),
	       .rst_tri_en		(rst_tri_en),
	       .cpu_clk			(cmp_rclk),		 // Templated
	       .cpu_rst_l		(cmp_rst_l),		 // Templated
	       .cpu_tx_en		(tx_en_local),		 // Templated
	       .cpu_rx_en		(rx_en_local),		 // Templated
	       .hold			(sehold),		 // Templated
	       .csr_16x65array_margin	(csr_16x65array_margin[4:0]),
	       .csr_jbi_config_port_pres(csr_jbi_config_port_pres[6:0]),
	       .csr_jbi_error_config_erren(csr_jbi_error_config_erren),
	       .csr_jbi_log_enb_apar	(csr_jbi_log_enb_apar),
	       .csr_jbi_log_enb_dpar_wr	(csr_jbi_log_enb_dpar_wr),
	       .csr_jbi_log_enb_dpar_rd	(csr_jbi_log_enb_dpar_rd),
	       .csr_jbi_log_enb_rep_ue	(csr_jbi_log_enb_rep_ue),
	       .csr_jbi_log_enb_nonex_rd(csr_jbi_log_enb_nonex_rd),
	       .csr_jbi_log_enb_err_cycle(csr_jbi_log_enb_err_cycle),
	       .csr_jbi_log_enb_dpar_o	(csr_jbi_log_enb_dpar_o),
	       .csr_jbi_log_enb_unexp_dr(csr_jbi_log_enb_unexp_dr),
	       .csr_jbi_config2_iq_high	(csr_jbi_config2_iq_high[3:0]),
	       .csr_jbi_config2_iq_low	(csr_jbi_config2_iq_low[3:0]),
	       .csr_jbi_config2_max_rd	(csr_jbi_config2_max_rd[1:0]),
	       .csr_jbi_config2_max_wr	(csr_jbi_config2_max_wr[3:0]),
	       .csr_jbi_config2_ord_rd	(csr_jbi_config2_ord_rd),
	       .csr_jbi_config2_ord_wr	(csr_jbi_config2_ord_wr),
	       .csr_jbi_memsize_size	(csr_jbi_memsize_size[37:30]),
	       .csr_jbi_config2_max_wris(csr_jbi_config2_max_wris[1:0]),
	       .csr_jbi_l2_timeout_timeval(csr_jbi_l2_timeout_timeval[31:0]),
	       .csr_jbi_err_inject_input(csr_jbi_err_inject_input),
	       .csr_jbi_err_inject_output(csr_jbi_err_inject_output),
	       .csr_jbi_err_inject_errtype(csr_jbi_err_inject_errtype),
	       .csr_jbi_err_inject_xormask(csr_jbi_err_inject_xormask[3:0]),
	       .csr_jbi_err_inject_count(csr_jbi_err_inject_count[23:0]),
	       .sctag0_jbi_iq_dequeue	(sctag0_jbi_iq_dequeue),
	       .sctag0_jbi_wib_dequeue	(sctag0_jbi_wib_dequeue),
	       .sctag1_jbi_iq_dequeue	(sctag1_jbi_iq_dequeue),
	       .sctag1_jbi_wib_dequeue	(sctag1_jbi_wib_dequeue),
	       .sctag2_jbi_iq_dequeue	(sctag2_jbi_iq_dequeue),
	       .sctag2_jbi_wib_dequeue	(sctag2_jbi_wib_dequeue),
	       .sctag3_jbi_iq_dequeue	(sctag3_jbi_iq_dequeue),
	       .sctag3_jbi_wib_dequeue	(sctag3_jbi_wib_dequeue),
	       .io_jbi_j_adtype		(io_jbi_j_adtype[7:0]),
	       .io_jbi_j_ad		(io_jbi_j_ad[127:0]),
	       .io_jbi_j_adp		(io_jbi_j_adp[3:0]),
	       .mout_dsbl_sampling	(mout_dsbl_sampling),
	       .mout_scb0_jbus_wr_ack	(mout_scb0_jbus_wr_ack),
	       .mout_scb1_jbus_wr_ack	(mout_scb1_jbus_wr_ack),
	       .mout_scb2_jbus_wr_ack	(mout_scb2_jbus_wr_ack),
	       .mout_scb3_jbus_wr_ack	(mout_scb3_jbus_wr_ack),
	       .mout_scb0_jbus_rd_ack	(mout_scb0_jbus_rd_ack),
	       .mout_scb1_jbus_rd_ack	(mout_scb1_jbus_rd_ack),
	       .mout_scb2_jbus_rd_ack	(mout_scb2_jbus_rd_ack),
	       .mout_scb3_jbus_rd_ack	(mout_scb3_jbus_rd_ack),
	       .mout_trans_valid	(mout_trans_valid),
	       .mout_min_inject_err_done(mout_min_inject_err_done),
	       .mout_min_jbus_owner	(mout_min_jbus_owner[5:0]));



//*******************************************************************************
// Memory Outbound Block
//*******************************************************************************

/* jbi_mout AUTO_TEMPLATE (
 .cclk                (cmp_rclk),
 .crst_l              (cmp_rst_l_ff0),
 .clk                 (jbus_rclk),
 .rst_l               (jbus_rst_l),
 .tx_en_local_m1      (tx_en_local),
 .hold 		      (sehold),
 .arst_l	      (cmp_arst_l),
 ); */
 
jbi_mout u_mout(/*AUTOINST*/
		// Outputs
		.mout_pio_req_adv	(mout_pio_req_adv),
		.mout_pio_pop		(mout_pio_pop),
		.mout_mondo_pop		(mout_mondo_pop),
		.jbi_io_j_adtype	(jbi_io_j_adtype[7:0]),
		.jbi_io_j_adtype_en	(jbi_io_j_adtype_en),
		.jbi_io_j_ad		(jbi_io_j_ad[127:0]),
		.jbi_io_j_ad_en		(jbi_io_j_ad_en[3:0]),
		.jbi_io_j_adp		(jbi_io_j_adp[3:0]),
		.jbi_io_j_adp_en	(jbi_io_j_adp_en),
		.jbi_io_j_req0_out_l	(jbi_io_j_req0_out_l),
		.jbi_io_j_req0_out_en	(jbi_io_j_req0_out_en),
		.jbi_io_j_pack0		(jbi_io_j_pack0[2:0]),
		.jbi_io_j_pack0_en	(jbi_io_j_pack0_en),
		.jbi_io_j_pack1		(jbi_io_j_pack1[2:0]),
		.jbi_io_j_pack1_en	(jbi_io_j_pack1_en),
		.mout_dsbl_sampling	(mout_dsbl_sampling),
		.mout_trans_yid		(mout_trans_yid[`JBI_YID_WIDTH-1:0]),
		.mout_trans_valid	(mout_trans_valid),
		.mout_scb0_jbus_wr_ack	(mout_scb0_jbus_wr_ack),
		.mout_scb1_jbus_wr_ack	(mout_scb1_jbus_wr_ack),
		.mout_scb2_jbus_wr_ack	(mout_scb2_jbus_wr_ack),
		.mout_scb3_jbus_wr_ack	(mout_scb3_jbus_wr_ack),
		.mout_scb0_jbus_rd_ack	(mout_scb0_jbus_rd_ack),
		.mout_scb1_jbus_rd_ack	(mout_scb1_jbus_rd_ack),
		.mout_scb2_jbus_rd_ack	(mout_scb2_jbus_rd_ack),
		.mout_scb3_jbus_rd_ack	(mout_scb3_jbus_rd_ack),
		.mout_nack		(mout_nack),
		.mout_nack_buf_id	(mout_nack_buf_id[1:0]),
		.mout_nack_thr_id	(mout_nack_thr_id[5:0]),
		.mout_min_inject_err_done(mout_min_inject_err_done),
		.mout_csr_inject_output_done(mout_csr_inject_output_done),
		.mout_min_jbus_owner	(mout_min_jbus_owner[5:0]),
		.mout_port_4_present	(mout_port_4_present),
		.mout_port_5_present	(mout_port_5_present),
		.mout_csr_err_cpar	(mout_csr_err_cpar),
		.mout_csr_jbi_log_par_jpar(mout_csr_jbi_log_par_jpar),
		.mout_csr_jbi_log_par_jpack0(mout_csr_jbi_log_par_jpack0[2:0]),
		.mout_csr_jbi_log_par_jpack1(mout_csr_jbi_log_par_jpack1[2:0]),
		.mout_csr_jbi_log_par_jpack4(mout_csr_jbi_log_par_jpack4[2:0]),
		.mout_csr_jbi_log_par_jpack5(mout_csr_jbi_log_par_jpack5[2:0]),
		.mout_csr_jbi_log_par_jreq(mout_csr_jbi_log_par_jreq[6:0]),
		.mout_csr_err_arb_to	(mout_csr_err_arb_to),
		.jbi_log_arb_myreq	(jbi_log_arb_myreq[2:0]),
		.jbi_log_arb_reqtype	(jbi_log_arb_reqtype[2:0]),
		.jbi_log_arb_aok	(jbi_log_arb_aok[6:0]),
		.jbi_log_arb_dok	(jbi_log_arb_dok[6:0]),
		.jbi_log_arb_jreq	(jbi_log_arb_jreq[6:0]),
		.mout_csr_err_fatal	(mout_csr_err_fatal[5:4]),
		.mout_csr_err_read_to	(mout_csr_err_read_to),
		.mout_perf_aok_off	(mout_perf_aok_off),
		.mout_perf_dok_off	(mout_perf_dok_off),
		.mout_dbg_pop		(mout_dbg_pop),
		// Inputs
		.scbuf0_jbi_data	(scbuf0_jbi_data[31:0]),
		.scbuf0_jbi_ctag_vld	(scbuf0_jbi_ctag_vld),
		.scbuf0_jbi_ue_err	(scbuf0_jbi_ue_err),
		.sctag0_jbi_por_req_buf	(sctag0_jbi_por_req_buf),
		.scbuf1_jbi_data	(scbuf1_jbi_data[31:0]),
		.scbuf1_jbi_ctag_vld	(scbuf1_jbi_ctag_vld),
		.scbuf1_jbi_ue_err	(scbuf1_jbi_ue_err),
		.sctag1_jbi_por_req_buf	(sctag1_jbi_por_req_buf),
		.scbuf2_jbi_data	(scbuf2_jbi_data[31:0]),
		.scbuf2_jbi_ctag_vld	(scbuf2_jbi_ctag_vld),
		.scbuf2_jbi_ue_err	(scbuf2_jbi_ue_err),
		.sctag2_jbi_por_req_buf	(sctag2_jbi_por_req_buf),
		.scbuf3_jbi_data	(scbuf3_jbi_data[31:0]),
		.scbuf3_jbi_ctag_vld	(scbuf3_jbi_ctag_vld),
		.scbuf3_jbi_ue_err	(scbuf3_jbi_ue_err),
		.sctag3_jbi_por_req_buf	(sctag3_jbi_por_req_buf),
		.ncio_pio_req		(ncio_pio_req),
		.ncio_pio_req_rw	(ncio_pio_req_rw),
		.ncio_pio_req_dest	(ncio_pio_req_dest[1:0]),
		.ncio_pio_ad		(ncio_pio_ad[63:0]),
		.ncio_pio_ue		(ncio_pio_ue),
		.ncio_pio_be		(ncio_pio_be[15:0]),
		.ncio_yid		(ncio_yid[`JBI_YID_WIDTH-1:0]),
		.ncio_mondo_req		(ncio_mondo_req),
		.ncio_mondo_ack		(ncio_mondo_ack),
		.ncio_mondo_agnt_id	(ncio_mondo_agnt_id[`JBI_AD_INT_AGTID_WIDTH-1:0]),
		.ncio_mondo_cpu_id	(ncio_mondo_cpu_id[`JBI_AD_INT_CPUID_WIDTH-1:0]),
		.ncio_prqq_level	(ncio_prqq_level[`JBI_PRQQ_ADDR_WIDTH:0]),
		.ncio_makq_level	(ncio_makq_level[`JBI_MAKQ_ADDR_WIDTH:0]),
		.io_jbi_j_pack4		(io_jbi_j_pack4[2:0]),
		.io_jbi_j_pack5		(io_jbi_j_pack5[2:0]),
		.io_jbi_j_req4_in_l	(io_jbi_j_req4_in_l),
		.io_jbi_j_req5_in_l	(io_jbi_j_req5_in_l),
		.io_jbi_j_par		(io_jbi_j_par),
		.min_free		(min_free),
		.min_free_jid		(min_free_jid[3:0]),
		.min_trans_jid		(min_trans_jid[`JBI_JID_WIDTH-1:0]),
		.min_aok_on		(min_aok_on),
		.min_aok_off		(min_aok_off),
		.min_snp_launch		(min_snp_launch),
		.ncio_mout_nack_pop	(ncio_mout_nack_pop),
		.min_mout_inject_err	(min_mout_inject_err),
		.csr_jbi_config_arb_mode(csr_jbi_config_arb_mode[1:0]),
		.csr_jbi_arb_timeout_timeval(csr_jbi_arb_timeout_timeval[31:0]),
		.csr_jbi_trans_timeout_timeval(csr_jbi_trans_timeout_timeval[31:0]),
		.csr_jbi_err_inject_errtype(csr_jbi_err_inject_errtype),
		.csr_jbi_err_inject_xormask(csr_jbi_err_inject_xormask[3:0]),
		.csr_jbi_debug_info_enb	(csr_jbi_debug_info_enb),
		.csr_dok_on		(csr_dok_on),
		.csr_jbi_debug_arb_aggr_arb(csr_jbi_debug_arb_aggr_arb),
		.csr_jbi_error_config_fe_enb(csr_jbi_error_config_fe_enb),
		.csr_jbi_log_enb_read_to(csr_jbi_log_enb_read_to),
		.dbg_req_transparent	(dbg_req_transparent),
		.dbg_req_arbitrate	(dbg_req_arbitrate),
		.dbg_req_priority	(dbg_req_priority),
		.dbg_data		(dbg_data[127:0]),
		.testmux_sel		(testmux_sel),
		.hold			(sehold),		 // Templated
		.rst_tri_en		(rst_tri_en),
		.cclk			(cmp_rclk),		 // Templated
		.crst_l			(cmp_rst_l_ff0),	 // Templated
		.clk			(jbus_rclk),		 // Templated
		.rst_l			(jbus_rst_l),		 // Templated
		.tx_en_local_m1		(tx_en_local),		 // Templated
		.arst_l			(cmp_arst_l));		 // Templated



//*******************************************************************************
// NCIO Block (Non-Cached IO)
//*******************************************************************************

/* jbi_ncio AUTO_TEMPLATE (
 .clk (jbus_rclk),
 .rst_l (jbus_rst_l),
 .arst_l (jbus_arst_l),
 .cpu_clk (cmp_rclk),
 .cpu_rst_l (cmp_rst_l_ff1),
 .hold (sehold),
 .scan_en (se),
 .io_jbi_j_ad_ff (min_j_ad_ff),
 .cpu_tx_en (tx_en_local),
 .cpu_rx_en (rx_en_local),
 ); */

jbi_ncio u_ncio (/*AUTOINST*/
		 // Outputs
		 .ncio_csr_err_intr_to	(ncio_csr_err_intr_to[31:0]),
		 .ncio_csr_perf_pio_rd_out(ncio_csr_perf_pio_rd_out),
		 .ncio_csr_perf_pio_wr	(ncio_csr_perf_pio_wr),
		 .ncio_csr_perf_pio_rd_latency(ncio_csr_perf_pio_rd_latency[4:0]),
		 .ncio_csr_read_addr	(ncio_csr_read_addr[`JBI_CSR_ADDR_WIDTH-1:0]),
		 .ncio_csr_write	(ncio_csr_write),
		 .ncio_csr_write_addr	(ncio_csr_write_addr[`JBI_CSR_ADDR_WIDTH-1:0]),
		 .ncio_csr_write_data	(ncio_csr_write_data[`JBI_CSR_WIDTH-1:0]),
		 .jbi_iob_pio_vld	(jbi_iob_pio_vld),
		 .jbi_iob_pio_data	(jbi_iob_pio_data[`JBI_IOB_WIDTH-1:0]),
		 .jbi_iob_pio_stall	(jbi_iob_pio_stall),
		 .jbi_iob_mondo_vld	(jbi_iob_mondo_vld),
		 .jbi_iob_mondo_data	(jbi_iob_mondo_data[`JBI_IOB_MONDO_BUS_WIDTH-1:0]),
		 .ncio_pio_req		(ncio_pio_req),
		 .ncio_pio_req_rw	(ncio_pio_req_rw),
		 .ncio_pio_req_dest	(ncio_pio_req_dest[1:0]),
		 .ncio_pio_ue		(ncio_pio_ue),
		 .ncio_pio_be		(ncio_pio_be[15:0]),
		 .ncio_pio_ad		(ncio_pio_ad[63:0]),
		 .ncio_yid		(ncio_yid[`JBI_YID_WIDTH-1:0]),
		 .ncio_prqq_level	(ncio_prqq_level[`JBI_PRQQ_ADDR_WIDTH:0]),
		 .ncio_mondo_req	(ncio_mondo_req),
		 .ncio_mondo_ack	(ncio_mondo_ack),
		 .ncio_mondo_agnt_id	(ncio_mondo_agnt_id[`JBI_AD_INT_AGTID_WIDTH-1:0]),
		 .ncio_mondo_cpu_id	(ncio_mondo_cpu_id[`JBI_AD_INT_CPUID_WIDTH-1:0]),
		 .ncio_makq_level	(ncio_makq_level[`JBI_MAKQ_ADDR_WIDTH:0]),
		 .ncio_mout_nack_pop	(ncio_mout_nack_pop),
		 // Inputs
		 .clk			(jbus_rclk),		 // Templated
		 .rst_l			(jbus_rst_l),		 // Templated
		 .arst_l		(jbus_arst_l),		 // Templated
		 .cpu_clk		(cmp_rclk),		 // Templated
		 .cpu_rst_l		(cmp_rst_l_ff1),	 // Templated
		 .cpu_rx_en		(rx_en_local),		 // Templated
		 .cpu_tx_en		(tx_en_local),		 // Templated
		 .hold			(sehold),		 // Templated
		 .testmux_sel		(testmux_sel),
		 .scan_en		(se),			 // Templated
		 .rst_tri_en		(rst_tri_en),
		 .csr_16x65array_margin	(csr_16x65array_margin[4:0]),
		 .csr_16x81array_margin	(csr_16x81array_margin[4:0]),
		 .csr_jbi_config2_max_pio(csr_jbi_config2_max_pio[3:0]),
		 .csr_jbi_config2_ord_int(csr_jbi_config2_ord_int),
		 .csr_jbi_config2_ord_pio(csr_jbi_config2_ord_pio),
		 .csr_jbi_intr_timeout_timeval(csr_jbi_intr_timeout_timeval[31:0]),
		 .csr_jbi_intr_timeout_rst_l(csr_jbi_intr_timeout_rst_l),
		 .csr_int_req		(csr_int_req),
		 .csr_csr_read_data	(csr_csr_read_data[`JBI_CSR_WIDTH-1:0]),
		 .iob_jbi_pio_stall	(iob_jbi_pio_stall),
		 .iob_jbi_pio_vld	(iob_jbi_pio_vld),
		 .iob_jbi_pio_data	(iob_jbi_pio_data[`IOB_JBI_WIDTH-1:0]),
		 .iob_jbi_mondo_ack	(iob_jbi_mondo_ack),
		 .iob_jbi_mondo_nack	(iob_jbi_mondo_nack),
		 .io_jbi_j_ad_ff	(min_j_ad_ff),		 // Templated
		 .min_pio_rtrn_push	(min_pio_rtrn_push),
		 .min_pio_data_err	(min_pio_data_err),
		 .min_mondo_hdr_push	(min_mondo_hdr_push),
		 .min_mondo_data_push	(min_mondo_data_push),
		 .min_mondo_data_err	(min_mondo_data_err),
		 .min_oldest_wri_tag	(min_oldest_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		 .min_pre_wri_tag	(min_pre_wri_tag[`JBI_WRI_TAG_WIDTH-1:0]),
		 .mout_trans_yid	(mout_trans_yid[`JBI_YID_WIDTH-1:0]),
		 .mout_pio_pop		(mout_pio_pop),
		 .mout_pio_req_adv	(mout_pio_req_adv),
		 .mout_mondo_pop	(mout_mondo_pop),
		 .mout_nack		(mout_nack),
		 .mout_nack_buf_id	(mout_nack_buf_id[`UCB_BUF_HI-`UCB_BUF_LO:0]),
		 .mout_nack_thr_id	(mout_nack_thr_id[`UCB_THR_HI-`UCB_THR_LO:0]));



//*******************************************************************************
// SSI (System Serial Interface)
//*******************************************************************************

/* jbi_ssi AUTO_TEMPLATE (
 .clk (jbus_rclk),
 .rst_l (jbus_rst_l),
 .arst_l (jbus_arst_l),
); */

jbi_ssi u_ssi (/*AUTOINST*/
	       // Outputs
	       .jbi_io_ssi_mosi		(jbi_io_ssi_mosi),
	       .jbi_io_ssi_sck		(jbi_io_ssi_sck),
	       .jbi_iob_spi_vld		(jbi_iob_spi_vld),
	       .jbi_iob_spi_data	(jbi_iob_spi_data[3:0]),
	       .jbi_iob_spi_stall	(jbi_iob_spi_stall),
	       // Inputs
	       .clk			(jbus_rclk),		 // Templated
	       .rst_l			(jbus_rst_l),		 // Templated
	       .arst_l			(jbus_arst_l),		 // Templated
	       .ctu_jbi_ssiclk		(ctu_jbi_ssiclk),
	       .io_jbi_ssi_miso		(io_jbi_ssi_miso),
	       .io_jbi_ext_int_l	(io_jbi_ext_int_l),
	       .iob_jbi_spi_vld		(iob_jbi_spi_vld),
	       .iob_jbi_spi_data	(iob_jbi_spi_data[3:0]),
	       .iob_jbi_spi_stall	(iob_jbi_spi_stall));



//*******************************************************************************
// Debug Port
//*******************************************************************************

/* jbi_dbg AUTO_TEMPLATE (
 .clk (jbus_rclk),
 .rst_l (jbus_rst_l),
 .dbg_rst_l (jbus_rst_l),
 .hold (sehold),
 .scan_en (se),
); */

jbi_dbg u_dbg (/*AUTOINST*/
	       // Outputs
	       .dbg_req_transparent	(dbg_req_transparent),
	       .dbg_req_arbitrate	(dbg_req_arbitrate),
	       .dbg_req_priority	(dbg_req_priority),
	       .dbg_data		(dbg_data[127:0]),
	       // Inputs
	       .clk			(jbus_rclk),		 // Templated
	       .rst_l			(jbus_rst_l),		 // Templated
	       .dbg_rst_l		(jbus_rst_l),		 // Templated
	       .hold			(sehold),		 // Templated
	       .testmux_sel		(testmux_sel),
	       .scan_en			(se),			 // Templated
	       .csr_16x65array_margin	(csr_16x65array_margin[4:0]),
	       .csr_jbi_debug_arb_max_wait(csr_jbi_debug_arb_max_wait[`JBI_CSR_DBG_MAX_WAIT_WIDTH-1:0]),
	       .csr_jbi_debug_arb_hi_water(csr_jbi_debug_arb_hi_water[`JBI_CSR_DBG_HI_WATER_WIDTH-1:0]),
	       .csr_jbi_debug_arb_lo_water(csr_jbi_debug_arb_lo_water[`JBI_CSR_DBG_LO_WATER_WIDTH-1:0]),
	       .csr_jbi_debug_arb_data_arb(csr_jbi_debug_arb_data_arb),
	       .csr_jbi_debug_arb_tstamp_wrap(csr_jbi_debug_arb_tstamp_wrap[`JBI_CSR_DBG_TSWRAP_WIDTH-1:0]),
	       .csr_jbi_debug_arb_alternate(csr_jbi_debug_arb_alternate),
	       .csr_jbi_debug_arb_alternate_set_l(csr_jbi_debug_arb_alternate_set_l),
	       .iob_jbi_dbg_hi_data	(iob_jbi_dbg_hi_data[47:0]),
	       .iob_jbi_dbg_hi_vld	(iob_jbi_dbg_hi_vld),
	       .iob_jbi_dbg_lo_data	(iob_jbi_dbg_lo_data[47:0]),
	       .iob_jbi_dbg_lo_vld	(iob_jbi_dbg_lo_vld),
	       .mout_dbg_pop		(mout_dbg_pop));



//*******************************************************************************
// CSR
//*******************************************************************************

/* jbi_csr AUTO_TEMPLATE (
 .clk    (jbus_rclk),
 .rst_l  (jbus_rst_l),
); */

jbi_csr u_csr (/*AUTOINST*/
	       // Outputs
	       .csr_csr_read_data	(csr_csr_read_data[`JBI_CSR_WIDTH-1:0]),
	       .csr_jbi_config_port_pres(csr_jbi_config_port_pres[6:0]),
	       .jbi_io_config_dtl	(jbi_io_config_dtl[1:0]),
	       .csr_jbi_config_arb_mode	(csr_jbi_config_arb_mode[1:0]),
	       .csr_jbi_config2_iq_high	(csr_jbi_config2_iq_high[3:0]),
	       .csr_jbi_config2_iq_low	(csr_jbi_config2_iq_low[3:0]),
	       .csr_jbi_config2_max_rd	(csr_jbi_config2_max_rd[1:0]),
	       .csr_jbi_config2_max_wris(csr_jbi_config2_max_wris[1:0]),
	       .csr_jbi_config2_max_wr	(csr_jbi_config2_max_wr[3:0]),
	       .csr_jbi_config2_ord_wr	(csr_jbi_config2_ord_wr),
	       .csr_jbi_config2_ord_int	(csr_jbi_config2_ord_int),
	       .csr_jbi_config2_ord_pio	(csr_jbi_config2_ord_pio),
	       .csr_jbi_config2_ord_rd	(csr_jbi_config2_ord_rd),
	       .csr_jbi_config2_max_pio	(csr_jbi_config2_max_pio[3:0]),
	       .csr_16x65array_margin	(csr_16x65array_margin[4:0]),
	       .csr_16x81array_margin	(csr_16x81array_margin[4:0]),
	       .csr_jbi_debug_info_enb	(csr_jbi_debug_info_enb),
	       .csr_jbi_debug_arb_tstamp_wrap(csr_jbi_debug_arb_tstamp_wrap[6:0]),
	       .csr_jbi_debug_arb_alternate(csr_jbi_debug_arb_alternate),
	       .csr_jbi_debug_arb_hi_water(csr_jbi_debug_arb_hi_water[4:0]),
	       .csr_jbi_debug_arb_lo_water(csr_jbi_debug_arb_lo_water[4:0]),
	       .csr_jbi_debug_arb_data_arb(csr_jbi_debug_arb_data_arb),
	       .csr_jbi_debug_arb_aggr_arb(csr_jbi_debug_arb_aggr_arb),
	       .csr_jbi_debug_arb_max_wait(csr_jbi_debug_arb_max_wait[9:0]),
	       .csr_jbi_debug_arb_alternate_set_l(csr_jbi_debug_arb_alternate_set_l),
	       .csr_jbi_err_inject_output(csr_jbi_err_inject_output),
	       .csr_jbi_err_inject_input(csr_jbi_err_inject_input),
	       .csr_jbi_err_inject_errtype(csr_jbi_err_inject_errtype),
	       .csr_jbi_err_inject_xormask(csr_jbi_err_inject_xormask[3:0]),
	       .csr_jbi_err_inject_count(csr_jbi_err_inject_count[23:0]),
	       .csr_jbi_error_config_fe_enb(csr_jbi_error_config_fe_enb),
	       .csr_jbi_error_config_erren(csr_jbi_error_config_erren),
	       .csr_jbi_error_config_sigen(csr_jbi_error_config_sigen),
	       .csr_jbi_log_enb_apar	(csr_jbi_log_enb_apar),
	       .csr_jbi_log_enb_dpar_wr	(csr_jbi_log_enb_dpar_wr),
	       .csr_jbi_log_enb_dpar_rd	(csr_jbi_log_enb_dpar_rd),
	       .csr_jbi_log_enb_dpar_o	(csr_jbi_log_enb_dpar_o),
	       .csr_jbi_log_enb_rep_ue	(csr_jbi_log_enb_rep_ue),
	       .csr_jbi_log_enb_nonex_rd(csr_jbi_log_enb_nonex_rd),
	       .csr_jbi_log_enb_read_to	(csr_jbi_log_enb_read_to),
	       .csr_jbi_log_enb_err_cycle(csr_jbi_log_enb_err_cycle),
	       .csr_jbi_log_enb_unexp_dr(csr_jbi_log_enb_unexp_dr),
	       .csr_int_req		(csr_int_req),
	       .csr_dok_on		(csr_dok_on),
	       .csr_jbi_l2_timeout_timeval(csr_jbi_l2_timeout_timeval[31:0]),
	       .csr_jbi_arb_timeout_timeval(csr_jbi_arb_timeout_timeval[31:0]),
	       .csr_jbi_trans_timeout_timeval(csr_jbi_trans_timeout_timeval[31:0]),
	       .csr_jbi_intr_timeout_timeval(csr_jbi_intr_timeout_timeval[31:0]),
	       .csr_jbi_intr_timeout_rst_l(csr_jbi_intr_timeout_rst_l),
	       .csr_jbi_memsize_size	(csr_jbi_memsize_size[37:30]),
	       .jbi_clk_tr		(jbi_clk_tr),
	       // Inputs
	       .ncio_csr_read_addr	(ncio_csr_read_addr[`JBI_CSR_ADDR_WIDTH-1:0]),
	       .ncio_csr_write		(ncio_csr_write),
	       .ncio_csr_write_addr	(ncio_csr_write_addr[`JBI_CSR_ADDR_WIDTH-1:0]),
	       .ncio_csr_write_data	(ncio_csr_write_data[`JBI_CSR_WIDTH-1:0]),
	       .mout_port_4_present	(mout_port_4_present),
	       .mout_port_5_present	(mout_port_5_present),
	       .min_csr_inject_input_done(min_csr_inject_input_done),
	       .mout_csr_inject_output_done(mout_csr_inject_output_done),
	       .min_csr_err_apar	(min_csr_err_apar),
	       .min_csr_err_adtype	(min_csr_err_adtype),
	       .min_csr_err_dpar_wr	(min_csr_err_dpar_wr),
	       .min_csr_err_dpar_rd	(min_csr_err_dpar_rd),
	       .min_csr_err_dpar_o	(min_csr_err_dpar_o),
	       .min_csr_err_rep_ue	(min_csr_err_rep_ue),
	       .min_csr_err_illegal	(min_csr_err_illegal),
	       .min_csr_err_unsupp	(min_csr_err_unsupp),
	       .min_csr_err_nonex_wr	(min_csr_err_nonex_wr),
	       .min_csr_err_nonex_rd	(min_csr_err_nonex_rd),
	       .min_csr_err_err_cycle	(min_csr_err_err_cycle),
	       .min_csr_err_unexp_dr	(min_csr_err_unexp_dr),
	       .min_csr_err_unmap_wr	(min_csr_err_unmap_wr),
	       .ncio_csr_err_intr_to	(ncio_csr_err_intr_to[31:0]),
	       .min_csr_err_l2_to0	(min_csr_err_l2_to0),
	       .min_csr_err_l2_to1	(min_csr_err_l2_to1),
	       .min_csr_err_l2_to2	(min_csr_err_l2_to2),
	       .min_csr_err_l2_to3	(min_csr_err_l2_to3),
	       .mout_csr_err_cpar	(mout_csr_err_cpar),
	       .mout_csr_err_arb_to	(mout_csr_err_arb_to),
	       .mout_csr_err_fatal	(mout_csr_err_fatal[5:4]),
	       .mout_csr_err_read_to	(mout_csr_err_read_to),
	       .min_csr_write_log_addr	(min_csr_write_log_addr),
	       .min_csr_log_addr_owner	(min_csr_log_addr_owner[2:0]),
	       .min_csr_log_addr_adtype	(min_csr_log_addr_adtype[7:0]),
	       .min_csr_log_addr_ttype	(min_csr_log_addr_ttype[4:0]),
	       .min_csr_log_addr_addr	(min_csr_log_addr_addr[42:0]),
	       .min_csr_log_ctl_owner	(min_csr_log_ctl_owner[2:0]),
	       .min_csr_log_ctl_parity	(min_csr_log_ctl_parity[3:0]),
	       .min_csr_log_ctl_adtype0	(min_csr_log_ctl_adtype0[7:0]),
	       .min_csr_log_ctl_adtype1	(min_csr_log_ctl_adtype1[7:0]),
	       .min_csr_log_ctl_adtype2	(min_csr_log_ctl_adtype2[7:0]),
	       .min_csr_log_ctl_adtype3	(min_csr_log_ctl_adtype3[7:0]),
	       .min_csr_log_ctl_adtype4	(min_csr_log_ctl_adtype4[7:0]),
	       .min_csr_log_ctl_adtype5	(min_csr_log_ctl_adtype5[7:0]),
	       .min_csr_log_ctl_adtype6	(min_csr_log_ctl_adtype6[7:0]),
	       .min_csr_log_data0	(min_csr_log_data0[63:0]),
	       .min_csr_log_data1	(min_csr_log_data1[63:0]),
	       .mout_csr_jbi_log_par_jpar(mout_csr_jbi_log_par_jpar),
	       .mout_csr_jbi_log_par_jpack5(mout_csr_jbi_log_par_jpack5[2:0]),
	       .mout_csr_jbi_log_par_jpack4(mout_csr_jbi_log_par_jpack4[2:0]),
	       .mout_csr_jbi_log_par_jpack1(mout_csr_jbi_log_par_jpack1[2:0]),
	       .mout_csr_jbi_log_par_jpack0(mout_csr_jbi_log_par_jpack0[2:0]),
	       .mout_csr_jbi_log_par_jreq(mout_csr_jbi_log_par_jreq[6:0]),
	       .jbi_log_arb_myreq	(jbi_log_arb_myreq[2:0]),
	       .jbi_log_arb_reqtype	(jbi_log_arb_reqtype[2:0]),
	       .jbi_log_arb_aok		(jbi_log_arb_aok[6:0]),
	       .jbi_log_arb_dok		(jbi_log_arb_dok[6:0]),
	       .jbi_log_arb_jreq	(jbi_log_arb_jreq[6:0]),
	       .min_csr_perf_dma_rd_in	(min_csr_perf_dma_rd_in),
	       .min_csr_perf_dma_rd_latency(min_csr_perf_dma_rd_latency[4:0]),
	       .min_csr_perf_dma_wr	(min_csr_perf_dma_wr),
	       .min_csr_perf_dma_wr8	(min_csr_perf_dma_wr8),
	       .min_csr_perf_blk_q0	(min_csr_perf_blk_q0[3:0]),
	       .min_csr_perf_blk_q1	(min_csr_perf_blk_q1[3:0]),
	       .min_csr_perf_blk_q2	(min_csr_perf_blk_q2[3:0]),
	       .min_csr_perf_blk_q3	(min_csr_perf_blk_q3[3:0]),
	       .ncio_csr_perf_pio_rd_out(ncio_csr_perf_pio_rd_out),
	       .ncio_csr_perf_pio_wr	(ncio_csr_perf_pio_wr),
	       .ncio_csr_perf_pio_rd_latency(ncio_csr_perf_pio_rd_latency[4:0]),
	       .mout_perf_aok_off	(mout_perf_aok_off),
	       .mout_perf_dok_off	(mout_perf_dok_off),
	       .clk			(jbus_rclk),		 // Templated
	       .rst_l			(jbus_rst_l),		 // Templated
	       .ctu_jbi_fst_rst_l	(ctu_jbi_fst_rst_l),
	       .sehold			(sehold));


endmodule


// Local Variables:
// verilog-library-directories:("." "../jbi_min/rtl" "../jbi_mout/rtl" "../jbi_ncio/rtl" "../jbi_ssi/rtl" "../jbi_dbg/rtl" "../jbi_csr/rtl" "../../common/rtl")
// verilog-library-files:      ("../../common/rtl/swrvr_clib.v")
// End:
