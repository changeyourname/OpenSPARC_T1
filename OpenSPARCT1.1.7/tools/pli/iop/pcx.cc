// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: pcx.cc
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
#include "pcx.h"
/*------------------------------------------
  constructor.
--------------------------------------------*/
pcx::pcx(int* p)
{
  wait = random() & 0x7;
  for(idx = 0; idx < 4;idx++)pkt[idx] = p[idx];
}
/*------------------------------------------
  clean paket.
--------------------------------------------*/
void pcx::clean()
{
  for(idx = 0; idx < 4;idx++)pkt[idx] = 0;
  io_wait = 0;
  dev     = 0;
}
/*------------------------------------------
  clean paket.
--------------------------------------------*/
void pcx::set_dev()
{
  int up_half = up & 0xff0;
  aval = 0;
  if(up == 0xfff)dev = 0;//boot root
  else if(up == 0x970)dev = 1;//dram control register
  else if(up == 0x980){//iob address
    dev = 3;//iob intr
    if((low != 0x830) && (low != 0x810) && (low & 0x800))dev = 4;
    if(low == 0x830)aval = 1;
  }
  else if((up_half >= 0x800) && (up_half <= 0xfe0)){
    dev = 2;
  }
  else dev = 10;//out of range 
}
/*------------------------------------------
PCX: vld[123]
     rq[122:118]
     nc[117]
     cpu[116:114]
     thread[113:112]
     size[106:104]
     pa_10_6[75:70]
     addr[103:64]
     pcx[123:96], pcx[95:64], pcx[63:32], pcx[31:0]    
-------------------------------------------*/
void pcx::chop_pkt(int* pcx_pkt, int avail)
{
  char str[10];
  io_wait   = 0;
  rqtype    = (pcx_pkt[0] >> 22) & 0x1f;
  nc        = (pcx_pkt[0] >> 21) & 0x1;
  cpu_id    = (pcx_pkt[0] >> 18) & 0x7;
  thrid     = (pcx_pkt[0] >> 16) & 0x3;  
  bf_id     = (pcx_pkt[0] >> 13) & 0x7;
  way       = (pcx_pkt[0] >> 11) & 0x3;
  size      = (pcx_pkt[0] >> 8)  & 0x7;
  
  pa_10_6   = (pcx_pkt[1] >> 6)  & 0x3f;

  way_vld   = 1;
  addr      = (pcx_pkt[0] & 0xff);
  addr    <<= 32;
  addr     |= pcx_pkt[1];
  low       = pcx_pkt[1];//long long type addr
  mask_addr = (addr >> 6)  & 0x3ffffffff;
  up        = (addr >> 28) & 0xfff;
  //find dram channel for ucb
  dram_channel = addr & 0x1000 ? 1 : 0;
  //delay 
  wait      = 3;//random() & 0x7;
  set_dev();//recoginze device
  io_wait   = (dev == 1 || dev == 2) && (rqtype == LOAD_RQ);
  //comment for debug.
  switch(rqtype){
  case(IMISS_RQ): 
    strcpy(str, "ifill");
    break;
  case(STORE_RQ) :
    strcpy(str, "store");
    break;
  case(LOAD_RQ)  :
    strcpy(str, "load");
    break;
  default : 
    strcpy(str, "");
    break;
  }
  io_printf("(%0d):Info iob pcx %s packet -> ", tf_gettime(), str);
  for(idx = 0;idx < 4;idx++){
    pkt[idx] = pcx_pkt[idx];
    io_printf("%08x",  pkt[idx]);
  }
  io_printf("\n");
  available = aval ? avail : 0;
 }


