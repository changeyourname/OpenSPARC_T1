// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: i2c_sdp.v
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
//  Module Name:	i2c_sdp (io-to-cpu slow datapath)
//  Description:	Datapath for packets going to the CPU.
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
module i2c_sdp (/*AUTOARG*/
   // Outputs
   io_mondo_data_wr_addr_s, io_mondo_data0_din_s, 
   io_mondo_data1_din_s, io_mondo_source_din_s, io_intman_addr, 
   ack_packet_d1, io_buf_din_raw, iob_tap_packet, 
   // Inputs
   clk, jbi_mondo_data0, jbi_mondo_data1, jbi_mondo_target, 
   jbi_mondo_source, jbi_int_packet, clk_int_packet, 
   dram0_int_packet, dram1_int_packet, iob_man_int_packet, 
   spi_int_packet, jbi_ack_packet, clk_ack_packet, dram0_ack_packet, 
   dram1_ack_packet, iob_man_ack_packet, iob_int_ack_packet, 
   spi_ack_packet, bounce_ack_packet, rd_nack_packet, 
   int_vec_dout_raw, int_cpu_dout_raw, int_sel, ack_sel, 
   mondo_srvcd_d1, int_srvcd_d1, ack_srvcd_d1, wr_ack_io_buf_din, 
   creg_jintv_vec, first_availcore
   );

   
