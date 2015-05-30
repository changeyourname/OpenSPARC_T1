/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: shuffle_memory.c
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
#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>


#include "shuffle_memory.h"
#include "insn_asm.h"
#include "data.h"


int verbose_flag = 0;
int loop_count   = LOOP_COUNT;


struct insn_info {
    int         op;
    char       *name;
    int         n_bytes;
    uint64_t    aligned_addr_mask;
    int         store_only;
};


#define LDUB      0
#define LDUH      1
#define LDUW      2
#define LDX       3

#define STB       4
#define STH       5
#define STW       6
#define STX       7

#define SWAP      8
#define CAS       9
#define CASX      10
#define LDSTUB    11

#define N_INSNS_REAL   12

#define N_INSNS   (12 + N_INSNS_REAL)


struct insn_info insn_info[N_INSNS] = {

    { LDUB,   "LDUB",   1,  ~(UINT64_C(0x0)), 0 },
    { LDUH,   "LDUH",   2,  ~(UINT64_C(0x1)), 0 },
    { LDUW,   "LDUW",   4,  ~(UINT64_C(0x3)), 0 },
    { LDX,    "LDX",    8,  ~(UINT64_C(0x7)), 0 },
  
    { STB,    "STB",    1,  ~(UINT64_C(0x0)), 1 },
    { STH,    "STH",    2,  ~(UINT64_C(0x1)), 1 },
    { STW,    "STW",    4,  ~(UINT64_C(0x3)), 1 },
    { STX,    "STX",    8,  ~(UINT64_C(0x7)), 1 },

    { SWAP,   "SWAP",   4,  ~(UINT64_C(0x3)), 0 },
    { CAS,    "CAS",    4,  ~(UINT64_C(0x3)), 0 },
    { CASX,   "CASX",   8,  ~(UINT64_C(0x7)), 0 },
    { LDSTUB, "LDSTUB", 1,  ~(UINT64_C(0x0)), 0 },

    { LDUB,   "LDUB",   1,  ~(UINT64_C(0x0)), 0 },
    { LDUH,   "LDUH",   2,  ~(UINT64_C(0x1)), 0 },
    { LDUW,   "LDUW",   4,  ~(UINT64_C(0x3)), 0 },
    { LDX,    "LDX",    8,  ~(UINT64_C(0x7)), 0 },
  
    { STB,    "STB",    1,  ~(UINT64_C(0x0)), 1 },
    { STH,    "STH",    2,  ~(UINT64_C(0x1)), 1 },
    { STW,    "STW",    4,  ~(UINT64_C(0x3)), 1 },
    { STX,    "STX",    8,  ~(UINT64_C(0x7)), 1 },

    { SWAP,   "SWAP",   4,  ~(UINT64_C(0x3)), 0 },
    { CAS,    "CAS",    4,  ~(UINT64_C(0x3)), 0 },
    { CASX,   "CASX",   8,  ~(UINT64_C(0x7)), 0 },
    { LDSTUB, "LDSTUB", 1,  ~(UINT64_C(0x0)), 0 }
};



#define CAS_CMP_VALUE       0xbadcafe
#define CASX_CMP_VALUE      0xbadcafe0badcafe


static int t1_randx = 1;

static void
t1_srand(unsigned int seed)
{
    t1_randx = seed;
}

static int
t1_rand(void)
{
    return (((t1_randx = t1_randx * 1103515245 + 12345)>>16) & 0x7fff);
}


static uint32_t
rand_30(void)
{
    uint32_t bits_29_15 = ((uint32_t) t1_rand()) << 15;
    uint32_t bits_14_0  = ((uint32_t) t1_rand());

    uint32_t ivalue = bits_29_15 | bits_14_0;

    return ivalue;
}


static int
verify_alignment(void *ptr, char *ptr_name)
{
    uintptr_t addr = (uintptr_t ) ptr;
    uintptr_t mask = TEST_MEMORY_ALIGNMENT - 1;

    if (addr & mask) {
	printf("ERROR: %s address 0x%llx is not aligned to 0x%x byte boundary \n", 
		             ptr_name, (unsigned long long) ptr, TEST_MEMORY_ALIGNMENT);
	return 0;
    }

    return 1;
}


static void
update_store_bytes(uint64_t *store_bytes_ptr, int bitpos, uint64_t new_value, int n_bytes)
{
    uint64_t mask;

    switch (n_bytes) {
	case 1: mask = (0xFFULL << bitpos); break;
	case 2: mask = (0xFFFFULL << bitpos); break;
	case 4: mask = (0xFFFFFFFFULL << bitpos); break;
	case 8: mask = (0xFFFFFFFFFFFFFFFFULL << bitpos); break;
	default: mask = 0; break;
    }

    (*store_bytes_ptr) &= ~mask;
    (*store_bytes_ptr) |= ((new_value << bitpos) & mask);

    return;
}


