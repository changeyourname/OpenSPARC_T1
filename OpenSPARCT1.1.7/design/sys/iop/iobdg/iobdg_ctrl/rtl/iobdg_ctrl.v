// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: iobdg_ctrl.v
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
//  Module Name:	iobdg_ctrl (IO Bridge control)
//  Description:	
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
module iobdg_ctrl (/*AUTOARG*/
   // Outputs
   tap_mondo_acc_addr_s, tap_mondo_acc_seq_s, tap_mondo_wr_s, 
   tap_mondo_din_s, iob_man_ucb_buf_acpt, iob_int_ucb_buf_acpt, 
   bounce_ucb_buf_acpt, rd_nack_ucb_buf_acpt, iob_man_int_vld, 
   iob_man_int_packet, iob_man_ack_vld, iob_man_ack_packet, 
   iob_int_ack_vld, iob_int_ack_packet, bounce_ack_vld, 
   bounce_ack_packet, rd_nack_vld, rd_nack_packet, cpu_intman_acc, 
   cpu_intctrl_acc, creg_intctrl_mask, creg_jintv_vec, 
   first_availcore, iob_ctu_coreavail, int_vec_addr, int_vec_din_raw, 
   int_vec_wr_l, int_cpu_addr, int_cpu_din_raw, int_cpu_wr_l, 
   creg_dbg_l2_vis_ctrl, creg_dbg_l2_vis_maska_s, 
   creg_dbg_l2_vis_maskb_s, creg_dbg_l2_vis_cmpa_s, 
   creg_dbg_l2_vis_cmpb_s, creg_dbg_l2_vis_trig_delay_s, 
   creg_dbg_iob_vis_ctrl, creg_dbg_enet_ctrl, creg_dbg_enet_idleval, 
   creg_dbg_jbus_ctrl, creg_dbg_jbus_lo_mask0, 
   creg_dbg_jbus_lo_mask1, creg_dbg_jbus_lo_cmp0, 
   creg_dbg_jbus_lo_cmp1, creg_dbg_jbus_lo_cnt0, 
   creg_dbg_jbus_lo_cnt1, creg_dbg_jbus_hi_mask0, 
   creg_dbg_jbus_hi_mask1, creg_dbg_jbus_hi_cmp0, 
   creg_dbg_jbus_hi_cmp1, creg_dbg_jbus_hi_cnt0, 
   creg_dbg_jbus_hi_cnt1, creg_margin_16x65, 
   // Inputs
   rst_l, arst_l, clk, sehold, tap_mondo_acc_addr_invld_d2_f, 
   tap_mondo_acc_seq_d2_f, tap_mondo_dout_d2_f, iob_man_ucb_sel, 
   iob_int_ucb_sel, bounce_ucb_sel, c2i_packet_vld, 
   c2i_packet_is_rd_req, c2i_packet_is_wr_req, c2i_packet, 
   rd_nack_ucb_sel, c2i_rd_nack_packet, iob_man_int_rd, 
   iob_man_ack_rd, iob_int_ack_rd, bounce_ack_rd, rd_nack_rd, 
   io_intman_addr, int_srvcd, int_srvcd_d1, clspine_iob_resetstat_wr, 
   clspine_iob_resetstat, ctu_iob_wake_thr, fuse_clk, 
   efc_iob_fuse_data, efc_iob_coreavail_dshift, 
   efc_iob_sernum0_dshift, efc_iob_sernum1_dshift, 
   efc_iob_sernum2_dshift, efc_iob_fusestat_dshift, io_temp_trig, 
   int_vec_dout_raw, int_cpu_dout_raw, l2_vis_armin
   );

////////////////////////////////////////////////////////////////////////
// Signal declarations
////////////////////////////////////////////////////////////////////////
   // Global interface
   input                                    rst_l;
   input 				    arst_l;
   input 				    clk;
   input 				    sehold;
 				    

   // c2i interface
   // Interrupt status table read/write from TAP
   output [`IOB_ADDR_WIDTH-1:0] 	    tap_mondo_acc_addr_s;
   output 				    tap_mondo_acc_seq_s;
   output 				    tap_mondo_wr_s;
   input 				    tap_mondo_acc_addr_invld_d2_f;
   input 				    tap_mondo_acc_seq_d2_f;
   output [63:0] 			    tap_mondo_din_s;
   input [63:0] 			    tap_mondo_dout_d2_f;

   
   // c2i interface
   // Accessing IOB control registers
   // Bounce back master request/ack
   // Read Nack
   input 				    iob_man_ucb_sel;
   output 				    iob_man_ucb_buf_acpt;

   input 				    iob_int_ucb_sel;
   output 				    iob_int_ucb_buf_acpt;
   
   input 				    bounce_ucb_sel;
   output 				    bounce_ucb_buf_acpt;

   input 				    c2i_packet_vld;
   input 				    c2i_packet_is_rd_req;
   input 				    c2i_packet_is_wr_req;
   input [`UCB_64PAY_PKT_WIDTH-1:0] 	    c2i_packet;

   input 				    rd_nack_ucb_sel;
   output 				    rd_nack_ucb_buf_acpt;
   
   input [`UCB_NOPAY_PKT_WIDTH-1:0] 	    c2i_rd_nack_packet;


   // i2c interface
   // Sending interrupts/Returning acks or nacks
   output 				    iob_man_int_vld;
   output [`UCB_INT_PKT_WIDTH-1:0] 	    iob_man_int_packet;
   
   output 				    iob_man_ack_vld;
   output [`UCB_64PAY_PKT_WIDTH-1:0] 	    iob_man_ack_packet;
  
   output 				    iob_int_ack_vld;
   output [`UCB_64PAY_PKT_WIDTH-1:0] 	    iob_int_ack_packet;
   
   output 				    bounce_ack_vld;
   output [`UCB_64PAY_PKT_WIDTH-1:0] 	    bounce_ack_packet;
   
   output 				    rd_nack_vld;
   output [`UCB_NOPAY_PKT_WIDTH-1:0] 	    rd_nack_packet;

   input 				    iob_man_int_rd;
   input 				    iob_man_ack_rd; 
   input 				    iob_int_ack_rd;
   input 				    bounce_ack_rd;
   input 				    rd_nack_rd;

   
   // i2c interface
   // Arbitrating INT_MAN table access
   output 				    cpu_intman_acc;
   output 				    cpu_intctrl_acc;
   input [`IOB_INT_TAB_INDEX-1:0] 	    io_intman_addr;
   input 				    int_srvcd;
   input 				    int_srvcd_d1;
   output 				    creg_intctrl_mask;

   output [`IOB_INT_VEC_WIDTH-1:0] 	    creg_jintv_vec;

   // Indicate which core to bounce off from when accessing L2 creg
   output [`IOB_CPU_WIDTH-1:0] 		    first_availcore;

   
   // clspine interface
   input 				    clspine_iob_resetstat_wr;
   input [`IOB_RESET_STAT_WIDTH-1:0] 	    clspine_iob_resetstat;
       
   
   // ctu interface
   output [`IOB_CPU_WIDTH-1:0] 		    iob_ctu_coreavail;
   input 				    ctu_iob_wake_thr;

   
   // efuse control interface
   input 				    fuse_clk;
   input 				    efc_iob_fuse_data;
   input 				    efc_iob_coreavail_dshift;
   input 				    efc_iob_sernum0_dshift;
   input 				    efc_iob_sernum1_dshift;
   input 				    efc_iob_sernum2_dshift;
   input 				    efc_iob_fusestat_dshift;
   
   // Pad interface
   input 				    io_temp_trig;

   
   // Interrupt vector table interface
   output [`IOB_INT_TAB_INDEX-1:0] 	    int_vec_addr;
   wire [`IOB_INT_VEC_WIDTH-1:0] 	    int_vec_din;
   output [14:0] 			    int_vec_din_raw;
   output 				    int_vec_wr_l;
   wire [`IOB_INT_VEC_WIDTH-1:0] 	    int_vec_dout;
   input [14:0] 			    int_vec_dout_raw;

   assign int_vec_din_raw = {{(15-`IOB_INT_VEC_WIDTH){1'b0}},int_vec_din};
   assign int_vec_dout = int_vec_dout_raw[`IOB_INT_VEC_WIDTH-1:0];

   
   // Interrupt CPU table interface
   output [`IOB_INT_TAB_INDEX-1:0] 	    int_cpu_addr;
   wire [`IOB_INT_CPU_WIDTH-1:0] 	    int_cpu_din;
   output [14:0] 			    int_cpu_din_raw;
   output 				    int_cpu_wr_l;
   wire [`IOB_INT_CPU_WIDTH-1:0] 	    int_cpu_dout;
   input [14:0] 			    int_cpu_dout_raw;

   assign int_cpu_din_raw = {{(15-`IOB_INT_CPU_WIDTH){1'b0}},int_cpu_din};
   assign int_cpu_dout = int_cpu_dout_raw[`IOB_INT_CPU_WIDTH-1:0];

   
   // Debug logic interface
   output [63:0] 			    creg_dbg_l2_vis_ctrl;
   output [63:0] 			    creg_dbg_l2_vis_maska_s;
   output [63:0] 			    creg_dbg_l2_vis_maskb_s;
   output [63:0] 			    creg_dbg_l2_vis_cmpa_s;
   output [63:0] 			    creg_dbg_l2_vis_cmpb_s;
   output [63:0] 			    creg_dbg_l2_vis_trig_delay_s;
   output [63:0] 			    creg_dbg_iob_vis_ctrl;
   output [63:0] 			    creg_dbg_enet_ctrl;
   output [63:0] 			    creg_dbg_enet_idleval;
   output [63:0] 			    creg_dbg_jbus_ctrl;
   output [63:0] 			    creg_dbg_jbus_lo_mask0;
   output [63:0] 			    creg_dbg_jbus_lo_mask1;
   output [63:0] 			    creg_dbg_jbus_lo_cmp0;
   output [63:0] 			    creg_dbg_jbus_lo_cmp1;
   output [63:0] 			    creg_dbg_jbus_lo_cnt0;
   output [63:0] 			    creg_dbg_jbus_lo_cnt1;
   output [63:0] 			    creg_dbg_jbus_hi_mask0;
   output [63:0] 			    creg_dbg_jbus_hi_mask1;
   output [63:0] 			    creg_dbg_jbus_hi_cmp0;
   output [63:0] 			    creg_dbg_jbus_hi_cmp1;
   output [63:0] 			    creg_dbg_jbus_hi_cnt0;
   output [63:0] 			    creg_dbg_jbus_hi_cnt1;

   input 				    l2_vis_armin;

   
   // Memory control register interface
   output [4:0]				    creg_margin_16x65;

   
   // Internal signals
   wire 				    iob_man_ucb_buf_acpt_d1;
   wire 				    iob_man_ucb_buf_acpt_d2;
   wire [`UCB_64PAY_PKT_WIDTH-1:0] 	    iob_man_ucb_c2i_packet;
   wire 				    iob_man_ucb_c2i_packet_is_rd_req;
   wire 				    iob_man_ucb_c2i_packet_is_wr_req;
   wire [`IOB_ADDR_WIDTH-1:0] 		    iob_man_ucb_c2i_packet_addr;
   wire [63:0] 				    iob_man_ucb_c2i_packet_data;
   wire 				    creg_intman_dec;
   wire 				    creg_intctrl_dec;
   wire 				    creg_intvecdisp_dec;
   wire 				    creg_resetstat_dec;
   wire 				    creg_sernum_dec;
   wire 				    creg_tmstatctrl_dec;
   wire 				    creg_coreavail_dec;
   wire 				    creg_fusestat_dec;
   wire 				    creg_jintv_dec;
   wire 				    creg_dbg_l2_vis_ctrl_dec;
   wire 				    creg_dbg_l2_vis_maska_dec;
   wire 				    creg_dbg_l2_vis_maskb_dec;
   wire 				    creg_dbg_l2_vis_cmpa_dec;
   wire 				    creg_dbg_l2_vis_cmpb_dec;
   wire 				    creg_dbg_l2_vis_trig_delay_dec;
   wire 				    creg_dbg_iob_vis_ctrl_dec;
   wire 				    creg_dbg_enet_ctrl_dec;
   wire 				    creg_dbg_enet_idleval_dec;
   wire 				    creg_dbg_jbus_ctrl_dec;
   wire 				    creg_dbg_jbus_lo_mask0_dec;
   wire 				    creg_dbg_jbus_lo_mask1_dec;
   wire 				    creg_dbg_jbus_lo_cmp0_dec;
   wire 				    creg_dbg_jbus_lo_cmp1_dec;
   wire 				    creg_dbg_jbus_lo_cnt0_dec;
   wire 				    creg_dbg_jbus_lo_cnt1_dec;
   wire 				    creg_dbg_jbus_hi_mask0_dec;
   wire 				    creg_dbg_jbus_hi_mask1_dec;
   wire 				    creg_dbg_jbus_hi_cmp0_dec;
   wire 				    creg_dbg_jbus_hi_cmp1_dec;
   wire 				    creg_dbg_jbus_hi_cnt0_dec;
   wire 				    creg_dbg_jbus_hi_cnt1_dec;
   wire 				    creg_margin_dec;
   wire 				    creg_nomatch;
   wire 				    iob_man_int_buf_wr;
   wire [`UCB_INT_PKT_WIDTH-1:0] 	    iob_man_int_buf_din;
   wire 				    iob_man_int_buf_vld;
   wire [`UCB_INT_PKT_WIDTH-1:0] 	    iob_man_int_buf_dout;
   wire 				    iob_man_int_buf_rd;
   wire 				    iob_man_int_buf_full;
   wire 				    iob_man_ack_buf_wr;
   wire [63:0] 				    iob_man_ack_i2c_packet_data;
   wire [`UCB_PKT_WIDTH-1:0] 		    iob_man_ack_i2c_packet_type;
   wire [`UCB_64PAY_PKT_WIDTH-1:0] 	    iob_man_ack_i2c_packet;
   wire [`UCB_64PAY_PKT_WIDTH-1:0] 	    iob_man_ack_buf_din;
   wire 				    iob_man_ack_buf_vld;
   wire [`UCB_64PAY_PKT_WIDTH-1:0] 	    iob_man_ack_buf_dout;
   wire 				    iob_man_ack_buf_rd;
   wire 				    iob_man_ack_buf_full;
   wire [`IOB_INT_TAB_INDEX-1:0] 	    cpu_intman_addr;
   wire 				    cpu_intman_acc;
   wire 				    int_vec_wr;
   wire [63:0] 				    creg_intman;
   wire 				    cpu_intctrl_acc_d1;
   wire 				    creg_intctrl_wr;
   wire [`IOB_INT_TAB_INDEX-1:0] 	    io_intman_addr_d1;
   wire [`IOB_INT_TAB_DEPTH-1:0] 	    intctrl_addr_dec;
   wire 				    creg_intctrl_mask;
   wire 				    creg_intctrl_pend;
   wire 				    creg_intctrl_mask_next;
   wire [`IOB_INT_TAB_DEPTH-1:0] 	    creg_intctrl_mask_en;
   wire [`IOB_INT_TAB_DEPTH-1:0] 	    creg_intctrl_mask_vec_next;
   wire [`IOB_INT_TAB_DEPTH-1:0] 	    creg_intctrl_mask_vec;
   wire 				    creg_intctrl_clear_next;
   wire 				    creg_intctrl_pend_next;
   wire [`IOB_INT_TAB_DEPTH-1:0] 	    creg_intctrl_pend_en;
   wire [`IOB_INT_TAB_DEPTH-1:0] 	    creg_intctrl_pend_vec_next;
   wire [`IOB_INT_TAB_DEPTH-1:0] 	    creg_intctrl_pend_vec;
   wire 				    intctrl_int_vld;
   wire [`UCB_INT_PKT_WIDTH-1:0] 	    intctrl_int;
   wire [63:0] 				    creg_intctrl;
   wire 				    creg_intvecdisp_wr;
   wire 				    intvecdisp_int_vld;
   wire [`IOB_INT_VEC_WIDTH-1:0] 	    intvecdisp_int_vec;
   wire [`IOB_CPU_INDEX+`IOB_THR_INDEX-1:0] intvecdisp_int_thr;
   reg [`UCB_PKT_WIDTH-1:0] 		    intvecdisp_int_type;
   wire [`UCB_INT_PKT_WIDTH-1:0] 	    intvecdisp_int;
   wire [63:0] 				    creg_intvecdisp;
   wire 				    creg_resetstat_hi_wr;
   wire [`IOB_RESET_STAT_WIDTH-1:0] 	    creg_resetstat_hi;
   wire 				    creg_resetstat_wr;
   wire 				    creg_resetstat_lo_wr;
   wire [`IOB_RESET_STAT_WIDTH-1:0] 	    creg_resetstat_lo_next;
   wire [`IOB_RESET_STAT_WIDTH-1:0] 	    creg_resetstat_lo;
   wire [63:0] 				    creg_resetstat;
   wire [`IOB_FUSE_WIDTH-1:0] 		    sernum0;
   wire [`IOB_FUSE_WIDTH-1:0] 		    sernum1;
   wire [`IOB_FUSE_WIDTH-1:0] 		    sernum2;
   wire [63:0] 				    creg_sernum;
   wire [63:0] 				    fusestat;
   wire [63:0]				    creg_fusestat;
   wire 				    creg_tmstatctrl_wr;
   wire [`IOB_CPU_WIDTH*`IOB_THR_WIDTH-1:0] creg_tmstatctrl_mask;
   wire 				    io_temp_trig_d1;
   wire 				    io_temp_trig_d2;
   wire 				    temp_trig_asserted;
   wire 				    temp_trig_assert;
   wire 				    temp_trig_deassert;
   wire 				    creg_tmstatctrl_therm_next;
   wire 				    creg_tmstatctrl_therm;
   wire [63:0] 				    creg_tmstatctrl;
   wire 				    therm_cycle_next;
   wire 				    therm_cycle;
   wire [`UCB_PKT_WIDTH-1:0] 		    therm_type_next;
   wire [`UCB_PKT_WIDTH-1:0] 		    therm_type;
   wire 				    therm_counter_inc;
   wire [`IOB_CPU_INDEX+`IOB_THR_INDEX-1:0] therm_counter_plus1;
   wire [`IOB_CPU_INDEX+`IOB_THR_INDEX-1:0] therm_counter;
   wire 				    therm_mask;
   wire 				    tmstatctrl_int_vld;
   wire [`UCB_INT_PKT_WIDTH-1:0] 	    tmstatctrl_int;
   wire [`IOB_FUSE_WIDTH-1:0] 		    coreavail;
   integer 				    i, j;
   reg [63:0] 				    creg_coreavail;
   wire 				    wake_thr;
   wire 				    firstthr_int_vld;
   wire [`IOB_CPUTHR_INDEX-1:0] 	    firstthr_int_thr;
   wire [`UCB_INT_PKT_WIDTH-1:0]	    firstthr_int;
   wire 				    creg_jintv_wr;
   wire [63:0] 				    creg_jintv;
   wire 				    creg_dbg_l2_vis_ctrl_wr;
   wire 				    creg_dbg_l2_vis_ctrl_en_next;
   wire 				    creg_dbg_l2_vis_ctrl_en;
   wire 				    creg_dbg_l2_vis_ctrl_trigen;
   wire 				    creg_dbg_l2_vis_maska_wr;
   wire [38:0] 				    creg_dbg_l2_vis_maska_bits;
   wire [63:0] 				    creg_dbg_l2_vis_maska;
   wire 				    creg_dbg_l2_vis_maskb_wr;
   wire [38:0] 				    creg_dbg_l2_vis_maskb_bits;
   wire [63:0] 				    creg_dbg_l2_vis_maskb;
   wire 				    creg_dbg_l2_vis_cmpa_wr;
   wire [38:0] 				    creg_dbg_l2_vis_cmpa_bits;
   wire [63:0] 				    creg_dbg_l2_vis_cmpa;
   wire 				    creg_dbg_l2_vis_cmpb_wr;
   wire [38:0] 				    creg_dbg_l2_vis_cmpb_bits;
   wire [63:0] 				    creg_dbg_l2_vis_cmpb;
   wire 				    creg_dbg_l2_vis_trig_delay_wr;
   wire [31:0] 				    creg_dbg_l2_vis_trig_delay_bits;
   wire [63:0] 				    creg_dbg_l2_vis_trig_delay;
   wire 				    creg_dbg_iob_vis_ctrl_wr;
   wire [3:0] 				    creg_dbg_iob_vis_ctrl_bits;
   wire 				    creg_dbg_enet_ctrl_wr;
   wire [4:0] 				    creg_dbg_enet_ctrl_bits_next;
   wire [4:0] 				    creg_dbg_enet_ctrl_bits;
   wire [1:0] 				    creg_dbg_enet_ctrl_rbits;
   wire 				    creg_dbg_enet_idleval_wr;
   wire [39:0] 				    creg_dbg_enet_idleval_bits;
   wire 				    creg_dbg_jbus_ctrl_wr;
   wire [6:0] 				    creg_dbg_jbus_ctrl_bits_next;
   wire [6:0] 				    creg_dbg_jbus_ctrl_bits;
   wire 				    creg_dbg_jbus_lo_mask0_wr;
   wire [45:0] 				    creg_dbg_jbus_lo_mask0_bits;
   wire 				    creg_dbg_jbus_lo_mask1_wr;
   wire [45:0] 				    creg_dbg_jbus_lo_mask1_bits;
   wire 				    creg_dbg_jbus_lo_cmp0_wr;
   wire [43:0] 				    creg_dbg_jbus_lo_cmp0_bits;
   wire 				    creg_dbg_jbus_lo_cmp1_wr;
   wire [43:0] 				    creg_dbg_jbus_lo_cmp1_bits;
   wire 				    creg_dbg_jbus_lo_cnt0_wr;
   wire [8:0] 				    creg_dbg_jbus_lo_cnt0_bits;
   wire 				    creg_dbg_jbus_lo_cnt1_wr;
   wire [8:0] 				    creg_dbg_jbus_lo_cnt1_bits;
   wire 				    creg_dbg_jbus_hi_mask0_wr;
   wire [45:0] 				    creg_dbg_jbus_hi_mask0_bits;
   wire 				    creg_dbg_jbus_hi_mask1_wr;
   wire [45:0] 				    creg_dbg_jbus_hi_mask1_bits;
   wire 				    creg_dbg_jbus_hi_cmp0_wr;
   wire [43:0] 				    creg_dbg_jbus_hi_cmp0_bits;
   wire 				    creg_dbg_jbus_hi_cmp1_wr;
   wire [43:0] 				    creg_dbg_jbus_hi_cmp1_bits;
   wire 				    creg_dbg_jbus_hi_cnt0_wr;
   wire [8:0] 				    creg_dbg_jbus_hi_cnt0_bits;
   wire 				    creg_dbg_jbus_hi_cnt1_wr;
   wire [8:0] 				    creg_dbg_jbus_hi_cnt1_bits;
   wire 				    creg_margin_wr;
   wire [4:0] 				    creg_margin_16x65_next;
   wire [63:0] 				    creg_margin;
   wire [`UCB_64PAY_PKT_WIDTH-1:0] 	    iob_int_ucb_c2i_packet;
   wire 				    iob_int_ucb_c2i_packet_is_rd_req;
   wire 				    iob_int_ucb_c2i_packet_is_wr_req;
   wire [63:0] 				    iob_int_ucb_c2i_packet_data;
   wire 				    tap_mondo_acc_seq_next;
   wire 				    tap_mondo_acc_seq;
   wire 				    tap_mondo_acc_addr_invld_d2;
   wire 				    tap_mondo_acc_seq_d2;
   wire [63:0] 				    tap_mondo_dout_d2;
   wire 				    tap_mondo_acc_outstanding;
   wire 				    tap_mondo_acc_outstanding_d1;
   wire 				    tap_mondo_rd_done;
   wire [`UCB_PKT_WIDTH-1:0] 		    iob_int_ucb_i2c_packet_type;
   wire [`UCB_64PAY_PKT_WIDTH-1:0] 	    iob_int_ucb_i2c_packet;
   wire 				    iob_int_ack_vld_next;

   wire 				    bounce_ack_buf_wr;
   wire [`UCB_64PAY_PKT_WIDTH-1:0] 	    bounce_ack_buf_din;
   wire 				    bounce_ack_buf_vld;
   wire [`UCB_64PAY_PKT_WIDTH-1:0] 	    bounce_ack_buf_dout;
   wire 				    bounce_ack_buf_rd;
   wire 				    bounce_ack_buf_full;

   wire 				    rd_nack_buf_wr;
   wire [`UCB_NOPAY_PKT_WIDTH-1:0] 	    rd_nack_buf_din;
   wire 				    rd_nack_buf_vld;
   wire [`UCB_NOPAY_PKT_WIDTH-1:0] 	    rd_nack_buf_dout;
   wire 				    rd_nack_buf_rd;
   wire 				    rd_nack_buf_full;
   
   
////////////////////////////////////////////////////////////////////////
// Code starts here
////////////////////////////////////////////////////////////////////////
   /*****************************************************************
    * iob_man_ucb
    * Access to IOBMAN space (0xD8) takes two cycles and is not pipelined.  
    *****************************************************************/
   // Flop c2i_packet
   assign       iob_man_ucb_buf_acpt = c2i_packet_vld & iob_man_ucb_sel &
	                               ~iob_man_ucb_buf_acpt_d1 &
	                               ~iob_man_ucb_buf_acpt_d2 &
		                       ~iob_man_int_buf_full &
		                       ~iob_man_ack_buf_full;
   
   dffrl_ns #(1) iob_man_ucb_buf_acpt_d1_ff (.din(iob_man_ucb_buf_acpt),
					     .clk(clk),
					     .rst_l(rst_l),
					     .q(iob_man_ucb_buf_acpt_d1));

   dffrl_ns #(1) iob_man_ucb_buf_acpt_d2_ff (.din(iob_man_ucb_buf_acpt_d1),
					     .clk(clk),
					     .rst_l(rst_l),
					     .q(iob_man_ucb_buf_acpt_d2));

   dffe_ns #(`UCB_64PAY_PKT_WIDTH) iob_man_ucb_c2i_packet_ff (.din(c2i_packet),
							      .en(iob_man_ucb_buf_acpt),
							      .clk(clk),
							      .q(iob_man_ucb_c2i_packet));

   dffe_ns #(1) iob_man_ucb_c2i_packet_is_rd_req_ff (.din(c2i_packet_is_rd_req),
						     .en(iob_man_ucb_buf_acpt),
						     .clk(clk),
						     .q(iob_man_ucb_c2i_packet_is_rd_req));

   dffe_ns #(1) iob_man_ucb_c2i_packet_is_wr_req_ff (.din(c2i_packet_is_wr_req),
						     .en(iob_man_ucb_buf_acpt),
						     .clk(clk),
						     .q(iob_man_ucb_c2i_packet_is_wr_req));

   assign 	iob_man_ucb_c2i_packet_addr = iob_man_ucb_c2i_packet[`UCB_ADDR_HI:`UCB_ADDR_LO];

   assign 	iob_man_ucb_c2i_packet_data = iob_man_ucb_c2i_packet[`UCB_DATA_HI:`UCB_DATA_LO];


   /*****************************************************************
    * Decoding here for requests directed to IOB registers
    *****************************************************************/
   // Assertion: decode signals must be mutually exclusive
   assign 	creg_intman_dec     = ((iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] & `IOB_DEV_ADDR_MASK) ==
				       `IOB_CREG_INTMAN);

   assign 	creg_intctrl_dec    = ((iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] & `IOB_DEV_ADDR_MASK) ==
				       `IOB_CREG_INTCTL);

   assign 	creg_intvecdisp_dec = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
				       `IOB_CREG_INTVECDISP);

   assign 	creg_resetstat_dec  = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
                                       `IOB_CREG_RESETSTAT);

   assign 	creg_sernum_dec     = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
                                       `IOB_CREG_SERNUM);
   
   assign 	creg_tmstatctrl_dec = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
                                       `IOB_CREG_TMSTATCTRL);

   assign 	creg_coreavail_dec  = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
                                       `IOB_CREG_COREAVAIL);
   
   assign 	creg_fusestat_dec  = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
                                       `IOB_CREG_FUSESTAT);
   
   assign 	creg_jintv_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
                                       `IOB_CREG_JINTV);
   
   assign 	creg_dbg_l2_vis_ctrl_dec       = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_L2VIS_CTRL);
   
   assign 	creg_dbg_l2_vis_maska_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_L2VIS_MASKA);
   
   assign 	creg_dbg_l2_vis_maskb_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_L2VIS_MASKB);
   
   assign 	creg_dbg_l2_vis_cmpa_dec       = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_L2VIS_CMPA);
   
   assign 	creg_dbg_l2_vis_cmpb_dec       = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_L2VIS_CMPB);
   
   assign 	creg_dbg_l2_vis_trig_delay_dec = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_L2VIS_TRIG);
   
   assign 	creg_dbg_iob_vis_ctrl_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_IOBVIS_CTRL);
   
   assign 	creg_dbg_enet_ctrl_dec         = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_ENET_CTRL);
   
   assign 	creg_dbg_enet_idleval_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_ENET_IDLEVAL);
   
   assign 	creg_dbg_jbus_ctrl_dec         = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_CTRL);
   
   assign 	creg_dbg_jbus_lo_mask0_dec     = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_LO_MASK0);
   
   assign 	creg_dbg_jbus_lo_mask1_dec     = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_LO_MASK1);
   
   assign 	creg_dbg_jbus_lo_cmp0_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_LO_CMP0);
   
   assign 	creg_dbg_jbus_lo_cmp1_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_LO_CMP1);
   
   assign 	creg_dbg_jbus_lo_cnt0_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_LO_CNT0);
   
   assign 	creg_dbg_jbus_lo_cnt1_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_LO_CNT1);

   assign 	creg_dbg_jbus_hi_mask0_dec     = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_HI_MASK0);
   
   assign 	creg_dbg_jbus_hi_mask1_dec     = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_HI_MASK1);
   
   assign 	creg_dbg_jbus_hi_cmp0_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_HI_CMP0);
   
   assign 	creg_dbg_jbus_hi_cmp1_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_HI_CMP1);
   
   assign 	creg_dbg_jbus_hi_cnt0_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_HI_CNT0);
   
   assign 	creg_dbg_jbus_hi_cnt1_dec      = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
						  `IOB_CREG_DBG_JBUS_HI_CNT1);

   assign 	creg_margin_dec   = (iob_man_ucb_c2i_packet_addr[`IOB_LOCAL_ADDR_WIDTH-1:0] ==
                                     `IOB_CREG_MARGIN);
   

   // Send nack if address doesn't match any register
   assign 	creg_nomatch = ~(creg_intman_dec |
				 creg_intctrl_dec |
				 creg_intvecdisp_dec |
                                 creg_resetstat_dec |
                                 creg_sernum_dec |
				 creg_tmstatctrl_dec |
				 creg_coreavail_dec |
				 creg_fusestat_dec |
				 creg_jintv_dec |
				 creg_dbg_l2_vis_ctrl_dec |
				 creg_dbg_l2_vis_maska_dec |
				 creg_dbg_l2_vis_maskb_dec |
				 creg_dbg_l2_vis_cmpa_dec |
				 creg_dbg_l2_vis_cmpb_dec |
				 creg_dbg_l2_vis_trig_delay_dec |
				 creg_dbg_iob_vis_ctrl_dec |
				 creg_dbg_enet_ctrl_dec |
				 creg_dbg_enet_idleval_dec |
				 creg_dbg_jbus_ctrl_dec |
				 creg_dbg_jbus_lo_mask0_dec |
				 creg_dbg_jbus_lo_mask1_dec |
				 creg_dbg_jbus_lo_cmp0_dec |
				 creg_dbg_jbus_lo_cmp1_dec |
				 creg_dbg_jbus_lo_cnt0_dec |
				 creg_dbg_jbus_lo_cnt1_dec |
				 creg_dbg_jbus_hi_mask0_dec |
				 creg_dbg_jbus_hi_mask1_dec |
				 creg_dbg_jbus_hi_cmp0_dec |
				 creg_dbg_jbus_hi_cmp1_dec |
				 creg_dbg_jbus_hi_cnt0_dec |
				 creg_dbg_jbus_hi_cnt1_dec |
				 creg_margin_dec);

   // Double buffer for iob_man_int
   // Assertion: firstthr_int_vld AND intctrl_int_vld AND intvecdisp_int_vld AND tmstatctrl_int_vld
   //            are mutually exclusive.
   assign 	iob_man_int_buf_wr = firstthr_int_vld | intctrl_int_vld |
                                     intvecdisp_int_vld | tmstatctrl_int_vld;

   assign 	iob_man_int_buf_din = firstthr_int_vld   ? firstthr_int :
		                      intctrl_int_vld    ? intctrl_int :
		                      intvecdisp_int_vld ? intvecdisp_int :
	           	              tmstatctrl_int_vld ? tmstatctrl_int :
		                                           `UCB_INT_PKT_WIDTH'b0;
   
   dbl_buf #(`UCB_INT_PKT_WIDTH) iob_man_int_buf (.rst_l(rst_l),
						  .clk(clk),
						  .wr(iob_man_int_buf_wr),
						  .din(iob_man_int_buf_din),
						  .vld(iob_man_int_buf_vld),
						  .dout(iob_man_int_buf_dout),
						  .rd(iob_man_int_buf_rd),
						  .full(iob_man_int_buf_full));

   assign 	iob_man_int_vld = iob_man_int_buf_vld;

   assign 	iob_man_int_packet = iob_man_int_buf_dout;
   
   assign 	iob_man_int_buf_rd = iob_man_int_rd;
   
   
   // Double buffer for iob_man_ack
   assign 	iob_man_ack_buf_wr = iob_man_ucb_buf_acpt_d2 & iob_man_ucb_c2i_packet_is_rd_req;


   assign 	iob_man_ack_i2c_packet_data =
		({64{creg_intman_dec}}     & creg_intman) |
		({64{creg_intctrl_dec}}    & creg_intctrl) |
		({64{creg_intvecdisp_dec}} & creg_intvecdisp) |
		({64{creg_resetstat_dec}}  & creg_resetstat) |
		({64{creg_sernum_dec}}     & creg_sernum) |
		({64{creg_tmstatctrl_dec}} & creg_tmstatctrl) |
		({64{creg_coreavail_dec}}  & creg_coreavail) |
		({64{creg_fusestat_dec}}   & creg_fusestat) |
		({64{creg_jintv_dec}}      & creg_jintv) |
		({64{creg_dbg_l2_vis_ctrl_dec}}       & creg_dbg_l2_vis_ctrl) |
		({64{creg_dbg_l2_vis_maska_dec}}      & creg_dbg_l2_vis_maska) |
		({64{creg_dbg_l2_vis_maskb_dec}}      & creg_dbg_l2_vis_maskb) |
		({64{creg_dbg_l2_vis_cmpa_dec}}       & creg_dbg_l2_vis_cmpa) |
		({64{creg_dbg_l2_vis_cmpb_dec}}       & creg_dbg_l2_vis_cmpb) |
		({64{creg_dbg_l2_vis_trig_delay_dec}} & creg_dbg_l2_vis_trig_delay) |
		({64{creg_dbg_iob_vis_ctrl_dec}}      & creg_dbg_iob_vis_ctrl) |
		({64{creg_dbg_enet_ctrl_dec}}         & creg_dbg_enet_ctrl) |
		({64{creg_dbg_enet_idleval_dec}}      & creg_dbg_enet_idleval) |
		({64{creg_dbg_jbus_ctrl_dec}}         & creg_dbg_jbus_ctrl) |
		({64{creg_dbg_jbus_lo_mask0_dec}}     & creg_dbg_jbus_lo_mask0) |
		({64{creg_dbg_jbus_lo_mask1_dec}}     & creg_dbg_jbus_lo_mask1) |
		({64{creg_dbg_jbus_lo_cmp0_dec}}      & creg_dbg_jbus_lo_cmp0) |
		({64{creg_dbg_jbus_lo_cmp1_dec}}      & creg_dbg_jbus_lo_cmp1) |
		({64{creg_dbg_jbus_lo_cnt0_dec}}      & creg_dbg_jbus_lo_cnt0) |
		({64{creg_dbg_jbus_lo_cnt1_dec}}      & creg_dbg_jbus_lo_cnt1) |
		({64{creg_dbg_jbus_hi_mask0_dec}}     & creg_dbg_jbus_hi_mask0) |
		({64{creg_dbg_jbus_hi_mask1_dec}}     & creg_dbg_jbus_hi_mask1) |
		({64{creg_dbg_jbus_hi_cmp0_dec}}      & creg_dbg_jbus_hi_cmp0) |
		({64{creg_dbg_jbus_hi_cmp1_dec}}      & creg_dbg_jbus_hi_cmp1) |
		({64{creg_dbg_jbus_hi_cnt0_dec}}      & creg_dbg_jbus_hi_cnt0) |
		({64{creg_dbg_jbus_hi_cnt1_dec}}      & creg_dbg_jbus_hi_cnt1) |
		({64{creg_margin_dec}}                & creg_margin);

   assign 	iob_man_ack_i2c_packet_type = creg_nomatch ? `UCB_READ_NACK : `UCB_READ_ACK;
   
   assign 	iob_man_ack_i2c_packet = {iob_man_ack_i2c_packet_data,
					  `UCB_RSV_WIDTH'b0,
					  `UCB_ADDR_WIDTH'b0,
					  `UCB_SIZE_WIDTH'b0,
					  iob_man_ucb_c2i_packet[`UCB_BUF_HI:`UCB_BUF_LO],
					  iob_man_ucb_c2i_packet[`UCB_THR_HI:`UCB_THR_LO],
					  iob_man_ack_i2c_packet_type};
   
   assign 	iob_man_ack_buf_din = iob_man_ack_i2c_packet;
   
   dbl_buf #(`UCB_64PAY_PKT_WIDTH) iob_man_ack_buf (.rst_l(rst_l),
						    .clk(clk),
						    .wr(iob_man_ack_buf_wr),
						    .din(iob_man_ack_buf_din),
						    .vld(iob_man_ack_buf_vld),
						    .dout(iob_man_ack_buf_dout),
						    .rd(iob_man_ack_buf_rd),
						    .full(iob_man_ack_buf_full));

   assign  	 iob_man_ack_vld = iob_man_ack_buf_vld;

   assign 	 iob_man_ack_packet = iob_man_ack_buf_dout;
   
   assign 	 iob_man_ack_buf_rd = iob_man_ack_rd;
   

   /*****************************************************************
    * IOB Interrupt Management Register
    * IOB Interrupt Control Register
    *****************************************************************/
   assign 	 cpu_intman_addr = iob_man_ucb_c2i_packet_addr[`IOB_INT_TAB_INDEX-1+3:3];

   // Setup array access in cycle 1
   assign 	cpu_intman_acc = iob_man_ucb_buf_acpt_d1 & creg_intman_dec;
   
   assign 	cpu_intctrl_acc = iob_man_ucb_buf_acpt_d1 & creg_intctrl_dec;
   
   assign 	int_vec_addr = (cpu_intman_acc|cpu_intctrl_acc) ? cpu_intman_addr : io_intman_addr; 
   
   assign 	int_vec_din = iob_man_ucb_c2i_packet_data[`IOB_INT_VEC_HI:`IOB_INT_VEC_LO];
   
   assign 	int_vec_wr =  cpu_intman_acc & iob_man_ucb_c2i_packet_is_wr_req;
   
   assign 	int_vec_wr_l = ~int_vec_wr;

   assign 	int_cpu_addr = int_vec_addr;

   assign 	int_cpu_din = iob_man_ucb_c2i_packet_data[`IOB_INT_CPU_HI:`IOB_INT_CPU_LO];
   
   assign       int_cpu_wr_l = int_vec_wr_l;

   assign 	creg_intman = {51'b0,         // reserved         [63:13]
			       int_cpu_dout,  // interrupt cpu ID [12:8]
			       2'b0,          // reserved         [7:6]
			       int_vec_dout}; // interrupt vector [5:0]
   
   // Access FF in cycle 2
   dffrl_ns #(1) cpu_intctrl_acc_d1_ff (.din(cpu_intctrl_acc),
					.clk(clk),
					.rst_l(rst_l),
					.q(cpu_intctrl_acc_d1));
   
   assign 	creg_intctrl_wr = iob_man_ucb_buf_acpt_d2 & creg_intctrl_dec &
		                  iob_man_ucb_c2i_packet_is_wr_req;
   
   dff_ns #(`IOB_INT_TAB_INDEX) io_intman_addr_d1_ff (.din(io_intman_addr),
						      .clk(clk),
						      .q(io_intman_addr_d1));
   
   assign 	intctrl_addr_dec = 1'b1 << (cpu_intctrl_acc_d1 ? cpu_intman_addr : io_intman_addr_d1);

   assign 	creg_intctrl_mask = |((creg_intctrl_mask_vec & ~(1'b1<<`DUMMY_DEV_ID)) & intctrl_addr_dec);
   assign 	creg_intctrl_pend = |((creg_intctrl_pend_vec & ~(1'b1<<`DUMMY_DEV_ID)) & intctrl_addr_dec);

   assign 	creg_intctrl_mask_next = int_srvcd_d1 ? 1'b1 :
                                                        (iob_man_ucb_c2i_packet_data[`IOB_INT_MASK] |
							 creg_intctrl_pend);
   assign 	creg_intctrl_mask_en = intctrl_addr_dec & {`IOB_INT_TAB_DEPTH{creg_intctrl_wr|int_srvcd_d1}};
   assign 	creg_intctrl_mask_vec_next = {`IOB_INT_TAB_DEPTH{~rst_l}} |
		                             (creg_intctrl_mask_en & {`IOB_INT_TAB_DEPTH{creg_intctrl_mask_next}}) |
					     (~creg_intctrl_mask_en & creg_intctrl_mask_vec);

   dff_ns #(`IOB_INT_TAB_DEPTH) creg_intctrl_mask_vec_ff (.din(creg_intctrl_mask_vec_next),
							  .clk(clk),
							  .q(creg_intctrl_mask_vec));

   assign 	creg_intctrl_clear_next = iob_man_ucb_c2i_packet_data[`IOB_INT_CLEAR];
   
   // Assert: creg_intctrl_wr AND int_srvcd_d1 are mutually exclusive
   assign 	creg_intctrl_pend_next = int_srvcd_d1 ? creg_intctrl_mask :
		                                        (~creg_intctrl_clear_next &
							 iob_man_ucb_c2i_packet_data[`IOB_INT_MASK] &
							 creg_intctrl_pend);
   assign 	creg_intctrl_pend_en = intctrl_addr_dec & {`IOB_INT_TAB_DEPTH{creg_intctrl_wr|int_srvcd_d1}};
   assign 	creg_intctrl_pend_vec_next = (creg_intctrl_pend_en & {`IOB_INT_TAB_DEPTH{creg_intctrl_pend_next}}) |
					     (~creg_intctrl_pend_en & creg_intctrl_pend_vec);

   dffrl_ns #(`IOB_INT_TAB_DEPTH) creg_intctrl_pend_vec_ff (.din(creg_intctrl_pend_vec_next),
							    .clk(clk),
							    .rst_l(rst_l),
							    .q(creg_intctrl_pend_vec));
   
   assign 	intctrl_int_vld = creg_intctrl_wr &
		                  ~iob_man_ucb_c2i_packet_data[`IOB_INT_MASK] & creg_intctrl_pend & ~creg_intctrl_clear_next;

   assign 	intctrl_int = {`UCB_INT_RSV_WIDTH'b0,
			       int_vec_dout,
			       `UCB_INT_STAT_WIDTH'b0,
			       `DUMMY_DEV_ID,
			       1'b0,int_cpu_dout,
			       `UCB_INT_VEC};

   assign 	creg_intctrl = {61'b0,              // reserved [63:3]
				creg_intctrl_mask,  // mask    [2]
				1'b0,               // clear   [1]
				creg_intctrl_pend}; // pend    [0]

   
   /*****************************************************************
    * IOB Remote Interrupt Vector Dispatch Register
    *****************************************************************/
   assign 	creg_intvecdisp_wr = iob_man_ucb_buf_acpt_d2 &
		                     iob_man_ucb_c2i_packet_is_wr_req &
		                     creg_intvecdisp_dec;

   assign 	intvecdisp_int_vld = creg_intvecdisp_wr;

   assign 	intvecdisp_int_vec = iob_man_ucb_c2i_packet_data[`IOB_DISP_VEC_HI:`IOB_DISP_VEC_LO];
   
   assign 	intvecdisp_int_thr = iob_man_ucb_c2i_packet_data[`IOB_DISP_THR_HI:`IOB_DISP_THR_LO];

   always @(/*AUTOSENSE*/iob_man_ucb_c2i_packet_data)
     case (iob_man_ucb_c2i_packet_data[`IOB_DISP_TYPE_HI:`IOB_DISP_TYPE_LO])
       2'b00: intvecdisp_int_type = `UCB_INT_VEC;
       2'b01: intvecdisp_int_type = `UCB_RESET_VEC;
       2'b10: intvecdisp_int_type = `UCB_IDLE_VEC;
       2'b11: intvecdisp_int_type = `UCB_RESUME_VEC;
     endcase // case(iob_man_ucb_c2i_packet_data[`IOB_DISP_TYPE_HI:`IOB_DISP_TYPE_LO])
     
   assign 	intvecdisp_int = {`UCB_INT_RSV_WIDTH'b0,
				  intvecdisp_int_vec,
				  `UCB_INT_STAT_WIDTH'b0,
				  `DUMMY_DEV_ID,
				  1'b0,intvecdisp_int_thr,
				  intvecdisp_int_type};

   // No real storage for this one, just read back zeros.
   assign 	creg_intvecdisp = 64'b0;

   
   /*****************************************************************
    * IOB Chip Reset Status Register
    *****************************************************************/
   // Can be written by software or by the clspine unit
   // Reset Status Hi
   assign 	creg_resetstat_hi_wr = clspine_iob_resetstat_wr;
   
   dffe_ns #(`IOB_RESET_STAT_WIDTH) creg_resetstat_hi_ff (.din(creg_resetstat_lo),
							  .en(creg_resetstat_hi_wr),
							  .clk(clk),
							  .q(creg_resetstat_hi));

   // Reset Status Lo
   assign 	creg_resetstat_wr = iob_man_ucb_buf_acpt_d2 &
		                    iob_man_ucb_c2i_packet_is_wr_req &
		                    creg_resetstat_dec;
   
   assign 	creg_resetstat_lo_wr = clspine_iob_resetstat_wr | creg_resetstat_wr;

   assign 	creg_resetstat_lo_next =
                clspine_iob_resetstat_wr ? clspine_iob_resetstat :
		                           iob_man_ucb_c2i_packet_data[`IOB_RESET_STAT_HI:`IOB_RESET_STAT_LO];
          
   dffe_ns #(`IOB_RESET_STAT_WIDTH) creg_resetstat_lo_ff (.din(creg_resetstat_lo_next),
							  .en(creg_resetstat_lo_wr),
							  .clk(clk),
							  .q(creg_resetstat_lo));
   
   assign 	creg_resetstat = {52'b0,                   // reserved       [63:12]
                                  creg_resetstat_hi,       // shadow status  [11:9]
                                  5'b0,                    // reserved       [8:4]
                                  creg_resetstat_lo,       // current status [3:1]
                                  1'b0};                   // rsvd           [0]

   
   /*****************************************************************
    * IOB Processor Serial Number Register
    *****************************************************************/
   iobdg_efuse_reg #(`IOB_FUSE_WIDTH) sernum0_reg (.arst_l(arst_l),
						   .fuse_clk(fuse_clk),
						   .data_in(efc_iob_fuse_data),
						   .shift_en(efc_iob_sernum0_dshift),
						   .fuse_reg(sernum0));

   iobdg_efuse_reg #(`IOB_FUSE_WIDTH) sernum1_reg (.arst_l(arst_l),
						   .fuse_clk(fuse_clk),
						   .data_in(efc_iob_fuse_data),
						   .shift_en(efc_iob_sernum1_dshift),
						   .fuse_reg(sernum1));

   iobdg_efuse_reg #(`IOB_FUSE_WIDTH) sernum2_reg (.arst_l(arst_l),
						   .fuse_clk(fuse_clk),
						   .data_in(efc_iob_fuse_data),
						   .shift_en(efc_iob_sernum2_dshift),
						   .fuse_reg(sernum2));

   // Upper unused bits will be dropped
   assign 	creg_sernum = {sernum2,sernum1,sernum0};

   
   /*****************************************************************
    * IOB Fuse Status Register
    *****************************************************************/
   iobdg_efuse_reg #(64) fusestat_reg (.arst_l(arst_l),
				       .fuse_clk(fuse_clk),
				       .data_in(efc_iob_fuse_data),
				       .shift_en(efc_iob_fusestat_dshift),
				       .fuse_reg(fusestat));

   assign 	creg_fusestat = fusestat;

   
   /*****************************************************************
    * IOB Thermal Status/Control Register
    *****************************************************************/
   assign 	creg_tmstatctrl_wr = iob_man_ucb_buf_acpt_d2 &
		                     iob_man_ucb_c2i_packet_is_wr_req &
		                     creg_tmstatctrl_dec;
   
   dffrle_ns #(`IOB_CPU_WIDTH*`IOB_THR_WIDTH) creg_tmstatctrl_mask_ff (.din(iob_man_ucb_c2i_packet_data[`IOB_CPU_WIDTH*`IOB_THR_WIDTH-1:0]),
								       .rst_l(rst_l),
								       .en(creg_tmstatctrl_wr),
								       .clk(clk),
								       .q(creg_tmstatctrl_mask));

   // flop io_temp_trig twice before using it
   dffrl_ns #(1) io_temp_trig_d1_ff (.din(io_temp_trig),
				     .clk(clk),
				     .rst_l(rst_l),
				     .q(io_temp_trig_d1));

   dffrl_ns #(1) io_temp_trig_d2_ff (.din(io_temp_trig_d1),
				     .clk(clk),
				     .rst_l(rst_l),
				     .q(io_temp_trig_d2));

   
   dffrle_ns #(1) temp_trig_asserted_ff (.din(temp_trig_assert),
				     	 .rst_l(rst_l),
					 .en(temp_trig_assert|temp_trig_deassert),
				     	 .clk(clk),
				     	 .q(temp_trig_asserted));
					
   assign 	temp_trig_assert = io_temp_trig_d2 & ~temp_trig_asserted & ~therm_cycle;
   
   assign 	temp_trig_deassert = ~io_temp_trig_d2 & temp_trig_asserted & ~therm_cycle;

   assign 	creg_tmstatctrl_therm_next = iob_man_ucb_c2i_packet_data[`IOB_TMSTAT_THERM] |
		                             temp_trig_assert;
   
   dffrle_ns #(1) creg_tmstatctrl_therm_ff (.din(creg_tmstatctrl_therm_next),
					    .rst_l(rst_l),
					    .en(creg_tmstatctrl_wr|temp_trig_assert),
					    .clk(clk),
					    .q(creg_tmstatctrl_therm));
   
   assign 	creg_tmstatctrl = {creg_tmstatctrl_therm,
				   31'b0,
				   creg_tmstatctrl_mask};


   // Generate IDLE or RESUME requests
   assign 	therm_cycle_next = (temp_trig_assert | temp_trig_deassert | therm_cycle) &
				     ~(therm_counter_inc & (&therm_counter));
   
   dffrl_ns #(1) therm_cycle_ff (.din(therm_cycle_next),
                                 .clk(clk),
                                 .rst_l(rst_l),
                                 .q(therm_cycle));

   assign 	therm_type_next = temp_trig_assert ? `UCB_IDLE_VEC : `UCB_RESUME_VEC;

   dffe_ns #(`UCB_PKT_WIDTH) therm_type_ff (.din(therm_type_next),
					    .en(temp_trig_assert|temp_trig_deassert),
					    .clk(clk),
					    .q(therm_type));

   assign 	therm_counter_inc = therm_cycle &
		                    (~therm_mask |
		                     (~firstthr_int_vld & ~intctrl_int_vld & ~intvecdisp_int_vld &
		                      ~iob_man_int_buf_vld));
		
   assign 	therm_counter_plus1 = therm_counter + 1'b1;

   dffrle_ns #(`IOB_CPU_INDEX+`IOB_THR_INDEX) therm_counter_ff (.din(therm_counter_plus1),
								.rst_l(rst_l),
								.en(therm_counter_inc),
								.clk(clk),
								.q(therm_counter));

   // therm_mask = 0 means don't send idle/resume to the corresponding thread
   assign 	therm_mask = |(creg_tmstatctrl_mask & (1'b1 << therm_counter));
   
   assign 	tmstatctrl_int_vld = therm_cycle & therm_mask &
		                     ~firstthr_int_vld & ~intctrl_int_vld & ~intvecdisp_int_vld &
		                     ~iob_man_int_buf_vld;
   
   assign 	tmstatctrl_int = {`UCB_INT_RSV_WIDTH'b0,
				  `UCB_INT_VEC_WIDTH'b0,
				  `UCB_INT_STAT_WIDTH'b0,
				  `DUMMY_DEV_ID,
				  1'b0,therm_counter,
				  therm_type};

   
   /*****************************************************************
    * IOB Core Available Register
    *****************************************************************/
   iobdg_efuse_reg #(`IOB_FUSE_WIDTH) coreavail_reg (.arst_l(arst_l),
						     .fuse_clk(fuse_clk),
						     .data_in(efc_iob_fuse_data),
						     .shift_en(efc_iob_coreavail_dshift),
						     .fuse_reg(coreavail));

   assign 	iob_ctu_coreavail = coreavail[`IOB_CPU_WIDTH-1:0];
   
   always @(/*AUTOSENSE*/coreavail)
     begin
	creg_coreavail = 64'b0;
     	for (i=0; i<`IOB_CPU_WIDTH; i=i+1)
	  begin
	     for (j=0; j<`IOB_THR_WIDTH; j=j+1)
	       begin
		  creg_coreavail[i*`IOB_THR_WIDTH+j] = coreavail[i];
	       end
	  end
     end
   
   
   /*****************************************************************
    * First Available Thread Reset logic
    * We will reset the first available thread after CTU indicates
    * it's okay to wake up the first thread (after bist done for POR).  
    *****************************************************************/
   dffrl_ns #(1) wake_thr_ff (.din(ctu_iob_wake_thr),
			      .clk(clk),
			      .rst_l(rst_l),
			      .q(wake_thr));

   assign 	firstthr_int_vld = wake_thr;

   iobdg_findfirst #(`IOB_CPU_WIDTH) findfirst_availcore (.vec_in(coreavail[`IOB_CPU_WIDTH-1:0]),
							  .vec_out(first_availcore));

   // Encode first_availcore into 3 bits and left shift by two bits
   assign 	firstthr_int_thr = {first_availcore[7]|
				    first_availcore[6]|
				    first_availcore[5]|
				    first_availcore[4],
				    first_availcore[7]|
				    first_availcore[6]|
				    first_availcore[3]|
				    first_availcore[2],
				    first_availcore[7]|
				    first_availcore[5]|
				    first_availcore[3]|
				    first_availcore[1],
				    2'b0};
				    
   assign 	firstthr_int = {`UCB_INT_RSV_WIDTH'b0,
				`IOB_POR_TT,
				`UCB_INT_STAT_WIDTH'b0,
				`DUMMY_DEV_ID,
				1'b0,firstthr_int_thr,
				`UCB_RESET_VEC};

   
   /*****************************************************************
    * IOB JBUS Interrupt Vector Register
    *****************************************************************/
   assign 	creg_jintv_wr = iob_man_ucb_buf_acpt_d2 &
		                iob_man_ucb_c2i_packet_is_wr_req &
		                creg_jintv_dec;

   dffe_ns #(`IOB_INT_VEC_WIDTH) creg_jintv_vec_ff (.din(iob_man_ucb_c2i_packet_data[`IOB_INT_VEC_WIDTH-1:0]),
						    .en(creg_jintv_wr),
						    .clk(clk),
						    .q(creg_jintv_vec));

   assign 	creg_jintv = {{(64-`IOB_INT_VEC_WIDTH){1'b0}},
			      creg_jintv_vec};

   
   /*****************************************************************
    * IOB Debug Port Register
    *****************************************************************/
   // creg_dbg_l2_vis_ctrl
   assign 	creg_dbg_l2_vis_ctrl_wr = iob_man_ucb_buf_acpt_d2 &
		                          iob_man_ucb_c2i_packet_is_wr_req &
		                          creg_dbg_l2_vis_ctrl_dec;

   assign 	creg_dbg_l2_vis_ctrl_en_next = ~rst_l                  ? creg_dbg_l2_vis_ctrl_en :
		                               creg_dbg_l2_vis_ctrl_wr ? iob_man_ucb_c2i_packet_data[3] :
		                                                         creg_dbg_l2_vis_ctrl_en;
   
   dffrl_async_ns #(1) creg_dbg_l2_vis_ctrl_en_ff (.din(creg_dbg_l2_vis_ctrl_en_next),
						   .clk(clk),
						   .rst_l(arst_l),
						   .q(creg_dbg_l2_vis_ctrl_en));

   dffrle_ns #(1) creg_dbg_l2_vis_ctrl_trigen_ff (.din(iob_man_ucb_c2i_packet_data[2] | l2_vis_armin),
						  .rst_l(rst_l),
					      	  .en(creg_dbg_l2_vis_ctrl_wr | l2_vis_armin),
					      	  .clk(clk),
					      	  .q(creg_dbg_l2_vis_ctrl_trigen));

   assign 	creg_dbg_l2_vis_ctrl = {60'b0,
					creg_dbg_l2_vis_ctrl_en,
					creg_dbg_l2_vis_ctrl_trigen,
					2'b0};

   // creg_dbg_l2_vis_maska
   assign 	creg_dbg_l2_vis_maska_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_l2_vis_maska_dec;

   dffe_ns #(39) creg_dbg_l2_vis_maska_bits_ff (.din({iob_man_ucb_c2i_packet_data[51:48],
						      iob_man_ucb_c2i_packet_data[44:40],
						      iob_man_ucb_c2i_packet_data[33:8],
						      iob_man_ucb_c2i_packet_data[5:2]}),
						.en(creg_dbg_l2_vis_maska_wr),
						.clk(clk),
						.q(creg_dbg_l2_vis_maska_bits));

   assign 	creg_dbg_l2_vis_maska = {12'b0,
					 creg_dbg_l2_vis_maska_bits[38:35],
					 3'b0,
					 creg_dbg_l2_vis_maska_bits[34:30],
					 6'b0,
					 creg_dbg_l2_vis_maska_bits[29:4],
					 2'b0,
					 creg_dbg_l2_vis_maska_bits[3:0],
					 2'b0};

   assign 	creg_dbg_l2_vis_maska_s = creg_dbg_l2_vis_maska;
   
   // creg_dbg_l2_vis_maskb
   assign 	creg_dbg_l2_vis_maskb_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_l2_vis_maskb_dec;

   dffe_ns #(39) creg_dbg_l2_vis_maskb_bits_ff (.din({iob_man_ucb_c2i_packet_data[51:48],
						      iob_man_ucb_c2i_packet_data[44:40],
						      iob_man_ucb_c2i_packet_data[33:8],
						      iob_man_ucb_c2i_packet_data[5:2]}),
						.en(creg_dbg_l2_vis_maskb_wr),
						.clk(clk),
						.q(creg_dbg_l2_vis_maskb_bits));

   assign 	creg_dbg_l2_vis_maskb = {12'b0,
					 creg_dbg_l2_vis_maskb_bits[38:35],
					 3'b0,
					 creg_dbg_l2_vis_maskb_bits[34:30],
					 6'b0,
					 creg_dbg_l2_vis_maskb_bits[29:4],
					 2'b0,
					 creg_dbg_l2_vis_maskb_bits[3:0],
					 2'b0};

   assign 	creg_dbg_l2_vis_maskb_s = creg_dbg_l2_vis_maskb;
   
   // creg_dbg_l2_vis_cmpa
   assign 	creg_dbg_l2_vis_cmpa_wr = iob_man_ucb_buf_acpt_d2 &
		                          iob_man_ucb_c2i_packet_is_wr_req &
		                          creg_dbg_l2_vis_cmpa_dec;

   dffe_ns #(39) creg_dbg_l2_vis_cmpa_bits_ff (.din({iob_man_ucb_c2i_packet_data[51:48],
						     iob_man_ucb_c2i_packet_data[44:40],
						     iob_man_ucb_c2i_packet_data[33:8],
						     iob_man_ucb_c2i_packet_data[5:2]}),
						.en(creg_dbg_l2_vis_cmpa_wr),
						.clk(clk),
						.q(creg_dbg_l2_vis_cmpa_bits));

   assign 	creg_dbg_l2_vis_cmpa = {12'b0,
					creg_dbg_l2_vis_cmpa_bits[38:35],
					3'b0,
					creg_dbg_l2_vis_cmpa_bits[34:30],
					6'b0,
					creg_dbg_l2_vis_cmpa_bits[29:4],
					2'b0,
					creg_dbg_l2_vis_cmpa_bits[3:0],
					2'b0};

   assign 	creg_dbg_l2_vis_cmpa_s = creg_dbg_l2_vis_cmpa;
   
   // creg_dbg_l2_vis_cmpb
   assign 	creg_dbg_l2_vis_cmpb_wr = iob_man_ucb_buf_acpt_d2 &
		                          iob_man_ucb_c2i_packet_is_wr_req &
		                          creg_dbg_l2_vis_cmpb_dec;

   dffe_ns #(39) creg_dbg_l2_vis_cmpb_bits_ff (.din({iob_man_ucb_c2i_packet_data[51:48],
						     iob_man_ucb_c2i_packet_data[44:40],
						     iob_man_ucb_c2i_packet_data[33:8],
						     iob_man_ucb_c2i_packet_data[5:2]}),
						.en(creg_dbg_l2_vis_cmpb_wr),
						.clk(clk),
						.q(creg_dbg_l2_vis_cmpb_bits));

   assign 	creg_dbg_l2_vis_cmpb = {12'b0,
					creg_dbg_l2_vis_cmpb_bits[38:35],
					3'b0,
					creg_dbg_l2_vis_cmpb_bits[34:30],
					6'b0,
					creg_dbg_l2_vis_cmpb_bits[29:4],
					2'b0,
					creg_dbg_l2_vis_cmpb_bits[3:0],
					2'b0};

   assign 	creg_dbg_l2_vis_cmpb_s = creg_dbg_l2_vis_cmpb;
   
   // creg_dbg_l2_vis_trig_delay
   assign 	creg_dbg_l2_vis_trig_delay_wr = iob_man_ucb_buf_acpt_d2 &
		                                iob_man_ucb_c2i_packet_is_wr_req &
		                                creg_dbg_l2_vis_trig_delay_dec;

   dffe_ns #(32) creg_dbg_l2_vis_trig_delay_bits_ff (.din(iob_man_ucb_c2i_packet_data[31:0]),
						     .en(creg_dbg_l2_vis_trig_delay_wr),
						     .clk(clk),
						     .q(creg_dbg_l2_vis_trig_delay_bits));

   assign 	creg_dbg_l2_vis_trig_delay = {32'b0,
					      creg_dbg_l2_vis_trig_delay_bits};

   assign 	creg_dbg_l2_vis_trig_delay_s = creg_dbg_l2_vis_trig_delay;
   
   // creg_dbg_iob_vis_ctrl
   assign 	creg_dbg_iob_vis_ctrl_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_iob_vis_ctrl_dec;

   dffe_ns #(4) creg_dbg_iob_vis_ctrl_bits_ff (.din(iob_man_ucb_c2i_packet_data[3:0]),
					       .en(creg_dbg_iob_vis_ctrl_wr),
					       .clk(clk),
					       .q(creg_dbg_iob_vis_ctrl_bits));

   assign 	creg_dbg_iob_vis_ctrl = {60'b0,
					 creg_dbg_iob_vis_ctrl_bits};

   // creg_dbg_enet_ctrl
   assign 	creg_dbg_enet_ctrl_wr = iob_man_ucb_buf_acpt_d2 &
		                        iob_man_ucb_c2i_packet_is_wr_req &
		                        creg_dbg_enet_ctrl_dec;

   // preserved bits for creg_dbg_enet_ctrl
   // cleared only on POR
   assign 	creg_dbg_enet_ctrl_bits_next = ~rst_l                ? creg_dbg_enet_ctrl_bits :
		                               creg_dbg_enet_ctrl_wr ? {iob_man_ucb_c2i_packet_data[8],
									iob_man_ucb_c2i_packet_data[3:0]} :
		                                                       creg_dbg_enet_ctrl_bits;
   
   dffrl_async_ns #(5) creg_dbg_enet_ctrl_bits_ff (.din(creg_dbg_enet_ctrl_bits_next),
						   .clk(clk),
						   .rst_l(arst_l),
						   .q(creg_dbg_enet_ctrl_bits));

   // reset bits for creg_dbg_enet_ctrl
   dffrle_ns #(2) creg_dbg_enet_ctrl_rbits_ff (.din(iob_man_ucb_c2i_packet_data[6:5]),
					       .en(creg_dbg_enet_ctrl_wr),
					       .clk(clk),
					       .rst_l(rst_l),
					       .q(creg_dbg_enet_ctrl_rbits));

   assign 	 creg_dbg_enet_ctrl = {55'b0,
				       creg_dbg_enet_ctrl_bits[4],
				       1'b0,
				       creg_dbg_enet_ctrl_rbits[1:0],
				       1'b0,
				       creg_dbg_enet_ctrl_bits[3:0]};

   // creg_dbg_enet_idleval
   assign 	creg_dbg_enet_idleval_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_enet_idleval_dec;

   dffe_ns #(40) creg_dbg_enet_idleval_bits_ff (.din(iob_man_ucb_c2i_packet_data[39:0]),
						.en(creg_dbg_enet_idleval_wr),
						.clk(clk),
						.q(creg_dbg_enet_idleval_bits));

   assign 	creg_dbg_enet_idleval = {24'b0,
					 creg_dbg_enet_idleval_bits};

   // creg_dbg_jbus_ctrl
   // cleared only on POR
   assign 	creg_dbg_jbus_ctrl_wr = iob_man_ucb_buf_acpt_d2 &
		                        iob_man_ucb_c2i_packet_is_wr_req &
		                        creg_dbg_jbus_ctrl_dec;

   assign 	creg_dbg_jbus_ctrl_bits_next = ~rst_l                ? creg_dbg_jbus_ctrl_bits :
	  	                               creg_dbg_jbus_ctrl_wr ? {iob_man_ucb_c2i_packet_data[16],
									iob_man_ucb_c2i_packet_data[6:4],
									iob_man_ucb_c2i_packet_data[2:0]} :
		                                                       creg_dbg_jbus_ctrl_bits;
   
   dffrl_async_ns #(7) creg_dbg_jbus_ctrl_bits_ff (.din(creg_dbg_jbus_ctrl_bits_next),
						   .clk(clk),
						   .rst_l(arst_l),
						   .q(creg_dbg_jbus_ctrl_bits));

   assign 	creg_dbg_jbus_ctrl = {47'b0,
				      creg_dbg_jbus_ctrl_bits[6],
				      9'b0,
				      creg_dbg_jbus_ctrl_bits[5:3],
				      1'b0,
				      creg_dbg_jbus_ctrl_bits[2:0]};
   
   // creg_dbg_jbus_lo_mask0
   assign 	creg_dbg_jbus_lo_mask0_wr = iob_man_ucb_buf_acpt_d2 &
		                            iob_man_ucb_c2i_packet_is_wr_req &
		                            creg_dbg_jbus_lo_mask0_dec;

   dffe_ns #(46) creg_dbg_jbus_lo_mask0_bits_ff (.din(iob_man_ucb_c2i_packet_data[45:0]),
						 .en(creg_dbg_jbus_lo_mask0_wr),
						 .clk(clk),
						 .q(creg_dbg_jbus_lo_mask0_bits));

   assign 	creg_dbg_jbus_lo_mask0 = {18'b0,
					  creg_dbg_jbus_lo_mask0_bits};

   // creg_dbg_jbus_lo_mask1
   assign 	creg_dbg_jbus_lo_mask1_wr = iob_man_ucb_buf_acpt_d2 &
		                            iob_man_ucb_c2i_packet_is_wr_req &
		                            creg_dbg_jbus_lo_mask1_dec;

   dffe_ns #(46) creg_dbg_jbus_lo_mask1_bits_ff (.din(iob_man_ucb_c2i_packet_data[45:0]),
						 .en(creg_dbg_jbus_lo_mask1_wr),
						 .clk(clk),
						 .q(creg_dbg_jbus_lo_mask1_bits));

   assign 	creg_dbg_jbus_lo_mask1 = {18'b0,
					  creg_dbg_jbus_lo_mask1_bits};

   // creg_dbg_jbus_lo_cmp0
   assign 	creg_dbg_jbus_lo_cmp0_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_jbus_lo_cmp0_dec;

   dffe_ns #(44) creg_dbg_jbus_lo_cmp0_bits_ff (.din(iob_man_ucb_c2i_packet_data[43:0]),
						.en(creg_dbg_jbus_lo_cmp0_wr),
						.clk(clk),
						.q(creg_dbg_jbus_lo_cmp0_bits));

   assign 	creg_dbg_jbus_lo_cmp0 = {20'b0,
					 creg_dbg_jbus_lo_cmp0_bits};

   // creg_dbg_jbus_lo_cmp1
   assign 	creg_dbg_jbus_lo_cmp1_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_jbus_lo_cmp1_dec;

   dffe_ns #(44) creg_dbg_jbus_lo_cmp1_bits_ff (.din(iob_man_ucb_c2i_packet_data[43:0]),
						.en(creg_dbg_jbus_lo_cmp1_wr),
						.clk(clk),
						.q(creg_dbg_jbus_lo_cmp1_bits));

   assign 	creg_dbg_jbus_lo_cmp1 = {20'b0,
					 creg_dbg_jbus_lo_cmp1_bits};

   // creg_dbg_jbus_lo_cnt0
   assign 	creg_dbg_jbus_lo_cnt0_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_jbus_lo_cnt0_dec;

   dffe_ns #(9) creg_dbg_jbus_lo_cnt0_bits_ff (.din(iob_man_ucb_c2i_packet_data[8:0]),
					       .en(creg_dbg_jbus_lo_cnt0_wr),
					       .clk(clk),
					       .q(creg_dbg_jbus_lo_cnt0_bits));

   assign 	creg_dbg_jbus_lo_cnt0 = {55'b0,
					 creg_dbg_jbus_lo_cnt0_bits};

   // creg_dbg_jbus_lo_cnt1
   assign 	creg_dbg_jbus_lo_cnt1_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_jbus_lo_cnt1_dec;

   dffe_ns #(9) creg_dbg_jbus_lo_cnt1_bits_ff (.din(iob_man_ucb_c2i_packet_data[8:0]),
					       .en(creg_dbg_jbus_lo_cnt1_wr),
					       .clk(clk),
					       .q(creg_dbg_jbus_lo_cnt1_bits));

   assign 	creg_dbg_jbus_lo_cnt1 = {55'b0,
					 creg_dbg_jbus_lo_cnt1_bits};

   // creg_dbg_jbus_hi_mask0
   assign 	creg_dbg_jbus_hi_mask0_wr = iob_man_ucb_buf_acpt_d2 &
		                            iob_man_ucb_c2i_packet_is_wr_req &
		                            creg_dbg_jbus_hi_mask0_dec;

   dffe_ns #(46) creg_dbg_jbus_hi_mask0_bits_ff (.din(iob_man_ucb_c2i_packet_data[45:0]),
						 .en(creg_dbg_jbus_hi_mask0_wr),
						 .clk(clk),
						 .q(creg_dbg_jbus_hi_mask0_bits));

   assign 	creg_dbg_jbus_hi_mask0 = {18'b0,
					  creg_dbg_jbus_hi_mask0_bits};

   // creg_dbg_jbus_hi_mask1
   assign 	creg_dbg_jbus_hi_mask1_wr = iob_man_ucb_buf_acpt_d2 &
		                            iob_man_ucb_c2i_packet_is_wr_req &
		                            creg_dbg_jbus_hi_mask1_dec;

   dffe_ns #(46) creg_dbg_jbus_hi_mask1_bits_ff (.din(iob_man_ucb_c2i_packet_data[45:0]),
						 .en(creg_dbg_jbus_hi_mask1_wr),
						 .clk(clk),
						 .q(creg_dbg_jbus_hi_mask1_bits));

   assign 	creg_dbg_jbus_hi_mask1 = {18'b0,
					  creg_dbg_jbus_hi_mask1_bits};

   // creg_dbg_jbus_hi_cmp0
   assign 	creg_dbg_jbus_hi_cmp0_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_jbus_hi_cmp0_dec;

   dffe_ns #(44) creg_dbg_jbus_hi_cmp0_bits_ff (.din(iob_man_ucb_c2i_packet_data[43:0]),
						.en(creg_dbg_jbus_hi_cmp0_wr),
						.clk(clk),
						.q(creg_dbg_jbus_hi_cmp0_bits));

   assign 	creg_dbg_jbus_hi_cmp0 = {20'b0,
					 creg_dbg_jbus_hi_cmp0_bits};

   // creg_dbg_jbus_hi_cmp1
   assign 	creg_dbg_jbus_hi_cmp1_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_jbus_hi_cmp1_dec;

   dffe_ns #(44) creg_dbg_jbus_hi_cmp1_bits_ff (.din(iob_man_ucb_c2i_packet_data[43:0]),
						.en(creg_dbg_jbus_hi_cmp1_wr),
						.clk(clk),
						.q(creg_dbg_jbus_hi_cmp1_bits));

   assign 	creg_dbg_jbus_hi_cmp1 = {20'b0,
					 creg_dbg_jbus_hi_cmp1_bits};

   // creg_dbg_jbus_hi_cnt0
   assign 	creg_dbg_jbus_hi_cnt0_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_jbus_hi_cnt0_dec;

   dffe_ns #(9) creg_dbg_jbus_hi_cnt0_bits_ff (.din(iob_man_ucb_c2i_packet_data[8:0]),
					       .en(creg_dbg_jbus_hi_cnt0_wr),
					       .clk(clk),
					       .q(creg_dbg_jbus_hi_cnt0_bits));

   assign 	creg_dbg_jbus_hi_cnt0 = {55'b0,
					 creg_dbg_jbus_hi_cnt0_bits};

   // creg_dbg_jbus_hi_cnt1
   assign 	creg_dbg_jbus_hi_cnt1_wr = iob_man_ucb_buf_acpt_d2 &
		                           iob_man_ucb_c2i_packet_is_wr_req &
		                           creg_dbg_jbus_hi_cnt1_dec;

   dffe_ns #(9) creg_dbg_jbus_hi_cnt1_bits_ff (.din(iob_man_ucb_c2i_packet_data[8:0]),
					       .en(creg_dbg_jbus_hi_cnt1_wr),
					       .clk(clk),
					       .q(creg_dbg_jbus_hi_cnt1_bits));

   assign 	creg_dbg_jbus_hi_cnt1 = {55'b0,
					 creg_dbg_jbus_hi_cnt1_bits};


   /*****************************************************************
    * Memory Control Register
    * Margin register is programmed to default value on POR but
    * preserved across warm reset.  Default value for creg_margin_16x65
    * is 5'b15.
    *****************************************************************/
   assign 	creg_margin_wr = iob_man_ucb_buf_acpt_d2 &
		                 iob_man_ucb_c2i_packet_is_wr_req &
		                 creg_margin_dec &
		                 ~sehold;

   assign 	creg_margin_16x65_next = ~rst_l         ? creg_margin_16x65 :
		                         creg_margin_wr ? iob_man_ucb_c2i_packet_data[4:0] :
		                                          creg_margin_16x65;
		
   dffsl_async_ns #(3) creg_margin_16x65_one_ff (.din({creg_margin_16x65_next[4],
						       creg_margin_16x65_next[2],
						       creg_margin_16x65_next[0]}),
						 .set_l(arst_l),
						 .clk(clk),
						 .q({creg_margin_16x65[4],
						     creg_margin_16x65[2],
						     creg_margin_16x65[0]}));

   dffrl_async_ns #(2) creg_margin_16x65_zero_ff (.din({creg_margin_16x65_next[3],
							creg_margin_16x65_next[1]}),
						  .clk(clk),
						  .rst_l(arst_l),
						  .q({creg_margin_16x65[3],
						      creg_margin_16x65[1]}));

   assign 	creg_margin = {59'b0,
			       creg_margin_16x65};

   
   /*****************************************************************
    * iob_int_ucb
    *****************************************************************/
   // Flop c2i_packet
   assign       iob_int_ucb_buf_acpt = c2i_packet_vld & iob_int_ucb_sel &
	                               ~tap_mondo_acc_outstanding &
		                       ~tap_mondo_acc_outstanding_d1 &
		                       ~iob_int_ack_vld;

   dffe_ns #(`UCB_64PAY_PKT_WIDTH) iob_int_ucb_c2i_packet_ff (.din(c2i_packet),
							      .en(iob_int_ucb_buf_acpt),
							      .clk(clk),
							      .q(iob_int_ucb_c2i_packet));

   dffe_ns #(1) iob_int_ucb_c2i_packet_is_rd_req_ff (.din(c2i_packet_is_rd_req),
						     .en(iob_int_ucb_buf_acpt),
						     .clk(clk),
						     .q(iob_int_ucb_c2i_packet_is_rd_req));

   dffe_ns #(1) iob_int_ucb_c2i_packet_is_wr_req_ff (.din(c2i_packet_is_wr_req),
						     .en(iob_int_ucb_buf_acpt),
						     .clk(clk),
						     .q(iob_int_ucb_c2i_packet_is_wr_req));

   assign 	iob_int_ucb_c2i_packet_data = iob_int_ucb_c2i_packet[`UCB_DATA_HI:`UCB_DATA_LO];

   // Send interrupt status table read/write request to c2i
   assign 	tap_mondo_acc_addr_s = iob_int_ucb_c2i_packet[`UCB_ADDR_HI:`UCB_ADDR_LO];
   
   assign 	tap_mondo_acc_seq_next = ~tap_mondo_acc_seq;
   
   dffrle_ns #(1) tap_mondo_acc_seq_ff (.din(tap_mondo_acc_seq_next),
					    .rst_l(rst_l),
					    .en(iob_int_ucb_buf_acpt),
					    .clk(clk),
					    .q(tap_mondo_acc_seq));

   assign 	tap_mondo_acc_seq_s = tap_mondo_acc_seq;
   
   assign  	tap_mondo_wr_s = iob_int_ucb_c2i_packet_is_wr_req;
   
   assign 	tap_mondo_din_s = iob_int_ucb_c2i_packet_data;
   

   // Receive interrupt status table read/write ack from c2i
   dffrl_ns #(1) tap_mondo_acc_addr_invld_d2_ff (.din(tap_mondo_acc_addr_invld_d2_f),
						     .clk(clk),
						     .rst_l(rst_l),
						     .q(tap_mondo_acc_addr_invld_d2));
   
   dffrl_ns #(1) tap_mondo_acc_seq_d2_ff (.din(tap_mondo_acc_seq_d2_f),
					      .clk(clk),
					      .rst_l(rst_l),
					      .q(tap_mondo_acc_seq_d2));

   dff_ns #(64) tap_mondo_dout_d2_ff (.din(tap_mondo_dout_d2_f),
					  .clk(clk),
					  .q(tap_mondo_dout_d2));

   // Detect when the interrupt table access is done
   assign 	tap_mondo_acc_outstanding = (tap_mondo_acc_seq != tap_mondo_acc_seq_d2);
   
   dffrl_ns #(1) tap_mondo_acc_outstanding_d1_ff (.din(tap_mondo_acc_outstanding),
						      .clk(clk),
						      .rst_l(rst_l),
						      .q(tap_mondo_acc_outstanding_d1));

   assign 	tap_mondo_rd_done = ~tap_mondo_acc_outstanding &
		                        tap_mondo_acc_outstanding_d1 &
		                        iob_int_ucb_c2i_packet_is_rd_req;

   // Assemble read result back to UCB packet format
   assign 	iob_int_ucb_i2c_packet_type = tap_mondo_acc_addr_invld_d2 ? `UCB_READ_NACK :
	                                                                        `UCB_READ_ACK;
   
   assign 	iob_int_ucb_i2c_packet = {tap_mondo_dout_d2,        // data
					  `UCB_RSV_WIDTH'b0,            // reserved
					  `UCB_ADDR_WIDTH'b0,           // address
					  `UCB_SIZE_WIDTH'b0,           // size
					  `UCB_BID_TAP,                 // buffer ID
					  `UCB_THR_WIDTH'b0,            // thread ID
					  iob_int_ucb_i2c_packet_type}; // packet type
   
   dffe_ns #(`UCB_64PAY_PKT_WIDTH) iob_int_ack_packet_ff (.din(iob_int_ucb_i2c_packet),
							  .en(tap_mondo_rd_done),
							  .clk(clk),
							  .q(iob_int_ack_packet));

   assign 	iob_int_ack_vld_next = tap_mondo_rd_done |
		                       (iob_int_ack_vld & ~iob_int_ack_rd);
   
   dffrl_ns #(1) iob_int_ack_vld_ff (.din(iob_int_ack_vld_next),
				     .clk(clk),
				     .rst_l(rst_l),
				     .q(iob_int_ack_vld));

   
   /*****************************************************************
    * bounce_ucb
    *****************************************************************/
   assign 	bounce_ack_buf_wr = c2i_packet_vld & bounce_ucb_sel &
		                    ~bounce_ack_buf_full;

   assign 	bounce_ucb_buf_acpt = bounce_ack_buf_wr;
   
   assign 	bounce_ack_buf_din = c2i_packet;
   
   dbl_buf #(`UCB_64PAY_PKT_WIDTH) bounce_ack_buf (.rst_l(rst_l),
						   .clk(clk),
						   .wr(bounce_ack_buf_wr),
						   .din(bounce_ack_buf_din),
						   .vld(bounce_ack_buf_vld),
						   .dout(bounce_ack_buf_dout),
						   .rd(bounce_ack_buf_rd),
						   .full(bounce_ack_buf_full));

   assign 	bounce_ack_vld = bounce_ack_buf_vld;

   assign 	bounce_ack_packet = bounce_ack_buf_dout;
   
   assign 	bounce_ack_buf_rd = bounce_ack_rd;
   

   /*****************************************************************
    * rd_nack_ucb
    *****************************************************************/
   assign 	rd_nack_buf_wr = c2i_packet_vld & rd_nack_ucb_sel &
		                 ~rd_nack_buf_full;

   assign 	rd_nack_ucb_buf_acpt = rd_nack_buf_wr;
   
   assign 	rd_nack_buf_din = c2i_rd_nack_packet;
   
   dbl_buf #(`UCB_NOPAY_PKT_WIDTH) rd_nack__buf (.rst_l(rst_l),
						 .clk(clk),
						 .wr(rd_nack_buf_wr),
						 .din(rd_nack_buf_din),
						 .vld(rd_nack_buf_vld),
						 .dout(rd_nack_buf_dout),
						 .rd(rd_nack_buf_rd),
						 .full(rd_nack_buf_full));

   assign 	rd_nack_vld = rd_nack_buf_vld;

   assign 	rd_nack_packet = rd_nack_buf_dout;
   
   assign 	rd_nack_buf_rd = rd_nack_rd;
   

endmodule // iobdg_ctrl


// Local Variables:
// verilog-auto-sense-defines-constant:t
// End:



