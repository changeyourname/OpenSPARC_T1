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

WRITEMSKIO  0x00000612ff0eccc0 0xf0f0  0x6c983272 0x00000000 0xbbeff760 0x00000000 

READMSKIO   0x00000612ff0eccc0 0xf0f0  0x6c983272 0x00000000 0xbbeff760 0x00000000 

WRITEIO  0x00000613dd916600 8 0xf463b4ef 0xbb37dfd5 

WRITEBLKIO  0x00000601e5c73ec0 +
        0x14c6e6cc 0x11205ffc 0x08ff0ca9 0x8b3781b3 +
        0x74ce7711 0xcd63b969 0xbcaf542e 0x0ab97b6f +
        0xe3cb8afa 0xea3e1107 0xe3855558 0x8b4a8856 +
        0x4ee6462c 0x9d56ad41 0x9762ee5a 0x791723a1 

WRITEBLKIO  0x00000613a40f1040 +
        0x5036ef9c 0x3e8a2208 0x5800cde7 0x4e3bea29 +
        0x16f604ab 0x38a54398 0x32268065 0xcf4e588f +
        0x1c9c5159 0x30775d52 0x3bcc18a6 0x5e6b9a53 +
        0x98634410 0xd8a330cc 0x51735dab 0xbb2392c7 

WRITEBLKIO  0x0000060ed7e13900 +
        0xf73d366b 0xfac79c90 0xb4aeaf96 0x5361f826 +
        0x29731923 0x92960cd2 0x5dd9cecc 0xe11b532f +
        0x61256dbc 0xe61dd63e 0xf46b0546 0x9d509899 +
        0x57ddde47 0x930be9ac 0x577ecb8b 0x8ad0ee59 

WRITEMSKIO  0x0000061794afc440 0x00f0  0x00000000 0x00000000 0xe7065b7b 0x00000000 

WRITEIO  0x0000060ab4228c00 4 0x25e70a98 

WRITEMSKIO  0x000006009374bec0 0xf00f  0x21b936d3 0x00000000 0x00000000 0x9fc78ed8 

WRITEBLKIO  0x00000603efde9a40 +
        0x615dfb7b 0x0a6795cc 0x51964c74 0x5816b23c +
        0x2cf1a72e 0x09ceb27b 0x88c4ad8b 0x0e26f0eb +
        0x9cb38116 0xdc66675b 0x33e27d91 0x475b009b +
        0x4c32ff77 0x3ee073d2 0x5ba0f6ea 0xae2a6227 

WRITEIO  0x0000060dc1bf5cc0 8 0xee03a85f 0x9efba71e 

WRITEMSKIO  0x00000606e3ae41c0 0xf000  0xab7a4796 0x00000000 0x00000000 0x00000000 

READMSKIO   0x0000061794afc440 0x00f0  0x00000000 0x00000000 0xe7065b7b 0x00000000 

READBLKIO  0x00000601e5c73ec0 +
        0x14c6e6cc 0x11205ffc 0x08ff0ca9 0x8b3781b3 +
        0x74ce7711 0xcd63b969 0xbcaf542e 0x0ab97b6f +
        0xe3cb8afa 0xea3e1107 0xe3855558 0x8b4a8856 +
        0x4ee6462c 0x9d56ad41 0x9762ee5a 0x791723a1 

WRITEMSKIO  0x0000060c4b839940 0x0000  0x00000000 0x00000000 0x00000000 0x00000000 

WRITEMSKIO  0x0000061816e4ab00 0xffff  0xeadfd3cc 0xf3792805 0x86d35f2f 0x42ff74d2 

READBLKIO  0x00000613a40f1040 +
        0x5036ef9c 0x3e8a2208 0x5800cde7 0x4e3bea29 +
        0x16f604ab 0x38a54398 0x32268065 0xcf4e588f +
        0x1c9c5159 0x30775d52 0x3bcc18a6 0x5e6b9a53 +
        0x98634410 0xd8a330cc 0x51735dab 0xbb2392c7 

