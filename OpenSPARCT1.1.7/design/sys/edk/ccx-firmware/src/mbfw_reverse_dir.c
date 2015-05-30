/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_reverse_dir.c
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
#include "mbfw_types.h"
#include "mbfw_config.h"
#include "mbfw_reverse_dir.h"


#define INVALID_TAG             0x80000000


#define T1_ICACHE_SIZE	        16 * 1024
#define T1_DCACHE_SIZE	        8 * 1024


#define L1_CACHE_N_WAYS         4


#define ICACHE_N_SETS           ((T1_ICACHE_SIZE / T1_ICACHE_LINE_SIZE) / L1_CACHE_N_WAYS)
#define DCACHE_N_SETS           ((T1_DCACHE_SIZE / T1_DCACHE_LINE_SIZE) / L1_CACHE_N_WAYS)


#define ICACHE_INDEX(t1_addr)   ((t1_addr & 0xfe0) >> 5)
#define ICACHE_TAG(t1_addr)     (t1_addr >> 12)

#define DCACHE_INDEX(t1_addr)   ((t1_addr & 0x7f0) >> 4)
#define DCACHE_TAG(t1_addr)     (t1_addr >> 11)



struct cache_set {
    uint32_t  tags[L1_CACHE_N_WAYS];
};

static struct cache_set  icache_reverse_dir[T1_NUM_OF_CORES][ICACHE_N_SETS];
static struct cache_set  dcache_reverse_dir[T1_NUM_OF_CORES][DCACHE_N_SETS];


void
init_l1_reverse_dir(void)
{
    int i, j;
    int core_id;


    /* Assuming sequential core ids starting from 0 */

    for (core_id = 0; core_id < T1_NUM_OF_CORES; core_id++) {
	for (i = 0; i < ICACHE_N_SETS; i++) {
	    for (j = 0; j < L1_CACHE_N_WAYS; j++) {
		icache_reverse_dir[core_id][i].tags[j] = INVALID_TAG;
		dcache_reverse_dir[core_id][i].tags[j] = INVALID_TAG;
		/* ICACHE_N_SETS == DCACHE_N_SETS */
	    }
	}
    }
}

void
add_icache_line(int core_id, taddr_opt_t t1_addr, int way)
{
    int       index = ICACHE_INDEX(t1_addr);
    uint32_t  tag   = ICACHE_TAG(t1_addr);

    icache_reverse_dir[core_id][index].tags[way] = tag;
    return;
}

void
add_dcache_line(int core_id, taddr_opt_t t1_addr, int way)
{
    int       index = DCACHE_INDEX(t1_addr);
    uint32_t  tag   = DCACHE_TAG(t1_addr);

    dcache_reverse_dir[core_id][index].tags[way] = tag;
    return;
}


/* return the way if found, otherwise return -1 */

int
search_icache(int core_id, taddr_opt_t t1_addr)
{
    int       index = ICACHE_INDEX(t1_addr);
    uint32_t  tag   = ICACHE_TAG(t1_addr);
    int       way;


    /* counting down from 3 ... 0 saves instructions in the loop */

    for (way = (L1_CACHE_N_WAYS-1); way >= 0; way--) {
        if (icache_reverse_dir[core_id][index].tags[way] == tag) {
            return way;
	}
    }
    return way;
}


/* return the way if found, otherwise return -1 */

int
search_dcache(int core_id, taddr_opt_t t1_addr)
{
    int       index = DCACHE_INDEX(t1_addr);
    uint32_t  tag   = DCACHE_TAG(t1_addr);
    int       way;

    for (way = (L1_CACHE_N_WAYS-1); way >= 0; way--) {
        if (dcache_reverse_dir[core_id][index].tags[way] == tag) {
            return way;
	}
    }
    return way;
}


/* invalidate if found and return the way. return -1 if not found */

int
invalidate_icache(int core_id, taddr_opt_t t1_addr)
{
    int       index = ICACHE_INDEX(t1_addr);
    uint32_t  tag   = ICACHE_TAG(t1_addr);
    int       way;

    for (way = (L1_CACHE_N_WAYS-1); way >= 0; way--) {
        if (icache_reverse_dir[core_id][index].tags[way] == tag) {
	    icache_reverse_dir[core_id][index].tags[way] = INVALID_TAG;
            return way;
	}
    }
    return way;
}



/* invalidate if found and return the way. return -1 if not found */

int
invalidate_dcache(int core_id, taddr_opt_t t1_addr)
{
    int       index = DCACHE_INDEX(t1_addr);
    uint32_t  tag   = DCACHE_TAG(t1_addr);
    int       way;

    for (way = (L1_CACHE_N_WAYS-1); way >= 0; way--) {
        if (dcache_reverse_dir[core_id][index].tags[way] == tag) {
	    dcache_reverse_dir[core_id][index].tags[way] = INVALID_TAG;
            return way;
	}
    }
    return way;
}

/* Invalidate all ways of a given index */

void
icache_invalidate_all_ways(int core_id, taddr_opt_t t1_addr)
{
    int       index = ICACHE_INDEX(t1_addr);
    int        way;

    for (way = (L1_CACHE_N_WAYS-1); way >= 0; way--) {
	icache_reverse_dir[core_id][index].tags[way] = INVALID_TAG;
    }
    return;
}

/* Invalidate all ways of a given index */

void
dcache_invalidate_all_ways(int core_id, taddr_opt_t t1_addr)
{
    int       index = DCACHE_INDEX(t1_addr);
    int        way;

    for (way = (L1_CACHE_N_WAYS-1); way >= 0; way--) {
	dcache_reverse_dir[core_id][index].tags[way] = INVALID_TAG;
    }
    return;
}

