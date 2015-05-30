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


LABEL_0:

WRITEMSKIO  0x00000608b8122d80 0x00ff  0x00000000 0x00000000 0xb4f63774 0xa4fc4e0a 

WRITEMSKIO  0x0000061e69499a80 0xff0f  0xaf7f6e92 0xb69ff57f 0x00000000 0xf2d0b017 

WRITEMSKIO  0x0000061edd4452c0 0x0000  0x00000000 0x00000000 0x00000000 0x00000000 

WRITEBLK  0x0000000f0c5e5140 +
        0xb2841eaa 0x214e6b52 0xde2d88c7 0xac7575af +
        0x8ca7ba2c 0x32df8088 0xa3aba426 0x992f89b9 +
        0x35a0c769 0x3c573572 0x37d41c97 0x696e2895 +
        0x3fd66d68 0x114929ca 0xc9ff1af9 0x1380b8ee 

WRITEIO  0x0000060aaeedb580 8 0xe29a9ceb 0x01a8134f 

WRITEMSK  0x0000000f0c5e5140 0xf0000fff00fff000 +
        0x31086e46 0x00000000 0x00000000 0x00000000 +
        0x00000000 0xbc8ba76c 0x0522ff14 0x4668a9bd +
        0x00000000 0x00000000 0xe9acacf5 0x806cd74a +
        0xc39b1441 0x00000000 0x00000000 0x00000000 

READIO  0x0000060aaeedb580 8 0xe29a9ceb 0x01a8134f 
WRITEBLKIO  0x0000061e6cbe9680 +
        0x95402b09 0x65e6f0ea 0x20e34fcb 0xa03ee1f9 +
        0xad4832b3 0x655e45d3 0x5faaf32b 0xe7b2b8c3 +
        0xdb23b081 0x26b37798 0x33e408ad 0x95e7beea +
        0x22bbb230 0x527f527b 0x1be573c4 0xa749cc55 

WRITEMSK  0x0000000f0c5e5140 0xf0fff00f0000ff00 +
        0xd005b3b5 0x00000000 0x79cd3471 0xe593a358 +
        0xc415e370 0x00000000 0x00000000 0x17a9e166 +
        0x00000000 0x00000000 0x00000000 0x00000000 +
        0xdbbf71f9 0x53027412 0x00000000 0x00000000 

READMSKIO   0x00000608b8122d80 0x00ff  0x00000000 0x00000000 0xb4f63774 0xa4fc4e0a 

READBLK  0x0000000f0c5e5140 +
        0xd005b3b5 0x214e6b52 0x79cd3471 0xe593a358 +
        0xc415e370 0xbc8ba76c 0x0522ff14 0x17a9e166 +
        0x35a0c769 0x3c573572 0xe9acacf5 0x806cd74a +
        0xdbbf71f9 0x53027412 0xc9ff1af9 0x1380b8ee 

READBLKIO  0x0000061e6cbe9680 +
        0x95402b09 0x65e6f0ea 0x20e34fcb 0xa03ee1f9 +
        0xad4832b3 0x655e45d3 0x5faaf32b 0xe7b2b8c3 +
        0xdb23b081 0x26b37798 0x33e408ad 0x95e7beea +
        0x22bbb230 0x527f527b 0x1be573c4 0xa749cc55 

WRITEIO  0x0000061b12222e40 16 0x2a84e8cb 0xb313e4ea 0x0ebb591c 0xa6ae99ad 

WRITEBLKIO  0x000006108f4eca00 +
        0xffab21ee 0x66e5f9f7 0x57533e90 0x43c74269 +
        0xed20c1bf 0x6f200788 0xf9682b77 0x46765c2d +
        0xc2135bb8 0x6aadfd54 0x364d1250 0x42fed86f +
        0x95ceb248 0xe50b7a13 0xcb9300df 0x4334d4e0 

WRITEMSKIO  0x00000614ebf60f00 0x00f0  0x00000000 0x00000000 0x442289f1 0x00000000 

