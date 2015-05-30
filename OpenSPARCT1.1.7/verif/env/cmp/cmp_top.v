// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: cmp_top.v
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
////////////////////////////////////////////////////////
`include "sys_paths.h"
`include "sys.h"
`include "iop.h"


module cmp_top ();

  wire                 rst_l ;
  wire                 pwrok ;
  wire [2:0]           j_pack2 ;
  wire [2:0]           j_pack3 ;
  wire [2:0]           j_pack6 ;
  wire [5:0]           j_req_out_l_0 ;
  wire [5:0]           j_req_out_l_1 ;
  wire [5:0]           j_req_out_l_2 ;
  wire [5:0]           j_req_out_l_3 ;
  wire [5:0]           j_req_out_l_4 ;
  wire [5:0]           j_req_out_l_5 ;
  wire [5:0]           j_req_out_l_6 ;
  wire [5:0]           j_req_in_l_0 ;
  wire [5:0]           j_req_in_l_1 ;
  wire [5:0]           j_req_in_l_2 ;
  wire [5:0]           j_req_in_l_3 ;
  wire [5:0]           j_req_in_l_4 ;
  wire [5:0]           j_req_in_l_5 ;
  wire [5:0]           j_req_in_l_6 ;

  reg  [2:0]           j_pack0_d1 ;
  reg  [2:0]           j_pack0_d2 ;
  reg  [2:0]           j_pack0_d3 ;
  reg  [2:0]           j_pack1_d1 ;
  reg  [2:0]           j_pack1_d2 ;
  reg  [2:0]           j_pack1_d3 ;
  reg                  j_fatal_error_l ;

  reg  [2:0]           j_pack0_d  ;
  reg  [2:0]           j_pack1_d  ;
  reg  [2:0]           j_pack2_d  ;
  reg  [2:0]           j_pack3_d  ;
  reg  [2:0]           j_pack4_d  ;
  reg  [2:0]           j_pack5_d  ;
  reg  [2:0]           j_pack6_d  ;
  reg                  j_par_d1 ;
  reg                  j_par_d2 ;
  reg                  jbus_j_por_l_reg ;

  reg                  jbi_io_j_ad_en_d ;
  reg                  jbi_io_j_adp_en_d ;
  reg                  jbi_io_j_adtype_en_d ;
  reg                  jbi_io_j_pack0_en_d ;
  reg                  jbi_io_j_pack1_en_d ;

  reg  [1:0]           sjm_4_status ;
  reg  [1:0]           sjm_5_status ;
  reg 		       trigger_sjm_4 ;
  reg 		       trigger_sjm_5 ;
  reg 		       reset_handler_done ;
  integer              sjm_init_status ;
  wire                 start_sjm ;
  wire                 jbus_j_por_l ;
  wire                 j_change_l ;
  wire                 j_clk ;
  wire                 pwron_rst_l ;
  wire                 j_rst_l ;
  wire 	               j_err_5 ;

  wire 	               xir_l ;
  wire 	               valid0 ;
  wire 	               valid1 ;
  wire 	               p_trdy ;
  wire 	               p_int_arb ;
  wire 	               g_int_arb ;
  wire 	               pci_master_rst_l ;
  wire [7:0]           pci_int1_l ;
  wire [7:0]           pci_int2_l ;
  wire [7:0]           pci_int3_l ;
  wire [7:0]           pci_int4_l ;
  wire [5:0]           pci_int5_l ;
  wire [3:0]           pci_int6_l ;
  wire [3:0]           pci_int7_l ;
  wire [3:0]           pci_int8_l ;
  wire [7:4] 	       pci_int4;
  wire [5:0]           int_in_l ;

  wire 	               p_clk ;
  wire 	               g_clk ;
  wire 	               g_rd_clk, g_rd_clk_l ;
  wire 	               g_upa_refclk, g_upa_refclk_l ;
  wire 	               upa_clk ;
  wire 	               p_bpclk ;
  wire 	               ichip_clk ;
  wire 	               p_rst_l ;
  wire 	               g_rst_l ;

  wire  [7:0]          stub_done ;
  wire  [7:0]          stub_pass ;
  wire                 cken_off_done ;
  wire                 warm_rst_l ;
  wire                 warm_rst_trig_l ;
  wire [7:0] 	       pll_byp_offset ;
  reg 		       do_bist_warm_rst_trig_l ;
  reg 		       pwron_seq_done ;
  reg 		       trig_tap_cmd;
  reg 		       tap_end_cmd;
  reg 		       in_pll_byp;
  integer 	       delay;

  wire [2:0]           DBG_CK_P;
  wire [2:0]           DBG_CK_N;
  wire [39:0]          DBG_DQ;
  wire                 DBG_VREF;

  wire                 BURNIN;
  wire [1:0]           CLKOBS;			// From iop of iop.v
  wire [2:0]           DIODE_TOP;		// From iop of iop.v
  wire                 MDC;			// From iop of iop.v
  wire                 SSI_MOSI;        // From iop of iop.v
  wire                 SSI_SCK;        // From iop of iop.v
  wire                 TDO;            // From iop of iop.v
  wire                 DO_BIST;        // To iop of iop.v
  wire                 DRAM01_N_REF_RES;    // To iop of iop.v
  wire                 DRAM01_P_REF_RES;    // To iop of iop.v
  wire                 DRAM02_SCL;        // To cmp_dram of cmp_dram.v
  wire                 DRAM13_SCL;        // To cmp_dram of cmp_dram.v
  wire                 DRAM23_N_REF_RES;    // To iop of iop.v
  wire                 DRAM23_P_REF_RES;    // To iop of iop.v
  wire                 DRAM_FAIL_OVER;        // To cmp_dram of cmp_dram.v
  wire [5:0]           DRAM_FAIL_PART;        // To cmp_dram of cmp_dram.v
  wire                 EXT_INT_L;        // To iop of iop.v
  wire                 HSTL_VREF;        // To iop of iop.v
  wire                 JBUS_N_REF_RES;        // To iop of iop.v
  wire                 JBUS_P_REF_RES;        // To iop of iop.v
  wire [1:0]           J_CLK;            // To iop of iop.v
  wire                 PGRM_EN;        // To iop of iop.v
  wire                 PWRON_RST_L;        // To iop of iop.v
  wire                 SSI_MISO;        // To iop of iop.v
  wire                 TCK;            // To iop of iop.v
  wire                 TCK2;            // To iop of iop.v
  wire                 TDI;            // To iop of iop.v
  wire                 TEMP_TRIG;        // To iop of iop.v
  wire                 TEST_MODE;        // To iop of iop.v
  wire                 TMS;            // To iop of iop.v
  wire                 TRIGIN;            // To iop of iop.v
  wire                 TRST_L;            // To iop of iop.v
  wire                 VDD_PLL;        // To iop of iop.v
  wire                 VDD_TSR;        // To iop of iop.v
  wire [2:0]           XXSA;            // To cmp_dram of cmp_dram.v
  wire                 XXWP;            // To cmp_dram of cmp_dram.v
  wire                 DRAM02_SDA;        // To/From cmp_dram of cmp_dram.v
  wire [14:0]          DRAM0_ADDR;        // From iop of iop.v
  wire [2:0]           DRAM0_BA;        // From iop of iop.v
  wire                 DRAM0_CAS_L;        // From iop of iop.v
  wire [15:0]          DRAM0_CB;        // To/From iop of iop.v, ...
  wire                 DRAM0_CKE;        // From iop of iop.v
  wire [3:0]           DRAM0_CK_N;        // From iop of iop.v
  wire [3:0]           DRAM0_CK_P;        // From iop of iop.v
  wire [3:0]           DRAM0_CS_L;        // From iop of iop.v
  wire [127:0]         DRAM0_DQ;        // To/From iop of iop.v, ...
  wire [35:0]          DRAM0_DQS;        // To/From iop of iop.v, ...
  wire                 DRAM0_RAS_L;        // From iop of iop.v
  wire                 DRAM0_WE_L;        // From iop of iop.v
  wire                 DRAM13_SDA;        // To/From cmp_dram of cmp_dram.v
  wire [14:0]          DRAM1_ADDR;        // From iop of iop.v
  wire [2:0]           DRAM1_BA;        // From iop of iop.v
  wire                 DRAM1_CAS_L;        // From iop of iop.v
  wire [15:0]          DRAM1_CB;        // To/From iop of iop.v, ...
  wire                 DRAM1_CKE;        // From iop of iop.v
  wire [3:0]           DRAM1_CK_N;        // From iop of iop.v
  wire [3:0]           DRAM1_CK_P;        // From iop of iop.v
  wire [3:0]           DRAM1_CS_L;        // From iop of iop.v
  wire [127:0]         DRAM1_DQ;        // To/From iop of iop.v, ...
  wire [35:0]          DRAM1_DQS;        // To/From iop of iop.v, ...
  wire                 DRAM1_RAS_L;        // From iop of iop.v
  wire                 DRAM1_WE_L;        // From iop of iop.v
  wire [14:0]          DRAM2_ADDR;        // From iop of iop.v
  wire [2:0]           DRAM2_BA;        // From iop of iop.v
  wire                 DRAM2_CAS_L;        // From iop of iop.v
  wire [15:0]          DRAM2_CB;        // To/From iop of iop.v, ...
  wire                 DRAM2_CKE;        // From iop of iop.v
  wire [3:0]           DRAM2_CK_N;        // From iop of iop.v
  wire [3:0]           DRAM2_CK_P;        // From iop of iop.v
  wire [3:0]           DRAM2_CS_L;        // From iop of iop.v
  wire [127:0]         DRAM2_DQ;        // To/From iop of iop.v, ...
  wire [35:0]          DRAM2_DQS;        // To/From iop of iop.v, ...
  wire                 DRAM2_RAS_L;        // From iop of iop.v
  wire                 DRAM2_WE_L;        // From iop of iop.v
  wire [14:0]          DRAM3_ADDR;        // From iop of iop.v
  wire [2:0]           DRAM3_BA;        // From iop of iop.v
  wire                 DRAM3_CAS_L;        // From iop of iop.v
  wire [15:0]          DRAM3_CB;        // To/From iop of iop.v, ...
  wire                 DRAM3_CKE;        // From iop of iop.v
  wire [3:0]           DRAM3_CK_N;        // From iop of iop.v
  wire [3:0]           DRAM3_CK_P;        // From iop of iop.v
  wire [3:0]           DRAM3_CS_L;        // From iop of iop.v
  wire [127:0]         DRAM3_DQ;        // To/From iop of iop.v, ...
  wire [35:0]          DRAM3_DQS;        // To/From iop of iop.v, ...
  wire                 DRAM3_RAS_L;        // From iop of iop.v
  wire                 DRAM3_WE_L;        // From iop of iop.v
  wire [127:0]         J_AD;            // To/From iop of iop.v
  wire [3:0]           J_ADP;            // To/From iop of iop.v
  wire [7:0]           J_ADTYPE;        // To/From iop of iop.v
  wire [2:0]           J_PACK0;        // To/From iop of iop.v
  wire [2:0]           J_PACK1;        // To/From iop of iop.v
  wire [2:0]           J_PACK4;        // To/From iop of iop.v
  wire [2:0]           J_PACK5;        // To/From iop of iop.v
  wire                 J_PAR;            // To/From iop of iop.v
  wire                 J_REQ0_OUT_L;        // To/From iop of iop.v
  wire                 J_REQ1_OUT_L;        // To/From iop of iop.v
  wire                 J_REQ4_IN_L;        // To/From iop of iop.v
  wire                 J_REQ5_IN_L;        // To/From iop of iop.v
  wire                 J_RST_L;        // To/From iop of iop.v
  wire                 SPARE_DDR0_PIN;        // To/From iop of iop.v
  wire [2:0]           SPARE_DDR1_PIN;
  wire [2:0]           SPARE_DDR2_PIN;        // To/From iop of iop.v
  wire [2:0]           SPARE_DDR3_PIN;        // To/From iop of iop.v
  wire                 SPARE_MISC_PIN;        // To/From iop of iop.v
  wire                 DTL_L_VREF;        // To/From iop of iop.v
  wire                 DTL_R_VREF;        // To/From iop of iop.v
  wire                 CLK_STRETCH;        // To/From iop of iop.v
  wire                 PMI;            // To/From iop of iop.v
  wire                 PLL_CHAR_IN;            // To/From iop of iop.v
  wire                 VREG_SELBG_L;            // To/From iop of iop.v
  wire                 SPARE_JBUSR_PIN;        // To/From iop of iop.v
  wire [1:0]           TSR_TESTIO;        // To/From iop of iop.v
  wire [2:0]           DIODE_BOT;        // To/From iop of iop.v

  reg [2048:0]         filename;

  // dummy wire used only by coreccx_coverage
  wire [11:0] coreccx_pcx_retry_req_cov;
   //wire for tap testing.
   wire       cmp_tck;
   wire       tclk;
   
`ifdef DRAM_SAT

  wire clk_ddr_slfrsh ; 
  wire cmp_gclk ;
  wire cmp_grst_l ;
  wire cmp_grst ;
  wire cmp_arst_l ;
  wire cmp_gdbginit_l ;
  wire cmp_adbginit_l ;
  wire jbus_j_clk ;
  //wire jbus_gclk = jbus_j_clk ;
  wire jbus_gclk;
  wire jbus_grst_l ;
  wire jbus_arst_l ;
  wire jbus_gdbginit_l ;
  wire jbus_adbginit_l ;
  wire dram_gclk ;
  wire free_dram_gclk ;
  wire dram_grst_l ;
  wire dram_arst_l ;
  wire dram_gdbginit_l ;
  wire dram_adbginit_l ;

  assign j_clk = jbus_j_clk;

  assign cmp_top.iop.dram_gdbginit_l = dram_gdbginit_l ;
  assign cmp_top.iop.dram_adbginit_l = dram_adbginit_l ;
  assign cmp_top.iop.jbus_gdbginit_l = jbus_gdbginit_l ;
  assign cmp_top.iop.jbus_adbginit_l = jbus_adbginit_l ;
  assign cmp_top.iop.cmp_gdbginit_out_l = cmp_gdbginit_l ;
  assign cmp_top.iop.cmp_adbginit_l = cmp_adbginit_l ;

  assign cmp_top.iop.ccx_rclk = cmp_gclk; // ccx_rclk is the clock for L2-DRAM buffers.
  assign cmp_top.iop.cmp_gclk = cmp_gclk ;
  assign cmp_top.iop.dram_gclk = dram_gclk ;
  assign cmp_top.iop.jbus_gclk = jbus_gclk ;
  //assign cmp_top.iop.bscan_clock_dr_in = tck ;

  assign cmp_top.iop.jbus_grst_l = jbus_grst_l ;
  assign cmp_top.iop.dram_grst_l = dram_grst_l ;
  assign cmp_top.iop.cmp_grst_out_l = cmp_grst_l ;
  assign cmp_top.iop.jbus_arst_l = jbus_arst_l ;
  assign cmp_top.iop.dram_arst_l = dram_arst_l ;
  assign cmp_top.iop.cmp_arst_l = cmp_arst_l ;

  assign cmp_grst = ~cmp_grst_l ;

