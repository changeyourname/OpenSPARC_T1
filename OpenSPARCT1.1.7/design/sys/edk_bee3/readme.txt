
This directory contains a port of the dual-core OpenSPARC T1 FPGA implementation
for the BEE3 hardware platform.  The hardware, firmware, and software
architectures are preserved.  Changes were made only to the target FPGA device,
memory controller, external resets, Aurora GTP parameters, and physical
constraints (pinouts, locations, etc.), each of which is necessary to match
the underlying hardware configuration on BEE3.

A CX4 cable must be connected between ports "CX4 A 1" and "CX4 B 1" and also
between "CX4 C 1" and "CX4 D 1" on the BEE3 front panel.  These cables provide
the necessary connections between the master and slave T1 cores.

In addition, the on-board jumpers must be set properly to define the CPU ID for
each T1 core.  FPGAs A and D are slave cores (cpu_id = 01), and FPGAs B and C
are master cores (cpu_id = 00).  The jumpers on BEE3 pull each signal to ground,
therefore FPGAs A and D (the front FPGAs) must have the lowest jumper row open
and the second-lowest jumper row shunted, while FPGAs B and C (the rear FPGAs)
must have both of the two lowest jumper rows shunted.

The current BEE3 port does not fully support networking, therefore the default
Solaris RAM disk image for BEE3 skips network initialization during boot.

The 'bee3_util' subdirectory contains scripts for generating a SystemACE file
and for directly programming the system via JTAG.  These scripts are located in
'bee3_util/ace' and 'bee3_util/prog', respectively.


To build the BEE3 OpenSPARC T1 dual-core system, follow these steps:

1) Run the project setup script:
    >> ./setup_bee3_proj.pl

2) Download the BEE3 basic memory controller core and drivers from:
   http://www.beecube.com/opensparc/edk_bee3.1.7.tar.gz

3) Unpack the archive in the current directory:
    >> tar -zxvf edk_bee3.1.7.tar.gz

4) Run Xilinx Platform Studio in batch mode:
    >> xps -nw dual_core.xmp

5) From the XPS prompt, build the firmware applications:
    >> XPS% run program

6) From the XPS prompt, build the complete hardware system:
    >> XPS% run init_bram

7) Verify that the build completed successfully, then exit XPS:
    >> XPS% exit

8) Verify that all connections to the BEE3 system are up and running (jumpers,
   CX4 cables, serial consoles, JTAG, etc.)

9a) Generate a SystemACE file (the fastest programming method):
    >> cd bee3_util/ace
    >> sh full_bee3.sh

9b) Program the FPGAs directly via JTAG:
    >> cd bee3_util/prog
    >> sh jtag_prog.sh

Once programmed, the OpenSPARC cores will be initialized and begin booting, just
as with the standard FPGA implementation.  Please refer to the main OpenSPARC
documentation for more information on the boot process and different OS
alternatives.
