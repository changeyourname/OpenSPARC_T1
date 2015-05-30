# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: sjm_4.cmd
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
CONFIG id=28 iosyncadr=0x7CF00BEEF00
TIMEOUT 10000000
IOSYNC
#==================================================
#==================================================


LABEL_0:

WRITEBLK  0x00000008843bcf00 +
        0x62cf160d 0x9638ebac 0xf6d7db46 0x05d9df2d +
        0x6df1be1a 0x35ef9033 0x585c079a 0xa1d676f1 +
        0x82bc055f 0xc8d07276 0x83ae4928 0x70a1aaf9 +
        0x6bde1e96 0xdd951e3e 0x76cd1c34 0xb63945d5 

WRITEMSKIO  0x0000061459c9f240 0x0fff  0x00000000 0x735a149c 0x9c520513 0x9c4f839e 

WRITEMSKIO  0x0000060a088bf6c0 0x0fff  0x00000000 0x070cfa36 0x6918fbb6 0x79bb0ce3 

WRITEMSK  0x00000008843bcf00 0xf00ff0f000ff00ff +
        0x89822d3b 0x00000000 0x00000000 0xc79e2f4a +
        0x16cbf51f 0x00000000 0xaf45986d 0x00000000 +
        0x00000000 0x00000000 0x3411d4a9 0xedee563b +
        0x00000000 0x00000000 0xf9bc613a 0xbf8f33be 

WRITEMSK  0x00000008843bcf00 0x00000f0ffff0f00f +
        0x00000000 0x00000000 0x00000000 0x00000000 +
        0x00000000 0x99daeeda 0x00000000 0x863d4721 +
        0xef57232f 0x68cc8441 0x9b87dc13 0x00000000 +
        0x504aa2c2 0x00000000 0x00000000 0x5cb41e75 

WRITEMSKIO  0x0000060469cf65c0 0x0ff0  0x00000000 0x32edbb43 0x7362f464 0x00000000 

WRITEIO  0x0000061a7f643740 8 0x3fdfc3ed 0x2245a4cc 

READBLK  0x00000008843bcf00 +
        0x89822d3b 0x9638ebac 0xf6d7db46 0xc79e2f4a +
        0x16cbf51f 0x99daeeda 0xaf45986d 0x863d4721 +
        0xef57232f 0x68cc8441 0x9b87dc13 0xedee563b +
        0x504aa2c2 0xdd951e3e 0xf9bc613a 0x5cb41e75 

WRITEBLKIO  0x0000060b1d782ec0 +
        0x80a6692f 0x09629475 0xcd144df0 0x99f92717 +
        0xd65cfbca 0xdec09753 0xb065779b 0xf58a9e0d +
        0x5b3123aa 0xce6b5f11 0x7dbcf34c 0x7495a19b +
        0x3d7f3694 0x6254aa41 0x616e06e3 0x129eec47 

READBLKIO  0x0000060b1d782ec0 +
        0x80a6692f 0x09629475 0xcd144df0 0x99f92717 +
        0xd65cfbca 0xdec09753 0xb065779b 0xf58a9e0d +
        0x5b3123aa 0xce6b5f11 0x7dbcf34c 0x7495a19b +
        0x3d7f3694 0x6254aa41 0x616e06e3 0x129eec47 

READMSKIO   0x0000061459c9f240 0x0fff  0x00000000 0x735a149c 0x9c520513 0x9c4f839e 

READIO  0x0000061a7f643740 8 0x3fdfc3ed 0x2245a4cc 
WRITEBLK  0x0000000f480ea680 +
        0xa96ba0fd 0x98ee5aef 0x58a3142e 0x164e7f2d +
        0xd412f77e 0x6819ca36 0x354dbcdf 0xcefc2a5d +
        0x30734c09 0x49b8a925 0x6549aeb7 0xf2b76daa +
        0x739961d9 0x21a5bba3 0xcfbcdd33 0x081e8ce3 

WRITEIO  0x0000061989848740 4 0x79fd80b6 

WRITEBLKIO  0x0000060e6d0a0f00 +
        0xf44370e7 0x5db1e552 0x07b73206 0x0b9e8b26 +
        0x2c622cc1 0x064ace1d 0x8da631f2 0xdb326490 +
        0xa438e538 0x480b625b 0x768b2344 0x9ea484c8 +
        0x214dacac 0x1aa894a3 0x3511969c 0xa8e77fdf 

