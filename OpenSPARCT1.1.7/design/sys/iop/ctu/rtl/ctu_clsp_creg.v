// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: ctu_clsp_creg.v
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
//
//    Cluster Name:  CTU
//    Unit Name: ctu_clsp_creg
//
//-----------------------------------------------------------------------------
`include "sys.h"
`include "ctu.h"

// Clock Unit Register Addresses (0x96_0000_00xx)
//      00   CLK_DIV
//      08   CLK_CTL
//      10   CLK_DBG_INT
//      18   CLK_DLL_CTRL
//      28   CLK_JSYNC
//      30   CLK_DSYNC
//      38   CLK_DLL_BYPASS
//      40   CLK_VERSION


module ctu_clsp_creg (/*AUTOARG*/
// Outputs
reg_cdiv_0, reg_ddiv_0, reg_jdiv_0, reg_cdiv_vec, reg_ddiv_vec, 
reg_jdiv_vec, stretch_cnt_vec, clk_stretch_cnt_val_6, 
clk_stretch_cnt_val_odd, reg_div_cmult, reg_div_dmult, reg_div_jmult, 
dsync_reg_init, dsync_reg_period, dsync_reg_rx0, dsync_reg_rx1, 
dsync_reg_rx2, dsync_reg_tx0, dsync_reg_tx1, dsync_reg_tx2, 
jsync_reg_init, jsync_reg_period, jsync_reg_rx0, jsync_reg_rx1, 
jsync_reg_rx2, jsync_reg_tx0, jsync_reg_tx1, jsync_reg_tx2, 
ctu_spc_const_maskid, frq_chng_pending_jl, ctu_ddr0_dll_delayctr_jl, 
ctu_ddr1_dll_delayctr_jl, ctu_ddr2_dll_delayctr_jl, 
ctu_ddr3_dll_delayctr_jl, de_dbginit_jl, a_dbginit_jl, 
clsp_ucb_rd_ack_vld, clsp_ucb_rd_nack_vld, clsp_ucb_thr_id_out, 
clsp_ucb_buf_id_out, clsp_ucb_data_out, dbgtrig_dly_cnt_val, 
jbus_grst_jl_l, jbus_dbginit_jl_l, clk_stretch_trig, 
ctu_dll3_byp_val_jl, ctu_dll2_byp_val_jl, ctu_dll1_byp_val_jl, 
ctu_dll0_byp_val_jl, ctu_dll3_byp_l_jl, ctu_dll2_byp_l_jl, 
ctu_dll1_byp_l_jl, ctu_dll0_byp_l_jl, stop_id_vld_jl, 
stop_id_decoded, update_clkctrl_reg_jl, clkctrl_data_in_reg, 
rd_clkctrl_reg_jl, 
// Inputs
se, mask_major_id, mask_minor_id, ddr0_ctu_dll_lock, 
ddr1_ctu_dll_lock, ddr2_ctu_dll_lock, ddr3_ctu_dll_lock, 
ddr0_ctu_dll_overflow, ddr1_ctu_dll_overflow, ddr2_ctu_dll_overflow, 
ddr3_ctu_dll_overflow, jbus_clk, rst_l, io_pwron_rst_l, start_clk_jl, 
start_clk_early_jl, a_grst_jl, io_clk_stretch, clsp_ctrl_rd_bus_cl, 
shadreg_div_jmult, de_grst_jsync_edge, de_dbginit_jsync_edge, 
ucb_clsp_rd_req_vld, ucb_clsp_wr_req_vld, ucb_clsp_addr_in, 
ucb_clsp_data_in, ucb_clsp_thr_id_in, ucb_clsp_buf_id_in, 
bypclksel, jbus_mult_rst_l, jtag_clsp_stop_id_vld, 
jtag_clsp_stop_id, dll3_ctu_ctrl, dll2_ctu_ctrl, dll1_ctu_ctrl, 
dll0_ctu_ctrl
);
   parameter REG_WIDTH=64;
   parameter DBG_CNT= 5'd31;

   // to clkgn block

   output reg_cdiv_0;
   output reg_ddiv_0;
   output reg_jdiv_0;
   output [14:0] reg_cdiv_vec;
   output [14:0] reg_ddiv_vec;
   output [14:0] reg_jdiv_vec;
   output [14:0] stretch_cnt_vec;
   output clk_stretch_cnt_val_6; 
   output clk_stretch_cnt_val_odd;
   output [13:0]         reg_div_cmult;           // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [9:0]         reg_div_dmult;           // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [9:0]         reg_div_jmult;           // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [4:0]          dsync_reg_init;         // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [4:0]          dsync_reg_period;       // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [1:0]          dsync_reg_rx0;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [1:0]          dsync_reg_rx1;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [1:0]          dsync_reg_rx2;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [4:0]          dsync_reg_tx0;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [4:0]          dsync_reg_tx1;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [4:0]          dsync_reg_tx2;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [4:0]          jsync_reg_init;         // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [4:0]          jsync_reg_period;       // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [1:0]          jsync_reg_rx0;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [1:0]          jsync_reg_rx1;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [1:0]          jsync_reg_rx2;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [4:0]          jsync_reg_tx0;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [4:0]          jsync_reg_tx1;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v
   output [4:0]          jsync_reg_tx2;          // To u_ctu_clsp_clkgn_shadreg of ctu_clsp_clkgn_shadreg.v

   output [7:0]          ctu_spc_const_maskid;

   // to rstctrl
   // output clk_dram_freq_200_sel; 
   output frq_chng_pending_jl;
   

   // to ddr

   output [2:0] ctu_ddr0_dll_delayctr_jl;   // ddr0 deskew data
   output [2:0] ctu_ddr1_dll_delayctr_jl;   // ddr1 deskew data
   output [2:0] ctu_ddr2_dll_delayctr_jl;   // ddr2 deskew data
   output [2:0] ctu_ddr3_dll_delayctr_jl;   // ddr3 deskew data


   output de_dbginit_jl;
   output a_dbginit_jl;

   input      se;

   input      [3:0] mask_major_id;
   input      [3:0] mask_minor_id;
   input      ddr0_ctu_dll_lock;        // ddr0 deskew lock
   input      ddr1_ctu_dll_lock;        // ddr1 deskew lock
   input      ddr2_ctu_dll_lock;        // ddr2 deskew lock
   input      ddr3_ctu_dll_lock;        // ddr3 deskew lock

   input      ddr0_ctu_dll_overflow;    // ddr0 deskew overflow
   input      ddr1_ctu_dll_overflow;    // ddr0 deskew overflow
   input      ddr2_ctu_dll_overflow;    // ddr0 deskew overflow
   input      ddr3_ctu_dll_overflow;    // ddr0 deskew overflow


   //output to ucb

   output                 clsp_ucb_rd_ack_vld;
   output                 clsp_ucb_rd_nack_vld;
   output [`UCB_THR_HI-`UCB_THR_LO:0] clsp_ucb_thr_id_out;
   output [`UCB_BUF_HI-`UCB_BUF_LO:0] clsp_ucb_buf_id_out;
   output [REG_WIDTH-1:0] clsp_ucb_data_out;


   output  [4:0] dbgtrig_dly_cnt_val;

   output                 jbus_grst_jl_l;
   output                 jbus_dbginit_jl_l;
   output                 clk_stretch_trig;

   //global inputs
   input                  jbus_clk;
   input                  rst_l;
   input                  io_pwron_rst_l;
   input                  start_clk_jl;
   input                  start_clk_early_jl;
   input                  a_grst_jl;
   input                  io_clk_stretch;
   input   [63:0]         clsp_ctrl_rd_bus_cl;


   // sync edge signals
   input [9:0]            shadreg_div_jmult;
   input                  de_grst_jsync_edge;
   input                  de_dbginit_jsync_edge;

   //inputs from ucb
   input                  ucb_clsp_rd_req_vld;
   input                  ucb_clsp_wr_req_vld;
   input [`UCB_ADDR_HI-`UCB_ADDR_LO:0] ucb_clsp_addr_in;
   input [`UCB_DATA_HI-`UCB_DATA_LO:0] ucb_clsp_data_in;
   input [`UCB_THR_HI-`UCB_THR_LO:0] ucb_clsp_thr_id_in;
   input [`UCB_BUF_HI-`UCB_BUF_LO:0] ucb_clsp_buf_id_in;


   // jtag stop id

    input bypclksel;
    input jbus_mult_rst_l;
    input jtag_clsp_stop_id_vld;
    input  [5:0] jtag_clsp_stop_id;

    input [4:0] dll3_ctu_ctrl;
    input [4:0] dll2_ctu_ctrl;
    input [4:0] dll1_ctu_ctrl;
    input [4:0] dll0_ctu_ctrl;

    output [4:0] ctu_dll3_byp_val_jl;
    output [4:0] ctu_dll2_byp_val_jl;
    output [4:0] ctu_dll1_byp_val_jl;
    output [4:0] ctu_dll0_byp_val_jl;

    output ctu_dll3_byp_l_jl;
    output ctu_dll2_byp_l_jl;
    output ctu_dll1_byp_l_jl;
    output ctu_dll0_byp_l_jl;

    output stop_id_vld_jl;
    output [`CCTRLSM_MAX_ST-1:0] stop_id_decoded;
    output update_clkctrl_reg_jl;
    output [63:0]  clkctrl_data_in_reg;
    output rd_clkctrl_reg_jl;
    


   wire  mult_rst_l;
   wire  se_bar;

// Wires

  
   wire                  ucb_clsp_rd_req_vld_reg;
   wire                  ucb_clsp_wr_req_vld_reg;
   wire [`UCB_THR_HI-`UCB_THR_LO:0] ucb_clsp_thr_id_in_reg;
   wire [`UCB_BUF_HI-`UCB_BUF_LO:0] ucb_clsp_buf_id_in_reg;
   wire [`UCB_ADDR_HI-`UCB_ADDR_LO:0] ucb_clsp_addr_in_reg;
   wire [`UCB_DATA_HI-`UCB_DATA_LO:0] ucb_clsp_data_in_reg;
   wire [`UCB_ADDR_HI-`UCB_ADDR_LO:0] ucb_clsp_addr_in_reg_nxt;
   wire [`UCB_DATA_HI-`UCB_DATA_LO:0] ucb_clsp_data_in_reg_nxt;
   wire [`UCB_DATA_HI-`UCB_DATA_LO:0] ucb_data_out_nxt;

// address decoding
wire  clsp_div_sel;
wire  clsp_ctrl_sel;
wire  clsp_dbg_init_sel;
wire  clsp_dll_ctrl_sel;
wire  clsp_jsync_sel;
wire  clsp_dsync_sel;
wire  clsp_upper_addr_vld;
wire  clsp_lower_addr_vld;

// ucbif signals
wire  clsp_wr_req_nxt;
wire  clsp_wr_req_vld;
wire  clsp_wr_req_vld_d;
wire  clsp_rd_req_vld_nxt;
wire  clsp_rd_req_vld;
wire  clsp_rd_req_vld_d;
wire  clsp_rd_req_vld_1sht;
wire  rd_nack_vld_nxt;
wire  rd_nack_vld;
wire  rd_nack_vld_d;
wire  rd_nack_vld_1sht;

// clkdiv reg
wire [13:0] reg_div_cmult_nxt;
wire [13:0] reg_div_cmult;
wire [9:0] reg_div_dmult_nxt;
wire [9:0] reg_div_dmult;
wire [9:0] reg_div_jmult_nxt;
wire [9:0] reg_div_jmult;
wire frq_chng_pending_nxt;
//wire clk_dram_freq_200_sel_nxt;
//wire clk_dram_freq_200_sel;
wire [4:0] reg_jdiv_nxt;
wire [4:0] reg_ddiv_nxt;
wire [4:0] reg_cdiv_nxt;
wire [4:0] reg_jdiv;
wire [4:0] reg_ddiv;
wire [4:0] reg_cdiv;
wire frq_chng_pending_jl;
wire clsp_div_rd_vld;
wire [63:0] clsp_div_rd_bus;

// clkctrl reg

wire [63:0] clsp_ctrl_rd_bus;


// reg ddl_ctrl

wire [4:0] dbgtrig_dly_cnt_val_nxt;
wire [4:0] dbgtrig_dly_cnt_val;
wire clk_stretch_cnt_val_6_nxt;
wire [4:0] clk_stretch_cnt_val;
wire [4:0] clk_stretch_cnt_val_nxt;
wire [2:0] clsp_ddr3_dll_delayctr_jl;
wire [2:0] clsp_ddr3_dll_delay_nxt;
wire [2:0] clsp_ddr2_dll_delayctr_jl;
wire [2:0] clsp_ddr2_dll_delay_nxt;
wire [2:0] clsp_ddr1_dll_delayctr_jl;
wire [2:0] clsp_ddr1_dll_delay_nxt;
wire [2:0] clsp_ddr0_dll_delayctr_jl;
wire [2:0] clsp_ddr0_dll_delay_nxt;
wire ddr0_dll_lock_jl;
wire ddr1_dll_lock_jl;
wire ddr2_dll_lock_jl;
wire ddr3_dll_lock_jl;
wire ddr0_dll_overflow_jl;
wire ddr1_dll_overflow_jl;
wire ddr2_dll_overflow_jl;
wire ddr3_dll_overflow_jl;
wire ddr0_dll_lock_nxt;
wire ddr1_dll_lock_nxt;
wire ddr2_dll_lock_nxt;
wire ddr3_dll_lock_nxt;
wire ddr0_dll_overflow_nxt;
wire ddr1_dll_overflow_nxt;
wire ddr2_dll_overflow_nxt;
wire ddr3_dll_overflow_nxt;
wire ddr0_dll_lock;
wire ddr1_dll_lock;
wire ddr2_dll_lock;
wire ddr3_dll_lock;
wire ddr0_dll_overflow;
wire ddr1_dll_overflow;
wire ddr2_dll_overflow;
wire ddr3_dll_overflow;
wire clsp_dll_ctrl_rd_vld;
wire [63:0] clsp_dll_ctrl_rd_bus;


// reg jsync

wire [1:0] jsync_reg_rx2_nxt;
wire [1:0] jsync_reg_rx2;
wire [1:0] jsync_reg_rx1_nxt;
wire [1:0] jsync_reg_rx1;
wire [1:0] jsync_reg_rx0_nxt;
wire [1:0] jsync_reg_rx0;
wire [4:0] jsync_reg_tx2_nxt;
wire [4:0] jsync_reg_tx2;
wire [4:0] jsync_reg_tx1_nxt;
wire [4:0] jsync_reg_tx1;
wire [4:0] jsync_reg_tx0_nxt;
wire [4:0] jsync_reg_tx0;
wire [4:0] jsync_reg_period_nxt;
wire [4:0] jsync_reg_period;
wire [4:0] jsync_reg_init_nxt;
wire [4:0] jsync_reg_init;
wire clsp_jsync_rd_vld;
wire [63:0] clsp_jsync_rd_bus;

// reg dsync

wire [1:0] dsync_reg_rx2_nxt;
wire [1:0] dsync_reg_rx2;
wire [1:0] dsync_reg_rx1_nxt;
wire [1:0] dsync_reg_rx1;
wire [1:0] dsync_reg_rx0_nxt;
wire [1:0] dsync_reg_rx0;
wire [4:0] dsync_reg_tx2_nxt;
wire [4:0] dsync_reg_tx2;
wire [4:0] dsync_reg_tx1_nxt;
wire [4:0] dsync_reg_tx1;
wire [4:0] dsync_reg_tx0_nxt;
wire [4:0] dsync_reg_tx0;
wire [4:0] dsync_reg_period_nxt;
wire [4:0] dsync_reg_period;
wire [4:0] dsync_reg_init_nxt;
wire [4:0] dsync_reg_init;
wire clsp_dsync_rd_vld;
wire [63:0] clsp_dsync_rd_bus;


// read bus
wire [63:0] data_out;
wire [63:0] ucb_data_out;
wire ucb_rd_ack_vld;

// dbginit reg

wire dbginit_1sht;
wire [4:0] dbg_init_cnt_plus1;
wire [4:0] dbg_init_cnt_nxt;
wire [4:0] dbg_init_cnt;
wire dbg_init_cnt_dn;
wire de_dbginit_jl_nxt;
wire a_dbginit_jl_nxt;
wire jbus_grst_jl_l_nxt;
wire jbus_dbginit_jl_l_nxt;
wire a_dbginit_jl;

wire rd_clkctrl_reg_nxt;
wire rd_clkctrl_reg_jl;
wire update_clkctrl_reg_nxt;
wire update_clkctrl_reg_jl;


// sync edge count

   wire [9:0] lcm_cnt_minus_1;
   wire [9:0] lcm_cnt_nxt;
   wire [9:0] lcm_cnt;
   wire lcm_cnt_zero;
   wire cnt_ld;
   wire grst_en_window_nxt;
   wire grst_en_window;
   wire dbginit_en_window;
   wire dbginit_en_window_nxt;
   wire dbginit_rd_vld_window_nxt;
   wire dbginit_rd_vld_window;
   wire dbginit_rd_vld;
   wire ucb_rd_ack_vld_nxt;

   wire [`UCB_THR_HI-`UCB_THR_LO:0] ucb_clsp_thr_id_in_nxt;
   wire [`UCB_BUF_HI-`UCB_BUF_LO:0] ucb_clsp_buf_id_in_nxt;

   reg [14:0] cdiv_vec_nxt;
   reg [14:0] jdiv_vec_nxt;
   reg [14:0] ddiv_vec_nxt;
   reg [14:0] stretch_cnt_vec_nxt;


  // jtag stop id
   wire [5:0] new_id_nxt;
   wire [5:0] new_id;
   reg  [`CCTRLSM_MAX_ST-1:0] jtag_clsp_stop_id_decoded;
   wire jtag_clsp_stop_id_vld_jl;
   wire jtag_clsp_stop_id_vld_jl_dly_l;
   wire jtag_clsp_stop_id_vld_1sht;
   wire stop_id_vld_dly;

  // dll bypass
    wire clsp_dll_byp_sel;
    wire ctu_dll3_byp_l_nxt;
    wire ctu_dll3_byp_l_jl;
    wire ctu_dll2_byp_l_nxt;
    wire ctu_dll2_byp_l_jl;
    wire ctu_dll1_byp_l_nxt;
    wire ctu_dll1_byp_l_jl;
    wire ctu_dll0_byp_l_nxt;
    wire ctu_dll0_byp_l_jl;
    wire [4:0] ctu_dll3_byp_val_nxt;
    wire [4:0] ctu_dll2_byp_val_nxt;
    wire [4:0] ctu_dll1_byp_val_nxt;
    wire [4:0] ctu_dll0_byp_val_nxt;
    wire clsp_dll_byp_rd_vld;
    wire [63:0] clsp_dll_byp_rd_bus;
    
    wire [4:0] dll3_ctu_ctrl_jl;
    wire [4:0] dll2_ctu_ctrl_jl;
    wire [4:0] dll1_ctu_ctrl_jl;
    wire [4:0] dll0_ctu_ctrl_jl;

   // version register
