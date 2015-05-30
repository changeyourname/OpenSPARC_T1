#!/bin/sh

PATH=${XILINX_EDK}/gnu/microblaze/lin64/bin:$PATH

# Build SVF stream for base hardware configuration

impact -batch hardware.scr

# Build SVF stream to load software images

rm -f software.svf

# Slave left (FPGA A)
xmd -tcl genace_bee3.tcl -jprog -target mdm -board bee3_a             \
    -elf  ../../ccx-firmware-slave/executable.elf                     \
    -data ../../../edk/os/proms/2c4t_obp_prom.bin 0x8ff00000          \
    -ace bee3_fpga_A_sw.ace
rm -f bee3_fpga_A_sw.ace
cat bee3_fpga_A_sw.svf >> software.svf

# Slave right (FPGA D)
xmd -tcl genace_bee3.tcl -jprog -target mdm -board bee3_d             \
    -elf  ../../ccx-firmware-slave/executable.elf                     \
    -data ../../../edk/os/proms/2c4t_obp_prom.bin 0x8ff00000          \
    -ace bee3_fpga_D_sw.ace
rm -f bee3_fpga_D_sw.ace
cat bee3_fpga_D_sw.svf >> software.svf

# Master left (FPGA B)
xmd -tcl genace_bee3.tcl -jprog -target mdm -board bee3_b             \
    -elf  ../../ccx-firmware/executable.elf                           \
    -data ../../../edk/os/proms/2c4t_obp_prom.bin 0x8ff00000          \
    -data ../../../edk/os/OpenSolaris/proto/ramdisk.snv-b77-nd.no-boot-time-network.gz 0x8af00000 \
    -ace bee3_fpga_B_sw.ace
rm -f bee3_fpga_B_sw.ace
cat bee3_fpga_B_sw.svf >> software.svf

# Master right (FPGA C)
xmd -tcl genace_bee3.tcl -jprog -target mdm -board bee3_c             \
    -elf  ../../ccx-firmware/executable.elf                           \
    -data ../../../edk/os/proms/2c4t_obp_prom.bin 0x8ff00000          \
    -data ../../../edk/os/OpenSolaris/proto/ramdisk.snv-b77-nd.no-boot-time-network.gz 0x8af00000 \
    -ace bee3_fpga_C_sw.ace
rm -f bee3_fpga_C_sw.ace
cat bee3_fpga_C_sw.svf >> software.svf

# Concatenate SVF streams and convert to ACE

echo
echo "Converting SVF to ACE..."

rm -f full_bee3.svf
cat hardware.svf >> full_bee3.svf
cat software.svf >> full_bee3.svf
impact -batch full_bee3.scr 2>full_bee3.log 1>&2

echo "ACE file generation complete"

# Clean up generated files

rm -f *.svf
rm -f bit2svf.scr svf2ace.scr
rm -f _impactbatch.log

