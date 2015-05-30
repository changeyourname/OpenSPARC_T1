/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: file2array.c
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
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <sys/stat.h>
#include <libgen.h>
#include <ctype.h>




/*
 * Notes:
 *
 * 1) This utility is used for generating data files for l2_emul_test.
 *
 * 2) The type of the elements of the arrays is assumed to be uint32_t.
 *
 * 3) The array alignment is set to the maximum allowable value of 128.
 *
 */


#define ARRAY_ELEM_SIZE    sizeof(uint32_t)

#define MAX_N_FILES 100
static char *filenames[MAX_N_FILES];

#define BUF_SIZE 8192
static char buf[BUF_SIZE];


static uint32_t *words;



static void
remove_spec_chars(char *filename)
{
    int c = 0;

    while ((c = *filename)) {
	if ( !(isalnum(c) || (c == '_') || (c == '-')) ) {
	    *filename = '_';
	}
	filename++;
    }

    return;
}


/*
 * Notes: 
 *    1) Always returns a value which is a multiple of ARRAY_ELEM_SIZE
 */

static size_t
read_data(FILE *fp, char *buf, size_t buf_size, char *filepath)
{
    size_t  bytes_read;
    size_t  rem_bytes;

    if (buf_size & (ARRAY_ELEM_SIZE - 1)) {
	fprintf(stderr, "ERROR: buf_size 0x%" PRIx64 " must be a multiple of %d \n", (uint64_t) buf_size, ARRAY_ELEM_SIZE);
	exit(EXIT_FAILURE);
    }

    bytes_read = fread(buf, 1, buf_size, fp);
    if (bytes_read != buf_size) {
	if (ferror(fp)) {
	    perror("ERROR: fread");
	    fprintf(stderr, "ERROR: encountered error reading file \"%s\" \n", filepath);
	    exit(EXIT_FAILURE);
	}

	if (bytes_read == 0) {
	    return 0;
	}
    }

    /* If the input file size is not a multiple of ARRAY_ELEM_SIZE, zero out the remaining bytes */

    if (bytes_read & (ARRAY_ELEM_SIZE - 1)) {
	rem_bytes = ARRAY_ELEM_SIZE - (bytes_read & (ARRAY_ELEM_SIZE - 1));
	for (int i=0; i<rem_bytes; i++) {
	    buf[bytes_read + i] = 0;
	    bytes_read++;
	}
    }

    return bytes_read;
}


static void
print_file(char *filepath)
{
    FILE *fp;

    char *filename;
    char *no_spec_chars_filename;

    size_t bytes_read;

    long  word_count, num_words;
    


    fp = fopen(filepath, "r");
    if (fp == NULL) {
	fprintf(stderr, "ERROR: couldn't open file \"%s\" for reading. \n", filepath);
	exit(EXIT_FAILURE);
    }

    filename = basename(filepath);
    no_spec_chars_filename = strdup(filename);
    if (no_spec_chars_filename == NULL) {
	fprintf(stderr, "strdup returned NULL for \"%s\" \n", filename);
	exit(EXIT_FAILURE);
    }

    remove_spec_chars(no_spec_chars_filename);


    fprintf(stdout, "#pragma align 128 (%s) \n\n", no_spec_chars_filename);

    fprintf(stdout, "Elem %s[TEST_MEMORY_WORDS] = { \n", no_spec_chars_filename);

    word_count = 0;
    words = (uint32_t *) buf;
    for (;;) {
	bytes_read = read_data(fp, buf, BUF_SIZE, filepath);
	if (bytes_read == 0) {
	    break;
	}

	num_words = bytes_read / ARRAY_ELEM_SIZE;
	for (int i=0; i<num_words; i++) {
	    if ((word_count > 0) && ((word_count % 4) == 0)) {
		printf(",\n    ");
	    } else if (word_count == 0) {
		printf("    ");
	    } else {
		printf(", ");
	    }
	    printf("0x%08x", words[i]);
	    word_count++;
	}
    }
    printf("\n};\n\n\n\n");

    return;
}



int
main(int argc, char *argv[])
{
    char *filepath;
    int   file_count;

    if (argc < 2) {
	fprintf(stderr, "usage: %s filename [ filename ] .... \n", argv[0]);
	exit(EXIT_FAILURE);
    }

    if (argc > (MAX_N_FILES + 1)) {
	fprintf(stderr, "ERROR: Number of files specified %d is more than the allowed maximum %d \n", argc - 1, MAX_N_FILES);
	exit(EXIT_FAILURE);
    }

    if (sizeof(*words) != ARRAY_ELEM_SIZE) {
	fprintf(stderr, "ERROR: sizeof(*words) != ARRAY_ELEM_SIZE \n");
	exit(EXIT_FAILURE);
    }

    file_count = 0;
    for (int i=1; i<argc; i++) {
	filepath = strdup(argv[i]);
	if (filepath == NULL) {
	    fprintf(stderr, "strdup returned NULL for \"%s\" \n", argv[i]);
	    exit(EXIT_FAILURE);
	}
	filenames[file_count] = filepath;
	file_count++;
    }

    fprintf(stdout, "/* This is an auto-generated file */ \n\n");
    fprintf(stdout, "#include <sys/types.h>\n");
    fprintf(stdout, "\n");
    fprintf(stdout, "#include \"shuffle_memory.h\"\n");
    fprintf(stdout, "#include \"data.h\"\n");
    fprintf(stdout, "\n\n\n");
    fprintf(stdout, "/* Notes: \n");
    fprintf(stdout, " *        The seed used to generate the initial random values in \n");
    fprintf(stdout, " *        test_memory is stored in the first 8 bytes of test_memory \n");
    fprintf(stdout, " */\n");
    fprintf(stdout, "\n\n\n");

    for (int i=0; i<file_count; i++) {
	print_file(filenames[i]);
    }

    return 0;
}
