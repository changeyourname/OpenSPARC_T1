#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>

#include <sys/fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <linux/fs.h>

#include <errno.h>


/*
 * This file has to be compiled and run on a (Ubuntu) Linux system.
 * The faq docs/t1_fpga_ubuntu_gutsy_faq.txt has more information
 * on this utility.
 */


#define SECTOR_SIZE  512

int
get_file_sectors(char *filename, unsigned int *sectors, int *max_count)
{
    int fd;
    struct stat statbuf;
    size_t filesize;
    size_t blk_size;
    size_t n_blks;

    int nsectors_per_blk;
    int n_sectors;
    int sector_count;
    int blk_count;
    unsigned int blk;

    int i;

    
    fd = open(filename, O_RDONLY);
    if (fd < 0) {
        fprintf(stderr, "ERROR: open failed on file \"%s\". error string \"%s\" \n", filename, strerror(errno));
	return -1;
    }
    if (fstat (fd, &statbuf) < 0) {
        fprintf(stderr, "ERROR: fstat failed on file \"%s\". error string \"%s\" \n", filename, strerror(errno));
	close(fd);
	return -1;
    }

    filesize = statbuf.st_size;

    blk_size = 0;
    if (ioctl(fd, FIGETBSZ, &blk_size) < 0) {
        fprintf(stderr, "ERROR: ioctl cmd FIGETBSZ failed on file \"%s\". error string  \"%s\" \n", filename, strerror(errno));
	close(fd);
	return -1;
    }

    filesize += (blk_size - 1);
    filesize &= (~(blk_size - 1));

    nsectors_per_blk = blk_size / SECTOR_SIZE;

    if (*max_count < (filesize / SECTOR_SIZE)) {
        fprintf(stderr, "ERROR: get_file_sectors(): input buffer size %d < required size %d \n", *max_count, (filesize / SECTOR_SIZE));
	close(fd);
        return -1;
    }

    *max_count = 0;

    sector_count = 0;
    blk_count = 0;
    n_blks = filesize / blk_size;
    while (n_blks > 0) {
	blk = blk_count;
	if (ioctl(fd, FIBMAP, &blk) < 0) {
	    fprintf(stderr, "ERROR: ioctl cmd FIBMAP failed on file \"%s\". error string  \"%s\" \n", filename, strerror(errno));
	    return -1;
        }
	if (!blk) {
	    fprintf(stderr, "ERROR: ioctl cmd FIBMAP failed on file \"%s\". blk number %d \n", blk_count);
	    return -1;
	}
	for (i = 0; i<nsectors_per_blk; i++) {
	    sectors[sector_count++] = (blk * nsectors_per_blk) + i;
        }
	n_blks--;
	blk_count++;
    }

    *max_count = sector_count;

    close(fd);

    return 0;
}

int
main(int argc, char *argv[])
{
    int fd;
    char *first_filename = argv[1];
    char *second_filename = argv[2];

    unsigned int blks[1024];

    int filesize;
    int i;

    caddr_t file_buf;
    unsigned int *ptr;

    struct stat statbuf;
    int read_only = 0;

    int n_sectors;

    if ((argc < 3) || (argc > 4)) {
        printf("Usage: update_first_second  first_b_filename second_b_filename \n");
	exit(1);
    }

    if (argc == 4) {
        read_only = 1;
    }

    n_sectors = 1024;
    if (get_file_sectors(second_filename, blks, &n_sectors) < 0) {
        fprintf(stderr, "ERROR: get_file_sectors() failed \n");
	exit(1);
    }

    if (read_only) {
	printf("%s : sector numbers: \n", second_filename);
	for (i=0; i<n_sectors; i++) {
	    printf("%d -> 0x%x \n", i, blks[i]);
	}
    }


    fd = open(second_filename, O_RDWR);
    if (fd < 0) {
        fprintf(stderr, "ERROR: Couldn't open file \"%s\". error string \"%s\" \n", second_filename, strerror(errno));
	exit(1);
    }
    if (fstat(fd, &statbuf) < 0) {
        fprintf(stderr, "ERROR: fstat failed on file \"%s\". error string \"%s\" \n", second_filename, strerror(errno));
	exit(1);
    }
    filesize = statbuf.st_size;
    file_buf = mmap(NULL, filesize, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if (file_buf == (caddr_t ) MAP_FAILED) {
        fprintf(stderr, "ERROR: mmap failed on file \"%s\". error string \"%s\" \n", second_filename, strerror(errno));
	exit(1);
    }
    ptr = (unsigned int *) file_buf;
    if (read_only) {
        printf("%s: current sector numbers: \n", second_filename);
	for (i=0; i<n_sectors; i++) {
	    printf("%d -> 0x%x \n", i, ptr[i]);
	}
    } else {
        printf("%s: overwriting current sector numbers \n", second_filename);
	for (i=0; i<n_sectors; i++) {
	    ptr[i] = blks[i];
	}
    }
    munmap(file_buf, filesize);
    close(fd);





    fd = open(first_filename, O_RDWR);
    if (fd < 0) {
        fprintf(stderr, "ERROR: Couldn't open file \"%s\". error string \"%s\" \n", first_filename, strerror(errno));
	exit(1);
    }
    if (fstat(fd, &statbuf) < 0) {
        fprintf(stderr, "ERROR: fstat failed on file \"%s\". error string \"%s\" \n", first_filename, strerror(errno));
	exit(1);
    }
    filesize = statbuf.st_size;
    file_buf = mmap(NULL, filesize, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if (file_buf == (caddr_t) MAP_FAILED) {
        fprintf(stderr, "ERROR: mmap failed on file \"%s\". error string \"%s\" \n", first_filename, strerror(errno));
	exit(1);
    }
    ptr = (unsigned int *) (file_buf + 0x1fc);
    if (read_only) {
        printf("%s: second sector number: 0x%x 0x%p 0x%p \n", first_filename, *ptr, file_buf, ptr);
    } else {
        printf("%s: overwriting second sector number with 0x%x \n", first_filename, blks[0]);
	*ptr = blks[0];
    }
    munmap(file_buf, filesize);
    close(fd);



    return 0;
}

