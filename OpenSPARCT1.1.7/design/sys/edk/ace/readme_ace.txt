
========================================================
Instructions to directly run ACE files
========================================================

1. Copy the OpenSPARCT1_1_7_os_boot.ace into one of
   the partitions of the compact flash card provided by
   Xilinx with a Virtex ML410 or ML505 board.

2. Set the SYSACE_CONFG switch on the Xilinx board to the
   partition number the ace file is copied into

3. Restart the FPGA.


========================================================
Instructions to directly run ACE files for a 2-board system
========================================================

1. Copy the OpenSPARCT1_1_7_2core_master.ace into one of 
   the partitions of the compact flash card provided by 
   Xilinx with a Virtex ML410 or ML505 board.

2. Copy the OpenSPARCT1_1_7_2core_slave.ace into one of 
   the partitions of a second compact flash card.

3. Connect two ML505-V5LX110T boards together in a system,
   using the red SATA crossover cable to connect the SATA
   port 2 on each board.

4. Connect the serial port of the board to a computer, and open
   a terminal on that computer to the serial port.

5. Set the SYSACE_CONFG switch on each board to the
   partition number the ace file is copied into.

6. Set the corner DIP switch (switches 6,7,8) to select the
   CPU ID.  (0 for master, 1 for slave).

7. Power on the slave board first.  Wait about five seconds.

8. Power on the master board.


For further information, please refer to the OpenSPARC
T1 Design and Verification Guide and the XMD Tutorial
from Xilinx.


ACE Files provided:
===================
OpenSPARCT1_1_7_os_boot.ace		Release 1.7 for ML505-XC5VLX110T board
					Boots OpenSolaris
OpenSPARCT1_1_7_2core_master.ace	Release 1.7 for ML505-XC5VLX110T board
					This image is for the master board of
					a two-board system.
					Boots OpenSolaris
OpenSPARCT1_1_7_2core_slave.ace		Release 1.7 for ML505-XC5VLX110T board
					This image is for the slave board of a
					two-board system.

