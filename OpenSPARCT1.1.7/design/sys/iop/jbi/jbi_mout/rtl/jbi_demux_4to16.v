// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_demux_4to16.v
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
// jbi_demux_4to16 -- 4-to-16 Demultiplexer.
// _____________________________________________________________________________
//

function [15:0] jbi_demux_4to16;
  input  [3:0] encoded_value;

  begin
    casex (encoded_value)
      4'h0:    jbi_demux_4to16 = 16'b0000_0000_0000_0001;
      4'h1:    jbi_demux_4to16 = 16'b0000_0000_0000_0010;
      4'h2:    jbi_demux_4to16 = 16'b0000_0000_0000_0100;
      4'h3:    jbi_demux_4to16 = 16'b0000_0000_0000_1000;
      4'h4:    jbi_demux_4to16 = 16'b0000_0000_0001_0000;
      4'h5:    jbi_demux_4to16 = 16'b0000_0000_0010_0000;
      4'h6:    jbi_demux_4to16 = 16'b0000_0000_0100_0000;
      4'h7:    jbi_demux_4to16 = 16'b0000_0000_1000_0000;
      4'h8:    jbi_demux_4to16 = 16'b0000_0001_0000_0000;
      4'h9:    jbi_demux_4to16 = 16'b0000_0010_0000_0000;
      4'ha:    jbi_demux_4to16 = 16'b0000_0100_0000_0000;
      4'hb:    jbi_demux_4to16 = 16'b0000_1000_0000_0000;
      4'hc:    jbi_demux_4to16 = 16'b0001_0000_0000_0000;
      4'hd:    jbi_demux_4to16 = 16'b0010_0000_0000_0000;
      4'he:    jbi_demux_4to16 = 16'b0100_0000_0000_0000;
      4'hf:    jbi_demux_4to16 = 16'b1000_0000_0000_0000;
// CoverMeter line_off
      default: jbi_demux_4to16 = 16'bxxxx_xxxx_xxxx_xxxx;
// CoverMeter line_on
      endcase
    end

  endfunction


// Local Variables:
// verilog-library-directories:(".")
// verilog-module-parents:("jbi_ncrd_timeout")
// End:
