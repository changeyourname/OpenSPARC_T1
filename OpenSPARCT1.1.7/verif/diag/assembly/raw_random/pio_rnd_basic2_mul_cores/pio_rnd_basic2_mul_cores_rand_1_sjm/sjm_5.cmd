# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: sjm_5.cmd
# Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
# 
# The above named program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License version 2 as published by the Free Software Foundation.
# 
# The above named program is distributed in the hope that it will be 
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public
# License along with this work; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
# 
# ========== Copyright Header End ============================================
CONFIG id=30 iosyncadr=0x7EF00BEEF00
TIMEOUT 10000000
IOSYNC
#==================================================
#==================================================

WRITEBLKIO  0x0000060fb2aebc00 +
        0x11d11010 0xcc2f6dc3 0x70e8b4da 0xbc2ecbec +
        0x8b3c185f 0xe6ac3823 0x42c16adb 0xe8355af9 +
        0x1c3b8656 0xda732e60 0xd051ce4d 0x5a495bef +
        0x3d3a295c 0x5ba668c9 0x3dde3aa0 0x37bf1423 

WRITEBLKIO  0x00000610bab58880 +
        0x6d08946d 0x21adbe9c 0x5a268f7e 0x77b4bfcb +
        0xee6b5166 0x83faf824 0x4610d41a 0xdf8e3058 +
        0xdb0eff85 0xc5d5915d 0xdae33c48 0x3544a9d3 +
        0xd6d60f52 0x47867f37 0xc270eb3e 0x2749b852 

WRITEBLK  0x00000003983a3000 +
        0xc4f10ecc 0x9af846ca 0xa0e7b813 0x3cba7311 +
        0x872495e5 0xa298db96 0x158490be 0xe50442cd +
        0xc09b7e19 0x6a46a0f7 0x207c5efd 0x4dfe9168 +
        0x51aca425 0x33b1de2e 0xd305b417 0x869620d3 

READBLK  0x00000003983a3000 +
        0xc4f10ecc 0x9af846ca 0xa0e7b813 0x3cba7311 +
        0x872495e5 0xa298db96 0x158490be 0xe50442cd +
        0xc09b7e19 0x6a46a0f7 0x207c5efd 0x4dfe9168 +
        0x51aca425 0x33b1de2e 0xd305b417 0x869620d3 

WRITEIO  0x000006062d082680 8 0x22dd3461 0x550cae0e 

WRITEBLKIO  0x0000061697eb5b40 +
        0x8e5db77d 0x7b992ba5 0x5b8b43b0 0x330e9eb9 +
        0x2f8cdade 0xff8e310a 0xaaaa62df 0x3fe70b42 +
        0x3af194d0 0xde01841f 0x2347aecb 0x7d834cc6 +
        0xd0dc493a 0x3ce00f07 0xebc24a7c 0xaa94576a 

WRITEBLKIO  0x00000617ecf98e00 +
        0x7c0873bc 0x46e07407 0xc01bfbbe 0xb9567c75 +
        0xb643b415 0xa772a0fb 0x995a6d59 0x7d413623 +
        0xee562011 0xbf65d720 0x7b7c980d 0x46189fca +
        0x6ce5e455 0xf61137f6 0x98308301 0x6941b74d 

READBLKIO  0x0000060fb2aebc00 +
        0x11d11010 0xcc2f6dc3 0x70e8b4da 0xbc2ecbec +
        0x8b3c185f 0xe6ac3823 0x42c16adb 0xe8355af9 +
        0x1c3b8656 0xda732e60 0xd051ce4d 0x5a495bef +
        0x3d3a295c 0x5ba668c9 0x3dde3aa0 0x37bf1423 

READIO  0x000006062d082680 8 0x22dd3461 0x550cae0e 
WRITEMSKIO  0x00000619b8404600 0xfff0  0x8a503e98 0xf8f723a8 0xcf24727c 0x00000000 

WRITEMSKIO  0x0000061d88c2c680 0xf00f  0xde8e3cdb 0x00000000 0x00000000 0xc09d2506 

WRITEBLKIO  0x00000616b51cc300 +
        0xab90d697 0xca3b3536 0x68ddc490 0xf181c562 +
        0x5f2e9311 0x2a4dafad 0x7d30dc90 0x8e9fda9c +
        0x818df504 0x7f2a21cd 0xb06d7012 0x79c9d866 +
        0x73106fcd 0x2a6b76b8 0xec991a79 0x8f9c1e19 

READBLKIO  0x00000610bab58880 +
        0x6d08946d 0x21adbe9c 0x5a268f7e 0x77b4bfcb +
        0xee6b5166 0x83faf824 0x4610d41a 0xdf8e3058 +
        0xdb0eff85 0xc5d5915d 0xdae33c48 0x3544a9d3 +
        0xd6d60f52 0x47867f37 0xc270eb3e 0x2749b852 

WRITEBLK  0x0000001b8b3ce140 +
        0x305c595d 0x9cf50a58 0x6ce026ab 0xe1e852c8 +
        0xd17c600f 0xf9f8bdfd 0x1051db01 0x981514c6 +
        0x70106c2d 0xc55df244 0x5cad05a5 0x9a38f003 +
        0x6685762c 0xcfb78020 0xffc5a1f7 0x4fded1f5 

READBLKIO  0x0000061697eb5b40 +
        0x8e5db77d 0x7b992ba5 0x5b8b43b0 0x330e9eb9 +
        0x2f8cdade 0xff8e310a 0xaaaa62df 0x3fe70b42 +
        0x3af194d0 0xde01841f 0x2347aecb 0x7d834cc6 +
        0xd0dc493a 0x3ce00f07 0xebc24a7c 0xaa94576a 

WRITEBLKIO  0x000006195cf14980 +
        0xf87e510d 0x5c3352ea 0xa61ae338 0x1425a75c +
        0xc127f982 0x62b960d7 0x1e97b008 0xece22b9c +
        0x4ef2d189 0xb8c1e5be 0x453afc9b 0x2694b379 +
        0x822192e9 0x59420f67 0xf9ee1a52 0xe68967e4 

READBLK  0x0000001b8b3ce140 +
        0x305c595d 0x9cf50a58 0x6ce026ab 0xe1e852c8 +
        0xd17c600f 0xf9f8bdfd 0x1051db01 0x981514c6 +
        0x70106c2d 0xc55df244 0x5cad05a5 0x9a38f003 +
        0x6685762c 0xcfb78020 0xffc5a1f7 0x4fded1f5 

WRITEIO  0x00000611b3e72380 8 0x971306e7 0x6b250ce4 

WRITEMSKIO  0x0000061aad276780 0xf0f0  0x9005cd48 0x00000000 0x28178ba3 0x00000000 

WRITEMSKIO  0x000006014a321040 0xf0ff  0x9ead2918 0x00000000 0x270ed587 0x9a4d731e 

WRITEBLK  0x00000016b7143980 +
        0xcd8b473b 0xcd94c099 0xce8f43fe 0x72a1a742 +
        0x17440e01 0xb2371e42 0xf728ee79 0xf6ab3f56 +
        0xb8c1cb50 0x49cc01f9 0xfdff7742 0xb6c5c399 +
        0xb2d226a3 0x4c69c14a 0x5d185e2d 0x133368cd 

READBLK  0x00000016b7143980 +
        0xcd8b473b 0xcd94c099 0xce8f43fe 0x72a1a742 +
        0x17440e01 0xb2371e42 0xf728ee79 0xf6ab3f56 +
        0xb8c1cb50 0x49cc01f9 0xfdff7742 0xb6c5c399 +
        0xb2d226a3 0x4c69c14a 0x5d185e2d 0x133368cd 

WRITEMSKIO  0x00000603e0da0e80 0xf000  0x3e27218c 0x00000000 0x00000000 0x00000000 

READMSKIO   0x00000619b8404600 0xfff0  0x8a503e98 0xf8f723a8 0xcf24727c 0x00000000 

READMSKIO   0x0000061d88c2c680 0xf00f  0xde8e3cdb 0x00000000 0x00000000 0xc09d2506 

READBLKIO  0x00000617ecf98e00 +
        0x7c0873bc 0x46e07407 0xc01bfbbe 0xb9567c75 +
        0xb643b415 0xa772a0fb 0x995a6d59 0x7d413623 +
        0xee562011 0xbf65d720 0x7b7c980d 0x46189fca +
        0x6ce5e455 0xf61137f6 0x98308301 0x6941b74d 

WRITEMSKIO  0x0000061c52d92080 0xf000  0x8f8a1262 0x00000000 0x00000000 0x00000000 

READMSKIO   0x0000061aad276780 0xf0f0  0x9005cd48 0x00000000 0x28178ba3 0x00000000 

WRITEBLKIO  0x00000604ab1d43c0 +
        0x5b444724 0x13cf9481 0x128761aa 0x0905cb07 +
        0xf5740f9d 0x61c517bb 0xa308f411 0x30b2d3dd +
        0x99889052 0xbc8590fa 0x54a60304 0x6cbdbfbe +
        0x9749ba96 0x10053fcc 0x9354f89f 0xb1f26e33 

READMSKIO   0x000006014a321040 0xf0ff  0x9ead2918 0x00000000 0x270ed587 0x9a4d731e 

WRITEIO  0x0000060dd335fd00 8 0xc2bee4e2 0x396081b5 

READMSKIO   0x00000603e0da0e80 0xf000  0x3e27218c 0x00000000 0x00000000 0x00000000 