`else
  `ifdef MSS_SAT

    // wires used by MSS coverage only
    wire l2_iq_cas12_cov_0 = 0;
    wire l2_iq_cas12_cov_1 = 0;
    wire l2_iq_cas12_cov_2 = 0;
    wire l2_iq_cas12_cov_3 = 0;
    wire [13:0] l2_atomic_store_cov_0 = 0;
    wire [13:0] l2_atomic_store_cov_1 = 0;
    wire [13:0] l2_atomic_store_cov_2 = 0;
    wire [13:0] l2_atomic_store_cov_3 = 0;
    wire [2:0] l2_pst1_dataerr_pst2_tagerr_cov_0 = 0;
    wire [2:0] l2_pst1_dataerr_pst2_tagerr_cov_1 = 0;
    wire [2:0] l2_pst1_dataerr_pst2_tagerr_cov_2 = 0;
    wire [2:0] l2_pst1_dataerr_pst2_tagerr_cov_3 = 0;

    reg ctu_tst_pre_grst_l;
    wire clk_ddr_slfrsh ; 
    wire cmp_gclk ;
    wire cmp_rclk = cmp_top.iop.ccx.rclk ;
    wire cmp_grst_l ;
    wire cmp_grst ;
    wire cmp_arst_l ;
    wire cmp_gdbginit_l ;
    wire cmp_adbginit_l ;
    wire jbus_j_clk ;
    //wire jbus_gclk = jbus_j_clk ;
    wire jbus_gclk;
    wire jbus_grst_l ;
    wire jbus_arst_l ;
    wire jbus_gdbginit_l ;
    wire jbus_adbginit_l ;
    wire dram_gclk ;
    wire free_dram_gclk ;
    wire dram_grst_l ;
    wire dram_arst_l ;
    wire dram_gdbginit_l ;
    wire dram_adbginit_l ;

    assign j_clk = jbus_j_clk;

    assign cmp_top.iop.dram_gdbginit_l = dram_gdbginit_l ;
    assign cmp_top.iop.dram_adbginit_l = dram_adbginit_l ;
    assign cmp_top.iop.jbus_gdbginit_l = jbus_gdbginit_l ;
    assign cmp_top.iop.jbus_adbginit_l = jbus_adbginit_l ;
    assign cmp_top.iop.cmp_gdbginit_out_l = cmp_gdbginit_l ;
    assign cmp_top.iop.cmp_adbginit_l = cmp_adbginit_l ;

    assign cmp_top.iop.cmp_gclk = cmp_gclk ;
    assign cmp_top.iop.dram_gclk = dram_gclk ;
    assign cmp_top.iop.jbus_gclk = jbus_gclk ;

    assign cmp_top.iop.jbus_grst_l = jbus_grst_l ;
    assign cmp_top.iop.dram_grst_l = dram_grst_l ;
    assign cmp_top.iop.cmp_grst_out_l = cmp_grst_l ;
    assign cmp_top.iop.jbus_arst_l = jbus_arst_l ;
    assign cmp_top.iop.dram_arst_l = dram_arst_l ;
    assign cmp_top.iop.cmp_arst_l = cmp_arst_l ;

    assign cmp_grst = ~cmp_grst_l ;

  `else

    wire clk_ddr_slfrsh ; 
    wire cmp_grst_l = cmp_top.iop.cmp_grst_out_l ;
    wire cmp_grst = ~cmp_top.iop.cmp_grst_out_l ;
    wire jbus_gclk = cmp_top.iop.jbus_gclk ;
    wire cmp_gclk = cmp_top.iop.cmp_gclk ;
    wire cmp_rclk = cmp_top.iop.sparc0.rclk ;
    wire dram_gclk = cmp_top.iop.dram_gclk ;
    wire jbus_j_clk = j_clk ;
    wire jbus_j_clk_l = ~jbus_j_clk;

  `endif // ifdef MSS_SAT
`endif // ifdef DRAM_SAT


  ////////////////////////////////////////////////////////
  // jtag interface
  ////////////////////////////////////////////////////////

`ifdef DRAM_SAT
  assign cmp_top.iop.ctu_misc_mode_ctl = 1'b0 ;
  assign cmp_top.iop.ctu_misc_shift_dr  = 1'b0 ;
  assign cmp_top.iop.ctu_misc_hiz_l     = 1'b0 ;
  assign cmp_top.iop.ctu_misc_update_dr = 1'b0 ;
  assign cmp_top.iop.ctu_misc_clock_dr  = 1'b0 ;

  assign cmp_top.iop.io_test_mode = 1'b0 ;
  assign cmp_top.iop.ctu_ddr1_hiz_l = 0 ;
  assign cmp_top.iop.ctu_ddr1_mode_ctl = 0 ;
  assign cmp_top.iop.ctu_ddr2_mode_ctl = 0 ;
  assign cmp_top.iop.ctu_ddr2_hiz_l = 0 ;
  assign cmp_top.iop.ctu_ddr3_mode_ctl = 0 ;
  assign cmp_top.iop.ctu_ddr3_hiz_l = 0 ;

  assign cmp_top.iop.ctu_dram02_cmp_cken  = 1'b1 ;
  assign cmp_top.iop.ctu_dram13_cmp_cken  = 1'b1 ;
  assign cmp_top.iop.ctu_ddr0_dram_cken = 1 ;
  assign cmp_top.iop.ctu_ddr1_dram_cken = 1 ;
  assign cmp_top.iop.ctu_ddr2_dram_cken = 1 ;
  assign cmp_top.iop.ctu_ddr3_dram_cken = 1 ;
  assign cmp_top.iop.ctu_dram02_dram_cken = 1 ;
  assign cmp_top.iop.ctu_dram13_dram_cken = 1 ;
  assign cmp_top.iop.ctu_dram02_jbus_cken = 1 ;
  assign cmp_top.iop.ctu_dram13_jbus_cken = 1 ;

  assign cmp_top.iop.global_shift_enable = 1'b0 ;
  assign cmp_top.iop.ctu_dram_selfrsh = clk_ddr_slfrsh;
  assign cmp_top.iop.ctu_ddr0_hiz_l = 0 ;
  assign cmp_top.iop.ctu_ddr0_mode_ctl = 0 ;
  assign cmp_top.iop.ctu_ddr_testmode_l = 1'b1;

  assign cmp_top.iop.ctu_tst_scanmode = 0 ;
  assign cmp_top.iop.ctu_tst_macrotest = 0 ;
  assign cmp_top.iop.ctu_tst_pre_grst_l = 1 ;
  assign cmp_top.iop.ctu_tst_scan_disable = 0 ;
`endif

`ifdef MSS_SAT
  assign cmp_top.iop.ctu_misc_mode_ctl = 1'b0 ;
  assign cmp_top.iop.ctu_misc_shift_dr  = 1'b0 ;
  assign cmp_top.iop.ctu_misc_hiz_l     = 1'b0 ;
  assign cmp_top.iop.ctu_misc_update_dr = 1'b0 ;
  assign cmp_top.iop.ctu_misc_clock_dr  = 1'b0 ;

  assign cmp_top.iop.ctu_ddr0_hiz_l = 0 ;
  assign cmp_top.iop.ctu_ddr1_hiz_l = 0 ;
  assign cmp_top.iop.ctu_ddr2_hiz_l = 0 ;
  assign cmp_top.iop.ctu_ddr3_hiz_l = 0 ;
  assign cmp_top.iop.ctu_ddr0_mode_ctl = 0 ;
  assign cmp_top.iop.ctu_ddr1_mode_ctl = 0 ;
  assign cmp_top.iop.ctu_ddr2_mode_ctl = 0 ;
  assign cmp_top.iop.ctu_ddr3_mode_ctl = 0 ;

  assign cmp_top.iop.ctu_scdata0_cmp_cken = 1'b1 ;
  assign cmp_top.iop.ctu_scdata1_cmp_cken = 1'b1 ;
  assign cmp_top.iop.ctu_scdata2_cmp_cken = 1'b1 ;
  assign cmp_top.iop.ctu_scdata3_cmp_cken = 1'b1 ;
  assign cmp_top.iop.ctu_sctag0_cmp_cken  = 1'b1 ;
  assign cmp_top.iop.ctu_sctag1_cmp_cken  = 1'b1 ;
  assign cmp_top.iop.ctu_sctag2_cmp_cken  = 1'b1 ;
  assign cmp_top.iop.ctu_sctag3_cmp_cken  = 1'b1 ;
  assign cmp_top.iop.ctu_ccx_cmp_cken     = 1'b1 ;

  assign cmp_top.iop.ctu_ddr0_dram_cken = 1 ;
  assign cmp_top.iop.ctu_ddr1_dram_cken = 1 ;
  assign cmp_top.iop.ctu_ddr2_dram_cken = 1 ;
  assign cmp_top.iop.ctu_ddr3_dram_cken = 1 ;
  assign cmp_top.iop.ctu_dram02_cmp_cken  = 1'b1 ;
  assign cmp_top.iop.ctu_dram13_cmp_cken  = 1'b1 ;
  assign cmp_top.iop.ctu_dram02_dram_cken = 1 ;
  assign cmp_top.iop.ctu_dram13_dram_cken = 1 ;
  assign cmp_top.iop.ctu_dram02_jbus_cken = 1 ;
  assign cmp_top.iop.ctu_dram13_jbus_cken = 1 ;

  assign cmp_top.iop.io_test_mode = 1'b0 ;
  assign cmp_top.iop.global_shift_enable = 1'b0 ;
  assign cmp_top.iop.ctu_dram_selfrsh = clk_ddr_slfrsh;
  assign cmp_top.iop.ctu_ddr_testmode_l = 1'b1;
  assign cmp_top.iop.ctu_tst_scanmode = 0 ;
  assign cmp_top.iop.ctu_tst_macrotest = 0 ;
  assign cmp_top.iop.ctu_tst_scan_disable = 0 ;
  assign cmp_top.iop.ctu_sctag0_mbisten = 0;
  assign cmp_top.iop.ctu_sctag1_mbisten = 0;
  assign cmp_top.iop.ctu_sctag2_mbisten = 0;
  assign cmp_top.iop.ctu_sctag3_mbisten = 0;

  assign cmp_top.iop.ctu_tst_pre_grst_l = ctu_tst_pre_grst_l;
  initial begin
    ctu_tst_pre_grst_l = 0;
    repeat(120) @(posedge cmp_gclk);
    ctu_tst_pre_grst_l = 1;
  end