wire   [15:0] manufacture_code;
wire   [15:0] impl_code;
wire   [7:0]  mask_id;
wire   [2:0]  max_glb_reg;
wire   [7:0]  max_trap_level;
wire   [4:0]  max_cwp;
wire   [63:0] clsp_version_rd_bus;
wire   clsp_version_sel;
wire   clsp_version_rd_vld;
wire   bypclksel_sync;

wire   [14:0] stretch_cnt_vec_pre;


//-----------------------------------------------------------------------
//
//    Synchronizer
//
//-----------------------------------------------------------------------

// assuming all signals are level 

ctu_synchronizer #(5) u_dll0_ctu_ctrl(
             .presyncdata(dll0_ctu_ctrl),
             .syncdata (dll0_ctu_ctrl_jl),
             .clk(jbus_clk)
              );
ctu_synchronizer #(5) u_dll1_ctu_ctrl(
             .presyncdata(dll1_ctu_ctrl),
             .syncdata (dll1_ctu_ctrl_jl),
             .clk(jbus_clk)
              );
ctu_synchronizer #(5) u_dll2_ctu_ctrl(
             .presyncdata(dll2_ctu_ctrl),
             .syncdata (dll2_ctu_ctrl_jl),
             .clk(jbus_clk)
              );
ctu_synchronizer #(5) u_dll3_ctu_ctrl(
             .presyncdata(dll3_ctu_ctrl),
             .syncdata (dll3_ctu_ctrl_jl),
             .clk(jbus_clk)
              );

ctu_synchronizer u_ddr0_ctu_dll_lock(
             .presyncdata(ddr0_ctu_dll_lock),
             .syncdata (ddr0_dll_lock_jl),
             .clk(jbus_clk)
              );

ctu_synchronizer u_ddr1_ctu_dll_lock(
             .presyncdata(ddr1_ctu_dll_lock),
             .syncdata (ddr1_dll_lock_jl),
             .clk(jbus_clk)
              );

ctu_synchronizer u_ddr2_ctu_dll_lock(
             .presyncdata(ddr2_ctu_dll_lock),
             .syncdata (ddr2_dll_lock_jl),
             .clk(jbus_clk)
              );

ctu_synchronizer u_ddr3_ctu_dll_lock(
             .presyncdata(ddr3_ctu_dll_lock),
             .syncdata (ddr3_dll_lock_jl),
             .clk(jbus_clk)
              );

ctu_synchronizer u_ddr0_ctu_dll_overflow(
             .presyncdata(ddr0_ctu_dll_overflow),
             .syncdata (ddr0_dll_overflow_jl),
             .clk(jbus_clk)
              );

ctu_synchronizer u_ddr1_ctu_dll_overflow(
             .presyncdata(ddr1_ctu_dll_overflow),
             .syncdata (ddr1_dll_overflow_jl),
             .clk(jbus_clk)
              );

ctu_synchronizer u_ddr2_ctu_dll_overflow(
             .presyncdata(ddr2_ctu_dll_overflow),
             .syncdata (ddr2_dll_overflow_jl),
             .clk(jbus_clk)
              );

ctu_synchronizer u_ddr3_ctu_dll_overflow(
             .presyncdata(ddr3_ctu_dll_overflow),
             .syncdata (ddr3_dll_overflow_jl),
             .clk(jbus_clk)
              );

 // io_tck -> jbus_clk

ctu_synchronizer u_jtag_clsp_stop_id_vld(
             .presyncdata(jtag_clsp_stop_id_vld),
             .syncdata (jtag_clsp_stop_id_vld_jl),
             .clk(jbus_clk)
              );

 ctu_synchronizer u_bypclksel(
             .presyncdata( bypclksel),
             .syncdata ( bypclksel_sync),
             .clk(jbus_clk)
              );

//---------------------------------------------------------------------------
//
// output assignments
//
//---------------------------------------------------------------------------

