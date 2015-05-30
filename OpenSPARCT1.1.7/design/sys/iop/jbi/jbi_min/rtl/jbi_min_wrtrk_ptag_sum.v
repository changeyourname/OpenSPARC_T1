// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: jbi_min_wrtrk_ptag_sum.v
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
/////////////////////////////////////////////////////////////////////////
/*
//
//  Description:	Predicted Tag Summation Block
//  Top level Module:	jbi_min_wrtrk_ptag_sum
//  Where Instantiated:	jbi_min_wrtrk
//
//  Description: from right to left, look for 0<-1 transitions in groups
//               of 8-bit BE
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
`include	"sys.h" // system level definition file which contains the 
					// time scale definition

module jbi_min_wrtrk_ptag_sum(/*AUTOARG*/
// Outputs
pre_tag_incr, 
// Inputs
io_jbi_j_ad_ff
);

input [127:64] io_jbi_j_ad_ff;
output [5:0]   pre_tag_incr;


////////////////////////////////////////////////////////////////////////
// Interface signal type declarations
////////////////////////////////////////////////////////////////////////
wire [5:0]   pre_tag_incr;

////////////////////////////////////////////////////////////////////////
// Local signal declarations 
////////////////////////////////////////////////////////////////////////

wire 	     or_s0_b0_0;
wire 	     or_s0_b0_1;
wire 	     or_s0_b0_2;
wire 	     or_s0_b0_3;
wire 	     or_s0_b0_4;
wire 	     or_s0_b0_5;
wire 	     or_s0_b1_0;
wire 	     or_s0_b1_1;
wire 	     or_s0_b1_2;
wire 	     or_s0_b1_3;
wire 	     or_s0_b1_4;
wire 	     or_s0_b1_5;
wire 	     or_s0_b2_0;
wire 	     or_s0_b2_1;
wire 	     or_s0_b2_2;
wire 	     or_s0_b2_3;
wire 	     or_s0_b2_4;
wire 	     or_s0_b2_5;
wire 	     or_s0_b3_0;
wire 	     or_s0_b3_1;
wire 	     or_s0_b3_2;
wire 	     or_s0_b3_3;
wire 	     or_s0_b3_4;
wire 	     or_s0_b3_5;
wire 	     or_s0_b4_0;
wire 	     or_s0_b4_1;
wire 	     or_s0_b4_2;
wire 	     or_s0_b4_3;
wire 	     or_s0_b4_4;
wire 	     or_s0_b4_5;
wire 	     or_s0_b5_0;
wire 	     or_s0_b5_1;
wire 	     or_s0_b5_2;
wire 	     or_s0_b5_3;
wire 	     or_s0_b5_4;
wire 	     or_s0_b5_5;
wire 	     or_s0_b6_0;
wire 	     or_s0_b6_1;
wire 	     or_s0_b6_2;
wire 	     or_s0_b6_3;
wire 	     or_s0_b6_4;
wire 	     or_s0_b6_5;
wire 	     or_s0_b7_0;
wire 	     or_s0_b7_1;
wire 	     or_s0_b7_2;
wire 	     or_s0_b7_3;
wire 	     or_s0_b7_4;
wire 	     or_s0_b7_5;
wire 	     s1_b0_ci;
wire 	     s1_b1_ci;
wire 	     s1_b2_ci;
wire 	     s1_b3_ci;
wire 	     s1_b4_ci;
wire 	     s1_b5_ci;
wire 	     s1_b6_ci;
wire 	     s1_b7_ci;
wire 	     s0_b0_0;
wire 	     s0_b0_1;
wire 	     s0_b1_0;
wire 	     s0_b1_1;
wire 	     s0_b2_0;
wire 	     s0_b2_1;
wire 	     s0_b3_0;
wire 	     s0_b3_1;
wire 	     s0_b4_0;
wire 	     s0_b4_1;
wire 	     s0_b5_0;
wire 	     s0_b5_1;
wire 	     s0_b6_0;
wire 	     s0_b6_1;
wire 	     s0_b7_0;
wire 	     s0_b7_1;
wire 	     s0_b0_0_co;
wire 	     s0_b0_1_co;
wire 	     s0_b1_0_co;
wire 	     s0_b1_1_co;
wire 	     s0_b2_0_co;
wire 	     s0_b2_1_co;
wire 	     s0_b3_0_co;
wire 	     s0_b3_1_co;
wire 	     s0_b4_0_co;
wire 	     s0_b4_1_co;
wire 	     s0_b5_0_co;
wire 	     s0_b5_1_co;
wire 	     s0_b6_0_co;
wire 	     s0_b6_1_co;
wire 	     s0_b7_0_co;
wire 	     s0_b7_1_co;
wire [1:0]   s1_b0;
wire [1:0]   s1_b1;
wire [1:0]   s1_b2;
wire [1:0]   s1_b3;
wire [1:0]   s1_b4;
wire [1:0]   s1_b5;
wire [1:0]   s1_b6;
wire [1:0]   s1_b7;
wire 	     s1_b0_co;
wire 	     s1_b1_co;
wire 	     s1_b2_co;
wire 	     s1_b3_co;
wire 	     s1_b4_co;
wire 	     s1_b5_co;
wire 	     s1_b6_co;
wire 	     s1_b7_co;
wire [2:0]   s2_b0;
wire [2:0]   s2_b1;
wire [2:0]   s2_b2;
wire [2:0]   s2_b3;
wire 	     s2_b0_co;
wire 	     s2_b1_co;
wire 	     s2_b2_co;
wire 	     s2_b3_co;
wire [3:0]   s3_b0;
wire [3:0]   s3_b1;
wire 	     s3_b0_co;
wire 	     s3_b1_co;
wire [4:0]   s4;
wire 	     s4_co;

//
// Code start here 
//

//----------------------
// Stage 0
// - 1-bit adders
//----------------------

assign or_s0_b0_0 = ~io_jbi_j_ad_ff[65] & io_jbi_j_ad_ff[64];
assign or_s0_b0_1 = ~io_jbi_j_ad_ff[66] & io_jbi_j_ad_ff[65];
assign or_s0_b0_2 = ~io_jbi_j_ad_ff[67] & io_jbi_j_ad_ff[66];
assign or_s0_b0_3 = ~io_jbi_j_ad_ff[68] & io_jbi_j_ad_ff[67];
assign or_s0_b0_4 = ~io_jbi_j_ad_ff[69] & io_jbi_j_ad_ff[68];
assign or_s0_b0_5 = ~io_jbi_j_ad_ff[70] & io_jbi_j_ad_ff[69];
assign s1_b0_ci   = io_jbi_j_ad_ff[71] | (~io_jbi_j_ad_ff[71] & io_jbi_j_ad_ff[70]);

jbi_adder_1b u_add_pre_tag_incr_s0_b0_0
   (.oper1(or_s0_b0_0),
    .oper2(or_s0_b0_1),
    .cin(or_s0_b0_2),
    .sum(s0_b0_0),
    .cout(s0_b0_0_co)
    );

jbi_adder_1b u_add_pre_tag_incr_s0_b0_1
   (.oper1(or_s0_b0_3),
    .oper2(or_s0_b0_4),
    .cin(or_s0_b0_5),
    .sum(s0_b0_1),
    .cout(s0_b0_1_co)
    );

assign or_s0_b1_0 = ~io_jbi_j_ad_ff[73] & io_jbi_j_ad_ff[72];
assign or_s0_b1_1 = ~io_jbi_j_ad_ff[74] & io_jbi_j_ad_ff[73];
assign or_s0_b1_2 = ~io_jbi_j_ad_ff[75] & io_jbi_j_ad_ff[74];
assign or_s0_b1_3 = ~io_jbi_j_ad_ff[76] & io_jbi_j_ad_ff[75];
assign or_s0_b1_4 = ~io_jbi_j_ad_ff[77] & io_jbi_j_ad_ff[76];
assign or_s0_b1_5 = ~io_jbi_j_ad_ff[78] & io_jbi_j_ad_ff[77];
assign s1_b1_ci   = io_jbi_j_ad_ff[79] | (~io_jbi_j_ad_ff[79] & io_jbi_j_ad_ff[78]);


jbi_adder_1b u_add_pre_tag_incr_s0_b1_0
   (.oper1(or_s0_b1_0),
    .oper2(or_s0_b1_1),
    .cin(or_s0_b1_2),
    .sum(s0_b1_0),
    .cout(s0_b1_0_co)
    );

jbi_adder_1b u_add_pre_tag_incr_s0_b1_1
   (.oper1(or_s0_b1_3),
    .oper2(or_s0_b1_4),
    .cin(or_s0_b1_5),
    .sum(s0_b1_1),
    .cout(s0_b1_1_co)
    );

assign or_s0_b2_0 = ~io_jbi_j_ad_ff[81] & io_jbi_j_ad_ff[80];
assign or_s0_b2_1 = ~io_jbi_j_ad_ff[82] & io_jbi_j_ad_ff[81];
assign or_s0_b2_2 = ~io_jbi_j_ad_ff[83] & io_jbi_j_ad_ff[82];
assign or_s0_b2_3 = ~io_jbi_j_ad_ff[84] & io_jbi_j_ad_ff[83];
assign or_s0_b2_4 = ~io_jbi_j_ad_ff[85] & io_jbi_j_ad_ff[84];
assign or_s0_b2_5 = ~io_jbi_j_ad_ff[86] & io_jbi_j_ad_ff[85];
assign s1_b2_ci   = io_jbi_j_ad_ff[87] | (~io_jbi_j_ad_ff[87] & io_jbi_j_ad_ff[86]);

jbi_adder_1b u_add_pre_tag_incr_s0_b2_0
   (.oper1(or_s0_b2_0),
    .oper2(or_s0_b2_1),
    .cin(or_s0_b2_2),
    .sum(s0_b2_0),
    .cout(s0_b2_0_co)
    );

jbi_adder_1b u_add_pre_tag_incr_s0_b2_1
   (.oper1(or_s0_b2_3),
    .oper2(or_s0_b2_4),
    .cin(or_s0_b2_5),
    .sum(s0_b2_1),
    .cout(s0_b2_1_co)
    );

assign or_s0_b3_0 = ~io_jbi_j_ad_ff[89] & io_jbi_j_ad_ff[88];
assign or_s0_b3_1 = ~io_jbi_j_ad_ff[90] & io_jbi_j_ad_ff[89];
assign or_s0_b3_2 = ~io_jbi_j_ad_ff[91] & io_jbi_j_ad_ff[90];
assign or_s0_b3_3 = ~io_jbi_j_ad_ff[92] & io_jbi_j_ad_ff[91];
assign or_s0_b3_4 = ~io_jbi_j_ad_ff[93] & io_jbi_j_ad_ff[92];
assign or_s0_b3_5 = ~io_jbi_j_ad_ff[94] & io_jbi_j_ad_ff[93];
assign s1_b3_ci   = io_jbi_j_ad_ff[95]| (~io_jbi_j_ad_ff[95] & io_jbi_j_ad_ff[94]);

jbi_adder_1b u_add_pre_tag_incr_s0_b3_0
   (.oper1(or_s0_b3_0),
    .oper2(or_s0_b3_1),
    .cin(or_s0_b3_2),
    .sum(s0_b3_0),
    .cout(s0_b3_0_co)
    );

jbi_adder_1b u_add_pre_tag_incr_s0_b3_1
   (.oper1(or_s0_b3_3),
    .oper2(or_s0_b3_4),
    .cin(or_s0_b3_5),
    .sum(s0_b3_1),
    .cout(s0_b3_1_co)
    );

assign or_s0_b4_0 = ~io_jbi_j_ad_ff[97] & io_jbi_j_ad_ff[96];
assign or_s0_b4_1 = ~io_jbi_j_ad_ff[98] & io_jbi_j_ad_ff[97];
assign or_s0_b4_2 = ~io_jbi_j_ad_ff[99] & io_jbi_j_ad_ff[98];
assign or_s0_b4_3 = ~io_jbi_j_ad_ff[100] & io_jbi_j_ad_ff[99];
assign or_s0_b4_4 = ~io_jbi_j_ad_ff[101] & io_jbi_j_ad_ff[100];
assign or_s0_b4_5 = ~io_jbi_j_ad_ff[102] & io_jbi_j_ad_ff[101];
assign s1_b4_ci   = io_jbi_j_ad_ff[103] | (~io_jbi_j_ad_ff[103] & io_jbi_j_ad_ff[102]);

jbi_adder_1b u_add_pre_tag_incr_s0_b4_0
   (.oper1(or_s0_b4_0),
    .oper2(or_s0_b4_1),
    .cin(or_s0_b4_2),
    .sum(s0_b4_0),
    .cout(s0_b4_0_co)
    );

jbi_adder_1b u_add_pre_tag_incr_s0_b4_1
   (.oper1(or_s0_b4_3),
    .oper2(or_s0_b4_4),
    .cin(or_s0_b4_5),
    .sum(s0_b4_1),
    .cout(s0_b4_1_co)
    );

assign or_s0_b5_0 = ~io_jbi_j_ad_ff[105] & io_jbi_j_ad_ff[104];
assign or_s0_b5_1 = ~io_jbi_j_ad_ff[106] & io_jbi_j_ad_ff[105];
assign or_s0_b5_2 = ~io_jbi_j_ad_ff[107] & io_jbi_j_ad_ff[106];
assign or_s0_b5_3 = ~io_jbi_j_ad_ff[108] & io_jbi_j_ad_ff[107];
assign or_s0_b5_4 = ~io_jbi_j_ad_ff[109] & io_jbi_j_ad_ff[108];
assign or_s0_b5_5 = ~io_jbi_j_ad_ff[110] & io_jbi_j_ad_ff[109];
assign s1_b5_ci   = io_jbi_j_ad_ff[111] | (~io_jbi_j_ad_ff[111] & io_jbi_j_ad_ff[110]);

jbi_adder_1b u_add_pre_tag_incr_s0_b5_0
   (.oper1(or_s0_b5_0),
    .oper2(or_s0_b5_1),
    .cin(or_s0_b5_2),
    .sum(s0_b5_0),
    .cout(s0_b5_0_co)
    );

jbi_adder_1b u_add_pre_tag_incr_s0_b5_1
   (.oper1(or_s0_b5_3),
    .oper2(or_s0_b5_4),
    .cin(or_s0_b5_5),
    .sum(s0_b5_1),
    .cout(s0_b5_1_co)
    );

assign or_s0_b6_0 = ~io_jbi_j_ad_ff[113] & io_jbi_j_ad_ff[112];
assign or_s0_b6_1 = ~io_jbi_j_ad_ff[114] & io_jbi_j_ad_ff[113];
assign or_s0_b6_2 = ~io_jbi_j_ad_ff[115] & io_jbi_j_ad_ff[114];
assign or_s0_b6_3 = ~io_jbi_j_ad_ff[116] & io_jbi_j_ad_ff[115];
assign or_s0_b6_4 = ~io_jbi_j_ad_ff[117] & io_jbi_j_ad_ff[116];
assign or_s0_b6_5 = ~io_jbi_j_ad_ff[118] & io_jbi_j_ad_ff[117];
assign s1_b6_ci   = io_jbi_j_ad_ff[119] | (~io_jbi_j_ad_ff[119] & io_jbi_j_ad_ff[118]);

jbi_adder_1b u_add_pre_tag_incr_s0_b6_0
   (.oper1(or_s0_b6_0),
    .oper2(or_s0_b6_1),
    .cin(or_s0_b6_2),
    .sum(s0_b6_0),
    .cout(s0_b6_0_co)
    );

jbi_adder_1b u_add_pre_tag_incr_s0_b6_1
   (.oper1(or_s0_b6_3),
    .oper2(or_s0_b6_4),
    .cin(or_s0_b6_5),
    .sum(s0_b6_1),
    .cout(s0_b6_1_co)
    );

assign or_s0_b7_0 = ~io_jbi_j_ad_ff[121] & io_jbi_j_ad_ff[120];
assign or_s0_b7_1 = ~io_jbi_j_ad_ff[122] & io_jbi_j_ad_ff[121];
assign or_s0_b7_2 = ~io_jbi_j_ad_ff[123] & io_jbi_j_ad_ff[122];
assign or_s0_b7_3 = ~io_jbi_j_ad_ff[124] & io_jbi_j_ad_ff[123];
assign or_s0_b7_4 = ~io_jbi_j_ad_ff[125] & io_jbi_j_ad_ff[124];
assign or_s0_b7_5 = ~io_jbi_j_ad_ff[126] & io_jbi_j_ad_ff[125];
assign s1_b7_ci   = io_jbi_j_ad_ff[127] | (~io_jbi_j_ad_ff[127] & io_jbi_j_ad_ff[126]);

jbi_adder_1b u_add_pre_tag_incr_s0_b7_0
   (.oper1(or_s0_b7_0),
    .oper2(or_s0_b7_1),
    .cin(or_s0_b7_2),
    .sum(s0_b7_0),
    .cout(s0_b7_0_co)
    );