WRITEBLKIO  0x0000061947157b80 +
        0xbdd0b247 0xd950e471 0x208eb9dc 0xe040ae1b +
        0x5a55a2a7 0xe12333ba 0x6d850183 0xebc9117d +
        0x30026f6d 0xf9d627c4 0x5d29bf66 0x227beab9 +
        0xdc6a1c11 0x5c86f9e0 0xd2be3c97 0x8a2ec596 

WRITEBLKIO  0x00000600e7499400 +
        0x0d366a80 0xc77f7003 0x6ee6ac96 0x2f18e319 +
        0xe3172cdd 0x7e0a7937 0xab9fba62 0x55557f69 +
        0x25f8edb0 0x2c10bbba 0xca354559 0x47d074aa +
        0x9d8a8d5f 0xa18850ea 0x5b291504 0x1cd354b1 

WRITEMSKIO  0x000006025b39ce80 0xff00  0x9cfbbabf 0x9f9eba62 0x00000000 0x00000000 

WRITEMSKIO  0x00000617da96a840 0xffff  0x429c2016 0x5caee9fe 0x3520ca0b 0xbd92e5bd 

READIO  0x0000061b12222e40 16 0x2a84e8cb 0xb313e4ea 0x0ebb591c 0xa6ae99ad 
WRITEBLKIO  0x0000061b744b9740 +
        0xbd9e4e22 0x7582dbf5 0xab0a8536 0xd33e18d1 +
        0xb00fc5f1 0xfadb8540 0xcdbb3af4 0x14f1d696 +
        0xf2aa975c 0x17b319e6 0xfa5ec8c7 0x603f5a25 +
        0x774a27bc 0xb9ccc457 0xd6877c34 0x493c5da5 

WRITEIO  0x0000061890bd9a00 16 0xea54fec7 0x84377d2e 0x1e0d7c29 0x9aa94697 

READMSKIO   0x0000061e69499a80 0xff0f  0xaf7f6e92 0xb69ff57f 0x00000000 0xf2d0b017 

READBLKIO  0x000006108f4eca00 +
        0xffab21ee 0x66e5f9f7 0x57533e90 0x43c74269 +
        0xed20c1bf 0x6f200788 0xf9682b77 0x46765c2d +
        0xc2135bb8 0x6aadfd54 0x364d1250 0x42fed86f +
        0x95ceb248 0xe50b7a13 0xcb9300df 0x4334d4e0 

WRITEBLK  0x0000000f37537c00 +
        0x640b5e06 0xb888305e 0x72415a43 0x5155a164 +
        0xff3358bf 0xfba4801b 0x81162c97 0x8c6889a7 +
        0x8942695f 0x2adbbe6b 0xe12ed9c8 0x7c63fdbe +
        0x71bdca92 0x120b05e0 0x3abe5d8d 0xaac3a19c 

WRITEMSK  0x0000000f37537c00 0x0f0f000f0ff0f0f0 +
        0x00000000 0xe84190cc 0x00000000 0xdee186e7 +
        0x00000000 0x00000000 0x00000000 0x77a14803 +
        0x00000000 0x95f7550d 0x62de6af7 0x00000000 +
        0xe5e7e221 0x00000000 0xb6fcd20a 0x00000000 

WRITEIO  0x0000061831a96500 8 0xe5af9462 0xf2a628d5 

READIO  0x0000061890bd9a00 16 0xea54fec7 0x84377d2e 0x1e0d7c29 0x9aa94697 
WRITEMSKIO  0x000006151d05f580 0x0f0f  0x00000000 0x3ccf7204 0x00000000 0x3cdcc9c9 

READBLK  0x0000000f37537c00 +
        0x640b5e06 0xe84190cc 0x72415a43 0xdee186e7 +
        0xff3358bf 0xfba4801b 0x81162c97 0x77a14803 +
        0x8942695f 0x95f7550d 0x62de6af7 0x7c63fdbe +
        0xe5e7e221 0x120b05e0 0xb6fcd20a 0xaac3a19c 

WRITEMSKIO  0x0000060f873b8100 0xf0f0  0x929db0d5 0x00000000 0x90ed5ba5 0x00000000 

WRITEMSKIO  0x0000061e8c3fb480 0xf000  0xf28ce9a0 0x00000000 0x00000000 0x00000000 