dffrl_async_ns  u_clk_stretch_trig (.din(io_clk_stretch & start_clk_jl),
                                  .clk(jbus_clk),
                                   .rst_l (io_pwron_rst_l),
                                  .q (clk_stretch_trig)
                                    );

//---------------------------------------------------------------------------
//
//  UCB interface logic
//
//---------------------------------------------------------------------------
assign clsp_ucb_rd_ack_vld =  ucb_rd_ack_vld;
assign clsp_ucb_rd_nack_vld = rd_nack_vld_1sht;
assign clsp_ucb_data_out=  ucb_data_out [63:0];

assign reg_cdiv_0 =  reg_cdiv[0];
assign reg_jdiv_0 =  reg_jdiv[0];
assign reg_ddiv_0 =  reg_ddiv[0];
assign ctu_ddr0_dll_delayctr_jl = clsp_ddr0_dll_delayctr_jl;
assign ctu_ddr1_dll_delayctr_jl = clsp_ddr1_dll_delayctr_jl;
assign ctu_ddr2_dll_delayctr_jl = clsp_ddr2_dll_delayctr_jl;
assign ctu_ddr3_dll_delayctr_jl = clsp_ddr3_dll_delayctr_jl;


//---------------------------------------------------------------------------
//
// Address decoding:
//
//---------------------------------------------------------------------------


assign clsp_ucb_thr_id_out = ucb_clsp_thr_id_in_reg;
assign clsp_ucb_buf_id_out = ucb_clsp_buf_id_in_reg;


assign ucb_clsp_thr_id_in_nxt =  ucb_clsp_rd_req_vld  & rst_l ?
                                 ucb_clsp_thr_id_in : ucb_clsp_thr_id_in_reg;


dffrl_async_ns #(`UCB_THR_HI-`UCB_THR_LO+1) u_ucb_clsp_thr_id_in(.din(ucb_clsp_thr_id_in_nxt),
                                  .clk(jbus_clk),
                                   .rst_l (io_pwron_rst_l),
                                  .q (ucb_clsp_thr_id_in_reg)
                                 );

assign ucb_clsp_buf_id_in_nxt =  ucb_clsp_rd_req_vld  & rst_l ?
                                 ucb_clsp_buf_id_in : ucb_clsp_buf_id_in_reg;

dffrl_async_ns #(`UCB_BUF_HI-`UCB_BUF_LO+1) u_ucb_clsp_buf_id_in_reg(.din(ucb_clsp_buf_id_in_nxt),
                                  .clk(jbus_clk),
                                   .rst_l (io_pwron_rst_l),
                                  .q (ucb_clsp_buf_id_in_reg)
                                 );

dffrl_async_ns  u_ucb_clsp_rd_req_vld_tmp (.din( ucb_clsp_rd_req_vld),
                                  .clk(jbus_clk),
                                   .rst_l (io_pwron_rst_l),
                                  .q (ucb_clsp_rd_req_vld_reg)
                                 );
assign ucb_clsp_data_in_reg_nxt =  (ucb_clsp_rd_req_vld | ucb_clsp_wr_req_vld)  & rst_l ?
                                    ucb_clsp_data_in : ucb_clsp_data_in_reg;

dffrl_async_ns #(`UCB_DATA_HI-`UCB_DATA_LO+1) u_ucb_clsp_data_in_tmp(.din( ucb_clsp_data_in_reg_nxt),
                                  .clk(jbus_clk),
                                  .rst_l (io_pwron_rst_l),
                                  .q (ucb_clsp_data_in_reg)
                                 );

assign ucb_clsp_addr_in_reg_nxt =  (ucb_clsp_rd_req_vld | ucb_clsp_wr_req_vld)  & rst_l ?
                                    ucb_clsp_addr_in : ucb_clsp_addr_in_reg;

dffrl_async_ns #(`UCB_ADDR_HI-`UCB_ADDR_LO+1) u_ucb_clsp_addr_in_tmp(.din( ucb_clsp_addr_in_reg_nxt),
                                  .clk(jbus_clk),
                                  .rst_l (io_pwron_rst_l),
                                  .q (ucb_clsp_addr_in_reg)
                                 );


dffrl_async_ns  u_ucb_clsp_wr_req_vld_reg (.din( ucb_clsp_wr_req_vld),
                                  .clk(jbus_clk),
                                  .rst_l (io_pwron_rst_l),
                                  .q (ucb_clsp_wr_req_vld_reg)
                                 );



assign clsp_upper_addr_vld = ucb_clsp_addr_in_reg[`UCB_ADDR_HI-`UCB_ADDR_LO:`CLK_ADDR_HI+1] == `CLK_UPPER_ADDR;

assign clsp_div_sel =  ucb_clsp_addr_in_reg[`CLK_ADDR_HI:0] == `CLK_DIV_ADDR;
assign clsp_ctrl_sel =  ucb_clsp_addr_in_reg[`CLK_ADDR_HI:0] == `CLK_CTRL_ADDR;
assign clsp_dbg_init_sel  =  ucb_clsp_addr_in_reg[`CLK_ADDR_HI:0] == `CLK_DBG_INIT_ADDR;
assign clsp_dll_ctrl_sel =  ucb_clsp_addr_in_reg[`CLK_ADDR_HI:0] == `CLK_DLL_CTRL_ADDR;
assign clsp_jsync_sel =  ucb_clsp_addr_in_reg[`CLK_ADDR_HI:0] == `CLK_JSYNC_ADDR;
assign clsp_dsync_sel =  ucb_clsp_addr_in_reg[`CLK_ADDR_HI:0] == `CLK_DSYNC_ADDR;
assign clsp_dll_byp_sel =  ucb_clsp_addr_in_reg[`CLK_ADDR_HI:0] == `CLK_DLL_BYP_ADDR;
assign clsp_version_sel =  ucb_clsp_addr_in_reg[`CLK_ADDR_HI:0] == `CLK_VERSION_ADDR;

assign clsp_lower_addr_vld =  clsp_div_sel |  clsp_ctrl_sel | clsp_dbg_init_sel  | clsp_dll_byp_sel | clsp_version_sel |
                              clsp_dll_ctrl_sel |  clsp_jsync_sel |   clsp_dsync_sel  ;

//---------------------------------------------------------------------------
//
//  UCB IF signals
//
//---------------------------------------------------------------------------

assign clsp_wr_req_nxt  = clsp_upper_addr_vld & ucb_clsp_wr_req_vld_reg ;

dffrl_async_ns u_clsp_wr_req_vld_ff (.din( clsp_wr_req_nxt),
                                  .clk(jbus_clk),
                                  .rst_l (io_pwron_rst_l),
                                  .q (clsp_wr_req_vld)
                                 );

dff_ns u_clsp_wr_req_vld_d (.din( clsp_wr_req_vld),
                                  .clk(jbus_clk),
                                  .q (clsp_wr_req_vld_d)
                                 );


assign clsp_rd_req_vld_nxt  = clsp_upper_addr_vld &  ucb_clsp_rd_req_vld_reg;

dffrl_async_ns u_clsp_rd_req_vld_ff (.din( clsp_rd_req_vld_nxt),
                               .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l),
                               .q (clsp_rd_req_vld)
                              );

dffrl_async_ns u_clsp_rd_req_vld_d_ff (.din( clsp_rd_req_vld),
                               .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l),
                               .q (clsp_rd_req_vld_d)
                              );

assign clsp_rd_req_vld_1sht = clsp_rd_req_vld & ~clsp_rd_req_vld_d ;

//assign   rd_nack_vld_nxt =     clsp_upper_addr_vld &  ~clsp_lower_addr_vld & ucb_clsp_rd_req_vld_reg & rst_l;
assign   rd_nack_vld_nxt =      ~(clsp_upper_addr_vld & clsp_lower_addr_vld) & ucb_clsp_rd_req_vld_reg & rst_l;

dffrl_async_ns u_clsp_rd_nack_vld_ff (.din( rd_nack_vld_nxt),
                                  .clk(jbus_clk),
                                  .rst_l (io_pwron_rst_l),
                                  .q (rd_nack_vld)
                                 );
dffrl_async_ns u_clsp_rd_nack_vld_d_ff (.din( rd_nack_vld),
                                  .clk(jbus_clk),
                                  .rst_l (io_pwron_rst_l),
                                  .q (rd_nack_vld_d)
                                 );

assign rd_nack_vld_1sht = rd_nack_vld & ~rd_nack_vld_d;




//---------------------------------------------------------------------------
//
// Register : Clock divide
//
//---------------------------------------------------------------------------

// MULT     41:28 (default 16)
// CHANGE   26    (default 0)
// DRAM200  25    (default 0 ; POR only)
// DDIV     24:19 (default 010000 ; POR only )
// JDIV     12:7  (default 010000 ; POR only)
// CDIV     5:0   (default 000100 ; POR only)

assign  reg_div_dmult_nxt = clsp_div_sel & clsp_wr_req_vld_d  & rst_l? 
                            ucb_clsp_data_in_reg[61:52]
                     :  reg_div_dmult;

assign  reg_div_jmult_nxt = clsp_div_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[51:42]
                     :  reg_div_jmult;

assign  reg_div_cmult_nxt = clsp_div_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[41:28]
                     :  reg_div_cmult;


assign  reg_ddiv_nxt =  clsp_div_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[20:16]
                         :  reg_ddiv;


assign  reg_jdiv_nxt =  clsp_div_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[12:8]
                         :  reg_jdiv;

assign  reg_cdiv_nxt =  clsp_div_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[4:0]
                         :  reg_cdiv;



assign  frq_chng_pending_nxt =    ~rst_l ?  1'b0:
                                  clsp_div_sel & clsp_wr_req_vld_d? ucb_clsp_data_in_reg[26]:
                                  frq_chng_pending_jl;
 
dffrl_async_ns u_frq_chng_pending_jl_ff (.din(frq_chng_pending_nxt),
                                    .clk(jbus_clk),
                                    .rst_l (io_pwron_rst_l), 
                                    .q (frq_chng_pending_jl)
                                    );


dffrl_async_ns #(2) u_reg_cdiv_4_3_ff (.din( reg_cdiv_nxt[4:3]), 
                                          .clk(jbus_clk),
                                          .rst_l (io_pwron_rst_l), 
                                          .q (reg_cdiv[4:3])
                                         );
dffsl_async_ns u_reg_cdiv_2_ff (.din( reg_cdiv_nxt[2]), 
                                        .clk(jbus_clk),
                                        .set_l (io_pwron_rst_l), 
                                        .q (reg_cdiv[2])
                                        );
dffrl_async_ns #(2) u_reg_cdiv_1_0_ff (.din( reg_cdiv_nxt[1:0]), 
                                        .clk(jbus_clk),
                                        .rst_l (io_pwron_rst_l), 
                                        .q (reg_cdiv[1:0])
                                        );

// default to 0010_0000 (32)

dffrl_async_ns #(8) u_reg_div_cmult_13_6_ff (.din(reg_div_cmult_nxt[13:6]), 
                                          .clk(jbus_clk),
                                          .rst_l (io_pwron_rst_l), 
                                          .q (reg_div_cmult[13:6])
                                         );

dffsl_async_ns u_reg_div_cmult_5_ff (.din( reg_div_cmult_nxt[5]), 
                                        .clk(jbus_clk),
                                        .set_l (io_pwron_rst_l), 
                                        .q (reg_div_cmult[5])
                                        );
dffrl_async_ns #(5) u_reg_div_cmult_4_0_ff (.din( reg_div_cmult_nxt[4:0]), 
                                        .clk(jbus_clk),
                                        .rst_l (io_pwron_rst_l), 
                                        .q (reg_div_cmult[4:0])
                                        );

// default to 0000_1000 (8)

dffrl_async_ns #(6) u_reg_div_dmult_9_4_ff (.din(reg_div_dmult_nxt[9:4]), 
                                          .clk(jbus_clk),
                                          .rst_l (io_pwron_rst_l), 
                                          .q (reg_div_dmult[9:4])
                                         );

dffsl_async_ns u_reg_div_dmult_3_ff (.din( reg_div_dmult_nxt[3]), 
                                        .clk(jbus_clk),
                                        .set_l (io_pwron_rst_l), 
                                        .q (reg_div_dmult[3])
                                        );
dffrl_async_ns #(3) u_reg_div_dmult_2_0_ff (.din( reg_div_dmult_nxt[2:0]), 
                                        .clk(jbus_clk),
                                        .rst_l (io_pwron_rst_l), 
                                        .q (reg_div_dmult[2:0])
                                        );

// default to 0000_1000 (8)
dffrl_async_ns #(6) u_reg_div_jmult_9_4_ff (.din(reg_div_jmult_nxt[9:4]), 
                                          .clk(jbus_clk),
                                          .rst_l (io_pwron_rst_l), 
                                          .q (reg_div_jmult[9:4])
                                         );