////////////////////////////////////////////////////////////////////////
// Signal declarations
////////////////////////////////////////////////////////////////////////
   // Global interface
   input 	 clk;

   
   // UCB buffer interface
   input [63:0] 		     jbi_mondo_data0;
   input [63:0] 		     jbi_mondo_data1;
   input [`IOB_CPUTHR_INDEX-1:0]     jbi_mondo_target;
   input [`JBI_IOB_MONDO_SRC_WIDTH-1:0] jbi_mondo_source;
   
   input [`UCB_INT_PKT_WIDTH-1:0]    jbi_int_packet;
   input [`UCB_INT_PKT_WIDTH-1:0]    clk_int_packet;
   input [`UCB_INT_PKT_WIDTH-1:0]    dram0_int_packet;
   input [`UCB_INT_PKT_WIDTH-1:0]    dram1_int_packet;
   input [`UCB_INT_PKT_WIDTH-1:0]    iob_man_int_packet;
   input [`UCB_INT_PKT_WIDTH-1:0]    spi_int_packet;

   input [`UCB_128PAY_PKT_WIDTH-1:0] jbi_ack_packet;
   input [`UCB_64PAY_PKT_WIDTH-1:0]  clk_ack_packet;
   input [`UCB_64PAY_PKT_WIDTH-1:0]  dram0_ack_packet;
   input [`UCB_64PAY_PKT_WIDTH-1:0]  dram1_ack_packet;
   input [`UCB_64PAY_PKT_WIDTH-1:0]  iob_man_ack_packet;
   input [`UCB_64PAY_PKT_WIDTH-1:0]  iob_int_ack_packet;
   input [`UCB_64PAY_PKT_WIDTH-1:0]  spi_ack_packet;
   input [`UCB_64PAY_PKT_WIDTH-1:0]  bounce_ack_packet;
   input [`UCB_NOPAY_PKT_WIDTH-1:0]  rd_nack_packet;

   
   // Mondo table interface
   output [`IOB_CPUTHR_INDEX-1:0]    io_mondo_data_wr_addr_s;
   output [63:0] 		     io_mondo_data0_din_s;
   output [63:0] 		     io_mondo_data1_din_s;
   output [`JBI_IOB_MONDO_SRC_WIDTH-1:0] io_mondo_source_din_s;

   
   // Interrupt table interface
   output [`IOB_INT_TAB_INDEX-1:0]   io_intman_addr;
   wire [`IOB_INT_VEC_WIDTH-1:0]     int_vec_dout;
   input [14:0] 		     int_vec_dout_raw;
   wire [`IOB_INT_CPU_WIDTH-1:0]     int_cpu_dout;
   input [14:0] 		     int_cpu_dout_raw;

   assign int_vec_dout = int_vec_dout_raw[`IOB_INT_VEC_WIDTH-1:0];
   assign int_cpu_dout = int_cpu_dout_raw[`IOB_INT_CPU_WIDTH-1:0];

   
   // i2c slow control interface
   input [`IOB_INT_AVEC_WIDTH-1:0]   int_sel;
   input [`IOB_ACK_AVEC_WIDTH-1:0]   ack_sel;
   input 			     mondo_srvcd_d1;
   input 			     int_srvcd_d1;
   input 			     ack_srvcd_d1;

   output [`UCB_128PAY_PKT_WIDTH-1:0] ack_packet_d1;

   
   // c2i slow datapath
   input [`IOB_IO_BUF_WIDTH-1:0]     wr_ack_io_buf_din;


   // IOB control interface
   input [`IOB_INT_VEC_WIDTH-1:0]    creg_jintv_vec;
   // Indicate which core to bounce off from when accessing L2 creg
   input [`IOB_CPU_WIDTH-1:0] 	     first_availcore;

   
   // IO buffer interface
   wire [`IOB_IO_BUF_WIDTH-1:0]      io_buf_din;
   output [159:0] 		     io_buf_din_raw;

   assign io_buf_din_raw = {{(160-`IOB_IO_BUF_WIDTH){1'b0}},io_buf_din};
   
	  
   // TAP interface
   output [`UCB_64PAY_PKT_WIDTH-1:0] iob_tap_packet;

   
   // Internal signals
   wire [`IOB_CPUTHR_INDEX-1:0]      mondo_packet_thr_d1;
   wire [`IOB_CPU_WIDTH-1:0] 	     mondo_packet_cpu_d1;
   wire [`IOB_IO_BUF_WIDTH-1:0]      mondo_io_buf_din;
   
   reg [`UCB_INT_PKT_WIDTH-1:0]      int_packet;
   wire [`UCB_INT_PKT_WIDTH-1:0]     int_packet_d1;
   wire [`IOB_CPUTHR_INDEX-1:0]      int_packet_thr_d1;
   wire [`IOB_CPU_WIDTH-1:0] 	     int_packet_cpu_d1;
   reg [1:0] 			     int_packet_type_d1;
   wire [`IOB_INT_VEC_WIDTH-1:0]     int_packet_vec_d1;
   wire [`IOB_IO_BUF_WIDTH-1:0]      int_io_buf_din;
   
   reg [`UCB_128PAY_PKT_WIDTH-1:0]   ack_packet;
   wire 			     ack_packet_is_req_d1;
   wire [`IOB_CPU_WIDTH-1:0] 	     ack_packet_req_cpu_d1;
   wire [`IOB_CPU_INDEX-1:0] 	     ack_packet_req_cpu_encoded_d1;
   wire [31:0] 			     ack_packet_asi_ctrl_d1;
   wire [31:0] 			     ack_packet_asi_addr_d1;
   wire [63:0] 			     ack_packet_req_addr_d1;
   wire 			     ack_packet_is_rd_req_d1;
   wire 			     ack_packet_is_asi_req_d1;
   wire 			     ack_packet_is_nack_d1;
   wire 			     ack_packet_is_ifill_d1;
   wire 			     ack_packet_bit130_d1;
   wire [`UCB_PKT_WIDTH-1:0] 	     ack_packet_type_d1;
   wire [`IOB_CPU_WIDTH-1:0] 	     ack_packet_cpu_d1;
   wire [`IOB_IO_BUF_WIDTH-1:0]      ack_io_buf_din;
   
   
////////////////////////////////////////////////////////////////////////
// Code starts here
////////////////////////////////////////////////////////////////////////
   /************************************************************
    * Flop Mondo interrupt data, source, target
    ************************************************************/
   // Write to Mondo data0, data1 and source
   dff_ns #(`IOB_CPUTHR_INDEX) io_mondo_data_wr_addr_s_ff (.din(jbi_mondo_target),
							   .clk(clk),
							   .q(io_mondo_data_wr_addr_s));

   dff_ns #(64) io_mondo_data0_din_s_ff (.din(jbi_mondo_data0),
					 .clk(clk),
					 .q(io_mondo_data0_din_s));

   dff_ns #(64) io_mondo_data1_din_s_ff (.din(jbi_mondo_data1),
					 .clk(clk),
					 .q(io_mondo_data1_din_s));

   dff_ns #(`JBI_IOB_MONDO_SRC_WIDTH) io_mondo_source_din_s_ff (.din(jbi_mondo_source),
						  	     	.clk(clk),
						  	     	.q(io_mondo_source_din_s));
   
   // Assemble CPX packet
   assign 	 mondo_packet_thr_d1 = io_mondo_data_wr_addr_s;

   assign 	 mondo_packet_cpu_d1 = 1'b1 <<  mondo_packet_thr_d1[4:2];
   
   assign 	 mondo_io_buf_din = {mondo_packet_cpu_d1,                        // cpu ID
				     1'b1,                                       // valid                 [144]
				     `INT_RET,                                   // return type           [143:140]
				     3'b0,                                       // error                 [139:137]
				     1'b0,                                       // flush                 [136]
				     8'b0,                                       // un-used shared bits   [135:128]
				     64'b0,                                      // un-used               [127:64]
				     46'b0,                                      // un-used               [63:18]
				     `IOB_INT,                                   // int/reset/idle/resume [17:16]
				     3'b0,                                       // un-used               [15:13]  
				     mondo_packet_thr_d1,                        // cputhread ID          [12:8]
				     2'b0,                                       // un-used               [7:6]
				     creg_jintv_vec};                            // int vector            [5:0]
   
   
   /************************************************************
    * Mux out Int that we are going to service
    ************************************************************/
   always @(/*AUTOSENSE*/clk_int_packet or dram0_int_packet
	    or dram1_int_packet or int_sel or iob_man_int_packet
	    or jbi_int_packet or spi_int_packet) begin
      int_packet = {`UCB_INT_PKT_WIDTH{1'b0}};
      case (int_sel)
	`IOB_INT_AVEC_WIDTH'b000000001: int_packet = jbi_int_packet;
	`IOB_INT_AVEC_WIDTH'b000000010: int_packet = clk_int_packet;
	`IOB_INT_AVEC_WIDTH'b000000100: int_packet = dram0_int_packet;
	`IOB_INT_AVEC_WIDTH'b000001000: int_packet = dram1_int_packet;
	`IOB_INT_AVEC_WIDTH'b000010000: int_packet = iob_man_int_packet;
	`IOB_INT_AVEC_WIDTH'b000100000: int_packet = {`UCB_INT_PKT_WIDTH{1'b0}};
	`IOB_INT_AVEC_WIDTH'b001000000: int_packet = spi_int_packet;
	`IOB_INT_AVEC_WIDTH'b010000000: int_packet = {`UCB_INT_PKT_WIDTH{1'b0}};
	`IOB_INT_AVEC_WIDTH'b100000000: int_packet = {`UCB_INT_PKT_WIDTH{1'b0}};
      endcase // case(int_sel)
   end // always @ (...
   
   dff_ns #(`UCB_INT_PKT_WIDTH) int_packet_d1_ff (.din(int_packet),
						  .clk(clk),
						  .q(int_packet_d1));

   // Read from interrupt vector/interrupt CPU table
   assign 	 io_intman_addr = int_packet[`IOB_INT_TAB_INDEX+`UCB_INT_DEV_LO-1:`UCB_INT_DEV_LO];

   // Assemble CPX packet
   assign 	 int_packet_thr_d1 = (int_packet_d1[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_INT) ?
				     int_cpu_dout :
		                     int_packet_d1[`IOB_CPUTHR_INDEX+`UCB_THR_LO-1:`UCB_THR_LO];
  
   assign 	 int_packet_cpu_d1 = 1'b1 <<  int_packet_thr_d1[4:2];

   always @(/*AUTOSENSE*/int_packet_d1)
     case (int_packet_d1[`UCB_PKT_HI:`UCB_PKT_LO])
       `UCB_INT       : int_packet_type_d1 = `IOB_INT;
       `UCB_INT_VEC   : int_packet_type_d1 = `IOB_INT;
       `UCB_RESET_VEC : int_packet_type_d1 = `IOB_RESET;
       `UCB_IDLE_VEC  : int_packet_type_d1 = `IOB_IDLE;
       `UCB_RESUME_VEC: int_packet_type_d1 = `IOB_RESUME;
       default        : int_packet_type_d1 = `IOB_INT;
     endcase // case(int_packet_d1[`UCB_PKT_HI:`UCB_PKT_LO])
     
   assign 	 int_packet_vec_d1 = (int_packet_d1[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_INT) ?
				     int_vec_dout :
				     int_packet_d1[`UCB_INT_VEC_HI:`UCB_INT_VEC_LO];
   
   // assemble interrupt back to CPU
   assign 	 int_io_buf_din = {int_packet_cpu_d1,                          // cpu ID
				   1'b1,                                       // valid                 [144]
				   `INT_RET,                                   // return type           [143:140]
				   3'b0,                                       // error                 [139:137]
				   1'b0,                                       // flush                 [136]
				   8'b0,                                       // un-used shared bits   [135:128]
				   64'b0,                                      // un-used               [127:64]
				   46'b0,                                      // un-used               [63:18]
				   int_packet_type_d1,                         // int/reset/idle/resume [17:16]
				   3'b0,                                       // un-used               [15:13]  
				   int_packet_thr_d1,                          // cputhread ID          [12:8]
				   2'b0,                                       // un-used               [7:6]
				   int_packet_vec_d1};                         // int vector            [5:0]
			
			
   /************************************************************
    * Mux out Ack that we are going to service
    ************************************************************/
   always @(/*AUTOSENSE*/ack_sel or bounce_ack_packet
	    or clk_ack_packet or dram0_ack_packet or dram1_ack_packet
	    or iob_int_ack_packet or iob_man_ack_packet
	    or jbi_ack_packet or rd_nack_packet or spi_ack_packet) begin
      ack_packet = {`UCB_128PAY_PKT_WIDTH{1'b0}};
      case (ack_sel)
	`IOB_ACK_AVEC_WIDTH'b000000001: ack_packet = jbi_ack_packet;
	`IOB_ACK_AVEC_WIDTH'b000000010: ack_packet = {clk_ack_packet[`UCB_DATA_HI:`UCB_DATA_LO],clk_ack_packet};
	`IOB_ACK_AVEC_WIDTH'b000000100: ack_packet = {dram0_ack_packet[`UCB_DATA_HI:`UCB_DATA_LO],dram0_ack_packet};
	`IOB_ACK_AVEC_WIDTH'b000001000: ack_packet = {dram1_ack_packet[`UCB_DATA_HI:`UCB_DATA_LO],dram1_ack_packet};
	`IOB_ACK_AVEC_WIDTH'b000010000: ack_packet = {iob_man_ack_packet[`UCB_DATA_HI:`UCB_DATA_LO],iob_man_ack_packet};
	`IOB_ACK_AVEC_WIDTH'b000100000: ack_packet = {iob_int_ack_packet[`UCB_DATA_HI:`UCB_DATA_LO],iob_int_ack_packet};
	`IOB_ACK_AVEC_WIDTH'b001000000: ack_packet = {spi_ack_packet[`UCB_DATA_HI:`UCB_DATA_LO],spi_ack_packet};
	`IOB_ACK_AVEC_WIDTH'b010000000: ack_packet = {bounce_ack_packet[`UCB_DATA_HI:`UCB_DATA_LO],bounce_ack_packet};
	`IOB_ACK_AVEC_WIDTH'b100000000: ack_packet = {128'b0,rd_nack_packet};
      endcase // case(ack_sel)
   end
   
   dff_ns #(`UCB_128PAY_PKT_WIDTH) ack_packet_d1_ff (.din(ack_packet),
						    .clk(clk),
						    .q(ack_packet_d1));

   
   // Assemble CPX packet
   assign        ack_packet_is_req_d1 = ((ack_packet_d1[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_READ_REQ) |
					 (ack_packet_d1[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_WRITE_REQ));

   // If tap access is to ASI registers, then the core is specified by addr[27:25]
   // If tap access is to the L2, then the core for bouncing is specified by availcore
   assign 	 ack_packet_req_cpu_d1 = ack_packet_is_asi_req_d1 ?
		                         (1'b1 <<  ack_packet_d1[27+`UCB_ADDR_LO:25+`UCB_ADDR_LO]) :
					 first_availcore;  // direct to "first avail core" if L2 access (ie non asi access)

   assign  	 ack_packet_req_cpu_encoded_d1[0] = ack_packet_req_cpu_d1[1] | ack_packet_req_cpu_d1[3] | ack_packet_req_cpu_d1[5] | ack_packet_req_cpu_d1[7];
   assign  	 ack_packet_req_cpu_encoded_d1[1] = ack_packet_req_cpu_d1[2] | ack_packet_req_cpu_d1[3] | ack_packet_req_cpu_d1[6] | ack_packet_req_cpu_d1[7];
   assign  	 ack_packet_req_cpu_encoded_d1[2] = ack_packet_req_cpu_d1[4] | ack_packet_req_cpu_d1[5] | ack_packet_req_cpu_d1[6] | ack_packet_req_cpu_d1[7];
   
   assign 	 ack_packet_is_rd_req_d1 = (ack_packet_d1[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_READ_REQ);

   assign 	 ack_packet_is_asi_req_d1 = ack_packet_is_req_d1 &
		                            (ack_packet_d1[`ADDR_MAP_HI+`UCB_ADDR_LO:`ADDR_MAP_LO+`UCB_ADDR_LO] == `CPU_ASI);

   iobdg_asi_dec iobdg_asi_dec (.ucb_packet(ack_packet_d1[`UCB_64PAY_PKT_WIDTH-1:0]),
				.asi_ctrl(ack_packet_asi_ctrl_d1),
				.asi_addr(ack_packet_asi_addr_d1));
   
   assign 	 ack_packet_req_addr_d1 = ack_packet_is_asi_req_d1 ?
		                          {ack_packet_asi_ctrl_d1,ack_packet_asi_addr_d1} :
		                          {24'b0,ack_packet_d1[`UCB_ADDR_HI:`UCB_ADDR_LO]};
   
   assign 	 ack_packet_is_nack_d1 = ((ack_packet_d1[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_READ_NACK) |
					  (ack_packet_d1[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_IFILL_NACK));

   assign 	 ack_packet_is_ifill_d1 = ((ack_packet_d1[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_IFILL_ACK) |
					   (ack_packet_d1[`UCB_PKT_HI:`UCB_PKT_LO] == `UCB_IFILL_NACK));

   // Set bit 130 if 4B ifill return
   assign 	 ack_packet_bit130_d1 = ack_packet_is_ifill_d1;
   
   assign 	 ack_packet_type_d1 = ack_packet_is_ifill_d1 ? `IFILL_RET : `LOAD_RET;

   assign 	 ack_packet_cpu_d1 = 1'b1 <<  ack_packet_d1[`UCB_THR_HI-1:`UCB_THR_HI-3];
   
			 
   assign 	 ack_io_buf_din = ack_packet_is_req_d1 ?
		                  {ack_packet_req_cpu_d1,                          // direct to "first avail core" if L2 access
				   1'b1,                                           // valid
				   `FWD_RQ_RET,                                    // type
				   3'b0,                                           // error
				   ack_packet_is_rd_req_d1,                        // R/!W
				   2'b0,                                           // XX
				   ack_packet_req_cpu_encoded_d1,                  // TAP
				   ack_packet_is_asi_req_d1,                       // ASI access
				   2'b0,                                           // XX
				   ack_packet_req_addr_d1,                         // address
				   ack_packet_d1[`UCB_DATA_HI:`UCB_DATA_LO]} :     // data
		                  {ack_packet_cpu_d1,                              // cpu ID
				   1'b1,                                           // valid
				   ack_packet_type_d1,                             // return type
				   1'b0,ack_packet_is_nack_d1,1'b0,                // error
				   1'b1,                                           // NC
				   ack_packet_d1[`UCB_THR_LO+1:`UCB_THR_LO],       // thread ID
				   3'b0,                                           // WV, W, W
				   ack_packet_bit130_d1,                           // IFill 4B
				   1'b0,                                           // atomic
				   1'b0,                                           // X
				   ack_packet_d1[`UCB_DATA_EXT_HI:`UCB_DATA_EXT_LO], // data
				   ack_packet_d1[`UCB_DATA_HI:`UCB_DATA_LO]};
   
   
   /************************************************************
    * Mux transaction to IO buffer
    ************************************************************/
   assign 	 io_buf_din = mondo_srvcd_d1 ? mondo_io_buf_din :  // mondo
		              int_srvcd_d1   ? int_io_buf_din :    // interrupt
		              ack_srvcd_d1   ? ack_io_buf_din :    // read ack/nack
                                               wr_ack_io_buf_din;  // write ack

   
   /************************************************************
    * Send transaction to TAP
    ************************************************************/
   assign 	 iob_tap_packet = ack_packet_d1;

   
endmodule // i2c_sdp

			       
// Local Variables:
// verilog-auto-sense-defines-constant:t
// End:


