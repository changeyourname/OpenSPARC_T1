/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: randmem.c
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
#include <stdlib.h>
#include <strings.h>
#include <errno.h>

#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#include <inttypes.h>
#include <time.h>


/*
 * This program initializes the test_memory with random data and then shuffles
 * the test_memory. The initial and final shuffled contents of the test_memory
 * are written out to files. The files are included as data arrays in l2_emul_test
 * as test_memory_data[] and expected_memory_data[].  The shuffling function is 
 * also run on T1 FPGA system. The final shuffled contents of test_memory must 
 * match the contents of expected_memory.
 */



#include "shuffle_memory.h"
#include "data.h"




#define TEST_MEMORY_FILENAME       "test_memory.data"
#define EXPECTED_MEMORY_FILENAME   "expected_memory.data"



static Elem *test_memory;


static void
allocate_memory(void)
{
    uintptr_t alignment = TEST_MEMORY_ALIGNMENT;

    alignment = (alignment + 0xFFFFF) & ~(0xFFFFF);

    test_memory = (Elem *) mmap((void *) alignment, TEST_MEMORY_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_ANON|MAP_ALIGN, -1, 0);
    if (test_memory == (Elem *) MAP_FAILED) {
	perror("ERROR: mmap test_memory ");
	exit(EXIT_FAILURE);
    }

    return;
}


static void
init_test_memory(void)
{
    Elem ivalue;

    for (int i=0; i<TEST_MEMORY_WORDS; i++) {
	ivalue = lrand48();   /* bit 31 is always 0 */
	test_memory[i] = ivalue;
    }
}

static void
write_all(int ofd, const char *buf, size_t nbyte, const char *filename)
{
    size_t   rem_bytes, bytes_written;
    ssize_t  write_result;

    bytes_written = 0;
    rem_bytes     = nbyte;

    while (rem_bytes) {
	write_result = write(ofd, &buf[bytes_written], rem_bytes);
	if (write_result < 0) {
	    perror("ERROR: write ");
	    fprintf(stderr, "ERROR: Couldn't write file \"%s\" \n", filename);
	    exit(EXIT_FAILURE);
	}

	rem_bytes     -= write_result;
	bytes_written += write_result;
    }

    return;
}

void
write_file(const char *filename, char *buf, size_t buf_size)
{
    int     fd;

    fd = open(filename, O_WRONLY|O_CREAT|O_TRUNC, 0666);
    if (fd < 0) {
	perror("ERROR: open ");
	fprintf(stderr, "ERROR: Couldn't open file \"%s\" for writing \n", filename);
	exit(EXIT_FAILURE);
    }

    write_all(fd, buf, buf_size, filename);

    close(fd);

    return;
}


int
main(int argc, char *argv[])
{
    time_t seed = time(NULL);

    fprintf(stdout, "INFO: Using seed 0x%" PRIx64 " \n", (uint64_t) seed);

    srand48(seed);

    allocate_memory();
    init_test_memory();

    if (TEST_MEMORY_WORDS > 1) {
	test_memory[0] = seed >> 32;
	test_memory[1] = seed;
    } else {
	test_memory[0] = seed;
    }

    write_file(TEST_MEMORY_FILENAME, (char *) test_memory, TEST_MEMORY_SIZE);

    shuffle_memory(test_memory);

    write_file(EXPECTED_MEMORY_FILENAME, (char *) test_memory, TEST_MEMORY_SIZE);

    return 0;
}