dffsl_async_ns u_reg_div_jmult_3_ff (.din( reg_div_jmult_nxt[3]), 
                                        .clk(jbus_clk),
                                        .set_l (io_pwron_rst_l), 
                                        .q (reg_div_jmult[3])
                                        );
dffrl_async_ns #(3) u_reg_div_jmult_2_0_ff (.din( reg_div_jmult_nxt[2:0]), 
                                        .clk(jbus_clk),
                                        .rst_l (io_pwron_rst_l), 
                                        .q (reg_div_jmult[2:0])
                                        );


// default to 010000


dffsl_async_ns u_reg_jdiv_4_ff (.din( reg_jdiv_nxt[4]), 
                                        .clk(jbus_clk),
                                        .set_l (io_pwron_rst_l), 
                                        .q (reg_jdiv[4])
                                        );
dffrl_async_ns #(4) u_reg_jdiv_3_0_ff (.din( reg_jdiv_nxt[3:0]), 
                                        .clk(jbus_clk),
                                        .rst_l (io_pwron_rst_l), 
                                        .q (reg_jdiv[3:0])
                                        );

// default to 010000
dffsl_async_ns u_reg_ddiv_4_ff (.din( reg_ddiv_nxt[4]), 
                                        .clk(jbus_clk),
                                        .set_l (io_pwron_rst_l), 
                                        .q (reg_ddiv[4])
                                        );
dffrl_async_ns #(4) u_reg_ddiv_3_0_ff (.din( reg_ddiv_nxt[3:0]), 
                                        .clk(jbus_clk),
                                        .rst_l (io_pwron_rst_l), 
                                        .q (reg_ddiv[3:0])
                                        );

assign clsp_div_rd_vld = clsp_rd_req_vld_1sht  & clsp_div_sel; 

assign clsp_div_rd_bus     =  { 2'b00, 
                               reg_div_dmult[9:0],
                               reg_div_jmult[9:0], 
                               reg_div_cmult[13:0],
                               1'b0,
                               frq_chng_pending_jl,
                               5'b00000,
			       reg_ddiv[4:0],
                               3'b000,
			       reg_jdiv[4:0],
                               3'b000,
			       reg_cdiv[4:0]} & { 64 {clsp_div_rd_vld}};

//---------------------------------------------------------------------------
//
// Register : Clock control
//
//---------------------------------------------------------------------------

// All registers all located on clkctrl block ; cmp_clk domain

assign update_clkctrl_reg_nxt =  clsp_ctrl_sel & clsp_wr_req_vld_d & rst_l;

dffrl_async_ns u_update_clkctrl_reg(.din(update_clkctrl_reg_nxt), 
                               .clk(jbus_clk),
                               .rst_l (io_pwron_rst_l), 
                               .q (update_clkctrl_reg_jl)
                               );

dffe_ns #(64)  u_rd_ucb_clsp_data_in_reg (.din(ucb_clsp_data_in_reg), 
                               .clk(jbus_clk),
                               .en(update_clkctrl_reg_nxt),
                               .q (clkctrl_data_in_reg)
                               );

assign rd_clkctrl_reg_nxt =  clsp_rd_req_vld_1sht & clsp_ctrl_sel & rst_l; 

// Guarantee data is stable after 2 jbus_clk ; no need  to get an ack
// clsp_ctrl_rd_bus_cl needs to hold for 2 cycles after rd_clkctrl_reg_jl is asserted 

dffrl_async_ns u_rd_clkctrl_reg(.din(rd_clkctrl_reg_nxt), 
                               .clk(jbus_clk),
                               .rst_l (io_pwron_rst_l), 
                               .q (rd_clkctrl_reg_jl)
                               );

dffrl_async_ns u_rd_clkctrl_reg_dly (.din(rd_clkctrl_reg_jl), 
                               .clk(jbus_clk),
                               .rst_l (io_pwron_rst_l), 
                               .q (rd_clkctrl_reg_dly )
                               );

dffrl_async_ns u_clsp_ctrl_rd_vld (.din(rd_clkctrl_reg_dly), 
                               .clk(jbus_clk),
                               .rst_l (io_pwron_rst_l), 
                               .q (clsp_ctrl_rd_vld)
                               );


assign clsp_ctrl_rd_bus   =  clsp_ctrl_rd_bus_cl & {64 {clsp_ctrl_rd_vld}};

//---------------------------------------------------------------------------
//
// Register : dbg_init
//
//---------------------------------------------------------------------------


assign dbginit_1sht = clsp_rd_req_vld_1sht  & clsp_dbg_init_sel;

//---------------------------------------------------------------------------
//
//  dbginit assertion count
//
//---------------------------------------------------------------------------

//  dbginit needs to be asserted more than 32 jbus cycles

assign dbg_init_cnt_plus1 = dbg_init_cnt + 5'b00001;

// We should not have another read  (dbginit_1sht) while dbginit_l is asserted
// (rd_ack is not returned yet)

assign dbg_init_cnt_nxt =   dbginit_1sht ?  5'b00000:                           
                            a_dbginit_jl & ~dbg_init_cnt_dn ? dbg_init_cnt_plus1:  
                            dbg_init_cnt;

dffrl_async_ns #(5) u_dbg_init_cnt (.din(  dbg_init_cnt_nxt),
                             .clk(jbus_clk),
                             .rst_l (io_pwron_rst_l), 
                             .q (dbg_init_cnt)
                                   );

assign  dbg_init_cnt_dn = ( dbg_init_cnt == DBG_CNT);


//---------------------------------------------------------------------------
//
//  dbginit assertion count
//
//---------------------------------------------------------------------------
// rd_ack should be returned only when  dbginit_rd_vld_window is set to 1 
// jbus_dbginit_jl_l is the actually dbginit signal (waited for coin_edge)
// rd_ack is returned after jbus_dbginit_jl_l is deasserted  on coincidenet edge

 // dbginit_rd_vld_window is 1 when a read to register
 // dbginit_rd_vld_window is set to 0 when jbus_dbginit_jl_l is de-asserted and on coincident edge

// ECO 6534 TO_1_1

assign dbginit_rd_vld_window_nxt  = 
                                    dbginit_1sht? 1'b1:   
                                    lcm_cnt_zero & de_dbginit_jl & jbus_dbginit_jl_l? 1'b0: 
                                    //lcm_cnt_zero & de_dbginit_jl & jbus_dbginit_jl_l? 1'b0: 
                                    //dbginit_1sht? 1'b1:   
                                    dbginit_rd_vld_window;

dffrl_async_ns u_dbginit_rd_vld_window(.din(dbginit_rd_vld_window_nxt),
                             .clk(jbus_clk),
                             .rst_l (io_pwron_rst_l), 
                             .q ( dbginit_rd_vld_window)
                                 );
// rd ack returned to iob on coincident edge
assign dbginit_rd_vld = dbginit_rd_vld_window & lcm_cnt_zero & de_dbginit_jl & jbus_dbginit_jl_l ;


//---------------------------------------------------------------------------
//
//  Generate ctrl signal to shadreg block
//  All controls of assertion and de-assertion of dbginit signal are originated from cmp_clk domain
//
//---------------------------------------------------------------------------

assign  de_dbginit_jl_nxt = dbginit_1sht? 1'b0:           // read to register
                            dbg_init_cnt_dn ? 1'b1:       // 32 jbus cycle done
                            de_dbginit_jl;

assign  a_dbginit_jl_nxt = dbginit_1sht? 1'b1:    
                           dbg_init_cnt_dn ? 1'b0:
                           a_dbginit_jl;
                       
dffrl_async_ns u_de_dbginit_jl(.din(de_dbginit_jl_nxt),
                             .clk(jbus_clk),
                             .rst_l (io_pwron_rst_l), 
                             .q (de_dbginit_jl)
                                 );
dffrl_async_ns u_a_dbginit_jl(.din(a_dbginit_jl_nxt),
                             .clk(jbus_clk),
                             .rst_l (io_pwron_rst_l), 
                             .q (a_dbginit_jl)
                                 );

//---------------------------------------------------------------------------
//
// Register : clsp_dll_ctrl
//
//---------------------------------------------------------------------------

// TRIG_DELY 44:40
// STRETCH 38:32
// DDR3_DLL_OVF  19
// DDR3_DLL_LOCK 18
// DDR3_DLL_DELAY 17:15
// DDR2_DLL_OVF  14
// DDR2_DLL_LOCK 13
// DDR2_DLL_DELAY 12:10
// DDR1_DLL_OVF  9
// DDR1_DLL_LOCK 8
// DDR1_DLL_DELAY 7:5
// DDR0_DLL_OVF  4
// DDR0_DLL_LOCK 3
// DDR0_DLL_DELAY 2:0

assign    dbgtrig_dly_cnt_val_nxt =  clsp_dll_ctrl_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[44:40]
                              :  dbgtrig_dly_cnt_val;

dffsl_async_ns  #(5) u_dbgtrig_dly_cnt_val ( .din(dbgtrig_dly_cnt_val_nxt), 
                                .clk(jbus_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (dbgtrig_dly_cnt_val)
                              );


assign    clk_stretch_cnt_val_6_nxt =  clsp_dll_ctrl_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[38]
                              :  clk_stretch_cnt_val_6;

dffrl_async_ns  u_clk_stretch_cnt_val_6_ff ( .din(clk_stretch_cnt_val_6_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (clk_stretch_cnt_val_6)
                              );

assign    clk_stretch_cnt_val_nxt =  clsp_dll_ctrl_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[36:32]
                              :  clk_stretch_cnt_val;

dffrl_async_ns  #(3) u_clk_stretch_cnt_val_4_2_ff ( .din(clk_stretch_cnt_val_nxt[4:2]), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (clk_stretch_cnt_val[4:2])
                              );

dffsl_async_ns  #(1) u_clk_stretch_cnt_val_1_ff ( .din(clk_stretch_cnt_val_nxt[1]), 
                                .clk(jbus_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clk_stretch_cnt_val[1])
                              );

dffrl_async_ns  #(1) u_clk_stretch_cnt_val_0_ff ( .din(clk_stretch_cnt_val_nxt[0]), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (clk_stretch_cnt_val[0])
                              );

assign clk_stretch_cnt_val_odd = clk_stretch_cnt_val[0];

