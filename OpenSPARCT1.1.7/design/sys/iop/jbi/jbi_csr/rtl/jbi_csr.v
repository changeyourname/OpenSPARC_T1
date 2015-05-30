// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_csr.v
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
// _____________________________________________________________________________
//
// jbi_csr -- JBI Control and Status Registers.
// _____________________________________________________________________________
//
// Description:
//
//   Implements the following registers as defined in the
//   "JBUS Interface Specification" 
//
//       pg              Addr      RO    WO    RW    Description
//       --    --------------    ----  ----  ----    --------------
//        6    ?
//        7    ?
//       19    0x80_0000_0000      38     -    22    JBI_CONFIG
//       20    0x80_0000_0008       -     -    24    JBI_CONFIG2
//       22    0x80_0000_4000       -     -     1    JBI_DEBUG (*1)
//       22    0x80_0000_4100       -     -    24    JBI_DEBUG_ARB
//       28    0x80_0001_0000       -     -     3    JBI_ERROR_CONFIG
//       29    0x80_0001_0020       -     -    20    JBI_ERROR_LOG
//       30    0x80_0001_0028       -     -    20    JBI_ERROR_OVF
//       31    0x80_0001_0030       -     -    20    JBI_LOG_ENB
//       32    0x80_0001_0038       -     -    20    JBI_SIG_ENB
//       33    0x80_0001_0040       -     -    59    JBI_LOG_ADDR (*2)
//       34    0x80_0001_0048       -     -    63    JBI_LOG_CTRL
//       33    0x80_0001_0050       -     -    64    JBI_LOG_DATA0 (*2)
//       33    0x80_0001_0058       -     -    64    JBI_LOG_DATA1 (*2)
//       34    0x80_0001_0060       -     -    21    JBI_LOG_PAR 
//       35    0x80_0001_0070       -     -    32    JBI_LOG_NACK (*3)
//       35    0x80_0001_0078       -     -    26    JBI_LOG_ARB
//       35    0x80_0001_0080       -     -    32    JBI_L2_TIMEOUT
//       36    0x80_0001_0088       -     -    32    JBI_ARB_TIMEOUT
//       36    0x80_0001_0090       -     -    32    JBI_TRANS_TIMEOUT
//       36    0x80_0001_0098       -     -    32    JBI_INTR_TIMEOUT
//       36    0x80_0001_00A0       -     -     8    JBI_MEMSIZE (*4)
// _____________________________________________________________________________

`include "sys.h"
`include "jbi.h"

module jbi_csr (/*AUTOARG*/
// Outputs
csr_csr_read_data, csr_jbi_config_port_pres, jbi_io_config_dtl, 
csr_jbi_config_arb_mode, csr_jbi_config2_iq_high, 
csr_jbi_config2_iq_low, csr_jbi_config2_max_rd, 
csr_jbi_config2_max_wris, csr_jbi_config2_max_wr, 
csr_jbi_config2_ord_wr, csr_jbi_config2_ord_int, 
csr_jbi_config2_ord_pio, csr_jbi_config2_ord_rd, 
csr_jbi_config2_max_pio, csr_16x65array_margin, 
csr_16x81array_margin, csr_jbi_debug_info_enb, 
csr_jbi_debug_arb_tstamp_wrap, csr_jbi_debug_arb_alternate, 
csr_jbi_debug_arb_hi_water, csr_jbi_debug_arb_lo_water, 
csr_jbi_debug_arb_data_arb, csr_jbi_debug_arb_aggr_arb, 
csr_jbi_debug_arb_max_wait, csr_jbi_debug_arb_alternate_set_l, 
csr_jbi_err_inject_output, csr_jbi_err_inject_input, 
csr_jbi_err_inject_errtype, csr_jbi_err_inject_xormask, 
csr_jbi_err_inject_count, csr_jbi_error_config_fe_enb, 
csr_jbi_error_config_erren, csr_jbi_error_config_sigen, 
csr_jbi_log_enb_apar, csr_jbi_log_enb_dpar_wr, 
csr_jbi_log_enb_dpar_rd, csr_jbi_log_enb_dpar_o, 
csr_jbi_log_enb_rep_ue, csr_jbi_log_enb_nonex_rd, 
csr_jbi_log_enb_read_to, csr_jbi_log_enb_err_cycle, 
csr_jbi_log_enb_unexp_dr, csr_int_req, csr_dok_on, 
csr_jbi_l2_timeout_timeval, csr_jbi_arb_timeout_timeval, 
csr_jbi_trans_timeout_timeval, csr_jbi_intr_timeout_timeval, 
csr_jbi_intr_timeout_rst_l, csr_jbi_memsize_size, jbi_clk_tr, 
// Inputs
ncio_csr_read_addr, ncio_csr_write, ncio_csr_write_addr, 
ncio_csr_write_data, mout_port_4_present, mout_port_5_present, 
min_csr_inject_input_done, mout_csr_inject_output_done, 
min_csr_err_apar, min_csr_err_adtype, min_csr_err_dpar_wr, 
min_csr_err_dpar_rd, min_csr_err_dpar_o, min_csr_err_rep_ue, 
min_csr_err_illegal, min_csr_err_unsupp, min_csr_err_nonex_wr, 
min_csr_err_nonex_rd, min_csr_err_err_cycle, min_csr_err_unexp_dr, 
min_csr_err_unmap_wr, ncio_csr_err_intr_to, min_csr_err_l2_to0, 
min_csr_err_l2_to1, min_csr_err_l2_to2, min_csr_err_l2_to3, 
mout_csr_err_cpar, mout_csr_err_arb_to, mout_csr_err_fatal, 
mout_csr_err_read_to, min_csr_write_log_addr, min_csr_log_addr_owner, 
min_csr_log_addr_adtype, min_csr_log_addr_ttype, 
min_csr_log_addr_addr, min_csr_log_ctl_owner, min_csr_log_ctl_parity, 
min_csr_log_ctl_adtype0, min_csr_log_ctl_adtype1, 
min_csr_log_ctl_adtype2, min_csr_log_ctl_adtype3, 
min_csr_log_ctl_adtype4, min_csr_log_ctl_adtype5, 
min_csr_log_ctl_adtype6, min_csr_log_data0, min_csr_log_data1, 
mout_csr_jbi_log_par_jpar, mout_csr_jbi_log_par_jpack5, 
mout_csr_jbi_log_par_jpack4, mout_csr_jbi_log_par_jpack1, 
mout_csr_jbi_log_par_jpack0, mout_csr_jbi_log_par_jreq, 
jbi_log_arb_myreq, jbi_log_arb_reqtype, jbi_log_arb_aok, jbi_log_arb_dok, 
jbi_log_arb_jreq, min_csr_perf_dma_rd_in, 
min_csr_perf_dma_rd_latency, min_csr_perf_dma_wr, 
min_csr_perf_dma_wr8, min_csr_perf_blk_q0, min_csr_perf_blk_q1, 
min_csr_perf_blk_q2, min_csr_perf_blk_q3, ncio_csr_perf_pio_rd_out, 
ncio_csr_perf_pio_wr, ncio_csr_perf_pio_rd_latency, 
mout_perf_aok_off, mout_perf_dok_off, clk, rst_l, ctu_jbi_fst_rst_l, 
sehold
);

  // Read port.
  input [`JBI_CSR_ADDR_WIDTH-1:0] ncio_csr_read_addr;
  output     [`JBI_CSR_WIDTH-1:0] csr_csr_read_data;

  // Write port.
  input 			  ncio_csr_write;
  input [`JBI_CSR_ADDR_WIDTH-1:0] ncio_csr_write_addr;
  input      [`JBI_CSR_WIDTH-1:0] ncio_csr_write_data;

  // CSR - JBI_CONFIG.
  input 			  mout_port_4_present;
  input 			  mout_port_5_present;
  output 		    [6:0] csr_jbi_config_port_pres;
  output 		    [1:0] jbi_io_config_dtl;
  output 		    [1:0] csr_jbi_config_arb_mode;

  // CSR - JBI_CONFIG2.
  output 		    [3:0] csr_jbi_config2_iq_high;
  output 		    [3:0] csr_jbi_config2_iq_low;
  output 		    [1:0] csr_jbi_config2_max_rd;
  output 		    [1:0] csr_jbi_config2_max_wris;
  output 		    [3:0] csr_jbi_config2_max_wr;
  output 			  csr_jbi_config2_ord_wr;
  output 			  csr_jbi_config2_ord_int;
  output 			  csr_jbi_config2_ord_pio;
  output 			  csr_jbi_config2_ord_rd;
  output 		    [3:0] csr_jbi_config2_max_pio;

// CSR - JBI_INT_MRGN
output [4:0] 			  csr_16x65array_margin;
output [4:0] 			  csr_16x81array_margin;

  // CSR - JBI_DEBUG.
  output 			  csr_jbi_debug_info_enb;

  // CSR - JBI_DEBUG_ARB.
  output 		    [6:0] csr_jbi_debug_arb_tstamp_wrap;
  output 			  csr_jbi_debug_arb_alternate;
  output 		    [4:0] csr_jbi_debug_arb_hi_water;
  output 		    [4:0] csr_jbi_debug_arb_lo_water;
  output 			  csr_jbi_debug_arb_data_arb;
  output 			  csr_jbi_debug_arb_aggr_arb;
  output 		    [9:0] csr_jbi_debug_arb_max_wait;
  output 			  csr_jbi_debug_arb_alternate_set_l;

  // CSR - JBI_ERR_INJECT
  input 			  min_csr_inject_input_done;
  input 			  mout_csr_inject_output_done;
  output 			  csr_jbi_err_inject_output;
  output 			  csr_jbi_err_inject_input;
  output 			  csr_jbi_err_inject_errtype;
  output 		    [3:0] csr_jbi_err_inject_xormask;
  output 		   [23:0] csr_jbi_err_inject_count;

  // CSR - JBI_ERROR_CONFIG.
  output 			  csr_jbi_error_config_fe_enb;
  output 			  csr_jbi_error_config_erren;
  output 			  csr_jbi_error_config_sigen;

  // CSR - JBI_ERROR_LOG.
  input 			  min_csr_err_apar;
  input 			  min_csr_err_adtype;
  input 			  min_csr_err_dpar_wr;
  input 			  min_csr_err_dpar_rd;
  input 			  min_csr_err_dpar_o;
  input 			  min_csr_err_rep_ue;
  input 			  min_csr_err_illegal;
  input 			  min_csr_err_unsupp;
  input 			  min_csr_err_nonex_wr;
  input 			  min_csr_err_nonex_rd;
  input 			  min_csr_err_err_cycle;
  input 			  min_csr_err_unexp_dr;
  input 			  min_csr_err_unmap_wr;
  input 		   [31:0] ncio_csr_err_intr_to;
  input 			  min_csr_err_l2_to0;
  input 			  min_csr_err_l2_to1;
  input 			  min_csr_err_l2_to2;
  input 			  min_csr_err_l2_to3;
  //?
  input 			  mout_csr_err_cpar;
  input 			  mout_csr_err_arb_to;
  input 		    [5:4] mout_csr_err_fatal;
  input 			  mout_csr_err_read_to;

  // CSR - JBI_ERROR_OVF.

  // CSR - JBI_LOG_ENB.
  output 			  csr_jbi_log_enb_apar;
  output 			  csr_jbi_log_enb_dpar_wr;
  output 			  csr_jbi_log_enb_dpar_rd;
  output                          csr_jbi_log_enb_dpar_o;
  output 			  csr_jbi_log_enb_rep_ue;
  output 			  csr_jbi_log_enb_nonex_rd;
  output                          csr_jbi_log_enb_read_to;
  output 			  csr_jbi_log_enb_err_cycle; 	     
  output                          csr_jbi_log_enb_unexp_dr;

  // CSR - JBI_SIG_ENB.
  output 			  csr_int_req;
  output 			  csr_dok_on;

  // CSR - JBI_LOG_ADDR.
  input 			  min_csr_write_log_addr;
  input 		    [2:0] min_csr_log_addr_owner;
  input 		    [7:0] min_csr_log_addr_adtype;
  input 		    [4:0] min_csr_log_addr_ttype;
  input 		   [42:0] min_csr_log_addr_addr;

  // CSR - JBI_LOG_CTRL.
  input 		    [2:0] min_csr_log_ctl_owner;
  input 		    [3:0] min_csr_log_ctl_parity;
  input 		    [7:0] min_csr_log_ctl_adtype0;
  input 		    [7:0] min_csr_log_ctl_adtype1;
  input 		    [7:0] min_csr_log_ctl_adtype2;
  input 		    [7:0] min_csr_log_ctl_adtype3;
  input 		    [7:0] min_csr_log_ctl_adtype4;
  input 		    [7:0] min_csr_log_ctl_adtype5;
  input 		    [7:0] min_csr_log_ctl_adtype6;

  // CSR - JBI_LOG_DATA0.
  input 		   [63:0] min_csr_log_data0;
  // CSR - JBI_LOG_DATA1.
  input 		   [63:0] min_csr_log_data1;

  // CSR - JBI_LOG_PAR.
  input 			  mout_csr_jbi_log_par_jpar;
  input 		    [2:0] mout_csr_jbi_log_par_jpack5;
  input 		    [2:0] mout_csr_jbi_log_par_jpack4;
  input 		    [2:0] mout_csr_jbi_log_par_jpack1;
  input 		    [2:0] mout_csr_jbi_log_par_jpack0;
  input 		    [6:0] mout_csr_jbi_log_par_jreq;

  // CSR - JBI_LOG_NACK.

  // CSR - JBI_LOG_ARB.
  input 		    [2:0] jbi_log_arb_myreq;
  input 		    [2:0] jbi_log_arb_reqtype;
  input 		    [6:0] jbi_log_arb_aok;
  input 		    [6:0] jbi_log_arb_dok;
  input 		    [6:0] jbi_log_arb_jreq;

  // CSR - JBI_L2_TIMEOUT.
  output 		   [31:0] csr_jbi_l2_timeout_timeval;

  // CSR - JBI_ARB_TIMEOUT.
  output 		   [31:0] csr_jbi_arb_timeout_timeval;

  // CSR - JBI_TRANS_TIMEOUT.
  output 		   [31:0] csr_jbi_trans_timeout_timeval;

  // CSR - JBI_INTR_TIMEOUT.
  output 		   [31:0] csr_jbi_intr_timeout_timeval;
  output 			  csr_jbi_intr_timeout_rst_l;

  // CSR - JBI_MEMSIZE.
  output 		  [37:30] csr_jbi_memsize_size;

  // CSR - JBI_PERF_CTL
  input 			  min_csr_perf_dma_rd_in;
  input 		    [4:0] min_csr_perf_dma_rd_latency;
  input 			  min_csr_perf_dma_wr;
  input 			  min_csr_perf_dma_wr8;
  input 		    [3:0] min_csr_perf_blk_q0;
  input 		    [3:0] min_csr_perf_blk_q1;
  input 		    [3:0] min_csr_perf_blk_q2;
  input 		    [3:0] min_csr_perf_blk_q3;
  input 			  ncio_csr_perf_pio_rd_out;
  input 			  ncio_csr_perf_pio_wr;
  input 		    [4:0] ncio_csr_perf_pio_rd_latency;
  input 			  mout_perf_aok_off;
  input 			  mout_perf_dok_off;

  // CSR - JBI_PERF_COUNT

  // Clock and reset.
  input 			  clk;					// JBus clock.
  input 			  rst_l;				// JBus clock domain reset.
  input 			  ctu_jbi_fst_rst_l;			// Fast JBus clock domain reset for use in catching Port Present bits (J_RST_L + 1).

  // Debug
  output 			  jbi_clk_tr;