/*
 * The function shuffle_memory() shuffles the contents of test_memory
 * by randomly picking a memory instruction for each move (load/store)
 * operation. Eight bytes are always maintained in the variable "store_bytes".
 * The load value of any memory instruction is used to update "store_bytes" 
 * and "store_bytes" is used as the store value of any memory instruction.
 *
 * If the store value of a memory instruction is less than 8 bytes, then
 * the 8 byte offset of the address is used to pick the bytes in the "store_bytes".
 * Similary if the load value of a memory instruction is less than 8 bytes, then
 * the 8 byte offset of the address is used to pick the bytes in the "store_bytes",
 * to be updated with the new load value.
 *
 * If there are consequetive store only memory operations, the "store_bytes" value
 * doesn't change and to prevent propagation of the same value everywhere, the
 * address is not changed for consequetive store only memory operations.
 *
 * ldstub always writes 0xFF to the memory location and to prevent propagation of
 * 0xFF everywhere, less weightage is given for ldstub instruction.
 */

int
shuffle_memory(Elem *test_memory)
{
    int index, memory_insn, bitpos, print_period;

    int prev_op_store_only_flag = 0;
    int error_count = 0;

    uintptr_t test_memory_addr;
    uintptr_t mem_addr, aligned_mem_addr;
    uint64_t  offset, aligned_offset;


    uint64_t store_bytes;

    uint64_t load_value;
    uint64_t store_value;

    uint64_t old_cas_value;
    uint64_t old_casx_value;



    print_period = (TEST_MEMORY_SIZE * loop_count) >> 4;
    if (print_period == 0) {
	print_period = 1;
    }


    printf("INFO: Shuffling test memory using the following memory operations. \n\n");
    printf("INFO: ");
    for (int i=0; i<N_INSNS_REAL; i++) {
	printf("%s ", insn_info[i].name);
    }
    printf("\n\n");
     

    if (verify_alignment(test_memory, "test_memory") == 0) {
	printf("ERROR: test_memory failed alignment verification \n");
	return 0;
    }

    test_memory_addr = (uintptr_t ) test_memory;



    offset           = rand_30() % TEST_MEMORY_SIZE;
    aligned_offset   = offset & ~(0x7ULL);

    mem_addr         = test_memory_addr + offset;
    aligned_mem_addr = mem_addr & ~(0x7ULL);

    store_bytes = ldx(aligned_mem_addr);

    if (verbose_flag) {
	printf("Initial value of store_bytes: test_memory_offset 0x%" PRIx64 " store_bytes 0x%" PRIx64 " \n\n",
		aligned_offset, store_bytes);
    }


    for (int i=0; i<(TEST_MEMORY_SIZE * loop_count); i++) {

        if (verbose_flag == 0) {
	    if ((i % print_period) == 0) {
		printf("INFO: mem_op_count 0x%x \n", i);
	    }
	}

	index = t1_rand() % N_INSNS_REAL;
	memory_insn = insn_info[index].op;
	if (memory_insn == LDSTUB) {
	    if ((t1_rand() % (10 * loop_count)) >= 2) {
		// reduce weightage for ldstub instructions
		index = t1_rand() % N_INSNS_REAL;
		memory_insn = insn_info[index].op;
		if (memory_insn == LDSTUB) {
		    index = 0;
		    memory_insn = insn_info[index].op;
		}
	    }
	}

	if (insn_info[index].store_only && prev_op_store_only_flag) {

	    aligned_offset   = offset   & insn_info[index].aligned_addr_mask;
	    aligned_mem_addr = mem_addr & insn_info[index].aligned_addr_mask;

	} else {

	    offset           = rand_30() % TEST_MEMORY_SIZE;
	    aligned_offset   = offset & insn_info[index].aligned_addr_mask;

	    mem_addr         = test_memory_addr + offset;
	    aligned_mem_addr = mem_addr & insn_info[index].aligned_addr_mask;
	}


	bitpos = ((aligned_mem_addr & 0x7) << 3);

	switch (memory_insn) {
	    case LDUB:
	    {
		load_value = ldub(aligned_mem_addr);
	    }
	    break;

	    case LDUH:
	    {
		load_value = lduh(aligned_mem_addr);
	    }
	    break;

	    case LDUW:
	    {
		load_value = lduw(aligned_mem_addr);
	    }
	    break;

	    case LDX:
	    {
		load_value = ldx(aligned_mem_addr);
	    }
	    break;

	    case STB:
	    {
		store_value = (store_bytes >> bitpos) & 0xFF;
		stb(aligned_mem_addr, store_value);
	    }
	    break;

	    case STH:
	    {
		store_value = (store_bytes >> bitpos) & 0xFFFF;
		sth(aligned_mem_addr, store_value);
	    }
	    break;

	    case STW:
	    {
		store_value = (store_bytes >> bitpos) & 0xFFFFFFFF;
		stw(aligned_mem_addr, store_value);
	    }
	    break;

	    case STX:
	    {
		store_value = store_bytes;
		stx(aligned_mem_addr, store_value);
	    }
	    break;

	    case SWAP:
	    {
		store_value = (store_bytes >> bitpos) & 0xFFFFFFFF;
		load_value = swap(aligned_mem_addr, store_value);
	    }
	    break;

	    case CAS:
	    {
		store_value = (store_bytes >> bitpos) & 0xFFFFFFFF;
		old_cas_value = cas(aligned_mem_addr, CAS_CMP_VALUE, store_value);
		if (old_cas_value != CAS_CMP_VALUE) {
		    load_value = cas(aligned_mem_addr, old_cas_value, store_value);
		    if (load_value != old_cas_value) {
			printf("ERROR: cas failed old_cas_value 0x%x load_value 0x%x \n", old_cas_value, load_value);
			error_count++;
		    }
		} else {
		    load_value = old_cas_value;
		}
	    }
	    break;

	    case CASX:
	    {
		store_value = store_bytes;
		old_casx_value = casx(aligned_mem_addr, CASX_CMP_VALUE, store_value);
		if (old_casx_value != CASX_CMP_VALUE) {
		    load_value = casx(aligned_mem_addr, old_casx_value, store_value);
		    if (load_value != old_casx_value) {
			printf("ERROR: casx failed old_casx_value 0x%x load_value 0x%x \n", old_casx_value, load_value);
			error_count++;
		    }
		} else {
		    load_value = old_casx_value;
		}
	    }
	    break;

	    case LDSTUB:
	    {
		load_value = ldstub(aligned_mem_addr);
	    }
	    break;
	}

	if (insn_info[index].store_only == 0) {
	    update_store_bytes(&store_bytes, bitpos, load_value, insn_info[index].n_bytes);
	}

	prev_op_store_only_flag = insn_info[index].store_only;

	if (verbose_flag) {

	    printf("INFO: mem_op_count 0x%x: %s test_memory_offset 0x%" PRIx64, i, insn_info[index].name, aligned_offset);

	    if ((memory_insn == SWAP) || (memory_insn == CAS) || (memory_insn == CASX)) {
		printf(" store_value 0x%" PRIx64 " load_value 0x%" PRIx64 " store_bytes 0x%" PRIx64 " \n",
			store_value, load_value, store_bytes);
	    } else if (insn_info[index].store_only) {
		printf(" store_value 0x%" PRIx64 " store_bytes 0x%" PRIx64 " \n", store_value, store_bytes);
	    } else {
		printf(" load_value 0x%" PRIx64 " store_bytes 0x%" PRIx64 " \n", load_value, store_bytes);
	    }
	    if ((i > 0) && ((i % 4) == 0)) {
		printf("\n");
	    }
	}
    }

    printf("\n");
    if (error_count) {
	printf("ERROR: Shuffling of test_memory completed. error_count 0x%x \n\n", error_count);
    } else {
	printf("INFO: Shuffling of test_memory completed. \n\n");
    }

    return (error_count ? 0 : 1);
}