WRITEBLKIO  0x00000600e4934f80 +
        0xfc135ede 0xf6cd5761 0x9eba8950 0x1fd38af7 +
        0x3024cac8 0x82ec3b5b 0xc905288f 0x1c034222 +
        0x6453bac4 0xb8796d48 0xd6b1d019 0x94432ad2 +
        0x51ffe57d 0xdc40609b 0xccc48ce6 0x7e61e7c8 

READMSKIO   0x000006009374bec0 0xf00f  0x21b936d3 0x00000000 0x00000000 0x9fc78ed8 

WRITEIO  0x00000617fcf54040 4 0x168c27a7 

READBLKIO  0x0000060ed7e13900 +
        0xf73d366b 0xfac79c90 0xb4aeaf96 0x5361f826 +
        0x29731923 0x92960cd2 0x5dd9cecc 0xe11b532f +
        0x61256dbc 0xe61dd63e 0xf46b0546 0x9d509899 +
        0x57ddde47 0x930be9ac 0x577ecb8b 0x8ad0ee59 

WRITEMSKIO  0x0000061e7f91a580 0xff0f  0x1f97e7f6 0x2d73b03d 0x00000000 0x0f83492a 

READBLKIO  0x00000603efde9a40 +
        0x615dfb7b 0x0a6795cc 0x51964c74 0x5816b23c +
        0x2cf1a72e 0x09ceb27b 0x88c4ad8b 0x0e26f0eb +
        0x9cb38116 0xdc66675b 0x33e27d91 0x475b009b +
        0x4c32ff77 0x3ee073d2 0x5ba0f6ea 0xae2a6227 

WRITEIO  0x0000061e12ebb1c0 4 0xd3563502 

READIO  0x00000613dd916600 8 0xf463b4ef 0xbb37dfd5 
WRITEBLK  0x00000001058a26c0 +
        0xbd980410 0x9865edcc 0x0bca0c1d 0xcec766fd +
        0xc93a647e 0x7d9c2bda 0x73bf6743 0x5718f1c3 +
        0x940fe938 0xb990fd02 0xd44e3fcd 0x7aebc89c +
        0xe56e3aa9 0x20b23dc7 0x46800daa 0x46d5106b 

READMSKIO   0x00000606e3ae41c0 0xf000  0xab7a4796 0x00000000 0x00000000 0x00000000 

WRITEMSK  0x00000001058a26c0 0x0ffff0f0f0f0ff0f +
        0x00000000 0xd1d16619 0xe22ea2bd 0x7562a1d1 +
        0x2211e6ae 0x00000000 0xc241bb76 0x00000000 +
        0x69ec66f7 0x00000000 0x64f1aeb8 0x00000000 +
        0x06fdad3b 0xc9e49193 0x00000000 0x58ba862e 

READIO  0x0000060ab4228c00 4 0x25e70a98 
READBLK  0x00000001058a26c0 +
        0xbd980410 0xd1d16619 0xe22ea2bd 0x7562a1d1 +
        0x2211e6ae 0x7d9c2bda 0xc241bb76 0x5718f1c3 +
        0x69ec66f7 0xb990fd02 0x64f1aeb8 0x7aebc89c +
        0x06fdad3b 0xc9e49193 0x46800daa 0x58ba862e 

WRITEBLK  0x0000001d72c4c780 +
        0x713fc6d9 0x0e270c8b 0x2dd1bfab 0x3a8ef637 +
        0x6153331b 0x69cbd6ad 0xe9ce38d0 0xc31a77cb +
        0xfcf61620 0x15fb4d50 0x0b30ec3f 0x647616c2 +
        0x7221b4b0 0x047cab41 0xbec4c584 0x1edf8692 

READBLKIO  0x00000600e4934f80 +
        0xfc135ede 0xf6cd5761 0x9eba8950 0x1fd38af7 +
        0x3024cac8 0x82ec3b5b 0xc905288f 0x1c034222 +
        0x6453bac4 0xb8796d48 0xd6b1d019 0x94432ad2 +
        0x51ffe57d 0xdc40609b 0xccc48ce6 0x7e61e7c8 


BA LABEL_0