READBLKIO  0x0000060e6d0a0f00 +
        0xf44370e7 0x5db1e552 0x07b73206 0x0b9e8b26 +
        0x2c622cc1 0x064ace1d 0x8da631f2 0xdb326490 +
        0xa438e538 0x480b625b 0x768b2344 0x9ea484c8 +
        0x214dacac 0x1aa894a3 0x3511969c 0xa8e77fdf 

WRITEBLKIO  0x00000611f3e40c40 +
        0x9b11108b 0xc0949f65 0x9fa69763 0x0666fd20 +
        0x8db7966b 0x7857ed6a 0x90d84014 0xda24bf52 +
        0x46dd43bd 0xb9097dfc 0x876c4744 0xae002423 +
        0xf6a7226a 0x676aa3d3 0x77f12fcf 0xc3ace7ba 

WRITEIO  0x00000615fd61e780 4 0xcbe31ed9 

READMSKIO   0x0000060a088bf6c0 0x0fff  0x00000000 0x070cfa36 0x6918fbb6 0x79bb0ce3 

WRITEBLKIO  0x0000060bcee58a00 +
        0x388a4d17 0xa16fbaf0 0x8f6e8a3e 0x0789af40 +
        0x00dc1a35 0x91830ebd 0xc8a17a27 0x4721dd9c +
        0xa0adf69e 0x2d9b75fb 0x28d95649 0x225757f5 +
        0x0b8d2b33 0x5e4fc8f3 0x1986d869 0x126c75f8 

READMSKIO   0x0000060469cf65c0 0x0ff0  0x00000000 0x32edbb43 0x7362f464 0x00000000 

READIO  0x0000061989848740 4 0x79fd80b6 
WRITEIO  0x00000604e5302dc0 16 0x92445508 0x8e33fa77 0xbf5c101f 0x30a61cee 

WRITEIO  0x00000603faed3b40 4 0xee582c4f 

WRITEBLKIO  0x0000060502994880 +
        0x7d25a19e 0xf40593b9 0x58163900 0x5d664a89 +
        0x97c239e7 0xfbacf910 0xcc161bc5 0x0afca6b2 +
        0x2bcac4a8 0x759455df 0x051e13d0 0xb979ac70 +
        0x417cfcf5 0x1b4810ae 0xc64ea92e 0xac6edc59 

READIO  0x00000615fd61e780 4 0xcbe31ed9 
WRITEBLKIO  0x0000060062f2b080 +
        0x708c2b4c 0x17d3d6da 0x9b61765d 0xca19072b +
        0x521554ef 0x86f848c1 0x690e9ff3 0x421c1b8d +
        0xa33360ac 0x3c89edb8 0x54a5fbd2 0x4d28a6ff +
        0x810fbb38 0xabe60512 0x1f37cfe9 0x2add04db 

WRITEMSK  0x0000000f480ea680 0xf0f00fff000ff000 +
        0x658b5971 0x00000000 0xb07024c1 0x00000000 +
        0x00000000 0x51b469c2 0x2a72e22b 0x980914a3 +
        0x00000000 0x00000000 0x00000000 0x4260ead0 +
        0xe6b07673 0x00000000 0x00000000 0x00000000 

WRITEBLKIO  0x000006159d3a07c0 +
        0x7bcb34eb 0x388892dd 0xb1122ad8 0x03c23d14 +
        0x6a9e05bd 0x0e921930 0x4c96ecc1 0x418a5479 +
        0xe97aa56c 0xccb77243 0x5053a9d9 0xaae6a3b1 +
        0xf75b994c 0xe77d8e51 0x147c197f 0x9daf37e1 

READBLK  0x0000000f480ea680 +
        0x658b5971 0x98ee5aef 0xb07024c1 0x164e7f2d +
        0xd412f77e 0x51b469c2 0x2a72e22b 0x980914a3 +
        0x30734c09 0x49b8a925 0x6549aeb7 0x4260ead0 +
        0xe6b07673 0x21a5bba3 0xcfbcdd33 0x081e8ce3 

