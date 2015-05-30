/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: put.c
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
#include <sys/types.h>


#include <t1_stdio.h>
#include <hcall.h>


/*
 * Notes: 
 *
 * 1) For convenience, puts does line control and inserts
 *    a CR before every NL.
 */



static uchar_t byte_to_hexchar[] = "0123456789abcdef";

/*
 * Print the string to the console.
 */

int
t1_puts(const char *str)
{
    int  c;
    int  count = 0;

    while (c = *str++) {
	if (c == '\n') {
	    hv_cnputchar('\r');
	}
	hv_cnputchar(c);
	count++;
    }

    return count;
}



/*
 * Print the 64-bit value to the console in hex format.
 */

int
t1_putx(const uint64_t lvalue)
{
    int count = 0;
    int byte, c;

    uint64_t tmp_lvalue = lvalue; 
    int shift_count = 0;

    if (lvalue == 0) {
	hv_cnputchar('0');
	return 1;
    }

    while (tmp_lvalue) {
	shift_count += 4;
	tmp_lvalue >>= 4;
    }

    do {
	shift_count -= 4;
	byte = (lvalue >> shift_count) & 0xf;
	c = byte_to_hexchar[byte];
	hv_cnputchar(c);
    } while (shift_count);

    return count;
}
