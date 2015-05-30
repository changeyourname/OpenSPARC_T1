/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: Range.h
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/
//------------------------------------------------------------------------------
//
// Description:  An object to capture an address range.
//
//------------------------------------------------------------------------------

#ifndef RANGE_H
#define RANGE_H

typedef unsigned long long ull;

class Range {
private:
  ull lo;
  ull hi;

public:
  Range(ull l, ull h) { lo = l; hi = h; }
  ull GetLo() { return lo; }
  ull GetHi() { return hi; }
  int InRange(ull val) {
    if ((lo <= val) && (hi >= val))
      return 1;
    return 0;
  }
};

#endif // RANGE_H