WRITEBLK  0x00000019b7eb4a80 +
        0xb48c857c 0x1da4ba5e 0xd5290afe 0x774a534d +
        0x03271b8c 0x72f38ea4 0xd865fb84 0x6b4d99ec +
        0xae1cb3a1 0x04f930b4 0x2faead2d 0xfdca8c30 +
        0xdf261e20 0x3f494dad 0xd77763e2 0x572493df 

READIO  0x00000604e5302dc0 16 0x92445508 0x8e33fa77 0xbf5c101f 0x30a61cee 
READIO  0x00000603faed3b40 4 0xee582c4f 
WRITEBLKIO  0x0000060eaad85640 +
        0x4a5a9b7c 0xe6b05b58 0x44e953c3 0xbad0b524 +
        0x15bb2d53 0xe90aaf61 0x0b4974cb 0x626bc794 +
        0x765a7db9 0x1de9c92a 0x582159d3 0x3bac42f2 +
        0x4bb31c82 0x79969e09 0xa503d8df 0xf6411545 

READBLKIO  0x00000611f3e40c40 +
        0x9b11108b 0xc0949f65 0x9fa69763 0x0666fd20 +
        0x8db7966b 0x7857ed6a 0x90d84014 0xda24bf52 +
        0x46dd43bd 0xb9097dfc 0x876c4744 0xae002423 +
        0xf6a7226a 0x676aa3d3 0x77f12fcf 0xc3ace7ba 

WRITEBLK  0x0000000ff76d7980 +
        0x5f62f3ef 0x6948c526 0x588b16ea 0x8c31cc71 +
        0x3ed0b0e2 0x0f963825 0x93c05c96 0xbe2334f7 +
        0x83e27105 0x2fa2b103 0x64100dc1 0xbea5aea7 +
        0x5589c61d 0xf2717adb 0xcfb59141 0x8fcd141c 

READBLK  0x00000019b7eb4a80 +
        0xb48c857c 0x1da4ba5e 0xd5290afe 0x774a534d +
        0x03271b8c 0x72f38ea4 0xd865fb84 0x6b4d99ec +
        0xae1cb3a1 0x04f930b4 0x2faead2d 0xfdca8c30 +
        0xdf261e20 0x3f494dad 0xd77763e2 0x572493df 

WRITEBLK  0x00000011c02ea680 +
        0xea5b2d67 0x59d6e1ae 0x91c1777f 0x9e90f6e3 +
        0x1f721d2d 0x279e642d 0x97388481 0x5ac6e3a4 +
        0x84e8b412 0x62b16337 0xa47b24c8 0xc451262b +
        0x55e00a85 0xf9ef1e4e 0x5b1948c4 0x47a7baaa 

WRITEBLK  0x0000001e21b47540 +
        0x329b1344 0xc109563b 0x30cdf1e9 0x4f1471ec +
        0x11f5bdb4 0xe833b80c 0xf5a3ba5f 0xdd15dad3 +
        0x7795712b 0x7aa17496 0xb6c187f9 0x37beec9a +
        0x50e1d7dd 0xe4338376 0x5a74bf89 0x28bd3808 

READBLK  0x0000000ff76d7980 +
        0x5f62f3ef 0x6948c526 0x588b16ea 0x8c31cc71 +
        0x3ed0b0e2 0x0f963825 0x93c05c96 0xbe2334f7 +
        0x83e27105 0x2fa2b103 0x64100dc1 0xbea5aea7 +
        0x5589c61d 0xf2717adb 0xcfb59141 0x8fcd141c 

READBLK  0x00000011c02ea680 +
        0xea5b2d67 0x59d6e1ae 0x91c1777f 0x9e90f6e3 +
        0x1f721d2d 0x279e642d 0x97388481 0x5ac6e3a4 +
        0x84e8b412 0x62b16337 0xa47b24c8 0xc451262b +
        0x55e00a85 0xf9ef1e4e 0x5b1948c4 0x47a7baaa 

WRITEBLKIO  0x0000061102c252c0 +
        0xe4e54252 0x2c70879f 0x0617524a 0xe29b4002 +
        0x90dff269 0x4134b3f3 0x2d5ebb20 0x7e625331 +
        0xc0671881 0x6e4d87f9 0xde98887f 0x744136a2 +
        0x628bd55f 0x6887ce39 0x233a5727 0x855bc1b1 

WRITEMSK  0x0000001e21b47540 0x00000ff0ffff00ff +
        0x00000000 0x00000000 0x00000000 0x00000000 +
        0x00000000 0xe7e57a2c 0xf8278cf4 0x00000000 +
        0xf302b516 0x89301202 0x2063a6b5 0xfb7469cf +
        0x00000000 0x00000000 0xed4195c8 0x86d30dc2 

READBLKIO  0x0000060bcee58a00 +
        0x388a4d17 0xa16fbaf0 0x8f6e8a3e 0x0789af40 +
        0x00dc1a35 0x91830ebd 0xc8a17a27 0x4721dd9c +
        0xa0adf69e 0x2d9b75fb 0x28d95649 0x225757f5 +
        0x0b8d2b33 0x5e4fc8f3 0x1986d869 0x126c75f8 

WRITEMSKIO  0x000006020c13e880 0xf00f  0x070af8af 0x00000000 0x00000000 0xa02ec15a 

WRITEBLKIO  0x0000061c5ab1d280 +
        0xa5cb5df9 0xe99a5527 0x3657ba65 0x5ed6c68b +
        0xe086677e 0xa31c9af8 0x67ce2d81 0x05cc6b22 +
        0x4dcf451f 0xe6a8e497 0xe8e84d87 0x78cd1823 +
        0x0b664709 0x33b488b4 0xca3b08a9 0xa6a676a4 

WRITEIO  0x0000060304f50400 8 0x4192a42a 0x8a8d6ab9 

WRITEMSKIO  0x000006119f487a40 0xf0ff  0xdcbd8a73 0x00000000 0x4f0959ee 0xf25abf0b 

READMSKIO   0x000006020c13e880 0xf00f  0x070af8af 0x00000000 0x00000000 0xa02ec15a 

READMSKIO   0x000006119f487a40 0xf0ff  0xdcbd8a73 0x00000000 0x4f0959ee 0xf25abf0b 

WRITEMSK  0x0000001e21b47540 0xf00f0ff000ffff00 +
        0x0bdf7d31 0x00000000 0x00000000 0x62c5b8a0 +
        0x00000000 0x7311d4bb 0x430c2491 0x00000000 +
        0x00000000 0x00000000 0x8b6feae6 0x28c777f1 +
        0xcc247230 0x182dbc68 0x00000000 0x00000000 

WRITEMSKIO  0x00000602eeb48a40 0x0fff  0x00000000 0x79bdccac 0x74e67e4d 0xf1f51251 

READIO  0x0000060304f50400 8 0x4192a42a 0x8a8d6ab9 
READBLKIO  0x0000060502994880 +
        0x7d25a19e 0xf40593b9 0x58163900 0x5d664a89 +
        0x97c239e7 0xfbacf910 0xcc161bc5 0x0afca6b2 +
        0x2bcac4a8 0x759455df 0x051e13d0 0xb979ac70 +
        0x417cfcf5 0x1b4810ae 0xc64ea92e 0xac6edc59 

READMSKIO   0x00000602eeb48a40 0x0fff  0x00000000 0x79bdccac 0x74e67e4d 0xf1f51251 

WRITEBLK  0x0000001ca69991c0 +
        0xd35f3a7d 0xb36c7a45 0x60d9f22e 0x1b02d4ef +
        0x426c1aac 0x6950a771 0xcb227a52 0x50025e5e +
        0xf49177f9 0x55bc8ad1 0xa43fa31f 0xa9fd6507 +
        0xed43d1d8 0xcff04c8e 0xd02350cf 0x90735750 

WRITEMSK  0x0000001e21b47540 0x0fff0f0ffffff000 +
        0x00000000 0x1d0da669 0x09f78d3e 0x881c0f14 +
        0x00000000 0x96dc7a95 0x00000000 0x86fcd210 +
        0x51b0f6f5 0xc490d99c 0xa1dd5005 0x6e71b89e +
        0x4adec93b 0x00000000 0x00000000 0x00000000 

