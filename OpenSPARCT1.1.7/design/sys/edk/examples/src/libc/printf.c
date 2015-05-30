/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: printf.c
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
#include <stdio.h>

#include <stdarg.h>

#include <t1_stdio.h>



/*
 * Notes:
 *
 * 1) This minimalist vprintf implementation is done so that strings 
 *    and hex values could be printed without splitting a single printf
 *    into multiple unreadable t1_puts(), t1_putx() calls.
 *
 * 2) only %s %x %lx %llx supported.
 *
 */


#define PRINT_BUF_SIZE   128


static int
t1_vprintf(const char *format, va_list ap)
{
    const char *fmt = format;

    char buf[PRINT_BUF_SIZE];

    char               *s_arg;
    uint_t              x_arg;
    unsigned long long  ll_arg;
    ulong_t             l_arg;

    int index;
    int c;
    int pct;
    int pct_l;
    int pct_ll;

    index = 0;
    pct = pct_l = pct_ll = 0;
    while (c = *fmt) {
	if (pct) {
	    if (pct_ll) {
		if (c == 'x') {
		    ll_arg = va_arg(ap, unsigned long long);
		    t1_putx(ll_arg);
		    pct = pct_l = pct_ll = 0;
		} else {
		    t1_puts("ERROR: invalid printf format starting at \"");
		    t1_puts(fmt);
		    t1_puts("\" \n");
		    t1_puts("only %s %x %lx %llx supported. \n");
		    va_end(ap);
		    return 0;
		}
	    } else {
		if (pct_l) {
		    if (c == 'x') {
			l_arg = va_arg(ap, ulong_t);
			t1_putx(l_arg);
			pct = pct_l = 0;
		    } else if (c == 'l') {
			pct_ll = 1;
		    } else {
			t1_puts("ERROR: invalid printf format starting at \"");
			t1_puts(fmt);
			t1_puts("\" \n");
			t1_puts("only %s %x %lx %llx supported. \n");
			va_end(ap);
			return 0;
		    }
		} else {
		    if (c == 's') {
			s_arg = va_arg(ap, char *);
			t1_puts(s_arg);
			pct = 0;
		    } else if (c == 'x') {
			x_arg = va_arg(ap, uint_t); 
			t1_putx(x_arg);
			pct = 0;
		    } else if (c == 'l') {
			pct_l = 1;
		    } else {
			t1_puts("ERROR: invalid printf format starting at \"");
			t1_puts(fmt);
			t1_puts("\" \n");
			t1_puts("only %s %x %lx %llx supported. \n");
			va_end(ap);
			return 0;
		    }
		}
	    }
	} else {
	    if (c != '%') {
		buf[index++] = c;
		if (index == (PRINT_BUF_SIZE - 1)) {
		    buf[index] = 0;
		    t1_puts(buf);
		    index = 0;
		}
	    } else {
		buf[index++] = 0;
		t1_puts(buf);
		pct = 1;
		index = 0;
	    }
	}
	fmt++;
    }
    if (index > 0) {
	buf[index] = 0;
	t1_puts(buf);
	index = 0;
    }

    va_end(ap);

    return 0;
}



#pragma weak printf


int
printf(const char *format, ...)
{
    va_list ap;

    va_start(ap, format);

    return t1_vprintf(format, ap);
}
