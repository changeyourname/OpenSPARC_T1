Default is to use the Synplicity netlist sparc.edf in the netlist subdir.

To use the XST netlist, move netlist/sparc.edf to this directory
and move sparc.ngc to the netlist directory.

Change data/iop_fpga_v2_1_0.bbd to point to the correct netlist.

NOTE: make sure there is only one netlist in the directory!!! 

Synplicity netlist "sparc.edf" is one-code-one-thread version of OpenSPARC T1 and
is used to synthesise the core with other Xilinx peripherals and Microblaze
to finally produce the corresponding bit file.

XST netlist "sparc_netlist.v" in the sim directory is one-code-one-thread version
of OpenSPARC T1 and is used for full-system simulation only.