assign clsp_ddr3_dll_delay_nxt =  clsp_dll_ctrl_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[17:15]
                          :  clsp_ddr3_dll_delayctr_jl;

dffrl_async_ns       u_clsp_ddr3_dll_delay_2_ff ( .din(clsp_ddr3_dll_delay_nxt[2] ), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (clsp_ddr3_dll_delayctr_jl[2])
                              );

dffsl_async_ns  #(2) u_clsp_ddr3_dll_delay_1_0_ff ( .din(clsp_ddr3_dll_delay_nxt[1:0] ), 
                                .clk(jbus_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ddr3_dll_delayctr_jl[1:0])
                              );

assign clsp_ddr2_dll_delay_nxt =  clsp_dll_ctrl_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[12:10]
                          :  clsp_ddr2_dll_delayctr_jl;

dffrl_async_ns       u_clsp_ddr2_dll_delay_2_ff ( .din(clsp_ddr2_dll_delay_nxt[2] ), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (clsp_ddr2_dll_delayctr_jl[2])
                              );

dffsl_async_ns  #(2) u_clsp_ddr2_dll_delay_1_0_ff ( .din(clsp_ddr2_dll_delay_nxt[1:0] ), 
                                .clk(jbus_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ddr2_dll_delayctr_jl[1:0])
                              );

assign clsp_ddr1_dll_delay_nxt =  clsp_dll_ctrl_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[7:5]
                          :  clsp_ddr1_dll_delayctr_jl;

dffrl_async_ns       u_clsp_ddr1_dll_delay_2_ff ( .din(clsp_ddr1_dll_delay_nxt[2] ), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (clsp_ddr1_dll_delayctr_jl[2])
                              );

dffsl_async_ns  #(2) u_clsp_ddr1_dll_delay_1_0_ff ( .din(clsp_ddr1_dll_delay_nxt[1:0] ), 
                                .clk(jbus_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ddr1_dll_delayctr_jl[1:0])
                              );

assign clsp_ddr0_dll_delay_nxt =  clsp_dll_ctrl_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[2:0]
                          :  clsp_ddr0_dll_delayctr_jl;

dffrl_async_ns       u_clsp_ddr0_dll_delay_2_ff ( .din(clsp_ddr0_dll_delay_nxt[2] ), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (clsp_ddr0_dll_delayctr_jl[2])
                              );

dffsl_async_ns  #(2) u_clsp_ddr0_dll_delay_1_0_ff ( .din(clsp_ddr0_dll_delay_nxt[1:0] ), 
                                .clk(jbus_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (clsp_ddr0_dll_delayctr_jl[1:0])
                              );


assign ddr3_dll_overflow_nxt = rst_l ? ddr3_dll_overflow_jl :  ddr3_dll_overflow;
dffrl_async_ns       u_clsp_ddr3_dll_overflow_jl ( .din(ddr3_dll_overflow_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ddr3_dll_overflow)
                              );
assign ddr2_dll_overflow_nxt = rst_l ? ddr2_dll_overflow_jl :  ddr2_dll_overflow;
dffrl_async_ns       u_clsp_ddr2_dll_overflow_jl ( .din(ddr2_dll_overflow_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ddr2_dll_overflow)
                              );
assign ddr1_dll_overflow_nxt = rst_l ? ddr1_dll_overflow_jl :  ddr1_dll_overflow;
dffrl_async_ns       u_clsp_ddr1_dll_overflow_jl ( .din(ddr1_dll_overflow_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ddr1_dll_overflow)
                              );
assign ddr0_dll_overflow_nxt = rst_l ? ddr0_dll_overflow_jl :  ddr0_dll_overflow;
dffrl_async_ns       u_clsp_ddr0_dll_overflow_jl ( .din(ddr0_dll_overflow_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ddr0_dll_overflow)
                              );
assign ddr3_dll_lock_nxt = rst_l ? ddr3_dll_lock_jl :  ddr3_dll_lock;
dffrl_async_ns       u_clsp_ddr3_dll_lock_jl ( .din(ddr3_dll_lock_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ddr3_dll_lock)
                              );
assign ddr2_dll_lock_nxt = rst_l ? ddr2_dll_lock_jl :  ddr2_dll_lock;
dffrl_async_ns       u_clsp_ddr2_dll_lock_jl ( .din(ddr2_dll_lock_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ddr2_dll_lock)
                              );
assign ddr1_dll_lock_nxt = rst_l ? ddr1_dll_lock_jl :  ddr1_dll_lock;
dffrl_async_ns       u_clsp_ddr1_dll_lock_jl ( .din(ddr1_dll_lock_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ddr1_dll_lock)
                              );
assign ddr0_dll_lock_nxt = rst_l ? ddr0_dll_lock_jl :  ddr0_dll_lock;
dffrl_async_ns       u_clsp_ddr0_dll_lock_jl ( .din(ddr0_dll_lock_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ddr0_dll_lock)
                              );


assign clsp_dll_ctrl_rd_vld = clsp_rd_req_vld_1sht  & clsp_dll_ctrl_sel; 

assign clsp_dll_ctrl_rd_bus = { 19'h00000,
                               dbgtrig_dly_cnt_val[4:0],
                               1'b0,
                               clk_stretch_cnt_val_6,
                               1'b0,
                               clk_stretch_cnt_val[4:0],
                               12'h000,
                               ddr3_dll_overflow,
                               ddr3_dll_lock,
                               ctu_ddr3_dll_delayctr_jl[2:0],
                               ddr2_dll_overflow,
                               ddr2_dll_lock,
                               ctu_ddr2_dll_delayctr_jl[2:0],
                               ddr1_dll_overflow,
                               ddr1_dll_lock,
                               ctu_ddr1_dll_delayctr_jl[2:0],
                               ddr0_dll_overflow,
                               ddr0_dll_lock,
                               ctu_ddr0_dll_delayctr_jl[2:0]} &
                              { 64 {clsp_dll_ctrl_rd_vld }};
                      

//---------------------------------------------------------------------------
//
// Register : sync pulse (jbus_clk)
//
//---------------------------------------------------------------------------
// default 13:2
// JSYNC_RCV2 39:38  (default 2)
// JSYNC_TRN2 36:32  (default 1)
// JSYNC_RCV1 28:24  (default 2)
// JSYNC_TRN1 23:22  (default 1)
// JSYNC_RCV0 20:16  (default 2)
// JSYNC_TRN0 15:13  (default 1)
// JSYNC_INIT 12:8   (default 3)
// JSYNC_PERIOD 4:0  (default 3)


assign    jsync_reg_rx2_nxt  =  clsp_jsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[39:38]
                           :    jsync_reg_rx2;

dffrl_async_ns  u_jsync_reg_rx2_1_ff ( .din(jsync_reg_rx2_nxt[1]), 
                                 .clk(jbus_clk),
                                 .rst_l(io_pwron_rst_l), 
                                 .q (jsync_reg_rx2[1])
                               );

dffsl_async_ns  u_jsync_reg_rx2_0_ff ( .din(jsync_reg_rx2_nxt[0]), 
                                 .clk(jbus_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (jsync_reg_rx2[0])
                               );

assign    jsync_reg_tx2_nxt  =  clsp_jsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[36:32]
                           :    jsync_reg_tx2;

dffrl_async_ns  #(5) u_jsync_reg_tx2_4_0_ff ( .din(jsync_reg_tx2_nxt[4:0]), 
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l), 
                                 .q (jsync_reg_tx2[4:0])
                               );


assign    jsync_reg_rx1_nxt  =  clsp_jsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[31:30]
                           :    jsync_reg_rx1;

dffrl_async_ns  u_jsync_reg_rx1_1_ff ( .din(jsync_reg_rx1_nxt[1]), 
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l), 
                                 .q (jsync_reg_rx1[1])
                               );

dffsl_async_ns  u_jsync_reg_rx1_0_ff ( .din(jsync_reg_rx1_nxt[0]), 
                                 .clk(jbus_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (jsync_reg_rx1[0])
                               );

assign    jsync_reg_tx1_nxt  =  clsp_jsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[28:24]
                           :    jsync_reg_tx1;

dffrl_async_ns  #(5) u_jsync_reg_tx1_4_0_ff ( .din(jsync_reg_tx1_nxt[4:0]), 
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l), 
                                 .q (jsync_reg_tx1[4:0])
                               );


assign    jsync_reg_rx0_nxt  =  clsp_jsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[23:22]
                           :    jsync_reg_rx0;

dffrl_async_ns  u_jsync_reg_rx0_1_ff ( .din(jsync_reg_rx0_nxt[1]), 
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l), 
                                 .q (jsync_reg_rx0[1])
                               );

dffsl_async_ns  u_jsync_reg_rx0_0_ff ( .din(jsync_reg_rx0_nxt[0]), 
                                 .clk(jbus_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (jsync_reg_rx0[0])
                               );

assign    jsync_reg_tx0_nxt  =  clsp_jsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[20:16]
                           :    jsync_reg_tx0;

dffrl_async_ns  #(5) u_jsync_reg_tx0_4_0_ff ( .din(jsync_reg_tx0_nxt[4:0]), 
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l), 
                                 .q (jsync_reg_tx0[4:0])
                               );



assign    jsync_reg_init_nxt  =  clsp_jsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[12:8]
                           :     jsync_reg_init;

dffrl_async_ns  #(3) u_jsync_reg_4_3_init ( .din(jsync_reg_init_nxt[4:2]),
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l),
                                 .q (jsync_reg_init[4:2])
                               );

dffsl_async_ns       u_jsync_reg_2_1_init ( .din(jsync_reg_init_nxt[1]),
                                 .clk(jbus_clk),
                                 .set_l (io_pwron_rst_l),
                                 .q (jsync_reg_init[1])
                               );

dffrl_async_ns       u_jsync_reg_0_init ( .din(jsync_reg_init_nxt[0]),
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l),
                                 .q (jsync_reg_init[0])
                               );
// default to  3

assign    jsync_reg_period_nxt  =  clsp_jsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[4:0]
                           :     jsync_reg_period;

dffrl_async_ns  #(3) u_jsync_reg_4_2_period ( .din(jsync_reg_period_nxt[4:2]),
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l),
                                 .q (jsync_reg_period[4:2])
                               );

dffsl_async_ns  #(2) u_jsync_reg_1_0_period ( .din(jsync_reg_period_nxt[1:0]),
                                 .clk(jbus_clk),
                                 .set_l (io_pwron_rst_l),
                                 .q (jsync_reg_period[1:0])
                               );

assign  clsp_jsync_rd_vld = clsp_rd_req_vld_1sht  &  clsp_jsync_sel;
assign clsp_jsync_rd_bus= { 24'h000000,
                            jsync_reg_rx2[1:0],
                            1'b0,
                            jsync_reg_tx2[4:0],
                            jsync_reg_rx1[1:0],
                            1'b0,
                            jsync_reg_tx1[4:0],
                            jsync_reg_rx0[1:0],
                            1'b0,
                            jsync_reg_tx0[4:0],
                            3'b000,
                            jsync_reg_init[4:0],
                            3'b000,
                            jsync_reg_period[4:0]} & { 64 {clsp_jsync_rd_vld}};

//---------------------------------------------------------------------------
//
// Register : sync pulse (jbus_clk)
//
//---------------------------------------------------------------------------
// default 13:2
// DSYNC_RCV2 39:38  (default 1)
// DSYNC_TRN2 36:32  (default 4)
// DSYNC_RCV1 28:24  (default 10)
// DSYNC_TRN1 23:22  (default 2)
// DSYNC_RCV0 20:16  (default 4)
// DSYNC_TRN0 15:13  (default 1)
// DSYNC_INIT 12:8   (default 0)
// DSYNC_PERIOD 4:0  (default 12)


assign    dsync_reg_rx2_nxt  =  clsp_dsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[39:38]
                           :    dsync_reg_rx2;

dffrl_async_ns  u_dsync_reg_rx2_1_ff ( .din(dsync_reg_rx2_nxt[1]), 
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l), 
                                 .q (dsync_reg_rx2[1])
                               );

dffsl_async_ns  u_dsync_reg_rx2_0_ff ( .din(dsync_reg_rx2_nxt[0]), 
                                 .clk(jbus_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (dsync_reg_rx2[0])
                               );

assign    dsync_reg_tx2_nxt  =  clsp_dsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[36:32]
                           :    dsync_reg_tx2;

dffrl_async_ns  #(5) u_dsync_reg_tx2_4_0_ff ( .din(dsync_reg_tx2_nxt[4:0]), 
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l), 
                                 .q (dsync_reg_tx2[4:0])
                               );


assign    dsync_reg_rx1_nxt  =  clsp_dsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[31:30]
                           :    dsync_reg_rx1;

dffrl_async_ns  u_dsync_reg_rx1_1_ff ( .din(dsync_reg_rx1_nxt[1]), 
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l), 
                                 .q (dsync_reg_rx1[1])
                               );

dffsl_async_ns  u_dsync_reg_rx1_0_ff ( .din(dsync_reg_rx1_nxt[0]), 
                                 .clk(jbus_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (dsync_reg_rx1[0])
                               );

assign    dsync_reg_tx1_nxt  =  clsp_dsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[28:24]
                           :    dsync_reg_tx1;

dffrl_async_ns  #(5) u_dsync_reg_tx1_4_0_ff ( .din(dsync_reg_tx1_nxt[4:0]), 
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l), 
                                 .q (dsync_reg_tx1[4:0])
                               );


assign    dsync_reg_rx0_nxt  =  clsp_dsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[23:22]
                           :    dsync_reg_rx0;

dffrl_async_ns  u_dsync_reg_rx0_1_ff ( .din(dsync_reg_rx0_nxt[1]), 
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l), 
                                 .q (dsync_reg_rx0[1])
                               );

dffsl_async_ns  u_dsync_reg_rx0_0_ff ( .din(dsync_reg_rx0_nxt[0]), 
                                 .clk(jbus_clk),
                                 .set_l (io_pwron_rst_l), 
                                 .q (dsync_reg_rx0[0])
                               );

assign    dsync_reg_tx0_nxt  =  clsp_dsync_sel & clsp_wr_req_vld_d & rst_l  ? ucb_clsp_data_in_reg[20:16]
                           :    dsync_reg_tx0;

dffrl_async_ns  #(5) u_dsync_reg_tx0_4_0_ff ( .din(dsync_reg_tx0_nxt[4:0]), 
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l), 
                                 .q (dsync_reg_tx0[4:0])
                               );



assign    dsync_reg_init_nxt  =  clsp_dsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[12:8]
                           :     dsync_reg_init;

dffrl_async_ns  #(3) u_dsync_reg_4_2_init ( .din(dsync_reg_init_nxt[4:2]),
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l),
                                 .q (dsync_reg_init[4:2])
                               );

dffsl_async_ns      u_dsync_reg_1_init ( .din(dsync_reg_init_nxt[1]),
                                 .clk(jbus_clk),
                                 .set_l (io_pwron_rst_l),
                                 .q (dsync_reg_init[1])
				);

dffrl_async_ns       u_dsync_reg_0_init ( .din(dsync_reg_init_nxt[0]),
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l),
                                 .q (dsync_reg_init[0])
                               );

assign    dsync_reg_period_nxt  =  clsp_dsync_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[4:0]
                           :     dsync_reg_period;

dffrl_async_ns  #(3) u_dsync_reg_4_2_period ( .din(dsync_reg_period_nxt[4:2]),
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l),
                                 .q (dsync_reg_period[4:2])
                               );


dffsl_async_ns  #(2) u_dsync_reg_1_0_period ( .din(dsync_reg_period_nxt[1:0]),
                                 .clk(jbus_clk),
                                 .set_l (io_pwron_rst_l),
                                 .q (dsync_reg_period[1:0])
                               );

assign  clsp_dsync_rd_vld = clsp_rd_req_vld_1sht  &  clsp_dsync_sel;
assign clsp_dsync_rd_bus= { 24'h000000,
                            dsync_reg_rx2[1:0],
                            1'b0,
                            dsync_reg_tx2[4:0],
                            dsync_reg_rx1[1:0],
                            1'b0,
                            dsync_reg_tx1[4:0],
                            dsync_reg_rx0[1:0],
                            1'b0,
                            dsync_reg_tx0[4:0],
                            3'b000,
                            dsync_reg_init[4:0],
                            3'b000,
                            dsync_reg_period[4:0]} & { 64 {clsp_dsync_rd_vld}};

//---------------------------------------------------------------------------
//
// Register : clsp_dll_byp
//
//---------------------------------------------------------------------------
// DLL3_BYP_L [61]
// DLL3_BYP_DATA [60:56]
// DLL3_CTRL [52:48]

// DLL2_BYP_L [45]
// DLL2_BYP_DATA [44:40]
// DLL2_CTRL [36:32]

// DLL1_BYP_L [29]
// DLL1_BYP_DATA [28:24]
// DLL1_CTRL [20:16]

// DLL0_BYP_L [13]
// DLL0_BYP_DATA [12:8]
// DLL0_CTRL [4:0]


assign    ctu_dll3_byp_l_nxt =  clsp_dll_byp_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[61]
                             :  ctu_dll3_byp_l_jl;

dffsl_async_ns  u_ctu_dll3_byp_l ( .din(ctu_dll3_byp_l_nxt), 
                                .clk(jbus_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (ctu_dll3_byp_l_jl)
                              );

assign    ctu_dll2_byp_l_nxt =  clsp_dll_byp_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[45]
                             :  ctu_dll2_byp_l_jl;

dffsl_async_ns  u_ctu_dll2_byp_l ( .din(ctu_dll2_byp_l_nxt), 
                                .clk(jbus_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (ctu_dll2_byp_l_jl)
                              );

assign    ctu_dll1_byp_l_nxt =  clsp_dll_byp_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[29]
                             :  ctu_dll1_byp_l_jl;

dffsl_async_ns  u_ctu_dll1_byp_l ( .din(ctu_dll1_byp_l_nxt), 
                                .clk(jbus_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (ctu_dll1_byp_l_jl)
                              );

assign    ctu_dll0_byp_l_nxt =  clsp_dll_byp_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[13]
                             :  ctu_dll0_byp_l_jl;

dffsl_async_ns  u_ctu_dll0_byp_l ( .din(ctu_dll0_byp_l_nxt), 
                                .clk(jbus_clk),
                                .set_l (io_pwron_rst_l), 
                                .q (ctu_dll0_byp_l_jl)
                              );

assign    ctu_dll3_byp_val_nxt =  clsp_dll_byp_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[60:56]
                             :  ctu_dll3_byp_val_jl;

dffrl_async_ns #(5) u_ctu_dll3_byp_val ( .din(ctu_dll3_byp_val_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ctu_dll3_byp_val_jl)
                              );

assign    ctu_dll2_byp_val_nxt =  clsp_dll_byp_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[44:40]
                             :  ctu_dll2_byp_val_jl;

dffrl_async_ns #(5) u_ctu_dll2_byp_val ( .din(ctu_dll2_byp_val_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ctu_dll2_byp_val_jl)
                              );

assign    ctu_dll1_byp_val_nxt =  clsp_dll_byp_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[28:24]
                             :  ctu_dll1_byp_val_jl;

dffrl_async_ns #(5) u_ctu_dll1_byp_val ( .din(ctu_dll1_byp_val_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ctu_dll1_byp_val_jl)
                              );

assign    ctu_dll0_byp_val_nxt =  clsp_dll_byp_sel & clsp_wr_req_vld_d & rst_l ? ucb_clsp_data_in_reg[12:8]
                             :  ctu_dll0_byp_val_jl;

dffrl_async_ns #(5) u_ctu_dll0_byp_val ( .din(ctu_dll0_byp_val_nxt), 
                                .clk(jbus_clk),
                                .rst_l (io_pwron_rst_l), 
                                .q (ctu_dll0_byp_val_jl)
                              );



assign clsp_dll_byp_rd_vld = clsp_rd_req_vld_1sht  & clsp_dll_byp_sel; 

assign clsp_dll_byp_rd_bus = { 2'b00,
                               ctu_dll3_byp_l_jl,
                               ctu_dll3_byp_val_jl[4:0],
                               3'b000,
                               dll3_ctu_ctrl_jl[4:0],
                               2'b00,
                               ctu_dll2_byp_l_jl,
                               ctu_dll2_byp_val_jl[4:0],
                               3'b000,
                               dll2_ctu_ctrl_jl[4:0],
                               2'b00,
                               ctu_dll1_byp_l_jl,
                               ctu_dll1_byp_val_jl[4:0],
                               3'b000,
                               dll1_ctu_ctrl_jl[4:0],
                               2'b00,
                               ctu_dll0_byp_l_jl,
                               ctu_dll0_byp_val_jl[4:0],
                               3'b000,
                               dll0_ctu_ctrl_jl[4:0]
                              } &
                              { 64 {clsp_dll_byp_rd_vld }};
                      
//---------------------------------------------------------------------------
//
// Register : version
//
//---------------------------------------------------------------------------
// 63:48 Manufacture code
// 47:32 Implementation code
// 31:24 Mask code (major, minor)
// 18:16 Maximum index number  global register set
// 15:8  Max trap level support
//  4:0 Max index number for use as a valid CWP value