jbi_adder_1b u_add_pre_tag_incr_s0_b7_1
   (.oper1(or_s0_b7_3),
    .oper2(or_s0_b7_4),
    .cin(or_s0_b7_5),
    .sum(s0_b7_1),
    .cout(s0_b7_1_co)
    );

//----------------------
// Stage 1
// - 2-bit adders
//----------------------
				   
jbi_adder_2b u_add_pre_tag_incr_s1_b0
   (.oper1({s0_b0_0_co, s0_b0_0}),
    .oper2({s0_b0_1_co, s0_b0_1}),
    .cin(s1_b0_ci),
    .sum(s1_b0),
    .cout(s1_b0_co)
    );

jbi_adder_2b u_add_pre_tag_incr_s1_b1
   (.oper1({s0_b1_0_co, s0_b1_0}),
    .oper2({s0_b1_1_co, s0_b1_1}),
    .cin(s1_b1_ci),
    .sum(s1_b1),
    .cout(s1_b1_co)
    );

jbi_adder_2b u_add_pre_tag_incr_s1_b2
   (.oper1({s0_b2_0_co, s0_b2_0}),
    .oper2({s0_b2_1_co, s0_b2_1}),
    .cin(s1_b2_ci),
    .sum(s1_b2),
    .cout(s1_b2_co)
    );

jbi_adder_2b u_add_pre_tag_incr_s1_b3
   (.oper1({s0_b3_0_co, s0_b3_0}),
    .oper2({s0_b3_1_co, s0_b3_1}),
    .cin(s1_b3_ci),
    .sum(s1_b3),
    .cout(s1_b3_co)
    );

jbi_adder_2b u_add_pre_tag_incr_s1_b4
   (.oper1({s0_b4_0_co, s0_b4_0}),
    .oper2({s0_b4_1_co, s0_b4_1}),
    .cin(s1_b4_ci),
    .sum(s1_b4),
    .cout(s1_b4_co)
    );

jbi_adder_2b u_add_pre_tag_incr_s1_b5
   (.oper1({s0_b5_0_co, s0_b5_0}),
    .oper2({s0_b5_1_co, s0_b5_1}),
    .cin(s1_b5_ci),
    .sum(s1_b5),
    .cout(s1_b5_co)
    );

jbi_adder_2b u_add_pre_tag_incr_s1_b6
   (.oper1({s0_b6_0_co, s0_b6_0}),
    .oper2({s0_b6_1_co, s0_b6_1}),
    .cin(s1_b6_ci),
    .sum(s1_b6),
    .cout(s1_b6_co)
    );
				   
jbi_adder_2b u_add_pre_tag_incr_s1_b7
   (.oper1({s0_b7_0_co, s0_b7_0}),
    .oper2({s0_b7_1_co, s0_b7_1}),
    .cin(s1_b7_ci),
    .sum(s1_b7),
    .cout(s1_b7_co)
    );

//----------------------
// Stage 2
// - 3-bit adders
//----------------------
				   
