// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: board.v
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
`timescale 1 ns/10 ps

`uselib lib=unisims_ver

module board
(
	sys_clk_pin,
	sys_rst_pin
);

input sys_clk_pin;
input sys_rst_pin;
  
// Internal Signals
wire fpga_0_RS232_Uart_1_RX_pin;
wire fpga_0_RS232_Uart_1_TX_pin;
wire [1:0] fpga_0_DDR2_SDRAM_DDR2_ODT_pin;
wire [12:0] fpga_0_DDR2_SDRAM_DDR2_Addr_pin;
wire [1:0] fpga_0_DDR2_SDRAM_DDR2_BankAddr_pin;
wire fpga_0_DDR2_SDRAM_DDR2_CAS_n_pin;
wire [1:0] fpga_0_DDR2_SDRAM_DDR2_CE_pin;
wire [1:0] fpga_0_DDR2_SDRAM_DDR2_CS_n_pin;
wire fpga_0_DDR2_SDRAM_DDR2_RAS_n_pin;
wire fpga_0_DDR2_SDRAM_DDR2_WE_n_pin;
wire [1:0] fpga_0_DDR2_SDRAM_DDR2_Clk_pin;
wire [1:0] fpga_0_DDR2_SDRAM_DDR2_Clk_n_pin;
wire [7:0] fpga_0_DDR2_SDRAM_DDR2_DM_pin;
wire [7:0] fpga_0_DDR2_SDRAM_DDR2_DQS;
wire [7:0] fpga_0_DDR2_SDRAM_DDR2_DQS_n;
wire [63:0] fpga_0_DDR2_SDRAM_DDR2_DQ;
`ifdef ETHERNET_LITE
wire fpga_0_Ethernet_MAC_PHY_rst_n_pin;
wire fpga_0_Ethernet_MAC_PHY_crs_pin;
wire fpga_0_Ethernet_MAC_PHY_col_pin;
wire [3:0] fpga_0_Ethernet_MAC_PHY_tx_data_pin;
wire fpga_0_Ethernet_MAC_PHY_tx_en_pin;
wire fpga_0_Ethernet_MAC_PHY_tx_clk_pin;
wire fpga_0_Ethernet_MAC_PHY_rx_er_pin;
wire fpga_0_Ethernet_MAC_PHY_rx_clk_pin;
wire fpga_0_Ethernet_MAC_PHY_dv_pin;
wire [3:0] fpga_0_Ethernet_MAC_PHY_rx_data_pin;
`else
wire fpga_0_Hard_Ethernet_MAC_PHY_MII_INT;
wire fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin;
wire fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin;
wire fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin;
wire fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin;
wire fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin;
wire fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin;
wire fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin;
wire fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin;
wire fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin;
wire fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin;
wire fpga_0_Hard_Ethernet_MAC_MDC_0_pin;
wire fpga_0_Hard_Ethernet_MAC_MDIO_0_pin;
`endif

wire [9:0] noconnect10;
wire noconnect;
   

system
	system_0
  (
    .fpga_0_RS232_Uart_1_RX_pin(fpga_0_RS232_Uart_1_RX_pin),
    .fpga_0_RS232_Uart_1_TX_pin(fpga_0_RS232_Uart_1_TX_pin),
    .fpga_0_DDR2_SDRAM_DDR2_ODT_pin(fpga_0_DDR2_SDRAM_DDR2_ODT_pin),
    .fpga_0_DDR2_SDRAM_DDR2_Addr_pin(fpga_0_DDR2_SDRAM_DDR2_Addr_pin),
    .fpga_0_DDR2_SDRAM_DDR2_BankAddr_pin(fpga_0_DDR2_SDRAM_DDR2_BankAddr_pin),
    .fpga_0_DDR2_SDRAM_DDR2_CAS_n_pin(fpga_0_DDR2_SDRAM_DDR2_CAS_n_pin),
    .fpga_0_DDR2_SDRAM_DDR2_CE_pin(fpga_0_DDR2_SDRAM_DDR2_CE_pin),
    .fpga_0_DDR2_SDRAM_DDR2_CS_n_pin(fpga_0_DDR2_SDRAM_DDR2_CS_n_pin),
    .fpga_0_DDR2_SDRAM_DDR2_RAS_n_pin(fpga_0_DDR2_SDRAM_DDR2_RAS_n_pin),
    .fpga_0_DDR2_SDRAM_DDR2_WE_n_pin(fpga_0_DDR2_SDRAM_DDR2_WE_n_pin),
    .fpga_0_DDR2_SDRAM_DDR2_Clk_pin(fpga_0_DDR2_SDRAM_DDR2_Clk_pin),
    .fpga_0_DDR2_SDRAM_DDR2_Clk_n_pin(fpga_0_DDR2_SDRAM_DDR2_Clk_n_pin),
    .fpga_0_DDR2_SDRAM_DDR2_DM_pin(fpga_0_DDR2_SDRAM_DDR2_DM_pin),
    .fpga_0_DDR2_SDRAM_DDR2_DQS(fpga_0_DDR2_SDRAM_DDR2_DQS),
    .fpga_0_DDR2_SDRAM_DDR2_DQS_n(fpga_0_DDR2_SDRAM_DDR2_DQS_n),
    .fpga_0_DDR2_SDRAM_DDR2_DQ(fpga_0_DDR2_SDRAM_DDR2_DQ),
`ifdef ETHERNET_LITE
    .fpga_0_Hard_Ethernet_MAC_PHY_MII_INT(fpga_0_Hard_Ethernet_MAC_PHY_MII_INT),
    .fpga_0_Ethernet_MAC_PHY_rst_n_pin(fpga_0_Ethernet_MAC_PHY_rst_n_pin),
    .fpga_0_Ethernet_MAC_PHY_crs_pin(fpga_0_Ethernet_MAC_PHY_crs_pin),
    .fpga_0_Ethernet_MAC_PHY_col_pin(fpga_0_Ethernet_MAC_PHY_col_pin),
    .fpga_0_Ethernet_MAC_PHY_tx_data_pin(fpga_0_Ethernet_MAC_PHY_tx_data_pin),
    .fpga_0_Ethernet_MAC_PHY_tx_en_pin(fpga_0_Ethernet_MAC_PHY_tx_en_pin),
    .fpga_0_Ethernet_MAC_PHY_tx_clk_pin(fpga_0_Ethernet_MAC_PHY_tx_clk_pin),
    .fpga_0_Ethernet_MAC_PHY_rx_er_pin(fpga_0_Ethernet_MAC_PHY_rx_er_pin),
    .fpga_0_Ethernet_MAC_PHY_rx_clk_pin(fpga_0_Ethernet_MAC_PHY_rx_clk_pin),
    .fpga_0_Ethernet_MAC_PHY_dv_pin(fpga_0_Ethernet_MAC_PHY_dv_pin),
    .fpga_0_Ethernet_MAC_PHY_rx_data_pin(fpga_0_Ethernet_MAC_PHY_rx_data_pin),
`else
    .fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin(fpga_0_Hard_Ethernet_MAC_TemacPhy_RST_n_pin),
    .fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin(fpga_0_Hard_Ethernet_MAC_GMII_TXD_0_pin),
    .fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin(fpga_0_Hard_Ethernet_MAC_GMII_TX_EN_0_pin),
    .fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin(fpga_0_Hard_Ethernet_MAC_GMII_TX_CLK_0_pin),
    .fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin(fpga_0_Hard_Ethernet_MAC_GMII_TX_ER_0_pin),
    .fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin(fpga_0_Hard_Ethernet_MAC_GMII_RX_ER_0_pin),
    .fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin(fpga_0_Hard_Ethernet_MAC_GMII_RX_CLK_0_pin),
    .fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin(fpga_0_Hard_Ethernet_MAC_GMII_RX_DV_0_pin),
    .fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin(fpga_0_Hard_Ethernet_MAC_GMII_RXD_0_pin),
    .fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin(fpga_0_Hard_Ethernet_MAC_MII_TX_CLK_0_pin),
    .fpga_0_Hard_Ethernet_MAC_MDC_0_pin(fpga_0_Hard_Ethernet_MAC_MDC_0_pin),
    .fpga_0_Hard_Ethernet_MAC_MDIO_0_pin(fpga_0_Hard_Ethernet_MAC_MDIO_0_pin),
`endif 
    .sys_clk_pin(sys_clk_pin),
    .sys_rst_pin(sys_rst_pin)
  );


  //  Micron DDR model version 5.5 now supports SODIMM modules
  //  Be sure to compile file ddr2_module.v with +define+SODIMM 

  ddr2_module ddr2_module
   (
    .ck     (fpga_0_DDR2_SDRAM_DDR2_Clk_pin),
    .ck_n   (fpga_0_DDR2_SDRAM_DDR2_Clk_n_pin),
    .cke    (fpga_0_DDR2_SDRAM_DDR2_CE_pin),
    .s_n    (fpga_0_DDR2_SDRAM_DDR2_CS_n_pin), 
    .ras_n  (fpga_0_DDR2_SDRAM_DDR2_RAS_n_pin),
    .cas_n  (fpga_0_DDR2_SDRAM_DDR2_CAS_n_pin),
    .we_n   (fpga_0_DDR2_SDRAM_DDR2_WE_n_pin),
    .ba     ({1'b0,fpga_0_DDR2_SDRAM_DDR2_BankAddr_pin}),
    .addr   (fpga_0_DDR2_SDRAM_DDR2_Addr_pin),
    .odt    (fpga_0_DDR2_SDRAM_DDR2_ODT_pin),
    .dqs  ({noconnect,fpga_0_DDR2_SDRAM_DDR2_DM_pin,noconnect,fpga_0_DDR2_SDRAM_DDR2_DQS}),
    .dqs_n  ({noconnect10,fpga_0_DDR2_SDRAM_DDR2_DQS_n}),
    .dq     (fpga_0_DDR2_SDRAM_DDR2_DQ),
    .scl    (1'b1),
    .sa     (),
    .sda    ()
   );	
   

/*
  ddr
        #("bin0.dat")
        ddr_0 (
                .Dq ( DDR_DQ[0:15] ),
                .Dqs ( DDR_DQS[0:1] ),
		.Addr ( DDR_Addr ),
		.Ba ( DDR_BankAddr ),
		.Clk ( DDR_Clk ),
		.Clk_n ( DDR_Clkn ),
		.Cke ( DDR_CKE ),
		.Cs_n ( DDR_CSn ),
		.Ras_n ( DDR_RASn ),
		.Cas_n ( DDR_CASn ),
		.We_n ( DDR_WEn ),
		.Dm ( DDR_DM[0:1] )
		);
  ddr
  	#("bin1.dat")
  	ddr_1 (
		.Dq ( DDR_DQ[16:31] ),
		.Dqs ( DDR_DQS[2:3] ),
		.Addr ( DDR_Addr ),
		.Ba ( DDR_BankAddr ),
		.Clk ( DDR_Clk ),
		.Clk_n ( DDR_Clkn ),
		.Cke ( DDR_CKE ),
		.Cs_n ( DDR_CSn ),
		.Ras_n ( DDR_RASn ),
		.Cas_n ( DDR_CASn ),
		.We_n ( DDR_WEn ),
		.Dm ( DDR_DM[2:3] )
		);
	//init_mems init_mems_0 ();
*/

    pcx_monitor pcx_mon_0 (
	    .rclk(system_0.gclk),
	    .spc_pcx_req_pq(system_0.ccx2mb_0_spc_pcx_req_pq),
	    .spc_pcx_data_pa(system_0.ccx2mb_0_spc_pcx_data_pa)
	    );

endmodule