assign manufacture_code = `CLK_MAN_ID;
assign impl_code = `CLK_IMPL_CODE;
assign mask_id =  {mask_major_id[3:0],mask_minor_id[3:0]};
assign max_glb_reg = `CLK_MAX_GLB_REG;
assign max_trap_level = `CLK_MAX_TRAP_LEVEL;
assign max_cwp = `CLK_MAX_CWP;

assign  clsp_version_rd_vld = clsp_rd_req_vld_1sht  &  clsp_version_sel;

assign  clsp_version_rd_bus= { manufacture_code[15:0],
                               impl_code[15:0],
                               mask_id[7:0],
                               5'b00000,
                               max_glb_reg[2:0],
                               max_trap_level[7:0],
                               3'b000,
                               max_cwp[4:0]
                              } & {64 {clsp_version_rd_vld}};
assign ctu_spc_const_maskid = mask_id;

//---------------------------------------------------------------------------
//
//  Read bus 
//
//---------------------------------------------------------------------------



assign data_out = clsp_div_rd_bus |
                  clsp_ctrl_rd_bus |
                  clsp_jsync_rd_bus |
                  clsp_dll_ctrl_rd_bus |
                  clsp_dsync_rd_bus |
                  clsp_dll_byp_rd_bus |
		  clsp_version_rd_bus;


assign ucb_rd_ack_vld_nxt = (clsp_div_rd_vld | clsp_ctrl_rd_vld | clsp_dll_byp_rd_vld |
                            clsp_dll_ctrl_rd_vld |  clsp_version_rd_vld |
                             clsp_jsync_rd_vld  | clsp_dsync_rd_vld |  dbginit_rd_vld)  & rst_l ;

dffrl_async_ns u_ucb_rd_ack_vld (.din(  ucb_rd_ack_vld_nxt), 
                       .clk(jbus_clk),
                       .rst_l(io_pwron_rst_l),
                       .q (ucb_rd_ack_vld)
                      );

assign ucb_data_out_nxt =  ucb_rd_ack_vld_nxt ? data_out[63:0]: ucb_data_out[63:0];


dffrl_async_ns #(64) u_ucb_data_out_ff (.din( ucb_data_out_nxt[63:0]), 
                                  .clk(jbus_clk),
                                  .rst_l(io_pwron_rst_l),
                                  .q (ucb_data_out[63:0])
                                 );


//---------------------------------------------------------------------------
//
//  Waveform Generation
//
//---------------------------------------------------------------------------
function [14:0] f_div_vect;
  input [4:0] divisor;
begin
			   //  111 11
			   //  432 109 8765 4321 0
  case (divisor)  	   // 1175  4    3    1  0
    5'b00010: f_div_vect = 15'b000_001_0010_0001_1;// 2
    5'b00011: f_div_vect = 15'b100_001_1000_1000_0;// 3
    5'b00100: f_div_vect = 15'b000_001_0100_0100_0;// 4
    5'b00101: f_div_vect = 15'b100_001_1000_0010_0;// 5
    5'b00110: f_div_vect = 15'b001_001_0100_0010_0;// 6
    5'b00111: f_div_vect = 15'b100_001_1000_0001_0;// 7
    5'b01000: f_div_vect = 15'b000_001_0100_0001_0;// 8
    5'b01001: f_div_vect = 15'b100_001_0010_0001_0;// 9
    5'b01010: f_div_vect = 15'b000_001_0010_0001_0;// 10
    // align_edge generation changes here
    5'b01011: f_div_vect = 15'b100_100_0001_0001_0;// 11
    5'b01100: f_div_vect = 15'b000_100_0001_0001_0;// 12
    5'b01101: f_div_vect = 15'b110_010_0001_0001_0;// 13
    5'b01110: f_div_vect = 15'b010_010_0001_0001_0;// 14
    5'b01111: f_div_vect = 15'b111_001_0001_0001_0;// 15
    5'b10000: f_div_vect = 15'b011_001_0001_0001_0;// 16
    5'b10001: f_div_vect = 15'b110_001_0001_0001_0;// 17
    5'b10010: f_div_vect = 15'b010_001_0001_0001_0;// 18
    5'b10011: f_div_vect = 15'b100_010_0001_0001_0;// 19
    5'b10100: f_div_vect = 15'b000_010_0001_0001_0;// 20
    5'b10101: f_div_vect = 15'b101_001_0001_0001_0;// 21
    5'b10110: f_div_vect = 15'b001_001_0001_0001_0;// 22
    5'b10111: f_div_vect = 15'b100_001_0001_0001_0;// 23
    5'b11000: f_div_vect = 15'b000_001_0001_0001_0;// 24
    // not done below here
    // CoverMeter line_off  
     default: f_div_vect = 15'b000_001_0001_0001_0;// 4
    // CoverMeter line_on
  endcase
end
endfunction


   /************************************************************
    *Decoding clock divisor  for cmp clk
    ************************************************************/
   always @(/*AUTOSENSE*/reg_cdiv)
     begin 
       cdiv_vec_nxt = f_div_vect(reg_cdiv);
     end // always @ (reg_cdiv)

     dffrl_async_ns  #(5) u_cdiv_vec_14_10(.din( cdiv_vec_nxt[14:10]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_cdiv_vec[14:10])
                                       );

     dffsl_async_ns #(1) u_cdiv_vec_9 (.din( cdiv_vec_nxt[9]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (reg_cdiv_vec[9])
                                      );

     dffrl_async_ns #(1) u_cdiv_vec_8 (.din( cdiv_vec_nxt[8]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_cdiv_vec[8])
                                       );

     dffsl_async_ns #(1) u_cdiv_vec_7 (.din( cdiv_vec_nxt[7]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (reg_cdiv_vec[7])
                                      );

     dffrl_async_ns  #(3) u_cdiv_vec_6_4(.din( cdiv_vec_nxt[6:4]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_cdiv_vec[6:4])
                                       );

     dffsl_async_ns #(1) u_cdiv_vec_3(.din( cdiv_vec_nxt[3]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (reg_cdiv_vec[3])
                                       );

     dffrl_async_ns #(3) u_cdiv_vec_2_0(.din( cdiv_vec_nxt[2:0]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_cdiv_vec[2:0])
                                       );

   /************************************************************
    *Decoding clock divisor  for jbus clk
    ************************************************************/
   always @(/*AUTOSENSE*/reg_jdiv)
     begin 
       jdiv_vec_nxt = f_div_vect(reg_jdiv);
     end // always @ (reg_jdiv)

     dffrl_async_ns  #(1)  u_jdiv_vec_14(.din( jdiv_vec_nxt[14]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_jdiv_vec[14])
                                       );

     dffsl_async_ns #(2) u_jdiv_vec_13_12 (.din( jdiv_vec_nxt[13:12]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (reg_jdiv_vec[13:12])
                                       );

     dffrl_async_ns #(2) u_jdiv_vec_11_10(.din( jdiv_vec_nxt[11:10]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_jdiv_vec[11:10])
                                       );
     dffsl_async_ns #(1) u_jdiv_vec_9 (.din( jdiv_vec_nxt[9]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (reg_jdiv_vec[9])
                                       );

     dffrl_async_ns #(3) u_jdiv_vec_8_6(.din( jdiv_vec_nxt[8:6]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_jdiv_vec[8:6])
                                       );

     dffsl_async_ns #(1) u_jdiv_vec_5(.din( jdiv_vec_nxt[5]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (reg_jdiv_vec[5])
                                       );

     dffrl_async_ns #(3) u_jdiv_vec_4_2(.din( jdiv_vec_nxt[4:2]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_jdiv_vec[4:2])
                                       );

     dffsl_async_ns #(1) u_jdiv_vec_1(.din( jdiv_vec_nxt[1]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (reg_jdiv_vec[1])
                                       );

     dffrl_async_ns #(1) u_jdiv_vec_0(.din( jdiv_vec_nxt[0]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_jdiv_vec[0])
                                       );

   /************************************************************
    *Decoding clock divisor  for dram clk
    ************************************************************/
   always @(/*AUTOSENSE*/reg_ddiv)
     begin
       ddiv_vec_nxt = f_div_vect(reg_ddiv);
     end // always @ (reg_ddiv)

     dffrl_async_ns  #(1)  u_ddiv_vec_14(.din( ddiv_vec_nxt[14]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_ddiv_vec[14])
                                       );

     dffsl_async_ns #(2) u_ddiv_vec_13_12 (.din( ddiv_vec_nxt[13:12]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (reg_ddiv_vec[13:12])
                                       );

     dffrl_async_ns #(2) u_ddiv_vec_11_10(.din( ddiv_vec_nxt[11:10]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_ddiv_vec[11:10])
                                       );
     dffsl_async_ns #(1) u_ddiv_vec_9 (.din( ddiv_vec_nxt[9]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (reg_ddiv_vec[9])
                                       );

     dffrl_async_ns #(3) u_ddiv_vec_8_6(.din( ddiv_vec_nxt[8:6]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_ddiv_vec[8:6])
                                       );

     dffsl_async_ns #(1) u_ddiv_vec_5(.din( ddiv_vec_nxt[5]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (reg_ddiv_vec[5])
                                       );

     dffrl_async_ns #(3) u_ddiv_vec_4_2(.din( ddiv_vec_nxt[4:2]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_ddiv_vec[4:2])
                                       );

     dffsl_async_ns #(1) u_ddiv_vec_1(.din( ddiv_vec_nxt[1]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (reg_ddiv_vec[1])
                                       );

     dffrl_async_ns #(1) u_ddiv_vec_0(.din( ddiv_vec_nxt[0]),
                                      .clk(jbus_clk),
                                      .rst_l (io_pwron_rst_l),
                                      .q (reg_ddiv_vec[0])
                                       );

   /************************************************************
    *Decoding cnt value  for stretch_counter  
    ************************************************************/
   always @(/*AUTOSENSE*/clk_stretch_cnt_val)
     begin 
       stretch_cnt_vec_nxt = f_div_vect(clk_stretch_cnt_val[4:0]);
     end // always @ (reg_ddiv)

     dffrl_async_ns #(5) u_stretch_cnt_vec_14_10(.din( stretch_cnt_vec_nxt[14:10]),
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l),
                                 .q (stretch_cnt_vec_pre[14:10])
	                         );

     dffsl_async_ns #(1) u_stretch_cnt_vec_9 (.din( stretch_cnt_vec_nxt[9]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (stretch_cnt_vec_pre[9])
                                       );

     dffrl_async_ns #(7) u_stretch_cnt_vec_8_2(.din( stretch_cnt_vec_nxt[8:2]),
                                 .clk(jbus_clk),
                                 .rst_l (io_pwron_rst_l),
                                 .q (stretch_cnt_vec_pre[8:2])
	                         );

     dffsl_async_ns #(2) u_stretch_cnt_vec_1_0 (.din( stretch_cnt_vec_nxt[1:0]),
                                      .clk(jbus_clk),
                                      .set_l (io_pwron_rst_l),
                                      .q (stretch_cnt_vec_pre[1:0])
                                       );

   //assign stretch_cnt_vec[14:0] = se?  15'b000_0000_0000_0000 : stretch_cnt_vec_pre[14:0];
   assign se_bar = ~se;
   assign stretch_cnt_vec[14:0] =  {15 {se_bar}} & stretch_cnt_vec_pre[14:0];

//---------------------------------------------------------------------------
//
//   Sync edge generator
//
//---------------------------------------------------------------------------

assign mult_rst_l = bypclksel_sync? jbus_mult_rst_l : start_clk_early_jl ;


//dffsl_async_ns  u_cnt_ld(
dffsl_ns  u_cnt_ld(
                   .din (1'b0),
                   .clk (jbus_clk),
                   .set_l (start_clk_early_jl),
                   //.set_l (mult_rst_l),
                   .q(cnt_ld));

assign lcm_cnt_minus_1 = lcm_cnt - 10'h001;

assign lcm_cnt_nxt =  cnt_ld? shadreg_div_jmult[9:0]:
                      (|(lcm_cnt[9:1])) ?   lcm_cnt_minus_1  : 
                      shadreg_div_jmult[9:0];


//dffrl_async_ns #(10) u_lcm_ff (
dffrl_ns #(10) u_lcm_ff (
                   .din (lcm_cnt_nxt),
                   .clk (jbus_clk),
                   //.rst_l (start_clk_early_jl),
                   .rst_l (mult_rst_l),
                   .q(lcm_cnt));

assign lcm_cnt_zero =  ~(|(lcm_cnt[9:1]));

 /************************************************************
 *   Grst logic
 ************************************************************/

// -----------------------------------------
//
//  grst_l signal only allow to de-assert when grst_en_window is 1
//  jbus_grst_jl_l is set when the pipeline latency is reached and enable window is 1
//  jbus_grst_jl_l is reset by a_grst_cl
//
// -----------------------------------------


assign grst_en_window_nxt = de_grst_jsync_edge & lcm_cnt_zero ? 1'b1:
                            lcm_cnt_zero &  grst_en_window ? 1'b0:
                            grst_en_window;

dffrl_ns u_grst_en_window( .din (grst_en_window_nxt),
                   .clk (jbus_clk),
                   .rst_l (start_clk_jl),
                   .q(grst_en_window));


assign jbus_grst_jl_l_nxt  = a_grst_jl ? 1'b0:
                             (lcm_cnt == `JBUS_GLOBAL_LATENCY) & grst_en_window ?  1'b1:
                            jbus_grst_jl_l;