READBLK  0x0000001e21b47540 +
        0x0bdf7d31 0x1d0da669 0x09f78d3e 0x881c0f14 +
        0x11f5bdb4 0x96dc7a95 0x430c2491 0x86fcd210 +
        0x51b0f6f5 0xc490d99c 0xa1dd5005 0x6e71b89e +
        0x4adec93b 0x182dbc68 0xed4195c8 0x86d30dc2 

READBLK  0x0000001ca69991c0 +
        0xd35f3a7d 0xb36c7a45 0x60d9f22e 0x1b02d4ef +
        0x426c1aac 0x6950a771 0xcb227a52 0x50025e5e +
        0xf49177f9 0x55bc8ad1 0xa43fa31f 0xa9fd6507 +
        0xed43d1d8 0xcff04c8e 0xd02350cf 0x90735750 

WRITEMSKIO  0x000006099c714300 0xff00  0x4dc14b4b 0xfdf69cb8 0x00000000 0x00000000 

READMSKIO   0x000006099c714300 0xff00  0x4dc14b4b 0xfdf69cb8 0x00000000 0x00000000 

WRITEBLKIO  0x00000616b69c9f00 +
        0xa889c3d5 0x3ee72a9c 0xc59450c8 0x2574b72b +
        0x1ebccce0 0x960dba39 0xde91bbb4 0xf5a5b3d9 +
        0x51f9e064 0x9f588d17 0xda443de5 0x64976197 +
        0x0796364a 0xf98a3efa 0xa4177f56 0x7f02b5b2 

WRITEMSKIO  0x0000061f8de9f540 0xf0f0  0x8ec393a1 0x00000000 0x41bab2fa 0x00000000 

WRITEBLK  0x00000019a40a9800 +
        0xd64a1b52 0x158a1d2e 0xa9d625d8 0x8a2f3c54 +
        0x2bfaf872 0x96de4ed4 0xb0df730b 0x483916ee +
        0xadef27fc 0xad623c6c 0x19473aaa 0x6bb07645 +
        0xb0647024 0x6c043098 0x3e6489ea 0x7e606745 

READMSKIO   0x0000061f8de9f540 0xf0f0  0x8ec393a1 0x00000000 0x41bab2fa 0x00000000 

WRITEIO  0x0000060a74aa3440 4 0xe047195b 

WRITEBLK  0x0000001146b08940 +
        0x19b2d5ba 0x9a6fc10c 0x19ee341d 0x3cd37338 +
        0x3be89748 0x051c2db7 0xbb8b23c6 0xfcdd2294 +
        0x2366ebb6 0xb46fac8d 0x2b22d466 0x8b4d3d81 +
        0xe92c0fa2 0x0b6d5819 0x88fc7d14 0x14162837 

WRITEBLK  0x0000001c11f0b140 +
        0xf0883fa8 0x145a5538 0xd0b09bb2 0x69a3abfa +
        0x3e82c005 0x1dab7ee7 0xfbe07316 0x09bad143 +
        0xe955fa49 0xff571062 0x369fdbf8 0x439d923c +
        0x0e3795b9 0xa5d99ad4 0xa40e9853 0xf890c980 

READIO  0x0000060a74aa3440 4 0xe047195b 
WRITEMSKIO  0x000006174ae15ac0 0xf00f  0xfffe8cad 0x00000000 0x00000000 0x2f7db995 

WRITEIO  0x00000611b11566c0 4 0xc50a276b 

WRITEBLKIO  0x000006007f877d00 +
        0xd6f9f218 0x82aeb678 0x911177e9 0xf9302eab +
        0x4f27e3ce 0x7f6cc124 0x13ac13ab 0x85317e94 +
        0x9595a83b 0xa86de257 0x85136c1a 0x63eaf2c6 +
        0xd11974ce 0xce9a60b9 0xdafa3978 0xab4ed2d3 

READMSKIO   0x000006174ae15ac0 0xf00f  0xfffe8cad 0x00000000 0x00000000 0x2f7db995 

READBLK  0x00000019a40a9800 +
        0xd64a1b52 0x158a1d2e 0xa9d625d8 0x8a2f3c54 +
        0x2bfaf872 0x96de4ed4 0xb0df730b 0x483916ee +
        0xadef27fc 0xad623c6c 0x19473aaa 0x6bb07645 +
        0xb0647024 0x6c043098 0x3e6489ea 0x7e606745 


BA LABEL_0