WRITEIO  0x00000608467dd680 4 0x0d86fcc3 

READMSKIO   0x0000061edd4452c0 0x0000  0x00000000 0x00000000 0x00000000 0x00000000 

READIO  0x0000061831a96500 8 0xe5af9462 0xf2a628d5 
WRITEBLK  0x0000001fb7d96b00 +
        0x069878db 0x20840b75 0xd8e2f408 0x505eb320 +
        0xf79b9acf 0xf87e268a 0x24a0cecf 0xa8f77182 +
        0x0d86e4de 0x629e438e 0xd533cb76 0x27f837a8 +
        0x785a3413 0xa8d11e3d 0x9ff3682d 0x951ec628 

WRITEIO  0x00000604e4eb9bc0 8 0xd67569e9 0x2d55ba0c 

READMSKIO   0x00000614ebf60f00 0x00f0  0x00000000 0x00000000 0x442289f1 0x00000000 

READBLKIO  0x0000061947157b80 +
        0xbdd0b247 0xd950e471 0x208eb9dc 0xe040ae1b +
        0x5a55a2a7 0xe12333ba 0x6d850183 0xebc9117d +
        0x30026f6d 0xf9d627c4 0x5d29bf66 0x227beab9 +
        0xdc6a1c11 0x5c86f9e0 0xd2be3c97 0x8a2ec596 

READIO  0x00000608467dd680 4 0x0d86fcc3 
WRITEMSK  0x0000001fb7d96b00 0xf0f0f00f0000f00f +
        0x5f87f41a 0x00000000 0x2b51c5ad 0x00000000 +
        0xa677ade2 0x00000000 0x00000000 0xf1d53c3a +
        0x00000000 0x00000000 0x00000000 0x00000000 +
        0x5ec437a6 0x00000000 0x00000000 0xeaee211f 

WRITEBLK  0x0000000b94dfb480 +
        0xfd1e3695 0x9dfa70df 0xc6ea52f3 0x0dd224de +
        0xa7dfc31f 0xd6dd1fc5 0x75471a60 0x7610f27b +
        0x920bf771 0x4b0fd2eb 0xe4483fbb 0x695981eb +
        0x24ce82ff 0x273fbb58 0xbbf01c5a 0xd85ff133 

READBLK  0x0000001fb7d96b00 +
        0x5f87f41a 0x20840b75 0x2b51c5ad 0x505eb320 +
        0xa677ade2 0xf87e268a 0x24a0cecf 0xf1d53c3a +
        0x0d86e4de 0x629e438e 0xd533cb76 0x27f837a8 +
        0x5ec437a6 0xa8d11e3d 0x9ff3682d 0xeaee211f 

READBLK  0x0000000b94dfb480 +
        0xfd1e3695 0x9dfa70df 0xc6ea52f3 0x0dd224de +
        0xa7dfc31f 0xd6dd1fc5 0x75471a60 0x7610f27b +
        0x920bf771 0x4b0fd2eb 0xe4483fbb 0x695981eb +
        0x24ce82ff 0x273fbb58 0xbbf01c5a 0xd85ff133 

READBLKIO  0x00000600e7499400 +
        0x0d366a80 0xc77f7003 0x6ee6ac96 0x2f18e319 +
        0xe3172cdd 0x7e0a7937 0xab9fba62 0x55557f69 +
        0x25f8edb0 0x2c10bbba 0xca354559 0x47d074aa +
        0x9d8a8d5f 0xa18850ea 0x5b291504 0x1cd354b1 

WRITEIO  0x0000061959146180 8 0xf61a3ad0 0x7615d1fe 

READIO  0x00000604e4eb9bc0 8 0xd67569e9 0x2d55ba0c 
READMSKIO   0x000006025b39ce80 0xff00  0x9cfbbabf 0x9f9eba62 0x00000000 0x00000000 

WRITEIO  0x0000060755e35500 4 0xbe84427a 

WRITEIO  0x00000609e21508c0 8 0x79a64547 0x8c286033 

READMSKIO   0x00000617da96a840 0xffff  0x429c2016 0x5caee9fe 0x3520ca0b 0xbd92e5bd 