dffrl_ns u_jbus_grst_jl_l(
                   .din (jbus_grst_jl_l_nxt),
                   .clk (jbus_clk),
                   .rst_l(start_clk_jl),
                   .q(jbus_grst_jl_l));


// ----------------------------------------------------------------------
//
//  dbginit_l signal only allow to de-assert when dbginit_en_window is 1
//  (i.e. when  de_grst_cl | de_dbginit_cl is asserted)
//  dbginit_l signal is reset by a_grst_cl | a_dbginit_cl signal
//
// ---------------------------------------------------------------------


assign dbginit_en_window_nxt = de_dbginit_jsync_edge  &  lcm_cnt_zero  ? 1'b1:
                            lcm_cnt_zero  &  dbginit_en_window ? 1'b0:
                            dbginit_en_window;

dffrl_ns u_dbginit_en_window( .din (dbginit_en_window_nxt),
                   .clk (jbus_clk),
                   .rst_l (start_clk_jl),
                   .q(dbginit_en_window));

assign jbus_dbginit_jl_l_nxt  = 
                        (a_dbginit_jl | a_grst_jl)? 1'b0:
                        (lcm_cnt == `JBUS_GLOBAL_LATENCY) & dbginit_en_window? 1'b1:
                        jbus_dbginit_jl_l;

dffrl_ns u_jbus_dbginit_jl_l(
                   .din (jbus_dbginit_jl_l_nxt),
                   .clk (jbus_clk),
                   .rst_l(start_clk_jl),
                   .q(jbus_dbginit_jl_l));

//---------------------------------------------------------------------------
//
//   Clock stop id from jtag
//
//---------------------------------------------------------------------------

// jtag_clsp_stop_id needs to be stable for 3 cycles

   dffrl_async_ns u_jtag_clsp_stop_id_vld_dly(
                         .din (~jtag_clsp_stop_id_vld_jl),
                         .clk (jbus_clk),
                         .rst_l(io_pwron_rst_l),
                         .q (jtag_clsp_stop_id_vld_jl_dly_l)
                         );

   assign jtag_clsp_stop_id_vld_1sht = 
          jtag_clsp_stop_id_vld_jl & jtag_clsp_stop_id_vld_jl_dly_l & start_clk_jl;

   dffrl_async_ns u_stop_id_vld_dly(
                         .din (jtag_clsp_stop_id_vld_1sht),
                         .clk (jbus_clk),
                         .rst_l(io_pwron_rst_l),
                         .q (stop_id_vld_dly)
                         );

   dffrl_async_ns u_stop_id_vld_jl(
                         .din (stop_id_vld_dly),
                         .clk (jbus_clk),
                         .rst_l(io_pwron_rst_l),
                         .q (stop_id_vld_jl)
                         );

   assign new_id_nxt = jtag_clsp_stop_id_vld_1sht ? jtag_clsp_stop_id: new_id;

   dffrl_async_ns #(6) u_jtag_clsp_stop_vld(
                         .din (new_id_nxt),
                         .clk (jbus_clk),
                         .rst_l(io_pwron_rst_l),
                         .q (new_id)
                         );

   dffrl_async_ns #(`CCTRLSM_MAX_ST) u_stop_id_decoded(
                         .din (jtag_clsp_stop_id_decoded),
                         .clk (jbus_clk),
                         .rst_l(io_pwron_rst_l),
                         .q (stop_id_decoded)
                         );

 always @(new_id)
    case (new_id)
     `CTU_SPARC0_ID: jtag_clsp_stop_id_decoded =  `CTU_SPARC0_IDD;
     `CTU_SPARC1_ID: jtag_clsp_stop_id_decoded =  `CTU_SPARC1_IDD;
     `CTU_SPARC2_ID: jtag_clsp_stop_id_decoded =  `CTU_SPARC2_IDD;
     `CTU_SPARC3_ID: jtag_clsp_stop_id_decoded =  `CTU_SPARC3_IDD;
     `CTU_SPARC4_ID: jtag_clsp_stop_id_decoded =  `CTU_SPARC4_IDD;
     `CTU_SPARC5_ID: jtag_clsp_stop_id_decoded =  `CTU_SPARC5_IDD;
     `CTU_SPARC6_ID: jtag_clsp_stop_id_decoded =  `CTU_SPARC6_IDD;
     `CTU_SPARC7_ID: jtag_clsp_stop_id_decoded =  `CTU_SPARC7_IDD;
     `CTU_SCDATA0_ID: jtag_clsp_stop_id_decoded =  `CTU_SCDATA0_IDD;
     `CTU_SCDATA1_ID: jtag_clsp_stop_id_decoded =  `CTU_SCDATA1_IDD;
     `CTU_SCDATA2_ID: jtag_clsp_stop_id_decoded =  `CTU_SCDATA2_IDD;
     `CTU_SCDATA3_ID: jtag_clsp_stop_id_decoded =  `CTU_SCDATA3_IDD;
     `CTU_SCTAG0_ID: jtag_clsp_stop_id_decoded =  `CTU_SCTAG0_IDD;
     `CTU_SCTAG1_ID: jtag_clsp_stop_id_decoded =  `CTU_SCTAG1_IDD;
     `CTU_SCTAG2_ID: jtag_clsp_stop_id_decoded =  `CTU_SCTAG2_IDD;
     `CTU_SCTAG3_ID: jtag_clsp_stop_id_decoded =  `CTU_SCTAG3_IDD;
     `CTU_DRAM02_ID: jtag_clsp_stop_id_decoded =  `CTU_DRAM02_IDD;
     `CTU_DRAM13_ID: jtag_clsp_stop_id_decoded =  `CTU_DRAM13_IDD;
     `CTU_CCX_ID: jtag_clsp_stop_id_decoded =  `CTU_CCX_IDD;
     `CTU_FPU_ID: jtag_clsp_stop_id_decoded =  `CTU_FPU_IDD;
     `CTU_DDR0_ID: jtag_clsp_stop_id_decoded =  `CTU_DDR0_IDD;
     `CTU_DDR1_ID: jtag_clsp_stop_id_decoded =  `CTU_DDR1_IDD;
     `CTU_DDR2_ID: jtag_clsp_stop_id_decoded =  `CTU_DDR2_IDD;
     `CTU_DDR3_ID: jtag_clsp_stop_id_decoded =  `CTU_DDR3_IDD;
     `CTU_JBI_ID: jtag_clsp_stop_id_decoded =  `CTU_JBI_IDD;
     `CTU_JBUSR_ID: jtag_clsp_stop_id_decoded =  `CTU_JBUSR_IDD;
     `CTU_JBUSL_ID: jtag_clsp_stop_id_decoded =  `CTU_JBUSL_IDD;
     `CTU_IOB_ID: jtag_clsp_stop_id_decoded =  `CTU_IOB_IDD;
     `CTU_EFC_ID: jtag_clsp_stop_id_decoded =  `CTU_EFC_IDD;
     `CTU_DBG_ID: jtag_clsp_stop_id_decoded =  `CTU_DBG_IDD;
     `CTU_MISC_ID: jtag_clsp_stop_id_decoded =  `CTU_MISC_IDD;
  // CoverMeter line_off
      default : jtag_clsp_stop_id_decoded =  31'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
  // CoverMeter line_on
    endcase

//---------------------------------------------------------------------------
//
//   Synchronization/Multicycle path  checks 
//
//---------------------------------------------------------------------------

// synopsys translate_off
     reg [63:0]  prev_clsp_ctrl_rd_bus_cl;

     always @(clsp_ctrl_rd_bus_cl)
     begin
             prev_clsp_ctrl_rd_bus_cl <= clsp_ctrl_rd_bus_cl;
             $display("CHECK TIME %d\n",$stime);
            @(posedge `CTU_PATH.jbus_clk)
            begin
               $display("CHECK TIME2 %d\n",$stime);
               if( (rst_l === 1'b1) & 
                    (`CTU_PATH.testmode_l === 1'b1) & ( `CTU_PATH.pll_bypass === 1'b0) &
                    (prev_clsp_ctrl_rd_bus_cl !== 64'hx) &
                    (prev_clsp_ctrl_rd_bus_cl !== clsp_ctrl_rd_bus_cl) 
                 )
		`ifdef MODELSIM
             $display ( "CTU_mpath_check_error", "clsp_ctrl_rd_bus_cl should hold for at least 2 jbus cycles ");
		`else	 
             $error ( "CTU_mpath_check_error", "clsp_ctrl_rd_bus_cl should hold for at least 2 jbus cycles ");
		`endif
            end
            @(posedge `CTU_PATH.jbus_clk)
               if( (rst_l === 1'b1) & 
                   (`CTU_PATH.testmode_l === 1'b1) & ( `CTU_PATH.pll_bypass === 1'b0) &
                   (prev_clsp_ctrl_rd_bus_cl !== 64'hx) &
                   (prev_clsp_ctrl_rd_bus_cl !== clsp_ctrl_rd_bus_cl) 
                 )
		`ifdef MODELSIM
             $display ( "CTU_mpath_check_error", "clsp_ctrl_rd_bus_cl should hold for at least 2 jbus cycles");
		`else	 
             $error ( "CTU_mpath_check_error", "clsp_ctrl_rd_bus_cl should hold for at least 2 jbus cycles");
		`endif
    end 


     //jtag_clsp_stop_id should hold for at least 3 clocks 

     reg [5:0] prev_jtag_clsp_stop_id;

     always @(posedge jtag_clsp_stop_id_vld)
     begin
             prev_jtag_clsp_stop_id<= jtag_clsp_stop_id;
             @(posedge `CTU_PATH.jbus_clk)
             if( (start_clk_jl === 1'b1) & 
                 (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                 (prev_jtag_clsp_stop_id !== jtag_clsp_stop_id)
                )
		`ifdef MODELSIM
                $display ( "CTU_mpath_check_error", "jtag_clsp_stop_id should hold for at least 3 jbus cycles");
		`else		
                $error ( "CTU_mpath_check_error", "jtag_clsp_stop_id should hold for at least 3 jbus cycles");
		`endif
             @(posedge `CTU_PATH.jbus_clk)
             if( (start_clk_jl === 1'b1) & 
                 (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                 (prev_jtag_clsp_stop_id !== jtag_clsp_stop_id)
               )
		`ifdef MODELSIM
                $display ( "CTU_mpath_check_error", "jtag_clsp_stop_id should hold for at least 3 jbus cycles");
		`else		
                $error ( "CTU_mpath_check_error", "jtag_clsp_stop_id should hold for at least 3 jbus cycles");
		`endif
             @(posedge `CTU_PATH.jbus_clk)
             if( (start_clk_jl === 1'b1) & 
                 (`CTU_PATH.testmode_l === 1'b1) & (`CTU_PATH.pll_bypass === 1'b0) &
                 (prev_jtag_clsp_stop_id !== jtag_clsp_stop_id)
               )
		`ifdef MODELSIM
                $display ( "CTU_mpath_check_error", "jtag_clsp_stop_id should hold for at least 3 jbus cycles");
		`else		
                $error ( "CTU_mpath_check_error", "jtag_clsp_stop_id should hold for at least 3 jbus cycles");
		`endif
     end


// synopsys translate_on

endmodule
// Local Variables:
// verilog-library-directories:("." "../../common/rtl")
// verilog-library-files:      ("../../common/rtl/swrvr_clib.v")
// verilog-auto-sense-defines-constant:t
// End:
