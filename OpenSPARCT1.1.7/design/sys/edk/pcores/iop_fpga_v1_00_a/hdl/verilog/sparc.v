// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc.v
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
// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc.v
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

/*`include "sys.h"
`include "iop.h"
`include "ifu.h"
`include "tlu.h"
`include "lsu.h"
*/

`define PCX_WIDTH       124  //PCX payload packet width
`define CPX_WIDTH       145  //CPX payload packet width


module sparc (/*AUTOARG*/
   // Outputs
   spc_pcx_req_pq, spc_pcx_atom_pq, spc_pcx_data_pa, spc_sscan_so, 
   spc_scanout0, spc_scanout1, tst_ctu_mbist_done, 
   tst_ctu_mbist_fail, spc_efc_ifuse_data, spc_efc_dfuse_data, 
   // Inputs
   pcx_spc_grant_px, cpx_spc_data_rdy_cx2, cpx_spc_data_cx2, 
   const_cpuid, const_maskid, ctu_tck, ctu_sscan_se, ctu_sscan_snap, 
   ctu_sscan_tid, ctu_tst_mbist_enable, efc_spc_fuse_clk1, 
   efc_spc_fuse_clk2, efc_spc_ifuse_ashift, efc_spc_ifuse_dshift, 
   efc_spc_ifuse_data, efc_spc_dfuse_ashift, efc_spc_dfuse_dshift, 
   efc_spc_dfuse_data, ctu_tst_macrotest, ctu_tst_scan_disable, 
   ctu_tst_short_chain, global_shift_enable, ctu_tst_scanmode, 
   spc_scanin0, spc_scanin1, cluster_cken, gclk, cmp_grst_l, 
   cmp_arst_l, ctu_tst_pre_grst_l, adbginit_l, gdbginit_l
   );

   // these are the only legal IOs

   // pcx
   output [4:0]   spc_pcx_req_pq;    // processor to pcx request
   output         spc_pcx_atom_pq;   // processor to pcx atomic request
   output [`PCX_WIDTH-1:0] spc_pcx_data_pa;  // processor to pcx packet

   // shadow scan
   output     spc_sscan_so;         // From ifu of sparc_ifu.v
   output     spc_scanout0;         // From test_stub of test_stub_bist.v
   output     spc_scanout1;         // From test_stub of test_stub_bist.v

   // bist
   output     tst_ctu_mbist_done;  // From test_stub of test_stub_two_bist.v
   output     tst_ctu_mbist_fail;  // From test_stub of test_stub_two_bist.v

   // fuse
   output     spc_efc_ifuse_data;     // From ifu of sparc_ifu.v
   output     spc_efc_dfuse_data;     // From ifu of sparc_ifu.v


   // cpx interface
   input [4:0] pcx_spc_grant_px; // pcx to processor grant info  
   input       cpx_spc_data_rdy_cx2; // cpx data inflight to sparc  
   input [`CPX_WIDTH-1:0] cpx_spc_data_cx2;     // cpx to sparc data packet

   input [3:0]  const_cpuid;
   input [7:0]  const_maskid;           // To ifu of sparc_ifu.v

   // sscan
   input        ctu_tck;                // To ifu of sparc_ifu.v
   input        ctu_sscan_se;           // To ifu of sparc_ifu.v
   input        ctu_sscan_snap;         // To ifu of sparc_ifu.v
   input [3:0]  ctu_sscan_tid;          // To ifu of sparc_ifu.v

   // bist
   input        ctu_tst_mbist_enable;   // To test_stub of test_stub_bist.v

   // efuse
   input        efc_spc_fuse_clk1;
   input        efc_spc_fuse_clk2;
   input        efc_spc_ifuse_ashift;
   input        efc_spc_ifuse_dshift;
   input        efc_spc_ifuse_data;
   input        efc_spc_dfuse_ashift;
   input        efc_spc_dfuse_dshift;
   input        efc_spc_dfuse_data;
   
   // scan and macro test
   input        ctu_tst_macrotest;      // To test_stub of test_stub_bist.v
   input        ctu_tst_scan_disable;   // To test_stub of test_stub_bist.v
   input        ctu_tst_short_chain;    // To test_stub of test_stub_bist.v
   input        global_shift_enable;    // To test_stub of test_stub_two_bist.v
   input        ctu_tst_scanmode;       // To test_stub of test_stub_two_bist.v
   input        spc_scanin0;
   input        spc_scanin1;
   
   // clk
   input        cluster_cken;           // To spc_hdr of cluster_header.v
   input        gclk;                   // To spc_hdr of cluster_header.v

   // reset
   input        cmp_grst_l;
   input        cmp_arst_l;
   input        ctu_tst_pre_grst_l;     // To test_stub of test_stub_bist.v

   input        adbginit_l;             // To spc_hdr of cluster_header.v
   input        gdbginit_l;             // To spc_hdr of cluster_header.v


   // ----------------- End of IOs -------------------------- //

endmodule // sparc