// Macrotest
  input 			  sehold;

  // Wires and Regs.
  wire [63:0] jbi_error_log;
  wire [63:0] jbi_log_enb;
  wire [63:0] jbi_error_log_read_data;







//*******************************************************************************
// CSR - JBI_CONFIG (0x80_0000_0000).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_config = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_CONFIG);
  //
  // Control logic.
  wire next_fst_rst_presync =  (~ctu_jbi_fst_rst_l);
  dff_ns fst_rst_presync_reg (.din(next_fst_rst_presync), .q(fst_rst_presync), .clk(clk));
  wire next_fst_rst_sync = fst_rst_presync;
  dff_ns fst_rst_sync_reg (.din(next_fst_rst_sync), .q(fst_rst_sync), .clk(clk));
  wire         write_jbi_config_48_49 = fst_rst_sync || write_jbi_config;
  wire [49:48] jbi_config_reg_din     = fst_rst_sync? { mout_port_5_present, mout_port_4_present }: ncio_csr_write_data[49:48];
  //
  // CSR registers and initial values.
  wire [63:0] jbi_config;
  dffrle_ns #(1) jbi_config_reg_50    (.din(ncio_csr_write_data[  50]),  .en(write_jbi_config),       .q(jbi_config[   50]), .rst_l(rst_l), .clk(clk));   // [50:44] = 0x0PP0011.
  dffe_ns   #(2) jbi_config_reg_49_48 (.din(jbi_config_reg_din [49:48]), .en(write_jbi_config_48_49), .q(jbi_config[49:48]),                .clk(clk));   
  dffrle_ns #(2) jbi_config_reg_47_46 (.din(ncio_csr_write_data[47:46]), .en(write_jbi_config),       .q(jbi_config[47:46]), .rst_l(rst_l), .clk(clk));   
  dffsle_ns #(2) jbi_config_reg_45_44 (.din(ncio_csr_write_data[45:44]), .en(write_jbi_config),       .q(jbi_config[45:44]), .set_l(rst_l), .clk(clk));   
  dffrle_ns #(2) jbi_config_reg_39_38 (.din(ncio_csr_write_data[39:38]), .en(write_jbi_config),       .q(jbi_config[39:38]), .rst_l(rst_l), .clk(clk));   // [39:38] = 0x0.
  dffe_ns   #(4) jbi_config_reg_31_28 (.din(ncio_csr_write_data[31:28]), .en(write_jbi_config),       .q(jbi_config[31:28]),                .clk(clk));   // [31:28] = Preserved.
  dffe_ns   #(6) jbi_config_reg_27_22 (.din(ncio_csr_write_data[27:22]), .en(write_jbi_config),       .q(jbi_config[27:22]),                .clk(clk));   // [27:22] = Preserved.
  dffrle_ns #(2) jbi_config_reg_1_0   (.din(ncio_csr_write_data[ 1: 0]), .en(write_jbi_config),       .q(jbi_config[ 1: 0]), .rst_l(rst_l), .clk(clk));   // [ 1: 0] = 0x0
  //
  // Read port data formation.
  wire [63:0] jbi_config_read_data = { 4'd0, 
				       1'b0, 
				       1'b0, 
				       7'h7f, 
				       jbi_config[50:44],
				       4'd0, 
				       jbi_config[39:38], 
				       `MANUFACTURER_ID, 
				       jbi_config[31:22], 
				       5'd0,
				       15'd0, 
				       jbi_config[1:0] };
  //
  //
  assign csr_jbi_config_port_pres[6:0] = jbi_config[50:44];
  assign jbi_io_config_dtl[1:0]        = jbi_config[39:38];
  assign csr_jbi_config_arb_mode[1:0]  = jbi_config[ 1: 0];



//*******************************************************************************
// CSR - JBI_CONFIG2 (0x80_0000_0008).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_config2 = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_CONFIG2);
  //
  // CSR registers and initial values.
  wire [63:0] jbi_config2;
  dffrle_ns #(1) jbi_config2_reg_31    (.din(ncio_csr_write_data[   31]), .en(write_jbi_config2), .q(jbi_config2[   31]), .rst_l(rst_l), .clk(clk));   // [31:28] = 0x7.
  dffsle_ns #(3) jbi_config2_reg_30_28 (.din(ncio_csr_write_data[30:28]), .en(write_jbi_config2), .q(jbi_config2[30:28]), .set_l(rst_l), .clk(clk));
  dffrle_ns #(4) jbi_config2_reg_27_24 (.din(ncio_csr_write_data[27:24]), .en(write_jbi_config2), .q(jbi_config2[27:24]), .rst_l(rst_l), .clk(clk));   // [27:24] = 0x0.
  dffrle_ns #(2) jbi_config2_reg_21_20 (.din(ncio_csr_write_data[21:20]), .en(write_jbi_config2), .q(jbi_config2[21:20]), .rst_l(rst_l), .clk(clk));   // [21:20] = 0x0.
  dffrle_ns #(2) jbi_config2_reg_17_16 (.din(ncio_csr_write_data[17:16]), .en(write_jbi_config2), .q(jbi_config2[17:16]), .rst_l(rst_l), .clk(clk));   // [17:16] = 0x0.
  dffrle_ns #(4) jbi_config2_reg_15_12 (.din(ncio_csr_write_data[15:12]), .en(write_jbi_config2), .q(jbi_config2[15:12]), .rst_l(rst_l), .clk(clk));   // [15:12] = 0x0.
  dffrle_ns #(1) jbi_config2_reg_11    (.din(ncio_csr_write_data[   11]), .en(write_jbi_config2), .q(jbi_config2[   11]), .rst_l(rst_l), .clk(clk));   // [   11] = 0.
  dffrle_ns #(1) jbi_config2_reg_10    (.din(ncio_csr_write_data[   10]), .en(write_jbi_config2), .q(jbi_config2[   10]), .rst_l(rst_l), .clk(clk));   // [   10] = 0.
  dffrle_ns #(1) jbi_config2_reg_9     (.din(ncio_csr_write_data[    9]), .en(write_jbi_config2), .q(jbi_config2[    9]), .rst_l(rst_l), .clk(clk));   // [    9] = 0.
  dffrle_ns #(1) jbi_config2_reg_8     (.din(ncio_csr_write_data[    8]), .en(write_jbi_config2), .q(jbi_config2[    8]), .rst_l(rst_l), .clk(clk));   // [    8] = 0.
  dffrle_ns #(4) jbi_config2_reg_3_0   (.din(ncio_csr_write_data[ 3: 0]), .en(write_jbi_config2), .q(jbi_config2[ 3: 0]), .rst_l(rst_l), .clk(clk));   // [ 3: 0] = 0x0.
  //
  // Read port data formation.
  wire [63:0] jbi_config2_read_data = { 32'h0, jbi_config2[31:28], jbi_config2[27:24], 2'h0, jbi_config2[21:20], 2'h0, jbi_config2[17:16],
    jbi_config2[15:12], jbi_config2[11], jbi_config2[10], jbi_config2[9], jbi_config2[8], 4'h0, jbi_config2[3:0] };
  //
  // Control logic.
  assign csr_jbi_config2_iq_high[3:0]  = jbi_config2[31:28];
  assign csr_jbi_config2_iq_low[3:0]   = jbi_config2[27:24];
  assign csr_jbi_config2_max_rd[1:0]   = jbi_config2[21:20];
  assign csr_jbi_config2_max_wris[1:0] = jbi_config2[17:16];
  assign csr_jbi_config2_max_wr[3:0]   = jbi_config2[15:12];
  assign csr_jbi_config2_ord_wr        = jbi_config2[   11];
  assign csr_jbi_config2_ord_int       = jbi_config2[   10];
  assign csr_jbi_config2_ord_pio       = jbi_config2[    9];
  assign csr_jbi_config2_ord_rd        = jbi_config2[    8];
  assign csr_jbi_config2_max_pio[3:0]  = jbi_config2[ 3: 0];

//*******************************************************************************
// CSR - JBI_INT_MRGN (0x80_0000_0010).
//*******************************************************************************
//
// Write port.
wire write_jbi_int_mrgn = ncio_csr_write 
                          && (ncio_csr_write_addr == `JBI_CSR_ADDR_INT_MRGN)
                          && ~sehold;  //retain value in macrotest