READMSKIO   0x000006151d05f580 0x0f0f  0x00000000 0x3ccf7204 0x00000000 0x3cdcc9c9 

WRITEMSKIO  0x00000618d6cd6980 0xf0f0  0x197c4a0b 0x00000000 0x92aa8a40 0x00000000 

READBLKIO  0x0000061b744b9740 +
        0xbd9e4e22 0x7582dbf5 0xab0a8536 0xd33e18d1 +
        0xb00fc5f1 0xfadb8540 0xcdbb3af4 0x14f1d696 +
        0xf2aa975c 0x17b319e6 0xfa5ec8c7 0x603f5a25 +
        0x774a27bc 0xb9ccc457 0xd6877c34 0x493c5da5 

WRITEBLK  0x000000059f610b80 +
        0x3199ea27 0x415afc15 0x8e3fa4a8 0x18f15eac +
        0xf80c9541 0x7aad1228 0x0fd5015b 0xbdbcbfa5 +
        0x746b5d95 0xc48f5cca 0xf41a4198 0x80dbfa44 +
        0x873b5630 0x937b66c6 0xc784fc1f 0xfc23a17a 

WRITEMSK  0x000000059f610b80 0x0ffff000f00ff0ff +
        0x00000000 0xc8594056 0x72e287ca 0xd64fda3d +
        0x9848496b 0x00000000 0x00000000 0x00000000 +
        0x717e3d6d 0x00000000 0x00000000 0x9d446004 +
        0x586135f5 0x00000000 0x7877dce3 0xef713643 

READBLK  0x000000059f610b80 +
        0x3199ea27 0xc8594056 0x72e287ca 0xd64fda3d +
        0x9848496b 0x7aad1228 0x0fd5015b 0xbdbcbfa5 +
        0x717e3d6d 0xc48f5cca 0xf41a4198 0x9d446004 +
        0x586135f5 0x937b66c6 0x7877dce3 0xef713643 

READMSKIO   0x0000060f873b8100 0xf0f0  0x929db0d5 0x00000000 0x90ed5ba5 0x00000000 

READMSKIO   0x0000061e8c3fb480 0xf000  0xf28ce9a0 0x00000000 0x00000000 0x00000000 

WRITEMSKIO  0x0000061df14cf6c0 0xfff0  0xb4d08477 0xd9f1667e 0x51faf7c1 0x00000000 

WRITEMSKIO  0x000006122bd84440 0x0fff  0x00000000 0x2d63e70a 0x8e823245 0x8177987b 

WRITEIO  0x0000061caffcf300 4 0xff178103 

READIO  0x0000061959146180 8 0xf61a3ad0 0x7615d1fe 
READMSKIO   0x00000618d6cd6980 0xf0f0  0x197c4a0b 0x00000000 0x92aa8a40 0x00000000 

WRITEBLK  0x0000000802c30100 +
        0xed20521c 0x2c5ca23a 0x9dbfc733 0xcff80e7c +
        0x90d2bfe0 0x8bc48489 0x5009f5bc 0x59642380 +
        0x7600f18f 0x5c2517ec 0x2854bd5f 0xd02ce1bf +
        0x0fc04535 0x578a6fd9 0xf85d7569 0x8df3c29c 

WRITEMSKIO  0x0000061b9c525800 0x0f00  0x00000000 0x70c1d006 0x00000000 0x00000000 

READIO  0x0000060755e35500 4 0xbe84427a 
READIO  0x00000609e21508c0 8 0x79a64547 0x8c286033 
WRITEIO  0x000006092a2c2540 4 0x7de0fe16 

READBLK  0x0000000802c30100 +
        0xed20521c 0x2c5ca23a 0x9dbfc733 0xcff80e7c +
        0x90d2bfe0 0x8bc48489 0x5009f5bc 0x59642380 +
        0x7600f18f 0x5c2517ec 0x2854bd5f 0xd02ce1bf +
        0x0fc04535 0x578a6fd9 0xf85d7569 0x8df3c29c 

WRITEIO  0x000006054521cc80 4 0xcb799a9f 

