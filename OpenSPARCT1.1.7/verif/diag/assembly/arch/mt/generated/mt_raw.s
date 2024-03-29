/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: mt_raw.s
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
/***********************************************************************
 *  Description:
 *  boundary cases for add instruction	
 *
 **********************************************************************/



#define THREAD_COUNT	4
		

#define USER_PAGE_CUSTOM_MAP
#define USER_TEXT_MT_MAP
#define USER_DATA_MT_MAP

#include "boot.s"

#define THREAD_0_DIAG arch/cache_buf/Dcache_war.s
#define THREAD_1_DIAG arch/cache_buf/Dcache_realraw.s
#define THREAD_2_DIAG arch/cache_buf/Dcache_partialraw.s
#define THREAD_3_DIAG arch/cache_buf/Dcache_falseraw.s


#include "mt_template_1_body.s"	
