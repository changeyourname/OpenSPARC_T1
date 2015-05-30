/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mbfw_gunzip.c
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
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "mbfw_types.h"
#include "mbfw_config.h"
#include "mbfw_gunzip.h"

#include "zlib.h"


/*
 * Uncompress the in-memory .gz format file stored in T1_RAM_DISK
 * memory segment. The uncompressed file is temporarily stored
 * in T1_DRAM segment and copied back to T1_RAM_DISK memory segment.
 */

void
mbfw_gunzip(void)
{
    Bytef    *compr_start, *uncompr_start;
    int       compr_len,   uncompr_len;
    int       zlib_result;

    z_stream  d_stream;


    memset(&d_stream, 0, sizeof(d_stream));

    d_stream.zalloc = (alloc_func)0;
    d_stream.zfree  = (free_func)0;
    d_stream.opaque = (voidpf)0;

    compr_start   = (Bytef *) MB_T1_RAM_DISK_START;
    uncompr_start = (Bytef *) MB_T1_DRAM_START;
    /*
     * The real compressed file size could be smaller and the zlib code
     * ignores the extra bytes.
     */
    compr_len     = T1_RAM_DISK_SIZE;
    uncompr_len   = T1_DRAM_SIZE;

    d_stream.next_in   = compr_start;
    d_stream.avail_in  = compr_len;

    d_stream.next_out  = uncompr_start;
    d_stream.avail_out = uncompr_len;


    zlib_result = inflateInit2(&d_stream, 31);
    if (zlib_result != Z_OK) {
	mbfw_printf("MBFW_ERROR: mbfw_gunzip(): inflateInit2 failed %d \r\n",
								  zlib_result);
	mbfw_exit(1);
    }

    zlib_result = inflate(&d_stream, Z_NO_FLUSH);
    if ((zlib_result != Z_OK) && (zlib_result != Z_STREAM_END)) {
	mbfw_printf("MBFW_ERROR: mbfw_gunzip(): inflate failed %d \r\n",
							     zlib_result);
	mbfw_exit(1);
    }

    uncompr_len -= d_stream.avail_out;

    zlib_result = inflateEnd(&d_stream);
    if (zlib_result != Z_OK) {
	mbfw_printf("MBFW_ERROR: mbfw_gunzip(): inflateEnd failed %d \r\n",
								 zlib_result);
	mbfw_exit(1);
    }

    memmove(compr_start, uncompr_start, uncompr_len);

    return;
}