WRITEBLK  0x00000017f4cd7f00 +
        0xcecb9324 0xde689457 0xef997205 0x5634d7a0 +
        0xa0911609 0xa00741c9 0x6bffc8bb 0x56c9da1a +
        0xbd08f2c0 0x08e99225 0x36df4c6f 0x876cb63c +
        0x4e993438 0x10f89b95 0x256f0c37 0xd66639ca 

READIO  0x0000061caffcf300 4 0xff178103 
WRITEBLKIO  0x00000611b7b0b3c0 +
        0xbc6ffc7a 0x77fd9f15 0x75b29815 0x61c6e9a4 +
        0x3154236b 0x34f112a0 0xdd94d4ff 0xf6f5b1c7 +
        0xee3a9d70 0x39461afd 0xd0e25534 0x9c3586ca +
        0xf24129ca 0x6a521cfa 0xd0a30cb7 0x20b34831 

WRITEBLK  0x0000000a043379c0 +
        0x3d1291d4 0x956e5dab 0x87d1dfe6 0x3da7c460 +
        0xe9f927ff 0xa4c6a7d3 0xb5a9b47a 0x41dca1f7 +
        0x81753b3b 0xd786165c 0x6a01a437 0x83f0d9d6 +
        0xd9e21fa9 0x258a47e7 0x1d75b69e 0xb17b0d41 

WRITEMSK  0x00000017f4cd7f00 0x0f0fff0fffffffff +
        0x00000000 0x05902180 0x00000000 0x9b4a5a5f +
        0x794aae0a 0xcb05161b 0x00000000 0xf39ab388 +
        0x5a2ff392 0xb170be98 0x07ce3b2c 0x2e8b7577 +
        0xfeaa49c1 0xe2a82e91 0xbb19863e 0xd560b586 

READBLK  0x00000017f4cd7f00 +
        0xcecb9324 0x05902180 0xef997205 0x9b4a5a5f +
        0x794aae0a 0xcb05161b 0x6bffc8bb 0xf39ab388 +
        0x5a2ff392 0xb170be98 0x07ce3b2c 0x2e8b7577 +
        0xfeaa49c1 0xe2a82e91 0xbb19863e 0xd560b586 

WRITEBLK  0x000000119cc52400 +
        0x5cb2e468 0xda87404f 0x6f2ea891 0x5c4b85b5 +
        0x67166b1f 0x12bd7472 0x737f31aa 0xf956f984 +
        0x11e0a27e 0x061be572 0xd3d3d842 0xa48459da +
        0x5b79bbfc 0x56a9dda8 0xfbada63c 0xb0809fac 

WRITEMSK  0x0000000a043379c0 0xff0ffffffff00000 +
        0x582ef577 0xa8e8eecf 0x00000000 0x55b35b9f +
        0xca0ae912 0x9ab66c8b 0xdb55de45 0xeff73440 +
        0xb52cee0e 0xa4b18058 0x2f0440ea 0x00000000 +
        0x00000000 0x00000000 0x00000000 0x00000000 

READBLK  0x0000000a043379c0 +
        0x582ef577 0xa8e8eecf 0x87d1dfe6 0x55b35b9f +
        0xca0ae912 0x9ab66c8b 0xdb55de45 0xeff73440 +
        0xb52cee0e 0xa4b18058 0x2f0440ea 0x83f0d9d6 +
        0xd9e21fa9 0x258a47e7 0x1d75b69e 0xb17b0d41 

READBLKIO  0x00000611b7b0b3c0 +
        0xbc6ffc7a 0x77fd9f15 0x75b29815 0x61c6e9a4 +
        0x3154236b 0x34f112a0 0xdd94d4ff 0xf6f5b1c7 +
        0xee3a9d70 0x39461afd 0xd0e25534 0x9c3586ca +
        0xf24129ca 0x6a521cfa 0xd0a30cb7 0x20b34831 

WRITEMSK  0x000000119cc52400 0xffff00f0ff00000f +
        0xf887686f 0x11c58139 0x073c308a 0x264e5eb3 +
        0x00000000 0x00000000 0x89725f37 0x00000000 +
        0x2cb71979 0x64b8bd4d 0x00000000 0x00000000 +
        0x00000000 0x00000000 0x00000000 0x318c2eb3 


BA LABEL_0