//
// CSR registers and initial values.
wire [63:0] jbi_int_mrgn;
dffsle_ns #(1) jbi_int_mrgn_reg_0 (.din(ncio_csr_write_data[ 0]), .en(write_jbi_int_mrgn), .q(jbi_int_mrgn[ 0]), .set_l(rst_l), .clk(clk));   // [    0] = 1.
dffrle_ns #(1) jbi_int_mrgn_reg_1 (.din(ncio_csr_write_data[ 1]), .en(write_jbi_int_mrgn), .q(jbi_int_mrgn[ 1]), .rst_l(rst_l), .clk(clk));   // [    0] = 0.
dffsle_ns #(1) jbi_int_mrgn_reg_2 (.din(ncio_csr_write_data[ 2]), .en(write_jbi_int_mrgn), .q(jbi_int_mrgn[ 2]), .set_l(rst_l), .clk(clk));   // [    0] = 1.
dffrle_ns #(1) jbi_int_mrgn_reg_3 (.din(ncio_csr_write_data[ 3]), .en(write_jbi_int_mrgn), .q(jbi_int_mrgn[ 3]), .rst_l(rst_l), .clk(clk));   // [    0] = 0.
dffsle_ns #(1) jbi_int_mrgn_reg_4 (.din(ncio_csr_write_data[ 4]), .en(write_jbi_int_mrgn), .q(jbi_int_mrgn[ 4]), .set_l(rst_l), .clk(clk));   // [    0] = 1.
dffsle_ns #(1) jbi_int_mrgn_reg_8 (.din(ncio_csr_write_data[ 8]), .en(write_jbi_int_mrgn), .q(jbi_int_mrgn[ 8]), .set_l(rst_l), .clk(clk));   // [    0] = 1.
dffrle_ns #(1) jbi_int_mrgn_reg_9 (.din(ncio_csr_write_data[ 9]), .en(write_jbi_int_mrgn), .q(jbi_int_mrgn[ 9]), .rst_l(rst_l), .clk(clk));   // [    0] = 0.
dffsle_ns #(1) jbi_int_mrgn_reg_10(.din(ncio_csr_write_data[10]), .en(write_jbi_int_mrgn), .q(jbi_int_mrgn[10]), .set_l(rst_l), .clk(clk));   // [    0] = 1.
dffrle_ns #(1) jbi_int_mrgn_reg_11(.din(ncio_csr_write_data[11]), .en(write_jbi_int_mrgn), .q(jbi_int_mrgn[11]), .rst_l(rst_l), .clk(clk));   // [    0] = 0.
dffsle_ns #(1) jbi_int_mrgn_reg_12(.din(ncio_csr_write_data[12]), .en(write_jbi_int_mrgn), .q(jbi_int_mrgn[12]), .set_l(rst_l), .clk(clk));   // [    0] = 1.
//
// Read port data formation.
wire [63:0] jbi_int_mrgn_read_data = { {51{1'b0}},
				       jbi_int_mrgn[12:8],
				       {3{1'b0}},
				       jbi_int_mrgn[4:0] };
//
// Control logic.
assign csr_16x65array_margin[4:0] = jbi_int_mrgn[ 4:0];
assign csr_16x81array_margin[4:0] = jbi_int_mrgn[12:8];

//*******************************************************************************
// CSR - JBI_DEBUG (0x80_0000_4000).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_debug = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_DEBUG);
  //
  // CSR registers and initial values.
  wire [63:0] jbi_debug;
  dffrle_ns #(1) jbi_debug_reg_0 (.din(ncio_csr_write_data[0]), .en(write_jbi_debug), .q(jbi_debug[0]), .rst_l(rst_l), .clk(clk));   // [    0] = 0.
  //
  // Read port data formation.
  wire [63:0] jbi_debug_read_data = { 63'h0, jbi_debug[0] };
  //
  // Control logic.
  assign csr_jbi_debug_info_enb = jbi_debug[0];



//*******************************************************************************
// CSR - JBI_DEBUG_ARB (0x80_0000_4100).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_debug_arb = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_DEBUG_ARB);
  //
  // CSR registers and initial values.
  wire [63:0] jbi_debug_arb;
  dffsle_ns #( 7) jbi_debug_arb_reg_31_25 (.din(ncio_csr_write_data[31:25]), .en(write_jbi_debug_arb), .set_l(rst_l), .q(jbi_debug_arb[31:25]), .clk(clk));   	// [31:25] = 7'h7f (max).
  dffrle_ns #( 1) jbi_debug_arb_reg_24    (.din(ncio_csr_write_data[   24]), .en(write_jbi_debug_arb), .rst_l(rst_l), .q(jbi_debug_arb[   24]), .clk(clk));   	// [   24] = 0.
  dffsle_ns #( 2) jbi_debug_arb_reg_22_21 (.din(ncio_csr_write_data[22:21]), .en(write_jbi_debug_arb), .set_l(rst_l), .q(jbi_debug_arb[22:21]), .clk(clk));   	// [22:18] = 5'h18 (75%).
  dffrle_ns #( 3) jbi_debug_arb_reg_20_18 (.din(ncio_csr_write_data[20:18]), .en(write_jbi_debug_arb), .rst_l(rst_l), .q(jbi_debug_arb[20:18]), .clk(clk));   	//
  dffsle_ns #( 1) jbi_debug_arb_reg_16    (.din(ncio_csr_write_data[   16]), .en(write_jbi_debug_arb), .set_l(rst_l), .q(jbi_debug_arb[   16]), .clk(clk));   	// [16:12] = 5'h10 (50%).
  dffrle_ns #( 4) jbi_debug_arb_reg_15_12 (.din(ncio_csr_write_data[15:12]), .en(write_jbi_debug_arb), .rst_l(rst_l), .q(jbi_debug_arb[15:12]), .clk(clk));   	//
  dffsle_ns #( 1) jbi_debug_arb_reg_11    (.din(ncio_csr_write_data[   11]), .en(write_jbi_debug_arb), .set_l(rst_l), .q(jbi_debug_arb[   11]), .clk(clk));   	// [   11] = 1.
  dffrle_ns #( 1) jbi_debug_arb_reg_10    (.din(ncio_csr_write_data[   10]), .en(write_jbi_debug_arb), .rst_l(rst_l), .q(jbi_debug_arb[   10]), .clk(clk));   	// [   10] = 0.
  dffsle_ns #( 1) jbi_debug_arb_reg_9     (.din(ncio_csr_write_data[    9]), .en(write_jbi_debug_arb), .set_l(rst_l), .q(jbi_debug_arb[    9]), .clk(clk)); 	// [ 9: 0] = 10'h200 (50%).
  dffrle_ns #( 9) jbi_debug_arb_reg_8_0   (.din(ncio_csr_write_data[ 8: 0]), .en(write_jbi_debug_arb), .rst_l(rst_l), .q(jbi_debug_arb[ 8: 0]), .clk(clk)); 	//
  //
  // Read port data formation.
  wire [63:0] jbi_debug_arb_read_data = { 32'h0, jbi_debug_arb[31:25], jbi_debug_arb[24], 1'b0, jbi_debug_arb[22:18], 1'b0, jbi_debug_arb[16:12], jbi_debug_arb[11], jbi_debug_arb[10], jbi_debug_arb[9:0] };
  //
  // Control logic.
  assign csr_jbi_debug_arb_tstamp_wrap[6:0] = jbi_debug_arb[31:25];
  assign csr_jbi_debug_arb_alternate        = jbi_debug_arb[   24];
  assign csr_jbi_debug_arb_hi_water[4:0]    = jbi_debug_arb[22:18];
  assign csr_jbi_debug_arb_lo_water[4:0]    = jbi_debug_arb[16:12];
  assign csr_jbi_debug_arb_data_arb         = jbi_debug_arb[   11];
  assign csr_jbi_debug_arb_aggr_arb         = jbi_debug_arb[   10];
  assign csr_jbi_debug_arb_max_wait[9:0]    = jbi_debug_arb[ 9: 0];
  assign csr_jbi_debug_arb_alternate_set_l  = ~write_jbi_debug_arb;



//*******************************************************************************
// CSR - JBI_ERR_INJECT  (0x80_0000_4800).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_err_inject = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_ERR_INJECT);
  //
  // Reset port
  wire jbi_err_inject_input_rst_l = rst_l & ~min_csr_inject_input_done;
  wire jbi_err_inject_output_rst_l = ~( (~rst_l) || mout_csr_inject_output_done );
  //
  // CSR registers and initial values.
  wire [30:0] jbi_err_inject;
  dffrle_ns #(1)  jbi_err_inject_reg_30    (.din(ncio_csr_write_data[   30]), .en(write_jbi_err_inject), .q(jbi_err_inject[   30]), .rst_l(jbi_err_inject_output_rst_l), .clk(clk));   // [   30] = 0.
  dffrle_ns #(1)  jbi_err_inject_reg_29    (.din(ncio_csr_write_data[   29]), .en(write_jbi_err_inject), .q(jbi_err_inject[   29]), .rst_l(jbi_err_inject_input_rst_l),  .clk(clk));   // [   29] = 0.
  dffrle_ns #(1)  jbi_err_inject_reg_28    (.din(ncio_csr_write_data[   28]), .en(write_jbi_err_inject), .q(jbi_err_inject[   28]), .rst_l(rst_l), 			 .clk(clk));   // [   28] = 0.
  dffrle_ns #(4)  jbi_err_inject_reg_27_24 (.din(ncio_csr_write_data[27:24]), .en(write_jbi_err_inject), .q(jbi_err_inject[27:24]), .rst_l(rst_l),                       .clk(clk));   // [27:24] = 0.
  dffrle_ns #(24) jbi_err_inject_reg_23_0  (.din(ncio_csr_write_data[23: 0]), .en(write_jbi_err_inject), .q(jbi_err_inject[23: 0]), .rst_l(rst_l),                       .clk(clk));   // [23: 0] = 0.
  //
  // Read port data formation.
  wire [63:0] jbi_err_inject_read_data = { 33'd0,
  					   jbi_err_inject[30:0] };
  //
  // Control logic.
  wire 	      csr_jbi_err_inject_output  = jbi_err_inject[   30];
  wire 	      csr_jbi_err_inject_input   = jbi_err_inject[   29];
  wire 	      csr_jbi_err_inject_errtype = jbi_err_inject[   28];
  wire  [3:0] csr_jbi_err_inject_xormask = jbi_err_inject[27:24];
  wire [23:0] csr_jbi_err_inject_count   = jbi_err_inject[23: 0];



//*******************************************************************************
// CSR - JBI_ERROR_CONFIG (0x80_0001_0000).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_error_config = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_ERROR_CONFIG);
  //
  // CSR registers and initial values.
  wire [63:0] jbi_error_config;
  dffrle_ns #(1) jbi_error_config_reg_4 (.din(ncio_csr_write_data[    4]), .en(write_jbi_error_config), .q(jbi_error_config[    4]), .rst_l(rst_l), .clk(clk));   // [    4] = 0.
  dffrle_ns #(1) jbi_error_config_reg_3 (.din(ncio_csr_write_data[    3]), .en(write_jbi_error_config), .q(jbi_error_config[    3]), .rst_l(rst_l), .clk(clk));   // [    3] = 0.
  dffrle_ns #(1) jbi_error_config_reg_2 (.din(ncio_csr_write_data[    2]), .en(write_jbi_error_config), .q(jbi_error_config[    2]), .rst_l(rst_l), .clk(clk));   // [    2] = 0.
  //
  // Read port data formation.
  wire [63:0] jbi_error_config_read_data = { 59'h0, jbi_error_config[4], jbi_error_config[3], jbi_error_config[2], 2'h0 };
  //
  // Control logic.
  assign csr_jbi_error_config_fe_enb = jbi_error_config[    4];
  assign csr_jbi_error_config_erren  = jbi_error_config[    3];
  assign csr_jbi_error_config_sigen  = jbi_error_config[    2];



//*******************************************************************************
// CSR - JBI_ERROR_LOG (0x80_0001_0020).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_error_log = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_ERROR_LOG);
  //
  // Control logic.
  wire        csr_err_l2_to    = min_csr_err_l2_to0 || min_csr_err_l2_to1 || min_csr_err_l2_to2 || min_csr_err_l2_to3;
  wire        csr_err_intr_to  = | (ncio_csr_err_intr_to[31:0]);

  wire log_any_seen =  (|jbi_error_log_read_data[63:0]);

  wire log_fatal_seen =  jbi_error_log[28]	// apar
                       | jbi_error_log[27]	// cpar
                       | jbi_error_log[26]	// adtype
                       | jbi_error_log[25]	// l2_to
                       | jbi_error_log[24];	// arb_to

  wire        set_error_log28 = csr_jbi_error_config_erren & jbi_log_enb[28] & ~log_fatal_seen & min_csr_err_apar;
  wire        set_error_log27 = csr_jbi_error_config_erren & jbi_log_enb[27] & ~log_fatal_seen & mout_csr_err_cpar;
  wire        set_error_log26 = csr_jbi_error_config_erren & jbi_log_enb[26] & ~log_fatal_seen & min_csr_err_adtype;
  wire        set_error_log25 = csr_jbi_error_config_erren & jbi_log_enb[25] & ~log_fatal_seen & csr_err_l2_to;
  wire        set_error_log24 = csr_jbi_error_config_erren & jbi_log_enb[24] & ~log_fatal_seen & mout_csr_err_arb_to;
  wire        set_error_log17 = csr_jbi_error_config_erren & jbi_log_enb[17] & ~log_any_seen   & mout_csr_err_fatal[5] & csr_jbi_config_port_pres[5];
  wire        set_error_log16 = csr_jbi_error_config_erren & jbi_log_enb[16] & ~log_any_seen   & mout_csr_err_fatal[4] & csr_jbi_config_port_pres[4];
  wire        set_error_log15 = csr_jbi_error_config_erren & jbi_log_enb[15] & ~log_any_seen   & min_csr_err_dpar_wr;
  wire        set_error_log14 = csr_jbi_error_config_erren & jbi_log_enb[14] & ~log_any_seen   & min_csr_err_dpar_rd;
  wire        set_error_log13 = csr_jbi_error_config_erren & jbi_log_enb[13] & ~log_any_seen   & min_csr_err_dpar_o;
  wire        set_error_log12 = csr_jbi_error_config_erren & jbi_log_enb[12] & ~log_any_seen   & min_csr_err_rep_ue;
  wire        set_error_log11 = csr_jbi_error_config_erren & jbi_log_enb[11] & ~log_any_seen   & min_csr_err_illegal;
  wire        set_error_log10 = csr_jbi_error_config_erren & jbi_log_enb[10] & ~log_any_seen   & min_csr_err_unsupp;
  wire        set_error_log9  = csr_jbi_error_config_erren & jbi_log_enb[ 9] & ~log_any_seen   & min_csr_err_nonex_wr;
  wire        set_error_log8  = csr_jbi_error_config_erren & jbi_log_enb[ 8] & ~log_any_seen   & min_csr_err_nonex_rd;
  wire        set_error_log5  = csr_jbi_error_config_erren & jbi_log_enb[ 5] & ~log_any_seen   & mout_csr_err_read_to;
  wire        set_error_log4  = csr_jbi_error_config_erren & jbi_log_enb[ 4] & ~log_any_seen   & min_csr_err_unmap_wr;
  wire        set_error_log2  = csr_jbi_error_config_erren & jbi_log_enb[ 2] & ~log_any_seen   & min_csr_err_err_cycle;
  wire        set_error_log1  = csr_jbi_error_config_erren & jbi_log_enb[ 1] & ~log_any_seen   & min_csr_err_unexp_dr;
  wire        set_error_log0  = csr_jbi_error_config_erren & jbi_log_enb[ 0] & ~log_any_seen   & csr_err_intr_to;
  //
  // CSR registers and initial values.
  dffrle_ns #(1) jbi_error_log_reg_28 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[28])), .en(set_error_log28), .q(jbi_error_log[28]), .clk(clk));   // [28] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_27 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[27])), .en(set_error_log27), .q(jbi_error_log[27]), .clk(clk));   // [27] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_26 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[26])), .en(set_error_log26), .q(jbi_error_log[26]), .clk(clk));   // [26] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_25 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[25])), .en(set_error_log25), .q(jbi_error_log[25]), .clk(clk));   // [25] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_24 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[24])), .en(set_error_log24), .q(jbi_error_log[24]), .clk(clk));   // [24] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_17 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[17])), .en(set_error_log17), .q(jbi_error_log[17]), .clk(clk));   // [17] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_16 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[16])), .en(set_error_log16), .q(jbi_error_log[16]), .clk(clk));   // [16] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_15 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[15])), .en(set_error_log15), .q(jbi_error_log[15]), .clk(clk));   // [15] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_14 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[14])), .en(set_error_log14), .q(jbi_error_log[14]), .clk(clk));   // [14] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_13 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[13])), .en(set_error_log13), .q(jbi_error_log[13]), .clk(clk));   // [13] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_12 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[12])), .en(set_error_log12), .q(jbi_error_log[12]), .clk(clk));   // [12] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_11 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[11])), .en(set_error_log11), .q(jbi_error_log[11]), .clk(clk));   // [11] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_10 (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[10])), .en(set_error_log10), .q(jbi_error_log[10]), .clk(clk));   // [10] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_9  (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[ 9])), .en(set_error_log9),  .q(jbi_error_log[ 9]), .clk(clk));   // [ 9] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_8  (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[ 8])), .en(set_error_log8),  .q(jbi_error_log[ 8]), .clk(clk));   // [ 8] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_5  (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[ 5])), .en(set_error_log5),  .q(jbi_error_log[ 5]), .clk(clk));   // [ 5] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_4  (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[ 4])), .en(set_error_log4),  .q(jbi_error_log[ 4]), .clk(clk));   // [ 4] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_2  (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[ 2])), .en(set_error_log2),  .q(jbi_error_log[ 2]), .clk(clk));   // [ 2] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_1  (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[ 1])), .en(set_error_log1),  .q(jbi_error_log[ 1]), .clk(clk));   // [ 1] = Preserved.
  dffrle_ns #(1) jbi_error_log_reg_0  (.din(1'b1), .rst_l(~(write_jbi_error_log & ncio_csr_write_data[ 0])), .en(set_error_log0),  .q(jbi_error_log[ 0]), .clk(clk));   // [ 0] = Preserved.
  //
  // Read port data formation.
  assign jbi_error_log_read_data[63:0] = { 35'd0,
					   jbi_error_log[28:24], 
					   6'd0,
					   jbi_error_log[17: 8], 
				 	   2'd0, 
				 	   jbi_error_log[ 5: 4],
				 	   1'd0, 
					   jbi_error_log[ 2: 0] };



//*******************************************************************************
// CSR - JBI_ERROR_OVF (0x80_0001_0028).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_error_ovf = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_ERROR_OVF);
  //
  // Control logic.
  wire set_error_ovf28 = csr_jbi_error_config_erren & jbi_log_enb[28] & log_fatal_seen & min_csr_err_apar;
  wire set_error_ovf27 = csr_jbi_error_config_erren & jbi_log_enb[27] & log_fatal_seen & mout_csr_err_cpar;
  wire set_error_ovf26 = csr_jbi_error_config_erren & jbi_log_enb[26] & log_fatal_seen & min_csr_err_adtype;
  wire set_error_ovf25 = csr_jbi_error_config_erren & jbi_log_enb[25] & log_fatal_seen & csr_err_l2_to;
  wire set_error_ovf24 = csr_jbi_error_config_erren & jbi_log_enb[24] & log_fatal_seen & mout_csr_err_arb_to;
  wire set_error_ovf17 = csr_jbi_error_config_erren & jbi_log_enb[17] & log_any_seen   & mout_csr_err_fatal[5];
  wire set_error_ovf16 = csr_jbi_error_config_erren & jbi_log_enb[16] & log_any_seen   & mout_csr_err_fatal[4];
  wire set_error_ovf15 = csr_jbi_error_config_erren & jbi_log_enb[15] & log_any_seen   & min_csr_err_dpar_wr;
  wire set_error_ovf14 = csr_jbi_error_config_erren & jbi_log_enb[14] & log_any_seen   & min_csr_err_dpar_rd;
  wire set_error_ovf13 = csr_jbi_error_config_erren & jbi_log_enb[13] & log_any_seen   & min_csr_err_dpar_o;
  wire set_error_ovf12 = csr_jbi_error_config_erren & jbi_log_enb[12] & log_any_seen   & min_csr_err_rep_ue;
  wire set_error_ovf11 = csr_jbi_error_config_erren & jbi_log_enb[11] & log_any_seen   & min_csr_err_illegal;
  wire set_error_ovf10 = csr_jbi_error_config_erren & jbi_log_enb[10] & log_any_seen   & min_csr_err_unsupp;
  wire set_error_ovf9  = csr_jbi_error_config_erren & jbi_log_enb[ 9] & log_any_seen   & min_csr_err_nonex_wr;
  wire set_error_ovf8  = csr_jbi_error_config_erren & jbi_log_enb[ 8] & log_any_seen   & min_csr_err_nonex_rd;
  wire set_error_ovf5  = csr_jbi_error_config_erren & jbi_log_enb[ 5] & log_any_seen   & mout_csr_err_read_to;
  wire set_error_ovf4  = csr_jbi_error_config_erren & jbi_log_enb[ 4] & log_any_seen   & min_csr_err_unmap_wr;
  wire set_error_ovf2  = csr_jbi_error_config_erren & jbi_log_enb[ 2] & log_any_seen   & min_csr_err_err_cycle;
  wire set_error_ovf1  = csr_jbi_error_config_erren & jbi_log_enb[ 1] & log_any_seen   & min_csr_err_unexp_dr;
  wire set_error_ovf0  = csr_jbi_error_config_erren & jbi_log_enb[ 0] & log_any_seen   & csr_err_intr_to;
  //
  // CSR registers and initial values.
  wire [63:0] jbi_error_ovf;
  dffrle_ns #(1) jbi_error_ovf_reg_28 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[28])), .en(set_error_ovf28), .q(jbi_error_ovf[28]), .clk(clk));   // [28] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_27 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[27])), .en(set_error_ovf27), .q(jbi_error_ovf[27]), .clk(clk));   // [27] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_26 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[26])), .en(set_error_ovf26), .q(jbi_error_ovf[26]), .clk(clk));   // [26] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_25 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[25])), .en(set_error_ovf25), .q(jbi_error_ovf[25]), .clk(clk));   // [25] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_24 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[24])), .en(set_error_ovf24), .q(jbi_error_ovf[24]), .clk(clk));   // [24] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_17 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[17])), .en(set_error_ovf17), .q(jbi_error_ovf[17]), .clk(clk));   // [17] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_16 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[16])), .en(set_error_ovf16), .q(jbi_error_ovf[16]), .clk(clk));   // [16] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_15 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[15])), .en(set_error_ovf15), .q(jbi_error_ovf[15]), .clk(clk));   // [15] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_14 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[14])), .en(set_error_ovf14), .q(jbi_error_ovf[14]), .clk(clk));   // [14] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_13 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[13])), .en(set_error_ovf13), .q(jbi_error_ovf[13]), .clk(clk));   // [13] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_12 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[12])), .en(set_error_ovf12), .q(jbi_error_ovf[12]), .clk(clk));   // [12] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_11 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[11])), .en(set_error_ovf11), .q(jbi_error_ovf[11]), .clk(clk));   // [11] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_10 (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[10])), .en(set_error_ovf10), .q(jbi_error_ovf[10]), .clk(clk));   // [10] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_9  (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[ 9])), .en(set_error_ovf9),  .q(jbi_error_ovf[ 9]), .clk(clk));   // [ 9] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_8  (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[ 8])), .en(set_error_ovf8),  .q(jbi_error_ovf[ 8]), .clk(clk));   // [ 8] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_5  (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[ 5])), .en(set_error_ovf5),  .q(jbi_error_ovf[ 5]), .clk(clk));   // [ 5] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_4  (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[ 4])), .en(set_error_ovf4),  .q(jbi_error_ovf[ 4]), .clk(clk));   // [ 4] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_2  (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[ 2])), .en(set_error_ovf2),  .q(jbi_error_ovf[ 2]), .clk(clk));   // [ 2] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_1  (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[ 1])), .en(set_error_ovf1),  .q(jbi_error_ovf[ 1]), .clk(clk));   // [ 1] = Preserved.
  dffrle_ns #(1) jbi_error_ovf_reg_0  (.din(1'b1), .rst_l(~(write_jbi_error_ovf & ncio_csr_write_data[ 0])), .en(set_error_ovf0),  .q(jbi_error_ovf[ 0]), .clk(clk));   // [ 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_error_ovf_read_data = { 35'd0, 
					  jbi_error_ovf[28:24],
					  6'd0,
					  jbi_error_ovf[17: 8], 
					  2'd0, 
					  jbi_error_ovf[ 5: 4], 
					  1'd0, 
					  jbi_error_ovf[ 2: 0] };



//*******************************************************************************
// CSR - JBI_LOG_ENB (0x80_0001_0030).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_log_enb = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_LOG_ENB);
  //
  // CSR registers and initial values.
  // wire [63:0] jbi_log_enb;
  dffe_ns #(1) jbi_log_enb_reg_28 (.din(ncio_csr_write_data[28]), .en(write_jbi_log_enb), .q(jbi_log_enb[28]), .clk(clk));   // [28] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_27 (.din(ncio_csr_write_data[27]), .en(write_jbi_log_enb), .q(jbi_log_enb[27]), .clk(clk));   // [27] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_26 (.din(ncio_csr_write_data[26]), .en(write_jbi_log_enb), .q(jbi_log_enb[26]), .clk(clk));   // [26] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_25 (.din(ncio_csr_write_data[25]), .en(write_jbi_log_enb), .q(jbi_log_enb[25]), .clk(clk));   // [25] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_24 (.din(ncio_csr_write_data[24]), .en(write_jbi_log_enb), .q(jbi_log_enb[24]), .clk(clk));   // [24] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_17 (.din(ncio_csr_write_data[17]), .en(write_jbi_log_enb), .q(jbi_log_enb[17]), .clk(clk));   // [17] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_16 (.din(ncio_csr_write_data[16]), .en(write_jbi_log_enb), .q(jbi_log_enb[16]), .clk(clk));   // [16] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_15 (.din(ncio_csr_write_data[15]), .en(write_jbi_log_enb), .q(jbi_log_enb[15]), .clk(clk));   // [15] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_14 (.din(ncio_csr_write_data[14]), .en(write_jbi_log_enb), .q(jbi_log_enb[14]), .clk(clk));   // [14] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_13 (.din(ncio_csr_write_data[13]), .en(write_jbi_log_enb), .q(jbi_log_enb[13]), .clk(clk));   // [13] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_12 (.din(ncio_csr_write_data[12]), .en(write_jbi_log_enb), .q(jbi_log_enb[12]), .clk(clk));   // [12] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_11 (.din(ncio_csr_write_data[11]), .en(write_jbi_log_enb), .q(jbi_log_enb[11]), .clk(clk));   // [11] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_10 (.din(ncio_csr_write_data[10]), .en(write_jbi_log_enb), .q(jbi_log_enb[10]), .clk(clk));   // [10] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_9  (.din(ncio_csr_write_data[ 9]), .en(write_jbi_log_enb), .q(jbi_log_enb[ 9]), .clk(clk));   // [ 9] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_8  (.din(ncio_csr_write_data[ 8]), .en(write_jbi_log_enb), .q(jbi_log_enb[ 8]), .clk(clk));   // [ 8] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_5  (.din(ncio_csr_write_data[ 5]), .en(write_jbi_log_enb), .q(jbi_log_enb[ 5]), .clk(clk));   // [ 5] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_4  (.din(ncio_csr_write_data[ 4]), .en(write_jbi_log_enb), .q(jbi_log_enb[ 4]), .clk(clk));   // [ 4] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_2  (.din(ncio_csr_write_data[ 2]), .en(write_jbi_log_enb), .q(jbi_log_enb[ 2]), .clk(clk));   // [ 2] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_1  (.din(ncio_csr_write_data[ 1]), .en(write_jbi_log_enb), .q(jbi_log_enb[ 1]), .clk(clk));   // [ 1] = Preserved.
  dffe_ns #(1) jbi_log_enb_reg_0  (.din(ncio_csr_write_data[ 0]), .en(write_jbi_log_enb), .q(jbi_log_enb[ 0]), .clk(clk));   // [ 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_log_enb_read_data = { 35'd0, 
					jbi_log_enb[28:24],
					6'd0,
					jbi_log_enb[17: 8], 
					2'd0, 
					jbi_log_enb[ 5: 4],
					1'd0, 
					jbi_log_enb[ 2: 0] };
  //
  //
  wire csr_jbi_log_enb_apar      = jbi_log_enb[28];
  wire csr_jbi_log_enb_dpar_wr   = jbi_log_enb[15];
  wire csr_jbi_log_enb_dpar_rd   = jbi_log_enb[14];
  wire csr_jbi_log_enb_dpar_o    = jbi_log_enb[13];
  wire csr_jbi_log_enb_rep_ue    = jbi_log_enb[12];
  wire csr_jbi_log_enb_nonex_rd  = jbi_log_enb[ 8];
  wire csr_jbi_log_enb_read_to   = jbi_log_enb[ 5];
  wire csr_jbi_log_enb_err_cycle = jbi_log_enb[ 2];
  wire csr_jbi_log_enb_unexp_dr  = jbi_log_enb[ 1];



//*******************************************************************************
// CSR - JBI_SIG_ENB (0x80_0001_0038).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_sig_enb = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_SIG_ENB);
  //
  // CSR registers and initial values.
  wire [63:0] jbi_sig_enb;
  dffe_ns #(1) jbi_sig_enb_reg_28 (.din(ncio_csr_write_data[28]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[28]), .clk(clk));   // [28] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_27 (.din(ncio_csr_write_data[27]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[27]), .clk(clk));   // [27] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_26 (.din(ncio_csr_write_data[26]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[26]), .clk(clk));   // [26] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_25 (.din(ncio_csr_write_data[25]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[25]), .clk(clk));   // [25] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_24 (.din(ncio_csr_write_data[24]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[24]), .clk(clk));   // [24] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_17 (.din(ncio_csr_write_data[17]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[17]), .clk(clk));   // [17] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_16 (.din(ncio_csr_write_data[16]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[16]), .clk(clk));   // [16] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_15 (.din(ncio_csr_write_data[15]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[15]), .clk(clk));   // [15] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_14 (.din(ncio_csr_write_data[14]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[14]), .clk(clk));   // [14] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_13 (.din(ncio_csr_write_data[13]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[13]), .clk(clk));   // [13] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_12 (.din(ncio_csr_write_data[12]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[12]), .clk(clk));   // [12] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_11 (.din(ncio_csr_write_data[11]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[11]), .clk(clk));   // [11] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_10 (.din(ncio_csr_write_data[10]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[10]), .clk(clk));   // [10] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_9  (.din(ncio_csr_write_data[ 9]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[ 9]), .clk(clk));   // [ 9] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_8  (.din(ncio_csr_write_data[ 8]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[ 8]), .clk(clk));   // [ 8] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_5  (.din(ncio_csr_write_data[ 5]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[ 5]), .clk(clk));   // [ 5] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_4  (.din(ncio_csr_write_data[ 4]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[ 4]), .clk(clk));   // [ 4] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_2  (.din(ncio_csr_write_data[ 2]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[ 2]), .clk(clk));   // [ 2] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_1  (.din(ncio_csr_write_data[ 1]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[ 1]), .clk(clk));   // [ 1] = Preserved.
  dffe_ns #(1) jbi_sig_enb_reg_0  (.din(ncio_csr_write_data[ 0]), .en(write_jbi_sig_enb), .q(jbi_sig_enb[ 0]), .clk(clk));   // [ 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_sig_enb_read_data = { 35'd0, 
					jbi_sig_enb[28:24],
					6'd0,
					jbi_sig_enb[17: 8], 
					2'd0, 
					jbi_sig_enb[ 5: 4],
					1'd0, 
					jbi_sig_enb[ 2: 0] };

  wire next_jbi_clk_tr = csr_jbi_error_config_sigen
                       & (  (jbi_log_enb[28] & min_csr_err_apar)
                          | (jbi_log_enb[27] & mout_csr_err_cpar)
	                  | (jbi_log_enb[26] & min_csr_err_adtype)
	                  | (jbi_log_enb[25] & csr_err_l2_to )
	                  | (jbi_log_enb[24] & mout_csr_err_arb_to)
	                  | (jbi_log_enb[17] & mout_csr_err_fatal[5])
	                  | (jbi_log_enb[16] & mout_csr_err_fatal[4])
	                  | (jbi_log_enb[15] & min_csr_err_dpar_wr)
	                  | (jbi_log_enb[14] & min_csr_err_dpar_rd)
	                  | (jbi_log_enb[13] & min_csr_err_dpar_o)
	                  | (jbi_log_enb[12] & min_csr_err_rep_ue)
	                  | (jbi_log_enb[11] & min_csr_err_illegal)
	                  | (jbi_log_enb[10] & min_csr_err_unsupp)
	                  | (jbi_log_enb[ 9] & min_csr_err_nonex_wr)
	                  | (jbi_log_enb[ 8] & min_csr_err_nonex_rd)
                          | (jbi_log_enb[ 5] & mout_csr_err_read_to)
	                  | (jbi_log_enb[ 4] & min_csr_err_unmap_wr)
	                  | (jbi_log_enb[ 2] & min_csr_err_err_cycle)
	                  | (jbi_log_enb[ 1] & min_csr_err_unexp_dr)
                          | (jbi_log_enb[ 0] & csr_err_intr_to));
  dff_ns jbi_clk_tr_reg (.din(next_jbi_clk_tr), .q(jbi_clk_tr), .clk(clk));

  wire csr_int_req = csr_jbi_error_config_erren
                   & (  (jbi_log_enb[28] & min_csr_err_apar)
                      | (jbi_log_enb[27] & mout_csr_err_cpar)
	              | (jbi_log_enb[26] & min_csr_err_adtype)
	              | (jbi_log_enb[25] & csr_err_l2_to)
	              | (jbi_log_enb[24] & mout_csr_err_arb_to)
                      | (jbi_sig_enb[17] & mout_csr_err_fatal[5])
	              | (jbi_sig_enb[16] & mout_csr_err_fatal[4])
	              | (jbi_sig_enb[15] & min_csr_err_dpar_wr)
	              | (jbi_sig_enb[14] & min_csr_err_dpar_rd)
	              | (jbi_sig_enb[13] & min_csr_err_dpar_o)
	              | (jbi_sig_enb[12] & min_csr_err_rep_ue)
	              | (jbi_sig_enb[11] & min_csr_err_illegal)
	              | (jbi_sig_enb[10] & min_csr_err_unsupp)
	              | (jbi_sig_enb[ 9] & min_csr_err_nonex_wr)
	              | (jbi_sig_enb[ 8] & min_csr_err_nonex_rd)
                      | (jbi_sig_enb[ 5] & mout_csr_err_read_to)
	              | (jbi_sig_enb[ 4] & min_csr_err_unmap_wr)
	              | (jbi_sig_enb[ 2] & min_csr_err_err_cycle)
	              | (jbi_sig_enb[ 1] & min_csr_err_unexp_dr)
                      | (jbi_sig_enb[ 0] & csr_err_intr_to));

  wire next_csr_dok_on = csr_jbi_error_config_erren
                       & (  (jbi_sig_enb[28] & min_csr_err_apar)
                          | (jbi_sig_enb[27] & mout_csr_err_cpar)
	                  | (jbi_sig_enb[26] & min_csr_err_adtype)
	                  | (jbi_sig_enb[25] & csr_err_l2_to)
	                  | (jbi_sig_enb[24] & mout_csr_err_arb_to));
  dff_ns csr_dok_on_reg (.din(next_csr_dok_on), .q(csr_dok_on), .clk(clk));



//*******************************************************************************
// CSR - JBI_LOG_ADDR (0x80_0001_0040).
//*******************************************************************************
  //
  // Write port.
  wire ad_fatal_err =   set_error_log28  // addr parity
                      | set_error_log27  // ctl parity
                      | set_error_log26; // illegal adtype

  wire ad_uncorr_err =   set_error_log15
                       | set_error_log14
                       | set_error_log13
                       | set_error_log12
                       | set_error_log11
                       | set_error_log10
                       | set_error_log9
                       | set_error_log8
                       | set_error_log4
                       | set_error_log2
                       | set_error_log1;

  // Continuousely log until first error seen
  wire write_jbi_log_addr =  min_csr_write_log_addr & ~log_any_seen;
  //
  // CSR registers and initial values.
  wire [63:0] jbi_log_addr;
  dffe_ns #( 3) jbi_log_addr_reg_63_61 (.din(min_csr_log_addr_owner),  .en(write_jbi_log_addr), .q(jbi_log_addr[63:61]), .clk(clk));   // [63:61] = Preserved.
  dffe_ns #( 8) jbi_log_addr_reg_55_48 (.din(min_csr_log_addr_adtype), .en(write_jbi_log_addr), .q(jbi_log_addr[55:48]), .clk(clk));   // [55:48] = Preserved.
  dffe_ns #( 5) jbi_log_addr_reg_47_43 (.din(min_csr_log_addr_ttype),  .en(write_jbi_log_addr), .q(jbi_log_addr[47:43]), .clk(clk));   // [47:43] = Preserved.
  dffe_ns #(43) jbi_log_addr_reg_42_0  (.din(min_csr_log_addr_addr),   .en(write_jbi_log_addr), .q(jbi_log_addr[42: 0]), .clk(clk));   // [42: 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_log_addr_read_data = { jbi_log_addr[63:61], 
					 5'b0, 
					 jbi_log_addr[55: 0] };



//*******************************************************************************
// CSR - JBI_LOG_CTRL (0x80_0001_0048).
//*******************************************************************************
  //
  // Write port.
  // Log first error, and overwrite if uncorrectable followed by addr parity error or illegal adtype
  wire write_jbi_log_ctl =  ad_uncorr_err
                          | (ad_fatal_err & ~log_any_seen)
			  | set_error_log28   // addr parity
			  | set_error_log26;  // illegal adtype
  //
  // CSR registers and initial values.
  wire [63:0] jbi_log_ctrl;
  dffe_ns #(3) jbi_log_ctrl_reg_63_61 (.din(min_csr_log_ctl_owner[2:0]),   .en(write_jbi_log_ctl), .q(jbi_log_ctrl[63:61]), .clk(clk));   // [63:61] = Preserved.
  dffe_ns #(4) jbi_log_ctrl_reg_59_56 (.din(min_csr_log_ctl_parity[3:0]),  .en(write_jbi_log_ctl), .q(jbi_log_ctrl[59:56]), .clk(clk));   // [59:56] = Preserved.
  dffe_ns #(8) jbi_log_ctrl_reg_55_48 (.din(min_csr_log_ctl_adtype0[7:0]), .en(write_jbi_log_ctl), .q(jbi_log_ctrl[55:48]), .clk(clk));   // [55:48] = Preserved.
  dffe_ns #(8) jbi_log_ctrl_reg_47_40 (.din(min_csr_log_ctl_adtype1[7:0]), .en(write_jbi_log_ctl), .q(jbi_log_ctrl[47:40]), .clk(clk));   // [47:40] = Preserved.
  dffe_ns #(8) jbi_log_ctrl_reg_39_32 (.din(min_csr_log_ctl_adtype2[7:0]), .en(write_jbi_log_ctl), .q(jbi_log_ctrl[39:32]), .clk(clk));   // [39:32] = Preserved.
  dffe_ns #(8) jbi_log_ctrl_reg_31_24 (.din(min_csr_log_ctl_adtype3[7:0]), .en(write_jbi_log_ctl), .q(jbi_log_ctrl[31:24]), .clk(clk));   // [31:24] = Preserved.
  dffe_ns #(8) jbi_log_ctrl_reg_23_16 (.din(min_csr_log_ctl_adtype4[7:0]), .en(write_jbi_log_ctl), .q(jbi_log_ctrl[23:16]), .clk(clk));   // [23:16] = Preserved.
  dffe_ns #(8) jbi_log_ctrl_reg_15_8  (.din(min_csr_log_ctl_adtype5[7:0]), .en(write_jbi_log_ctl), .q(jbi_log_ctrl[15: 8]), .clk(clk));   // [15: 8] = Preserved.
  dffe_ns #(8) jbi_log_ctrl_reg_7_0   (.din(min_csr_log_ctl_adtype6[7:0]), .en(write_jbi_log_ctl), .q(jbi_log_ctrl[ 7: 0]), .clk(clk));   // [ 7: 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0]  jbi_log_ctrl_read_data = { jbi_log_ctrl[63:61], 
					  1'b0,
					  jbi_log_ctrl[59: 0] };



//*******************************************************************************
// CSR - JBI_LOG_DATA0 (0x80_0001_0050).
//*******************************************************************************
  //
  // Write port.
  // Log first error, and overwrite if uncorrectable followed by addr parity error
  wire write_jbi_log_data0_addr =  ad_uncorr_err
                                  | (ad_fatal_err & ~log_any_seen)
                                  | set_error_log28;    //addr parity
  //
  // CSR registers and initial values.
  wire [63:0] jbi_log_data0;
  dffe_ns #(64) jbi_log_data0_reg_63_0 (.din(min_csr_log_data0[63:0]), .en(write_jbi_log_data0_addr), .q(jbi_log_data0[63: 0]), .clk(clk));   // [63: 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_log_data0_read_data = { jbi_log_data0[63:0] };



//*******************************************************************************
// CSR - JBI_LOG_DATA1 (0x80_0001_0058).
//*******************************************************************************
  //
  // Write port.
  // Log first error, and overwrite if uncorrectable followed by addr parity error
  wire write_jbi_log_data1_addr =   ad_uncorr_err
                                  | (ad_fatal_err & ~log_any_seen)
                                  | set_error_log28;    //addr parity
  //
  // CSR registers and initial values.
  wire [63:0] jbi_log_data1;
  dffe_ns #(64) jbi_log_data1_reg_63_0 (.din(min_csr_log_data1[63:0]), .en(write_jbi_log_data1_addr), .q(jbi_log_data1[63: 0]), .clk(clk));   // [63: 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_log_data1_read_data = { jbi_log_data1[63:0] };



//*******************************************************************************
// CSR - JBI_LOG_PAR (0x80_0001_0060).
//*******************************************************************************
  //
  // Write port.
  // Log first error, and overwrite if uncorrectable followed by control parity error
  wire jbi_log_par_reg_wr =  ad_uncorr_err
                           | (ad_fatal_err & ~log_any_seen)
                           | set_error_log27;
  //
  // CSR registers and initial values.
  wire [63:0] jbi_log_par;
//  wire jbi_log_par_reg_wr = mout_csr_err_cpar && (csr_jbi_error_config_erren && jbi_log_enb[27] && !jbi_error_log[27] && !jbi_error_ovf[27]);
  dffe_ns #(1) jbi_log_par_reg_63_61 (.din(mout_csr_jbi_log_par_jpar),        .en(jbi_log_par_reg_wr), .q(jbi_log_par[   32]), .clk(clk));   // [   32] = Preserved.
  dffe_ns #(3) jbi_log_par_reg_59_56 (.din(mout_csr_jbi_log_par_jpack5[2:0]), .en(jbi_log_par_reg_wr), .q(jbi_log_par[25:23]), .clk(clk));   // [25:23] = Preserved.
  dffe_ns #(3) jbi_log_par_reg_55_48 (.din(mout_csr_jbi_log_par_jpack4[2:0]), .en(jbi_log_par_reg_wr), .q(jbi_log_par[22:20]), .clk(clk));   // [22:20] = Preserved.
  dffe_ns #(3) jbi_log_par_reg_47_40 (.din(mout_csr_jbi_log_par_jpack1[2:0]), .en(jbi_log_par_reg_wr), .q(jbi_log_par[13:11]), .clk(clk));   // [13:11] = Preserved.
  dffe_ns #(3) jbi_log_par_reg_39_32 (.din(mout_csr_jbi_log_par_jpack0[2:0]), .en(jbi_log_par_reg_wr), .q(jbi_log_par[10: 8]), .clk(clk));   // [10: 8] = Preserved.
  dffe_ns #(7) jbi_log_par_reg_6_0   (.din(mout_csr_jbi_log_par_jreq[6:0]),   .en(jbi_log_par_reg_wr), .q(jbi_log_par[ 6: 0]), .clk(clk));   // [ 6: 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_log_par_read_data = { 31'd0, jbi_log_par[32], 6'd0, jbi_log_par[25:20], 6'd0, jbi_log_par[13:8], 1'd0, jbi_log_par[6:0] };
  //
  // Control logic.
  // <none>



//*******************************************************************************
// CSR - JBI_LOG_NACK (0x80_0001_0070).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_log_nack = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_LOG_NACK);

  wire log_nack_enb = csr_jbi_error_config_erren & jbi_log_enb[0];

  wire set_log_nack_reg31 = log_nack_enb & ncio_csr_err_intr_to[31];
  wire set_log_nack_reg30 = log_nack_enb & ncio_csr_err_intr_to[30];
  wire set_log_nack_reg29 = log_nack_enb & ncio_csr_err_intr_to[29];
  wire set_log_nack_reg28 = log_nack_enb & ncio_csr_err_intr_to[28];
  wire set_log_nack_reg27 = log_nack_enb & ncio_csr_err_intr_to[27];
  wire set_log_nack_reg26 = log_nack_enb & ncio_csr_err_intr_to[26];
  wire set_log_nack_reg25 = log_nack_enb & ncio_csr_err_intr_to[25];
  wire set_log_nack_reg24 = log_nack_enb & ncio_csr_err_intr_to[24];
  wire set_log_nack_reg23 = log_nack_enb & ncio_csr_err_intr_to[23];
  wire set_log_nack_reg22 = log_nack_enb & ncio_csr_err_intr_to[22];
  wire set_log_nack_reg21 = log_nack_enb & ncio_csr_err_intr_to[21];
  wire set_log_nack_reg20 = log_nack_enb & ncio_csr_err_intr_to[20];
  wire set_log_nack_reg19 = log_nack_enb & ncio_csr_err_intr_to[19];
  wire set_log_nack_reg18 = log_nack_enb & ncio_csr_err_intr_to[18];
  wire set_log_nack_reg17 = log_nack_enb & ncio_csr_err_intr_to[17];
  wire set_log_nack_reg16 = log_nack_enb & ncio_csr_err_intr_to[16];
  wire set_log_nack_reg15 = log_nack_enb & ncio_csr_err_intr_to[15];
  wire set_log_nack_reg14 = log_nack_enb & ncio_csr_err_intr_to[14];
  wire set_log_nack_reg13 = log_nack_enb & ncio_csr_err_intr_to[13];
  wire set_log_nack_reg12 = log_nack_enb & ncio_csr_err_intr_to[12];
  wire set_log_nack_reg11 = log_nack_enb & ncio_csr_err_intr_to[11];
  wire set_log_nack_reg10 = log_nack_enb & ncio_csr_err_intr_to[10];
  wire set_log_nack_reg9  = log_nack_enb & ncio_csr_err_intr_to[ 9];
  wire set_log_nack_reg8  = log_nack_enb & ncio_csr_err_intr_to[ 8];
  wire set_log_nack_reg7  = log_nack_enb & ncio_csr_err_intr_to[ 7];
  wire set_log_nack_reg6  = log_nack_enb & ncio_csr_err_intr_to[ 6];
  wire set_log_nack_reg5  = log_nack_enb & ncio_csr_err_intr_to[ 5];
  wire set_log_nack_reg4  = log_nack_enb & ncio_csr_err_intr_to[ 4];
  wire set_log_nack_reg3  = log_nack_enb & ncio_csr_err_intr_to[ 3];
  wire set_log_nack_reg2  = log_nack_enb & ncio_csr_err_intr_to[ 2];
  wire set_log_nack_reg1  = log_nack_enb & ncio_csr_err_intr_to[ 1];
  wire set_log_nack_reg0  = log_nack_enb & ncio_csr_err_intr_to[ 0];

  // CSR registers and initial values.
  wire [63:0] jbi_log_nack;
  dffrle_ns #(1) jbi_log_nack_reg_31 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[31])), .en(set_log_nack_reg31), .q(jbi_log_nack[31]), .clk(clk));   // [   31] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_30 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[30])), .en(set_log_nack_reg30), .q(jbi_log_nack[30]), .clk(clk));   // [   30] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_29 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[29])), .en(set_log_nack_reg29), .q(jbi_log_nack[29]), .clk(clk));   // [   29] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_28 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[28])), .en(set_log_nack_reg28), .q(jbi_log_nack[28]), .clk(clk));   // [   28] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_27 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[27])), .en(set_log_nack_reg27), .q(jbi_log_nack[27]), .clk(clk));   // [   27] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_26 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[26])), .en(set_log_nack_reg26), .q(jbi_log_nack[26]), .clk(clk));   // [   26] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_25 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[25])), .en(set_log_nack_reg25), .q(jbi_log_nack[25]), .clk(clk));   // [   25] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_24 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[24])), .en(set_log_nack_reg24), .q(jbi_log_nack[24]), .clk(clk));   // [   24] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_23 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[23])), .en(set_log_nack_reg23), .q(jbi_log_nack[23]), .clk(clk));   // [   23] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_22 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[22])), .en(set_log_nack_reg22), .q(jbi_log_nack[22]), .clk(clk));   // [   22] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_21 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[21])), .en(set_log_nack_reg21), .q(jbi_log_nack[21]), .clk(clk));   // [   21] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_20 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[20])), .en(set_log_nack_reg20), .q(jbi_log_nack[20]), .clk(clk));   // [   20] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_19 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[19])), .en(set_log_nack_reg19), .q(jbi_log_nack[19]), .clk(clk));   // [   19] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_18 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[18])), .en(set_log_nack_reg18), .q(jbi_log_nack[18]), .clk(clk));   // [   18] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_17 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[17])), .en(set_log_nack_reg17), .q(jbi_log_nack[17]), .clk(clk));   // [   17] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_16 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[16])), .en(set_log_nack_reg16), .q(jbi_log_nack[16]), .clk(clk));   // [   16] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_15 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[15])), .en(set_log_nack_reg15), .q(jbi_log_nack[15]), .clk(clk));   // [   15] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_14 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[14])), .en(set_log_nack_reg14), .q(jbi_log_nack[14]), .clk(clk));   // [   14] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_13 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[13])), .en(set_log_nack_reg13), .q(jbi_log_nack[13]), .clk(clk));   // [   13] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_12 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[12])), .en(set_log_nack_reg12), .q(jbi_log_nack[12]), .clk(clk));   // [   12] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_11 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[11])), .en(set_log_nack_reg11), .q(jbi_log_nack[11]), .clk(clk));   // [   11] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_10 (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[10])), .en(set_log_nack_reg10), .q(jbi_log_nack[10]), .clk(clk));   // [   10] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_9  (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[ 9])), .en(set_log_nack_reg9),  .q(jbi_log_nack[ 9]), .clk(clk));   // [    9] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_8  (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[ 8])), .en(set_log_nack_reg8),  .q(jbi_log_nack[ 8]), .clk(clk));   // [    8] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_7  (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[ 7])), .en(set_log_nack_reg7),  .q(jbi_log_nack[ 7]), .clk(clk));   // [    7] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_6  (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[ 6])), .en(set_log_nack_reg6),  .q(jbi_log_nack[ 6]), .clk(clk));   // [    6] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_5  (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[ 5])), .en(set_log_nack_reg5),  .q(jbi_log_nack[ 5]), .clk(clk));   // [    5] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_4  (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[ 4])), .en(set_log_nack_reg4),  .q(jbi_log_nack[ 4]), .clk(clk));   // [    4] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_3  (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[ 3])), .en(set_log_nack_reg3),  .q(jbi_log_nack[ 3]), .clk(clk));   // [    3] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_2  (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[ 2])), .en(set_log_nack_reg2),  .q(jbi_log_nack[ 2]), .clk(clk));   // [    2] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_1  (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[ 1])), .en(set_log_nack_reg1),  .q(jbi_log_nack[ 1]), .clk(clk));   // [    1] = Preserved.
  dffrle_ns #(1) jbi_log_nack_reg_0  (.din(1'b1), .rst_l(~(write_jbi_log_nack&ncio_csr_write_data[ 0])), .en(set_log_nack_reg0),  .q(jbi_log_nack[ 0]), .clk(clk));   // [    0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_log_nack_read_data = { 32'b0, jbi_log_nack[31:0] };
  //
  // Control logic.



//*******************************************************************************
// CSR - JBI_LOG_ARB (0x80_0001_0078).
//*******************************************************************************
  //
  // Write port.
  // <none>
  //
  // CSR registers and initial values.
  wire [63:0] jbi_log_arb;
  wire jbi_log_arb_reg_wr = mout_csr_err_arb_to && (csr_jbi_error_config_erren && jbi_log_enb[24] && !jbi_error_log[24] && !jbi_error_ovf[24]);
  dffe_ns #(3) jbi_log_arb_reg_34_32 (.din(jbi_log_arb_myreq[2:0]),   .en(jbi_log_arb_reg_wr), .q(jbi_log_arb[34:32]), .clk(clk));   // [34:32] = Preserved.
  dffe_ns #(3) jbi_log_arb_reg_26_24 (.din(jbi_log_arb_reqtype[2:0]), .en(jbi_log_arb_reg_wr), .q(jbi_log_arb[26:24]), .clk(clk));   // [26:24] = Preserved.
  dffe_ns #(7) jbi_log_arb_reg_22_16 (.din(jbi_log_arb_aok[6:0]),     .en(jbi_log_arb_reg_wr), .q(jbi_log_arb[22:16]), .clk(clk));   // [22:16] = Preserved.
  dffe_ns #(7) jbi_log_arb_reg_14_8  (.din(jbi_log_arb_dok[6:0]),     .en(jbi_log_arb_reg_wr), .q(jbi_log_arb[14: 8]), .clk(clk));   // [14: 8] = Preserved.
  dffe_ns #(7) jbi_log_arb_reg_6_0   (.din(jbi_log_arb_jreq[6:0]),    .en(jbi_log_arb_reg_wr), .q(jbi_log_arb[ 6: 0]), .clk(clk));   // [ 6: 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_log_arb_read_data = { 29'b0, jbi_log_arb[34:32], 5'b0, jbi_log_arb[26:24], 1'b0, jbi_log_arb[22:16], 1'b0, jbi_log_arb[14: 8], 1'b0, jbi_log_arb[ 6: 0] };
  //
  // Control logic.



//*******************************************************************************
// CSR - JBI_L2_TIMEOUT (0x80_0001_0080).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_l2_timeout = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_L2_TIMEOUT);
  //
  // CSR registers and initial values.
  wire [63:0] jbi_l2_timeout;
  dffe_ns #(32) jbi_l2_timeout_reg_31_0 (.din(ncio_csr_write_data[31: 0]), .en(write_jbi_l2_timeout), .q(jbi_l2_timeout[31: 0]), .clk(clk));   // [31: 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_l2_timeout_read_data = { 32'b0, jbi_l2_timeout[31:0] };
  //
  // Control logic.
  assign csr_jbi_l2_timeout_timeval[31:0] = jbi_l2_timeout[31:0];



//*******************************************************************************
// CSR - JBI_ARB_TIMEOUT (0x80_0001_0088).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_arb_timeout = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_ARB_TIMEOUT);
  //
  // CSR registers and initial values.
  wire [63:0] jbi_arb_timeout;
  dffe_ns #(32) jbi_arb_timeout_reg_31_0 (.din(ncio_csr_write_data[31: 0]), .en(write_jbi_arb_timeout), .q(jbi_arb_timeout[31: 0]), .clk(clk));   // [31: 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_arb_timeout_read_data = { 32'b0, jbi_arb_timeout[31:0] };
  //
  // Control logic.
  assign csr_jbi_arb_timeout_timeval[31:0] = jbi_arb_timeout[31:0];



//*******************************************************************************
// CSR - JBI_TRANS_TIMEOUT (0x80_0001_0090).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_trans_timeout = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_TRANS_TIMEOUT);
  //
  // CSR registers and initial values.
  wire [63:0] jbi_trans_timeout;
  dffe_ns #(32) jbi_trans_timeout_reg_31_0 (.din(ncio_csr_write_data[31: 0]), .en(write_jbi_trans_timeout), .q(jbi_trans_timeout[31: 0]), .clk(clk));   // [31: 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_trans_timeout_read_data = { 32'b0, jbi_trans_timeout[31:0] };
  //
  // Control logic.
  assign csr_jbi_trans_timeout_timeval[31:0] = jbi_trans_timeout[31:0];



//*******************************************************************************
// CSR - JBI_INTR_TIMEOUT (0x80_0001_0098).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_intr_timeout = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_INTR_TIMEOUT);
  //
  // CSR registers and initial values.
  wire [63:0] jbi_intr_timeout;
  dffe_ns #(32) jbi_intr_timeout_reg_31_0 (.din(ncio_csr_write_data[31: 0]), .en(write_jbi_intr_timeout), .q(jbi_intr_timeout[31: 0]), .clk(clk));   // [31: 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_intr_timeout_read_data = { 32'b0, jbi_intr_timeout[31:0] };
  //
  // Control logic.
  assign csr_jbi_intr_timeout_timeval[31:0] = jbi_intr_timeout[31:0];
  assign csr_jbi_intr_timeout_rst_l         = ~write_jbi_intr_timeout;



//*******************************************************************************
// CSR - JBI_MEMSIZE (0x80_0001_00A0).
//*******************************************************************************
  //
  // Write port.
  wire write_jbi_memsize = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_MEMSIZE);
  //
  // CSR registers and initial values.
  wire [63:0] jbi_memsize;
  dffe_ns #(8) jbi_memsize_reg_37_30 (.din(ncio_csr_write_data[37:30]), .en(write_jbi_memsize), .q(jbi_memsize[37:30]), .clk(clk));   // [37:30] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_memsize_read_data = { 26'b0, jbi_memsize[37:30], 30'b0 };
  //
  // Control logic.
  assign csr_jbi_memsize_size[37:30] = jbi_memsize[37:30];


