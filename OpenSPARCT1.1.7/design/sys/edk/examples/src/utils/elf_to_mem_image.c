/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: elf_to_mem_image.c
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
#include <sys/stat.h>

#include <inttypes.h>

#include <unistd.h>
#include <fcntl.h>


#include <libelf.h>


/*
 * Notes:
 *
 * 1) The input is assumed to be a static ELF executable.
 *
 * 2) Only 64-bit executable files are processed.
 *
 * 3) The output memory image file is rounded up to 1MB boundary so
 *    that small change in executable program size doesn't always require
 *    a corresponding change in memory pre-initialization code in firmware.
 */



#define MEM_IMAGE_EXT_NAME  ".mem.image"


#define COPY_BUF_SIZE   8192
#define ZERO_BUF_SIZE   8192


static int verbose_flag = 0;

/*
 * Always reads "nbyte" bytes unless end of file encountered.
 */

static ssize_t
read_all(int ifd, char *buf, size_t nbyte, const char *filename)
{
    size_t   rem_bytes, bytes_read;
    ssize_t  read_result;

    bytes_read = 0;
    rem_bytes  = nbyte;

    while (rem_bytes) {
	read_result = read(ifd, &buf[bytes_read], rem_bytes);
	if (read_result < 0) {
	    perror("ERROR: read ");
	    fprintf(stderr, "ERROR: Couldn't read file \"%s\" \n", filename);
	    exit(EXIT_FAILURE);
	}
	if (read_result == 0) {
	    return bytes_read;
	}

	rem_bytes  -= read_result;
	bytes_read += read_result;
    }

    return bytes_read;
}


/*
 * Always writes "nbyte" bytes.
 */

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



/*
 * Notes:
 *
 * 1) Not depending on filesystem behavior of zero filling holes in a file.
 *
 */

static void
roundup_file_to_megabyte_boundary(int ofd, size_t file_size, const char *filename)
{
    char    *zero_buf;
    size_t   nwrite;

    size_t zero_data_size = (0x100000 - (file_size & 0xfffff));

    if (verbose_flag) {
	fprintf(stdout, "INFO: mem_image file padding size 0x%" PRIx64 " \n", (uint64_t) zero_data_size);
    }

    zero_buf = calloc(ZERO_BUF_SIZE, sizeof(*zero_buf));
    if (zero_buf == NULL) {
	fprintf(stderr, "ERROR: zero_buf calloc returned NULL \n");
	exit(EXIT_FAILURE);
    }

    while (zero_data_size) {
	if (zero_data_size > ZERO_BUF_SIZE) {
	    nwrite = ZERO_BUF_SIZE;
	} else {
	    nwrite = zero_data_size;
	}
	write_all(ofd, zero_buf, nwrite, filename);
	zero_data_size -= nwrite;
    }

    return;
}

static size_t
get_file_size(const char *filename)
{
    struct stat stat_buf;

    if (stat(filename, &stat_buf) < 0) {
	perror("ERROR: stat");
	fprintf(stderr, "ERROR: Couldn't stat file \"%s\" \n", filename);
	exit(EXIT_FAILURE);
    }

    return stat_buf.st_size;
}


int
main(int argc, char *argv[])
{
    int      ifd, ofd;
    ssize_t  nread, nbyte;
    off_t    lseek_result;

    char   *copy_buf;
    char   *filename;
    char   *mem_filename;
    size_t  mem_filename_len;

    Elf        *elf;
    Elf64_Phdr *phdr_table;
    Elf64_Phdr *phdr;
    Elf64_Ehdr *ehdr;

    char   *ident;
    size_t  ident_size;
    int     first_entry;


    uint64_t  mem_image_start_vaddr;
    uint64_t  mem_image_file_size, expected_file_size, file_size;
    uint64_t  p_vaddr, p_filesz, p_memsz, p_offset, p_align, p_type;
    uint64_t  copy_nbyte;

    off_t    mem_image_file_offset;





    if (argc != 2) {
	fprintf(stderr, "usage: %s 64-bit_elf_filename \n", argv[0]);
	exit(EXIT_FAILURE);
    }



    filename = argv[1];

    mem_filename_len = strlen(filename) + strlen(MEM_IMAGE_EXT_NAME) + 1;
    mem_filename     = calloc(mem_filename_len, sizeof(*mem_filename));
    if (mem_filename == NULL) {
	fprintf(stderr, "ERROR: calloc returned NULL \n");
	exit(EXIT_FAILURE);
    }

    strcpy(mem_filename, filename);
    strcat(mem_filename, MEM_IMAGE_EXT_NAME);




    ifd = open(filename, O_RDONLY);
    if (ifd < 0) {
       perror("ERROR: open");
       fprintf(stderr, "ERROR: Couldn't open file \"%s\" for reading \n", filename);
       exit(EXIT_FAILURE);
    }

    if (elf_version(EV_CURRENT) == EV_NONE) {
	fprintf(stderr, "ERROR: elf library version is out of date. Requested version 0x%x \n", EV_CURRENT);
	exit(EXIT_FAILURE);
    }
    if ((elf = elf_begin(ifd, ELF_C_READ, NULL)) == NULL) {
	fprintf(stderr, "ERROR: elf_begin failed. \n");
	exit(EXIT_FAILURE);
    }


    ident_size = 0;
    ident = elf_getident(elf, &ident_size);
    if (ident == NULL) {
	fprintf(stderr, "ERROR: elf_getident failed. \n");
	exit(EXIT_FAILURE);
    }
    if (ident_size < EI_NIDENT) {
	fprintf(stderr, "ERROR: elf_getident returned 0x%" PRIx64 " bytes instead of %d bytes. \n", (uint64_t)ident_size, EI_NIDENT);
	exit(EXIT_FAILURE);
    }
    if (ident[EI_CLASS] != ELFCLASS64) {
	fprintf(stderr, "ERROR: file \"%s\" is not a 64-bit executable \n", filename);
	exit(EXIT_FAILURE);
    }


    ehdr = elf64_getehdr(elf);
    if (ehdr == NULL) {
	fprintf(stderr, "ERROR: elf64_getehdr failed. \n");
	exit(EXIT_FAILURE);
    }

    phdr_table = elf64_getphdr(elf);
    if (ehdr == NULL) {
	fprintf(stderr, "ERROR: elf64_getphdr failed. \n");
	exit(EXIT_FAILURE);
    }


    copy_buf = calloc(COPY_BUF_SIZE, sizeof(*copy_buf));
    if (copy_buf == NULL) {
	fprintf(stderr, "ERROR: copy_buf calloc returned NULL \n");
	exit(EXIT_FAILURE);
    }



    ofd = open(mem_filename, O_RDWR|O_TRUNC|O_CREAT, 0666);
    if (ofd < 0) {
	perror("ERROR: open ");
	fprintf(stderr, "ERROR: Couldn't open file \"%s\" for writing \n", mem_filename);
	exit(EXIT_FAILURE);
    }



    first_entry = 1;

    for (int i=0; i<ehdr->e_phnum; i++) {

	phdr = phdr_table + i;

	p_vaddr  = phdr->p_vaddr;
	p_filesz = phdr->p_filesz;
	p_memsz  = phdr->p_memsz;
	p_offset = phdr->p_offset;
	p_align  = phdr->p_align;
	p_type   = phdr->p_type;

	if (p_type != PT_LOAD) {
	    continue;
	}

	if (first_entry) {
	    first_entry = 0;
	    mem_image_start_vaddr  = p_vaddr;
	    if (verbose_flag) {
		fprintf(stdout, "INFO: mem_image_start_vaddr 0x%" PRIx64 " \n\n", mem_image_start_vaddr);
	    }
	}

        if (verbose_flag) {
	    fprintf(stdout, "INFO: p_vaddr  0x%" PRIx64 " p_filesz 0x%" PRIx64 " p_memsz 0x%" PRIx64 " "
	                    "p_offset 0x%" PRIx64 " p_align 0x%" PRIx64 " \n\n", p_vaddr, p_filesz, p_memsz, p_offset, p_align);
	}


	mem_image_file_offset = p_vaddr - mem_image_start_vaddr;
	mem_image_file_size   = mem_image_file_offset + p_memsz;

        if (verbose_flag) {
	    fprintf(stdout, "INFO: copying p_filesz 0x%" PRIx64 " bytes from p_offset 0x%" PRIx64 " "
			    "to mem_image_file_offset 0x%" PRIx64 " at p_vaddr 0x%" PRIx64 " \n\n",
			    p_filesz, p_offset, (uint64_t) mem_image_file_offset, p_vaddr);
	    fprintf(stdout, "\nINFO: mem_image_file_size 0x%" PRIx64 " \n", mem_image_file_size);
	}

	lseek_result = lseek(ifd, p_offset, SEEK_SET);
	if (lseek_result == (off_t) -1) {
	    perror("ERROR: lseek ifd");
	    fprintf(stderr, "ERROR: lseek failed trying to set file pointer to 0x%" PRIx64 " \n", p_offset);
	    exit(EXIT_FAILURE);
	}

	lseek_result = lseek(ofd, mem_image_file_offset, SEEK_SET);
	if (lseek_result == (off_t) -1) {
	    perror("ERROR: lseek ofd");
	    fprintf(stderr, "ERROR: lseek failed trying to set file pointer to 0x%" PRIx64 " \n", (uint64_t)mem_image_file_offset);
	    exit(EXIT_FAILURE);
	}

        copy_nbyte = p_filesz;
        while (copy_nbyte > 0) {
	    if (copy_nbyte > COPY_BUF_SIZE) {
		nbyte = COPY_BUF_SIZE;
	    } else {
		nbyte = copy_nbyte;
	    }
	    nread = read_all(ifd, copy_buf, nbyte, filename);
	    if (nread == 0) {
		break;
	    }
	    write_all(ofd, copy_buf, nread, mem_filename);
	    copy_nbyte -= nread;
	}

	if (p_memsz - p_filesz) {
	    size_t  zero_fill_size, nbyte;

	    memset(copy_buf, 0, COPY_BUF_SIZE);

	    /* Not depending on filesystem behavior of zero filling holes in a file. */

	    zero_fill_size = p_memsz - p_filesz;
	    while (zero_fill_size) {
		if (zero_fill_size > COPY_BUF_SIZE) {
		   nbyte = COPY_BUF_SIZE; 
		} else {
		   nbyte = zero_fill_size; 
		}
		write_all(ofd, copy_buf, nbyte, mem_filename);
		zero_fill_size -= nbyte;
	    }
	}
    }

    roundup_file_to_megabyte_boundary(ofd, mem_image_file_size, mem_filename);

    close(ifd);
    close(ofd);

    expected_file_size = (mem_image_file_size + 0xfffff) & ~0xfffff;
    file_size = get_file_size(mem_filename);
    if (file_size != expected_file_size) {
	fprintf(stderr, "ERROR: %s: file_size 0x%" PRIx64 " != expected_file_size 0x%" PRIx64 " \n", 
				mem_filename, file_size, expected_file_size);
	fprintf(stderr, "ERROR: Removing the file \"%s\" \n", mem_filename);
	unlink(mem_filename);
	exit(EXIT_FAILURE);
    }

    return 0;
}