`endif

  ////////////////////////////////////////////////////////
  // OpenSPARCT1 instantiation
  ////////////////////////////////////////////////////////

  OpenSPARCT1 iop(/*AUTOINST*/
	  // Outputs
	  .DRAM0_RAS_L			(DRAM0_RAS_L),
	  .DRAM0_CAS_L			(DRAM0_CAS_L),
	  .DRAM0_WE_L			(DRAM0_WE_L),
	  .DRAM0_CS_L			(DRAM0_CS_L[3:0]),
	  .DRAM0_CKE			(DRAM0_CKE),
	  .DRAM0_ADDR			(DRAM0_ADDR[14:0]),
	  .DRAM0_BA			(DRAM0_BA[2:0]),
	  .DRAM0_CK_P			(DRAM0_CK_P[3:0]),
	  .DRAM0_CK_N			(DRAM0_CK_N[3:0]),
	  .DRAM1_RAS_L			(DRAM1_RAS_L),
	  .DRAM1_CAS_L			(DRAM1_CAS_L),
	  .DRAM1_WE_L			(DRAM1_WE_L),
	  .DRAM1_CS_L			(DRAM1_CS_L[3:0]),
	  .DRAM1_CKE			(DRAM1_CKE),
	  .DRAM1_ADDR			(DRAM1_ADDR[14:0]),
	  .DRAM1_BA			(DRAM1_BA[2:0]),
	  .DRAM1_CK_P			(DRAM1_CK_P[3:0]),
	  .DRAM1_CK_N			(DRAM1_CK_N[3:0]),
	  .CLKOBS			(CLKOBS[1:0]),
	  .DRAM2_RAS_L			(DRAM2_RAS_L),
	  .DRAM2_CAS_L			(DRAM2_CAS_L),
	  .DRAM2_WE_L			(DRAM2_WE_L),
	  .DRAM2_CS_L			(DRAM2_CS_L[3:0]),
	  .DRAM2_CKE			(DRAM2_CKE),
	  .DRAM2_ADDR			(DRAM2_ADDR[14:0]),
	  .DRAM2_BA			(DRAM2_BA[2:0]),
	  .DRAM2_CK_P			(DRAM2_CK_P[3:0]),
	  .DRAM2_CK_N			(DRAM2_CK_N[3:0]),
	  .DRAM3_RAS_L			(DRAM3_RAS_L),
	  .DRAM3_CAS_L			(DRAM3_CAS_L),
	  .DRAM3_WE_L			(DRAM3_WE_L),
	  .DRAM3_CS_L			(DRAM3_CS_L[3:0]),
	  .DRAM3_CKE			(DRAM3_CKE),
	  .DRAM3_ADDR			(DRAM3_ADDR[14:0]),
	  .DRAM3_BA			(DRAM3_BA[2:0]),
	  .DRAM3_CK_P			(DRAM3_CK_P[3:0]),
	  .DRAM3_CK_N			(DRAM3_CK_N[3:0]),
	  .J_PACK0			(J_PACK0[2:0]),
	  .J_PACK1			(J_PACK1[2:0]),
	  .J_REQ0_OUT_L			(J_REQ0_OUT_L),
	  .J_REQ1_OUT_L			(J_REQ1_OUT_L),
	  .J_ERR			(J_ERR),
	  .TSR_TESTIO			(TSR_TESTIO[1:0]),
	  .DIODE_TOP			(DIODE_TOP[2:0]),
	  .DIODE_BOT			(DIODE_BOT[2:0]),
	  .TDO				(TDO),
	  .SSI_MOSI			(SSI_MOSI),
	  .SSI_SCK			(SSI_SCK),
	  .PMO				(PMO),
	  .VDD_SENSE			(VDD_SENSE),
	  .VSS_SENSE			(VSS_SENSE),
	  // Inouts
          .DBG_DQ                       (DBG_DQ[39:0]),
          .DBG_CK_P                     (DBG_CK_P[2:0]),
          .DBG_CK_N                     (DBG_CK_N[2:0]),
          .DBG_VREF                     (DBG_VREF),
	  .DRAM0_DQ			(DRAM0_DQ[127:0]),
	  .DRAM0_CB			(DRAM0_CB[15:0]),
	  .DRAM0_DQS			(DRAM0_DQS[35:0]),
	  .SPARE_DDR0_PIN		(SPARE_DDR0_PIN),
	  .DRAM1_DQ			(DRAM1_DQ[127:0]),
	  .DRAM1_CB			(DRAM1_CB[15:0]),
	  .DRAM1_DQS			(DRAM1_DQS[35:0]),
	  .SPARE_DDR1_PIN		(SPARE_DDR1_PIN[2:0]),
	  .DRAM2_DQ			(DRAM2_DQ[127:0]),
	  .DRAM2_CB			(DRAM2_CB[15:0]),
	  .DRAM2_DQS			(DRAM2_DQS[35:0]),
	  .SPARE_DDR2_PIN		(SPARE_DDR2_PIN[2:0]),
	  .DRAM3_DQ			(DRAM3_DQ[127:0]),
	  .DRAM3_CB			(DRAM3_CB[15:0]),
	  .DRAM3_DQS			(DRAM3_DQS[35:0]),
	  .SPARE_DDR3_PIN		(SPARE_DDR3_PIN[2:0]),
	  .J_AD				(J_AD[127:0]),
	  .J_ADP			(J_ADP[3:0]),
	  .J_ADTYPE			(J_ADTYPE[7:0]),
	  .J_PAR			(J_PAR),
	  .SPARE_JBUSR_PIN		(SPARE_JBUSR_PIN),
	  .VDDA				(VDDA),
	  .VPP				(VPP),
	  .SPARE_MISC_PIN		(SPARE_MISC_PIN),
	  // Inputs
          .BURNIN                       (BURNIN),
	  .DRAM01_P_REF_RES		(DRAM01_P_REF_RES),
	  .DRAM01_N_REF_RES		(DRAM01_N_REF_RES),
	  .DRAM23_P_REF_RES		(DRAM23_P_REF_RES),
	  .DRAM23_N_REF_RES		(DRAM23_N_REF_RES),
	  .J_PACK4			(J_PACK4[2:0]),
	  .J_PACK5			(J_PACK5[2:0]),
	  .J_REQ4_IN_L			(J_REQ4_IN_L),
	  .J_REQ5_IN_L			(J_REQ5_IN_L),
	  .J_RST_L			(J_RST_L),
	  .DTL_L_VREF			(DTL_L_VREF),
	  .DTL_R_VREF			(DTL_R_VREF),
	  .JBUS_P_REF_RES		(JBUS_P_REF_RES),
	  .JBUS_N_REF_RES		(JBUS_N_REF_RES),
	  .J_CLK			(J_CLK[1:0]),
	  .TCK				(TCK),
	  .TCK2				(TCK2),
	  .TRST_L			(TRST_L),
	  .TDI				(TDI),
	  .TMS				(TMS),
	  .TEST_MODE			(TEST_MODE),
	  .PWRON_RST_L			(PWRON_RST_L),
	  .SSI_MISO			(SSI_MISO),
	  .CLK_STRETCH			(CLK_STRETCH),
	  .DO_BIST			(DO_BIST),
	  .EXT_INT_L			(EXT_INT_L),
	  .PMI				(PMI),
	  .PGRM_EN			(PGRM_EN),
	  .PLL_CHAR_IN			(PLL_CHAR_IN),
	  .VREG_SELBG_L			(VREG_SELBG_L),
	  .TEMP_TRIG			(TEMP_TRIG),
	  .TRIGIN			(TRIGIN),
	  .HSTL_VREF			(HSTL_VREF));
	  // .VDD_PLL			(VDD_PLL),
	  // .VDD_TSR			(VDD_TSR));

  `ifdef RTL_DRAM02

  // instantiate dram modules
  
  cmp_dram cmp_dram(/*AUTOINST*/
		    // Inouts
		    .DRAM0_CB		(DRAM0_CB[15:0]),
		    .DRAM0_DQ		(DRAM0_DQ[127:0]),
		    .DRAM0_DQS		(DRAM0_DQS[35:0]),
		    .DRAM1_CB		(DRAM1_CB[15:0]),
		    .DRAM1_DQ		(DRAM1_DQ[127:0]),
		    .DRAM1_DQS		(DRAM1_DQS[35:0]),
		    .DRAM2_CB		(DRAM2_CB[15:0]),
		    .DRAM2_DQ		(DRAM2_DQ[127:0]),
		    .DRAM2_DQS		(DRAM2_DQS[35:0]),
		    .DRAM3_CB		(DRAM3_CB[15:0]),
		    .DRAM3_DQ		(DRAM3_DQ[127:0]),
		    .DRAM3_DQS		(DRAM3_DQS[35:0]),
		    .DRAM02_SDA		(DRAM02_SDA),
		    .DRAM13_SDA		(DRAM13_SDA),
		    // Inputs
		    .DRAM02_SCL		(DRAM02_SCL),
		    .DRAM13_SCL		(DRAM13_SCL),
		    .DRAM0_ADDR		(DRAM0_ADDR[14:0]),
		    .DRAM0_BA		(DRAM0_BA[2:0]),
		    .DRAM0_CAS_L	(DRAM0_CAS_L),
		    .DRAM0_CKE		(DRAM0_CKE),
		    .DRAM0_CK_N		(DRAM0_CK_N[3:0]),
		    .DRAM0_CK_P		(DRAM0_CK_P[3:0]),
		    .DRAM0_CS_L		(DRAM0_CS_L[3:0]),
		    .DRAM0_RAS_L	(DRAM0_RAS_L),
		    .DRAM0_RST_L	(cmp_top.iop.cmp_grst_out_l),		 // Templated
		    .DRAM0_WE_L		(DRAM0_WE_L),
		    .DRAM1_ADDR		(DRAM1_ADDR[14:0]),
		    .DRAM1_BA		(DRAM1_BA[2:0]),
		    .DRAM1_CAS_L	(DRAM1_CAS_L),
		    .DRAM1_CKE		(DRAM1_CKE),
		    .DRAM1_CK_N		(DRAM1_CK_N[3:0]),
		    .DRAM1_CK_P		(DRAM1_CK_P[3:0]),
		    .DRAM1_CS_L		(DRAM1_CS_L[3:0]),
		    .DRAM1_RAS_L	(DRAM1_RAS_L),
		    .DRAM1_RST_L	(cmp_top.iop.cmp_grst_out_l),		 // Templated
		    .DRAM1_WE_L		(DRAM1_WE_L),
		    .DRAM2_ADDR		(DRAM2_ADDR[14:0]),
		    .DRAM2_BA		(DRAM2_BA[2:0]),
		    .DRAM2_CAS_L	(DRAM2_CAS_L),
		    .DRAM2_CKE		(DRAM2_CKE),
		    .DRAM2_CK_N		(DRAM2_CK_N[3:0]),
		    .DRAM2_CK_P		(DRAM2_CK_P[3:0]),
		    .DRAM2_CS_L		(DRAM2_CS_L[3:0]),
		    .DRAM2_RAS_L	(DRAM2_RAS_L),
		    .DRAM2_RST_L	(cmp_top.iop.cmp_grst_out_l),		 // Templated
		    .DRAM2_WE_L		(DRAM2_WE_L),
		    .DRAM3_ADDR		(DRAM3_ADDR[14:0]),
		    .DRAM3_BA		(DRAM3_BA[2:0]),
		    .DRAM3_CAS_L	(DRAM3_CAS_L),
		    .DRAM3_CKE		(DRAM3_CKE),
		    .DRAM3_CK_N		(DRAM3_CK_N[3:0]),
		    .DRAM3_CK_P		(DRAM3_CK_P[3:0]),
		    .DRAM3_CS_L		(DRAM3_CS_L[3:0]),
		    .DRAM3_RAS_L	(DRAM3_RAS_L),
		    .DRAM3_RST_L	(cmp_top.iop.cmp_grst_out_l),		 // Templated
		    .DRAM3_WE_L		(DRAM3_WE_L),
		    .DRAM_FAIL_OVER	(DRAM_FAIL_OVER),
		    .DRAM_FAIL_PART	(DRAM_FAIL_PART[5:0]),
		    .XXSA		(XXSA[2:0]),
		    .XXWP		(XXWP),
		    .cmp_grst		(cmp_grst),
		    .dram_gclk		(cmp_top.iop.dram_gclk));
  
  `endif


  /*monitor  AUTO_TEMPLATE
  (
  .rst_l(cmp_grst_l),
  .clk(cmp_gclk),
  );
  */

  monitor   monitor(/*AUTOINST*/
		    // Inputs
		    .clk		(cmp_rclk),		 // Templated
		    .cmp_gclk		(cmp_gclk),		 // Templated
		    .rst_l		(cmp_grst_l));		 // Templated

`ifdef RTL_IOBDG
  dbg_port_chk dbg_port_chk () ;