//*******************************************************************************
// CSR - JBI_PERF_CTL (0x80_0002_0000).
//*******************************************************************************
  //
  // Write port.
  wire 	 write_jbi_perf_ctl = ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_PERF_CTL);
  //
  // CSR registers and initial values.
  wire [7:0] jbi_perf_ctl;
  dffe_ns #(4) jbi_perf_ctl_reg_7_4 (.din(ncio_csr_write_data[7:4]), .en(write_jbi_perf_ctl), .q(jbi_perf_ctl[7:4]), .clk(clk));   // [7:4] = Preserved.
  dffe_ns #(4) jbi_perf_ctl_reg_3_0 (.din(ncio_csr_write_data[3:0]), .en(write_jbi_perf_ctl), .q(jbi_perf_ctl[3:0]), .clk(clk));   // [3:0] = Preserved.
  //
  // Read port data formation.
  wire [63:0] jbi_perf_ctl_read_data = { 56'd0, jbi_perf_ctl[7:0] };
  //
  // Control Logic
  wire [3:0]  jbi_perf_event_sel1 = jbi_perf_ctl[7:4];
  wire [3:0]  jbi_perf_event_sel0 = jbi_perf_ctl[3:0];



//*******************************************************************************
// CSR - JBI_PERF_COUNT (0x80_0002_0000).
//*******************************************************************************
  //
  // Write port.
  reg incr_perf_count1;
  reg incr_perf_count0;
  wire write_jbi_perf_count =   ncio_csr_write && (ncio_csr_write_addr == `JBI_CSR_ADDR_PERF_COUNT);
  wire write_jbi_perf_count_sticky1 = write_jbi_perf_count | incr_perf_count1;
  wire write_jbi_perf_count1        = write_jbi_perf_count | incr_perf_count1;
  wire write_jbi_perf_count_sticky0 = write_jbi_perf_count | incr_perf_count0;
  wire write_jbi_perf_count0        = write_jbi_perf_count | incr_perf_count0;
  //
  // CSR registers and initial values.
  wire jbi_perf_count_sticky1;
  wire [30:0] jbi_perf_count1;
  wire 	    jbi_perf_count_sticky0;
  wire [30:0] jbi_perf_count0;
  reg 	    next_jbi_perf_count_sticky1;
  reg [30:0]  next_jbi_perf_count1;
  reg 	    next_jbi_perf_count_sticky0;
  reg [30:0]  next_jbi_perf_count0;

  dffe_ns #(1)  jbi_perf_count_reg_63    (.din(next_jbi_perf_count_sticky1), .en(write_jbi_perf_count_sticky1), .q(jbi_perf_count_sticky1), .clk(clk));   // [   63] = Preserved.
  dffe_ns #(31) jbi_perf_count_reg_62_32 (.din(next_jbi_perf_count1),        .en(write_jbi_perf_count1),        .q(jbi_perf_count1),        .clk(clk));   // [62:32] = Preserved.
  dffe_ns #(1)  jbi_perf_count_reg_31    (.din(next_jbi_perf_count_sticky0), .en(write_jbi_perf_count_sticky0), .q(jbi_perf_count_sticky0), .clk(clk));   // [   31] = Preserved.
  dffe_ns #(31) jbi_perf_count_reg_30_0  (.din(next_jbi_perf_count0),        .en(write_jbi_perf_count0),        .q(jbi_perf_count0),        .clk(clk));   // [30: 0] = Preserved.
  //
  // Read port data formation.
  wire [63:0]  jbi_perf_count_read_data = { jbi_perf_count_sticky1, 
					  jbi_perf_count1, 
					  jbi_perf_count_sticky0, 
					  jbi_perf_count0 };
//---------------
// Control Logic
//---------------

// Performance Counter Select Encodings
always @ ( /*AUTOSENSE*/jbi_perf_event_sel1 or min_csr_perf_dma_rd_in
	  or min_csr_perf_dma_wr or min_csr_perf_dma_wr8
	  or mout_perf_aok_off or mout_perf_dok_off
	  or ncio_csr_perf_pio_rd_out or ncio_csr_perf_pio_wr) begin
   case(jbi_perf_event_sel1)
      4'h1: incr_perf_count1 = 1'b1;					// JBus cycles
      4'h2: incr_perf_count1 = min_csr_perf_dma_rd_in;			// dma read transactions (inbound)
      4'h3: incr_perf_count1 = 1'b1;					// total dma read latency
      4'h4: incr_perf_count1 = min_csr_perf_dma_wr;    			// dma write transactions 
      4'h5: incr_perf_count1 = min_csr_perf_dma_wr8;   			// dma wr8 subtransactions
      4'h6: incr_perf_count1 = 1'b1;                   			// ordering waits = # of jbi->l2 queues blocked each cycle
      4'h8: incr_perf_count1 = ncio_csr_perf_pio_rd_out;  		// pio read transactions
      4'h9: incr_perf_count1 = 1'b1;                      		// total pio read latency
      4'ha: incr_perf_count1 = ncio_csr_perf_pio_wr;      		// pio write transactions
      4'hc: incr_perf_count1 = mout_perf_aok_off || mout_perf_dok_off;	// aok_off or dok_off seen
      4'hd: incr_perf_count1 = mout_perf_aok_off;			// aok_off seen
      4'he: incr_perf_count1 = mout_perf_dok_off;			// dok_off seen
      default: incr_perf_count1 = 1'b0;
   endcase
end

always @ ( /*AUTOSENSE*/jbi_perf_event_sel0 or min_csr_perf_dma_rd_in
	  or min_csr_perf_dma_wr or min_csr_perf_dma_wr8
	  or mout_perf_aok_off or mout_perf_dok_off
	  or ncio_csr_perf_pio_rd_out or ncio_csr_perf_pio_wr) begin
   case(jbi_perf_event_sel0)
      4'h1: incr_perf_count0 = 1'b1;					// JBus cycles
      4'h2: incr_perf_count0 = min_csr_perf_dma_rd_in;    		// dma read transactions (inbound)
      4'h3: incr_perf_count0 = 1'b1;                      		// total dma read latency
      4'h4: incr_perf_count0 = min_csr_perf_dma_wr;       		// dma write transactions 
      4'h5: incr_perf_count0 = min_csr_perf_dma_wr8;      		// dma wr8 subtransactions
      4'h6: incr_perf_count0 = 1'b1;                      		// ordering waits = # of jbi->l2 queues blocked each cycle
      4'h8: incr_perf_count0 = ncio_csr_perf_pio_rd_out;  		// pio read transactions
      4'h9: incr_perf_count0 = 1'b1;                      		// total pio read latency
      4'ha: incr_perf_count0 = ncio_csr_perf_pio_wr;      		// pio write transactions
      4'hc: incr_perf_count0 = mout_perf_aok_off || mout_perf_dok_off;	// aok_off or dok_off seen
      4'hd: incr_perf_count0 = mout_perf_aok_off;			// aok_off seen
      4'he: incr_perf_count0 = mout_perf_dok_off;			// dok_off seen
      default: incr_perf_count0 = 1'b0;
   endcase
end


// Sum up ordering waits
//wire [5:0] csr_perf_blk_q =  {2'd0, min_csr_perf_blk_q0[3:0]}
//			   + {2'd0, min_csr_perf_blk_q1[3:0]}
//			   + {2'd0, min_csr_perf_blk_q2[3:0]}
//			   + {2'd0, min_csr_perf_blk_q3[3:0]};

wire [3:0] csr_perf_blk_q_s00, csr_perf_blk_q_s01;
wire 	   csr_perf_blk_q_co00, csr_perf_blk_q_co01;
wire [4:0] csr_perf_blk_q_s1;
wire 	   csr_perf_blk_q_co1;

jbi_adder_4b u_add_csr_perf_blk_q_00
   (.oper1(min_csr_perf_blk_q0[3:0]),
    .oper2(min_csr_perf_blk_q1[3:0]),
    .cin(1'b0),
    .sum(csr_perf_blk_q_s00[3:0]),
    .cout(csr_perf_blk_q_co00)
    );

jbi_adder_4b u_add_csr_perf_blk_q_01
   (.oper1(min_csr_perf_blk_q2[3:0]),
    .oper2(min_csr_perf_blk_q3[3:0]),
    .cin(1'b0),
    .sum(csr_perf_blk_q_s01[3:0]),
    .cout(csr_perf_blk_q_co01)
    );

jbi_adder_5b u_add_csr_perf_blk_q_1
   (.oper1({csr_perf_blk_q_co00, csr_perf_blk_q_s00[3:0]}),
    .oper2({csr_perf_blk_q_co01, csr_perf_blk_q_s01[3:0]}),
    .cin(1'b0),
    .sum(csr_perf_blk_q_s1),
    .cout(csr_perf_blk_q_co1)
    );

wire [5:0] csr_perf_blk_q = {csr_perf_blk_q_co1, csr_perf_blk_q_s1[4:0]};

// increment performance counters
always @ ( /*AUTOSENSE*/jbi_perf_count1 or jbi_perf_count_sticky1
	  or ncio_csr_write_data or write_jbi_perf_count) begin
   if (write_jbi_perf_count)
      next_jbi_perf_count_sticky1 = ncio_csr_write_data[63];
   else
      next_jbi_perf_count_sticky1 = jbi_perf_count_sticky1
				    | (&jbi_perf_count1);
end

always @ ( /*AUTOSENSE*/csr_perf_blk_q or jbi_perf_count1
	  or jbi_perf_event_sel1 or min_csr_perf_dma_rd_latency
	  or ncio_csr_perf_pio_rd_latency or ncio_csr_write_data
	  or write_jbi_perf_count) begin
   if (write_jbi_perf_count)
      next_jbi_perf_count1 = ncio_csr_write_data[62:32];
   else begin
      case (jbi_perf_event_sel1)
	 4'h3: next_jbi_perf_count1 = jbi_perf_count1 + {26'd0, min_csr_perf_dma_rd_latency[4:0]};  // total dma read latency
	 4'h6: next_jbi_perf_count1 = jbi_perf_count1 + {25'd0, csr_perf_blk_q[5:0]};               // ordering waits = # of jbi->l2 queues blocked each cycle
	 4'h9: next_jbi_perf_count1 = jbi_perf_count1 + {26'd0, ncio_csr_perf_pio_rd_latency[4:0]}; // total pio read latency
	 default: next_jbi_perf_count1 = jbi_perf_count1 + 1'b1;
      endcase
   end
end

always @ ( /*AUTOSENSE*/jbi_perf_count0 or jbi_perf_count_sticky0
	  or ncio_csr_write_data or write_jbi_perf_count) begin
   if (write_jbi_perf_count)
      next_jbi_perf_count_sticky0 = ncio_csr_write_data[31];
   else
      next_jbi_perf_count_sticky0 = jbi_perf_count_sticky0
				    | (&jbi_perf_count0);
end

always @ ( /*AUTOSENSE*/csr_perf_blk_q or jbi_perf_count0
	  or jbi_perf_event_sel0 or min_csr_perf_dma_rd_latency
	  or ncio_csr_perf_pio_rd_latency or ncio_csr_write_data
	  or write_jbi_perf_count) begin
   if (write_jbi_perf_count)
      next_jbi_perf_count0 = ncio_csr_write_data[30:0];
   else begin
      case (jbi_perf_event_sel0)
	 4'h3: next_jbi_perf_count0 = jbi_perf_count0 + {26'd0, min_csr_perf_dma_rd_latency[4:0]};  // total dma read latency
	 4'h6: next_jbi_perf_count0 = jbi_perf_count0 + {25'd0, csr_perf_blk_q[5:0]};               // ordering waits = # of jbi->l2 queues blocked each cycle
	 4'h9: next_jbi_perf_count0 = jbi_perf_count0 + {26'd0, ncio_csr_perf_pio_rd_latency[4:0]}; // total pio read latency
	 default: next_jbi_perf_count0 = jbi_perf_count0 + 1'b1;
      endcase
   end
end


//*******************************************************************************
// CSR Read port mux.
//*******************************************************************************

reg [63:0] csr_csr_read_data;
  always @(/*AUTOSENSE*/jbi_arb_timeout_read_data
	   or jbi_config2_read_data or jbi_config_read_data
	   or jbi_debug_arb_read_data or jbi_debug_read_data
	   or jbi_err_inject_read_data or jbi_error_config_read_data
	   or jbi_error_log_read_data or jbi_error_ovf_read_data
	   or jbi_int_mrgn_read_data or jbi_intr_timeout_read_data
	   or jbi_l2_timeout_read_data or jbi_log_addr_read_data
	   or jbi_log_arb_read_data or jbi_log_ctrl_read_data
	   or jbi_log_data0_read_data or jbi_log_data1_read_data
	   or jbi_log_enb_read_data or jbi_log_nack_read_data
	   or jbi_log_par_read_data or jbi_memsize_read_data
	   or jbi_perf_count_read_data or jbi_perf_ctl_read_data
	   or jbi_sig_enb_read_data or jbi_trans_timeout_read_data
	   or ncio_csr_read_addr) begin
    case (ncio_csr_read_addr)
      `JBI_CSR_ADDR_CONFIG:         csr_csr_read_data[63:0] = jbi_config_read_data[63:0];
      `JBI_CSR_ADDR_CONFIG2:        csr_csr_read_data[63:0] = jbi_config2_read_data[63:0];
      `JBI_CSR_ADDR_INT_MRGN:       csr_csr_read_data[63:0] = jbi_int_mrgn_read_data[63:0];
      `JBI_CSR_ADDR_DEBUG:          csr_csr_read_data[63:0] = jbi_debug_read_data[63:0];
      `JBI_CSR_ADDR_DEBUG_ARB:      csr_csr_read_data[63:0] = jbi_debug_arb_read_data[63:0];
      `JBI_CSR_ADDR_ERR_INJECT:     csr_csr_read_data[63:0] = jbi_err_inject_read_data[63:0];
      `JBI_CSR_ADDR_ERROR_CONFIG:   csr_csr_read_data[63:0] = jbi_error_config_read_data[63:0];
      `JBI_CSR_ADDR_ERROR_LOG:      csr_csr_read_data[63:0] = jbi_error_log_read_data[63:0];
      `JBI_CSR_ADDR_ERROR_OVF:      csr_csr_read_data[63:0] = jbi_error_ovf_read_data[63:0];
      `JBI_CSR_ADDR_LOG_ENB:        csr_csr_read_data[63:0] = jbi_log_enb_read_data[63:0];
      `JBI_CSR_ADDR_SIG_ENB:        csr_csr_read_data[63:0] = jbi_sig_enb_read_data[63:0];
      `JBI_CSR_ADDR_LOG_ADDR:       csr_csr_read_data[63:0] = jbi_log_addr_read_data[63:0];
      `JBI_CSR_ADDR_LOG_CTRL:       csr_csr_read_data[63:0] = jbi_log_ctrl_read_data[63:0];
      `JBI_CSR_ADDR_LOG_DATA0:      csr_csr_read_data[63:0] = jbi_log_data0_read_data[63:0];
      `JBI_CSR_ADDR_LOG_DATA1:      csr_csr_read_data[63:0] = jbi_log_data1_read_data[63:0];
      `JBI_CSR_ADDR_LOG_PAR:        csr_csr_read_data[63:0] = jbi_log_par_read_data[63:0];
      `JBI_CSR_ADDR_LOG_NACK:       csr_csr_read_data[63:0] = jbi_log_nack_read_data[63:0];
      `JBI_CSR_ADDR_LOG_ARB:        csr_csr_read_data[63:0] = jbi_log_arb_read_data[63:0];
      `JBI_CSR_ADDR_L2_TIMEOUT:     csr_csr_read_data[63:0] = jbi_l2_timeout_read_data[63:0];
      `JBI_CSR_ADDR_ARB_TIMEOUT:    csr_csr_read_data[63:0] = jbi_arb_timeout_read_data[63:0];
      `JBI_CSR_ADDR_TRANS_TIMEOUT:  csr_csr_read_data[63:0] = jbi_trans_timeout_read_data[63:0];
      `JBI_CSR_ADDR_INTR_TIMEOUT:   csr_csr_read_data[63:0] = jbi_intr_timeout_read_data[63:0];
      `JBI_CSR_ADDR_MEMSIZE:        csr_csr_read_data[63:0] = jbi_memsize_read_data[63:0];
      `JBI_CSR_ADDR_PERF_CTL:       csr_csr_read_data[63:0] = jbi_perf_ctl_read_data[63:0];
      `JBI_CSR_ADDR_PERF_COUNT:     csr_csr_read_data[63:0] = jbi_perf_count_read_data[63:0];
      default: begin                csr_csr_read_data[63:0] = {64{1'b0}};
         end
      endcase
  end

  endmodule


// Local Variables:
// verilog-library-directories:("." "../../include" "../../../common/rtl")
// verilog-auto-sense-defines-constant:t
// End:
