#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

#include <sys/param.h>
#include <sys/stat.h>


#include <sys/dklabel.h>


/*
 * This utility creates and writes VTOC to the first sector of the ramdisk image.
 *
 * Usage: create_vtoc -f <ramdisk_image_file_path>
 */

/*
 * WARNING: This code doesn't compile on a Linux system. This file has to be compiled and run on a Solaris system.
 */


// 80MB 0x28000


#define C_TRUE   1
#define C_FALSE  0


typedef struct options {
    int     print_only;
    char   *disk_filename;
} Options;

Options options;

void
print_help(void)
{
    printf("Usage: create_vtoc   -f disk_image_filename       # \n");
    printf("                   [ -p ]                          # print_only. don't modify the disk image \n");
}


void
print_help_and_exit(void)
{
    print_help();
    exit(0);
}

int
process_options(int argc, char *argv[], Options *optp)
{
    int     lib_result;

    while ((lib_result = getopt(argc, argv, "f:vhp")) != -1) {
        switch (lib_result) {
            case 'f':
            {
		optp->disk_filename = strdup(optarg);
            }
            break;

            case 'p':
            {
		optp->print_only = C_TRUE;
            }
            break;

	    case 'h':
	    {
		print_help_and_exit();
		/* NOT REACHED */
	    }
            break;
        }
    }

    return 0;
}

void
options_init(Options *optp)
{
    optp->print_only = C_FALSE;
    optp->disk_filename = NULL;
}


static ssize_t
read_all(int ifd, char *buf, size_t nbyte, const char *filename)
{
    size_t   rem_bytes, bytes_read;
    ssize_t  read_result;

    bytes_read = 0;
    rem_bytes     = nbyte;

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


#define DBSIZE   512


void
print_vtoc(struct dk_vtoc *dkv_ptr)
{
    fprintf(stdout, "v_version               0x%x \n", dkv_ptr->v_version);
    fprintf(stdout, "v_volume                %s \n", dkv_ptr->v_volume);
    fprintf(stdout, "v_nparts                0x%x \n", dkv_ptr->v_nparts);
    for (int i=0; i<NDKMAP; i++) {
	fprintf(stdout, "v_part[%d]          tag 0x%x flag 0x%x \n", i, dkv_ptr->v_part[i].p_tag, dkv_ptr->v_part[i].p_flag);
    }
    for (int i=0; i<3; i++) {
	fprintf(stdout, "v_bootinfo[%d]         0x%x \n", i, dkv_ptr->v_bootinfo[i]);
    }
    fprintf(stdout, "v_sanity                 0x%x \n", dkv_ptr->v_sanity);
    for (int i=0; i<10; i++) {
	fprintf(stdout, "v_reserved[%d]         0x%x \n", i, dkv_ptr->v_reserved[i]);
    }
    for (int i=0; i<NDKMAP; i++) {
	fprintf(stdout, "v_timestamp[%d]           0x%llx \n", i, dkv_ptr->v_timestamp[i]);
    }
}

void
print_dk_label(struct dk_label *dkl_ptr)
{
    fprintf(stdout, "dkl_asciilabel          %s \n", dkl_ptr->dkl_asciilabel);
    print_vtoc(&dkl_ptr->dkl_vtoc);
    fprintf(stdout, "dkl_write_reinstruct    0x%x \n", dkl_ptr->dkl_write_reinstruct);
    fprintf(stdout, "dkl_read_reinstruct     0x%x \n", dkl_ptr->dkl_read_reinstruct);
    fprintf(stdout, "dkl_rpm                 0x%x \n", dkl_ptr->dkl_rpm);
    fprintf(stdout, "dkl_pcyl                0x%x \n", dkl_ptr->dkl_pcyl);
    fprintf(stdout, "dkl_apc                 0x%x \n", dkl_ptr->dkl_apc);
    fprintf(stdout, "dkl_obs1                0x%x \n", dkl_ptr->dkl_obs1);
    fprintf(stdout, "dkl_obs2                0x%x \n", dkl_ptr->dkl_obs2);
    fprintf(stdout, "dkl_intrlv              0x%x \n", dkl_ptr->dkl_intrlv);
    fprintf(stdout, "dkl_ncyl                0x%x \n", dkl_ptr->dkl_ncyl);
    fprintf(stdout, "dkl_acyl                0x%x \n", dkl_ptr->dkl_acyl);
    fprintf(stdout, "dkl_nhead               0x%x \n", dkl_ptr->dkl_nhead);
    fprintf(stdout, "dkl_nsect               0x%x \n", dkl_ptr->dkl_nsect);
    fprintf(stdout, "dkl_obs3                0x%x \n", dkl_ptr->dkl_obs3);
    fprintf(stdout, "dkl_obs4                0x%x \n", dkl_ptr->dkl_obs4);
    for (int i=0; i<NDKMAP; i++) {
	fprintf(stdout, "dkl_map[%d]          cylno 0x%x nblk 0x%x \n", i, dkl_ptr->dkl_map[i].dkl_cylno, dkl_ptr->dkl_map[i].dkl_nblk);
    }
    fprintf(stdout, "dkl_magic               0x%x \n", dkl_ptr->dkl_magic);
    fprintf(stdout, "dkl_cksum               0x%x \n", dkl_ptr->dkl_cksum);
}

uint_t
dk_label_checksum(struct dk_label *dkl_ptr)
{
    uint16_t    *ptr = (uint16_t *) dkl_ptr;

    uint16_t cksum = 0;
    int count = DBSIZE / sizeof(uint16_t);
    count--;

    for (int i=0; i<count; i++) {
	cksum = cksum ^ *ptr;
	ptr++;
    }

    return cksum;
}


void
print_file_dk_label(Options *optp)
{
#define DKLABEL_BUF_SIZE   (1 * DBSIZE)
    char *dk_label_buf = memalign(PAGESIZE, DKLABEL_BUF_SIZE);

    int fd = open(optp->disk_filename, O_RDONLY);
    if (fd < 0) {
	perror("ERROR: open ");
	fprintf(stderr, "ERROR: failed to open file \"%s\" for reading \n", optp->disk_filename);
	exit(EXIT_FAILURE);
    }

    read_all(fd, dk_label_buf, DKLABEL_BUF_SIZE, optp->disk_filename);

    print_dk_label((struct  dk_label *) dk_label_buf);
    dk_label_checksum((struct  dk_label *) dk_label_buf);

    close(fd);


    return;
}

void
create_vtoc(struct dk_vtoc *dkv_ptr)
{
    dkv_ptr->v_version   = 0;
    dkv_ptr->v_volume[0] = 0;
    dkv_ptr->v_nparts    = 0;

    dkv_ptr->v_part[0].p_tag  = 2;
    dkv_ptr->v_part[0].p_flag = 0;

    dkv_ptr->v_part[1].p_tag  = 0;
    dkv_ptr->v_part[1].p_flag = 1;

    dkv_ptr->v_part[2].p_tag  = 5;
    dkv_ptr->v_part[2].p_flag = 1;

    dkv_ptr->v_part[3].p_tag  = 0;
    dkv_ptr->v_part[3].p_flag = 1;

    dkv_ptr->v_part[4].p_tag  = 0;
    dkv_ptr->v_part[4].p_flag = 1;

    dkv_ptr->v_part[5].p_tag  = 0;
    dkv_ptr->v_part[5].p_flag = 1;

    dkv_ptr->v_part[6].p_tag  = 0;
    dkv_ptr->v_part[6].p_flag = 1;

    dkv_ptr->v_part[7].p_tag  = 0;
    dkv_ptr->v_part[7].p_flag = 1;

    for (int i=0; i<3; i++) {
	dkv_ptr->v_bootinfo[i] = 0;
    }
    dkv_ptr->v_sanity = 0;
    for (int i=0; i<10; i++) {
	dkv_ptr->v_reserved[i] = 0;
    }
    for (int i=0; i<NDKMAP; i++) {
	dkv_ptr->v_timestamp[i] = 0x0;
    }
}

void
create_dk_label(struct dk_label *dkl_ptr, uint64_t disk_size)
{
    memset(dkl_ptr, 0, LEN_DKL_ASCII);
    create_vtoc(&dkl_ptr->dkl_vtoc);
    dkl_ptr->dkl_write_reinstruct = 0;
    dkl_ptr->dkl_read_reinstruct  = 0;
    dkl_ptr->dkl_rpm    = 0;
    dkl_ptr->dkl_pcyl   = 0;
    dkl_ptr->dkl_apc    = 0;
    dkl_ptr->dkl_obs1   = 0;
    dkl_ptr->dkl_obs2   = 0;
    dkl_ptr->dkl_intrlv = 0;
    dkl_ptr->dkl_ncyl   = 0;
    dkl_ptr->dkl_acyl   = 0;
    dkl_ptr->dkl_nhead  = 1;
    dkl_ptr->dkl_nsect  = 1;
    dkl_ptr->dkl_obs3   = 0;
    dkl_ptr->dkl_obs4   = 0;

    dkl_ptr->dkl_map[0].dkl_cylno = 0;
    dkl_ptr->dkl_map[0].dkl_nblk  = disk_size >> 9;

    dkl_ptr->dkl_map[2].dkl_cylno = 0;
    dkl_ptr->dkl_map[2].dkl_nblk  = disk_size >> 9;

    dkl_ptr->dkl_magic = DKL_MAGIC;
    dkl_ptr->dkl_cksum =  dk_label_checksum(dkl_ptr);
}

void
create_file_dk_label(Options *optp)
{
#define DKLABEL_BUF_SIZE   (1 * DBSIZE)
    char *dk_label_buf = memalign(PAGESIZE, DKLABEL_BUF_SIZE);
    uint64_t disk_size;
    struct stat   statbuf;

    memset(dk_label_buf, 0, DKLABEL_BUF_SIZE);

    int fd = open(optp->disk_filename, O_RDWR);
    if (fd < 0) {
	perror("ERROR: open ");
	fprintf(stderr, "ERROR: failed to open file \"%s\" for reading \n", optp->disk_filename);
	exit(EXIT_FAILURE);
    }

    if (fstat(fd, &statbuf) < 0) {
	perror("ERROR: fstat ");
	fprintf(stderr, "ERROR: fstat failed on file \"%s\" \n", optp->disk_filename);
	exit(EXIT_FAILURE);
    }
    disk_size = statbuf.st_size;

    create_dk_label((struct  dk_label *) dk_label_buf, disk_size);
    write_all(fd, dk_label_buf, DKLABEL_BUF_SIZE, optp->disk_filename);

    close(fd);

    return;
}

int
main(int argc, char *argv[])
{
    options_init(&options);
    process_options(argc, argv, &options);

    if (options.disk_filename == NULL) {
	print_help();
	exit(1);
    }

    if ((int) sizeof(struct dk_label) != DBSIZE) {
	fprintf(stderr, "ERROR: sizeof(struct dk_label) %d != %d \n", sizeof(struct dk_label), DBSIZE);
	exit(1);
    }

    if (options.print_only == C_TRUE) {
	print_file_dk_label(&options);
	exit(0);
    }
    create_file_dk_label(&options);
    return 0;
}