int
verify_results(Elem *test_memory, Elem *expected_memory)
{
    int error_count = 0;
    int print_period;

 
    print_period = TEST_MEMORY_WORDS >> 4;
    if (print_period == 0) {
	print_period = 1;
    }


    printf("INFO: Starting comparison of shuffled test_memory with expected_memory ...... \n\n");


    if (verify_alignment(test_memory, "test_memory") == 0) {
	printf("ERROR: test_memory failed alignment verification \n");
	return 0;
    }

    if (verify_alignment(expected_memory, "expected_memory") == 0) {
	printf("ERROR: expected_memory failed alignment verification \n");
	return 0;
    }

    for (int i=0; i<TEST_MEMORY_WORDS; i++) {
	if (test_memory[i] != expected_memory[i]) {
	    printf("ERROR: test_memory 0x%" PRIx64 " !=  expected_memory 0x%" PRIx64 "   at word 0x%x \n", 
			   (uint64_t) test_memory[i], (uint64_t) expected_memory[i], i);
	    error_count++;
	    if (error_count > MAX_ERROR_COUNT) {
		printf("ERROR: terminating comparison because number of errors exceeded MAX_ERROR_COUNT 0x%x \n", MAX_ERROR_COUNT);
		break;
	    }
	} else if (verbose_flag == 0) {
	    if ((i % print_period) == 0) {
		printf("INFO: offset 0x%x test_memory 0x%" PRIx64 " expected_memory 0x%" PRIx64 " \n", 
			      (i * 4), (uint64_t) test_memory[i], (uint64_t) expected_memory[i]);
	    }
	} else {
	    if ((i % 4) == 0) {
		printf("\n");
	    }
	    printf("INFO: offset 0x%x test_memory 0x%" PRIx64 " expected_memory 0x%" PRIx64 " \n", 
			  (i * 4), (uint64_t) test_memory[i], (uint64_t) expected_memory[i]);
	}
    }

    if (error_count == 0) {
	printf("\nINFO: Memory Operations Test PASSED \n\n");
    } else {
	printf("\nINFO: Memory Operations Test FAILED . error_count 0x%x  \n\n", error_count);
    }

    return (error_count ? 0 : 1);
}