jbi_adder_3b u_add_pre_tag_incr_s2_b0
   (.oper1({s1_b0_co, s1_b0}),
    .oper2({s1_b1_co, s1_b1}),
    .cin(1'b0),
    .sum(s2_b0),
    .cout(s2_b0_co)
    );

jbi_adder_3b u_add_pre_tag_incr_s2_b1
   (.oper1({s1_b2_co, s1_b2}),
    .oper2({s1_b3_co, s1_b3}),
    .cin(1'b0),
    .sum(s2_b1),
    .cout(s2_b1_co)
    );

jbi_adder_3b u_add_pre_tag_incr_s2_b2
   (.oper1({s1_b4_co, s1_b4}),
    .oper2({s1_b5_co, s1_b5}),
    .cin(1'b0),
    .sum(s2_b2),
    .cout(s2_b2_co)
    );

jbi_adder_3b u_add_pre_tag_incr_s2_b3
   (.oper1({s1_b6_co, s1_b6}),
    .oper2({s1_b7_co, s1_b7}),
    .cin(1'b0),
    .sum(s2_b3),
    .cout(s2_b3_co)
    );


//----------------------
// Stage 3
// - 4-bit adders
//----------------------
				   
jbi_adder_4b u_add_pre_tag_incr_s3_b0
   (.oper1({s2_b0_co, s2_b0}),
    .oper2({s2_b1_co, s2_b1}),
    .cin(1'b0),
    .sum(s3_b0),
    .cout(s3_b0_co)
    );

jbi_adder_4b u_add_pre_tag_incr_s3_b1
   (.oper1({s2_b2_co, s2_b2}),
    .oper2({s2_b3_co, s2_b3}),
    .cin(1'b0),
    .sum(s3_b1),
    .cout(s3_b1_co)
    );

//----------------------
// Stage 4
// - 5-bit adder
//----------------------
				   
jbi_adder_5b u_add_pre_tag_incr_s4
   (.oper1({s3_b0_co, s3_b0}),
    .oper2({s3_b1_co, s3_b1}),
    .cin(1'b0),
    .sum(s4),
    .cout(s4_co)
    );

assign pre_tag_incr = {s4_co, s4};

endmodule

// Local Variables:
// verilog-library-directories:(".")
// verilog-auto-sense-defines-constant:t
// End:


module jbi_adder_1b(/*AUTOARG*/
   // Outputs
   cout, sum, 
   // Inputs
   oper1, oper2, cin
   );
input   oper1;
input   oper2;
input   cin;
output  cout;
output  sum;

assign  sum = oper1 ^ oper2 ^ cin ;
assign  cout =  ( cin & ( oper1 | oper2 ) ) |
                ( oper1 & oper2 ) ;

endmodule

module jbi_adder_2b(/*AUTOARG*/
   // Outputs
   sum, cout, 
   // Inputs
   oper1, oper2, cin
   );

input   [1:0]	oper1;
input   [1:0]	oper2;
input   cin;
output  [1:0]	sum;
output  cout;

wire    [1:0]   gen, prop;
wire    [2:0]   carry ;

assign  carry[0] = cin;

assign  gen[0] = oper1[0] & oper2[0] ;
assign  prop[0] = oper1[0] | oper2[0] ;
assign  sum[0] = oper1[0] ^ oper2[0] ^ carry[0] ;


assign  carry[1] = ( carry[0]  & prop[0] ) | gen[0] ;

assign  gen[1] = oper1[1] & oper2[1] ;
assign  prop[1] = oper1[1] | oper2[1] ;
assign  sum[1] = oper1[1] ^ oper2[1] ^ carry[1] ;

assign  carry[2] = ( carry[0] & prop[0]  & prop[1] ) |
                ( gen[0]  &  prop[1] ) |
                 gen[1] ;

assign  cout = carry[2] ;


endmodule


module jbi_adder_3b(/*AUTOARG*/
   // Outputs
   sum, cout, 
   // Inputs
   oper1, oper2, cin
   );

input   [2:0]	oper1;
input   [2:0]	oper2;
input   cin;
output  [2:0]	sum;
output	cout;

wire    [2:0]   gen, prop;
wire    [3:0]   carry ;

assign  carry[0] = cin;

assign  gen[0] = oper1[0] & oper2[0] ;
assign  prop[0] = oper1[0] | oper2[0] ;
assign  sum[0] = oper1[0] ^ oper2[0] ^ carry[0] ;


assign  carry[1] = ( carry[0]  & prop[0] ) | gen[0] ;

assign  gen[1] = oper1[1] & oper2[1] ;
assign  prop[1] = oper1[1] | oper2[1] ;
assign  sum[1] = oper1[1] ^ oper2[1] ^ carry[1] ;

assign  carry[2] = ( carry[0]  & prop[0] & prop[1] ) |
                ( gen[0]  & prop[1] ) | gen[1]   ;

assign  gen[2] = oper1[2] & oper2[2] ;
assign  prop[2] = oper1[2] | oper2[2] ;
assign  sum[2] = oper1[2] ^ oper2[2] ^ carry[2] ;

assign  carry[3] = ( carry[0]  & prop[0] & prop[1] & prop[2] ) |
                        ( gen[0]  & prop[1] & prop[2] ) |
                        ( gen[1]  & prop[2] ) | gen[2]   ;


assign  cout = carry[3];

endmodule

module jbi_adder_4b(/*AUTOARG*/
   // Outputs
   sum, cout, 
   // Inputs
   oper1, oper2, cin
   );

input   [3:0]	oper1;
input   [3:0]	oper2;
input   cin;
output  [3:0]	sum;
output	cout;

wire    [3:0]   gen, prop;
wire    [4:0]   carry ;

assign  carry[0] = cin;

assign  gen[0] = oper1[0] & oper2[0] ;
assign  prop[0] = oper1[0] | oper2[0] ;
assign  sum[0] = oper1[0] ^ oper2[0] ^ carry[0] ;


assign  carry[1] = ( carry[0]  & prop[0] ) | gen[0] ;

assign  gen[1] = oper1[1] & oper2[1] ;
assign  prop[1] = oper1[1] | oper2[1] ;
assign  sum[1] = oper1[1] ^ oper2[1] ^ carry[1] ;

assign  carry[2] = ( carry[0]  & prop[0] & prop[1] ) |
                ( gen[0]  & prop[1] ) | gen[1]   ;

assign  gen[2] = oper1[2] & oper2[2] ;
assign  prop[2] = oper1[2] | oper2[2] ;
assign  sum[2] = oper1[2] ^ oper2[2] ^ carry[2] ;

assign  carry[3] = ( carry[0]  & prop[0] & prop[1] & prop[2] ) |
                        ( gen[0]  & prop[1] & prop[2] ) |
                        ( gen[1]  & prop[2] ) | gen[2]   ;

assign  gen[3] = oper1[3] & oper2[3] ;
assign  prop[3] = oper1[3] | oper2[3] ;
assign  sum[3] = oper1[3] ^ oper2[3] ^ carry[3] ;

assign  carry[4] = ( carry[0]  & prop[0] & prop[1] & prop[2]  & prop[3] ) |
                        ( gen[0]  & prop[1] & prop[2] & prop[3] ) |
                        ( gen[1]  & prop[2] & prop[3] ) | 
			( gen[2] & prop[3] ) |
			( gen[3] );   



assign  cout = carry[4];

endmodule



module jbi_adder_5b(/*AUTOARG*/
   // Outputs
   sum, cout, 
   // Inputs
   oper1, oper2, cin
   );

input   [4:0]	oper1;
input   [4:0]	oper2;
input   cin;
output  [4:0]	sum;
output	cout;

wire    [4:0]   gen, prop;
wire    [5:0]   carry ;

assign  carry[0] = cin;

assign  gen[0] = oper1[0] & oper2[0] ;
assign  prop[0] = oper1[0] | oper2[0] ;
assign  sum[0] = oper1[0] ^ oper2[0] ^ carry[0] ;


assign  carry[1] = ( carry[0]  & prop[0] ) | gen[0] ;

assign  gen[1] = oper1[1] & oper2[1] ;
assign  prop[1] = oper1[1] | oper2[1] ;
assign  sum[1] = oper1[1] ^ oper2[1] ^ carry[1] ;

assign  carry[2] = ( carry[0]  & prop[0] & prop[1] ) |
                ( gen[0]  & prop[1] ) | gen[1]   ;

assign  gen[2] = oper1[2] & oper2[2] ;
assign  prop[2] = oper1[2] | oper2[2] ;
assign  sum[2] = oper1[2] ^ oper2[2] ^ carry[2] ;

assign  carry[3] = ( carry[0]  & prop[0] & prop[1] & prop[2] ) |
                        ( gen[0]  & prop[1] & prop[2] ) |
                        ( gen[1]  & prop[2] ) | gen[2]   ;

assign  gen[3] = oper1[3] & oper2[3] ;
assign  prop[3] = oper1[3] | oper2[3] ;
assign  sum[3] = oper1[3] ^ oper2[3] ^ carry[3] ;

assign  carry[4] = ( carry[0]  & prop[0] & prop[1] & prop[2]  & prop[3] ) |
                        ( gen[0]  & prop[1] & prop[2] & prop[3] ) |
                        ( gen[1]  & prop[2] & prop[3] ) | 
			( gen[2] & prop[3] ) |
			( gen[3] );   

assign  gen[4] = oper1[4] & oper2[4] ;
assign  prop[4] = oper1[4] | oper2[4] ;
assign  sum[4] = oper1[4] ^ oper2[4] ^ carry[4] ;

assign  carry[5] = ( carry[0]  & prop[0] & prop[1] & prop[2]  & prop[3] 
			& prop[4] ) |
                        ( gen[0]  & prop[1] & prop[2] & prop[3] 
			& prop[4] ) |
                        ( gen[1]  & prop[2] & prop[3] & prop[4] ) | 
			( gen[2] & prop[3] & prop[4] ) |
			( gen[3] & prop[4] ) |
			( gen[4] );   

assign  cout = carry[5];

endmodule



