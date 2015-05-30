xtemac_example_readme.txt
-------------------------

The examples in this directory are provided to give the user some idea of
how the TEMAC and its driver are intended to be used.

SYSTEM REQUIREMENTS

The system containing the TEMAC should have the following capabilities:

  - PPC based system
  - At least one TEMAC core
  - An interrupt controller
  - An external memory controller with at least 200KB of RAM available
  - A UART to display messages

FILES

1. xtemac_example.h - Top level include for all examples.

2. xtemac_example_util.c - Provide various utilities for debugging, and 
   ethernet frame construction.

3. xtemac_example_polled.c - Examples using the L1 API found in xtemac.h
   in polled mode. HW must be setup for FIFO direct mode.

4. xtemac_example_intr_fifo.c - Examples using the L1 API found in
   xtemac.h in interrupt driven FIFO direct mode. HW must be setup for 
   FIFO direct mode.

5. xtemac_example_intr_sgdma.c - Examples using the L1 API found in 
   xtemac.h in interrupt driven scatter-gather DMA mode. HW must be setup
   for SGDMA mode. HW must be setup for checksum offloading for that
   specific example to properly execute.


INCLUDING EXAMPLES IN EDK

Each example is independent from the others except for common code found in 
xtemac_example_util.c. When including source code files in an EDK SW
application, select xtemac_example_util.c along with one other example
source code file.

SETUP

Examine xtemac_example.h. There are TODOs to take care of that will match
various system attributes to the examples.


OTHER NOTES

* Included HW features are critical as to which examples will run properly.
* PHY specific code is used to implement function Util_EnterLoopback().
