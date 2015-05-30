// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: ctu_revision.v
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
//    Unit Name: ctu_revision

// Generates revision numbers for JTAGID and SPARC V9 VERSION register.
// The JTAGID and minor mask revisions are mask programmable and can be
// incremented with a single metal layer change. The major mask revision
// is a constant for the life of a given mask set and is only incremented
// when a new full mask set is generated.

`include "ctu.h"
module ctu_revision (/*AUTOARG*/
// Outputs
jtag_id, mask_major_id, mask_minor_id
);

output [3:0] jtag_id;
output [3:0] mask_major_id;
output [3:0] mask_minor_id;

assign mask_major_id  = `MASK_MAJOR;

ctu_jtag_id #`JTAGID jtag_id_cell(jtag_id);
ctu_mask_id #`MASK_MINOR mask_minor_id_cell(mask_minor_id);

endmodule