`endif

  cmp_mem   cmp_mem();

`ifdef GATE_SIM
`else
  `ifdef MSS_SAT
  `else
   `ifdef DRAM_SAT
    err_inject err_inject();
   `else
    err_inject err_inject();
    one_hot_mux_mon one_hot_mux_mon();
   `endif // ifdef DRAM_SAT
  `endif // ifdef MSS_SAT
`endif // ifdef GATE_SIM

  
`ifdef DRAM_SAT
`else
  `ifdef MSS_SAT

    slam_init slam_init();

    pcx_stall pcx_stall();

    cpx_stall cpx_stall();

  `else

  `ifdef GATE_SIM
  `else
    // randomly asserts sctag_pcx_stall_pq to exercise protocol adherence of Core
    pcx_stall pcx_stall();

    // randomly asserts CPX stall signal to make CPX packets arrive at the Cores in bursts
    cpx_stall cpx_stall();
  `endif // ifdef GATE_SIM

    ////////////////////////////////////////////////////////
    // system interfaces - boot rom, external interrupts
    ////////////////////////////////////////////////////////

    initial begin
      $init_jbus_model("mem.image");
    end

    bw_sys bw_sys(/*AUTOINST*/
               // Outputs
               .ssi_miso              (SSI_MISO),
               .ext_int_l             (EXT_INT_L),
	       .warm_rst_l            (warm_rst_trig_l),
	       .temp_trig             (TEMP_TRIG),
	       .clk_stretch           (CLK_STRETCH), 
               // Inputs
               .j_rst_l               (j_rst_l),
               .jbus_gclk             (jbus_j_clk),
               .ssi_sck               (SSI_SCK),
               .ssi_mosi              (SSI_MOSI));

    ////////////////////////////////////////////////////////
    // slam initial values into model
    ////////////////////////////////////////////////////////

    slam_init slam_init () ;

    ////////////////////////////////////////////////////////
    // efuse stub
    ////////////////////////////////////////////////////////

    assign PGRM_EN = 0 ;

    // efuse_stub efuse_stub (
    //   .efc_iob_coreavail_dshift   (`TOP_MOD.iop.efc_iob_coreavail_dshift),
    //   .efc_iob_fuse_clk1          (`TOP_MOD.iop.efc_iob_fuse_clk1),
    //   .efc_iob_fuse_data          (`TOP_MOD.iop.efc_iob_fuse_data),
    //   .efc_iob_fusestat_dshift    (`TOP_MOD.iop.efc_iob_fusestat_dshift),
    //   .efc_iob_sernum0_dshift     (`TOP_MOD.iop.efc_iob_sernum0_dshift),
    //   .efc_iob_sernum1_dshift     (`TOP_MOD.iop.efc_iob_sernum1_dshift),
    //   .efc_iob_sernum2_dshift     (`TOP_MOD.iop.efc_iob_sernum2_dshift),
    //   .jbus_arst_l                (cmp_top.iop.jbus_arst_l),
    //   .jbus_gclk                  (jbus_j_clk)
    // );

  `endif // ifdef MSS_SAT
`endif  // ifdef DRAM_SAT


  ////////////////////////////////////////////////////////
  // clock generator stub
  ////////////////////////////////////////////////////////

`ifdef MSS_SAT
    `define DRAM_OR_MSS_SAT
`else
  `ifdef DRAM_SAT
    `define DRAM_OR_MSS_SAT
  `endif 
`endif

`ifdef DRAM_OR_MSS_SAT

  assign TCK = 1'b0 ;
  assign TCK2 = 1'b0 ;
  assign TEST_MODE = 1'b0 ;

  sys_clk sys_clk (
                    // InOuts
                    .pwron_rst_l        (pwron_rst_l),
                    .j_rst_l            (j_rst_l),
                    .free_jbus_gclk     (jbus_j_clk),
                    //.jbus_gclk          (j_clk),
                    .jbus_gclk          (jbus_gclk),
                    .free_clk           (free_clk),
                    .dram_gclk          (dram_gclk),
                    .free_dram_gclk     (free_dram_gclk),
                    .cmp_gclk           (cmp_gclk),
                    .pci_gclk           (pci_gclk),
                    .io_gb_clkref       (io_gb_clkref),
                    .jbus_grst_l        (jbus_grst_l),
                    .cmp_grst_l         (cmp_grst_l),
                    .dram_grst_l        (dram_grst_l),
                    .jbus_arst_l        (jbus_arst_l),
                    .cmp_arst_l         (cmp_arst_l),
                    .dram_arst_l        (dram_arst_l),
                    // .ctu_jbi_fst_rst_l  (`TOP_MOD.iop.ctu_jbi_fst_rst_l),
                    .ctu_jbi_ssiclk     (`TOP_MOD.iop.ctu_jbi_ssiclk),
                    .jbus_gdbginit_l        (jbus_gdbginit_l),
                    .cmp_gdbginit_l         (cmp_gdbginit_l),
                    .dram_gdbginit_l        (dram_gdbginit_l),
                    .jbus_adbginit_l        (jbus_adbginit_l),
                    .cmp_adbginit_l         (cmp_adbginit_l),
                    .dram_adbginit_l        (dram_adbginit_l),
                    .clspine_jbus_tx_sync (`TOP_MOD.iop.ctu_jbus_tx_sync_out),
                    .clspine_jbus_rx_sync (`TOP_MOD.iop.ctu_jbus_rx_sync_out),
                    .clspine_dram_tx_sync (`TOP_MOD.iop.ctu_dram_tx_sync_out),
                    .clspine_dram_rx_sync (`TOP_MOD.iop.ctu_dram_rx_sync_out),
                    // Inputs
                    .rst_l              (rst_l));

`else

    assign stub_pass[3] = 1'b1 ;
    assign stub_done[3] = cken_off_done ;
    assign TCK2 = TCK ;

   // this part determines when to trigger a warm reset so that do_bist sequence can be driven
   initial begin
      pwron_seq_done = 1'b0 ;
      do_bist_warm_rst_trig_l = 1'b1;
      // wait for pwron_rst_l deassertion
      @(posedge pwron_rst_l);
      // wait for first deassertion of j_rst_l, cold pwron
      @(posedge j_rst_l);
      pwron_seq_done = 1'b1;
      if ($test$plusargs("do_bist")) begin
         // wait for wake thread to determine when efc array readout is done
         //      @(posedge cmp_top.iop.ctu_iob_wake_thr);
         // need to be more deterministic, and since efc readout is deterministic, can hard set a wait time
         // 22 cyles from deassertion of J_RST_L to efc_read_start, 8K to wake_thr
         repeat (8022 * pll_byp_offset) @(posedge j_clk);
         // trigger a warm reset
         do_bist_warm_rst_trig_l = 1'b0;
         @(posedge j_clk);
         do_bist_warm_rst_trig_l = 1'b1;
      end
   end
  
   assign warm_rst_l = j_fatal_error_l & warm_rst_trig_l & do_bist_warm_rst_trig_l;

   cmp_clk cmp_clk (
                    .warm_rst_l         (warm_rst_l),    // input
                    .in_pll_byp					(in_pll_byp),    // input
                    .test_mode          (TEST_MODE),
                    .cken_off_done      (cken_off_done), // output
                    .tck                (cmp_tck),           // output
                    .pwron_rst_l        (pwron_rst_l),   // output
                    .j_rst_l            (j_rst_l),       // output
		                .xir_l              (xir_l),         // output
		                .pwrok              (pwrok),         // output
                    .j_clk              (j_clk),         // output
                    .pll_char_in        (PLL_CHAR_IN),   // output
                    .do_bist            (DO_BIST),       // output
                    .g_rd_clk           (g_rd_clk),      // output
                    .g_upa_refclk       (g_upa_refclk),  // output
                    .p_clk              (p_clk),         // output
                    .ichip_clk          (ichip_clk)) ;   // output


`endif // ifdef DRAM_OR_MSS_SAT

`ifdef DRAM_SAT
`else
  `ifdef MSS_SAT
  `else

    ////////////////////////////////////////////////////////
    // iobridge rtl/stub
    ////////////////////////////////////////////////////////

    `ifdef RTL_IOBDG
    `else
      ciop_iob ciop_iob(
                     // Outputs
                     .iob_clk_l2_tr     (`TOP_MOD.iop.iob_ctu_l2_tr),
                     .iob_clk_tr        (`TOP_MOD.iop.iob_ctu_tr),
                     .iob_cpx_data_ca   (`TOP_MOD.iop.iob_cpx_data_ca[`CPX_WIDTH-1:0]),
                     .iob_cpx_req_cq    (`TOP_MOD.iop.iob_cpx_req_cq[`IOB_CPU_WIDTH-1:0]),
                     .iob_ctu_coreavail (`TOP_MOD.iop.iob_ctu_coreavail[`IOB_CPU_WIDTH-1:0]),
                     .iob_io_dbg_data   (`TOP_MOD.iop.iob_io_dbg_data[39:0]),
                     .iob_io_dbg_en     (`TOP_MOD.iop.iob_io_dbg_en),
                     .iob_jbi_dbg_hi_data(`TOP_MOD.iop.iob_jbi_dbg_hi_data[47:0]),
                     .iob_jbi_dbg_hi_vld(`TOP_MOD.iop.iob_jbi_dbg_hi_vld),
                     .iob_jbi_dbg_lo_data(`TOP_MOD.iop.iob_jbi_dbg_lo_data[47:0]),
                     .iob_jbi_dbg_lo_vld(`TOP_MOD.iop.iob_jbi_dbg_lo_vld),
                     .iob_jbi_mondo_ack (`TOP_MOD.iop.iob_jbi_mondo_ack),
                     .iob_jbi_mondo_nack(`TOP_MOD.iop.iob_jbi_mondo_nack),
                     .iob_pcx_stall_pq  (`TOP_MOD.iop.iob_pcx_stall_pq),
                     .iob_clk_data      (`TOP_MOD.iop.iob_clsp_data[`IOB_CLK_WIDTH-1:0]),
                     .iob_clk_stall     (`TOP_MOD.iop.iob_clsp_stall),
                     .iob_clk_vld       (`TOP_MOD.iop.iob_clsp_vld),
                     .iob_dram02_data   (`TOP_MOD.iop.iob_dram02_data[`IOB_DRAM_WIDTH-1:0]),
                     .iob_dram02_stall  (`TOP_MOD.iop.iob_dram02_stall),
                     .iob_dram02_vld    (`TOP_MOD.iop.iob_dram02_vld),
                     .iob_dram13_data   (`TOP_MOD.iop.iob_dram13_data[`IOB_DRAM_WIDTH-1:0]),
                     .iob_dram13_stall  (`TOP_MOD.iop.iob_dram13_stall),
                     .iob_dram13_vld    (`TOP_MOD.iop.iob_dram13_vld),
                     .iob_jbi_pio_data  (`TOP_MOD.iop.iob_jbi_pio_data[`IOB_JBI_WIDTH-1:0]),
                     .iob_jbi_pio_stall (`TOP_MOD.iop.iob_jbi_pio_stall),
                     .iob_jbi_pio_vld   (`TOP_MOD.iop.iob_jbi_pio_vld),
                     .iob_jbi_spi_data  (`TOP_MOD.iop.iob_jbi_spi_data[`IOB_SPI_WIDTH-1:0]),
                     .iob_jbi_spi_stall (`TOP_MOD.iop.iob_jbi_spi_stall),
                     .iob_jbi_spi_vld   (`TOP_MOD.iop.iob_jbi_spi_vld),
                     .iob_tap_data      (`TOP_MOD.iop.iob_tap_data[`IOB_TAP_WIDTH-1:0]),
                     .iob_tap_stall     (`TOP_MOD.iop.iob_tap_stall),
                     .iob_tap_vld       (`TOP_MOD.iop.iob_tap_vld),
                     .iob_scanout       (`TOP_MOD.iop.par_scan_tail[30]),
                     .iob_io_dbg_ck_p   (`TOP_MOD.iop.iob_io_dbg_ck_p[2:0]),
                     .iob_io_dbg_ck_n   (`TOP_MOD.iop.iob_io_dbg_ck_n[2:0]),
                     // Inputs
                     .clk_iob_cken                       (`TOP_MOD.iop.ctu_iob_jbus_cken),
                     .clspine_iob_resetstat              (`TOP_MOD.iop.ctu_iob_resetstat[`IOB_RESET_STAT_WIDTH-1:0]),
                     .clspine_iob_resetstat_wr           (`TOP_MOD.iop.ctu_iob_resetstat_wr),
                     .clspine_jbus_rx_sync               (`TOP_MOD.iop.ctu_jbus_rx_sync_out),
                     .clspine_jbus_tx_sync               (`TOP_MOD.iop.ctu_jbus_tx_sync_out),
                     .cpx_iob_grant_cx2  (`TOP_MOD.iop.cpx_iob_grant_cx2[`IOB_CPU_WIDTH-1:0]),
                     .ctu_iob_wake_thr  (`TOP_MOD.iop.ctu_iob_wake_thr),
                     .jbi_iob_mondo_data(`TOP_MOD.iop.jbi_iob_mondo_data[`JBI_IOB_MONDO_BUS_WIDTH-1:0]),
                     .jbi_iob_mondo_vld (`TOP_MOD.iop.jbi_iob_mondo_vld),
                     .jbus_gclk         (`TOP_MOD.iop.jbi.jbus_rclk),
                     .jbus_grst_l       (`TOP_MOD.iop.jbi.jbus_grst_l),
                     .pcx_iob_data_px2   (`TOP_MOD.iop.pcx_iob_data_px2[`PCX_WIDTH-1:0]),
                     .pcx_iob_data_rdy_px2(`TOP_MOD.iop.pcx_iob_data_rdy_px2),
                     .dram02_iob_data   (`TOP_MOD.iop.dram02_iob_data[`DRAM_IOB_WIDTH-1:0]),
                     .dram02_iob_stall  (`TOP_MOD.iop.dram02_iob_stall),
                     .dram02_iob_vld    (`TOP_MOD.iop.dram02_iob_vld),
                     .dram13_iob_data   (`TOP_MOD.iop.dram13_iob_data[`DRAM_IOB_WIDTH-1:0]),
                     .dram13_iob_stall  (`TOP_MOD.iop.dram13_iob_stall),
                     .dram13_iob_vld    (`TOP_MOD.iop.dram13_iob_vld),
                     .jbi_iob_pio_data  (`TOP_MOD.iop.jbi_iob_pio_data[`JBI_IOB_WIDTH-1:0]),
                     .jbi_iob_pio_stall (`TOP_MOD.iop.jbi_iob_pio_stall),
                     .jbi_iob_pio_vld   (`TOP_MOD.iop.jbi_iob_pio_vld),
                     .jbi_iob_spi_data  (`TOP_MOD.iop.jbi_iob_spi_data[`SPI_IOB_WIDTH-1:0]),
                     .jbi_iob_spi_stall (`TOP_MOD.iop.jbi_iob_spi_stall),
                     .jbi_iob_spi_vld   (`TOP_MOD.iop.jbi_iob_spi_vld),

                     `ifdef GATE_SIM_SPARC
                     .spc0_inst_done    (`TOP_MOD.monitor.pc_cmp.spc0_inst_done),
                     .pc_w0             (`PCPATH0.ifu_fdp.pc_w),
                     `else
                     `ifdef RTL_SPARC0
                     .spc0_inst_done    (`TOP_MOD.monitor.pc_cmp.spc0_inst_done),
                     .pc_w0             (`PCPATH0.fdp.pc_w),
                     `else
                     .spc0_inst_done    (1'b0),
                     .pc_w0             (49'h0),
                     `endif
		     `endif // ifdef GATE_SIM_SPARC	

                     `ifdef RTL_SPARC1
                     .spc1_inst_done    (`TOP_MOD.monitor.pc_cmp.spc1_inst_done),
                     .pc_w1             (`PCPATH1.fdp.pc_w),
                     `else
                     .spc1_inst_done    (1'b0),
                     .pc_w1             (49'h0),
                     `endif

                     `ifdef RTL_SPARC2
                     .spc2_inst_done    (`TOP_MOD.monitor.pc_cmp.spc2_inst_done),
                     .pc_w2             (`PCPATH2.fdp.pc_w),
                     `else
                     .spc2_inst_done    (1'b0),
                     .pc_w2             (49'h0),
                     `endif

                     `ifdef RTL_SPARC3
                     .spc3_inst_done    (`TOP_MOD.monitor.pc_cmp.spc3_inst_done),
                     .pc_w3             (`PCPATH3.fdp.pc_w),
                     `else
                     .spc3_inst_done    (1'b0),
                     .pc_w3             (49'h0),
                     `endif

                     `ifdef RTL_SPARC4
                     .spc4_inst_done    (`TOP_MOD.monitor.pc_cmp.spc4_inst_done),
                     .pc_w4             (`PCPATH4.fdp.pc_w),
                     `else
                     .spc4_inst_done    (1'b0),
                     .pc_w4             (49'h0),
                     `endif

                     `ifdef RTL_SPARC5
                     .spc5_inst_done    (`TOP_MOD.monitor.pc_cmp.spc5_inst_done),
                     .pc_w5             (`PCPATH5.fdp.pc_w),
                     `else
                     .spc5_inst_done    (1'b0), 
                     .pc_w5             (49'h0),     
                     `endif

                     `ifdef RTL_SPARC6
                     .spc6_inst_done    (`TOP_MOD.monitor.pc_cmp.spc6_inst_done),
                     .pc_w6             (`PCPATH6.fdp.pc_w),
                     `else
                     .spc6_inst_done    (1'b0), 
                     .pc_w6             (49'h0),     
                     `endif

                     `ifdef RTL_SPARC7
                     .spc7_inst_done    (`TOP_MOD.monitor.pc_cmp.spc7_inst_done),
                     .pc_w7             (`PCPATH7.fdp.pc_w),
                     `else
                     .spc7_inst_done    (1'b0), 
                     .pc_w7             (49'h0),     
                     `endif

                     .cmp_gclk          (`TOP_MOD.iop.ccx.rclk));

    `endif // ifdef RTL_IOBDG
  `endif // ifdef MSS_SAT
`endif // ifdef DRAM_SAT


  ////////////////////////////////////////////////////////
  // dft stuff
  ////////////////////////////////////////////////////////

//  assign DO_BIST = 1'b0;
//  assign CLK_STRETCH = 1'b0;
  assign VREG_SELBG_L = 1'b0 ;
//  assign PLL_CHAR_IN = 1'b0 ;
  assign VDD_PLL = 1'b1 ;
  assign VDD_TSR = 1'b1 ;


  // flags for verification environment
  reg 	fail_flag, diag_done;
  initial begin
      fail_flag = 0;
      diag_done =0;
  end // initial begin

  // parse command line for monitors
  initial begin
    $monInit();
    $monErrorDisable() ;
    while (cmp_top.iop.jbus_grst_l !== 1'b0) @(posedge j_clk) ;
    @(posedge cmp_top.iop.jbus_grst_l) ;
    $monErrorEnable() ;
  end


`ifdef DRAM_SAT
`else
  `ifdef MSS_SAT
    assign J_RST_L = j_rst_l ;
  `else

    ////////////////////////////////////////////////////////
    // jbus proper
    ////////////////////////////////////////////////////////

    assign (weak0,weak1) J_AD = 128'hffffffffffffffffffffffffffffffff ;
    assign (weak0,weak1) J_ADP = 4'b1111 ;
    assign (weak0,weak1) J_ADTYPE = 8'b11111111 ;
    assign (weak0,weak1) J_PACK0 = 3'b111 ;
    assign (weak0,weak1) J_PACK1 = 3'b111 ;
    assign (weak0,weak1) j_pack2 = 3'b111 ;
    assign (weak0,weak1) j_pack3 = 3'b111 ;
    assign (weak0,weak1) J_PACK4 = 3'b111 ;
    assign (weak0,weak1) J_PACK5 = 3'b111 ;
    assign (weak0,weak1) j_pack6 = 3'b111 ;

   // for pll bypass case, to ensure repeatability we mask out the clock until
   // entering bypass mode
   reg     j_clk_mask;
   initial begin
      j_clk_mask = 1'b1;
      if ($test$plusargs("tap_pll_byp")) begin
	       if ($test$plusargs("mask_j_clk")) begin
	          $display("cmp_top.v: %0d masking j_clk", $time);
	          j_clk_mask = 1'b0;
	  
	          @(posedge cmp_top.iop.ctu.pll_bypass);
	          repeat (4) @(posedge j_clk);
	          j_clk_mask = 1'b1;
	          $display("cmp_top.v: %0d unmasking j_clk", $time);
	       end
      end
   end

   assign J_CLK [0] = j_clk & j_clk_mask;
   assign J_CLK [1] = ~j_clk & j_clk_mask;

    assign (weak0,weak1) j_req_out_l_0 = 6'b111111 ;
    assign (weak0,weak1) j_req_out_l_1 = 6'b111111 ;
    assign (weak0,weak1) j_req_out_l_2 = 6'b111111 ;
    assign (weak0,weak1) j_req_out_l_3 = 6'b111111 ;
    assign (weak0,weak1) j_req_out_l_4 = 6'b111111 ;
    assign (weak0,weak1) j_req_out_l_5 = 6'b111111 ;
    assign (weak0,weak1) j_req_out_l_6 = 6'b111111 ;

    assign (weak0,weak1) j_req_in_l_0 = 6'b111111 ;
    assign (weak0,weak1) j_req_in_l_1 = 6'b111111 ;
    assign (weak0,weak1) j_req_in_l_2 = 6'b111111 ;
    assign (weak0,weak1) j_req_in_l_3 = 6'b111111 ;
    assign (weak0,weak1) j_req_in_l_4 = 6'b111111 ;
    assign (weak0,weak1) j_req_in_l_5 = 6'b111111 ;
    assign (weak0,weak1) j_req_in_l_6 = 6'b111111 ;

    assign (weak0,weak1) j_change_l = 1'b1 ;

    // bw pins
    assign j_req_out_l_0 = {3{J_REQ1_OUT_L,J_REQ0_OUT_L}} ;
    assign J_REQ4_IN_L = j_req_in_l_0 [3] ;
    assign J_REQ5_IN_L = j_req_in_l_0 [4] ;

    // bw
    assign j_req_in_l_0 [3] = j_req_out_l_4 [0] ;
    assign j_req_in_l_0 [4] = j_req_out_l_5 [0] ;

    // sjm 4
    assign j_req_in_l_4 [0] = j_req_out_l_5 [0] ;
    assign j_req_in_l_4 [2] = j_req_out_l_0 [0] ;
    assign j_req_in_l_4 [3] = j_req_out_l_1 [0] ;

    // sjm 5
    assign j_req_in_l_5 [1] = j_req_out_l_0 [1] ;
    assign j_req_in_l_5 [2] = j_req_out_l_1 [0] ;
    assign j_req_in_l_5 [5] = j_req_out_l_4 [0] ;
  
    ////////////////////////////////////////////////////////
    // sjm
    ////////////////////////////////////////////////////////

    initial begin
      jbus_j_por_l_reg = 1'b0 ;
      repeat (15) @(posedge jbus_j_clk) ;
      jbus_j_por_l_reg = 1'b1 ;
    end

    assign jbus_j_por_l = jbus_j_por_l_reg ;

    initial begin
      $disable_errwarnmon();
    end

    // disable_errwarnmon is used to disable the dispmon error messages during reset
    always @(negedge J_RST_L) begin
      $dispmon("reset", 0, "Detected reset assertion.  Will disable errwarnmon") ;
      $disable_errwarnmon() ;
    end

    // enable_errwarnmon is used to enable the dispmon error messages after reset
    always @(posedge J_RST_L) begin
      if (pwron_seq_done == 1'b1) begin
	       $dispmon("reset", 0, "Detected reset deassertion.  Will enable errwarnmon") ;
         $enable_errwarnmon() ;
      end
    end

`ifdef NO_SJM
`else
// { start ifndef NO_SJM, SJM code segment

    initial begin
      // Trigger sjm stubs
      trigger_sjm_4 = 1'b0;
      trigger_sjm_5 = 1'b0;
      // Drive reset to pci master stubs
      reset_handler_done = 1'b0;
      sjm_init_status = $sjm_init ;
    end

    always @(posedge j_clk) begin
      while (cmp_top.iop.jbus_grst_l !== 1'b0) @(posedge j_clk) ;
     // added to start sjms after second reset for tester runs
     if ($test$plusargs("tester_rst_seq")) begin
       repeat (2) @(posedge cmp_top.iop.jbus_grst_l) ;
     end else
      @(posedge cmp_top.iop.jbus_grst_l) ;
      repeat (8) @(posedge j_clk) ;
      trigger_sjm_4 = 1'b1;
      trigger_sjm_5 = 1'b1;
      reset_handler_done = 1'b1;
    end

// } end ifndef NO_SJM, SJM code segment
`endif
    
    assign stub_pass[1] = 1'b1 ; // sjm will die before getting here if a failure occurs
    assign stub_done[1] = (sjm_4_status === 2'b11) ? 1'b1 : 1'b0 ;

`ifdef NO_SJM
`else
// { start ifndef NO_SJM, SJM code segment

    ////////////////////////////////////////////////////////
    // sjm 4
    ////////////////////////////////////////////////////////
  
    always @(posedge j_clk) begin
      cmp_top.j_sjm_4.sjm_status (sjm_4_status) ;
      // $info (0, "sjm 4 status %d", sjm_4_status);
    end

    always @ (posedge trigger_sjm_4) begin
      $info (0, "Starting sjm_4 master devices");
      cmp_top.j_sjm_4.sjm_start_executing;
    end

    jp_sjm j_sjm_4 (
                   .j_id        (3'b100),
                   .j_req_in_l  (j_req_in_l_4),
                   .j_req_out_l (j_req_out_l_4),  //output
                   .j_ad        (J_AD),          //inout
                   .j_adp       (J_ADP),         //inout
                   .j_adtype    (J_ADTYPE),      //inout
                   .j_pack0     (J_PACK0),      //inout
                   .j_pack1     (J_PACK1),      //inout
                   .j_pack2     (j_pack2),      //inout
                   .j_pack3     (j_pack3),      //inout
                   .j_pack4     (J_PACK4),      //inout
                   .j_pack5     (J_PACK5),      //inout
                   .j_pack6     (j_pack6),      //inout
                   .j_change_l  (j_change_l),      //inout
                   .j_rst_l     (j_rst_l),        //inout
                   .j_por_l     (jbus_j_por_l),        //inout
                   .j_clk       (jbus_j_clk),
                   .pwr_ok      (pwrok)
                   );

// } end ifndef NO_SJM, SJM code segment
`endif

    assign stub_pass[2] = 1'b1 ; // sjm will die before getting here if a failure occurs
    assign stub_done[2] = (sjm_5_status === 2'b11) ? 1'b1 : 1'b0 ;

// { start SJM_5 code segment

   // These signals are driven by I/O Bridge when it is present
   // in the system.
   assign 		j_err_5 = 1'b0;
   assign 		J_PAR = j_par_d2 ;
   assign 		J_RST_L = j_rst_l ;
   assign 		PWRON_RST_L = pwron_rst_l ;

   assign 		p_rst_l = 1'b1;
   assign 		g_rst_l = 1'b1;

   ////////////////////////////////////////////////////////
   // jbus fatal error detection
   ////////////////////////////////////////////////////////

   // DOK ON for 4 consecutive cycles indicates a fatal error.  I/O Bridge
   // should recognize this and assert j_rst_l.
   always @(posedge jbus_j_clk) begin
     j_pack0_d1 <= J_PACK0 ;
     j_pack0_d2 <= j_pack0_d1 ;
     j_pack0_d3 <= j_pack0_d2 ;
     j_pack1_d1 <= J_PACK1 ;
     j_pack1_d2 <= j_pack1_d1 ;
     j_pack1_d3 <= j_pack1_d2 ;

     j_fatal_error_l  <= ((J_PACK0 === 3'h7) &&
                          (j_pack0_d1 === 3'h7) &&
                          (j_pack0_d2 === 3'h7) &&
                          (j_pack0_d3 === 3'h7)) ||

                         ((J_PACK1 === 3'h7) &&
                          (j_pack1_d1 === 3'h7) &&
                          (j_pack1_d2 === 3'h7) &&
                          (j_pack1_d3 === 3'h7)) ? 1'b0 : 1'b1 ;
   end

 `ifdef NO_SJM
 `else
 // { start ifndef NO_SJM, SJM code segment

   ////////////////////////////////////////////////////////
   // sjm 5
   ////////////////////////////////////////////////////////

   always @(posedge j_clk) begin
     cmp_top.j_sjm_5.sjm_status (sjm_5_status) ;
     // $info (0, "sjm 5 status %d", sjm_5_status);
   end

   always @ (posedge trigger_sjm_5) begin
     $info (0, "Starting sjm_5 master devices");
     cmp_top.j_sjm_5.sjm_start_executing;
   end

   jp_sjm j_sjm_5 (
                   .j_id        (3'b101),
                   .j_req_in_l  (j_req_in_l_5),
                   .j_req_out_l (j_req_out_l_5),  //output
                   .j_ad        (J_AD),          //inout
                   .j_adp       (J_ADP),         //inout
                   .j_adtype    (J_ADTYPE),      //inout
                   .j_pack0     (J_PACK0),      //inout
                   .j_pack1     (J_PACK1),      //inout
                   .j_pack2     (j_pack2),      //inout
                   .j_pack3     (j_pack3),      //inout
                   .j_pack4     (J_PACK4),      //inout
                   .j_pack5     (J_PACK5),      //inout
                   .j_pack6     (j_pack6),      //inout
                   .j_change_l  (j_change_l),      //inout
                   .j_rst_l     (j_rst_l),        //inout
                   .j_por_l     (jbus_j_por_l),        //inout
                   .j_clk       (jbus_j_clk),
                   .pwr_ok      (pwrok)
                   );

 // } end ifndef NO_SJM, SJM code segment
 `endif

// } end SJM_5 code segment

    ////////////////////////////////////////////////////////
    // parity generation
    ////////////////////////////////////////////////////////

    always @(posedge jbus_j_clk) begin
      j_pack0_d <=  J_PACK0 ;
      j_pack1_d <=  J_PACK1 ;
      j_pack2_d <=  j_pack2 ;
      j_pack3_d <=  j_pack3 ;
      j_pack4_d <=  J_PACK4 ;
      j_pack5_d <=  J_PACK5 ;
      j_pack6_d <=  j_pack6 ;
  
      j_par_d1  <= ~ ((j_req_out_l_0 [0]) ^
                      (j_req_out_l_1 [0]) ^
                      (j_req_out_l_2 [0]) ^
                      (j_req_out_l_3 [0]) ^
                      (j_req_out_l_4 [0]) ^
                      (j_req_out_l_5 [0]) ^
                      (j_req_out_l_6 [0]) ^
                      (^ j_pack0_d) ^
                      (^ j_pack1_d) ^
                      (^ j_pack2_d) ^
                      (^ j_pack3_d) ^
                      (^ j_pack4_d) ^
                      (^ j_pack5_d) ^
                      (^ j_pack6_d)) ;

      j_par_d2 <= j_par_d1 ;

    end

    `ifdef NO_JBUS_MON
    `else
    ////////////////////////////////////////////////////////
    // jbus monitor
    ////////////////////////////////////////////////////////

    always @(posedge diag_done) begin
       $jbus_mon_finish;
    end
  
    jbus_monitor jbus_monitor (
                              .jbus_j_req_out_l_0 (j_req_out_l_0),
                              .jbus_j_req_out_l_1 (j_req_out_l_1),
                              .jbus_j_req_out_l_2 (j_req_out_l_2),
                              .jbus_j_req_out_l_3 (j_req_out_l_3),
                              .jbus_j_req_out_l_4 (j_req_out_l_4),
                              .jbus_j_req_out_l_5 (j_req_out_l_5),
                              .jbus_j_req_out_l_6 (j_req_out_l_6),
                              .jbus_j_ad          (J_AD),
                              .jbus_j_adtype      (J_ADTYPE),
                              .jbus_j_adp         (J_ADP),
                              .jbus_j_pack0       (J_PACK0),
                              .jbus_j_pack1       (J_PACK1),
                              .jbus_j_pack2       (j_pack2),
                              .jbus_j_pack3       (j_pack3),
                              .jbus_j_pack4       (J_PACK4),
                              .jbus_j_pack5       (J_PACK5),
                              .jbus_j_pack6       (j_pack6),
                              .jbus_j_par         (J_PAR),
                              .jbus_j_rst         (j_rst_l),
                              .jbus_j_por         (jbus_j_por_l),
                              .jbus_j_clk         (jbus_j_clk),
                              .local_ports        (7'h33),
                              .jbus_j_err         ({1'b0, j_err_5, 5'h0}),
                              .jbus_j_change_l    (j_change_l)
                              );
    `endif // NO_JBUS_MON
  `endif // ifdef MSS_SAT
`endif // ifdef DRAM_SAT


`ifdef INCLUDE_SAS_TASKS

  // turn on sas interface after a delay
  reg 	need_sas_sparc_intf_update;
  initial begin
      need_sas_sparc_intf_update  = 0;
      #12500;
      need_sas_sparc_intf_update  = 1;
  end // initial begin

  sas_intf  sas_intf(/*AUTOINST*/
		     // Inputs
		     .clk		(cmp_rclk),		 // Templated
		     .rst_l		(cmp_grst_l));		 // Templated

  // create sas tasks
  sas_tasks sas_tasks(/*AUTOINST*/
		      // Inputs
		      .clk		(cmp_rclk),		 // Templated
		      .rst_l		(cmp_grst_l));		 // Templated

  // sparc pipe flow monitor
  sparc_pipe_flow sparc_pipe_flow(/*AUTOINST*/
				  // Inputs
				  .clk	(cmp_rclk));		 // Templated
  // initialize client to communicate with ref model through socket      
  integer 	vsocket, i, list_handle;
  initial begin 
	//list_handle = $bw_list(list_handle, 0);chin's change
     //if not use sas, list should not be called
	if($test$plusargs("use_sas_tasks"))begin
	   list_handle = $bw_list(list_handle, 0);
           $bw_socket_init();
	end
  end

`endif // ifdef INCLUDE_SAS_TASKS

  
`ifdef GATE_SIM
  initial $sdf_annotate ("cmp_top.sdf") ;
`endif

// This code is needed for production vector generation
// please do not remove it
`ifdef RTL_PAD_JBUSR
  always @(posedge  cmp_top.iop.pad_jbusr.clk) begin
    jbi_io_j_ad_en_d =  cmp_top.iop.pad_jbusr.jbi_io_j_ad_en ;
    jbi_io_j_adp_en_d =  cmp_top.iop.pad_jbusr.jbi_io_j_adp_en ;
    jbi_io_j_adtype_en_d = cmp_top.iop.pad_jbusr.jbi_io_j_adtype_en ;
    jbi_io_j_pack0_en_d = cmp_top.iop.pad_jbusr.jbi_io_j_pack0_en ;
    jbi_io_j_pack1_en_d = cmp_top.iop.pad_jbusr.jbi_io_j_pack1_en ;
  end
`endif

`ifdef NO_VERA
// { start of NO_VERA
// Sniper is not present when vera is missing ... tie the sparc
// ports off here

`ifdef RTL_SPARC0
`else
assign cmp_top.iop.spc0_pcx_data_pa = 1'b0 ;
assign cmp_top.iop.spc0_pcx_req_pq = 5'b00000 ;
assign cmp_top.iop.spc0_pcx_atom_pq = 1'b0 ;
`endif

`ifdef RTL_SPARC1
`else
assign cmp_top.iop.spc1_pcx_data_pa = 1'b0 ;
assign cmp_top.iop.spc1_pcx_req_pq = 5'b00000 ;
assign cmp_top.iop.spc1_pcx_atom_pq = 1'b0 ;
`endif

`ifdef RTL_SPARC2
`else
assign cmp_top.iop.spc2_pcx_data_pa = 1'b0 ;
assign cmp_top.iop.spc2_pcx_req_pq = 5'b00000 ;
assign cmp_top.iop.spc2_pcx_atom_pq = 1'b0 ;
`endif

`ifdef RTL_SPARC3
`else
assign cmp_top.iop.spc3_pcx_data_pa = 1'b0 ;
assign cmp_top.iop.spc3_pcx_req_pq = 5'b00000 ;
assign cmp_top.iop.spc3_pcx_atom_pq = 1'b0 ;
`endif

`ifdef RTL_SPARC4
`else
assign cmp_top.iop.spc4_pcx_data_pa = 1'b0 ;
assign cmp_top.iop.spc4_pcx_req_pq = 5'b00000 ;
assign cmp_top.iop.spc4_pcx_atom_pq = 1'b0 ;
`endif

`ifdef RTL_SPARC5
`else
assign cmp_top.iop.spc5_pcx_data_pa = 1'b0 ;
assign cmp_top.iop.spc5_pcx_req_pq = 5'b00000 ;
assign cmp_top.iop.spc5_pcx_atom_pq = 1'b0 ;
`endif

`ifdef RTL_SPARC6
`else
assign cmp_top.iop.spc6_pcx_data_pa = 1'b0 ;
assign cmp_top.iop.spc6_pcx_req_pq = 5'b00000 ;
assign cmp_top.iop.spc6_pcx_atom_pq = 1'b0 ;
`endif

`ifdef RTL_SPARC7
`else
assign cmp_top.iop.spc7_pcx_data_pa = 1'b0 ;
assign cmp_top.iop.spc7_pcx_req_pq = 5'b00000 ;
assign cmp_top.iop.spc7_pcx_atom_pq = 1'b0 ;
`endif

// } endif of NO_VERA
`endif


`ifdef MSS_SAT
`else
//tcl interface
 `ifdef TCL_TAP_TEST
   assign TCK = tclk;
   tap tap( // Outputs
            .stub_done (stub_done[0]),
            .stub_pass(stub_pass[0]),
            .trst_n (TRST_L),
            .tms (TMS),
            .tdi (TDI),
            .trigin(TRIGIN),
	    .tclk(tclk),
            // Inputs
            .tdo (TDO),
            .tck(cmp_tck)
           );
 `else
   assign TCK = cmp_tck;
   
   task send_tap_cmd;
      begin
         tap_end_cmd = 1'b1; // this will enable the final tap command that goes back to rst state
         @(posedge j_clk);
         trig_tap_cmd = 1'b1;
         @(posedge j_clk);
         trig_tap_cmd = 1'b0;
      end
   endtask

   // all tap related commands
   initial begin
      trig_tap_cmd = 1'b0;
      tap_end_cmd = 1'b0;
      in_pll_byp = 1'b0;
      if ($test$plusargs("tester_tap_seq")) begin
         // pll bypass
         if ($test$plusargs("tap_pll_byp")) begin
	          @(negedge cmp_top.tap_stub.stub_done); // wait for tap_stub to get ready
	          repeat (2) @(posedge TCK); // addition wait required for tap_stub
	          $display("cmp_top.v: %0d sending pll_bypass command thru tap", $time);
	          send_tap_cmd;
	          in_pll_byp = 1'b1;
         end

         // wait for first j_rst_l deassertion, warm reset
         @(posedge pwron_seq_done);

         // clock divider programming
         if ($test$plusargs("tap_wr_clk_div")) begin
	          $display("cmp_top.v: %0d programming clk divs thru tap", $time);
            repeat (200) @(posedge j_clk);
	          send_tap_cmd;
            delay = 7350 - 200;
         end
         else begin
         // 22 cycles, then efc_read_start issued, efc array readout will take 8K cycles
         // inside the efc, the word addr count == 6'h3f at 7322 cycles, starting from pwron_seq_done
         // question is to count 7350 or sync on the word addr count in the efc?
         // why 7350?  no particular reason.  multiply by 4 during pll bypass mode
         delay = 7350 * pll_byp_offset;
         end
         $display("cmp_top.v: %0d waiting %d jbus cycles for efc array readout", $time, delay);
         repeat (delay) @(posedge j_clk);

         // send efc_byp_data and efc_byp command
         if ($test$plusargs("tap_efc_byp")) begin
	          $display("cmp_top.v: %0d sending efc_bypass_data and efc_bypass_cmd thru tap", $time);
	          send_tap_cmd;
         end

         // toggle out of pll_bypass
         if ($test$plusargs("tap_clr_pll_bypass")) begin
	          send_tap_cmd;
         end

         // wait for start of warm rst, where bisi will started on do_bist pin
         $display("cmp_top.v: %0d syncing on start of warm reset", $time);
         @(negedge j_rst_l);
         $display("cmp_top.v: %0d warm reset started", $time);
         @(posedge j_clk);

         // wait for end of warm_rst, when do_bist happens, then wait to issue bist_abort
         $display("cmp_top.v: %0d syncing on end of warm reset", $time);
         @(posedge j_rst_l);
         $display("cmp_top.v: %0d end of warm reset detected", $time);
         // bist_abort
         if ($test$plusargs("tap_bist_abort")) begin
	          // bist_abort after 10K cpu cycles, in bypass mode cpu clk is same as j_clk
	          // in normal mode at 4:16 ratio, that comes to 2500 j_clk cycles
	          delay = 2500 * pll_byp_offset;
	          $display("cmp_top.v: %0d waiting %d jbus cycles before issuing bist_abort", $time, delay);
	          repeat (delay) @(posedge j_clk);

	          $display("cmp_top.v: %0d sending bist_abort thru tap", $time);
	          send_tap_cmd;
         end

         // the final tap command, go to reset state
         if (tap_end_cmd == 1'b1) begin
	          $display("cmp_top.v: %0d sending tap end command", $time);
	          send_tap_cmd;
         end
      end
  end
    
   assign pll_byp_offset = 1 + (3 * in_pll_byp);

   tap_stub tap_stub (
                      // Outputs
                      .stub_done (stub_done[0]),
                      .stub_pass (stub_pass[0]),
                      .trst_n (TRST_L),
                      .tms (TMS),
                      .tdi (TDI),
                      .trigin(TRIGIN),
                      // Inputs
                      .tdo (TDO),
                      .tck (TCK),
                      .diag_done (diag_done),
		                  .trig_tap_cmd(trig_tap_cmd)
                      ) ;
 `endif
`endif


`ifdef FSDB_OFF
`else
  // control dumping of debussy waveform
  integer limitInMegaBytes;
  initial begin
        if ($test$plusargs("debussy")) begin
	  // the following must be specified before any other fsdb command
	  // [Viranjit 04/13/04]
          if ($value$plusargs ("fsdbDumplimit=%d", limitInMegaBytes)) begin
            $fsdbDumplimit(limitInMegaBytes);
          end
          if ($value$plusargs ("fsdbfile=%s", filename)) begin
            $fsdbDumpfile(filename);
          end

          if ($test$plusargs("gate_sim")) begin
            $fsdbDumpvars(1, cmp_top.iop);
`ifdef RTL_SPARC0
            $fsdbDumpvars(1, cmp_top.iop.sparc0);
`endif
`ifdef RTL_SPARC1
            $fsdbDumpvars(1, cmp_top.iop.sparc1);
`endif
`ifdef RTL_SPARC2
            $fsdbDumpvars(1, cmp_top.iop.sparc2);
`endif
`ifdef RTL_SPARC3
            $fsdbDumpvars(1, cmp_top.iop.sparc3);
`endif
`ifdef RTL_SPARC4
            $fsdbDumpvars(1, cmp_top.iop.sparc4);
`endif
`ifdef RTL_SPARC5
            $fsdbDumpvars(1, cmp_top.iop.sparc5);
`endif
`ifdef RTL_SPARC6
            $fsdbDumpvars(1, cmp_top.iop.sparc6);
`endif
`ifdef RTL_SPARC7
            $fsdbDumpvars(1, cmp_top.iop.sparc7);
`endif
          end
          else if ($test$plusargs("pinonly")) begin
            $fsdbDumpvars(1, cmp_top.cmp_gclk);
            $fsdbDumpvars(1, cmp_top.dram_gclk);
            $fsdbDumpvars(1, cmp_top.jbus_gclk);
            $fsdbDumpvars(1, cmp_top.iop.ctu_dram_rx_sync_out);
            $fsdbDumpvars(1, cmp_top.iop.ctu_dram_tx_sync_out);
            $fsdbDumpvars(1, cmp_top.iop.ctu_jbus_rx_sync_out);
            $fsdbDumpvars(1, cmp_top.iop.ctu_jbus_tx_sync_out);
            `ifdef GATE_SIM
            `else
               $fsdbDumpvars(1, cmp_top.iop.ctu.ctu_clsp.u_ctu_clsp_ctrl.text);
            `endif 
            $fsdbDumpvars(1, cmp_top.DBG_CK_P);
            $fsdbDumpvars(1, cmp_top.DBG_CK_N);
            $fsdbDumpvars(1, cmp_top.DBG_DQ);
            $fsdbDumpvars(1, cmp_top.DRAM0_RAS_L);
            $fsdbDumpvars(1, cmp_top.DRAM0_CAS_L);
            $fsdbDumpvars(1, cmp_top.DRAM0_WE_L);
            $fsdbDumpvars(1, cmp_top.DRAM0_CS_L);
            $fsdbDumpvars(1, cmp_top.DRAM0_CKE);
            $fsdbDumpvars(1, cmp_top.DRAM0_ADDR);
            $fsdbDumpvars(1, cmp_top.DRAM0_BA);
            $fsdbDumpvars(1, cmp_top.ddr0_dq);
            $fsdbDumpvars(1, cmp_top.ddr0_cb);
            $fsdbDumpvars(1, cmp_top.DRAM0_DQS);
            $fsdbDumpvars(1, cmp_top.DRAM0_CK_P);
            $fsdbDumpvars(1, cmp_top.DRAM0_CK_N);
            $fsdbDumpvars(1, cmp_top.SPARE_DDR0_PIN);
`ifdef RTL_PAD_DDR0
            $fsdbDumpvars(1, cmp_top.ddr0_pad_dq_oe);
            $fsdbDumpvars(1, cmp_top.ddr0_pad_dqs_oe);
`endif
            $fsdbDumpvars(1, cmp_top.DRAM1_RAS_L);
            $fsdbDumpvars(1, cmp_top.DRAM1_CAS_L);
            $fsdbDumpvars(1, cmp_top.DRAM1_WE_L);
            $fsdbDumpvars(1, cmp_top.DRAM1_CS_L);
            $fsdbDumpvars(1, cmp_top.DRAM1_CKE);
            $fsdbDumpvars(1, cmp_top.DRAM1_ADDR);
            $fsdbDumpvars(1, cmp_top.DRAM1_BA);
            $fsdbDumpvars(1, cmp_top.ddr1_dq);
            $fsdbDumpvars(1, cmp_top.ddr1_cb);
            $fsdbDumpvars(1, cmp_top.DRAM1_DQS);
            $fsdbDumpvars(1, cmp_top.DRAM1_CK_P);
            $fsdbDumpvars(1, cmp_top.DRAM1_CK_N);
            $fsdbDumpvars(1, cmp_top.SPARE_DDR1_PIN);
`ifdef RTL_PAD_DDR1
            $fsdbDumpvars(1, cmp_top.ddr1_pad_dq_oe);
            $fsdbDumpvars(1, cmp_top.ddr1_pad_dqs_oe);
`endif
            $fsdbDumpvars(1, cmp_top.CLKOBS);
            $fsdbDumpvars(1, cmp_top.DRAM2_RAS_L);
            $fsdbDumpvars(1, cmp_top.DRAM2_CAS_L);
            $fsdbDumpvars(1, cmp_top.DRAM2_WE_L);
            $fsdbDumpvars(1, cmp_top.DRAM2_CS_L);
            $fsdbDumpvars(1, cmp_top.DRAM2_CKE);
            $fsdbDumpvars(1, cmp_top.DRAM2_ADDR);
            $fsdbDumpvars(1, cmp_top.DRAM2_BA);
            $fsdbDumpvars(1, cmp_top.ddr2_dq);
            $fsdbDumpvars(1, cmp_top.ddr2_cb);
            $fsdbDumpvars(1, cmp_top.DRAM2_DQS);
            $fsdbDumpvars(1, cmp_top.DRAM2_CK_P);
            $fsdbDumpvars(1, cmp_top.DRAM2_CK_N);
            $fsdbDumpvars(1, cmp_top.SPARE_DDR2_PIN);
`ifdef RTL_PAD_DDR2
            $fsdbDumpvars(1, cmp_top.ddr2_pad_dq_oe);
            $fsdbDumpvars(1, cmp_top.ddr2_pad_dqs_oe);
`endif
            $fsdbDumpvars(1, cmp_top.DRAM3_RAS_L);
            $fsdbDumpvars(1, cmp_top.DRAM3_CAS_L);
            $fsdbDumpvars(1, cmp_top.DRAM3_WE_L);
            $fsdbDumpvars(1, cmp_top.DRAM3_CS_L);
            $fsdbDumpvars(1, cmp_top.DRAM3_CKE);
            $fsdbDumpvars(1, cmp_top.DRAM3_ADDR);
            $fsdbDumpvars(1, cmp_top.DRAM3_BA);
            $fsdbDumpvars(1, cmp_top.ddr3_dq);
            $fsdbDumpvars(1, cmp_top.ddr3_cb);
            $fsdbDumpvars(1, cmp_top.DRAM3_DQS);
            $fsdbDumpvars(1, cmp_top.DRAM3_CK_P);
            $fsdbDumpvars(1, cmp_top.DRAM3_CK_N);
            $fsdbDumpvars(1, cmp_top.SPARE_DDR3_PIN);
`ifdef RTL_PAD_DDR3
            $fsdbDumpvars(1, cmp_top.ddr3_pad_dq_oe);
            $fsdbDumpvars(1, cmp_top.ddr3_pad_dqs_oe);
`endif
            $fsdbDumpvars(1, cmp_top.J_CLK);
            $fsdbDumpvars(1, cmp_top.J_REQ4_IN_L);
            $fsdbDumpvars(1, cmp_top.J_REQ5_IN_L);
            $fsdbDumpvars(1, cmp_top.J_REQ0_OUT_L);
            $fsdbDumpvars(1, cmp_top.J_REQ1_OUT_L);
            $fsdbDumpvars(1, cmp_top.J_AD);
            $fsdbDumpvars(1, cmp_top.J_ADP);
            $fsdbDumpvars(1, cmp_top.J_ADTYPE);
            $fsdbDumpvars(1, cmp_top.J_PACK0);
            $fsdbDumpvars(1, cmp_top.J_PACK1);
            $fsdbDumpvars(1, cmp_top.jbi_io_j_ad_en_d);
            $fsdbDumpvars(1, cmp_top.jbi_io_j_adp_en_d);
            $fsdbDumpvars(1, cmp_top.jbi_io_j_adtype_en_d);
            $fsdbDumpvars(1, cmp_top.jbi_io_j_pack0_en_d);
            $fsdbDumpvars(1, cmp_top.jbi_io_j_pack1_en_d);
            $fsdbDumpvars(1, cmp_top.J_PACK4);
            $fsdbDumpvars(1, cmp_top.J_PACK5);
            $fsdbDumpvars(1, cmp_top.J_PAR);
            $fsdbDumpvars(1, cmp_top.J_ERR);
            $fsdbDumpvars(1, cmp_top.J_RST_L);
            $fsdbDumpvars(1, cmp_top.SPARE_JBUSR_PIN);
            $fsdbDumpvars(1, cmp_top.SPARE_MISC_PIN);
            $fsdbDumpvars(1, cmp_top.BURNIN);
            $fsdbDumpvars(1, cmp_top.TEMP_TRIG);
            $fsdbDumpvars(1, cmp_top.PWRON_RST_L);
            $fsdbDumpvars(1, cmp_top.TDI);
            $fsdbDumpvars(1, cmp_top.TDO);
            $fsdbDumpvars(1, cmp_top.TCK);
            $fsdbDumpvars(1, cmp_top.TCK2);
            $fsdbDumpvars(1, cmp_top.TRST_L);
            $fsdbDumpvars(1, cmp_top.TMS);
            $fsdbDumpvars(1, cmp_top.PLL_CHAR_IN);
            $fsdbDumpvars(1, cmp_top.DO_BIST);
            $fsdbDumpvars(1, cmp_top.TRIGIN);
            $fsdbDumpvars(1, cmp_top.SSI_MOSI);
            $fsdbDumpvars(1, cmp_top.SSI_MISO);
            $fsdbDumpvars(1, cmp_top.SSI_SCK);
            $fsdbDumpvars(1, cmp_top.EXT_INT_L);
            $fsdbDumpvars(1, cmp_top.TEST_MODE);
            $fsdbDumpvars(1, cmp_top.PGRM_EN);
            $fsdbDumpvars(1, cmp_top.PMI);
            $fsdbDumpvars(1, cmp_top.PMO);
            $fsdbDumpvars(1, cmp_top.CLK_STRETCH);
            $fsdbDumpvars(1, cmp_top.VREG_SELBG_L);
            $fsdbDumpvars(1, cmp_top.iop.ctu_iob_wake_thr);

`ifdef RTL_IOBDG
            $fsdbDumpvars(1, cmp_top.dbg_port_chk.dbg_dq_a4i0) ;
            $fsdbDumpvars(1, cmp_top.dbg_port_chk.dbg_dq_a2i0) ;
            $fsdbDumpvars(1, cmp_top.dbg_port_chk.dbg_dq_a2i1) ;
            $fsdbDumpvars(1, cmp_top.dbg_port_chk.dbg_dq_a2i2) ;
            $fsdbDumpvars(1, cmp_top.dbg_port_chk.dbg_dq_a2i3) ;
            $fsdbDumpvars(1, cmp_top.dbg_port_chk.dbg_dq_a2i6) ;
            $fsdbDumpvars(1, cmp_top.dbg_port_chk.dbg_dq_a2i7) ;
            $fsdbDumpvars(1, cmp_top.dbg_port_chk.dbg_dq_a3i7) ;
            $fsdbDumpvars(1, cmp_top.dbg_port_chk.dbg_dq_a3i6) ;
            $fsdbDumpvars(1, cmp_top.dbg_port_chk.dbg_dq_a3i3) ;
`endif
          end
          else if ($test$plusargs("gate_top")) 
          begin
            $fsdbDumpvars(1,cmp_top.iop);
          end
          else begin
            $fsdbDumpvars(0, cmp_top);
          end
        end
  end
`endif

///////////////////////////////////////////////
// Generate fake OE for DQ and CB pads at DDR0.
///////////////////////////////////////////////

`ifdef RTL_PAD_DDR0
`ifdef GATE_SIM_DRAM
wire ddr0_pad_dqs_oe = cmp_top.iop.pad_ddr0.ddr0_ddr_ch_I0_I0_ddr_6sig0_dqs_pad0_dqs_edgelogic_oe_n ;
`else
wire ddr0_pad_dqs_oe = cmp_top.iop.pad_ddr0.ddr0_ddr_ch.I0.I0.ddr_6sig0.dqs_pad0.dqs_edgelogic.oe ;
wire ddr0_drive_dqs_q = cmp_top.iop.pad_ddr0.ddr0_ddr_ch.I0.I0.ddr_6sig0.dqs_pad0.dqs_edgelogic.drive_dqs_q;
wire ddr0_dqs_read = cmp_top.iop.pad_ddr0.ddr0_ddr_ch.I0.I0.ddr_6sig0.dq_pad0.dq_edgelogic.dqs_read;
`endif

dffrl_async #(1) flop_ddr0_oe(
                .din(ddr0_drive_dqs_q),
                .q(ddr0_pad_dq_oe),
		.rst_l(pwron_rst_l),
                .clk(~ddr0_dqs_read), .si(), .so(), .se(1'b0));

wire [127:0] ddr0_dq = ddr0_pad_dqs_oe & ddr0_pad_dq_oe ? cmp_top.DRAM0_DQ : 
		       ddr0_pad_dqs_oe ? 128'hz :
                       cmp_top.DRAM0_DQ ;
wire [15:0] ddr0_cb = ddr0_pad_dqs_oe & ddr0_pad_dq_oe ? cmp_top.DRAM0_CB : 
                      ddr0_pad_dqs_oe ? 16'hz :
                      cmp_top.DRAM0_CB;
`endif

///////////////////////////////////////////////
// FOR DDR1
///////////////////////////////////////////////

`ifdef RTL_PAD_DDR1
`ifdef GATE_SIM_DRAM
wire ddr1_pad_dqs_oe = cmp_top.iop.pad_ddr1.ddr1_ddr_ch_b_I0_I0_ddr_6sig0_dqs_pad0_dqs_edgelogic_oe_n ;
`else
wire ddr1_pad_dqs_oe = cmp_top.iop.pad_ddr1.ddr1_ddr_ch_b.I0.I0.ddr_6sig0.dqs_pad0.dqs_edgelogic.oe ;
wire ddr1_drive_dqs_q = cmp_top.iop.pad_ddr1.ddr1_ddr_ch_b.I0.I0.ddr_6sig0.dqs_pad0.dqs_edgelogic.drive_dqs_q;
wire ddr1_dqs_read = cmp_top.iop.pad_ddr1.ddr1_ddr_ch_b.I0.I0.ddr_6sig0.dq_pad0.dq_edgelogic.dqs_read;
`endif

dffrl_async #(1) flop_ddr1_oe(
                .din(ddr1_drive_dqs_q),
                .q(ddr1_pad_dq_oe),   
                .rst_l(pwron_rst_l),
                .clk(~ddr1_dqs_read), .si(), .so(), .se(1'b0));

wire [127:0] ddr1_dq = ddr1_pad_dqs_oe & ddr1_pad_dq_oe ? cmp_top.DRAM1_DQ :
                       ddr1_pad_dqs_oe ? 128'hz : 
                       cmp_top.DRAM1_DQ ;
wire [15:0] ddr1_cb = ddr1_pad_dqs_oe & ddr1_pad_dq_oe ? cmp_top.DRAM1_CB :
                      ddr1_pad_dqs_oe ? 16'hz : 
                      cmp_top.DRAM1_CB;
`endif

///////////////////////////////////////////////
// FOR DDR2
///////////////////////////////////////////////

`ifdef RTL_PAD_DDR2
`ifdef GATE_SIM_DRAM
wire ddr2_pad_dqs_oe = cmp_top.iop.pad_ddr2.ddr2_ddr_ch_I0_I0_ddr_6sig0_dqs_pad0_dqs_edgelogic_oe_n ;
`else
wire ddr2_pad_dqs_oe = cmp_top.iop.pad_ddr2.ddr2_ddr_ch.I0.I0.ddr_6sig0.dqs_pad0.dqs_edgelogic.oe ;
wire ddr2_drive_dqs_q = cmp_top.iop.pad_ddr2.ddr2_ddr_ch.I0.I0.ddr_6sig0.dqs_pad0.dqs_edgelogic.drive_dqs_q;
wire ddr2_dqs_read = cmp_top.iop.pad_ddr2.ddr2_ddr_ch.I0.I0.ddr_6sig0.dq_pad0.dq_edgelogic.dqs_read;
`endif

dffrl_async #(1) flop_ddr2_oe(
                .din(ddr2_drive_dqs_q),
                .q(ddr2_pad_dq_oe),   
                .rst_l(pwron_rst_l),
                .clk(~ddr2_dqs_read), .si(), .so(), .se(1'b0));

wire [127:0] ddr2_dq = ddr2_pad_dqs_oe & ddr2_pad_dq_oe ? cmp_top.DRAM2_DQ :
                       ddr2_pad_dqs_oe ? 128'hz :
                       cmp_top.DRAM2_DQ ;
wire [15:0] ddr2_cb = ddr2_pad_dqs_oe & ddr2_pad_dq_oe ? cmp_top.DRAM2_CB :
                      ddr2_pad_dqs_oe ? 16'hz :
                      cmp_top.DRAM2_CB;
`endif

///////////////////////////////////////////////
// FOR DDR3
///////////////////////////////////////////////

`ifdef RTL_PAD_DDR3
`ifdef GATE_SIM_DRAM
wire ddr3_pad_dqs_oe = cmp_top.iop.pad_ddr3.ddr3_ddr_ch_b_I0_I0_ddr_6sig2_dqs_pad0_dqs_edgelogic_oe_n ;
`else
wire ddr3_pad_dqs_oe = cmp_top.iop.pad_ddr3.ddr3_ddr_ch_b.I0.I0.ddr_6sig0.dqs_pad0.dqs_edgelogic.oe ;
wire ddr3_drive_dqs_q = cmp_top.iop.pad_ddr3.ddr3_ddr_ch_b.I0.I0.ddr_6sig0.dqs_pad0.dqs_edgelogic.drive_dqs_q;
wire ddr3_dqs_read = cmp_top.iop.pad_ddr3.ddr3_ddr_ch_b.I0.I0.ddr_6sig0.dq_pad0.dq_edgelogic.dqs_read;
`endif

dffrl_async #(1) flop_ddr3_oe(
                .din(ddr3_drive_dqs_q),
                .q(ddr3_pad_dq_oe),   
                .rst_l(pwron_rst_l),
                .clk(~ddr3_dqs_read), .si(), .so(), .se(1'b0));

wire [127:0] ddr3_dq = ddr3_pad_dqs_oe & ddr3_pad_dq_oe ? cmp_top.DRAM3_DQ :
                       ddr3_pad_dqs_oe ? 128'hz :
                       cmp_top.DRAM3_DQ ;
wire [15:0] ddr3_cb = ddr3_pad_dqs_oe & ddr3_pad_dq_oe ? cmp_top.DRAM3_CB :
                      ddr3_pad_dqs_oe ? 16'hz :
                      cmp_top.DRAM3_CB;
`endif

endmodule // cmp_top
