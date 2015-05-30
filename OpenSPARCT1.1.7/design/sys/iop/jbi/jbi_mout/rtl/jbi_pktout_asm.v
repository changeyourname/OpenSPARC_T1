// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_pktout_asm.v
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
// jbi_pktout_asm -- JBus Packet Assembler and Driver.
// _____________________________________________________________________________
//
// Design Notes:
//   The mux select is a combination of the queue to read from ('sel_queue') and
//   the packet cycle ('sel_j_adbus').
// _____________________________________________________________________________

`include "sys.h"


module jbi_pktout_asm (/*AUTOARG*/
  // Outputs
  jbi_io_j_adtype, jbi_io_j_ad, jbi_io_j_adp, 
  // Inputs
  sel_j_adbus, sel_queue, sct0rdq_install_state, sct0rdq_unmapped_error, 
  sct0rdq_jid, sct0rdq_data, sct0rdq_ue_err, sct1rdq_install_state, 
  sct1rdq_unmapped_error, sct1rdq_jid, sct1rdq_data, sct1rdq_ue_err, 
  sct2rdq_install_state, sct2rdq_unmapped_error, sct2rdq_jid, sct2rdq_data, 
  sct2rdq_ue_err, sct3rdq_install_state, sct3rdq_unmapped_error, sct3rdq_jid, 
  sct3rdq_data, sct3rdq_ue_err, ncio_pio_ue, ncio_pio_be, ncio_pio_ad, 
  ncio_mondo_agnt_id, ncio_mondo_cpu_id, dbg_data, unused_jid, inj_err_j_ad, 
  csr_jbi_debug_info_enb, thread_id, sct0rdq_trans_count, sct1rdq_trans_count, 
  sct2rdq_trans_count, sct3rdq_trans_count, ncio_prqq_level, ncio_makq_level, 
  clk
  );

  // Outbound Packet Controller.
  input    [3:0] sel_j_adbus;
  input    [2:0] sel_queue;

  // Queues.
  // SCT0 RDQ.
  input          sct0rdq_install_state;
  input          sct0rdq_unmapped_error;
  input    [5:0] sct0rdq_jid;
  input  [127:0] sct0rdq_data;
  input 	 sct0rdq_ue_err;
  // SCT1 RDQ.
  input          sct1rdq_install_state;
  input          sct1rdq_unmapped_error;
  input    [5:0] sct1rdq_jid;
  input  [127:0] sct1rdq_data;
  input 	 sct1rdq_ue_err;
  // SCT2 RDQ.
  input          sct2rdq_install_state;
  input          sct2rdq_unmapped_error;
  input    [5:0] sct2rdq_jid;
  input  [127:0] sct2rdq_data;
  input 	 sct2rdq_ue_err;
  // SCT3 RDQ.
  input          sct3rdq_install_state;
  input          sct3rdq_unmapped_error;
  input    [5:0] sct3rdq_jid;
  input  [127:0] sct3rdq_data;
  input 	 sct3rdq_ue_err;
  // PIO RQQ.
  input 	 ncio_pio_ue;
  input   [15:0] ncio_pio_be;
  input   [63:0] ncio_pio_ad;
  // PIO ACKQ.
  input    [4:0] ncio_mondo_agnt_id;
  input    [4:0] ncio_mondo_cpu_id;
  // DBGQ.
  input  [127:0] dbg_data;
  
  // JID to PIO ID map.
  input    [5:0] unused_jid;
  
  // J_ADTYPE, J_AD, J_ADP busses.
  output   [7:0] jbi_io_j_adtype;
  output [127:0] jbi_io_j_ad;
  output   [3:0] jbi_io_j_adp;

  // Error injection.
  input    [3:0] inj_err_j_ad;
  
  // Debug Info.
  input 	 csr_jbi_debug_info_enb;	// Put these data fields in high half of JBus Address Cycles.
  input    [4:0] thread_id;
  input    [3:0] sct0rdq_trans_count;
  input    [3:0] sct1rdq_trans_count;
  input    [3:0] sct2rdq_trans_count;
  input    [3:0] sct3rdq_trans_count;
  input    [4:0] ncio_prqq_level;
  input    [4:0] ncio_makq_level;

  // Clock.
  input 	 clk;
  

  // Wires and Regs.




  // Packet assembly multiplexer.
  jbi_pktout_mux  pktout_mux (
    
    // Select.
    .sel_queue			(sel_queue[2:0]),
    .sel_j_adbus		(sel_j_adbus[3:0]),
    
    // Input sources
    // SCT0 RDQ.
    .sct0rdq_install_state	(sct0rdq_install_state),
    .sct0rdq_unmapped_error	(sct0rdq_unmapped_error),
    .sct0rdq_jid		(sct0rdq_jid[5:0]),
    .sct0rdq_data		(sct0rdq_data[127:0]),
    .sct0rdq_ue_err		(sct0rdq_ue_err),
    // SCT1 RDQ.
    .sct1rdq_install_state	(sct1rdq_install_state),
    .sct1rdq_unmapped_error	(sct1rdq_unmapped_error),
    .sct1rdq_jid		(sct1rdq_jid[5:0]),
    .sct1rdq_data		(sct1rdq_data[127:0]),
    .sct1rdq_ue_err		(sct1rdq_ue_err),
    // SCT2 RDQ.
    .sct2rdq_install_state	(sct2rdq_install_state),
    .sct2rdq_unmapped_error	(sct2rdq_unmapped_error),
    .sct2rdq_jid		(sct2rdq_jid[5:0]),
    .sct2rdq_data		(sct2rdq_data[127:0]),
    .sct2rdq_ue_err		(sct2rdq_ue_err),
    // SCT3 RDQ.
    .sct3rdq_install_state	(sct3rdq_install_state),
    .sct3rdq_unmapped_error	(sct3rdq_unmapped_error),
    .sct3rdq_jid		(sct3rdq_jid[5:0]),
    .sct3rdq_data		(sct3rdq_data[127:0]),
    .sct3rdq_ue_err		(sct3rdq_ue_err),
    // PIO RQQ.
    .ncio_pio_ue		(ncio_pio_ue),
    .ncio_pio_be		(ncio_pio_be[15:0]),
    .ncio_pio_ad		(ncio_pio_ad[63:0]),
    // PIO ACKQ.
    .ncio_mondo_agnt_id		(ncio_mondo_agnt_id[4:0]),
    .ncio_mondo_cpu_id		(ncio_mondo_cpu_id[4:0]),
    // DBGQ.
    .dbg_data			(dbg_data),

    
    // YID-to-JID Translation.
    .unused_jid			(unused_jid[5:0]),
    
    // J_ADTYPE, J_AD, J_ADP busses.
    .jbi_io_j_adtype		(jbi_io_j_adtype[7:0]),
    .jbi_io_j_ad		(jbi_io_j_ad[127:0]),
    .jbi_io_j_adp		(jbi_io_j_adp[3:0]),
    
    // Error injection.
    .inj_err_j_ad		(inj_err_j_ad[3:0]),		// Inject an error on the J_AD[] (bit3=J_AD[96], bit2=J_AD[64], bit1=J_AD[32], bit0=J_AD[0]).
    
    // Debug Info.
    .csr_jbi_debug_info_enb	(csr_jbi_debug_info_enb),	// Put these data fields in high half of JBus Address Cycles.
    .thread_id			(thread_id[4:0]),
    .sct0rdq_trans_count	(sct0rdq_trans_count[3:0]),
    .sct1rdq_trans_count	(sct1rdq_trans_count[3:0]),
    .sct2rdq_trans_count	(sct2rdq_trans_count[3:0]),
    .sct3rdq_trans_count	(sct3rdq_trans_count[3:0]),
    .ncio_prqq_level		(ncio_prqq_level[4:0]),
    .ncio_makq_level		(ncio_makq_level[4:0]),
    
    // Clock.
    .clk			(clk)
    );


  endmodule


// Local Variables:
// verilog-library-directories:("." "../../../include")
// verilog-module-parents:("jbi_mout")
// End:
